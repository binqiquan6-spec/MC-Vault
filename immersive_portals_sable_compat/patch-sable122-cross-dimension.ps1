param(
    [Parameter(Mandatory = $true)]
    [string]$InputJar,

    [Parameter(Mandatory = $true)]
    [string]$OutputJar
)

$ErrorActionPreference = 'Stop'

function Read-U2BE {
    param([byte[]]$Data, [int]$Offset)
    return ([int]$Data[$Offset] -shl 8) -bor [int]$Data[$Offset + 1]
}

function Read-U4BE {
    param([byte[]]$Data, [int]$Offset)
    return ([int]$Data[$Offset] -shl 24) -bor
        ([int]$Data[$Offset + 1] -shl 16) -bor
        ([int]$Data[$Offset + 2] -shl 8) -bor
        [int]$Data[$Offset + 3]
}

function Skip-Members {
    param(
        [byte[]]$Data,
        [int]$Offset
    )

    $count = Read-U2BE -Data $Data -Offset $Offset
    $position = $Offset + 2
    for ($i = 0; $i -lt $count; $i++) {
        $attributeCount = Read-U2BE -Data $Data -Offset ($position + 6)
        $position += 8
        for ($j = 0; $j -lt $attributeCount; $j++) {
            $attributeLength = Read-U4BE -Data $Data -Offset ($position + 2)
            $position += 6 + $attributeLength
        }
    }
    return $position
}

function Patch-PhysicsStepGuard {
    param([byte[]]$Data)

    if ($Data.Length -lt 10 -or
        $Data[0] -ne 0xca -or $Data[1] -ne 0xfe -or
        $Data[2] -ne 0xba -or $Data[3] -ne 0xbe) {
        throw '不是有效的 Java class 文件'
    }

    $patched = [byte[]]$Data.Clone()
    $constantPoolCount = Read-U2BE -Data $patched -Offset 8
    $constantPool = @{}
    $position = 10
    $index = 1

    while ($index -lt $constantPoolCount) {
        $tag = [int]$patched[$position]
        $entry = @{ Tag = $tag }
        $position++
        switch ($tag) {
            1 {
                $length = Read-U2BE -Data $patched -Offset $position
                $entry.Value = [System.Text.Encoding]::UTF8.GetString($patched, $position + 2, $length)
                $position += 2 + $length
            }
            { $_ -in 3, 4 } { $position += 4 }
            { $_ -in 5, 6 } { $position += 8; $index++ }
            7 { $entry.NameIndex = Read-U2BE -Data $patched -Offset $position; $position += 2 }
            8 { $position += 2 }
            { $_ -in 9, 10, 11 } {
                $entry.ClassIndex = Read-U2BE -Data $patched -Offset $position
                $entry.NameAndTypeIndex = Read-U2BE -Data $patched -Offset ($position + 2)
                $position += 4
            }
            12 {
                $entry.NameIndex = Read-U2BE -Data $patched -Offset $position
                $entry.DescriptorIndex = Read-U2BE -Data $patched -Offset ($position + 2)
                $position += 4
            }
            { $_ -in 16, 19, 20 } { $position += 2 }
            { $_ -in 17, 18 } { $position += 4 }
            15 { $position += 3 }
            default { throw "未知的 class 常量池标签：$tag" }
        }
        $constantPool[$index] = $entry
        $index++
    }

    $targetFieldIndex = $null
    foreach ($candidateIndex in $constantPool.Keys) {
        $candidate = $constantPool[$candidateIndex]
        if ($candidate.Tag -ne 9) { continue }
        $classEntry = $constantPool[$candidate.ClassIndex]
        $nameAndType = $constantPool[$candidate.NameAndTypeIndex]
        $owner = $constantPool[$classEntry.NameIndex].Value
        $name = $constantPool[$nameAndType.NameIndex].Value
        $descriptor = $constantPool[$nameAndType.DescriptorIndex].Value
        if ($owner -eq 'dev/ryanhcode/sable/sublevel/system/SubLevelPhysicsSystem' -and
            $name -eq 'IN_PHYSICS_STEP' -and $descriptor -eq 'Z') {
            $targetFieldIndex = [int]$candidateIndex
            break
        }
    }
    if ($null -eq $targetFieldIndex) { throw '找不到 Sable IN_PHYSICS_STEP 字段引用' }

    $position += 6
    $interfaceCount = Read-U2BE -Data $patched -Offset $position
    $position += 2 + (2 * $interfaceCount)
    $position = Skip-Members -Data $patched -Offset $position

    $methodCount = Read-U2BE -Data $patched -Offset $position
    $position += 2
    $replacementCount = 0
    for ($i = 0; $i -lt $methodCount; $i++) {
        $methodNameIndex = Read-U2BE -Data $patched -Offset ($position + 2)
        $methodDescriptorIndex = Read-U2BE -Data $patched -Offset ($position + 4)
        $attributeCount = Read-U2BE -Data $patched -Offset ($position + 6)
        $methodName = $constantPool[$methodNameIndex].Value
        $methodDescriptor = $constantPool[$methodDescriptorIndex].Value
        $position += 8

        for ($j = 0; $j -lt $attributeCount; $j++) {
            $attributeNameIndex = Read-U2BE -Data $patched -Offset $position
            $attributeLength = Read-U4BE -Data $patched -Offset ($position + 2)
            $attributeName = $constantPool[$attributeNameIndex].Value
            $attributeData = $position + 6

            if ($methodName -eq 'tick' -and
                $methodDescriptor -eq '(Lnet/minecraft/server/MinecraftServer;)V' -and
                $attributeName -eq 'Code') {
                $codeLength = Read-U4BE -Data $patched -Offset ($attributeData + 4)
                $codeStart = $attributeData + 8
                $fieldHigh = ($targetFieldIndex -shr 8) -band 0xff
                $fieldLow = $targetFieldIndex -band 0xff
                for ($k = $codeStart; $k -le $codeStart + $codeLength - 3; $k++) {
                    if ($patched[$k] -eq 0xb2 -and
                        $patched[$k + 1] -eq $fieldHigh -and
                        $patched[$k + 2] -eq $fieldLow) {
                        # getstatic (3 bytes) -> iconst_0, nop, nop. The following
                        # IFEQ consumes zero and continues into the existing scan.
                        $patched[$k] = 0x03
                        $patched[$k + 1] = 0x00
                        $patched[$k + 2] = 0x00
                        $replacementCount++
                    }
                }
            }
            $position += 6 + $attributeLength
        }
    }

    if ($replacementCount -ne 1) {
        throw "物理步骤保护替换次数异常：$replacementCount"
    }
    return $patched
}

if (-not (Test-Path -LiteralPath $InputJar -PathType Leaf)) {
    throw "找不到输入文件：$InputJar"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$targetEntryName = 'qouteall/imm_ptl/core/IPShipPortalTraversalImpl.class'
$inputArchive = [System.IO.Compression.ZipFile]::OpenRead($InputJar)
$outputStream = New-Object System.IO.FileStream(
    $OutputJar,
    [System.IO.FileMode]::Create,
    [System.IO.FileAccess]::Write,
    [System.IO.FileShare]::None
)
$outputArchive = New-Object System.IO.Compression.ZipArchive(
    $outputStream,
    [System.IO.Compression.ZipArchiveMode]::Create,
    $false
)
$foundTarget = $false

try {
    foreach ($entry in $inputArchive.Entries) {
        $stream = $entry.Open()
        $buffer = New-Object System.IO.MemoryStream
        try { $stream.CopyTo($buffer); $entryBytes = $buffer.ToArray() }
        finally { $stream.Dispose(); $buffer.Dispose() }

        if ($entry.FullName -eq $targetEntryName) {
            $entryBytes = Patch-PhysicsStepGuard -Data $entryBytes
            $foundTarget = $true
        }

        $newEntry = $outputArchive.CreateEntry($entry.FullName, [System.IO.Compression.CompressionLevel]::Optimal)
        $newEntry.LastWriteTime = $entry.LastWriteTime
        $newEntry.ExternalAttributes = $entry.ExternalAttributes
        $newStream = $newEntry.Open()
        try { $newStream.Write($entryBytes, 0, $entryBytes.Length) }
        finally { $newStream.Dispose() }
    }
    if (-not $foundTarget) { throw "JAR 中缺少目标类：$targetEntryName" }
}
finally {
    $outputArchive.Dispose()
    $outputStream.Dispose()
    $inputArchive.Dispose()
}

Get-FileHash -LiteralPath $OutputJar -Algorithm SHA256

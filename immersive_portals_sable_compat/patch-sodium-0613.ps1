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

function Write-U2BE {
    param([System.IO.Stream]$Stream, [int]$Value)
    $Stream.WriteByte([byte](($Value -shr 8) -band 0xff))
    $Stream.WriteByte([byte]($Value -band 0xff))
}

function Patch-ClassUtf8 {
    param(
        [byte[]]$Data,
        [hashtable]$Replacements
    )

    if ($Data.Length -lt 10 -or
        $Data[0] -ne 0xca -or $Data[1] -ne 0xfe -or
        $Data[2] -ne 0xba -or $Data[3] -ne 0xbe) {
        throw '不是有效的 Java class 文件'
    }

    $output = New-Object System.IO.MemoryStream
    try {
        $output.Write($Data, 0, 10)
        $constantPoolCount = Read-U2BE -Data $Data -Offset 8
        $position = 10
        $index = 1

        while ($index -lt $constantPoolCount) {
            $tag = [int]$Data[$position]
            $output.WriteByte([byte]$tag)
            $position++

            switch ($tag) {
                1 {
                    $length = Read-U2BE -Data $Data -Offset $position
                    $position += 2
                    $value = [System.Text.Encoding]::UTF8.GetString($Data, $position, $length)
                    foreach ($oldValue in $Replacements.Keys) {
                        $value = $value.Replace([string]$oldValue, [string]$Replacements[$oldValue])
                    }
                    $encoded = [System.Text.Encoding]::UTF8.GetBytes($value)
                    if ($encoded.Length -gt 65535) { throw '常量池 UTF-8 项过长' }
                    Write-U2BE -Stream $output -Value $encoded.Length
                    $output.Write($encoded, 0, $encoded.Length)
                    $position += $length
                }
                { $_ -in 3, 4 } {
                    $output.Write($Data, $position, 4)
                    $position += 4
                }
                { $_ -in 5, 6 } {
                    $output.Write($Data, $position, 8)
                    $position += 8
                    $index++
                }
                { $_ -in 7, 8, 16, 19, 20 } {
                    $output.Write($Data, $position, 2)
                    $position += 2
                }
                { $_ -in 9, 10, 11, 12, 17, 18 } {
                    $output.Write($Data, $position, 4)
                    $position += 4
                }
                15 {
                    $output.Write($Data, $position, 3)
                    $position += 3
                }
                default { throw "未知的 class 常量池标签：$tag" }
            }
            $index++
        }

        $output.Write($Data, $position, $Data.Length - $position)
        return $output.ToArray()
    }
    finally {
        $output.Dispose()
    }
}

if (-not (Test-Path -LiteralPath $InputJar -PathType Leaf)) {
    throw "找不到输入文件：$InputJar"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$targets = @{
    'qouteall/imm_ptl/core/compat/mixin/sodium/MixinSodiumOcclusionCuller.class' = @{
        'net/caffeinemc/mods/sodium/client/render/chunk/lists/RenderSectionVisitor' =
            'net/caffeinemc/mods/sodium/client/render/chunk/occlusion/OcclusionCuller$Visitor'
    }
    'qouteall/imm_ptl/core/compat/mixin/sodium/MixinSodiumViewport.class' = @{
        'isBoxVisibleDirect' = 'isBoxVisible'
    }
}

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
try {
    $foundTargets = @{}
    foreach ($entry in $inputArchive.Entries) {
        $stream = $entry.Open()
        $buffer = New-Object System.IO.MemoryStream
        try {
            $stream.CopyTo($buffer)
            $entryBytes = $buffer.ToArray()
        }
        finally {
            $stream.Dispose()
            $buffer.Dispose()
        }

        if ($targets.ContainsKey($entry.FullName)) {
            $entryBytes = Patch-ClassUtf8 -Data $entryBytes -Replacements $targets[$entry.FullName]
            $foundTargets[$entry.FullName] = $true
        }

        $newEntry = $outputArchive.CreateEntry(
            $entry.FullName,
            [System.IO.Compression.CompressionLevel]::Optimal
        )
        $newEntry.LastWriteTime = $entry.LastWriteTime
        $newEntry.ExternalAttributes = $entry.ExternalAttributes
        $newStream = $newEntry.Open()
        try { $newStream.Write($entryBytes, 0, $entryBytes.Length) }
        finally { $newStream.Dispose() }
    }

    foreach ($entryName in $targets.Keys) {
        if (-not $foundTargets.ContainsKey($entryName)) {
            throw "JAR 中缺少目标类：$entryName"
        }
    }
}
finally {
    $outputArchive.Dispose()
    $outputStream.Dispose()
    $inputArchive.Dispose()
}

Get-FileHash -LiteralPath $OutputJar -Algorithm SHA256

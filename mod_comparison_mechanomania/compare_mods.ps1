param(
    [Parameter(Mandatory = $true)]
    [string]$FirstDirectory,

    [Parameter(Mandatory = $true)]
    [string]$SecondDirectory
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Read-ZipText {
    param(
        [System.IO.Compression.ZipArchive]$Archive,
        [string]$EntryName
    )

    $entry = $Archive.Entries | Where-Object { $_.FullName -ieq $EntryName } | Select-Object -First 1
    if ($null -eq $entry) {
        return $null
    }

    $stream = $entry.Open()
    $reader = [System.IO.StreamReader]::new($stream)
    try {
        return $reader.ReadToEnd()
    }
    finally {
        $reader.Dispose()
        $stream.Dispose()
    }
}

function Get-TomlValue {
    param(
        [string]$Block,
        [string]$Key
    )

    $pattern = '(?m)^\s*' + [regex]::Escape($Key) + '\s*=\s*["'']([^"'']+)["'']'
    $match = [regex]::Match($Block, $pattern)
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    return $null
}

function Get-JarMetadata {
    param([System.IO.FileInfo]$JarFile)

    $records = [System.Collections.Generic.List[object]]::new()
    $archive = [System.IO.Compression.ZipFile]::OpenRead($JarFile.FullName)
    try {
        $tomlText = Read-ZipText -Archive $archive -EntryName 'META-INF/neoforge.mods.toml'
        $metadataKind = 'neoforge.mods.toml'
        if ($null -eq $tomlText) {
            $tomlText = Read-ZipText -Archive $archive -EntryName 'META-INF/mods.toml'
            $metadataKind = 'mods.toml'
        }

        if ($null -ne $tomlText) {
            $modBlocks = [regex]::Matches($tomlText, '(?ms)^\s*\[\[mods\]\]\s*(.*?)(?=^\s*\[\[|\z)')
            foreach ($blockMatch in $modBlocks) {
                $block = $blockMatch.Groups[1].Value
                $modId = Get-TomlValue -Block $block -Key 'modId'
                if ([string]::IsNullOrWhiteSpace($modId)) {
                    continue
                }

                $dependencyIds = [System.Collections.Generic.List[string]]::new()
                $dependencyPattern = '(?ms)^\s*\[\[dependencies\.' + [regex]::Escape($modId) + '\]\]\s*(.*?)(?=^\s*\[\[|\z)'
                foreach ($dependencyMatch in [regex]::Matches($tomlText, $dependencyPattern)) {
                    $dependencyBlock = $dependencyMatch.Groups[1].Value
                    $dependencyId = Get-TomlValue -Block $dependencyBlock -Key 'modId'
                    $dependencyType = Get-TomlValue -Block $dependencyBlock -Key 'type'
                    $mandatoryText = Get-TomlValue -Block $dependencyBlock -Key 'mandatory'
                    $isRequired = ($dependencyType -eq 'required') -or ($mandatoryText -eq 'true')
                    if ($isRequired -and $dependencyId -notin @('minecraft', 'neoforge', 'forge', 'java')) {
                        $dependencyIds.Add($dependencyId)
                    }
                }

                $records.Add([pscustomobject]@{
                    Id = $modId
                    Name = Get-TomlValue -Block $block -Key 'displayName'
                    Version = Get-TomlValue -Block $block -Key 'version'
                    File = $JarFile.Name
                    Metadata = $metadataKind
                    RequiredDependencies = @($dependencyIds | Sort-Object -Unique)
                })
            }
        }

        if ($records.Count -eq 0) {
            $fabricText = Read-ZipText -Archive $archive -EntryName 'fabric.mod.json'
            if ($null -ne $fabricText) {
                $fabricData = $fabricText | ConvertFrom-Json
                $dependencyIds = @()
                if ($null -ne $fabricData.depends) {
                    $dependencyIds = @($fabricData.depends.PSObject.Properties.Name | Where-Object { $_ -notin @('minecraft', 'java', 'fabricloader') })
                }
                $records.Add([pscustomobject]@{
                    Id = [string]$fabricData.id
                    Name = [string]$fabricData.name
                    Version = [string]$fabricData.version
                    File = $JarFile.Name
                    Metadata = 'fabric.mod.json'
                    RequiredDependencies = @($dependencyIds | Sort-Object -Unique)
                })
            }
        }
    }
    catch {
        $records.Add([pscustomobject]@{
            Id = $null
            Name = $null
            Version = $null
            File = $JarFile.Name
            Metadata = 'unreadable'
            RequiredDependencies = @()
            Error = $_.Exception.Message
        })
    }
    finally {
        $archive.Dispose()
    }

    if ($records.Count -eq 0) {
        $records.Add([pscustomobject]@{
            Id = $null
            Name = $null
            Version = $null
            File = $JarFile.Name
            Metadata = 'unknown'
            RequiredDependencies = @()
        })
    }

    return @($records)
}

function Get-DirectoryMetadata {
    param([string]$Directory)

    $results = [System.Collections.Generic.List[object]]::new()
    foreach ($jarFile in Get-ChildItem -LiteralPath $Directory -File -Filter '*.jar' | Sort-Object Name) {
        foreach ($record in Get-JarMetadata -JarFile $jarFile) {
            $results.Add($record)
        }
    }
    return @($results)
}

$firstRecords = Get-DirectoryMetadata -Directory $FirstDirectory
$secondRecords = Get-DirectoryMetadata -Directory $SecondDirectory

$firstKnown = @($firstRecords | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Id) })
$secondKnown = @($secondRecords | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Id) })
$firstIds = @($firstKnown.Id | Sort-Object -Unique)
$secondIds = @($secondKnown.Id | Sort-Object -Unique)

$missingFromFirst = foreach ($modId in $secondIds | Where-Object { $_ -notin $firstIds }) {
    $secondKnown | Where-Object Id -eq $modId
}

$onlyInFirst = foreach ($modId in $firstIds | Where-Object { $_ -notin $secondIds }) {
    $firstKnown | Where-Object Id -eq $modId
}

$differentFiles = foreach ($modId in $firstIds | Where-Object { $_ -in $secondIds }) {
    $firstForId = @($firstKnown | Where-Object Id -eq $modId)
    $secondForId = @($secondKnown | Where-Object Id -eq $modId)
    $firstNames = @($firstForId.File | Sort-Object -Unique)
    $secondNames = @($secondForId.File | Sort-Object -Unique)
    if (($firstNames -join '|') -ne ($secondNames -join '|')) {
        [pscustomobject]@{
            Id = $modId
            FirstFiles = $firstNames
            SecondFiles = $secondNames
        }
    }
}

$firstDuplicates = @($firstKnown | Group-Object Id | Where-Object Count -gt 1 | ForEach-Object {
    [pscustomobject]@{ Id = $_.Name; Files = @($_.Group.File | Sort-Object -Unique) }
})
$secondDuplicates = @($secondKnown | Group-Object Id | Where-Object Count -gt 1 | ForEach-Object {
    [pscustomobject]@{ Id = $_.Name; Files = @($_.Group.File | Sort-Object -Unique) }
})

[pscustomobject]@{
    FirstJarCount = @(Get-ChildItem -LiteralPath $FirstDirectory -File -Filter '*.jar').Count
    SecondJarCount = @(Get-ChildItem -LiteralPath $SecondDirectory -File -Filter '*.jar').Count
    FirstModIdCount = $firstIds.Count
    SecondModIdCount = $secondIds.Count
    MissingFromFirst = @($missingFromFirst | Sort-Object Id, File)
    OnlyInFirst = @($onlyInFirst | Sort-Object Id, File)
    DifferentFilesForSameId = @($differentFiles | Sort-Object Id)
    FirstDuplicateIds = $firstDuplicates
    SecondDuplicateIds = $secondDuplicates
    FirstUnknown = @($firstRecords | Where-Object { [string]::IsNullOrWhiteSpace($_.Id) } | Select-Object File, Metadata, Error)
    SecondUnknown = @($secondRecords | Where-Object { [string]::IsNullOrWhiteSpace($_.Id) } | Select-Object File, Metadata, Error)
} | ConvertTo-Json -Depth 8

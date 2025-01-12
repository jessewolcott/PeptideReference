Set-Location $PSScriptRoot
# Define input and output file paths
$csvPath = "abbreviations.csv"
$jsonPath = "abbreviations.json"

# Import CSV and convert to custom object
$csvData = Import-Csv $csvPath | Where-Object { $_.abbreviation -ne "" } | ForEach-Object {
    [PSCustomObject]@{
        abbreviation = $_.abbreviation.Trim()
        category = if ($_.latin -match "^[a-zA-Z\s]+$") { "Latin" } else { "Common" }
        expanded_meaning = $_.latin.Trim()
        explanation = $_.english.Trim()
        possible_confusion = if ($_.'possible_confusion') { $_.'possible_confusion'.Trim() } else { "" }
    }
}

# Create wrapper object
$jsonObject = @{
    prescription_abbreviations = @($csvData)
}

# Convert to JSON and format
$jsonString = ConvertTo-Json -InputObject $jsonObject -Depth 10

# Save to file with UTF8 encoding without BOM
[System.IO.File]::WriteAllText($jsonPath, $jsonString, [System.Text.UTF8Encoding]::new($false))

Write-Host "Conversion complete. JSON file saved as $jsonPath"

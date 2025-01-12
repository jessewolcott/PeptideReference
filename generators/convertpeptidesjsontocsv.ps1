# Function to convert the nested JSON to CSV format
function Convert-NestedJsonToCsv {
    param (
        [string]$outputFile
    )

    # Read and parse the JSON file
    $jsonContent = Get-Content ".\peptides.json" -Raw
    # Remove the "var nestedData =" part and any comments
    $data = $jsonContent | ConvertFrom-Json

    # Create an array to hold the flattened data
    $flattenedData = @()

    # Process each peptide
    foreach ($peptide in $data) {
        # If there's an administration array
        if ($peptide.administration) {
            foreach ($admin in $peptide.administration) {
                $flattenedRow = [PSCustomObject]@{
                    'ID' = $peptide.id
                    'Peptide Name' = $peptide.peptidename
                    'Mechanism' = $peptide.mechanism
                    'Tags' = $peptide.tags
                    'Synergistic' = $peptide.synergistic
                    'Discordant' = $peptide.discordant
                    'Half Life' = $peptide.halfLife
                    'Side Effects' = $peptide.sideEffects
                    'Route' = $admin.route
                    'Dosage' = $admin.dosage
                    'Timing' = $admin.timing
                    'Fasting' = $admin.fasting
                    'Frequency' = $admin.frequency
                    'Protocol' = $admin.protocol
                    'Source' = $admin.source
                }
                $flattenedData += $flattenedRow
            }
        } else {
            # If there's no administration array, create a single row
            $flattenedRow = [PSCustomObject]@{
                'ID' = $peptide.id
                'Peptide Name' = $peptide.peptidename
                'Mechanism' = $peptide.mechanism
                'Tags' = $peptide.tags
                'Synergistic' = $peptide.synergistic
                'Discordant' = $peptide.discordant
                'Half Life' = $peptide.halfLife
                'Side Effects' = $peptide.sideEffects
                'Route' = ''
                'Dosage' = ''
                'Timing' = ''
                'Fasting' = ''
                'Frequency' = ''
                'Protocol' = ''
                'Source' = ''
            }
            $flattenedData += $flattenedRow
        }
    }

    # Export to CSV
    $flattenedData | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
    Write-Host "CSV file created successfully at: $outputFile"
}

# Usage example
$outputFilePath = "peptides.csv"  # The CSV will be created here
Convert-NestedJsonToCsv -outputFile $outputFilePath

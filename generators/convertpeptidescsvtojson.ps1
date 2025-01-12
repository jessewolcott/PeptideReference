function Convert-CsvToNestedJson {
    param (
        [string]$inputFile = "peptides.csv",
        [string]$outputFile = "peptides.json"
    )

    try {
        # Read the CSV file with UTF8 encoding
        $csvData = Import-Csv -Path $inputFile -Encoding UTF8

        # Create a hashtable to group by peptide ID
        $peptides = @{}

        # Process each row in the CSV
        foreach ($row in $csvData) {
            $peptideId = $row.ID

            # If this peptide hasn't been processed yet, create the base object
            if (-not $peptides.ContainsKey($peptideId)) {
                $peptides[$peptideId] = @{
                    id = $row.ID
                    peptidename = $row.'Peptide Name'
                    mechanism = $row.Mechanism
                    tags = $row.Tags
                    synergistic = $row.Synergistic
                    discordant = $row.Discordant
                    halfLife = $row.'Half Life'
                    sideEffects = $row.'Side Effects'
                    administration = @()
                }
            }

            # Add administration data if route exists and isn't "Not indicated"
            if ($row.Route -and $row.Route -ne "Not indicated") {
                $adminData = @{
                    route = $row.Route
                }

                # Only add non-empty values
                if ($row.Dosage -and $row.Dosage -ne "Not indicated") { $adminData.dosage = $row.Dosage }
                if ($row.Timing) { $adminData.timing = $row.Timing }
                if ($row.Fasting) { $adminData.fasting = $row.Fasting }
                if ($row.Frequency) { $adminData.frequency = $row.Frequency }
                if ($row.Protocol) { $adminData.protocol = $row.Protocol }
                if ($row.Source) { $adminData.source = $row.Source }

                $peptides[$peptideId].administration += $adminData
            }
        }

        # Convert hashtable to array and sort by ID numerically
        $result = $peptides.Values | 
            Sort-Object { [int]$_.id } | 
            ForEach-Object {
                $peptide = $_

                # Remove empty administration arrays
                if ($peptide.administration.Count -eq 0) {
                    $peptide.Remove('administration')
                }

                # Remove empty or null values from the peptide object
                @($peptide.PSObject.Properties) | Where-Object { 
                    [string]::IsNullOrEmpty($_.Value) 
                } | ForEach-Object { 
                    $peptide.PSObject.Properties.Remove($_.Name) 
                }

                $peptide
            }

        # Convert to JSON and save to file
        $jsonString = $result | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($outputFile, $jsonString, [System.Text.Encoding]::UTF8)
        Write-Host "JSON file created successfully at: $outputFile"
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}

# Execute the function
Convert-CsvToNestedJson

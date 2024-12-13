# Set SQL Server connection parameters
$serverName = "server name"
$databaseName = "databse name"
$outputFolderPath = "location where you want the csv files"

# List of table names to export
$tableNames = @("table_name")  # Add more table names as needed

# Create output folder if it doesn't exist
if (!(Test-Path -Path $outputFolderPath)) {
    New-Item -ItemType Directory -Path $outputFolderPath | Out-Null
}

# Create a function to export a table to CSV
function Export-TableToCSV {
    param(
        [string]$tableName,
        [string]$outputFolderPath
    )

    # Build SQL query
    $query = "SELECT * FROM $tableName"

    # Create connection to SQL Server
    $connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=True;"
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString

    # Create command to execute query
    $command = New-Object System.Data.SqlClient.SqlCommand
    $command.CommandText = $query
    $command.Connection = $connection

    # Start time
    $startTime = Get-Date
    
    # Open connection
    $connection.Open()

    # Execute query and retrieve data
    $reader = $command.ExecuteReader()

    # Export data to CSV
    $outputFilePath = Join-Path -Path $outputFolderPath -ChildPath "$tableName.csv"
    $table = New-Object System.Data.DataTable
    $table.Load($reader)
    $table | Export-Csv -Path $outputFilePath -NoTypeInformation

    # Close connection
    $connection.Close()

    # End time
    $endTime = Get-Date

    # Calculate duration
    $duration = New-TimeSpan -Start $startTime -End $endTime

    Write-Host "Export of table '$tableName' completed in $($duration.TotalSeconds) seconds. Data saved to $outputFilePath"
}

# Export each table to CSV
foreach ($tableName in $tableNames) {
    Export-TableToCSV -tableName $tableName -outputFolderPath $outputFolderPath
}

Write-Host ""
Write-Host ""
Write-Host "CHECK RED ERROR MESSAGES FOR CORRECTIONS"
Write-Host "SUCCESS"

Read-Host "PRESS ENTER"
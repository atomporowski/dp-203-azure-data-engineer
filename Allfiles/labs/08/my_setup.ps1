$sqlDatabaseName = "sqlz1uv9s2_warehouse"
$sqlUser = "SQLUser"
$synapseWorkspace = "synapsez1uv9s2"
$sqlPassword = "f8gAUpk!"

# Create database
write-host "Creating the $sqlDatabaseName database..."
sqlcmd -S "$synapseWorkspace.sql.azuresynapse.net" -U $sqlUser -P $sqlPassword -d $sqlDatabaseName -I -i setup.sql

# Load data
write-host "Loading data..."
Get-ChildItem "./data/*.txt" -File | Foreach-Object {
    write-host ""
    $file = $_.FullName
    Write-Host "$file"
    $table = $_.Name.Replace(".txt","")
    bcp dbo.$table in $file -S "$synapseWorkspace.sql.azuresynapse.net" -U $sqlUser -P $sqlPassword -d $sqlDatabaseName -f $file.Replace("txt", "fmt") -q -k -E -b 5000
}

# Pause SQL Pool
write-host "Pausing the $sqlDatabaseName SQL Pool..."
Suspend-AzSynapseSqlPool -WorkspaceName $synapseWorkspace -Name $sqlDatabaseName -AsJob

# Upload solution script
write-host "Uploading script..."
$solutionScriptPath = "Solution.sql"
Set-AzSynapseSqlScript -WorkspaceName $synapseWorkspace -DefinitionFile $solutionScriptPath -sqlPoolName $sqlDatabaseName -sqlDatabaseName $sqlDatabaseName

write-host "Script completed at $(Get-Date)"
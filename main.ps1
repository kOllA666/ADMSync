# Sync file across multiple AD Machines.
# Version: 1.0.0
# Author: Marko Eling <markoeling@gmail.com>

# Path to origin file that will be synced to remote machines.
$OriginFilePath = "c:\temp\rdp.txt";
# Path to destination where the file is stored on remote computer.
$DestinationPath = "temp\rdp.txt";

# Implements remote machine logic.
class Machine {
    [string] $Host;
    # Path to the rdp file on remote machine.
    [string] $Path = "\\$($this.Host)\c$\$($DestinationPath)"; # eg. \\HOSTNAME.dev.local\c$\
    [string] $OriginFilePath = $OriginFilePath;

    [void] UpdateFile() {
        # Copy origin file to remote computer to sync.
        Copy-Item $this.OriginFilePath -Destination $this.Path;
    }

    [void] HelloWorld() {
        Write-Host "Hello from $($this.Host)!";
    }
}


$DumpPath = "c:\temp\dump.txt";
# Search the AD for machines and filter names. Stored in variable and dumped to file.
Get-ADComputer -Filter "Name -like '*VM*' -or Name -like '*WS*'" | Select-Object -Expand DNSHostName | Out-File -FilePath $DumpPath;

# Get dump file content.
# ! Try fetching needed AD Computers stright from Get-ADComputer to save on performance and memory.
$DumpFile = (Get-Content $DumpPath);
$MachLen = ($DumpFile).Length;

for($i=0; $i -le $MachLen; $i++) {
    # Get the next line content.
    $ln = ((Get-Content -Path $DumpPath -TotalCount ($i+1))[-1]);
    
    # Check if line is empty.
    if(($ln).Length -gt 1) {
        # Initialize new instance of Machine.
        $m = [Machine]::new();
        # Set newly created machine's host.
        $m.Host = $ln;

        # Fire cool functions from this machine. :fire_emoji:
        $m.HelloWorld();
    }
}



# Research alternative.
# Enter-PSSession –ComputerName host [-Credential username]
# Copy-Item -Path \\serverb\c$\programs\temp\test.txt -Destination \\servera\c$\programs\temp\test.txt;
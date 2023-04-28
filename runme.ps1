Param(
    [CmdletBinding()]

    [Parameter(Mandatory=$false)]
    [validateSet("Debian", "Ubuntu")]
    [string]$DistroName = "Ubuntu",

    [Parameter(
        Mandatory=$false,
        ParameterSetName='VagrantOptions'
    )]
    [Switch]$VagrantHaltOnCompletion,

    [Parameter(
        Mandatory=$false,
        ParameterSetName='VagrantOptions'
    )]
    [Switch]$VagrantDestroyOnCompletion,

    [Parameter(Mandatory=$false)]
    [Switch]$RemoveWSLEnvironmentOnCompletion,

    [Parameter(Mandatory=$false)]
    [string]$vagrantDownloadUrl = "https://releases.hashicorp.com/vagrant/2.3.4/vagrant_2.3.4_windows_amd64.msi" 
)

Write-Host "Checking for WSL Installation"
if ($null -eq $(wsl -l)){
    Write-Host "WSL is not installed. Installing"
    wsl --install -d $DistroName --no-launch
    Write-Host "WSL Installed. Please restart your computer and run this script again"
    exit
}
else {
    Write-Host "WSL is installed. Checking for Vagrant Installation"
}

$vagrantInstalled = cmd /c vagrant --version 2`>`&1

if ($?){
    Write-Host "$vagrantInstalled is already installed. Checking for WSL Installation"
}
else {
    Write-Host "Vagrant is not installed. Installing"
    $vagrantDownloadPath = "$env:TEMP\vagrant.msi"

    Write-Host "Downloading Vagrant from [$vagrantDownloadUrl] to [$vagrantDownloadPath]"
    Invoke-WebRequest -Uri $vagrantDownloadUrl -OutFile $vagrantDownloadPath

    Write-Host "Installing Vagrant"
    Start-Process -FilePath $vagrantDownloadPath -ArgumentList "/passive /norestart" -Wait

    Write-Host "Cleaning up: Removing Vagrant download from [$vagrantDownloadPath]]"
    [Void](Remove-Item -Path $vagrantDownloadPath -Force)

    if ($?){
        Write-Host "Vagrant Installation successful. Please restart your machine and run this script again"
        exit
    }
    else {
        Write-Error "Vagrant Install Failed. Exiting" -ErrorAction Stop
    }
}

if ($DistroName -eq "Debian" -or $DistroName -eq "Ubuntu"){
    if ($(wsl -l) -notcontains $DistroName){
        wsl --install -d $DistroName --no-launch
    }
    else {
        Write-Host "WSL $DistroName is already installed. Skipping"
    }

    Write-Host "Checking for Ansible Installation and dependencies"
    . $DistroName run -u root "sudo apt update -y"
    . $DistroName run -u root "sudo apt upgrade -y"
    . $DistroName run -u root "sudo apt install python3 python3-dev python3-pip -y"
    . $DistroName run -u root "sudo python3 -m pip install ansible pywinrm --upgrade"

    $wslConfigExists = $(. $DistroName run -u root "sudo cat /etc/wsl.conf" 2>&1 | Out-String).trim()
    if ($wslConfigExists -eq "cat: /etc/wsl.conf: No such file or directory"){
        Write-Host "Wsl Config Does Not Exist. Creating to change permissions for ansible"
        . $DistroName run -u root "sudo touch /etc/wsl.conf"
        [void](. $DistroName run -u root "echo -e '# Enable extra metadata options by default\n[automount]\nenabled = true\nroot = /mnt/\noptions = `"metadata,umask=77,fmask=11`"\nmountFsTab = false' | sudo tee /etc/wsl.conf")
    }
    else {
        Write-Host "Wsl Config Exists. Checking for permissions"
        $wslConfigContents = . $DistroName run -u root "sudo cat /etc/wsl.conf"
        if ($wslConfigContents -notcontains "[automount]"){
            Write-Host "Wsl Config Does Not Contain Permissions. Adding"
            . $DistroName run -u root "echo -e '# Enable extra metadata options by default\n[automount]\nenabled = true\nroot = /mnt/\noptions = `"metadata,umask=77,fmask=11`"\nmountFsTab = false' | sudo tee -a /etc/wsl.conf"
        }
        else {
            Write-Host "Wsl Config Contains Permissions moving on"
        }
    } 
}

Write-Host "Running Vagrant Up to build VMs from Vagrantfile configuration in $PSScriptRoot"
vagrant up

if ($?){
    Write-Host "Vagrant Up Successful. Running ansible playbook in WSL"
    $projectPath = $PSScriptRoot.ToLower().Replace(":", "").Replace("\", "/")
    . $DistroName run "cd /mnt/$projectPath/ansible; ansible-playbook main.yml"
}
else {
    Write-Error "Vagrant Up Failed. Exiting" -ErrorAction Stop
}


if ($VagrantHaltOnCompletion){
    Write-Host "Halting Vagrant VM as requested."
    vagrant halt

    if($?){
        Write-Host "Vagrant Halt Successful"
    }
    else {
        Write-Error "Vagrant Halt Failed. Exiting" -ErrorAction Stop
    }
}


if ($VagrantDestroyOnCompletion){
    Write-Host "Destroying Vagrant VM as requested."
    vagrant destroy -f

    if($?){
        Write-Host "Vagrant Destroy Successful"
    }
    else {
        Write-Error "Vagrant Destroy Failed. Exiting" -ErrorAction Stop
    }
}

if ($RemoveWSLEnvironmentOnCompletion){
    Write-Host "Removing WSL Environment as requested."
    wsl --unregister $DistroName

    if($?){
        Write-Host "WSL Environment Removed"
    }
    else {
        Write-Error "WSL Environment Removal Failed. Exiting" -ErrorAction Stop
    }
}

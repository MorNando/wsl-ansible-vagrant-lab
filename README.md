# wsl-ansible-vagrant-lab
This is an lab that:
- Automatically installs WSL2 Debian or Ubuntu if required.
- Installs Vagrant 2.3.4 if required. The version of Vagrant needed can be controlled via a variable.
- Installs 3 Windows Server VMs using vagrant via VirtualBox.
- Installs and configures ansible on Windows Subsystem For Linux 2 (WSL2). This needs to be either Ubuntu or Debian.
- Runs the ansible configuration found in the `ansible` folder of this repository.

It is a great accelerator for testing and learning Ansible.

## Prerequisites
It requires VirtualBox (tested with version 7) already installed on your Windows machine.

It has also only been tested on Windows 11 but may work with Windows 10.

## How to Use
- Clone this repository to a folder of your choice.
- run the script `runme.ps1`
- Everything in the `Vagrantfile` and `ansible` folder is customisable to fit your requirements.

Examples of how `runme.ps1` can be used below:

Run with all the defaults. This will use ubuntu WSL2 out of the box and keep your VMs running afterwards
```powershell
runme.ps1
```

Run using Debian in WSL2 and stop the VMs once finished
```powershell
runme.ps1 -DistroName Debian -VagrantHaltOnCompletion
```

Run using Debian in WSL2 and stop the VMs once finished
```powershell
runme.ps1 -DistroName Debian -VagrantDestroyOnCompletion
```

Run using Ubuntu in WSL2, stop the VMs once finished and removes the WSL2 environment image
```powershell
runme.ps1 -DistroName Ubuntu -VagrantDestroyOnCompletion -RemoveWSLEnvironmentOnCompletion
```

Installs an alternative version of Vagrant (feel free to change the default value in the script)
```powershell
runme.ps1 -VagrantDownloadUrl "https://releases.hashicorp.com/vagrant/2.1.6/vagrant_2.1.6_windows_amd64.msi" 
```
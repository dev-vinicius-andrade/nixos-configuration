# nix-config

Personal nix configuration files.
This repository contains my development environment configuration which are configured using Flakes and Disko.

## Table of Contents
- []
- [Installation] (#installation)
  - [Pre-Requisites] (#pre-requisites)
  - [Change Current user] (#change-current-user)
  - [Setting up the keymap] (#setting-up-the-keymap)
  - [Setting a Root Password] (#setting-a-root-password)
  - [A Command To Rule Them All] (#a-command-to-rule-them-all)
  - [Clear the nixos configuration files] (#clear-the-nixos-configuration-files)
  - [Cloning the repository] (#cloning-the-repository)
  - [Init script] (#init-script)
    - [Script permissions] (#script-permissions)
    - [Running the script] (#running-the-script)
    - [Personalization] (#personalization)
  - [Installing NixOS] (#installing-nixos)

## Installation

Bellow is a step-by-step guide to install NixOS using this repository.

### Pre-Requisites

- A working internet connection
- Create a bootable USB with the nixos iso, you can get it [here](https://nixos.org/download.html);
- A Machine or a VM;
- Knowledge of the terminal;
- Basic understanding of the nix package manager;
- Basic understanding of the nixos configuration files;
- Basic knowledge of how to boot from a USB drive;

### Change Current user

As default nixos minimal ISO uses the `nixos` user, I prefer to use the `root` user, so I change the current user to `root`.

```bash
   sudo -i 
```

### Setting up the keymap

As I'm using a brazilian keyboard, I need to set the keymap to br-abnt2, you can change it to your own keymap or skip this step if not needed.

```bash
    loadkeys br-abnt2
```

> Note: Normally the keymap name is the `<country_code>-<layout>`;

### Setting a Root Password

As I wanted to connect to the machine using ssh, I need to set a root password.

```bash
    passwd
```

### Installing git

As I wan't to use my personal dotfiles, I needed to install git in the **iso** system, you can check more about why [here](#configurations-dotfiles)    

```bash
    nix-env -i git
```

It may take a while, but after the installation you can clone the repository, either using git or curl.

### Cloning the repository

You can clone the repository using:

- [Git](#cloning-the-repository-using-git);
- [Curl](#cloning-the-repository-using-curl);

#### Cloning the repository using git

```bash
    git clone https://github.com/dev-vinicius-andrade/nix-configuration.git
```

#### Cloning the repository using curl

```bash
     mkdir -p /root/nixos-configuration && \
    curl -L https://github.com/dev-vinicius-andrade/nix-configuration/archive/refs/heads/main.tar.gz | tar xz --strip-components=1 -C /root/nixos-configuration
```

> Note: You can change the directory to your own path if you want, but remember to change the path in the following commands.

### Prepare installation

There are several ways to install NixOs, I will describe the way I use to install it.

The repository contains a tool that I've called [nioscli](#nioscli) that I've developed to make the installation commands more verbose.
If you want to use this tool as well you **must** give it execution permission.

```bash
    chmod +x /root/nixos-configuration/nix/tools/nioscli
```

#### Personalization

After running the script the templates files will be copied to /etc/nixos, there you can personalize the configurations as you want, mainly you need to personalize the [variables.nix](variables.nix) file with your own configurations.
Also, you can personalize the nixos configuration files as you want, this is just a starting point.

#### Installing NixOS

Bellow are the steps to install NixOS using this repository.

- [Bootstrapping the disks](#bootstrapping-the-disks)

##### Bootstrapping the disks

To Install NixOs firts you need to bootstrap the disks, to do it you can use the following command:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./nixos-config/nix/disko/default/disko.nix  --show-trace
```

Or you can use the [nioscli](#nioscli) tool to do it:

```bash
/root/nixos-configuration/nix/tools/nioscli create disko --path /root/nixos-configuration/nix/disko/default/disko.nix
```

Here we are using the `disko` tool to bootstrap the disks, you can check the [disko.nix](nix/disko/default/disko.nix) file to see the configurations.
You can also check the [disko documentation here](https://github.com/nix-community/disko)

But basically we are enabling flakes and using their flake to generate the partitions using the [disko.nix](nix/disko/default/disko.nix) file;

##### Generating the hardware configuration

After bootstrapping the disks you need to generate the hardware configuration, to do it you can use the following command:

```bash
nixos-generate-config --root /mnt --no-filesystems && \
rm /mnt/etc/nixos/configuration.nix && \
cp /mnt/etc/nixos/hardware-configuration.nix /root/nixos-configuration/nix/hardware-configuration.nix
```

Or you can use the [nioscli](#nioscli) tool to do it:

```bash
/root/nixos-configuration/nix/tools/nioscli create hardware --no-filesystem --move-file --destination /root/nixos-configuration/nix
```

##### Generating the variables from the templates

If you choose to use the nioscli tool you can generate the variables from the templates using the following command:

```bash
./nixos-configuration/nix/tools/nioscli templates --src ./nixos-configuration/nix/templates --dest ./nixos-configuration/nix/ 
```

Or you can do it manually:

```bash
mkdir -p /root/nixos-configuration/nix/templates && \
cp -r /root/nixos-configuration/nix/templates/* /root/nixos-configuration/nix/
```

###### Changing the variables

After copying the templates to the variables directory, you can change according to your needs.
The idea of those files are not to replace the nixos way of doing things, but to make some common configurations that may vary from system to system easier to change.

Take a look at the files in the [templates folder](nix/templates/) to see the variables that you can change

- [common.template.nix](nix/templates/variables/common.template.nix) - A common sets of variables that will be used to all hosts.
- [hostname.template.nix](nix/templates/variables/hostname.template.nix) - A host specific configuration file.

##### Running NixOS Install

If you followed all the steps above you are ready to install NixOS.
Run the following command to install NixOS:

```bash
nixos-install --root /mnt --flake /root/nixos-configuration/nix#default
```

> Note: The `--flake /root/nixos-configuration/nix#default` is the path to the flake, you can change it to your own path if you want, and change the `#default` to the. name of the system you want to install.

##### Post Installation

After the installation copy the `/root/nixos-configuration/nix` directory to `/mnt/etc/nixos`:
This way you can keep the configurations in the default nixos configuration directory.

```bash
[ -d /mnt/etc/nixos ] && cp -r /mnt/etc/nixos /mnt/etc/nixos.bkp;  rm -Rf /mnt/etc/nixos/* && cp -r ./nixos-configuration/nix/* /mnt/etc/nixos
```

The command above will:

- Create a backup of the nixos configuration files;
- Remove the current configuration files;
- Copy the files from the repository to the nixos configuration directory.

Shutdown your machine and remove the USB drive(or the ISO) and boot your machine.

### Nioscli

Nioscli is a cli tool that I've created to help me run some commands in the nixos installation process.
The main goal is not to create a tool to replace the nixos tools, but to help use the terminal in a more verbose way.
Currently I didn't have time to create a documentation for it, but you can use the `nioscli --help` to see the available commands.

Basically you can run bootrap the disks, generate the hardware configuration, generate the nixos configuration files;

## A Command To Rule Them All

If you want to run all the commands in one go you can use the following command:

```bash
nix-shell -p git --run "\
chmod +x ./nixos-configuration/nix/tools/nioscli && \
./nixos-configuration/nix/tools/nioscli create disko --path ./nixos-configuration/nix/disko/default/disko.nix  && \
./nixos-configuration/nix/tools/nioscli create hardware --no-filesystem --move-file --destination ./nixos-configuration/nix/hosts/example && \
mkdir -p /mnt/etc/ssh && \
mkdir -p /mnt/var/lib/sops-nix && \
[[ -f keys/keys.txt ]] && cp keys/keys.txt /mnt/var/lib/sops-nix/keys.txt && \
[[ -f keys/ssh_id_ed25519 ]] && cp keys/ssh_id_ed25519 /mnt/etc/ssh/ssh_id_ed25519 && \
[[ -f keys/ssh_id_ed25519.pub ]] && cp keys/ssh_id_ed25519.pub /mnt/etc/ssh/ssh_id_ed25519.pub && \
[[ -f keys/id_rsa ]] && cp keys/id_rsa /mnt/etc/ssh/id_rsa && \
[[ -f keys/id_rsa.pub ]] && cp keys/ssh_id_ed25519.pub /mnt/etc/ssh/id_rsa.pub
"


# I didn't put the nixos-install command together with the others, because you may want to personalize the variables before running the nixos-install command
# After running the commands above you can run the following command to install nixos
nixos-install --root /mnt --flake ./nixos-configuration/nix#example  && \
[ -d /mnt/etc/nixos ] && cp -r /mnt/etc/nixos /mnt/etc/nixos.bkp;  rm -Rf /mnt/etc/nixos/* && cp -r ./nixos-configuration/nix/* /mnt/etc/nixos
```

## WSL

If you want to use this repository in WSL you basically need:

- If you don't want to run a step-by-step check the [WSL A Command To Rule Them All](#wsl-a-command-to-rule-them-all);
- Install WSL [here](https://docs.microsoft.com/en-us/windows/wsl/install);
- Add NixOS distribution to WSL [here](#add-nixos-distribution-to-wsl);
- Update the system channels [here](#wsl-update-the-system-channels);
- Run nix shell and install git [here](#wsl-installing-git);
- Delete the default nixos configuration files [here](#wsl-clear-the-nixos-configuration-files);
- (Optional) Modify the [variables.nix](hosts/wsl/variables/host.nix) file to your own configurations;
- Run the nix rebuild wsl command [here](#wsl-rebuild-nixos-configuration);
- Usefull commands [here](#wsl-usefull-commands);

### WSL Installing git

After you connected to your WSL distribution you can run the following command to install git:

```bash
    nix-shell -p git
```

### WSL Clear the nixos configuration files

I recommend you to delete the default nixos configuration files, because they are not needed in WSL.

```bash
rm -Rf /etc/nixos
```

Then you can create a symbolic link to the nixos configuration files in the repository where you saved your nixos configuration files.

For example, if you saved the nixos configuration files in your windows home directory you can run the following command:
> **Note**: Change the path to your own path.
>
> **IMPORTANT**: You can't ln directly the **nix** folder of this repository, because it will give you errors while trying to rebuild the nixos system.
>
> The flake will say that the /etc/nixos is not a directory, so you need to link the parent directory of the nix folder.

```bash
    WINDOWS_HOME_DIR=$(wslpath "$(cmd.exe /C "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')") && \
sudo ln -snf "$WINDOWS_HOME_DIR/nixos" /etc/nixos
```

In my case this repo is saved in another directory, so I run the following command:

```bash
sudo ln -snf /mnt/f/repos/github/dev-vinicius-andrade/nix-configuration /etc/nixos
```

> **Note**:
Also as I'm testing a lot of changes I've created a different folder with a empty git repository to test the changes before I commit to the real version.

```bash
sudo ln -snf /mnt/f/repos/github/dev-vinicius-andrade/nix-configuration_tests /etc/nixos
```

### Add NixOS distribution to WSL

Checkout the [nixos-in-wsl](https://github.com/nix-community/NixOS-WSL) repository to see how to add NixOS to WSL.

I recomend to download the tarball to your windows home directory, because you can simply run the command they provide to install NixOS in WSL.

I don't think the command will change but, check the repository to see the latest instructions.
For now the command is:

**PowerShell**:

```powershell
wsl --import NixOS $env:USERPROFILE\NixOS\ $env:USERPROFILE\nixos-wsl.tar.gz
```

or if you are using pure **CMD**:

```cmd
wsl --import NixOS %USERPROFILE%\NixOS\ %USERPROFILE%\nixos-wsl.tar.gz
```

### WSL Rebuild NixOS Configuration

If you followed the steps above you can run the following command to rebuild the nixos configuration:

```bash
sudo nixos-rebuild switch --flake /etc/nixos/nix#wsl
```

### WSL A Command To Rule Them All

If you want to run all the commands in one go you can use the following command:

```bash
nix-shell -p git --run "\
WINDOWS_HOME_DIR=$(wslpath "$(cmd.exe /C "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')") && \
sudo rm -Rf /etc/nixos && \
sudo ln -snf "$WINDOWS_HOME_DIR/nixos" /etc/nixos && \
sudo nixos-rebuild switch --flake /etc/nixos/nix#wsl" && \
sudo reboot
```

In my case:

```bash
nix-shell -p git --run "\
sudo rm -Rf /etc/nixos && \
sudo ln -snf /mnt/e/repos/github/dev-vinicius-andrade/nixos-configuration /etc/nixos && \
sudo nixos-rebuild switch --flake /etc/nixos/nix#wsl" && \
sudo reboot
```


Or:

```bash
nix-shell -p git --run "\
sudo rm -Rf /etc/nixos && \
sudo ln -snf /mnt/e/repos/github/dev-vinicius-andrade/nixos-configuration /etc/nixos && \
sudo nixos-rebuild switch --flake /etc/nixos/nix#wsl --show-trace" && \
sudo reboot
```

### WSL Update the system channels

If you want to update the system channels you can run the following command:

```bash
sudo nix-channel --update
```

### WSL Usefull commands

If you ever needed to remove the NixOS distribution from WSL you can use the following command:

**PowerShell**:

```powershell
wsl --unregister NixOS
```

or if you are using pure **CMD**:

```cmd
wsl --unregister NixOS
```

### SOPS

In order to use the sops to manage the secrets there are some steps that you need to follow, depending on the system you are using.

- [Pre-Requisites](#sops-pre-requisites)
- [SOPS in WSL](#sops-in-wsl)

#### SOPS Pre-Requisites

1. Generate a new ssh key pair:
    - [Generating a new ssh key pair on windows](#generating-a-new-ssh-key-pair-on-windows);
    - [Generating a new ssh key pair on nixos iso](#generating-a-new-ssh-key-pair-on-nixos-iso);

##### Generating a new ssh key pair on windows

> **IMPORTANT**:  If you copy the variables file to create a new host, make sure the sops configuration are correctly set, I mean, the sops.age.sshKeyPaths should point to the correct ssh key pair, in this case the `ssh_id_ed25519`, because it's the name we are defining in the -f flag.
> **NOTE**: replaca the name of the key value in all commands of this file that uses it.
If you are on a windows machine, you will need the [Git Bash](https://git-scm.com/downloads) to generate the ssh key pair.

```bash
        ssh-keygen -t ed25519 -C "ssh" -f ~/.ssh/ssh_id_ed25519
```

> I recommend you to use the ed25519 key pair, but you can use the rsa key pair if you want.
>
> The command above will generate a new ssh key pair with the name `ssh_id_ed25519` in the `~/.ssh` directory.

After that you may need to copy the ssh keys to the `ISO /etc/ssh directory` or to your wsl `/etc/ssh directory`, you can use the following command:

```bash
    sudo cp ~/.ssh/ssh_id_* /etc/ssh
```

##### Generating a new ssh key pair on ISO

Consider using this step to create your primary ssh key pair which will be use to encrypt you secrets.
So, I'll ansume you are using the nixos iso to generate the ssh key pair.

```bash
    ssh-keygen -t ed25519 -C "ssh" -f /etc/ssh/ssh_id_ed25519
```



#### SOPS in WSL

```bash
HOST_WIN_HOME=$(wslpath $(cmd.exe /C "echo %USERPROFILE%" 2>/dev/null | tr -d "\r")) && \
sudo cp "$HOST_WIN_HOME"/.ssh/ssh_id_* /etc/ssh && \
KEYFILE=/var/lib/sops-nix/keys.txt && sudo mkdir -p $(dirname /var/lib/sops-nix/keys.txt) && \
sudo cp "$HOST_WIN_HOME/.ssh/keys.txt" $(dirname /var/lib/sops-nix/keys.txt)
```

```bash
nix-shell -p git --run "\
chmod +x ./nixos-configuration/nix/tools/nioscli && \
./nixos-configuration/nix/tools/nioscli create disko --path ./nixos-configuration/nix/disko/default/disko.nix  && \
./nixos-configuration/nix/tools/nioscli create hardware --no-filesystem --move-file --destination ./nixos-configuration/nix/hosts/nixos-home-server" && \
./nixos-configuration/nix/tools/nioscli templates --src ./nixos-configuration/nix/templates --dest ./nixos-configuration/nix/ && \
mkdir -p /mnt/etc/ssh && \
mkdir -p /mnt/var/lib/sops-nix && \
[[ -f keys/keys.txt ]] && cp keys/keys.txt /mnt/var/lib/sops-nix/keys.txt && \
[[ -f keys/ssh_id_ed25519 ]] && cp keys/ssh_id_ed25519 /mnt/etc/ssh/ssh_id_ed25519 && \
[[ -f keys/ssh_id_ed25519.pub ]] && cp keys/ssh_id_ed25519.pub /mnt/etc/ssh/ssh_id_ed25519.pub && \
[[ -f keys/id_rsa ]] && cp keys/id_rsa /mnt/etc/ssh/id_rsa && \
[[ -f keys/id_rsa.pub ]] && cp keys/ssh_id_ed25519.pub /mnt/etc/ssh/id_rsa.pub

# I didn't put the nixos-install command together with the others, because you may want to personalize the variables before running the nixos-install command
# After running the commands above you can run the following command to install nixos
nixos-install --root /mnt --flake ./nixos-configuration/nix#nixos-home-server  && \
[ -d /mnt/etc/nixos ] && cp -r /mnt/etc/nixos /mnt/etc/nixos.bkp;  rm -Rf /mnt/etc/nixos/* && cp -r ./nixos-configuration/nix/* /mnt/etc/nixos
```

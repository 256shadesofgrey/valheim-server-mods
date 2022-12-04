# About
This repository contains scripts and other files that I use to manage my Valheim server that runs on an ARM64 machine. I made this repo mostly as a backup for the aforementioned files, and to help me remember how I got it to run in case I have to redo it at some point. I made it public, because someone might find it useful to help setup their own server, but I will not provide any support or help troubleshoot anything.

# Instructions
## Prerequisites
All of the instructions and scripts in this repo assume that [this guide](https://github.com/Nyrren/Free-Valheim-Server-Oracle-Cloud-ARM-Edition) ([mirror](https://github.com/256shadesofgrey/Free-Valheim-Server-Oracle-Cloud-ARM-Edition) in case the original was deleted or changed) was used to setup the server, and the paths you used were the same. Note that I'm not in any way affiliated with the original author of that guide, I just used it to set up my own server.

## Preparation
1. Install 7z on the server to allow the download script to extract the downloaded mods:
   ```
   sudo apt install p7zip-full
   ```
2. For some reason box64 kept crashing every time I tried to run the modded server, so I installed a different emulator, [FEX-Emu](https://github.com/FEX-Emu/FEX). You can skip this step for now and come back later if you want to try running the server with box64 first in case there were any updates that fixed this problem since this was written. If not, follow the installation instructions from the [FEX-Emu github page](https://github.com/FEX-Emu/FEX):
   ```
   curl --silent https://raw.githubusercontent.com/FEX-Emu/FEX/main/Scripts/InstallFEX.py --output /tmp/InstallFEX.py && python3 /tmp/InstallFEX.py && rm /tmp/InstallFEX.py
   ```
## Install mods
1. Clone this repo:
   ```
   git clone https://github.com/256shadesofgrey/valheim-server-mods.git
   ```

2. Switch to its directory:
   ```
   cd valheim-server-mods
   ```

3. Now you can edit the `download_mods.sh` file to select the mods you want to install. This script will download these mods from [valheim.thunderstore.io](https://valheim.thunderstore.io/). You can also download the mods manually at this point, but by adjusting this script you will make it easier for yourself whenever you have to update them.
   ```
   nano download_mods.sh
   ```
   To select the mods you want the script to install, change the variable `MOD_PAGE_LINKS`. The script by default installs the mods that I am using, but the only required part is that BepInEx remains as the first entry. You can delete the rest of it if you don't want it and replace it with the mods that you want to use.

   Go to [valheim.thunderstore.io](https://valheim.thunderstore.io/), search for the mod that you want to install, open the page of that mod, then put everything that comes after `https://valheim.thunderstore.io` except for the version number in quotation marks as another entry in `MOD_PAGE_LINKS`. For example if the link is
   ```
   https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/
   ```
   or
   ```
   https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/5.4.1901/
   ```
   you have to put this as another entry into the list:
   ```
   "/package/denikson/BepInExPack_Valheim/"
   ```
   If you put them in separate lines, make sure to escape the line breaks with `\`, otherwise just leave a space between entries. These are both valid formats:
   ```
   MOD_PAGE_LINKS=("/package/denikson/BepInExPack_Valheim/" \
   "/package/ValheimModding/Jotunn/" \
   "/package/ValheimModding/HookGenPatcher/" \
   "/package/MathiasDecrock/PlanBuild/")
   ```
   ```
   MOD_PAGE_LINKS=("/package/denikson/BepInExPack_Valheim/" "/package/ValheimModding/Jotunn/" "/package/ValheimModding/HookGenPatcher/" "/package/MathiasDecrock/PlanBuild/")
   ```
   If the mod you want to use has prerequisites, make sure that you search for them and add them to the list too.

   Also make sure that you keep track of the `/` in the links. The script is dumb and does not fix the links if there are not enough or too many `/`, so follow the examples closely.

4. Run the script. This will download the mods to `~/downloads/mods`, then extract them and put them in `~/mods`:
   ```
   ./download_mods.sh
   ```
5. Because the mods are in the `~/mods` folder, and not `~/valheim_server` where the server is installed, we need to create links to the relevant files by running the `create_symlinks.sh` script:
   ```
   ./create_symlinks.sh
   ```
   By doing it this way we can restore the "clean" unmodded version of the server without actually deleting the mods by just deleting the links. Think of the `create_symlinks.sh` script as "enable all mods" and the `delete_symlinks.sh` script as "disable all mods".

## Start server
1. When we installed BepInEx, we also got a `start_server_bepinex.sh` script, which we previously linked to the `valheim_server` folder. Edit that script to load the world you want to run, and make sure to change the default password too:
   ```
   cd ~/valheim_server/
   nano start_server_bepinex.sh
   ```
2. Now just start the server:
   ```
   ./start_server_bepinex.sh
   ```

## Play
You should now be able to start the game and log in to your modded server.

## Configure service
TODO: I haven't figured out this part yet.

# Known problems
- The server often crashes when trying to start it. I don't know any fix for it. Maybe use a different emulator in future?

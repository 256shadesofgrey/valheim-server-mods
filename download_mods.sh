#!/bin/bash
SITE_LINK="https://valheim.thunderstore.io"

# Add mods to be downloaded to this array.
# You have to add the rest of the link that comes after the SITE_LINK.
# For example "https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/"
# becomes "/package/denikson/BepInExPack_Valheim/".
# Also BepInEx must always be the first entry in this array.
MOD_PAGE_LINKS=("/package/denikson/BepInExPack_Valheim/" \
"/package/ValheimModding/Jotunn/" \
"/package/ValheimModding/HookGenPatcher/" \
"/package/MathiasDecrock/PlanBuild/")

# Where the downloaded files will go.
DOWNLOAD_PATH="~/downloads/mods/"

# The file extension with which the downloaded files will be saved.
# We need this because we won't use the original file names.
FILE_EXTENSION="zip"

# Where the mods will be installed.
INSTAL_PATH="~/mods/"

# Files will be extracted here before installation.
# Because this folder will be deleted afterwards, try to create a unique name for it,
# so that we don't accidentally delete something important.
TEMP_EXTRACTION_PATH="/tmp/valheim-mods-""$(date +%s)""/"

# Get the highest index of the MOD_PAGE_LINKS array.
LAST_INDEX=$((${#MOD_PAGE_LINKS[@]}-1))

# Regex to match every version string with the additional / at the end to complete the link.
VERSION_REGEX="([0-9]*\.){2}[0-9]*/"

# Array that will contain the download links.
MOD_DOWNLOAD_LINKS=()

# Array that will contain the mod names.
MOD_NAMES=()

# Generate the regex to match download links on the page and save it as MOD_DOWNLOAD_LINKS.
# Get mod names from the provided links.
for ((i=0; i<=$LAST_INDEX; ++i))
do
    MOD_DOWNLOAD_LINKS[$i]=$(echo ${MOD_PAGE_LINKS[$i]} | sed "s/\/package/\/package\/download/g")
    MOD_DOWNLOAD_LINKS[$i]+=$VERSION_REGEX
    MOD_NAMES[$i]=$(echo ${MOD_PAGE_LINKS[$i]} | sed "s/\/package\/[a-zA-Z0-9]*\///" | sed "s/\/$//")
done

# Get the first link on each page that matches the expected format of the download link.
# Because the latest version is listed first, the first match is the latest version.
for ((i=0; i<=$LAST_INDEX; ++i))
do
    FULL_MOD_PAGE_LINK=$SITE_LINK${MOD_PAGE_LINKS[$i]}

    # This downloads the page and searches it for the download link.
    MOD_DOWNLOAD_LINKS[$i]=$(wget -q ${FULL_MOD_PAGE_LINK} -O - | grep -m1 -iohE ${MOD_DOWNLOAD_LINKS[$i]})

    # Combine the download link with the SITE_LINK to get the full link that we can use.
    MOD_DOWNLOAD_LINKS[$i]=$SITE_LINK${MOD_DOWNLOAD_LINKS[$i]}

    echo "Acquired download link: " ${MOD_DOWNLOAD_LINKS[$i]}
done

# Download the mods to the download folder, name them $i.$FILE_EXTENSION (i.e. 0.zip, 1.zip...)
mkdir -p "$(eval echo $DOWNLOAD_PATH)"
for ((i=0; i<=$LAST_INDEX; ++i))
do
    #wget ${MOD_DOWNLOAD_LINKS[$i]} -O "$(eval echo ${DOWNLOAD_PATH}${i}.${FILE_EXTENSION})"
    curl --connect-timeout 20 --max-time 20 --retry-delay 30 --retry 10 -o "$(eval echo ${DOWNLOAD_PATH}${i}.${FILE_EXTENSION})" -L ${MOD_DOWNLOAD_LINKS[$i]}
done

# Extract files to the temp folder.
mkdir -p "$(eval echo $TEMP_EXTRACTION_PATH)"
for ((i=0; i<=$LAST_INDEX; ++i))
do
    7z -y x "$(eval echo ${DOWNLOAD_PATH}${i}.${FILE_EXTENSION})" -o"$(eval echo $TEMP_EXTRACTION_PATH/${MOD_NAMES[$i]}/)"
done

# Move bepinex to the mod instal folder.
# This has to be done separately, because the paths are different from the other mods.
rsync -r "$(eval echo $TEMP_EXTRACTION_PATH${MOD_NAMES[0]}/${MOD_NAMES[0]}/)"* "$(eval echo $INSTAL_PATH)"

# Move the rest of the mods to the bepinex folder.
for ((i=1; i<=$LAST_INDEX; ++i))
do
    cd $TEMP_EXTRACTION_PATH/${MOD_NAMES[$i]}/
    FILES_TO_MOVE=$(ls $TEMP_EXTRACTION_PATH/${MOD_NAMES[$i]}/ -I icon.png -I manifest.json -I README.md)
    rsync -r $FILES_TO_MOVE "$(eval echo ${INSTAL_PATH}BepInEx/)"
done

# Delete the temporary folder.
rm -rf "$(eval echo $TEMP_EXTRACTION_PATH)"

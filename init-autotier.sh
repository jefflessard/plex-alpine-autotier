#!/usr/bin/with-contenv bash

preferences="/config/Library/Application Support/Plex Media Server/Preferences.xml"
default="/config/Library/Application Support/Plex Media Server/Cache"
tier1="${AUTOTIER_PATH:-'/tmp/autotier'}"
tier2="/config/Library/Application Support/Plex Media Server/Cache/Transcode-autotier"
quota="${AUTOTIER_QUOTA:-'512MiB'}"

tempdir=$(cat "$preferences" | grep -Eo 'TranscoderTempDirectory="[^"]*"' | sed -E 's/TranscoderTempDirectory="([^"]*)"/\1/')
tempdir=${tempdir:-"$default"}
tempdir="$tempdir/Transcode"

echo "Configuring autotierfs :"
echo "	tier1=$tier1 ($quota)"
echo "	tier2=$tier2"
echo "	mount=$tempdir"

sed -i "s|{tier1}|$tier1|" /etc/autotier.conf
sed -i "s|{tier2}|$tier2|" /etc/autotier.conf
sed -i "s|{quota}|$quota|" /etc/autotier.conf

su abc -s /bin/bash -c "mkdir -p '$tier1' '$tier2' '$tempdir'"

mount --bind "$tempdir" "$tier2"

autotierfs "$tempdir" -o allow_other,default_permissions

#chown nobody:abc "$tier1" "$tier2" "$tempdir"

echo "autotier status:"
autotier status


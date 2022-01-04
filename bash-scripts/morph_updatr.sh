#!/usr/local/bin/bash
#:
#: Morpheus Incremental Updater
#: Taken from https://www.morpheusdata.com/support/getting-started/installation#download
#:
#: Download the latest revision:
#:
NVERS=$(curl -s --ssl https://www.morpheusdata.com/support/release-notes |awk -F'>' '/Release Notes/ {print $3}' |tr -d [:alpha:] |cut -d'<' -f1 |sort -nr |head -1 |sed 's/ //g')
#:
function IVERS() {
	dpkg --get-selections |awk '/morph/ {print $1}' |xargs dpkg -s |awk -F: '/Version/ {print $2}' |sed 's/ //g' |cut -d- -f1
}
#:
#: Check installed version against latest release
#:
NVERS_CONVERT=$(echo $NVERS |tr -d [:punct:])
#:
function IVERS_CONVERT() {
	IVERS |tr -d [:punct:]
}
#:
#: Banner
#:
echo "
                      ______
                     /     /\
                    /     /##\
                   /     /####\
                  /     /######\
                 /     /########\
                /     /##########\
               /     /#####/\#####\
              /     /#####/++\#####\
             /     /#####/++++\#####\
            /     /#####/\+++++\#####\
           /     /#####/  \+++++\#####\
          /     /#####/    \+++++\#####\
         /     /#####/      \+++++\#####\
        /     /#####/        \+++++\#####\
       /     /#####/__________\+++++\#####\
      /                        \+++++\#####\
     /__________________________\+++++\####/
     \+++++++++++++++++++++++++++++++++\##/
      \+++++++++++++++++++++++++++++++++\/
       ``````````````````````````````````
     __  __  ___  ___ ___ _  _ ___ _   _ ___
    |  \/  |/ _ \| _ \ _ \ || | __| | | / __|
    | |\/| | (_) |   /  _/ __ | _|| |_| \__ \
    |_|  |_|\___/|_|_\_| |_||_|___|\___/|___/
                 Installer v1.0
"
printf '\n\e[1;32m%-6s\e[m\n\n' "Version Check:"
if [[ $NVERS_CONVERT -gt $(IVERS_CONVERT) ]]; then
	printf '\e[1;33m%-6s\e[m\n' "The installed version $(IVERS) is behind the latest available release version $NVERS"
	printf '\e[1;33m%-6s\e[m\n\n' "Fetching the latest appliance release for installation: morpheus-appliance_${NVERS}-1_amd64.deb"
	wget --tries=3 https://downloads.gomorpheus.com/apt/dists/morpheus/main/binary-amd64/morpheus-appliance_${NVERS}-1_amd64.deb
elif [[ $NVERS_CONVERT -eq $(IVERS_CONVERT) ]]; then
	printf '\e[1;31m%-6s\e[m\n' "The installed version $(IVERS) is >= the latest publically available release version $NVERS"
	printf '\e[1;31m%-6s\e[m' "If you have been provided a custom package, enter the package name now: "
	read -r CUSTOM_PACKAGE
	NVERS=$(echo $CUSTOM_PACKAGE |cut -d_ -f2 |cut -d- -f1)
	NVERS_CONVERT=$(echo $NVERS |tr -d [:punct:])
	printf '\e[1;31m%-6s\e[m\n' "Fetching $CUSTOM_PACKAGE:"
	wget --tries=3 https://downloads.gomorpheus.com/apt/dists/morpheus/main/binary-amd64/${CUSTOM_PACKAGE}
else
	printf '\e[1;31m%-6s\e[m\n' "The installed version $(IVERS) is >= the latest available release version $NVERS"
	printf '\e[1;31m%-6s\e[m\n' "OR"
	printf '\e[1;31m%-6s\e[m\n' "Whatever you entered as your custom package was invalid: $CUSTOM_PACKAGE"
	printf '\e[1;31m%-6s\e[m\n\n' "The appliance will remain as: morpheus-appliance_$(IVERS)-1_amd64.deb"
	exit 0;
fi
#:
#: Confirm the file is present or exit
#:
if [ ! -e ~/morpheus-appliance_${NVERS}-1_amd64.deb ]; then
	ls -l ~/morpheus-appliance_${NVERS}-1_amd64.deb
	printf '\e[1;31m%-6s\e[m\n\n' "The expected file does not exist; aborting"
	exit 1;
fi
#:
#: Update the system packages
#:
printf '\e[1;31m%-6s\e[m\n\n' "Updating System Packages"
sudo apt-get update
#:
#: Install the new package
#:
sudo dpkg -i morpheus-appliance_${NVERS}-1_amd64.deb
#:
#: Pause for station identification...
#:
for i in {30..0}; do
	printf '\e[1;33m%-6s\e[m\r' "Verifying morpheus-appliance_${NVERS}-1_amd64.deb. Pausing for $i seconds: "
	sleep 1;
done;
printf '\e[1;33m%-71s\e[m\n\n' "Complete."
#:
printf '\e[1;33m%-6s\e[m\n\n' "Post Validation:"
dpkg --get-selections |awk '/morph/ {print $1}' |xargs dpkg -s |egrep 'Version|Package'
#:
#: Recheck what the appliance recognizes as the installed package
#:
if [[ $NVERS_CONVERT -eq $(IVERS_CONVERT) ]]; then
	printf '\e[1;33m%-6s\e[m\n\n' "Appliance successfully upgraded to Version: $NVERS"
else
	printf '\e[1;33m%-6s\e[m\n' "Something hath run a-muck."
	printf '\e[1;33m%-6s\e[m\n\n' "The appliance should be Version: $NVERS, not $(dpkg --get-selections |awk '/morph/ {print $1}' |xargs dpkg -s |grep Version)"
	exit 1;
fi
#:
#: Reconfiguring Morpheus as the new version
#:
printf '\e[1;33m%-6s\e[m\n\n' "Reconfiguring the new appliance:"
sudo morpheus-ctl reconfigure
#:
printf '\e[1;33m%-6s\e[m\n' "Morpheus takes approximately 3 minutes to start.  You may experience a '502 Bad gateway' error until then."
printf '\e[1;33m%-6s\e[m\n' "Upon completion, it will be available at: https://morpheus.ops.hightail.com/"
printf '\e[1;33m%-6s\e[m\n\n' "Should anything fail at this point, simply re-run 'sudo morpheus-ctl reconfigure' and all will be well :)"
#:
#: Cleanup
#:
sudo morpheus-ctl stop morpheus-ui
for i in $(ps auxwww |awk '/morpheus/ {print $2}'); do
  sudo kill -9 $i;
done
sleep 10;
sudo morpheus-ctl start morpheus-ui
for i in {240..0}; do
	printf '\e[1;33m%-6s\e[m\r' "Verifying morpheus-appliance_${NVERS}-1_amd64.deb startup. Pausing for $i seconds: "
	sleep 1;
done;
printf '\e[1;33m%-80s\e[m\n\n' "Complete, checking logs for startup entries:"
#:
sudo grep -A1 -B6 "Start Time: " /var/log/morpheus/morpheus-ui/current
#:
dpkg --get-selections |awk '/morph/ {print $1}' |xargs dpkg -s |grep Version
printf '\e[1;33m%-6s\e[m\n\n' "UPGRADE COMPLETE"
#:
#: EOF
#:

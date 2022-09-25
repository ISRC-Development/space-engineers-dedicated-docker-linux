#!/bin/bash

# #check if /appdata/space-engineers/config/World is a folder
if [ ! -d "/appdata/space-engineers/World" ]; then
  echo "World folder does not exist, exiting"
  exit 129
fi

# #check if /appdata/space-engineers/config/World/Sandbox.sbc exists and is a file
if [ ! -f "/appdata/space-engineers/World/Sandbox.sbc" ]; then
  echo "Sandbox.sbc file does not exist, exiting."
  exit 130
fi

# #check if /appdata/space-engineers/config/SpaceEngineers-Dedicated.cfg is a file
if [ ! -f "/appdata/space-engineers/SpaceEngineersDedicated/SpaceEngineers-Dedicated.cfg" ]; then
  echo "SpaceEngineers-Dedicated.cfg file does not exist, exiting."
  exit 131
fi

#set <LoadWorld> to the correct value
cat /appdata/space-engineers/SpaceEngineersDedicated/SpaceEngineers-Dedicated.cfg | sed -E '/.*LoadWorld.*/c\  <LoadWorld>Z:\\appdata\\space-engineers\\World</LoadWorld>' > /tmp/SpaceEngineers-Dedicated.cfg && cat /tmp/SpaceEngineers-Dedicated.cfg > /appdata/space-engineers/SpaceEngineersDedicated/SpaceEngineers-Dedicated.cfg

#set game port to the correct value
#cat /appdata/space-engineers/SpaceEngineersDedicated/SpaceEngineers-Dedicated.cfg | sed -E '/.*ServerPort.*/c\  <ServerPort>27016</ServerPort>' > /tmp/SpaceEngineers-Dedicated.cfg && cat /tmp/SpaceEngineers-Dedicated.cfg > /appdata/space-engineers/SpaceEngineersDedicated/SpaceEngineers-Dedicated.cfg

#configure plugins section in SpaceEngineers-Dedicated.cfg
#get new plugins string

if [ "$(ls -1 /appdata/space-engineers/Plugins/*.dll | wc -l)" -gt "0" ]; then
  PLUGINS_STRING=$(ls -1 /appdata/space-engineers/Plugins/*.dll |\
  awk '{ print "<string>" $0 "</string>" }' |\
  tr -d '\n' |\
  awk '{ print "<Plugins>" $0 "</Plugins>" }' )
else
  PLUGINS_STRING="<Plugins />"
fi

SED_EXPRESSION_EMPTY="s/<Plugins \/>/${PLUGINS_STRING////\\/} /g"
SED_EXPRESSION_FULL="s/<Plugins>.*<\/Plugins>/${PLUGINS_STRING////\\/} /g"

#find and replace in SpaceEngineers-Dedicated.cfg for empty "<Plugins />" element
cat /appdata/space-engineers/SpaceEngineersDedicated/SpaceEngineers-Dedicated.cfg | sed -E "$SED_EXPRESSION_EMPTY" > /tmp/SpaceEngineers-Dedicated.cfg && cat /tmp/SpaceEngineers-Dedicated.cfg > /appdata/space-engineers/SpaceEngineersDedicated/SpaceEngineers-Dedicated.cfg

#find and replace in SpaceEngineers-Dedicated.cfg for filled out "<Plugins>...</Plugins>" element
# sed can't handle multiple lines easily, so everything needs to be on a single line.
cat /appdata/space-engineers/SpaceEngineersDedicated/SpaceEngineers-Dedicated.cfg | sed -E "$SED_EXPRESSION_FULL" > /tmp/SpaceEngineers-Dedicated.cfg && cat /tmp/SpaceEngineers-Dedicated.cfg > /appdata/space-engineers/SpaceEngineersDedicated/SpaceEngineers-Dedicated.cfg


runuser -l wine bash -c 'steamcmd +login anonymous +@sSteamCmdForcePlatformType windows +force_install_dir /appdata/space-engineers/SpaceEngineersDedicated +app_update 298740  +workshop_download_item 244850 642589539 +workshop_download_item 244850 1592304459 +workshop_download_item 244850 406244471 +workshop_download_item 244850 1931509062 +workshop_download_item 244850 1662953858 +workshop_download_item 244850 1918681825 +workshop_download_item 244850 1697184408 +workshop_download_item 244850 514062285 +workshop_download_item 244850 1359954841 +workshop_download_item 244850 2789619117 +workshop_download_item 244850 2143322540 +workshop_download_item 244850 2266109786 +workshop_download_item 244850 1521905890 +workshop_download_item 244850 1902970975 +quit'
runuser -l wine bash -c '/entrypoint-space_engineers.bash'
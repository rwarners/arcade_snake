export PATH=/userdata/system/java/jdk-24.0.2/bin:$PATH
#batocera-save-overlay
# Read the current directory this script is being executed from and save to variable DIR.
DIR="$(dirname "$(readlink -f "$0")")"
# Change the current directory to that of the game's data folder. cd "${DIR}/.data/<folder of game here>"
cd "${DIR}"
# Show the mouse cursor. It's a good idea to first show it when setting up the game, in case it's needed.
unclutter-remote -s
./start
# These events will be executed once the game terminates.
# Hide the mouse cursor as we are going back to ES.
unclutter-remote -h

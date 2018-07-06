#!/usr/bin/env bash

# ======================================================================================

# The University of Edinburgh
# University Website Programme

# Bash script for building a range of pre-configured Docker files.

# Developed by: Callum Kerr
# Special thanks: Angelos Athanasakos, coffee, Stack Overflow

# Version: 1.0
# Date: Feburary 2017

# ======================================================================================

IMG="edweb"

function completed {

	clear
	echo "   _____ ____  __  __ _____  _      ______ _______ ______ _ "
	echo "  / ____/ __ \|  \/  |  __ \| |    |  ____|__   __|  ____| |"
	echo " | |   | |  | | \  / | |__) | |    | |__     | |  | |__  | |"
	echo " | |   | |  | | |\/| |  ___/| |    |  __|    | |  |  __| | |"
	echo " | |___| |__| | |  | | |    | |____| |____   | |  | |____|_|"
	echo "  \_____\____/|_|  |_|_|    |______|______|  |_|  |______(_)"
	echo ""
	echo "Awesome, that's your new machine built!"
	echo ""
	echo "We're starting it now, hang on a wee second..."
}

function run_container() {
	# Run the Docker image we've just built with some parameters.
	
	echo ""
	echo -n "What port do you want to run on? (exit to cancel) Type here: "
	read portNumber

	if [ "$portNumber" == "exit" ]; then
		echo ">>> Cancelled. Bye! :)"
	else
		echo ">>> Chosen to run on $portNumber."
		echo ""
		docker run -e "portNumber=$portNumber" -p $portNumber:80 -p 9000:9000 -d -v $(pwd)/www:/var/www/html --name $IMG-$portNumber $IMG 
		RESULT=$?
	fi	

	

	if [ $RESULT -ne 0 ]; then
		echo ""
		echo ">>> Oops, something went wrong. Most likely a machine is already running with that port number assigned."
	else
		echo ">>> Successfully started!"
		echo ""
		echo "The Docker machine has started"
		echo ">>> Access it here: http://192.168.10.10:$portNumber"
		echo ""
		echo "We're in the process of setting up some folders inside the machine, please wait a minute or two before"
		echo "trying to access the machine via a browser. The first time you load the site will also take a couple of minutes."
		echo ""
		echo "Otherwise, we're all done! Happy building! :)"
	fi
}



function installDist () {

	echo "Building image"
	
	docker build -t $IMG . --build-arg installVersion=http://dist.drupal.is.ed.ac.uk/files/project/uoe_distribution-7.x-1.15-core.tar.gz 
	
	if [ $? -eq 0 ]; then
		completed
	else
		echo "================================================"
		echo "Something went wrong during the build process."
		echo "If you made any changes to the Dockerfile or script, please review the output above."
	fi
}





# Restart the script where appropriate.
function restartScript {

	clear
	echo ""
	echo "  _    _  ____  ______   _____   ____   _____ _  ________ _____ "
	echo " | |  | |/ __ \|  ____| |  __ \ / __ \ / ____| |/ /  ____|  __ \ "
	echo " | |  | | |  | | |__    | |  | | |  | | |    | ' /| |__  | |__) |"
	echo " | |  | | |  | |  __|   | |  | | |  | | |    |  < |  __| |  _  / "
	echo " | |__| | |__| | |____  | |__| | |__| | |____| . \| |____| | \ \ "
	echo "  \____/ \____/|______| |_____/ \____/ \_____|_|\_\______|_|  \_\ v1.0"
	echo ""
	echo "Welcome!"
	echo ""
	echo "This script will help you to install and run a Docker image."
	echo ""

}

echo "Starting..."




if [[ -z $(docker images -q $IMG:latest) ]]; then 
    installDist
fi

echo "Running container..."
restartScript
run_container



# Start with restarting. Yeah.









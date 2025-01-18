#!/usr/bin/bash


clear

mkdir -p Databases

cd Databases/

# Colors
RED='\033[31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Symbols
CHECKMARK="✔"
CROSSMARK="✘"
ARROW="→"


# =====> Helper Functions <=====
# Function to check if input is alphabetic
is_alpha() {
    if [[ "$1" =~ ^[a-zA-Z-]+$ ]]; then
        return 0  
    else
        return 1  
    fi
}

# Function to confirm deletion
confirm_deletion() {

	# Prompt the user for confirmation
	echo -e "${RED} ${ARROW} Are you sure you want to delete the database '$1'? (yes/y to confirm): ${YELLOW}"
	read -p "${ARROW}: " choice

	# Convert the user's input to lowercase for case-insensitive comparison
    	choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    	# Check if the input is 'yes' or 'y'
    	if [[ "$choice" == "yes" || "$choice" == "y" ]]; then
        	return 0  
    	else
        	return 1  
    	fi
}

# Function to ensure input is not empty
check_non_empty() {
    if [[ -z "$1" ]]; then
        return 1  
    else
        return 0  
    fi
}

# Exists the application
exit_app() {	
	echo -e "${CYAN} Exiting..."
	sleep .5
	exit 0
}

display_main_menu_options() {
    	echo
	echo -e "${CYAN} ### Main Menu (Database Creation Options) ###"
	echo -e "-------------------------------------------------${YELLOW}"	
	echo
    	echo -e "1) create_db\t  3) connect\t  5) clear_screen"
    	echo -e "2) list_dbs\t  4) drop_db\t  6) quit"
    	echo
}

# Function to display the menu
display_sub_menu_options() {
	echo
	echo -e "${CYAN} ### Table Creation Options Menu ###"
	echo -e "-------------------------------------------------${YELLOW}"	
	echo
	echo -e "1) create_table\t  4) insert_into\t  7) update_table\t  10) quit"
	echo -e "2) list_tables\t  5) select_from\t  8) main_menu"
	echo -e "3) drop_table\t  6) delete_from\t  9) clear_screen"
	echo
}

# =====> Main Menu Functions <=====
# Function to handle db creation option
create_db() {
	echo -ne "${ARROW} ${BLUE} Please enter a db name: ${YELLOW}"
	read dbName
	check_non_empty $dbName
	if [ $? -ne 0 ] ; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Db name can't be empty ${YELLOW}"
		echo
	else
		if [ -d $dbName ]; then
			echo
			echo -e "${RED} ${CROSSMARK} Fail: This name already exist ${YELLOW}"
			echo

		else
			if is_alpha $dbName; then
				mkdir $dbName
				echo
				echo -e "${GREEN} ${CHECKMARK} Success: DB created Successfuly ${YELLOW}"
				echo
			else
				echo
				echo -e "${RED} ${CROSSMARK} Fail: DB name can only contain alphabetic characters and - ${YELLOW}"
				echo
			fi
		fi
	fi
}

# Function to list all databases
list_dbs() {
	numberOfDbs=$(ls | wc -l)
	if [ $numberOfDbs -eq 0 ]; then
		echo -e ${RED}
		echo -e "${CROSSMARK} You don't have any databases"
		echo -e ${YELLOW}
	else
		echo -e "${GREEN} ${CHECKMARK} List of all databases: ${YELLOW}"
		echo -e "${BLUE}" 
		ls
		echo -e "${YELLOW}" 
	fi

}

# Connect to database
connect_db() {
	echo -ne "${ARROW} ${BLUE} Please enter a db name: ${YELLOW}"
	read dbName
	check_non_empty $dbName
	if [ $? -ne 0 ] ; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Db name can't be empty ${YELLOW}"
		echo
	else
		if [ -d $dbName ]; then
			echo
			echo -e "${GREEN} ${CHECKMARK} Suceess: Connected to db: $dbName ${YELLOW}"
			cd $dbName
			PS3="${ARROW} (${dbName}) -- Please select an option: "

			# Render New Select Menu
			render_table_control_menu
		else
			echo
			echo -e "${RED} ${CROSSMARK} Fail: Invalid db name ${YELLOW}"
			echo
		fi
	fi
}

# Function to drop database
drop_db() {
	echo -ne "${ARROW} ${BLUE} Please enter a db name: ${YELLOW}"
	read dbName
	check_non_empty $dbName
	if [ $? -ne 0 ] ; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Db name can't be empty ${YELLOW}"
		echo
	else
		if [ -d $dbName ]; then
			if confirm_deletion $dbName; then
				rm -r $dbName
				echo
				echo -e "${GREEN} ${CHECKMARK} Suceess: Database dropped: $dbName ${YELLOW}"
				echo
			else
				echo
				echo -e "${RED} ${CROSSMARK} Fail: Database ${dbName} was not deleted. ${YELLOW}"
				echo
			fi
		else
			echo
			echo -e "${RED} ${CROSSMARK} Fail: Invalid db name ${YELLOW}"
			echo
		fi
	fi
}


# Function to show the main menu
render_main_menu() {
	echo
	echo -e "${CYAN} ### Main Menu (Database Creation Options) ###"
        echo -e "-------------------------------------------------${YELLOW}"	
	echo
	PS3="${ARROW} Please select an option: "
	ddl=(create_db list_dbs connect drop_db clear_screen quit)
	select option in ${ddl[@]}; do
		echo "_________________________________"
		echo
		case $option in
			create_db) create_db;;
			list_dbs) list_dbs;; 
			connect) connect_db;;
			drop_db) drop_db;; 
			clear_screen) clear; display_main_menu_options;;
			quit) exit_app;; 
			*) 	
				echo -e "${RED} ${CROSSMARK} Invalid option. Try again. ${YELLOW}"
				echo;;

	esac
done	
}

# =====> Sub-Menu Functions <=====
return_to_main_menu() {
	
	cd ..	
	PS3="${ARROW} Please select an option: "
	display_main_menu_options
}
# Function to show table controls menu
render_table_control_menu() {
	dml=(create_table list_tables drop_table insert_into select_from delete_from update_table main_menu clear_screen quit)
	echo
	echo -e "${CYAN} ### Table Creation Options Menu ###"
        echo -e "-------------------------------------------------${YELLOW}"	
	echo
	select option in ${dml[@]}; do
		case $option in
			create_table) echo Creating table...;;
			list_tables) echo Listing tables...;;
			drop_table) echo Dropping table...;;
			insert_into) echo Inserting...;;
			select_from) echo Selecting...;;
			delete_from) echo Deleting...;;
			update_table) echo Updating...;;
			main_menu)
				return_to_main_menu
				return
				;;
			clear_screen) clear; display_sub_menu_options;;
			quit) exit_app;;
		esac
	done
}

render_main_menu


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
# Function to check if the input is alphabetic
is_alpha() {
    if [[ "$1" =~ ^[a-zA-Z-]+$ && -n "$1" ]]; then
        return 0  
    else
        return 1  
    fi
}

# Function to check if the input is numeric
is_numeric() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        return 0 
    else
        return 1  
    fi
}

# check if a column exists in a table
is_column_exists() {
    if grep -wq "$1" "$2"; then
        return 0  
    else
        return 1 
    fi
}

# Function that prompts user to choose y/n for action confirmation 
confirm_action() {
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

# Function to confirm deletion
confirm_deletion() {

	# Prompt the user for confirmation
	echo -e "${RED} ${ARROW} Are you sure you want to delete the database '$1'? (yes/y to confirm): ${YELLOW}"

	confirm_action
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
render_col_datatype_menu() {
	options=(str int)
	select option in ${options[@]}; do
		case $option in
			str) echo str; break;;
			int) echo int; break;;
		esac
	done
}

# Function to check if the value already exists
# Usage: column-Number, table_name, entered_value
is_duplicate_pk_value() {
	if awk -F ":" -v value="$3" '{if ($1 == value) found=1} END {exit !found}' "$2"; then
		return 0
	else
		return 1
	fi
}

create_table() {
	echo -ne "${ARROW} ${BLUE} Please enter a table name: ${YELLOW}"
	read tblName
	check_non_empty $tblName
	if [ $? -ne 0 ] ; then
                  echo
                  echo -e "${RED} ${CROSSMARK} Fail: Table name can't be empty ${YELLOW}"
                  echo
	else
		if [ -f $tblName ]; then
			echo
			echo -e "${RED} ${CROSSMARK} Fail: This name already exist ${YELLOW}"
			echo

		else
			if is_alpha $tblName; then
				echo -ne "${ARROW} ${BLUE} Please enter number of columns: ${YELLOW}"
				read numberOfCols

				while ! is_numeric $numberOfCols; do
					echo
					echo -e "${RED} ${CROSSMARK} Fail: Please enter a valid number ${YELLOW}"
					echo
					echo -ne "${ARROW} ${BLUE} Please enter number of columns: ${YELLOW}"
					read numberOfCols
				done

				touch .$tblName-metadata

				isPkExists=0
				for ((i=1;i<=numberOfCols;i++)); do
					line=""

					while true; do
						echo -ne "${ARROW} ${BLUE} column number $i name: ${YELLOW}"
						read colName
						
						# Check if the column name is non-empty
						if ! check_non_empty "$colName"; then
								echo -e "${RED} ${CROSSMARK} Fail: Column name can't be empty ${YELLOW}"
								continue
						fi
						
						# Check if the column name contains only alphabetic characters and hyphen
						if ! is_alpha "$colName"; then
								echo -e "${RED} ${CROSSMARK} Fail: Column name can only contain alphabetic characters and - ${YELLOW}"
								continue
						fi
						
						# Check if the column name already exists
						if is_column_exists $colName ".${tblName}-metadata"; then
								echo -e "${RED} ${CROSSMARK} Fail: Column with the same name already exists ${YELLOW}"
								continue
						fi
						
						break
					done
					
					line+=$colName:

					echo
					echo -e "${CYAN} ### Column Datatype Options Menu ###"
					echo -e "-------------------------------------------------${YELLOW}"	

					line+=$(render_col_datatype_menu):

					if [ $isPkExists -eq 0 ]; then
						echo -ne "${ARROW} ${BLUE} Do you want to make column: $colName the primary key: ${YELLOW}"
						if confirm_action; then
							line+=pk
							isPkExists=1
						else
						line+="null"
						fi
					else
						line+="null"
					fi

					echo $line >> .$tblName-metadata
				done

				touch $tblName
			
				echo
				echo -e "${GREEN} ${CHECKMARK} Success: Table created Successfully ${YELLOW}"
				echo	
			
			else
				echo
				echo -e "${RED} ${CROSSMARK} Fail: table name can only contain alphabetic characters and - ${YELLOW}"
				echo
			fi
		fi
	fi

}

insert_into() {
	echo -ne "${ARROW} ${BLUE} Please enter a table name: ${YELLOW}"
  read tblName
  check_non_empty $tblName
  if [ $? -ne 0 ] ; then
	  echo
    echo -e "${RED} ${CROSSMARK} Fail: Table name can't be empty ${YELLOW}"
    echo
  else
		if [ -f $tblName ]; then
			numberOfCols=$(wc -l .$tblName-metadata | cut -d" " -f1)
			line=""
			for ((i=1; i<=numberOfCols; i++)); do
			  col=$(sed -n "${i}p" .$tblName-metadata)
				colName=$(echo $col | cut -d: -f1)
				colDataType=$(echo $col | cut -d: -f2)
				colPkCheck=$(echo $col | cut -d: -f3)

				while true; do
					echo -ne "${ARROW} ${BLUE} Please enter value for column: $colName ($colDataType): ${YELLOW}"
        	read value
					if ! check_non_empty "$value"; then
					  echo -e "${RED} ${CROSSMARK} Fail: Value can't be empty ${YELLOW}"
            continue
          fi
					case $colDataType in
						str) if ! is_alpha $value; then
							echo -e "${RED} ${CROSSMARK} Fail: Value should be a string ${YELLOW}"
							continue
							fi
							;;
						int) if ! is_numeric $value; then
							echo -e "${RED} ${CROSSMARK} Fail: Value should be a number ${YELLOW}"
							continue
							fi
					esac

					if [[ $colPkCheck == "pk" ]]; then
					  if is_duplicate_pk_value $i $tblName $value; then
						  echo -e "${RED} ${CROSSMARK} Fail: Duplicate primary key value ${YELLOW}"
              continue
            fi
          fi

					break
				done

				# To prevent printing ":" at the end of the last column
				if [ $i -eq $numberOfCols ]; then
					line+=$value
				else
					line+=$value:
				fi

      done
			echo $line >> $tblName
      echo
      echo -e "${GREEN} ${CHECKMARK} Success: Row inserted successfully ${YELLOW}"
      echo
		else
		  echo
      echo -e "${RED} ${CROSSMARK} Fail: Invalid table name ${YELLOW}"
      echo
		fi
    

	fi
}






list_tables() {
	numberOfTables=$(ls | wc -l)
	if [ $numberOfTables -eq 0 ]; then
		echo -e ${RED}
		echo -e "${CROSSMARK} You don't have any tables"
		echo -e ${YELLOW}
	else
		echo -e "${GREEN} ${CHECKMARK} List of all tables: ${YELLOW}"
		echo -e "${BLUE}" 
		ls
		echo -e "${YELLOW}" 
	fi
}


drop_table() {
	echo -ne "${ARROW} ${BLUE} Please enter a table name: ${YELLOW}"
	read tblName
	check_non_empty $tblName
	if [ $? -ne 0 ] ; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Table name can't be empty ${YELLOW}"
		echo
	else
		if [ -f $tblName ]; then
			if confirm_deletion $tblName; then
				rm $tblName
				rm .$tblName-metadata
				echo
				echo Dropping table...
				echo -e "${GREEN} ${CHECKMARK} Suceess: Table dropped: $tblName ${YELLOW}"
				echo
			else
				echo
				echo -e "${RED} ${CROSSMARK} Fail: Table ${tblName} was not deleted. ${YELLOW}"
				echo
			fi
		else
			echo
			echo -e "${RED} ${CROSSMARK} Fail: Invalid table name ${YELLOW}"
			echo
		fi
	fi
}

select_from() {
	echo -ne "${ARROW} ${BLUE} Please enter a table name: ${YELLOW}"
	read tblName
	check_non_empty $tblName
	if [ $? -ne 0 ] ; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Table name can't be empty ${YELLOW}"
		echo
	else
		if [ -f $tblName ]; then
			# awk -F: '{print $0}' $tblName
			echo -ne "${ARROW} ${BLUE} Please enter a column name: ${YELLOW}"
			read columnName
			if [[ -z "$columnName" ]]; then
				echo
				echo -e "${RED} ${CROSSMARK} Fail: Column name can't be empty ${YELLOW}"
				echo
			else
				if is_column_exists $columnName ".$tblName-metadata"; then
					awk -F: '{print $0}' $tblName | cut -d: -f1
					echo
					echo -e "${GREEN} ${CHECKMARK} Success: Table selected ${YELLOW}"
					echo
				else
					echo
					echo -e "${RED} ${CROSSMARK} Fail: Invalid column name ${YELLOW}"
					echo
				fi
			fi
			echo
			echo -e "${GREEN} ${CHECKMARK} Success: Table selected ${YELLOW}"
			echo
		else
			echo
			echo -e "${RED} ${CROSSMARK} Fail: Invalid table name ${YELLOW}"
			echo
		fi
	fi
}

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
			create_table) create_table;;
			list_tables) echo Listing tables...; list_tables;;
			drop_table) drop_table;;
			insert_into) insert_into;;
			select_from) select_from;;
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


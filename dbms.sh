#!/usr/bin/bash


clear

mkdir -p Databases

cd Databases/

########## Colors ##########
RED='\033[31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

########## Symbols ##########
CHECKMARK="✔"
CROSSMARK="✘"
ARROW="→"


# =====> Helper Functions <=====

########## Check For Alphanumeric , _ , -  ##########
is_alpha() {
    if [[ "$1" =~ ^[a-zA-Z0-9_-]*[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        return 0  
    else
				echo
				echo -e "${RED} ${CROSSMARK} Error: The string must contain at least one alphabetic character and can only include alphanumeric characters, underscores (_), and hyphens (-). ${YELLOW}"
				echo
        return 1  
    fi
}

########## Check For Valid String (Except :)  ##########
is_valid_string() {
    if [[ "$1" =~ ^[^:]*[a-zA-Z][^:]*$ ]]; then
        return 0  
    else
        echo
        echo -e "${RED} ${CROSSMARK} Error: The string must contain at least one alphabetic character and cannot contain colons (:). ${YELLOW}"
        echo
        return 1  
    fi
}

# Function to check if the input is numeric
########## Check For Numeric ##########
is_numeric() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        return 0 
    else
				echo
				echo -e "${RED} ${CROSSMARK} Error: Please enter a valid number ${YELLOW}"
				echo
        return 1  
    fi
}

########## Check If A Column Exists In A Table ##########
is_column_exists() {
    if grep -wq "$1" "$2"; then
        return 0  
    else
        return 1 
    fi
}

########## prompts user to choose y/n for action confirmation ##########
confirm_action() {
	 read choice

	# Convert the user's input to lowercase for case-insensitive comparison
	choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

	# Check if the input is 'yes' or 'y'
	if [[ "$choice" == "yes" || "$choice" == "y" ]]; then
					return 0
	else    
					return 1
	fi
}

########### Ensure input is not empty ##########
check_non_empty() {
    if [[ -z "$1" ]]; then
        return 1  
    else
        return 0  
    fi
}

########## Exists the application ##########
exit_app() {	
	echo -e "${CYAN} Exiting..."
	sleep .5
	cd ..
	if [ -f "ThankYou.sh" ]; then
		pwd
		./ThankYou.sh
	else
	  pwd
		cd ..
		./ThankYou.sh
	fi
	exit 0
}

########## Display The Main Menu Options ##########
display_main_menu_options() {
    	echo
	echo -e "${CYAN} ### Main Menu (Database Creation Options) ###"
	echo -e "-------------------------------------------------${YELLOW}"	
	echo
    	echo -e "1) create_db\t  3) connect\t  5) clear_screen"
    	echo -e "2) list_dbs\t  4) drop_db\t  6) quit"
    	echo
}

########## Display The Sub Menu Options ##########
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

# =====> Main Menu Functions <===== #

########## Create Database ##########
create_db() {
	echo -ne "${ARROW} ${BLUE} Please enter a db name: ${YELLOW}"
	read dbName

	if ! check_non_empty "$dbName"; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Db name can't be empty ${YELLOW}"
		echo
		return 1
	fi

	if ! is_alpha "$dbName"; then
		return 1
	fi

	if [ -d "$dbName" ]; then
			echo
			echo -e "${RED} ${CROSSMARK} Fail: This name already exist ${YELLOW}"
			echo
			return 1
	fi

	mkdir "$dbName"
	echo
	echo -e "${GREEN} ${CHECKMARK} Success: DB created Successfuly ${YELLOW}"
	echo
}

########## List All Databases ##########
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

########## Connect To Database ##########
connect_db() {
	echo -ne "${ARROW} ${BLUE} Please enter a db name: ${YELLOW}"
	read dbName

	if ! check_non_empty "$dbName"; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Db name can't be empty ${YELLOW}"
		echo
		return 1
	fi

	if [ ! -d "$dbName" ]; then
			echo
			echo -e "${RED} ${CROSSMARK} Fail: Invalid db name ${YELLOW}"
			echo
			return 1
	fi

	echo
	echo -e "${GREEN} ${CHECKMARK} Success: Connected to db:" $dbName" ${YELLOW}"
	cd "$dbName"
	PS3="${ARROW} (${dbName}) -- Please select an option: "

	# Render New Select Menu
	render_table_control_menu
}

########## Drop Database ##########
drop_db() {
	echo -ne "${ARROW} ${BLUE} Please enter a db name: ${YELLOW}"
	read dbName

	if ! check_non_empty "$dbName"; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Db name can't be empty ${YELLOW}"
		echo
		return 1
	fi

	if [ ! -d "$dbName" ]; then
			echo
			echo -e "${RED} ${CROSSMARK} Fail: Invalid db name ${YELLOW}"
			echo
			return 1
	fi

	# Prompt the user for confirmation
	echo -ne "${RED} ${ARROW} Are you sure you want to delete the database '$dbName'? (yes/y to confirm): ${YELLOW}"

	if ! confirm_action "$dbName"; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Database ${dbName} was not deleted. ${YELLOW}"
		echo
		return 1
	fi

	rm -r "$dbName"
	echo
	echo -e "${GREEN} ${CHECKMARK} Success: Dropped db : "$dbName" ${YELLOW}"
	echo
}

########## Show The Main Menu ##########
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

# =====> Sub-Menu Functions <===== #

########## Show Choose Datatype Menu ##########
render_col_datatype_menu() {
	options=(str int)
	select option in ${options[@]}; do
		case $option in
			str) echo str; break;;
			int) echo int; break;;
		esac
	done
}

########## Check If The Value Already Exists ##########
# Usage: column-Number, table_name, entered_value
is_duplicate_pk_value() {
	if awk -F ":" -v value="$3" '{if ($1 == value) found=1} END {exit !found}' "$2"; then
		return 0
	else
		return 1
	fi
}

########## Create Table ##########
create_table() {
	echo -ne "${ARROW} ${BLUE} Please enter a table name: ${YELLOW}"
	read tblName

	if ! check_non_empty "$tblName"; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Db name can't be empty ${YELLOW}"
		echo
		return 1
	fi

  if [ -f "$tblName" ]; then
			echo
			echo -e "${RED} ${CROSSMARK} Fail: This name already exist ${YELLOW}"
			echo
			return 1
  fi

  if ! is_alpha "$tblName"; then
		return 1
  fi

  while true; do
    echo -ne "${ARROW} ${BLUE} Please enter number of columns: ${YELLOW}"
    read numberOfCols

    if ! is_numeric "$numberOfCols"; then
      continue
    fi

    break
  done

  touch ".$tblName-metadata"

  isPkExists=0
  tableHeader=""
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
      
      if ! is_alpha "$colName"; then
          continue
      fi
      
      # Check if the column name already exists
      if is_column_exists "$colName" ".${tblName}-metadata"; then
          echo -e "${RED} ${CROSSMARK} Fail: Column with the same name already exists ${YELLOW}"
          continue
      fi
      
      break
    done
    
    line+="$colName:"

    if [ $i -eq $numberOfCols ]; then
      tableHeader+="$colName"
    else
      tableHeader+="$colName:"
    fi

    echo
    echo -e "${CYAN} ### Column Datatype Options Menu ###"
    echo -e "-------------------------------------------------${YELLOW}"	

    line+=$(render_col_datatype_menu):

    if [ "$isPkExists" -eq 0 ]; then
      echo -ne "${ARROW} ${BLUE} Do you want to make column: "$colName" the primary key: ${YELLOW}"
      if confirm_action; then
        line+=pk
        isPkExists=1
      else
      line+="null"
      fi
    else
      line+="null"
    fi

    echo $line >> ".$tblName-metadata"
  done

  echo $tableHeader > "$tblName"

  echo
  echo -e "${GREEN} ${CHECKMARK} Success: Table created Successfully ${YELLOW}"
  echo	
}

########## Insert Into Table ##########
insert_into() {
	echo -ne "${ARROW} ${BLUE} Please enter a table name: ${YELLOW}"
  read tblName

	if ! check_non_empty "$tblName"; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Db name can't be empty ${YELLOW}"
		echo
		return 1
	fi

  if [ ! -f "$tblName" ]; then
			echo
			echo -e "${RED} ${CROSSMARK} Fail: This table doesn't exist ${YELLOW}"
			echo
			return 1
  fi

	numberOfCols=$(wc -l ".$tblName-metadata" | cut -d" " -f1)
	line=""
	for ((i=1; i<=numberOfCols; i++)); do
		col=$(sed -n "${i}p" ".$tblName-metadata")
		colName=$(echo $col | cut -d: -f1)
		colDataType=$(echo $col | cut -d: -f2)
		colPkCheck=$(echo $col | cut -d: -f3)

		while true; do
			echo -ne "${ARROW} ${BLUE} Please enter value for column: "$colName" ("$colDataType"): ${YELLOW}"
			read value

			case "$colDataType" in
			
				str) if ! check_non_empty "$value"; then
						value="NULL"
				elif ! is_valid_string "$value"; then
						continue
				fi
          ;;
				int) if ! check_non_empty "$value"; then
						value="NULL"
					elif ! is_numeric "$value"; then
						continue
					fi
			esac

			if [[ "$colPkCheck" == "pk" ]]; then
				if is_duplicate_pk_value "$i" "$tblName" "$value"; then
					echo -e "${RED} ${CROSSMARK} Fail: Duplicate primary key value ${YELLOW}"
					continue
				fi

				if [[ "$value" == "NULL" ]]; then
				  echo -e "${RED} ${CROSSMARK} Fail: Primary key can't be NULL ${YELLOW}"
          continue
        fi
			fi

			break
		done

		# To prevent printing ":" at the end of the last column
		if [ $i -eq "$numberOfCols" ]; then
			line+="$value"
		else
			line+="$value:"
		fi

	done
	
	echo "$line" >> "$tblName"

	echo
	echo -e "${GREEN} ${CHECKMARK} Success: Row inserted successfully ${YELLOW}"
	echo
  
}

########## List Tables ##########
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

########## select from Tables ##########
select_from(){
    echo -ne "${ARROW} ${BLUE} Please enter a table name: ${YELLOW}"
    read tblName

    if ! check_non_empty "$tblName"; then
        echo
        echo -e "${RED} ${CROSSMARK} Fail: Table name can't be empty ${YELLOW}"
        echo
        return 1
    fi

    if [ ! -f "$tblName" ]; then
        echo
        echo -e "${RED} ${CROSSMARK} Fail: Invalid table name ${YELLOW}"
        echo
        return 1
    fi

    # Get the Column name from user
    echo -ne "${ARROW} ${BLUE} Please enter a column name or * for all: ${YELLOW}"
    read columnName

    if ! check_non_empty "$columnName"; then
        echo
        echo -e "${RED} ${CROSSMARK} Fail: Column name can't be empty ${YELLOW}"
        echo
        return 1
    fi

    if [ "$columnName" == "*" ]; then
        columnName=$(head -n 1 "$tblName" | tr ':' ' ')
    fi

    columns=($columnName)

    # Validate if all columns exist
    metadataFile=".$tblName-metadata"
    for col in "${columns[@]}"; do
        if ! is_column_exists "$col" "$metadataFile"; then
            echo
            echo -e "${RED} ${CROSSMARK} Fail: Invalid column name '$col' ${YELLOW}"
            echo
            return 1
        fi
    done

    columnIndexes=()
    for col in "${columns[@]}"; do    
        index=$(awk -F':' -v col="$col" '{ if ($1 == col) { print NR } }' $metadataFile)
        if [ -z "$index" ]; then
            echo -e "${RED} ${CROSSMARK} Fail: Column '$col' does not exist in metadata ${YELLOW}"
            return 1
        fi
        columnIndexes+=("$index")
    done

    # Ask if the user wants to apply a WHERE clause filter
    echo -ne "${ARROW} ${BLUE} Do you want to apply a WHERE clause filter? (yes/y or no/n): ${YELLOW}"
		# Print the entire column if user don't want to specify where clause
		if ! confirm_action; then
			echo -e "${GREEN}"
        awk -v cols="${columnIndexes[*]}" '
        BEGIN { FS = ":"; OFS = "\t|\t" }
        {
						if (NR == 1) {
							print "________________________________________________________________________________________________________"
							print ""
						}
            split(cols, arr, " ")
            for (i in arr) {
                printf "%s", $arr[i]
                if (i < length(arr)) printf OFS
            }
            print ""
						if (NR == 1) {
							print "________________________________________________________________________________________________________"
							print ""
						}
        }
        ' $tblName
        echo -e "${YELLOW}"
				return 0
			fi

    # Ask for the column and value for the WHERE clause
		echo -ne "${ARROW} ${BLUE} Please enter the WHERE clause column: ${YELLOW}"
		read whereColumn
	
		# Validate if the WHERE column exists in the table's metadata
		if ! is_column_exists "$whereColumn" "$metadataFile"; then
				echo -e "${RED} ${CROSSMARK} Fail: Invalid WHERE column '$whereColumn' ${YELLOW}"
				return 1
		fi

		echo -ne "${ARROW} ${BLUE} Please enter the WHERE clause value: ${YELLOW}"
		read whereValue


	# Print the selected columns with the WHERE filter applied
	echo -e "${GREEN}"
	awk -v cols="${columnIndexes[*]}" -v whereCol="$whereColumn" -v whereVal="$whereValue" '
	BEGIN { FS = ":"; OFS = "\t|\t" }
	{
    if (NR == 1) {
			print "________________________________________________________________________________________________________" 
			print "" 
			split(cols, arr, " ")
			for (i in arr) {
					printf "%s", $arr[i]
					if (i < length(arr)) printf OFS
			}
			print "" 
			print "________________________________________________________________________________________________________" 
			print "" 

			whereIndex = 0
			for (i = 1; i <= NF; i++) {
					if ($i == whereCol) {
							whereIndex = i
							break
					}
			}
    }

    if (whereIndex > 0 && $whereIndex == whereVal) {
        split(cols, arr, " ")
        for (i in arr) {
            printf "%s", $arr[i]  
            if (i < length(arr)) printf OFS
        }
        print ""  # print a newline after each row
    }
	}
	' $tblName
		echo -e "${YELLOW}"
}

########## Drop Table ##########
drop_table() {
	echo -ne "${ARROW} ${BLUE} Please enter a table name: ${YELLOW}"
	read tblName

	if ! check_non_empty "$tblName"; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Db name can't be empty ${YELLOW}"
		echo
		return 1
	fi

	if [ ! -f "$tblName" ]; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Invalid table name ${YELLOW}"
		echo
		return 1
	fi

	# Prompt the user for confirmation
	echo -ne "${RED} ${ARROW} Are you sure you want to delete table '$dbName'? (yes/y to confirm): ${YELLOW}"

	if ! confirm_action "$tblName"; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Table ${tblName} was not deleted. ${YELLOW}"
		echo
		return 1
	fi

	rm "$tblName"
	rm ".$tblName-metadata"
	echo
	echo -e "${GREEN} ${CHECKMARK} Success: Table dropped: "$tblName" ${YELLOW}"
	echo
}

########## Delete A Record From A Table ##########
delete_from() {
	echo -ne "${ARROW} ${BLUE} Please enter a table name: ${YELLOW}"
  read tblName

	# Empty Table Name
  check_non_empty "$tblName"
  if [ $? -ne 0 ]; then
    echo
    echo -e "${RED} ${CROSSMARK} Fail: Table name can't be empty ${YELLOW}"
    echo
    return 1
  fi

	# Invalid Table Name
	if [ ! -f "$tblName" ]; then
    echo
    echo -e "${RED} ${CROSSMARK} Fail: Invalid table name ${YELLOW}"
    echo
    return 1
  fi

	echo -ne "${ARROW} ${BLUE} Please enter the column name for the WHERE clause: ${YELLOW}"
  read colName

	check_non_empty "$colName"
  if [ $? -ne 0 ]; then
    echo
    echo -e "${RED} ${CROSSMARK} Fail: Column name can't be empty ${YELLOW}"
    echo
    return 1
  fi

	# column name doesn't exist
	if ! is_column_exists "$colName" ".${tblName}-metadata"; then
			echo -e "${RED} ${CROSSMARK} Fail: Column doesn't exist ${YELLOW}"
			return 1
	fi

	echo -ne "${ARROW} ${BLUE} Please enter the value for the WHERE clause: ${YELLOW}"
  read colValue
	check_non_empty "$colValue"
  if [ $? -ne 0 ]; then
    echo
    echo -e "${RED} ${CROSSMARK} Fail: Value can't be empty ${YELLOW}"
    echo
    return 1
  fi


	deletedRows=$(awk -v colName="$colName" -v colValue="$colValue" '
		BEGIN { FS = ":"; OFS = ":"; deletedRows = 0 } 
		NR == 1 { 
			print > "temp_file"; 
			for (i = 1; i <= NF; i++) {
				if ($i == colName) colIndex = i;
			}
			if (!colIndex) {
				print "Error: Column '"colName"' not found in header.";
				exit 1;
			}
			next;
		}
		{
			if ($colIndex != colValue) {
				print > "temp_file";
			} else {
				deletedRows++;
			}
		}
		END {
			print deletedRows;
		}
	' "$tblName")

	# Check for errors and handle the output
	if [ $? -ne 0 ]; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Deletion failed due to an error ${YELLOW}"
		echo
		return 1
	fi

	# Replace the original table with the updated temp file
	mv temp_file "$tblName"

	# Provide the success message along with the number of deleted rows
	echo
	echo -e "${GREEN} ${CHECKMARK} Success: $deletedRows record(s) deleted ${YELLOW}"
	echo
}

########## Update A Record In A Table ##########
update_table() {
  echo -ne "${ARROW} ${BLUE} Please enter a table name: ${YELLOW}"
  read tblName

  # Empty Table Name
  check_non_empty $tblName
  if [ $? -ne 0 ]; then
    echo
    echo -e "${RED} ${CROSSMARK} Fail: Table name can't be empty ${YELLOW}"
    echo
    return 1
  fi

  # Invalid Table Name
  if [ ! -f $tblName ]; then
    echo
    echo -e "${RED} ${CROSSMARK} Fail: Invalid table name ${YELLOW}"
    echo
    return 1
  fi

  # Check metadata file
  metaFile=".${tblName}-metadata"
  if [ ! -f $metaFile ]; then
    echo
    echo -e "${RED} ${CROSSMARK} Fail: Metadata file not found for the table ${YELLOW}"
    echo
    return 1
  fi

	echo -ne "${ARROW} ${BLUE} Please enter the column name to update: ${YELLOW}"
  read updateColName

  check_non_empty $updateColName
  if [ $? -ne 0 ]; then
    echo
    echo -e "${RED} ${CROSSMARK} Fail: Column name can't be empty ${YELLOW}"
    echo
    return 1
  fi

  # Column name doesn't exist
  if ! is_column_exists $updateColName "$metaFile"; then
    echo -e "${RED} ${CROSSMARK} Fail: Column doesn't exist ${YELLOW}"
    return 1
  fi

  # Extract column constraints
  colConstraint=$(awk -F: -v col="$updateColName" '$1 == col {print $2":"$3}' "$metaFile")
  colType=$(echo "$colConstraint" | cut -d: -f1)
  colRule=$(echo "$colConstraint" | cut -d: -f2)

  echo -ne "${ARROW} ${BLUE} Please enter the new value for the column: ${YELLOW}"
  read updateColValue

  # Validate value type
  if [ "$colType" == "int" ]; then
		if ! is_numeric "$updateColValue"; then
			return 1
		fi
  fi

  if [ "$colType" == "str" ]; then
		if ! check_non_empty "$updateColValue"; then
				updateColValue="NULL"	
		elif ! is_valid_string "$updateColValue"; then
						return 1
		fi
	fi

  # Check for primary key constraint
  if [ "$colRule" == "pk" ]; then
		# Find the column number of the primary key
		pkColNum=$(awk -F: -v col="$updateColName" '
			NR == 1 {
				for (i = 1; i <= NF; i++) {
					if ($i == col) print i;
				}
			}
		' "$tblName")

		if is_duplicate_pk_value "$pkColNum" "$tblName" "$updateColValue"; then
			echo
			echo -e "${RED} ${CROSSMARK} Fail: Duplicate value violates primary key constraint ${YELLOW}"
			echo
			return 1
		fi
  fi

  echo -ne "${ARROW} ${BLUE} Please enter the column name for the WHERE clause: ${YELLOW}"
  read whereColName

  check_non_empty $whereColName
  if [ $? -ne 0 ]; then
    echo
    echo -e "${RED} ${CROSSMARK} Fail: Column name can't be empty ${YELLOW}"
    echo
    return 1
  fi

  # Column name doesn't exist
  if ! is_column_exists $whereColName "$metaFile"; then
    echo -e "${RED} ${CROSSMARK} Fail: Column doesn't exist ${YELLOW}"
    return 1
  fi

  echo -ne "${ARROW} ${BLUE} Please enter the value for the WHERE clause: ${YELLOW}"
  read whereColValue
  check_non_empty $whereColValue
  if [ $? -ne 0 ]; then
    echo
    echo -e "${RED} ${CROSSMARK} Fail: Value can't be empty ${YELLOW}"
    echo
    return 1
  fi

	# Update records 
	affectedRows=$(awk -v whereColName="$whereColName" -v whereColValue="$whereColValue" \
			-v updateColName="$updateColName" -v updateColValue="$updateColValue" -v updateColRule="$colRule" '
		BEGIN { FS = ":"; OFS = ":"; count = 0 }
		NR == 1 {
			print > "temp_file";  
			for (i = 1; i <= NF; i++) {
				if ($i == whereColName) whereColIndex = i;
				if ($i == updateColName) updateColIndex = i;
			}
			if (!whereColIndex || !updateColIndex) {
				exit 1;
			}
			next;
		}
		{
			if ($whereColIndex == whereColValue) {
				$updateColIndex = updateColValue;
				count++;
			}
			if (count > 1 && updateColRule == "pk") {
				exit 1;
			}
			print > "temp_file";
		}
		END { print count }
		' "$tblName")

	# Check for errors and handle the output
	if [ $? -ne 0 ]; then
		echo
		echo -e "${RED} ${CROSSMARK} Fail: Update failed due to an error ${YELLOW}"
		echo
		return 1
	fi

	# Replace the original table with the updated temp file
	mv temp_file "$tblName"

	echo
	echo -e "${GREEN} ${CHECKMARK} Success: $affectedRows record(s) updated ${YELLOW}"
	echo
}

########## Return To The Main Menu ##########
return_to_main_menu() {	
	cd ..	
	PS3="${ARROW} Please select an option: "
	display_main_menu_options
}

########## Show Sub-Menu (Table Controls Menu) ##########
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
			delete_from) delete_from;;
			update_table) update_table;;
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


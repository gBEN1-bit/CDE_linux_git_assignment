# --To instruct linux to run the file or script in a bash shell
#!/bin/bash 

# Ensuring csvkit is installed as it it will be use to select certain columns from the csv file
echo "----- Installing necessary libraries..... -----"
if ! command -v csvcut; then
    echo "csvkit not found, installing..."
    pip install --user csvkit
fi

# Adding common user install paths to PATH (for Linux, MacOs, Windows Git Bash)
export PATH=$HOME/.local/bin:$PATH
export PATH=$PATH:/c/Users/$USERNAME/AppData/Roaming/Python/Python313/Scripts

printf "\n"  # Add one blank line

#Starting ETL
echo "----- Starting ETL Process..... -----"

printf "\n"  # Add one blank line

#assign the url to a variable
echo "----- Assigning URL to a variable..... -----"
url="https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"

printf "\n"  # Add one blank line

# Taking care of scenario when the url is modified: this will delete the existing one, then append new one, to avoid duplication and having unnecessary records of the past urls
echo "----- Ensuring URL Variable is globally persistent..... -----"
sed -i "/^export assignment_url=/d" ~/.bashrc    #delete existing one
echo "export assignment_url=$url" >> ~/.bashrc   #append new one

# Applying changes/Run the ~/.bashrc file incase the url was modified
source ~/.bashrc

printf "\n"  # Add one blank line

# To print out the assignment_url value
echo "----- URL Environment Variable Value..... -----"
echo "assignment_url=$assignment_url"
 
printf "\n"  # Add one blank line

#Create RAW folder Directory
echo "----- Creating "RAW" folder directory (provided, it doesn't exist)..... -----"
mkdir -p ../../raw     #-p was used to ensure it doesn't throw any error if the directory already exist

printf "\n"  # Add one blank line

#Remove existing CDE_Project.csv file before downloading in the RAW folder directory
echo "----- Removing existing CDE_Project.csv file (if exists) before downloading in the RAW folder directory..... -----"
rm ../../raw/CDE_Project.csv

printf "\n"  # Add one blank line

#Download the file from the url - (Note: curl will always overwrite if it is existing.)- save it it into a folder called raw
echo "----- Downloading file from the Environment Variable URL..... -----"
curl -o ../../raw/CDE_Project.csv $assignment_url

printf "\n"  # Add one blank line

#confirm that the CDE_Project.csv downloaded file has been saved in the RAW folder.
echo "----- Has the CDE_Project.csv file been saved successfully in the RAW folder? -----"
if [ -f ../../raw/CDE_Project.csv ];
then
    echo "Yes, CDE_Project.csv has been saved successfully in the RAW folder"
else
    echo "No, CDE_Project.csv was NOT saved successfully and can't be found in the RAW folder"
fi

printf "\n"  # Add one blank line

# Rename column Variable_code to variable_code
echo "----- Renaming Column "Variable_code" to "variable_code"..... -----"
sed -i '1s/Variable_code/variable_code/' ../../raw/CDE_Project.csv

printf "\n"  # Add one blank line

#Create Transformed folder Directory
echo "----- Creating "Transformed" folder directory (provided, it doesn't exist)..... -----"
mkdir -p ../../Transformed #-p was used to ensure it doesn't throw any error if the directory already exist

printf "\n"  # Add one blank line

#Remove existing 2023_year_finance.csv file before downloading in the Transformed folder directory
echo "----- Removing existing 2023_year_finance.csv file (if exists) before downloading in the Transformed folder directory..... -----"
rm -f ../../Transformed/2023_year_finance.csv 

printf "\n"  # Add one blank line

#Select only the following columns: year, Value, Units, variable_code
echo "----- Processing file (selecting Year, Value, Units, variable_code)..... -----"
csvcut -c Year,Value,Units,variable_code ../../raw/CDE_Project.csv > ../../Transformed/2023_year_finance.csv  #Used csvcut becuase I noticed some records in the value Column have comma(",") and awk was not extracting it perfectly.

printf "\n"  # Add one blank line

#confirm that the 2023_year_finance.csv downloaded file has been saved in the Transformed folder.
echo "----- Has the 2023_year_finance.csv file been saved successfully in the Transformed folder? -----"
if [ -f ../../Transformed/2023_year_finance.csv ];
then
    echo "Yes, 2023_year_finance.csv has been saved successfully in the Transformed folder"
else
    echo "No, 2023_year_finance.csv was NOT saved successfully and can't be found in the Transformed folder"
fi

printf "\n"  # Add one blank line

#Create Gold folder Directory
echo "----- Creating "Gold" folder directory (provided, it doesn't exist)..... -----"
mkdir -p ../../Gold #-p was used to ensure it doesn't throw any error if the directory already exist

printf "\n"  # Add one blank line

#Remove existing 2023_year_finance.csv file before downloading in the Gold folder directory
echo "----- Removing existing 2023_year_finance.csv file (if exists) before downloading in the Gold folder directory..... -----"
rm -f ../../Gold/2023_year_finance.csv 

printf "\n"  # Add one blank line

#Move/Load the Transformed Data into the Gold Directory
echo "----- Moving/Loading the Transformed Data into the Gold Directory..... ------"
mv ../../Transformed/2023_year_finance.csv ../../Gold/2023_year_finance.csv 

printf "\n"  # Add one blank line

#confirm that the 2023_year_finance.csv downloaded file has been saved in the Gold folder.
echo "----- Has the 2023_year_finance.csv file been saved/loaded successfully in the Gold folder? -----"
if [ -f ../../Gold/2023_year_finance.csv ];
then
    echo "Yes, 2023_year_finance.csv has been saved/loaded successfully in the Gold folder"
else
    echo "No, 2023_year_finance.csv was NOT saved/loaded successfully and can't be found in the Gold folder"
fi

printf "\n"  # Add one blank line

#Completing ETL
echo "----- Finishing ETL Process..... -----"


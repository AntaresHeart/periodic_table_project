#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"

$($PSQL "DELETE FROM properties WHERE atomic_number = 1000;")
$($PSQL "DELETE FROM elements WHERE atomic_number = 1000;")
echo -e "DELETE: removed both fake elements\n"

$($PSQL "ALTER TABLE properties 
        RENAME weight 
        TO atomic_mass;")
ehco -e "FIX: weight renamed to atomic_mass\n"
        

$($PSQL "ALTER TABLE properties 
        RENAME melting_point 
        TO melting_point_celsius;")
echo -e "FIX: melting_point renamed to melting_point_celsius\n"

$($PSQL "ALTER TABLE properties 
        RENAME boiling_point 
        TO boiling_point_celsius;")
echo -e "FIX: boiling_point renamed to boiling_point_celsius\n"

$($PSQL "ALTER TABLE properties 
        ALTER COLUMN melting_point_celsius 
        SET NOT NULL;")
echo -e "FIX: properties table, melting point column - set not null\n"

$($PSQL "ALTER TABLE properties 
        ALTER COLUMN boiling_point_celsius 
        SET NOT NULL;")
echo -e "FIX: properties table, boiling point column - set not null\n"

$($PSQL "ALTER TABLE elements 
        ADD CONSTRAINT unique_elements 
        UNIQUE (symbol, name);")
echo -e "FIX: elements table, symbol and name columns - set unique\n"

$($PSQL "ALTER TABLE elements 
        ALTER COLUMN symbol 
        SET NOT NULL;")

$($PSQL "ALTER TABLE elements 
        ALTER COLUMN name 
        SET NOT NULL;")
echo -e "FIX: elements table, symbol and name columns - set not null\n"


$($PSQL "ALTER TABLE properties 
        ADD FOREIGN KEY (atomic_number) 
        REFERENCES elements(atomic_number);")
echo -e "FEAT: foreign key added for atomic_number in the properties table to ref the elements table\n"

$($PSQL "CREATE TABLE types(type_id SERIAL PRIMARY KEY, 
                            type VARCHAR(40) NOT NULL);")
echo -e "FEAT: types table created and primary key created for type_id\n"

$($PSQL "ALTER TABLE properties 
        ADD COLUMN type_id INT DEFAULT 0 NOT NULL")
echo -e "FEAT: type_id column created for properties table and value initialized to 0\n"

TYPE_TABLE_EXIST=$($PSQL "SELECT type FROM types")
if [[ -z $TYPE_TABLE_EXIST ]]
then
        $($PSQL "INSERT INTO types(type) VALUES('nonmetal'), ('metal'), ('metalloid')")
fi
echo -e "FEAT: types table filled out with values - done so it will not repeat if you run the script again\n"


TYPE_DATA=$($PSQL "SELECT type, type_id, atomic_number FROM properties;" | sed 's/ *| */ /g')
echo "$TYPE_DATA" | while read TYPE TYPE_ID ATOMIC_NUMBER
        do
                SET_TYPE_ID=$($PSQL "SELECT type_id FROM types WHERE type='$TYPE';")
                INSERT_CORRECT_TYPE_ID=$($PSQL "UPDATE properties SET type_id=$SET_TYPE_ID WHERE atomic_number =$ATOMIC_NUMBER;")
        done
echo -e "FIX: type_id in the properties table fixed to match the types table\n"

$($PSQL "ALTER TABLE properties 
        ADD FOREIGN KEY (type_id) 
        REFERENCES types(type_id);")
echo -e "FEAT: foreign key added for type_id in the properties table to ref the types table\n"

$($PSQL "ALTER TABLE properties DROP COLUMN type")
echo -e "DELETE: type column dropped from the properties table\n"

SYMBOL_DATA=$($PSQL "SELECT symbol, name FROM elements" | sed 's/ *| */ /g')

echo "$SYMBOL_DATA" | while read SYMBOL NAME
do
    UPPERCASE=$(echo "$SYMBOL" | sed 's/^[a-z]/\U&/')
    INSERT_UPPCASE_SYMBOL=$($PSQL "UPDATE elements SET symbol='$UPPERCASE' WHERE name ='$NAME'")
done
echo -e "FIX: symbols capitalized in the elements table\n"


$($PSQL "INSERT INTO elements(atomic_number, symbol, name) 
        VALUES(9, 'F', 'Fluorine'), (10, 'Ne', 'Neon') ON CONFLICT (atomic_number) DO NOTHING" ;)

$($PSQL "INSERT INTO properties(atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id)
        VALUES(9, 18.998, -220, -188.1, 1), (10, 20.18, -248.6, -246.1, 1) ON CONFLICT (atomic_number) DO NOTHING")
echo -e "FEAT: both new elements inserted (F, Ne)\n"

$($PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL;")
$($PSQL "UPDATE properties SET atomic_mass=trim(trailing '00' FROM atomic_mass::TEXT)::DECIMAL;")
echo -e "FIX: removed trailing zeros from atomic_mass column\n"



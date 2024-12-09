#!/bin/bash
# Retrieve element information from the periodic table
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

# echo -e "\n~~ Element Search Application ~~\n"

# 参数处理
if [[ ! $1 ]]
then
  # 参数为空
  echo "Please provide an element as an argument."
else
  # 按原子序数查询，eg: ./element.sh 1
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e FULL JOIN properties p USING(atomic_number) FULL JOIN types t USING(type_id) WHERE e.atomic_number=$1")
  
  # 按元素符号查询，eg: ./element.sh H
  elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
  then
    ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e FULL JOIN properties p USING(atomic_number) FULL JOIN types t USING(type_id) WHERE e.symbol='$1'")
  
  # 按元素名称查询，eg: ./element.sh Hydrogen
  elif [[ $1 =~ ^[A-Z][a-z]+$ ]]
  then
    ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e FULL JOIN properties p USING(atomic_number) FULL JOIN types t USING(type_id) WHERE e.name='$1'")
  fi

  # 检查查询结果
  if [[ -z $ELEMENT ]]
  then
    # 查询结果为空
    echo "I could not find that element in the database."
  else
    # 从查询结果中获取七个参数：# 原子序数、元素名称、元素符号、元素类型、元素质量、元素熔点、元素沸点
    echo "$ELEMENT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi

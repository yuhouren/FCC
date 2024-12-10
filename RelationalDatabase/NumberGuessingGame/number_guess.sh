#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

# 随机生成一个1000以内的数字，作为秘密数字
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
# 定义计数器变量，设置为0
GUESSES=0

# 提示用户输入用户名
echo "Enter your username:"
read USERNAME

# 数据库中查询输入的用户名
USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USERNAME'")

# 查询结果为空
if [[ -z $USER_ID ]]
then
  # 查询结果为空，数据库中添加新用户
  INSERT_USER=$($PSQL "INSERT INTO users(user_name) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # 查询结果非空，数据库中已存在该用户，查询该用户的数据
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# 提示用户输入一个数字
echo "Guess the secret number between 1 and 1000:"
while true
do
  read GUESS
  # 检查输入是否为整数
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    # 输入非整数时提示
    echo "That is not an integer, guess again:"
    continue
  fi
  
  # 增加猜测次数
  ((GUESSES++))
  
  # 比较数字
  if [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    # 猜对了，更新数据库
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    # 保存本次的游戏数据
    SAVE_GAME_DATA=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($GUESSES, $USER_ID)")
    break
  fi
done

#!/bin/bash
lockFilePath=".install.lock"

configArr=(
    "redis_db=请输入redis数据库名=0"
    "redis_psd=请输入redis密码=123"
)

readInput() {
    stty erase "^H"
    if [ ! -n "$2" ]; then
        msgDefault=""
    else
        msgDefault="(默认：$2)"
    fi
    read -p "$1$msgDefault: " val
    if [ ! -n "$val" ]; then
        val=$2
    fi
    echo $val
}


replaceSettings() {
    settings=$(echo "$settings" | sed "s/$1/$2/g")
}

replaceConfig() {
    replaceSettings "\($1\s*\:\s*'\?\)[^\']*\('\?,\)" "\1$2\2"
}

askAndSetConfig() {
    value=$(readInput $2 $3)
    replaceConfig $1 $value
}

askAndSetDB() {
    dbName=$(readInput "输入数据库名" "doracms")
    replaceSettings "mongodb:\/\/mongo:27017\/\w*" "mongodb:\/\/mongo:27017\/$dbName"
    replaceConfig DB "$dbName" doracms
}

askAndSetConfigItem() {
    #configItemArr=($(echo $1))
#echo ${configItemArr[1]}
    #configItemArr=(${str//=/})
    #echo "$1" | IFS='=' read -r -a configItemArr
    OLD_IFS=$IFS
    IFS='='
    read -ra configItemArr <<< "$1"
    askAndSetConfig ${configItemArr[0]} ${configItemArr[1]} ${configItemArr[2]}
    IFS=$OLD_IFS
}

askAndSetConfigArray() {
    OLD_IFS=$IFS
    IFS=' '
    for configItem in ${configArr[*]}; do
        askAndSetConfigItem $configItem
    done
    IFS=$OLD_IFS
}


if [ ! -f "$lockFilePath" ]; then

settingsPath="models/db/settings.js"
#settingsPath="test.txt"
settings=$(<$settingsPath)

askAndSetDB

askAndSetConfigArray

echo "$settings" > $settingsPath

touch $lockFilePath

fi

forever -e err.log bin/www

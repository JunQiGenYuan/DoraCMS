function readInput() {
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

containerName=$(readInput "请输入容器名称" "doracms")
appPort=$(readInput "输入app端口号" "7979")
sshPort=$(readInput "请输入ssh端口号" "7980")
mongoContainerName=$(readInput "请输入连接的mongo容器名" "mongo")
redisContainerName=$(readInput "请输入连接的redis容器名" "redis")
otherArgs=$(readInput "请输入其他命令参数")

docker run -it --name $containerName -p $appPort:7878 --link $mongoContainerName:mongo --link $redisContainerName:redis $otherArgs registry.cn-hangzhou.aliyuncs.com/simonhg/doracms bash startApp.sh

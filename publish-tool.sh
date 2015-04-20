#!/bin/sh

usage="./publish-tool.sh [(-a | --autopublish)]  (package name(s))\n\nBy default, this will publish each package specified."
autopublish=false
TAB="    "
packages=()

while [ "$1" != "" ]; do
    case $1 in
        -a | --autopublish )    autopublish=true
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     packages+=($1)
                                ;;
    esac
    shift
done

cwd=`pwd`
for pkg in ${packages[*]}
do
    cd $pkg
    pkgPath=`pwd`

    name=`grep "name:" package.js | sed "s/name://g" | sed "s/[[:space:]]//g" | sed "s/[\'\",]//g"`
    printf "Publishing $name\n"

    EXTRAARGS=""
    while [ true ]
    do
        printf "${TAB}Started publishing\n"
        meteor publish $EXTRAARGS 2>/tmp/meteor-publish-error > /dev/null
        error=$?

        if [ $error -eq 0 ]; then
            printf "${TAB}Successfully published $name\n"
        elif [ $error -eq 1 ]; then
            ERROR=$(</tmp/meteor-publish-error)
            ERROR=`echo $ERROR | sed "s/.*error: //g"`
            if [ "$ERROR" == "Version already exists" ]; then
                if [ $autopublish == false ]; then
                    read -p "${TAB}The current version already exists. Specify a [M]ajor, [m]inor, [p]atch, or [n]one > " result
                    case $result in
                        [M]* )      $cwd/version-tool.sh -M .
                                    continue
                                    ;;
                        [m]* )      $cwd/version-tool.sh -m .
                                    continue
                                    ;;
                        [p]* )      $cwd/version-tool.sh .
                                    continue
                                    ;;
                        * )         printf "${TAB}Not updating version. Cancelling publish.\n"
                                    ;;
                    esac
                else
                    printf "${TAB}The current version already exists. Patching to new version.\n"
                    $cwd/version-tool.sh .
                    continue
                fi
            elif [[ "$ERROR" =~ ^unknown\ package.* ]]; then
                printf "${TAB}Depends on unknown package. Cancelling publish.\n"
            elif [[ "$ERROR" =~ ^There\ is\ no\ package.* ]]; then
                if [ $autopublish == false ]; then
                    read -e -p "${TAB}This package has not been published. Would you like to create it for the first time (y/n)? [y] " result
                    case $result in
                        [Yy]* )     EXTRAARGS="--create"
                                    continue
                                    ;;
                        [Nn]* )     ;;
                        * )         EXTRAARGS="--create"
                                    continue
                                    ;;
                    esac
                else
                    printf "${TAB}Package has never been published. Rerunning with --create flag.\n"
                    EXTRAARGS="--create"
                    continue
                fi
            else
                printf "${TAB}Unknown Error: $ERROR. Cancelling publish.\n"
            fi
        fi

        EXTRAARGS=""
        break;
    done

    cd $cwd
done

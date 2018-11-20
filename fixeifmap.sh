#!/bin/ksh
#script to fix situation with wrong mapping

check_issue()
{
    if [[ -d $PWD/$DIR ]]
    then
        echo "$PWD/$DIR exists, will use $PWD/$DIR"
    else
        mkdir $PWD/$DIR
    fi
    
    tacmd listsit | grep $WT |awk '{print $1}' > sit.$SS
    
    SITCT=`cat sit.$SS | wc -l`
    CT=0
    
    touch $PWD/$DIR/dummy.$$.xml
    
    for i in `cat sit.$SS`
    do
        CT=$((CT + 1))
        echo "processing $i $CT of $SITCT"
        tacmd viewsit -s $i -e $PWD/$DIR/$i.$$.xml
    done
    
    echo "###################################################"
    echo "potential issue:"
    echo
    grep MAP $PWD/$DIR/*.$SS.xml | awk -F":" '{print $1}'
    echo
    echo Situations:
    
    for MAP in `grep MAP $PWD/$DIR/*.$SS.xml | awk -F":" '{print $1}'`
    do
        echo $(basename $MAP) | awk -F"." '{print $1}'
    done
        echo "###################################################"
}

fixfile()
{
    if [[ -d $FIX ]]
    then
        echo "$FIX exists, will use $FIX"
    else
        mkdir $FIX
    fi
    
    for i in `grep MAP $PWD/$DIR/*.$SS.xml | awk -F":" '{print $1}'`
    do
        echo "creating xml fix for $i"
        arquivo=$(basename $i)
        head -79 $i > $FIX/$arquivo.fix
        echo >>  $FIX/$arquivo.fix
        echo "</TABLE>" >>  $FIX/$arquivo.fix
        echo "$FIX/$arquivo.fix" >> $FIX/tofix.$SS
    done
}


fix()
{

    cat $FIX/tofix.$SS  >/dev/null 2>&1

    if [[ $? -gt 0 ]]
    then
        echo "nothing to fix"
        exit 1
    fi

    for i in `cat $FIX/tofix.$SS`
    do
        Sit=`echo $(basename $i) | awk -F"." '{print $1}'`
        echo "fixing $Sit"
        tacmd deletesit -s $Sit -f
        if [[ $? -eq 0 ]]
        then
            tacmd viewsit -s $Sit >/dev/null 2>&1
            if [[ $? -eq 0 ]]
                then
                    echo "tacmd retuned unable to delete $Sit aborting"
                    exit 1
                fi
        else
                echo "unable to delete $Sit aborting"
                exit 1
        fi
        
        tacmd createsit -i $i >/dev/null 2>&1
        if [[ $? -gt 0 ]]
        then
            echo "Unable to create sit $Sit aborting"
            exit 10
        else
            echo "Sit $Sit recreated"
        fi
    done
}

usage()
{
        echo "#############################################"
        echo "Usage:"
        echo "./fixeifmap.sh <string to grep> <opt>"
        echo "examples:"
        echo "./fixeifmap.sh whr_fss -fix (this example will search errors in all situations with whr_fss and fix it"
        echo
        echo "options:"
        echo "-fix = search potential errors and fix it"
        echo "-report = just verify for potential errors but don't fix it"
        echo "-fixfile = runs report and generate fix file but does not run the fix itself"
        echo "-help - display this screen :->"
        echo "#############################################"
}


DIR=`date +%Y%m%d`
PWD=`pwd`
FIX="$PWD/$DIR/fix"
WT=$1
SS=$$
OPT=$2

echo "WT=$WT OPT=$OPT"

if [[ $WT == "" ]]
then
    usage
    exit 1
fi

if [[ $OPT  == "" ]]
then
    usage
    exit 1
fi

if [[ $OPT != "-fix" ]] && [[ $OPT != "-report" ]] && [[ $OPT != "-fixfile" ]]
then
    usage
    exit 1
fi

if [[ $OPT == "-fix" ]]
then
    check_issue
    fixfile
    fix;
    exit 0
fi

if [[ $OPT == "-fixfile" ]]
then
    check_issue
    fixfile
    exit 0
fi

if [[ $OPT == "-report" ]]
then
    check_issue
    exit 0
fi

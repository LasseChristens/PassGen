##########################################################
#               passgen.sh version 1.0.0                 #
# password generator written by Lasse Christens 2021 (c) #
##########################################################

#!/bin/bash

# defaults
numPasswordLength=8
numUpperCase=0
numLowerCase=0
numSpecialCase=0
numDigits=0
numRandomChr=0
numPasswordCount=1
stringPasswordPattern=""
charAppending="q"
flagRandomize=""
flagStatistic=""

# procedure show help
usage(){
cat << EOF

./passgen.sh -option -option [value] ...

valid options:
-h | --help

    show this help

-n | --password-length [number]

    value [number]:
    any positiv number

    this option generate password(s) with a
    length of [number]

    default = 8

-u | --upper-case [number]

    value [number]:
    any positiv number

    this option generate password(s) containing at
    least [number] uppercase character(s)

    default = 0

-l | --lower-case [number]

    value [number]:
    any positiv number

    this option generate password(s) containing
    at least [number] lowercase character(s)

    default = 0

-s | --special-case [number]

    value [number]:
    any positiv number

    this option generate password(s) containing
    at least [number] specialcase character(s)

    default = 0

-q | --random-chars [number]

    value [number]:
    any positiv number

    this option generate password(s) containing
    at least [number] random character(s)

    default = 0

-d | --digit-chars [number]

    value [number]:
    any positiv number

    this option generate password(s) containing at
    least [number] digit character(s)

    default = 0

-c | --password-count [number]

    value [number]:
    any positiv number

    this option generate [number] password(s)

    default = 1

-p | --password-pattern [string]

    value [string]:
    any combination of the following characters:
    u = uppercase character
    l = lowercase character
    s = specialcase character
    d = digit character
    q = randomly chosen character
    @[char] = constant character [char]
              NOTE:
              some characters must be escaped
              some special characters may result
              in a unpredictable behavior

    this option generate password(s) following
    the pattern given in [string]

    example:
    ./passgen.sh --password-pattern ulsdq@X
    will generate a password like this:
    [A-Z][a-z][specialcase][0-9][random][staticX]

-a | --apending-char [char]

    value [char]:
    any of the following characters:
    u = uppercase characters
    l = lowercase characters
    s = special case characters
    d = digit characters
    q = random characters

    this option set the characterset which will be used for padding

    default value = q

-r | --randomize

    force password randomization

    default = false

-t | --statistics

    print out statistics

    default = false

EOF
}

# procedure validate parameter values
checkParamValue() {
    if [[ $1 != -p ]] && [[ $1 != --password-pattern ]] &&
       [[ $1 != -a ]] && [[ $1 != --apending-char ]] &&
       [[ $1 != -r ]] && [[ $1 != --randomize ]] &&
       [[ $1 != -t ]] && [[ $1 != --statistics ]];then
        if [[ ! $2 =~ ^[0-9]+$ ]];then
            echo "ERROR: invalid value \"$2\" in option $1"
            usage
            exit 1
        fi
    fi
}

# procedure parse parameters
while [[ $1 != "" ]]; do
    PARAM=$1
    if [[ $PARAM != -r ]] && [[ $PARAM != --randomize ]] &&
       [[ $PARAM != -t ]] && [[ $PARAM != --statistics ]];then
        VALUE=$2
        shift
    fi
    shift
    case $PARAM in
        -h | --help)
            usage
            exit 1
            ;;
        -n | --password-length)
            numPasswordLength=$VALUE
            ;;
        -u | --upper-case)
            numUpperCase=$VALUE
            ;;
        -l | --lower-case)
            numLowerCase=$VALUE
            ;;
        -s | --special-case)
            numSpecialCase=$VALUE
            ;;
        -d | --digit-chars)
            numDigits=$VALUE
            ;;
        -q | --random-chars)
            numRandomChr=$VALUE
            ;;
        -c | --password-count)
            numPasswordCount=$VALUE
            ;;
        -p | --password-pattern)
            stringPasswordPattern=$VALUE
            ;;
        -r | --randomize)
            flagRandomize=1
            ;;
        -a | --apending-char)
            charAppending=$VALUE
            ;;
        -t | --statistics)
            flagStatistic=1
            ;;
        *)
            echo "ERROR: invalid option \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    checkParamValue $PARAM $VALUE
done

# constant character pool
charsUpperCase="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
charsLowerCase="abcdefghijklmnopqrstuvwxyz"
charsSpecialCase="@#$%*-+=~.,:;"
charsDigits="0123456789"

# function grap n characters randomly from a string
# function parameters = count string
# function return type = string
GetRandomChars() {
    local count=$1
    local string=$2
    result=""
    if [[ -n $string ]];then
    for ((i=0;i<$count;i++));do
        result+=${string:$(( RANDOM % ${#string} )):1}
    done
    fi
    return 0
}

# function randomize string
# function parameters = string
# function return type = string
RandomizeString() {
    echo $1 | fold -w1 | shuf | tr -d '\n'
}

# get start time
start=$(date +%s.%N)

# main loop
for ((j=0;j<$numPasswordCount;j++));do

    # if --password-pattern is set then parse it
    if [[ -n $stringPasswordPattern ]];then
        password=""
        for ((k=0;k<${#stringPasswordPattern};k++));do
            chr=${stringPasswordPattern:$k:1}
            case $chr in
                u) GetRandomChars 1 $charsUpperCase
                   password+=$result
                   ;;
                l) GetRandomChars 1 $charsLowerCase
                   password+=$result
                   ;;
                s) GetRandomChars 1 $charsSpecialCase
                   password+=$result
                   ;;
                d) GetRandomChars 1 $charsDigits
                   password+=$result
                   ;;
                q) GetRandomChars 1 $charsUpperCase$charsLowerCase$charsSpecialCase$charsDigits
                   password+=$result
                   ;;
                @) k=$((k+1))
                   chr=${stringPasswordPattern:$k:1}
                   password+=$chr
                   ;;
                *) echo "ERROR: invalid character \"$chr\" in --password-pattern"
                   usage
                   exit 1
                   ;;
            esac
        done
    else
        # get the minimum characters from constant characterpool
        GetRandomChars $numUpperCase $charsUpperCase
        password=$result
        GetRandomChars $numLowerCase $charsLowerCase
        password+=$result
        GetRandomChars $numSpecialCase $charsSpecialCase
        password+=$result
        GetRandomChars $numDigits $charsDigits
        password+=$result
        GetRandomChars $numRandomChr $charsUpperCase$charsLowerCase$charsSpecialCase$charsDigits
        password+=$result
    fi

    # calculate password padding-length
    diff=$((numPasswordLength-${#password}))

    # password padding
    if [[ $diff > 0 ]] ;then
        case $charAppending in
            u) GetRandomChars $diff $charsUpperCase
               password+=$result
               ;;
            l) GetRandomChars $diff $charsLowerCase
               password+=$result
               ;;
            s) GetRandomChars $diff $charsSpecialCase
               password+=$result
               ;;
            d) GetRandomChars $diff $charsDigits
               password+=$result
               ;;
            q) GetRandomChars $diff $charsUpperCase$charsLowerCase$charsSpecialCase$charsDigits
               password+=$result
               ;;
            *) echo "ERROR: invalid value \"$charAppending\" in --apending-char"
               usage
               exit 1
               ;;
        esac
    fi

    # password randomization
    if [[ -n $flagRandomize ]];then
        password=$(RandomizeString $password)
    fi

    # output password
    echo $password
done

# get end time
end=$(date +%s.%N)

# calculate runtime
runtime=$(echo "$end-$start" | bc -l)

# write out statistics
if [[ -n $flagStatistic ]];then
    echo
    echo "$numPasswordCount passwords"
    echo "with ${#password} characters ($((${#password} * 8)) bits)"
    echo "created in $runtime seconds"
fi

exit 0

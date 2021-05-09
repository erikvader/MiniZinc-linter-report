#!/bin/bash

set -eo pipefail
shopt -s lastpipe

# stuff for recording arguments
model=
solver=
timeout=
satisfy=
Nmin=
Nmax=
Mmin=
Mmax=
scoremin=
scoremax=
bettermaxscore=
dynmaxscore=
abortonfirst=

# last score from run_minizinc
# curscore=

# function print_help {
#     echo "$0 -h"
#     echo
#     echo "$0 -m MODEL -s SOLVER [flags..] -N NR"
#     echo "    run MODEL using SOLVER on all datafiles specified in range NR"
#     echo
#     echo "$0 -m MODEL -s SOLVER [flags..] [-d] [-c] -N N -M MR [-S SR]"
#     echo "    run MODEL using SOLVER on a board of size N."
#     echo "    MR is a range of number of rectangles to use and SR is optionally a range of score upper limits to use."
#     echo "    If -d then update the score limit dynamically. SR can't be a range if this is specified."
#     echo "    If -c then stop as soon as a solution has been found"
#     echo
#     echo "flags"
#     echo "-t TIMEOUT: timeout after TIMEOUT milliseconds"
#     echo "-a:         use solve satisfy and score equals"
#     echo "-b:         use a tighter maximum score limit"
# }

solver=chuffed
model=$HOME/Documents/minizinc-benchmarks/nsp/nsp_1_improved.mzn
timeout=60000
datafiles=$HOME/Documents/minizinc-benchmarks/nsp/period_14_

function run_minizinc {
    # curscore=
    local TIMEFORMAT='Elapsed time: %R'
    { time minizinc ${timeout:+ --time-limit "$timeout"} --solver "$solver" "$model" "$@" ; } 2>&1 \
        | sed -E '/^(Elapsed time: |score: |% Time limit exceeded!|=====UNSATISFIABLE=====|xs: |ys: |hs: |ws: )/!d; s/^=====UNSATISFIABLE=====/score: unsat/'
}

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo -n "$(basename "$line"),"
    run_minizinc "$line"
done < <(find "$datafiles" -type f | sort -V)

# function max_score {
#     local n=$1
#     if [[ -n $bettermaxscore ]]; then
#         bc -l <<EOD
# a = $n / l($n)
# scale=0
# (a+1)/1 + 3
# EOD
#     elif [[ $((n % 2)) -eq 0 ]]; then
#         echo $((2 * n))
#     else
#         echo "$n"
#     fi
# }

# function datafile_name {
#     echo datafiles/d_"$(printf %02d "$1")".dzn
# }

# function solution {
#     local N="$1"
#     local dfn
#     dfn=$(datafile_name "$N")
#     if [[ -f $dfn ]]; then
#         sed -En 's/^% res: /optimal: /p' < "$dfn"
#     else
#         echo 'optimal: unknown'
#     fi
# }

# while getopts ':m:s:N:M:t:S:habdc' opt; do
#     case "$opt" in
#         m) model=$OPTARG ;;
#         s) solver=$OPTARG ;;
#         a) satisfy=1 ;;
#         b) bettermaxscore=1 ;;
#         d) dynmaxscore=1 ;;
#         c) abortonfirst=1 ;;
#         N) case "$OPTARG" in
#                *-*) IFS=- read -r Nmin Nmax <<< "$OPTARG" ;;
#                *) Nmin=$OPTARG; Nmax=$OPTARG ;;
#            esac
#            ;;
#         M) case "$OPTARG" in
#                *-*) IFS=- read -r Mmin Mmax <<< "$OPTARG" ;;
#                *) Mmin=$OPTARG; Mmax=$OPTARG ;;
#            esac
#            ;;
#         S) case "$OPTARG" in
#                *-*) IFS=- read -r scoremin scoremax <<< "$OPTARG" ;;
#                *) scoremin=$OPTARG; scoremax=$OPTARG ;;
#            esac
#            ;;
#         t) timeout=$OPTARG ;;
#         h)
#             print_help
#             exit 1
#             ;;
#         \?)
#             echo invalid flag -"$OPTARG" >&2
#             print_help
#             exit 1
#             ;;
#         :)
#             echo "option -$OPTARG wants a parameter" >&2
#             exit 1
#             ;;
#     esac
# done

# if [[ -z $model || -z $solver ]]; then
#     echo must specify a model and a solver >&2
#     exit 1
# fi

# if [[ $satisfy ]]; then
#     tempfile=$(mktemp --tmpdir 'run_mondrian-XXXXXXXX.mzn')
#     trap 'rm -f "$tempfile"' EXIT
#     sed 's/minimize score;/satisfy;/; s/^constraint score <= MAX_SCORE;/constraint score = MAX_SCORE;/' < "$model" > "$tempfile"
#     model=$tempfile
# fi

# if [[ -z $Mmin && -z $scoremin && -n $Nmin ]]; then
#     for n in $(seq "$Nmin" "$Nmax"); do
#         scoremax=$(max_score "$n")
#         scoremin=$scoremax
#         echo "--score limit: $scoremax--"
#         echo "N: $n"
#         solution "$n"
#         run_minizinc -DMAX_SCORE="$scoremax" "$(datafile_name "$n")"
#         echo
#     done
# elif [[ -n $Mmin && -n $Nmin && $Nmin -eq $Nmax && ( -z $dynmaxscore || $scoremin = "$scoremax" ) ]]; then
#     if [[ -z $scoremin ]]; then
#         scoremin=$(max_score "$Nmin")
#         scoremax=$scoremin
#     fi

#     solution "$Nmin"
#     echo
#     for s in $(seq "$scoremin" "$scoremax"); do
#         echo "--score limit: $s--"
#         for m in $(seq "$Mmin" "$Mmax"); do
#             echo "M: $m"
#             run_minizinc -DN="$Nmin" -DM="$m" -DMAX_SCORE="$s"
#             echo

#             if [[ -n $abortonfirst && $curscore =~ ^[0-9]+$ ]]; then
#                 echo 'exiting early...'
#                 exit 0
#             fi

#             if [[ -n $dynmaxscore && $curscore =~ ^[0-9]+$ && $curscore -lt $scoremin ]]; then
#                 scoremin=$curscore
#                 scoremax=$curscore
#                 echo "--score limit: $curscore--"
#                 s=$curscore
#             fi
#         done
#     done
# fi

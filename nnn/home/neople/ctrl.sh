#!/bin/sh

DNF_DIR="/home/neople"
mess0="伺服器要關閉了"
mess1="分鐘後伺服器即將關閉"
mess2="伺服器即將要關機進行維護，會以更好的品質與您見面!"

game ()
{
  script_run1=$1
  script_run2=$2
  script_run3=$3
  cfg1=cfg
  cd ${DNF_DIR}/game
  if [ ${script_run2} = "stop" ];
  then
    cfg1=pid
  fi
  if [ -z "$script_run3" ];
  then
    CFG=`ls $cfg1 | awk -F . '{print $1}'`
  else
    CFG=`ls $cfg1 | grep -w $script_run3 | awk -F . '{print $1}'`
  fi
  for i in $CFG
  do
    ./df_game_r $i $script_run2
    echo "CH:$i $script_run2"
    sleep 3
  done
  exit 999;
}


chk_ps()
{
  for i in `ls cfg | grep -v db_info | awk -F . '{print$1}'`
  do
    CHK_RESULT=`ps -ef | grep "${i} " | grep -v grep | awk '{print$9}' | sort -u`
    TCP_PORT=`grep "^tcp_port " ./cfg/${i}.cfg | awk -F = '{print$2}'  | awk '{print$1}' | cut -c1-5`
    UDP_PORT=`grep -e "^udp_port " ./cfg/${i}.cfg | awk -F = '{print$2}' | awk '{print$1}' | cut -c1-5`
    if [ "${i}" = "${CHK_RESULT}" ]
    then
      printf "${i} - t:${TCP_PORT} - u:${UDP_PORT} - ${CHK_RESULT} - [OK]\n"
    else
      printf "${i} - t:${TCP_PORT} - u:${UDP_PORT} - ${CHK_RESULT} - "
      echo -e "\033[1;31mFail\033[m"
    fi
  done
}

chk_count()
{
  PS_COUNT=`ps -ef | grep df_game | grep -v grep | awk '{print$9}' | sort -u | wc -l`
  CFG_DIR_COUNT=`ls ${DNF_DIR}/cfg | grep -v db_info | wc -w | awk '{print$1}'`
  if [ "${PS_COUNT}" -eq "${CFG_DIR_COUNT}" ]
  then
    echo "process count : ${PS_COUNT} / cfg dir : ${CFG_DIR_COUNT} : OK."
  else
    echo "process count : ${PS_COUNT} / cfg dir : ${CFG_DIR_COUNT} : Fail."
  fi
}

###############################
# 2013.03.04
# DNF 10분 종료
# sibaek@neople.co.kr
###############################

# Usage
function help
{
  echo "Usage   : `basename $0` [ -h  | -d  | -s  | -a ]"
  echo "  -h | help : This help"
  echo "  -d | display : just display DNF Game processes and exit"
  echo "  -s | stop : just display DNF Game processes and choice stop"
  echo "  -a | all : just display DNF Game processes and all stop"
  exit
}

# DNF GAME Process Display.
function Display
{
  echo ""
  echo "+--------+-------+-------+-------+-------+"
  echo "|   PID  |  PPID | State |  User |  CMD  |"
  echo "+--------+-------+-------+-------+-------+"
  UNIX95= ps -eo pid,ppid,state,user,cmd | awk 'BEGIN { count=0 } $5 ~ /df_game_r/ { count++; print $1" | ",$2" | ",$3" | ",$4" | ",$5,$6,$7 } END { print "\n" "Process: " count "\n\nDNF GAME Process to Display." }'
  echo ""
}

# DNF GAME All Stop
function AStop
{
  read -p "Enter DNF Game Process to All Stop ? Y|N   : " CHOICE
    
  if [ "$CHOICE" = "N" ] || [ "$CHOICE" = "n" ] || [ "$CHOICE" = "" ]
  then
    echo "+--------+-------+-------+-------+-------+ "
    echo "+ Exit Program...                        + "
    echo "+--------+-------+-------+-------+-------+ " 
    exit
  fi

  if [ "$CHOICE" = "Y" ] || [ "$CHOICE" = "y" ]
  then
    echo "+--------+-------+-------+-------+-------+ "
    echo "+ DNF Game Process All Stop...           + "
    echo "+--------+-------+-------+-------+-------+ "
    OIFS=$IFS;
    IFS="|";
    daemon=(`ps -eo cmd | awk '$1 ~ /df_game_r/ { print $1" "$2"|"}'`);
    IFS=$OIFS;
    echo "+--------+-------+-------+-------+-------+ "
    echo "+daemon element = [${daemon[@]}]         + "
    echo "+daemon len = ${#daemon[*]}              + "
    echo "+--------+-------+-------+-------+-------+ "
  fi

  daemon_count=${#daemon[*]}

  if [ 0 -eq $daemon_count ]
    then
    echo "+--------+-------+-------+-------+-------+ "
    echo "+ Game Process not running...            + " 
    echo "+ Exit Program...                        + "
    echo "+--------+-------+-------+-------+-------+ "
    exit
  fi

  timedown ${daemon_count} $1
}

function timedown
{
  daemon_count=$1
  for ((i=0; i< $daemon_count; i++  ))
  do
    ${daemon[i]} mess $mess0
    echo "+--------+-------+-------+-------+-------+--------+-------+-------+-------+-------+-------+-------+ "
    echo "+ ${daemon[i]} mess $mess0                                                                        + "
    echo "+--------+-------+-------+-------+-------+--------+-------+-------+-------+-------+-------+-------+ "
  done

  for i in `seq $2 -1 1`
  do
    for ((j=0; j< $daemon_count; j++  ))
    do
            ${daemon[j]} mess "$i $mess1"
            echo "+--------+-------+-------+-------+-------+-------+-------+ "
            echo "+ ${daemon[j]} mess  $i $mess1                           + "
            echo "+--------+-------+-------+-------+-------+-------+-------+ "

    done

    sleep 60

  done

  for ((i=0; i< $daemon_count; i++  ))
  do
    ${daemon[i]} mess $mess2
    echo "+--------+-------+-------+-------+-------+-------+  "
    echo "+ ${daemon[i]} mess $mess2                       +  "
    echo "+--------+-------+-------+-------+-------+-------+  "

  done

  sleep 10

  for ((i=0; i< $daemon_count; i++  ))
  do
    ${daemon[i]} stop
    echo "+--------+-------+-------+  "
    echo "+ ${daemon[i]} stop      +  "
    echo "+--------+-------+-------+  "

    sleep 3

  done
}

# DNF GAME Choice Stop
function CStop
{
  echo "+-Example-+-----+-----+-----+-----+-----+ "
  echo "+ pid entered once : 1234               + "
  echo "+ pid for multiple input : 1234,5678    + "
  echo "+---------+-----+-----+-----+-----+-----+ "
  echo ""
  echo "Enter DNF Game PID or 'exit'  : " 
  IFS="," read -ra GPID
  echo "+--------+-------+-------+-------+-------+ "
  echo "+ GPID element = [${GPID[@]}]            + "
  echo "+ GPID len = ${#GPID[*]}                 + "
  echo "+--------+-------+-------+-------+-------+ "

  pid_count=${#GPID[*]}
 
  if [ "${GPID[@]}" = "exit" ] || [ 0 -eq $pid_count ] 
  then
    echo "+--------+-------+-------+-------+-------+ "
    echo "+ Exit Program...                        + " 
    echo "+--------+-------+-------+-------+-------+ "
    exit
  fi

  if [ 0 -eq $pid_count ]
  then
    echo "+--------+-------+-------+-------+-------+ "
    echo "+ Game Process not running...            + " 
    echo "+ Exit Program...                        + "
    echo "+--------+-------+-------+-------+-------+ "
    exit
  fi


  for ((i=0; i< $pid_count; i++  ))
  do
    if [ "${GPID[i]}" != "0" ]
    then
      UNIX95= ps -o pid,user,state,cmd -p ${GPID[i]} | \
              awk '$1 ~ /^[0-9]*$/ { print "The program cmd " $4" "$5" "$6 " with PID " $1 " is being run by the user " $2 }'

      #read -p "Are you sure you want to stop PID $GPID ? Y|N : " COMMIT_KILL
      #if [ "$COMMIT_KILL" = "Y" ] || [ "$COMMIT_KILL" = "y" ]
      #then
      #fi
      #daemon+=(`ps -eo pid,cmd | grep ${GPID[i]} |grep -v grep | awk '{print $2" "$3}'`);
      OIFS=$IFS;
      IFS="|";
      daemon+=(`ps -o pid,cmd -p ${GPID[i]} | awk '$1 ~ /^[0-9]*$/ {print $2" "$3} '`);
      IFS=$OIFS;
    fi 
  done
 
  echo "+--------+-------+-------+-------+-------+ "
  echo "+ daemon element = [${daemon[@]}]        + "
  echo "+ daemon len = ${#daemon[*]}             + "
  echo "+--------+-------+-------+-------+-------+ "

  daemon_count=${#daemon[*]}
  timedown ${daemon_count} $1

}

command()
{
  case "$1" in
    "all_app")
      if [ "$2" == "start" ]
      then
        script_run=( dbmw_mnt dbmw_stat dbmw_guild guild monitor statics )
      else
        script_run=( guild monitor statics dbmw_mnt dbmw_stat dbmw_guild )
      fi
    ;;
    "all_common")
      script_run=( manager bridge community coserver )
    ;;
    "all_auction")
      script_run="auction"
      cd ${DNF_DIR}/${script_run}
      CFG=`ls cfg`
      for i in $CFG
      do
        ./df_auction_r cfg/$i $2 df_auction_r
        echo "Auction:$i $2"
        sleep 2
      done
      exit 999;
    ;;
    "all_point")
      script_run="point"
      cd ${DNF_DIR}/${script_run}
      CFG=`ls cfg`
      for i in $CFG
      do
        ./df_point_r cfg/$i $2 df_point_r
        echo "point:$i $2"
        sleep 2
      done
      exit 999;
    ;;
    "auction")
      script_run="auction"
      cd ${DNF_DIR}/${script_run}
      CFG=`ls cfg | grep $3`
      for i in $CFG
      do
        ./df_auction_r cfg/$i $2 df_auction_r
        echo "Auction:$i $2"
      done
      exit 999;
    ;;
    "point")
      script_run="point"
      cd ${DNF_DIR}/${script_run}
      CFG=`ls cfg | grep $3`
      for i in $CFG
      do
        ./df_point_r cfg/$i $2 df_point_r
        echo "point:$i $2"
      done
      exit 999;
    ;;
    "stun")
      script_run=$1
      cd ${DNF_DIR}/${script_run}
      ./df_$1_r $2
      exit 999;
    ;;
    bridge|channel|community|coserver|manager|statics|monitor|guild|dbmw_guild|dbmw_stat|dbmw_mnt)
      script_run=$1
    ;;
    "game")
      game $1 $2 $3
      exit 999;
    ;;
    "relay")
      script_run=$1
      cd ${DNF_DIR}/${script_run}
      CFG=`ls cfg | awk -F . '{print $1}'`
      for i in $CFG
      do
        ./df_relay_r $i $2
        echo "CH:$i $script_run"
        sleep 1
      done
      exit 999;
    ;;
    "waitdown")
      script_run="game"
      cd ${DNF_DIR}/${script_run}
      # arg check 
      if [ $# -lt 1 ]; then
        help
      fi

      if [ "$3" = "-h" ] || [ "$3" = "help" ]
      then
        help
      fi

      if [ "$3" = "-d" ] || [ "$3" = "display" ]
      then
        Display
      fi

      if [ "$3" = "-s" ] || [ "$3" = "stop" ]
      then
        Display
        CStop $2
      fi

      if [ "$3" = "-a" ] || [ "$3" = "all" ]
      then
        Display
        AStop $2
      fi
      Display
      AStop $2
      cd
      echo ""
      exit 999;
    ;;
    "chk_ch")
      cd ${DNF_DIR}
      chk_count
      chk_ps
      exit;
    ;;
    # "update")
    #   cd /home/neople/patch/TWDF_Server_LIVE_tw
    #   /usr/bin/svn up
    #   cd
    # ;;
    # "core_commit")
    #   cd /home/neople/patch/TWDF_Server_LIVE_tw/data/core
    #   svn status | awk '{if ($1 == "?") print $2 }' | xargs svn add
    #   /usr/bin/svn ci -m'[core] commit'
    #   cd
    # ;;
    # "tp")
    #   cd ${DNF_DIR}/secsvr/bin
    #   if [ "$2" == "start" ]
    #   then
    #     ./start_secagent.sh
    #   else
    #     ./stop_secagent.sh
    #   fi
    #   cd
    # ;;
    *)
      echo "process name was wrong"
      exit 999;
    ;;
  esac

  for i in ${script_run[@]}
  do
    cd ${DNF_DIR}/$i
    if [ ${i:0:4} == "dbmw" ]; then
      i=${i:0:4}
    fi
    ./df_${i}_r `ls cfg | grep cfg | awk -F"." '{print $1}'` $2
    sleep 2
    cd
  done
}

exhand2=( chk_ch update waitdown core_commit )
exhand1=( all_app all_auction all_common all_point tp )

case "$2" in
  start|stop)
    if [ -d $1 ] || [ $1 == ${exhand1[0]} ] || [ $1 == ${exhand1[1]} ] || [ $1 == ${exhand1[2]} ] || [ $1 == ${exhand1[3]} ] || [ $1 == ${exhand1[4]} ]
    then
    command $1 $2 $3;
    else
    echo "dont installed"
    fi
  ;;
  *)
    if [ $1 == ${exhand2[0]} ] || [ $1 == ${exhand2[1]} ] || [ $1 == ${exhand2[2]} ] || [ $1 == ${exhand2[3]} ]
    then
      echo "$2";
      command $1 $2 $3;
    else
      echo "start/stop?"
    fi
  ;;
esac

#!/usr/bin/env bash
#
#
MTS_HOST=${MTS_HOST:-172.17.0.2}
MTS_USER=${MTS_USER:-st01}
MTS_PASSWORD=${MTS_PASSWORD:-st01}
MTS_PRINTER_PORT=${MTS_PRINTER_PORT:-1403}
MTS_CARD_RDR_PORT=${MTS_CARD_RDR_PORT:-3505}
MTS_CARD_PCH_PORT=${MTS_CARD_PCH_PORT:-3525}
MTS_TERMINAL_PORT=${MTS_TERMINAL_PORT:-3270}
PARAMS=""
PROG=`basename $0`


while (( "$#" )); do
  case "$1" in
    -h|--host)
      MTS_HOST=$2
      shift 2
      ;;
    -u|--user)
      MTS_USER=$2
      shift 2
      ;;
    -p|--password)
      MTS_PASSWORD=$2
      shift 2
      ;;
    --rdr-port)
      MTS_CARD_RDR_PORT=$2
      shift 2
      ;;
    --pch-port)
      MTS_CARD_PCH_PORT=$2
      shift 2
      ;;
    -t|--terminal-port)
      MTS_TERMINAL_PORT=$2
      shift 2
      ;;
    --printer-port)
      MTS_PRINTER_PORT=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      echo "Usage: $0 [ --printer-port num ] [ -t num | --terminal-port num ] [--pch-port num ]  [ --rdr-port num ] [ -h host | --host host ] [ -u user | --user user ] [ -p password | --password password ]"
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"

#
# Now set netcat style commands for print, punch and reader.
#
which ncat > /dev/null 2>&1
if [ $? -eq 0 ]
then
    MTS_PRINT="ncat --recv-only -i 5 $MTS_HOST $MTS_PRINTER_PORT"
    MTS_PUNCH="ncat --recv-only -i 5 $MTS_HOST $MTS_CARD_PCH_PORT"
    MTS_READR="ncat --send-only -w 1 $MTS_HOST $MTS_CARD_RDR_PORT"
else
    which gnetcat > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
	MTS_PRINT="gnetcat -w 20 $MTS_HOST $MTS_PRINTER_PORT"
	MTS_PUNCH="gnetcat -w 1 $MTS_HOST $MTS_CARD_PCH_PORT"
	MTS_READR="gnetcat --close $MTS_HOST $MTS_CARD_RDR_PORT"
    else
	MTS_PRINT="netcat -w 20 $MTS_HOST $MTS_PRINTER_PORT"
	MTS_PUNCH="netcat -w 1 $MTS_HOST $MTS_CARD_PCH_PORT"
	MTS_READR="netcat -w 1 $MTS_HOST $MTS_CARD_RDR_PORT"
    fi
fi

BATCH_FILE=/tmp/mts_batch.$$

function gen_card_number ()
{
    echo `expr $RANDOM + 100000`
}

function begin_job ()
{
    CARDNUM=`gen_card_number`
    echo "\                " $CARDNUM "              DECK                             199999 ."  > $BATCH_FILE
    echo '$signon ' "$MTS_USER CROUTE=CNTR TIME=100 " >> $BATCH_FILE
    echo "$MTS_PASSWORD" >> $BATCH_FILE
}

function copy_file_to_mts ()
{
    echo '$create' "$1" >> $BATCH_FILE
    echo '$empty' "$1" >> $BATCH_FILE
    echo '$COPY *SOURCE*' "$1" >> $BATCH_FILE
    cut -c 1-80 $1 >> $BATCH_FILE
    echo '$ENDFILE' >> $BATCH_FILE
}

function copy_file_from_mts()
{
    echo '$copy ' "$1 *PUNCH*" >> $BATCH_FILE
}

function end_job ()
{
    echo '$SIGNOFF' >> $BATCH_FILE
}

function run_gpss ()
{
    echo '$run *gpss' "scards=$1 PAR=SIZE=C" >> $BATCH_FILE
}


#
# How were we invoked?
#

case "$PROG" in
    "mts-copyto" )
	begin_job $1
	copy_file_to_mts $1
	end_job
	;;
    "mts-copyfrom")
	begin_job
	copy_file_from_mts $1
	end_job
        ;;
    "mts-gpss")
	begin_job
	copy_file_to_mts $1
	run_gpss $1
	end_job
	;;
    *)
	begin_job
	cut -c 1-80 $1 >> $BATCH_FILE
	end_job
	;;
esac

$MTS_READR < $BATCH_FILE

$MTS_PRINT

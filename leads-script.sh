# Script to get leds from the server logs
# Args:
#   - $1: log file
#   - $2: num unique ips to look at
# Outputs:
#   - report.txt: final report
#   - domains.txt: a list of the domains found (from the incoming IP addresses)
#   - unique-ips.txt: a list of unique IPs found

LOG_PATH=""
#LOG_NAME=$LOG_PATH"erlerobotics.com.access.log-20150405"
LOG_NAME=$LOG_PATH
LOG_NAME+=$1
NUM=$2
UNIQUE_IPS="unique-ips.txt"
UNIQUE_IPS_AUX="unique-ips.txt.aux"
REPORT_FILE="report.txt.aux"
FINAL_REPORT="report.txt"
DOMAINS_FILE="domains.txt"
DOMAINS_FILE_AUX="domains.aux"
DOMAINS_FILE_AUX2="domains.aux2"

# Clear report file
echo "" > $DOMAINS_FILE
echo "" > $UNIQUE_IPS
echo "" > $FINAL_REPORT
echo "========================" >> $REPORT_FILE
echo "========================" >> $REPORT_FILE
echo "REPORT            " >> $REPORT_FILE
echo "========================" >> $REPORT_FILE
echo "========================" >> $REPORT_FILE

# Unique IPs and source queried (format: <ip address> <relative-path-resource>)
#cat $LOG_NAME | awk '{print $1" "$7 "\n"}' | grep blog/product | sort -u | head -20  > $UNIQUE_IPS_AUX
cat $LOG_NAME | awk '{print $1 "\n"}' | sort -u | head -$NUM > $UNIQUE_IPS

# Domains with dig
cat $UNIQUE_IPS | sed 's/^/dig -x /' | sed "s/$/ | head -12 | tail -1| awk '{print "'$5'"}' #/" \
    > $DOMAINS_FILE_AUX

while read p; do
    echo "========================" >> $REPORT_FILE
    echo "      LEAD                 ">> $REPORT_FILE
    echo "========================" >> $REPORT_FILE

    IP=$(echo $p | awk '{print $3}')
    echo $IP >> $REPORT_FILE
    DOMAIN=$(echo $p | bash 2> /dev/null )
    echo $DOMAIN >> $REPORT_FILE
    echo $DOMAIN >> $DOMAINS_FILE_AUX2

    echo "Searched for: ">> $REPORT_FILE
    cat $LOG_NAME | grep $IP | awk '{print $7}' >> $REPORT_FILE

    echo $DOMAIN | awk '{print "theHarvester/theHarvester.py -d "$0" -l 100 -b google"}' | bash | \
        tail -n+15 >> $REPORT_FILE
done < $DOMAINS_FILE_AUX

# Sort domains in the domain file
cat $DOMAINS_FILE_AUX2 | sort -u > $DOMAINS_FILE

# Create the final report
cat $DOMAINS_FILE >> $FINAL_REPORT
cat $REPORT_FILE >> $FINAL_REPORT

rm $REPORT_FILE
rm $DOMAINS_FILE_AUX
rm $DOMAINS_FILE_AUX2


#!/bin/bash

#GET INFO
domain=$1

#FIND SUBDOMAINS 
subfinder -d $domain >> temp_domains.txt

curl "https://crt.sh/?q=%25."$domain | grep -oE '[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' >> temp_domains.txt

#Remove duplicates
sort temp_domains.txt | uniq > unique_domains.txt



#Check for alive domains and add them in to domains.txt
cat unique_domains.txt | httprobe > t_domains.txt



#Remove duplicates
sort t_domains.txt | uniq > td_domains.txt
cat td_domains.txt | grep -v "crt.sh" | grep -v 'github' | grep -v 'sectigo'> domains.txt

#Get JS files
cat domains.txt | jsfinder -read -s -o js-files.txt

#Aquatone 
mkdir aquatone_report
cd aquatone_report
cat ../domains.txt | aquatone
firefox aquatone_report.html
cd ..

#Find Emails
emailfinder $domain > emails.txt

#Find Whois Info
whois $domain > whois.txt

#Find Web Info
whatweb --input-file=domains.txt > whatweb.txt

#Find Hijacable Domains
subjack -w unique_domains.txt -t 20 -v -timeout 30 -o hijacable.txt

#Find Interesting Params
paramspider -d $domain

#Find Location
geoiplookup $domain > geo_location.txt

#Find DNS Info
dnsrecon -d $domain > dns.txt

#Get Report Showing
echo '----------------------------------- REPORT -----------------------------------'
echo ' '
echo ' '
echo '----------------------------------- WHOIS -----------------------------------' 
cat whois.txt
echo ' '
echo ' '
echo '----------------------------------- DNS - INFO -----------------------------------' 
cat dns.txt
echo ' '
echo ' '
echo '----------------------------------- DOMAINS -----------------------------------' 
cat domains.txt
echo ' '
echo ' '
echo '----------------------------------- JS-FILES -----------------------------------' 
cat js-files.txt
echo ' '
echo ' '
echo '----------------------------------- Interesting Parameters -----------------------------------' 
cat results/$domain.txt
echo ' '
echo ' '
echo '----------------------------------- HIJACABLE-DOMAINS -----------------------------------' 
cat hijacable.txt
echo ' '
echo ' '
echo '----------------------------------- GEO-LOCATION -----------------------------------' 
cat geo_location.txt
echo ' '
echo ' '
echo '----------------------------------- EMAILS-FOUND -----------------------------------' 
cat emails.txt
echo ' '
echo ' '

#Cleans Env
rm unique_domains.txt temp_domains.txt t_domains.txt td_domains.txt

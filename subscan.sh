#!/bin/bash

APP_PATH=$(pwd)
RESOURCES="$HOME/.resources"

[ ! -d "$HOME/.resources" ] && mkdir "$HOME/.resources"

# colors
info=$(tput setaf 4)
none=$(tput sgr0)

# domains
if [[ ! -e "$APP_PATH/domains" || ! -s "$APP_PATH/domains" ]]; then
    echo '"domains" file not found or are empty.'
    exit 1
fi

domains=$(cat domains)

# passive recon
echo "[$info+$none] Initializing passive recon 󰣉 "

# subfinder
subfinder -up &> /dev/null
subfinder -nW -t 100 -all -o subdomains.subfinder -dL domains
cat subdomains.subfinder | anewer subdomains.all && rm subdomains.subfinder

# amass
amass enum -v -norecursive -passive -nf subdomains -df domains -o subdomains.amass
cat subdomains.amass | anewer subdomains.all && rm subdomains.amass

# crt.sh
curl -s "https://crt.sh/?q=%25.$domains&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | anewer subdomains.all

# crobat
crobat -s domains | anewer subdomains.all

# cleaning up
cat subdomains.all | dnsx -silent | anewer subdomains && rm subdomains.all

echo "[$info+$none] Initializing brute recon 󰣉 "

# getting files
wget -nv -O "$RESOURCES/resolvers.txt" https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt
wget -nv -O "$RESOURCES/all.txt" https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt 
wget -nc -O "$RESOURCES/top-1million.txt" https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-110000.txt 

# top 1 million
for domain in $(cat "$APP_PATH/domains"); do
    shuffledns -d $domain -r "$RESOURCES/resolvers.txt" -w "$RESOURCES/top-1million.txt" -o "$APP_PATH/subdomains.shuffledns"
    cat "$APP_PATH/subdomains.shuffledns" | anewer subdomains
    rm  "$APP_PATH/subdomains.shuffledns"
done

# all
for domain in $(cat "$APP_PATH/domains"); do
    shuffledns -d $domain -r "$RESOURCES/all.txt" -w "$RESOURCES/top-1million.txt" -o "$APP_PATH/subdomains.shuffledns"
    cat "$APP_PATH/subdomains.shuffledns" | anewer subdomains
    rm  "$APP_PATH/subdomains.shuffledns"
done

echo "[$info+$none] Recon Finished"


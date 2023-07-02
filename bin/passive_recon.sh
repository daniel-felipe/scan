#!/bin/bash

domains=$(cat domains)

# colors
info=$(tput setaf 4)
none=$(tput sgr0)

echo "[$info+$none] Initializing passive recon 󰣉 "

# subfinder
subfinder -up &> /dev/null
subfinder -nW -t 100 -all -o subdomains.subfinder -dL domains
[ -e subdomains.subfinder ] && cat subdomains.subfinder | anewer subdomains.all && rm subdomains.subfinder

# amass
amass enum -v -norecursive -passive -nf subdomains -df domains -o subdomains.amass
[ -e subdomains.amass ] && cat subdomains.amass | anewer subdomains.all && rm subdomains.amass

# crt.sh
curl -s "https://crt.sh/?q=%25.$domains&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | anewer subdomains.all

# crobat
crobat -s domains | anewer subdomains.all

# cleaning
cat subdomains | dnsx -silent | anewer subdomains
rm subdomains.all

#!/bin/bash
###########################################################################################
##
##          FREEBOX DELTA LIBRARY WITH VM SUPPORT: fbx-delta-nba_bash_api.sh 
##
##          => forked by NBA from https://github.com/JrCs/freeboxos-bash-api 
##_________________________________________________________________________________________
##
## 
##   THIS BASH LIBRARY (from 2013 to 2023):
##           => allow you to call all HTTPS & WEBSOCKET API on Freebox / Iliadbox 
##           => provide all backend function for calling API, login...
##           => was designed first for Virtual Machines management on Freebox Delta
##           => but provide frontend functions for managing:
##               - Download API / share link API
##               - Network DHCP API
##               - Network NAT redirection API
##               - Virtual Machine API
##		 - Filesystem tasks API
##
##   WARNING: curl openssl and websocat are needed - see 'EXTOOLS' after the code 
##
##   WARNING: lots of changes add been made to the original project (+3000 lines) 
##            => See CHANGELOG at the end afer 'EXTOOLS' (after the code)
##
##
##_________________________________________________________________________________________
##
##   This bash library can be used on Internet Home Router & Server from FREE Telecom : 
##    --> French FREEBOX: DELTA - POP - MINI - Revolution - ONE(end of sell 2020-07)
##    --> Italian ILIADBOX (since 2022-01-25) <=> Italian "Freebox POP" 
##_________________________________________________________________________________________
##
##   This program / library is provided 'as is' with no warranty - use at your own risks
##
###########################################################################################


###########################################################################################
## 
##  Library USER configuration - URL - Certificate Authority - Country - External Tools
## 
###########################################################################################


#---------------------------- USER CONFIGURABLE OPTIONS ----------------------------#


# Uncomment next line to check required external tools:
# source $BASH_SOURCE && for tool in curl openssl websocat; do check_tool $tool; done 

# Support of Italian ILIADBOX
# Set value to "yes" if you are in Italy and you want to use this library with your ILIADBOX
# If you set ITALY="yes", you must fullfill ILIADBOX_*_URL and ILIADBOX_*_CACERT variables
#ITALY="yes"
ITALY="no"

# Support of auto relogin (necessary for long monitoring tasks)
# here you need to put a strong password used to protect your "app-token" in the session
# As an example here is the password I'm using to protect my token in the session
#_APP_PASSWORD="DefineAStrongPasswordM"
_APP_PASSWORD="NMZ7kTRv+wWow9M"

# Freebox local URL (optional, used if set and if $FREEBOX_WAN_URL not set)
# This option require you add a local domain name and a private certificate 
# in your freebox / iliadbox in FreeboxOS> parameters > domain names
# NB: This option MUST be null: "" or commented if you do not use it 
# NB: Working the same way for ILIADBOX_LAN_URL 
# As an example to access my box API from my internal LAN domain I set :
FREEBOX_LAN_URL="https://fbx.fbx.lan"
#FREEBOX_LAN_URL=""
ILIADBOX_LAN_URL=""

# Freebox WAN URL (optional, will be used if set)
# This option require you add a local domain name and a private certificate 
# in your freebox / iliadbox in FreeboxOS> parameters > domain names
# NB: This option MUST be null: "" or commented if you do not use it 
# NB: Working the same way for ILIADBOX_WAN_URL
# As an example to access my box API from WAN I set :
# FREEBOX_WAN_URL="https://fbx.my-public-domain.net:2111"
FREEBOX_WAN_URL="https://fbx.mydomain.net:2011"
#FREEBOX_WAN_URL=""
ILIADBOX_WAN_URL=""


# API SECURE ACCESS: PKI SUPPORT & ROOT CA CERTIFICATE 
# This PKI support let us add support for different private CA like Freebox Private CA 
# and let us create a Certificate CA Bundle with all declared private rootCA
# and public CA certificate chain or to fallback to insecure TLS mode (curl -k) 

# Local & private CA certificate used for local domain defined in $FREEBOX_LAN_URL: 
# NB: Only need this option if your local domain use a certificate from a pivate CA
# NB: Working the same way for ILIADBOX_LAN_CACERT
# Here my $FREEBOX_LAN_URL certificate had been signed by my private RSA4096 CA, so   
# for example to access my box API from my LAN domain using my LAN private PKI I set:
FREEBOX_LAN_CACERT="/usr/share/ca-certificates/nba/14rv-rootCA-RSA4096.pem"
#FREEBOX_LAN_CACERT=""
ILIADBOX_LAN_CACERT=""

# Public or private CA certificate used for public domain defined in $FREEBOX_WAN_URL: 
# NB: Needed when using a public domain certificate from a pivate CA or with a "CA chain"
# NB: Working the same way for ILIADBOX_LAN_CACERT
# Here my $FREEBOX_WAN_URL certificate had been signed by my private RSA8192 CA, so
# for example to access my box API from my WAN domain and my WAN private PKI I set:
FREEBOX_WAN_CACERT="/usr/share/ca-certificates/nba/14rv-rootCA-RSA8192.pem"
#FREEBOX_WAN_CACERT=""
ILIADBOX_WAN_CACERT=""


#-------------------------END OF USER CONFIGURABLE OPTIONS -------------------------#


# Freebox / Iliadbox default local URL
# (default, hardcoded, used if $FREEBOX_WAN_URL and $FREEBOX_LAN_URL are not set 
# or for Iliadbox if $ILIADBOX_WAN_URL and $ILIADBOX_LAN_URL are not set) 
# Freebox API will always be reachable on this URL from freebox lan network
FREEBOX_DEFAULT_URL="https://mafreebox.freebox.fr"
ILIADBOX_DEFAULT_URL="https://myiliadbox.iliad.it"


# Freebox Root Certificate Authority (rootCA) :   --hardcoded-- 
# --> RSA (Freebox Root CA): valid until 2035-20-25
# --> ECDSA (Freebox ECC Root CA): valid until 2035-08-27
FREEBOX_DEFAULT_CACERT="-----BEGIN CERTIFICATE-----
MIICWTCCAd+gAwIBAgIJAMaRcLnIgyukMAoGCCqGSM49BAMCMGExCzAJBgNVBAYT
AkZSMQ8wDQYDVQQIDAZGcmFuY2UxDjAMBgNVBAcMBVBhcmlzMRMwEQYDVQQKDApG
cmVlYm94IFNBMRwwGgYDVQQDDBNGcmVlYm94IEVDQyBSb290IENBMB4XDTE1MDkw
MTE4MDIwN1oXDTM1MDgyNzE4MDIwN1owYTELMAkGA1UEBhMCRlIxDzANBgNVBAgM
BkZyYW5jZTEOMAwGA1UEBwwFUGFyaXMxEzARBgNVBAoMCkZyZWVib3ggU0ExHDAa
BgNVBAMME0ZyZWVib3ggRUNDIFJvb3QgQ0EwdjAQBgcqhkjOPQIBBgUrgQQAIgNi
AASCjD6ZKn5ko6cU5Vxh8GA1KqRi6p2GQzndxHtuUmwY8RvBbhZ0GIL7bQ4f08ae
JOv0ycWjEW0fyOnAw6AYdsN6y1eNvH2DVfoXQyGoCSvXQNAUxla+sJuLGICRYiZz
mnijYzBhMB0GA1UdDgQWBBTIB3c2GlbV6EIh2ErEMJvFxMz/QTAfBgNVHSMEGDAW
gBTIB3c2GlbV6EIh2ErEMJvFxMz/QTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB
/wQEAwIBhjAKBggqhkjOPQQDAgNoADBlAjA8tzEMRVX8vrFuOGDhvZr7OSJjbBr8
gl2I70LeVNGEXZsAThUkqj5Rg9bV8xw3aSMCMQCDjB5CgsLH8EdZmiksdBRRKM2r
vxo6c0dSSNrr7dDN+m2/dRvgoIpGL2GauOGqDFY=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIFmjCCA4KgAwIBAgIJAKLyz15lYOrYMA0GCSqGSIb3DQEBCwUAMFoxCzAJBgNV
BAYTAkZSMQ8wDQYDVQQIDAZGcmFuY2UxDjAMBgNVBAcMBVBhcmlzMRAwDgYDVQQK
DAdGcmVlYm94MRgwFgYDVQQDDA9GcmVlYm94IFJvb3QgQ0EwHhcNMTUwNzMwMTUw
OTIwWhcNMzUwNzI1MTUwOTIwWjBaMQswCQYDVQQGEwJGUjEPMA0GA1UECAwGRnJh
bmNlMQ4wDAYDVQQHDAVQYXJpczEQMA4GA1UECgwHRnJlZWJveDEYMBYGA1UEAwwP
RnJlZWJveCBSb290IENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
xqYIvq8538SH6BJ99jDlOPoyDBrlwKEp879oYplicTC2/p0X66R/ft0en1uSQadC
sL/JTyfgyJAgI1Dq2Y5EYVT/7G6GBtVH6Bxa713mM+I/v0JlTGFalgMqamMuIRDQ
tdyvqEIs8DcfGB/1l2A8UhKOFbHQsMcigxOe9ZodMhtVNn0mUyG+9Zgu1e/YMhsS
iG4Kqap6TGtk80yruS1mMWVSgLOq9F5BGD4rlNlWLo0C3R10mFCpqvsFU+g4kYoA
dTxaIpi1pgng3CGLE0FXgwstJz8RBaZObYEslEYKDzmer5zrU1pVHiwkjsgwbnuy
WtM1Xry3Jxc7N/i1rxFmN/4l/Tcb1F7x4yVZmrzbQVptKSmyTEvPvpzqzdxVWuYi
qIFSe/njl8dX9v5hjbMo4CeLuXIRE4nSq2A7GBm4j9Zb6/l2WIBpnCKtwUVlroKw
NBgB6zHg5WI9nWGuy3ozpP4zyxqXhaTgrQcDDIG/SQS1GOXKGdkCcSa+VkJ0jTf5
od7PxBn9/TuN0yYdgQK3YDjD9F9+CLp8QZK1bnPdVGywPfL1iztngF9J6JohTyL/
VMvpWfS/X6R4Y3p8/eSio4BNuPvm9r0xp6IMpW92V8SYL0N6TQQxzZYgkLV7TbQI
Hw6v64yMbbF0YS9VjS0sFpZcFERVQiodRu7nYNC1jy8CAwEAAaNjMGEwHQYDVR0O
BBYEFD2erMkECujilR0BuER09FdsYIebMB8GA1UdIwQYMBaAFD2erMkECujilR0B
uER09FdsYIebMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMA0GCSqG
SIb3DQEBCwUAA4ICAQAZ2Nx8mWIWckNY8X2t/ymmCbcKxGw8Hn3BfTDcUWQ7GLRf
MGzTqxGSLBQ5tENaclbtTpNrqPv2k6LY0VjfrKoTSS8JfXkm6+FUtyXpsGK8MrLL
hZ/YdADTfbbWOjjD0VaPUoglvo2N4n7rOuRxVYIij11fL/wl3OUZ7GHLgL3qXSz0
+RGW+1oZo8HQ7pb6RwLfv42Gf+2gyNBckM7VVh9R19UkLCsHFqhFBbUmqwJgNA2/
3twgV6Y26qlyHXXODUfV3arLCwFoNB+IIrde1E/JoOry9oKvF8DZTo/Qm6o2KsdZ
dxs/YcIUsCvKX8WCKtH6la/kFCUcXIb8f1u+Y4pjj3PBmKI/1+Rs9GqB0kt1otyx
Q6bqxqBSgsrkuhCfRxwjbfBgmXjIZ/a4muY5uMI0gbl9zbMFEJHDojhH6TUB5qd0
JJlI61gldaT5Ci1aLbvVcJtdeGhElf7pOE9JrXINpP3NOJJaUSueAvxyj/WWoo0v
4KO7njox8F6jCHALNDLdTsX0FTGmUZ/s/QfJry3VNwyjCyWDy1ra4KWoqt6U7SzM
d5jENIZChM8TnDXJzqc+mu00cI3icn9bV9flYCXLTIsprB21wVSMh0XeBGylKxeB
S27oDfFq04XSox7JM9HdTt2hLK96x1T7FpFrBTnALzb7vHv9MhXqAT90fPR/8A==
-----END CERTIFICATE-----"

# Iliadbox Root Certificate Authority (rootCA) :   --hardcoded-- 
# --> RSA (Iliadbox RSA Root CA): valid until 2040-11-22
# --> ECDSA (Iliadbox ECC Root CA): valid until 2040-11-22
ILIADBOX_DEFAULT_CACERT="-----BEGIN CERTIFICATE-----
MIICOjCCAcCgAwIBAgIUI0Tu7zsrBJACQIZgLMJobtbdNn4wCgYIKoZIzj0EAwIw
TDELMAkGA1UEBhMCSVQxDjAMBgNVBAgMBUl0YWx5MQ4wDAYDVQQKDAVJbGlhZDEd
MBsGA1UEAwwUSWxpYWRib3ggRUNDIFJvb3QgQ0EwHhcNMjAxMTI3MDkzODEzWhcN
NDAxMTIyMDkzODEzWjBMMQswCQYDVQQGEwJJVDEOMAwGA1UECAwFSXRhbHkxDjAM
BgNVBAoMBUlsaWFkMR0wGwYDVQQDDBRJbGlhZGJveCBFQ0MgUm9vdCBDQTB2MBAG
ByqGSM49AgEGBSuBBAAiA2IABMryJyb2loHNAioY8IztN5MI3UgbVHVP/vZwcnre
ZvJOyDvE4HJgIti5qmfswlnMzpNbwf/MkT+7HAU8jJoTorRm1wtAnQ9cWD3Ebv79
RPwtjjy3Bza3SgdVxmd6fWPUKaNjMGEwHQYDVR0OBBYEFDUij/4lpoJ+kOXRyrcM
jf2RPzOqMB8GA1UdIwQYMBaAFDUij/4lpoJ+kOXRyrcMjf2RPzOqMA8GA1UdEwEB
/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMAoGCCqGSM49BAMCA2gAMGUCMQC6eUV1
pFh4UpJOTc1JToztN4ttnQR6rIzxMZ6mNCe+nhjkohWp24pr7BpUYSbEizYCMAQ6
LCiBKV2j7QQGy7N1aBmdur17ZepYzR1YV0eI+Kd978aZggsmhjXENQYVTmm/XA==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIFiTCCA3GgAwIBAgIUTXoJE/kJnSKpxk5FjcmqmGah9zcwDQYJKoZIhvcNAQEL
BQAwTDELMAkGA1UEBhMCSVQxDjAMBgNVBAgMBUl0YWx5MQ4wDAYDVQQKDAVJbGlh
ZDEdMBsGA1UEAwwUSWxpYWRib3ggUlNBIFJvb3QgQ0EwHhcNMjAxMTI3MDkzODEy
WhcNNDAxMTIyMDkzODEyWjBMMQswCQYDVQQGEwJJVDEOMAwGA1UECAwFSXRhbHkx
DjAMBgNVBAoMBUlsaWFkMR0wGwYDVQQDDBRJbGlhZGJveCBSU0EgUm9vdCBDQTCC
AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANXKZSyCmix6jt7jUmaCP4XF
caF4azeYZuA8A4sWQmQXRWTDj8oNClE5w7zo5qUYzHIBOubKY7hhIU7RXYR5Bdny
arNRoo5ZBplgEkv3G00IgXY2/lCywPQ8WorAn0k/uaRce239r6EkGC3fxCA3Asnc
q9lNkUoWaf0GktJai0DuW7bNY8cq+vzZpy/36ey0LQ4OoehfiA6vlUTVWakpjecJ
ller1RfVlgEH26wnerGge3LYBZv27XiahCft54AQLxRY3H/z8XpKsPnJJrrhEvSo
2p64Bd+g7ZbzCdeakrypjVC/eWn14UzbcBVgh0p4F4990LuGxLVqyh6XcZOSSi01
4fpca5xPDCiohEX7ehMLpdURbhKzPj17IpwTmonfVmxkvV8rca1PqhDPEOouwPtc
M55eCgtwgSBeDznFKD7s+az/SZYC16GTgyXTCd2lId/J1unZ4pdzNVMAglTpnGgz
eQkHvfcVYdJj49tOtW0OpSPBiNIC6LCVY9wtH5dRMm0k+A8QDP+9HQaOs3LIUMwu
WGePw6r+eXUYw/2yO0z3zI/63hOpzZVixW+T7h3SY5B+sTrxR9fRD1oyk/rPV4I3
X5mZnyzSowjcN3+hSkGIZBleMO3CHaYleIf1/9HHhCJCVeeJ4kwEWY18Z0A+ohFh
D/dipgwmLCDH1/irDT4pAgMBAAGjYzBhMB0GA1UdDgQWBBTcW1RrTVIizaqkrkTI
CSw86qDJkTAfBgNVHSMEGDAWgBTcW1RrTVIizaqkrkTICSw86qDJkTAPBgNVHRMB
Af8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjANBgkqhkiG9w0BAQsFAAOCAgEAOfi6
fCuVLJD+vttO34cdB3i5hofmNrzgLh/spnwdm4y9EvvVqDvLdVLEIbvKf0QEcW0Y
dwP1BgmKwwHVv9YydHov8Jr4ANoGGXJnPLPcYDhRnixYEQmlTwSL/CLUcQ2hQWXx
Oc0k1jJB7uk6TPdX2YJyW4NpIcwI2sa5Dg/L8PqM0/pMYnMyG1hBwUc2M2qg3qTJ
zeiYT9zBHxS/JXA40yH4g9NzcFisVuYrfmINb11GmeqClm2OWehSdgdv9tEph3NW
ntJTENRrDvuj/pGZsnbofzgHNN6/nanymmrEPxG+xUGLIAW7zFndTKityhJ9FRqF
ultoZR2D19hh+n1277TSCPRJzUpq9rrfiqukjua3UjBzEvevnmSbLs1bXcNAxFYN
oZZ2euHoBv+E3BHjGik4RUkEJYtf5Xh+iffk4zTMfKBERn40fB7yF1xzxyoziltL
VxfueF9V6N7qjo5Ia7kiShXXsB+QdQdweuxWm1pPYmMbfTxNEqFUs3GhwEjzLaJc
cJOedwCT4ntbyCcTQaRlDL8QFjdE4gNm2ZaoG+gqGTLPS55H+ZvLsgUCiR5YY44N
G2Gkv4w/V/eB3eAvd5lgm6oOe8ehdr5JdpD6wnW2GOHs4SBdBo6yR+4RgEimNmgF
Yu11tlZsB2Iw/TT1EyPVb5z6tK4wUgWLNFAvjXU=
-----END CERTIFICATE-----"


###########################################################################################
## 
## CERTIFICATE and URL: Management - Policies - Bundle
## 
###########################################################################################


## Resetting CA certificate to null: "" when URL is null
[[ "$FREEBOX_LAN_URL" == "" ]]  && FREEBOX_LAN_CACERT=""
[[ "$FREEBOX_WAN_URL" == "" ]]  && FREEBOX_WAN_CACERT=""
[[ "$ILIADBOX_LAN_URL" == "" ]]  && ILIADBOX_LAN_CACERT=""
[[ "$ILIADBOX_WAN_URL" == "" ]]  && ILIADBOX_WAN_CACERT=""

# Resetting null path to real file path (/dev/null)
[[ "$FREEBOX_LAN_CACERT" == "" ]]  && FREEBOX_LAN_CACERT="/dev/null"
[[ "$FREEBOX_WAN_CACERT" == "" ]]  && FREEBOX_WAN_CACERT="/dev/null"
[[ "$ILIADBOX_LAN_CACERT" == "" ]]  && ILIADBOX_LAN_CACERT="/dev/null"
[[ "$ILIADBOX_WAN_CACERT" == "" ]]  && ILIADBOX_WAN_CACERT="/dev/null"


# Building a "Root CA certificate bundle" with all 3 Root CA certificate
# This bundle of CA certificate will be use to connect Freebox API
FREEBOX_CA_BUNDLE="$(sed '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/!d' $FREEBOX_WAN_CACERT)
$(sed '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/!d' $FREEBOX_LAN_CACERT)
${FREEBOX_DEFAULT_CACERT}"

ILIADBOX_CA_BUNDLE="$(sed '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/!d' $ILIADBOX_WAN_CACERT)
$(sed '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/!d' $ILIADBOX_LAN_CACERT)
${ILIADBOX_DEFAULT_CACERT}"


# FREEBOX_URL POLICY : 
# $FREEBOX_WAN_URL has precedence over $FREEBOX_LAN_URL
# $FREEBOX_LAN_URL has precedence over $FREEBOX_DEFAULT_URL 
# NB: Working the same way for ILIADBOX_URL

[[ ! -n $FREEBOX_LAN_URL ]] \
	&& FREEBOX_LAN_URL="$FREEBOX_DEFAULT_URL" \
	|| FREEBOX_LAN_URL="$FREEBOX_LAN_URL" 

[[ ! -n $FREEBOX_WAN_URL ]] \
	&& FREEBOX_URL="$FREEBOX_LAN_URL" \
	|| FREEBOX_URL="$FREEBOX_WAN_URL" 

[[ ! -n $ILIADBOX_LAN_URL ]] \
	&& ILIADBOX_LAN_URL="$ILIADBOX_DEFAULT_URL" \
	|| ILIADBOX_LAN_URL="$ILIADBOX_LAN_URL" 

[[ ! -n $ILIADBOX_WAN_URL ]] \
	&& ILIADBOX_URL="$ILIADBOX_LAN_URL" \
	|| ILIADBOX_URL="$ILIADBOX_WAN_URL" 


# Now to avoid changing more than 1000 lines of code, we will assume that if ITALY="yes"
# FREEBOX_URL=$ILIADBOX_URL  and FREEBOX_CACERT=$ILIADBOX_CA_BUNDLE

[[ "$ITALY" == "yes" ]] \
	&& FREEBOX_URL=$ILIADBOX_URL \
	&& FREEBOX_CA_BUNDLE=$ILIADBOX_CA_BUNDLE

[[ "$ITALY" == "yes" ]] \
        && BOX="ILIADBOX" \
        || BOX="FREEBOX" 


# Verifying that FREEBOX_CA_BUNDLE is a valid list of PEM certificate
# if yes: FREEBOX_CA_BUNDLE will be use to verify freebox domain name TLS certificate 
# if not: API librairy will fallback to insecure TLS /!\ no certificate check /!\
CAbdl=$(mktemp /dev/shm/fbx-ca-bundle.XXX)
echo -e "$FREEBOX_CA_BUNDLE" |grep -v ^$ > ${CAbdl}
is_cert=$(file ${CAbdl}|cut -d' ' -f2-)
#cat ${CAbdl}
rm -f ${CAbdl}
RED='\033[31m' && WHITE='\033[37m' && norm='\033[00m' 
[[ "${is_cert}" != "PEM certificate" ]] \
	&& echo -e "\n${WHITE}ERROR:\t ${RED}${BOX}_CA_BUNDLE is not a list of valid PEM CA certificate${norm}\n" \
	&& echo -e "${WHITE}WARNING: ${RED}fbx-delta-nba_bash_api.sh library will fallback to insecure TLS ! ${norm}\n" \
	&& FREEBOX_CACERT='' \
	|| FREEBOX_CACERT=$FREEBOX_CA_BUNDLE
#echo -e FREEBOX_CACERT="$FREEBOX_CACERT"  # debug
#echo -e FREEBOX_URL="$FREEBOX_URL"        # debug

# Soring FREEBOX_CACERT in a static variable
STORE_FREEBOX_CACERT=$FREEBOX_CACERT
unset CAbdl is_cert


## cleaning old CA BUNDLE FILE in shared memory
#del_bundle_cert_file fbx-cacert
## making new CA BUNDLE FILE in shared memory
#mk_bundle_cert_file fbx-cacert



###########################################################################################
## 
## Global variables needed for frontent function interraction from foreign program
## 
###########################################################################################

#######  FRONTEND INTERRACTION BETWEEN LIB AND PROGRAMM WHICH SOURCE THIS LIB  #######
# ${prog_cmd}  --> global - name of command which call - to be set by program which source this lib
# ${list_cmd}  --> global - name of listing command of frontend program which source this lib
# ex : prog_cmd="fbxvm-ctrl add dhcp"  listcmd="fbxvm-ctrl list dhcp"
# => output of function param_dhcp_err will say : 
# error in "fbxvm-ctrl add dhcp" instead of error in "param_download_err"


###########################################################################################
## 
## Static variables needed for fbx-delta-nba_bash_api.sh library - DO NOT MODIFY
## 
###########################################################################################

#######   COLOR    ########
red='\033[01;31m'
RED='\033[31m'
LRED='\033[91m'
blue='\033[01;34m'
BLUE='\033[34m'
green='\033[01;32m'
GREEN='\033[32m'
purpl='\033[01;35m'
PURPL='\033[35m'
WHITE='\033[37m'
LBLUE='\033[36m'
white='\033[01;37m'
norm='\033[00m'


#######  EXTENDED COLOR (256 COLORS) + 'SED ESC CHAR' ########
esc_sed="\x1B"
norm_sed="${esc_sed}[0m"
red_sed="${esc_sed}[31m"
lblue_sed="${esc_sed}[36m"
blue_sed="${esc_sed}[34m"
green_sed="${esc_sed}[32m"
purpl_sed="${esc_sed}[35m"
pink_sed="${esc_sed}[38;5;201m"
light_purple_sed="${esc_sed}[38;5;147m"


#######  STATIC  #######
# final values are fullfiled automatically by functions _check_freebox_api & login_freebox  
_API_VERSION="latest"
_API_BASE_URL="/api/"
_SESSION_TOKEN=""


######## GLOBAL VARIABLES ########
_JSON_DATA=
_JSON_DECODE_DATA_KEYS=
_JSON_DECODE_DATA_VALUES=

case "$OSTYPE" in
    darwin*) SED_REX='-E' ;;
    *) SED_REX='-r' ;;
esac

if echo "test string" | egrep -ao --color=never "test" &>/dev/null; then
    GREP='egrep -ao --color=never'
else
    GREP='egrep -ao'
fi



###########################################################################################
## 
## FUNCTIONS: Underlying and global function used by fbx-delta-nba_bash_api.sh library 
## 
###########################################################################################


######## FUNCTIONS ########

######## EXIT FUNTCION STACK WITHOUT KILLING BASH SHELL - replace exit() ########
# Function which tand like CTRL+C to exit the bash stack
ctrlc () {
kill -INT $$
}	


######## MAKE TMP CACERT FILE ########
# Function which create a CACERT bundle file in memory (/dev/shm)
# and set FREEBOX_CACERT=$CACERT_FILE
# (some programs cannot deal with variable contents and need regular certificate file !)
# USED in : _check_freebox_api call_freebox_api(2) add_freebox_api del_freebox_api
# USED in : update_freebox_api enc_dl_task_api add_dl_task_api call_freebox-ws_api 
# USED in : get_freebox_api local_direct_dl_api 
mk_bundle_cert_file () {
local CACERT_FILENAME=$1
local CACERT_FILE=/dev/shm/$CACERT_FILENAME
#echo -e "$FREEBOX_CACERT" |grep -v "^$" >$CACERT_FILE
echo -e "$STORE_FREEBOX_CACERT" |grep -v "^$" >$CACERT_FILE
FREEBOX_CACERT=$CACERT_FILE
#cat $FREEBOX_CACERT
}

######## DEL TMP CACERT FILE ########
# Function which delete CACERT file created in memory by function "mk_bundle_cert-file" 
# and rollback FREEBOX_CACERT value to FREEBOX_CA_BUNDLE
# USED in : _check_freebox_api call_freebox_api(2) add_freebox_api del_freebox_api
# USED in : update_freebox_api enc_dl_task_api add_dl_task_api call_freebox-ws_api 
# USED in : get_freebox_api local_direct_dl_api 
del_bundle_cert_file () {
local CACERT_FILENAME=$1
local CACERT_FILE=/dev/shm/$CACERT_FILENAME
rm -f $CACERT_FILE
FREEBOX_CACERT=$FREEBOX_CA_BUNDLE
}


####### NBA CHECK TOOL #######
# This function allows you to check if the required tools have been installed.
# As "websocat" was not in my distribution repository, if check_tool detect 
# that "websocat" should be installed, check_tool will also explane how to proceed
check_tool_exit () {
  cmd=$1
if ! command -v $cmd &>/dev/null
  then
    echo -e "\n${RED}$cmd${norm} could not be found. Please install ${RED}$cmd${norm}\n"
    [[ "$cmd" == "websocat" ]] && echo -e "${GREEN}websocat install on amd64/emt64${norm}    
$ curl -L https://github.com/vi/websocat/releases/download/v1.12.0/websocat.x86_64-unknown-linux-musl >websocat-1.12_x86_64
$ sudo cp websocat-1.12_x86_64 /usr/bin/websocat-1.12_x86_64
$ sudo ln -s /usr/bin/websocat-1.12_x86_64 /usr/bin/websocat
$ sudo chmod +x /usr/bin/websocat-1.12_x86_64

${GREEN}websocat install on arm64: aarch64${norm}
$ curl -L https://github.com/vi/websocat/releases/download/v1.12.0/websocat.aarch64-unknown-linux-musl >websocat-1.12_aarch64 
$ sudo cp websocat-1.12_aarch64 /usr/bin/websocat-1.12_aarch64
$ sudo ln -s /usr/bin/websocat-1.12_aarch64 /usr/bin/websocat
$ sudo chmod +x /usr/bin/websocat-1.12_aarch64
"
    error=1
    exit 31
fi
}

# adding this check_tool function which launch check_tool_exit in a bash subshell:
# this way 'exit 31' in check_tool_exit does not disconnect session when sourcing 
# fbx-delta-nba_bash_api.sh library in another program 
check_tool () {
bash -c "source ${BASH_SOURCE} && check_tool_exit $1"
}

####### NBA PRINT TERMINAL LINE #######
# terminal dash line (---) autoscale from terminal width or forced width by parameter
print_term_line () {
	local force_length=${1}
	local line=$(
	#for dash in `seq 1 $(($(stty -a <$(tty) | grep -Po '(?<=columns )\d+')-1))` 
	for dash in `seq 1 $(stty -a <$(tty) | grep -Po '(?<=columns )\d+')` 
        do 
                echo -ne "-"; ((dash++)); 
        done && echo
	)
	local line_force=$(
	for dash in `seq 1 ${force_length}`
	do 
                echo -ne "-"; ((dash++)); 
        done && echo	
	)
	[[ "${force_length}" != "" ]] \
		&& line=${line_force} \
		|| line=${line}
        echo -e "${line}"
}

####### NBA PROGRESSBAR #######
# Creating a progress bar

progress () {
    local width=$(stty -a <$(tty) | grep -Po '(?<=columns )\d+') 
    local w=$(($width-40)) p=$1;  shift
    # create a string of spaces, then change them to dots
    printf -v dots "%*s" "$(( $p*$w/100 ))" ""; dots=${dots// /.};
    # print those dots on a fixed-width space plus the percentage etc. 
    printf "\r\e[K|%-*s| %3d %% %s " "$w" "$dots" "$p" "$*"; 
}

# Configuring the progress bar
wrprogress () {
MSG=$1
SPEED=$2
while [ -d /proc/$! ]
do
        for x in {1..100}
        do
                progress "$x" ${MSG} ...
                sleep ${SPEED}
        done ; echo
done
}

######## END NBA PROGRESSBAR  ##########


######## FUNCTIONS FROM JSON.SH ########
# This is from https://github.com/dominictarr/JSON.sh
# See LICENSE for more info.

_throw () {
    echo "$*" >&2
    #exit 1
    return 1 && ctrlc
}

_throw_nba () {
# NBA 20230123: 
# modif to avoid terminal exit when sourcing lib and using function directly in cmdline
    bash -c "echo -e \"${RED}$*${norm}\" >&2 && exit 1"
    return 1

}

_tokenize_json () {
    local ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    local CHAR='[^[:cntrl:]"\\]'
    local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
    # The Freebox api don't put quote between string values
    # STRING2 solve this problem
    local STRING2="[^:,][a-zA-Z][a-zA-Z0-9_-]*[^],}]"
    local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
    local KEYWORD='null|false|true'
    local SPACE='[[:space:]]+'

    $GREP "$STRING|$STRING2|$NUMBER|$KEYWORD|$SPACE|." | egrep -v "^$SPACE$"
    # " Fix xemacs fontification
}

_parse_array () {
    local index=0
    local ary=''
    read -r token
    case "$token" in
        ']') ;;
        *)
           while : ; do
               _parse_value "${1%*.}" "[$index]."
               index=$((index+1))
               ary="$ary""$value"
               read -r token
               case "$token" in
                   ']') break ;;
                   ',') ary="$ary," ;;
                   *) _throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
               esac
               read -r token
           done
           ;;
    esac
    value=$(printf '[%s]' "$ary")
}

_parse_object () {
    local key
    local obj=''
    read -r token
    case "$token" in
        '}') ;;
        *)
           while : ; do
               case "$token" in
                   '"'*'"') key=$token;;
                   *) _throw "EXPECTED string GOT ${token:-EOF}" ;;
               esac
               read -r token
               case "$token" in
                   ':') ;;
                   *) _throw "EXPECTED : GOT ${token:-EOF}" ;;
               esac
               read -r token
               _parse_value "$1" "$key"
               obj="$obj$key:$value"
               read -r token
               case "$token" in
                   '}') break ;;
                   ',') obj="$obj," ;;
                   *) _throw "EXPECTED , or } GOT ${token:-EOF}" ;;
               esac
               read -r token
           done
           ;;
    esac
    value=$(printf '{%s}' "$obj")
}

_parse_value () {
    local jpath="${1:-}${2:-}"
    case "$token" in
        '{') _parse_object "$jpath" ;;
        '[') _parse_array  "$jpath";;
        # At this point, the only valid single-character tokens are digits.
        ''|[!0-9]) _throw "EXPECTED value GOT ${token:-EOF}" ;;
        *) value=$token ;;
    esac
    [ "${value:-}" = '' ] && return
    jpath=${jpath//\"\"/.}
    jpath=${jpath//\"/}
    local key="${jpath%*.}"
    [[ "$key" = '' ]] && return
    _JSON_DECODE_DATA_KEYS+=("$key")
    value=${value#\"}  # Remove leading "
    value=${value%*\"} # Remove trailing "
    value=${value//\\\///} # convert \/ to /
    _JSON_DECODE_DATA_VALUES+=("$value")
    # NBA  	
    #_JSON_NBA+=("${key}=${value}\n")
}

_parse_json () {
    read -r token
    _parse_value
    read -r token
    case "$token" in
        '') ;;
        *) _throw "EXPECTED EOF GOT $token" ;;
    esac
}

######## END OF FUNCTIONS FROM JSON.SH ########


###########################################################################################
## 
## FUNCTIONS: CORE and CALL function provided and used by fbx-delta-nba_bash_api.sh library 
## 
###########################################################################################


########  LIBRARY API CORE FUNCTIONS  #########

_parse_and_cache_json () {
    if [[ "$_JSON_DATA" != "$1" ]]; then
        _JSON_DATA="$1"
        _JSON_DECODE_DATA_KEYS=("")
        _JSON_DECODE_DATA_VALUES=("")
        _parse_json < <(echo "$_JSON_DATA" | _tokenize_json)
    fi
}


get_json_value_for_key () {
   # if [[ -x /usr/bin/jq ]]
   # then
   #         echo ${1} | jq -r ..${2} 
   # else
    _parse_and_cache_json "$1"
    local key i=1 max_index=${#_JSON_DECODE_DATA_KEYS[@]};
    while [[ $i -lt $max_index ]]; do
        if [[ "${_JSON_DECODE_DATA_KEYS[$i]}" = "$2" ]]; then
       	    echo ${_JSON_DECODE_DATA_VALUES[$i]}
       	    return 0
        fi
    ((i++))
    done
    return 1
    #fi
}


dump_json_keys_values () {
    _parse_and_cache_json "$1"
    local key i=1 max_index=${#_JSON_DECODE_DATA_KEYS[@]};
    while [[ $i -lt $max_index ]]; do
        printf "%s = %s\n" "${_JSON_DECODE_DATA_KEYS[$i]}" "${_JSON_DECODE_DATA_VALUES[$i]}"
        ((i++))
    done
}



# NBA: Original _check_success function: too slow
_check_success_old () {
    local value=$(get_json_value_for_key "$1" success)
    if [[ "$value" != true ]]; then
        echo "$(get_json_value_for_key "$1" msg): $(get_json_value_for_key "$1" error_code)" >&2
        return 1
    fi
    return 0
}

_check_success () {
    #  NBA  
    local val="${1}"
    local value=$(echo ${val} \
	    		|tr "," "\n" \
			|egrep success \
			|cut -d':' -f2 \
			|sed -e 's/,//g' -e 's/}\+//g'  
		)
    if [[ "$value" != true ]]
    then 
	    local msg=$(echo ${val} |tr "," "\n" |egrep msg |cut -d'"' -f4)
	    local error_code=$(echo ${val} |tr "," "\n" |egrep error_code |cut -d'"' -f4)
	    echo  -e "${RED}${msg}: ${error_code}" >&2 
	    return 1
    fi
    return 0
}

print_err () {
	# This function print error on stdout	
	_check_success "${answer}" || \
	(echo -e "${RED}${answer}${norm}" && return 1)
}

_check_freebox_api () {
    local options=("")
    mk_bundle_cert_file fbx-cacert                # create CACERT BUNDLE FILE
    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
            && options+=(--cacert "$FREEBOX_CACERT") \
            || options+=("-k")
    local answer=$(curl -s "${options[@]}" "$FREEBOX_URL/api_version")
    _API_VERSION=$(get_json_value_for_key "$answer" api_version | sed 's/\..*//')
    _API_BASE_URL=$(get_json_value_for_key "$answer" api_base_url)
    del_bundle_cert_file fbx-cacert               # remove CACERT BUNDLE FILE
}


########  LIBRARY API CALL FUNCTIONS  #########

# cleaning old & making new CA BUNDLE FILE in shared memory
# --> not used globally but used locally in CALL functions
#del_bundle_cert_file fbx-cacert
#mk_bundle_cert_file fbx-cacert


# simple API call using curl automatic GET or POST detection (simple POST)  
call_freebox_api () {
    local api_url="$1"
    local data="${2-}"
    local options=("")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$_SESSION_TOKEN" ]] && options+=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN")
    [[ -n "$data" ]] && options+=(-d "$data")
    mk_bundle_cert_file fbx-cacert                # create CACERT BUNDLE FILE
    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
	    && options+=(--cacert "$FREEBOX_CACERT") \
	    || options+=("-k")
    answer=$(curl -s "$url" "${options[@]}")
    #_check_success "$answer" || return 1
    _check_success "$answer" || ctrlc
    echo "$answer"
    del_bundle_cert_file fbx-cacert               # remove CACERT BUNDLE FILE
}

# simple API call using curl automatic GET or POST detection (including debug)  
call_freebox_api2 () {
    local api_url="$1"
    local data="${2-}"
    local options=("")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$_SESSION_TOKEN" ]] && options+=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN")
    [[ -n "$data" ]] && options+=(-d "$data")
    mk_bundle_cert_file fbx-cacert-callapi2                # create CACERT BUNDLE FILE
    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
            && options+=(--cacert "$FREEBOX_CACERT") \
            || options+=("-k")
    echo "curl -s \"$url\" \"${options[@]}\""
    #answer=$(curl --trace-ascii - -s "$url" "${options[@]}" 2>&1)
    answer=$(curl -s "$url" "${options[@]}")
    #_check_success "$answer" || return 1
    _check_success "$answer" || ctrlc
    echo "$answer"
    #echo "'curl -s \"$url\" \"${options[@]}\"'" >curlvar2 # debug
    del_bundle_cert_file fbx-cacert-callapi2               # remove CACERT BUNDLE FILE
}

# simple API call using curl forcing HTTP GET => '-d' options are passe as URL param :
# curl -s -G -d "onlyFolder=1" ${URL} <=> curl -s -X GET "${URL}?onlyFolder=1" 
get_freebox_api () {
    local api_url="$1"
    local data=("${@:2}")
    local dataget=("")
    local options=("")
    local param=""
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$_SESSION_TOKEN" ]] && options+=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN")
    [[ -n "$api_url" ]] && options+=(-G)
    [[ -n "$data" ]] \
	    && for param in ${data[@]} 
    	       	do 
	       	dataget+=(-d "${param}") 
	       	done
    mk_bundle_cert_file fbx-cacert                # create CACERT BUNDLE FILE
    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
	    && options+=(--cacert "$FREEBOX_CACERT") \
	    || options+=("-k")
	answer=$(curl -s "$url" "${options[@]}" ${dataget[@]})
    #_check_success "$answer" || return 1
    _check_success "$answer" || ctrlc
    echo "$answer"
    #echo "curl -s \"$url\" \"${options[@]}\" \"${dataget[@]}\"" >curlvarget # debug
    del_bundle_cert_file fbx-cacert               # remove CACERT BUNDLE FILE
}


# simple API call forcing HTTP PUT for content-type application/json  
update_freebox_api () {
    local api_url="$1"
    local data="${2}"
    local options=("")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$_SESSION_TOKEN" ]] \
	    && options+=(-H "Content-Type: application/json")\
	    && options+=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN")\
	    && options+=(-X PUT)
    mk_bundle_cert_file fbx-cacert                # create CACERT BUNDLE FILE
    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
            && options+=(--cacert "$FREEBOX_CACERT") \
            || options+=("-k")
    [[ -n "$data" ]] && options+=(-d "${data}")
    #echo -e "curl -s \"$url\" \"${options[@]}\"\n" # debug
    answer=$(curl -s "$url" "${options[@]}")
    #_check_success "$answer" || return 1
    _check_success "$answer" || ctrlc
    echo "$answer"
    del_bundle_cert_file fbx-cacert               # remove CACERT BUNDLE FILE
}

# simple API call forcing HTTP POST for content-type application/json  
add_freebox_api () {
    local api_url="$1"
    local data="${2}"
    local options=("")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$_SESSION_TOKEN" ]] \
	    && options+=(-H "Content-Type: application/json")\
	    && options+=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN")\
	    && options+=(-X POST)
    mk_bundle_cert_file fbx-cacert                # create CACERT BUNDLE FILE
    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
            && options+=(--cacert "$FREEBOX_CACERT") \
            || options+=("-k")	    
    [[ -n "$data" ]] && options+=(-d "${data}")
    echo -e "curl -s \"$url\" \"${options[@]}\"\n" # debug
    answer=$(curl -s "$url" "${options[@]}")
    #_check_success "$answer" || return 1
    _check_success "$answer" || ctrlc
    echo "$answer"
    del_bundle_cert_file fbx-cacert               # remove CACERT BUNDLE FILE
}

# simple API call forcing HTTP DELETE   
del_freebox_api () {
    local api_url="$1"
    local data="${2}"
    local options=("")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$_SESSION_TOKEN" ]] \
            && options+=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN")\
            && options+=(-X DELETE)
    mk_bundle_cert_file fbx-cacert                # create CACERT BUNDLE FILE
    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
            && options+=(--cacert "$FREEBOX_CACERT") \
            || options+=("-k")	    
    [[ -n "$data" ]] && options+=(-d "${data}")
    #echo -e "curl -s \"$url\" \"${options[@]}\"\n" # debug
    answer=$(curl -s "$url" "${options[@]}")
    #_check_success "$answer" || return 1
    _check_success "$answer" || ctrlc
    echo "$answer"
    del_bundle_cert_file fbx-cacert               # remove CACERT BUNDLE FILE
}



###########################################################################################
## 
##  LOGIN FUNCTIONS: library application api "login" and create authorized application
## 
###########################################################################################

# login to Freebox API / create session - original name: login_freebox() renamed login_fbx()  
login_fbx () {
    local APP_ID="$1"
    local APP_TOKEN="$2"
    local answer=

    answer=$(call_freebox_api 'login') || return 1
    #echo answer=$answer
    local challenge=$(get_json_value_for_key "$answer" "result.challenge")
    #echo challenge=$challenge
    [[ "$(openssl version |cut -d' ' -f2)" != "1.1.1n" ]] && \
    local password=$(echo -n "$challenge" | openssl dgst -sha1 -hmac "$APP_TOKEN" | sed  's/^SHA1(stdin)= //') || \
    local password=$(echo -n "$challenge" | openssl dgst -sha1 -hmac "$APP_TOKEN" | sed  's/^(stdin)= //')
    #echo password=$password
    answer=$(call_freebox_api '/login/session/' "{\"app_id\":\"${APP_ID}\", \"password\":\"${password}\" }") || return 1
    _SESSION_TOKEN=$(get_json_value_for_key "$answer" "result.session_token")
    #echo answer=$answer
}

# Login to Freebox API - copy of 'login_fbx' - For debugging purpose 
login_fbx2 () {
    local APP_ID="$1"
    local APP_TOKEN="$2"
    local answer=

    answer=$(call_freebox_api 'login') || return 1
    local challenge=$(get_json_value_for_key "$answer" "result.challenge")
    [[ "$(openssl version |cut -d' ' -f2)" != "1.1.1n" ]] && \
    local password=$(echo -n "$challenge" | openssl dgst -sha1 -hmac "$APP_TOKEN" | sed  's/^SHA1(stdin)= //') || \
    local password=$(echo -n "$challenge" | openssl dgst -sha1 -hmac "$APP_TOKEN" | sed  's/^(stdin)= //')
    #local password=$(echo -n "$challenge" | openssl dgst -sha1 -hmac "$APP_TOKEN" | sed  's/^(stdin)= //')
    answer=$(call_freebox_api '/login/session/' "{\"app_id\":\"${APP_ID}\", \"password\":\"${password}\" }") || return 1
    _SESSION_TOKEN=$(get_json_value_for_key "$answer" "result.session_token")
    echo -e "${answer}"    # debug
}

logout_freebox () {
	local answer=
        answer=$(add_freebox_api 'login/logout') 
	_check_success $answer \
		&& echo -e "${RED}Sucessfully logout from ${BOX,,} API !${norm}" \
		|| return 1
	#echo -e ${answer     # debug}
}	

# Login to Freebox API and export to subshell _APP_ID and _APP_ENCRYPTED_TOKEN (reused by library)
login_freebox () {
    local _MY_APP_ID="$1"
    local _MY_APP_TOKEN="$2"
    
    login_fbx "$_MY_APP_ID" "$_MY_APP_TOKEN"
    export _APP_ID=${_MY_APP_ID}
    export _APP_ENCRYPTED_TOKEN=$(echo ${_MY_APP_TOKEN}|openssl enc -base64 -e -aes-256-cbc -salt -pass pass:${_APP_PASSWORD} -pbkdf2)
}

# login an app automatically based on login_freebox exported variables _APP_ID and _APP_ENCRYPTED_TOKEN
# this function does not need you to pass APP_ID and APP_TOKEN again. It create the possibility 
# of autologin of the library after fist login and without calling it again with your APP_ID and APP_TOKEN
app_login_freebox () {
	local _MY_APP_ID=${_APP_ID}
	local _MY_APP_TOKEN=$(echo "${_APP_ENCRYPTED_TOKEN}"|openssl enc -base64 -d -aes-256-cbc -salt -pass pass:${_APP_PASSWORD} -pbkdf2)
	source ${BASH_SOURCE[0]}
	#echo -e "_MY_APP_TOKEN=$_MY_APP_TOKEN \n_MY_APP_ID=$_MY_APP_ID"  # debug
	login_freebox "$_MY_APP_ID" "$_MY_APP_TOKEN" || return 1
}

# check if currently logged-in 
check_login_freebox () {
    local answer=
    local session=

    answer=$(call_freebox_api 'login')
    session=$(get_json_value_for_key "$answer" "result.logged_in")
    [[ "${session}" == "true" ]] || return 1
}	

# relogin if session id disconnected
relogin_freebox () {
    check_login_freebox || app_login_freebox
}

# create application id and application token for login to Freebox API
authorize_application () {
    local APP_ID="$1"
    local APP_NAME="$2"
    local APP_VERSION="$3"
    local DEVICE_NAME="$4"
    local answer=

    answer=$(call_freebox_api 'login/authorize' "{\"app_id\":\"${APP_ID}\", \"app_name\":\"${APP_NAME}\", \"app_version\":\"${APP_VERSION}\", \"device_name\":\"${DEVICE_NAME}\" }")
    local app_token=$(get_json_value_for_key "$answer" "result.app_token")
    local track_id=$(get_json_value_for_key "$answer" "result.track_id")

    echo 'Please grant/deny access to the application on the Freebox LCD...' >&2
    local status='pending'
    while [[ "$status" == 'pending' ]]; do
      sleep 5
      answer=$(call_freebox_api "login/authorize/$track_id")
      status=$(get_json_value_for_key "$answer" "result.status")
    done
    echo "Authorization $status" >&2
    [[ "$status" != 'granted' ]] && return 1
    echo >&2
    cat <<EOF
MY_APP_ID="$APP_ID"
MY_APP_TOKEN="$app_token"
EOF
}


###########################################################################################
## 
## FRONTEND FUNCTIONS: library global frontend function for managing "output"
## 
###########################################################################################


####### NBA ADDING FUNCTION FOR FRONTEND OUTPUT


# colorize result (green = sucess ; red = failed) and print result json 
colorize_output () {
	local result=("${@}")
	#echo res=${result[@]}
	#echo $error
        [[ "${error}" != "1" ]] \
	&& echo ${result[@]} |grep -q '{"success":true' >/dev/null \
	&& echo -e "\n${WHITE}operation completed: \n${GREEN}$(echo ${result[@]}\
	|sed -e 's/true,/true}\\\n/' -e  's/"result":/\\\nresult:\\\n/' -e 's/\\//g' -e 's/}}$/}/g' \
	)${norm}\n" \
        || echo -e "\n${WHITE}operation failed ! \n${RED}${result[@]}${norm}\n" \
	|| return 1
}

# OK but dev in progress - print 'pretty json' output
colorize_output_pretty_json () {
        local result=("${@}")
        #echo res=${result[@]}
        #echo $error
        [[ "${error}" != "1" ]] \
        && echo ${result[@]} |grep -q '{"success":true' >/dev/null \
        && echo -e "\n${WHITE}operation completed: \n${norm}" \
	&& echo	-e "$(echo ${result[@]} \
        |sed -e 's/true,/true}\\\n/' -e  's/"result":/\\\nresult:\\\n/' -e 's/\\//g' -e 's/}}$/}/g'\
	|grep -Eo '"([^"\]*(\\")*(\\[^"])*)*" *(: *([0-9]*|"([^"\]*(\\")*(\\[^"])*)*")[^{}\["]*|,)?|[^"\]\[\}\{]*|\{|\},?|\[|\],?|[0-9]+ *,?|,' \
	| awk '{if ($0 ~ /^[]}]/ ) offset-=4; c=0; while (c++<offset) printf " "; printf "%s\n",$0; if ($0 ~ /^[[{]/) offset+=4}' \
	|xargs -0I @ echo "${GREEN}@${norm}" \
        )\n" \
        || echo -e "\n${WHITE}operation failed ! \n${RED}${result[@]}${norm}\n" \
        || return 1

	# NBA ORIG PRINT pretty-json :
	#|grep -Eo '"[^"]*" *(: *([0-9]*|"[^"]*")[^{}\["]*|,)?|[^"\]\[\}\{]*|\{|\},?|\[|\],?|[0-9 ]*,?' \
	#|awk '{if ($0 ~ /^[}\]]/ ) offset-=4; printf "%*c%s\n", offset, " ", $0; if ($0 ~ /^[{\[]/) offset+=4}' \
}




###########################################################################################
## 
## FRONTEND FUNCTIONS: library frontend function for managing "download API"
## 
###########################################################################################


####### ADDING FUNCTION FOR MANAGING DOWNLOAD TASKS API #######
# DONE --> missing check download params 
# DONE --> missing error messages + help 
# DONE --> missing list download tasks + start + stop + update (io_priority queue status)
# --> missing download task upload function (websocket, from device to freebox)
# --> missing monitor upload task function (websocket)
# --> missing downloads api configuration (speed limits ...) 
# --> missing support of bittorrent and newsgroups (.torrent & .nzb file) 


param_download_err () {
# when calling this function inside this lib, prog_cmd= and prog_list= must be null: ""    
# when calling this function from an external program, you must set 'prog_cmd' and 'list_cmd' values you use to call this function as a GLOBAL VARIABLES. ex : prog_cmd="fbxvm-ctrl add dhcp" list_cmd="fbxvm-ctrl add dl"
# ${action} parameter must be set by function which calling 'param_download_err' (or by primitive function) 
error=1
	[[ "${action}" == "add" \
	|| "${action}" == "upd" \
	|| "${action}" == "enc" \
	|| "${action}" == "show" \
	|| "${action}" == "del" ]] \
	&& local funct="${action}_dl_task_api"
	[[ "${action}" == "mon" ]] && local funct="monitor_dl_task_api"
	[[ "${action}" == "adv" ]] && local funct="monitor_dl_task_adv_api"
	[[ "${action}" == "log" ]] && local funct="dl_task_log_api"

[[ "${prog_cmd}" == "" ]] \
        && local progfunct=${funct} \
        || local progfunct=${prog_cmd} 
[[ "${list_cmd}" == "" ]] \
        && local listfunct="list_dl_task_api" \
        || local listfunct=${list_cmd} 


## add_dl_task_api param error ## NO encoding of parameters => NO interrest 
[[ "${action}" == "add" ]] \
&& echo -e "\nERROR: ${RED}all <param> for \"${progfunct}\" must be preceded by '--data-urlencode' and must be some of:${norm}${BLUE}|download_url= \t\t# URL to download|hash=\t\t\t# URL of hash file - hash format: MD5SUMS SHAxxxSUMS file or file.md5 or file.shaXXX |download_dir= \t\t# Download directory (will be created if not exist)|filename= \t\t# Name of downloaded file |recursive= \t\t# if set to 'true' download will be recursive|username= \t\t# (Optionnal) remote URL username |password= \t\t# (Optionnal) remote URL password |cookie1= \t\t# (Optionnal) content of HTTP Cookie header - to pass session cookie |cookie2= \t\t# (Optionnal) second HTTP cookie |cookie3= \t\t# (Optionnal) third HTTP cookie${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to create a download task: ${norm}\n${BLUE}download_url= ${norm}\n" \
&& echo -e "EXAMPLE (simple):\n${BLUE}${progfunct} --data-urlencode \"download_url=https://images.jeedom.com/freebox/freeboxDelta.qcow2\"${norm}\n" \
&& echo -e "EXAMPLE (medium):\n${BLUE}${progfunct} --data-urlencode \"download_url=https://images.jeedom.com/freebox/freeboxDelta.qcow2\" --data-urlencode \"hash=https://images.jeedom.com/freebox/SHA256SUMS\" --data-urlencode \"download_dir=/FBX24T/dl/vmimage/\" --data-urlencode \"filename=MyJedomDelta-efi-aarch64-nba0.qcow2\"${norm}\n" \
&& echo -e "EXAMPLE (full):\n${BLUE}${progfunct} --data-urlencode \"download_url=https://my-private-mirror.net/freebox/MyPrivateFreeboxVM_Image.qcow2\" --data-urlencode \"hash=https://my-private-mirror.net/freebox/MyPrivateFreeboxVM_Image.qcow2.sha512\" --data-urlencode \"download_dir=/FBX24T/dl/vmimage/\" --data-urlencode \"filename=MyNewVMimage-efi-aarch64.qcow2\" --data-urlencode \"username=MyUserName\" --data-urlencode \"password=VerySecret\" --data-urlencode \"recursive=false\" --data-urlencode cookie1=\"MyHTTPsessionCookie\" --data-urlencode cookie2=\"MyStickysessionCookie\" --data-urlencode cookie3=\"MyAuthTokenCookie\" ${norm}\n"  


# enc_dl_task_api param error
[[ "${action}" == "enc" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|download_url= \t\t# URL to download|hash=\t\t\t# URL of hash file - hash format: MD5SUMS SHAxxxSUMS file or file.md5 or file.shaXXX |download_dir= \t\t# Download directory (will be created if not exist)|filename= \t\t# Name of downloaded file |recursive= \t\t# if set to 'true' download will be recursive|username= \t\t# (Optionnal) remote URL username |password= \t\t# (Optionnal) remote URL password |cookie1= \t\t# (Optionnal) content of HTTP Cookie header - to pass session cookie |cookie2= \t\t# (Optionnal) second HTTP cookie |cookie3= \t\t# (Optionnal) third HTTP cookie${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to create a download task: ${norm}\n${BLUE}download_url= ${norm}\n" \
&& echo -e "EXAMPLE (simple):\n${BLUE}${progfunct} download_url=\"https://images.jeedom.com/freebox/freeboxDelta.qcow2\"${norm}\n" \
&& echo -e "EXAMPLE (medium):\n${BLUE}${progfunct} download_url=\"https://images.jeedom.com/freebox/freeboxDelta.qcow2\" hash=\"https://images.jeedom.com/freebox/SHA256SUMS\" download_dir=\"/FBX24T/dl/vmimage/\" filename=\"MyJedomDelta-efi-aarch64-nba0.qcow2\"${norm}\n" \
&& echo -e "EXAMPLE (full):\n${BLUE}${progfunct} download_url=\"https://my-private-mirror.net/freebox/MyPrivateFreeboxVM_Image.qcow2\" hash=\"https://my-private-mirror.net/freebox/MyPrivateFreeboxVM_Image.qcow2.sha512\" download_dir=\"/FBX24T/dl/vmimage/\" filename=\"MyNewVMimage-efi-aarch64.qcow2\" username=\"MyUserName\" password=\"VerySecret\" recursive=\"false\" cookie1=\"MyHTTPsessionCookie\" cookie2=\"MyStickysessionCookie\" cookie3=\"MyAuthTokenCookie\" ${norm}\n" 


# upd_dl_task_api param error
[[ "${action}" == "upd" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|id \t\t\t# Task id: MUST be a number|io_priority= \t\t# Disk IO priority: high normal or low|status= \t\t# Status action: stopped or downloading or queued or retry|queue_pos= \t\t# Task position in queue - 1= immediate download${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to update a download task: ${norm}\n${BLUE}id \nio_priority= or/and status= or/and queue_pos= ${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} 15 io_priority=\"high\" queue_pos=\"1\" status=\"retry\"${norm}\n" 


# del_dl_task_api param error
[[ "${action}" == "del" || "${action}" == "log" || "${action}" == "mon" || "${action}" == "adv" || "${action}" == "show" ]] \
&& echo -e "\nERROR: ${RED}<param> must be :${norm}${BLUE}|id${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}you can get a list of download tasks (showing all 'id'), just run: ${norm}\n${BLUE}${listfunct}${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} 53${norm}\n" 

unset prog_cmd list_cmd
return 1
}


check_and_feed_dl_param () {
        local param=("${@}")
        local nameparam=("")		idparam=0
        local valueparam=("")		numparam="$#"
	local download_url=""		p_download_url=""
	local hash=""			p_hash=""
	local download_dir=""		p_download_dir=""
	local filename=""		p_filename=""
	local recursive=""		p_recursive=""
	local username=""		p_username=""
	local password=""		p_password=""
	local cookie1=""		p_cookie1=""
	local cookie2=""		p_cookie2=""
	local cookie3=""		p_cookie3=""
	local id=""			p_id=""
	local state=""			p_state=""
	local qpos=""			p_qpos=""
	local io_priority=""		p_io_priority=""
        error=0
	dl_enc_param_object=("")
	dl_upd_param_object=("")
        [[ "$numparam" -lt "1" ]] && param_download_err

# checking param for 'enc_dl_task_api'
        [[ "$numparam" -ge "1" ]] && [[ "${action}" == "enc" ]] && [[ "${error}" != "1" ]] && \
        while [[ "${param[$idparam]}" != "" ]]
        do
                [[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "download_url" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "hash" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "download_dir" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "filename" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "recursive" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "cookie1" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "cookie2" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "cookie3" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "username" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "password" ]] \
                && param_download_err && break
                nameparam=$(echo "${param[$idparam]}"|cut -d= -f1)
                valueparam=$(echo -e "${param[$idparam]}"|cut -d= -f2-)
        [[ "${nameparam}" == "download_url" ]] && p_download_url="${nameparam}=" && download_url=${valueparam}
        [[ "${nameparam}" == "hash" ]] && p_hash="${nameparam}=" && hash=${valueparam}
        [[ "${nameparam}" == "download_dir" ]] && p_download_dir="${nameparam}=" && download_dir=${valueparam}
        [[ "${nameparam}" == "filename" ]] && p_filename="${nameparam}=" && filename=${valueparam}
        [[ "${nameparam}" == "recursive" ]] && p_recursive="${nameparam}=" && recursive=${valueparam}
        [[ "${nameparam}" == "cookie1" ]] && p_cookie1="${nameparam}=" && cookie1=${valueparam}
        [[ "${nameparam}" == "cookie2" ]] && p_cookie2="${nameparam}=" && cookie2=${valueparam}
        [[ "${nameparam}" == "cookie3" ]] && p_cookie3="${nameparam}=" && cookie3=${valueparam}
        [[ "${nameparam}" == "username" ]] && p_username="${nameparam}=" && username=${valueparam}
        [[ "${nameparam}" == "password" ]] && p_password="${nameparam}=" && password=${valueparam}
        ((idparam++))
        done


# checking param for 'upd_dl_task_api'
        [[ "$numparam" -ge "1" ]] && [[ "${action}" == "upd" ]] && [[ "${error}" != "1" ]] && \
        while [[ "${param[$idparam]}" != "" ]]
        do
                [[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "id" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "io_priority" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "queue_pos" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "status" ]] \
                && param_download_err && break
                nameparam[$idparam]=$(echo "${param[$idparam]}"|cut -d= -f1)
                valueparam[$idparam]=$(echo -e "${param[$idparam]}"|cut -d= -f2-)
        	[[ "${nameparam[$idparam]}" == "id" ]] \
			&& p_id="${nameparam[$idparam]}=" \
			&& id=${valueparam[$idparam]}
        	[[ "${nameparam[$idparam]}" == "io_priority" ]] \
			&& p_io_priority="${nameparam[$idparam]}=" \
			&& io_priority=${valueparam[$idparam]}
        	[[ "${nameparam[$idparam]}" == "queue_pos" ]] \
			&& p_qpos="${nameparam[$idparam]}=" \
			&& qpos=${valueparam[$idparam]}
        	[[ "${nameparam[$idparam]}" == "status" ]] \
			&& p_state="${nameparam[$idparam]}=" \
			&& state=${valueparam[$idparam]}
        ((idparam++))
        done

# building dl_enc_param_object
if [[ "${action}" == "enc" && "${error}" != "1" ]]
	then	
	[[ "${download_url}" == "" ]] && p_download_url=""
	[[ "${hash}" == "" ]] && p_hash=""
	[[ "${download_dir}" == "" ]] && p_download_dir="" || download_dir=$(echo -n ${download_dir}|base64)
	[[ "${filename}" == "" ]] && p_filename=""
	[[ "${recursive}" == "" ]] && p_recursive=""
	[[ "${cookie1}" == "" ]] && p_cookie1=""
	[[ "${cookie2}" == "" ]] && p_cookie2=""
	[[ "${cookie3}" == "" ]] && p_cookie3=""
	[[ "${username}" == "" ]] && p_username=""
	[[ "${password}" == "" ]] && p_password=""
	dl_enc_param_object=("${p_download_url}${download_url} ${p_hash}${hash} ${p_download_dir}${download_dir} ${p_filename}${filename} ${p_username}${username} ${p_password}${password} ${p_cookie1}${cookie1} ${p_cookie2}${cookie2} ${p_cookie3}${cookie3}")
	#echo -e  "dl_enc_param_object: ${dl_enc_param_object}"
fi

# building dl_upd_param_object
if [[ "${action}" == "upd" && "${error}" != "1" ]]
	then
	[[ "${io_priority}" == "" ]] && p_io_priority=""
	[[ "${qpos}" == "" ]] && p_qpos=""
	[[ "${state}" == "" ]] && p_state=""

	dl_upd_param_object=$(
		local idnameparam=0
                while [[ "${nameparam[$idnameparam]}" != "" ]]
                do
                        echo "\"${nameparam[$idnameparam]}\":\"${valueparam[$idnameparam]}\""
                ((idnameparam++))
		done | tr "\n" "," |sed -e 's@"@\"@g' -e 's@^@{@' -e 's@,$@}@' ) \
                || return 1

	#echo -e  "dl_upd_param_object: ${dl_upd_param_object}"  # debug
fi
}


# function which download a file from Freebox storage to computer running this function
local_direct_dl_api () {
    local api_url="dl"
    local file_fullpath="${1}"
    local filename=$(echo -n ${file_fullpath}|base64 -w0)
    local options=("")
    local extopts=("--progress-bar --output")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$filename" ]] \
	    && url="${url}/${filename}" \
	    && local file_target=$(echo ${file_fullpath}|grep -o '[^/]*$') \
	    || echo -e "\n${RED}file_fullpath parameters missing !${norm}"
    [[ -n "$_SESSION_TOKEN" ]] \
	    && options=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN") \
	    && options+=(-X GET)
    mk_bundle_cert_file fbx-cacert                # create CACERT BUNDLE FILE
    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
	    && options+=(--cacert "$FREEBOX_CACERT") \
	    || options+=("-k")
    [[ -n "$extopts" ]] || echo -e "\n${RED}extopts parameters missing !${norm}\n" 
    [[ -n "$file_fullpath" ]] || echo -e "\n${RED}you must provide /path/to/download/file on the cmdline !${norm}\n" 
if [[ -n "$file_fullpath" ]] 
then	
    # direct download from freebox to the computer which launch this function
    echo -e "\n${WHITE}Downloading file from Freebox to local directory:${norm}"
    echo -e "\n${PURPL}${file_fullpath}${norm} ---> ${GREEN}./${file_target}${norm}${WHITE}"
    curl "$url" "${options[@]}" ${extopts[@]} ${file_target}
    echo -e "\n${WHITE}Done: \n${GREEN}$(du -sh ${file_target}|cut -d' ' -f1)${norm}\n"
fi
    del_bundle_cert_file fbx-cacert               # remove CACERT BUNDLE FILE
}

# DEPRECATED # NO encoding of parameters => NO interrest 
# DO NOT USE # add a download task: No encoding => specify '--data-urlencode' before each params 
add_dl_task_api () {
    local api_url="downloads/add"
    local taskopt=("${@}")
    local options=("")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$_SESSION_TOKEN" ]] \
	    && options=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN") \
	    && options+=(-X POST)
    mk_bundle_cert_file fbx-cacert                # create CACERT BUNDLE FILE
    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
	    && options+=(--cacert "$FREEBOX_CACERT") \
	    || options+=("-k")
    [[ -n "$taskopt" ]] || echo -e "${RED}task parameters missing !${norm}" 
    error=0
    [[ "${#taskopt[@]}" -lt "2" ]] && action=add && param_download_err
    
    answer=$(curl -s "$url" "${options[@]}" ${taskopt[@]})
    _check_success "$answer" || return 1
    #echo "'echo -e "curl -s \"$url\" \"${options[@]}\" ${taskopt[@]}"'" >curlvar # debug
    echo -e "${answer}"
    del_bundle_cert_file fbx-cacert               # remove CACERT BUNDLE FILE
}

# list downloads tasks 
list_dl_task_api () {
	local dlid=${1}
        local api_url="downloads/${dlid}"
	local TYPE="LIST OF DOWNLOADS TASKS:"
        local p0="]"
        local status=""
	[[ "${action}" == "show" ]] && p0="" && TYPE="SHOW DOWNLOADS TASK: ${token}"
	#local answer=$(call_freebox_api  "/$api_url/" 2>&1)
	local answer=$(call_freebox_api  "/$api_url/" )
        local cache_result=("$(dump_json_keys_values "${answer}")")
	#echo -e "\n${white}\t\t\t\tLIST OF DOWNLOADS TASKS:${norm}\n"        
	echo -e "\n${white}\t\t\t\t\t${TYPE}${norm}\n"
        # When json reply is big (ex: recieve a lanHost object) we need to cache results 
        local id=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.id |cut -d' ' -f3))
        #local download_dir=($(echo -e "${cache_result[@]}" |egrep ${p0}.download_dir |cut -d' ' -f3))
        local eta=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.eta |cut -d' ' -f3))
        local status=($(echo -e "${cache_result[@]}"|egrep -v "}$"|egrep ${p0}.status |cut -d' ' -f3))
        local io_priority=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.io_priority |cut -d' ' -f3))
        local type=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.type |cut -d' ' -f3))
        local queue_pos=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.queue_pos |cut -d' ' -f3))
        local created_ts=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.created_ts |cut -d' ' -f3))
        local name=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.name |cut -d' ' -f3))
        local size=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.size |cut -d' ' -f3))
        local error=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.error |cut -d' ' -f3))
        local tx_pct=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.tx_pct |cut -d' ' -f3))
        local rx_pct=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.rx_pct |cut -d' ' -f3))
        local i=0 k=0 
	# if download_dir is null, forcing download_dir to [error:no_download_dir_availiable]
	local download_dir=("")
	local download_path=("$(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.download_dir)")
	local err=("$(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep result.error|cut -d' ' -f3)")
	if [[ "${action}" == "show" ]] 
	then	
		download_dir=("$(echo -e "${download_path[@]}" |egrep ${p0}.download_dir |cut -d' ' -f3)")
		[[ "${download_dir}" == "" ]] && \
		download_dir="${LBLUE}[error:no_download_dir_availiable]${norm}" 
		error=${err}
	else  while [[ $k != ${#id[@]} ]] 
        do
	download_dir[$k]=$(
	[[ -n $(echo -e "${download_path[@]}" | egrep -w "result\[$k\].download_dir" |cut -d' ' -f3) ]] \
		&& echo -e "${download_path[@]}" | egrep -w "result\[$k\].download_dir" |cut -d' ' -f3 \
	       	|| echo -e "${LBLUE}[error:no_download_dir_availiable]${norm}"
		)
        ((k++))
	done
	fi
	# writing 1 line of dashes (---) 
	print_term_line 120
	[[ ${id[$i]} == "" ]] && echo -e "\n${RED}No download tasks to list !${norm}\n"  
	while [[ ${id[$i]} != "" ]]
        do
                # decoding base64 path in ${download_dir[@]} array, date from epoch in ${created_ts[@]}...
		echo "${download_dir[$i]}" |grep -q '\[error:no_download_dir_availiable\]' || \
                download_dir[$i]=$(echo ${download_dir[$i]} |base64 -d)
                created_ts[$i]=$(date "+%Y%m%d-%H:%M:%S" -d@${created_ts[$i]})
		tx_pct[$i]=$(echo $((${tx_pct[$i]}/100)))
		rx_pct[$i]=$(echo $((${rx_pct[$i]}/100)))
                [[ "${status[$i]}" == "error" ]] \
			&& status[$i]="${RED}${status[$i]}\t" \
			|| status[$i]="${GREEN}${status[$i]}"
		#echo -e "status[$i]=${status[$i]}a"
                [[ "${status[$i]}" == "${GREEN}done" || "${status[$i]}" == "${GREEN}stopped" ]] \
			&& status[$i]="${status[$i]}\t" \
			|| status[$i]="${status[$i]}"
		#echo -e "status[$i]=${status[$i]}b"
                [[ "${error[$i]}" == "none" ]] \
			&& error[$i]="${GREEN}${error[$i]}" \
			|| error[$i]="${RED}${error[$i]}"
        	if [[ "${size[$i]}" -gt "1073741824" ]]
                then
                echo -e "${RED}id: ${id[$i]}${norm}\tqueue_pos: ${GREEN}${queue_pos[$i]}${norm}\t\ttimestamp: ${GREEN}${created_ts[$i]}${norm}\tsize: ${GREEN}$((${size[$i]}/1073741824)) GB${norm}\t%in: ${GREEN}${rx_pct[$i]} % ${norm}\t%out: ${GREEN}${tx_pct[$i]} %${norm}\n\tstatus: ${PURPL}${status[$i]}${norm}\tI/O: ${PURPL}${io_priority[$i]}${norm}\tpath: ${PURPL}${download_dir[$i]}${norm}\n\terror: ${PURPL}${error[$i]}${norm}\t\tend-in: ${GREEN}${eta[$i]}s${norm}\tname: ${PURPL}${name[$i]}${norm}"
                elif [[ "${size[$i]}" -gt "1048576" ]]
                then
                echo -e "${RED}id: ${id[$i]}${norm}\tqueue_pos: ${GREEN}${queue_pos[$i]}${norm}\t\ttimestamp: ${GREEN}${created_ts[$i]}${norm}\tsize: ${GREEN}$((${size[$i]}/1048576)) MB${norm}\t%in: ${GREEN}${rx_pct[$i]} % ${norm}\t%out: ${GREEN}${tx_pct[$i]} %${norm}\n\tstatus: ${PURPL}${status[$i]}${norm}\tI/O: ${PURPL}${io_priority[$i]}${norm}\tpath: ${PURPL}${download_dir[$i]}${norm}\n\terror: ${PURPL}${error[$i]}${norm}\t\tend-in: ${GREEN}${eta[$i]}s${norm}\tname: ${PURPL}${name[$i]}${norm}"
                else
                echo -e "${RED}id: ${id[$i]}${norm}\tqueue_pos: ${GREEN}${queue_pos[$i]}${norm}\t\ttimestamp: ${GREEN}${created_ts[$i]}${norm}\tsize: ${GREEN}${size[$i]} B${norm}\t%in: ${GREEN}${rx_pct[$i]} % ${norm}\t%out: ${GREEN}${tx_pct[$i]} %${norm}\n\tstatus: ${PURPL}${status[$i]}${norm}\tI/O: ${PURPL}${io_priority[$i]}${norm}\tpath: ${PURPL}${download_dir[$i]}${norm}\n\terror: ${PURPL}${error[$i]}${norm}\t\tend-in: ${GREEN}${eta[$i]}s${norm}\tname: ${PURPL}${name[$i]}${norm}"
                 fi
		 print_term_line 120
        ((i++))
        done || return 1
echo
}


# NBA : function which pretty print a particular share_link 
show_dl_task_api () {
        local id=${1}
        action=show
        error=0
        check_and_feed_dl_param "${@}" \
        && [[ "${error}" != "1" ]] \
        && list_dl_task_api ${id} 2>&1
        echo
        unset action
}


# function which add a download task and encode param in "www data urlencode" format
enc_dl_task_api () {
    local api_url="downloads/add"
    local taskopt=("${@}")
    local options=("")
    local opttask=("")
    local param=""
          action=enc
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    [[ -n "$_SESSION_TOKEN" ]] \
	    && options=(-H "X-Fbx-App-Auth: $_SESSION_TOKEN") \
	    && options+=(-X POST)
    mk_bundle_cert_file fbx-cacert                # create CACERT BUNDLE FILE
    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
	    && options+=(--cacert "$FREEBOX_CACERT") \
	    || options+=("-k")
    [[ -n "$taskopt" ]] || echo -e "${RED}task parameters missing !${norm}" 
	check_and_feed_dl_param ${taskopt[@]}
    	for param in ${dl_enc_param_object[@]}; 
    		do 
		opttask+=(--data-urlencode $param)
    	done		
	if [[ "$error" != "1" ]]
        then
		#echo curl -s "$url" "${options[@]}" ${opttask[@]}
    		answer=$(curl -s "$url" "${options[@]}" ${opttask[@]})
    		_check_success "$answer" || return 1
    		echo -e "${answer}"
	fi	
    del_bundle_cert_file fbx-cacert               # remove CACERT BUNDLE FILE
    unset action    
}


upd_dl_task_api () {
    local id=${1}
    local taskopt=("${@:2}")
    local upddl=""
    	  action=upd
    #[[ -n "$taskopt" ]] || echo -e "${RED}update download task parameters missing !${norm}" 
	check_and_feed_dl_param ${taskopt[@]}
        if [[ "$error" != "1" ]]
        then
		upddl=$(update_freebox_api /downloads/${id} "${dl_upd_param_object}" 2>&1)	
		colorize_output "${upddl}"
	fi
    unset action error
}





# monitor a download task - no dynamic output - for scripting 
monitor_dl_task_api () {
    local api_url="downloads"
    local task_id="$1"
    local status=""
    local state=""
    local percent="0"
    local speed="0"
    local rx="0"
    local eta="99"
    local size=""
    error=0
    action="mon" && [[ "$#" -ne "1" ]] && param_download_err
    [[ "${error}" != "1" ]] && \
    while [ "$status" != "done" ]; do
	relogin_freebox  # auto re-login if task is long and session is disconnected 
        answer=$(call_freebox_api "/$api_url/$task_id" )
        status=$(get_json_value_for_key "$answer" "result.status")
	[[ "$status" == "error" ]] \
	&& echo -e "${RED}task $task_id failed !${norm}" && break \
        ||echo -e "${GREEN}task $task_id $status $speed MB/s, $rx/${size}MB $percent% ... ${norm}"
                answer=$(call_freebox_api "/$api_url/$task_id" )
                speed=$(get_json_value_for_key "$answer" "result.rx_rate")
                speed=$(($speed/1024/1024))
                percent=$(get_json_value_for_key "$answer" "result.rx_pct")
                percent=$(($percent/100))
                rx=$(get_json_value_for_key "$answer" "result.rx_bytes")
                rx=$(($rx/1024/1024))
                size=$(get_json_value_for_key "$answer" "result.size")
                size=$(($size/1024/1024))

		[[ "$status" == "checking" ]] && sleep 2 && \
                [[ "$size" -gt "1000" ]] && \
		while [ "$eta" != "100" ]; do
			relogin_freebox  # auto re-login if session is disconnected due to long task 
                        answer=$(call_freebox_api "/$api_url/$task_id" )
			status=$(get_json_value_for_key "$answer" "result.status")
                        eta=$(get_json_value_for_key "$answer" "result.eta")
			[[ "$eta" -lt "0" || "$eta" -gt "100" ]] && eta=97
			eta=$((100-eta))
			sleep 2
			echo -e "${GREEN}task $task_id $status ${size}MB $eta% ... ${norm}"
  	        	[[ "$status" == "done" ]] &&  \
			echo -e "${GREEN}task $task_id $status !${norm}" && \
			break
		done	
		[[ "$status" == "done" ]] && break
        #echo
        sleep 2 
    done  || return 1
unset action
}

# monitor a download task - advanced dynamic output - for terminal use
monitor_dl_task_adv_api () {
    local api_url="downloads"
    local task_id="$1"
    local status=""
    local percent="0"
    local speed="0"
    local rx="0"
    local eta="99"
    local size=""
    error=0
    action="adv" && [[ "$#" -ne "1" ]] && param_download_err
    [[ "${error}" != "1" ]] && \
    while [ "$status" != "done" ]; do
	relogin_freebox  # auto re-login if session is disconnected due to long task 
        answer=$(call_freebox_api "/$api_url/$task_id" )
        status=$(get_json_value_for_key "$answer" "result.status")
	[[ "$status" == "error" ]] \
		&& echo -e "${RED}task $task_id failed !${norm}" && break \
	        ||echo -e "${GREEN}task $task_id $status ... ${norm}"
  	        [[ "$status" == "done" ]] && break
		while [ "$percent" != "100" ]; do
		      relogin_freebox  # auto re-login if session is disconnected due to long task 
		      answer=$(call_freebox_api "/$api_url/$task_id" )
	              speed=$(get_json_value_for_key "$answer" "result.rx_rate")
        	      speed=$(($speed/1024/1024))
		      percent=$(get_json_value_for_key "$answer" "result.rx_pct")
		      percent=$(($percent/100))
		      rx=$(get_json_value_for_key "$answer" "result.rx_bytes")
        	      rx=$(($rx/1024/1024))
        	      size=$(get_json_value_for_key "$answer" "result.size")
        	      size=$(($size/1024/1024))
		      #progress "$percent" "${status}" "$speed MB/s $rx/$size MB"
		      progress "$percent" "$speed MB/s $rx/${size}MB"
		      sleep .5
	        done
	        [[ "$status" == "checking" ]] && \
	        [[ "$size" -gt "1000" ]] && \
		while [ "$eta" != "100" ]; do
		        relogin_freebox  # auto re-login if session is disconnected due to long task 
			answer=$(call_freebox_api "/$api_url/$task_id" )
			eta=$(get_json_value_for_key "$answer" "result.eta")
			eta=$((100-eta))
			progress "$eta" "$status" "..." 
		        sleep .5
		done
        echo
        sleep 1 
    done  || return 1
unset action
}

# print download task log with error message if task_id or api_url empty 
dl_task_log_api () {
	  cl_info_sed="${light_purple_sed}"
	  cl_err_sed="${red_sed}"
    local api_url="downloads"
    local task_id="$1"
    error=0
    action="log" && [[ "$#" -ne "1" ]] && param_download_err
    if [[ "${error}" != "1" ]] 
    then	    
    echo -e "\n${WHITE}Download Task log: ${norm}${PURPL}task $task_id${norm}\n"
         answer=$(call_freebox_api  "/$api_url/$task_id/log" 2>&1)
	 answer=$(cut -d":" -f3- <(echo ${answer} |sed -e 's/"//g')) \
		 # Using sed to supress '"' and '\' and for colouring output on 'err:' and 'info:'
		 answer=$(echo -e "${answer}" | sed -e 's/"//g') \
		 && echo -e "${answer}"|grep -v '}'| sed -e 's/\\//g' -e  "s|err: .*$|${cl_err_sed}&${norm_sed}|" -e "s|info: .*$|${cl_info_sed}&${norm_sed}|" \
		 && echo || return 1 
		 #&& echo -e "${answer}"|grep -v '}'| sed -e 's/\\//g' -e  's|err: .*$|\x1B[31m&\x1B[0m|' -e 's|info: .*$|\x1B[38;5;201m&\x1B[0m|' \
    fi		 
unset action
}

# delete a download task 
del_dl_task_api () {
    local api_url="downloads"
    local task_id="$1"
    error=0
    action="del" && [[ "$#" -ne "1" ]] && param_download_err
    if [[ "${error}" != "1" ]]
    then
	 answer=$(del_freebox_api  "/$api_url/$task_id" 2>&1)
	 # Here we provide a final result (no work in progress) 
	 # => output is formated from lib   
         echo ${answer} |grep -q '{"success":true' >/dev/null \
         && echo -e "${WHITE}Sucessfully delete ${norm}${PURPL}task #${task_id}${norm}${WHITE}: ${GREEN}${answer}${norm}" \
        || echo -e "${WHITE}Error deleting ${norm}${PURPL}task #${task_id}${norm}${WHITE}: \n${RED}${answer}${norm}" 
    fi || return 1
unset action
}



###########################################################################################
## 
## FRONTEND FUNCTIONS: library frontend function for managing "filesystem API"
## 
###########################################################################################


####### ADDING FUNCTION FOR MANAGING FILESYSTEM TASKS API #######
# OK --> missing check filesystem params
# OK --> missing error messages + help 
# OK --> missing copy, move (rename), delete, compress, uncompress
# OK --> missing mkdir + recursive delete
# OK --> missing monitor filesystem task 


# list filesystem path: need 'path' argument, results cached in local array 
# optional arguments : onlyFolder=1 removeHidden=1
ls_fs () {
	local first_param="$1"
	#local sec_opts=("${@:2}")
	#local fs_file_path=$(echo -n "$1"|base64)
	#local fs_opts=("${@:2}")
	#if [[ "${first_param}" == "LWg=" || "${first_param}" == "LS1o"  || "${first_param}" == "LWhlbHA=" || "${first_param}" == "LS1oZWxw" ]] # -h or --h or --help in base64
	if [[ "${first_param}" == "-h" || "${first_param}" == "--h"  || "${first_param}" == "-help" || "${first_param}" == "--help" ]] 
	then
		echo -e "\n${WHITE}function param:\n\t\t -h /  -help\t\tprint this help\n\t\t--h / --help\t\tprint this help\n\n\t\tonlyFolder=1\t\tdo not display files BUT display only folder\n\t\tremoveHidden=1\t\tdo not display hidden files and folders\n${norm}"
		local help=1
	else	
		local fs_file_path=$(echo -n "$1"|base64)
		local fs_opts=("${@:2}")
		local help=0
	fi
	if [[ "${help}" == "0" ]]
	then       	
	#local answer=$(get_freebox_api "/fs/ls/${fs_file_path}" ${fs_opts[@]} 2>&1)
	local answer=$(get_freebox_api "/fs/ls/${fs_file_path}" ${fs_opts[@]} )
	local cache_result=("$(dump_json_keys_values "$answer")")
	local idx=(`echo -e "${cache_result[@]}" |egrep ].index |cut -d' ' -f3`)
	local name=(`echo -e "${cache_result[@]}" |egrep ].name |cut -d' ' -f3- |sed -e 's/ /IA==/g'`)
	local type=(`echo -e "${cache_result[@]}" |egrep ].type |cut -d' ' -f3`)
	local size=(`echo -e "${cache_result[@]}" |egrep ].size |cut -d' ' -f3`)
	local modification=(`echo -e "${cache_result[@]}" |egrep ].modification |cut -d' ' -f3`)
	local hidden=(`echo -e "${cache_result[@]}" |egrep ].hidden |cut -d' ' -f3`)
	#local mimetype=(`dump_json_keys_values ${answer} |egrep ].mimetype |cut -d' ' -f3`)

	local i=0
	while [[ "${name[$i]}" != "" ]];
	do
		if [[ "${idx[$i]}" -ge "0" && "${idx[$i]}" -lt "10" ]] 
		then
			[[ "${hidden[$i]}" == "true" ]] && hidden[$i]="  hidden" || hidden[$i]="\t"		
		elif [[ "${idx[$i]}" -ge "10" && "${idx[$i]}" -lt "100" ]]
		then
			[[ "${hidden[$i]}" == "true" ]] && hidden[$i]=" hidden" || hidden[$i]="\t"
		elif [[ "${idx[$i]}" -ge "100" && "${idx[$i]}" -lt "1000" ]]
		then
			[[ "${hidden[$i]}" == "true" ]] && hidden[$i]="hidden" || hidden[$i]="\t"
		fi
                modification[$i]=$(date "+%Y%m%d-%H:%M:%S" -d@${modification[$i]})
		if [[ "${size[$i]}" -gt "1099511627776" ]]
                then
echo -e "${RED}idx: ${idx[$i]}${norm}  ${WHITE}${hidden[$i]}${norm}  ${GREEN}${type[$i]}${norm}\t${modification[$i]}${norm}\tsize: ${PURPL}$((${size[$i]}/1099511627776)) TB${norm}\tname: ${GREEN}${name[$i]//'IA=='/ }${norm}"
		elif [[ "${size[$i]}" -gt "1073741824" ]]
                then
echo -e "${RED}idx: ${idx[$i]}${norm}  ${WHITE}${hidden[$i]}${norm}  ${GREEN}${type[$i]}${norm}\t${modification[$i]}${norm}\tsize: ${PURPL}$((${size[$i]}/1073741824)) GB${norm}\tname: ${GREEN}${name[$i]//'IA=='/ }${norm}"
                elif [[ "${size[$i]}" -gt "1048576" ]]
		then
echo -e "${RED}idx: ${idx[$i]}${norm}  ${WHITE}${hidden[$i]}${norm}  ${GREEN}${type[$i]}${norm}\t${modification[$i]}${norm}\tsize: ${PURPL}$((${size[$i]}/1048576)) MB${norm}\tname: ${GREEN}${name[$i]//'IA=='/ }${norm}"
                elif [[ "${size[$i]}" -gt "1024" ]]
		then
echo -e "${RED}idx: ${idx[$i]}${norm}  ${WHITE}${hidden[$i]}${norm}  ${GREEN}${type[$i]}${norm}\t${modification[$i]}${norm}\tsize: ${PURPL}$((${size[$i]}/1024)) KB${norm}\tname: ${GREEN}${name[$i]//'IA=='/ }${norm}"
                else
echo -e "${RED}idx: ${idx[$i]}${norm}  ${WHITE}${hidden[$i]}${norm}  ${GREEN}${type[$i]}${norm}\t${modification[$i]}${norm}\tsize: ${PURPL}${size[$i]} B${norm}\tname: ${GREEN}${name[$i]//'IA=='/ }${norm}"
                 fi
                ((i++))

	done 
	fi|| return 1
}

# DEPRECATED : original fs listing function: usage aborted for performance issue
# DO NOT USE : "list_fs_file();" --> performance issue due to the design of the function
# PLEASE USE : "ls_fs();" function instead

# NBA 20230122: for better performances caching json results in env
# NBA 20230122: from today, speed became "acceptable"

list_fs_file () {

	local first_param="$1"
	if [[ "${first_param}" == "-h" || "${first_param}" == "--h"  || "${first_param}" == "-help" || "${first_param}" == "--help" ]] 
	then
		echo -e "\n${WHITE}function param:\n\t\t -h /  -help\t\tprint this help\n\t\t--h / --help\t\tprint this help\n\n\t\tonlyFolder=1\t\tdo not display files BUT display only folder\n\t\tremoveHidden=1\t\tdo not display hidden files and folders\n${norm}"
		local help=1
	else	
		local fs_file_path=$(echo -n "$1"|base64)
		local fs_opts=("${@:2}")
		local help=0
	fi

	if [[ "${help}" == "0" ]]
	then       	
        echo -e "\n${WHITE}LIST CONTENT IN : ${1}  ${norm}\n"
	#local answer=$(get_freebox_api "/fs/ls/${fs_file_path}" ${fs_opts[@]} 2>&1)
	local answer=$(get_freebox_api "/fs/ls/${fs_file_path}" ${fs_opts[@]} )

	# NBA 20230122: caching json results in env to avoid performance issue
	dump_json_keys_values "$answer" >/dev/null

	local i=0 #j=0
        while [[ $(get_json_value_for_key "$answer" "result[$i].name") != "" ]]
                do
                        local type=$(get_json_value_for_key "$answer" "result[$i].type")
                        local index=$(get_json_value_for_key "$answer" "result[$i].index")
                        local link=$(get_json_value_for_key "$answer" "result[$i].link")
                        local modification=$(get_json_value_for_key "$answer" "result[$i].modification")
                        local hidden=$(get_json_value_for_key "$answer" "result[$i].hidden")
                        local mimetype=$(get_json_value_for_key "$answer" "result[$i].mimetype")
                        local name=$(get_json_value_for_key "$answer" "result[$i].name")
                        local size=$(get_json_value_for_key "$answer" "result[$i].size")
			modification=$(date "+%Y%m%d-%H:%M:%S" -d@${modification})
		#	[[ "$hidden" == "true" ]] && hidden=hidden || hidden=''
			if [[ "${index}" -ge "0" && "${index}" -lt "10" ]] 
			then
				[[ "${hidden}" == "true" ]] && hidden="  hidden" || hidden="\t"		
			elif [[ "${index}" -ge "10" && "${index}" -lt "100" ]]
			then
				[[ "${hidden}" == "true" ]] && hidden=" hidden" || hidden="\t"
			elif [[ "${index}" -ge "100" && "${index}" -lt "1000" ]]
			then
				[[ "${hidden}" == "true" ]] && hidden="hidden" || hidden="\t"
			fi
			#nc=$(echo -n "$name"|wc -m)
	                #[[ "$nc" == "1" ]] && name="${name}\t\t\t\t\t"
        	        #[[ "$nc" -gt "1" && "$nc" -lt "10" ]] && name="${name}\t\t\t\t"
        	      	#[[ "$nc" -gt "9" && "$nc" -lt "17" ]] && name="${name}\t\t\t"
        	        #[[ "$nc" -gt "16" && "$nc" -lt "26" ]] && name="${name}\t\t"
        	        #[[ "$nc" -gt "25" && "$nc" -lt "33" ]] && name="${name}\t"
     		        #[[ "$nc" -gt "32" ]] && name[$i]="${name[$i]}"

			if [[ "$size" -gt "1099511627776" ]] 
				then 
echo -e "${RED}idx: ${index}${norm}  ${WHITE}${hidden}${norm}  ${GREEN}${type}${norm}\t${modification}${norm}\tsize: ${PURPL}$((${size}/1099511627776)) TB${norm}\tname: ${GREEN}${name}${norm}"
			elif [[ "$size" -gt "1073741824" ]] 
				then 
echo -e "${RED}idx: ${index}${norm}  ${WHITE}${hidden}${norm}  ${GREEN}${type}${norm}\t${modification}${norm}\tsize: ${PURPL}$((${size}/1073741824)) GB${norm}\tname: ${GREEN}${name}${norm}"
			elif [[ "$size" -gt "1048576" ]] 
				then 
echo -e "${RED}idx: ${index}${norm}  ${WHITE}${hidden}${norm}  ${GREEN}${type}${norm}\t${modification}${norm}\tsize: ${PURPL}$((${size}/1048576)) MB${norm}\tname: ${GREEN}${name}${norm}"
			elif [[ "$size" -gt "1024" ]] 
				then 
echo -e "${RED}idx: ${index}${norm}  ${WHITE}${hidden}${norm}  ${GREEN}${type}${norm}\t${modification}${norm}\tsize: ${PURPL}$((${size}/1024)) KB${norm}\tname: ${GREEN}${name}${norm}"
				else
echo -e "${RED}idx: ${index}${norm}  ${WHITE}${hidden}${norm}  ${GREEN}${type}${norm}\t${modification}${norm}\tsize: ${PURPL}${size} B ${norm}\tname: ${GREEN}${name}${norm}"
                                fi
                ((i++))
                done 
		fi|| return 1
	echo
}

list_fs_task_api () {
	# This function provide a pretty list of all filesystem tasks 
	# if "${action}=show" and you pass a task id as $1 argument, only task with this id will be shawn
        # function show_fs_task call does this job
    local api_url="fs/tasks/${tskid}"
    local TYPE="LIST OF FILESYSTEM TASKS:"
    local p0="]"
    local p1=""
    local tskid="$1"  
    [[ "${action}" == "show" ]] && p0="" && p1='egrep -v "}$"' && TYPE="SHOW FILESYSTEM TASK: ${tskid}" 
        #local answer=$(call_freebox_api  "/$api_url/" 2>&1)
        local answer=$(call_freebox_api  "/$api_url/")
        local cache_result=("$(dump_json_keys_values "${answer}")")
        echo -e "\n${white}\t\t\t\t\t${TYPE}${norm}\n"        
        # When json reply is big (ex: recieve a collection of lanHost object) we need to cache results 
        local id=($(echo -e "${cache_result[@]}" |egrep -v "}$|invalid"|egrep  ${p0}.id |cut -d' ' -f3))
        local eta=($(echo -e "${cache_result[@]}" |egrep ${p0}.eta |cut -d' ' -f3))
        local duration=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.duration |cut -d' ' -f3))
        local started_ts=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.started_ts |cut -d' ' -f3))
        local done_ts=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.done_ts |cut -d' ' -f3))
        local type=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.type |cut -d' ' -f3))
        local progress=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.progress |cut -d' ' -f3))
        local total_bytes=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.total_bytes |cut -d' ' -f3))
        local total_bytes_done=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.total_bytes_done |cut -d' ' -f3))
        #local nfiles_done=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ].nfiles_done |cut -d' ' -f3))
        local nfiles=($(echo -e "${cache_result[@]}"|egrep -v "}$"|egrep ${p0}.nfiles |cut -d' ' -f3))
        local state=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.state |cut -d' ' -f3))
        local error=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.error |cut -d' ' -f3))
	# feeding values in array for from, to and dst when when values is null 
	local i=0 k=0 
	local to=("") from=("") dst=("")
	local to_orig=("$(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.to |egrep -v ${p0}.total)")
	local from_orig=("$(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.from)")
	local dst_orig=("$(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.dst)")
	if [[ "${action}" == "show" ]] 
	then
		to=("$(echo -e "${to_orig[@]}" |egrep -v "}$"|egrep ${p0}.to |cut -d' ' -f3-)") 
		[[ "$to" == "" ]] && to="${BLUE}[t:empty_value]" 
		#if [[ "$to" == "" ]]; then to="${BLUE}[t:empty_value]"; fi 
		from=("$(echo -e "${from_orig[@]}" |egrep -v "}$"|egrep ${p0}.from |cut -d' ' -f3-)") 
		[[ "$from" == "" ]] && from="${BLUE}[f:empty_value]" 
		dst=("$(echo -e "${dst_orig[@]}" |egrep -v "}$"|egrep ${p0}.dst |cut -d' ' -f3-)") 
		[[ "$dst" == "" ]] && dst="${BLUE}[d:empty_value]" 
	else while [[ $k != ${#id[@]} ]] 
        do
	to[$k]=$(
	[[ -n $(echo -e "${to_orig[@]}" | egrep -w "result\[$k\].to" |cut -d' ' -f3-) ]] \
                && echo -e "${to_orig[@]}" | egrep -w "result\[$k\].to" |cut -d' ' -f3- \
                || echo -e "${BLUE}[t:empty_value]"
                )
	from[$k]=$(
	[[ -n $(echo -e "${from_orig[@]}" | egrep -w "result\[$k\].from" |cut -d' ' -f3-) ]] \
                && echo -e "${from_orig[@]}" | egrep -w "result\[$k\].from" |cut -d' ' -f3- \
                || echo -e "${BLUE}[f:empty_value]"
                )
	dst[$k]=$(
	[[ -n $(echo -e "${dst_orig[@]}" | egrep -w "result\[$k\].dst" |cut -d' ' -f3-) ]] \
                && echo -e "${dst_orig[@]}" | egrep -w "result\[$k\].dst" |cut -d' ' -f3- \
                || echo -e "${BLUE}[d:empty_value]"
                )
        ((k++))
        done
	fi
        # writing 1 line of dashes (---) 
	print_term_line 120
        [[ ${id[$i]} == "" ]] && echo -e "\n${RED}No filesystem tasks to list !${norm}\n"  
        while [[ ${id[$i]} != "" ]]
        do
                started_ts[$i]=$(date "+%Y%m%d-%H:%M:%S" -d@${started_ts[$i]})
		done_ts[$i]=$(date "+%Y%m%d-%H:%M:%S" -d@${done_ts[$i]})
                [[ "${state[$i]}" == "error" \
			|| "${state[$i]}" == "failed"  \
			|| "${state[$i]}" == "running" ]] \
                        && state[$i]="${RED}${state[$i]}\t" \
                        || state[$i]="${GREEN}${state[$i]}"
                [[ "${state[$i]}" == "${GREEN}done" || "${state[$i]}" == "${GREEN}queued" || "${state[$i]}" == "${GREEN}paused" || "${state[$i]}" == "${RED}running" ]] \
                        && state[$i]="${state[$i]}\t\t" \
                        || state[$i]="${state[$i]}\t"
                [[ "${error[$i]}" == "none" ]] \
                        && error[$i]="${GREEN}${error[$i]}\t\t" \
                        || error[$i]="${RED}${error[$i]}\t"
		[[ "${error[$i]}" == "${RED}archive_open_failed\t" ]] \
			&& error[$i]="${RED}archive_open_failed"
                [[ "${type[$i]}" == "cp" || "${type[$i]}" == "mv" || "${type[$i]}" == "rm" || "${type[$i]}" == "hash" ]] \
                        && type[$i]="${type[$i]}\t" \
                        || type[$i]="${type[$i]}"
                if [[ "${total_bytes_done[$i]}" -gt "10737418240" ]]
		then
                echo -e "${RED}id: ${id[$i]}${norm}\tstart: ${GREEN}${started_ts[$i]}${norm}\tend: ${GREEN}${done_ts[$i]}${norm}\t%progress: ${LBLUE}${progress[$i]} %  ${norm}\tsize: ${GREEN}$((${total_bytes_done[$i]}/1073741824)) GB${norm}\n\tstatus: ${PURPL}${state[$i]}${norm}\ttime: ${GREEN}${duration[$i]}s${norm}\t\tfrom: ${PURPL}${from[$i]}${norm}\n\terror: ${PURPL}${error[$i]}${norm}\tend-in: ${GREEN}${eta[$i]}s${norm}\t\tto:   ${PURPL}${to[$i]}${norm}\n\ttask type: ${LBLUE}${type[$i]}${norm}\t\t#files: ${GREEN}${nfiles[$i]} ${norm}\t\tdst:  ${PURPL}${dst[$i]}${norm}"
		elif [[ "${total_bytes_done[$i]}" -gt "10485760" ]]
		then
                echo -e "${RED}id: ${id[$i]}${norm}\tstart: ${GREEN}${started_ts[$i]}${norm}\tend: ${GREEN}${done_ts[$i]}${norm}\t%progress: ${LBLUE}${progress[$i]} %  ${norm}\tsize: ${GREEN}$((${total_bytes_done[$i]}/1048576)) MB${norm}\n\tstatus: ${PURPL}${state[$i]}${norm}\ttime: ${GREEN}${duration[$i]}s${norm}\t\tfrom: ${PURPL}${from[$i]}${norm}\n\terror: ${PURPL}${error[$i]}${norm}\tend-in: ${GREEN}${eta[$i]}s${norm}\t\tto:   ${PURPL}${to[$i]}${norm}\n\ttask type: ${LBLUE}${type[$i]}${norm}\t\t#files: ${GREEN}${nfiles[$i]} ${norm}\t\tdst:  ${PURPL}${dst[$i]}${norm}"
		elif [[ "${total_bytes_done[$i]}" -gt "10240" ]]
		then
                echo -e "${RED}id: ${id[$i]}${norm}\tstart: ${GREEN}${started_ts[$i]}${norm}\tend: ${GREEN}${done_ts[$i]}${norm}\t%progress: ${LBLUE}${progress[$i]} %  ${norm}\tsize: ${GREEN}$((${total_bytes_done[$i]}/1024)) KB${norm}\n\tstatus: ${PURPL}${state[$i]}${norm}\ttime: ${GREEN}${duration[$i]}s${norm}\t\tfrom: ${PURPL}${from[$i]}${norm}\n\terror: ${PURPL}${error[$i]}${norm}\tend-in: ${GREEN}${eta[$i]}s${norm}\t\tto:   ${PURPL}${to[$i]}${norm}\n\ttask type: ${LBLUE}${type[$i]}${norm}\t\t#files: ${GREEN}${nfiles[$i]} ${norm}\t\tdst:  ${PURPL}${dst[$i]}${norm}"
		else
                echo -e "${RED}id: ${id[$i]}${norm}\tstart: ${GREEN}${started_ts[$i]}${norm}\tend: ${GREEN}${done_ts[$i]}${norm}\t%progress: ${LBLUE}${progress[$i]} %  ${norm}\tsize: ${GREEN}${total_bytes_done[$i]} B ${norm}\n\tstatus: ${PURPL}${state[$i]}${norm}\ttime: ${GREEN}${duration[$i]}s${norm}\t\tfrom: ${PURPL}${from[$i]}${norm}\n\terror: ${PURPL}${error[$i]}${norm}\tend-in: ${GREEN}${eta[$i]}s${norm}\t\tto:   ${PURPL}${to[$i]}${norm}\n\ttask type: ${LBLUE}${type[$i]}${norm}\t\t#files: ${GREEN}${nfiles[$i]} ${norm}\t\tdst:  ${PURPL}${dst[$i]}${norm}"
		fi
		print_term_line 120
	((i++))
	done|| return 1
echo
}


param_fs_task_err () {
# when calling this function inside this lib, prog_cmd= and prog_list= must be null: ""    
# when calling this function from an external program, you must set 'prog_cmd' and 'list_cmd' values you use to call this function as a GLOBAL VARIABLES. ex : prog_cmd="fbxvm-ctrl modify fstask" list_cmd="fbxvm-ctrl list fstask"
# ${action} parameter must be set by function which calling 'param_fs_task_err' (or by primitive function)	
error=1
        [[ "${action}" == "hash" \
        || "${action}" == "get" \
        || "${action}" == "show" \
        || "${action}" == "mon" \
        || "${action}" == "upd" \
        || "${action}" == "del" ]] \
	&& local funct="${action}_fs_task"

[[ "${prog_cmd}" == "" ]] \
        && local progfunct=${funct} \
        || local progfunct=${prog_cmd}
[[ "${list_cmd}" == "" ]] \
        && local listfunct="list_fs_task_api" \
        || local listfunct=${list_cmd}

# upd_fs_tasks param error
[[ "${action}" == "upd" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|id \t\t\t# Task id: MUST be a number|state= \t\t\t# Status action: paused or running ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to update a download task: ${norm}\n${BLUE}id |state= ${norm}\n" |tr "|" "\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} 215 state=\"paused\" ${norm}\n" 

# del_dl_tasks get_fs_tasks mon_fs_tasks show_fs_task and hash_fs_tasks param error
[[ "${action}" == "del" \
	|| "${action}" == "get" \
	|| "${action}" == "show" \
	|| "${action}" == "hash" \
	|| "${action}" == "mon" ]] \
&& echo -e "\nERROR: ${RED}<param> must be :${norm}${BLUE}|id${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}you can get a list of filesystem tasks (showing all 'id'), just run: ${norm}\n${BLUE}${listfunct}${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} 215 ${norm}\n" 

unset prog_cmd list_cmd
return 1
}


check_and_feed_fs_task_param () {
        local param=("${@}")		opt=${2}
        local nameparam=("")            id=${1}
        local valueparam=("")           numparam="$#"
        local action=${action}                  
        error=0
        fs_task_param_object=("")
        [[ "$numparam" -lt "1" ]] && param_fs_task_err

# checking param for 'fs tasks api': first param must be a number 

if [[ "$numparam" -ge "1" ]] && [[ "${error}" != "1" ]] 
then
	[[ ${id} =~ ^[[:digit:]]+$ ]] || param_fs_task_err
fi
# update action take 'state=' parameter	
if [[ "$numparam" -ge "1" ]] && [[ "${error}" != "1" ]] 
then	
        if [[ "${action}" == "upd" ]]
        then
		if [[ "$#" -lt "2" || "$(echo ${opt}|cut -d= -f1)" != "state" ]]			
		then
			param_fs_task_err && break
		else
			nameparam=$(echo ${opt}|cut -d= -f1)
			valueparam=$(echo ${opt}|cut -d= -f2)
			fs_task_param_object="{\"${nameparam}\":\"${valueparam}\"}"
		fi
	fi
fi \
|| return 1
}


mon_fs_task_api () {
    local api_url="fs/tasks"
    local task_id="$1"
    local state=""
    local progress="0"
    local duration=""
    local eta=""
    local size_done=""
    error=0
    action="mon" && [[ "$#" -ne "1" ]] && param_fs_task_err
    [[ "${error}" != "1" ]] && \
    while [[ "$state" != "done" ]]; do
        relogin_freebox # relogin if session is disconnected (task longer than session)
        answer=$(call_freebox_api "/$api_url/$task_id" )
        state=$(get_json_value_for_key "$answer" "result.state")
        [[ "$state" == "failed" ]] \
                && echo -e "${RED}task $task_id failed !${norm}" && break \
                ||echo -e "${GREEN}task $task_id $state ... ${norm}"
                [[ "$state" == "done" ]] && break
		while [[ "$progress" != "100" || "$state" != "done" ]]; do
		      # here we relogin if task is too long and session timeout (1800s)	
		      relogin_freebox 
                      local answer=$(call_freebox_api "/$api_url/$task_id" )
        	      state=$(get_json_value_for_key "$answer" "result.state")
		      [[ "$state" == "failed" ]] && break	
                      eta=$(get_json_value_for_key "$answer" "result.eta")
                      duration=$(get_json_value_for_key "$answer" "result.duration")
                      progress=$(get_json_value_for_key "$answer" "result.progress")
		      local sleep=".6"
		      [[ "$state" == "queued" ]] && sleep="3"	
		      [[ "${eta}" -gt "300" ]] && sleep="1"
		      [[ "${eta}" -gt "1800" ]] && sleep="5"
		      [[ "${eta}" -gt "3600" ]] && sleep="10"
		      [[ "${eta}" -gt "21600" ]] && sleep="30"
		      [[ "${eta}" -gt "43200" ]] && sleep="60"
		      #[[ "${eta}" == "0" && ${progress} =="0" ]] && eta="?"
                      size_done=$(get_json_value_for_key "$answer" "result.total_bytes_done")
		      if [[ "${size_done}" -gt "10737418240" ]]
		      then	      
			       size_done="$(($size_done/1024/1024/1024))GB"
		      elif [[ "${size_done}" -gt "10485760" ]] 
		      then	      
			       size_done="$(($size_done/1024/1024))MB"
		      elif [[ "${size_done}" -gt "10240" ]]
		      then	      
			       size_done="$(($size_done/1024))KB"
		      else
	       		       size_done="${size_done}B "			      
		      fi
		      # restoring saved value of $progress if API send a null value (api bug?)
		      [[ "${progress}" == "" ]] && progress=$prog 
                      progress "$progress" "${duration}s end: ${eta}s ${size_done} "
                      sleep $sleep 
		      # saving last value of $progress if API send a null value for progress (api bug?)
		      local prog=$progress
                done

        echo
        sleep 1
    done || return 1
    [[ "$state" != "failed" ]] \
    && echo -e "${GREEN}task $task_id $state ... ${norm}" 
unset action
}	


# NBA : function which update a filesystem task (paused, running, queued)
upd_fs_task () {
        local tskresult=""
	local tskid=${1}
        action=upd
        error=0
        check_and_feed_fs_task_param "${@}" 
	[[ "${error}" != "1" ]] \
        && tskresult=$(update_freebox_api /fs/tasks/${tskid} "${fs_task_param_object}" 2>&1)
        colorize_output "${tskresult}"
        unset action
}

# NBA : function which delete a filesystem task 
del_fs_task () {
        local tskresult=""
	local tskid=${1}
        action=del
        error=0
        check_and_feed_fs_task_param "${@}" \
        && [[ "${error}" != "1" ]] \
        && tskresult=$(del_freebox_api /fs/tasks/${tskid} 2>&1)
        colorize_output "${tskresult}"
        unset action
}

# NBA : function which retrieve info on a particular filesystem task 
get_fs_task () {
        local tskresult=""
	local tskid=${1}
        action=get
        error=0
        check_and_feed_fs_task_param "${@}" \
        && [[ "${error}" != "1" ]] \
        && tskresult=$(get_freebox_api /fs/tasks/${tskid}/ 2>&1)
        colorize_output "${tskresult}" 
	#echo -e "tskresult=${tskresult}"
        unset action
}

# NBA : function which pretty print on a particular filesystem task 
show_fs_task () {
	local tskid=${1}
        action=show
        error=0
        check_and_feed_fs_task_param "${@}" \
        && [[ "${error}" != "1" ]] \
        && list_fs_task_api ${tskid} 2>&1 
	echo
        unset action
}

# NBA : function which retrieve hash value after asking fbx to compute it in a filesystem task  
hash_fs_task () {
        local tskresult=""
	local tskid=${1}
        action=hash
        error=0
        check_and_feed_fs_task_param "${@}" \
        && [[ "${error}" != "1" ]] \
        && tskresult=$(get_freebox_api /fs/tasks/${tskid}/hash 2>&1)
        colorize_output "${tskresult}"
        unset action
}



####### ADDING FUNCTION FOR MANAGING FILESYSTEM ACTIONS ########

param_fs_err () {
# when calling this function inside this lib, prog_cmd= and prog_list= must be null: ""    
# when calling this function from an external program, you must set 'prog_cmd' and 'list_cmd' values you use to call this function as a GLOBAL VARIABLES. ex : prog_cmd="fbxvm-ctrl file copy" list_cmd="fbxvm-ctrl list file"
# ${action} parameter must be set by function which calling 'param_fs_err' (or by primitive function)	
error=1
        [[ "${action}" == "extract" \
        || "${action}" == "archive" \
        || "${action}" == "mkdir" \
        || "${action}" == "rename" \
        || "${action}" == "cp" \
        || "${action}" == "mv" \
        || "${action}" == "rm" \
        || "${action}" == "hash" \
        || "${action}" == "del" ]] \
        && local funct="${action}_fs_file"

[[ "${prog_cmd}" == "" ]] \
        && local progfunct=${funct} \
        || local progfunct=${prog_cmd}
[[ "${list_cmd}" == "" ]] \
        && local listfunct="ls_fs" \
        || local listfunct=${list_cmd}

[[ "${action}" == "extract" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|src= \t\t\t# The archive file|dst=\t\t\t# The destination folder |password= \t\t# (Optionnal) The archive password|delete_archive= \t# boolean true or false (Optionnal) Delete archive after extraction |overwrite= \t\t# boolean true or false (Optionnal) Overwrite files on conflict${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to extract an archive: ${norm}\n${BLUE}src=|dst= ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}archive type will be autodetect from archive filename extention - supported type: ${norm}\n${BLUE}.zip|.iso|.cpio|.tar|.tar.gz|.tar.xz|.7z|.tar.7z|.tar.bz2 ${norm}\n" |tr "|" "\n" \
&& echo -e "EXAMPLE (simple):\n${BLUE}${progfunct} src=\"/FBXDSK/vm/archive.zip\" dst=\"/FBXDSK/vm\" ${norm}\n" \
&& echo -e "EXAMPLE (medium):\n${BLUE}${progfunct} src=\"/FBXDSK/vm/archive.zip\" dst=\"/FBXDSK/vm\" password=\"MyArchivePassword\" ${norm}\n" \
&& echo -e "EXAMPLE (full):\n${BLUE}${progfunct} src=\"/FBXDSK/vm/archive.zip\" dst=\"/FBXDSK/vm\" password=\"MyArchivePassword\" delete_archive=\"1\" overwrite=\"0\" ${norm}\n" 

[[ "${action}" == "archive" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|files= \t\t\t# List of files fullpath separated by a coma \",\" |dst=\t\t\t# The destination archive (name of the archive) ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to create an archive: ${norm}\n${BLUE}files=|dst= ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}archive type will be autodetect from archive filename extention - supported type: ${norm}\n${BLUE}.zip|.iso|.cpio|.tar|.tar.gz|.tar.xz|.7z|.tar.7z|.tar.bz2 ${norm}\n" |tr "|" "\n" \
&& echo -e "EXAMPLE (simple):\n${BLUE}${progfunct} files=\"/FBXDSK/vm/vm1-disk0.qcow2\" dst=\"/FBXDSK/vm/archive.zip\" ${norm}\n" \
&& echo -e "EXAMPLE (multiple files/dir):\n${BLUE}${progfunct} files=\"/FBXDSK/vm/vm1-disk0.qcow2,/FBXDSK/vm/vm2-disk0.qcow2\" dst=\"/FBXDSK/vm/archive.zip\" ${norm}\n"

[[ "${action}" == "mkdir" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|parent= \t\t# The parent directory path |dirname=\t\t# The name of the directory to create ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to create a directory: ${norm}\n${BLUE}parent=|dirname= ${norm}\n" |tr "|" "\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} parent=\"/FBXDSK/vm\" dirname=\"MyNewVMdir\"${norm}\n"

[[ "${action}" == "rename" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|src= \t\t\t# The source file path |dst=\t\t\t# The new name of the file (filename only, no path) ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to  ${action} a file/dir: ${norm}\n${BLUE}src=|dst= ${norm}\n" |tr "|" "\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} src=\"/FBXDSK/vm/vm1-disk0.qcow2\" dst=\"vm2-disk2.qcow2\"${norm}\n"

[[ "${action}" == "cp" || "${action}" == "mv" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|files= \t\t\t# List of files to ${action} separated by a coma \",\" - avoid spaces in filename |dst=\t\t\t# The destination|mode= \t\t\t# Conflict resolution : overwrite, both, skip, recent  ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to ${action} a file/dir: ${norm}\n${BLUE}files=|dst=|mode= ${norm}\n" |tr "|" "\n" \
&& echo -e "EXAMPLE (simple):\n${BLUE}${progfunct} files=\"/FBXDSK/vm/vm1-disk0.qcow2\" dst=\"/FBXDSK/vm2\" mode=\"overwrite\" ${norm}\n" \
&& echo -e "EXAMPLE (multiple files/dir):\n${BLUE}${progfunct} files=\"/FBXDSK/vm/vm1-disk0.qcow2,/FBXDSK/vm/vm2-disk0.qcow2\" dst=\"/FBXDSK/vm2\" mode=\"overwrite\" ${norm}\n"

[[ "${action}" == "rm" || "${action}" == "del" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|files= \t\t\t# List of files to ${action} separated by a coma \",\" - avoid spaces in filename ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to  ${action} a file/dir: ${norm}\n${BLUE}files= ${norm}\n" |tr "|" "\n" \
&& echo -e "EXAMPLE (simple):\n${BLUE}${progfunct} files=\"/FBXDSK/vm/oldvm1-disk0.qcow2\" ${norm}\n" \
&& echo -e "EXAMPLE (multiple files/dir):\n${BLUE}${progfunct} files=\"/FBXDSK/vm/oldvm1-disk0.qcow2,/FBXDSK/vm/oldvm2-disk0.qcow2,/FBXDSK/vm/oldvm3-disk0.qcow2\" ${norm}\n"

[[ "${action}" == "hash" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|src= \t\t\t\t# The source file path to hash |hash_type=\t\t\t# The hash algo, can be: md5 sha1 sha256 sha512  ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to  ${action} a file/dir: ${norm}\n${BLUE}src=|hash_type= ${norm}\n" |tr "|" "\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} src=\"/FBXDSK/vm/vm1-disk0.qcow2\" hash_type=\"sha256\"${norm}\n"

unset prog_cmd list_cmd
return 1
}	

check_and_feed_fs_param () {
        local param=("${@}")
        local nameparam=("")		idparam=0
        local valueparam=("")		numparam="$#"
	local action=${action}			
        error=0
	fs_param_object=("")
	#fs_task_param_object=("")
        [[ "$numparam" -lt "1" ]] && param_fs_err

# checking and feeding param for 'fs command api' 
[[ "$numparam" -ge "1" ]] && [[ "${error}" != "1" ]] && \
    while [[ "${param[$idparam]}" != "" ]]
    do	
	if [[ "${action}" == "cp" || "${action}" == "mv" ]]
	then
		[[ "${error}" != "1" ]] && \
		[[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "files" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "dst" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "mode" ]] \
		&& param_fs_err && break
	elif [[ "${action}" == "mkdir" ]]
	then
		[[ "${error}" != "1" ]] && \
		[[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "parent" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "dirname" ]] \
		&& param_fs_err && break
	elif [[ "${action}" == "rename" ]]
	then
		[[ "${error}" != "1" ]] && \
		[[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "src" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "dst" ]] \
		&& param_fs_err && break
	elif [[ "${action}" == "hash" ]]
	then
		[[ "${error}" != "1" ]] && \
		[[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "src" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "hash_type" ]] \
		&& param_fs_err && break
	elif [[ "${action}" == "rm" ]]
	then
		[[ "${error}" != "1" ]] && \
		[[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "files" ]] \
		&& param_fs_err && break
		#{\"files\":[\"${file1}\",\"${file2}\",...,\"${fileN}\"]}
		#files='["file1","file2",...,"fileN"]'
	elif [[ "${action}" == "archive" ]]
	then
		[[ "${error}" != "1" ]] && \
		[[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "files" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "dst" ]] \
		&& param_fs_err && break 
	elif [[ "${action}" == "extract" ]]
	then
		[[ "${error}" != "1" ]] && \
		[[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "src" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "dst" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "password" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "overwrite" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "delete_archive" ]] \
		&& param_fs_err && break
	fi
				
        nameparam[$idparam]=$(echo "${param[$idparam]}"|cut -d= -f1)
        valueparam[$idparam]=$(echo -e "${param[$idparam]}"|cut -d= -f2-)

    ((idparam++))
    done

# building ${fs_param_object[@]} json object
[[ "${error}" != "1" ]] && fs_param_object=$(
        local idnameparam=0
        while [[ "${nameparam[$idnameparam]}" != "" ]]
        do
		if [[ "${nameparam[$idnameparam]}" == "files" ]]
		then
			if grep -q ',' <(echo ${valueparam[$idnameparam]})
			then
			local k=0 files=($(echo -e "${valueparam[$idnameparam]}"|tr "," "\n"))
			while [[ "${files[$k]}" != "" ]] 
			do
				files[$k]=$(echo -n ${files[$k]}|base64 -w0)
				((k++))	
			done
			valueparam[$idnameparam]=$(echo ${files[@]}|tr " " ",")
	#valueparam[$idnameparam]="[\\\"$(echo ${valueparam[$idnameparam]}|sed -e 's/,/\\\",\\\"/g')\\\"]"
			valueparam[$idnameparam]="[\"$(echo ${valueparam[$idnameparam]}|sed -e 's/,/\",\"/g')\"]"
			else
			valueparam[$idnameparam]="[\"$(echo -n ${valueparam[$idnameparam]}|base64 -w0)\"]"
			fi
		elif  [[ "${nameparam[$idnameparam]}" == "src" \
			|| "${nameparam[$idnameparam]}" == "parent" ]]
		then
			valueparam[$idnameparam]=$(echo -n ${valueparam[$idnameparam]}|base64 -w0)	
		elif  [[ "${nameparam[$idnameparam]}" == "dst" \
			&& "${action}" != "rename" ]]
		then
			valueparam[$idnameparam]=$(echo -n ${valueparam[$idnameparam]}|base64 -w0)	
		fi
		[[ "${nameparam[$idnameparam]}" == "files" ]] && \
                echo "\"${nameparam[$idnameparam]}\":${valueparam[$idnameparam]}" || \
                echo "\"${nameparam[$idnameparam]}\":\"${valueparam[$idnameparam]}\""
                ((idnameparam++))
	done | tr "\n" "," |sed -e 's@"@\"@g' -e 's@^@{@' -e 's@,$@}@' ) \
        || return 1

        #echo -e  "fs_param_object: ${fs_param_object}"  # debug

}



# NBA : Filesystem function which will copy files 
cp_fs_file () {
        local fsresult=""
        action=cp
        error=0
        check_and_feed_fs_param "${@}" 
	[[ "${error}" != "1" ]] \
        && fsresult=$(add_freebox_api /fs/${action}/ "${fs_param_object}" 2>&1)
        colorize_output "${fsresult}"
        unset action
}


# NBA : Filesystem function which will move files 
mv_fs_file () {
        local fsresult=""
        action=mv
        error=0
        check_and_feed_fs_param "${@}" \
	&& [[ "${error}" != "1" ]] \
        && fsresult=$(add_freebox_api /fs/${action}/ "${fs_param_object}" 2>&1)
        colorize_output "${fsresult}"
        unset action
}


# NBA : Filesystem function which will remove (delete) files 
rm_fs_file () {
        local fsresult=""
        action=rm
        error=0
        check_and_feed_fs_param "${@}" \
	&& [[ "${error}" != "1" ]] \
        && fsresult=$(add_freebox_api /fs/${action}/ "${fs_param_object}" 2>&1)
        colorize_output "${fsresult}"
        unset action
}

# NBA : Filesystem function which will delete (remove) files 
del_fs_file () {
	rm_fs_file "${@}"
}


# NBA : Filesystem function which will create a directory 
mkdir_fs_file () {
        local fsresult=""
        action=mkdir
        error=0
        check_and_feed_fs_param "${@}" \
	&& [[ "${error}" != "1" ]] \
        && fsresult=$(add_freebox_api /fs/${action}/ "${fs_param_object}" 2>&1)
        colorize_output "${fsresult}"
        unset action
}


# NBA : Filesystem function which will rename files 
rename_fs_file () {
        local fsresult=""
        action=rename
        error=0
        check_and_feed_fs_param "${@}" \
	&& [[ "${error}" != "1" ]] \
        && fsresult=$(add_freebox_api /fs/${action}/ "${fs_param_object}" 2>&1)
        colorize_output "${fsresult}"
        unset action
}


# NBA : Filesystem function which will hash a file 
hash_fs_file () {
        local fsresult=""
        action=hash
        error=0
        check_and_feed_fs_param "${@}" \
	&& [[ "${error}" != "1" ]] \
        && fsresult=$(add_freebox_api /fs/${action}/ "${fs_param_object}" 2>&1)
        colorize_output "${fsresult}"
        unset action
}


# NBA : Filesystem function which will make an archive with provided files/dir 
archive_fs_file () {
        local fsresult=""
        action=archive
        error=0
        check_and_feed_fs_param "${@}" \
	&& [[ "${error}" != "1" ]] \
        && fsresult=$(add_freebox_api /fs/${action}/ "${fs_param_object}" 2>&1)
        colorize_output "${fsresult}"
        unset action
}


# NBA : Filesystem function which will extract files from an archive 
extract_fs_file () {
        local fsresult=""
        action=extract
        error=0
        check_and_feed_fs_param "${@}" \
	&& [[ "${error}" != "1" ]] \
        && fsresult=$(add_freebox_api /fs/${action}/ "${fs_param_object}" 2>&1)
        colorize_output "${fsresult}"
        unset action
}



###########################################################################################
## 
## FRONTEND FUNCTIONS: library frontend function for managing "DOWNLOAD SHARE LINK"
## 
###########################################################################################


param_share_link_err () {
# when calling this function inside this lib, prog_cmd= and prog_list= must be null: ""    
# when calling this function from an external program, you must set 'prog_cmd' and 'list_cmd' values you use to call this function as a GLOBAL VARIABLES. ex : prog_cmd="fbxvm-ctrl add sharelink" list_cmd="fbxvm-ctrl list sharelink"
# ${action} parameter must be set by function which calling 'param_share_link_err' (or by primitive function)      
error=1
        [[ "${action}" == "add" \
        || "${action}" == "get" \
        || "${action}" == "show" \
        || "${action}" == "del" ]] \
        && local funct="${action}_share_link"

[[ "${prog_cmd}" == "" ]] \
        && local progfunct=${funct} \
        || local progfunct=${prog_cmd}
[[ "${list_cmd}" == "" ]] \
        && local listfunct="list_share_link" \
        || local listfunct=${list_cmd}

# add_share_link  
[[ "${action}" == "add" ]] \
&& echo -e "\nERROR: ${RED}<param> must be :${norm}${BLUE}|path=\t\t\t# fullpath of file or dir to share |expire=\t\t\t# expire date: 0=never - format yyyy-mm-dd - to specify time add: Thh:mm:ss${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to add a share_link: ${norm}\n${BLUE}path= |expire= ${norm}\n" |tr "|" "\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} path=\"/MyFBX/dl/debian-vm-12.qcow2\" expire=\"2023-12-12T22:33:44\" ${norm}\n" 

# del_share_link get_share_link and show_share_link 
[[ "${action}" == "del" \
        || "${action}" == "get" \
        || "${action}" == "show" ]] \
&& echo -e "\nERROR: ${RED}<param> must be :${norm}${BLUE}|token\t\t\t# token is a chain of 16 alphanumeric or punctuation characters${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}you can get a list of share_link token (showing all 'token'), just run: ${norm}\n${BLUE}${listfunct}${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} \"nb5KDjU9TOeC00w3\" ${norm}\n" 

unset prog_cmd list_cmd
return 1
}

check_and_feed_share_link_param () {
        local nameparam=("")            token=${1}
        local param=("${@}")            idparam=0
        local valueparam=("")           numparam="$#"
        error=0
        share_link_object=("")
        [[ "$numparam" -lt "1" || "$numparam" -ge "3" ]] && param_share_link_err

# checking param for 'share link api': 
# if only 1 param is provided, it must be a token (16 alphanum or punct char) 
if [[ "$numparam" -eq "1" ]] && [[ "${error}" != "1" ]]
then
	if [[ "${action}" == "del" || "${action}" == "get" || "${action}" == "show" ]]
	then
		[[ ${token} =~ ^([[:alnum:]]|[[:punct:]]){16}$ ]] \
		&& return 0 \
		|| param_share_link_err  
	fi	
fi
# add action take 'path=' and 'expire=' parameter
[[ "$numparam" -eq "2" ]] && [[ "${error}" != "1" ]] &&  [[ "${action}" != "add" ]] && param_share_link_err
[[ "$numparam" -eq "2" ]] && [[ "${error}" != "1" ]] &&  [[ "${action}" == "add" ]] && \
    while [[ "${param[$idparam]}" != "" ]]
    do	
		[[  "${error}" != "1" ]] && \
		[[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "path" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "expire" ]] \
		&& param_share_link_err && break
		#if [[ "$(echo ${param[$idparam]}|cut -d= -f1)" == "expire" ]]
		#then	
		#	date -d"$(echo ${param[$idparam]}|cut -d= -f2)" 2>&1 >/dev/null 
		#	[[ "$?" != "0" ]] && \
		#echo -e "\n${RED}Error in date format! please use yyyy-mm-dd or yyyy-mm-ddThh:mm:ss${norm}" \
		#	&& param_share_link_err && break
		#fi	
        nameparam[$idparam]=$(echo "${param[$idparam]}"|cut -d= -f1)
        valueparam[$idparam]=$(echo -e "${param[$idparam]}"|cut -d= -f2-)
    ((idparam++))
    done
[[ "${action}" == "add" ]] && [[ "${error}" != "1" ]] && \
	share_link_object=$(
        local idnameparam=0
        while [[ "${nameparam[$idnameparam]}" != "" ]]
        do
                if  [[ "${nameparam[$idnameparam]}" == "path" ]] 
                then
                        valueparam[$idnameparam]=$(echo -n ${valueparam[$idnameparam]}|base64 -w0)      
                elif  [[ "${nameparam[$idnameparam]}" == "expire" ]]
                then
                    if [[ "${valueparam[$idnameparam]}" == "never" || "${valueparam[$idnameparam]}" == "0" ]]
		    then
		        valueparam[$idnameparam]=0
		    else 
			valueparam[$idnameparam]=$(date +%s -d"${valueparam[$idnameparam]}")
		    fi	
                fi
                echo "\"${nameparam[$idnameparam]}\":\"${valueparam[$idnameparam]}\""
                ((idnameparam++))
        done | tr "\n" "," |sed -e 's@"@\"@g' -e 's@^@{@' -e 's@,$@}@' ) 
	#echo -e share_link_object="${share_link_object[@]}"   # debug
}	


# NBA : function which print a pretty list of share_link 
list_share_link () {
	# This function provide a pretty list of all download links accessible without login in freebox 
        # if "${action}=show" and you pass a token as $1 argument, only task with this token will be shawn
        # function show_shared_link call does this job      

	local tok=${1}
        local api_url="share_link/${tok}"
        local TYPE="LIST OF SHARED LINKS:"
	local p0="]"
  
        [[ "${action}" == "show" ]] && p0="" && TYPE="SHOW LINK TOKEN: ${token}"
        #local answer=$(call_freebox_api  "/$api_url/" 2>&1)
        local answer=$(call_freebox_api  "/$api_url/" )
        local cache_result=("$(dump_json_keys_values "${answer}")")
        echo -e "\n${white}\t\t\t\t\t${TYPE}${norm}\n"        
        local path=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep  ${p0}.path |cut -d' ' -f3))
        local token=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.token |cut -d' ' -f3))
        local name=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.name |cut -d' ' -f3))
        local expire=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.expire |cut -d' ' -f3))
        local fullurl=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.fullurl |cut -d' ' -f3))
        local internal=($(echo -e "${cache_result[@]}" |egrep -v "}$"|egrep ${p0}.internal |cut -d' ' -f3))
	local i=0
        # writing 1 line of dashes (---) 
	print_term_line 120
        [[ ${token[$i]} == "" ]] && echo -e "\n${RED}No download share links to list !${norm}\n"  
        while [[ ${token[$i]} != "" ]]
        do
	expire[$i]=$(date "+%Y-%m-%dT%H:%M:%S" -d@${expire[$i]})
	path[$i]=$(echo ${path[$i]}|base64 -d)
echo -e "token: ${RED}${token[$i]}${norm}\t\texpire: ${PURPL}${expire[$i]/T/ }${norm}\tname: ${LBLUE}${name[$i]}${norm}\npath: ${LBLUE}${path[$i]}${norm}\nURL: ${GREEN}${fullurl[$i]}${norm}"
	print_term_line 120
        ((i++))
        done|| return 1
echo
}


# NBA : function which delete a share_link 
add_share_link () {
        local lnkresult=""
	local token=${1}
        action=add
        error=0
        check_and_feed_share_link_param "${@}" \
        && [[ "${error}" != "1" ]] \
        && lnkresult=$(add_freebox_api /share_link/ "${share_link_object[@]}" 2>&1)
        colorize_output "${lnkresult}"
        unset action
}

# NBA : function which restrive a share_link 
get_share_link () {
        local lnkresult=""
	local token=${1}
        action=get
        error=0
        check_and_feed_share_link_param "${@}" \
        && [[ "${error}" != "1" ]] \
        && lnkresult=$(get_freebox_api /share_link/${token} 2>&1)
	#echo -e "lnkresult=${lnkresult}" # debug
        colorize_output "${lnkresult}"
        unset action
}

# NBA : function which pretty print a particular share_link 
show_share_link () {
	local token=${1}
        action=show
        error=0
	check_and_feed_share_link_param "${@}" \
        && [[ "${error}" != "1" ]] \
        && list_share_link ${token} 2>&1
        echo
        unset action
}

# NBA : function which delete a share_link 
del_share_link () {
        local lnkresult=""
	local token=${1}
        action=del
        error=0
        check_and_feed_share_link_param "${@}" \
        && [[ "${error}" != "1" ]] \
        && lnkresult=$(del_freebox_api /share_link/${token} 2>&1)
        colorize_output "${lnkresult}"
        unset action
}




###########################################################################################
## 
## FRONTEND FUNCTIONS: library frontend function for managing "NETWORK"
## 
###########################################################################################


####### NBA: GLOBAL NETWORK TEST FUNCTION #######

# testing if *port* is a number in [1- 65535]
check_if_port () {
	local port="${1}"
[[ $port =~ ^[[:digit:]]+$ ]] \
	&& [[ $port -gt 1 && $port -lt 65535 ]] \
	|| return 1
}

# testing if *mac* has a 'mac address' format : 01:23:EF:45:ab:89
check_if_mac () {
	local mac="${1}"
[[ $mac =~ ^([0-9a-fA-F]{2}:){5}([0-9a-fA-F]{2})$ ]] \
	|| return 1
}	

# testing if *ip* has an 'ip address' format : 0.0.0.0 to 255.255.255.255 
check_if_ip () {
	local ip="${1}"
[[ $ip =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] \
        || return 1
}	

# testing if *ip* is a 'local ip address' as defined in rfc1918 
check_if_rfc1918 () {
        local ip="${1}"
	check_if_ip $ip \
	&& [[ $ip =~ ^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.) ]] \
	|| return 1
}


######## match debug ##########
#[[ $mac =~ ^([0-9a-fA-F]{2}:){5}([0-9a-fA-F]{2})$ ]] && echo match-mac-and="$?"
#[[ $mac =~ ^([0-9a-fA-F]{2}:){5}([0-9a-fA-F]{2})$ ]] || echo match-mac-or="$?"
#[[ $port =~ ^[[:digit:]]+$ ]] && echo match-digit-and="$?"
#[[ $port =~ ^[[:digit:]]+$ ]] || echo match-digit-or="$?"
#[[ $port -gt 1 && $port -lt 65535 ]] && echo match-value-and="$?"
#[[ $port -gt 1 && $port -lt 65535 ]] || echo match-value-or="$?"
####### /match debug/ #########



####### NBA ADDING FUNCTION FOR MANAGING DHCP TASKS API #######

# NBA : Function which will list all dhcp static leases
# This function do not take parameters
# --> success return 0 and a list of DHCP static leases  
# --> error return 1 and print stderr

list_dhcp_static_lease () {

	#local answer=$(call_freebox_api "/dhcp/static_lease" 2>&1)
	local answer=$(call_freebox_api "/dhcp/static_lease" )
	echo -e "\n\e${white}\t\t\t\tDHCP ASSIGNED STATIC LEASES:${norm}\n" 	
	local cache_result=("$(dump_json_keys_values "${answer}")")
	local id=($(echo -e "${cache_result[@]}" |egrep ].id |cut -d' ' -f3))
	local mac=($(echo -e "${cache_result[@]}" |egrep ].mac |cut -d' ' -f3))
	local ip=($(echo -e "${cache_result[@]}" |egrep ].ip |cut -d' ' -f3))
	local hostname=($(echo -e "${cache_result[@]}" |egrep ].hostname |cut -d' ' -f3))
	local status=("$(echo -e "${cache_result[@]}" |egrep ].host.active)")
	local state=("")
	local i=0 j=0 k=0           # if mac had never connect the l2 network, lanHost api object
	while [[ $k != ${#id[@]} ]] # does not exist => force init status to: status=offline
	do                          
		state[$k]=$(echo -e "${status[@]}" | egrep -w "result\[$k\].host.active = true" \
			|| echo "result[$k].host.active = false")
		((k++))
	done

	#echo -e "${cache_result[@]}" >./restest # debug
	#echo -e "${state[@]}" >./idtest #&& echo -e state[$i]="${state[$i]}"  # debug
	echo -e "\e[4m${WHITE}#:\t\tid:\t\t\tmac:\t\t\tip: \t\tstate: \t\thostname:${norm}" 	
	_check_success "${answer}" || echo -e "${RED}${answer}${norm}" || return 1

        while [[ "${id[$i]}" != "" ]];
       	do
		[[ "${state[$i]}" == "result[$i].host.active = true" ]] \
			&& state[$i]="online" \
			|| state[$i]="offline"
		[[ "${state[$i]}" == "online" ]] \
			&& echo -e "$j:\t${GREEN}${id[$i]}${norm}\t${GREEN}${mac[$i]}${norm}\t${GREEN}${ip[$i]} ${norm} \t${GREEN}${state[$i]}${norm}  \t${RED}${hostname[$i]}${norm}"\
			|| echo -e "$j:\t${PURPL}${id[$i]}${norm}\t${PURPL}${mac[$i]}${norm}\t${PURPL}${ip[$i]} ${norm} \t${PURPL}${state[$i]}${norm}  \t${BLUE}${hostname[$i]}${norm}"
	((i++))
	((j++))
	done  || return 1 
echo
}	


# NBA : Function which will print help on error for DHCP functions :
# - add_dhcp_static_lease
# - upd_dhcp_static_lease
# - del_dhcp_static_lease

param_dhcp_err () {
# when calling this function inside this lib, prog_cmd= and prog_list= must be null: ""    
# when calling this function from an external program, you must set 'prog_cmd' and 'list_cmd' values you use to call this function as a GLOBAL VARIABLES. ex : prog_cmd="fbxvm-ctrl add dhcp" list_cmd="fbxvm-ctrl list dhcp"
# ${action} parameter must be set by function which calling 'param_dhcp_err' (or by primitive function) 
error=1

	[[ "${action}" == "add" \
	|| "${action}" == "upd" \
	|| "${action}" == "del" ]] \
	&& local funct="${action}_dhcp_static_lease" 

[[ "${prog_cmd}" == "" ]] \
	&& local progfunct=${funct} \
	|| local progfunct=${prog_cmd} 
[[ "${list_cmd}" == "" ]] \
        && local listfunct="list_dhcp_static_lease" \
        || local listfunct=${list_cmd} 


# add_dhcp_static_lease param error
[[ "${action}" == "add" ]] \
&& echo -e "\nERROR: ${RED}<param> for ${progfunct} must be some of:${norm}${BLUE}|mac=|ip=|comment=${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to create a static DHCP lease: ${norm}\n${BLUE}mac= \nip=${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} mac=\"00:01:02:03:04:05\" ip=\"192.168.123.123\" comment=\"VM: 14RV-FSRV-123\"${norm}\n" 

# upd_dhcp_static_lease param error
[[ "${action}" == "upd" ]] \
&& echo -e "\nERROR: ${RED}<param> for ${progfunct} must be some of:${norm}${BLUE}|mac=|ip=|comment=${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to update a static DHCP lease: ${norm}\n${BLUE}mac= \nip=  or comment= ${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} mac=\"00:01:02:03:04:05\" ip=\"192.168.123.123\" comment=\"VM: 14RV-FSRV-123\"${norm}\n" 

# del_dhcp_static_lease param error
[[ "${action}" == "del" ]] \
&& echo -e "\nERROR: ${RED}<param> must be :${norm}${BLUE}|id${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}you can get a list of DHCP static lease (showing all 'id'), just run : ${norm}\n${BLUE}${listfunct}${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} 00:01:02:03:04:05${norm}\n" \
&& if [[ "${iderr}" -eq 1 ]]; then echo -e "ERROR: ${RED}Bad value for id, id must have a mac address format:${norm}${BLUE}|00:01:02:03:04:05${norm}" |tr "|" "\n" ; iderr=2 ; fi

unset prog_cmd list_cmd
return 1
}


# NBA : Function which will check and filled dhcp functions parameters:
# --> Return a json "dhcp_object" 
check_and_feed_dhcp_param () {
	local param=("${@}")
	local mac=""
	local ip=""
	local comment=""
	local error=""
	local idparam=0
	local numparam="$#"
	local nameparam=("")
	local valueparam=("")
	id=""
	dhcp_object=("")
	[[ "$numparam" -lt "2" ]] && param_dhcp_err 
	[[ "$numparam" -ge "2" ]] && \
	while [[ "${param[$idparam]}" != "" ]]
	do
		[[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "mac" \
		&& "$(echo ${param[$idparam]}|cut -d= -f1)" != "ip" \
		&& "$(echo ${param[$idparam]}|cut -d= -f1)" != "comment" ]] \
		&& param_dhcp_err && break 
		nameparam=$(echo "${param[$idparam]}"|cut -d= -f1)
		valueparam=$(echo -e"${param[$idparam]}"|cut -d= -f2-)
                [[ "${nameparam}" == "mac" ]] && mac=${valueparam}
                [[ "${nameparam}" == "ip" ]] && ip=${valueparam}
                [[ "${nameparam}" == "comment" ]] && comment=${valueparam}
	((idparam++))
	done
	
	id=$mac
	dhcp_object="{\"mac\":\"${mac}\",\"ip\":\"${ip}\",\"comment\":\"${comment}\"}"
	#echo dhcp_object=${dhcp_object} # debug
}


# NBA : Function which will add DHCP static lease for specified MAC address
# parameters : - mac=
#              - ip=
#              - comment= (optionnal BUT value must be "quoted") 
add_dhcp_static_lease () {
	local addlease=""
	action=add
	error=0
	check_and_feed_dhcp_param "${@}" \
	&& addlease=$(add_freebox_api /dhcp/static_lease/ "${dhcp_object}" 2>&1) 
	colorize_output "${addlease}"
	unset action
}

# NBA : Function which will upd DHCP static lease for specified MAC address
# parameters : - mac=
#              - ip=
#              - comment= (optionnal BUT value must be "quoted") 
upd_dhcp_static_lease () {
	local updlease=""
	action=upd
	error=0
	check_and_feed_dhcp_param "${@}" \
	&& updlease=$(update_freebox_api /dhcp/static_lease/${id} "${dhcp_object}" 2>&1) 
	colorize_output "${updlease}"
	unset action
}


# NBA : Function which will del DHCP static lease for specified MAC address
# parameters : - id=    ('id' = 'mac' => 'id' has a 'mac address' format
del_dhcp_static_lease () {
	local id=$1
	local dellease=""
	action=del
	error=0
	iderr=0

	# test if "id" has a "mac adress" format #->replace with 'check_if_mac' function  
	! [[ "$id" =~ ^([0-9a-fA-F]{2}:){5}([0-9a-fA-F]{2})$ ]] \
		&& iderr=1 \
		&& param_dhcp_err
	[[ "$iderr" -eq "0" ]] \
	&& dellease=$(del_freebox_api /dhcp/static_lease/${id} 2>&1) \
        || dellease="Error in 'id' mac address format"	
	colorize_output "${dellease}"
	unset iderr
	unset action
}



####### NBA ADDING FUNCTION FOR MANAGING INCOMMING NAT REDIRECTION API #######

# NBA : Function which will list all incomming NAT redirections
# This function do not take parameters
# --> success return 0 and a list of incomming NAT redirections
# --> error return 1 and print stderr

list_fw_redir () {

	local answer=$(call_freebox_api "/fw/redir/")
	echo -e "\n${white}\t\t\t\tNETWORK INCOMMING NAT REDIRECTIONS:${norm}\n" 	
	# When json reply is big (ex: recieve a lanHost object) we need to cache results 
	local cache_result=("$(dump_json_keys_values "${answer}")")
	local id=($(echo -e "${cache_result[@]}" |egrep ].id |cut -d' ' -f3))
	local lan_port=($(echo -e "${cache_result[@]}" |egrep ].lan_port |cut -d' ' -f3))
	local lan_ip=($(echo -e "${cache_result[@]}" |egrep ].lan_ip |cut -d' ' -f3))
	local src_ip=($(echo -e "${cache_result[@]}" |egrep ].src_ip |cut -d' ' -f3))
	local ip_proto=($(echo -e "${cache_result[@]}" |egrep ].ip_proto |cut -d' ' -f3))
	local wan_port_s=($(echo -e "${cache_result[@]}" |egrep ].wan_port_start |cut -d' ' -f3))
	local wan_port_e=($(echo -e "${cache_result[@]}" |egrep ].wan_port_end |cut -d' ' -f3))
	local hostname=($(echo -e "${cache_result[@]}" |egrep ].hostname |cut -d' ' -f3))
	local state=($(echo -e "${cache_result[@]}" |egrep ].enabled |cut -d' ' -f3))
	local i=0 j=0
	#echo -e "${cache_result[@]}" >./restest # debug
	#echo -e "${id[@]}" >./idtest && echo -e \"id[$i]="${id[$i]}"\"  # debug
	echo -e "\e[4m${WHITE}#:\tid:\tlan-port:\tprotocol:\tlan_ip:\t\t\twan-port-range:\t\tallowed-ip\tstate:\t\thostname:${norm}" 	
        while [[ "${id[$i]}" != "" ]];
        	do
		[[ "${state[$i]}" == "true" ]] \
			&& state[$i]="active" \
			|| state[$i]="disabled"
		[[ "${state[$i]}" == "active" ]] \
			&& echo -e "$j:\t${RED}${id[$i]}\t${GREEN}${lan_port[$i]}\t\t${ip_proto[$i]}\t\t${lan_ip[$i]}\t\t${wan_port_s[$i]}\t${wan_port_e[$i]}\t\t${src_ip[$i]}   \t${state[$i]}${norm}  \t${RED}${hostname[$i]}${norm}"\
			|| echo -e "$j:\t${RED}${id[$i]}\t${PURPL}${lan_port[$i]}\t\t${ip_proto[$i]}\t\t${lan_ip[$i]}\t\t${wan_port_s[$i]}\t${wan_port_e[$i]}\t\t${src_ip[$i]}   \t${state[$i]}${norm}   \t${BLUE}${hostname[$i]}${norm}"
	((i++))
	((j++))
	done  || return 1
echo
}	


# NBA : Function which will print help on error FW_REDIR / NAT functions :
# - add_fw_redir
# - upd_fw_redir
# - del_fw_redir
# - ena_fw_redir
# - dis_fw_redir
# ${action} parameter must be set by function which calling 'param_fw_redir_err' (or by primitive) 
# This function return 1

param_fw_redir_err () {    
# when calling this function inside this lib, prog_cmd= and prog_list= must be null: ""    
# when calling this function from an external program, you must set 'prog_cmd' and 'list_cmd' values you use to call this function as a GLOBAL VARIABLES. ex : prog_cmd="fbxvm-ctrl add fw_redir" list_cmd="fbxvm-ctrl list fw_redir"
error=1

        [[ "${action}" == "add" \
        || "${action}" == "upd" \
        || "${action}" == "ena" \
        || "${action}" == "dis" \
        || "${action}" == "del" ]] \
        && local funct="${action}_fw_redir"

[[ "${prog_cmd}" == "" ]] \
        && local progfunct=${funct} \
        || local progfunct=${prog_cmd} 
[[ "${list_cmd}" == "" ]] \
        && local listfunct="list_fw_redir" \
        || local listfunct=${list_cmd} 

# add_fw_redir param error	
[[ "${action}" == "add" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|lan_port=\t\t# lan start port: must be a number in [1-65535]|wan_port_start=\t\t# wan start port: must be a number in [1-65535]|wan_port_end=\t\t# wan end port: must be a number in [1-65535]|lan_ip=\t\t\t# local destination ip|ip_proto=\t\t# must be: 'tcp' or 'udp'|src_ip=\t\t\t# allowed ip: default: all ip allowed|enabled=\t\t# boolean 'true' or 'false': default 'true'|comment=\t\t# string: maximum 63 char ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to create a destination NAT redirection: ${norm}\n${BLUE}wan_port_start= \nlan_port= \nlan_ip= \nip_proto=${norm}\n" \
&& echo -e "WARNING: ${RED}if not specified on cmdline following parameters will be reset to their default values${norm}${BLUE}|wan_port_end=\t\t# default value: wan_port_start|src_ip=\t\t\t# default: all ip allowed: 0.0.0.0|enabled=\t\t# default: true${norm}\n" |tr "|" "\n"  \
&& echo -e "EXAMPLE: (simple)\n${BLUE}${progfunct} wan_port_start=\"443\" lan_port=\"443\" lan_ip=\"192.168.123.123\" ip_proto=\"tcp\" comment=\"NAT: destination nat: HTTPS to VM 14RV-FSRV-123:HTTPS\"${norm}\n" \
&& echo -e "EXAMPLE: (full)\n${BLUE}${progfunct} wan_port_start=\"60000\" wan_port_end=\"60010\" lan_port=\"60000\" lan_ip=\"192.168.123.123\" ip_proto=\"tcp\" src_ip=\"22.22.22.22\" enabled=\"true\" comment=\"NAT: destination nat: PASV_FTP to VM 14RV-FSRV-123:FTP_PASV\"${norm}\n" 

# comment=(MAX 63 char)

# upd_fw_redir param error
[[ "${action}" == "upd" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|id=\t\t\t# id: must be a number: id of nat rule to modify|lan_port=\t\t# lan start port: must be a number in [1-65535]|wan_port_start=\t\t# wan start port: must be a number in [1-65535]|wan_port_end=\t\t# wan end port: must be a number in [1-65535]|lan_ip=\t\t\t# local destination ip|ip_proto=\t\t# must be: 'tcp' or 'udp'|src_ip=\t\t\t# allowed ip: default all ip allowed|enabled=\t\t# boolean 'true' or 'false': default 'true'|comment=\t\t# string: maximum 63 char ${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}please run \"${listfunct}\" to get list of all rules 'id' ${norm}\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to update a destination NAT redirection: ${norm}${BLUE}|id=|wan_port_start=${norm}\n" |tr "|" "\n"  \
&& echo -e "WARNING: ${RED}if not specified on cmdline following parameters will be reset to their default values${norm}${BLUE}|wan_port_end=\t\t# default value: wan_port_start|src_ip=\t\t\t# default: all ip allowed: 0.0.0.0|enabled=\t\t# default: true${norm}\n" |tr "|" "\n"  \
&& echo -e "EXAMPLE: (simple)\n${BLUE}${progfunct} id=34 wan_port_start=\"443\" lan_port=\"443\" lan_ip=\"192.168.123.123\" comment=\"NAT: destination nat: HTTPS to VM 14RV-FSRV-123:HTTPS\"${norm}\n" \
&& echo -e "EXAMPLE: (full)\n${BLUE}${progfunct} id=34 wan_port_start=\"60000\" wan_port_end=\"60010\" lan_port=\"60000\" lan_ip=\"192.168.123.123\" comment=\"NAT: destination nat: FTP(S) PASIVE PORT to VM 14RV-FSRV-123:FTP_PASV\"${norm}\n" 


# del_fw_redir param error
[[ "${action}" == "del" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be :${norm}${BLUE}|id\t\t\t# id: must be a number${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}please run \"${listfunct}\" to get list of all destination NAT redirection (showing all 'id'):${norm}\n${BLUE}${listfunct}${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} 34${norm}\n" 



# ena_fw_redir param error
[[ "${action}" == "ena" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be :${norm}${BLUE}|id\t\t\t# id: must be a number${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}please run \"${listfunct}\" to get list of all destination NAT redirection (showing all 'id'):${norm}\n${BLUE}${listfunct}${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} 34${norm}\n" 


# dis_fw_redir param error
[[ "${action}" == "dis" ]] \
&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be :${norm}${BLUE}|id\t\t\t# id: must be a number${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}please run  \"${listfunct}\" to get list of all destination NAT redirection (showing all 'id'):${norm}\n${BLUE}${listfunct}${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} 34${norm}\n" 

unset prog_cmd list_cmd
return 1
}


# NBA : This function validate contents of parameters and fullfill variables
# --> Return a json 'fw_redir_object' object
# - lan_port
# - wan_port_start
# - wan_port_end
# - lan_ip
# - ip_proto

check_and_feed_fw_redir_param () {
	local param=("${@}")
	local lan_port=
	local wan_port_end=
	local wan_port_start=
	local lan_ip=
	local ip_proto=
        local comment=""
	local src_ip=
	local enabled=
        local idparam=0
	local idnameparam=0 
        local numparam="$#"
        local nameparam=("")
        local valueparam=("")
	local port_err_msg="all *port* values must be a number in [1-65535]"
	local ip_err_msg="lan_ip must be an rfc1918 valid ip address"
	local src_ip_err_msg="src_ip must be a valid ip address in [0.0.0.0-255.255.255.255]"
        error=0
        id=""
        fw_redir_object=("")

	# test params and assign values in 2 arrays : nameparam[$idparam] and valueparam[$idparam]
        [[ "$numparam" -lt "2" ]] && param_fw_redir_err
        [[ "$numparam" -ge "2" ]] && \
        while [[ "${param[$idparam]}" != "" ]]
        do
                [[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "wan_port_start" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "wan_port_end" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "lan_port" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "lan_ip" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "ip_proto" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "src_ip" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "enabled" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "id" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "comment" ]] \
                && param_fw_redir_err && break
                nameparam[$idparam]=$(echo "${param[$idparam]}"|cut -d= -f1)
                valueparam[$idparam]=$(echo -e"${param[$idparam]}"|cut -d= -f2-)
                [[ "${nameparam[$idparam]}" == "wan_port_start" ]] && wan_port_start=${valueparam[$idparam]}  
                [[ "${nameparam[$idparam]}" == "wan_port_end" ]] && wan_port_end=${valueparam[$idparam]}
                [[ "${nameparam[$idparam]}" == "lan_port" ]] && lan_port=${valueparam[$idparam]}
                [[ "${nameparam[$idparam]}" == "lan_ip" ]] && lan_ip=${valueparam[$idparam]}
                [[ "${nameparam[$idparam]}" == "ip_proto" ]] && ip_proto=${valueparam[$idparam]}
                [[ "${nameparam[$idparam]}" == "src_ip" ]] && src_ip=${valueparam[$idparam]}
                [[ "${nameparam[$idparam]}" == "enabled" ]] && enabled=${valueparam[$idparam]}
                [[ "${nameparam[$idparam]}" == "id" ]] && id=${valueparam[$idparam]}
                [[ "${nameparam[$idparam]}" == "comment" ]] && comment=${valueparam[$idparam]}
        ((idparam++))
        done
	
	
	# testing *port* is a number in [1-65535]
	for port in $wan_port_start $wan_port_end $lan_port ; do
	[[ "${port}" != "" && "${error}" != "1" && "${action}" == "add" ]] \
		&& ! check_if_port $port \
		&& addfwredir="${port_err_msg}" \
		&& param_fw_redir_err 
	[[ "${port}" != "" && "${error}" != "1" && "${action}" == "upd" ]] \
		&& ! check_if_port $port \
		&& updfwredir="${port_err_msg}" \
		&& param_fw_redir_err 
	done

	# testing 'lan_ip' is a local ip address as describes in rfc1918
	[[ "${lan_ip}" != "" && "${error}" != "1" && "${action}" == "add" ]] \
                && ! check_if_rfc1918 $lan_ip \
                && addfwredir="${ip_err_msg}" \
                && param_fw_redir_err
        [[ "${lan_ip}" != "" && "${error}" != "1" && "${action}" == "upd" ]] \
                && ! check_if_rfc1918 $lan_ip \
                && updfwredir="${ip_err_msg}" \
                && param_fw_redir_err

	# testing 'src_ip' is valid ip address in [0.0.0.0-255.255.255.255]
	[[ "${src_ip}" != "" && "${error}" != "1" && "${action}" == "add" ]] \
                && ! check_if_ip $src_ip \
                && addfwredir="${src_ip_err_msg}" \
                && param_fw_redir_err
        [[ "${src_ip}" != "" && "${error}" != "1" && "${action}" == "upd" ]] \
                && ! check_if_ip $src_ip \
                && updfwredir="${src_ip_err_msg}" \
                && param_fw_redir_err
	
	# testing 'comment' length not exceeded 63 char
	[[ "${comment}" != "" && "${error}" != "1" && "${action}" == "add" ]] \
		&& [[ "$(echo $comment |wc -m)" -gt 63 ]] \
                && addfwredir="comment cannot exceeded 63 char" \
                && param_fw_redir_err
	[[ "${comment}" != "" && "${error}" != "1" && "${action}" == "upd" ]] \
		&& [[ "$(echo $comment |wc -m)" -gt 63 ]] \
                && updfwredir="comment cannot exceeded 63 char" \
                && param_fw_redir_err
	
        # Affecting default values    
	[[ "${wan_port_end}" == ""  ]] \
		&& wan_port_end=${wan_port_start} \
		&& nameparam+=(wan_port_end) \
		&& valueparam+=($wan_port_end)
	[[ "${src_ip}" == ""  ]] \
		&& src_ip=0.0.0.0 \
		&& nameparam+=(src_ip) \
                && valueparam+=($src_ip)
	[[ "${enabled}" == ""  ]] \
		&& enabled=1 \
		&& nameparam+=(enabled) \
		&& valueparam+=($enabled)

	# verify 'id' is specified for action=upd
	#echo error=$error    # debug
	if [[ "${action}" == "upd"  ]]
	then
		echo ${nameparam[@]}|grep -q 'id' 
		[[ "$?" -eq "1" ]] \
			&& [[ "${error}" != "1" ]] \
			&& param_fw_redir_err
	fi
	
	#verify 'ip_proto' is specified for action=add
        if [[ "${action}" == "add"  ]]
        then
                echo ${nameparam[@]}|grep -q 'ip_proto'
                [[ "$?" -eq "1" ]] \
                        && [[ "${error}" != "1" ]] \
			&& addfwredir="Invalid protocole: you must specify ip_proto=tcp or ip_proto=udp" \
                        && param_fw_redir_err
        fi


	# building 'fw_redir_object' json object
	[[ "${error}" != "1" ]] \
		&& fw_redir_object=$(
		while [[ "${nameparam[$idnameparam]}" != "" ]]
		do
			echo "\"${nameparam[$idnameparam]}\":\"${valueparam[$idnameparam]}\""
		((idnameparam++))
		done | tr "\n" "," |sed -e 's@"@\"@g' -e 's@^@{@' -e 's@,$@}@' ) \
		|| return 1	

	#echo fw_redir_object=${fw_redir_object} # debug

#fw_redir_object="{\"wan_port_start\":\"60000\",\"wan_port_end\":\"60010\",\"lan_port\":\"60000\",\"lan_ip\":\"192.168.123.123\",\"ip_proto\":\"tcp\",\"comment\":\"NAT: destination nat: PASIVE PORT\",\"src_ip\":\"0.0.0.0\",\"enabled\":\"1\"}"
}


# NBA : Function which will add a NAT redirection (WAN-> LAN)
# This function takes following parameters :
# - lan_port
# - wan_port_start
# - wan_port_end
# - lan_ip
# - ip_proto
add_fw_redir () {
	local addfwredir="" 
        action=add
        error=0
        check_and_feed_fw_redir_param "${@}" \
	&& addfwredir=$(add_freebox_api /fw/redir/ "${fw_redir_object}" 2>&1)
        colorize_output "${addfwredir}"
        unset action
}


# NBA : Function which will update an existing NAT redirection (WAN -> LAN)
# This function takes 'id' + add_fw_redir parameters 
# (only id and wan_port_start are mandatory)  
upd_fw_redir () {
        local updfwredir="" 
        action=upd
        error=0
        check_and_feed_fw_redir_param "${@}" \
        && updfwredir=$(update_freebox_api /fw/redir/${id} "${fw_redir_object}" 2>&1)
        colorize_output "${updfwredir}"
        unset action
}


# NBA : Function which will delete an existing NAT redirection 
# This function takes 'id' parameter 
del_fw_redir () {
	local id=${1}
        local delfwredir=""
        action=del
        error=0  iderr=0
        # test if "id" is a number
        ! [[ "$id" =~ ^[0-9]+$ ]] \
                && iderr=1 \
        	&& delfwredir="Error : 'id' must be a number !" \
                && param_fw_redir_err 
        [[ "$iderr" -eq "0" ]] \
        	&& delfwredir=$(del_freebox_api /fw/redir/${id} 2>&1) 
        colorize_output "${delfwredir}" 
        unset iderr action
}


# NBA : Function which will enable an existing NAT redirection 
# This function takes 'id' parameter 
ena_fw_redir () {
        local id=${1}
        local enafwredir=""
	action=ena
        error=0  iderr=0
        # test if "id" is a number
        ! [[ "$id" =~ ^[0-9]+$ ]] \
                && iderr=1 \
                && enafwredir="Error : 'id' must be a number !" \
                && param_fw_redir_err 
        [[ "$iderr" -eq "0" ]] \
                && enafwredir=$(update_freebox_api /fw/redir/${id} "{\"enabled\":true}" 2>&1)
        colorize_output "${enafwredir}"
        unset iderr action
}


# NBA : Function which will disable an existing NAT redirection
# This function takes 'id' parameter 
dis_fw_redir () {
        local id=${1}
        local disfwredir=""
	action=dis
        error=0  iderr=0
        # test if "id" is a number
        ! [[ "$id" =~ ^[0-9]+$ ]] \
                && iderr=1 \
                && disfwredir="Error : 'id' must be a number !" \
                && param_fw_redir_err 
        [[ "$iderr" -eq "0" ]] \
                && disfwredir=$(update_freebox_api /fw/redir/${id} "{\"enabled\":false}" 2>&1)
        colorize_output "${disfwredir}"
        unset iderr action
}




###########################################################################################
## 
## FRONTEND FUNCTIONS: library frontend function for managing "VM PREBUILD DISTROS"
## 
###########################################################################################


# function which list VM prebuild distros and export distros values to subshell
list_vm_prebuild_distros () {
	local quiete=${1}  # "-q" argument make function had a silent output - "-h" for help
 	local i=0 k=0
	answer=$(call_freebox_api /vm/distros 2>&1)
	local cache_result=("$(dump_json_keys_values "${answer}")") # caching results
        local name=($(echo -e "${cache_result[@]}" |egrep ].name |cut -d' ' -f3-|sed -e 's/ /_/g'))
        local os=($(echo -e "${cache_result[@]}" |egrep ].os |cut -d' ' -f3-))
        local url=($(echo -e "${cache_result[@]}" |egrep ].url |cut -d' ' -f3-))
        local hash=("")
        local hashresult=("$(echo -e "${cache_result[@]}" |egrep ].hash)")
        local filename=("")
	# to keep sequence order we populate optional 'hash' value in array when hash=""       
        while [[ $k != ${#url[@]} ]] 
        do
		hash[$k]=$(echo -e "${hashresult[@]}" | egrep -w "result\[$k\].hash = [hf][t]?tp[s]?://.*" \
                        || echo "result[$k].hash = \033[36m[no_hashfile_url_available]\033[00m")
		hash[$k]=$(echo ${hash[$k]} |cut  -d' ' -f3-)
                ((k++))
        done
	[[ ${quiete} == "-h" ]] && \
	echo -e "\n${WHITE}function param:\n\t\t-h\tprint this help\n\t\t-q\tsilently export distros variables - no output\n${norm}"
	[[ ${quiete} != "-q" && ${quiete} != "-h" ]] && \
        echo -e "\n${white}\t\t\t\tLIST AVAILIABLE 'Freebox Delta' PREBUILD VM DISTROS IMAGES:${norm}\n"
	[[ ${quiete} != "-q" && ${quiete} != "-h" ]] && \
	print_term_line
        while [[ ${os[$i]} != "" ]]
        do
		# feeding ${filename[@]} array
		filename[$i]=$(echo ${url[$i]} |grep -o '[^/]*$') 
		# calibrationg distros list output	
		nc=$(echo -n "${name[$i]}"|wc -m)
        	[[ "$nc" -ge "1" && "$nc" -lt "10" ]] && name[$i]="${name[$i]}\t\t\t"
        	[[ "$nc" -gt "9" && "$nc" -lt "15" ]] && name[$i]="${name[$i]}\t\t"
        	[[ "$nc" -gt "14" && "$nc" -lt "28" ]] && name[$i]="${name[$i]}\t"
        	[[ "$nc" -gt "27" && "$nc" -lt "33" ]] && name[$i]="${name[$i]}"
        	[[ "$nc" -gt "32" ]] && name[$i]="${name[$i]}"
		# printing distros list output
		[[ ${quiete} != "-q" && ${quiete} != "-h" ]] && \
		echo -e "${RED}id: $i${norm}\tname=${GREEN}${name[$i]//_/ }${norm}\tos=${GREEN}${os[$i]}${norm}\tfilename=${GREEN}${filename[$i]}${norm}\n\turl=${PURPL}${url[$i]}${norm}\n\thash=${PURPL}${hash[$i]}${norm}" && \
	print_term_line
	((i++))
	done && echo || return 1
# publish distro to subshell 
export distro_name=("${name[@]}")
export distro_os=("${os[@]}")
export distro_url=("${url[@]}")
export distro_hash=("${hash[@]}")
export distro_filename=("${filename[@]}")
export distro_count="${#distro_url[@]}"
export distro_idx=("${name[@]}" "${os[@]}" "${filename[@]}" "${url[@]}" "${hash[@]}")
}	


param_vm_prebuild_distros_err () {
# when calling this function inside this lib, prog_cmd= and prog_list= must be null: ""
# when calling this function from an external program, you must set 'prog_cmd' and 'list_cmd' values you use to call this function as a GLOBAL VARIABLES. ex : prog_cmd="fbxvm-ctrl add distro" list_cmd="fbxvm-ctrl list distros"
error=1

[[ "${action}" == "dl" ]] \
        && local funct="${action}_vm_prebuild_distros"

[[ "${prog_cmd}" == "" ]] \
        && local progfunct=${funct} \
        || local progfunct=${prog_cmd} 
[[ "${list_cmd}" == "" ]] \
        && local listfunct="list_vm_prebuild_distros" \
        || local listfunct=${list_cmd} 

# dl_vm_prebuild_distros param error  
[[ "${action}" == "dl" ]] \
	&& echo -e "\nERROR: ${RED}<param> for \"${progfunct}\" must be some of:${norm}${BLUE}|id=\t\t\t# distro id for selected distro in distro list|dl_path=\t\t# optional download path (override default download_dir - non existent directory will be created)|filename=\t\t# optional filename (override default filename)${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}please run \"${listfunct}\" to get list of all prebuild VM distros ${norm}\n" \
&& echo -e "NOTE: ${RED}minimum parameters to specify on cmdline to dowload a VM prebuild distro: ${norm}\n${BLUE}id=${norm}\n" \
&& echo -e "EXAMPLE: (simple)\n${BLUE}${progfunct} id=5${norm}\n" \
&& echo -e "EXAMPLE: (full)\n${BLUE}${progfunct} id=5 dl_path=/FBXSTORAGE/VMdownload filename=myOpenSuzeVM-7.qcow2${norm}\n" 
unset prog_cmd list_cmd
return 1
}

check_and_feed_vm_prebuild_distros_param () {
        local param=("${@}")
        local idparam=0
        local numparam="$#"
        local nameparam=("")
        local valueparam=("")
        error=0
        id=""
        dl_path=""
        filename=""
	dist_cmd=""
	dl_cmd=""
	is_hash=""
        [[ "$numparam" -lt "1" ]] && param_vm_prebuild_distros_err
        [[ "$numparam" -ge "1" ]] && \
        while [[ "${param[$idparam]}" != "" ]]
        do
                [[ "$(echo ${param[$idparam]}|cut -d= -f1)" != "id" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "dl_path" \
                && "$(echo ${param[$idparam]}|cut -d= -f1)" != "filename" ]] \
                && param_vm_prebuild_distros_err && break
                nameparam=$(echo "${param[$idparam]}"|cut -d= -f1)
                valueparam=$(echo -e"${param[$idparam]}"|cut -d= -f2-)
                [[ "${nameparam}" == "id" ]] && id=${valueparam}
                [[ "${nameparam}" == "dl_path" ]] && dl_path=${valueparam}
                [[ "${nameparam}" == "filename" ]] && filename=${valueparam}
        ((idparam++))
        done

	# feeding global variables & formatting request parameters & feeding default values
	[[ "$error" != "1" ]] && list_vm_prebuild_distros -q  # populating vm distro variables 
	[[ "${filename}" == "" ]] && filename=${distro_filename[$id]}

	# printing on cmdline 'hash=' and 'download_dir=' only if hash and dl_path exist
        [[ "$error" != "1" ]] && \
		is_hash="${distro_hash[$id]}" && \
		echo ${is_hash} | grep -Eq [hf][t]?tp[s]?:// \
		&& dist_cmd="hash=" \
		|| dist_cmd=""
        [[ "${dist_cmd}" == "" ]] \
		&& is_hash=""
        [[ -n "${dl_path}" ]] \
		&& dl_cmd="download_dir=" \
		|| dl_cmd=""
}





# function which download a specific VM prebuild distro from the list
dl_vm_prebuild_distros () {
	action="dl"
	error=0

	# check and fullfill vm prebuild distros parameters
	check_and_feed_vm_prebuild_distros_param "${@}"

	if [[ "$error" != "1" ]] 
		then	
		local dlvmdistro=$(enc_dl_task_api \
				download_url=${distro_url[$id]} \
				${dist_cmd}${is_hash} ${dl_cmd}${dl_path} \
				filename=${filename} 2>&1)
		colorize_output ${dlvmdistro}
		local task_id=$(echo ${dlvmdistro}| cut -d':' -f4 |cut -d'}' -f1) && \
		monitor_dl_task_adv_api $task_id
		dl_task_log_api $task_id
		del_dl_task_api $task_id
		echo
	fi		
unset error action dl_cmd dl_path dist_cmd is_hash id filename
}	




###########################################################################################
## 
##  VM FUNCTIONS: library function for managing "VM CONSOLE" using WEBSOCKET API
## 
###########################################################################################



####### NBA ADDING FUNCTION FOR USING FREEBOX WEBSOCKET API #######

## test if websocket is alive with cURL, example : 
#curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Host: echo.websocket.events" -H "Origin: https://www.websocket.events" https://echo.websocket.events

## but cURL do not allow interractive websocket flows and do not support 'ws://' & 'wss://' addresses
## ==> NEED EXTERNAL PACKAGES (in 2022) : "websocat" : see 'EXTOOL' (after the code) for install  

## NB1 : 
# --> websocat fullfill all "websocket" HTTP like headers automatically => no need of :  
    #&& options+=(-H \"Connection: Upgrade\") \
    #&& options+=(-H \"Upgrade: websocket\") \
    #&& options+=(-H \"Sec-WebSocket-Version: 13\") \
    #&& options+=(-H \"Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==\") \
    #&& options+=(-H \"Host: $FREEBOX_URL\") \

# --> websocat provide some dedicated options for those specials headers :
    #&& options+=(-H \"Sec-WebSocket-Protocol: chat, superchat\") \
    #&& options+=(-H \"Origin: $FREEBOX_URL\")
    #==> Using websocat "--protocol" and "--origin" option

## NB2 : 
# In comparison to function call_freebox_api (), call_freebox-ws_api is using websocket API
# -->  That want to say that datastream are send and recieve interractively (stdin - stdout) 
# So, compared to call_freebox_api () :
    # => no "$data" string to send (removing next line)
    #[[ -n "$data" ]] && options+=(-d "$data")
    # => no "$answer" string to parse (removing next line)
    #answer="bash -c \"${req[@]}\"" ; #_check_success "$answer" || return 1 ;  #echo "$answer"

# And websocat do not support --cacert option => using "SSL_CERT_FILE" env variable 
# or -k" (--insecure) in ${opssl[@]}

## NB3 : 20220601 
# It was not possible to exit websocat when terminal was in raw mode without using an external program
# That's why the possibility to launch websocat detached (using GNU dtach) add been added in the past.
# Same, the possibility to launch in a screen (using GNU screen) add previously been added
# Speaking with Vitaly Shukela ('websocat' developper, see https://github.com/vi/websocat/issues/152)  
# Vitaly release a new functionnality in websocat 1.10 specially for my use case : 
# He add the possibility to kill the connection in raw mode from the client or target
# He also add the possibility to define the "exit char", refering to the decimal value of the ASCII 
# char selected. Default is ctrl+\ (ascii decimal = 28) but as on my local keyboard it need to hit
# 3 strokes, I decide to change it to ctrl+K (asci decimal = 11) like 'ctrl kill'
#
# If you want to change the exit char, you may find the ascii table here :
# https://www.physics.udel.edu/~watson/scen103/ascii.html
#
# You can also close he connection from the target, writing the equivalent value to the terminal :
# echo -e "\013\c" >/proc/$$/fd/0
# It's also possible to automatically close the connection when logout, add in ~/.bash_logout
# something like : echo -e "Connection closed\n\013\c" >/proc/$$/fd/0

## NB4 : 20220601 
# I let in the code the possibility to use dtach and screen (with additionnal external packages) but
# it's not mandatory now to have those functionnality to exit the connection without killing websocat
# from another terminal
#

###### END NOTA BENE #####
ws_session () {
sleep .5
#debug
#echo $(date) >./wstemp.log
#echo $_SESSION_TOKEN >>./wstemp.log
#/debug
while [[ $(pgrep websocat) ]] ;
	do 
		# Refresh token every 1750 second (expire every 1800s)
		for ((i=1;i<3500;i++)); 
			do
			pgrep websocat >/dev/null || break
			sleep 0.5
			((i++))
		done	
		source ${BASH_SOURCE} && relogin_freebox
		#bash -c "source ${BASH_SOURCE} && relogin_freebox"
		#debug
	        #echo $(date +"%Y%m%d %H:%M:%S") >>./wstemp.log
		#echo  $(pgrep websocat) >>./wstemp.log
		#echo $_SESSION_TOKEN >>./wstemp.log
		#/debug
	done 
exit 200 # this function is never sourced directly from a tty but from websocat_session() 
}

websocat_session () {
ws_session & 2>&1 >/dev/null
}	

call_freebox-ws_api () {
check_login_freebox || (echo -e "${RED}Vous devez vous connecter pour accéder à cette fonction: auth_required${norm}" && ctrlc)
    local api_url="$1"
    local mode="$2"
    local sockname=$(echo $api_url |cut -d'/' -f3)
    local optssl=("")
    local options=("")
    local optws=("")
    local optwscl=("")
    local optsttys=("")
    local optsttye=("")
    local optscreen=("")
    local req=("")
    local url="$FREEBOX_URL"$( echo "/$_API_BASE_URL/v$_API_VERSION/$api_url" | sed 's@//@/@g')
    local wsurl=$(echo $url |sed 's@https@wss@g')
    echo -e "\nConnecting Freebox websocket : ${light_purple_sed}${wsurl}${norm_sed}\n"
    [[ -n "$_SESSION_TOKEN" ]] \
    && options+=(-H \"X-Fbx-App-Auth: $_SESSION_TOKEN\") \
    && optws+=(--origin $FREEBOX_URL) \
    && optws+=(--protocol \"chat, superchat\") \
    && optws+=(-E --binary --byte-to-exit-on 11 exit_on_specific_byte:stdio:) \
    && optwscl+=(exit_on_specific_byte) \
    && optsttys+=(stty raw -echo) \
    && optsttye+=(stty sane cooked) \
    && optscreen+=(-h 10000 -U -t Freebox-WS-API -dmS fbxws-$sockname) 

    mk_bundle_cert_file fbx-cacert-ws                # create CACERT BUNDLE FILE

    [[ -n "$FREEBOX_CACERT" ]] && [[ -f "$FREEBOX_CACERT" ]] \
    && optssl+=("SSL_CERT_FILE=$FREEBOX_CACERT") \
    || optws+=(-k)     

    #req="${optsttys[@]}; ${optssl[@]} websocat ${options[@]} ${optws[@]} \"$wsurl\"; ${optsttye[@]}"
    req="${optsttys[@]}; ${optssl[@]} websocat ${options[@]} ${optws[@]} ${optwscl[@]}:${wsurl}; ${optsttye[@]}"

    # DEBUG : 
     #echo ${req[@]} ; # bash -c "${req[@]}"  
        
        
    [[ ! -n "$mode" ]] \
    && websocat_session \
    && echo -e "${red}Type CTRL+K to EXIT ${norm}" \
    && bash -c "${req[@]}"  
    
    [[ "$mode" == "detached" ]] \
    && dtach -n /tmp/fbxws.$sockname bash -c "${req[@]}" \
    && echo -e "${red}Switching to terminal ...... type CTRL+K to EXIT${norm}" \
    && sleep 1.2 \
    && dtach -a /tmp/fbxws.$sockname -e '^K' \
    && [[ ! -z "$(pgrep websocat)" ]] && kill -9 $(pgrep websocat)

    [[ "$mode" == "screen" ]] \
    && echo -e "${red}Switching to GNU screen ...... type CTRL-A+K to EXIT${norm}" \
    && sleep 2.5 \
    && screen  ${optscreen[@]} bash -c "${req[@]}" \
    && screen -r fbxws-$sockname \
    && [[ ! -z "$(pgrep websocat)" ]] && kill -9 $(pgrep websocat)


    ret=$?
    echo -e "\n\nWebsocket connection closed" 
    del_bundle_cert_file fbx-cacert-ws                # remove CACERT BUNDLE FILE
#    exit $ret
    ctrlc
}

####### NBA END FUNCTION FOR FREEBOX WEBSOCKET API #######



###########################################################################################
## 
##  VM ACTIONS: library VM action (simple API call which made action on Virtual Machines)
## 
###########################################################################################

#case "${vmid}" in
#        list) print_vm_summary && exit 29 ; ;;
#        listdisk) list_vm_disk ${@:2} && exit 33 ; ;;
#        add) add ${@:2}; ;;
#        del) del ${@:2}; ;;
#        resize) resize_disk ${@:2}; ;;
#esac
#
#case "${action}" in
#        start) call_freebox_api "/$API/$vmid/$action" {}; ;;
#        restart) call_freebox_api "/$API/$vmid/$action" {}; ;;
#        shutdown) call_freebox_api "/$API/$vmid/powerbutton" {}; ;;
#        stop) call_freebox_api "/$API/$vmid/$action" {}; ;;
#        detail) print_vm_detail ${vmid}; ;;
#        modify) modify_vm ${vmid} ${@:2}; ;;
#        console) call_freebox-ws_api "/$API/$vmid/$action" ${mode}; ;;
#esac

# NBA : Function which will print help on error for VM actions :
# - vm_start
# - vm_stop
# - vm_restart
# - vm_shutdown
# - vm_console
# - vm_sconsole # start and launch console
# - vm_show
# - vm_detail
# - /!\ project to add 'list_vm' too
# ${action} parameter must be set by function which calling 'param_vm_action_err' (or by primitive) 
# This function return 1 and error=1

param_vm_action_err () {

	error=1

        [[ "${action}" == "start" \
        || "${action}" == "stop" \
        || "${action}" == "restart" \
        || "${action}" == "reload" \
        || "${action}" == "detail" \
        || "${action}" == "show" \
        || "${action}" == "shutdown" \
        || "${action}" == "sconsole" \
        || "${action}" == "console" ]] \
        && local funct="vm_${action}"

[[ "${prog_cmd}" == "" ]] \
        && local progfunct=${funct} \
        || local progfunct=${prog_cmd} 
[[ "${list_cmd}" == "" ]] \
        && local listfunct="list_vm" \
        || local listfunct=${list_cmd} 

[[ "${action}" == "start" \
        || "${action}" == "stop" \
        || "${action}" == "restart" \
        || "${action}" == "reload" \
        || "${action}" == "detail" \
        || "${action}" == "show" \
        || "${action}" == "shutdown" ]] \
&& echo -e "\nERROR: ${RED}<param> must be :${norm}${BLUE}|id\t\t\t# id must be a number${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}you can get a list of all virtuals machines (showing all 'id'), just run: ${norm}\n${BLUE}${listfunct}${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} 5 ${norm}\n" 

[[ "${action}" == "console" \
        || "${action}" == "sconsole" ]] \
	&& echo -e "\nERROR: ${RED}<param> must be :${norm}${BLUE}|id\t\t# id must be a number|mode\t\t# (Optional) can be 'screen' to launch console in a SCREEN - need 'GNU screen'|\t\t# or mode can be 'detached' to detach console in a pipe attached to terminal - need 'GNU dtach'${norm}\n" |tr "|" "\n" \
&& echo -e "NOTE: ${RED}you can get a list of all virtuals machines (showing all 'id'), just run: ${norm}\n${BLUE}${listfunct}${norm}\n" \
&& echo -e "EXAMPLE:\n${BLUE}${progfunct} 5 ${norm}\n" \
&& echo -e "EXAMPLE FULL:\n${BLUE}${progfunct} 5 screen\n${progfunct} 5 detached ${norm}\n" 
#echo	
}	

check_and_feed_vm_action_param () {
	# This function validate VM acctions parameters (id) and return 'vm_action_param_object'
	# when there is more than 1 param and call param_vm_action_err on error
	local param=("${@}")            opt=${2}
        local nameparam=("")            id=${1}
        local valueparam=("")           numparam="$#"
        local action=${action}                  
        error=0
        vm_action_param_object=("")
        [[ "$numparam" -lt "1" ]] && param_vm_action_err

# checking param for 'VM actions': first param must be a number 

if [[ "$numparam" -ge "1" ]] && [[ "${error}" != "1" ]]
then
        [[ ${id} =~ ^[[:digit:]]+$ ]] || param_vm_action_err
fi

if [[ "$numparam" -eq "2" ]] && [[ "${error}" != "1" ]]
then
        [[ "${action}" == "console" || "${action}" == "sconsole" ]] \
		&& [[ "${opt}" != "screen" && "${opt}" != "detached" ]] \
	       	&& param_vm_action_err \
		|| vm_action_param_object="${opt}"

	[[ "${vm_action_param_object}" == "screen" ]] && check_tool screen
	[[ "${vm_action_param_object}" == "detached" ]] && check_tool dtach

fi 
#echo	
}

# NBA : function which get vm object variable for all VM from API call 
get_vm_object_var () {
local i=0
local answer=$(call_freebox_api "/vm/")
# caching json results in env to avoid performance issue
dump_json_keys_values "$answer" >/dev/null
while [[ $(get_json_value_for_key "$answer" "result[$i].id") != "" ]] 
do
        local j=$(get_json_value_for_key "$answer" "result[$i].id")
        mac[$j]=$(get_json_value_for_key "$answer" "result[$i].mac")
        userdata[$j]=$(get_json_value_for_key "$answer" "result[$i].cloudinit_userdata")
        cd_path[$j]=$(get_json_value_for_key "$answer" "result[$i].cd_path")
        id[$j]=$(get_json_value_for_key "$answer" "result[$i].id")
        os[$j]=$(get_json_value_for_key "$answer" "result[$i].os")
        cloudinit[$j]=$(get_json_value_for_key "$answer" "result[$i].enable_cloudinit")
        disk_path[$j]=$(get_json_value_for_key "$answer" "result[$i].disk_path")
        vcpus[$j]=$(get_json_value_for_key "$answer" "result[$i].vcpus")
        memory[$j]=$(get_json_value_for_key "$answer" "result[$i].memory")
        name[$j]=$(get_json_value_for_key "$answer" "result[$i].name")
        cloudinit_hostname[$j]=$(get_json_value_for_key "$answer" "result[$i].cloudinit_hostname")
        state[$j]=$(get_json_value_for_key "$answer" "result[$i].status")
        usb_0[$j]=$(get_json_value_for_key "$answer" "result[$i].bind_usb_ports[0]")
        usb_1[$j]=$(get_json_value_for_key "$answer" "result[$i].bind_usb_ports[1]")
        usb[$j]=$(echo "[\"${usb_0[$j]}\",\"${usb_1[$j]}\"]")
        enable_screen[$j]=$(get_json_value_for_key "$answer" "result[$i].enable_screen")
        disk_type[$j]=$(get_json_value_for_key "$answer" "result[$i].disk_type")

        vm_object_[$j]="{\"mac\":${mac[$j]},\"cloudinit_userdata\":${userdata[$j]},\"cd_path\":${cd_path[$j]},\"id\":${id[$j]},\"os\":${os[$j]},\"enable_cloudinit\":${cloudinit[$j]},\"disk_path\":${disk_path[$j]},\"vcpus\":${vcpus[$j]},\"memory\":${memory[$j]},\"name\":${name[$j]},\"cloudinit_hostname\":${cloudinit_hostname[$j]},\"status\":${state[$j]},\"bind_usb_ports\":${usb[$j]},\"enable_screen\":${enable_screen[$j]},\"disk_type\":${disk_type[$j]}}"

        #echo -e "${vm_object_[$i]}\n" 
        ((i++))
done
}


list_vm () {

        local i=0
        answer=$(call_freebox_api "/vm/$1/")
        echo -e "\n\t\t\t${WHITE}VIRTUAL MACHINE ID, NAME, MAC AND STATUS : ${norm}\n"
        # testing json results to detect a single vm or a list of vm
	dump_json_keys_values "$answer" |grep -q "result.id"
	if [[ "$?" == "0" ]]
	then
        	# caching json results to avoid performance issue
        	dump_json_keys_values "$answer" >/dev/null
                name=$(get_json_value_for_key "$answer" "result.name")
                id=$(get_json_value_for_key "$answer" "result.id")
                mac=$(get_json_value_for_key "$answer" "result.mac")
                state=$(get_json_value_for_key "$answer" "result.status")
		[ "$state" == "running" ] \
                        && echo -e "${GREEN}VM-$i:\t${WHITE}id: ${GREEN}${id}${norm} \t ${WHITE}status:${norm} ${GREEN}${state}${norm} \t${WHITE}name:${norm} ${GREEN}${name}${norm} \t${WHITE}mac_address:${norm} ${GREEN}${mac}${norm}" \
                        || echo -e "${WHITE}VM-$i:\t${RED}id: ${id}${norm} \t ${BLUE}status:${norm} ${PURPL}${state}${norm} \t${BLUE}name:${norm} ${PURPL}${name}${norm} \t${BLUE}mac_address:${norm} ${PURPL}${mac}${norm}" 
	else	
        	# caching json results to avoid performance issue
        	dump_json_keys_values "$answer" >/dev/null
        	while [[ $(get_json_value_for_key "$answer" "result[$i].id") != "" ]] 
        	do	
                name=$(get_json_value_for_key "$answer" "result[$i].name")
                id=$(get_json_value_for_key "$answer" "result[$i].id")
                mac=$(get_json_value_for_key "$answer" "result[$i].mac")
                state=$(get_json_value_for_key "$answer" "result[$i].status")
                if [ ! -z "$id" ];
                        then
			[ "$state" == "running" ] \
                        && echo -e "${GREEN}VM-$i:\t${WHITE}id: ${GREEN}${id}${norm} \t ${WHITE}status:${norm} ${GREEN}${state}${norm} \t${WHITE}name:${norm} ${GREEN}${name}${norm} \t${WHITE}mac_address:${norm} ${GREEN}${mac}${norm}" \
                        || echo -e "${WHITE}VM-$i:\t${RED}id: ${id}${norm} \t ${BLUE}status:${norm} ${PURPL}${state}${norm} \t${BLUE}name:${norm} ${PURPL}${name}${norm} \t${BLUE}mac_address:${norm} ${PURPL}${mac}${norm}" 
                fi
                ((i++))
        	done
	fi	
        echo
}


# NBA : function which pretty print a particular vm of the list
vm_show () {
        local vmid=${1}
        action=show
        error=0
        check_and_feed_vm_action_param "${@}" \
        && [[ "${error}" != "1" ]] \
	&& bash -c "source ${BASH_SOURCE} && relogin_freebox && list_vm ${vmid} 2>&1" \
	|sed -e "s/Impossible/${red_sed}Impossible/" -e "s/no_such_vm/no_such_vm${norm_sed}/"
        echo
        unset action
}


vm_detail () {
        [ -z "$1" ] && echo "function vm_detail take 'id' as argument" 
        local idvm="${1}"
        action=detail
        error=0
        check_and_feed_vm_action_param "${@}" \
        && get_vm_object_var \
        && if [ ! -z "$idvm" ];
                then
                echo -e "\nVM-$idvm : Full details properties :\n"
                echo -e "\tname = ${GREEN}${name[$idvm]}${norm}" 
                echo -e "\tid = ${RED}${id[$idvm]}${norm}" 
                [ "${state[$idvm]}" == "running" ] \
                        && echo -e "\tstatus = ${green}${state[$idvm]}${norm}" \
                        || echo -e "\tstatus = ${purpl}${state[$idvm]}${norm}" 
                echo -e "\tmemory = ${RED}${memory[$idvm]}${norm}" 
                echo -e "\tvcpus = ${RED}${vcpus[$idvm]}${norm}" 
                echo -e "\tdisk_type = ${GREEN}${disk_type[$idvm]}${norm}" 
                echo -e "\tdisk_path = ${RED}$(echo ${disk_path[$idvm]}|base64 -d)${norm}" 
                echo -e "\tcd_path = ${RED}$(echo ${cd_path[$idvm]}|base64 -d)${norm}" 
                echo -e "\tmac_address = ${GREEN}${mac[$idvm]}${norm}" 
                echo -e "\tos = ${GREEN}${os[$idvm]}${norm}" 
                echo -e "\tenable_screen = ${RED}${enable_screen[$idvm]}${norm}" 
                echo -e "\tbind_usb_ports = ${RED}${usb[$idvm]}${norm}" 
                echo -e "\tenable_cloudinit = ${GREEN}${cloudinit[$idvm]}${norm}" 
                echo -e "\tcloudinit_hostname = ${GREEN}${cloudinit_hostname[$idvm]}${norm}" 
                echo -e "\tcloudinit_userdata = ${GREEN}${userdata[$idvm]}${norm}" 
                echo -e "\tjson_vm_object = ${BLUE}${vm_object_[$idvm]}${norm}\n"
        fi

}


vm_start () {
#[ -z "$1" ] && echo "function vm_start take 'id' as argument" 
	local id=${1}
	action=start
        error=0
	check_and_feed_vm_action_param "${@}"
       	[[ ${error} -eq 0 ]] && \
	local startvm=$(call_freebox_api "/vm/${id}/start" {};)
	colorize_output ${startvm}
	unset action
}

vm_restart () {
#[ -z "$1" ] && echo "function vm_restart take 'id' as argument"
	local id=${1}
	action=restart
        error=0
	check_and_feed_vm_action_param "${@}"
       	[[ ${error} -eq 0 ]] && \
	local restartvm=$(call_freebox_api "/vm/${id}/restart" {};)
        colorize_output ${restartvm}
	unset action
}

vm_stop () {
#[ -z "$1" ] && echo "function vm_stop take 'id' as argument" 
	local id=${1}
	action=stop
        error=0
	check_and_feed_vm_action_param "${@}"
       	[[ ${error} -eq 0 ]] && \
	local stopvm=$(call_freebox_api "/vm/${id}/stop" {};)
        colorize_output ${stopvm}
	unset action
}

vm_shutdown () {
#[ -z "$1" ] && echo "function vm_shutdown take 'id' as argument"
	local id=${1}
	action=shutdown
        error=0
	check_and_feed_vm_action_param "${@}"
       	[[ ${error} -eq 0 ]] && \
	local vmshutdown=$(call_freebox_api "/vm/${id}/powerbutton" {};)
	colorize_output ${vmshutdown}
	unset action
}

vm_reload () {
	local id=${1}
	action=reload
        error=0
	check_and_feed_vm_action_param "${@}"
       	[[ ${error} -eq 0 ]] && \
	vm_shutdown ${id} 
	local answer=$(call_freebox_api /vm/${id})
	echo Waiting for vm shutdown...
	while [[ "$(get_json_value_for_key "${answer}" result.status)" == "running" ]];
	do
		sleep .1
		answer=$(call_freebox_api /vm/${id})
	done 
	echo Waiting for vm start...
	vm_start ${id}
	unset action
}

vm_console () {
#[ -z "$1" ] && echo "function vm_console take 'id' as argument and optionnal 'mode'" 
	local id=${1}
	local mode=${2}
	action=console
        error=0
	check_and_feed_vm_action_param "${@}"
	[[ ${error} -eq 0 ]] && \
	call_freebox-ws_api "/vm/${id}/console" ${mode};	
	unset action
}

vm_sconsole () {
# Start VM and launch console 
	local id=${1}
	local mode=${2}
	action=sconsole
        error=0
	check_and_feed_vm_action_param "${@}"
	[[ ${error} -eq 0 ]] && \
	vm_start ${id} 
	call_freebox-ws_api "/vm/${id}/console" ${mode};	
	unset action
}

###########################################################################################
## 
##  STATUS FUNCTIONS: library status function (simple API call) AND 'reboot' action
## 
###########################################################################################


reboot_freebox () {
    # NBA modify for getting reboot status from API 
    #call_freebox_api '/system/reboot' '{}' >/dev/null
    call_freebox_api '/system/reboot' '{}' 
}
status_freebox () {
    # NBA add for getting freebox status json from API 
    call_freebox_api '/system'
}
full_vm_detail () {
    # NBA add for getting a json with all freebox vm details from API 
    call_freebox_api '/vm'
}
vm_resource () {
    # NBA add for getting a json with hardware allocated to freebx vm from API 
    call_freebox_api '/vm/info'
}



###########################################################################################
## 
##  END FUNCTIONS: end of library function and actions - MAIN PART - 
## 
###########################################################################################


######## MAIN ########

# fill _API_VERSION and _API_BASE_URL variables
_check_freebox_api
# verify you have required tools to use this library :
# source $BASH_SOURCE && for tool in curl openssl websocat; do check_tool $tool; done 
#

######################


###########################################################################################
###########################################################################################
##
##   EXTOOL : External tool needed by library
##
###########################################################################################
##
##______________________________
## external program needed : 
## --> cURL (curl)
## --> openssl                               <--# should already be installed on your system
## --> websocat (see "websocat install")
## --> GNU screen (optionnal only)
## --> GNU detach (optionnal only)
## --> Command from GNU coreutils, util-linux (or similar UNIX package) are used in this library:
##     those command are generally installed on every *nix system and can be easily find as single
##     command / package if one missing on your system and you need to install it 
##
##______________________________
## websocat install :
## --> install instruction: ./fbx-delta-nba_bash_api.sh && 'check_tool websocat' 
##
##______________________________
## websocat build (optionnal) :
## You can build websocat from the latest source : 
## - Firts install 'rust' : 
## $ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
## if needed, install required / missing lib (under debian : apt -f install && apt install libxxxx) 
## - Second build 'websocat' : 
## $ cargo install --features=ssl --git https://github.com/vi/websocat
##
## NB: I can build/compile/crosscompile websocat for you if you need, just ask !
##
##
###########################################################################################



###########################################################################################
###########################################################################################
##
##   CHANGELOG OF LIBRARY fbx-delta-nba_bash_api.sh 
## 
##   WARNING lots of changes add been made (+3000 lines) to the original project: 
##          => some features/info at the starting of this changelog can changes after
##          => have a look on the complete changelog if you need particular info 
##
###########################################################################################
#
#____________
# 2013-2021 : 
# NBA : I was a simple user of the original version of freeboxos_bash_api.sh from API v2 
# NBA : to API v6 - I had just develop a script for backing up major config like NAT   
# NBA : redirection or dhcp leases and get freebox status & reboot freebox
# NBA : In 2021, Free add a function to backup and restore freebox configuration, so my 
# NBA : script became outdated
# NBA : BUT in 2021, Free also add support of VM in Freebox Delta and as I'm only using Linux 
# NBA : (at home, at work & on my phone), I decide to write another tool for managing my Freebox 
# NBA : Delta & it's VM from my current bash cmdline. I also wanted to access the VM serial
# NBA : console through the Freebox Delta websocket API to have an out-of-band access to 
# NBA : Freebox Delta's Virtual Machine (like a "chassis" console access on a bigger infra)
# NBA : That was the starting of this library fork and of fbxvm-ctrl bash programm
# NBA : Rest of the story is in the following changelog
#
#___________
# 20211114 : 
# NBA : fbx-delta-nba_bash_api.sh : function for Freebox http/ws API 
# NBA : forked by NBA from https://github.com/JrCs/freeboxos-bash-api
# NBA : Original script has core function to call APIv2 and login function - 220 lines
#
#___________
# 20211116 :
# Modify by NBA to support version 8 of API and HTTPS over the internet :
# APPLICATIONS will be availiable remotely if Freebox allow admin connection from internet
#
# Ex : my freebox delta use its own PKI and has internet access on :
#     -   Secure port : 2xxx
#     -          URL@ : fbx.mydomain.net
#     -           PKI : 14RV
#     -     Signed CA : 14RV-rootCA-RSA8192
#  CA : 14RV must be installed or the system will use '-k = --insecure' option of cURL
#
#___________
# 20220504 :
# Modify by NBA for testing the add-on of websockets
# Freebox Delta's API supports several commands for Virtual Machines and console / monitor
# interractive access through websockets 
# 
# => So adding functions to interract with the Freebox Delta websockets API
#    - using external tool : "websocat" a cURL like websockets client from :    
#      https://github.com/vi/websocat/releases/download/v1.9.0/websocat_linux64
#
#___________
# 20220506 : 
# Modify to add a check_tool function because this script use several external tools
# like "cURL" for requestion HTTP/HTTPS API and 2 others tools for exploiting 
# WEBSOCKET API : tools are : 
# "websocat" a cURL/ncap/socat like tool which can interract with websockets
# DEPRECATED on 20220509 : "rlwrap" a line-buffer wrapper for websocat 
# DEPRECATED on 20220509 : "rlfe" a line-buffer front-end
#
#____________________________
# 20220509 - part 1 - issue : 
# Detecting issue when using websocket API to connect VM console :
# The problem begin when after login the VM console using this websocket API function, 
# when trying to use tools like VIM or NANO for file editting : Arrows do not work and 
# those text editors are impossible to use, chars are not interpreted correctly
# ==> Opening issue #152 at https://github.com/vi/websocat/issues/152
# Maintener told me to have a look at :
# https://github.com/vi/websocat/issues/60#issuecomment-545911812
# Having a look at his recommendation, I made several changes to correct the issue
# Now, we will avoid using 'rlwrap' or 'rlfe', we will use the power of 'stty' for
# managing the behaviour of the terminal
# --> So, we do not need anymore external 'readline' tools like 'rlwrap' or 'rlfe'
# --> The issue is fixed 
# --> Accessing VM console through websocket API have the expected behaviour
#___________________________________
# 20220509 - part 2 - code & clean : 
# --> Cleaning code (delete) where "rlwrap" or "rlfe" were use
# --> Replacing exec file './req' by variable "${req[@]}" containing exec string
# --> Deleting code where './req' file appears
# --> Adding 'DEPRECATED' mention to this changelog
#
#
#___________
# 20220510 :
# --> Organizing comments for websocket functions
# --> Optimizing code : 
#          - using websocat dedicated options for specific headers
#          - supressing automatically fullfilled headers
# --> Testing code to launch the websocket in a screen (stty don't trap SIGINT, screen does) 
#
#___________
# 20220511 :
# --> Adding support of "GNU screen" and "GNU dtach" when launching websocket API :
#          - websocket connection can be directly in current terminal (basic mode)
#            --> for exit, you must kill connection from another terminal
#          - websocket connection can be simply detached (best mode) 
#            --> use CTRL-K to exit the connection 
#          - websocket connection can be launched in a screen (alternative mode)
#            --> use CTRL-A+K to exit the connection 
# --> Adding 'websocat' install process in check_tool() function
# --> Cleaning code 
#
#___________
# 20220513 :
# --> Adding socket name distinction when using websocket VM console API :
#          - Now it's possible to connect differents VM console in all 3 modes  
# --> Adding update_freebox_api function which support HTTP PUT methode - json header 
# --> Adding status_freebox function which dump Freebox system status
#
#___________
# 20220515 :
# --> Adding add_freebox_api function which support HTTP POST methode   - json header
# --> Adding del_freebox_api function which support HTTP DELETE methode - json header
#
#___________
# 20220517 :
# --> Adding progress/wrprogress function to provide progress bar while waiting for a task
#
#___________
# 20220519 :
# --> Modifying websocat install path (new version) and check_tool function
# --> Modifying check_tool function to show the new path for installing websocat
#
#___________
# 20220520 :
# --> Adding aarch64 (ARM-64) websocat install path (new version) 
# --> Modifying check_tool function to show the new aarch64 path for installing websocat
# --> Adding color support for check_tool function
#
#___________
# 20220520 :
# --> Adding better support of cURL PKI / CA : using '-k' if certificate does not exist
#
#___________
# 20220605 :
# --> Adding support of PKI / CA to 'websocat' : 
# --> using 'SSL_CERT_FILE=/path/to/ca/certificate' if a CA certificate is found
# --> using '-k' (= --insecure)  if certificate does not exist
#
#___________
# 20220616 : 
# --> Adding the functionnality to exit 'websocat' from client or target when terminal is in raw mode
# --> Now, GNU dtach or GNU screen are really less mandatory
# --> This is a new functionality developped for this use case by Vitaly Shukela (websocat developper)
# --> See NB3 & NB4 comment later in the code (details + possibility of tuning exit char) 
# --> Exit char is set to CTRL+K or ASCII DEC 11 (can be modify in this lib file)
#
#___________
# 20220628 : 
# --> Adding function to get hardware ressource globaly bind to VM
# --> Adding function to get all vm full details
#
#___________
# 20221123 : 
#--> Switching to websocat-1.11 which included "Escape Char when terminal is un raw mode"
#--> "Escape Char when terminal is un raw mode" function had been developped for this use case 
#
#___________
# 20221204 : 
#--> Adding functions for managing HTTP(S) download tasks :
#--> function which add a download task but do not urlencode params
#--> function which add a download task and urlencode params
#--> 2 functions which monitor a download task (scripting function & frontend advanced function) 
#--> function which print a download task log
#--> function which delete a download task
#
#___________
# 20221215 : 
#--> Adding underlying functions for frontend functions
#    - function which colorize output depending on result
#--> Adding underlying functions for testing network parameters validity
#    - function to check mac address syntaxe
#    - function to check ethernet port 
#    - function to check ip address syntaxe
#    - function to check if ip is an rfc1918 ip address
#
#___________
# 20221219 : 
#--> Adding support of FREEBOX_DEFAULT_URL and FREEBOX_LAN_URL and FREEBOX_WAN_URL
#    - FREEBOX_WAN_URL preferred 
#    - FREEBOX_LAN_URL will be use if FREEBOX_WAN_URL is not defined 
#    - FREEBOX_DEFAULT_URL will be use if FREEBOX_WAN_URL and FREEBOX_LAN_URL are not defined 
#
#--> Adding support of FREEBOX_DEFAULT_CACERT, FREEBOX_LAN_CACERT, FREEBOX_WAN_CACERT and
#    FREEBOX_CA_BUNDLE which concatenate in a single CA certificate bundle all certificates of:
#             - FREEBOX_DEFAULT_CACERT
#             - FREEBOX_LAN_CACERT
#             - FREEBOX_WAN_CACERT
#
#___________
# 20221221 :
#--> Adding support for ILIADBOX, the ITALIAN FREEBOX which had the same API 
#--> Adding support of ILIADBOX_DEFAULT_URL and ILIADBOX_LAN_URL and ILIADBOX_WAN_URL
#    - ILIADBOX_WAN_URL preferred 
#    - ILIADBOX_LAN_URL will be use if ILIADBOX_WAN_URL is not defined 
#    - ILIADBOX_DEFAULT_URL will be use if ILIADBOX_WAN_URL and ILIADBOX_LAN_URL are not defined 
#
#--> Adding support of ILIADBOX_DEFAULT_CACERT, ILIADBOX_LAN_CACERT, ILIADBOX_WAN_CACERT and
#    ILIADBOX_CA_BUNDLE which concatenate in a single CA certificate bundle all certificates of:
#             - ILIADBOX_DEFAULT_CACERT
#             - ILIADBOX_LAN_CACERT
#             - ILIADBOX_WAN_CACERT
#
#--> Adding ITALY support which will use ILIADBOX_*_URL and ILIADBOX_*_CACERT
#
#
#___________
# 20221222 :
#--> Bug corrections of *BOX_CA_BUNDLE with websocat 
#--> fbx-delta-nba_bash_api.sh started to be BIG => structurate API
#--> Adding comments to guide user configuration of library
#--> Adding comments for each groups of functions and for some functions
#--> Adding functions for forcing a GET request with data-www-urlencode of parameters
#
#
#___________
# 20221223 :
#--> Moving changelog at the end of the library for an easier configuration
#--> Adding functions for managing Freebox VM prebuild distros:
#	- function which list VM prebuild distro and export result to subshell
#	- function which add and monitor download of VM prebuild distro
#	- function which manage help / error and validate VM distro parameters
#--> Adding functions for managing DHCP static leases:
#	- function which list DHCP static leases and usage status
#	- function which add a DHCP static leases
#	- function which modify a DHCP static leases
#	- function which delete a DHCP static leases
#	- function which manage help / error and validate DHCP parameters
#--> Adding functions for managing incoming NAT redirection (WAN --> LAN):
#	- function which list incoming NAT redirections
#	- function which add an incoming NAT redirection
#	- function which modify an incoming NAT redirection
#	- function which delete an incoming NAT redirection
#	- function which enable an incoming NAT redirection
#	- function which disable an incoming NAT redirection
#	- function which manage help / error and validate NAT redirection parameters
#--> Adding functions for managing filesystem action:
#	- function list_fs_file: list content of a path / directory of freebox storage
#
#
#______________________
# 20221224 - 20230102 :
#--> Adding functions for managing filesystem tasks:
#       - function which list all filesystem tasks
#       - function which modify a filesystem tasks
#       - function which delete a filesystem tasks
#       - function which show a particular filesystem tasks (pretty human readable output)
#       - function which get a particular filesystem tasks (json output)
#       - function which get a hash result on 'hash' filesystem action tasks
#       - function which monitor a filesystem tasks (including progress bar)
#       - function which manage help / error and validate filesystem task parameters
#--> Adding functions for managing filesystem actions:
#       - function ls_fs: CACHE & list content of a path on freebox storage ('ls' style)
#       - function which copy a file/dir on freebox storage
#	- function which move a file/dir on freebox storage 
#	- function which delete / remove a file/dir on freebox storage 
#	- function which rename a file/dir on freebox storage 
#	- function which create directory on freebox storage 
#	- function which hash a file of freebox storage (md5 sha1 sha256 sha512) 
#	- function which archive files or dir (.tar .zip .7z .tar.gz .tar.bz2 .tar.xz .iso .cpio) 
#	- function which extract archive on freebox storage (.tar .zip .7z .tar.gz .tar.bz2 .tar.xz .iso .cpio)  
#       - function which manage help / error and validate filesystem action parameters
#--> Adding functions for managing unauthentified share link (download links):
#       - function which list all share link
#       - function which add a share link                       
#       - function which delete a share link                       
#       - function which show a particular share link (pretty human readable output)
#       - function which get a particular share link (json output)
#       - function which manage help / error and validate share link task parameters
#--> Adding functions for managing download tasks
#	- function which show a particular download task (pretty human readable output)
#
#
#____________
# 20230103 :
# Some tasks (filesystem tasks, big download) can take hours and hours, really more than the login
# session timeout (~1800 seconds). Now, this lib has some frontend autonomous functions which can 
# require a persistant login session. This part of the job is normally done by a frontend programme 
# which use functions from the library and ensure that the application still has a valid session opened.
# But for a direct use of frontend functions of this lib as some 'end-user program', it was require that 
# the librairy can manage the session persistance itself
#--> Adding functions for managing autologin in librairy :
#	- function which publish _APP_ID and _APP_ENCRYPTED_TOKEN to subshell env at first login
#	- function which logout the API
#	- function which check the session status
#	- function which get encrypted credential from environment and login with those credentials
#	- function which re-login if the session is disconnected
#--> Modifying filesystem task and download tasks monitoring functions to add the 'relogin' function
#
#
#____________
# 20230104 :
#--> Fixing issue on filesystem tasks monitoring 
#--> Icing & anonimizing the code 
#--> Publishing the code on https://github.com/nbanb  
#
#
#____________
# 20230107 :
#--> Fixing issue on monitor_dl_task_api when "checking" 
#--> Fixing issue on "help" output on local_direct_dl_api function
#
#____________
# 20230112 :
#--> Fixing issue on list_vm_prebuild_distro with -q option and -h option 
#
#____________
# 20230113 :
#--> Adding 'use at your own risk' in the header of the library 
#--> Fixing issue on size unit printing in mon_fs_task_api progress bar 
#
#____________
# 20230114 :
#--> Fixing issue on param_fs_err for function hash_fs_file output 
#
#____________
# 20230116 :
#--> Fixing issue on param_fs_err for function extract_fs_file help on booleans
#
#_____________________
# 20230121 - 20230122:
#--> Starting to include library VM functions/actions using frontend library mindset
#--> Fixing performance issue in list_fs_file in caching global json key:values 
#--> Adding support of 'TB': tera bytes files for 'ls_fs' and 'list_fs_file' functions
#--> Speeding up by 3 ls_fs function in caching only one time JSON results
#--> fixing issue in 'ls_fs' function when filename contains spaces ' '
#--> fixing indentation issue in 'ls_fs' function output with hidden files when +100 files in dir
#--> fixing indentation issue in 'list_fs_file' function output with hidden files when +100 files in dir
#--> fixing indentation issue in 'show_fs_task' and 'list_fs_task_api' with error: 'archive_open_failed' 
#--> Adding help option in function 'ls_fs' and 'list_fs_file'
#--> Adding 'onlyFolder' and 'removeHidden' option in 'list_fs_file' function
#--> fixing issue in 'mk_bundle_cacert': avoid getting filename in certfile after failiure 
#
#_____________________
# 20240214 
# --> fixing openssl version different '1.1.1n'
#
#___________
# 20240217 
# --> validating support of Freebox Ultra
# --> adding support of main VM functions : param structure, list, start, stop, console ...
# --> adding CTRL+C function 'ctrlc' to replace 'exit' which kill shell when sourcing lib from tty
# --> adding 'print_err' function to print error and cancel execution
# --> correcting functions behaviour when session expired or not logged (cleaner output) 
# --> adding support of persistance for websocket connection
# --> fixing small bugs: output format, unsollicitated shell exit when disconnected or error
#

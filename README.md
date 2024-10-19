
<a name="TOP"></a>
fbx-delta-nba_bash_api.sh 
==================

<br/>  

### Access [FreeboxOS API](https://dev.freebox.fr/sdk/os/#api-list) from BASH

<br/>

|Supported Freebox|Supported Iliadbox|Virtual Machine Support|
|:-:|:-:|:-:|
|ULTRA| - |YES|
|DELTA| - |YES|
|POP | POP|NO|
|REVOLUTION| - |NO|
|ONE| - |NO|

<br/>


- ### 100% BASH  
- ### APIv10 / APIv11 (ULTRA) 
- ### USE AT YOUR OWN RISK


<br/>


_________________________________________


<br/>

<a name="TOC1"></a>

Table of Contents:
-------------------------------



#### 1. Direct access to major part of this README:  
|Type| Description | Link |
|:-|:-|:-|
|howto example| Quick HOWTO example of how to use this lib  | [QUICK START FULL EXAMPLE](#QSFULLEX) |
|API| FreeboxOS API considerations | [API](#API) |
|core| Create application & login API |  [LOGIN FUNCTIONS](#LOGIN) |
|core| Functions for calling API in all cases | [CALL FUNCTIONS](#CALL) |
|core| Functions for retrieving Freebox component status | [STATUS FUNCTIONS](#STATUS)|
|core| Functions for checking validity or success |  [CHECK FUNCTIONS](#CHECK)|
|frontend| Functions for managing downloads | [DOWNLOAD FUNCTIONS](#DOWNLOAD)|
|frontend example| Example of usage of downloads function | [DOWNLOAD EXAMPLE](#DLEXTRA)|
|frontend| Functions for managing downloads share links | [SHARE LINK FUNCTIONS](#SHARELINK) |
|frontend network| Functions for managing DHCP reservations | [NETWORK DHCP FUNCTIONS](#DHCP) |
|frontend network| Functions for managing incomming NAT redirections | [NETWORK NAT FUNCTIONS](#NAT) |
|API| Filesystem API considerations|[FILESYSTEM](#FS) |
|frontend| Functions for managing filesystem tasks | [FILESYSTEM TASK FUNCTIONS](#FSTSK) |
|frontend| Functions for managing filesystem operations | [FILESYSTEM OPERATION FUNCTIONS](#FSOP) |
|frontend VM| Functions for managing VM | [VIRTUAL MACHINES FUNCTIONS](#VM) |
|frontend| Functions for managing DOMAIN NAME | [DOMAIN NAME FUNCTIONS](#DOMAIN) |
|frontend| Functions for formatting API reply of frontend functions | [API REPLY OUTPUT](#REPLY) |
|core| Functions for making direct actions on box from API | [API ACTIONS](#ACTIONS) |





<br/>


<a name="TOC2"></a>

#### 2. Extras actions / configurations needed on your box when using API:  
|Type| Description | Link |
|:-|:-|:-|
|howto| Configure your applications access right in your box OS | [GRANT API ACCESS](#GRANTAXX) |
|info| Get a  public URL | [URL](#RAXXURL)|
|info| Get a TLS certificate | [TLS CERTIFICATES](#TLSCERT)|
|howto| Configure remote access to your box | [REMOTE ACCESS](#RAXX) |
|howto| Configure public URL and TLS certificate on your box | [CONFIGURE URL AND TLS ](#CFGURLTLS) |
|howto| Ask ISP for a 'full-stack' IPv4 address | [FULL-STACK IPV4](#FULLSTK)|


<br/>


<a name="TOC3"></a>

#### 3. External ressources:   

|Type| Description | Link |
|:-|:-|:-|
|API SDK|Freebox API SDK |[FreeboxOS API SDK](https://dev.freebox.fr/sdk/os)|
|API list|Freebox API list |[All FreeboxOS API](https://mafreebox.freebox.fr/#Fbx.os.app.help.app)|
|tool|Freebox Delta Virtual Machines management (complete bash tool) |***[fbxvm-ctrl](https://github.com/nbanb/fbxvm-ctrl)*** |


<br/>


___________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

___________________________________________________________________________________________


Quick Start
-----------

You need to have `curl` and `openssl` installed.

- #### Get the source:
```bash
$ curl -L https://github.com/nbanb/fbx-delta-nba_bash_api.sh/raw/nbanb-freebox-api/fbx-delta-nba_bash_api.sh > fbx-delta-nba_bash_api.sh
```

- #### Configure the library:

 Edit fbx-delta-nba_bash_api.sh and set a password for:
```bash
_APP_PASSWORD=""
```

 If you  are in Italy, set
 ```bash
ITALY="yes"
```


- #### Configure URL (optional but needed to access API over internet)

If you want to use your own URL (WAN or LAN), configure 'FREEBOX_xxx_URL=' and 'FREEBOX_xxx_CACERT=' 
If you are in Italy, configure 'ILIADBOX_xxx_URL=' and 'ILIADBOX_xxx_CACERT=' instead 

For the WAN URL, if your box is not reachable on HTTPS port 443, please add ':#PORT' to the WAN URL as it's done in the following example :

```bash
FREEBOX_WAN_URL="https://fbx.my-public-domain.net:4011"
FREEBOX_WAN_CACERT="/path/to/my/own/pki/ROOT/CA/CERTIFICATE"
```



- #### Get an application token for API access (APP_ID and APP_TOKEN)

To connect your freebox API, you must create and grant access to an application in your freebox
Use function 'authorize_application' to create an application token and grant access on the freebox LCD
```bash
$ source ./fbx-delta-nba_bash_api.sh
$ authorize_application  'MyWonderfull.app'  'My Wonderfull App'  '1.0.0'  'GNU Linux'
```


- #### Login and use lirary functions:

Login with your APP_ID and APP_TOKEN 
```bash
$ login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"
$ answer=$(call_freebox_api /system)
$ get_json_value_for_key "$answer" result.model_info.net_operator
```
```bash
free_fra
```


___________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

______________________________________________________________________________________

<a name="QSFULLEX"></a>

Quick Start FULL Example
-------------------------

Get the library
```bash
$ curl -L https://github.com/nbanb/fbx-delta-nba_bash_api.sh/raw/nbanb-freebox-api/fbx-delta-nba_bash_api.sh > fbx-delta-nba_bash_api.sh
```

Configure the library 
```bash
$ sed -i 's/^_APP_PASSWORD=""/_APP_PASSWORD="MySTRONGpassword"/' ./fbx-delta-nba_bash_api.sh 
$
$ # Next lines are optional, except if you want to access Freebox API over internet
$ sed -i 's|^FREEBOX_WAN_URL=""|FREEBOX_WAN_URL="https://fbx.my-public-domain.net:4011"|' ./fbx-delta-nba_bash_api.sh
$ sed -i 's|^FREEBOX_WAN_CACERT=""|FREEBOX_WAN_CACERT="/path/to/my/own/pki/ROOT/CA/CERTIFICATE"|' ./fbx-delta-nba_bash_api.sh
```

Create an application token which can access Freebox API
```bash
$ source ./fbx-delta-nba_bash_api.sh
$ authorize_application  'MyWonderfull.app'  'My Wonderfull App'  '1.0.0'  'GNU Linux'
Please grant/deny access to the application on the Freebox LCD...
Authorization granted

APP_ID="MyWonderfull.app"
APP_TOKEN="4uZTLMMwSyiPB42tSCWLpSSZbXIYi+d+F32tVMx2j1p8oSUUk4Awr/OMZne4RRlY"
```
##### For detailed procedure to get an APP_TOKEN see: [LOGIN](#LOGIN)

Now you can create an application 
```bash
$ cat my-box-uptime.sh
#!/bin/bash

MY_APP_ID="MyWonderfull.app"
MY_APP_TOKEN="4uZTLMMwSyiPB42tSCWLpSSZbXIYi+d+F32tVMx2j1p8oSUUk4Awr/OMZne4RRlY"

# source the fbx-delta-nba_bash_api.sh
source ./fbx-delta-nba_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"

# get system data
answer=$(call_freebox_api /system/)

# extract your box uptime 
uptime=$(get_json_value_for_key "${answer}" 'result.uptime')

# print the result
echo "My box is up since $uptime"
```


Or you can use the library's functions directly from your bash terminal
Create your 'logintomybox' file to source:
```bash
$ # configure 'logintomybox' with your APP_ID and APP_TOKEN
$  
$ echo "#!/bin/bash" >logintomybox
$ echo "source ./fbx-delta-nba_bash_api.sh" >>logintomybox
$ echo 'MY_APP_ID="PutHereYourAPP_ID"' >>logintomybox
$ echo 'MY_APP_TOKEN="PutHereYourAPP_TOKEN"' >>logintomybox
$ echo 'login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"' >>logintomybox
```
Now, you can source your 'logintomyfbx' file to access library function directly in your bash command shell:  
```bash  
$ source logintomybox
$  
$ # now you can use the library functions directly in your terminal: 
$ # ex: reboot your box (your app need to be granted to modify your box settings)
$ reboot_freebox
{"success":true}
```
##### If you get an error saying that your application is not granted to use this API, see: [GRANT API ACCESS](#GRANTAXX)



___________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

____________________________________________________________________________________________

<a name="API"></a>

API 
===


##### NOTE 
- Some underlying functions used by other functions of the API may NOT be listed in this README but you have here the most important functions for writing an application and for direct use in your bash cmdline.
- Frontend functions listed above can be used directlly like an end user program as they include their own check parameters engine and error / help output and when necessary tasks monitoring and task management.

___________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

_____________________________________________________________________________________________



<a name="LOGIN"></a>

LOGIN FUNCTIONS
---------------

### Obtain an application token / login / logout the API

#### *  authorize_application *app_id* *app_name* *app_version* *device_name*
It is used to obtain a token to identify a new application (need to be done only once)
##### Example
```bash
$ source ./fbx-delta-nba_bash_api.sh
$ authorize_application 'MyFbxVMapp' 'fbx VM control' '1.0.0-a' 'FreeboxVM-Linux'
Please grant/deny access to the app on the Freebox LCD...
Authorization granted

MY_APP_ID="MyFbxVMapp"
MY_APP_TOKEN="I7Sj+jpquj0rnPVSjLokXhy3gglOZflOQDTxjA8Vxdbma/VtoRwhR/nIluBuG8Wt"
```


##### Process
First run: 
```bash
source ./fbx-delta-nba_bash_api.sh
authorize_application 'MyFbxVMapp' 'fbx VM control' '1.0.0-a' 'FreeboxVM-Linux'
```
```bash
Please grant/deny access to the application on the Freebox LCD...

```
##### Picture
![fbxapp-w](https://user-images.githubusercontent.com/13208359/211529339-9cf1ff2e-1abb-4f30-9f8e-1ddf662eef44.png)

Now grant access on Feeebox LCD :  
- Your applications APP_ID and APP_NAME and APP_VERSION and DEVICE_NAME will be scrolling on the Freebox LCD
(sorry for the picture, application name scrolling on the LCD is fast, I didn't succeed in taking a readable picture) 

![fbx-vapp](https://user-images.githubusercontent.com/13208359/211530100-0f518469-0c62-43dd-bd09-4356de3d8f91.png)

- Select the tic to validate

![fbx-val0](https://user-images.githubusercontent.com/13208359/211530899-272062af-ea56-460c-8676-c9315627c70c.png)

- You must see 'YES' displayed on the LCD in your box current language (in France you will see 'OUI')
- If needed, tic again to validate

![fbx-val-ok](https://user-images.githubusercontent.com/13208359/211531303-c2f09336-3958-460d-9e29-46880d174148.png)

And now on your bash terminal, you will see your APP_ID and APP_TOKEN printed : 
```bash
$ authorize_application 'MyFbxVMapp' 'fbx VM control' '1.0.0-a' 'FreeboxVM-Linux'
Please grant/deny access to the application on the Freebox LCD...
Authorization granted

MY_APP_ID="MyFbxVMapp"
MY_APP_TOKEN="I7Sj+jpquj0rnPVSjLokXhy3gglOZflOQDTxjA8Vxdbma/VtoRwhR/nIluBuG8Wt"
```

##### Picture:
![fbxapp-ok](https://user-images.githubusercontent.com/13208359/211531771-673551f6-30f7-4a30-8c8c-57562ab94f0e.png)



___________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|


-------------------------------------------------------------------------------



#### *  login_freebox *app_id* *app_token*
It is used to log in the application to the freebox API  (you need the application token obtain from authorize_application function).
WARNING : 
The original function had been modified and renamed to login_fbx as it's now used as an underlying function called by login_freebox which login and also publish to subshell 2 variables (_APP_ID and _APP_ENCRYPTED_TOKEN). Those 2 variables are used by the library to auto re-login when the session had timeout but you're watching for a task that is longer than the session timeout. 

##### Example
```bash
#!/bin/bash

MY_APP_ID="MyWonderfull.app"
MY_APP_TOKEN="4uZTLMMwSyiPB42tSCWLpSSZbXIYi+d+F32tVMx2j1p8oSUUk4Awr/OMZne4RRlY"

# source the fbx-delta-nba_bash_api.sh
source ./fbx-delta-nba_bash_api.sh

# login
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"
```

-------------------------------------------------------------------------------


#### *  logout_freebox 
It is used to logout the session opened by the application 
Return 0 if success, 1 otherwise 
##### Example
```bash
logout_freebox
```

-------------------------------------------------------------------------------


#### *  check_login_freebox 
It is used to check the status of the login session opened by the application
Return 0 if success, 1 otherwise 
##### Example
```bash
check_login_freebox
```

-------------------------------------------------------------------------------


#### *  app_login_freebox 
After a first sucessfull login using function 'login_freebox', this function is able to retrieve credential from environnment variables (_APP_ID and _APP_ENCRYPTED_TOKEN) and to perform a login from the application or the library itself
Return 0 if success, 1 otherwise
##### Example
```bash
app_login_freebox
```

-------------------------------------------------------------------------------


#### *  relogin_freebox 
After a first sucessfull login using function 'login_freebox', this function is able to check the connection status and if the session is closed this function will re-login automatically from the application or from the library itself
Return 0 if success, 1 otherwise
##### Example
```bash
relogin_freebox
```


| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

____________________________________________________________________________________________

<a name="CALL"></a>


API CALL FUNCTIONS
---------------


#### *  call_freebox_api *api_path* *{optionnal_json_object}*
It is used to call a freebox API. This function make an HTTP GET request if no parameters are specified, and make an HTTP POST request if you provide '{optionnal_json_object}' parameter. 
The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](https://dev.freebox.fr/sdk/os/#api-list) or a more up-to-date developer documentation including specificities of your box directly in FreeboxOS [here](https://mafreebox.freebox.fr/#Fbx.os.app.help.app)
##### Example
```bash
answer=$(call_freebox_api '/connection/xdsl')
```

-------------------------------------------------------------------------------



#### *  add_freebox_api *api_path* *{json_object}*
It is used to call a freebox API with a define HTTP POST request forcing "Content-Type: application/json" header. 
The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](https://dev.freebox.fr/sdk/os/#api-list) or a more up-to-date developer documentation including specificities of your box directly in FreeboxOS [here](https://mafreebox.freebox.fr/#Fbx.os.app.help.app)
##### Example
```bash
answer=$(add_freebox_api '/vm/create' '{create_vm_json_object}')
```

-------------------------------------------------------------------------------


#### *  get_freebox_api *api_path* *URLoptions*
It is used to call a freebox API with a define HTTP GET request forcing parameter encoding in "with data-www-urlencode" format. 
The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](https://dev.freebox.fr/sdk/os/#api-list) or a more up-to-date developer documentation including specificities of your box directly in FreeboxOS [here](https://mafreebox.freebox.fr/#Fbx.os.app.help.app)
##### Example
```bash
answer=$(get_freebox_api "/fs/ls/${base64_file_path}" "{fs_opts[@]}" 2>&1)
```

-------------------------------------------------------------------------------



#### *  update_freebox_api *api_path* *{json_object}*
It is used to call a freebox API with a define HTTP PUT request forcing "Content-Type: application/json" header. The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](https://dev.freebox.fr/sdk/os/#api-list) or a more up-to-date developer documentation including specificities of your box directly in FreeboxOS [here](https://mafreebox.freebox.fr/#Fbx.os.app.help.app)
##### Example
```bash
answer=$(update_freebox_api '/vm/8' '{update_vm_json_object}')
```

-------------------------------------------------------------------------------



#### *  del_freebox_api *api_path*
It is used to call a freebox API with a define HTTP DELETE request. The function will return a json string with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available api [here](https://dev.freebox.fr/sdk/os/#api-list) or a more up-to-date developer documentation including specificities of your box directly in FreeboxOS [here](https://mafreebox.freebox.fr/#Fbx.os.app.help.app)
##### Example
```bash
answer=$(del_freebox_api '/vm/8')
```

-------------------------------------------------------------------------------



#### *  call_freebox-ws_api *api_path*
It is used to call a freebox Websocket API with websocket request. It need you install 'websocat' from [here](https://github.com/vi/websocat/) The function will return a websocket interractive connection and exit with an exit code of 0 if successfull. Otherwise it will return an empty string with an exit code of 1 and the reason of the error output to STDERR.
You can find the list of all available websocket api directly in FreeboxOS [here](https://mafreebox.freebox.fr/#Fbx.os.app.help.app)
##### Example
```bash
answer=$(call_freebox-ws_api '/vm/8/console')
```

-------------------------------------------------------------------------------



#### *  get_json_value_for_key *json_string* *key*
This function will return the value for the *key* from the *json_string*
##### Example
```bash
value=$(get_json_value_for_key "$answer" 'result.down.maxrate')
```

-------------------------------------------------------------------------------


#### *  dump_json_keys_values *json_string*
This function will dump on stdout all the keys values pairs from the *json_string*
##### Example
```bash
answer=$(call_freebox_api '/connection/')
dump_json_keys_values "$answer"
echo
bytes_down=$(get_json_value_for_key "$answer" 'result.bytes_down')
echo "bytes_down: $bytes_down"
```
<pre>
success = true
result.type = rfc2684
result.rate_down = 40
result.bytes_up = 945912
result.rate_up = 0
result.bandwidth_up = 412981
result.ipv6 = 2a01:e35:XXXX:XXX::1
result.bandwidth_down = 3218716
result.media = xdsl
result.state = up
result.bytes_down = 2726853
result.ipv4 = XX.XXX.XXX.XXX
result = {"type":rfc2684,"rate_down":40,"bytes_up":945912,"rate_up":0,"bandwidth_up":412981,"ipv6":2a01:e35:XXXX:XXXX::1,"bandwidth_down":3218716,"media":xdsl,"state":up,"bytes_down":2726853,"ipv4":XX.XXX.XXX.XXX}

bytes_down: 2726853</pre>


-------------------------------------------------------------------------------



#### *  _check_success
This function will check if last command/function result is successfull. It is not a "system logical test"but a check on the answer returned by the API. It check that "success" has for value 'true' in API reply:  {"success":true,"result":{...}}
Return 0 if success, 1 otherwise 
##### Example
```bash
$ answer=$(call_freebox_api downloads/add '{}')
Erreur lors de l'ajout du téléchargement: invalid_request
$ _check_success ${answer}
$ echo $?
1
```

___________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

____________________________________________________________________________________________

<a name="STATUS"></a>

API STATUS FUNCTIONS
-----------------

#### *  status_freebox
This function will return a json containing your freebox global status/infos (CPU, TEMP, FAN, DISK, etc). 
To be parsed by the script calling this function.
Return code will be 0 if the freebox is alive and send its status, 1 otherwise.
##### Example
```bash
status_freebox
```
Result : 
```bash
{"success":true,"result":{"mac":"34:27:92:xx:xx:xx","sensors":[{"id":"temp_hdd1","name":"Disque dur 2","value":39},{"id":"temp_hdd3","name":"Disque dur 4","value":40},{"id":"temp_hdd2","name":"Disque dur 3","value":45},{"id":"temp_hdd0","name":"Disque dur 1","value":47},{"id":"temp_t2","name":"Température 2","value":51},{"id":"temp_t1","name":"Température 1","value":47},{"id":"temp_t3","name":"Température 3","value":47},{"id":"temp_cpu_cp_slave","name":"Température CPU CP Slave","value":80},{"id":"temp_cpu_ap","name":"Température CPU AP","value":71},{"id":"temp_cpu_cp_master","name":"Température CPU CP Master","value":80}],"model_info":{"customer_hdd_slots":4,"net_operator":"free_fra","supported_languages":["fra"],"has_dsl":true,"has_dect":true,"wifi_country":"FR","has_home_automation":true,"wifi_type":"2d4_5g_5g","pretty_name":"Freebox v7 (r1)","has_lan_sfp":true,"name":"fbxgw7-r1\/full","has_separate_internal_storage":true,"internal_hdd_size":0,"default_language":"fra","has_vm":true,"has_expansions":true},"fans":[{"id":"fan1_speed","name":"Ventilateur 2","value":2401},{"id":"fan0_speed","name":"Ventilateur 1","value":4208}],"expansions":[{"type":"security","present":true,"slot":1,"probe_done":true,"supported":true,"bundle":"985700J12345678"},{"type":"ftth_pon","present":true,"slot":2,"probe_done":true,"supported":true,"bundle":"955800A12345678"}],"board_name":"fbxgw7r","disk_status":"active","uptime":"8 jours 14 heures 53 minutes 21 secondes","uptime_val":744801,"user_main_storage":"FBX-500G","box_authenticated":true,"serial":"957602K123456789","firmware_version":"4.5.7"}}
```


-------------------------------------------------------------------------------



#### *  full_vm_detail
This function will print all json_vm_objects defined in the freebox
##### Example
```bash
full_vm_detail 
```
Result :
```bash
{"success":true,"result":[{"mac":"ce:3e:20:b9:66:fc","cloudinit_userdata":"","cd_path":"","id":0,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-wLnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-00","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"3e:6e:bd:2b:fe:c7","cloudinit_userdata":"","cd_path":"","id":1,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-zLnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-03","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"ae:2c:8c:f6:3e:fb","cloudinit_userdata":"","cd_path":"","id":2,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-xLnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-01","cloudinit_hostname":"","status":"running","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"5a:e3:85:db:26:ee","cloudinit_userdata":"","cd_path":"","id":3,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-yLnFjb3cy","vcpus":1,"memory":4096,"name":"14RV-FSRV-02","cloudinit_hostname":"","status":"running","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"5e:e3:3a:13:ab:20","cloudinit_userdata":"","cd_path":"","id":4,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-0LnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-04","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"be:dd:fc:cc:53:8d","cloudinit_userdata":"","cd_path":"","id":5,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-1LnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-05","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"ba:81:13:4f:2f:4e","cloudinit_userdata":"","cd_path":"","id":6,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-2LnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-06","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"da:05:e4:43:33:5d","cloudinit_userdata":"","cd_path":"","id":7,"os":"unknown","enable_cloudinit":false,"disk_path":"freebox-disk-path-3LnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-07","cloudinit_hostname":"","status":"stopped","bind_usb_ports":"","enable_screen":false,"disk_type":"qcow2"},{"mac":"ce:3c:ee:b4:f4:f0","cloudinit_userdata":"ssh_authorized_keys:\n- ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAGEA3FSyQwBI6Z+nCSjUUk8EEAnnkhXlukKoUPND\/RRClWz2s5TCzIkd3Ou5+Cyz71X0XmazM3l5WgeErvtIwQMyT1KjNoMhoJMrJnWqQPOt5Q8zWd9qG7PBl9+eiH5qV7NZ mykey@host\n- ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3I7VUf2l5gSn5uavROsc5HRDpZdQueUq5ozemNSj8T7enqKHOEaFoU2VoPgGEWC9RyzSQVeyD6s7APMcE82EtmW4skVEgEGSbDc1pvxzxtchBj78hJP6Cf5TCMFSXw+Fz5rF1dR23QDbN1mkHs7adr8GW4kSWqU7Q7NDwfIrJJtO7Hi42GyXtvEONHbiRPOe8stqUly7MvUoN+5kfjBM8Qqpfl2+FNhTYWpMfYdPUnE7u536WqzFmsaqJctz3gBxH9Ex7dFtrxR4qiqEr9Qtlu3xGn7Bw07\/+i1D+ey3ONkZLN+LQ714cgj8fRS4Hj29SCmXp5Kt5\/82cD\/VN3NtHw== smoser@brickies\n8ssh_keys:\nrsa_private: |\n -----BEGIN RSA PRIVATE KEY-----\n MIIBxwIBAAJhAKD0YSHy73nUgysO13XsJmd4fHiFyQ+00R7VVu2iV9Qcon2LZS\/x\n 1cydPZ4pQpfjEha6WxZ6o8ci\/Ea\/w0n+0HGPwaxlEG2Z9inNtj3pgFrYcRztfECb\n 1j6HCibZbAzYtwIBIwJgO8h72WjcmvcpZ8OvHSvTwAguO2TkR6mPgHsgSaKy6GJo\n PUJnaZRWuba\/HX0KGyhz19nPzLpzG5f0fYahlMJAyc13FV7K6kMBPXTRR6FxgHEg\n L0MPC7cdqAwOVNcPY6A7AjEA1bNaIjOzFN2sfZX0j7OMhQuc4zP7r80zaGc5oy6W\n p58hRAncFKEvnEq2CeL3vtuZAjEAwNBHpbNsBYTRPCHM7rZuG\/iBtwp8Rxhc9I5w\n ixvzMgi+HpGLWzUIBS+P\/XhekIjPAjA285rVmEP+DR255Ls65QbgYhJmTzIXQ2T9\n luLvcmFBC6l35Uc4gTgg4ALsmXLn71MCMGMpSWspEvuGInayTCL+vEjmNBT+FAdO\n W7D4zCpI43jRS9U06JVOeSc9CDk2lwiA3wIwCTB\/6uc8Cq85D9YqpM10FuHjKpnP\n REPPOyrAspdeOAV+6VKRavstea7+2DZmSUgE\n -----END RSA PRIVATE KEY-----\n\nrsa_public: ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAGEAoPRhIfLvedSDKw7XdewmZ3h8eIXJD7TRHtVW7aJX1ByifYtlL\/HVzJ09nilCl+MSFrpbFnqjxyL8Rr\/DSf7QcY\/BrGUQbZn2Kc22PemAWthxHO18QJvWPocKJtlsDNi3 smoser@localhost\n\ndsa_private: |\n -----BEGIN DSA PRIVATE KEY-----\n MIIBuwIBAAKBgQDP2HLu7pTExL89USyM0264RCyWX\/CMLmukxX0Jdbm29ax8FBJT\n pLrO8TIXVY5rPAJm1dTHnpuyJhOvU9G7M8tPUABtzSJh4GVSHlwaCfycwcpLv9TX\n DgWIpSj+6EiHCyaRlB1\/CBp9RiaB+10QcFbm+lapuET+\/Au6vSDp9IRtlQIVAIMR\n 8KucvUYbOEI+yv+5LW9u3z\/BAoGBAI0q6JP+JvJmwZFaeCMMVxXUbqiSko\/P1lsa\n LNNBHZ5\/8MOUIm8rB2FC6ziidfueJpqTMqeQmSAlEBCwnwreUnGfRrKoJpyPNENY\n d15MG6N5J+z81sEcHFeprryZ+D3Ge9VjPq3Tf3NhKKwCDQ0240aPezbnjPeFm4mH\n bYxxcZ9GAoGAXmLIFSQgiAPu459rCKxT46tHJtM0QfnNiEnQLbFluefZ\/yiI4DI3\n 8UzTCOXLhUA7ybmZha+D\/csj15Y9\/BNFuO7unzVhikCQV9DTeXX46pG4s1o23JKC\n \/QaYWNMZ7kTRv+wWow9MhGiVdML4ZN4XnifuO5krqAybngIy66PMEoQCFEIsKKWv\n 99iziAH0KBMVbxy03Trz\n -----END DSA PRIVATE KEY-----\n\ndsa_public: ssh-dss AAAAB3NzaC1kc3MAAACBAM\/Ycu7ulMTEvz1RLIzTbrhELJZf8Iwua6TFfQl1ubb1rHwUElOkus7xMhdVjms8AmbV1Meem7ImE69T0bszy09QAG3NImHgZVIeXBoJ\/JzByku\/1NcOBYilKP7oSIcLJpGUHX8IGn1GJoH7XRBwVub6Vqm4RP78C7q9IOn0hG2VAAAAFQCDEfCrnL1GGzhCPsr\/uS1vbt8\/wQAAAIEAjSrok\/4m8mbBkVp4IwxXFdRuqJKSj8\/WWxos00Ednn\/ww5QibysHYULrOKJ1+54mmpMyp5CZICUQELCfCt5ScZ9GsqgmnI80Q1h3Xkwbo3kn7PzWwRwcV6muvJn4PcZ71WM+rdN\/c2EorAINDTbjRo97NueM94WbiYdtjHFxn0YAAACAXmLIFSQgiAPu459rCKxT46tHJtM0QfnNiEnQLbFluefZ\/yiI4DI38UzTCOXLhUA7ybmZha+D\/csj15Y9\/BNFuO7unzVhikCQV9DTeXX46pG4s1o23JKC\/QaYWNMZ7kTRv+wWow9MhGiVdML4ZN4XnifuO5krqAybngIy66PMEoQ= smoser@localhost\n\nno_ssh_fingerprints: false\nssh:\nemit_keys_to_console: false","cd_path":"L0ZCWDI0VC9pc28vZGViaWFuLTExLjAuMC1hcm02NC1EVkQtMS5pc28=","id":8,"os":"debian","enable_cloudinit":true,"disk_path":"freebox-disk-path-4LnFjb3cy","vcpus":1,"memory":2048,"name":"14RV-FSRV-08","cloudinit_hostname":"14RV-FSRV-2048","status":"stopped","bind_usb_ports":["usb-external-type-c","usb-external-type-a"],"enable_screen":true,"disk_type":"qcow2"}]}
```

-------------------------------------------------------------------------------



#### *  vm_resource
This function will print a json containing availiable ressources for VM on freebox chassis
##### Example
```bash
vm_resource 
```
Result :
```bash
{"success":true,"result":{"usb_used":false,"sata_used":false,"sata_ports":["sata-internal-p0","sata-internal-p1","sata-internal-p2","sata-internal-p3"],"used_memory":8192,"usb_ports":["usb-external-type-a","usb-external-type-c"],"used_cpus":3,"total_memory":15360,"total_cpus":3}}
```


___________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

____________________________________________________________________________________________

<a name="CHECK"></a>

API CHECK FUNCTIONS
-----------------


#### *  check_tool *program_name*
This function will check for external tool needed when running this program. Return code will be 0 if tool is installed and exit with a return code of 31 otherwise.
##### Example
```bash
check_tool websocat
```

```bash

websocat could not be found. Please install websocat

websocat install on amd64/emt64    
$ curl -L https://github.com/vi/websocat/releases/download/v1.11.0/websocat.x86_64-unknown-linux-musl >websocat-1.11_x86_64
$ sudo cp websocat-1.11_x86_64 /usr/bin/websocat-1.11_x86_64
$ sudo ln -s /usr/bin/websocat-1.11_x86_64 /usr/bin/websocat
$ sudo chmod +x /usr/bin/websocat-1.11_x86_64

websocat install on arm64: aarch64
$ curl -L https://github.com/vi/websocat/releases/download/v1.11.0/websocat.aarch64-unknown-linux-musl >websocat-1.11_aarch64 
$ sudo cp websocat-1.11_aarch64 /usr/bin/websocat-1.11_aarch64
$ sudo ln -s /usr/bin/websocat-1.11_aarch64 /usr/bin/websocat
$ sudo chmod +x /usr/bin/websocat-1.11_aarch64

```

-------------------------------------------------------------------------------


#### *  check_tool_exit *program_name*
This function is used inernally and is called by check_tool() function as it's underlying check process. Return code will be 0 if check is successfull, and exit with a return code of 1 otherwise.
NOTE: you should not use this function directly
##### Example
```bash
check_tool_exit websocat
```

-------------------------------------------------------------------------------


#### *  check_if_ip *string*
This function will check if the provided argument is an IP address. Return code will be 0 if the provided argument is an IP address, and will exit with a return code of 1 if argument is not a valid IP address.
##### Example
```bash
check_if_ip 123.123.123
echo $?
```

-------------------------------------------------------------------------------


#### *  check_if_rfc1918 *string*
This function will check if the provided argument is an IP address defines in [RFC1918](https://www.ietf.org/rfc/rfc1918.txt). Return code will be 0 if the provided argument is an IP address defined in RFC1918, and will exit with a return code of 1 if argument is not a valid RFC1918 IP address.
##### Example
```bash
check_if_rfc1918 10.10.10.10
echo $?
```

-------------------------------------------------------------------------------


#### *  check_if_port *string*
This function will check if the provided argument is a valid port in range [1-65535]. Return code will be 0 if the provided argument is a valid port, and will exit with a return code of 1 if argument is not a valid port.
##### Example
```bash
check_if_port 4011
echo $?
```

-------------------------------------------------------------------------------


#### *  check_if_mac *string*
This function will check if the provided argument is a MAC address (only REGEX check on syntaxe, no call to the 'OUI' database). Return code will be 0 if the provided argument is a MAC address, and will exit with a return code of 1 if argument is not a valid MAC address.
##### Example
```bash
check_if_mac 00:a3:b6:c9:da:fb
echo $?
```

___________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

____________________________________________________________________________________________


### API FRONTEND - MINDSET 

- The new FRONTEND functions of this library are usable directly as if they were some complete command or program 
- For all categories of API for which some frontend functions had been developped (DOWNLOAD, FILESYSTEM,...) you will always find the same mechanisme : 
	- Each categories has a listing function which can list API Objects or API Tasks
	- Each categories has a 'check_and_feed_XXX_param' for validating the arguement parameters and syntax
	- Each categories has a 'param_XXX_err' function which manage errors and print help / examples when necessary
	- Each function had a nice human readable output   


___________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

____________________________________________________________________________________________

<a name="DOWNLOAD"></a>


API FRONTEND FUNCTIONS - DOWNLOAD
-----------------

This API let you create download tasks, modify download tasks, monitor download tasks, list downloads tasks or show a particula tasks and finaly delete download tasks 
You can also retrieve download tasks logs.


-------------------------------------------------------------------------------


#### *  check_and_feed_dl_param *array_of_strings*
This function will check if the provided arguments are valid parameters for the function which is calling it depending of the "action" set by the calling function. If not, function param_dl_err will be called to set error and display help for the command depending on "action" set by the calling function. "action" are: 'add, enc, upd, show, del, mon, adv, log'. This function return a 'json' object or an 'as it must be formated object for the command' to be passed to "API CALL" functions
##### Example
```bash
action=enc
check_and_feed_dl_param download_url="https://images.jeedom.com/freebox/freeboxDelta.qcow2" hash="https://images.jeedom.com/freebox/SHA256SUMS" download_dir="/FBX24T/dl/vmimage/" filename="MyJedomDelta-efi-aarch64-nba0.qcow2"
echo -e  "${dl_enc_param_object}"
```
```bash
 download_url=https://images.jeedom.com/freebox/freeboxDelta.qcow2 hash=https://images.jeedom.com/freebox/SHA256SUMS download_dir=L0ZCWDI0VC9kbC92bWltYWdlLw== filename=MyJedomDelta-efi-aarch64-nba0.qcow2     
```

-------------------------------------------------------------------------------

#### *  param_dl_err
This function will display help / manual and example on the command which calling it, depending of the "action" set by the calling function. This function also set variable "error=1". "error" variable content is always checked before each API execution, and if error=1, nothing happends and the lib exit cleanly. "action" are: 'add, enc, upd, show, del, mon, adv, log'. This function return error=1 when it has been called
This function is mostly called by 'check_and_feed_dl_param' function 

-------------------------------------------------------------------------------

#### *  add_dl_task_api *array_of_strings*
This function will add a download task BUT DOES NOT urlencode parameters. 
For the freebox accept the request and for the action of adding a download task work, you must specify '--data-urlencode' option before ALL of the different parameters you pass to the function
##### Example
```bash
add_dl_task_api
```
```bash
task parameters missing !

ERROR: all <param> for "add_dl_task_api" must be preceded by '--data-urlencode' and must be some of:
download_url= 		# URL to download
hash=			# URL of hash file - hash format: MD5SUMS SHAxxxSUMS file or file.md5 or file.shaXXX 
download_dir= 		# Download directory (will be created if not exist)
filename= 		# Name of downloaded file 
recursive= 		# if set to 'true' download will be recursive
username= 		# (Optionnal) remote URL username 
password= 		# (Optionnal) remote URL password 
cookie1= 		# (Optionnal) content of HTTP Cookie header - to pass session cookie 
cookie2= 		# (Optionnal) second HTTP cookie 
cookie3= 		# (Optionnal) third HTTP cookie

NOTE: minimum parameters to specify on cmdline to create a download task: 
download_url= 

EXAMPLE (simple):
add_dl_task_api --data-urlencode "download_url=https://images.jeedom.com/freebox/freeboxDelta.qcow2"

EXAMPLE (medium):
add_dl_task_api --data-urlencode "download_url=https://images.jeedom.com/freebox/freeboxDelta.qcow2" --data-urlencode "hash=https://images.jeedom.com/freebox/SHA256SUMS" --data-urlencode "download_dir=/FBX24T/dl/vmimage/" --data-urlencode "filename=MyJedomDelta-efi-aarch64-nba0.qcow2"

EXAMPLE (full):
add_dl_task_api --data-urlencode "download_url=https://my-private-mirror.net/freebox/MyPrivateFreeboxVM_Image.qcow2" --data-urlencode "hash=https://my-private-mirror.net/freebox/MyPrivateFreeboxVM_Image.qcow2.sha512" --data-urlencode "download_dir=/FBX24T/dl/vmimage/" --data-urlencode "filename=MyNewVMimage-efi-aarch64.qcow2" --data-urlencode "username=MyUserName" --data-urlencode "password=VerySecret" --data-urlencode "recursive=false" --data-urlencode cookie1="MyHTTPsessionCookie" --data-urlencode cookie2="MyStickysessionCookie" --data-urlencode cookie3="MyAuthTokenCookie" 
```

##### Picture 
![add_dl](https://user-images.githubusercontent.com/13208359/211081579-21436cbd-41aa-432a-80b2-46fed180abce.png)

```bash
add_dl_task_api --data-urlencode "download_url=https://images.jeedom.com/freebox/freeboxDelta.qcow2" --data-urlencode "hash=https://images.jeedom.com/freebox/SHA256SUMS" --data-urlencode "download_dir=/FBX24T/dl/vmimage/" --data-urlencode "filename=MyJedomDelta-efi-aarch64-nba0.qcow2"
```
```bash
{"success":true,"result":{"id":476}}
```


-------------------------------------------------------------------------------


#### *  enc_dl_task_api *array_of_strings*
This function will add a download task AND urlencode parameters. 
See example in the output of the function (when called with no parameters)
This function return 0 if successfull and 1 otherwise
##### Example
```bash
enc_dl_task_api
```
```bash
task parameters missing !

ERROR: <param> for "enc_dl_task_api" must be some of:
download_url= 		# URL to download
hash=			# URL of hash file - hash format: MD5SUMS SHAxxxSUMS file or file.md5 or file.shaXXX 
download_dir= 		# Download directory (will be created if not exist)
filename= 		# Name of downloaded file 
recursive= 		# if set to 'true' download will be recursive
username= 		# (Optionnal) remote URL username 
password= 		# (Optionnal) remote URL password 
cookie1= 		# (Optionnal) content of HTTP Cookie header - to pass session cookie 
cookie2= 		# (Optionnal) second HTTP cookie 
cookie3= 		# (Optionnal) third HTTP cookie

NOTE: minimum parameters to specify on cmdline to create a download task: 
download_url= 

EXAMPLE (simple):
enc_dl_task_api download_url="https://images.jeedom.com/freebox/freeboxDelta.qcow2"

EXAMPLE (medium):
enc_dl_task_api download_url="https://images.jeedom.com/freebox/freeboxDelta.qcow2" hash="https://images.jeedom.com/freebox/SHA256SUMS" download_dir="/FBX24T/dl/vmimage/" filename="MyJedomDelta-efi-aarch64-nba0.qcow2"

EXAMPLE (full):
enc_dl_task_api download_url="https://my-private-mirror.net/freebox/MyPrivateFreeboxVM_Image.qcow2" hash="https://my-private-mirror.net/freebox/MyPrivateFreeboxVM_Image.qcow2.sha512" download_dir="/FBX24T/dl/vmimage/" filename="MyNewVMimage-efi-aarch64.qcow2" username="MyUserName" password="VerySecret" recursive="false" cookie1="MyHTTPsessionCookie" cookie2="MyStickysessionCookie" cookie3="MyAuthTokenCookie" 

```

##### Picture 
![enc_dl](https://user-images.githubusercontent.com/13208359/211081674-9e5e5e3a-7be2-47cc-ab20-557615fb6160.png)

```bash
enc_dl_task_api download_url="https://images.jeedom.com/freebox/freeboxDelta.qcow2" hash="https://images.jeedom.com/freebox/SHA256SUMS" download_dir="/FBX24T/dl/vm0/" filename="MyJedomDelta-efi-aarch64-nba0.qcow2"
```
```bash
{"success":true,"result":{"id":477}}
```
```bash
show_dl_task_api 477
```
```bash
					SHOW DOWNLOADS TASK: 

------------------------------------------------------------------------------------------------------------------------
id: 477	queue_pos: 12		timestamp: 20230109-10:54:44	size: 2 GB	%in: 3 % 	%out: 100 %
	status: downloading	I/O: normal	path: /FBX24T/dl/vm0/
	error: none		end-in: 654s	name: MyJedomDelta-efi-aarch64-nba0.qcow2
------------------------------------------------------------------------------------------------------------------------

```

##### Picture 
![enc_dlshow](https://user-images.githubusercontent.com/13208359/211282724-fbef7746-15dc-43f5-ad24-63e8e381efce.png)


-------------------------------------------------------------------------------


#### *  list_dl_task_api
This function will list all download tasks and display result in a pretty human readable format. 
##### Example
```bash
list_dl_task_api
```
```bash

					LIST OF DOWNLOADS TASKS:

------------------------------------------------------------------------------------------------------------------------
id: 256	queue_pos: 1		timestamp: 20221206-22:24:50	size: 9 GB	%in: 100 % 	%out: 100 %
	status: done		I/O: normal	path: /FBX24T/dl
	error: none		end-in: 0s	name: delta-10G-N.tar.gz
------------------------------------------------------------------------------------------------------------------------
id: 335	queue_pos: 2		timestamp: 20221223-15:32:13	size: 1 GB	%in: 0 % 	%out: 100 %
	status: error		I/O: normal	path: [error:no_download_dir_availiable]
	error: http_4xx		end-in: 0s	name: CentOS-8-GenericCloud-8.4.2105-20210603.0.aarch64.qcow2
------------------------------------------------------------------------------------------------------------------------
id: 435	queue_pos: 3		timestamp: 20221227-19:59:09	size: 290 MB	%in: 100 % 	%out: 100 %
	status: done		I/O: normal	path: /FBX24T/dl/vm6
	error: none		end-in: 0s	name: deb11-arm64.qcow2
------------------------------------------------------------------------------------------------------------------------
id: 436	queue_pos: 4		timestamp: 20221228-12:05:25	size: 500 MB	%in: 0 % 	%out: 100 %
	status: error		I/O: normal	path: L0ZCWDI0VC9kbA==
	error: http_4xx		end-in: 0s	name: delta-opensuze-N85.qcow2
------------------------------------------------------------------------------------------------------------------------
id: 449	queue_pos: 5		timestamp: 20221229-10:27:42	size: 9 GB	%in: 100 % 	%out: 100 %
	status: done		I/O: high	path: /FBX24T/dl/vm0
	error: none		end-in: 0s	name: delta-10G-8.tar.gz
------------------------------------------------------------------------------------------------------------------------
id: 450	queue_pos: 6		timestamp: 20221229-10:42:32	size: 9 GB	%in: 100 % 	%out: 100 %
	status: done		I/O: high	path: /FBX24T/dl/vm0
	error: none		end-in: 0s	name: delta-10G-9.tar.gz
------------------------------------------------------------------------------------------------------------------------
...

```

##### Picture 
![list_dl](https://user-images.githubusercontent.com/13208359/211082906-39d20b50-d422-4ba2-a2d1-d87117516371.png)



-------------------------------------------------------------------------------


#### *  show_dl_task_api *integer*
This function will show a particular download task and display result in a pretty human readable format. 
##### Example
```bash
show_dl_task_api 
```
```bash

ERROR: <param> must be :
id

NOTE: you can get a list of download tasks (showing all 'id'), just run: 
list_dl_task_api

EXAMPLE:
show_dl_task_api 450

```

##### Picture 
![show0_dl](https://user-images.githubusercontent.com/13208359/211083649-89321aa5-10c3-4047-830c-7fae13f6bdbb.png)


```bash
show_dl_task_api 450
```
```bash

					SHOW DOWNLOADS TASK: 

------------------------------------------------------------------------------------------------------------------------
id: 450	queue_pos: 6		timestamp: 20221229-10:42:32	size: 9 GB	%in: 100 % 	%out: 100 %
	status: done		I/O: high	path: /FBX24T/dl/vm0
	error: none		end-in: 0s	name: delta-10G-9.tar.gz
------------------------------------------------------------------------------------------------------------------------

```

##### Picture  
![show_dl](https://user-images.githubusercontent.com/13208359/211084527-f7968f7b-3be7-452e-9e7c-420d777b9f4a.png)


-------------------------------------------------------------------------------



#### *  upd_dl_task_api *array_of_strings*
This function will update a download task.
You can change the disk IO priority, the queue position of the concerned download task and you can also modify the status of the task. 
Valid status are : stopped, downloading, queued, retry
NOTE: "stopped" pause the download task and "downloading" restart it where "retry" retried a failed task  
##### Example
```bash
upd_dl_task_api 
```
```bash

ERROR: <param> for "upd_dl_task_api" must be some of:
id 			# Task id: MUST be a number
io_priority= 		# Disk IO priority: high normal or low
status= 		# Status action: stopped or downloading or queued or retry
queue_pos= 		# Task position in queue - 1= immediate download

NOTE: minimum parameters to specify on cmdline to update a download task: 
id 
io_priority= or/and status= or/and queue_pos= 

EXAMPLE:
upd_dl_task_api 15 io_priority="high" queue_pos="1" status="retry"

```

##### Picture  
![upd_dl](https://user-images.githubusercontent.com/13208359/211085526-9e2f2b32-b2f2-4d82-8efd-b4d19ba0fff2.png)

##### Example
Here we will update the download task #478: We will modify io_priority from "normal" to "high"
First, constat the  io_priority of task 478 with function show_dl_task_api
```bash
show_dl_task_api 478 
```
```bash
					SHOW DOWNLOADS TASK: 

------------------------------------------------------------------------------------------------------------------------
id: 478	queue_pos: 13		timestamp: 20230110-16:28:48	size: 9 GB	%in: 26 % 	%out: 100 %
	status: downloading	I/O: normal	path: /FBX24T/dl/vm0
	error: none		end-in: 43s	name: delta-10G-881.tar.gz
------------------------------------------------------------------------------------------------------------------------
```
##### Picture  
![upd_dl_n](https://user-images.githubusercontent.com/13208359/211594826-25660fde-3274-41fc-9227-3ba67f35e4d9.png)

Now we will update the 'io_priority' of the task:
```bash
upd_dl_task_api 478 io_priority="high"
```
```bash

operation completed: 
{"success":true}

result:
{"rx_bytes":5260000000,"tx_bytes":0,"download_dir":"L0ZCWDI0VC9kbC92bTA=","archive_password":"","eta":26,"status":"downloading","io_priority":"high","type":"http","piece_length":0,"queue_pos":13,"id":478,"info_hash":"","created_ts":1673364528,"stop_ratio":0,"tx_rate":0,"name":"delta-10G-881.tar.gz","tx_pct":10000,"rx_pct":5260,"rx_rate":177610000,"error":"none","size":10000000000}

```
##### Picture  
![upd_dl_u](https://user-images.githubusercontent.com/13208359/211595334-efac2bf8-4e81-4906-8233-b4f03e49b04e.png)

And now, constat that the 'io_priority' property had been updated with function show_dl_task_api:

```bash
show_dl_task_api 478 
```
```bash
					SHOW DOWNLOADS TASK: 

------------------------------------------------------------------------------------------------------------------------
id: 478	queue_pos: 13		timestamp: 20230110-16:28:48	size: 9 GB	%in: 58 % 	%out: 100 %
	status: downloading	I/O: high	path: /FBX24T/dl/vm0
	error: none		end-in: 24s	name: delta-10G-881.tar.gz
------------------------------------------------------------------------------------------------------------------------

```

##### Picture  
![upd_dl_h](https://user-images.githubusercontent.com/13208359/211595927-7ba53f01-2d17-4042-a7e1-4b098097fb67.png)


-------------------------------------------------------------------------------



#### *  monitor_dl_task_api *integer*
This function will monitor a download task.
The monitoring output is a line by line output (not dynamic) which is very convinient for scripting as it logs monitoring values to stdout line by line (can easyly be redirected to a file)
NOTE: if using function login_freebox to connect the API, this function can automatically relogin the API if the monitoring task is longer than the session timeout (~1800s)
NOTE: This function is for scripting, for direct use or for use in a terminal, please use function 'monitor_dl_task_adv_api'
##### Example
```bash
monitor_dl_task_api
```
```bash

ERROR: <param> must be :
id

NOTE: you can get a list of download tasks (showing all 'id'), just run: 
list_dl_task_api

EXAMPLE:
monitor_dl_task_api 53

```

##### Picture  
![mon-dl](https://user-images.githubusercontent.com/13208359/211145770-c7192c45-d4d0-4001-b201-98a6f3933909.png)

##### Example
```bash
monitor_dl_task_api 472
```
```bash
task 472 downloading 0 MB/s, 0/MB 0% ... 
task 472 downloading 85 MB/s, 170/9536MB 1% ... 
task 472 downloading 150 MB/s, 750/9536MB 7% ... 
task 472 downloading 159 MB/s, 1268/9536MB 13% ... 
task 472 downloading 164 MB/s, 1802/9536MB 18% ... 
task 472 downloading 162 MB/s, 2269/9536MB 23% ... 
task 472 downloading 164 MB/s, 2784/9536MB 29% ... 
task 472 downloading 162 MB/s, 3252/9536MB 34% ... 
task 472 downloading 160 MB/s, 3786/9536MB 39% ... 
task 472 downloading 160 MB/s, 4301/9536MB 45% ... 
task 472 downloading 162 MB/s, 4854/9536MB 50% ... 
task 472 downloading 163 MB/s, 5340/9536MB 56% ... 
task 472 downloading 160 MB/s, 5798/9536MB 60% ... 
task 472 downloading 166 MB/s, 6389/9536MB 67% ... 
task 472 downloading 165 MB/s, 6904/9536MB 72% ... 
task 472 downloading 167 MB/s, 7448/9536MB 78% ... 
task 472 downloading 166 MB/s, 7963/9536MB 83% ... 
task 472 downloading 164 MB/s, 8430/9536MB 88% ... 
task 472 downloading 170 MB/s, 8993/9536MB 94% ... 
task 472 checking 163 MB/s, 9450/9536MB 99% ... 
task 472 checking 9536MB 3% ... 
task 472 checking 9536MB 30% ... 
task 472 checking 9536MB 49% ... 
task 472 checking 9536MB 55% ... 
task 472 checking 9536MB 63% ... 
task 472 checking 9536MB 66% ... 
task 472 checking 9536MB 69% ... 
task 472 checking 9536MB 74% ... 
task 472 checking 9536MB 76% ... 
task 472 checking 9536MB 79% ... 
task 472 checking 9536MB 83% ... 
task 472 checking 9536MB 86% ... 
task 472 checking 9536MB 89% ... 
task 472 checking 9536MB 92% ... 
task 472 checking 9536MB 94% ... 
task 472 done 9536MB 100% ... 
task 472 done !
```

##### Picture  
![mon_dl_out](https://user-images.githubusercontent.com/13208359/211146744-0ef0e31b-6138-40df-8517-c77b1bff8b61.png)

-------------------------------------------------------------------------------


#### *  monitor_dl_task_adv_api *integer*
This function will monitor a download task.
The monitoring output is a dynamic progress bar which is very convinient for tty usage
NOTE: if using function login_freebox to connect the API, this function can automatically relogin the API if the monitoring task is longer than the session timeout (~1800s)
NOTE: This function is for use in a terminal, the progress bar autoscale to the terminal width. Perfect for direct usage
##### Example
```bash
monitor_dl_task_adv_api
```
```bash

ERROR: <param> must be :
id

NOTE: you can get a list of download tasks (showing all 'id'), just run: 
list_dl_task_api

EXAMPLE:
monitor_dl_task_adv_api 53

```

##### Picture  
![mon_dl_adv](https://user-images.githubusercontent.com/13208359/211147096-46a32d40-631b-4111-9c57-bb422204ac50.png)

##### Example
```bash
monitor_dl_task_adv_api 473
```
```bash

task 473 downloading ... 
|...........................................................................................................| 100 % 0 MB/s 9536/9536MB 
task 473 checking ... 
|...........................................................................................................| 100 % checking ... 
task 473 done ... 

```
##### Picture  
downloading 
![prog-bar-run](https://user-images.githubusercontent.com/13208359/211147372-da0623d3-3f8f-4d09-8c4f-e6af486127df.png)


checking
![prog-chk](https://user-images.githubusercontent.com/13208359/211147384-d2b75eb6-6811-465e-a932-248f21d2c973.png)


finished
![prog-done](https://user-images.githubusercontent.com/13208359/211147395-4790c031-b919-4ca6-88e8-08f839f05176.png)

-------------------------------------------------------------------------------


#### *  del_dl_task_api *integer*
This function will delete a download task.
NOTE: You must delete finished download tasks, no interrest to keep a list of finished tasks 
##### Example
```bash
del_dl_task_adv_api
```
```bash
ERROR: <param> must be :
id

NOTE: you can get a list of download tasks (showing all 'id'), just run: 
list_dl_task_api

EXAMPLE:
del_dl_task_api 53

```

##### Picture  
![del_dl](https://user-images.githubusercontent.com/13208359/211147638-ed231042-be3b-4cd9-bea9-0201759fd47b.png)

##### Example
```bash
del_dl_task_api 473
```
```bash
Sucessfully delete task #473: {"success":true}
```
##### Picture  
![del_dl_ok](https://user-images.githubusercontent.com/13208359/211147969-2625ddaa-dfe8-4c6a-b626-7d4cf5a687e7.png)

-------------------------------------------------------------------------------


#### *  dl_task_log_api *integer*
This function will print a download task log
NOTE: "info" level logs are in lightblue and "error" level log messages are printed in red
##### Example
```bash
dl_task_log_api
```
```bash
ERROR: <param> must be :
id

NOTE: you can get a list of download tasks (showing all 'id'), just run: 
list_dl_task_api

EXAMPLE:
dl_task_log_api 53

```
##### Picture  
![dl_log](https://user-images.githubusercontent.com/13208359/211148534-03437dba-8bd6-44af-89e4-ad764782dbb6.png)

##### Example
```bash
dl_task_log_api 473
```
```bash

2023-01-07 12:10:27 info: start url https://ipv4.paris.testdebit.info/10G/10G.tar.gz (crawling: 1)
2023-01-07 12:10:27 dbg: host resolved to 89.84.1.194:443
2023-01-07 12:10:27 dbg: connecting to remote host...
2023-01-07 12:10:27 dbg: connected
2023-01-07 12:10:27 dbg: sending request headers:
2023-01-07 12:10:27 dbg: 	User-Agent: Mozilla/5.0
2023-01-07 12:10:27 dbg: 	Host: ipv4.paris.testdebit.info:443
2023-01-07 12:10:27 dbg: request headers sent
2023-01-07 12:10:27 dbg: got response headers:
2023-01-07 12:10:27 dbg: 	Upgrade: h2,h2c
2023-01-07 12:10:27 dbg: 	Server: Apache
2023-01-07 12:10:27 dbg: 	Last-Modified: Sat, 09 Oct 2021 22:00:00 GMT
2023-01-07 12:10:27 dbg: 	ETag: 2540be400-5cdf29dfdf800
2023-01-07 12:10:27 dbg: 	Date: Sat, 07 Jan 2023 11:10:27 GMT
2023-01-07 12:10:27 dbg: 	Content-Type: application/x-gzip
2023-01-07 12:10:27 dbg: 	Content-Length: 10000000000
2023-01-07 12:10:27 dbg: 	Connection: Upgrade
2023-01-07 12:10:27 dbg: 	Accept-Ranges: bytes
2023-01-07 12:10:27 info: unable to resume (missing content_range)
2023-01-07 12:10:27 dbg: receiving body

```
##### Picture  
![dl_log_inf](https://user-images.githubusercontent.com/13208359/211148849-d64cc2a4-a381-4232-bf08-de888378b195.png)


##### Example
```bash
nba@14RV-SERVER-159:~/fbxapi$ dl_task_log_api 335
```
```bash

Download Task log: task 335

2022-12-23 15:32:13 info: start url https://cloud.centos.org/centos/8/aarch64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.aarch64.qcow2 (crawling: 1)
2022-12-23 15:32:14 dbg: host resolved to 3.8.21.190:443
2022-12-23 15:32:14 dbg: connecting to remote host...
2022-12-23 15:32:14 dbg: connected
2022-12-23 15:32:14 dbg: sending request headers:
2022-12-23 15:32:14 dbg: 	User-Agent: Mozilla/5.0
2022-12-23 15:32:14 dbg: 	Host: cloud.centos.org:443
2022-12-23 15:32:14 dbg: request headers sent
2022-12-23 15:32:14 dbg: got response headers:
2022-12-23 15:32:14 dbg: 	X-Xss-Protection: 1; mode=block
2022-12-23 15:32:14 dbg: 	X-Frame-Options: SAMEORIGIN
2022-12-23 15:32:14 dbg: 	X-Content-Type-Options: nosniff
2022-12-23 15:32:14 dbg: 	Strict-Transport-Security: max-age=31536000
2022-12-23 15:32:14 dbg: 	Server: Apache/2.4.6 (CentOS) OpenSSL/1.0.2k-fips
2022-12-23 15:32:14 dbg: 	Referrer-Policy: same-origin
2022-12-23 15:32:14 dbg: 	Last-Modified: Thu, 03 Jun 2021 05:37:48 GMT
2022-12-23 15:32:14 dbg: 	ETag: 4a2d0000-5c3d5f9b89a82
2022-12-23 15:32:14 dbg: 	Date: Fri, 23 Dec 2022 14:32:14 GMT
2022-12-23 15:32:14 dbg: 	Content-Type: application/octet-stream
2022-12-23 15:32:14 dbg: 	Content-Length: 1244463104
2022-12-23 15:32:14 dbg: 	Accept-Ranges: bytes
2022-12-23 15:32:14 err: failed to open //CentOS-8-GenericCloud-8.4.2105-20210603.0.aarch64.qcow2: Permission denied
2022-12-23 15:32:14 err: https://cloud.centos.org/centos/8/aarch64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.aarch64.qcow2 failed with code 418 OK
2022-12-23 15:32:14 dbg: receiving body

```
##### Picture  
![dl_log_err](https://user-images.githubusercontent.com/13208359/211149004-ac07436f-6051-4135-82ea-ebad8180d30e.png)


__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________

<a name="DLEXTRA"></a>


DOWNLOAD API  - EXTRA 
--------------------------------------------

####  LETS WRITE A SMALL PROGRAM FOR DOWNLOADING: 

- Our small program will 
	- create a download task for downloading a file 
	- show our newly launched task
	- monitor the download
	- monitor the checksum checking task 
	- print download task log 
	- show our finished task
	- delete our finished task

```bash
# Here my small program's name is 'tmon' like 'test monitoring download'
cat tmon
```
```bash
#!/bin/bash

# application credential:
MY_APP_ID="fbxvm"
MY_APP_TOKEN="Put-here-your-fbxvm-APP_TOKEN"

# source library and login
source ./fbx-delta-nba_bash_api.sh
login_freebox "$MY_APP_ID" "$MY_APP_TOKEN"

# variables:
download_dir="/FBX24T/dl/vm0"
download_url="https://ipv4.paris.testdebit.info/10G/10G.tar.gz" 
hash="https://master.3xo.fr/SHA512SUMS"
filename="delta-10G-505.tar.gz"


# MAIN PROGRAM:
answer=$(enc_dl_task_api download_url=${download_url} hash=${hash} download_dir=${download_dir} filename=${filename})
_check_success ${answer} || exit 1
colorize_output ${answer}
id=$(get_json_value_for_key "${answer}" result.id 2>/dev/null)
show_dl_task_api $id
monitor_dl_task_adv_api $id 
dl_task_log_api $id
show_dl_task_api $id
del_dl_task_api $id
echo
```

And now we'll just run this small program and let see the result and output: 

```bash
./tmon
```
```bash

operation completed: 
{"success":true}

result:
{"id":475}


					SHOW DOWNLOADS TASK: 

------------------------------------------------------------------------------------------------------------------------
id: 475	queue_pos: 11		timestamp: 20230107-13:12:51	size: 9 GB	%in: 0 % 	%out: 100 %
	status: downloading	I/O: normal	path: /FBX24T/dl/vm0
	error: none		end-in: 219s	name: delta-10G-506.tar.gz
------------------------------------------------------------------------------------------------------------------------

task 475 downloading ... 
|...............................................................................................................................................................| 100 % 0 MB/s 9536/9536MB 
task 475 checking ... 
|...............................................................................................................................................................| 100 % checking ... 
task 475 done ... 

Download Task log: task 475

2023-01-07 13:12:51 info: start url https://ipv4.paris.testdebit.info/10G/10G.tar.gz (crawling: 1)
2023-01-07 13:12:51 dbg: host resolved to 89.84.1.194:443
2023-01-07 13:12:51 dbg: connecting to remote host...
2023-01-07 13:12:51 dbg: connected
2023-01-07 13:12:51 dbg: sending request headers:
2023-01-07 13:12:51 dbg: 	User-Agent: Mozilla/5.0
2023-01-07 13:12:51 dbg: 	Host: ipv4.paris.testdebit.info:443
2023-01-07 13:12:51 dbg: request headers sent
2023-01-07 13:12:51 dbg: got response headers:
2023-01-07 13:12:51 dbg: 	Upgrade: h2,h2c
2023-01-07 13:12:51 dbg: 	Server: Apache
2023-01-07 13:12:51 dbg: 	Last-Modified: Sat, 09 Oct 2021 22:00:00 GMT
2023-01-07 13:12:51 dbg: 	ETag: 2540be400-5cdf29dfdf800
2023-01-07 13:12:51 dbg: 	Date: Sat, 07 Jan 2023 12:12:51 GMT
2023-01-07 13:12:51 dbg: 	Content-Type: application/x-gzip
2023-01-07 13:12:51 dbg: 	Content-Length: 10000000000
2023-01-07 13:12:51 dbg: 	Connection: Upgrade
2023-01-07 13:12:51 dbg: 	Accept-Ranges: bytes
2023-01-07 13:12:51 info: unable to resume (missing content_range)
2023-01-07 13:12:51 dbg: receiving body


					SHOW DOWNLOADS TASK: 

------------------------------------------------------------------------------------------------------------------------
id: 475	queue_pos: 11		timestamp: 20230107-13:12:51	size: 9 GB	%in: 100 % 	%out: 100 %
	status: done		I/O: normal	path: /FBX24T/dl/vm0
	error: none		end-in: 0s	name: delta-10G-506.tar.gz
------------------------------------------------------------------------------------------------------------------------

Sucessfully delete task #475: {"success":true}

```
##### Picture  
![tmon_dl](https://user-images.githubusercontent.com/13208359/211150245-a572cdae-d8ee-4a50-bb87-909ecf56c908.png)



__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________


API FRONTEND FUNCTIONS - DIRECT DOWNLOAD 
-----------------

- This API only provide the possibility to download files present on freebox starage (NAS) directly on the computer running this function 
	- This function make an authenticted call to the API 
	- This function let you download files with NO restrictions 
	- You do not need a valid "share link" to be able to download a file 


-------------------------------------------------------------------------------

#### *  local_direct_dl_api *path*
This function will download a file from freebox NAS storage to your computer
##### Example
```bash
local_direct_dl_api
```
```bash

file_fullpath parameters missing !

you must provide /path/to/download/file on the cmdline !

```
##### Picture 
![l_dl2](https://user-images.githubusercontent.com/13208359/211162323-adacf6c0-80f6-4514-a590-b3e2811f35ee.png) 

##### Example
```bash
local_direct_dl_api /FBX24T/dl/vm1/vm11/delta-opensuze-ZN90.qcow2
```
```bash

Downloading file from Freebox to local directory:

/FBX24T/dl/vm1/vm11/delta-opensuze-ZN90.qcow2 ---> ./delta-opensuze-ZN90.qcow2
############################################################################################################################################################################################### 100,0%

Done: 
501M	delta-opensuze-ZN90.qcow2

```
##### Picture  
![l_direct_dl_ok2](https://user-images.githubusercontent.com/13208359/211162389-baa10e12-d959-4d35-9962-0ed793132bb4.png)


__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________

<a name="SHARELINK"></a>


API FRONTEND FUNCTIONS - DOWNLOAD SHARE LINK
-----------------


- This API only provide the possibility to create non authentified download share link to publish stuff present on your Freebox storage (NAS) on internet.  
	- Files are accessible over an unauthenticated call to the API on a particular URL
	- This API let you manage download share links (list, create, delete) 
	- You can set an expiration date on each created share link


##### NOTE 1
To use this API, you must have a public URL and your "Freebox Remote Access" must be enabled in FreeboxOS

##### NOTE 2
When you post a share link on an internet forum, the target of the link become accessible for download to anyone which have access to this link and without any kind of authentication. Only files targed by the link become accessible.

##### USAGE EXAMPLE 
- If you have a Freebox Delta and you run Virtual Machines inside your Freebox Delta, you can install and build a custom VM image with all requirements needed to make work the service this VM will deliver (ex: home automation server, home web server, home TOR bridge, home Media server ...), and when your VM image is ready, you can decide to share it to Freebox Delta VM user's community 
	So you can stop your VM and copy the disk image to a "public" directory you create on Freebox storage for this use
	And you can create a share link which let people access to the copy of the VM image you've just done and you can post this share link on public forums. 
	As you can set an expiration date on each lnk, if you decide to provide the community rolling upgrade of your VM image (weekly or monthly), you can make all links valid only until the next rolling upgrade release you will provide to the community.   

- Sometimes, you may want to send an email with a big archive attached, but the attached files are too big for beeing accepted by remote SMTP server (don't forgot to encrypt and put a password on the archive before sending it over internet).
Here you can use a share link:
	- Put your attached archives in a directory of your Freebox storage
	- Create share links for all differents archives
	- Copy paste those share links in your mail and the destination people will be able to download the content target of share links you send them.  
 

##### WARNING 
- To maintien PRIVACY in this README, I'm masking the public URL and PORT in the share links I will publish here because it's pointing to a REAL Freebox reachable over the internet. 
- To do so, I will replace in all URL my public domain by 'my-public-domain.net' and the port by '4011', using something like: 
```bash
show_share_link l1i-SuYthQC8bjKo |sed -e "s/${mydom}/my-public-domain.net/g" -e "s/${myport}/4011/g"
```   

-------------------------------------------------------------------------------


#### *  check_and_feed_share_link_param *array_of_strings*
This function will check if the provided arguments are valid parameters for the function which is calling it depending of the "action" set by the calling function. If not, function param_share_link_err will be called to set error and display help for the command depending on "action" set by the calling function. "action" are: 'add, show, get, del'. This function return a 'json' object or an 'as it must be formated object for the command' to be passed to "API CALL" functions
##### Example
```bash
action=add
check_and_feed_share_link_param path=/FBX24T/dl/vm0/delta-10G-5.tar.gz expire=2023-12-10T10:00:00
echo -e  "${share_link_object}"
```
```bash
{"path":"L0ZCWDI0VC9kbC92bTAvZGVsdGEtMTBHLTUudGFyLmd6","expire":"1702198800"}
```

-------------------------------------------------------------------------------

#### *  param_share_link_err
This function will display help / manual and example on the command which calling it, depending of the "action" set by the calling function. This function also set variable "error=1". "error" variable content is always checked before each API execution, and if error=1, nothing happends and the lib exit cleanly. "action" are: 'add, get, show, del'. This function return error=1 when it has been called
This function is mostly called by 'check_and_feed_share_link_param' function 


-------------------------------------------------------------------------------


#### *  list_share_link
This function will list all download share links you have created on your Freebox
##### Example
```bash
list_share_link
```
```bash

					LIST OF SHARED LINKS:

------------------------------------------------------------------------------------------------------------------------
token: nb5KRyH4TOeC07w8		expire: 2023-01-11 12:42:08	name: nba50g2.tar.xz
path: /FBX24T/dl/vm1/vm15/nba50g2.tar.xz
URL: https://fbx.my-public-domain.net:4011/share/nb5KRyH4TOeC07w8/nba50g2.tar.xz
------------------------------------------------------------------------------------------------------------------------
token: FfL2R2C1dhbk9Xj8		expire: 2023-01-11 12:49:17	name: nba50g.tar.gz
path: /FBX24T/dl/vm1/vm15/nba50g.tar.gz
URL: https://fbx.my-public-domain.net:4011/share/FfL2R2C1dhbk9Xj8/nba50g.tar.gz
------------------------------------------------------------------------------------------------------------------------
token: khR-1PGGwMjxQMrY		expire: 2023-01-11 12:53:14	name: nba20g.7z
path: /FBX24T/dl/vm1/vm14/nba20g.7z
URL: https://fbx.my-public-domain.net:4011/share/khR-1PGGwMjxQMrY/nba20g.7z
------------------------------------------------------------------------------------------------------------------------
token: rLri0H5Sgbr3O-k5		expire: 2023-12-12 10:10:10	name: delta-10G-1.tar.gz
path: /FBX24T/dl/vm0/delta-10G-1.tar.gz
URL: https://fbx.my-public-domain.net:4011/share/rLri0H5Sgbr3O-k5/delta-10G-1.tar.gz
------------------------------------------------------------------------------------------------------------------------
token: bq2Lw-bh8FCbIM3b		expire: 2023-10-11 00:00:00	name: delta-10G-2.tar.gz
path: /FBX24T/dl/vm0/delta-10G-2.tar.gz
URL: https://fbx.my-public-domain.net:4011/share/bq2Lw-bh8FCbIM3b/delta-10G-2.tar.gz
------------------------------------------------------------------------------------------------------------------------
token: l1i-SuYthQC8bjKo		expire: 2023-10-01 01:00:00	name: delta-10G-3.tar.gz
path: /FBX24T/dl/vm0/delta-10G-3.tar.gz
URL: https://fbx.my-public-domain.net:4011/share/l1i-SuYthQC8bjKo/delta-10G-3.tar.gz
------------------------------------------------------------------------------------------------------------------------
token: S3VGVZ5b9vJvKAe-		expire: 1970-01-01 01:00:00	name: delta-10G-4.tar.gz
path: /FBX24T/dl/vm0/delta-10G-4.tar.gz
URL: https://fbx.my-public-domain.net:4011/share/S3VGVZ5b9vJvKAe-/delta-10G-4.tar.gz
------------------------------------------------------------------------------------------------------------------------
token: vQdJMkmfznzwnbV7		expire: 2023-10-11 00:00:00	name: delta-10G-6.tar.gz
path: /FBX24T/dl/vm0/delta-10G-6.tar.gz
URL: https://fbx.my-public-domain.net:4011/share/vQdJMkmfznzwnbV7/delta-10G-6.tar.gz
------------------------------------------------------------------------------------------------------------------------
token: L1hsYOX1JpVeX9hF		expire: 2023-12-10 10:00:00	name: delta-10G-5.tar.gz
path: /FBX24T/dl/vm0/delta-10G-5.tar.gz
URL: https://fbx.my-public-domain.net:4011/share/L1hsYOX1JpVeX9hF/delta-10G-5.tar.gz
------------------------------------------------------------------------------------------------------------------------

```
##### Picture 
![list_shl](https://user-images.githubusercontent.com/13208359/211189649-3db1f6c6-e6f3-4089-b24e-de5abdf64022.png)

-------------------------------------------------------------------------------


#### *  show_share_link *string*
This function will show a particular share link, specified by the "token" you provide as the first and only parameter of the command line 
This function has a Human Readable output, and is made to run in a terminal
##### Example
```bash
show_share_link
```
```bash

ERROR: <param> must be :
token			# token is a chain of 16 alphanumeric or punctuation characters

NOTE: you can get a list of share_link token (showing all 'token'), just run: 
list_share_link

EXAMPLE:
show_share_link "nb5KDjU9TOeC00w3" 

```
##### Picture 
![sh_sl](https://user-images.githubusercontent.com/13208359/211191368-e5f145f1-0f37-465b-ab26-760a47490b26.png)

##### Example
```bash
show_share_link l1i-SuYthQC8bjKo 
```
```bash
					SHOW LINK TOKEN: l1i-SuYthQC8bjKo

------------------------------------------------------------------------------------------------------------------------
token: l1i-SuYthQC8bjKo		expire: 2023-10-01 01:00:00	name: delta-10G-3.tar.gz
path: /FBX24T/dl/vm0/delta-10G-3.tar.gz
URL: https://fbx.my-public-domain.net:4011/share/l1i-SuYthQC8bjKo/delta-10G-3.tar.gz
------------------------------------------------------------------------------------------------------------------------

```
##### Picture 
![sh_sltk](https://user-images.githubusercontent.com/13208359/211191508-a781890b-7f2c-422e-905f-9336c065102d.png)


-------------------------------------------------------------------------------


#### *  get_share_link *string*
This function will show a particular share link, specified by the "token" you provide as the first and only parameter of the command line 
This function has a JSON output which can be easyly parse by a computer or another program
The purpose of this function is to have "machine" output of the share link for use in other programs
##### Example
```bash
get_share_link
```
```bash

ERROR: <param> must be :
token			# token is a chain of 16 alphanumeric or punctuation characters

NOTE: you can get a list of share_link token (showing all 'token'), just run: 
list_share_link

EXAMPLE:
get_share_link "nb5KDjU9TOeC00w3" 


```
##### Picture 
![g_sl_r](https://user-images.githubusercontent.com/13208359/211192089-be85e01f-2106-4f2f-8f5a-36b2cf2665ec.png)

##### Example
```bash
get_share_link l1i-SuYthQC8bjKo
```
```bash

operation completed: 
{"success":true}

result:
{"path":"L0ZCWDI0VC9kbC92bTAvZGVsdGEtMTBHLTMudGFyLmd6","token":"l1i-SuYthQC8bjKo","name":"delta-10G-3.tar.gz","expire":1696114800,"fullurl":"https://fbx.my-public-domain.net:4011/share/l1i-SuYthQC8bjKo/delta-10G-3.tar.gz","internal":0}

```
##### Picture 
![g_sl](https://user-images.githubusercontent.com/13208359/211192256-b803defd-8c56-47e9-9db7-1df623f29999.png)


-------------------------------------------------------------------------------

#### *  add_share_link *array_of_strings*
This function will add a share link and will return a json containing the share link "token" which idendtify this share link on your Freebox 
This function has a JSON output which can be easyly parse by a computer or another program
##### Example
```bash
add_share_link
```
```bash

ERROR: <param> must be :
path=			# fullpath of file or dir to share 
expire=			# expire date: 0=never - format yyyy-mm-dd - to specify time add: Thh:mm:ss

NOTE: minimum parameters to specify on cmdline to add a share_link: 
path= 
expire= 

EXAMPLE:
add_share_link path="/MyFBX/dl/debian-vm-12.qcow2" expire="2023-12-12T22:33:44" 

```
##### Picture 
![a_sl_r](https://user-images.githubusercontent.com/13208359/211192958-ece9f8ec-f951-448f-bb58-1acda7ca689a.png)

```bash
add_share_link path=/FBX24T/dl/vm0/delta-10G-5.tar.gz expire=2024-01-08T10:00:00 
```
```bash
operation completed: 
{"success":true}

result:
{"path":"L0ZCWDI0VC9kbC92bTAvZGVsdGEtMTBHLTUudGFyLmd6","token":"UQttle1mcziV2b9f","name":"delta-10G-5.tar.gz","expire":1704704400,"fullurl":"https://fbx.my-public-domain.net:4011/share/UQttle1mcziV2b9f/delta-10G-5.tar.gz","internal":0}

```
##### Picture 
![a_sl](https://user-images.githubusercontent.com/13208359/211192961-a193a5d7-ba7e-4a17-85ea-97bc9dac7e9d.png)


-------------------------------------------------------------------------------

#### *  del_share_link *string*
This function will del a share link and will return a json containing the success result 
This function take the 'share link token' as argument
##### Example
```bash
del_share_link
```
```bash

ERROR: <param> must be :
token			# token is a chain of 16 alphanumeric or punctuation characters

NOTE: you can get a list of share_link token (showing all 'token'), just run: 
list_share_link

EXAMPLE:
del_share_link "nb5KDjU9TOeC00w3" 

```

##### Picture 
![del_sl_r](https://user-images.githubusercontent.com/13208359/211194627-8f6ceebf-455c-445a-91dc-91d64c2ef012.png)

##### Example
```bash
del_share_link UQttle1mcziV2b9f
```
```bash

operation completed: 
{"success":true}

```

##### Picture 
![del_sl](https://user-images.githubusercontent.com/13208359/211194644-2d5d6d37-355c-4076-bfe6-9d8c49348484.png)



__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________

<a name="DHCP"></a>


API FRONTEND FUNCTIONS - NETWORK: DHCP
-----------------

- This API only provide the possibility to manage DHCP reservations and allow you to assign a predifined IP address to a particular MAC address
- Functions developped to manage this API let you list, add, update and delete DHCP reservation and the list command also show you if some reservations are currently used (when assigned IP is reachable)


##### WARNING 
To use these functions, your application which login the API MUST be granted to modify your box setup parameters (from freeboxOS web interface, see: [GRANT API ACCESS](#GRANTAXX))

-------------------------------------------------------------------------------


#### *  check_and_feed_dhcp_param *array_of_strings*
This function will check if the provided arguments are valid parameters for the function which is calling it depending of the "action" set by the calling function. If not, function param_dhcp_err will be called to set error and display help for the command depending on "action" set by the calling function. "action" are: 'add, upd, del'. This function return a 'json' object to be passed to "API CALL" functions.
This function also check the validity of IP adress (must be [RFC1918](https://www.ietf.org/rfc/rfc1918.txt) ip address) and validity of MAC address format using ':' (column) as separator, so the help / error output also contain an error message if IP or MAC address has a bad format 
##### Example
```bash
action=add
check_and_feed_dhcp_param mac="00:01:02:03:04:05" ip="192.168.123.123" comment="VM: 14RV-FSRV-123"
echo -e  "${dhcp_object}"
```
```bash
{"mac":"00:01:02:03:04:05","ip":"192.168.123.123","comment":"VM: 14RV-FSRV-123"}
```

-------------------------------------------------------------------------------

#### *  param_dhcp_err
This function will display help / manual and example on the command which calling it, depending of the "action" set by the calling function. This function also set variable "error=1". "error" variable content is always checked before each API execution, and if error=1, nothing happends and the lib exit cleanly. "action" are: 'add, upd, del'. This function return error=1 when it has been called
This function is mostly called by 'check_and_feed_dhcp_param' function 

-------------------------------------------------------------------------------


#### *  list_dhcp_static_lease
This function list DHCP static leases and will show leases usage status (show if machine is online or offline)

##### Example
```bash
list_dhcp_static_lease
```
```bash
				DHCP ASSIGNED STATIC LEASES:

#:		id:			mac:			ip: 		state: 		hostname:
0:	3C:FD:FE:1A:66:40	3C:FD:FE:1A:66:40	192.168.100.25  	offline  	14RV-SERVER-SFP0
1:	00:E0:81:D6:AE:B5	00:E0:81:D6:AE:B5	192.168.100.26  	offline  	14RV-SERVER-NBA0
2:	00:01:02:03:B4:11	00:01:02:03:B4:11	192.168.100.41  	offline  	00:01:02:03:B4:11
3:	00:01:02:03:04:12	00:01:02:03:04:12	192.168.100.42  	offline  	00:01:02:03:04:12
4:	00:01:42:33:34:33	00:01:42:33:34:33	192.168.100.43  	offline  	00:01:42:33:34:33
5:	00:01:02:03:14:20	00:01:02:03:14:20	192.168.100.44  	offline  	00:01:02:03:14:20
6:	60:F2:62:B6:93:1F	60:F2:62:B6:93:1F	192.168.100.55  	offline  	lap-nba
7:	14:DD:A9:D3:E8:B6	14:DD:A9:D3:E8:B6	192.168.100.59  	offline  	14RV-BMC
8:	14:DD:A9:D3:E8:B7	14:DD:A9:D3:E8:B7	192.168.100.79  	offline  	14RV-SERVER-BMC-SHARED
9:	34:27:92:80:29:7C	34:27:92:80:29:7C	192.168.100.88  	online  	14RV-DEVIALET
10:	8C:97:EA:55:BB:B6	8C:97:EA:55:BB:B6	192.168.100.89  	online  	14RV-FBXAP
11:	28:16:AD:09:43:63	28:16:AD:09:43:63	192.168.100.94  	offline  	14RV-ULTRA-wifi
12:	38:AF:29:55:D3:0E	38:AF:29:55:D3:0E	192.168.100.95  	online  	14RV-CAM
13:	34:27:92:E5:76:96	34:27:92:E5:76:96	192.168.100.96  	online  	14RV-FBXCAM
14:	8C:DC:D4:C9:13:A1	8C:DC:D4:C9:13:A1	192.168.100.100  	offline  	14RV-PRINTER
15:	24:5E:BE:43:B3:73	24:5E:BE:43:B3:73	192.168.100.123  	offline  	lap-nba-sfp+
16:	E0:23:FF:3F:A6:CC	E0:23:FF:3F:A6:CC	192.168.100.250  	offline  	14RV-FW101F

```

##### Picture
![list_dhcp](https://user-images.githubusercontent.com/13208359/211636663-4be45554-256b-42f5-aaaa-1b82a1f59a10.png)


-------------------------------------------------------------------------------


#### *  add_dhcp_static_lease *array_of_strings*
This function simply add a DHCP static leases 

##### Example
```bash
add_dhcp_static_lease
```
```bash

ERROR: <param> for add_dhcp_static_lease must be some of:
mac=
ip=
comment=

NOTE: minimum parameters to specify on cmdline to create a static DHCP lease: 
mac= 
ip=

EXAMPLE:
add_dhcp_static_lease mac="00:01:02:03:04:05" ip="192.168.123.123" comment="VM: 14RV-FSRV-123"


operation failed ! 
Adresse mac invalide: invalid_request

```

##### Picture
![add_dhcp_r](https://user-images.githubusercontent.com/13208359/211754257-fe53bec5-ebe8-4faa-b28a-6b582010d1c6.png)


##### Example
```bash
add_dhcp_static_lease mac=00:01:02:03:04:05 ip=192.168.100.46 comment="DHCP example for this README"
```
```bash

operation completed: 
{"success":true}

result:
{"mac":"00:01:02:03:04:05","comment":"DHCP example for this README","hostname":"00:01:02:03:04:05","id":"00:01:02:03:04:05","ip":"192.168.100.46"}

```
##### Picture
![add_dhcp](https://user-images.githubusercontent.com/13208359/211754457-8abac652-93fb-4e2f-aa9b-b394ed54f005.png)


Now we will verify that our DHCP static lease had successfully be added :
Note that I'm using here '--color=never' option of 'grep' because I want to keep the library formatting for the picture. 

```bash
list_dhcp_static_lease | grep --color=never '00:01:02:03:04:05'
```
```bash
6:      00:01:02:03:04:05       00:01:02:03:04:05       192.168.100.46          offline         00:01:02:03:04:05
```
##### Picture
![ad_dh_g](https://user-images.githubusercontent.com/13208359/211754887-a4eda24e-dabf-4939-b5c0-375ec9dfd52b.png)


-------------------------------------------------------------------------------


#### *  upd_dhcp_static_lease *array_of_strings*
This function update a DHCP static leases 
mac= parameter is mandatory

##### Example
```bash
upd_dhcp_static_lease 
```
```bash

ERROR: <param> for upd_dhcp_static_lease must be some of:
mac=
ip=
comment=

NOTE: minimum parameters to specify on cmdline to update a static DHCP lease: 
mac= 
ip=  or comment= 

EXAMPLE:
upd_dhcp_static_lease mac="00:01:02:03:04:05" ip="192.168.123.123" comment="VM: 14RV-FSRV-123"


operation failed ! 
Requête invalide (404): invalid_request

```

##### Picture
![upd_dhcp_r](https://user-images.githubusercontent.com/13208359/211855580-2ef9ff76-eab6-4d2d-b6c6-1fcdf3a2eec9.png)


##### Example
```bash
upd_dhcp_static_lease mac=00:01:02:03:04:05 ip=192.168.100.47 comment="DHCP example for this README"
```
```bash

operation completed: 
{"success":true}

result:
{"mac":"00:01:02:03:04:05","comment":"DHCP example for this README","hostname":"00:01:02:03:04:05","id":"00:01:02:03:04:05","ip":"192.168.100.47"}

```
##### Picture
![upd_dhcp](https://user-images.githubusercontent.com/13208359/211855809-c1a0be04-eaf6-4dfa-9da3-8e10dc135717.png)

And now we can verify that the IP address of this DHCP static lease had been successfully update from 192.168.100.46 to 192.168.100.47
```bash
list_dhcp_static_lease | grep --color=never '00:01:02:03:04:05'
```
```bash
6:	00:01:02:03:04:05	00:01:02:03:04:05	192.168.100.47  	offline  	00:01:02:03:04:05
```
##### Picture
![upd_dhcp_ok](https://user-images.githubusercontent.com/13208359/211858629-ec328f76-40b5-475b-bbee-10e25442a417.png)

-------------------------------------------------------------------------------



#### *  del_dhcp_static_lease *string*
This function simply del a DHCP static leases. 
It takes the DHCP lease MAC address as 'id' argument. 

##### Example
```bash
del_dhcp_static_lease 
```
```bash

ERROR: <param> must be :
id

NOTE: you can get a list of DHCP static lease (showing all 'id'), just run : 
list_dhcp_static_lease

EXAMPLE:
del_dhcp_static_lease 00:01:02:03:04:05

ERROR: Bad value for id, id must have a mac address format:
00:01:02:03:04:05

operation failed ! 
Error in 'id' mac address format

```
##### Picture
![del_dhcp_r](https://user-images.githubusercontent.com/13208359/211755054-9d7f5a5c-6ac2-4861-bbaf-424dfd3e4065.png)


##### Example
```bash
del_dhcp_static_lease 00:01:02:03:04:05             
```
```bash

operation completed: 
{"success":true}

```
##### Picture
![del_dhcp](https://user-images.githubusercontent.com/13208359/211755089-963feb4e-6051-4b8a-8280-6728146b4780.png)


__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________

<a name="NAT"></a>

API FRONTEND FUNCTIONS - NETWORK: NAT REDIRECTIONS
-----------------

- This API only provide the possibility to manage IPv4 destination NAT redirections and allow you open a port of your public IP and bind it to a local port of a local ip address. This way you can host some service on your network and make them accessibles on internet
- Functions developped to manage this API let you list, add, update, enable, disable and delete your box destination NAT redirections and the list command also show you the status (enabled or disabled) of each destination NAT redirections 


##### WARNING 
To use these functions, your application which login the API MUST be granted to modify your box setup parameters (from freeboxOS web interface, see: [GRANT API ACCESS](#GRANTAXX))

##### WARNING 
Today, when your connection is in ROUTER MODE, Free Telecom from Iliad Group often deliver your internet connection with 1 fixed public IP shared for 4 people and ISP NAT 25% of the availiable ports of the shared public IP adress to each of the 4 customer's connection. 

If you are in this case and this situation is convinient for you (maybe you have ports from 1 to 16384), you must BE CAREFULL when adding or modifying destination NAT redirection that the NAT redirection you want to add / modify is not out of your assigned port range


##### If this situation is not convinient for you, see how to get a full-stack IP address with all ports (Free of charges, see:  [FULL-STACK IPV4](#FULLSTK))


-------------------------------------------------------------------------------


#### *  check_and_feed_fw_redir_param *array_of_strings*
This function will check if the provided arguments are valid parameters for the function which is calling it depending of the "action" set by the calling function. If not, function param_fw_redir_err will be called to set error and display help for the command depending on "action" set by the calling function. "action" are: 'add, upd, del, ena, dis'. This function return a 'json' object to be passed to "API CALL" functions.
This function also check the validity of IP adress, of local IP address (must be [RFC1918](https://www.ietf.org/rfc/rfc1918.txt) ip address) and validity of MAC address format using ':' (column) as separator, so the help / error output also contain an error message if IP or MAC address has a bad format 
##### Example
```bash
action=add
check_and_feed_fw_redir_param  wan_port_start="443" lan_port="443" lan_ip="192.168.133.43" ip_proto="tcp"
echo -e ${fw_redir_object}
```
```bash
{"wan_port_start":"443","lan_port":"443","lan_ip":"192.168.133.43","ip_proto":"tcp","wan_port_end":"443","src_ip":"0.0.0.0","enabled":"1"}

```

-------------------------------------------------------------------------------

#### *  param_fw_redir_err
This function will display help / manual and example on the command which calling it, depending of the "action" set by the calling function. This function also set variable "error=1". "error" variable content is always checked before each API execution, and if error=1, nothing happends and the lib exit cleanly. "action" are: 'add, upd, del, ena, dis'. This function return error=1 when it has been called
This function is mostly called by 'check_and_feed_fw_redir_param' function 

-------------------------------------------------------------------------------


#### *  list_fw_redir
This function list destination NAT redirections and will show the status (if the redirection is enabled or if it's currently disabled).

##### Example
```bash
list_fw_redir
```
```bash

				NETWORK INCOMMING NAT REDIRECTIONS:

#:	id:	lan-port:	protocol:	lan_ip:			wan-port-range:		allowed-ip	state:		hostname:
0:	1	443		tcp		192.168.133.250		444	444		0.0.0.0   	active  	14RV-FW101F-cluster
1:	2	22		tcp		192.168.133.250		422	422		0.0.0.0   	active  	14RV-FW101F-cluster
2:	3	500		udp		192.168.133.248		500	500		0.0.0.0   	active  	14RV-FW101F-cluster
3:	4	4500		udp		192.168.133.248		4500	4500		0.0.0.0   	active  	14RV-FW101F-cluster
4:	5	8443		tcp		192.168.133.250		8443	8443		0.0.0.0   	active  	14RV-FW101F-cluster
5:	6	9443		tcp		192.168.133.1		9443	9443		0.0.0.0   	active  	14RV-FW90D
6:	8	9001		tcp		192.168.133.229		9001	9001		0.0.0.0   	active  	192.168.133.229
7:	9	80		tcp		192.168.133.227		80	80		0.0.0.0   	active  	192.168.133.227
8:	10	443		tcp		192.168.133.227		443	443		0.0.0.0   	active  	192.168.133.227
9:	11	22		tcp		192.168.133.227		222	222		0.0.0.0   	active  	192.168.133.227
10:	12	9030		tcp		192.168.133.229		9030	9030		0.0.0.0   	disabled   	192.168.133.229
11:	13	37777		tcp		192.168.133.230		37777	37777		0.0.0.0   	disabled   	192.168.133.230
12:	14	443		tcp		192.168.133.1		4444	4444		0.0.0.0   	disabled   	14RV-FW90D
13:	15	22		tcp		192.168.133.1		4422	4422		0.0.0.0   	disabled   	14RV-FW90D
14:	16	80		tcp		192.168.133.250		8080	8080		0.0.0.0   	disabled   	14RV-FW101F-cluster
15:	17	22		tcp		192.168.133.60		443	443		0.0.0.0   	disabled   	14RV-FBXSRV-02
16:	30	22		tcp		192.168.133.225		22	22		0.0.0.0   	active  	192.168.133.225
17:	74	61078		tcp		192.168.133.36		61078	61078		44.33.11.22   	active  	192.168.133.36
18:	66	61066		tcp		192.168.133.38		61066	61066		0.0.0.0   	disabled   	192.168.133.38
19:	67	61067		tcp		192.168.133.38		61067	61067		0.0.0.0   	disabled   	192.168.133.38
20:	72	61073		tcp		192.168.133.44		61073	61073		55.44.33.22   	active  	192.168.133.44
21:	73	61076		tcp		192.168.133.46		61076	61076		77.77.77.77   	active  	192.168.133.46

```


##### Picture
![list_fw_redir](https://user-images.githubusercontent.com/13208359/212084612-93b4f94f-15d7-4cba-a712-7ed059332565.png)

-------------------------------------------------------------------------------


#### *  add_fw_redir *array_of_strings*
This function add a destination NAT redirection from a port of your public IP to a port of a local ip address on your local network. It's also possible to specify ports range
When using port ranges, there is no options to specify the 'lan last port' because it's automatically calculated by the API : (last port is lan_port + wan_port_end - wan_port_start)

##### Example
```bash
add_fw_redir
```
```bash

ERROR: <param> for "add_fw_redir" must be some of:
lan_port=		# lan start port: must be a number in [1-65535]
wan_port_start=		# wan start port: must be a number in [1-65535]
wan_port_end=		# wan end port: must be a number in [1-65535]
lan_ip=			# local destination ip
ip_proto=		# must be: 'tcp' or 'udp'
src_ip=			# allowed ip: default: all ip allowed
enabled=		# boolean 'true' or 'false': default 'true'
comment=		# string: maximum 63 char 

NOTE: minimum parameters to specify on cmdline to create a destination NAT redirection: 
wan_port_start= 
lan_port= 
lan_ip= 
ip_proto=

WARNING: if not specified on cmdline following parameters will be reset to their default values
wan_port_end=		# default value: wan_port_start
src_ip=			# default: all ip allowed: 0.0.0.0
enabled=		# default: true

EXAMPLE: (simple)
add_fw_redir wan_port_start="443" lan_port="443" lan_ip="192.168.123.123" ip_proto="tcp" comment="NAT: destination nat: HTTPS to VM 14RV-FSRV-123:HTTPS"

EXAMPLE: (full)
add_fw_redir wan_port_start="60000" wan_port_end="60010" lan_port="60000" lan_ip="192.168.123.123" ip_proto="tcp" src_ip="22.22.22.22" enabled="true" comment="NAT: destination nat: PASV_FTP to VM 14RV-FSRV-123:FTP_PASV"

```
##### Picture
![a_fw_r](https://user-images.githubusercontent.com/13208359/212095637-db61881b-662b-4f9c-96d6-4071bef78623.png)

##### Example
```bash
add_fw_redir wan_port_start="1443" lan_port="443" lan_ip="192.168.133.47" ip_proto="tcp" comment="NAT: false HTTPS to VM 14RV-FSRV-47:HTTPS"
```
```bash

operation completed: 
{"success":true}

result:
{"enabled":true,"comment":"NAT: false HTTPS to VM 14RV-FSRV-47:HTTPS","id":75,"valid":true,"src_ip":"0.0.0.0","hostname":"192.168.133.47","lan_port":443,"wan_port_end":1443,"wan_port_start":1443,"lan_ip":"192.168.133.47","ip_proto":"tcp"}

```

##### Picture
![a_fw](https://user-images.githubusercontent.com/13208359/212095757-5afb9e0c-b723-455f-9b81-bdf6ce14c09f.png)


Now you can verify with the 'list_fw_redir' function
```bash
list_fw_redir | egrep --color=never '1443|port'
```
```bash
#:	id:	lan-port:	protocol:	lan_ip:			wan-port-range:		allowed-ip	state:		hostname:
22:	75	443		tcp		192.168.133.47		1443	1443		0.0.0.0   	active  	192.168.133.47

```
##### Picture
![a_fw_ok](https://user-images.githubusercontent.com/13208359/212096030-1b06be45-9328-405a-a8fd-f5c22a55fc29.png)

-------------------------------------------------------------------------------

 
#### *  upd_fw_redir *array_of_strings*
This function update an existant destination NAT redirection. Port range, status allowed-ip (parameter name: src_ip) and lan destination ip address can be updated.
 
 
##### Example
```bash
upd_fw_redir
```
```bash

ERROR: <param> for "upd_fw_redir" must be some of:
id=			# id: must be a number: id of nat rule to modify
lan_port=		# lan start port: must be a number in [1-65535]
wan_port_start=		# wan start port: must be a number in [1-65535]
wan_port_end=		# wan end port: must be a number in [1-65535]
lan_ip=			# local destination ip
ip_proto=		# must be: 'tcp' or 'udp'
src_ip=			# allowed ip: default all ip allowed
enabled=		# boolean 'true' or 'false': default 'true'
comment=		# string: maximum 63 char 

NOTE: please run "list_fw_redir" to get list of all rules 'id' 

NOTE: minimum parameters to specify on cmdline to update a destination NAT redirection: 
id=
wan_port_start=

WARNING: if not specified on cmdline following parameters will be reset to their default values
wan_port_end=		# default value: wan_port_start
src_ip=			# default: all ip allowed: 0.0.0.0
enabled=		# default: true

EXAMPLE: (simple)
upd_fw_redir id=34 wan_port_start="443" lan_port="443" lan_ip="192.168.123.123" comment="NAT: destination nat: HTTPS to VM 14RV-FSRV-123:HTTPS"

EXAMPLE: (full)
upd_fw_redir id=34 wan_port_start="60000" wan_port_end="60010" lan_port="60000" lan_ip="192.168.123.123" comment="NAT: destination nat: FTP(S) PASIVE PORT to VM 14RV-FSRV-123:FTP_PASV"

```

##### Picture
![upd_fw_r](https://user-images.githubusercontent.com/13208359/212099488-32fcb86b-6bff-4cc7-8848-9e800f081787.png)

##### Example
```bash
upd_fw_redir id=75 wan_port_start=1443 src_ip=88.77.66.55
```
```bash

operation completed: 
{"success":true}

result:
{"enabled":true,"comment":"NAT: false HTTPS to VM 14RV-FSRV-47:HTTPS","id":75,"valid":true,"src_ip":"88.77.66.55","hostname":"192.168.133.47","lan_port":443,"wan_port_end":1443,"wan_port_start":1443,"lan_ip":"192.168.133.47","ip_proto":"tcp"}

```

##### Picture
![upd_fw](https://user-images.githubusercontent.com/13208359/212099751-ba0b4989-20b8-4a52-904e-816dde2b28c2.png)

Now you can verify with the 'list_fw_redir' function that the redirection had been updated, allowed-ip change from 0.0.0.0 to 88.77.66.55
```bash
list_fw_redir | egrep --color=never '1443|port'
```
```bash
#:	id:	lan-port:	protocol:	lan_ip:			wan-port-range:		allowed-ip	state:		hostname:
22:	75	443		tcp		192.168.133.47		1443	1443		88.77.66.55   	active  	192.168.133.47
```
##### Picture
![upd_fw_ok](https://user-images.githubusercontent.com/13208359/212099860-db0e57cf-d2a9-4d11-8e36-24b7f8808db4.png)


-------------------------------------------------------------------------------

 
#### *  dis_fw_redir *integer*
This function simply disable a previously created NAT redirection. This function take 'id' as argument. You can list all incoming NAT redirection and get a list of all 'id' with function 'list_fw_redir'.
 

##### Example
```bash
dis_fw_redir
```
```bash

ERROR: <param> for "dis_fw_redir" must be :
id			# id: must be a number

NOTE: please run  "list_fw_redir" to get list of all destination NAT redirection (showing all 'id'):
list_fw_redir

EXAMPLE:
dis_fw_redir 34

```

##### Picture
![dis_fw_r](https://user-images.githubusercontent.com/13208359/212105120-5f6eb565-9a7e-4770-8cb7-c8b1fe21341f.png)


##### Example
```bash
dis_fw_redir 75
```
```bash

operation completed: 
{"success":true}

result:
{"enabled":false,"comment":"NAT: false HTTPS to VM 14RV-FSRV-47:HTTPS","id":75,"valid":true,"src_ip":"88.77.66.55","hostname":"192.168.133.47","lan_port":443,"wan_port_end":1443,"wan_port_start":1443,"lan_ip":"192.168.133.47","ip_proto":"tcp"}

```

##### Picture
![dis_fw](https://user-images.githubusercontent.com/13208359/212105368-17c57904-3263-48a2-8e8d-2a1798b969b0.png)


Now you can verify with the 'list_fw_redir' function that the redirection had been disabled (state value is now 'disabled')
```bash
list_fw_redir | egrep --color=never '1443|port'
```
```bash
#:	id:	lan-port:	protocol:	lan_ip:			wan-port-range:		allowed-ip	state:		hostname:
22:	75	443		tcp		192.168.133.47		1443	1443		88.77.66.55   	disabled	192.168.133.47
```
##### Picture
![dis_fw_o](https://user-images.githubusercontent.com/13208359/212105475-82e11344-43ad-4ff7-b08c-96aa98ca1776.png)

 

-------------------------------------------------------------------------------
 
#### *  ena_fw_redir *integer*
This function simply enable a previously created NAT redirection. This function take 'id' as argument. You can list all incoming NAT redirection and get a list of all 'id' with function 'list_fw_redir'.


##### Example
```bash
ena_fw_redir
```
```bash

ERROR: <param> for "ena_fw_redir" must be :
id			# id: must be a number

NOTE: please run "list_fw_redir" to get list of all destination NAT redirection (showing all 'id'):
list_fw_redir

EXAMPLE:
ena_fw_redir 34

```

##### Picture
![ena_fw_r](https://user-images.githubusercontent.com/13208359/212106453-e4fd299c-4caa-4298-9ac5-7788c0c3316d.png)

##### Example
```bash
ena_fw_redir 75
```
```bash

operation completed: 
{"success":true}

result:
{"enabled":true,"comment":"NAT: false HTTPS to VM 14RV-FSRV-47:HTTPS","id":75,"valid":true,"src_ip":"88.77.66.55","hostname":"192.168.133.47","lan_port":443,"wan_port_end":1443,"wan_port_start":1443,"lan_ip":"192.168.133.47","ip_proto":"tcp"}

```

##### Picture
![ena_fw](https://user-images.githubusercontent.com/13208359/212106232-01e3ef8e-921c-4fa1-8b29-3522386db174.png)

Now you can verify with the 'list_fw_redir' function that the redirection had been enabled (state value is now 'active' again)
```bash
list_fw_redir | egrep --color=never '1443|port'
```
```bash
#:	id:	lan-port:	protocol:	lan_ip:			wan-port-range:		allowed-ip	state:		hostname:
22:	75	443		tcp		192.168.133.47		1443	1443		88.77.66.55   	active  	192.168.133.47
```
##### Picture
![ena_fw_o](https://user-images.githubusercontent.com/13208359/212106015-4cf18d1b-dc45-4424-a0f1-81f222c58cdd.png) 
 
 

-------------------------------------------------------------------------------

#### *  del_fw_redir *integer*
This function simply delete an incoming NAT redirection. This function take 'id' as argument. You can list all incoming NAT redirection and get a list of all 'id' with function 'list_fw_redir'. 
 
##### Example
```bash
del_fw_redir
```
```bash

ERROR: <param> for "del_fw_redir" must be :
id			# id: must be a number

NOTE: please run "list_fw_redir" to get list of all destination NAT redirection (showing all 'id'):
list_fw_redir

EXAMPLE:
del_fw_redir 34

```
##### Picture
![del_fw_r](https://user-images.githubusercontent.com/13208359/212110182-d2584bc0-2f7d-4c6e-944a-ee2e71a1dd0b.png)

##### Example
```bash
del_fw_redir 75
```
```bash

operation completed: 
{"success":true}

```
##### Picture
![del_fw](https://user-images.githubusercontent.com/13208359/212110347-d9e70b8f-d64d-468e-a993-98f3ad71e887.png)
 
Now you can verify with the 'list_fw_redir' function that the redirection had been suppressed but for changing, we will just try to delete the same redirection once again (this NAT redirection is already deleted). You can notice that the redirection does not exist anymore:
```bash
del_fw_redir 75
```
```bash

operation failed ! 
Impossible de supprimer la redirection : Entrée non trouvée: noent

```
##### Picture
![del_fw_o](https://user-images.githubusercontent.com/13208359/212110489-bdce5382-a55f-4701-b007-3f06d6449fe8.png)
 
 

__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________

<a name="FS"></a>

API FRONTEND FUNCTIONS - FILESYSTEM 
-----------------

This API let you list and manage files and directory on Freebox storage.
It also let you extract and create archives.

To be honest, we cannot work with 'share link api' or 'download api' or 'vm api' without having file and filesystem management. 

Let's imagine the following scenario: 
- You want to build / start a VM for a particular service
- You also want to publish and share your VM image (after adding inside your own configuration) to other Freebox Delta users

Just have a look on what differents tasks you will have to do with the API:
- You will have to download a VM image or an ISO for installing your VM
	- so you need to use the function which manage the download API 
- Maybe you will download a compressed archive
	- so you will need to extract it before using it
	- Maybe you will need to create directories, remove source archive...

After you create, start and configure your VM (using [fbxvm-ctrl](https://github.com/nbanb/fbxvm-ctrl) prgram) you want to share the image with other Freebox Delta users
- You will have to publish a copy of your VM disk image
	- so you will need to temporary stop your VM
	- you will need to copy the VM disk image
	- you will need to create a 'public' directory 
	- maybe you will need to create an archive    
- You may need to move the newly created archive to your public directory 
	- and you will need to create a share link with the share link functions of the library
Finaly, you can publish / post your share link to others users on some forums, ... 

So it was required that simple tasks like ls, cp, mv, rm, mkdir were availiable in this library

When using this API, you will have to manage 'filesystem tasks' for one hand and in the other hand you will have to manage 'filesystem operations (actions)'  



__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________

<a name="FSTSK"></a>

### FILESYSTEM TASKS MANAGEMENT

#### *  check_and_feed_fs_task_param *array_of_strings*
This function will check if the provided arguments are valid parameters for the function which is calling it depending of the "action" set by the calling function. If not, function param_fs_task_err will be called to set error and display help for the command depending on "action" set by the calling function. "action" are: 'hash, get, upd, show, del, mon'. This function will also check argument validity and return 0 if success or 1 if error. This function also return a json 'fs_task_param_object' to be passed as argument to api call function

##### Example
```bash  
action=upd
check_and_feed_fs_task_param 215 state="paused"
echo -e "${fs_task_param_object}"
```
```bash
{"state":"paused"}
```

-------------------------------------------------------------------------------

#### *  param_fs_task_err
This function will display help / manual and example on the command which calling it, depending of the "action" set by the calling function. This function also set variable "error=1". "error" variable content is always checked before each API execution, and if error=1, nothing happends and the lib exit cleanly. "action" are: 'hash, get, upd, show, del, mon'. This function return error=1 when it has been called
This function is mostly called by 'check_and_feed_fs_task_param' function 


-------------------------------------------------------------------------------

#### *  list_fs_task
This function will simply list all filesystem tasks and also show the status of each task

##### Example
```bash  
list_fs_task
```  
```bash

					LIST OF FILESYSTEM TASKS:

------------------------------------------------------------------------------------------------------------------------
id: 286	start: 20221230-17:58:34	end: 20221230-17:59:11	%progress: 100 %  	size: 10032 MB
	status: done			time: 12s		from: /FBX24T/dl/vm1/delta-opensuze-N87.qcow2
	error: none			end-in: 0s		to:   /FBX24T/dl/vm1/vm10/delta-opensuze-N87.qcow2
	task type: cp			#files: 2 		dst:  /FBX24T/dl/vm1/vm10
------------------------------------------------------------------------------------------------------------------------
id: 288	start: 20221230-18:03:43	end: 20221230-18:03:43	%progress: 100 %  	size: 0 B 
	status: done			time: 0s		from: [f:empty_value]
	error: none			end-in: 0s		to:   [t:empty_value]
	task type: mv			#files: 2 		dst:  /FBX24T/dl/vm1/vm12
------------------------------------------------------------------------------------------------------------------------
id: 291	start: 20221230-18:12:18	end: 20221230-18:12:18	%progress: 100 %  	size: 0 B 
	status: done			time: 0s		from: /FBX24T/dl/vm1/vm11/delta-opensuze-ZN87.qcow2
	error: none			end-in: 0s		to:   [t:empty_value]
	task type: rm			#files: 0 		dst:  [d:empty_value]
------------------------------------------------------------------------------------------------------------------------
id: 299	start: 20221230-18:29:55	end: 20221230-18:30:03	%progress: 100 %  	size: 1001 MB
	status: done			time: 0s		from: /FBX24T/dl/vm1/vm12/delta-opensuze.tar.gz
	error: none			end-in: 0s		to:   delta-opensuze-ZN90.qcow2
	task type: extract		#files: 0 		dst:  /FBX24T/dl/vm1/vm13
------------------------------------------------------------------------------------------------------------------------
id: 303	start: 20221231-02:43:01	end: 20221231-02:43:44	%progress: 100 %  	size: 9536 MB
	status: done			time: 38s		from: [f:empty_value]
	error: none			end-in: 0s		to:   [t:empty_value]
	task type: hash			#files: 1 		dst:  [d:empty_value]
------------------------------------------------------------------------------------------------------------------------
id: 305	start: 20221231-10:27:48	end: 20221231-11:21:11	%progress: 100 %  	size: 46 GB
	status: done			time: 3203s		from: /FBX24T/dl/delta-10G-xvxNX.tar.gz
	error: none			end-in: 0s		to:   /FBX24T/dl/vm1/vm15/nba50g.tar.gz
	task type: archive		#files: 1 		dst:  /FBX24T/dl/delta-10G-xvxNX.tar.gz
------------------------------------------------------------------------------------------------------------------------
id: 329	start: 20230104-11:25:12	end: 20230104-11:31:59	%progress: 100 %  	size: 500 MB
	status: done			time: 407s		from: /FBX24T/dl/vm1/vm13/delta-opensuze-ZN89.qcow2
	error: none			end-in: 0s		to:   /FBX24T/dl/vm1/vm13/nba500m1.7z
	task type: archive		#files: 2 		dst:  /FBX24T/dl/vm1/vm13/delta-opensuze-ZN89.qcow2
------------------------------------------------------------------------------------------------------------------------
id: 285	start: 20221230-17:41:39	end: 20221230-17:41:39	%progress: 100 %  	size: 0 B 
	status: failed			time: 0s		from: /FBX24T/dl/vm1/delta-10G-01.tar.gz
	error: dest_is_not_dir		end-in: 0s		to:   [t:empty_value]
	task type: cp			#files: 2 		dst:  /FBX24T/dl/vm1/vm10
------------------------------------------------------------------------------------------------------------------------
id: 301	start: 20221231-02:41:29	end: 20221231-02:41:29	%progress: 100 %  	size: 0 B 
	status: failed			time: 0s		from: /FBX24T/dl/delta-10G.tar.gz
	error: file_not_found		end-in: 0s		to:   [t:empty_value]
	task type: hash			#files: 0 		dst:  [d:empty_value]
------------------------------------------------------------------------------------------------------------------------

```  

##### Picture
![fst_l](https://user-images.githubusercontent.com/13208359/212299327-637e0657-8717-4712-be92-f9b0ac72d26a.png)

-------------------------------------------------------------------------------

#### *  show_fs_task *integer*
This function will simply show a particular filesystem tasks and also display its status 
This function have a pretty human readable outpout
##### Example
```bash  
show_fs_task 329
```  
```bash
					SHOW FILESYSTEM TASK: 329

------------------------------------------------------------------------------------------------------------------------
id: 329	start: 20230104-11:25:12	end: 20230104-11:31:59	%progress: 100 %  	size: 500 MB
	status: done			time: 407s		from: /FBX24T/dl/vm1/vm13/delta-opensuze-ZN89.qcow2
	error: none			end-in: 0s		to:   /FBX24T/dl/vm1/vm13/nba500m1.7z
	task type: archive		#files: 1 		dst:  /FBX24T/dl/vm1/vm13/delta-opensuze-ZN89.qcow2
------------------------------------------------------------------------------------------------------------------------

```  


##### Picture
![fst_s](https://user-images.githubusercontent.com/13208359/212299450-6845e441-117c-4d0a-93c9-622842e1cf3b.png)

-------------------------------------------------------------------------------

#### *  get_fs_task *integer*
This function will simply retrieve informations on a particular filesystem tasks 
It provide a "machine' output to be parsed by another script or program

##### Example
```bash  
get_fs_task 329
```  
```bash

operation completed: 
{"success":true}

result:
{"curr_bytes_done":525300000,"total_bytes":525300000,"nfiles_done":1,"started_ts":1672827912,"duration":407,"done_ts":1672828319,"src":["/FBX24T/dl/vm1/vm13/nba500m1.7z"],"curr_bytes":525300000,"type":"archive","to":"/FBX24T/dl/vm1/vm13/nba500m1.7z","id":329,"nfiles":1,"created_ts":1672827912,"state":"done","total_bytes_done":525300000,"rate":0,"from":"/FBX24T/dl/vm1/vm13/delta-opensuze-ZN89.qcow2","dst":"/FBX24T/dl/vm1/vm13/delta-opensuze-ZN89.qcow2","eta":0,"error":"none","progress":100}

```

##### Picture
![fst_g](https://user-images.githubusercontent.com/13208359/212299584-0dadea82-bae9-4d38-84bc-34410ac8a72a.png)


-------------------------------------------------------------------------------

#### *  hash_fs_task *integer*
This function will simply retrieve the hash value of a file after it had been compute by a filesystem hash action task. When task is finished, this function show the hash value  
This function provide a result only on 'hash' filesystem operation task

##### Example
```bash  
hash_fs_task 303
```  
```bash

operation completed: 
{"success":true}

result:
"0dad41fca4a5309b0a838d9928718a10ef6e08a51412753fe7ad41d9cd7b136625d8b083462f07ab9f8e9ce1a7ec30edb4a0eb730d01191df79588407b38238b"}

```  

##### Picture
![fst_h](https://user-images.githubusercontent.com/13208359/212299645-3a81a5dc-3f98-4600-aa19-430a310220a3.png)

-------------------------------------------------------------------------------

#### *  upd_fs_task *integer* *string*
This function will update a filesystem task. 
Possible updates actions:  'pause' or 'running' 
This function allow you to stop a task and to restart it later 
##### Example
```bash  
upd_fs_task 
```  
```bash

ERROR: <param> for "upd_fs_task" must be some of:
id 			# Task id: MUST be a number
state= 			# Status action: paused or running 

NOTE: minimum parameters to specify on cmdline to update a download task: 
id 
state= 

EXAMPLE:
upd_fs_task 215 state="paused" 


operation failed ! 

```  
##### Picture
![upd_fst_r](https://user-images.githubusercontent.com/13208359/212356088-d0097b98-6fc0-4d19-8431-654e3cfbd228.png)


Now we will pause a running fs task and restart it

##### Example
```bash  
upd_fs_task 347 state=paused
```  
```bash

operation completed: 
{"success":true}

result:
{"curr_bytes_done":97510000,"total_bytes":1050000000,"nfiles_done":0,"started_ts":1673618597,"duration":78,"done_ts":0,"src":["/FBX24T/dl/vm1/vm16/delta-osz.tar.xz","/FBX24T/dl/vm1/vm11/delta-opensuze-ZN89.qcow2"],"curr_bytes":525300000,"type":"archive","to":"/FBX24T/dl/vm1/vm16/delta-osz.tar.xz","id":347,"nfiles":2,"created_ts":1673618597,"state":"paused","total_bytes_done":97510000,"rate":0,"from":"/FBX24T/dl/vm1/vm11/delta-opensuze-ZN89.qcow2","dst":"/FBX24T/dl/vm1/vm11/delta-opensuze-ZN90.qcow2","eta":788,"error":"none","progress":9}

```  

##### Picture
![upd_fst_p](https://user-images.githubusercontent.com/13208359/212355944-b100990c-9fc6-43b6-8bfb-cd37d0fe65ce.png)

Let confirm the task is successfully updated and in status paused (see status value)
```bash  
show_fs_task 347
``` 
```bash

					SHOW FILESYSTEM TASK: 347

------------------------------------------------------------------------------------------------------------------------
id: 347	start: 20230113-15:03:17	end: 19700101-01:00:00	%progress: 9 %  	size: 92 MB
	status: paused			time: 78s		from: /FBX24T/dl/vm1/vm11/delta-opensuze-ZN89.qcow2
	error: none			end-in: 788s		to:   /FBX24T/dl/vm1/vm16/delta-osz.tar.xz
	task type: archive		#files: 0 		dst:  /FBX24T/dl/vm1/vm11/delta-opensuze-ZN90.qcow2
------------------------------------------------------------------------------------------------------------------------

``` 

##### Picture
![upd_fst_ps](https://user-images.githubusercontent.com/13208359/212355743-3fcce37f-6691-489a-94b4-c068e3c9a98d.png)

Now we will restart the task we just paused

##### Example
```bash  
upd_fs_task 347 state=running
```  
```bash

operation completed: 
{"success":true}

result:
{"curr_bytes_done":97510000,"total_bytes":1050000000,"nfiles_done":0,"started_ts":1673618597,"duration":78,"done_ts":0,"src":["/FBX24T/dl/vm1/vm16/delta-osz.tar.xz","/FBX24T/dl/vm1/vm11/delta-opensuze-ZN89.qcow2"],"curr_bytes":525300000,"type":"archive","to":"/FBX24T/dl/vm1/vm16/delta-osz.tar.xz","id":347,"nfiles":2,"created_ts":1673618597,"state":"running","total_bytes_done":97510000,"rate":0,"from":"/FBX24T/dl/vm1/vm11/delta-opensuze-ZN89.qcow2","dst":"/FBX24T/dl/vm1/vm11/delta-opensuze-ZN90.qcow2","eta":788,"error":"none","progress":9}

```  

##### Picture
![upd_fst_ru](https://user-images.githubusercontent.com/13208359/212355565-ab66d432-267d-42ac-aabe-47765984f3e5.png)

Let confirm again the task is successfully updated and in status running (see status value)
```bash  
show_fs_task 347
``` 
```bash

					SHOW FILESYSTEM TASK: 347

------------------------------------------------------------------------------------------------------------------------
id: 347	start: 20230113-15:03:17	end: 19700101-01:00:00	%progress: 9 %  	size: 92 MB
	status: running			time: 85s		from: /FBX24T/dl/vm1/vm11/delta-opensuze-ZN89.qcow2
	error: none			end-in: 781s		to:   /FBX24T/dl/vm1/vm16/delta-osz.tar.xz
	task type: archive		#files: 0 		dst:  /FBX24T/dl/vm1/vm11/delta-opensuze-ZN90.qcow2
------------------------------------------------------------------------------------------------------------------------

``` 

##### Picture
![upd_fst_rus](https://user-images.githubusercontent.com/13208359/212355414-2e0023a9-845c-447c-a898-ff5dba40b857.png)

-------------------------------------------------------------------------------

#### *  mon_fs_task *integer*
This function monitor a filesystem task.
When task are long (sometimes hours or days), and longer than the login session timeout the monitor function should logically be disconnected, so to avoid this behaviour, this function has the capacity of automatically relogin and continue monitoring. In other words, this function monitor the task in foreground and the login session in background and if session expire, it automatically relogin

##### Example
```bash  
mon_fs_task 
```  
```bash

ERROR: <param> must be :
id

NOTE: you can get a list of filesystem tasks (showing all 'id'), just run: 
list_fs_task_api

EXAMPLE:
mon_fs_task 215 

```  

##### Picture
![mon_fst_r](https://user-images.githubusercontent.com/13208359/212355151-fc1d7709-6861-45c1-83bd-84b13a5498c4.png)


Now we will monitor a running task

##### Example
```bash  
mon_fs_task 348
```  
```bash

task 348 running ... 
|.................................................                                                                 |  43 % 371s end: 480s 437MB  

```  
##### Picture
![mon_fst_run2](https://user-images.githubusercontent.com/13208359/212355027-ded67d71-d06a-437d-b38d-7e13acbbb2fd.png)

And when the task is finished
##### Example
```bash  
mon_fs_task 347
```  
```bash
task 347 running ... 
|..................................................................................................................| 100 % 822s end: 0s 1001MB  
task 347 done ... 

```  
##### Picture
![mon_fst_done](https://user-images.githubusercontent.com/13208359/212354872-a33caca7-3c7e-4196-a9bd-f96e073cd6b7.png)


-------------------------------------------------------------------------------

#### *  del_fs_task *integer*
This function delete a filesystem task

##### Example
```bash  
del_fs_task 
```
```bash

ERROR: <param> must be :
id

NOTE: you can get a list of filesystem tasks (showing all 'id'), just run: 
list_fs_task_api

EXAMPLE:
del_fs_task 215 

```

##### Picture
![del_fst_r](https://user-images.githubusercontent.com/13208359/212354608-7d98a294-da98-41f2-80ae-d915e9804a3e.png)

Now, we will delete our finished task 347

```bash  
del_fs_task 347 
```
```bash

operation completed: 
{"success":true}


```


##### Picture
![del_fst](https://user-images.githubusercontent.com/13208359/212354486-cdc16179-f8e6-43ee-92db-4bd1573e2a5c.png)

And again, we will verify that our task had been successfully deleted with function 'show_fs_task'

```bash  
show_fs_task 347 
```
```bash

					SHOW FILESYSTEM TASK: 347

------------------------------------------------------------------------------------------------------------------------

No filesystem tasks to list !


```

##### Picture
![del_fst_s](https://user-images.githubusercontent.com/13208359/212354370-5ad40f4f-fdcd-47ab-aa75-3332b0f2c42f.png)



__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________

<a name="FSOP"></a>


### FILESYSTEM OPERATIONS (ACTIONS)

#### *  check_and_feed_fs_param *array_of_strings*
This function will check if the provided arguments are valid parameters for the function which is calling it depending of the "action" set by the calling function. If not, function param_fs_err will be called to set error and display help for the command depending on "action" set by the calling function. "action" are: 'hash, extract, archive, mkdir, rename, cp, mv, rm, del'. This function will also check argument validity and return 0 if success or 1 if error. 
This function return a json 'fs_param_object' to be passed to the API call functions

##### Example
```bash  
action=hash
check_and_feed_fs_param src="/FBXDSK/vm/vm1-disk0.qcow2" hash_type="sha256"
echo $fs_param_object
```
```bash
{"src":"L0ZCWERTSy92bS92bTEtZGlzazAucWNvdzI=","hash_type":"sha256"}
```

-------------------------------------------------------------------------------

#### *  param_fs_err
This function will display help / manual and example on the command which calling it, depending of the "action" set by the calling function. This function also set variable "error=1". "error" variable content is always checked before each API execution, and if error=1, nothing happends and the lib exit cleanly. "action" are: 'hash, extract, archive, mkdir, rename, cp, mv, rm, del'. This function return error=1 when it has been called
This function is mostly called by 'check_and_feed_fs_param' function 

-------------------------------------------------------------------------------

#### *  ls_fs *path* *optional_options*
This function list your box storage. 
To avoid performance issue when directory listing is big (which want to say that the json object replied by the API will be more than 100KB), this function CACHE result and work in-memory instead of polling the API each time we need to retrieve a value for each file (traditional way)
Imagine if we need to retrieve 10 values on 100 files with no caching of results, we will need 1000 API call to print the result... 
Previous listing function of this library (list_fs_file) does not cache API results and suffers of performance issue when the directory contains more than 15 files or directories, so you MUST NOT use it except on very small directory, so with the new 'ms_fs' function, this old function become deprecated    

##### Example
```bash  
ls_fs /FBX24T/dl/vm1
```
```bash  
idx: 0	hidden	dir	20230113-17:09:12	size: 4096 B	name: .
idx: 1	hidden	dir	20230112-09:33:26	size: 4096 B	name: ..
idx: 2		dir	20221230-17:59:09	size: 4096 B	name: vm10
idx: 3		dir	20221230-18:14:44	size: 4096 B	name: vm11
idx: 4		dir	20221230-18:23:33	size: 4096 B	name: vm12
idx: 5		dir	20230104-11:25:12	size: 4096 B	name: vm13
idx: 6		dir	20230103-22:17:21	size: 4096 B	name: vm14
idx: 7		dir	20221231-11:38:45	size: 4096 B	name: vm15
idx: 8		dir	20230113-15:37:38	size: 4096 B	name: vm16
idx: 9		dir	20230113-17:17:28	size: 4096 B	name: vm17
idx: 10		file	20221229-23:51:20	size: 9 GB	name: delta-10G-01.tar.gz
idx: 11		file	20221231-10:11:15	size: 9 GB	name: delta-10G-222.tar.gz
idx: 12		file	20221231-10:32:54	size: 9 GB	name: delta-10G-223.tar.gz
idx: 13		file	20221231-11:04:36	size: 9 GB	name: delta-10G-224.tar.gz
idx: 14		file	20221231-11:33:45	size: 9 GB	name: delta-10G-225.tar.gz
idx: 15		file	20221228-13:08:13	size: 500 MB	name: delta-opensuze-N87.qcow2
```
##### Picture
![ls](https://user-images.githubusercontent.com/13208359/212380781-4be68d1a-a026-4271-aeb2-8be7ae4e6170.png)


This function also takes some optionals arguments to pass on the cmdline to filter output:
```
onlyFolder (bool)	--> Only list folders
removeHidden (bool)	--> Don’t return hidden files in directory listing
```

These options are boolean so you must specify the value you affected to the option (0 or 1) 
##### Example
```bash  
ls_fs /FBX24T/dl/vm1 onlyFolder=1 removeHidden=0
```
```bash  
idx: 0	hidden	dir	20230113-17:09:12	size: 4096 B	name: .
idx: 1	hidden	dir	20230112-09:33:26	size: 4096 B	name: ..
idx: 2		dir	20221230-17:59:09	size: 4096 B	name: vm10
idx: 3		dir	20221230-18:14:44	size: 4096 B	name: vm11
idx: 4		dir	20221230-18:23:33	size: 4096 B	name: vm12
idx: 5		dir	20230104-11:25:12	size: 4096 B	name: vm13
idx: 6		dir	20230103-22:17:21	size: 4096 B	name: vm14
idx: 7		dir	20221231-11:38:45	size: 4096 B	name: vm15
idx: 8		dir	20230113-15:37:38	size: 4096 B	name: vm16
idx: 9		dir	20230113-17:17:28	size: 4096 B	name: vm17
```

##### Picture
![ls_opt](https://user-images.githubusercontent.com/13208359/212381033-d65bbd0a-09f0-4e1c-88ae-5293730cb5fc.png)

-------------------------------------------------------------------------------

#### *  list_fs_file *path*

$${\color{red}\text{This function is DEPRECATED and MUST NOT BE USED ! }}$$

This function intend to have the same function as 'ls_fs' function BUT 
- it does not accept boolean options (onlyFolder & removeHidden)
- by design, when directory listing is big, suffer of performance issue 
- if we need to retrieve 10 values on 100 files this function will do 1000 API call to get the result... 

$${\color{red}\text{I let it in the lib as an example of what you should not do }}$$

-------------------------------------------------------------------------------

#### *  cp_fs_file *array_of_strings*
This function copy files provided as source files to the destination you provide as dst. 
This function act like 'cp' function in your bash terminal but only work on your box filesystem
All copy operation will be enqueued as a filesystem task

Some copy operations an result in conflict, so you have to specify the conflict resolution mode on the cmdline when you copy some files. 

##### Possible conflict resolution modes :
```
overwrite	--> Overwrite the destination file
both		--> Keep both files (rename the file adding a suffix)
recent		--> Only overwrite if newer than destination file
skip		--> Keep the destination file
```

##### Example
```bash  
cp_fs_file
```
```bash

ERROR: <param> for "cp_fs_file" must be some of:
files= 			# List of files to cp separated by a coma "," - avoid spaces in filename 
dst=			# The destination
mode= 			# Conflict resolution : overwrite, both, skip, recent  

NOTE: minimum parameters to specify on cmdline to cp a file/dir: 
files=
dst=
mode= 

EXAMPLE (simple):
cp_fs_file files="/FBXDSK/vm/vm1-disk0.qcow2" dst="/FBXDSK/vm2" mode="overwrite" 

EXAMPLE (multiple files/dir):
cp_fs_file files="/FBXDSK/vm/vm1-disk0.qcow2,/FBXDSK/vm/vm2-disk0.qcow2" dst="/FBXDSK/vm2" mode="overwrite" 

```

##### Picture
![cp_r](https://user-images.githubusercontent.com/13208359/212378600-75736b30-8590-4882-bf82-76fcf2aaf7c7.png)

##### Example
```bash  
cp_fs_file files=/FBX24T/dl/vm1/delta-10G-222.tar.gz,/FBX24T/dl/vm1/delta-10G-223.tar.gz dst=/FBX24T/dl/vm1/vm17 mode=recent 

```
```bash

operation completed: 
{"success":true}

result:
{"curr_bytes_done":0,"total_bytes":0,"nfiles_done":0,"started_ts":1673626613,"duration":0,"done_ts":0,"src":["/FBX24T/dl/vm1/delta-10G-222.tar.gz","/FBX24T/dl/vm1/delta-10G-223.tar.gz"],"curr_bytes":0,"type":"cp","to":"","id":349,"nfiles":0,"created_ts":1673626613,"state":"running","total_bytes_done":0,"rate":0,"from":"","dst":"/FBX24T/dl/vm1/vm17","eta":0,"error":"none","progress":0}

```

##### Picture
![cp](https://user-images.githubusercontent.com/13208359/212378468-8b2bfdc5-e652-46c0-aa02-c8478fbfbf9b.png)

And now we will verify that our files had been successfully copied to the target directory (here /FBX24T/dl/vm1/vm17) with 'ls_fs' function

```bash  
ls_fs /FBX24T/dl/vm1/vm17 
```
```bash
idx: 0	hidden	dir	20230113-17:17:28	size: 4096 B	name: .
idx: 1	hidden	dir	20230113-17:09:12	size: 4096 B	name: ..
idx: 2		file	20230113-17:17:28	size: 9 GB	name: delta-10G-222.tar.gz
idx: 3		file	20230113-17:18:03	size: 9 GB	name: delta-10G-223.tar.gz

```

##### Picture
![cp_ok](https://user-images.githubusercontent.com/13208359/212378382-cc5bbb68-76bd-402d-a5df-cbaf7588fe88.png)


-------------------------------------------------------------------------------

#### *  mv_fs_file *array_of_strings*
This function move provided files to the specified destination
This function act like 'mv' function in your bash terminal but only work on your box filesystem
All move operation will be enqueued as a filesystem task

Some move operations result in conflict, so you have to specify the conflict resolution mode on the cmdline when you move some files. 

##### Possible conflict resolution modes :
```
overwrite	--> Overwrite the destination file
both		--> Keep both files (rename the file adding a suffix)
recent		--> Only overwrite if newer than destination file
skip		--> Keep the destination file
```


##### Example
```bash
mv_fs_file
```
```bash

ERROR: <param> for "mv_fs_file" must be some of:
files= 			# List of files to mv separated by a coma "," - avoid spaces in filename 
dst=			# The destination
mode= 			# Conflict resolution : overwrite, both, skip, recent  

NOTE: minimum parameters to specify on cmdline to mv a file/dir: 
files=
dst=
mode= 

EXAMPLE (simple):
mv_fs_file files="/FBXDSK/vm/vm1-disk0.qcow2" dst="/FBXDSK/vm2" mode="overwrite" 

EXAMPLE (multiple files/dir):
mv_fs_file files="/FBXDSK/vm/vm1-disk0.qcow2,/FBXDSK/vm/vm2-disk0.qcow2" dst="/FBXDSK/vm2" mode="overwrite" 

```

##### Picture
![mv_fst_r](https://user-images.githubusercontent.com/13208359/212465151-c9e0fe9d-8a10-4bbb-9154-0b9df8e9edf1.png)


If you forgot to specify the conflict 'mode' resolution, you will get the following error from API
##### Example
```bash
mv_fs_file files=/FBX24T/dl/vm1/delta-10G-222.tar.gz,/FBX24T/dl/vm1/delta-10G-223.tar.gz dst=/FBX24T/dl/vm1/vm18
```
```bash

operation failed ! 
Erreur lors du déplacement des fichiers : Le mode de résolution de conflit spécifié est invalide: invalid_conflict_mode

```
##### Picture
![mv_fst_e](https://user-images.githubusercontent.com/13208359/212465134-852f3e00-a2b2-4992-a1d9-057f276240fd.png)

So, now we will specify the resolution mode
##### Example
```bash
mv_fs_file files=/FBX24T/dl/vm1/delta-10G-222.tar.gz,/FBX24T/dl/vm1/delta-10G-223.tar.gz dst=/FBX24T/dl/vm1/vm18 mode=overwrite
```
```bash

operation completed: 
{"success":true}

result:
{"curr_bytes_done":0,"total_bytes":0,"nfiles_done":0,"started_ts":1673686783,"duration":0,"done_ts":0,"src":["/FBX24T/dl/vm1/delta-10G-222.tar.gz","/FBX24T/dl/vm1/delta-10G-223.tar.gz"],"curr_bytes":0,"type":"mv","to":"","id":350,"nfiles":0,"created_ts":1673686783,"state":"running","total_bytes_done":0,"rate":0,"from":"","dst":"/FBX24T/dl/vm1/vm18","eta":0,"error":"none","progress":0}

```
##### Picture
![mv_fst](https://user-images.githubusercontent.com/13208359/212465102-f8eb75c8-2bbd-4af4-a035-64c603daf431.png)


Let's verify that our created task is sucessfully done with 'show_fs_task' function
##### Example
```bash
show_fs_task 350
```
```bash

					SHOW FILESYSTEM TASK: 350

------------------------------------------------------------------------------------------------------------------------
id: 350	start: 20230114-09:59:43	end: 20230114-09:59:43	%progress: 100 %  	size: 0 B 
	status: done			time: 0s		from: [f:empty_value]
	error: none			end-in: 0s		to:   [t:empty_value]
	task type: mv			#files: 0 		dst:  /FBX24T/dl/vm1/vm18
------------------------------------------------------------------------------------------------------------------------

```

##### Picture
![mv_fst_vs](https://user-images.githubusercontent.com/13208359/212465088-9f1ae9af-dbc6-43d5-b4ff-bbcddde3e399.png)

Task is sucessfully done, so we will verify that files were successfully moved in the target directory with 'ls_fs' function

##### Example
```bash
ls_fs /FBX24T/dl/vm1/vm18
```
```bash
idx: 0	hidden	dir	20230114-09:59:43	size: 4096 B	name: .
idx: 1	hidden	dir	20230114-09:59:43	size: 4096 B	name: ..
idx: 2		file	20221231-10:11:15	size: 9 GB	name: delta-10G-222.tar.gz
idx: 3		file	20221231-10:32:54	size: 9 GB	name: delta-10G-223.tar.gz
```
##### Picture
![mv_fst_vl](https://user-images.githubusercontent.com/13208359/212465027-85599f4b-7725-4b17-85ea-154e16e71dc7.png)

Files were moved, we can now delete the moving task (here #350) which had beed created for this example
```bash
del_fs_task 350
```
```bash

operation completed: 
{"success":true}

```
##### Picture
![mv_fst_del](https://user-images.githubusercontent.com/13208359/212465005-39c73ea0-7a41-4d3d-93ad-3cfb6d28f35e.png) 


-------------------------------------------------------------------------------


#### *  mkdir_fs_file *array_of_strings*
This function is used to create directories on your box storage
Contrary to other file system tasks, this operation is done synchronously.

Instead of a returning a Filessystem Task a call to this API will only return success status

##### Example
```bash
mkdir_fs_file
```
```bash

ERROR: <param> for "mkdir_fs_file" must be some of:
parent= 		# The parent directory path 
dirname=		# The name of the directory to create 

NOTE: minimum parameters to specify on cmdline to create a directory: 
parent=
dirname= 

EXAMPLE:
mkdir_fs_file parent="/FBXDSK/vm" dirname="MyNewVMdir"

```
##### Picture
![mkd_fs_r](https://user-images.githubusercontent.com/13208359/212466078-02bb2162-cd42-4913-ad3f-1b438bd745dc.png)


##### Example
```bash
mkdir_fs_file parent=/FBX24T/dl/vm1 dirname=vm18
```
```bash

operation completed: 
{"success":true}

result:
"L0ZCWDI0VC9kbC92bTEvdm0xOA=="}

```

##### Picture
![mkd_fs](https://user-images.githubusercontent.com/13208359/212466051-49650fe8-011e-488b-9b27-53e293555ef1.png)

The result return the base64 final directory path 
It can be verified from your bash terminal 
##### Example
```bash
echo 'L0ZCWDI0VC9kbC92bTEvdm0xOA==' |base64 -d && echo
```
```bash
/FBX24T/dl/vm1/vm18
```
##### Picture
![mkd_fs_vb](https://user-images.githubusercontent.com/13208359/212466022-06902c4a-14ca-4564-81cb-f3d9c49ef121.png)

We can also verify that the directory had been successfully created using 'ls_fs' function: 
Just constat that our 'vm18' directory is present in path '/FBX24T/dl/vm1/'
##### Example
```bash
ls_fs /FBX24T/dl/vm1/
```
```bash
idx: 0	hidden	dir	20230114-09:59:43	size: 4096 B	name: .
idx: 1	hidden	dir	20230112-09:33:26	size: 4096 B	name: ..
idx: 2		dir	20221230-17:59:09	size: 4096 B	name: vm10
idx: 3		dir	20221230-18:14:44	size: 4096 B	name: vm11
idx: 4		dir	20221230-18:23:33	size: 4096 B	name: vm12
idx: 5		dir	20230104-11:25:12	size: 4096 B	name: vm13
idx: 6		dir	20230103-22:17:21	size: 4096 B	name: vm14
idx: 7		dir	20221231-11:38:45	size: 4096 B	name: vm15
idx: 8		dir	20230113-15:37:38	size: 4096 B	name: vm16
idx: 9		dir	20230113-17:17:28	size: 4096 B	name: vm17
idx: 10		dir	20230114-09:59:43	size: 4096 B	name: vm18
idx: 11		file	20221229-23:51:20	size: 9 GB	name: delta-10G-01.tar.gz
idx: 12		file	20221231-11:04:36	size: 9 GB	name: delta-10G-224.tar.gz
idx: 13		file	20221231-11:33:45	size: 9 GB	name: delta-10G-225.tar.gz
idx: 14		file	20221228-13:08:13	size: 500 MB	name: delta-opensuze-N87.qcow2
```
##### Picture
![mkd_fs_vl](https://user-images.githubusercontent.com/13208359/212466012-273ba1aa-6b87-4006-8606-0b5338f51ca9.png)


-------------------------------------------------------------------------------


#### *  rename_fs_file *array_of_strings*
This function is used to rename files and directories on your box storage
Contrary to other file system tasks except 'mkdir_fs_file', this operation is done synchronously.

Instead of a returning a Filessystem Task a call to this API will only return success status

WARNING: The dst argument MUST ONLY CONTAIN new filename and NOT the whole path

##### Example
```bash
rename_fs_file
```
```bash

ERROR: <param> for "rename_fs_file" must be some of:
src= 			# The source file path 
dst=			# The new name of the file (filename only, no path) 

NOTE: minimum parameters to specify on cmdline to  rename a file/dir: 
src=
dst= 

EXAMPLE:
rename_fs_file src="/FBXDSK/vm/vm1-disk0.qcow2" dst="vm2-disk2.qcow2"

```
##### Picture
![ren_fs_r](https://user-images.githubusercontent.com/13208359/212466795-760e2520-9957-4878-a405-ff3883447aaa.png)

##### Example
```bash
rename_fs_file src=/FBX24T/dl/vm1/vm18/delta-10G-222.tar.gz dst=delta-10G-222.tar.gz_renamed
```
```bash

operation completed: 
{"success":true}

result:
"L0ZCWDI0VC9kbC92bTEvdm0xOC9kZWx0YS0xMEctMjIyLnRhci5nel9yZW5hbWVk"}

```
##### Picture
![ren](https://user-images.githubusercontent.com/13208359/212466789-9b13ca75-c629-4c83-84f8-ba9d78792578.png)

The result return the base64 final directory path 
It can be verified from your bash terminal 
##### Example
```bash
echo 'L0ZCWDI0VC9kbC92bTEvdm0xOC9kZWx0YS0xMEctMjIyLnRhci5nel9yZW5hbWVk' |base64 -d && echo
```
```bash
/FBX24T/dl/vm1/vm18/delta-10G-222.tar.gz_renamed
```
##### Picture
![ren_vb](https://user-images.githubusercontent.com/13208359/212466778-7b1e1c18-7779-4376-9ba4-4a69ddd88bc1.png)


Again, we can also verify that the file had been successfully renamed using 'ls_fs' function: 
Just constat that file delta-10G-222.tar.gz had been renamed to delta-10G-222.tar.gz_renamed
##### Example
```bash
ls_fs /FBX24T/dl/vm1/vm18
```
```bash
idx: 0	hidden	dir	20230114-10:55:54	size: 4096 B	name: .
idx: 1	hidden	dir	20230114-09:59:43	size: 4096 B	name: ..
idx: 2		file	20221231-10:11:15	size: 9 GB	name: delta-10G-222.tar.gz_renamed
idx: 3		file	20221231-10:32:54	size: 9 GB	name: delta-10G-223.tar.gz
```
##### Picture
![ren_vl](https://user-images.githubusercontent.com/13208359/212466762-cea44975-5ad0-4085-99b9-c9b915f7ccd6.png)

-------------------------------------------------------------------------------

#### *  rm_fs_file *array_of_strings*
This function simply delete files or folders you passed as argument
It act like your bash builtin command 'rm' but recursive and force options behaviour like 'rm -rf' is also applied here.
##### Example
```bash
rm_fs_file
```
```bash

ERROR: <param> for "rm_fs_file" must be some of:
files= 			# List of files to rm separated by a coma "," - avoid spaces in filename 

NOTE: minimum parameters to specify on cmdline to  rm a file/dir: 
files= 

EXAMPLE (simple):
rm_fs_file files="/FBXDSK/vm/oldvm1-disk0.qcow2" 

EXAMPLE (multiple files/dir):
rm_fs_file files="/FBXDSK/vm/oldvm1-disk0.qcow2,/FBXDSK/vm/oldvm2-disk0.qcow2,/FBXDSK/vm/oldvm3-disk0.qcow2" 

```
##### Picture
![rm_fs_r](https://user-images.githubusercontent.com/13208359/212480446-12f2d7df-d5bd-4bac-9f24-40ed74b61419.png)

##### Example
```bash
rm_fs_file files=/FBX24T/dl/vm1/vm18/delta-10G-223.tar.gz,/FBX24T/dl/vm1/vm18/delta-10G-222.tar.gz_renamed
```
```bash

operation completed: 
{"success":true}

result:
{"curr_bytes_done":0,"total_bytes":0,"nfiles_done":0,"started_ts":1673710920,"duration":0,"done_ts":0,"src":["/FBX24T/dl/vm1/vm18/delta-10G-223.tar.gz","/FBX24T/dl/vm1/vm18/delta-10G-222.tar.gz_renamed"],"curr_bytes":0,"type":"rm","to":"","id":351,"nfiles":0,"created_ts":1673710920,"state":"running","total_bytes_done":0,"rate":0,"from":"/FBX24T/dl/vm1/vm18/delta-10G-223.tar.gz","dst":"","eta":0,"error":"none","progress":0}

```
##### Picture
![rm_fs](https://user-images.githubusercontent.com/13208359/212480478-ed846d48-48bd-4748-b556-47310725d79a.png)

Now we will verify that our files had been successfully been deleted with function 'ls_fs'
##### Example
```bash
ls_fs /FBX24T/dl/vm1/vm18
```
```bash
idx: 0	hidden	dir	20230114-16:42:01	size: 4096 B	name: .
idx: 1	hidden	dir	20230114-09:59:43	size: 4096 B	name: ..
```
##### Picture
![rm_fs_vl](https://user-images.githubusercontent.com/13208359/212480482-d2a956b8-ea80-491b-8fbf-c8136430062a.png)


-------------------------------------------------------------------------------

#### *  del_fs_file *array_of_strings*
This function is an alias of the 'rm_fs_file' function.
The only work of this function is to call 'rm_fs_file' and to pass it all its arguments
So it takes the same parameters and syntaxe and provide the same output
##### See 'rm_fs_file' for detailed help and informations

-------------------------------------------------------------------------------

#### *  hash_fs_file *array_of_strings*
This function let you get compute the hash checksum value of a file.
A task is created, enqueued and executed.
When the task is finished and in status done, you must use 'hash_fs_task' function to retrieve the hash value, as describes in 'hash_fs_task' section of this README
Supported hash format are :
```
md5		--> make a 'mdsum' on the target file
sha1		--> make a 'sha1sum' on the target file
sha256		--> make a 'sha256sum' on the target file
sha512		--> make a 'sha512sum' on the target file
```

##### Example
```bash
hash_fs_file
```
```bash

ERROR: <param> for "hash_fs_file" must be some of:
src=	 			# The source file path to hash 
hash_type=			# The hash algo, can be: md5 sha1 sha256 sha512  

NOTE: minimum parameters to specify on cmdline to  hash a file/dir: 
src=
hash_type= 

EXAMPLE:
hash_fs_file src="/FBXDSK/vm/vm1-disk0.qcow2" hash_type="sha256"

```
##### Picture
![h_r](https://user-images.githubusercontent.com/13208359/212484449-459be3ab-f29e-4c66-aa60-e64847ef79f9.png)

Now we will hash a file 
##### Example
```bash
hash_fs_file src=/FBX24T/dl/vm1/vm18/delta-10G-225.tar.gz hash_type=sha512
```
```bash

operation completed: 
{"success":true}

result:
{"curr_bytes_done":0,"total_bytes":0,"nfiles_done":0,"started_ts":1673712615,"duration":0,"done_ts":0,"curr_bytes":0,"type":"hash","to":"","id":355,"nfiles":0,"created_ts":1673712615,"state":"running","total_bytes_done":0,"rate":0,"from":"","dst":"","eta":0,"error":"none","progress":0}

```
##### Picture
![h_512](https://user-images.githubusercontent.com/13208359/212484426-ad1fa406-78c4-4433-b5c1-9b135d40c58d.png)

So, let's monitor our hash task 
##### Example
```bash
mon_fs_task_api 355
```

Waiting for the end of the task 
```bash
task 355 running ... 
|..................................................................................................................| 100 % 43s end: 0s 9536MB  
task 355 done ... 
```
##### Picture
Running
![h_mon](https://user-images.githubusercontent.com/13208359/212484391-377b1b9d-cf19-4322-8452-5a14956db885.png)
Finished
![h_mon_e](https://user-images.githubusercontent.com/13208359/212484395-4425d1f1-1306-4e72-8f0c-116cd0302798.png)


And verifying the task is in status 'done' with "show_fs_task" function

```bash
show_fs_task_api 355
```
```bash

					SHOW FILESYSTEM TASK: 355

------------------------------------------------------------------------------------------------------------------------
id: 355	start: 20230114-17:10:15	end: 20230114-17:10:58	%progress: 100 %  	size: 9536 MB
	status: done			time: 43s		from: [f:empty_value]
	error: none			end-in: 0s		to:   [t:empty_value]
	task type: hash			#files: 0 		dst:  [d:empty_value]
------------------------------------------------------------------------------------------------------------------------

```
##### Picture
![h_tsk](https://user-images.githubusercontent.com/13208359/212484371-d90fd95e-2312-4759-89fb-b5c65897cf71.png)


To finished, we will now retrieve our hash value with function 'hash_fs_task'

##### Example
```bash
hash_fs_task 355
```
```bash

operation completed: 
{"success":true}

result:
"0dad41fca4a5309b0a838d9928718a10ef6e08a51412753fe7ad41d9cd7b136625d8b083462f07ab9f8e9ce1a7ec30edb4a0eb730d01191df79588407b38238b"}

```

##### Picture
![h_val](https://user-images.githubusercontent.com/13208359/212484329-5249007e-f5ed-41a6-8165-71a321019836.png)



-------------------------------------------------------------------------------


#### *  archive_fs_file *array_of_strings*
This function will make an archive with the files provided as argument.
Supported archive type:
```
.zip		--> a 'zip' archive will be created
.iso		--> a 'iso' archive will be created
.cpio		--> a 'cpio' archive will be created
.tar		--> a 'tar' archive will be created
.tar.gz		--> a 'tar' archive will be created compressed with 'gzip'
.tar.xz		--> a 'tar' archive will be created compressed with 'lzma'
.7z		--> a '7zip' archive will be created
.tar.7z		--> a 'tar' archive will be created compressed with '7zip'
.tar.bz2	--> a 'tar' archive will be created compressed with 'bzip2'
```

The archive type is autodetected by the API from the target archive filename extension
If you named your archive 'someting.zip', a zip archive will be done
If you named your archive 'someting.tar', a tar archive will be done
...


##### Example
```bash
archive_fs_file
```
```bash

ERROR: <param> for "archive_fs_file" must be some of:
files= 			# List of files fullpath separated by a coma "," 
dst=			# The destination archive (name of the archive) 

NOTE: minimum parameters to specify on cmdline to create an archive: 
files=
dst= 

NOTE: archive type will be autodetect from archive filename extention - supported type: 
.zip
.iso
.cpio
.tar
.tar.gz
.tar.xz
.7z
.tar.7z
.tar.bz2 

EXAMPLE (simple):
archive_fs_file files="/FBXDSK/vm/vm1-disk0.qcow2" dst="/FBXDSK/vm/archive.zip" 

EXAMPLE (multiple files/dir):
archive_fs_file files="/FBXDSK/vm/vm1-disk0.qcow2,/FBXDSK/vm/vm2-disk0.qcow2" dst="/FBXDSK/vm/archive.zip" 
```

##### Picture
![arc_r](https://user-images.githubusercontent.com/13208359/212486586-edae2ba6-15c9-4fd7-a504-5470956b3f77.png)

##### Example
```bash
archive_fs_file files=/FBX24T/dl/vm1/vm18/mjd-efi-arm64.qcow2,/FBX24T/dl/vm1/vm18/njd-efi-arm64.qcow2 dst=/FBX24T/dl/vm1/vm18/jd-efi-arm64.qcow2.tar
```
```bash

operation completed: 
{"success":true}

result:
{"curr_bytes_done":0,"total_bytes":0,"nfiles_done":0,"started_ts":1673715829,"duration":0,"done_ts":0,"src":["/FBX24T/dl/vm1/vm18/jd-efi-arm64.qcow2.tar","/FBX24T/dl/vm1/vm18/mjd-efi-arm64.qcow2"],"curr_bytes":0,"type":"archive","to":"/FBX24T/dl/vm1/vm18/jd-efi-arm64.qcow2.tar","id":358,"nfiles":0,"created_ts":1673715829,"state":"running","total_bytes_done":0,"rate":0,"from":"","dst":"/FBX24T/dl/vm1/vm18/njd-efi-arm64.qcow2","eta":0,"error":"none","progress":0}

```
##### Picture
![arc](https://user-images.githubusercontent.com/13208359/212486556-9fbd6491-95d3-48c3-b9ed-e2e7a5640ea5.png)

Again, let monitor our archive task
##### Example
```bash
mon_fs_task_api 358
```
```bash
task 358 running ... 
|..................................................................................................................| 100 % 24s end: 0s 5998MB  
task 358 done ... 
```
##### Picture
![a_mon](https://user-images.githubusercontent.com/13208359/212486532-803168ef-6a38-48f0-9eee-b015e0942ade.png)

And confirm our archive task is finished with 'show_fs_task' function
```bash
show_fs_task 358
```
```bash
					SHOW FILESYSTEM TASK: 358

------------------------------------------------------------------------------------------------------------------------
id: 358	start: 20230114-18:03:49	end: 20230114-18:04:14	%progress: 100 %  	size: 5998 MB
	status: done			time: 24s		from: /FBX24T/dl/vm1/vm18/njd-efi-arm64.qcow2
	error: none			end-in: 0s		to:   /FBX24T/dl/vm1/vm18/jd-efi-arm64.qcow2.tar
	task type: archive		#files: 2 		dst:  /FBX24T/dl/vm1/vm18/njd-efi-arm64.qcow2
------------------------------------------------------------------------------------------------------------------------

```
##### Picture
![a_s](https://user-images.githubusercontent.com/13208359/212486508-c1570c1b-e8a7-4a62-93ed-46021d287ccf.png)

When the task is finished, it can be delete with 'del_fs_task' function 
Let verify that our archive had been sucessfully created with 'ls_fs' function


```bash
ls_fs /FBX24T/dl/vm1/vm18
```
```bash
idx: 0	hidden	dir	20230114-18:03:49	size: 4096 B	name: .
idx: 1	hidden	dir	20230114-09:59:43	size: 4096 B	name: ..
idx: 2		file	20230114-17:02:55	size: 9 GB	name: delta-10G-224.tar.gz
idx: 3		file	20230114-17:03:33	size: 9 GB	name: delta-10G-225.tar.gz
idx: 4		file	20230114-18:04:14	size: 5 GB	name: jd-efi-arm64.qcow2.tar
idx: 5		file	20230114-17:58:49	size: 2 GB	name: mjd-efi-arm64.qcow2
idx: 6		file	20230114-18:01:34	size: 2 GB	name: njd-efi-arm64.qcow2
```
##### Picture
![a_l](https://user-images.githubusercontent.com/13208359/212486485-fcf0241f-40e7-4ab9-a66c-a88b02ab0ed7.png)



-------------------------------------------------------------------------------


#### *  extract_fs_file *array_of_strings*
This function will extract an archive from the files provided as argument.
Supported archive type:
```
.zip		--> 'zip' archive will be extracted with 'zip'
.iso		--> 'iso' archive will be extracted 
.cpio		--> 'cpio' archive will be extracted
.tar		--> 'tar' archive will be extracted with 'tape archiver'
.tar.gz		--> 'tar' archive will be extracted with 'gzip'
.tar.xz		--> 'tar' archive will be extracted with 'lzma'
.7z		--> '7zip' archive will be extracted with '7zip'
.tar.7z		--> 'tar' archive will be extracted with '7zip'
.tar.bz2	--> 'tar' archive will be extracted with 'bzip2'
```

The archive type is autodetected by the API from the archive filename extension
If your archive is named 'someting.zip', zip will be used for extraction
If your archive is named 'someting.tar', tar will be used for extraction
...

Note: 
If the provided archive has a password, you can specify the option 'password=' on the cmdline
You can also specify the option 'delete_archive=1' on the cmdline to delete archive after extraction but you must also specify the conflict resoution mode with option 'overwrite=0 or overwrite=1' on  the cmdline

##### Example
```bash
extract_fs_file
```
```bash

ERROR: <param> for "extract_fs_file" must be some of:
src= 			# The archive file
dst=			# The destination folder 
password= 		# (Optionnal) The archive password
delete_archive= 	# boolean true or false (Optionnal) Delete archive after extraction 
overwrite= 		# boolean true or false (Optionnal) Overwrite files on conflict

NOTE: minimum parameters to specify on cmdline to extract an archive: 
src=
dst= 

NOTE: archive type will be autodetect from archive filename extention - supported type: 
.zip
.iso
.cpio
.tar
.tar.gz
.tar.xz
.7z
.tar.7z
.tar.bz2 

EXAMPLE (simple):
extract_fs_file src="/FBXDSK/vm/archive.zip" dst="/FBXDSK/vm" 

EXAMPLE (medium):
extract_fs_file src="/FBXDSK/vm/archive.zip" dst="/FBXDSK/vm" password="MyArchivePassword" 

EXAMPLE (full):
extract_fs_file src="/FBXDSK/vm/archive.zip" dst="/FBXDSK/vm" password="MyArchivePassword" delete_archive="1" overwrite="0" 

```
##### Picture
![e_fs_r](https://user-images.githubusercontent.com/13208359/212629617-df16114f-63df-4c10-b52c-ad8527d18633.png)


Let extract the archive we had just created in previous documented function of this README 'archive_fs_file'  
##### Example
```bash
extract_fs_file src=/FBX24T/dl/vm1/vm18/jd-efi-arm64.qcow2.tar dst=/FBX24T/dl/vm1/vm19 overwrite=1 
```
```bash

operation completed: 
{"success":true}

result:
{"curr_bytes_done":0,"total_bytes":0,"nfiles_done":0,"started_ts":1673854880,"duration":0,"done_ts":0,"src":["/FBX24T/dl/vm1/vm18/jd-efi-arm64.qcow2.tar"],"curr_bytes":0,"type":"extract","to":"/FBX24T/dl/vm1/vm19","id":364,"nfiles":0,"created_ts":1673854880,"state":"running","total_bytes_done":0,"rate":0,"from":"/FBX24T/dl/vm1/vm18/jd-efi-arm64.qcow2.tar","dst":"/FBX24T/dl/vm1/vm19","eta":0,"error":"none","progress":0}

```
##### Picture
![e_fs](https://user-images.githubusercontent.com/13208359/212629527-b6e50521-c82c-47c5-8096-81e0b76ea752.png)


Again we will monitor our task until it finished
```bash
mon_fs_task_api 364
```
```bash
task 364 running ... 
|..................................................................................................................| 100 % 23s end: 0s 5998MB  
task 364 done ... 
```
##### Picture
![e_fs_m](https://user-images.githubusercontent.com/13208359/212629366-ff1ac0cf-3af9-4c91-92f0-7e5a36787869.png)


And again, we will verify and constat with function 'ls_fs' that the archive had been successfully extracted to directory '/FBX24T/dl/vm1/vm19'
```bash
ls_fs /FBX24T/dl/vm1/vm19
```
```bash
idx: 0	hidden	dir	20230116-08:41:31	size: 4096 B	name: .
idx: 1	hidden	dir	20230116-08:26:25	size: 4096 B	name: ..
idx: 2		file	20230114-17:58:49	size: 2 GB	name: mjd-efi-arm64.qcow2
idx: 3		file	20230114-18:01:34	size: 2 GB	name: njd-efi-arm64.qcow2
```
##### Picture
![e_fs_v](https://user-images.githubusercontent.com/13208359/212629332-5baa4fad-2da2-4dfe-80ca-eccc4c892be7.png)


__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________

<a name="VM"></a>   



API FRONTEND FUNCTIONS - VIRTUAL MACHINE
-----------------
You must notice that today, as I had already wrote a 'nearly' complete program for managing Freebox Delta virtual Machines from bash with api and which is also using some of the [LOGIN FUNCTIONS](#LOGIN) and of the [CALL FUNCTIONS](#CALL) of this library (I wrote those function before writing the library new frontend functions), and at the time I was first writing, there were very few functions in this library for managing Freebox Delta Virtual Machines. 
The 'nearly' complete program to manage Freebox Delta virtual machines from API and bash can be find here: [fbxvm-ctrl](https://github.com/nbanb/fbxvm-ctrl)

Since the whole documentation had been written, the new Freebox ULTRA appears in 2024 and have also VM feature, so I decide to port directly in library all Virtual Machines functions (and more) that I did developp in my other program [fbxvm-ctrl](https://github.com/nbanb/fbxvm-ctrl)   

<br />

**Extended Virtual Machines support in library  :**   
--> Now the following functions are usable directly from the library (= from the shell).   
--> Documentation is not updated at the time I'm writing, but all functions include help and example   

**Note :**   
--> VNC usage over websocket required you install TigerVNC client: https://tigervnc.org/   



**New :**   
--> Function auto_relogin on all control VM function (vm_start, sm_stop, vm_console...)   
--> Fixing websocket timeout while using vm_console or vm_vnc command    
<br />

**New VM functions supported : (adding vm display screen support)**

| function :| description |
|:-:|:-:|
|   |$${\color{red}\text{Calling function with no parameters will print help }}$$|
|vm_vnc|launch VM VNC screen through Websocket API - (Require option: enable_screen=true)|
|vm_svnc|start VM and launch VNC screen just after starting VM|

<br />


**VM already supported function :**

| function :| description |
|:-:|:-:|
|   |$${\color{red}\text{Calling function with no parameters will print help }}$$|
|vm_add|add a new vm|
|vm_adddisk|add a new disk for a VM|
|vm_console|launch VM console (through Freebox Websocket API - it act as an Out-Of-Band access)|
|vm_deldisk|remove a VM disk|
|vm_delete|remove a VM|
|vm_detail|print VM configuration detail and status|
|vm_list|list all VM|
|vm_listdisk |list all disks from a vmdisk directory|
|vm_modify|modify VM parameters|
|vm_param|print detailed help of ALL VM parameters|
|vm_reload|execute an ACPI shutdown and after start the VM again|
|vm_resizedisk|resize vM disk|
|vm_resource|print allocated and used ressources - json output|
|vm_restart|hard stop VM (electricaly) and after start the VM again|
|vm_sconsole|start VM and launch console just after starting VM|
|vm_show|list a specific VM|
|vm_shutdown|send an ACPI shutdown command to the VM|
|vm_start|simply start VM| 
|vm_stop|hard stop VM (electricaly)|



<br />

__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________


API FRONTEND FUNCTIONS - VM PREBUILD DISTROS
-----------------

This API let you list and download Freebox Delta Free's prebuild vm distros
For this API, we only have 4 functions for listing and downloading  Freebox Delta prebuild vm distros

As I'm never using prebuild VM images that someone other than me had installed, I didn't develop thoses functions in my previously written program [fbxvm-ctrl](https://github.com/nbanb/fbxvm-ctrl). But as some of my program users asked me, I did develop these new frontend functions + downloads capabilities and others frontend functions of this library 

So here, I'm only managing the part I did not developped in my other program [fbxvm-ctrl](https://github.com/nbanb/fbxvm-ctrl) 
That's why the lisiting and check_and_feed_vm__prebuild_distros function will publish some environnement variables containing distros parameters to subshell. This way, if you use [fbxvm-ctrl](https://github.com/nbanb/fbxvm-ctrl) program for managing VM, you can just list all prebuild VM distros from this library function, and after you can use the created environment variables to be passed as parameters to [fbxvm-ctrl](https://github.com/nbanb/fbxvm-ctrl) when creating a Virtual Machine or when updating a VM  



-------------------------------------------------------------------------------


#### *  check_and_feed_vm_prebuild_distros_param *array_of_strings*
This function will check if the provided arguments are valid parameters for the function which is calling it depending of the "action" set by the calling function. If not, function param_vm_prebuild_distros_err will be called to set error and display help for the command depending on "action" set by the calling function. "action" are: 'dl' (=download). This function do not return a 'json' object to be passed to "API CALL" functions because it fulfill some session exported variables (bash arrays) containing the whole list of variables / values for all prebuild VM distros.

##### Example
```bash
action=dl
check_and_feed_vm_prebuild_distros_param id=5 dl_path=/FBXSTORAGE/VMdownload filename=myOpenSuzeVM-7.qcow2
echo -e "${distro_url[@]}"|tr " " "\n"
```
```bash
http://ftp.free.fr/.private/ubuntu-cloud/releases/jammy/release/ubuntu-22.04-server-cloudimg-arm64.img
http://ftp.free.fr/.private/ubuntu-cloud/releases/impish/release/ubuntu-21.10-server-cloudimg-arm64.img
https://cloud.debian.org/images/cloud/bullseye/daily/latest/debian-11-generic-arm64-daily.qcow2
https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-generic-arm64-daily.qcow2
http://ftp.free.fr/pub/Distributions_Linux/Fedora/releases/36/Cloud/aarch64/images/Fedora-Cloud-Base-36-1.5.aarch64.qcow2
http://ftp.free.fr/mirrors/ftp.opensuse.org/opensuse/distribution/leap/15.4/appliances/openSUSE-Leap-15.4-ARM-JeOS-efi.aarch64.qcow2
https://cloud.centos.org/centos/8/aarch64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.aarch64.qcow2
https://images.jeedom.com/freebox/freeboxDelta.qcow2
```

```bash
echo -e "${distro_name[@]}" |tr " " "\n"
```
```bash
Ubuntu_22.04_LTS_(Jammy)	 
Ubuntu_21.10_(Impish)	 
Debian_11_(Bullseye)	 
Debian_Unstable_(sid)	 
Fedora_36			 
openSUSE_Leap_15.4_JeOS	 
CentOS_8.4_(snapshot_20210603) 
Jeedom_(fourni_par_Jeedom_SAS)
```
```bash
...
```

##### Picture
![vm_d_c](https://user-images.githubusercontent.com/13208359/212265738-8c12457b-45a7-4e5b-bb89-878f557def6f.png)


-------------------------------------------------------------------------------


#### *  param_vm_prebuild_distros_err
This function will display help / manual and example on the command which calling it, depending of the "action" set by the calling function. This function also set variable "error=1". "error" variable content is always checked before each API execution, and if error=1, nothing happends and the lib exit cleanly. "action" are: 'add, upd, del, ena, dis'. This function return error=1 when it has been called
This function is mostly called by 'check_and_feed_vm_prebuild_distros_param' function


-------------------------------------------------------------------------------


#### *  list_vm_prebuild_distros 
This function list all availiable Virtual Machines (VM) prebuild distros. These are FREEBOX distros from from Free Telecom, not mine.
I can also provide some prebuild distros with security enforcement, just ask... But use at your own risk 
As this function can automatically fulfill and export to subshell all variables and values of all Free VM prebuild distros, the list function can be used without providing output using the '-q' switch in the comand line

##### Example
```bash
list_vm_prebuild_distros -h
```
```bash

function param:
		-h	print this help
		-q	silently export distros variables - no output

```
##### Picture
![vm_d_q](https://user-images.githubusercontent.com/13208359/212266018-dedc0f99-14fd-4790-8cf6-cc0c6853cb91.png)


##### Example
```bash
list_vm_prebuild_distros -q
```
Now, you can retrieve distros information directly from environement variables.
the following variables are exported :
$distro_count     --> number of availiabledistros
$distro_filename  --> array of all distros filenames
$distro_hash      --> array of all distros hash URL
$distro_name      --> array of all distro names
$distro_os        --> array of all distro os - to be pass when creating a VM
$distro_url       --> array of all distro URL
$distro_idx       --> array of all distro variables ($distro_filename,$distro_hash, ...)

Let see an example with a simple bash loop printing variables of some distros
```bash
i=3 
while [[ "$i" != "${#distro_name[@]}" ]]; 
do 
	echo -e "distro $i"
	echo -e "${distro_os[$i]}"
	echo -e "${distro_name[$i]}"
	echo -e "${distro_url[$i]}"
	echo -e "${distro_hash[$i]}"
	echo -e "${distro_filename[$i]}\n"
	((i++))
done
```
```bash
distro 3
debian
Debian_Unstable_(sid)	
https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-generic-arm64-daily.qcow2
https://cloud.debian.org/images/cloud/sid/daily/latest/SHA512SUMS
debian-sid-generic-arm64-daily.qcow2

distro 4
fedora
Fedora_36			
http://ftp.free.fr/pub/Distributions_Linux/Fedora/releases/36/Cloud/aarch64/images/Fedora-Cloud-Base-36-1.5.aarch64.qcow2
http://ftp.free.fr/pub/Distributions_Linux/Fedora/releases/36/Cloud/aarch64/images/Fedora-Cloud-36-1.5-aarch64-CHECKSUM
Fedora-Cloud-Base-36-1.5.aarch64.qcow2

distro 5
opensuse
openSUSE_Leap_15.4_JeOS	
http://ftp.free.fr/mirrors/ftp.opensuse.org/opensuse/distribution/leap/15.4/appliances/openSUSE-Leap-15.4-ARM-JeOS-efi.aarch64.qcow2
http://ftp.free.fr/mirrors/ftp.opensuse.org/opensuse/distribution/leap/15.4/appliances/openSUSE-Leap-15.4-ARM-JeOS-efi.aarch64.qcow2.sha256
openSUSE-Leap-15.4-ARM-JeOS-efi.aarch64.qcow2

distro 6
centos
CentOS_8.4_(snapshot_20210603)
https://cloud.centos.org/centos/8/aarch64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.aarch64.qcow2
[no_hashfile_url_available]
CentOS-8-GenericCloud-8.4.2105-20210603.0.aarch64.qcow2

distro 7
jeedom
Jeedom_(fourni_par_Jeedom_SAS)
https://images.jeedom.com/freebox/freeboxDelta.qcow2
https://images.jeedom.com/freebox/SHA256SUMS
freeboxDelta.qcow2

```

##### Picture
![vm_d_var](https://user-images.githubusercontent.com/13208359/212266190-549dea2b-7cdf-47fe-bf00-c6f9f2556320.png)

Now we will use the 'list_vm_prebuild_distros' function with no argument to have it's normal output 
Note that distros variables will also be exported to subshell environment

##### Example
```bash
list_vm_prebuild_distros 
```
```bash

				LIST AVAILIABLE 'Freebox Delta' PREBUILD VM DISTROS IMAGES:

----------------------------------------------------------------------------------------------------------------------------------------------------------
id: 0	name=Ubuntu 22.04 LTS (Jammy)		os=ubuntu	filename=ubuntu-22.04-server-cloudimg-arm64.img
	url=http://ftp.free.fr/.private/ubuntu-cloud/releases/jammy/release/ubuntu-22.04-server-cloudimg-arm64.img
	hash=http://ftp.free.fr/.private/ubuntu-cloud/releases/jammy/release/SHA256SUMS
----------------------------------------------------------------------------------------------------------------------------------------------------------
id: 1	name=Ubuntu 21.10 (Impish)		os=ubuntu	filename=ubuntu-21.10-server-cloudimg-arm64.img
	url=http://ftp.free.fr/.private/ubuntu-cloud/releases/impish/release/ubuntu-21.10-server-cloudimg-arm64.img
	hash=http://ftp.free.fr/.private/ubuntu-cloud/releases/impish/release/SHA256SUMS
----------------------------------------------------------------------------------------------------------------------------------------------------------
id: 2	name=Debian 11 (Bullseye)		os=debian	filename=debian-11-generic-arm64-daily.qcow2
	url=https://cloud.debian.org/images/cloud/bullseye/daily/latest/debian-11-generic-arm64-daily.qcow2
	hash=https://cloud.debian.org/images/cloud/bullseye/daily/latest/SHA512SUMS
----------------------------------------------------------------------------------------------------------------------------------------------------------
id: 3	name=Debian Unstable (sid)		os=debian	filename=debian-sid-generic-arm64-daily.qcow2
	url=https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-generic-arm64-daily.qcow2
	hash=https://cloud.debian.org/images/cloud/sid/daily/latest/SHA512SUMS
----------------------------------------------------------------------------------------------------------------------------------------------------------
id: 4	name=Fedora 36				os=fedora	filename=Fedora-Cloud-Base-36-1.5.aarch64.qcow2
	url=http://ftp.free.fr/pub/Distributions_Linux/Fedora/releases/36/Cloud/aarch64/images/Fedora-Cloud-Base-36-1.5.aarch64.qcow2
	hash=http://ftp.free.fr/pub/Distributions_Linux/Fedora/releases/36/Cloud/aarch64/images/Fedora-Cloud-36-1.5-aarch64-CHECKSUM
----------------------------------------------------------------------------------------------------------------------------------------------------------
id: 5	name=openSUSE Leap 15.4 JeOS		os=opensuse	filename=openSUSE-Leap-15.4-ARM-JeOS-efi.aarch64.qcow2
	url=http://ftp.free.fr/mirrors/ftp.opensuse.org/opensuse/distribution/leap/15.4/appliances/openSUSE-Leap-15.4-ARM-JeOS-efi.aarch64.qcow2
	hash=http://ftp.free.fr/mirrors/ftp.opensuse.org/opensuse/distribution/leap/15.4/appliances/openSUSE-Leap-15.4-ARM-JeOS-efi.aarch64.qcow2.sha256
----------------------------------------------------------------------------------------------------------------------------------------------------------
id: 6	name=CentOS 8.4 (snapshot 20210603)	os=centos	filename=CentOS-8-GenericCloud-8.4.2105-20210603.0.aarch64.qcow2
	url=https://cloud.centos.org/centos/8/aarch64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.aarch64.qcow2
	hash=[no_hashfile_url_available]
----------------------------------------------------------------------------------------------------------------------------------------------------------
id: 7	name=Jeedom (fourni par Jeedom SAS)	os=jeedom	filename=freeboxDelta.qcow2
	url=https://images.jeedom.com/freebox/freeboxDelta.qcow2
	hash=https://images.jeedom.com/freebox/SHA256SUMS
----------------------------------------------------------------------------------------------------------------------------------------------------------

```


##### Picture
![vm_d_l](https://user-images.githubusercontent.com/13208359/212266352-8a581a7b-4b52-4a80-9880-322835080bf4.png)


-------------------------------------------------------------------------------



#### *  dl_vm_prebuild_distros 

This function let you download one of the VM prebuild distros on the path of your choice and name the download image with the name you provided as parameter (or with it's original name if you don't specify it on the command lines arguments

##### Example
```bash
dl_vm_prebuild_distros
```
```bash

ERROR: <param> for "dl_vm_prebuild_distros" must be some of:
id=			# distro id for selected distro in distro list
dl_path=		# optional download path (override default download_dir - non existent directory will be created)
filename=		# optional filename (override default filename)

NOTE: please run "list_vm_prebuild_distros" to get list of all prebuild VM distros 

NOTE: minimum parameters to specify on cmdline to dowload a VM prebuild distro: 
id=

EXAMPLE: (simple)
dl_vm_prebuild_distros id=5

EXAMPLE: (full)
dl_vm_prebuild_distros id=5 dl_path=/FBXSTORAGE/VMdownload filename=myOpenSuzeVM-7.qcow2

```

##### Picture
![dl_vmp_r](https://user-images.githubusercontent.com/13208359/212270968-3914afcc-bb3d-4dbd-a017-959c786c4222.png) 

##### Example
```bash
dl_vm_prebuild_distros id=7 dl_path=/FBX24T/dl/vm6 filename=MyDeltaJeeDom.qcow2
```
```bash

operation completed: 
{"success":true}

result:
{"id":483}

task 483 downloading ... 
|..................................................................................................................| 100 % 0 MB/s 2994/2994MB 
task 483 checking ... 
|..................................................................................................................| 100 % checking ... 
task 483 done ... 

Download Task log: task 483

2023-01-13 09:04:02 info: start url https://images.jeedom.com/freebox/freeboxDelta.qcow2 (crawling: 1)
2023-01-13 09:04:02 dbg: host resolved to 51.210.253.116:443
2023-01-13 09:04:02 dbg: connecting to remote host...
2023-01-13 09:04:02 dbg: connected
2023-01-13 09:04:02 dbg: sending request headers:
2023-01-13 09:04:02 dbg: 	User-Agent: Mozilla/5.0
2023-01-13 09:04:02 dbg: 	Host: images.jeedom.com:443
2023-01-13 09:04:02 dbg: request headers sent
2023-01-13 09:04:02 dbg: got response headers:
2023-01-13 09:04:02 dbg: 	Strict-Transport-Security: max-age=15724800; includeSubDomains
2023-01-13 09:04:02 dbg: 	Last-Modified: Tue, 08 Oct 2019 01:10:03 GMT
2023-01-13 09:04:02 dbg: 	ETag:bbe0000-5945bd3fc10c0
2023-01-13 09:04:02 dbg: 	Date: Fri, 13 Jan 2023 08:04:02 GMT
2023-01-13 09:04:02 dbg: 	Content-Length: 3149791232
2023-01-13 09:04:02 dbg: 	Connection: keep-alive
2023-01-13 09:04:02 dbg: 	Accept-Ranges: bytes
2023-01-13 09:04:02 info: unable to resume (missing content_range)
2023-01-13 09:04:02 dbg: receiving body

Sucessfully delete task #483: {"success":true}

```

##### Picture

Download progress
![dl_vmp_p](https://user-images.githubusercontent.com/13208359/212271117-9b18fb43-9851-446a-85a2-e3585fc3f36f.png)


Download finished
![dl_vm_f](https://user-images.githubusercontent.com/13208359/212271389-36037582-5fac-457c-be5e-4318035f4e79.png)

Now, we will verify that our prebuild VM distro image had been successfully downloaded in path '/FBX24T/dl/vm6' and have for filename 'MyDeltaJeeDom.qcow2'
To proceed, we will use one of the frontend [FILESYSTEM FUNCTIONS](#FS) to list the content of freebox storage


##### Example
```bash
ls_fs /FBX24T/dl/vm6
```
```bash
idx: 0	hidden	dir	20230113-09:04:02	size: 4096 B	name: .
idx: 1	hidden	dir	20230112-09:33:26	size: 4096 B	name: ..
idx: 2		file	20230113-09:15:05	size: 2 GB	name: MyDeltaJeeDom.qcow2
```

##### Picture
![dl_vm_ls](https://user-images.githubusercontent.com/13208359/212272198-6740388d-07c5-48a2-bc6e-89acc83963f2.png)



__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

__________________________________________________________________________________________


<br />

<a name="DOMAIN"></a>   



API FRONTEND FUNCTIONS - DOMAIN NAME
-----------------
You must notice that today, this API is not documented.
As describes in the Freebox developper documentation, NOT DOCUMENTED API MUST NOT BE USED ! 

But as it's a mess to go to FreeboxOS web interface to define domains and upload certificates, I decide to implement this functionnality.
At the time I'm writing (end of 2024), it's working well, but please $${\color{red}\text{USE AT YOUR OWN RISK }}$$



<br />

**Note :**   
NOT DOCUMENTED API MUST NOT BE USED ! 


**New :**   
--> Function domain_setdefault let you define Freebox default domain name    
--> listing domain name support auto_relogin   
<br />


**New DOMAIN functions supported :**   

| function :| description |
|:-:|:-:|
|   |$${\color{red}\text{Calling function with no parameters will print help }}$$|
|domain_list|list Freebox configured domain |
|domain_add|add a new domain name on Freebox|
|domain_del|delete a configured domain name on Freebox|
|domain_addcert|add a TLS certificat to a Freebox configured domain|
|domain_setdefault|set Freebox default domain name (used for remote acceess)|

<br />


-------------------------------------------------------------------------------

#### *  domain_list
This function will simply retrieve the list of domains configured  

##### Example
```bash  
domain_list
```  

```bash
			DOMAIN ID, TYPE, OWNER, CERTIFICAT DAYS LEFT 
--------------------------------------------------------------------------------------------------------------
DOMAIN-0:	owner: user	type: custom	rsa: none 	ecdsa: 105	domain id : sba.xxxxxxx.net 
DOMAIN-1:	owner: user	type: custom	rsa: 105 	ecdsa: none	domain id : 14rv.xxxxxxx.net 
DOMAIN-2:	owner: user	type: custom	rsa: 59 	ecdsa: none	domain id : fbx.fbx.lan 
DOMAIN-3:	owner: user	type: custom	rsa: none 	ecdsa: 105	domain id : test.14rv.lan 
DOMAIN-4:	owner: user	type: custom	rsa: none 	ecdsa: 105	domain id : 14rv-fbx.fbx.lan 
DOMAIN-5:	owner: user	type: custom	rsa: 80 	ecdsa: none	domain id : fbx.my-public-domain.net 
DOMAIN-6:	owner: user	type: custom	rsa: none 	ecdsa: 105	domain id : home.xxxxxxx.net 
DOMAIN-7:	owner: user	type: custom	rsa: none 	ecdsa: 105	domain id : test.xxxxxxx.lan 
DOMAIN-8:	owner: freebox	type: auto	rsa: 57 	ecdsa: 57	domain id : xxxxxxx.fbxos.fr 
DOMAIN-9:	owner: user	type: custom	rsa: none 	ecdsa: 105	id default: fbx.xxxxxxx.net 
DOMAIN-10:	owner: user	type: custom	rsa: none 	ecdsa: 105	domain id : lba.xxxxxxx.net 
DOMAIN-11:	owner: user	type: custom	rsa: none 	ecdsa: 105	domain id : fbx.14rv.lan 
DOMAIN-12:	owner: user	type: custom	rsa: none 	ecdsa: none	domain id : test.com 

```

##### Picture
![Capture d’écran du 2024-10-19 12-29-47](https://github.com/user-attachments/assets/178d2c7d-cc47-4703-ad8c-06ff3c8be105)


-------------------------------------------------------------------------------


#### *  domain_add
This function will simply retrieve the list of domains configured  

##### Example
```bash  
domain_add
```  

```bash
ERROR: <param> must be :
id			# id must be a domain name

NOTE: you can get a list of all configured domain and status (showing all 'id'), just run: 
domain_list

EXAMPLE:
domain_add id=my.domain.com 

```  

##### Picture
![image](https://github.com/user-attachments/assets/bbf9b13b-ee52-45ef-abc9-b2666fc7d318)


```bash  
domain_add id=test.fbx.lan
```  

```bash

operation completed: 
{"success":true}

result:
{"id":"test.fbx.lan","type":"custom","certs":{},"owner":"user"}

```  
##### Picture
![image](https://github.com/user-attachments/assets/d0e7db8c-2584-47ee-b5a0-4f7b930823ae)



-------------------------------------------------------------------------------


#### *  domain_addcert
This function will simply retrieve the list of domains configured  

##### Example
```bash  
domain_addcert
```  

```bash

ERROR: <param> must be :
id			# id must be a domain name
key_type		# key_type is 'ed' or 'rsa'
cert_pem		# path to file containing your certificat in PEM format
key_pem			# path to file containing your certificat PRIVATE KEY in PEM format
intermediates		# path to file containing your root or intermediate CA certificat in PEM format

NOTE: you can get a list of all configured domain and status (showing all 'id'), just run: 
domain_list

NOTE: your certificate files (+ intermediate) files must contains: 
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----
AND for key PEM files:
-----BEGIN PRIVATE KEY-----
-----END PRIVATE KEY-----

EXAMPLE (PEM files are stored in current directory):
domain_addcert id="my.domain.com" key_type="ec" cert_pem="mycert.pem" key_pem="mykey.pem" intermediates="myintermediateCA.pem"  

EXAMPLE (PEM files are stored in CERT/ directory):
domain_addcert id="my.domain.com" key_type="ec" cert_pem="CERT/mycert.pem" key_pem="CERT/mykey.pem" intermediates="CERT/myintermediateCA.pem"  


```  

##### Picture
![image](https://github.com/user-attachments/assets/124fa735-8b1b-4c5c-b1bd-424c99f46fa4)


```bash  
domain_addcert id=test.fbx.lan key_type=ec cert_pem=CERT/14rv-RSA8192_2023-crt.pem key_pem=CERT/14rv-RSA8192_2023-key.pem intermediates=CERT/14rv-rootCA-RSA8192.pem 
```  

```bash

operation completed: 
{"success":true}

```  
##### Picture
![image](https://github.com/user-attachments/assets/f991038e-03b9-400c-b7e3-9edcda4dcd7a)



<br />

__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|



__________________________________________________________________________________________

<br />
<a name="REPLY"></a>

API FRONTEND FUNCTIONS - REPLY OUTPUT 
-----------------

For managing output of all frontend function for a direct use from a bash terminal or for use inside other program / script, 2 functions had been developped and there are several possibility to keep the formatting output when filtering results (see filtering):


-------------------------------------------------------------------------------


#### * colorize_output *string* 
This function will print result in a colour and formated way, splitting result status and output messages: 
- GREEN if operation is successfull
- RED if operation failed

##### Example
```bash
logout_freebox
answer=$(call_freebox_api /vm/info 2>&1)
colorize_output $answer
```
```bash

operation failed ! 
Vous devez vous connecter pour accéder à cette fonction: auth_required

```

##### Picture
![c_o_f](https://user-images.githubusercontent.com/13208359/212138834-c1be6d91-12b0-437c-8e14-be2a6eccdc2f.png)

##### Example
```bash
relogin_freebox 
answer=$(call_freebox_api /vm/info 2>&1)
colorize_output $answer
```
```bash

operation completed: 
{"success":true}

result:
{"usb_used":false,"sata_used":false,"sata_ports":["sata-internal-p0","sata-internal-p1","sata-internal-p2","sata-internal-p3"],"used_memory":8192,"usb_ports":["usb-external-type-a","usb-external-type-c"],"used_cpus":3,"total_memory":15360,"total_cpus":3}

```

##### Picture
![c_o_o](https://user-images.githubusercontent.com/13208359/212138997-223ea33e-0487-4159-b11c-c535093fb048.png)



-------------------------------------------------------------------------------


#### * colorize_output_pretty_json  *string*
This function will print result in a colour and formated way, splitting result status and output messages: 
- GREEN if operation is successfull
- RED if operation failed

This function will also print JSON output in "pretty-json" manner.
When you have the API reply with a big json reply, it's sometimes nearly impossible to read and understand it. Displaying those kind of json strings in "pretty-json" way let json output becoming human readable

##### Example
```bash
logout_freebox
answer=$(call_freebox_api /vm/info 2>&1)
colorize_output_pretty_json $answer
```
```bash

operation failed ! 
Vous devez vous connecter pour accéder à cette fonction: auth_required

```

##### Picture
![c_o_pf](https://user-images.githubusercontent.com/13208359/212139138-d31b2523-3098-40d0-a181-24a3f1d7df04.png)

##### Example
```bash
relogin_freebox
answer=$(call_freebox_api /vm/info 2>&1)
colorize_output_pretty_json $answer
```
```bash

operation completed: 

 {
    "success":true
 }
 {
    "usb_used":false,
    "sata_used":false,
    "sata_ports":
    [
        "sata-internal-p0",
        "sata-internal-p1",
        "sata-internal-p2",
        "sata-internal-p3"
    ],
    "used_memory":8192,
    "usb_ports":
    [
        "usb-external-type-a",
        "usb-external-type-c"
    ],
    "used_cpus":3,
    "total_memory":15360,
    "total_cpus":3
 }

```

##### Picture
![c_o_po](https://user-images.githubusercontent.com/13208359/212139371-23c5d3c5-04a8-4d99-b5b3-ec349852d87e.png)



-------------------------------------------------------------------------------


#### filtering output 
To keep the formatting of the output of the frontend functions of the library when filtering output / results of a command or of a listing command, you can use several way to filter on a pattern and to keep the formatting


##### Example

Here we will list all dhcp static leases and filter on a particular mac address

Note that I'm using '--color=never' option of 'grep' because I want to keep the library formatting for the picture. 
You can replace this filtering expression (grep --color=never '00:01:02:03:04:05') by: 
- awk  '$2 ~ /00:01:02:03:04:05/' 
or by 
- sed '/00:01:02:03:04:05/!d' 

All of those 3 commands provide the same result and output, so you can use those 3 command in your scripts to retrieve a particular string without alterating the library output. 
(see the following example and picture)


##### Example 
No alteration with grep 
```bash
list_dhcp_static_lease | grep --color=never '00:01:02:03:04:05'
```
```bash
6:      00:01:02:03:04:05       00:01:02:03:04:05       192.168.100.46          offline         00:01:02:03:04:05
```
##### Picture
![ad_dh_g](https://user-images.githubusercontent.com/13208359/211754887-a4eda24e-dabf-4939-b5c0-375ec9dfd52b.png)


##### Example 
No alteration with awk
```bash
list_dhcp_static_lease | awk  '$2 ~ /00:01:02:03:04:05/'
```
```bash
6:      00:01:02:03:04:05       00:01:02:03:04:05       192.168.100.46          offline         00:01:02:03:04:05
```
##### Picture
![ad_dh_a](https://user-images.githubusercontent.com/13208359/211754931-88f10251-315a-466c-878c-7d231dc31046.png)


##### Example 
No alteration with sed
```bash
list_dhcp_static_lease | sed '/00:01:02:03:04:05/!d'
```
```bash
6:      00:01:02:03:04:05       00:01:02:03:04:05       192.168.100.46          offline         00:01:02:03:04:05
```
##### Picture
![ad_dh_s](https://user-images.githubusercontent.com/13208359/211754950-e63dcab6-14d7-4a62-81d9-5d7423517f8d.png)



__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|
__________________________________________________________________________________________

<a name="ACTIONS"></a>

API DIRECT ACTIONS
-----------------

#### *  reboot_freebox
This function will reboot your freebox. Return code will be 0 if the freebox is rebooting, 1 otherwise.
The application must be granted to modify the setup of the freebox (from freebox web interface, see: [GRANT API ACCESS](#GRANTAXX))
##### Example
```bash
reboot_freebox
```

__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|
__________________________________________________________________________________________


<a name="GRANTAXX"></a>

GRANT API ACCESS IN YOUR BOX OS (FreeboxOS, IliadboxOS)
-----------------

- To access some of the different API, your application MUST be granted for all tasks / API it will call. For example, to reboot your Freebox using the API, your application which call function 'reboot_freebox' must be granted to "modify freebox settings".
- The way to grant an application to an API categorie is to login your box OS (at the time I'm writing, FreeboxOS or IliadboxOS) 
	- connect your box  OS (1),
	- put your password (2)
	- and click LOGIN (3)

![mafbx](https://user-images.githubusercontent.com/13208359/211349581-0d913d1e-2475-4842-8e2d-ca221b8ec418.png)

- Access the "settings" (or "parameters") menu from the bottom left panel:

![mafbx-param](https://user-images.githubusercontent.com/13208359/211349589-7468fde9-3efb-4444-8d26-9de26e6b5f58.png)


- and to go to the advanced tab of the "parameters menu" 
	- select (at the bottom) the RBAC menu 
	- go to the "application" tab of this newly opened window 
	- edit your application access right 

See the following capture:

![fbx-app-axx](https://user-images.githubusercontent.com/13208359/211077203-039cdce8-b617-48ba-b612-b5a57d497bd5.png)

__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|
___________________________________________________________________________________________



<a name="RAXXURL"></a>

PUBLIC URL - TLS CERTIFICATE - API REMOTE ACCESS
-----------------

- Some of the API require you have a public URL (ex: download share links)
- Remote access to your freebox over internet (from everywhere) require you have a public URL
- This library support LAN, WAN and preconfigured DEFAULT URL and associated TLS certificates

If you want to configure a WAN URL on a public domain, here are the prerequisite:

#### DOMAIN NAME
You need a public domain name to access your box from internet
        - Buy a domain name (type "buy domain name" in google.com)
        - Configure a DNS 'A' record of your domain to point to your Freebox, example:
                - domain name= my-public-domain.net
                - freebox on domain= fbx.my-public-domain.net
                - freebox IP address= 82.82.82.82
        - DNS zone entry to add to my-public-domain.net in this example:
```bash
fbx         IN        A       82.82.82.82
```


__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|
__________________________________________________________________________________________



<a name="TLSCERT"></a>

#### TLS CERTIFICATE
You also need a TLS certificate configured for your new domain fbx.my-public-domain.net
        - You can buy such TLS certificate to a public Certificate Authority
        - You can obtain a FREE TLS certificate at site like [letsencrypt.org](https://letsencrypt.org)
        - Or you can create your own Root CA Certificate and issue Certificate from it, see [CreateMyRootCA](https://fabianlee.org/2018/02/17/ubuntu-creating-a-trusted-ca-and-san-certificate-using-openssl-on-ubuntu/)


Once you have your public URL pointing to your Freebox and a valid TLS certificate for it, go on FreeboxOS interface on https://mafreebox.freebox.fr or if you are in Italy on https://myiliadbox.iliadbox.it from your local network, login and proceed as describe on the following procedure



__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

-------------------------------------------------------------------------------


<a name="RAXX"></a>

### CONFIGURE REMOTE ACCESS

Login to your box OS:
- connect your box  OS (1), 
- put your password (2) 
- and click LOGIN (3)

![mafbx](https://user-images.githubusercontent.com/13208359/211349581-0d913d1e-2475-4842-8e2d-ca221b8ec418.png)

Access the "settings" menu from the bottom left panel:

![mafbx-param](https://user-images.githubusercontent.com/13208359/211349589-7468fde9-3efb-4444-8d26-9de26e6b5f58.png)

Allow remote access to your box: 
- click the "advanced tab"  (3) of the "setting menu" (2) 
- click "configuration" (4)
- you can allow ping (5) 
- you must tic "allow password authentication"  (6) 
- you must fulfill a custom HTTPS port (7)

![mafbx-param-axx](https://user-images.githubusercontent.com/13208359/211349593-598fa3cd-befa-4739-b370-b824a984250e.png)

Now you're ready to configure your domain name URL and TLS certificate 

__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|


-------------------------------------------------------------------------------


<a name="CFGURLTLS"></a>


### CONFIGURE DOMAIN NAME - URL - TLS CERTIFICATE

Access domain name menu:
- connect your box  OS (1),  
- click the "advanced tab"  (3) of the "setting menu" (2)
- select "domain names" (4) 
- click "add a domain name" (5)
- tic the box: "I want to add a domain I have already configured" (6) 
- click "Go" (7)

![mafbx-param-domain1](https://user-images.githubusercontent.com/13208359/211349595-97df3cc8-54b6-4aba-a484-a18cdcaf9dcd.png)

Set in the box the domain name you already configure in the prerequisite:

![mafbx-param-domain2](https://user-images.githubusercontent.com/13208359/211349597-304e33d7-6e3d-49a0-95a3-01c8563a1cca.png)

Tic: "Yes I want to add a TLS certificate":

![mafbx-param-domain3](https://user-images.githubusercontent.com/13208359/211349602-8a1e314e-7e83-487c-846b-24f6b43f4d90.png)

Select your certificate type (RSA/ECDSA) and fulfill all fields like on the picture:
- Certificate (public key)
- Certificate Private Key
- In the last field, put the certificate chain of certificate issuer OR if you'r using your own PKI, put here your Root CA Certificate 

![mafbx-param-domain4](https://user-images.githubusercontent.com/13208359/211349603-d60be069-dba7-4fcc-b96b-d956f368f845.png)


Done! Don't forgot to select your new domain as the "DEFAULT DOMAIN" 

![mafbx-param-domain5](https://user-images.githubusercontent.com/13208359/211349605-6e4f6175-02ab-4f64-bcb4-afe9c5a30f75.png)

Select your new domain as the "DEFAULT DOMAIN": 

![mafbx-param-domain6](https://user-images.githubusercontent.com/13208359/211349609-19366ebf-bf45-435a-b8fb-212d9f70918e.png)

And now, verify your BOX's configuration is fine: 
- go to  the "advanced tab"  (1) of the "setting menu"
- click "Role Based Access Control" (2)
- verify the 'PORT' is the one you previously set in the other menu (3), if not set the same value
- verify the 'Password Remote Access' box is tic (4), if not tic it
- verify the URL for the remote access (5): it must be the one you've just configured
- verify you can obtain new application tokens to access API (6) 

![fbx_remote_axx](https://user-images.githubusercontent.com/13208359/211352356-e3ead03a-a268-4a16-818f-af6c097c3fc5.png)



__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|
__________________________________________________________________________________________

<a name="FULLSTK"></a>

ASK FOR A FULL-STACK IPv4 PUBLIC IP ADDRESS
-----------------

Shared public IPv4 and NAT troubles:

Today, when your connection IS NOT IN BRIDGE MODE but is in ROUTER MODE, in France, Free Telecom from Iliad Group often deliver your internet connection with 1 fixed public IP shared for 4 people (=for 4 neighbourg connections) and Free will NAT 25% of the availiable ports of the public IP address shared with 4 customers to each of the 4 customer's connection. 

That want to say that for the same public IP address, 
- one customer have ports 1 to 16384
- the second customer have ports 16385 to 32768
- the third customer have ports 32768 to 49152
- the second customer have ports 49152 to 65536

If you are in this case and this situation is convinient for you (maybe you have ports from 1 to 16384 which let you disposed of the most usefull ports on internet which are ports less than 1024), you must BE CAREFULL when managing NAT redirection that the NAT redirection is not out of your assigned port range

In the same way, be carefull that your box internal services will not listen on standard port and maybe it can really be awkward in lots of situation, for example if you don't have ports 1 to 16384, it could be difficult to established some IPSEC tunnels with some enterprise class remote device peers which by design of the IPSEC protocole cannot change the IKE (UDP 500) target port when establishing an ipsec connection. This is a small example, but if you activate your box embed FTP server, you cannot use the port 21 for connection and ports 60000 to 65000 for pasive FTP ports (standard FTP configuration)

The number of outgoing session of your network will also be affected by this ip sharing, as each session is uniquely defined in linux kernel by the tuple of src port, src addr, dst addr, dst port, so having only 16384 availiable ports reduce by 4 the session capacity (assuming 50% of your 16384 ports are used for outgoing trafic) and result in session clash when heavy load or large number of clients on the local network.


##### If you have a normal use of your internet connection (if you read this README you may be a sort of 'advanced freebox/iliadbox user'), you may want to open ports and/or to host some services using standard internet ports and having only 25% of your public IP address ports can be awkwed for you. In this situation, you can ask (you may ask) the ISP for a "FULL STACK" public ip address and the ISP will give you a new public IPv4 address with all ports (1 to 65536).  

To ask for a FULL-STACK ip address, you need to connect you customer account at your ISP website.
If you are in France, please connect [Login Free](https://subscribe.free.fr/login/)
If you are in Italy, please connect [Login Iliad](https://www.iliad.it/account/)

When you're connected, select your box tab (in France "Ma Freebox", maybe "My Iliadbox" in Italy) and see the advanced options. Click on the one which speak of full-stack ip address or something similar and follow the process 
##### In France at the time I'm writing, this is FREE OF CHARGE ! 

##### Picture
![fbx-full-stk](https://user-images.githubusercontent.com/13208359/211880050-36fa0255-bad4-4763-8379-3ccc145ff040.png)



__________________________________________________________________________________________
| [TOP](#TOP) | [TABLE OF CONTENTS](#TOC1) | [TABLE OF EXTRAS](#TOC2) | [EXTERNAL RESSOURCES](#TOC3) |
|:-:|:-:|:-:|:-:|

___________________________________________________________________________________________




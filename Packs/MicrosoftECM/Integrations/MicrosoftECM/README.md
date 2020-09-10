
## Configure SCCM on Cortex XSOAR

1. Navigate to **Settings** > **Integrations** > **Servers & Services**.
2. Search for SCCM.
3. Click **Add instance** to create and configure a new integration instance.

| **Parameter** | **Description** | **Required** |
| --- | --- | --- |
| ComputerName | SCCM server IP | False |
| Key | ssh key | True |
| UserName | User Name | False |
| DomainName | Domain Name | True |
| password | The password for the given user | True |
| port | port | False |
| SiteCode | SCCM site code | True |
| insecure | Trust any certificate \(not secure\) | False |

4. Click **Test** to validate the URLs, token, and connection.
## Commands
You can execute these commands from the Demisto CLI, as part of an automation, or in a playbook.
After you successfully execute a command, a DBot message appears in the War Room with the command details.
### sccm-last-log-on-user
***
Gets the last user that logged on to a given computer name


#### Base Command

`sccm-last-log-on-user`
#### Input

| **Argument Name** | **Description** | **Required** |
| --- | --- | --- |
| ComputerName | The Name of the computer the be queried | Required | 


#### Context Output

| **Path** | **Type** | **Description** |
| --- | --- | --- |
| SCCM.Computer.CreationDate | date | The date the computer was created | 
| SCCM.Computer.IP | string | The IP of the computer | 
| SCCM.Computer.LastLogonTimestamp | date | The date of the last login to the computer | 
| SCCM.Computer.LastLogonUserName | string | The name of the last user who logged in  to the computer | 
| SCCM.Computer.Name | string | The name of the computer | 


#### Command Example
```!sccm-last-log-on-user ComputerName=EC2AMAZ-2AKQ815```

#### Context Example
```
{
    "SCCM": {
        "Computer": {
            "CreationDate": "2019-12-07T10:07:51Z",
            "IP": "172.31.32.170 fe80::81c5:1670:9363:a40b ",
            "LastLogonTimestamp": "2020-24-03T03:09:09Z",
            "LastLogonUserName": null,
            "Name": "EC2AMAZ-2AKQ815"
        }
    }
}
```

#### Human Readable Output

>### Last loggon user on EC2AMAZ-2AKQ815
>| CreationDate | IP | Name | LastLogonTimestamp | LastLogonUserName
>| --- | --- | --- | --- | ---
>| 2019\-12\-07T10:07:51Z | 172.31.32.170 fe80::81c5:1670:9363:a40b  | EC2AMAZ\-2AKQ815 | 2020\-24\-03T03:09:09Z | 


### sccm-get-primary-user
***
Get the primary user of a given computer name


#### Base Command

`sccm-get-primary-user`
#### Input

| **Argument Name** | **Description** | **Required** |
| --- | --- | --- |
| ComputerName | The name of the computer to be queried | Required | 


#### Context Output

| **Path** | **Type** | **Description** |
| --- | --- | --- |
| SCCM.PrimaryUsers.Machine Name | string | The name of the computer | 
| SCCM.PrimaryUsers.User Name | string | The name of the primary user | 


#### Command Example
```!sccm-get-primary-user ComputerName=EC2AMAZ-2AKQ815```

#### Context Example
```
{
    "SCCM": {
        "PrimaryUsers": {
            "Machine Name": "EC2AMAZ-2AKQ815",
            "User Name": "demisto\\sccmadmin"
        }
    }
}
```

#### Human Readable Output

>### Primary users on EC2AMAZ-2AKQ815
>| Machine Name | User Name
>| --- | ---
>| EC2AMAZ\-2AKQ815 | demisto\\sccmadmin


### sccm-get-installed-softwares
***
Gets installed softwares on a given computer name


#### Base Command

`sccm-get-installed-softwares`
#### Input

| **Argument Name** | **Description** | **Required** |
| --- | --- | --- |
| ComputerName | The name of the computer to be queried | Optional | 


#### Context Output

| **Path** | **Type** | **Description** |
| --- | --- | --- |
| SCCM.InstalledSoftwares.Caption | string | Short textual description for the software—a one-line string | 
| SCCM.InstalledSoftwares.IdentifyingNumber | string | Product identification such as a serial number on software, or a die number on a hardware chip | 
| SCCM.InstalledSoftwares.Name | string | Commonly used software name | 
| SCCM.InstalledSoftwares.Vendor | string | Name of the software supplier | 
| SCCM.InstalledSoftwares.Version | string | Software version information | 


#### Command Example
```!sccm-get-installed-softwares ComputerName=EC2AMAZ-2AKQ815```

#### Context Example
```
{
    "SCCM": {
        "InstalledSoftwares": [
            {
                "Caption": "Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.40660",
                "IdentifyingNumber": "E30D8B21-D82D-3211-82CC-0F0A5D1495E8",
                "Name": "Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.40660",
                "Vendor": "Microsoft Corporation",
                "Version": "12.0.40660"
            },
            {
                "Caption": "Configuration Manager Client",
                "IdentifyingNumber": "C4C37F43-7A9E-4E71-8465-B5AB1FA4A563",
                "Name": "Configuration Manager Client",
                "Vendor": "Microsoft Corporation",
                "Version": "5.00.8790.1000"
            },
            {
                "Caption": "Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40660",
                "IdentifyingNumber": "5740BD44-B58D-321A-AFC0-6D3D4556DD6C",
                "Name": "Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40660",
                "Vendor": "Microsoft Corporation",
                "Version": "12.0.40660"
            },
            {
                "Caption": "AWS Tools for Windows",
                "IdentifyingNumber": "52FCDD35-8301-4EC1-A6FA-A826CD43F542",
                "Name": "AWS Tools for Windows",
                "Vendor": "Amazon Web Services Developer Relations",
                "Version": "3.15.756"
            },
            {
                "Caption": "Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.40660",
                "IdentifyingNumber": "7DAD0258-515C-3DD4-8964-BD714199E0F7",
                "Name": "Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.40660",
                "Vendor": "Microsoft Corporation",
                "Version": "12.0.40660"
            },
            {
                "Caption": "Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40660",
                "IdentifyingNumber": "CB0836EC-B072-368D-82B2-D3470BF95707",
                "Name": "Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40660",
                "Vendor": "Microsoft Corporation",
                "Version": "12.0.40660"
            },
            {
                "Caption": "AWS PV Drivers",
                "IdentifyingNumber": "907CEBFD-464D-493F-A38C-45695EF12364",
                "Name": "AWS PV Drivers",
                "Vendor": "Amazon Web Services",
                "Version": "8.2.7"
            },
            {
                "Caption": "Microsoft Policy Platform",
                "IdentifyingNumber": "6549B04F-E826-4E0A-8C3F-388540F08541",
                "Name": "Microsoft Policy Platform",
                "Vendor": "Microsoft Corporation",
                "Version": "68.1.1010.0"
            },
            {
                "Caption": "aws-cfn-bootstrap",
                "IdentifyingNumber": "34CD0CCF-195B-4BC5-B409-D44EB9A129C8",
                "Name": "aws-cfn-bootstrap",
                "Vendor": "Amazon Web Services",
                "Version": "1.4.31"
            },
            {
                "Caption": "Amazon SSM Agent",
                "IdentifyingNumber": "37621EDF-2D4A-4636-804B-F79BCC30BE77",
                "Name": "Amazon SSM Agent",
                "Vendor": "Amazon Web Services",
                "Version": "2.3.542.0"
            }
        ]
    }
}
```

#### Human Readable Output

>### Installed softwares on EC2AMAZ-2AKQ815
>| Name | Version | Vendor | Caption | IdentifyingNumber
>| --- | --- | --- | --- | ---
>| Microsoft Visual C\+\+ 2013 x86 Minimum Runtime \- 12.0.40660 | 12.0.40660 | Microsoft Corporation | Microsoft Visual C\+\+ 2013 x86 Minimum Runtime \- 12.0.40660 | E30D8B21\-D82D\-3211\-82CC\-0F0A5D1495E8
>| Configuration Manager Client | 5.00.8790.1000 | Microsoft Corporation | Configuration Manager Client | C4C37F43\-7A9E\-4E71\-8465\-B5AB1FA4A563
>| Microsoft Visual C\+\+ 2013 x64 Additional Runtime \- 12.0.40660 | 12.0.40660 | Microsoft Corporation | Microsoft Visual C\+\+ 2013 x64 Additional Runtime \- 12.0.40660 | 5740BD44\-B58D\-321A\-AFC0\-6D3D4556DD6C
>| AWS Tools for Windows | 3.15.756 | Amazon Web Services Developer Relations | AWS Tools for Windows | 52FCDD35\-8301\-4EC1\-A6FA\-A826CD43F542
>| Microsoft Visual C\+\+ 2013 x86 Additional Runtime \- 12.0.40660 | 12.0.40660 | Microsoft Corporation | Microsoft Visual C\+\+ 2013 x86 Additional Runtime \- 12.0.40660 | 7DAD0258\-515C\-3DD4\-8964\-BD714199E0F7
>| Microsoft Visual C\+\+ 2013 x64 Minimum Runtime \- 12.0.40660 | 12.0.40660 | Microsoft Corporation | Microsoft Visual C\+\+ 2013 x64 Minimum Runtime \- 12.0.40660 | CB0836EC\-B072\-368D\-82B2\-D3470BF95707
>| AWS PV Drivers | 8.2.7 | Amazon Web Services | AWS PV Drivers | 907CEBFD\-464D\-493F\-A38C\-45695EF12364
>| Microsoft Policy Platform | 68.1.1010.0 | Microsoft Corporation | Microsoft Policy Platform | 6549B04F\-E826\-4E0A\-8C3F\-388540F08541
>| aws\-cfn\-bootstrap | 1.4.31 | Amazon Web Services | aws\-cfn\-bootstrap | 34CD0CCF\-195B\-4BC5\-B409\-D44EB9A129C8
>| Amazon SSM Agent | 2.3.542.0 | Amazon Web Services | Amazon SSM Agent | 37621EDF\-2D4A\-4636\-804B\-F79BCC30BE77


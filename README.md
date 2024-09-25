# QualvoSec
<img align="left" src="https://cdn.gyptazy.com/images/QualvoSec-Security-Patch-Framework.jpg"/>
<br>

<p float="center"><img src="https://img.shields.io/github/license/gyptazy/QualvoSec"/><img src="https://img.shields.io/github/contributors/gyptazy/QualvoSec"/><img src="https://img.shields.io/github/last-commit/gyptazy/QualvoSec/main"/><img src="https://img.shields.io/github/issues-raw/gyptazy/QualvoSec"/><img src="https://img.shields.io/github/issues-pr/gyptazy/QualvoSec"/></p>


## Table of Content
* Introduction
* Features
* General
  * Client
    * Config
    * Options
  * Server
    * Options
    * Weekday Definitions
  * Admin
* Usage
  * Systemd
  * Manual
  * Parameters
  * Supported Systems
  * Dependencies
* HowTos & References
* Motivation
* Packages
* Misc
  * Bugs
  * Contributing
  * Author(s)

## Introduction
`QualvoSec` is a minimalistic security patch management tools (security patch framework) for unattended upgrades on Linux and BSD based systems that are obtaining their packages from a distribution based repository. It is written in Python for minimal setups where solutions like Spacewalk or Landscape would be too bloated. QualvoSec supports Debian (e.g. Ubuntu, GardenLinux, etc.) and RedHat (CentOS, Fedora, RockyLinux, etc.) based Distributions but also BSD (e.g. FreeBSD, OpenBSD, macOS, etc.).

## Features
* Not running as root
  * Only specific commands allowed by sudo
* Clients pulling information from server
* Server provides only a static manifest
  * Holding the patch windows of clients
  * No remote code executions
  * A potential compromised server could not be able to execute code on clients
* Health monitoring endpoint on clients
* Minimalistic design
* Admin tool for creating, deleting and looking up of client patch windows
* Fully written in Python3
* Integrated packaging support by CMake
* CMake/CPack created .deb and .rpm files
* Support for Linux, BSD
* Support for AMD64, ARM64 and RISC-V hardware architecture

## General
QualvoSec is a software designed for efficient and automated security management of remote servers. This application operates by periodically inspecting a designated remote server manifest (a static YAML file) to extract information relevant to the local system's Fully Qualified Domain Name (FQDN). The manifest contains crucial details, including the specified date for patching corresponding systems and whether a system necessitates a reboot post-patch installation.

With its proactive approach, QualvoSec ensures that systems are up-to-date with the latest patches, promoting robust security measures. The software streamlines the process by matching FQDNs, allowing for targeted actions based on the unique identity of each local system. By providing clear directives on patching timelines and reboot requirements, QualvoSec enhances overall system security and stability, minimizing vulnerabilities and potential risks associated with outdated software.

### Communication
![right:40% 80%](https://cdn.gyptazy.ch/images/QualvoSec-topology.jpg)

### Flowchart
![width:22cm height:13cm](https://cdn.gyptazy.ch/images/QualvoSec-flowchart.png)

### Client
The client is required to gather additional information from a configuration file, which should include the specified details. By default, the client will search for a configuration file in /etc/qualvosec/qualvosec.conf. However, users have the flexibility to define a custom path for the configuration file by utilizing the -c argument with the client (refer to the usage chapter for more details).

Upon initiation, the client will retrieve the patch manifest file from the server, and this file will be cached for a duration of 6 hours. If necessary, the cache can be invalidated by simply restarting the client. Each time the client is started, the file will be freshly acquired before being cached. Throughout runtime, the cache will be automatically cleared after 6 hours, allowing for any changes from the manifest to take effect. This approach is implemented to prevent excessive server requests, particularly when multiple clients may otherwise inundate the server with requests every minute.

#### Config
```
[general]
server: https://patching.gyptazy.int
log_level: CRITICAL
log_handler: SystemdHandler()
```

#### Options
The following options can be set in the `qualvosec.conf` file:

| Option | Type | Description | 
|------|:------:|:------:|
| server | String | Defines the remote server instance hosting the manifest file. |
| monitoring | Bool | Defines to activate the monitoring interface. |
| monitoring_port | Integer | Defines the port of the monitoring interface (Default: 8037). |
| monitoring_listener | String | Defines the listener address of the monitoring interface (Default: 127.0.0.1). |
| log_level | String | Defines the log level (Default: CRITICAL). |
| log_handler | String | Defines the log handler (Default: SystemdHandler). |

#### Monitoring Interface
To validate that the service is up and running a monitoring interface including a health endpoint can be activated (see also chapter Options). By default, the endpoint listens on tcp/8037 (can be adjusted) and can be checked with
any http conform client (e.g. GypMon, Icinga2, etc.).

Example:

```
$> curl localhost:8037/health
healthy=true
```

Currently, the endpoint will only report the following states for type `healthy`:
* true
* false

### Server
On the root path of the defined domain, a `patch.yaml` file (manifest) must be placed. This static file contains all further information of the clients that consume the file periodically. An example file is given below:

```
hypervisor01.gyptazy.ch:
  patch: true
  reboot: true
  weekday: 1
  hour: 23
  minute: 30
  packages_whitelist:
    - nginx
    - tzdata
  packages_whitelisted:
    - vim
hypervisor02.gyptazy.ch:
  patch: true
  reboot: true
  weekday: 2
  hour: 3
  minute: 15
group_membership:
  - gyptazy_prod
  - patch_cycle_monday
```

This example provides patch information for two systems where the key is equal to the client system that should be patched. In this example, the system with the fqdn `hypervisor01.gyptazy.ch` should be patched and also be rebooted in general. The patches should be integrated every Tuesday (1) at 11:30 PM. Given by the key `packages` (type: list), only the defined packages (whitelist) will be upgraded.

#### Options
The following options can be set in the `patch.yaml` file and will be interpreted by the corresponding client.

| Option | Type | Description | 
|------|:------:|:------:|
| patch | Bool | Defines if the system should be patched in general. It might be helpful to deactivate this on important dates. |
| reboot | Bool | Defines if the system should be rebooted after the installation of patches. GLIBC, Kernel etc. may require this. |
| weekday | Integer | Defines the weekday (starting on Mondays with 0). |
| hour | Integer | Defines the hour to start the patching (to be defined in 24 hours syntax). |
| minute | Integer | Defines the minute to start the patching. |
| packages_whitelist | List | Defines specific packages to only update (Default: all) |
| packages_blacklist | List | Defines specific packages to exclude from being updated (Default: none) |
| group_membership | List | Defines a list of group memberships (e.g. customer, project, patch-cycles, etc.) (Default: none) |

#### Weekday Definitions
| Weekday | Config (Integer) | 
|------|:------:|
| Monday | 0 |
| Tuesday | 1 | 
| Wednesday | 2 | 
| Thursday | 3 | 
| Friday | 4 | 
| Saturday | 5 | 
| Sunday | 6 | 

### Admin
QualvoSec's admin utility offers a comprehensive solution for efficient system management. Users benefit from a centralized platform that provides a quick overview of connected systems and their patch statuses. The utility facilitates seamless system management by allowing users to add or remove systems with ease. This streamlined process ensures that the organization's security infrastructure remains up-to-date and aligned with operational requirements.

#### Options
The following options can be set in the `qualvosec_admin.conf` file:

| Option | Type | Description | 
|------|:------:|:------:|
| server | String | Defines the remote server instance hosting the manifest file. |
| log_file_path | String | Defines path to the server's access log file. |

#### Arguments
| Args | Description | 
|------|:------:|
| list | Lists all systems (providing an overview) |
| add | Adds new system and/or patch cycle |
| remove | Removes a system and/oe patch cycle |

#### Example Output List
Attached, you can find a sample outpout of the list command, showing the system overview:

```
System (FQDN)                            Last Seen            Alive      Reboot     Patch      Patch Date
______________________________________________________________________________________________________________
giro48.gyptazy.ch                         never                0          0          1          Fri, 3:15 
giro49.gyptazy.ch                         never                0          0          1          Tue, 3:15 
giro50.gyptazy.ch                         never                0          0          1          Fri, 3:15 
giro51.gyptazy.ch                         never                0          0          1          Tue, 3:15 
giro52.gyptazy.ch                         never                0          0          1          Fri, 3:15 
giro53.gyptazy.ch                         never                0          0          1          !WRONG WEEKDAY!, 1:15
```


## Usage
### Systemd
The easiest way, if supported by the underlying system, is to copy the sudo-droplet and the systemd-service file. Afterwards, the system can be started and orchestrated by systemd.

### Manual
A manual installation is possible and also supports BSD based systems. QualvoSec relies on mainly two important files:
* qualvosec (Python Executable)
* qualvosec.conf (Config file)

The executable must be able to read the config file.

### Parameters
The following options and parameters are currently supported:

| Option | Long Option | Description | Default |
|------|:------:|------:|------:|
| -c | --config | Path to a config file. | /etc/qualvosec/qualvosec.conf | 

### Supported Systems
The goal is to support as many platforms and systems as possible which only needs a small Python environment without any further custom imports. Therefore, this is supported to run on:
* Linux (Debian, Ubuntu, Garden Linux, RedHat, CentOS, RockyLinux, etc.)
* BSD (FreeBSD, NetBSD, OpenBSD)
* macOS (OSX)

### Dependencies
QualvoSec is fully written in Python and just needs the basic modules to run. Please make sure that you have in place:

* Python 3
  * argparse
  * configparser
  * datetime
  * http
  * logging
  * os
  * socket
  * subprocess
  * sys
  * time
  * urllib
  * yaml


When running on Linux systems with `systemd` you should also make sure to have `sudo` installed and to use the sudo-droplet.

## HowTos & References
A collection of howtos and references of QualvoSec in the net.

| Type | Description | Link |
|------|:------:|:------:|
| Announcement | Release announcement of QualvoSec | [Link](https://gyptazy.ch/blog/qualvosec-a-minimalistic-security-patch-management-tools-for-linux-and-bsd/) |
| HowTo | Howto Install QualvoSec Security Patch Management on Debian and Ubuntu | [Link](https://gyptazy.ch/howtos/howto-install-qualvosec-security-patch-management-on-debian/) |

## Motivation
The motivation behind developing a self-written security patch management software with a focus on minimalism and reduced dependencies stems from the need for a streamlined and efficient solution. Traditional patch management tools often come with unnecessary bloat and dependencies, leading to increased complexity and resource consumption. In response to this, the goal is to create a slim, lightweight alternative that prioritizes simplicity and effectiveness.

The key motivation is to provide a centralized system for managing security patches across different systems. This centralization enables administrators to define specific patch dates for various systems, ensuring a coordinated and controlled approach to patch deployment. By avoiding unnecessary features and dependencies, the software aims to minimize the risk of vulnerabilities associated with unused or poorly maintained components.

This approach not only enhances the software's performance but also reduces the attack surface, making it more resilient against potential security threats. The emphasis on simplicity and minimalism contributes to easier maintenance and faster response times when addressing emerging security concerns.

In summary, the motivation behind creating this self-written security patch management software lies in the pursuit of efficiency, reduced complexity, and centralized control. By offering a slim, lightweight solution with minimal dependencies, the software aims to provide a more secure and manageable approach to handling security patches across diverse systems.

## Packages
### Sources
All sources are available within this repository. Needed files can be just copied and manually be configured to the operator's needs. Next to this, you can also use a CMake script to re-package the sources for RPM and DEB based distributions.
Script for packaging can be found in the directory `packaging`. Packages can be created by simply running `packaging.sh`. A new directory `packages` gets created including the final artifacts.

### Distribution Packages
Packages for end-user can be found on https://cdn.gyptazy.ch/files/ for the following operating systems and architectures:

| OS | Distribution | Architecture | File |
|------|:------:|------:|------:|
| Linux | Debian | amd64 | https://cdn.gyptazy.ch/files/amd64/debian/qualvosec/ |
| Linux | Debian | arm64 | https://cdn.gyptazy.ch/files/amd64/debian/qualvosec/ |
| Linux | Debian | riscv64 | https://cdn.gyptazy.ch/files/amd64/debian/qualvosec/ |
| Linux | Ubuntu | amd64 | https://cdn.gyptazy.ch/files/amd64/ubuntu/qualvosec/ |
| Linux | Ubuntu | arm64 | https://cdn.gyptazy.ch/files/amd64/ubuntu/qualvosec/ |
| Linux | Ubuntu | riscv64 | https://cdn.gyptazy.ch/files/amd64/ubuntu/qualvosec/ |
| Linux | RedHat | amd64 | https://cdn.gyptazy.ch/files/amd64/redhat/qualvosec/ |
| Linux | RedHat | arm64 | https://cdn.gyptazy.ch/files/amd64/redhat/qualvosec/ |
| Linux | RedHat | riscv64 | https://cdn.gyptazy.ch/files/amd64/redhat/qualvosec/ |
| Linux | RockyLinux / CentOS | amd64 | https://cdn.gyptazy.ch/files/amd64/centos/qualvosec/ |
| Linux | RockyLinux / CentOS | arm64 | https://cdn.gyptazy.ch/files/amd64/centos/qualvosec/ |
| Linux | RockyLinux / CentOS | riscv64 | https://cdn.gyptazy.ch/files/amd64/centos/qualvosec/ |
| BSD | FreeBSD | amd64 | https://cdn.gyptazy.ch/files/amd64/freebsd/qualvosec/ |
| BSD | FreeBSD | arm64 | https://cdn.gyptazy.ch/files/amd64/freebsd/qualvosec/ |
| BSD | FreeBSD | riscv64 | https://cdn.gyptazy.ch/files/amd64/freebsd/qualvosec/ |

## Misc
### Bugs
Bugs can be reported via the GitHub issue tracker [here](https://github.com/gyptazy/QualvoSec/issues). You may also report bugs via email or deliver PRs to fix them on your own. Therefore, you might also see the contributing chapter.

### Contributing
Feel free to add further documentation, to adjust already existing one or to contribute with code. Please take care about the style guide and naming conventions.

### Author(s)
 * Florian Paul Azim Hoberg @gyptazy

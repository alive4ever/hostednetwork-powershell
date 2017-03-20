# Wifi Hosted Network Powershell

## Introduction
This is a rewrite of [wifi-hosted-network-cmd](https://github.com/alive4ever/wifi-hosted-network).
The rewrite is using Powershell instead of CMD for future compatibility.

I decide to rewrite the script in Powershell because of the following reason.

1. Batch scripting is legacy way to do things.
	
	While the batch scripting is working fine, I want to learn something new. Powershell 
	gives a new way to interact with Windows scripting environment.
	
2. Future proof.
	
	Somewhere in the future, batch scripting may be dropped. This rewrite will hopefully
	make this project survive in the future.
	
3. Easy to debug.

	Powershell makes a great environment to write and debug script. I want to make use of 
	those debugging feature to help me write the script.
	
My concept of a good script are below.

1. The script should be easy to use.
	
	[x] Good brief about what the script does.
	
	[x] Good user interaction.
	
2. The script should perform as intended.
	
	[x] Less actions needed to get the job done.
	
	[x] Self diagnostic can be performed to satisfy requirements of actions performed.
	
	[x] Good explanation on errors.
	
## What is hosted network?

Hosted network is Windows implementation of software-based wireless access point. It's 
different from Ad-hoc networking. Hosted network is recognized as wireless infrastructure 
and available for most mobile devices, including Android and iOS.

Hosted network can be set up manually via `cmd` or `powershell` with administrator rights, 
using the following commands.

1. Configuration.
```
netsh wlan set hostednetwork mode=Allow ssid="Wireless AP" key="My Secret Key" keyUsage="persistent"
```
2. Starting hosted network.
```
netsh wlan start hosted network
```
3. Stopping hosted network.
```
netsh wlan stop hostednetwork
```

## Usage
To run this script, you need Powershell to allow running script file.

1. Launch Powershell as administrator. Type the following command to show current 
script execution policy. It's likely to be `Restricted` for the first time.

```
Get-ExecutionPolicy
```
2. In the Administrator Powershell window, type the following command to allow running 
script.
```
Set-ExecutionPolicy Unrestricted
```
If you are sure to run the script, make an approval by pressing `y`. If you don't intend to run
the script, press `n` to decline.

3. Now, you can run the Powershell script.
Remember, if you don't trust me, you SHOULD open the script file via Powershell ISE by clicking File -->
Open or open it in your text editor prior to running. Review the script and make necessary editing as you 
need.

## What this script does.

If you are paranoid and doesn't trust me, this is a brief explanation of what this script does.

1.	Detecting administrator rights to perform hosted network configuration and tasks.
	
	* If administrator rights is unavailable, the script will abort.
	
2.	Detecting whether the wireless driver supports hosted network.
	
	* If the driver doesn't support hosted network, warn user and abort.
	
3.	If the wireless driver supports hosted network, prompt the user for configuration.
	
	* SSID (Wireless access point visible name)
	
	* WPA2 passphrase
	
4.	After configuration has been set up, prompt the user to do wifi related tasks.
	
	* Starting and stopping the hosted network.
		
		+ A guide to enable internet connection sharing is shown on successful startup.
		
		+ A warning is displayed if the wireless device is disabled or powered off.
		
	* List connected stations.
		
		+ Displayed by showing MAC-Addresses
		
	* Changing hosted network configuration.
		
		+ SSID & WPA2 passphrase.

5.	When the hosted network is not needed anymore, user can stop it and exit the script.

## Windows Hosted Network Limitation

Currently, Windows hosted network has the following limitations.

1. Wireless mode can't be changed.

	You are stuck with WPA2-PSK mode. This is considered good for personal use, but may be 
	unsuitable for use with Enterprise which needs stronger wireless protection. A passphrase 
	is always required to get the hosted network running.
	
2. No configuration of wireless operating mode.
	
	Windows hosted network operates at half-N speed (65 mbps). The achieved wireless throughput 
	may be less than that due to latency and other causes. You won't be able to utilize all 
	wireless chip potential due to this limitation.
	
3. Limited number of connected clients.
	
	Since Windows client OS is designed that way, there is a limitation of how many clients can 
	connect at the same time to the configured hosted network.

Currently, there is no way to overcome those limitations.

If you want a full featured wireless solution, you may get yourseft a recent wireless router or 
use Host AP implementation such as [HostApd](http://w1.fi/hostapd) which is available on GNU/Linux 
or BSD distributions.

# Bug Reports

All bugs should be reported via issue tracker. Patches and pull requests are greatly appreciated.

# License

MIT license, see [LICENSE](./LICENSE.md)
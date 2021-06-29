#!/bin/bash
# 
# ***** BEGIN LICENSE BLOCK *****
# Zimbra Collaboration Suite Server
# Copyright (C) 2005, 2007, 2010, 2013, 2014, 2016 Synacor, Inc.
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software Foundation,
# version 2 of the License.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program.
# If not, see <https://www.gnu.org/licenses/>.
# ***** END LICENSE BLOCK *****
# 

getConfigOptions() {
	echo ""
	echo "Configuration section"
	if [ $STORE_HERE = "yes" -a $POSTFIX_HERE = "no" ]; then
		askNonBlank "Please enter the hostname for zimbraSmtpHostname" \
			"$SMTPHOST"
		SMTPHOST=$response
	fi
	if [ $STORE_HERE = "yes" ]; then
		while :; do
			askNonBlank "Enter web server mode (http, https, mixed, redirect)" "$MODE"
			MODE=$response
			if [ $MODE = "http" -o $MODE = "https" -o $MODE = "mixed" -o $MODE = "redirect" ]; then
				break
			else
				echo "Please enter a valid mode"
			fi
		done
		if [ $ALLOWSELFSIGNED = "true" -o $ALLOWSELFSIGNED = "yes" ]; then
			ALLOWSELFSIGNED="yes"
		else
			ALLOWSELFSIGNED="no"
		fi
		# Hardcoding for bootstrap install. 20050725 MEM
		ALLOWSELFSIGNED="true"

	fi

	if [ $LDAP_HERE = "yes" ]; then
		LDAPHOST=$HOSTNAME
		LDAPPORT=389
		if [ $UPGRADE = "no" ]; then
			su - zimbra -c "zmlocalconfig -e -r startup_ldap_password"
			LDAPROOTPW=`su - zimbra -c "zmlocalconfig -s -m nokey startup_ldap_password"`
			askNonBlank "Enter the root ldap password for $LDAPHOST:" \
				"$LDAPROOTPW"
			LDAPROOTPW=$response
			su - zimbra -c "zmlocalconfig -e startup_ldap_password=''"
		fi
	else
		while :; do

			askNonBlank "Please enter the hostname for the ldap server" "$LDAPHOST"
			LDAPHOST=$response
			askInt "Please enter the port for the ldap server" "$LDAPPORT"
			LDAPPORT=$response

			if [ $LDAP_HERE = "no" -a $UPGRADE = "no" ]; then
				askNonBlank "Enter the root ldap password for $LDAPHOST:" \
					"$LDAPROOTPW"
				LDAPROOTPW=$response
				askNonBlank "Enter the zimbra admin ldap password for $LDAPHOST:" \
				LDAPZIMBRAPW=$response
			fi

			verifyLdapServer
			
			if [ $LDAPOK = "yes" ]; then
				break
			fi
		done

	fi

	if [ $UPGRADE = "no" ]; then

		if [ $POSTFIX_HERE = "yes" ]; then
			askYN "Enable Clam Anti-virus services?" "$RUNAV"
			RUNAV=$response
			if [ $RUNAV = "yes" ]; then
				if [ "x$AVUSER" = "x" ]; then
					AVUSER="notify@${HOSTNAME}"
				fi
				askNonBlank "Notification address for AV alerts?" "$AVUSER"
				AVUSER=$response
				AVDOMAIN=`echo $AVUSER | awk -F@ '{print $2}'`
			fi
			askYN "Enable SpamAssassin anti-spam services?" "$RUNSA"
			RUNSA=$response
		fi

		if [ $SNMP_HERE = "yes" ]; then
			askYN "Notify via SNMP?" "$SNMPNOTIFY"
			SNMPNOTIFY=$response
			if [ $SNMPNOTIFY = "yes" ]; then
				askNonBlank "SNMP Trap host?" "$SNMPTRAPHOST"
				SNMPTRAPHOST=$response
				SNMPNOTIFY=1
			else
				SNMPNOTIFY=0
			fi
			askYN "Notify via SMTP?" "$SMTPNOTIFY"
			SMTPNOTIFY=$response
			if [ $SMTPNOTIFY = "yes" ]; then
				askNonBlank "SMTP Source email address?" "$SMTPSOURCE"
				SMTPSOURCE=$response
				askNonBlank "SMTP Destination email address?" "$SMTPDEST"
				SMTPDEST=$response
				SMTPNOTIFY=1
			else
				SMTPNOTIFY=0
			fi
		fi

		askYN "Create a domain?" "Y"
		if [ $response = "yes" ]; then
			askNonBlank "Enter domain to create:" "$CREATEDOMAIN"
			CREATEDOMAIN=$response
			while :; do
				askYN "Create an admin account?" "Y"
				if [ $response = "yes" ]; then
					CREATEADMIN="admin@${CREATEDOMAIN}"
					askNonBlank "Enter admin account to create:" "$CREATEADMIN"
					CREATEADMIN=$response
					while :; do
						askNonBlankNoEcho "Enter admin password (min 6 chars):" ""
						len=`echo $response | wc -m`
						# Not sure why, but wc -m reports one too many
						if [ $len -gt 6 ]; then
							CREATEADMINPASS=$response
							askNonBlankNoEcho "Re-enter admin password (min 6 chars):" ""
							if [ $CREATEADMINPASS = $response ]; then
								break
							else
								echo "Passwords do not match!"
							fi
						else
							echo "Please enter a password 6 characters or longer"
						fi
					done
					admindomain=`echo $CREATEADMIN | awk -F@ '{print $2}'`
					if [ x$admindomain = x$CREATEDOMAIN ]; then
						break
					else
						echo "You must create an admin account under the domain $CREATEDOMAIN"
					fi
				else
					break
				fi
			done
		else
			CREATEDOMAIN=""
			CREATEADMIN=""
			CREATEADMINPASS=""
		fi
	fi

}

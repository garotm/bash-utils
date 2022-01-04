#!/usr/local/bin/bash
#: Title        : site_version-fix
#: Date         : 2013-05-05
#: Author       : Garot Conklin
#: Version      : 1.00
#: Description  : Site Version check fix
#: Options      : 0
#: Resident     : on-host
#: Extraction   : N/A
#: Runbook      : 11116
#: BUG          : [bug 6262157]
#: Return codes : 2
#:              : 0 = successful
#:              : 1 = failure
#:              :-1 = ambiguous; no execution
#:
#: Host validation
#:
if [[ $(uname -n |cut -d. -f1 |sed 's/[0-9]*//g') != "www" ]]; then
        printf "\n$(uname -n) is not a www host; aborting\n\n";
        exit 1;
fi
#:
#: Inital condition confirmation
#:
if [[ -n $(yms-test-checks -s site-version |grep OK) ]]; then
        yms-test-checks -s site-version -c
        printf '\n\e[1;33m%-6s\e[m\n\n' "Not Alerting; aborting."
        exit -1;
else
        yms-test-checks -s site-version -c
        printf '\n\e[1;33m%-6s\e[m\n' "Alert Verified, remediating."
        sudo rm /tmp/deploy.lock;
        sudo rm /tmp/flickr_version_check.tmp;
        sudo /home/y/libexec/nagios/flickr_check_version.py;
        for i in {5..0}; do
                printf "\rVerifying remediation, please wait for $i ";
                sleep 1;
        done;
        printf "\n\n";
        yms-test-checks -c
        exit 0;
fi
#:
#: EOF
#:

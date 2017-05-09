# attempt to connect to a running agent - cache SSH_AUTH_SOCK in ~/.ssh/
function getenv() {
        monenv=~/.ssh/ssh-agent.env
        [ -S "$SSH_AUTH_SOCK" ] || { [ -f $monenv ] && export SSH_AUTH_SOCK="$(< $monenv)" }
        PID=${SSH_AUTH_SOCK##*\.}
#       printf "\n  ssh-agent\tPID %s\tSOCKET %s\n" "$PID" $SSH_AUTH_SOCK
        echo "Agent récupéré"
}
function sagent()
{
        monenv=~/.ssh/ssh-agent.env

        find /tmp/ -name "ssh-*" -exec rm -r {} \;
        find $monenv -delete

        eval "$(ssh-agent)"
        echo "$SSH_AUTH_SOCK" > $monenv
        chmod u+rwx,go-rwx $monenv

        PID=${SSH_AUTH_SOCK##*\.}

#       printf "\n  ssh-agent\tPID %s\tSOCKET %s\n" "$PID" $SSH_AUTH_SOCK
        echo "Agent créé"
}

TMP=$(mktemp)
ps | grep ssh-agent > $TMP
size=$(wc -l $TMP | awk '{print $1}')

if [[ $size -eq 1 ]]
        then    getenv
elif [[ $size -eq 0 ]]
        then    sagent
elif [[ $size -gt 1 ]]
        then    echo "PROBLEME TROP D'AGENT"
                killall ssh-agent
                sagent
fi
rm $TMP
echo "use ssh-add to add keys"
echo ""
echo "  ssh-add .ssh/id_rsa_wf .ssh/id_rsa .ssh/id_rsa_frankfurt "
echo ""
echo "  a=makepasswd; echo \$(\$a)\$(\$a) "
echo ""

ssh-add -l && keyin="true" || keyin="false"

if [[ $keyin == "false" ]]
then
        echo "J'AI RIEN DEDANS"
        ssh-add .ssh/id_rsa_wf .ssh/id_rsa .ssh/id_rsa_frankfurt
else
        echo "c'est good"
fi


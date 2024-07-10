# Export 'SHELL' to child processes.  Programs such as 'screen'
# honor it and otherwise use /bin/sh.
export SHELL

if [[ $- != *i* ]]
then
    # We are being invoked from a non-interactive shell.  If this
    # is an SSH session (as in "ssh host command"), source
    # /etc/profile so we get PATH and other essential variables.
    [[ -n "$SSH_CLIENT" ]] && source /etc/profile

    # Don't do anything else.
    return
fi

# Source the system-wide file.
source /etc/bashrc

# Adjust the prompt depending on whether we're in 'guix environment'.
if [ -n "$GUIX_ENVIRONMENT" ]
then
    PS1='\u@\h \w [env]\$ '
else
    PS1='\u@\h \w\$ '
fi

alias ls='ls -p --color=auto'
alias ll='ls -l'
alias grep='grep --color=auto'

function prompt_command {
    GIT_BRANCH=$(git --no-optional-locks symbolic-ref --short HEAD 2> /dev/null) \
    || GIT_BRANCH=$(git --no-optional-locks rev-parse --short HEAD 2> /dev/null) \
    ||GIT_BRANCH=""
}

PROMPT_COMMAND=prompt_command

PS1="╭─[\u@\h \w] <\$GIT_BRANCH>
╰─$ "
. "$HOME/.cargo/env"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

function prompt_command {
    GIT_BRANCH=$(git --no-optional-locks symbolic-ref --short HEAD 2> /dev/null) \
    || GIT_BRANCH=$(git --no-optional-locks rev-parse --short HEAD 2> /dev/null) \
    ||GIT_BRANCH=""
}

PROMPT_COMMAND=prompt_command

PS1="╭─[\u@\h \w] <\$GIT_BRANCH>
╰─$ "

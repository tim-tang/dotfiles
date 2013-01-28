# some more ls aliases
alias ls='ls -G -ltr'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias h='history'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias mvn='mvn-color'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
#copy the working directory into the clipboard
alias cwd='pwd | pbcopy'

# Unbreak broken, non-colored terminal
export TERM='xterm-color'
export GREP_OPTIONS="--color"
# Erase duplicates in history
export HISTCONTROL=erasedups
# Store 10k history entries
export HISTSIZE=10000
# Append to the history file when exiting instead of overwriting it
shopt -s histappend

export CLICOLOR=1
export LSCOLORS=gxfxaxdxcxegedabagacad
#export PS1='\u@\h:\w\$'
PS1="[\[\033[1;32m\]\u@\h:\w\[\033[0m] \[\033[0m\]\[\033[1;36m\]\$(git_branch)\[\033[0;33m\]\$(git_since_last_commit)\[\033[0m\]$ "

MAVEN_OPTS="-Xms512m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m"
GIT_DIFF=/Users/tim/git-diff
JMETER_HOME=/Users/tim/Applications/apache-jmeter-2.7
M2_HOME=/Users/tim/Applications/apache-maven-3.0.3
PATH=$GIT_DIFF:$M2_HOME/bin:$POSTGRES_HOME/bin:$JMETER_HOME/bin:$PATH

export MAVEN_OPTS
export GIT_DIFF
export JMETER_HOME
export M2_HOME
export EDITOR=vim
#export PAGER=less

#Postgresql configuration
alias pstart='postgres -D /usr/local/var/postgres &'

function git_diff() {
git diff --no-ext-diff -w "$@" | vim -R -
}

function git_branch {
ref=$(git symbolic-ref HEAD 2> /dev/null) || return;
echo "("${ref#refs/heads/}") ";
}

function git_since_last_commit {
now=`date +%s`;
last_commit=$(git log --pretty=format:%at -1 2> /dev/null) || return;
seconds_since_last_commit=$((now-last_commit));
minutes_since_last_commit=$((seconds_since_last_commit/60));
hours_since_last_commit=$((minutes_since_last_commit/60));
minutes_since_last_commit=$((minutes_since_last_commit%60));
echo "${hours_since_last_commit}h${minutes_since_last_commit}m ";
}

#settings for bash-completion>> brew install bash-completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
fi

# Alias maven to provide colored output.
function mvn-color() {
    command mvn "$@" 2>&1 | colorlogs maven
}

# colorize maven shell
#source ~/colorize-maven.sh

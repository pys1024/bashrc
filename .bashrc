# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#when changing directory small typos can be ignored by bash
shopt -s cdspell

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm*|rxvt*) color_prompt=yes;;
    emacs*|dumb*|screen*) color_prompt=yes;;
    *) ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    if [ -f ~/.gitprompt ]; then
        . ~/.gitprompt
        PS1='\[\033[01;35;1m\]\u\[\033[00m\]@\h:\[\033[34;1m\]\w\[\033[33;1m\]$(__git_ps1)\n\[\033[31;1m\]\$ \[\033[00m\]'
    else
        PS1='\[\033[01;35;1m\]\u\[\033[00m\]@\h:\[\033[34;1m\]\w\n\[\033[31;1m\]\$ \[\033[00m\]'
    fi
   # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -ahlF'
alias la='ls -A'
alias l='ls -CF'

export HISTCONTROL=
export HISTTIMEFORMAT="%s "
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -t 30000 -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\''|xargs -i echo $(date +%s) $(pwd) {}|awk '\''{printf "%s %s %s %s %s %s\n\nDir: %s\nElapsed Time: %d:%d:%d\nSopt Time: ",$4,$5,$6,$7,$8,$9,$2, ($1-$3)/3600,($1-$3)/3600,($1-$3)%3600/60,($1-$3)%60}'\''|sed -e '\''s;$HOME;~;'\'')$(date +%T)"'
alias alert1='notify-send --urgency=critical -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert1$//'\''|xargs -i echo $(date +%s) $(pwd) {}|awk '\''{printf "%s %s %s %s %s %s\n\nDir: %s\nElapsed Time: %d:%d:%d\nSopt Time: ",$4,$5,$6,$7,$8,$9,$2, ($1-$3)/3600,($1-$3)/3600,($1-$3)%3600/60,($1-$3)%60}'\''|sed -e '\''s;$HOME;~;'\'')$(date +%T)"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
# This function defines a 'cd' replacement function capable of keeping,
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
cd_func ()
{
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
   fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
   popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

alias cd=cd_func

# LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
# export LS_COLORS

export JAVA_HOME=~/java/jdk1.8.0_191
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
# tool dirs need to add to PATH
tooldir_home=~/bin
tooldir_homebin=~/bin/bin
tooldir_java=$JAVA_HOME/bin
tooldir_jre=$JRE_HOME/bin
tooldir_nodejs=~/workspace/node-v14.17.3-linux-x64/bin
tool_pending_pio=~/.platformio/penv/bin

# append directory in the end
for dir in ""${!tool_pending_*}""; do
  # PATH=$(eval echo '$'{$dir}:$PATH)
  # PATH=${!dir}:$PATH
  echo $PATH | grep -q -E "(^|:)${!dir}[:$]" || PATH=${PATH}:${!dir}
done
# insert directory in the begining
for dir in ""${!tooldir_*}""; do
  # PATH=$(eval echo '$'{$dir}:$PATH)
  # PATH=${!dir}:$PATH
  echo $PATH | grep -q -E "(^|:)${!dir}[:$]" || PATH=${!dir}:$PATH
done

ec_func () {
    emacsclient "$@" &> /dev/null &
}
bc_func () {
    bcompare "$@" &> /dev/null &
}
mtime () {
    local start_t=$(date +%s)
    bash -c "$*"
    local code=$?
    local end_t=$(date +%s)
    local elapsed_t=$(date -d @$[$end_t - $start_t - 8*3600] +%T)
    start_t=$(date -d @${start_t} +"%F %T")
    end_t=$(date -d @${end_t} +"%F %T")
    echo
    [ $code = 0 ] && echo -e "\E[1;32mSUCCESS\E[0m" \
                          || echo -e "\E[1;31mFAILED\E[0m"
    echo -e "\E[37mCommand Line: $*\E[0m"
    echo -e "\E[37mStart   Time: $start_t\E[0m"
    echo -e "\E[37mEnd     Time: $end_t\E[0m\n"
    echo -e "\E[1;36mElapsed Time: $elapsed_t\E[0m\n"
    local info=$(echo -e "$*\n\nStart   Time: $start_t\nEnd     Time: $end_t\nElapsed Time: $elapsed_t")
    info="$*"
    notify-send --urgency=critical -i "$([ $code = 0 ] && echo terminal || echo error)" "$info"
}
psk () {
    force=false
    pattern=$1
    if [ x"$1" = x"-f" ]; then
        force=true
        pattern=$2
    fi
    num=$(ps -ef | grep -v grep | grep -i "$pattern" | wc -l)
    if [ $num -eq 0 ]; then
        echo -e "\033[1;31mNo process matches!\033[0m"
    elif [ $num -eq 1 ]; then
        if [ x"$force" = x"true" ]; then
            ans=y
        else
            ps -ef | grep -v grep | grep -i "$pattern"
            echo
            read -p "Are you sure to kill the process? [Y/N] " ans
        fi
        if [ x"$ans" = x"y" ] || [ x"$ans" = x"Y" ]; then
            pid=$(ps -ef | grep -v grep | grep -i "$pattern" | awk '{print $2}')
            pgid=$(ps -efj | grep -v grep | grep -i "$pattern" | awk '{print $4}')
            #kill $pid
            kill -- -$pgid
            echo -e "\033[1;32mProcess($pid) is killed!\033[0m"
        fi
    else
        echo -e "\033[1;33mMore than one process matches:\033[0m"
        ps -ef | grep -v grep | grep -i "$pattern"
    fi
}
alias ec=ec_func
alias bc4=bc_func
alias psg='ps -ef | grep -v grep | grep -i'
alias rgf='rg --files -uuu | rg -i'
alias rgi='rg -i -uuu'
alias rgv='rg -vi'
alias xargs='xargs -i'
export -f psk
export -f mtime

[ -r $HOME/.cargo/env ] && . $HOME/.cargo/env

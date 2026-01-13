#-------------------------------------------------------------
# Spelling typos - highly personnal and keyboard-dependent :-)
#-------------------------------------------------------------
alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'

alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

#-------------------------------------------------------------
# The 'ls' family (this assumes you use a recent GNU ls).
#-------------------------------------------------------------
# Add colors for filetype and  human-readable sizes by default on 'ls':
alias ls='ls -h --color'
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.
alias labc='ls -lap' #alphabetical sort
alias lf="ls -l | egrep -v '^d'" # files only
alias ldir="ls -l | egrep '^d'" # directories only


# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lv --group-directories-first"
alias lm='ll |more'        #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...


# Alias's for multiple directory listing commands
#alias l='ls -CF'    # -C: list in columns, -F: classify entries (/, *, @, |, =)
#alias ls='ls -aFh --color=always' # add colors and file type extensions
#alias lr='ls -lRh' # recursive ls

alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'

# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias bd='cd "$OLDPWD"'


alias hist-grep="history | grep "

alias ps-grep="ps aux | grep "
alias top-cpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

alias lsopenports='netstat -nape --inet'


# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'

alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'



alias df='df -h'

alias cp='cp -avi'   # -a: archive (preserve mode, owner, timestamps, links), -v: verbose

alias mv='mv -vb --suffix=.org'
alias mvi='mv -vib --suffix=.org'

alias rm='rm -iv'

alias cpv='rsync -ah --info=progress2'     # copy with progress
#alias mvv='rsync -ah --remove-source-files --info=progress2'  # move w/ progress

mvv() {
  if [ "$#" -lt 2 ]; then
    echo "Usage: mvv SRC... DEST" >&2
    return 2
  fi

  local dest="${@: -1}"
  local srcs=("${@:1:$#-1}")

  # Normalize sources to match mv behavior: treat "dir/" as "dir"
  local normalized_srcs=()
  local src
  for src in "${srcs[@]}"; do
    if [[ "$src" == "/" ]]; then
      normalized_srcs+=("$src")          # don't strip "/" -> ""
    else
      normalized_srcs+=("${src%/}")      # strip trailing slashes
    fi
  done

  # Move via rsync: preserve metadata, show progress, delete source files
  rsync -ah --info=progress2 --remove-source-files "${normalized_srcs[@]}" "$dest"
  local rc=$?
  [ $rc -ne 0 ] && return $rc

  # Remove now-empty source directories (including the source dir itself)
  for src in "${normalized_srcs[@]}"; do
    [ -d "$src" ] && find "$src" -type d -empty -delete 2>/dev/null
  done
}



#alias now='date +"%Y-%m-%d_%H:%M:%S"'
# "filename-$(now).txt"
now() {
  date +"%Y-%m-%d_%H:%M:%S"
}

#alias now-std='date +"%Y-%m-%d_%H-%M-%S"'
now-std() {
  date +"%Y-%m-%d_%H-%M-%S"
}


compare-dirs-sha256() {
  local dir1="$1"
  local dir2="$2"
  local tmp1 tmp2

  tmp1=$(mktemp /tmp/hashes1.XXXXXX) || return 1
  tmp2=$(mktemp /tmp/hashes2.XXXXXX) || return 1

  find "$dir1" -type f -exec sha256sum "{}" \; | sort > "$tmp1"
  find "$dir2" -type f -exec sha256sum "{}" \; | sort > "$tmp2"

  diff "$tmp1" "$tmp2"

  rm -f "$tmp1" "$tmp2"
}

compare-dirs-md5() {
  local dir1="$1"
  local dir2="$2"
  local tmp1 tmp2

  tmp1=$(mktemp /tmp/hashes1.XXXXXX) || return 1
  tmp2=$(mktemp /tmp/hashes2.XXXXXX) || return 1

  find "$dir1" -type f -exec md5sum "{}" \; | sort > "$tmp1"
  find "$dir2" -type f -exec md5sum "{}" \; | sort > "$tmp2"

  diff "$tmp1" "$tmp2"

  rm -f "$tmp1" "$tmp2"
}


snapshot-pool() {
  if [ -z "$1" ]; then
    echo "Usage: snapshot-pool <pool_name>"
    return 1
  fi

  # Get the pool name from the argument
  POOL=$1
  SNAPSHOT_NAME="$(date +'%Y-%m-%d_%H-%M-%S')"

  # Take a recursive snapshot of all datasets in the pool
  echo "Creating recursive snapshot for all datasets in $POOL with snapshot name $SNAPSHOT_NAME"
  sudo zfs snapshot -r $POOL@$SNAPSHOT_NAME
}

list-pool-snapshots() {
  sudo zfs list -t snapshot
}



function my_ip() # Get IP adress on ethernet.
{
    MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' |
      sed -e s/addr://)
    echo ${MY_IP:-"Not connected"}
}


function extract()
{
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1     ;;
             *.tar.gz)    tar xvzf $1     ;;
             *.bz2)       bunzip2 $1      ;;
             *.rar)       unrar x $1      ;;
             *.gz)        gunzip $1       ;;
             *.tar)       tar xvf $1      ;;
             *.tbz2)      tar xvjf $1     ;;
             *.tgz)       tar xvzf $1     ;;
             *.zip)       unzip $1        ;;
             *.Z)         uncompress $1   ;;
             *.7z)        7z x $1         ;;
             *.tar.xz)    tar xJvf $1     ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

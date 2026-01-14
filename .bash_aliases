# ~/.bash_aliases
#==============================================================
# Personal aliases & functions (safe-ish defaults + helpers)
#==============================================================

#-------------------------------------------------------------
# Spelling typos - highly personal and keyboard-dependent :-)
#-------------------------------------------------------------
alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'

#-------------------------------------------------------------
# Safer defaults (interactive shells only)
#-------------------------------------------------------------
if [[ $- == *i* ]]; then
  alias mkdir='mkdir -p'
  alias ps='ps auxf'
  alias ping='ping -c 10'
  alias less='less -R'

  # Safer / more informative file ops (interactive only)
  alias cp='cp -avi'                  # archive, verbose, interactive
  alias mv='mv -vb --suffix=.org'     # verbose, backups w/ suffix
  alias mvi='mv -vib --suffix=.org'   # verbose, interactive, backups w/ suffix
  alias rm='rm -iv'                   # interactive, verbose

  # Disk usage / filesystem
  alias du='du -h'                    # human-readable
  alias df='df -hT'                   # human-readable + type
fi

#-------------------------------------------------------------
# The 'ls' family (assumes GNU ls)
#-------------------------------------------------------------
# Color + human-readable sizes by default
alias ls='ls -h --color=auto'

alias lx='ls -lXB'                    # sort by extension
alias lk='ls -lSr'                    # sort by size, biggest last
alias lt='ls -ltr'                    # sort by date, most recent last
alias lc='ls -ltcr'                   # sort by ctime, most recent last
alias lu='ls -ltur'                   # sort by atime, most recent last
alias labc='ls -lap'                  # alphabetical (includes hidden except . and ..)
alias lf="ls -l | egrep -v '^d'"      # files only (non-dirs)
alias ldir="ls -l | egrep '^d'"       # directories only

# Ubiquitous 'll': directories first, alphanumeric sorting
alias ll="ls -lv --group-directories-first"
alias lm='ll | more'
alias lr='ll -R'
alias la='ll -A'

# Tree variants (avoid redefining "tree" twice)
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'

#-------------------------------------------------------------
# Navigation shortcuts
#-------------------------------------------------------------
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias bd='cd "$OLDPWD"'

#-------------------------------------------------------------
# Process / history helpers
#-------------------------------------------------------------
alias hist-grep='history | grep -i'
alias ps-grep='ps aux | grep -i'
alias top-cpu='/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10'

#-------------------------------------------------------------
# Networking helpers
#-------------------------------------------------------------
alias ls-openports='netstat -nape --inet'

#-------------------------------------------------------------
# Disk space helpers
#-------------------------------------------------------------
alias diskspace='du -S | sort -n -r | more'
alias folders='du --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias mountedinfo='df -hT'

#-------------------------------------------------------------
# Archive helpers
#-------------------------------------------------------------
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'

alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

extract() {
  local f="$1"
  if [[ -z "$f" ]]; then
    echo "Usage: extract <archive-file>" >&2
    return 2
  fi
  if [[ ! -f "$f" ]]; then
    echo "'$f' is not a valid file" >&2
    return 1
  fi

  case "$f" in
    *.tar.bz2) tar xvjf "$f" ;;
    *.tar.gz)  tar xvzf "$f" ;;
    *.bz2)     bunzip2 "$f" ;;
    *.rar)     unrar x "$f" ;;
    *.gz)      gunzip "$f" ;;
    *.tar)     tar xvf "$f" ;;
    *.tbz2)    tar xvjf "$f" ;;
    *.tgz)     tar xvzf "$f" ;;
    *.zip)     unzip "$f" ;;
    *.Z)       uncompress "$f" ;;
    *.7z)      7z x "$f" ;;
    *.tar.xz)  tar xJvf "$f" ;;
    *)         echo "'$f' cannot be extracted via extract" >&2; return 2 ;;
  esac
}

#-------------------------------------------------------------
# Copy / move with progress (rsync-based)
#-------------------------------------------------------------
alias cpv='rsync -ah --info=progress2'   # copy with progress

mvv() {
  if [[ "$#" -lt 2 ]]; then
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
      normalized_srcs+=("$src")
    else
      normalized_srcs+=("${src%/}")
    fi
  done

  # Move via rsync: preserve metadata, show progress, delete source files
  rsync -ah --info=progress2 --remove-source-files "${normalized_srcs[@]}" "$dest"
  local rc=$?
  [[ $rc -ne 0 ]] && return $rc

  # Remove now-empty source directories
  for src in "${normalized_srcs[@]}"; do
    [[ -d "$src" ]] && find "$src" -type d -empty -delete 2>/dev/null
  done
}

#-------------------------------------------------------------
# Timestamp helpers
#-------------------------------------------------------------
now() { date +"%Y-%m-%d_%H-%M-%S"; }
now-std() { date +"%Y-%m-%d_%H:%M:%S"; }


#-------------------------------------------------------------
# Directory comparison helpers (hash-based)
# Compares content + paths (same relative paths, same content)
#-------------------------------------------------------------
compare-dirs-sha256() {
  local dir1="$1" dir2="$2"
  local tmp1 tmp2

  if [[ -z "$dir1" || -z "$dir2" ]]; then
    echo "Usage: compare-dirs-sha256 <dir1> <dir2>" >&2
    return 2
  fi

  tmp1=$(mktemp /tmp/hashes1.XXXXXX) || return 1
  tmp2=$(mktemp /tmp/hashes2.XXXXXX) || { rm -f "$tmp1"; return 1; }

  find "$dir1" -type f -exec sha256sum "{}" \; | sort > "$tmp1"
  find "$dir2" -type f -exec sha256sum "{}" \; | sort > "$tmp2"

  diff "$tmp1" "$tmp2"
  local rc=$?

  rm -f "$tmp1" "$tmp2"
  return $rc
}

compare-dirs-md5() {
  local dir1="$1" dir2="$2"
  local tmp1 tmp2

  if [[ -z "$dir1" || -z "$dir2" ]]; then
    echo "Usage: compare-dirs-md5 <dir1> <dir2>" >&2
    return 2
  fi

  tmp1=$(mktemp /tmp/hashes1.XXXXXX) || return 1
  tmp2=$(mktemp /tmp/hashes2.XXXXXX) || { rm -f "$tmp1"; return 1; }

  find "$dir1" -type f -exec md5sum "{}" \; | sort > "$tmp1"
  find "$dir2" -type f -exec md5sum "{}" \; | sort > "$tmp2"

  diff "$tmp1" "$tmp2"
  local rc=$?

  rm -f "$tmp1" "$tmp2"
  return $rc
}

#-------------------------------------------------------------
# ZFS helpers
#-------------------------------------------------------------
snapshot-pool() {
  if [[ -z "$1" ]]; then
    echo "Usage: snapshot-pool <pool_name>" >&2
    return 1
  fi

  local POOL="$1"
  local SNAPSHOT_NAME
  SNAPSHOT_NAME="$(date +'%Y-%m-%d_%H-%M-%S')"

  echo "Creating recursive snapshot for all datasets in $POOL with snapshot name $SNAPSHOT_NAME"
  sudo zfs snapshot -r "$POOL@$SNAPSHOT_NAME"
}

list-pool-snapshots() {
  sudo zfs list -t snapshot
}

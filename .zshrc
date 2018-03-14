# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=/home/sindre/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="spaceship"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting emacs sudo)

source $ZSH/oh-my-zsh.sh

#Add ssh-keys to agent
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
    eval `ssh-agent`
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l | grep "The agent has no identities" && ssh-add

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias connect_ha="ssh -L 8123:localhost:8123 sindre@sindrehansen.no -p 2223"
alias cdb="cd ~/Documents/Blueye/"
alias cdn="cd ~/Documents/NTNU/"
alias cdw="cd ~/Documents/website/"
alias o="xdg-open"
alias nhere="nautilus . &"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

if [ -n "$INSIDE_EMACS" ]; then
  #  export EDITOR=emacsclient
    unset zle_bracketed_paste  # This line
fi

#Map caps lock as extra ctrl key
setxkbmap -option ctrl:nocaps

#Disable screen powersaving
xset s off

export GRAPHVIZ_DOT=/usr/bin/dot

#ROS
source /opt/ros/kinetic/setup.zsh
source $(find ~/catkin/*/devel -name setup.zsh)

#Blueye-ROS
export ROS_SENSOR_IMU=0
export ROS_SENSOR_DEPTH=0
export ROS_SENSOR_HUMIDITY_UPPER=0
export ROS_CAMERA_CONTROL=0
export ROS_UDP_TRANSFER=0


function ck (){
    wd=$(pwd)
    ws_options=($(find ~/catkin/* -maxdepth 0 -printf "%f "))
    op_options=("Make" "Test" "Clean")

    PS3='Workspace: '
    select ws in "${ws_options[@]}" "Quit"; do
        if (($REPLY== 1 + ${#ws_options[@]})); then
            return
        elif (( $REPLY > 0 && $REPLY <= ${#ws_options[@]})) ; then
            break
        else
            echo "Invalid option. Try another"
        fi
    done

    cd ~/catkin/$ws

    PS3='Operation: '
    select op in "${op_options[@]}"
    do
        case $op in
            "Make")
                catkin_make -DCMAKE_CXX_FLAGS=-Wall -DCMAKE_C_FLAGS=-Wallm
                break
                ;;
            "Test")
                catkin_make tests
                catkin_make run_tests
                break
                ;;
            "Clean")
                rm -rf build/ devel/
                catkin_make -DCMAKE_CXX_FLAGS=-Wall -DCMAKE_C_FLAGS=-Wall
                break
                ;;
            *) echo invalid option;;
        esac
    done
    source ~/catkin/$ws/devel/setup.zsh
    cd $wd
}

# Copy like emacs
x-copy-region-as-kill () {
  zle copy-region-as-kill
  print -rn $CUTBUFFER | xsel -i -b
}
zle -N x-copy-region-as-kill
x-kill-region () {
  zle kill-region
  print -rn $CUTBUFFER | xsel -i -b
}
zle -N x-kill-region
x-yank () {
  CUTBUFFER=$(xsel -o -b </dev/null)
  zle yank
}
zle -N x-yank
bindkey -e '\ew' x-copy-region-as-kill
bindkey -e '^W' x-kill-region
bindkey -e '^Y' x-yank


function copy_kboot_ipk() {
    echo "Downloading from Beast:"
    scp blueye@192.168.100.10://data/wsu/OpenWrt-SDK-ar71xx-nand_gcc-5.3.0_musl-1.1.16.Linux-x86_64/bin/ar71xx/packages/base/kboot-flasher_1_ar71xx.ipk /tmp/kboot-flasher.ipk
    echo "Uploading to WSU:"
    scp /tmp/kboot-flasher.ipk root@192.168.1.1:/root/kboot-flasher_1_ar71xx.ipk
}
# Extract files
ex() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2) tar xvjf $1;;
            *.tar.gz) tar xvzf $1;;
            *.tar.xz) tar xvJf $1;;
            *.tar.lzma) tar --lzma xvf $1;;
            *.bz2) bunzip $1;;
            *.rar) unrar $1;;
            *.gz) gunzip $1;;
            *.tar) tar xvf $1;;
            *.tbz2) tar xvjf $1;;
            *.tgz) tar xvzf $1;;
            *.zip) unzip $1;;
            *.Z) uncompress $1;;
            *.7z) 7z x $1;;
            *) echo "'$1' cannot be extracted via >ex<";;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

#Python virtual enviroment
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh

export PATH="$PATH:/opt/etcher-cli"
export ARMGCC_DIR=/usr
export KL82Z_SDK_DIR=/home/sindre/Documents/Blueye/SDK_2.3.0_MKL82Z_FreeRTOS

# added by travis gem
[ -f /home/sindre/.travis/travis.sh ] && source /home/sindre/.travis/travis.sh

# Secrets
source $HOME/.secrets

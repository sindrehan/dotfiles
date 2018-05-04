# Path to your oh-my-zsh installation.
  export ZSH=/home/sindre/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="spaceship"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting emacs thefuck globalias)

source $ZSH/oh-my-zsh.sh

#Add ssh-keys to agent
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
    eval `ssh-agent`
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l | grep "The agent has no identities" && ssh-add

alias cdb="cd ~/Documents/Blueye/"
alias cdn="cd ~/Documents/NTNU/"
alias cdw="cd ~/Documents/website/"
alias o="xdg-open"
alias thu="thunar . &"
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

function rnm(){
    echo "Restarting nm-applet"
    pkill nm-applet
    nohup nm-applet &
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

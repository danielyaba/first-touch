#!/bin/bash


ERROR_LOG_FILE=/tmp/first-touch-errors.log
LOG_FILE=/tmp/first-touch-output.log


install_oh-my-zsh() {
  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  elif command -v wget >/dev/null 2>&1; then
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
  else
    echo "Error: Neither curl nor wget is installed. Please install one of them." > $ERROR_LOG_FILE
    exit 1
  fi

  echo #### USEFUL ALIASES ### >> ~/.zshrc
  echo "alias install='brew install'" >> ~/.zshrc
  echo "alias uninstall='brew uninstall'" >> ~/.zshrc
  echo "alias refresh='source ~/.zshrc'" >> ~/.zshrc
  echo "alias ll='ls -lha'" >> ~/.zshrc
  echo "" >> ~/.zshrc
}

install_bat() {
  $1 bat
  echo "alias cat='bat --paging never --theme DarkNeon'" >> ~/.zshrc
}

install_docker() {
  $1 docker
  echo #### DOCKER ALIASES ### >> ~/.zshrc
  echo "alias dockerrm='docker rm $(docker ps -aq)'"
  echo "alias dockerstp='docker stop $(docker ps -aq)'"
  echo "alias dockerrmi='docker rmi -f $(docker images -q) && docker images'"
  echo "" >> ~/.zshrc
}

check_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "brew" > $LOG_FILE
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      if [[ "$ID" == "ubuntu" ]]; then
        echo "apt-get" > $LOG_FILE
      else
        echo "Unsupported Linux distribution: $ID"
        return 1
      fi
    else
      echo "Unsupported Linux distribution"exit 1
      return 1
    fi
  else
    echo "Unsupported OS: $OSTYPE"
    return 1
  fi
}


spinner() {
  local STEPS=("${@:1:$# / 2}")
  local CMDS=("${@:$# / 2 + 1}")

  local FRAME=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  local FRAME_INTERVAL=0.1
  local step=0

  tput civis

  while [ "$step" -lt "${#CMDS[@]}" ]; do
    ${CMDS[$step]} 2> $ERROR_LOG_FILE 1> $LOG_FILE &
    pid=$!

    while ps -p $pid &>/dev/null; do
      echo -ne "\\r[   ] ${STEPS[$step]}"

      for k in "${!FRAME[@]}"; do
        echo -ne "\\r[ ${FRAME[k]} ]"
        sleep $FRAME_INTERVAL
      done
    done

    wait $pid
    status=$?
    
    if [ $status -eq 0 ]; then
        echo -ne "\\r[ ✔ ] ${STEPS[$step]}\\n"
    else
        echo -ne "\\r[ X ] ${STEPS[$step]}\\n"
        output=$(cat $ERROR_LOG_FILE)
        echo -e "$output"
        rm -f $ERROR_LOG_FILE
        tput cnorm
        exit 1
    fi

    step=$((step + 1))
    rm -f $ERROR_LOG_FILE
  
  done

  tput cnorm
}

echo "==============================================================="
echo "=                                                             ="
echo "=               First-Touch Installation Script               ="
echo "=       Prepare your new workstations in a few minutes        ="
echo "=                                                             ="
echo "==============================================================="
echo ""

spinner "checking OS package manager" check_os
package_manager=$(cat $LOG_FILE)
echo "Your OS package manager is $package_manager" 

STEPS=(
  # "installing Oh-My-Zsh terminal"
  "Installing yq"
  "installing jq"
  # "installing VSCode"
  # "installing bat"
  # "installing kubectx & kubens"
  # "installing kubectl"
  # "installing helm"
  # "installing git"
  # "installing gcloud"
  # "installing docker"
  # "installing Python3"
)

CMDS=(
  # "$package_manager install oh-my-zsh"
  "$package_manager install yq"
  "$package_manager install jq"
  # "$package_manager  visual-studio-code"
  # "install_bat $package_manager"
  # "$package_manager install install visual-studio-code"
  # "$package_manager install kubectx"
  # "$package_manager install kubectl"
  # "$package_manager install helm"
  # "$package_manager install git"
  # "$package_manager gcloud"
  # "install_docker $package_manager"
  # "$package_manager python3"
)

spinner "${STEPS[@]}" "${CMDS[@]}"

echo ""
echo "First-Touch installation script is finished"
echo "Thank you for using First-Touch. See you on your next workstation!"
echo ""






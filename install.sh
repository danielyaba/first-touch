#!/bin/bash

ERROR_LOG_FILE=/tmp/first-touch-errors.log
LOG_FILE=/tmp/first-touch-output.log

# check_status () {
#   if [[ $1 -eq 0 ]]; then
#     echo "Successfully installed $2"
#     echo "==============================================================="
#   else   
#     echo "1: $1"
#     echo "Error installing $2 libraries."
#     echo "Reason: $(cat $ERROR_LOG_FILE)"
#     echo "Procceeding installing other utilities..."
#     echo "==============================================================="
#   fi
# }

install_tool() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install $1 2> $ERROR_LOG_FILE
    check_status
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      if [[ "$ID" == "ubuntu" ]]; then
        sudo apt-get update
        sudo apt-get install -y $1 2> $ERROR_LOG_FILE
        check_status
      else
        echo "Unsupported Linux distribution: $ID"
      fi
    else
      echo "Unsupported Linux distribution"
    fi
  else
    echo "Unsupported OS: $OSTYPE"
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

# install oh-my-zsh terminal
# echo "Installing Oh-My-Zsh..."
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# if [[ $0 -eq 0 ]]; then
#   echo "Error installing jq library. Reason: $(cat $ERROR_LOG_FILE)"
#   exit 1
# fi
# echo "Installed Oh-My-Zsh successfully"

# echo "### Useful aliases ###" > ~/.zshrc

# install jq
# TOOL=jq
# echo "installing $TOOL..."
# brew install $TOOL 2> $ERROR_LOG_FILE
# check_status $? $TOOL


# # install yq
# TOOL=yq
# echo "Installing $TOOL..."
# brew install $TOOL 2> $ERROR_LOG_FILE
# check_status $? $TOOL

# # install bat
# TOOL=bat
# brew install $TOOLS -y 2> $ERROR_LOG_FILE
# check_status $? $TOOL
# echo "Changing cat to bat with alias in ~/.zshrc file"
# sed -i '' '/### Useful aliases ###/a\
# alias cat='\''bat --paging never --theme DarkNeon'\''' ~/.zshrc
# echo "Successfully added bat alias in ~/.zshrc file"

# # install VSCode
# TOOL=visual-studio-code
# brew install $TOOLS -y 2> $ERROR_LOG_FILE
# check_status $? $TOOL


# install gcloud (including kubectl and Python)
# curl https://sdk.cloud.google.com > install.sh
# bash install.sh --disable-prompts

# install git
# brew intall git -y 2> $ERROR_LOG_FILE

# install kubens & kubectx
# brew install kubectx -y 2> $ERROR_LOG_FILE

# install GKE-Private-Tunneller (Access private GKE clusters)
# git clone https://github.com/danielyaba/gke-private-tunneller.git
# cp gke-private-tunneller/gke_tunnel gke-private-tunneller/disable_gke_tunnel /usr/local/bin/
# chmod +x /usr/local/bin/gke_tunnel /usr/local/bin/disable_gke_tunnel
# rm -rf gke-private-tunneller/

STEPS=(
  "Installing yq"
  "install jq"
  "installing VSCode"
)
CMDS=(
  "brew install yq"
  "brew install jq"
  "brew install visual-studio-code"
)

spinner "${STEPS[@]}" "${CMDS[@]}"

echo ""
echo "First-Touch installation script is finished"
echo "Thank you for using First-Touch. See you on your next workstation!"
echo ""






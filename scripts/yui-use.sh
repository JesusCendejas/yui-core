#!/usr/bin/env bash

# Copyright 2017 Yui AI Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# this script is for the Mark 1 and Picroft units

user=$( whoami )
#Build being changed to
change_to=${1}
#path to yui-core checkout
path=${2:-"${HOME}/yui-core"}
#currently installed package
current_pkg=$( cat /etc/apt/sources.list.d/repo.yui.ai.list )
stable_pkg="deb http://repo.yui.ai/repos/apt/debian debian main"
unstable_pkg="deb http://repo.yui.ai/repos/apt/debian debian-unstable main"

mark_1_package_list="yui-mark-1 yui-core yui-wifi-setup"
picroft_package_list="yui-picroft yui-core yui-wifi-setup"

# Determine the platform
yui_platform="null"
if [[ -r /etc/yui/yui.conf ]] ; then
    yui_platform=$( jq -r '.enclosure.platform' /etc/yui/yui.conf )
else
    if [[ "$( hostname )" == "picroft" ]] ; then
        yui_platform="picroft"
    elif [[ "$( hostname )" =~ "mark_1" ]] ; then
        yui_platform="mycroft_mark_1"
    fi
fi

function service_ctl() {
    service=${1}
    action=${2}
    sudo /etc/init.d/${service} ${action}
}

function stop_yui() {
    service_ctl yui-audio stop
    service_ctl yui-skills stop
    service_ctl yui-speech-client stop
    service_ctl yui-enclosure-client stop
    service_ctl yui-admin-service stop
    service_ctl yui-messagebus stop
}

function start_yui() {
    service_ctl yui-messagebus start
    service_ctl yui-enclosure-client start
    service_ctl yui-audio start
    service_ctl yui-skills start
    service_ctl yui-speech-client start
    service_ctl yui-admin-service start
}

function restart_yui() {
    service_ctl yui-messagebus restart
    service_ctl yui-audio restart
    service_ctl yui-skills restart
    service_ctl yui-speech-client restart
    service_ctl yui-enclosure-client restart
    service_ctl yui-admin-service restart
}

#Changes init scripts back to the original versions
function restore_init_scripts() {
    # stop running Yui services
    stop_yui

    # swap back to original service scripts
    sudo sh -c 'cat /etc/init.d/yui-audio.original > /etc/init.d/yui-audio'
    sudo sh -c 'cat /etc/init.d/yui-enclosure-client.original > /etc/init.d/yui-enclosure-client'
    sudo sh -c 'cat /etc/init.d/yui-messagebus.original > /etc/init.d/yui-messagebus'
    sudo sh -c 'cat /etc/init.d/yui-skills.original > /etc/init.d/yui-skills'
    sudo sh -c 'cat /etc/init.d/yui-speech-client.original > /etc/init.d/yui-speech-client'
    sudo sh -c 'cat /etc/init.d/yui-admin-service.original > /etc/init.d/yui-admin-service'
    sudo rm /etc/init.d/*.original
    chown yui:yui /home/yui/.yui/identity/identity2.json
    sudo chown -R yui:yui /var/log/yui*
    sudo chown -R yui:yui /tmp/yui
    sudo chown -R yui:yui /var/run/yui*
    sudo chown -R yui:yui /opt/yui
    sudo chown yui:yui /var/tmp/mycroft_web_cache.json

    # reload daemon scripts
    sudo systemctl daemon-reload

    # start services back up
    start_yui
}

function github_init_scripts() {
    if [ ! -f /etc/init.d/yui-skills.original ] ; then
        stop_yui

        # save original scripts
        sudo sh -c 'cat /etc/init.d/yui-audio > /etc/init.d/yui-audio.original'
        sudo sh -c 'cat /etc/init.d/yui-enclosure-client > /etc/init.d/yui-enclosure-client.original'
        sudo sh -c 'cat /etc/init.d/yui-messagebus > /etc/init.d/yui-messagebus.original'
        sudo sh -c 'cat /etc/init.d/yui-skills > /etc/init.d/yui-skills.original'
        sudo sh -c 'cat /etc/init.d/yui-speech-client > /etc/init.d/yui-speech-client.original'
        sudo sh -c 'cat /etc/init.d/yui-admin-service > /etc/init.d/yui-admin-service.original'

        # switch to point a github install and run as the current user
        # TODO Verify all of these
        sudo sed -i 's_.*SCRIPT=.*_SCRIPT="'${path}'/start-yui.sh audio"_g' /etc/init.d/yui-audio
        sudo sed -i 's_.*RUNAS=.*_RUNAS='${user}'_g' /etc/init.d/yui-audio
        sudo sed -i 's_stop() {_stop() {\nPID=$(ps ax | grep yui/audio/ | awk '"'NR==1{print \$1; exit}'"')\necho "${PID}" > "$PIDFILE"_g' /etc/init.d/yui-audio

        sudo sed -i 's_.*SCRIPT=.*_SCRIPT="'${path}'/start-yui.sh enclosure"_g' /etc/init.d/yui-enclosure-client
        sudo sed -i 's_.*RUNAS=.*_RUNAS='${user}'_g' /etc/init.d/yui-enclosure-client
        sudo sed -i 's_stop() {_stop() {\nPID=$(ps ax | grep yui/client/enclosure/ | awk '"'NR==1{print \$1; exit}'"')\necho "${PID}" > "$PIDFILE"_g' /etc/init.d/yui-enclosure-client

        sudo sed -i 's_.*SCRIPT=.*_SCRIPT="'${path}'/start-yui.sh bus"_g' /etc/init.d/yui-messagebus
        sudo sed -i 's_.*RUNAS=.*_RUNAS='${user}'_g' /etc/init.d/yui-messagebus
        sudo sed -i 's_stop() {_stop() {\nPID=$(ps ax | grep yui/messagebus/ | awk '"'NR==1{print \$1; exit}'"')\necho "${PID}" > "$PIDFILE"_g' /etc/init.d/yui-messagebus

        sudo sed -i 's_.*SCRIPT=.*_SCRIPT="'${path}'/start-yui.sh skills"_g' /etc/init.d/yui-skills
        sudo sed -i 's_.*RUNAS=.*_RUNAS='${user}'_g' /etc/init.d/yui-skills
        sudo sed -i 's_stop() {_stop() {\nPID=$(ps ax | grep yui/skills/ | awk '"'NR==1{print \$1; exit}'"')\necho "${PID}" > "$PIDFILE"_g' /etc/init.d/yui-skills

        sudo sed -i 's_.*SCRIPT=.*_SCRIPT="'${path}'/start-yui.sh voice"_g' /etc/init.d/yui-speech-client
        sudo sed -i 's_.*RUNAS=.*_RUNAS='${user}'_g' /etc/init.d/yui-speech-client
        sudo sed -i 's_stop() {_stop() {\nPID=$(ps ax | grep yui/client/speech | awk '"'NR==1{print \$1; exit}'"')\necho "${PID}" > "$PIDFILE"_g' /etc/init.d/yui-speech-client

        # soft link the current user to the yui user's identity folder
        chown ${user}:${user} /home/yui/.yui/identity/identity2.json
        if [ ! -e ${HOME}/.yui ] ; then
            mkdir ${HOME}/.yui
        fi
        if [ ! -e ${HOME}/.yui/identity ] ; then
            sudo ln -s /home/yui/.yui/identity ${HOME}/.yui/
        fi

        sudo chown -R ${user}:${user} /var/log/yui*
        sudo chown -R ${user}:${user} /var/run/yui*
        sudo chown -R ${user}:${user} /tmp/yui
        sudo chown -R ${user}:${user} /var/tmp/mycroft_web_cache.json

        # reload daemon scripts
        sudo systemctl daemon-reload

        restart_mycroft
    fi
}

function invoke_apt() {
    if [ ${mycroft_platform} == "mycroft_mark_1" ] ; then
        echo "${1}ing the mycroft-mark-1 metapackage..."
        sudo apt-get ${1} mycroft-mark-1 -y
    elif [ ${mycroft_platform} == "picroft" ] ; then
        echo "${1}ing the mycroft-picroft metapackage..."
        sudo apt-get ${1} mycroft-picroft -y
    else
        # for unknown, just update the generic package
        echo "${1}ing the generic yui-core package..."
        sudo apt-get ${1} yui-core -y
    fi
}

function remove_all() {
    if [ ${mycroft_platform} == "mycroft_mark_1" ] ; then
        echo "Removing the mycroft mark-1 packages..."
        sudo apt-get remove ${mark_1_package_list} -y
    elif [ ${mycroft_platform} == "picroft" ] ; then
        echo "Removing the picroft packages..."
        sudo apt-get remove ${picroft_package_list} -y
    else
        # for unknown, just update the generic package
        echo "Removing the generic yui-core package..."
        sudo apt-get remove yui-core -y
    fi
}

function change_build() {
    build=${1}
    sudo sh -c 'echo '"${build}"' > /etc/apt/sources.list.d/repo.yui.ai.list'
    sudo apt-get update

    invoke_apt install
}

function stable_to_unstable_server() {
    identity_path=/home/yui/.yui/identity/
    conf_path=/home/yui/.yui/

    # check if on stable (home-test.yui.ai) already
    cmp --silent ${conf_path}/yui.conf ${conf_path}/yui.conf.unstable
    if [ $? -eq 0 ] ; then
       echo "Already set to use the home-test.yui.ai server"
       return
    fi

    # point to test server
    echo "Changing yui.conf to point to test server api-test.mycroft.ai"
    if [ -f ${conf_path}yui.conf ] ; then
        cp ${conf_path}yui.conf ${conf_path}yui.conf.stable
    else
        echo "could not find yui.conf, was it deleted?"
    fi
    if [ -f ${conf_path}yui.conf.unstable ] ; then
        cp ${conf_path}yui.conf.unstable ${conf_path}yui.conf
    else
        rm -r ${conf_path}yui.conf
        echo '{"server": {"url":"https://api-test.mycroft.ai", "version":"v1", "update":true, "metrics":false }}' $( cat ${conf_path}yui.conf.stable ) | jq -s add > ${conf_path}yui.conf
    fi

    # saving identity2.json to stable state
    echo "Pointing identity2.json to unstable and saving to identity2.json.stable"
    if [ -f ${identity_path}identity2.json ] ; then
        mv ${identity_path}identity2.json ${identity_path}identity2.json.stable
    fi
    if [ -f /home/yui/.yui/identity/identity2.json.unstable ] ; then
        cp ${identity_path}identity2.json.unstable ${identity_path}identity2.json
    else
        echo "NOTE:  This seems to be your first time switching to unstable. You will need to go to home-test.yui.ai to pair on unstable."
    fi

    restart_yui
    echo "Set to use the home-test.mycroft.ai server!"
}

function unstable_to_stable_server() {
    # switching from unstable -> stable
    identity_path=/home/yui/.yui/identity/
    conf_path=/home/yui/.yui/

    # check if on stable (home.yui.ai) already
    cmp --silent ${conf_path}/yui.conf ${conf_path}/yui.conf.stable
    if [ $? -eq 0 ] ; then
        echo "Already set to use the home.yui.ai server"
        return
    fi

    # point api to production server
    echo "Changing yui.conf to point to production server api.mycroft.ai"
    if [ -f ${conf_path}yui.conf ] ; then
        echo '{"server": {"url":"https://api-test.mycroft.ai", "version":"v1", "update":true, "metrics":false }}' $( cat ${conf_path}yui.conf ) | jq -s add > ${conf_path}yui.conf.unstable
    else
        echo "could not find yui.conf, was it deleted?"
    fi
    if [ -f ${conf_path}yui.conf.stable ] ; then
        cp ${conf_path}yui.conf.stable ${conf_path}yui.conf
    else
        echo "ERROR:  Could not find yui.conf.stable, was it deleted?, an easy fix would be to copy yui.conf.unstable to yui.conf but remove the server field"
    fi

    # saving identity2.json into unstable state, then copying identity2.json.stable to identity2.json
    echo "Pointing identity2.json to unstable and saving to identity2.json.unstable"
    if [ -f ${identity_path}identity2.json ] ; then
        mv ${identity_path}identity2.json ${identity_path}identity2.json.unstable
    fi
    if [ -f ${identity_path}identity2.json.stable ] ; then
        cp ${identity_path}identity2.json.stable ${identity_path}identity2.json
    else
        echo "Can not find identity2.json.stable, was it deleted? You may need to repair at home.yui.ai"
    fi

    restart_mycroft
    echo "Set to use the home.yui.ai server!"
}

if [ "${change_to}" == "unstable" ] ; then
    # make sure user is running as sudo first
    if [ "$EUID" -ne 0 ] ; then
        echo "Please run with sudo"
        exit
    fi

    echo "Switching to unstable build..."
    if [ "${current_pkg}" == "${stable_pkg}" ] ; then
        change_build "${unstable_pkg}"
    else
        echo "already on unstable"
    fi

    if [ -f /etc/init.d/yui-skills.original ] ; then
        restore_init_scripts
        # Reboot since the audio input won't work for some reason
        sudo reboot
    fi
elif [ "${change_to}" == "stable" ] ; then
    # make sure user is running as sudo first
    if [ "$EUID" -ne 0 ] ; then
        echo "Please run with sudo"
        exit
    fi

        echo "Switching to stable build..."
        if [ "${current_pkg}" == "${unstable_pkg}" ] ; then
            # Need to remove the package to make sure upgrade happens due to
            # difference in stable/unstable to package numbering schemes
            remove_all

            change_build "${stable_pkg}"
        else
            echo "already on stable"
        fi

        if [ -f /etc/init.d/yui-skills.original ] ; then
            restore_init_scripts
            sudo chmod +x /etc/cron.hourly/yui-core # Enable updates

            # Reboot since the audio input won't work for some reason
            sudo reboot
        fi

elif [ "${change_to}" == "github" ] ; then
    echo "Switching to github..."
    if [ ! -d ${path} ] ; then
        mkdir --parents "${path}"
        cd "${path}"
        cd ..
        git clone https://github.com/MycroftAI/mycroft-core.git "${path}"
    fi

    sudo chmod -x /etc/cron.hourly/yui-core # Disable updates

    if [ -d ${path} ] ; then
        if  [ -f /usr/local/bin/mimic ] ; then
            echo "Mimic file exists"
            mimic_flag="-sm"
        else
            echo "file doesn't exist"
            mimic_flag=""
        fi
        cd ${path}
        # Build the dev environment
        ${path}/dev_setup.sh --allow-root ${mimic_flag}

        # Switch init scripts to start the github version
        github_init_scripts
    else
        echo "repository does not exist"
    fi
    # For some reason precise won't trigger until after a reboot
    echo "Rebooting..."
    sudo reboot
elif [ "${change_to}" == "home" ] ; then
    # make sure user is running as sudo first
    if [ "$EUID" -ne 0 ] ; then
        echo "Please run with sudo"
        exit
    fi
    unstable_to_stable_server
elif [ "${change_to}" == "home-test" ] ; then
    # make sure user is running as sudo first
    if [ "$EUID" -ne 0 ] ; then
        echo "Please run with sudo"
        exit
    fi
    stable_to_unstable_server
else
    echo "usage: yui-use.sh [stable | unstable | home | home-test | github [<path>]]"
    echo "Switch between yui-core install methods"
    echo
    echo "Options:"
    echo "  stable           switch to the current debian package"
    echo "  unstable         switch to the unstable debian package"
    echo "  github [<path>]  switch to the yui-core/dev github repo"
    echo
    echo "  home-test        switch to the test backend (home-test.yui.ai)"
    echo "  home             switch to the main backend (home.yui.ai)"
    echo
    echo "Params:"
    echo "  <path>  default for github installs is /home/<user>/yui-core"
    echo
    echo "Examples:"
    echo "  yui-use.sh stable"
    echo "  yui-use.sh unstable"
    echo "  yui-use.sh home"
    echo "  yui-use.sh home-test"
    echo "  yui-use.sh github"
    echo "  yui-use.sh github /home/bill/projects/yui/custom"
fi

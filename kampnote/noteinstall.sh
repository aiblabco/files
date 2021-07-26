#!/bin/bash

function notExistsFile() {
    if test -f "$1"; then
        return 1
    else
        return 0
    fi
}
function existsFile() {
    if test -f "$1"; then
        return 0
    else
        return 1
    fi
}

function notExistsFolder() {
    if test -d "$1"; then
        return 1
    else
        return 0
    fi
}

function existsFolder() {
    if test -d "$1"; then
        return 0
    else
        return 1
    fi
}

function notInstalledPackage() {
    if dpkg -s "$1" > /dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

function notExistsUser() {
    if id "$1" &> /dev/null; then
        return 1
    else
        return 0
    fi
}



if systemctl status kampnote.service > /dev/null 2>&1; then
    echo "previous removed kampnote service"
    sudo systemctl stop kampnote.service
    sudo systemctl disable kampnote.service
fi

if notInstalledPackage 'libcudnn8'; then
    sudo apt-get install -y libcudnn8=8.0.5.39-1+cuda11.0
    echo "installed libcudnn8"
else
    echo "founded libcudnn8 package"
fi
if notExistsFile '/etc/apt/sources.list.d/nodesource.list'; then
    echo "nodejs deb downloading..."
    curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
    echo "installed nodejs deb"
else
    echo "founded nodejs deb"
fi
if notInstalledPackage 'git'; then
    sudo apt-get install -y git
    echo "installed git package"
else
    echo "founded git package"
fi
if notInstalledPackage 'nodejs'; then
    sudo apt-get install -y nodejs
    echo "installed nodejs package"
else
    echo "founded nodejs package"
fi
if notExistsFolder '/usr/lib/node_modules/configurable-http-proxy'; then
    sudo npm install --cache /tmp/empty-cache -g configurable-http-proxy
    echo "installed npm configurable-http-proxy"
else
    echo "founded npm configurable-http-proxy"
fi

if sudo grep -q 'kampnote' /etc/sudoers; then
    echo 'kampnote sudoers exists'
else
    sudo chmod 0640 /etc/sudoers
    echo 'kampnote ALL=(%users) NOPASSWD: ALL' | sudo tee -a /etc/sudoers
    sudo chmod 0440 /etc/sudoers
    echo 'added kampnote sudoers'
fi

if notExistsUser 'kampnote'; then
    sudo useradd -m -s /bin/bash -G shadow -p $(openssl passwd -1 kampnote) kampnote
    echo 'user added kampnote'
else
    echo 'founded user kampnote'
fi

if notExistsUser 'kampuser'; then
    sudo useradd -m -s /bin/bash -G users -p $(openssl passwd -1 kampuser) kampuser
    echo 'user added kampuser'
else
    echo 'founded user kampuser'
fi

if existsFolder '/home/kampnote/mambaforge'; then
    sudo rm -rf /home/kampnote/.cache &> /dev/null
    sudo rm -rf /home/kampnote/.conda &> /dev/null
    sudo rm -rf /home/kampnote/mambaforge &> /dev/null
fi

tmp_dir=$(sudo -u kampnote mktemp -d -t ci-XXXXXXXXXX)
echo "downloading conda mambaforge"
sudo -u kampnote wget -P $tmp_dir https://github.com/conda-forge/miniforge/releases/download/4.9.2-7/Mambaforge-4.9.2-7-$(uname)-$(uname -m).sh
echo "downloaded conda mambaforge"

echo "installing conda"
sudo -u kampnote -H bash $tmp_dir/Mambaforge-4.9.2-7-$(uname)-$(uname -m).sh -f -b 
echo "installed conda"

echo "start config conda env"
echo "conda 4.9.2" | sudo -u kampnote -H tee -a /home/kampnote/mambaforge/conda-meta/pinned
sudo -u kampnote -H /home/kampnote/mambaforge/bin/conda config --system --set auto_update_conda false
sudo -u kampnote -H /home/kampnote/mambaforge/bin/conda config --system --set show_channel_urls true 

sudo -u kampnote -H /home/kampnote/mambaforge/bin/conda init bash
echo "end config conda env"

echo "installing tensorflow"
sudo -u kampnote -H /home/kampnote/mambaforge/bin/pip install tensorflow==2.4.1
echo "installed tensorflow"
echo "installing jupyter packages"
sudo -u kampnote -H /home/kampnote/mambaforge/bin/conda install -y jupyterhub=1.4.1 sudospawner==0.5.2 jupyterlab==3.0.16
echo "installed jupyter packages"


echo "downloading jupyterlab ko language pack"
sudo -u kampnote wget -P $tmp_dir https://raw.githubusercontent.com/aiblabco/files/main/jupyterlab_language_pack_ko_KR-0.0.1.dev0-py2.py3-none-any.whl
echo "downloaded jupyterlab ko language pack"

sudo -u kampnote -H /home/kampnote/mambaforge/bin/pip install $tmp_dir/jupyterlab_language_pack_ko_KR-0.0.1.dev0-py2.py3-none-any.whl

echo "downloading kampauth pack"
sudo -u kampnote wget -P $tmp_dir https://raw.githubusercontent.com/aiblabco/files/main/kampnote/kampauth-0.1.0-py2.py3-none-any.whl
echo "downloaded kampauth pack"

sudo -u kampnote -H /home/kampnote/mambaforge/bin/pip install $tmp_dir/kampauth-0.1.0-py2.py3-none-any.whl

echo "downloading kampnote images"
sudo -u kampnote wget -P $tmp_dir https://raw.githubusercontent.com/aiblabco/files/main/kampnote/images/favicon.ico
sudo -u kampnote wget -P $tmp_dir https://raw.githubusercontent.com/aiblabco/files/main/kampnote/images/kampnote.png
sudo -u kampnote wget -P $tmp_dir https://raw.githubusercontent.com/aiblabco/files/main/kampnote/images/logo_s.png
echo "downloaded kampnote images"

echo "starting replace kampnote images..."
sudo -u kampnote cp $tmp_dir/favicon.ico /home/kampnote/mambaforge/share/jupyterhub/static/favicon.ico
sudo -u kampnote cp $tmp_dir/favicon.ico /home/kampnote/mambaforge/lib/python3.8/dist-packages/notebook/static/base/images/favicon.ico
sudo -u kampnote cp $tmp_dir/favicon.ico /home/kampnote/mambaforge/lib/python3.8/dist-packages/jupyter_server/static/favicons/favicon.ico
sudo -u kampnote cp $tmp_dir/kampnote.png /home/kampnote/mambaforge/share/jupyterhub/static/images/kampnote.png
sudo -u kampnote mkdir /home/kampnote/mambaforge/share/jupyter/lab/static/images
sudo -u kampnote cp $tmp_dir/kampnote.png /home/kampnote/mambaforge/share/jupyter/lab/static/images/kampnote.png
sudo -u kampnote cp $tmp_dir/kampnote.png /home/kampnote/mambaforge/lib/python3.8/dist-packages/notebook/static/base/images/logo.png
sudo -u kampnote cp $tmp_dir/logo_s.png /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-light-extension/logo_s.png
sudo -u kampnote cp $tmp_dir/logo_s.png /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/logo_s.png

echo "#jp-MainLogo {" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-light-extension/index.css > /dev/null
echo "  background-image: url(logo_s.png);" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-light-extension/index.css > /dev/null
echo "  background-repeat: no-repeat;" | sudo -u tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-light-extension/index.css > /dev/null
echo "}" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-light-extension/index.css > /dev/null
echo "#jp-MainLogo > svg {" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-light-extension/index.css > /dev/null
echo "  visibility: hidden;" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-light-extension/index.css > /dev/null
echo "}" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-light-extension/index.css > /dev/null


echo "#jp-MainLogo {" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/index.css > /dev/null
echo "  background-image: url(logo_s.png);" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/index.css > /dev/null
echo "  background-repeat: no-repeat;" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/index.css > /dev/null
echo "}" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/index.css > /dev/null
echo "#jp-MainLogo > svg {" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/index.css > /dev/null
echo "  visibility: hidden;" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/index.css > /dev/null
echo "}" | sudo -u kampnote tee -a /home/kampnote/mambaforge/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/index.css > /dev/null

sudo -u kampnote sed -i 's/<title>JupyterLab<\/title>/<title>KAMP NOTE<\/title>/g' /home/kampnote/mambaforge/share/jupyter/lab/static/index.html

sudo -u kampnote sed -i "s/\"default\": false/\"default\": true/g" /home/kampnote/mambaforge/share/jupyter/lab/schemas/@jupyterlab/extensionmanager-extension/plugin.json
sudo -u kampnote sed -i "s/\"default\": \"en\"/\"default\": \"ko_KR\"/g" /home/kampnote/mambaforge/share/jupyter/lab/schemas/@jupyterlab/translation-extension/plugin.json


echo "downloading kampnote config file"
sudo -u kampnote wget -P $tmp_dir https://raw.githubusercontent.com/aiblabco/files/main/kampnote/config.py
echo "downloaded kampnote config file"

echo "input yours cmp userid ..."
read allowedcmpuser
sudo -u kampnote sed -i "s/{CMPUSER}/$allowedcmpuser/g" $tmp_dir/config.py
echo "$allowedcmpuser only allow cmp userid saved"

if notExistsFolder '/home/kampnote/jupyterconfig'; then    
    sudo -u kampnote -H mkdir /home/kampnote/jupyterconfig
fi
sudo -u kampnote -H cp $tmp_dir/config.py /home/kampnote/jupyterconfig/

local_tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
echo "downloading kampnote service file"
wget -P $local_tmp_dir https://raw.githubusercontent.com/aiblabco/files/main/kampnote/kampnote.service
echo "downloaded kampnote service file"

sudo cp $local_tmp_dir/kampnote.service /etc/systemd/system/kampnote.service

echo "starting kampnote service..."
sudo systemctl daemon-reload
sudo systemctl enable kampnote.service
sudo systemctl start kampnote.service
echo "started kampnote service - http://[floating ip]:8000"


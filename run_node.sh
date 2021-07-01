#!/bin/bash
function checkOS() {
	echo "checking OS.."
	# Check OS version
	if [[ -e /etc/debian_version ]]; then
		source /etc/os-release
		OS="${ID}" # debian or ubuntu
		if [[ ${ID} == "debian" || ${ID} == "raspbian" ]]; then
			if [[ ${VERSION_ID} -ne 10 ]]; then
				echo "Your version of Debian (${VERSION_ID}) is not supported. Please use Debian 10 Buster"
				exit 1
			fi
		fi
	elif [[ -e /etc/fedora-release ]]; then
		source /etc/os-release
		OS="${ID}"
	elif [[ -e /etc/centos-release ]]; then
		source /etc/os-release
		OS=centos
	elif [[ -e /etc/arch-release ]]; then
		OS=arch
	else
		echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS or Arch Linux system"
		exit 1
	
	fi
}

function initialCheck() {
	checkOS
}


initialCheck



# Detect public interface and pre-fill for the user
#ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1


IPV6=$(ip -6 addr | sed -ne 's|^.* inet6 \([^/]*\)/.* scope global.*$|\1|p' | head -1)
IPV4=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)

echo $IPV6 $IPV4

wget https://downloads.getmonero.org/cli/linux64

if curl -s "https://www.getmonero.org/downloads/" | grep $(sha256sum linux64 |cut -d " " -f 1) > /dev/null
then
    #Check hash
    echo "Hash verified! $(sha256sum linux64 |cut -d " " -f 1)"
    if [ -f linux64 ]; then
    	mkdir ~/blockchain
		echo Monero compressed file found! - linux64
		echo 'Beginning Extraction.....'
		tar xvf linux64
	else
		echo “File does not exist.”
		exit 1
	fi
	
else
    echo "Error, Hash not found. Check internet and website"
    exit 1
fi

cd monero-x86_64-linux-gnu*
wget https://raw.githubusercontent.com/westz36/xmr-tutorials/main/banlist.txt
current_dir=$(pwd)/

tmux new -s "xmr" -d "/bin/bash"

tmux send-keys -t "xmr" "${current}monerod --data-dir ~/blockchain --rpc-bind-ip $IPV4 --confirm-external-bind --public-node --restricted-rpc --no-zmq --no-igd --enable-dns-blocklist --out-peers 50 --in-peers 600 --limit-rate 500000 --ban-list=banlist.txt" C-m

echo tmux a [Enter] to view process

echo ./monerod --data-dir ~/blockchain --rpc-bind-ip $IPV4 --confirm-external-bind --public-node --restricted-rpc --no-zmq --no-igd --enable-dns-blocklist --out-peers 50 --in-peers 600 --limit-rate 500000 --ban-list=banlist.txt >>run_node.sh
echo “ ”
echo “bash run_node.sh” to start node


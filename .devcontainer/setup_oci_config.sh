set -e

mkdir /home/vscode/.oci/
cp config /home/vscode/.oci/config
chmod 600 /home/vscode/.oci/config
cp oci_api_key.pem /home/vscode/.oci/oci_api_key.pem
chmod 600 /home/vscode/.oci/oci_api_key.pem

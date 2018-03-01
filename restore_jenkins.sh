#!/bin/bash

if [ -z $1 ] || [ -z $2 ]; then
  echo "Usage: $0 <JENKINS_HOME> <JENKINS_USER>"
 
  exit 1 
fi

cp jenkins_backup*.tar.gz $JENKINS_HOME
JENKINS_HOME=$1
PLUGIN_DIR=$JENKINS_HOME/plugins
JENKINS_USER=$2

cd $JENKINS_HOME
tar -xzf jenkins_backup*.tar.gz


installPlugin() {
  if [ -f ${PLUGIN_DIR}/${1}.hpi -o -f ${PLUGIN_DIR}/${1}.jpi ]; then
    echo "Skipped: $1 (already installed)"
    return 0
  else
    echo "Installing: $1"
    curl -L --silent --output ${PLUGIN_DIR}/${1}.hpi  https://updates.jenkins-ci.org/download/plugins/${1}/${2}/${1}.hpi
    return 0
  fi
}

while read line; do
  PLUGIN=$(echo $line | cut -d ":" -f 1)
  VERSION=$(echo $line | cut -d ":" -f 2)
  installPlugin ${PLUGIN} ${VERSION}
done <installed_plugins.txt

echo "fixing permissions"

chown -R ${JENKINS_USER}: ${PLUGIN_DIR} 

echo "all done"

download_deploy_package(){
    if [ -n "$MSR_PACKAGE_URLS" ]
    then
      mkdir -p /opt/softwareag/IntegrationServer/replicate/autodeploy
      pushd `pwd`
      cd /opt/softwareag/IntegrationServer/replicate/autodeploy
      for url in $(echo $MSR_PACKAGE_URLS)
      do
        #zipfile=$(basename $url) 
        #packagename=$(echo $zipfile | cut -f 2 -d ".")
        curl -LO $url || true
      done
      popd
    fi
}

copy_files(){
        if [ -f "/tmp/filesLocations" ]
        then
                cat /tmp/filesLocations | while read line || [ -n "$line" ]; do echo $line; sh -c "cp /tmp/$line|| true" ; done
        fi
}
startMSR(){
    /bin/sh -c /opt/softwareag/IntegrationServer/bin/startContainer.sh&
}
copy_files
download_deploy_package
startMSR
PID_TO_WAIT=$!
wait $PID_TO_WAIT

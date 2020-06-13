import_configuration(){
	if [ ! -f /opt/softwareag/common/conf/.persistent/initialized ] && [ -f /tmp/config.xml ]
	then
		echo " importing configuration"
  		until	/opt/softwareag/UniversalMessaging/tools/runner/runUMTool.sh ImportRealmXML -rname=nsp://localhost:9000 -filename=/tmp/config.xml -importall=true; do sleep 10; done
		touch /opt/softwareag/common/conf/.persistent/initialized
	fi
}
start_UM(){
	/bin/sh -c umstart.sh&	
}
copy_files(){
	if [ -f "/tmp/filesLocations" ]
	then
		cat /tmp/filesLocations | while read line || [ -n "$line" ]; do echo $line; sh -c "cp /tmp/$line|| true" ; done
        fi
}
copy_external_files(){
        if [ -f "/tmp/externalFilesLocations" ]
        then
                cat /tmp/externalFilesLocations | while read line || [ -n "$line" ]; do echo $line; sh -c "cp /tmp/$line|| true" ; done
        fi
}
create_persistent_folder(){
	if [ ! -d /opt/softwareag/common/conf/.persistent ]
	then
		mkdir -p /opt/softwareag/common/conf/.persistent
	fi
}
link_license(){
	if [ -f /opt/softwareag/common/conf/.persistent/licence.xml ]
        then
                rm -f /opt/softwareag/UniversalMessaging/server/umserver/licence/licence.xml
                ln -s /opt/softwareag/common/conf/.persistent/licence.xml /opt/softwareag/UniversalMessaging/server/umserver/licence/licence.xml
        fi
}
create_persistent_folder
copy_files
copy_external_files
link_license
start_UM
PID_TO_WAIT=$!
# put custom code that should be executed after the UM has been started here
import_configuration
wait $PID_TO_WAIT

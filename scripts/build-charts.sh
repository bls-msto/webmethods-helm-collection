WORKDIR=`pwd`
pushd `pwd`
cd $WORKDIR/charts-repo/incubator/
helm package ../../charts/incubator/universal-messaging/
helm package ../../charts/incubator/microservices-runtime/
helm repo index . --url https://softwareag.github.io/webmethods-helm-collection/charts-repo/incubator
cd $WORKDIR
git add .
git commit -m "update charts"
git push
popd

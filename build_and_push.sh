if [ $# -ne 1 ] ; then
  echo "Please specify version"
  exit -1
fi

./gradlew build
docker build -t michalwit/boot-demo:$1 .
docker image push michalwit/boot-demo:$1

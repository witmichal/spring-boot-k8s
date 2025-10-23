if [ $# -ne 1 ] ; then
  echo "Please specify version"
  exit -1
fi

echo "Building version: $1"

echo "Previous versions:"
echo "002 [DB_PASS in secret]"
echo "003 [app name and HTTP client host in ConfigMap]"
echo "004 [/health endpoint]"
echo "005 [/health endpoint - changed | /ready endpoint added]"
echo "009 Java DNS caching set to 1sec"
echo "010 [/use-cup/1000] | actuator"
echo "011 enable readinessstate and livenessstate"

./gradlew build
docker build -t michalwit/boot-demo:$1 .
docker image push michalwit/boot-demo:$1

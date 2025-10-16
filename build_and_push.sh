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

./gradlew build
docker build -t michalwit/boot-demo:$1 .
docker image push michalwit/boot-demo:$1

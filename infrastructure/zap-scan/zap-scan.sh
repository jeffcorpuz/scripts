#!/bin/bash
# Will run OWASP quick scan against a url and/or API
set -ou pipefail
CONTAINER_NAME=zap
IS_ZAP_RUNNING=0
REPORTS_FOLDER="$(pwd)/reports"
WEB_REPORT_NAME=owasp-zap-scan-report.html
API_REPORT_NAME=owasp-zap-api-report.html
WEB_REPORT_PATH="${REPORTS_FOLDER}/${WEB_REPORT_NAME}"
API_REPORT_PATH="${REPORTS_FOLDER}/${API_REPORT_NAME}"
PORT=8080
ALERT_LEVEL='Medium'
OPEN_REPORT=0
URL_TO_SCAN=
ALERT_LEVEL=
API_TO_SCAN=
while getopts "u:l:a:oh" opt; do
  case $opt in
  u)
    URL_TO_SCAN=$OPTARG
    ;;
  l)
    ALERT_LEVEL=$OPTARG
    ;;
  a)
    API_TO_SCAN=$OPTARG
    ;;
  o)
    OPEN_REPORT=1
    ;;
  h)
    echo "Usage: Security scan [options]"
    echo "  -u URL to scan."
    echo "  -l Alert level to fail the script. Defaults to 'Medium'"
    echo "  -a API to scan"
    echo "  -o Open OWASP Report after script run"
    echo ""
    exit
  esac
done
function check_exit_code {
  if [ "$1" != "0" ]; then
    echo "Something went wrong with '${2}'"
    exit "$1"
  fi
}
function is_zap_running() {
  ZAP_STATUS=$(docker exec zap zap-cli status | grep -c INFO)
  if [[ "${ZAP_STATUS}" == 1 ]]; then IS_ZAP_RUNNING=1; fi
}
function remove_zap_container() {
  docker rm -f "${CONTAINER_NAME}"
}
function run_in_zap_container() {
  ZAP_COMMAND="docker exec ${CONTAINER_NAME} $1"
  echo 'Running...'
  echo "${ZAP_COMMAND}"
  echo ''
  sh -c "${ZAP_COMMAND}"
}
function launch_html_report() {
  open "${WEB_REPORT_PATH}"
}
function launch_api_report() {
  open "${API_REPORT_PATH}"
}
# Check if jq is installed. jq is used to count owasp alerts
if ! [ -x "$(command -v jq)" ]; then
  echo 'Please install jq from https://stedolan.github.io/jq/'
  exit 1
fi
# Make reports folder and set correct permissions where the docker container can write to the volume bind mount
if [[ -d "${REPORTS_FOLDER}" ]]; then
  echo "Directory ${REPORTS_FOLDER} exists." 
else
  mkdir -p "${REPORTS_FOLDER}"
  chmod 777 "${REPORTS_FOLDER}"
  check_exit_code $? "with changing permission"
fi
# Start zap container
remove_zap_container
if [[ ! -z ${URL_TO_SCAN} ]]; then
  echo "Scanning $URL_TO_SCAN ....."
  docker run --detach --name "${CONTAINER_NAME}" -u zap -v "${REPORTS_FOLDER}":/zap/reports/:rw \
    -i owasp/zap2docker-stable zap.sh -daemon -host 0.0.0.0 -port "${PORT}" \
    -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true \
    -config api.disablekey=true
    check_exit_code $? "starting container"
fi
if [[ ! -z ${API_TO_SCAN} ]]; then
  echo "Scanning $API_TO_SCAN ....."
  docker run --detach --name "${CONTAINER_NAME}" -u zap -v "${REPORTS_FOLDER}":/zap/wrk/:rw \
    -i owasp/zap2docker-stable zap.sh -daemon -host 0.0.0.0 -port "${PORT}" \
    -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true \
    -config api.disablekey=true
    check_exit_code $? "starting container"
fi
# Check that container and zap daemon has started
while [[ "${IS_ZAP_RUNNING}" == 0 ]]; do echo "zap container is starting up"; is_zap_running; sleep 1; done
if [[ ! -z ${URL_TO_SCAN} ]]; then
  # Run quick scan in container
  # quick-scan will open the URL to make sure it's in the site tree, run an active scan, and will output any found alerts.
  # https://github.com/Grunny/zap-cli
  run_in_zap_container "zap-cli --verbose quick-scan --spider -r ${URL_TO_SCAN}"
  run_in_zap_container "zap-cli --verbose report -o /zap/reports/${WEB_REPORT_NAME} --output-format html"
  # Check if report was generated
  if [[ ! -e "${WEB_REPORT_PATH}" ]]; then
    echo "${WEB_REPORT_PATH} should be generated but it is missing"
    remove_zap_container
    exit 1
  fi
  # Check alerts
  ALERT_NUM=$(docker exec "${CONTAINER_NAME}" zap-cli --verbose alerts --alert-level "${ALERT_LEVEL}" -f json | jq length)
  if [[ "${OPEN_REPORT}" == 1 ]]; then
    launch_html_report
  fi
  remove_zap_container
  if [[ "${ALERT_NUM}" -gt 0 ]]; then
    echo "${ALERT_NUM} ${ALERT_LEVEL} Alerts found! Please check the Zap Scanning Report ${WEB_REPORT_PATH}"
  fi
  echo "Scan successfully finished with no ${ALERT_LEVEL} alerts"
fi
if [[ ! -z ${API_TO_SCAN} ]]; then
  run_in_zap_container "zap-api-scan.py -t ${API_TO_SCAN} -f openapi -r ${API_REPORT_NAME}"
  # Check if report was generated
  if [[ ! -e "${API_REPORT_PATH}" ]]; then
    echo "${API_REPORT_PATH} should be generated but it is missing"
    remove_zap_container
    exit 1
  fi
  if [[ "${OPEN_REPORT}" == 1 ]]; then
    launch_api_report
  fi
  remove_zap_container
fi
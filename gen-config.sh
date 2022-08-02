#!/bin/sh
set -e

CFG_FILE="$CFG_DIR/config.xml"
CFG_FILE_BAK="$(mktemp -u "$CFG_FILE.bak.XXXXXX")"

if [ -f "$CFG_FILE" ]; then
    # Preserve old configuration, in case of ENOSPC or other errors
    cp "$CFG_FILE" "$CFG_FILE_BAK" || (echo "Error: Could not backup config file" >&2; exit 99)
fi

getOpt() {
    xmlstarlet sel -t -c /Config/"$1" "$CFG_FILE"
}
setOpt() {
    # If element exists
    if xmlstarlet sel -Q -t -c "/Config/$1" "$CFG_FILE"; then
        # Update the existing element
        xmlstarlet ed -O -L -u "/Config/$1" -v "$2" "$CFG_FILE"
    else
        # Insert a new sub-element
        xmlstarlet ed -O -L -s /Config -t elem -n "$1" -v "$2" "$CFG_FILE"
    fi
}
bool() {
    local var="$(echo "$1" | tr 'A-Z' 'a-z')"
    case "$var" in
        y|ye|yes|t|tr|tru|true|1)
            echo True;;
        n|no|f|fa|fal|fals|false|0)
            echo False;;
    esac
}
upper() { echo $1 | awk '{print toupper($0)}'; }
lower() { echo $1 | awk '{print tolower($0)}'; }
camel() { echo $1 | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}'; }

# Create config.xml file and fill in some sane defaults (or fill existing empty file)

# NOTE: If these defaults need to be set differently,
# please open an issue or pull request on the repo:
#   https://github.com/Adam-Ant/docker-sonarr

if [ ! -f "$CFG_FILE" ] || [ ! -s "$CFG_FILE" ]; then
    (echo '<Config>'; echo '</Config>') > "$CFG_FILE"
    setOpt AnalyticsEnabled False
    setOpt Branch 'develop'
    setOpt BindAddress '*'
    setOpt EnableSsl False
    setOpt LaunchBrowser False
    setOpt LogLevel 'info'
    setOpt UpdateAutomatically False
fi

# If they exist, add options that are specified in the environment
[ -n "$API_KEY" ]   && setOpt ApiKey $(lower "$API_KEY")
[ -n "$ANALYTICS" ] && setOpt AnalyticsEnabled $(bool "${ANALYTICS:-false}")
[ -n "$BRANCH" ] && setOpt Branch "${BRANCH:-develop}"
[ -n "$ENABLE_SSL" ] && setOpt EnableSsl $(bool "${ENABLE_SSL:-false}")
[ -n "$LOG_LEVEL" ] && setOpt LogLevel $(camel "${LOG_LEVEL:-info}")
[ -n "$URL_BASE" ] && setOpt UrlBase "$URL_BASE"


# Format the document pretty :)
xmlstarlet fo "$CFG_FILE" >/dev/null

# Finally, remove backup file after successfully creating new one
# This is done to prevent trampling the config when the disk is full
rm -f "$CFG_FILE_BAK"

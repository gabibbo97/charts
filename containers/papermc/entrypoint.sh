#!/bin/sh

# Automatically accept the EULA
if [ "$ACCEPT_EULA" = "y" ]; then
  echo 'Accepting Minecraft EULA'
  [ -f eula.txt ] || touch eula.txt
  grep 'eula' eula.txt | grep -q 'true' || echo 'eula=true' > eula.txt
fi

# Copy configuration from BASE_CONFIG_DIR
if [ -n "$BASE_CONFIG_DIR" ]; then
  # Base configuration directory
  if ! [ -d "$BASE_CONFIG_DIR" ]; then
    echo 'Base configuration directory not found!' && exit 1
  fi
  # Copy files
  copyFromTemplate() {

    BASE_FILE=$(basename "$1")

    # Overwrite
    if [ "$OVERWRITE_SETTINGS" = "y" ]; then
      cp "$1" "$BASE_FILE"
      echo "Overwrote config file $BASE_FILE"
      return
    fi

    # Copy only if not already present
    if [ -f "$BASE_FILE" ]; then
      echo "File $BASE_FILE was found, not copying"
      return
    fi

    # Copy only if different
    if cmp --silent "$1" "$BASE_FILE"; then
      echo "File $BASE_FILE is the same as in its base config, not copying"
      return
    fi

    # Perform the actual copy
    cp "$1" "$BASE_FILE"
    echo "Copied config file $BASE_FILE"
  }

  for file in "$BASE_CONFIG_DIR"/*; do
    copyFromTemplate "$file"
  done
fi

# Setup JVM options
[ -n "$JAVA_OPTS" ] || JAVA_OPTS=''

if [ -n "$JAVA_OPTS" ]; then
  echo "Using JAVA_OPTS: $JAVA_OPTS"
fi

exec java $JAVA_OPTS -jar /opt/papermc.jar "$@"

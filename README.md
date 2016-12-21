# Workstation setup for the PCF BOSH project

## Mounting a GCS bucket

[gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse) is installed and configured,
but to mount a bucket, you must run `gcsfuse pcf-bosh-ci "$HOME/gcs/pcf-bosh-ci"` on
every boot.

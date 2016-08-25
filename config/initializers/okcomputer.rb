require 'okcomputer'

OkComputer.mount_at = 'status' # use /status or /status/all or /status/<name-of-check>
OkComputer::Registry.deregister('database') # we don't use ActiveRecord

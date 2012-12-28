# encoding: utf-8

##
# Backup Generated: my_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t my_backup [-c <path_to_configuration_file>]
#

require 'yaml'
database_yml = File.expand_path('../database.yml',  __FILE__)
s3_yml       = File.path('/srv/3dj/s3.yml')
RAILS_ENV    = ENV['RAILS_ENV'] || 'development'
config       = YAML.load_file(database_yml)
s3_config    = YAML.load_file(s3_yml)
backups      = { hourly: 24, daily: 7, weekly: 52 }

backups.each do |period, keep|
  Backup::Model.new(period, '3-dj.com backup') do

    ##
    # PostgreSQL [Database]
    #
    database PostgreSQL do |db|
      db.name               = config[RAILS_ENV]["database"]
      db.username           = config[RAILS_ENV]["username"]
      db.password           = config[RAILS_ENV]["password"]
      db.host               = config[RAILS_ENV]["host"]
      db.port               = config[RAILS_ENV]["port"]
      db.skip_tables        = []
    end

    ##
    # Amazon Simple Storage Service [Storage]
    #
    # Available Regions:
    #
    #  - ap-northeast-1
    #  - ap-southeast-1
    #  - eu-west-1
    #  - us-east-1
    #  - us-west-1
    #
    store_with S3 do |s3|
      s3.access_key_id     = s3_config[RAILS_ENV]["access_key_id"]
      s3.secret_access_key = s3_config[RAILS_ENV]["secret_access_key"]
      s3.region            = s3_config[RAILS_ENV]["region"]
      s3.bucket            = s3_config[RAILS_ENV]["bucket"]
      s3.path              = "/backups/"
      s3.keep              = keep
    end

    ##
    # Gzip [Compressor]
    #
    compress_with Gzip do |compression|
      compression.best = true
      compression.fast = false
    end

  end
end

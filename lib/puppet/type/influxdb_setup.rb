# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'influxdb_setup',
  docs: <<~EOS,
    @summary Manages initial setup of InfluxDB.  It is recommended to use the influxdb::install class instead of this resource directly.
    @example
      influxdb_setup {'<influx_fqdn>':
        ensure     => 'present',
        token_file => <path_to_token_file>,
        bucket     => 'my_bucket',
        org        => 'my_org',
        username   => 'admin',
        password   => 'admin',
      }
  EOS
  features: [],
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether initial setup has been performed.  present/absent is determined by the response from the /setup api',
      default: 'present'
    },
    name: {
      type: 'String',
      desc: 'The fqdn of the host running InfluxDB',
      behaviour: :namevar
    },
    token_file: {
      type: 'String',
      desc: 'Absolute path to save the initial admin token',
      behavior: :parameter
    },
    bucket: {
      type: 'String',
      desc: 'Name of the initial bucket to create',
      behavior: :parameter
    },
    org: {
      type: 'String',
      desc: 'Name of the initial organization to create',
      behavior: :parameter
    },
    username: {
      type: 'String',
      desc: 'Name of the initial admin user',
      behavior: :parameter
    },
    password: {
      type: 'Sensitive[String]',
      desc: 'Initial admin user password',
      behavior: :parameter
    }
  }
)

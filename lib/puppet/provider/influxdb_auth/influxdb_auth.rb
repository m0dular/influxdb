# frozen_string_literal: true

require_relative '../influxdb/influxdb'
require 'puppet/resource_api/simple_provider'

# Implementation for performing initial setup of InfluxDB using the Resource API.
# Inheriting from the base provider gives us the get() and put() methods, as
#   well as a class variable for the connection
class Puppet::Provider::InfluxdbAuth::InfluxdbAuth < Puppet::Provider::Influxdb::Influxdb
  attr_accessor :auth_hash

  def get(context)
    init_attrs()
    init_auth()
    init_data()

    response = influx_get('/api/v2/authorizations', params: {})
    if response['authorizations']
      @auth_hash = response['authorizations']

      response['authorizations'].reduce([]) { |memo, value|
        #puts value.inspect
        memo + [
          {
            #TODO: terrible idea?  There's isn't a "name" attribute for a token, so what is our namevar
            name: value['description'],
            ensure: 'present',
            permissions: value['permissions'],
            status: value['status'],
            user: value['user'],
            org: value['org'],
          }
        ]
      }
    else
      []
    end
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")

    body = {
      influxdb_host: @influxdb_host,
      orgID: id_from_name(@org_hash, should[:org]),
      permissions: should[:permissions],
      description: name,
      status: should[:status],
    }

    influx_post('/api/v2/authorizations', JSON.dump(body))
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")

    token_id = @auth_hash.find {|auth| auth['description'] == name}.dig('id')
    influx_delete("/api/v2/authorizations/#{token_id}")
  end

end

#
# Copyright 2010, James Turnbull
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'sinatra/base'
require 'puppet'
require 'puppet/rails'

class PuppetRundeck < Sinatra::Base

  include Puppet

  class << self
    attr_accessor :config_file
    attr_accessor :username
    attr_accessor :puppet_server

    def configure
    end
  end

  get '/' do
    response = '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE project PUBLIC "-//DTO Labs Inc.//DTD Resources Document 1.0//EN" "project.dtd"><project>'
    Puppet::Rails.connect
    Puppet::Rails::Host.find_each do |node|
    # we need to merge in facts
      response << <<-EOH
<node name="#{xml_escape(node[:fqdn])}"
      type="Node"
      description="#{xml_escape(node.name)}"
      osArch="#{xml_escape(node.kernelfact}"
      osFamily="#{xml_escape(node.kernelfact)}"
      osName="#{xml_escape(node.operatingsystemfact)}"
      osVersion="#{xml_escape(node.operatingsystemversionfact)}"
      tags=#{xml_escape(node.tags)}""
      username="#{xml_escape(PuppetRundeck.username)}"
      hostname="#{xml_escape(node.fqdnfact)}"
EOH
    end
    response << "</project>"
    response
  end
end

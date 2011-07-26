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
require 'builder/xchar'

class PuppetRundeck < Sinatra::Base

  class << self
    attr_accessor :config_file
    attr_accessor :username
    attr_accessor :source

    def configure
      Puppet[:config] = PuppetRundeck.config_file
      Puppet.parse_config
    end
  end

  def xml_escape(input)
    # don't know if is string, so convert to string first, then to XML escaped text.
    return input.to_s.to_xs
  end

  get '/' do
    response = '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE project PUBLIC "-//DTO Labs Inc.//DTD Resources Document 1.0//EN" "project.dtd"><project>'
      Puppet::Node.terminus_class = :yaml
      Puppet[:clientyamldir] = "$yamldir"
      nodes = Puppet::Node.search("*")
      nodes.each do |n|
        facts = Puppet::Node::Facts.find(n.name)
        os_family = facts.values["kernel"] =~ /windows/i ? 'windows' : 'unix'
        tags = Puppet::Resource::Catalog.find(n.name).tags
      response << <<-EOH
<node name="#{xml_escape(n.name)}"
      type="Node"
      description="#{xml_escape(n.name)}"
      osArch="#{xml_escape(facts.values["kernel"])}"
      osFamily="#{xml_escape(os_family)}"
      osName="#{xml_escape(facts.values["operatingsystem"])}"
      osVersion="#{xml_escape(facts.values["operatingsystemrelease"])}"
      tags="#{xml_escape(tags.join(','))}"
      username="#{xml_escape(PuppetRundeck.username)}"
      hostname="#{xml_escape(facts.values["fqdn"])}"/>
EOH
    end
    response << "</project>"
    response
  end
end

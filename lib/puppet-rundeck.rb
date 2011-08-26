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
require 'builder/xchar'

begin
  require 'puppet'
rescue LoadError
  puts "You need to have Puppet 0.24.8 or later installed"
end

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

  require 'pp'
  get '/' do
    response = '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE project PUBLIC "-//DTO Labs Inc.//DTD Resources Document 1.0//EN" "project.dtd"><project>'
      # Fix for 2.6 to 2.7 indirection difference
      Puppet[:clientyamldir] = "$yamldir"
      if Puppet::Node.respond_to? :terminus_class
        Puppet::Node.terminus_class = :yaml
        nodes = Puppet::Node.search("*")
      else
        Puppet::Node.indirection.terminus_class = :yaml
        nodes = Puppet::Node.indirection.search("*")
      end
      nodes.each do |n|
        if Puppet::Node::Facts.respond_to? :find
          facts = Puppet::Node::Facts.find(n.name)
          tags = Puppet::Resource::Catalog.find(n.name).tags
        else
          facts = Puppet::Node::Facts.indirection.find(n.name)
          tags = Puppet::Resource::Catalog.indirection.find(n.name).tags
        end
        os_family = facts.values["kernel"] =~ /windows/i ? 'windows' : 'unix'
      response << <<-EOH
<node name="#{xml_escape(n.name)}"
      type="Node"
      description="#{xml_escape(n.name)}"
      osArch="#{xml_escape(facts.values["kernel"])}"
      osFamily="#{xml_escape(os_family)}"
      osName="#{xml_escape(facts.values["operatingsystem"])}"
      osVersion="#{xml_escape(facts.values["operatingsystemrelease"])}"
      tags="#{xml_escape([n.environment, tags.join(',')].join(','))}"
      username="#{xml_escape(PuppetRundeck.username)}"
      hostname="#{xml_escape(n.name)}"/>
EOH
    end
    response << "</project>"
    response
  end
end

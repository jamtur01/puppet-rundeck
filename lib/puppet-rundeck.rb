#
# Copyright 2012, James Turnbull
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
require 'fast_xs'

begin
  require 'puppet'
  require 'puppet/face'
rescue LoadError
  puts "You need to have Puppet 0.25.5 or later installed"
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
    return input.to_s.fast_xs
  end

  def respond(required_tag=nil, name_query="*")
    response['Content-Type'] = 'text/xml'
    response_xml = %Q(<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE project PUBLIC "-//DTO Labs Inc.//DTD Resources Document 1.0//EN" "project.dtd">\n<project>\n)
      # Fix for 2.6 to 2.7 indirection difference
      Puppet[:clientyamldir] = "$yamldir"
      if Puppet::Node.respond_to? :terminus_class
        Puppet::Node.terminus_class = :yaml
        nodes = Puppet::Node.search(name_query)
      else
        Puppet::Node.indirection.terminus_class = :yaml
        nodes = Puppet::Node.indirection.search(name_query)
      end
      Puppet::Node.indirection.terminus_class = :plain
      nodes.each do |n|
        if Puppet::Node::Facts.respond_to? :find
          tags = Puppet::Resource::Catalog.find(n.name).tags
        else
          tags = Puppet::Face[:catalog, :current].find(n.name).tags
        end
        if ! required_tag.nil?
          next if ! tags.include? required_tag
        end
        facts = n.parameters
        os_family = facts["kernel"] =~ /windows/i ? 'windows' : 'unix'
      response_xml << <<-EOH
<node name="#{xml_escape(n.name)}"
      type="Node"
      description="#{xml_escape(n.name)}"
      osArch="#{xml_escape(facts["kernel"])}"
      osFamily="#{xml_escape(os_family)}"
      osName="#{xml_escape(facts["operatingsystem"])}"
      osVersion="#{xml_escape(facts["operatingsystemrelease"])}"
      tags="#{xml_escape([n.environment, tags.join(',')].join(','))}"
      username="#{xml_escape(PuppetRundeck.username)}"
      hostname="#{xml_escape(facts["fqdn"])}"/>
EOH
    end
    response_xml << "</project>"
    response_xml
  end

  get '/' do
    respond
  end

  get '/tag/:tag' do
    respond(params[:tag])
  end
  
  get '/name/:query' do
    respond(nil, params[:query])
  end
end

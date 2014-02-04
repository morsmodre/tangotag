# encoding: utf-8

require 'rubygems'
require 'taglib'
require 'log4r'

include Log4r

Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'


class Discography

  @@map_resources =
  {
      'Tanturi' => 'c:\git\tangotag\resources\tangodj_tanturi.htm' #'..\resources\tangodj_tanturi.htm'
  }
  @@map_url =
  {
      'Tanturi' => 'http://www.tango-dj.at/DJ-ing/collection/orchestras/Tanturi.htm'
  }

  def self.map_resources
    @@map_resources
  end

  def self.map_url
    @@map_url
  end

end #Discography


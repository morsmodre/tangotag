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
      'Tanturi'   => 'c:\git\tangotag\resources\tangodj_tanturi.htm', #'..\resources\tangodj_tanturi.htm'
      'DeAngelis' => 'c:\git\tangotag\resources\tangodj_deangelis.htm',
      'Biagi'     => 'c:\git\tangotag\resources\tangodj_biagi.htm',
      'Troilo'    => 'c:\git\tangotag\resources\tangodj_troilo.htm',
      'DArienzo'  => 'c:\git\tangotag\resources\tangodj_darienzo.htm',
      'DiSarli'   => 'c:\git\tangotag\resources\tangodj_disarli.htm',
      'OTV'       => 'c:\git\tangotag\resources\tangodj_otv.htm',
      'Calo'      => 'c:\git\tangotag\resources\tangodj_calo.htm',
      'Canaro'    => 'c:\git\tangotag\resources\tangodj_canaro.htm',
  }
  @@map_url =
  {
      'Tanturi'   => 'http://www.tango-dj.at/DJ-ing/collection/orchestras/Tanturi.htm',
      'DeAngelis' => 'http://www.tango-dj.at/DJ-ing/collection/orchestras/DeAngelis.htm',
      'Biagi'     => 'http://www.tango-dj.at/DJ-ing/collection/orchestras/Biagi.htm',
      'Troilo'    => 'http://www.tango-dj.at/DJ-ing/collection/orchestras/Troilo.htm',
      'DArienzo'  => 'http://www.tango-dj.at/DJ-ing/collection/orchestras/DArienzo.htm',
      'DiSarli'   => 'http://www.tango-dj.at/DJ-ing/collection/orchestras/DiSarli.htm',
      'OTV'       => 'http://www.tango-dj.at/DJ-ing/collection/orchestras/OTV.htm',
      'Calo'      => 'http://www.tango-dj.at/DJ-ing/collection/orchestras/Calo.htm',
      'Canaro'    => 'http://www.tango-dj.at/DJ-ing/collection/orchestras/Canaro.htm',
  }

  def self.map_resources
    @@map_resources
  end

  def self.map_url
    @@map_url
  end

end #Discography


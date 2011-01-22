require 'helper'

class ValidateUri
  include ActiveModel::Validations
  attr_accessor :uri
end

class ValidateDefaultUri < ValidateUri
  validates :uri, :uri => true
end

class ValidateHttpUri < ValidateUri
  validates :uri, :uri => {:schemes => [:http, :https]}
end

class ValidateMailtoUri < ValidateUri
  validates :uri, :uri => {:schemes => :mailto}
end

class ValidateCustomUri < ValidateUri
  validates :uri, :uri => {:schemes => [:http, :https], :custom => Proc.new { |uri| uri.userinfo == nil }}
end

class TestRailsUriValidator < Test::Unit::TestCase
  def test_valid_uri
    instance = ValidateDefaultUri.new
    [
        'test',
        "http://user:pass@www.web.de:80/directory/?querystring#anker",
        "https://user:pass@www.web.de:80/directory/?querystring#anker",
        "http://www.web.de:80/directory/?querystring#anker",
        "https://www.web.de:80/directory/?querystring#anker",
        "http://www.web.de/directory/?querystring#anker",
        "https://www.web.de/directory/?querystring#anker",
        "http://www.web.de/directory",
        "https://www.web.de/directory",
        "http://de.wikipedia.org/wiki/Uniform_Resource_Identifier",
        "ftp://ftp.is.co.za/rfc/rfc1808.txt",
        "file:///C:/Dokumente%20und%20Einstellungen/Benutzer/Desktop/Uniform%20Resource%20Identifier.html",
        "geo:48.33,14.122;u=22.5",
        "ldap://[2001:db8::7]/c=GB?objectClass?one",
        "gopher://gopher.floodgap.com",
        "mailto:John.Doe@example.com",
        "sip:911@pbx.mycompany.com",
        "news:comp.infosystems.www.servers.unix",
        # "data:text/plain;charset=iso-8859-7,%be%fg%be", not supported
        "tel:+1-816-555-1212",
        "telnet://192.0.2.16:80/",
        "urn:oasis:names:specification:docbook:dtd:xml:4.1.2"
    ].each do |uri|
      instance.uri = uri
      assert instance.valid?, uri.to_s
    end
  end

  def test_http_and_https_only
    instance = ValidateHttpUri.new
    [
        "http://user:pass@www.web.de:80/directory/?querystring#anker",
        "https://user:pass@www.web.de:80/directory/?querystring#anker",
        "http://www.web.de:80/directory/?querystring#anker",
        "https://www.web.de:80/directory/?querystring#anker",
        "http://www.web.de/directory/?querystring#anker",
        "https://www.web.de/directory/?querystring#anker",
        "http://www.web.de/directory",
        "https://www.web.de/directory",
        "http://de.wikipedia.org/wiki/Uniform_Resource_Identifier"
    ].each do |uri|
      instance.uri = uri
      assert instance.valid?, uri.to_s
    end

    [
        "ftp://ftp.is.co.za/rfc/rfc1808.txt",
        "file:///C:/Dokumente%20und%20Einstellungen/Benutzer/Desktop/Uniform%20Resource%20Identifier.html",
        "geo:48.33,14.122;u=22.5",
        "ldap://[2001:db8::7]/c=GB?objectClass?one",
        "gopher://gopher.floodgap.com",
        "mailto:John.Doe@example.com",
        "sip:911@pbx.mycompany.com",
        "news:comp.infosystems.www.servers.unix",
        "tel:+1-816-555-1212",
        "telnet://192.0.2.16:80/",
        "urn:oasis:names:specification:docbook:dtd:xml:4.1.2"
    ].each do |uri|
      instance.uri = uri
      assert !instance.valid?, uri.to_s
    end
  end

  def test_mailto
    instance = ValidateMailtoUri.new
    [
        "mailto:test@example.net",
        "mailto:test@example.net?subject=Test"
    ].each do |uri|
      instance.uri = uri
      assert instance.valid?, uri.to_s
    end

    [
        "ftp://ftp.is.co.za/rfc/rfc1808.txt",
        "file:///C:/Dokumente%20und%20Einstellungen/Benutzer/Desktop/Uniform%20Resource%20Identifier.html",
        "geo:48.33,14.122;u=22.5",
        "ldap://[2001:db8::7]/c=GB?objectClass?one",
        "gopher://gopher.floodgap.com",
        "sip:911@pbx.mycompany.com",
        "news:comp.infosystems.www.servers.unix",
        "tel:+1-816-555-1212",
        "telnet://192.0.2.16:80/",
        "urn:oasis:names:specification:docbook:dtd:xml:4.1.2"
    ].each do |uri|
      instance.uri = uri
      assert !instance.valid?, uri.to_s
    end
  end

  def test_custom
    instance = ValidateCustomUri.new
    [
        "http://example.net",
        "http://example.net/test"
    ].each do |uri|
      instance.uri = uri
      assert instance.valid?, uri.to_s
    end

    [
        "http://test@example.net",
        "http://test:test@example.net/test"
    ].each do |uri|
      instance.uri = uri
      assert !instance.valid?, uri.to_s
    end
  end

  def test_invalid
    instance = ValidateDefaultUri.new
    [
        1,
        2.2,
       '##'
    ].each do |uri|
      instance.uri = uri
      assert !instance.valid?, uri.to_s
    end
  end

end

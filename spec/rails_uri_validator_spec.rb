# encoding: utf-8
require 'spec_helper'

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe UriValidator do
  before do
    class ValidateUri
      include ActiveModel::Validations
      attr_accessor :uri
    end
  end

  describe "default uri validation" do
    before do
      class ValidateDefaultUri < ValidateUri
        validates :uri, :uri => true
      end
      @object = ValidateDefaultUri.new
    end


    describe "uri validation with valid uris" do

      it "should validate without errors" do
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
          @object.uri = uri
          @object.should be_valid
        end
      end

    end


    describe "uri validation with invalid uris" do
      it "should validate with errors" do
        [
            1,
            2.2,
            '##'
        ].each do |uri|
          @object.uri = uri
          @object.should_not be_valid
        end
      end
    end

  end

  describe "http uri validation" do
    before do
      class ValidateHttpUri < ValidateUri
        validates :uri, :uri => {:schemes => [:http, :https]}
      end
      @object = ValidateHttpUri.new
    end

    describe "http uri validation with valid uris" do
      it "should validate without errors" do
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
          @object.uri = uri
          @object.should be_valid
        end
      end
    end

    describe "http uri validation with invalid uris" do
      it "should validate with errors" do
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
          @object.uri = uri
          @object.should_not be_valid
        end
      end
    end
  end

  describe "mailto uri validation" do
    before do
      class ValidateMailtoUri < ValidateUri
        validates :uri, :uri => {:schemes => :mailto}
      end
      @object = ValidateMailtoUri.new
    end

    describe "http uri validation with valid uris" do
      it "should validate without errors" do
        [
            "mailto:test@example.net",
            "mailto:test@example.net?subject=Test"
        ].each do |uri|
          @object.uri = uri
          @object.should be_valid
        end
      end
    end

    describe "http uri validation with invalid uris" do
      it "should validate with errors" do
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
          @object.uri = uri
          @object.should_not be_valid
        end
      end
    end
  end

  describe "custom uri validation" do
    before do
      class ValidateCustomUri < ValidateUri
        validates :uri, :uri => {:schemes => [:http, :https], :custom => Proc.new { |uri| uri.userinfo == nil }}
      end
      @object = ValidateCustomUri.new
    end

    describe "custom uri validation with valid uris" do
      it "should validate without errors" do
        [
            "http://example.net",
            "http://example.net/test"
        ].each do |uri|
          @object.uri = uri
          @object.should be_valid
        end
      end
    end

    describe "custom uri validation with invalid uris" do
      it "should validate with errors" do
        [
            "http://test@example.net",
            "http://test:test@example.net/test"
        ].each do |uri|
          @object.uri = uri
          @object.should_not be_valid
        end
      end
    end
  end
end

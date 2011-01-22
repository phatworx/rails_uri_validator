# encoding:utf-8

require 'active_model'
require 'uri'

# Validator for email
class UriValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)


    unless value.blank?
      # pre var
      valid = true

      begin
        uri = URI.parse(value)

        # need schemes validation?
        unless options[:schemes].nil?
          if options[:schemes].is_a? Array
            valid = false unless options[:schemes].include? uri.scheme.to_sym
          else
            valid = false unless options[:schemes] == uri.scheme.to_sym
          end
        end

      rescue
        valid = false
      end

      # ip valid
      record.errors.add(attribute, :invalid) unless valid
    end
  end

end

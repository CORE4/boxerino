require 'json'

module Boxerino
  # Represents box configuration data
  class Configuration
    attr_accessor :data

    def initialize(data = '{}')
      @data = JSON.parse(data)
    end

    def self.from_file(filename)
      new(File.read(filename))
    end

    def versions
      return @versions unless @versions.nil?
      @versions = []
      @data['versions'].each do |version|
        version['providers'].each do |provider|
          @versions << Boxerino::Box.from_provider_data(@data['name'], version['version'], provider)
        end
      end
      @versions.sort_by! { |item| Gem::Version.new(item.version) }
      @versions
    end

    def delete(version_number)
      versions.delete_if { |box| box.version == version_number }
    end

    def name
      @data['name']
    end

    def name=(name)
      @data['name'] = name
    end

    def description
      @data['description']
    end

    def description=(text)
      @data['description'] = text
    end

    def <<(box)
      raise 'Box name does not match this configuration' if box.name != name
      raise 'Box configuration is incomplete' unless box.complete?
      box.version = next_valid_version(box.version)
      @versions << box
    end

    def base_url
      match_data = /https?:\/\/[a-zA-Z0-9.\-]+/.match versions.first.url
      match_data[0]
    end

    def current_version
      versions.last.version
    end

    def next_bugfix
      parts = current_version.split('.')
      "#{parts[0]}.#{parts[1]}.#{parts[2].to_i + 1}"
    end

    def next_minor
      parts = current_version.split('.')
      "#{parts[0]}.#{parts[1].to_i + 1}#{parts.length > 2 ? '.0' : ''}"
    end

    def next_major
      parts = current_version.split('.')
      "#{parts[0].to_i + 1}#{parts.length > 1 ? '.0' : ''}#{parts.length > 2 ? '.0' : ''}"
    end

    def to_json
      all_versions = versions
      @data['versions'] = []
      all_versions.each do |version|
        @data['versions'] << version.to_hash
      end
      @data.to_json
    end

    protected

    def next_valid_version(version)
      case version
        when 'next-bugfix'
          return next_bugfix
        when 'next-minor'
          return next_minor
        when 'next-major'
          return next_major
        else
          raise 'Requested version format is invalid' unless /\d+\.\d+.\d+/.match version
          raise 'Requested version does already exist' if versions.map(&:version).include?(version)
          version
      end
    end
  end
end

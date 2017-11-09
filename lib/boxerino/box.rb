require 'digest/sha1'

module Boxerino
  # Represents a vagrant box file
  class Box
    attr_accessor :name, :version, :url, :checksum, :checksum_type, :provider
    def initialize(url)
      @url = url
      @provider = 'virtualbox'
    end

    def self.from_provider_data(name, version, data)
      box = Box.new(data['url'])
      box.name = name
      box.version = version
      box.checksum = data['checksum']
      box.checksum_type = data['checksum_type']
      box
    end

    def sha1
      fail 'Cannot compute sha1 of remote box (yet)' if remote?
      sha = File.open(@url, 'rb') do |io|
        dig = Digest::SHA1.new
        buf = ''
        dig.update(buf) while io.read(4096, buf)
        dig
      end
      sha.to_s
    end

    def checksum
      @checksum ||= sha1
    end

    def checksum_type
      @checksum_type ||= 'sha1'
    end

    def remote?
      @url =~ %r{https?://}
    end

    def filename
      "#{@name}/#{@name}_#{@version}.box"
    end

    def complete?
      @name && @version && @url && checksum && checksum_type && @provider
    end

    def to_hash
      {
        'version' => @version,
        'providers' => [{
          'name' => @provider,
          'url' => @url,
          'checksum_type' => checksum_type,
          'checksum' => checksum
        }]
      }
    end
  end
end
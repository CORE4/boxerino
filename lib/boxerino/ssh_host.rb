require 'fulmar/shell'

module Boxerino
  # Represent a host accessible via ssh, allow access to box lists
  class SshHost
    attr_reader :path, :host

    def initialize(host, path)
      @host = host
      @path = path
      @shell = Fulmar::Shell.new(path, host)
    end

    def list(all_versions)
      boxes = public_boxes
      boxes += internal_boxes.map { |box| "internal/#{box}" }
      box_list = []
      boxes.each do |box|
        if all_versions
          config(box).versions.each do |box_info|
            box_list << "#{box}, #{box_info.version}"
          end
        else
          box_list << "#{box}, #{config(box).versions.last.version}"
        end
      end
      box_list
    end

    def public_boxes
      @shell.run 'ls -1'
      @shell.last_output.reject { |item| item == 'internal' }
    end

    def internal_boxes
      @shell.run 'ls -1 internal'
      @shell.last_output
    end

    def config(name)
      @shell.run "cat #{name}/#{name.split('/').last}.json"
      json = @shell.last_output.join("\n")
      raise "Cannot load box configuration for '#{name}'" if json.empty?
      Boxerino::Configuration.new(json)
    end

    def delete(name, version)
      @shell.run "rm #{name}/#{name.split('/').last}_#{version}.box"
    end

    def upload(box)
      box_config = config(box.name)
      box_config << box
      system "scp -q #{box.url} #{@host}:#{@path}/#{box.name}/#{box.name.split('/').last}_#{box.version}.box"
      box.url = "#{box_config.base_url}/#{box.name}/#{box.name.split('/').last}_#{box.version}.box"
      update_config(box_config)
    end

    def update_config(config)
      File.open('/tmp/boxerino_box_config.tmp', 'w') { |f| f.puts config.to_json }
      system "scp -q /tmp/boxerino_box_config.tmp #{@host}:#{@path}/#{config.name}/#{config.name}.json"
    end
  end
end
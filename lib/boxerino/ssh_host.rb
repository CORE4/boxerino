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
      boxes = list_boxes
      box_list = []
      boxes.each do |box|
        if all_versions
          config(box).versions.each do |box_info|
            box_list << "#{box}, #{box_info.version}"
          end
        else
          box_list << "#{box}, #{config(box).versions.last.version}" unless config(box).versions.empty?
        end
      end
      box_list
    end

    def list_boxes
      @shell.run 'ls -1'
      @shell.last_output.reject { |item| item == 'internal' }
    end

    def config(name)
      @shell.run "cat #{name}/#{name}.json"
      json = @shell.last_output.join("\n")
      raise "Cannot load box configuration for '#{name}'" if json.empty?
      Boxerino::Configuration.new(json)
    end

    def delete(name, version)
      @shell.run "rm #{name}/#{name}_#{version}.box"
    end

    def upload(box)
      box_config = config(box.name)
      box_config << box
      system "scp -q #{box.url} #{@host}:#{@path}/#{box.name}/#{box.name}_#{box.version}.box"
      box.url = "#{box_config.base_url}/#{box.name}/#{box.name}_#{box.version}.box"
      update_config(box_config)
    end

    def update_config(config)
      File.open('/tmp/boxerino_box_config.tmp', 'w') { |f| f.puts config.to_json }
      path = "#{@path}/#{config.name}/#{config.name}.json"
      system "scp -q /tmp/boxerino_box_config.tmp #{@host}:#{path}"
    end
  end
end
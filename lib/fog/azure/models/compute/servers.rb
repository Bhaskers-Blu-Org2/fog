require 'fog/core/collection'
require 'fog/azure/models/compute/server'

module Fog
  module Compute
    class Azure

      class Servers < Fog::Collection

        model Fog::Compute::Azure::Server

        def all()
          servers = []
          service.list_virtual_machines.each do |vm|
            hash = {}
            vm.instance_variables.each do |var|
              hash[var.to_s.delete("@")] = vm.instance_variable_get(var)
            end
            hash[:vm_user] = 'azureuser' if hash[:vm_user].nil?
            servers << hash
          end
          load(servers)
        end

        def get(identity)
          hash = {}
          service.list_virtual_machines.each do |vm|
            if vm.vm_name == identity
              vm.instance_variables.each do |var|
                hash[var.to_s.delete("@")] = vm.instance_variable_get(var)
              end
              hash[:vm_user] = 'azureuser' if hash[:vm_user].nil?
            end
          end
          new(hash)
        end

        def bootstrap(new_attributes = {})
          name = "fog-#{Time.now.to_i}"
          defaults = {
            :vm_name => name,
            :vm_user => 'azureuser',
            :image => "b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-12_04_3-LTS-amd64-server-20131205-en-us-30GB",
            :location => "Central US",
            :private_key_file => File.expand_path("~/.ssh/id_rsa"),
            :public_key_file => File.expand_path("~/.ssh/id_rsa.pub"),
            :vm_size => "Small",
          }


          server = create(defaults.merge(new_attributes))
          server.wait_for { sshable? }

          server
        end
        
      end
    end
  end
end

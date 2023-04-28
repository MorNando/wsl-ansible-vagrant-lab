Vagrant.configure("2") do |config|
  config.vm.define "db01" do |server1|
    server1.vm.box = "gusztavvargadr/windows-server"
    server1.vm.network "private_network", ip: "192.168.56.3"
    server1.vm.hostname = "db01"
    server1.vm.provider "virtualbox" do |v|
      v.cpus = 2
      v.memory = 4096
      v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  config.vm.define "db02" do |server2|
    server2.vm.box = "gusztavvargadr/windows-server"
    server2.vm.network "private_network", ip: "192.168.56.4"
    server2.vm.hostname = "db02"
    server2.vm.provider "virtualbox" do |v|
      v.cpus = 2
      v.memory = 4096
      v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

config.vm.define "web01" do |server3|
  server3.vm.box = "gusztavvargadr/windows-server"
  server3.vm.network "private_network", ip: "192.168.56.5"
  server3.vm.hostname = "web01"
  server3.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 4096
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
  end
end

end
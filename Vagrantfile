# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # vagrant で立てる仮想マシンの名前
  config.vm.define "docker-basic" do |docker|
    docker.vm.box = "bento/almalinux-9"
    # ホスト名は任意に設定する
    docker.vm.hostname = "docker-basic.local"
    # IP アドレスは任意に設定する
    docker.vm.network "private_network", ip: "192.168.33.150"
    # ホストのファイルは必要に応じて同期する（ベースでは同期するものがないからコメントアウト）
    # config.vm.synced_folder "../data", "/vagrant_data"

    docker.vm.provider "virtualbox" do |vb|
      vb.cpus = 1
      vb.memory = "1024"
    end

    docker.vm.provision "shell", inline: <<-SHELL
      sudo timedatectl set-timezone Asia/Tokyo
      sudo dnf -y install dnf-plugins-core
      sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      sudo systemctl enable --now docker
      # このコマンドは vagrant ユーザを docker グループに追加するコマンドです。
      # こうすることで vagrant ユーザが docker コマンドを実行できるようになります。
      # sudo usermod -aG docker vagrant
      sudo systemctl enable docker
      sudo systemctl start docker
    SHELL
  end
end

说明是在 ubuntu 1204 的系统中执行部署工作。

## 基本依赖的安装

首先登录 vps

```sh
$ ssh root@178.xxx.xxx.xxx
```

执行 update

```sh
root@li349-144:~# apt-get update
```

安装基本包

```sh
root@li349-144:~# apt-get -y install curl git-core tmux htop python-software-properties
```

安装 nginx

```sh
root@li349-144:~# add-apt-repository ppa:nginx/stable
root@li349-144:~# apt-get update
root@li349-144:~# apt-get -y install nginx
```

启动 nginx 测试一下

```sh
root@li349-144:~# service nginx start
Starting nginx: nginx.
```

安装 nodejs （js css 编译需要)

```sh
root@li349-144:~# add-apt-repository ppa:chris-lea/node.js
root@li349-144:~# apt-get update
root@li349-144:~# apt-get -y install nodejs
```

安装 imagemagick

```sh
sudo apt-get install libmagickwand-dev libmagickcore-dev libmagickcore4-extra libgraphviz-dev libgvc5
```

安装 curlib

```sh
sudo apt-get install libcurl3 libcurl3-gnutls libcurl4-openssl-dev
```

## 安装 ruby

添加部署用户

```sh
root@li349-144:~# adduser deployer --ingroup admin
Adding user `deployer' ...
Adding new user `deployer' (1000) with group `admin' ...
Creating home directory `/home/deployer' ...
Copying files from `/etc/skel' ...
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
Changing the user information for deployer
Enter the new value, or press ENTER for the default
        Full Name []:
        Room Number []:
        Work Phone []:
        Home Phone []:
        Other []:
Is the information correct? [Y/n] Y
```

以 deployer 执行之后的步骤

```sh
root@li349-144:~# su deployer
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

deployer@li349-144:/root$ cd ~
```

安装 rbenv 环境

```sh
deployer@li349-144:~$ curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
```

这个命令执行之后会提示在 `.bashrc` 添加如下内容:

```sh
if [ -d \$HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
To edit the file we’ll use Vim.
```

注意在 `.bashrc` 文件中可能会有

```sh
[ -z "$PS1" ] && return
```

一定要把上面的语句添加到这一行之前，最终应该像如下这样

```sh
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

## If not running interactively, don't do anything
[ -z "$PS1" ] && return
Once we’ve saved .bashrc we’ll need to reload it.
```

最后执行一下 `.bashrc`

```sh
deployer@li349-144:~$ . ~/.bashrc
```

之后执行如下命令

```sh
deployer@li349-144:~$ rbenv bootstrap-ubuntu-12-04
```

这条命令会安装一些 ruby 的依赖包。

然后安装 `ruby 1.9.3`

```sh
deployer@li349-144:~$ rbenv install 1.9.3-p392
```

然后设置 `1.9.3` 为默认使用的版本

```sh
deployer@li349-144:~$ rbenv global 1.9.3-p392
deployer@li349-144:~$ ruby -v
ruby 1.9.3p392 (2013-02-22 revision 39386) [i686-linux]
```

安装 bundler

```sh
deployer@li349-144:~$ gem install bundler --no-ri --no-rdoc
deployer@li349-144:~$ rbenv rehash
deployer@li349-144:~$ bundle -v
Bundler version 1.3.5
```

生成 ssh-key

```sh
ssh-keygen
cat ~/.ssh/id_rsa.pub
```

将结果复制给 github 账号允许的 key 列表中，然后执行

```sh
ssh git@github.com
```

## 项目相关配置

项目用从 github 上取下最新的代码进行部署。

在项目中有三个文件需要在部署前做修改。

```
config/settings.yml # parse 和 七牛的配置 参见 config/settings.example.yml
config/deploy.rb    # 部署脚本 主要是修改默认部署的服务器以及 github 地址
lib/mina/servers/production.rb # 部署的服务器配置
```

在完成配置文件的修改后，在本地的项目中执行

```
bundle install
mina setup
mina deploy
mina unicorn:restart
```

完成部署任务。

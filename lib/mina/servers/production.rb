# FreeBSD
namespace :env do
  task :production => [:environment] do
    set :domain,              '192.168.33.10'
    set :deploy_to,           '/home/deployer/apps/bookstore'
    set :sudoer,              'sudoer_user'
    set :user,                'deployer'
    set :group,               'admin'
    # set :rvm_path,          '/usr/local/rvm/scripts/rvm'   # we don't use that. see below.
    set :services_path,       '/etc/init.d'                  # where your God and Unicorn service control scripts will go
    set :nginx_path,          '/etc/nginx'
    set :deploy_server,       'bookstore'                    # just a handy name of the server
    set :unicorn_workers,     2
    invoke :defaults                                         # load rest of the config
    # invoke :"rvm:use[#{rvm_string}]"                       # since my prod server runs 1.9 as default system ruby, there's no need to run rvm:use
  end
end

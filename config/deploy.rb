$:.unshift './lib'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

require 'mina/defaults'
require 'mina/extras'
require 'mina/god'
require 'mina/unicorn'
require 'mina/nginx'

Dir['lib/mina/servers/*.rb'].each { |f| load f }

###########################################################################
# Common settings for all servers
###########################################################################

set :app,                'bookstore'
set :repository,         'git@github.com:aisensiy/book-store.git'
set :keep_releases,      9999        #=> I like to keep all my releases
set :default_server,     :production

###########################################################################
# Tasks
###########################################################################

set :server, ENV['to'] || default_server
invoke :"env:#{server}"

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    # invoke :'rails:db_migrate'         # I'm using MongoDB, not AR, so I don't need those
    invoke :'rails:assets_precompile'  # I don't really like assets pipeline

    to :launch do
      invoke :'unicorn:restart'
    end
  end
end

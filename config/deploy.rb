# config valid only for Capistrano 3.1
require 'thor'
lock '3.6.0'

set :application, 'streakalong'
set :repo_url, 'git@github.com:mmcrockett/Streakalong.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'copy database configuration'
  task :copy_db_config do
    on roles(:app), in: :sequence, wait: 5 do
      if test("[ -f #{shared_path.join('config.yml')} ]")
        execute :cp, shared_path.join('config.yml'), release_path.join('config').join('database.yml')
      end
    end
  end

  desc 'Modify htaccess for test'
  task :htaccess do
    on roles(:test), in: :sequence, wait: 5 do
      if test("[ -f #{release_path.join('.htaccess')} ]")
        execute :sed, '-i', 's/streakalong.com/test.streakalong.com/g', release_path.join('.htaccess')
        execute :sed, '-i', '"s/\/streakalong\//\/testsa\//g"', release_path.join('.htaccess')
        execute :echo, '"SetEnv RAILS_ENV staging"', '>>', release_path.join('.htaccess')
      end
    end
  end

  desc 'Create a new secret'
  task :create_secret do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        execute :rake, 'secret', '>', release_path.join('config').join("streakalong.#{fetch(:rails_env)}.secret.token")
      end
    end
  end

  after :publishing, :restart
  before :restart, :htaccess
  before :migrate, :copy_db_config
  before "assets:precompile", :create_secret

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

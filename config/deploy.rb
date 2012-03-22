set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :user, "deploy"
set :repository, "git:/repos/qrcodes/bbc_qrcodes.git"
set :scm, :git
set :use_sudo, false

# this means you don't have to use any kind of SSH keychain
ssh_options[:forward_agent] = true

namespace :deploy do

  desc <<-DESC
  A macro-task that updates the code, fixes the symlink, added the symlink
  to the shared uploads folder. Finally takes a snapshot of the db.
  DESC
  task :default do
    update
  end

  task :update_code, :except => { :no_release => true } do
    on_rollback {
      run "rm -rf #{release_path}; true"
    }
    strategy.deploy!
    finalize_update
  end
end

after :deploy, "deploy:cleanup"

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

after :deploy, "passenger:restart"

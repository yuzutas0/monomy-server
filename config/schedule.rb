#===============================================
#     check
#-----------------------------------------------
# $ bundle exec whenever 
# $ bundle exec crontab -e
#===============================================
#     update
#-----------------------------------------------
# $ bundle exec whenever --update-crontab
#===============================================
#     delete
#-----------------------------------------------
# $ bundle exec whenever --clear-crontab
#-----------------------------------------------

# environment
rails_env = ENV['RAILS_ENV'] || :development
set :environment, rails_env

# log
set :output, 'log/cron.log'

# ruby
env :PATH, ENV['PATH']
job_type :rbenv_runner, %q[eval "$(rbenv init -)" && cd :path && bin/rails runner -e :environment ':task' :output]
# => rbenv_init + [runner](https://github.com/javan/whenever)

# batch
every '0 * * * *' do
	rbenv_runner "Crawls::Manager.execute"
end
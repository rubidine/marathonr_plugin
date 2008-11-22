# Copyright (c) 2008 Todd Willey <todd@rubidine.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# desc "Explaining what the task does"
# task :marathonr do
#   # Task goes here
# end

namespace :marathonr do

  desc 'Generate the marathonr.config file in RAILS_ROOT'
  task :generate_config => [:environment] do

    conf = File.join(RAILS_ROOT, 'marathonr.config')
    if File.exist?(conf)
      puts "#{conf} exists, doing nothing."
    else
      env = ENV['RAILS_ENV'] || 'development'
      db = YAML.load(File.read(File.join(RAILS_ROOT, 'config', 'database.yml')))
      db = db[env]

      if !db or !db.is_a?(Hash)
        abort "Unable to load database configuration"
      end

      db[:worker_dir] = 'lib/workers'

      puts "Writing #{conf}"
      File.open(conf, 'w'){|f| f << db.to_yaml}
    end
  end

  desc 'run migrations'
  task :migrate => [:generate_config] do
    puts `cd #{RAILS_ROOT} && marathonr_migrate`
  end
end

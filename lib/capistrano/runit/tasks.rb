require 'capistrano'

module Capistrano
  module Runit
    module Tasks
      def self.load_into(configuration)
        configuration.load do
          def set_default(name, *args, &block)
            set(name, *args, &block) unless exists?(name)
          end

          set_default(:runit_script_contents) { abort "Please specify the contents of your runit script, set :runit_script_contents" }
          set_default(:force_runit)           { true }
          set_default(:runit_app_dir)         { "/etc/sv/#{application}" }
          set_default(:runit_bin_dir)         { "/usr/local/bin" }
          set_default(:sv)                    { "#{runit_bin_dir}/sv" }

          namespace :runit do
            # uploads a file and moves it into place via sudo
            def put_sudo(data, to)
              filename = File.basename(to)
              to_directory = File.dirname(to)
              put data, "/tmp/#{filename}"
              run "#{sudo} mv -f /tmp/#{filename} #{to_directory}"
            end

            # Checks whether a file exists on the remote server
            def remote_file_exists?(fname)
              results = []

              invoke_command("if [ -e '#{path}' ]; then echo -n 'true'; fi") do |ch, stream, out|
                results << (out == 'true')
              end

              results.all?
            end

            desc "Starts runit on each host"
            task :start do
              run "#{sudo} start runsvdir"
            end

            desc "Creates a runit configuration for the service on the target"
            task :setup do
              run "#{sudo} mkdir -p #{runit_app_dir}/supervise"

              if force_runit || !remote_file_exists?("#{runit_app_dir}/run")
                put_sudo runit_script_contents, "#{runit_app_dir}/run"
                run "#{sudo} chmod 755 #{runit_app_dir}/run"
              end

              run "#{sudo} mkdir -p /service"

              if force_runit || !remote_file_exists?("/service/#{application}")
                run "#{sudo} ln -f -s #{runit_dir} /service/#{application}"
              end
            end

            %w[start stop shutdown force_stop force_shutdown].each do |cmd|
              desc "#{cmd} the application"
              task "#{cmd}_app".to_sym do
                sv_command = cmd.gsub('_', '-')
                run "#{sudo} #{sv} #{sv_command} #{application}"
              end
            end
            
            after "deploy:setup", "runit:setup"
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Runit::Tasks.load_into(Capistrano::Configuration.instance)
end



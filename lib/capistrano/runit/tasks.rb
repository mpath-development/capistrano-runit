require 'capistrano'

Capistrano::Configuration.instance.load do
  _cset(:runit_script_contents) { abort "Please specify the contents of your runit script, set :runit_script_contents" }

  namespace :runit do
    desc "Starts runit on each host"
    task :start do
      run "#{sudo} start runsvdir"
    end

    desc "Creates a runit configuration for the service on the target"
    task :setup do
      run "#{sudo} mkdir -p #{runit_dir}/supervise"

      if force_runit || !remote_file_exists?("#{runit_dir}/run")
        put_sudo runit_run_contents, "#{runit_dir}/run"
        run "#{sudo} chmod 755 #{runit_dir}/run"
      end

      run "#{sudo} mkdir -p /service"

      if force_runit || !remote_file_exists?("/service/#{application}")
        run "#{sudo} ln -f -s #{runit_dir} /service/#{application}"
      end
    end
    
    after "deploy:setup", "runit:setup"
  end
end


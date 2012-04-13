chef_repo_dir = File.expand_path( "../", File.dirname(__FILE__) )

client_key               "#{chef_repo_dir}/.chef/client.pem"
log_level                :info
log_location             STDOUT
cache_type               "BasicFile"
cookbook_path            [ "#{chef_repo_dir}/cookbooks" ]

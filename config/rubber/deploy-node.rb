
namespace :rubber do

  namespace :node do
  
    rubber.allow_optional_tasks(self)
  
    after "rubber:install_packages", "rubber:node:custom_install"
    
    task :custom_install, :roles => :node do
      rubber.sudo_script 'install_node', <<-ENDSCRIPT
        # check if already exists
        if [ -x /usr/local/bin/node ]
          then echo 'Found node on installed on system'
          if /usr/local/bin/node --version | grep '#{rubber_env.node_version}'
            then echo 'Sphinx version matches, no further steps needed'
            exit 0
          fi
        fi
        
        TMPDIR=`mktemp -d` || exit 1
        cd $TMPDIR
        wget -qN http://nodejs.org/dist/v#{rubber_env.node_version}/node-v#{rubber_env.node_version}.tar.gz
        tar zxvf node-v#{rubber_env.node_version}.tar.gz
        cd node-v#{rubber_env.node_version}
        ./configure
        make
        make install
        cd ; rm -rf $TMPDIR
      ENDSCRIPT
    end    
  end
end

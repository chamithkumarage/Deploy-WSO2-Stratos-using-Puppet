#
# Copyright (c) 2005-2012, WSO2 Inc. (http://www.wso2.org) 
# All Rights Reserved.
#

class stratos_lb ( $fronted_services, $maintenance_mode=true ) inherits system_config {
	$service_code = "lb"
	$service_dir = "wso2$service_code-$lb_version"
	
	$kill_command = "kill -9 `cat /mnt/$server_ip/$service_dir/wso2carbon.pid`"

	tag ("lb")

	file { "/mnt/$server_ip/$service_dir/":
                owner   => root,
                group   => root,
                source  => ["puppet:///stratos_lb/configs/",
			    "puppet:///stratos_lb/patches/"],
		sourceselect => all,
                ensure  => present,
                recurse => true,
                require => Exec["init_lb"],
        }

	file { "/mnt/$server_ip/$service_dir/repository/conf/loadbalancer.xml":
		owner   => root,
                group   => root,
                mode    => 755,
                content	=> template("lb/loadbalancer.xml.erb"),
                require => File["/mnt/$server_ip/$service_dir/"],
        }
	
	file { "/mnt/$server_ip/$service_dir/repository/conf/axis2.xml":
		owner   => root,
                group   => root,
                mode    => 755,
                content	=> template("lb/axis2.xml.erb"),
                require => File["/mnt/$server_ip/$service_dir/"],
        }

	exec { "remove_lb_poop":
                path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/",
                unless  => "test ! -d /mnt/$server_ip/$service_dir/repository/",
		command => $maintenance_mode ? {
                                "true" => "$kill_command ; /bin/echo Killed",
                                "false" => "$kill_command ; rm -rf /mnt/$server_ip/$service_dir",
                           },
                require => File["/opt/bin/init.sh"],
        }	

	exec { "init_lb":
		command => $maintenance_mode ? {
                                "true" => "/bin/echo In maintenance mode",
                                "false" => "/opt/bin/init.sh $service_code",
                           },
		creates => "/mnt/$server_ip/$service_dir/README.txt",
		require => Exec["remove_lb_poop"],
	}

	file { "/mnt/$server_ip/$service_dir/bin/wso2server.sh":
                owner   => root,
                group   => root,
                mode    => 755,
                content => template("lb/wso2server.sh.erb"),
                ensure  => present,
                require => File["/mnt/$server_ip/$service_dir/"],
        }
	

	exec { "start_lb":
		path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/",
		command	=> "/mnt/$server_ip/$service_dir/bin/wso2server.sh > /dev/null &2>1",
		creates	=> "/mnt/$server_ip/$service_dir/repository/wso2carbon.log",
		require => [ Exec["remove_lb_poop"], 
			     File["/mnt/$server_ip/$service_dir/repository/conf/loadbalancer.xml"],
			     File["/mnt/$server_ip/$service_dir/repository/conf/loadbalancer.xml"] ],
	}
	
	exec { "remove_autoscaler":
		path	=> "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/",
		command	=> "rm -f /mnt/$server_ip/$service_dir/repository/deployment/server/synapse-configs/default/tasks/autoscaler.xml",
		require	=> [ Exec["init_lb"], 
			     Exec["start_lb"],
			     File["/mnt/$server_ip/$service_dir/"],
			     File["/mnt/$server_ip/$service_dir/repository/conf/axis2.xml"], 
			     File["/mnt/$server_ip/$service_dir/repository/conf/loadbalancer.xml"] ],
	}
}

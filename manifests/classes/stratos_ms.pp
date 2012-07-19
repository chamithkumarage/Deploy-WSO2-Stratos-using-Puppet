#
# Copyright (c) 2005-2012, WSO2 Inc. (http://www.wso2.org) 
# All Rights Reserved.
#

class stratos_ms ( $offset=0, $tribes_port=4000, $config_db=governance, $maintenance_mode=true ) inherits system_config {
	
	$service_code = "ms"
	$service_dir = "wso2stratos-$service_code-$stratos_version"	
	$service_templates = ["registry.xml","axis2.xml","carbon.xml","advanced/authenticators.xml"]
	$common_templates = ["cache.xml","cloud-services-desc.xml","identity.xml","throttling-agent-config.xml","user-mgt.xml"]

	$kill_command = "kill -9 `cat /mnt/$server_ip/$service_dir/wso2carbon.pid`"	

	tag ("ms")

	define run_template ( $directory ) {

		file { "/mnt/$server_ip/$service_dir/repository/conf/$name":
	                owner   => root,
	                group   => root,
	                mode    => 755,
	                content => template("${directory}/${name}.erb"),
	                ensure  => present,
                	require => File["/mnt/$server_ip/$service_dir/"],
        	}

	}

	file { "/mnt/$server_ip/$service_dir/":
                owner   => root,
                group   => root,
                source  => ["puppet:///stratos_commons/configs/",
			    "puppet:///stratos_commons/patches/",
			    "puppet:///stratos_${service_code}/configs/",
			    "puppet:///stratos_${service_code}/patches/"],
		sourceselect => all,
                ensure  => present,
		recurse	=> true,
                require => Exec["init_ms"],
        }		

	run_template { $service_templates: 
		directory => "$service_code",
	}

	run_template { $common_templates:
		directory => "commons",
	}
	
	file { "/mnt/$server_ip/$service_dir/bin/wso2server.sh":
                owner   => root,
                group   => root,
                mode    => 755,
                content => template("commons/wso2server.sh.erb"),
                ensure  => present,
                require => File["/mnt/$server_ip/$service_dir/"],
        }
	
	exec { "remove_ms_poop":
                path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/",
                unless  => "test ! -d /mnt/$server_ip/$service_dir/repository",
		command => $maintenance_mode ? {
                                "true" => "$kill_command ; /bin/echo Killed",
                                "false" => "$kill_command ; rm -rf /mnt/$server_ip/$service_dir",
                           },
                require => File["/opt/bin/init.sh"],
        }

	exec { "init_ms":
		command => $maintenance_mode ? {
                                "true" => "/bin/echo In maintenance mode",
                                "false" => "/opt/bin/init.sh $service_code",
                           },
		timeout	=> 0,
                require => Exec["remove_ms_poop"],
        }

	exec { "start_$service_code":
                path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/",
                command => "/mnt/$server_ip/$service_dir/bin/wso2server.sh > /dev/null &2>1",
                creates => "/mnt/$server_ip/$service_dir/repository/wso2carbon.log",
                require => [ File["/mnt/$server_ip/$service_dir/"], run_template[$service_templates], run_template[$common_templates] ],
        }
}


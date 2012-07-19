class system_config {

	file { "/opt/bin":
                owner   => root,
                group   => root,
                ensure  => "directory",
        }

        file { "/opt/bin/init.sh":
                ensure  => present,
                owner   => root,
                group   => root,
                mode    => 0755,
                content => template("init.sh.erb"),
                require => File["/opt/bin"],
        }
	
	file { "/root/bin":
		owner	=> root,
		group	=> root,
		ensure	=> "directory";
	}

	file { "/root/bin/puppet_init.sh":
		owner	=> root,
		group	=> root,
		mode	=> 0755,
		source	=> "puppet:///stratos_commons/bin/puppet_init.sh",
		require	=> File["/root/bin"],
	}

	file { "/root/bin/puppet_clean.sh":
		owner   => root,
                group   => root,
                mode    => 0755,
		content => template("puppet_clean.sh.erb"),
		require => File["/root/bin"],
	}

        Exec {  path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/"  }
}


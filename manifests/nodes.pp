stage { 'configure': require => Stage['main'] }
stage { 'deploy': require => Stage['configure'] }

node basenode {
	$stratos_version = "1.5.2"
	$lb_version = "1.0.2"
}

node confignode inherits basenode  {
	
	$packs_repo = "http://puppetmaster.private.wso2.com/slive/packs/1.5.2_fresh/"

	$stratos_domain = "stratos.your_domain.com"
	$as_subdomain = "appserver"
	$bam_subdomain = "monitor"
	$bps_subdomain = "process"
	$brs_subdomain = "rule"
	$cep_subdomain = "cep"
	$dss_subdomain = "data"
	$esb_subdomain = "esb"
	$gs_subdomain = "gadget"
	$governance_subdomain = "governance"
	$is_subdomain = "identity"
	$mb_subdomain = "messaging"
	$ms_subdomain = "mashup"

	$mysql_server_1 = "mysql.stratos.your_domain.com"	
	$mysql_server_2 = "mysql.stratos.your_domain.com"	
	$mysql_root_password = "rootRoot"
	$mysql_port = "3306"
	$max_connections = "100000"
	$max_active = "150"
	$max_wait = "360000"
	
	$registry_user = "registry"
	$registry_password = "registry"
	$registry_database = "governance"

	$billing_user = "billing"
	$billing_password = "billing"
	$billing_database = "billing"

	$userstore_user = "userstore"
	$userstore_password = "userstore"
	$userstore_database = "userstore"

	$bps_user = "bps"
	$bps_password = "bps"
	$bps_database = "bps"
	
	$rss_user = "rss"
	$rss_password = "rss"	
	$rss_database = "rss_db"

	$backup_user = "backup"
	$backup_password = "backup"
}


#### STRATOS NODES ####

node 'stratosnodeA' inherits confignode {
	$server_ip = "192.168.4.111"

	include hosts
        
	class {"stratos_lb":
                fronted_services  => ["appserver","identity","process","monitor","rule","esb"],
                stage => "deploy",
                maintenance_mode => "true",
        }
	
	class {"stratos_as":
                offset => 1,
                tribes_port => 4100,
                config_db => "appserver_config",
		maintenance_mode => "true",
                stage => "deploy",
        }
	
	class {"stratos_is":
                offset => 2,
                tribes_port => 4200,
                config_db => "identity_config",
		maintenance_mode => "true",
                stage => "deploy",
        }
	
	class {"stratos_bam":
                offset => 3,
                tribes_port => 4300,
                config_db => "bam_config",
		maintenance_mode => "true",
                stage => "deploy",
        }
	
	class {"stratos_esb":
                offset => 4,
                tribes_port => 4400,
                config_db => "esb_config",
		maintenance_mode => "true",
                stage => "deploy",
        }
	
	class {"stratos_brs":
                offset => 5,
                tribes_port => 4500,
                config_db => "brs_config",
		maintenance_mode => "true",
                stage => "deploy",
        }
	
	class {"stratos_bps":
                offset => 6,
                tribes_port => 4600,
                config_db => "bps_config",
		maintenance_mode => "true",
                stage => "deploy",
        }
	
}


node 'stratosnodeB' inherits confignode {
	$server_ip = "192.168.4.112"

	include hosts
	
	class {"stratos_lb":
                fronted_services  => ["cep","message","governance","manager","gadget","mashup","data"],
                stage => "deploy",
                maintenance_mode => "true",
        }
        
	class {"stratos_cep":
                offset => 1,
                tribes_port => 4100,
                config_db => "cep_config",
                maintenance_mode => "true",
                stage => "deploy",
        }
        
	class {"stratos_mb":
                offset => 2,
                tribes_port => 4200,
                config_db => "mb_config",
                maintenance_mode => "true",
                stage => "deploy",
        }
        
	class {"stratos_governance":
                offset => 3,
                tribes_port => 4300,
                config_db => "governance_config",
                maintenance_mode => "true",
                stage => "deploy",
        }
        
	class {"stratos_gs":
                offset => 4,
                tribes_port => 4400,
                config_db => "gadget_config",
                maintenance_mode => "true",
                stage => "deploy",
        }
        
	class {"stratos_ms":
                offset => 5,
                tribes_port => 4500,
                config_db => "mashup_config",
                maintenance_mode => "true",
                stage => "deploy",
        }
        
	class {"stratos_dss":
                offset => 6,
                tribes_port => 4600,
                config_db => "dss_config",
                maintenance_mode => "true",
                stage => "deploy",
        }
        
	class {"stratos_manager":
                offset => 7,
                tribes_port => 4700,
                config_db => "manager_config",
                maintenance_mode => "true",
                stage => "deploy",
        }
	
}


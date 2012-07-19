#
# Copyright (c) 2005-2012, WSO2 Inc. (http://www.wso2.org) 
# All Rights Reserved.
#

class hosts {
    file { "/etc/hosts":
        owner   => root,
        group   => root,
        mode    => 775,
        content	=> template("hosts.erb"),
    }
}

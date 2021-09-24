local mysql_conf = {
	default = {
		host = "192.168.8.204",
		user = 'root',
		password = '',
		database = 'test',
		port = 3306,
	},
	tank = {
                host = "192.168.8.204",
                user = 'root',
                password = '',
                database = 'tank',
                port = 3306,
        }
}

return mysql_conf

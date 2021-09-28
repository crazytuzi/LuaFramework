--mysql.lua,提供mysql数据库访问功能

function mysql_init(dsn, user, pwd, host, port)
	local open_fun, code = package.loadlib("libluasql.so", "luaopen_luasql_mysql")
	if open_fun then
		--初始化mysql
		open_fun()
		local mysql = {}
		mysql_connect(mysql, dsn, user, pwd, host, port)
		return mysql
	end
	print("mysql init failed because:", code)
end

function mysql_close(mysql)
	if mysql._env then
		if mysql._con then
			mysql._con:close()
			mysql._con = nil
		end
		mysql._env:close()
		mysql._env = nil
	end
	mysql = nil
end

function mysql_connect(mysql, dsn, user, pwd, host, port)
	mysql._env = luasql.mysql()
	if mysql._env then
	--	local con = mysql_env:connect("cogame", "root", "", "localhost", 3306)
		mysql._con, code = mysql._env:connect(dsn, user, pwd, host, port or 3306)
		if not mysql._con then
			print(string.format("mysql.connect() failed, dsn(%s), user(%s), pwd(%s), host(%s), port(%d), result(%s)", dsn, user, pwd, host, port, code))
		end
	end
	return mysql._con ~= nil
end

function mysql_callSQL(mysql, sql)
	if mysql and mysql._con then
		--local cur = con:execute ("SELECT * from rolegroup")
		local cur, code = mysql._con:execute(sql)
		if cur then
			if type(cur) == "userdata" then
				local ret = {}
				local row = cur:fetch ({}, "a")
				while row do
					table.insert(ret, row)
					row = cur:fetch ({}, "a")
				end
				cur:close()
				return true, ret
			end
			return true, cur
		else
			print(string.format("mysql,execute() failed, sql(%s), result(%s)", sql, code))
			return false
		end
	end
	print(string.format("mysql,execute() failed, sql(%s), mysql object is nil", sql, code))
	return false
end

function mysql_callSP(mysql, sql, outsql)
	local code, records = mysql_callSQL(mysql, sql)
	if code then
		local outs = nil
		if outsql then
			--outsql = "select @id"
			local outCode, rows = mysql_callSQL(outsql)
			if outCode then
				outs = rows
			end
		end
		return code, records, outs
	end
	return false
end


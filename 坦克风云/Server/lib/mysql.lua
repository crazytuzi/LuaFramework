-- load driver
local luasql = require "luasql.mysql"

local mysql = {
	query = "",
	last_query_str="",
	queryResult,
	err
}

function mysql:connect(user,password,database,host,port)
    self.env = assert (luasql.mysql())
    self.conn,self.err = self.env:connect(database, user,password,host,port)
    if not self.conn then 
    	if not self.env:close() then
             self.err = tostring(self.err) .. "| couldn't close environment object"
        end
    	error(self.err) 
    end
end

function mysql:sanitize (value) 
	local valueType = type(value)

	if valueType == 'table' then
		value =  json.encode(value)
		value = "'" .. self.conn:escape(value) .. "'"
	elseif valueType == 'string' then
		value = "'" .. self.conn:escape(value) .. "'"
	elseif value == nil then
		value = "''"
	end
	  
    return value
end

function mysql:escape(value)
	return self.conn:escape(value)
end

function mysql:query(sql)
	self.last_query_str = sql
	local cur, err = self.conn:execute(sql)
	if not cur then
	    self.err = err
	    local errlog = {
	    	err = err,
	    	sql = sql,
		}
		writeLog(errlog,'sqlerror')
	end
	
	self.queryResult = cur
    return cur
end

function mysql:getQueryString()
    return self.last_query_str
end

function mysql:getError()
    return self.err
end

function mysql:fetchRow(result)	
  	return self:fetchAllRows(result)[1]
end
	
function mysql:getRow(sql,params)
	
	if type (params) == 'table' then
		for k,v in pairs (params) do
			v = self:sanitize(v)
			sql = string.gsub(sql,':' .. k,v)
		end
	end
	
	local query= self:query(sql)
	if query then
		local result = self:fetchRow(query)
		return result
	end
	return false
end

function mysql:fetchAllRows(result)
	if not result then
		result = self.queryResult
	end
	
	local data={}
    local row = result:fetch ({}, "a")	-- the rows will be indexed by field names
	while row do
	    table.insert(data,row)
	    row = result:fetch ({}, "a")	-- reusing the table of results
	end
	
	return data
end	

function mysql:getAllRows(sql,params)
	
	if type (params) == 'table' then
		for k,v in pairs (params) do
			v = self:sanitize(v)
			sql = string.gsub(sql,':' .. k,v)
		end
	end
	
	local query= self:query(sql)
	if query then
		local result = self:fetchAllRows(query)
		return result
	end
	return false
end

function mysql:insert(tablename,data)
	if type(data)~="table" then
		return false
	end
	local fields,values = {},{}
	for k,v in pairs (data) do
		table.insert(fields,k)
		table.insert(values,self:sanitize(v))
	end
	
	if #fields == 0 or #values == 0 then
		return false
	end

	local sql = "INSERT INTO "..tablename..' ( ' .. table.concat(fields,' , ' ) .. ' ) VALUES ( ' .. table.concat(values,' , ') .. ')'
    

	return self:query(sql)
    	-- if self:query(sql) then
    	-- 	return self.conn:getlastautoid()
    	-- end
end

function mysql:getlastautoid()
	return self.conn:getlastautoid()
end

function mysql:update(tablename,data,conditions)
	if type(data)~="table" then
		return false
	end
	
	local where
	if type(conditions) == "table" then
		local whereParams = {}
		for _,column in pairs(conditions) do
			table.insert(whereParams,column .. '=' .. self:sanitize(data[column]))
			-- data[column] = nil
		end
		where = table.concat(whereParams," and ")
	else
		where = conditions
	end

	local params = {}
	for k,v in pairs (data) do
		table.insert(params,k .. '=' .. self:sanitize(v))
	end

	if not #params == 0 then
		return false
	end

	local sql = 'UPDATE ' .. tablename .. ' SET ' .. table.concat(params," , ") .. " WHERE " .. where
    return self:query(sql)		
end

function mysql:replace(tablename,data)
	if type(data)~="table" then
		return false
	end
	
	local fields,values = {},{}
	for k,v in pairs (data) do
		table.insert(fields,k)
		table.insert(values,self:sanitize(v))
		--table.insert(values,v)
	end
	
	if #fields == 0 or #values == 0 then
		return false
	end

	local sql = "REPLACE INTO "..tablename..' ( ' .. table.concat(fields,' , ' ) .. ' ) VALUES ( ' .. table.concat(values,' , ') .. ')'
    return self:query(sql)		
end

function mysql:close()
	if self.conn then
		assert (self.conn:close () == true, "couldn't close cursor object")
		self.conn = nil
	end
	if self.env then 
		assert (self.env:close () == true, "couldn't close environment object")
		self.env = nil
	end
end

return mysql


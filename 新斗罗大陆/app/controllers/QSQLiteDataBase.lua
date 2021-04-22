local QSQLiteDataBase = class("QSQLiteDataBase")

require("pack")
local lsqlite3 = require("lsqlite3")

QSQLiteDataBase.SQLITE_OK           =	0 --Successful result 
-- beginning-of-error-codes 
QSQLiteDataBase.SQLITE_ERROR 		=	1 --SQL error or missing database 
QSQLiteDataBase.SQLITE_INTERNAL 	=	2 --Internal logic error in SQLite 
QSQLiteDataBase.SQLITE_PERM 		=	3 --Access permission denied 
QSQLiteDataBase.SQLITE_ABORT 		=	4 --Callback routine requested an abort 
QSQLiteDataBase.SQLITE_BUSY 		=	5 --The database file is locked 
QSQLiteDataBase.SQLITE_LOCKED 		=	6 --A table in the database is locked 
QSQLiteDataBase.SQLITE_NOMEM 		=	7 --A malloc() failed 
QSQLiteDataBase.SQLITE_READONLY 	=	8 --Attempt to write a readonly database 
QSQLiteDataBase.SQLITE_INTERRUPT 	=	9 --Operation terminated by sqlite3_interrupt()
QSQLiteDataBase.SQLITE_IOERR 		=	10 --Some kind of disk I/O error occurred 
QSQLiteDataBase.SQLITE_CORRUPT 		=	11 --The database disk image is malformed 
QSQLiteDataBase.SQLITE_NOTFOUND 	=	12 --Unknown opcode in sqlite3_file_control() 
QSQLiteDataBase.SQLITE_FULL 		=	13 --Insertion failed because database is full 
QSQLiteDataBase.SQLITE_CANTOPEN 	=	14 --Unable to open the database file 
QSQLiteDataBase.SQLITE_PROTOCOL 	=	15 --Database lock protocol error 
QSQLiteDataBase.SQLITE_EMPTY 		=	16 --Database is empty 
QSQLiteDataBase.SQLITE_SCHEMA 		=	17 --The database schema changed 
QSQLiteDataBase.SQLITE_TOOBIG 		=	18 --String or BLOB exceeds size limit 
QSQLiteDataBase.SQLITE_CONSTRAINT 	=  	19 --Abort due to constraint violation 
QSQLiteDataBase.SQLITE_MISMATCH 	=	20 --Data type mismatch 
QSQLiteDataBase.SQLITE_MISUSE 		=	21 --Library used incorrectly 
QSQLiteDataBase.SQLITE_NOLFS 		=	22 --Uses OS features not supported on host 
QSQLiteDataBase.SQLITE_AUTH 		=	23 --Authorization denied 
QSQLiteDataBase.SQLITE_FORMAT 		=	24 --Auxiliary database format error 
QSQLiteDataBase.SQLITE_RANGE 		=	25 --2nd parameter to sqlite3_bind out of range 
QSQLiteDataBase.SQLITE_NOTADB 		=	26 --File opened that is not a database file 
QSQLiteDataBase.SQLITE_NOTICE 		=	27 --Notifications from sqlite3_log() 
QSQLiteDataBase.SQLITE_WARNING 		=	28 --Warnings from sqlite3_log() 
QSQLiteDataBase.SQLITE_ROW 			=	100--sqlite3_step() has another row ready 
QSQLiteDataBase.SQLITE_DONE 		=	101--sqlite3_step() has finished executing 

function QSQLiteDataBase:sharedDatabase()
	if app._sql == nil then
        app._sql = QSQLiteDataBase.new()
    end
    return app._sql
end

function QSQLiteDataBase:ctor()
	self:open("staticdata")
end

function QSQLiteDataBase:open(path)
	if self:isopen() then 
		printf("database is opening")
		return 
	end
	-- self._database = lsqlite3.open(path)
	self._database = lsqlite3.open_memory(path)
	-- self:tableIsExist("user")
	-- self:deleteTable("user")
	-- self:createTable("create table user(id integer,username text,password text)", "user")
	-- self:tableIsExist("index")
end

function QSQLiteDataBase:isopen()
	if self._database == nil then return false end
	return self._database:isopen()
end

--表是否存在
function QSQLiteDataBase:tableIsExist(tableName, callback)
	if self._database == nil then return false end
	local sql = "select count(type) from sqlite_master where type='table' and name ='"..tableName.."'"
	local result = self:exec(sql, "tableIsExist", function (udata,cols,values,names)
		if udata == "tableIsExist" then
			if callback then callback(values[1] == "1") end
		end
	end)
end

--创建表
function QSQLiteDataBase:createTable(sql, name)
	if self._database == nil then return false end
	local result = self:exec(sql, "createTable")
	print("creat: ",name,result)
end

--删除表
function QSQLiteDataBase:deleteTable(name)
	if self._database == nil then return false end
	local sql = "DROP TABLE "..name
	local result = self:exec(sql, "deleteTable")
	print("delete: ",name,result)
end

--执行sql
function QSQLiteDataBase:exec(sql, name, callback)
	if callback == nil then callback = handler(self,self.createTableResult) end
	return self._database:exec(sql, callback, name)
end

--sql回调
function QSQLiteDataBase:createTableResult(udata,cols,values,names)
	print(udata)
  	print('exec:')
  	for i=1,cols do print('',names[i],values[i]) end
  	return 0
end

--创建表
function QSQLiteDataBase:createTableWithConfig(keys, tables, names)
	--判断表是否存在，存在则删除
	local _isExist = nil
	self:tableIsExist(names, function (isExist)
		_isExist = isExist
	end)
	if _isExist == true then
		self:deleteTable(names)
	end

	--表的字段类型查询
	local types = {}
	local checkTypeFun = function (tbls)
		for index,value3 in ipairs(tbls) do
			if types[index] == nil and value3 ~= nil then
				types[index] = self:getTypeByValue(value3)
			elseif types[index] ~= self:getTypeByValue(value3) then
				types[index] = "BLOB"
			end
		end
	end
	for _,value in pairs(tables) do
		if type(value[1]) == "table" then
			for index,value2 in ipairs(value) do
				checkTypeFun(value2)
			end
		else
			checkTypeFun(value)
		end
	end

	--组建创建表的sql语句
	local sql = "create table "..names.."("
	local totalKey = table.nums(keys)
	-- local _keys = {}
	local _types = {}
	-- for key,index in pairs(keys) do
	-- 	_keys[index] = key
	-- end
	for index,key in ipairs(keys) do
		local typeName = types[index] or "TEXT"
		_types[index] = typeName
		sql = sql..key.." "..typeName
		if index == totalKey then
			sql = sql..")"
		else
			sql = sql .. ","
		end
	end
	self:createTable(sql, names)
	--插入数据
	local insertSql = {}
	local insertTableFun = function (tbl)
		local insertName = ""
		local insertValue = ""
		local isFrist = true
		for index,key in ipairs(keys) do
			local _value = tbl[index]
			if _value ~= nil then
				if _types[index] == "TEXT" then
					-- _value = string.gsub(_value,",","，")
					_value = "'"..tostring(_value).."'"
				end
				if isFrist == false then
					insertName = insertName..","..key
					insertValue = insertValue..","..tostring(_value)
				else
					isFrist = false
					insertName = insertName..key
					insertValue = insertValue..tostring(_value)
				end
			end
		end
		table.insert(insertSql, "INSERT INTO "..names.." ("..insertName..")  VALUES ("..insertValue..")")
	end
	for _,value in pairs(tables) do
		if type(value[1]) == "table" then
			for index,value2 in ipairs(value) do
				insertTableFun(value2)
			end
		else
			insertTableFun(value)
		end
	end
	if #insertSql > 0 then
		self._database:exec('BEGIN') 
		for _,sql in ipairs(insertSql) do
			self._database:exec(sql)
		end
		self._database:exec('COMMIT') 
	end
end

--获取类型
-- "nil"，"number", "string", "boolean", "table", "function", "thread", "userdata"
--INTEGER, REAL, TEXT, BLOB
function QSQLiteDataBase:getTypeByValue(value)
	if type(value) == "boolean" then 
		return "INTEGER"
	end
	if type(value) == "number" then 
		return "REAL"
	end
	if type(value) == "nil" or type(value) == "string" or type(value) == "table" or type(value) == "function" or type(value) == "thread"  or type(value) == "userdata" then 
		return "TEXT"
	end
end

return QSQLiteDataBase
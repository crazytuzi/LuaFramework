--------------------------------------------------------------------------------------
-- 文件名:	Class_DbMgr.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-5-29 11:24
-- 版  本:	1.0
-- 描  述:	物品
-- 应  用:  基类
---------------------------------------------------------------------------------------

--创建CDbMgr类
Class_DbMgr = class("Class_DbMgr")
Class_DbMgr.__index = Class_DbMgr

function Class_DbMgr:create()
	local instance = Class_DbMgr.new()
	instance.sqlite3 = require("sqlite3")
	instance.Db = instance.sqlite3.open(CCFileUtils:sharedFileUtils():getWritablePath().."/XXZGame.db")
	return instance
end

function Class_DbMgr:exec(szSQL)
	if not self.Db then return end
	return self.Db:exec(szSQL) --0:成功
end

function Class_DbMgr:closeDB()
	if not self.Db then return end
	self.Db:close()
end

function Class_DbMgr:showTest()
	local db = self.Db
	--local db = sqlite3.open_memory()
    local tb = {a = "asd",b = "as"}
	db:exec[[
	  CREATE TABLE test1 (id INTEGER PRIMARY KEY, content BLOB);
	]]
	str = "Hello World\0sdas"
	cclog(str)
	cclog(string.find(str,"sdas"))
	str = string.gsub(str,"\0","")
	cclog(str)
	self:insert("test1", 13, str)
	self:insert("test1", 12, "adsfsads")

	for row in db:nrows("SELECT COUNT(*) FROM test1") do
        cclog(row["COUNT(*)"])
	end
    for row in db:nrows("SELECT * FROM test1") do
		cclog(row.id..row.content)
	end
end

function Class_DbMgr:createLogDb()
	local db = self.Db
	db:exec[[
	  CREATE TABLE IF NOT EXISTS logDB(id INTEGER PRIMARY KEY, uin INTEGER, areaid INTEGER,  time TEXT, value TEXT);
	]]
end

function Class_DbMgr:logToDB(szText)
	local szSQL = nil
    local szText = string.gsub(szText,"'","\"")
	local dateText = os.date("%c")
    local tbServer = g_DataMgr:getSeverInfoCsv(self.nCsvID)
	if(g_MsgMgr and g_MsgMgr:getUin() and tbServer.AreaID)then
		szSQL = "INSERT INTO logDB VALUES (NULL,"..g_MsgMgr:getUin()..","..tbServer.AreaID..",'"..dateText.."','"..szText.."');"
	else
		szSQL = "INSERT INTO logDB VALUES (NULL, -1, -1,'"..dateText.."','"..szText.."');"
	end
	
	self.Db:exec(szSQL)
end

function Class_DbMgr:getDB()
	return self.Db
end

function Class_DbMgr:closeDB()
	self.Db:close()
end

function dblog(szText)
	g_DbMgr:logToDB(szText)
end

--add by zgj
function Class_DbMgr:insert(tableName, ...)
	local str = ""
	local nNum = select('#', ...)
	for i = 1, nNum do
        local arg = select(i, ...)
        if not arg then
        	break
        end
        if type(arg) == "string" then
            arg = "'"..arg.."'"
        end
		str = str..arg..","
	end
	str = string.sub(str, 1, string.len(str) - 1)
	local sql = "INSERT INTO "..tableName.." VALUES ("..str..")"
	return self.Db:exec(sql)   --0:成功
end
--over


-----------------------------------------------------
--[[ 		]]
-----------------------------------------------------
--创建本地DB纪录
--RecordName
--return 0:成功
function Class_DbMgr:CreateRecordDB(RecordName)
	if not self.Db then return end
	if RecordName ==  nil or RecordName == "" then return 1 end

	return self:exec("create table if not exists "..RecordName..[[ (
				id INTEGER PRIMARY KEY, 
				buffer TEXT)
			]])
end


--更新本地纪录的 
--return 0:成功
function Class_DbMgr:UpdateRecordDB(RecordName, key, value)
	if not self.Db then return end
	if type(value) == "table" then
		return self:exec("update "..RecordName.." set buffer ='"..tableToString(value).."' where id ="..key)
	else
		return self:exec("update "..RecordName.." set buffer ='"..value.."' where id ="..key)
	end

	return 1
end


--删除本地纪录
--return 0:成功
function Class_DbMgr:DeleteRecordDB(RecordName, key)
	if not self.Db then return end
	return self:exec("delete from "..RecordName.." where id ="..key)
end


--获取本地纪录行数
function Class_DbMgr:GetRecordDBRow(RecordName)
	if not self.Db then return end
	return self.Db:nrows("SELECT * FROM "..RecordName)
end


--把服务器的结构体转成本地的可存储的字符串
--[[ 比如  服务器发的数据是这样的：
MsgData = {
["notice_list"]=  {
  {
    ["context"] = "context",
    ["event_id"] = 5,
    ["title"] = "title",
  },
  {
    ["context"] = "context",
    ["event_id"] = 6,
    ["title"] = "title",
  },
},
}
本地药存储的 结构体字符串要必须是 {XXXXXXXX} 所以要截取 11 字符 ；去掉 “MsgData =”
]]
function Class_DbMgr:TableToString(tbServer)
	local szBuffer = tostring(tbServer)
	szBuffer = string.sub(szBuffer,11, string.len(szBuffer))
	return szBuffer
end


--保存在本地的字符串 转换成可以使table
--要转换的字符串必须是 ｛｝格式
function Class_DbMgr:StringToTable(tbStr)
	if loadstring("return "..tbStr) == nil then return nil end
	
	local tb = loadstring("return "..tbStr)()
	return tb
end

function Class_DbMgr:initBaseTable()
	Game_MailBox:initBaseInfo()
end


g_DbMgr = Class_DbMgr:create()

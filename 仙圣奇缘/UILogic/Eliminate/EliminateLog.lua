 --------------------------------------------------------------------------------------
-- 文件名: EliminateLog.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 
-- 日  期:   
-- 版  本:    
-- 描  述:    消除的日志 保存本地数据 50条 显示最新的20条
-- 应  用:  	  log保存格式  color＋string
---------------------------------------------------------------------------------------
local DBLog = "EliminateLog"

------------------------------------------------------------
--[[     ]]
------------------------------------------------------------
EliminateLogItem = class("EliminateLogItem")
EliminateLogItem.__index = EliminateLogItem

function EliminateLogItem:ctor()
	self.color = ccs.COLOR.WHITE
	self.strLog = ""
end


function EliminateLogItem:InitItem(colorIndex, strLog)
	if colorIndex > 8 then return false end

	self.color = g_TbColorType[colorIndex]

	self.strLog = strLog

	return true
end


function EliminateLogItem:GetStrLog()
	return self.strLog
end

function EliminateLogItem:GetColor()
	return self.color
end

--[[
g_TbColorType = {
	[1] = ccs.COLOR.WHITE,				-- 1星 - 白色
	[2] = ccs.COLOR.LIME_GREEN,			-- 2星 - 深绿
	[3] = ccs.COLOR.DARK_SKY_BLUE,		-- 3星 - 深蓝
	[4] = ccs.COLOR.FUCHSIA,			-- 4星 - 洋红
	[5] = ccs.COLOR.GOLD,				-- 5星 - 金色
	[6] = ccs.COLOR.RED,		-- 6星 - 红色
	[7] = ccs.COLOR.RED,			-- 7星 - 红色
	[8] = ccs.COLOR.RED,				-- 8星 - 红色
}
]]
function EliminateLogItem:GetColorIndex()

	if self.color == ccs.COLOR.WHITE then
		return 1

	elseif self.color == ccs.COLOR.LIME_GREEN then
		return 2

	elseif self.color == ccs.COLOR.DARK_SKY_BLUE then
		return 3

	elseif self.color == ccs.COLOR.FUCHSIA then
		return 4

	elseif self.color == ccs.COLOR.GOLD then
		return 5

	elseif self.color == ccs.COLOR.RED then --奇了个怪
		return 6

	elseif self.color == ccs.COLOR.RED then
		return 7

	elseif self.color == ccs.COLOR.RED then
		return 8
	end

	return 1
end




------------------------------------------------------------
--[[     ]]
------------------------------------------------------------
EliminateLog = class("EliminateLog")
EliminateLog.__index = EliminateLog

function EliminateLog:ctor()
	--时时保存 但是性能会很消耗
	self.ontime = false

	self.tbLog = {}
end

function EliminateLog:Init()
	-- if g_DbMgr:CreateRecordDB(DBLog) == 0 then
	-- 	self.tbLog = {}

	-- 	for row  in g_DbMgr:GetRecordDBRow(DBLog)do
	-- 		-- cclog("======EliminateLog:Init======="..row.buffer)

	-- 		--第一个字符呢存颜色下标
	-- 		local colorindex = string.sub(row.buffer,1, 1)
	-- 		-- cclog("EliminateLog:Init state="..colorindex)
	-- 		colorindex = tonumber(colorindex)

	-- 		local strLog = string.sub(row.buffer,2, string.len(row.buffer))
	-- 		-- cclog("EliminateLog:Init strbuffer="..strLog)
		
	-- 		if strLog ~= nil and strLog ~= "" then

	-- 			local LogItem = EliminateLogItem.new()
	-- 			LogItem:InitItem(colorindex, strLog)
	-- 			table.insert(self.tbLog, LogItem)
	-- 		end
	-- 	end

	-- 	return true
	-- end

	return true
end


--返回20条
function EliminateLog:GetLogReverseCount()
	if #self.tbLog > 19 then
		return 20 
	end

	return #self.tbLog
end


--返回最新的数据
function EliminateLog:GetReverseLogByIndex(index)
	if #self.tbLog == 0 then return nil end
	local tin = (#self.tbLog - (index - 1))
	return self.tbLog[tin]
end


function EliminateLog:InsertLog(colorindex, strLog)
	local LogItem = EliminateLogItem.new()
	LogItem:InitItem(colorindex, strLog)

	if #self.tbLog > 29 then
		table.remove(self.tbLog, 1)
		table.insert(self.tbLog, LogItem)

		-- if self.ontime then
		-- 	--重新保存本地数据
		-- 	local index = 1
		-- 	for row  in g_DbMgr:GetRecordDBRow(DBLog)do
		-- 		g_DbMgr:DeleteRecordDB(DBLog, index)
		-- 		index = index + 1
		-- 	end

		-- 	local string_buf = nil
		-- 	for i=1, #self.tbLog do
		-- 		string_buf = string.format("%d%s", self.tbLog[i]:GetColorIndex(), self.tbLog[i]:GetStrLog())
		-- 		g_DbMgr:insert(DBLog, i, string_buf)
		-- 	end
		-- end

	else
		-- if self.ontime then
		-- 	local index = #self.tbLog + 1
		-- 	--保存本地
		-- 	local string_buf = string.format("%d%s", colorindex, strLog)
		-- 	g_DbMgr:insert(DBLog, index, string_buf)
		-- end

		table.insert(self.tbLog, LogItem)
	end
end

function EliminateLog:SaveRecordLog()
	-- if not self.ontime then
	-- 	local index = 1
	-- 	for row  in g_DbMgr:GetRecordDBRow(DBLog)do
	-- 		g_DbMgr:DeleteRecordDB(DBLog, index)
	-- 		index = index + 1
	-- 	end
	-- 	local string_buf = nil
	-- 	for i=1, #self.tbLog do
	-- 		string_buf = string.format("%d%s", self.tbLog[i]:GetColorIndex(), self.tbLog[i]:GetStrLog())
	-- 		g_DbMgr:insert(DBLog, i, string_buf)
	-- 		-- if 0 ~= g_DbMgr:UpdateRecordDB(DBLog, i, string_buf) then  
	-- 		-- 	g_DbMgr:insert(DBLog, i, string_buf)
	-- 		-- end
	-- 	end
	-- end
end


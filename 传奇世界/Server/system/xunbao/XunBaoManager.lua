--XunBaoManager.lua
--/*-----------------------------------------------------------------
--* Module:  XunBaoManager.lua
--* Author:  HE Ningxu
--* Modified: 2014年6月16日
--* Purpose: Implementation of the class XunBaoManager 
-------------------------------------------------------------------*/

require ("system.xunbao.XunBaoInfo")
require ("system.xunbao.XunBaoServlet")
require ("system.xunbao.XunBaoConstants")

XunBaoManager = class(nil, Singleton, Timer)

function XunBaoManager:__init()
	self._UserInfos = {} --运行时ID
	self._Item = {}
	self._ItemCompandAndSmelter = {}
	self._ItemSmelterSpecial = {}
	self._ItemWineInfo = {}
	self._ItemLevel = {}
	self:loadItem()
	self._operIdMap = {} --数据库操作ID映射
	self._DBSaveTimetick = os.time()
	self:loadProBasic()
	
    gTimerMgr:regTimer(self, 1000, 5000)
	print("XunBaoManager Timer ID: ", self._timerID_)

	g_listHandler:addListener(self)
end
function XunBaoManager:loadProBasic()
	self._aProBasic = 4 		--A奖池基础概率
	self._bProBasic = 60 		--B奖池基础概率
	local records = require "data.DropDB"
    for _, data in pairs(records or {}) do
    	if XUNBAO_A_REWARD_DROP_ID==data.q_id then     		--A奖池基础概率
    		if data.q_property then    			
    			self._aProBasic = tonumber(data.q_property)
    		end
    	elseif XUNBAO_B_REWARD_DROP_ID==data.q_id then     	--B奖池基础概率
    		if data.q_property then    			
    			self._bProBasic = tonumber(data.q_property)
    		end
    	else
    	end
    end
end

--玩家数据加载完成
--[[
function XunBaoManager:onCallSp(player, tabName, datas)	
	if tabName == "xunbao" then
		local User = self._UserInfos[player:getID()]
		if User then
			if #datas > 0 then
				User:loadDBdata(datas)
			end
		end
	end	
end
]]

--切换出world的通知
function XunBaoManager:onSwitchWorld2(roleID, peer, dbid, mapID)
	local User = self:getUserInfo(roleID)
	if User then
		User:switchOut(peer, dbid, mapID)
	end
end

--切换到本world的通知
function XunBaoManager:onPlayerSwitch(player, type, luabuf)
	if type == EVENT_XUNBAO_SETS then
		if not player then return end		

		local UID = player:getID()
		local SID = player:getSerialID()
		local User = self:getUserInfo(UID)		--没有将会新建
		if not User then
			--如果没有，则创建新的信息
			User = XunBaoInfo(UID, SID)
			self._UserInfos[UID] = User
		end

		if User then
			User:switchIn(luabuf)
		end
	end
end

--玩家上线
function XunBaoManager:onPlayerLoaded(player)
	local UID = player:getID()
	local SID = player:getSerialID()
	local User = XunBaoInfo(UID, SID)
	User:initABNums(self._aProBasic,self._bProBasic)
	self._UserInfos[UID] = User
	--g_entityDao:loadRole(SID, "xunbao")

	--self:loadxunbao(SID)
end

--玩家下线
function XunBaoManager:onPlayerOffLine(player)
	local UID = player:getID()
	local User = self:getUserInfo(UID)
	if User then
		User:cast2DB()
		self._UserInfos[UID] = nil
	end
end

--[[
function XunBaoManager:onPlayerCast2DB(player)
	local nowTimetick = os.time()
	if nowTimetick-self._DBSaveTimetick>=30 then
		self._DBSaveTimetick = nowTimetick
		local UID = player:getID()
		local User = self:getUserInfo(UID)
		if User then
			User:cast2DB()
		end
	end
end
]]

--广播掉落
function XunBaoManager.Boardcast(name, id, itemID)
	g_PushMsgMgr:sendErrMsg2Client(1, 2, {name, g_XunBaoMgr._Item[itemID].name})
end

--20151019
function XunBaoManager:loadxunbao(roleSID)
	if roleSID ~= "" then
		local params = {
			{
				rId = roleSID,
				spName = "sp_LoadXunbao",
				dataBase = 1,
				sort = "rId",
			}
		}
		local operId =  LuaDBAccess.callDB(params, apiEntry.onloadXunbao)
		self._operIdMap[operId] = roleSID
	end
end

--20151019
function XunBaoManager:onloadXunbao(data)
	if data[1] then
		local roleSID = self._operIdMap[data._operationID]
		if not roleSID then
			return
		end

		local player = g_entityMgr:getPlayerBySID(roleSID)
		if not player then
			return
		end

		local User = self._UserInfos[player:getID()]
		if User then
			--data[1] = {{ roleID=905000040, datas={b=0,f=0,s=0,r=999999,d={2015,10,12},l=0,t=0},count={0,0,0,0} },{第二条记录}}
			for _,v in pairs(data[1]) do 	
				User:loadDBdata(v)
			end
		end
	end
end

function XunBaoManager:getUserInfo(UID)
	return self._UserInfos[UID]
end

function XunBaoManager:loadItem()
	if package.loaded["data.ItemDB"] then
		package.loaded["data.ItemDB"] = nil
	end
	self._Item = {}

	local Datas = require "data.ItemDB"
	for _, record in pairs(Datas or {}) do
		local data = {}
		data.id = record.q_id
		data.name = record.q_name or ""
		data.bind = record.q_bind
		self._Item[data.id] = data

		--加载合成和分解属性 
		local curItemIDTmp = tonumber(record.q_id)
		local specialItemIDTmp = {30000,30001,30002,999998,666666,1219}
		if table.contains(specialItemIDTmp, curItemIDTmp) then
			local ItemTmp = {}
			ItemTmp.itemID = curItemIDTmp
			ItemTmp.itemName = tostring(record.q_name)
			self._ItemSmelterSpecial[curItemIDTmp] = ItemTmp
		end

		local qicai1Tmp = tonumber(record.q_qicai1 or 0)
		local qicai2Tmp = tonumber(record.q_qicai2 or 0)
		local soulTmp = tonumber(record.q_rlx or 0)
		local moneyTmp = tonumber(record.q_sell_price or 0)
		
		if qicai1Tmp>0 or qicai2Tmp>0 or soulTmp>0 or moneyTmp>0 then
			if not self._ItemCompandAndSmelter.smelter then
				self._ItemCompandAndSmelter.smelter = {}
			end

			local level = tonumber(record.q_level or 0)
			if not self._ItemCompandAndSmelter.smelter[level] then
				self._ItemCompandAndSmelter.smelter[level] = {}
			end

			local Temp = {}
			Temp.itemID=tonumber(record.q_id)
			Temp.itemName=record.q_name
			Temp.level=tonumber(record.q_level or 0)
			Temp.quality=tonumber(record.q_default or 1)
			Temp.soul=tonumber(record.q_rlx or 0)
			Temp.sellPrice=tonumber(record.q_sell_price or 0)
			Temp.qicai1=tonumber(record.q_qicai1 or 0)
			Temp.qicai2=tonumber(record.q_qicai2 or 0)
			table.insert(self._ItemCompandAndSmelter.smelter[level],Temp)
		end
		

		if record.q_sourceNeedID then
			if tonumber(record.q_sourceNeedID)>0 then
				if not self._ItemCompandAndSmelter.compand then
					self._ItemCompandAndSmelter.compand = {}
				end

				local level = tonumber(record.q_level or 0)
				if not self._ItemCompandAndSmelter.compand[level] then
					self._ItemCompandAndSmelter.compand[level] = {}
				end

				local Temp = {}
				Temp.itemID=tonumber(record.q_id)
				Temp.itemName=record.q_name
				Temp.level=tonumber(record.q_level or 0)
				Temp.quality=tonumber(record.q_default or 1)
				Temp.needID=tonumber(record.q_sourceNeedID or 0)
				Temp.needNum=tonumber(record.q_sourceNeedNum or 0)
				Temp.needID2=tonumber(record.q_sourceNeedID2 or 0)
				Temp.needNum2=tonumber(record.q_sourceNeedNum2 or 0)
				Temp.needSex=tonumber(record.q_sex or 0)
				table.insert(self._ItemCompandAndSmelter.compand[level],Temp)
			end
		end

		local itemIDTmp = record.q_id or 0
		local levelTmp = record.q_level or 0
		if 1==record.q_type then
			if not self._ItemLevel[itemIDTmp] then
				self._ItemLevel[itemIDTmp] = 0
			end
			self._ItemLevel[itemIDTmp] = levelTmp
		end

		if 6200024==record.q_id then
			self._ItemWineInfo = record
		end
	end
--print("XunBaoManager:loadItem 01",toString(self._ItemCompandAndSmelter))
end

function XunBaoManager:getItemName(itemID)
	return self._Item[itemID].name
end

function XunBaoManager:getItem(itemID)
	return self._Item[itemID]
end
 
function XunBaoManager:sendErrMsg2Client(roleId, errId, paramCount, params)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
	retBuff:pushShort(EVENT_XUNBAO_SETS)
	retBuff:pushShort(errId)
	retBuff:pushShort(XunBaoServlet.getInstance():getCurEventID())
	retBuff:pushChar(paramCount)

	for i=1, paramCount do
		retBuff:pushString(tostring(params[i])or "")
	end

	g_engine:fireLuaEvent(roleId, retBuff)
end

function XunBaoManager:getXunbaoAllNums(roleId)
	local allNums = 0
	local userInfo = self:getUserInfo(roleId)
	if userInfo then
		allNums = userInfo:getXunbaoAllCount()
	end

	return allNums
end

function XunBaoManager:update()
	--local nowHour = tonumber(os.date("%H"))
	--local nowMinite = tonumber(os.date("%M"))
	for i,v in pairs(self._UserInfos) do
		local userInfo = self:getUserInfo(i)
		if userInfo then
			if userInfo._step>0 then
				local timeleft = os.time()-tonumber(userInfo._time)
				if timeleft>0 then
					userInfo._time = 0
					userInfo._step = 0
				end
			end
		end
	end
end

function XunBaoManager.getInstance()
	return XunBaoManager()
end

g_XunBaoMgr = XunBaoManager.getInstance()
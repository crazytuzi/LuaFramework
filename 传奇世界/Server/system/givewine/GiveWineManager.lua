--GiveWineManager.lua
--/*-----------------------------------------------------------------
--* Module:  GiveWineManager.lua
--* Author:  liucheng
--* Modified: 2016年2月11日 
--* Purpose: Implementation of the class GiveWineManager 
-------------------------------------------------------------------*/
require "system.givewine.GiveWineConstant"
require "system.givewine.GiveWineServlet"

GiveWineManager = class(nil, Singleton, Timer)

function GiveWineManager:__init()	
	self._InActivity = false			--当前活动是否进行
	self._xtActive = 1 					--当前系统是否开启 0关闭	 1开启
	
	self._DrinkRecord = {} 				--饮酒次数和时间
	self._CurTimeTick = time.toedition("day")
	self._DrinkCD = 890 				--两次饮酒的时间间隔
	self._loadDrindSpace = false 		--是否从道具表加载了 饮酒间隔的 配置

	self._isGetDrinkLevel = false
	self._DrinkLevel = 0

	self._AddEXP = 2000
	self._AddAllTime = 900
	self._AddSpace = 10
	local records = require "data.BuffDB" 
	for _, data in pairs(records or {}) do
		if WINE_BUFFER_ID==data.id then		
			self._AddEXP = tonumber(data.upEXP) or 2000
			self._AddAllTime = tonumber(data.lastTime)/1000 or 900
			self._AddSpace = tonumber(data.spaceTime)/1000 or 10
			break
		end
	end

	gTimerMgr:regTimer(self, 1000, 1000)
	print("GiveWineManager Timer ID: ", self._timerID_)

	g_listHandler:addListener(self)
end

--玩家续线
function GiveWineManager:onActivePlayer(player)
	if not player then return end
	local roleSID = player:getSerialID()

	if self._DrinkRecord[roleSID] then
		local buffmgr = player:getBuffMgr()
		buffmgr:delBuff(WINE_BUFFER_ID)

		--如果buffer有效果  还要增加buffer
		local CurTimeTick = os.time()
		if tonumber(self._DrinkRecord[roleSID][5] or 0)>CurTimeTick then
			self._DrinkRecord[roleSID][6] = CurTimeTick
			
			local bufferleftMin =(self._DrinkRecord[roleSID][5]-CurTimeTick)*1000
			buffmgr:addBuff(WINE_BUFFER_ID,0,0,true,bufferleftMin)
		end
	end	
end

--玩家下线
function GiveWineManager:onPlayerOffLine(player)
	if player then
		local roleSID = player:getSerialID()
		--存入数据库
		self:cast2DB(roleSID)
		self._DrinkRecord[roleSID] = nil
	end
end

--切换出world的通知 
function GiveWineManager:onSwitchWorld2(roleID, peer, dbid, mapID)
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		local roleSID = player:getSerialID()

		local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
		luaBuf:pushInt(dbid)
		luaBuf:pushShort(EVENT_GIVEWINE_SETS)
		--具体数据跟在后面
		luaBuf:pushString(serialize(self._DrinkRecord[roleSID]))
		g_engine:fireSwitchBuffer(peer, mapID, luaBuf)
	end	
end

--切换到本world的通知
function GiveWineManager:onPlayerSwitch(player, type, luabuf)
	if type == EVENT_GIVEWINE_SETS then
		if not player then return end
		local roleSID = player:getSerialID()

		if luabuf:size() > 0 then
			self._DrinkRecord[roleSID] = unserialize(luabuf:popString())			
		end

		local buffmgr = player:getBuffMgr()
		buffmgr:delBuff(WINE_BUFFER_ID)

		if self._DrinkRecord[roleSID] then
			local CurTimeTick = os.time()
			if tonumber(self._DrinkRecord[roleSID][5] or 0)>CurTimeTick then
				self._DrinkRecord[roleSID][6] = CurTimeTick			

				local bufferleftMin =(self._DrinkRecord[roleSID][5]-CurTimeTick)*1000
				buffmgr:addBuff(WINE_BUFFER_ID,0,0,true,bufferleftMin)
			end
		end
	end
end

function GiveWineManager.loadDBData(player, cacha_buf, roleSid)
	g_GiveWineMgr:loadDBDataImpl(player, cacha_buf, roleSid)
end

--数据库加载回调
function GiveWineManager:loadDBDataImpl(player, cacha_buf, roleSid)
	if not player then return end
	local roleSID = player:getSerialID()

	local data = unserialize(cacha_buf)
	if data.d then
		local dbData = data.d
		local curDay = time.toedition("day")
		if dbData[1] ~= curDay then
			dbData[1] = curDay
			dbData[2] = 0
			dbData[3] = 0			
		end
		self._DrinkRecord[roleSID] = dbData

		local buffmgr = player:getBuffMgr()
		buffmgr:delBuff(WINE_BUFFER_ID)

		if self._DrinkRecord[roleSID] then
			--如果buffer有效果  还要增加buffer
			local CurTimeTick = os.time()
			local buffleft = dbData[5] - dbData[6]
			if buffleft>0 then
				self._DrinkRecord[roleSID][6] = CurTimeTick
				self._DrinkRecord[roleSID][5] = CurTimeTick + buffleft
				self:cast2DB(roleSID)
			end

			if tonumber(self._DrinkRecord[roleSID][5])>CurTimeTick then
				self._DrinkRecord[roleSID][6] = CurTimeTick

				local bufferleftMin =(self._DrinkRecord[roleSID][5]-CurTimeTick)*1000
				buffmgr:addBuff(WINE_BUFFER_ID,0,0,true,bufferleftMin)
			end
		end		
	end
end

function GiveWineManager:cast2DB(roleSID)
	local dbStr = {d=self._DrinkRecord[roleSID]}
	local cache_buf = serialize(dbStr)
	g_engine:savePlayerCache(roleSID, FIELD_GIVEWINE, cache_buf, #cache_buf)	
end

function GiveWineManager:getWineDrinkLevel()
	if not self._isGetDrinkLevel then
		--读取神仙醉使用等级
		local itemInfo = g_ActivityMgr:getItemInfo(WINE_ITEM_ID)
		if itemInfo then
			if itemInfo.itemLevel then
				self._DrinkLevel = tonumber(itemInfo.itemLevel)
			end
		end

		if self._DrinkLevel <= 0 then
			self._DrinkLevel = WINE_DRINK_LEVEL
		end
		self._isGetDrinkLevel = true
	end
	return self._DrinkLevel
end

function GiveWineManager:GetFreeWine(player)
	--系统是否开启
	if self._xtActive<1 then return end

	if not player then return end
	local roleSID = player:getSerialID()
	if not self._InActivity then
		--不在活动时间内
		self:sendErrMsg2Client(player:getID(),WINE_ERR_GET_NO_ACTIVITY,0,{})
		return
	end
	
	--判断领酒等级
	if FREE_WINE_GET_LEVEL>player:getLevel() then		
		self:sendErrMsg2Client(player:getID(),WINE_ERR_GET_LEVEL_LIMIT,1,{FREE_WINE_GET_LEVEL})
		return
	end

	if not self._DrinkRecord[roleSID] then
		self._DrinkRecord[roleSID] = {time.toedition("day"),0,0,0,0,0,0} 
	end
	
	if self._DrinkRecord[roleSID][2]>0 then
		if tonumber(os.time()) - self._DrinkRecord[roleSID][7]<FREE_WINE_GET_SPAN then
			--已经领取过了
			self:sendErrMsg2Client(player:getID(),WINE_ERR_GETWINE_AGAIN,0,{})
			return
		end
	end
	
	self._DrinkRecord[roleSID][2] = 1
	self._DrinkRecord[roleSID][7] = tonumber(os.time())

	local retData = {}
	retData.wineNum = 0
	fireProtoMessageBySid(roleSID, GIVEWINE_SC_GETWINE_NUM, "GetWineNumRetProtocol", retData)

	--物品放入背包
	local itemMgr = player:getItemMgr()
	if itemMgr then
		local emptySize = itemMgr:getEmptySize(Item_BagIndex_Bag)
		local freeSlotNum = itemMgr:getEmptySize()
		if freeSlotNum < 1 then
			--提示背包满
			local offlineMgr = g_entityMgr:getOfflineMgr()
			local email = offlineMgr:createEamil()
			local emailConfigId = 58
			email:setDescId(emailConfigId)
			email:insertProto(WINE_ITEM_ID, 1, true)
			offlineMgr:recvEamil(roleSID, email, 111, 0)
		else
			itemMgr:addItem(Item_BagIndex_Bag,WINE_ITEM_ID,1, 1, 0, 0, 0, 0)
			g_logManager:writePropChange(roleSID,1,111,WINE_ITEM_ID,0,1,1)
		end
	end

	g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.GIVEWINE, 1)
	g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.GIVE_WINE)
	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.joinWine, 1)
	self:sendErrMsg2Client(player:getID(),WINE_GET_SUCC,0,{})
	g_tlogMgr:TlogHDFlow(player, 2)	
end

function GiveWineManager:Drink(player,slotIndex)
	if not player then return end
	local roleSID = player:getSerialID()
	--if not self._InActivity then
		--不在活动时间内
		--self:sendErrMsg2Client(player:getID(),WINE_ERR_DRINK_NO_ACTIVITY,0,{})
		--return
	--end	

	local level = player:getLevel()
	local drinkLevel = self:getWineDrinkLevel()
	if level < drinkLevel then
		self:sendErrMsg2Client(player:getID(),WINE_ERR_LEVEL_LIMIT,1,{drinkLevel})
		return
	end

	if not self._DrinkRecord[roleSID] then
		--{数据日期，今天是否领酒，今日喝过多少坛，上次喝酒时间戳 ，增益达到时间，上次增益时间, 上次领酒时间}
		self._DrinkRecord[roleSID] = {time.toedition("day"),0,0,0,0,0,0} 
	end

	if not self._loadDrindSpace then
		local itemInfoTmp = g_ActivityMgr:getItemInfo(WINE_ITEM_ID)
		if itemInfoTmp and itemInfoTmp.coolCD and itemInfoTmp.coolCD > 0 then
			self._DrinkCD = itemInfoTmp.coolCD/1000
			self._loadDrindSpace = true
		end
	end

	local curTick = os.time()
	if curTick-self._DrinkRecord[roleSID][4] < self._DrinkCD then
		self:sendErrMsg2Client(player:getID(),WINE_ERR_DRINK_CD,0,{})
		return
	end

	if self._DrinkRecord[roleSID][3]>=3 then
		self:sendErrMsg2Client(player:getID(),WINE_ERR_DRINK_MAX,0,{})
		return
	end

	local itemMgr = player:getItemMgr()
	if not itemMgr then return end
	local item = itemMgr:findItem(slotIndex)
	if not item then return end

	local sourceItemID = item:getProtoID()
	if sourceItemID~=WINE_ITEM_ID then
		return
	end

	local flag=0
	local errcode=0
	flag, errcode = itemMgr:removeBagItem(slotIndex, 1, errcode)
	if not flag then return end
	g_logManager:writePropChange(roleSID,2,111,WINE_ITEM_ID,0,1,1)

	--增加buffer
	local buffmgr = player:getBuffMgr()
	buffmgr:addBuff(WINE_BUFFER_ID,0,0,true,self._AddAllTime*1000)

	self._DrinkRecord[roleSID][1] = time.toedition("day")
	self._DrinkRecord[roleSID][3] = self._DrinkRecord[roleSID][3] + 1
	self._DrinkRecord[roleSID][4] = curTick
	self._DrinkRecord[roleSID][5] = curTick + self._AddAllTime
	self._DrinkRecord[roleSID][6] = curTick

	self:sendErrMsg2Client(player:getID(),WINE_DRINK_SUCC,0,{})

	local retBuf = {}
	retBuf.itemID = WINE_ITEM_ID
	retBuf.itemNum = 1
	fireProtoMessage(player:getID(),ITEM_SC_USEMATERIAL,"ItemUseRetProtocol",retBuf)
end

function GiveWineManager:GetWineNum(player)
	--系统是否开启
	local canGetWine = true
	if self._xtActive<1 then canGetWine = false end

	if not player then canGetWine = false end
	local roleSID = player:getSerialID()
	if not self._InActivity then
		canGetWine = false
	end

	--判断领酒等级
	--if FREE_WINE_GET_LEVEL>player:getLevel() then
		--canGetWine = false
	--end

	if not self._DrinkRecord[roleSID] then
		self._DrinkRecord[roleSID] = {time.toedition("day"),0,0,0,0,0,0} 
	end
	
	if self._DrinkRecord[roleSID][2]>0 then
		if tonumber(os.time()) - self._DrinkRecord[roleSID][7]<FREE_WINE_GET_SPAN then
			--已经领取过了
			canGetWine = false			
		end
	end

	local winNum = FREE_WINE_GET_NUM
	if not canGetWine then winNum = 0 end
	local retData = {}
	retData.wineNum = winNum
	fireProtoMessageBySid(roleSID, GIVEWINE_SC_GETWINE_NUM, "GetWineNumRetProtocol", retData)
end

function GiveWineManager:canJoinAndGetWine(player)
	local canJoin = 1
	if not player then return canJoin end
	local roleSID = player:getSerialID()

	if self._xtActive<1 then 
		return canJoin 
	end
	if not self._InActivity then
		return canJoin
	end
	
	--判断领酒等级
	if FREE_WINE_GET_LEVEL>player:getLevel() then
		return canJoin
	end

	if self._DrinkRecord[roleSID] and self._DrinkRecord[roleSID][2] and self._DrinkRecord[roleSID][7] then
		if self._DrinkRecord[roleSID][2]>0 then
			if tonumber(os.time()) - self._DrinkRecord[roleSID][7]<FREE_WINE_GET_SPAN then
				--已经领取过了
				return 2
			end
		end
	end
	--0 代表可以参加  可以领取，1 代表不能参加，2 代表能参加  但活动时间内已领取
	return 0
end

function GiveWineManager:on()
	self:sendBroad2Client(60, 0, {})
	self._InActivity = true
end

function GiveWineManager:off()
	--全服跑马灯
	self:sendBroad2Client(61, 0, {})
	self._InActivity = false	
	
	for i,v in pairs(self._DrinkRecord or {}) do
		self._DrinkRecord[i][2] = 0
	end
end

--类似跑马灯消息
function GiveWineManager:sendBroad2Client(errId, paramCount, params, roleID)
	local ret = {}
	ret.eventId = EVENT_PUSH_MESSAGE
	ret.eCode = errId
	ret.mesId = GiveWineServlet.getInstance():getCurEventID()
	ret.param = {}
	paramCount = paramCount or 0
	for i=1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	boardProtoMessage(FRAME_SC_MESSAGE, "FrameScMessageProtocol", ret)
end

function GiveWineManager:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(GiveWineServlet.getInstance():getCurEventID(), roleId, EVENT_GIVEWINE_SETS, errId, paramCount, params)
end

function GiveWineManager:update()	
	for i,v in pairs(self._DrinkRecord or {}) do	

		local curDay = time.toedition("day")
		if self._DrinkRecord[i][1] ~= curDay then
			self._DrinkRecord[i][1] = curDay
			self._DrinkRecord[i][2] = 0
			self._DrinkRecord[i][3] = 0
		end

		local CurTimeTick = os.time()
		if CurTimeTick>=self._DrinkRecord[i][4] and CurTimeTick<=self._DrinkRecord[i][5] then
			if CurTimeTick-self._DrinkRecord[i][6]>=self._AddSpace then
				self._DrinkRecord[i][6] = CurTimeTick
				local player = g_entityMgr:getPlayerBySID(i)
				if player then
					local curXP = player:getXP()
					--player:setXP(curXP+self._AddEXP)
					--Tlog[PlayerExpFlow]
					addExpToPlayer(player,self._AddEXP,111)

					local retData = {}
					retData.type = 0 		--0 经验  1 物品  2 金币
					retData.value = self._AddEXP
					fireProtoMessage(player:getID(),FRAME_SC_PICKUP,"FramePickUpRetProtocol",retData)					
				end
			end
		end

		--增益效果过期
		if CurTimeTick>self._DrinkRecord[i][5] then
			self._DrinkRecord[i][5] = 0
		end
	end	
end

function GiveWineManager:setxtActive(value)
	self._xtActive = tonumber(value)
end

function GiveWineManager.getInstance()
	return GiveWineManager()
end

g_GiveWineMgr = GiveWineManager.getInstance()
--CommonInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  CommonInfo.lua
 --* Author:  Martin Yang
 --* Modified: 2014年6月18日 15:49:14
 --* Purpose: Implementation of the class CommonInfo
 -------------------------------------------------------------------*/
require "base.class"


function GetMoveDir(xDiff, yDiff)
	if xDiff == 0 and yDiff == 0 then
		return 8
	end

	if xDiff == 0 and yDiff > 0 then
		return 6
	end 

	if xDiff == 0 and yDiff < 0 then
		return 2
	end 

	if xDiff > 0 and yDiff == 0 then
		return 0
	end 

	if xDiff > 0 and yDiff > 0 then
		return 7
	end

	if xDiff > 0 and yDiff < 0 then
		return 1
	end

	if xDiff < 0 and yDiff == 0 then
		return 4
	end 

	if xDiff < 0 and yDiff > 0 then
		return 5
	end

	if xDiff < 0 and yDiff < 0 then
		return 3
	end
end

function GetMoveDirAndLen(pos1, pos2, notLimitLen)
	local xDiff = pos2.x - pos1.x
	local yDiff = pos2.y - pos1.y

	if xDiff == 0 and yDiff == 0 then
		return nil
	end

	local xDiffAbs = math.abs(xDiff)
	local yDiffAbs = math.abs(yDiff)

	local len = xDiffAbs

	if len == 0 then
		len = yDiffAbs
	else
		if len > yDiffAbs and yDiffAbs > 0 then
			len = yDiffAbs
		end
	end

	local dir = 0

	--[[
	if xDiffAbs < 4 and yDiffAbs < 4 then
		if len == xDiffAbs then
			dir = GetMoveDir(xDiff, 0)
		else
			dir = GetMoveDir(0, yDiff)
		end
	else
		dir = GetMoveDir(xDiff, yDiff)
	end
	]]

	dir = GetMoveDir(xDiff, yDiff)

	if not notLimitLen then
		if len > DART_RUNING_LEN then
			len = DART_RUNING_LEN
		end
	end
	return dir, len
end



local prop_chrge_sch = 4

CommonInfo = class(nil)

local prop = Property(CommonInfo)
prop:accessor("roleID")
prop:accessor("roleSID")

function CommonInfo:__init(roleID, roleSID)
	prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

	self._downloads = {}
	self._pay_cashs = {}
	self._pay_ingots = {}

	self._common_datas = {
		-- dartCount = 1, 
		-- dartState = 0, 
		-- dartStar = 1, 
		-- dartDate = 0,
		-- dartOffline = 0,
		firstKill = 0,
		freeBugle = 0,
		timeTick = 0,
		inlineTest = true,
		redBagCount = 0,	--红包数量
		redBagTime = 0,		--红包领取时间
		invadeDropID = 0,	--山贼入侵奖励掉落ID
		reliveTime = 0,
		reliveStamp = 0,

		downloads = {},
		
		dartData = {count = 0,state = 0, date = 0,offline = 0,rewardExp = 0},

		convoy = 0,			-- 是否有护送， 0是没有，1是有
	}

	self._dart_datas = {
		count = DART_MAX_TIMES,	-- 可以镖车次数
		mapId = 2100,
		offline = 0, -- 离线标志
		id = 0,	-- 镖车ID
		state = 0,	-- 状态
		dartId = 0,	-- 镖车配置ID
		dartHp = 1,	-- 镖车血量
		dartType = 0,
		hurt = 0,		-- 镖车被伤害值
		rewardID = 0,
		rewardCount = 0,	-- 镖车宝箱数
		dropCount = 0,
		step = 0,	-- 镖车运行的步数
		date = 0,
		rewardType = 0,
		flag = nil , --判断镖车血量是否经过临界值。    
		startTime = 0,
		checkMove = false,
		teamID = 0,
		rewardExp = 0,--镖车结束的经验奖励
		factionID = 0,
		gameAppID = 0,
		platID 	   = 0,
		openid	= 0,
		level = 0,
		posIndex = 1	-- 镖车运行到配置地点索引

	}

	self._loadDB = false		-- 是否加载了db数据
end

function CommonInfo:getCheckMove( )
	return self._dart_datas.checkMove
end
function CommonInfo:setCheckMove(checkMove)
	self._dart_datas.checkMove = checkMove
end

function CommonInfo:setDartState(state)
	if self._dart_datas.state ~= state then 
		self:fireDartState(state)
	end
	self._dart_datas.state = state
end

function CommonInfo:fireDartState(state)
	local retData = {}
	retData.state = state or self._dart_datas.state
	retData.rewardTpye = self._dart_datas.rewardType
	retData.hasReward = self._dart_datas.rewardExp ~= 0  and true or false
	fireProtoMessage(self:getRoleID(),DART_SC_CURSTATE_RET,"DartCurStateRetProtocol",retData)
end

function CommonInfo:finishClearDart( )
	self._dart_datas.id = 0
	self:setDartState(0) 
	self._dart_datas.dartId = 0	-- 镖车配置ID
	self._dart_datas.dartHp = 1	-- 镖车血量
	self._dart_datas.dartType = 0
	self._dart_datas.hurt = 0		-- 镖车被伤害值
	self._dart_datas.rewardID = 0
	self._dart_datas.rewardCount = 0	-- 镖车宝箱数
	self._dart_datas.dropCount = 0
	self._dart_datas.step = 0	-- 镖车运行的步数
	--self._dart_datas.date = time.toedition("day")
	--self._dart_datas.rewardType = 0
	self._dart_datas.flag = nil  --判断镖车血量是否经过临界值。    
	self._dart_datas.startTime = 0
	self._dart_datas.checkMove = false
	self._dart_datas.teamID = 0
	self._dart_datas.gameAppID = 0
	self._dart_datas.platID	= 0
	self._dart_datas.openid	= 0
	self._dart_datas.level = 0
	self._dart_datas.posIndex = 1	-- 镖车运行到配置地点索引

	self:cast2db()
end

function CommonInfo:__release()
end

function CommonInfo:getFreeBugle()
	return self._common_datas.freeBugle
end

function CommonInfo:setFreeBugle(f)
	self._common_datas.freeBugle = f
	self:cast2db()
end

function CommonInfo:getFirstKill()
	return self._common_datas.firstKill
end

function CommonInfo:setFirstKill(f)
	self._common_datas.firstKill = f
	self:cast2db()
end

function CommonInfo:getHasInlineTest()
	return self._common_datas.inlineTest
end

function CommonInfo:setHasInlineTest(f)
	self._common_datas.inlineTest = f
	self:cast2db()
end

function CommonInfo:setRedBagData(datas)
	self._common_datas.redBagCount = datas.count
	self._common_datas.redBagTime = datas.time
	self:cast2db()
end

function CommonInfo:setInvadeDropID(dropID)
	self._common_datas.invadeDropID = dropID
	self:cast2db()
end

function CommonInfo:getRedBagData()
	local datas = {
		count = self._common_datas.redBagCount,
		time = self._common_datas.redBagTime,
	}
	return datas
end

--写支付记录
function CommonInfo:writePayRecord(buff)
	buff:pushChar(table.size(self._pay_cashs))
	for i, record in pairs(self._pay_cashs or {}) do
		buff:pushInt(record.tick)
		buff:pushInt(record.oper)
		buff:pushInt(record.cost)
		buff:pushInt(record.left)
	end
	buff:pushChar(table.size(self._pay_ingots))
	for i, record in pairs(self._pay_cashs or {}) do
		buff:pushInt(record.tick)
		buff:pushInt(record.oper)
		buff:pushInt(record.cost)
		buff:pushInt(record.left)
	end
end

--添加记录
function CommonInfo:addRecord(player, payment, currency, operation)	
	if currency == CURRENCY_INGOT then
		if table.size(self._pay_ingots) > MAX_PAY_RECORD then
			table.remove(self._pay_ingots, 1)
		end
		local record = {cost = payment, tick = os.time(), oper = operation, left = player:getIngot()}
		table.insert(self._pay_ingots, record)
		self:syncRecord(player, currency, record)
	else
		if table.size(self._pay_ingots) > MAX_PAY_RECORD then
			table.remove(self._pay_ingots, 1)
		end
		local record = {cost = payment, tick = os.time(), oper = operation, left = player:getBindMoney()}
		table.insert(self._pay_cashs, record)
		self:syncRecord(player, currency, record)
	end
end

--同步记录给客户端
function CommonInfo:syncRecord(player, currency, record)
	local buff = LuaEventManager:instance():getLuaRPCEvent(ACTIVITY_SC_RECORD_RET)
	buff:pushInt(currency)
	buff:pushInt(record.tick)
	buff:pushInt(record.oper)
	buff:pushInt(record.cost)
	buff:pushInt(record.left)
	g_engine:fireLuaEvent(player:getID(), buff)
end

--切换world的通知
function CommonInfo:switchWorld(peer, dbid, mapID)
	local cache_buf = self:writeObject()
	local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
	luaBuf:pushInt(dbid)
	luaBuf:pushShort(EVENT_TALISMAN_SETS)
	luaBuf:pushLString(cache_buf, #cache_buf)
	-- print(self:getRoleSID())
	-- print("CommonInfo:switchWorld")
	-- print(toString(self._dart_datas))
	g_engine:fireSwitchBuffer(peer, mapID, luaBuf)
end

--保存到数据库
function CommonInfo:cast2db()	
	local cache_buf = self:writeObject()
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_COMMON, cache_buf, #cache_buf)
end

function CommonInfo:setStoneNumInfo(reliveTime, reliveStamp)
	self._common_datas.reliveTime = reliveTime
	self._common_datas.reliveStamp = reliveStamp
end

--保存到数据库
function CommonInfo:writeObject()
	self._common_datas.downloads = {}
	for id, _ in pairs(self._downloads) do
		table.insert(self._common_datas.downloads, id)
	end
	self._common_datas.dartData = {	
		count = self._dart_datas.count,
		state = self._dart_datas.state,
		date = self._dart_datas.date,
		offline = self._dart_datas.offline,
		rewardExp = self._dart_datas.rewardExp,
		rewardType = self._dart_datas.rewardType
	}

	g_MainObjectMgr:writeObject(self:getRoleSID(), self._common_datas)
	return protobuf.encode("CommonProtocol", self._common_datas)
end

--加载数据库数据
function CommonInfo:loadDBdata(player, cache_buf)
	--print(" CommonInfo:loadDBdata")

	g_MainObjectMgr:addPlayerData(player:getSerialID())

	if #cache_buf > 0 then
		local datas = protobuf.decode("CommonProtocol", cache_buf)
		-- 镖车数据
		-- self._common_datas.dartCount = datas.dartCount
		-- self._common_datas.dartState = datas.dartState
		-- self._common_datas.dartDate = datas.dartDate
		-- self._common_datas.dartOffline = datas.dartOffline
		--免费喇叭的次数
		self._common_datas.freeBugle = datas.freeBugle
		--首杀怪物等级
		self._common_datas.firstKill = datas.firstKill
		--时间戳
		self._common_datas.timeTick = datas.timeTick	
		--内测返利标记
		self._common_datas.inlineTest = datas.inlineTest
		--红包数据
		self._common_datas.redBagCount = datas.redBagCount
		self._common_datas.redBagTime = datas.redBagTime
		self._common_datas.invadeDropID = datas.invadeDropID
		--下载有礼
		self._downloads = {}
		for _, id in pairs(datas.downloads) do
			self._downloads[id] = true
		end
		local roleID = player:getID()
		g_RedBagMgr:loadDBData(roleID, self:getRedBagData())
		g_InvadeMgr:loadDBData(roleID, self._common_datas.invadeDropID)
		--通知运镖
		self._dart_datas.count = datas.dartData.count
		self._dart_datas.state = datas.dartData.state
		self._dart_datas.date = datas.dartData.date
		self._dart_datas.offline = datas.dartData.offline
		self._dart_datas.rewardExp = datas.dartData.rewardExp
		self._dart_datas.rewardType = datas.dartData.rewardType

		self._common_datas.convoy = datas.convoy

		g_MainObjectMgr:loadDBdata(self:getRoleSID(), datas.mainObject)

		local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
		if player then
			self._common_datas.reliveTime = datas.reliveTime
			self._common_datas.reliveStamp = datas.reliveStamp
			player:setReliveTime(datas.reliveTime)
			player:setReliveStamp(datas.reliveStamp)
		end
	end
	--print(self:getRoleSID())	
	--print("CommonInfo:loadDBdata")
	--print(toString(self._dart_datas))
	self:updateTick(player)

	self._loadDB = true
end

function CommonInfo:loadOtherDBdata(player, cache_buf)
	if #cache_buf > 0 then
		local datas = protobuf.decode("CommonProtocol", cache_buf)
		--免费喇叭的次数
		self._common_datas.freeBugle = datas.freeBugle
		--首杀怪物等级
		self._common_datas.firstKill = datas.firstKill
		--时间戳
		self._common_datas.timeTick = datas.timeTick	
		--内测返利标记
		self._common_datas.inlineTest = datas.inlineTest
		--红包数据
		self._common_datas.redBagCount = datas.redBagCount
		self._common_datas.redBagTime = datas.redBagTime
		self._common_datas.invadeDropID = datas.invadeDropID
		--下载有礼
		self._downloads = {}
		for _, id in pairs(datas.downloads) do
			self._downloads[id] = true
		end
		local roleID = player:getID()
		g_RedBagMgr:loadDBData(roleID, self:getRedBagData())
		g_InvadeMgr:loadDBData(roleID, self._common_datas.invadeDropID)

		self._common_datas.convoy = datas.convoy
		
	end	
	self:updateTick(player)

	self._loadDB = true
end


--是否有下载
function CommonInfo:hasDownload(id)
	return self._downloads[id] ~= nil
end

--下载成功
function CommonInfo:download(id)
	self._downloads[id] = true
	self:cast2db()
end

--更新时间戳
function CommonInfo:updateTick(player)
	local timeTick = time.toedition("day")
	if timeTick ~= self._common_datas.timeTick then
		self._common_datas.timeTick = timeTick		
		self._common_datas.freeBugle = 0
	end
end

function CommonInfo:clinkNPC()
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if not player then
		return
	end

	local timeTick = time.toedition("day")
	if timeTick ~= self._dart_datas.date then
		if self._dart_datas.teamID == 0 then 
			self:refreshDart()
		end
	end	

	local level = player:getLevel()
	local isTime = g_commonMgr:isDartTime()

	-- 不在活动时间内或无镖车次数时，状态标为0代表不能再镖车
	--print("CommonInfo:creatDart",self:getRoleSID(),"dart count = " .. self._dart_datas.count,"dart state  = " ..self._dart_datas.state )
-----------------------------	
--防止服务器重启造成 状态错误
	if self._dart_datas.state == 3 or self._dart_datas.state == 4 then 
		if self._dart_datas.teamID == 0 then 
			self:setDartState(0) 
		end

		if self._dart_datas.state == 4 then 
			local teamID = self._dart_datas.teamID
			if not  g_commonMgr._dart_datas.waitList[teamID] then 
				print(self:getRoleSID() .. "error operation")
				g_commonMgr:backItem(self:getRoleSID(),self._dart_datas.rewardType)
				self:finishClearDart()
			end
		end

	end
	if self._dart_datas.count == 0 and self._dart_datas.teamID == 0 then  
		self:setDartState(2) 
	end
-----------------------------
	if isTime and level >= DART_NEED_LEVEL and self._dart_datas.count ~= 0 then
		if self._dart_datas.state  == 0 then
			self:setDartState(1) 
		end
	else
		if self._dart_datas.state == 1 then
			self:setDartState(0)
		end
	end

	if not SYSTEM_DART_SWITCH then 
		self:setDartState(0) 
	end

	if self._dart_datas.count == 0 and self._dart_datas.state == 2 then 
		g_commonServlet:sendErrMsg2Client(DART_TIMES_VALID,0,{},self:getRoleID())
	end

	self:sendStatus()
end

function CommonInfo:sendStatus()
	local teamList = g_commonMgr._dart_datas.teamList or {}
	local teamData = {}
	for i,v in pairs(teamList) do
		local data = {
				teamID = v.teamID,
				maxCnt = v.teamMaxCnt,
				realCnt = v.teamRealCnt,
				name = v.name or "",
		}
		table.insert(teamData,data)
	end
	local retData = {
		state = self._dart_datas.state ,
		rewardType = self._dart_datas.rewardType,
		level = DART_NEED_LEVEL,
		teamID = self._dart_datas.teamID,
		count = self._dart_datas.count,
		teamNum = table.size(teamList),
		teamData = teamData
	}
	fireProtoMessage(self:getRoleID(),DART_SC_CLICK_NPC_RET,"DartClickRetProtocol",retData)
end


-- 镖车被攻击
function CommonInfo:onDartHurt(monID, hurt)
	self._dart_datas.hurt = self._dart_datas.hurt + hurt
	local hp = self._dart_datas.dartHp - self._dart_datas.hurt
	local Count = 0
--免费镖车 不掉落宝箱
	-- if self._dart_datas.dartType == DART_TYPE.FREE then 
	-- 	return 
	-- end
	--print("Count = " .. self._dart_datas.rewardCount)
	local dart = g_entityMgr:getMonster(monID)
	if hp / self._dart_datas.dartHp <= 0.2 then 
		-- 血量 从 0.1~0.4 减到 0.1 以下
		Count = self._dart_datas.flag[4] - self._dart_datas.dropCount
		
		self._dart_datas.rewardCount = self._dart_datas.rewardCount - Count
		--self:dropItem(monID, Count) 
		self._dart_datas.dropCount = self._dart_datas.flag[4]
	elseif hp / self._dart_datas.dartHp <= 0.4 then
		Count = self._dart_datas.flag[3] - self._dart_datas.dropCount
		
		self._dart_datas.rewardCount = self._dart_datas.rewardCount - Count
		--self:dropItem(monID, Count) 
		self._dart_datas.dropCount = self._dart_datas.flag[3]
		
	elseif hp / self._dart_datas.dartHp <= 0.6 then
	    -- 血量从 0.6~0.8 减至 0.6以下 
		Count = self._dart_datas.flag[2] - self._dart_datas.dropCount 
			
		self._dart_datas.rewardCount = self._dart_datas.rewardCount - Count 
		--self:dropItem(monID, Count) 
		self._dart_datas.dropCount = self._dart_datas.flag[2]
		-- print("血量减少至80%")
	elseif hp / self._dart_datas.dartHp <= 0.8  then
		Count = self._dart_datas.flag[1] - self._dart_datas.dropCount
		self._dart_datas.rewardCount = self._dart_datas.rewardCount - Count
		self._dart_datas.dropCount = self._dart_datas.flag[1]
		--self:dropItem(monID, Count) 
	end
	return Count
end



-- 镖车移动
function CommonInfo:move(moveSpeesd)
	--[[
	local dart = g_entityMgr:getMonster(self._dart_datas.id)
	if dart then
		self._dart_datas.step = self._dart_datas.step + 1
		local dir = DART_RUNING_STEP[self._dart_datas.step]
		-- print("步数:"..self._dart_datas.step,"方向:"..dir, "血量:"..dart:getHP(),"("..dart:getPosition().x..","..dart:getPosition().y..")")

		local pos = DART_RUNING_POSITION[self._dart_datas.step]

		dart.x = pos.x
		dart.y = pos.y
	
		dart:setMoveSpeed(moveSpeesd)
		dart:moveDir(dir, 0, DART_RUNING_LEN)
	end
	]]

	local dart = g_entityMgr:getMonster(self._dart_datas.id)
	if dart then
		local pos = dart:getPosition()
		local posStep = DART_RUNING_POSITION[self._dart_datas.posIndex]
		if pos.x == posStep.x and pos.y == posStep.y then
			self._dart_datas.posIndex = self._dart_datas.posIndex + 1
		end

		posStep = DART_RUNING_POSITION[self._dart_datas.posIndex]
		if not posStep then
			return
		end

		local dir, len = GetMoveDirAndLen(pos, posStep)
		if dir == nil then
			return
		end

		dart:setMoveSpeed(moveSpeesd)
		dart:moveDir(dir, 0, len)

	end
end

-- 镖车移动完成
function CommonInfo:stopMove(moveSpeesd)
	--[[

	if not SYSTEM_DART_SWITCH then
		table.insert(g_commonMgr._dart_datas.entitys, {monID = self._dart_datas.id, t = os.time()})
		g_commonMgr:removeDart(self._dart_datas.id)
		self._dart_datas.id = nil
	end	
	if self._dart_datas.step < #DART_RUNING_STEP and self._dart_datas.dartHp - self._dart_datas.hurt > 0 then
		self:move(moveSpeesd)
		return false
	elseif self._dart_datas.dartHp - self._dart_datas.hurt > 0 then

		return true 
	end	
	]]

	if not SYSTEM_DART_SWITCH then
		table.insert(g_commonMgr._dart_datas.entitys, {monID = self._dart_datas.id, t = os.time()})
		g_commonMgr:removeDart(self._dart_datas.id)
		self._dart_datas.id = nil
	end	

	local dart = g_entityMgr:getMonster(self._dart_datas.id)
	if not dart then
		return
	end

	local pos = dart:getPosition()
	local posStep = DART_RUNING_POSITION[#DART_RUNING_POSITION]
	if not (pos.x == posStep.x and pos.y == posStep.y) and self._dart_datas.dartHp - self._dart_datas.hurt > 0 then
		self:move(moveSpeesd)
		return false
	elseif self._dart_datas.dartHp - self._dart_datas.hurt > 0 then
		return true 
	end	

end
-- 镖车被劫
function CommonInfo:onDartKill(monID)
	local Count = self._dart_datas.flag[5] - self._dart_datas.dropCount
	self._dart_datas.rewardCount = self._dart_datas.rewardCount - Count
	if self._dart_datas.rewardType ~= 1 and self._dart_datas.startTime + DART_SURVIVE_TIME > os.time()then 
		g_commonMgr:dropItem(monID, Count)
	end
end

-- 刷新镖车
function CommonInfo:refreshDart()
	self._dart_datas.count = DART_MAX_TIMES
	self._dart_datas.id = 0
	self:setDartState(0)
	self._dart_datas.dartId = 0	-- 镖车配置ID
	self._dart_datas.dartHp = 1	-- 镖车血量
	self._dart_datas.dartType = 0
	self._dart_datas.hurt = 0		-- 镖车被伤害值
	self._dart_datas.rewardID = 0
	self._dart_datas.rewardCount = 0	-- 镖车宝箱数
	self._dart_datas.dropCount = 0
	self._dart_datas.step = 0	-- 镖车运行的步数
	self._dart_datas.date = time.toedition("day")
	self._dart_datas.flag = nil  --判断镖车血量是否经过临界值。    
	self._dart_datas.startTime = 0
	self._dart_datas.checkMove = false
	self._dart_datas.teamID = 0

	self._dart_datas.posIndex = 1	-- 镖车运行到配置地点索引
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if player then
		self:cast2db()
	end
end

-- 判断是否有足够的物品
function CommonInfo:hasItem(rewardType)
	if not g_commonMgr._dart_datas.data[rewardType] then
		return false
	end

	local itemID = g_commonMgr._dart_datas.data[rewardType].q_CostItemID
	if itemID == nil or itemID == 0 then
		return true
	end

	--扣除材料
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then return false end
    local itemMgr = player:getItemMgr()
	if not itemMgr then return false end

    if not isMatEnough(player, itemID, 1) then
       -- message
        return false 
    end

	return true
end


function CommonInfo:costItem(rewardType)
	if not g_commonMgr._dart_datas.data[rewardType] then
		return false
	end

	local itemID = g_commonMgr._dart_datas.data[rewardType].q_CostItemID
	if itemID == nil or itemID == 0 then
		return true
	end

	--扣除材料
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then return false end
    local itemMgr = player:getItemMgr()
	if not itemMgr then return false end

    if not isMatEnough(player, itemID, 1) then
       -- message
        return false 
    end

    local ItemTmp = itemMgr:findItemByItemID(itemID)  
	local ItemName = ""
	local BindTmp = 0
	if ItemTmp then
		ItemName = ItemTmp:getName()
		BindTmp = ItemTmp:isBinded() and 1 or 0
	end
	costMat(player, itemID, 1, 87, BindTmp)
	return true
end

function CommonInfo:getAroundTeamPlayerCount(teamID)
	if not teamID then 
		return 
	end
	--local step = math.min(self._dart_datas.step+1,#DART_RUNING_POSITION)
	--local pos = DART_RUNING_POSITION[step] 

	local dart = g_entityMgr:getMonster(self._dart_datas.id)
	if not dart then
		return
	end

	local pos = dart:getPosition()
	local scene = g_sceneMgr:getPublicScene(2100)
	local curScenePlayer = {}
	if scene then 
		curScenePlayer = scene:getEntities(0, pos.x, pos.y, DART_CHECK_AROUND, eClsTypePlayer, 0) or {}
	end
	local teamCount = 0
	local teamData = g_commonMgr._dart_datas.sendList[teamID]
	local teamRole = {}
	if teamData then 
		teamRole = teamData.teamRole
	else
		return 0
	end
	for i=1, #curScenePlayer do
		local roleID = curScenePlayer[i]
		local player = g_entityMgr:getPlayer(roleID)
		if player then 
			for i,v in pairs(teamRole) do
				if v.roleSID == player:getSerialID() then 
					teamCount = teamCount + 1
					break
				end
			end
		end
	end
	return teamCount
end


function CommonInfo:dealReward(result)
	local teamID = self._dart_datas.teamID
	local teamData = g_commonMgr._dart_datas.sendList[teamID]
	if teamData then 
		local expPer = g_commonMgr._dart_datas.ExpPer[teamData.teamMaxCnt]
		local rewardExp = g_commonMgr._dart_datas.rewardExp
		local exp = self._dart_datas.rewardCount * expPer * rewardExp
		print(self:getRoleSID(),expPer,rewardExp,exp)
		self._dart_datas.rewardExp = exp
		g_tlogMgr:TlogHuBiaoFlow(self._dart_datas.gameAppID,self._dart_datas.platID,self._dart_datas.openid,self._dart_datas.level,self._dart_datas.rewardType,teamData.teamMaxCnt,result,self._dart_datas.rewardExp)
		self:finishClearDart()
		if self._dart_datas.count == 0 then 
			self:setDartState(2) 
		end
		local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
		if player then 
			self:cast2db()
		else
			g_commonMgr._dartOffRewardeExp[self:getRoleSID()] = {roleSID = self:getRoleSID(),
														rewardExp = self._dart_datas.rewardExp,
														count = self._dart_datas.count
														}
			g_commonMgr:cast2Commondata()
		end
	end
end

function CommonInfo:FinishNotity(result)
	local player = g_entityMgr:getPlayerBySID(self:getRoleSID())
	if not player then 
		return 
	end

	if result then 
		--任务
		g_commonServlet:sendErrMsg2Client(DART_SUCCESS,0,{},self:getRoleID())
		
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.DartSuccess, 1)
		g_taskMgr:NotifyListener(player, "onDart") 
		g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.DART, 1)
	else
		g_commonServlet:sendErrMsg2Client(DART_FAILD,0,{},self:getRoleID())
	end
	player:setCampID(0)
end

-- 是否已经加载过db数据
function CommonInfo:getLoadDB()
	return self._loadDB
end

-- 获得是否有护送
function CommonInfo:getConvoy()
	return self._common_datas.convoy
end

-- 设置是否护送
function CommonInfo:setConvoy(value)
	self._common_datas.convoy = value
	self:cast2db()
end


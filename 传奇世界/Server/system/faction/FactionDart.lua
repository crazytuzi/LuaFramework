--FactionDart.lua
FactionDart = class()

--local prop = Property(FactionDart)

function FactionDart:__init(faction)
	self._dropItem = {}		--没有被持有的物资

	self._FacMorID = {}    --行会==领地ID
	self._facDartTable = {}--行会__物资对应

	self._itemOldFacID = {} --领取的物资纪录
	--self._OldFacItemID = {} 
	self._curFactionOwner = {} --{roleSID = player:getSerialID(), time = os.time()}
	self._facState = {}  -- nil 表示没开始 1表示领取成功,2 被劫,3 劫到 4已经完成 5 发送保底奖励

	self._singleRedExp = 0	--上交人奖励  经验
	self._RedFacMoney = 0	--上交行会奖励 行会财富
	self._allRewardExp = 0  --上交行会当前地图成员奖励 经验
	self._guarantee_guild_exp =0 -- 发起行会奖励
	self._timeStamp = time.toedition("day")
	self._notifyTimeStamp = os.time()

	self._tlogData = {}

	self:loadFacManorID()
end

function FactionDart:loadFacManorID( )
	local facDartDB = require "data.FacDart"
	for i,v in pairs(facDartDB) do
		local manorID = v.manorID
		local itemID = v.Item_id
		local dropID = v.Drop_id
		local factionID = g_manorWarMgr:getManorFacId(manorID)
		self._facDartTable[factionID] = {itemID = itemID, dropID = dropID}
	end
	self._singleRedExp = facDartDB[1].q_finish_exp
	self._RedFacMoney = facDartDB[1].q_finishs_guild
	self._allRewardExp = facDartDB[1].q_partake_exp
	self._guarantee_guild_exp = facDartDB[1].q_guarantee_guild_exp
	self._FacMorID = g_manorWarMgr:getFacManorID()
	self._facDartTable[9000017] = {itemID = 6200052,dropID = 2222}
	self._FacMorID[9000017] = 1
end
function FactionDart:isPickGoods( factionID)
	if not factionID then 
		return true
	end

	for i,v in pairs(self._itemOldFacID) do
		if v == factionID then 
			return true 
		end
	end

	return false
end

function FactionDart:finishDart( factionID,itemID)
	if factionID ~= 0 then
		if factionID == self._itemOldFacID[itemID] then 
			self:setDartState(factionID,4)
		else
			self:setDartState(factionID,3)
		end
		self._curFactionOwner[itemID] = nil
	end
	-- body
end

function FactionDart:getDartState(factionID)
	if factionID ~= 0 then 
		return self._facState[factionID]
	end
end
function FactionDart:setDartState( factionID,state )
	if factionID then 
		self._facState[factionID] = state
	end
end

function FactionDart:isHasManor(factionID)
	return self._FacMorID[factionID] and true or false
end

function FactionDart:pickUp(player, itemID)
	if player then 
		self._dropItem[itemID] = nil
		self._curFactionOwner[itemID] = {roleSID = player:getSerialID(), time = os.time()}
		local oldFactionID = self._itemOldFacID[itemID]
		local oldFaction = g_factionMgr:getFaction(oldFactionID)
		local faction = g_factionMgr:getFaction(player:getFactionID())
		if faction and oldFaction then 
			g_normalLimitMgr:sendErrMsg2Client(97,5,{faction:getName(),player:getName(),player:getPosition().x,player:getPosition().y,oldFaction:getName()})
		end

		g_rideMgr:offRide(player:getSerialID())

		if self._tlogData[oldFactionID] then
			self._tlogData[oldFactionID].changeCount = self._tlogData[oldFactionID].changeCount + 1
		end
	end
end

function FactionDart:drop(player, itemID)
	if player then 
		self._curFactionOwner[itemID] = nil
		self._dropItem[itemID] = {time = os.time(),startTime = os.time(),x = player:getPosition().x, y = player:getPosition().y,facName = player:getFactionName(),broadTimes = 0}
		--全服掉落公告
		g_normalLimitMgr:sendErrMsg2Client(96,3,{player:getFactionName(),player:getPosition().x,player:getPosition().y})
	end
end

function FactionDart:notify()
	for i,v in pairs(self._curFactionOwner) do
		local player = g_entityMgr:getPlayerBySID(v.roleSID)
		if player and os.time() > v.time + FACTION_DART_SPACE_TIME  then 
			self._curFactionOwner[i].time = os.time()
			g_normalLimitMgr:sendErrMsg2Client(99,4,{player:getFactionName(),player:getPosition().x,player:getPosition().y})
		end
	end

	for i,v in pairs(self._dropItem) do
		if os.time() > v.time + FACTION_DART_SPACE_TIME then 
			self._dropItem[i].time = os.time()
			self._dropItem[i].broadTimes = self._dropItem[i].broadTimes + 1

			-- if self._dropItem[i].broadTimes == 2 then 
			-- 	self._dropItem[i] = nil 
			-- end
			g_normalLimitMgr:sendErrMsg2Client(96,3,{v.facName,v.x,v.y})
		end	
		if os.time() > v.startTime + FACTION_DART_RELEASE_ITEM_TIME then 
			self._dropItem[i] = nil 

			local oldFactionID = self._itemOldFacID[itemID] 
			self:writeTlog(oldFactionID, 2, 0)

			self:sendBaseReward(i)
		end
	end
	if self._timeStamp ~= time.toedition("day") then 
		g_factionMgr:offFacDart()
	end

	if self._notifyTimeStamp ~= 0 and os.time() - self._notifyTimeStamp > 60 then
		self._notifyTimeStamp = 0
		g_normalLimitMgr:sendErrMsg2Client(104, 0, {})
	end
end

function FactionDart:join(player,faction)
	if player and faction then
		local factionID = player:getFactionID()
		if self._facDartTable[factionID] then
			local dropID = self._facDartTable[factionID].dropID 

			local itemID = self._facDartTable[factionID].itemID 
			self:setDartState(factionID,1)
			--保存活动开启行会信息
			self._itemOldFacID[itemID] = factionID
			self._curFactionOwner[itemID] = {roleSID = player:getSerialID(), time = os.time()}
			
			--显示头顶物品
			player:showDropItem(dropID)
			--全服公告
			g_normalLimitMgr:sendErrMsg2Client(95,4,{player:getFactionName(),player:getName(),player:getPosition().x,player:getPosition().y})

			local scene = g_sceneMgr:getPublicScene(4100)
			if scene then
				local curScenePlayer = scene:getEntities(0, 50, 50, 200, eClsTypePlayer, 0) or {}
				for i=1, #curScenePlayer do
					local roleID = curScenePlayer[i]
					local player = g_entityMgr:getPlayer(roleID)
					if player then 
						if player:getFactionID() == factionID then
							g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.FACTION_DART)
						end
					end
				end
			end

			self._tlogData[factionID] = {}
			self._tlogData[factionID].openFactionID = factionID
			self._tlogData[factionID].changeCount = 0
			self._tlogData[factionID].openTime = os.time()

			self:writeTlog(factionID, 1, 0)

			g_factionMgr:notifyAllMemByEmail(factionID, FactionHD.YUNBIAO)
		end
	end
end

function FactionDart:sendReward(player, faction,itemID)
	--[[

	if  not player or not faction or not itemID then 
		return 
	end

	g_normalLimitMgr:sendErrMsg2Client(98,3,{player:getName(),faction:getName(),self._RedFacMoney})	

	--给上交人发送单独奖励 经
	g_factionMgr:sendEmail(player:getSerialID(),FACTION_DART_SIGLE_EMAIL_ID, 444444, self._singleRedExp)

	--给发起运送的行会发放奖励和邮件
	local allFacMem = faction:getAllMembers()
	local allMem = {}
	for k,v in pairs(allFacMem) do
		local roleSID = v:getRoleSID()
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player and player:getMapID() == FACTION_DART_MAP_ID then 
			g_factionMgr:sendEmail(roleSID,FACTION_DART_ALL_EMAIL_ID,444444 , self._allRewardExp)
		end
	end
	--向完成的会长.发送邮件通知
	faction:setMoney(faction:getMoney() + self._RedFacMoney)
	g_factionMgr:sendEmail(faction:getLeaderID(),FACTION_DART_LEADER_EMAIL_ID, nil,nil, self._RedFacMoney)
	self:setDartState(player:getFactionID(),4)
	self._itemOldFacID[itemID] = nil
	--对发起行会发送保底 行会财富
	local oldFactionID = self._itemOldFacID[itemID]
	if player:getFactionID() ~= oldFactionID then 
		self:sendBaseReward(itemID)
	end

	]]

	if not player or not faction or not itemID then 
		return 
	end

	--给上交人发送单独奖励 经
	g_factionMgr:sendEmail(player:getSerialID(),FACTION_DART_GIVE_UP_EMAIL_ID, 444444, self._singleRedExp)

	-- 给上交的工会成员发奖励
	local allFacMem = faction:getAllMembers()
	local allMem = {}
	for k,v in pairs(allFacMem) do
		local roleSID = v:getRoleSID()
		g_factionMgr:sendEmail(roleSID,FACTION_DART_PART_IN_EMAIL_ID,444444 , self._allRewardExp)
	end

	local oldFactionID = self._itemOldFacID[itemID] 
	self:writeTlog(oldFactionID, 2, faction:getFactionID())

	self:sendBaseReward(itemID)

	local oldFaction = g_factionMgr:getFaction(oldFactionID)
	if oldFaction then 
		g_factionMgr:addNewBigEvent(FACTION_EVENT_GET_GOODS, {faction:getName(), oldFaction:getName()})
	end
end

function FactionDart:sendBaseReward(itemID)
	--[[
	if  not itemID then 
		return 
	end
	local oldFactionID = self._itemOldFacID[itemID]
	
	local oldFaction = g_factionMgr:getFaction(oldFactionID)
	if oldFaction then 
		oldFaction:setMoney(oldFaction:getMoney() + self._guarantee_guild)
		g_factionMgr:sendEmail(oldFaction:getLeaderID(),FACTION_DART_LEADER_EMAIL_ID, nil,nil,self._guarantee_guild)
	end
	self:setDartState(oldFactionID,4)
	self._itemOldFacID[itemID] = nil
	-- body
	]]

	if not itemID then
		return
	end

	local oldFactionID = self._itemOldFacID[itemID]
	if oldFactionID then
		local faction = g_factionMgr:getFaction(oldFactionID)
		if faction then
			local allFacMem = faction:getAllMembers()
			local allMem = {}
			for k,v in pairs(allFacMem) do
				local roleSID = v:getRoleSID()
				g_factionMgr:sendEmail(roleSID,FACTION_DART_FAQI_EMAIL_ID,444444 , self._guarantee_guild_exp)
			end
			self:setDartState(oldFactionID,4)
		end
	end

	self._itemOldFacID[itemID] = nil
end


function FactionDart:close( ... )
	-- body
end


function FactionDart:writeTlog(openFactionID, tType, handFactionID)
	if self._tlogData[openFactionID] == nil then
		return
	end

	local data = self._tlogData[openFactionID]

	if tType == 1 then
		g_tlogMgr:TlogFactionWZFlow(openFactionID, data.openTime, 1, 4100, 0, 0, 0, 0)
	elseif tType == 2 then
		local openPrizeMems = 0

		local openFaction = g_factionMgr:getFaction(openFactionID)
		if not openFaction then
			return
		else
			local allFacMem = openFaction:getAllMembers()
			for k,v in pairs(allFacMem) do
				openPrizeMems = openPrizeMems + 1
			end
		end

		local handPrizeMems = 0

		if handFactionID ~= 0 then
			local handFaction = g_factionMgr:getFaction(handFactionID)
			if not handFaction then
				return
			else
				local allFacMem = handFaction:getAllMembers()
				for k,v in pairs(allFacMem) do
					handPrizeMems = handPrizeMems + 1
				end
			end
		end

		prizeMems = openPrizeMems + handPrizeMems
		totalExp = openPrizeMems * self._guarantee_guild_exp + handPrizeMems * self._allRewardExp + self._singleRedExp

		g_tlogMgr:TlogFactionWZFlow(openFactionID, data.openTime, 2, 4100, prizeMems, handFactionID, data.changeCount, totalExp)
	end
end



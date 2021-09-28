--MonthCard.lua
--/*-----------------------------------------------------------------
--* Module:  MonthCard.lua
--* Author:  Andy
--* Modified: 2016年5月31日
--* Purpose: Implementation of the class MonthCard
-------------------------------------------------------------------*/

require ("base.class")
MonthCard = class()

local prop = Property(MonthCard)
prop:accessor("roleID")
prop:accessor("roleSID")
prop:accessor("ActivityID")

function MonthCard:__init(roleID, roleSID, activityID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)
	prop(self, "ActivityID", activityID)

	self._datas = {
		nLastRewardDate = 0, --上次领奖的日期
		nInvalidTime = 0,	 --失效的时间戳
	}
end

--续费使用的物品ID
function MonthCard:getBuyItemId()
	if self:getActivityID() == ACTIVITY_MONTHCARD_ID then
		return MONTH_CARD_ITEMID;
	elseif self:getActivityID() == ACTIVITY_MONTHCARD_LUXURY_ID then
		return MONTH_CARD_LUXURY_ITENID;
	end
	return nil;
end

--红点显示
function MonthCard:redDot()
	local nCureentTime = os.time();
	if self._datas.nInvalidTime > nCureentTime then
		if self._datas.nLastRewardDate < time.toedition("day") then	
			return true;
		end
	end	
	return false;
end

--整点判断是否能领取奖励
function MonthCard:check()
	local nCureentTime = os.time();
	if self._datas.nInvalidTime > nCureentTime then
		if self._datas.nLastRewardDate < time.toedition("day") then	
			--推送月卡剩余天数
			g_ActivityMgr:pushChargeData(self:getRoleID())
			--推送所有有效活动
			g_ActivityMgr:getActivityList(self:getRoleID())
		end
	end	
end

-- 得到月卡剩余天数
function MonthCard:calcSurplus()
	if self._datas.nInvalidTime > 0 and self._datas.nInvalidTime > os.time() then
		local second = self._datas.nInvalidTime - os.time()
		return math.ceil(second / DAY_SECENDS)
	else
		return 0 
	end
end

--使用物品
function MonthCard:useItem(nItemId,nActivityModule,nActivityId)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return 0;
	end

	--print("---m2---"..tostring(nItemId).."--"..tostring(self:getActivityID()))
	if nItemId ~= self:getBuyItemId() then
		return 0;
	end	

	--[[if self:calcSurplus() > 5 then
		g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_MONTHCARD_TIMELIMIT, 0, {})
		return 0;
	end]]--
	print("[MonthCard] UseItem Success!"..tostring(self:getRoleSID()).."CardType:"..tostring(self:getActivityID()));

	if self._datas.nInvalidTime < os.time() then
		local tDate = os.date("*t", now)
		self._datas.nInvalidTime = os.time() - tDate.hour * 3600 - tDate.min * 60 - tDate.sec - 1;
	end	

	if self:getActivityID() == ACTIVITY_MONTHCARD_ID then
		g_logManager:writePropChange(player:getSerialID(), 2, 221, nItemId, 0, 1, 0)
	elseif self:getActivityID() == ACTIVITY_MONTHCARD_LUXURY_ID then
		g_logManager:writePropChange(player:getSerialID(), 2, 222, nItemId, 0, 1, 0)
	end

	self._datas.nInvalidTime =  self._datas.nInvalidTime + 3600 * 24 * 30;
	self:cast2DB();

	g_ActivityMgr:getActivityList(self:getRoleID())
	return 1;
end

--续费
function MonthCard:renew(nIndex)
	--print("----renew---");
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return;
	end

	--print("----renew"..tostring(self:calcSurplus()));
	--[[if self:calcSurplus() > 5 then
		g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_MONTHCARD_TIMELIMIT, 0, {})
		return;
	end]]--


	--[[local itemMgr = player:getItemMgr()
	local nItemId = self:getBuyItemId()
	local tItem = itemMgr:findItemByItemID(nItemId)
	if not tItem then
		g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_MONTHCARD_BUYITEM_LIMIT, 0, {})
		return;
	end


	local errId = 0
	local bFlag = itemMgr:destoryItem(nItemId, 1, errId)
	if not bFlag then 
		g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_MONTHCARD_BUYITEM_LIMIT, 0, {})
		return 
	end
	
	if self:getActivityID() == ACTIVITY_MONTHCARD_ID then
		g_logManager:writePropChange(player:getSerialID(), 2, 221, nItemId, 0, 1, 0)
	elseif self:getActivityID() == ACTIVITY_MONTHCARD_LUXURY_ID then
		g_logManager:writePropChange(player:getSerialID(), 2, 222, nItemId, 0, 1, 0)
	end
	]]--

	local nItemId = self:getBuyItemId()
	local nLogTyp = 221
	if self:getActivityID() == ACTIVITY_MONTHCARD_LUXURY_ID then
		nLogTyp = 222
	end	
	
	local isCost = costMat(player, nItemId, 1, nLogTyp, 0)
	if not isCost then return end

	print("[MonthCard] Renew Success!"..tostring(self:getRoleSID()).."CardType:"..tostring(self:getActivityID()));

	if self._datas.nInvalidTime < os.time() then
		local tDate = os.date("*t", now)
		self._datas.nInvalidTime = os.time() - tDate.hour * 3600 - tDate.min * 60 - tDate.sec - 1;
	end	

	self._datas.nInvalidTime =  self._datas.nInvalidTime + 3600 * 24 * 30;
	self:cast2DB()

	g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_MONTHCARD_RENEW_SUCCESS, 0, {})

	g_ActivityMgr:getActivityList(self:getRoleID())
end

function MonthCard:req()
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if player then
		local monthCards = {}
		monthCards.surplus = self:calcSurplus()
		monthCards.status = 0
		if self._datas.nInvalidTime < os.time() then
			if self:getActivityID() == ACTIVITY_MONTHCARD_ID then
				--g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_MONTHCARD_INVALID, 0, {})
				monthCards.status = 2
			elseif self:getActivityID() == ACTIVITY_MONTHCARD_LUXURY_ID then
				--g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_LUXURY_MONTHCARD_INVALID, 0, {})
				monthCards.status = 2
			end
		end	

		if self._datas.nLastRewardDate >= time.toedition("day") then
			monthCards.status = 2
		end	

		local config = g_DataMgr:getMonthCardConfig()
		monthCards.reward = g_ActivityMgr:filterReward(player, config[self:getActivityID()])
		local ret = {}
		ret.modelID = ACTIVITY_MODEL.MONTHCARD
		ret.activityID = self:getActivityID()
		ret.monthCard = monthCards
		fireProtoMessage(self:getRoleID(), ACTIVITY_SC_RET, "ActivityRet", ret)
	end
end

function MonthCard:reward()
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return
	end
	if self._datas.nInvalidTime < os.time() then
		if self:getActivityID() == ACTIVITY_MONTHCARD_ID then
			g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_MONTHCARD_INVALID, 0, {})
		elseif self:getActivityID() == ACTIVITY_MONTHCARD_LUXURY_ID then
			g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_LUXURY_MONTHCARD_INVALID, 0, {})
		end
		return;
	end	
	if self._datas.nLastRewardDate >= time.toedition("day") then
		g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_MONTHCARD_REWARD_REPEAT, 0, {})	
		return;
	end	
	local itemMgr = player:getItemMgr()
	if itemMgr then
		local config = g_DataMgr:getMonthCardConfig()
		local rewards = g_ActivityMgr:filterReward(player, config[self:getActivityID()])
		if g_ActivityMgr:isEmpty(rewards) then
			return
		end
		self._datas.nLastRewardDate = time.toedition("day");
		if table.size(rewards) > itemMgr:getEmptySize(Item_BagIndex_Bag) then
			if self:getActivityID() == ACTIVITY_MONTHCARD_ID then
				g_ActivityMgr:sendRewardByEmail(self:getRoleSID(), rewards, 223)
			elseif self:getActivityID() == ACTIVITY_MONTHCARD_LUXURY_ID then
				g_ActivityMgr:sendRewardByEmail(self:getRoleSID(), rewards, 224)
			end
		else
			for _,item in pairs(rewards) do
				itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind, 0, 0, item.strength)
				if self:getActivityID() == ACTIVITY_MONTHCARD_ID then
					g_logManager:writePropChange(player:getSerialID(), 2, 223, item.itemID, 0, 1, item.bind)
				elseif self:getActivityID() == ACTIVITY_MONTHCARD_LUXURY_ID then
					g_logManager:writePropChange(player:getSerialID(), 2, 224, item.itemID, 0, 1, item.bind)
				end
			end	
			g_ActivityMgr:sendErrMsg2Client(self:getRoleID(), ACTIVITY_ERR_SUCCESS, 0, {})
		end
		self:req()
		g_ActivityMgr:getActivityList(self:getRoleID())
		g_logManager:writeOpactivities(self:getRoleSID(), self:getActivityID(), self._datas.date, 2)
		self:cast2DB()
	end
end

function MonthCard:loadDBdata(datas)
	self._datas = datas
	self:check()
end

function MonthCard:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), ACTIVITY_MODEL.MONTHCARD, self:getActivityID(), self._datas)
end
--SignIn.lua
--/*-----------------------------------------------------------------
--* Module:  SignIn.lua
--* Author:  Andy
--* Modified: 2016年06月27日
--* Purpose: Implementation of the class SignIn
-------------------------------------------------------------------*/

require ("base.class")
SignIn = class()

local prop = Property(SignIn)
prop:accessor("roleID")
prop:accessor("roleSID")

function SignIn:__init(roleID, roleSID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

    self._datas = {
	    count = 0,		--签到天数
		time = 0,		--签到时间戳
	}
end

function SignIn:redDot()
	return not self:signInToday()
end

--可以补签的天数
function SignIn:getResign()
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return 0
	end
	local createTime = time.totime(player:getCreateDate())		--创建账号的时间
	local now = os.time() - ACTIVITY_REFRESH * 3600
	local validDay = math.min(os.date("*t", now).day, dayBetween(now, createTime))
	return math.max(0, validDay - self._datas.count)
end

--当天是否已签到
function SignIn:signInToday()
	return time.toedition("day", os.time() - ACTIVITY_REFRESH * 3600) == time.toedition("day", self._datas.time)
end

function SignIn:req()
	local roleID = self:getRoleID()
	local player = g_entityMgr:getPlayer(roleID)
	if player then
		local sign = {}
		local t = os.date("*t", os.time())
		local month = t.month
		if self._datas.time ~= 0 and month ~= os.date("*t", self._datas.time).month then
			self._datas.count = 0
		end
		sign.day = t.day
		sign.month = month
		sign.signDay = self._datas.count
		sign.isToday = self:signInToday()
		sign.reSignDay = self:getResign()
		sign.reSignCount = ACTIVITY_RESIGN_INGOT
		local ret = {}
		ret.modelID = ACTIVITY_MODEL.SIGNIN
		ret.activityID = ACTIVITY_SIGNIN_ID
		ret.sign = sign
		fireProtoMessage(self:getRoleID(), ACTIVITY_SC_RET, "ActivityRet", ret)
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.supplementSign, 1)
	end
end

function SignIn:signIn()
	local roleID = self:getRoleID()
	if self:signInToday() then
		g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_SIGNIN, 0, {})
		return
	end
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end
	local roleSID = player:getSerialID()
	self._datas.count = self._datas.count + 1
	self._datas.time = os.time() - ACTIVITY_REFRESH * 3600
	local t = os.date("*t", os.time())
	local singData = g_DataMgr:getSignConfig(t.month)
	local item = singData[self._datas.count]
	local count = item.num
	local ret = {
		itemID = item.itemID,
		count = count,
	}
	fireProtoMessage(roleID, ACTIVITY_SC_SIGNIN, "ActivitySignInRet", ret)
	g_logManager:writeOpactivities(roleSID, ACTIVITY_SIGNIN_ID, t.day, 2)
	g_logManager:writeSign(roleSID, 1, g_ActivityMgr:getItemName(item.itemID), count, serialize(time.tostring(self._datas.time)))
	g_logManager:writePropChange(roleSID, 1, 41, item.itemID, 0, count)

	self:req()
	g_ActivityMgr:getActivityList(roleID)
	self:cast2DB()
	
	g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.sign, {t.year, t.month, t.day})
	--通知任务系统
	g_taskMgr:NotifyListener(player, "onTDailySign")
	if player:getAppStartType() == 1 or player:getAppStartType() == 2 then
		player:setMoney(player:getMoney() + ACTIVITY_ADD_MONEY)
		g_logManager:writeMoneyChange(roleSID, "", 1, 41, player:getMoney(), ACTIVITY_ADD_MONEY, 1)
		g_ChatSystem:GetMoneyIntoChat(roleSID, ITEM_MONEY_ID, ACTIVITY_ADD_MONEY)
	end
	if item.itemID == ITEM_INGOT_ID then
		player:setIngot(player:getIngot() + count)
		g_logManager:writeMoneyChange(roleSID, "", 3, 41, player:getIngot(), count, 1)
		g_ChatSystem:GetMoneyIntoChat(roleSID, ITEM_INGOT_ID, count)
	elseif item.itemID == ITEM_BIND_INGOT_ID then
		player:setBindIngot(player:getBindIngot() + count)
		g_logManager:writeMoneyChange(roleSID, "", 4, 41, player:getBindIngot(), count, 1)
		g_ChatSystem:GetMoneyIntoChat(roleSID, ITEM_BIND_INGOT_ID, count)
	elseif item.itemID == ITEM_MONEY_ID then
		player:setMoney(player:getMoney() + count)
		g_logManager:writeMoneyChange(roleSID, "", 1, 41, player:getMoney(), count, 1)
		g_ChatSystem:GetMoneyIntoChat(roleSID, ITEM_MONEY_ID, count)
	else
		local itemMgr = player:getItemMgr()
		if itemMgr:getEmptySize(Item_BagIndex_Bag) <= 0 then
			local reward = {{
				itemID = item.itemID,
				count = count,
				bind = item.bind,
				strength = 0,
			}}
			g_ActivityMgr:sendRewardByEmail(roleSID, reward, 41)
		else
			itemMgr:addItem(Item_BagIndex_Bag, item.itemID, count, item.bind)
		end
	end
end

function SignIn:reSign(times)
	local roleID = self:getRoleID()
	if times > self:getResign() then
		g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_RESIGN, 0, {})
		return
	end
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return
	end
	local itemMgr = player:getItemMgr()
	local ingot = player:getIngot()
	local needIngot = times * ACTIVITY_RESIGN_INGOT
	if itemMgr:getEmptySize(Item_BagIndex_Bag) < times then
		g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_NOSLOT, 0, {})
	elseif ingot < needIngot then
		g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_INGOT, 0, {})
	else
		local context = {roleID = roleID, modelID = ACTIVITY_MODEL.SIGNIN, activityID = ACTIVITY_SIGNIN_ID, times = times}
		local ret = g_tPayMgr:TPayScriptUseMoney(player, needIngot, 41, "", 0, 0, "ActivityManager.costIngotCallback", serialize(context))
		-- if ret == 0 then
		-- 	print("Success")
		-- else
		-- 	print("error")
		-- end
	end
end

function SignIn:reSignCallback(times)
	local roleID, result = self:getRoleID(), TPAY_FAILED
	if times > self:getResign() then
		g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_RESIGN, 0, {})
		return result
	end
	local player = g_entityMgr:getPlayer(roleID)
	if not player then
		return result
	end
	local itemMgr = player:getItemMgr()
	local ingot = player:getIngot()
	local needIngot = times * ACTIVITY_RESIGN_INGOT
	if itemMgr:getEmptySize(Item_BagIndex_Bag) < times then
		g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_NOSLOT, 0, {})
	elseif ingot < needIngot then
		g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_INGOT, 0, {})
	else
		self._datas.time = os.time() - ACTIVITY_REFRESH * 3600
		local t = os.date("*t", os.time())
		local singData = g_DataMgr:getSignConfig(t.month)
		local rewards = {}
		for day = self._datas.count + 1, self._datas.count + times do
			local item = singData[day]
			local count = item.num
			local reward = {}
			reward.itemID = item.itemID
			reward.count = count
			table.insert(rewards, reward)
			if item.itemID == ITEM_INGOT_ID then
				player:setIngot(player:getIngot() + count)
				g_logManager:writeMoneyChange(player:getSerialID(), "", 3, 41, player:getIngot(), count, 1)
			elseif item.itemID == ITEM_BIND_INGOT_ID then
				player:setBindIngot(player:getBindIngot() + count)
				g_logManager:writeMoneyChange(player:getSerialID(), "", 4, 41, player:getBindIngot(), count, 1)
			elseif item.itemID == ITEM_MONEY_ID then
				player:setMoney(player:getMoney() + count)
				g_logManager:writeMoneyChange(player:getSerialID(), "", 1, 41, player:getMoney(), count, 1)
			else
				itemMgr:addItem(Item_BagIndex_Bag, item.itemID, count, item.bind)
				g_logManager:writePropChange(player:getSerialID(), 1, 41, item.itemID, 0, count)
			end
			g_logManager:writeSign(player:getSerialID(), 2, g_ActivityMgr:getItemName(item.itemID), count, serialize(time.tostring(self._datas.time)))
			g_logManager:writeOpactivities(player:getSerialID(), ACTIVITY_SIGNIN_ID, day, 2)
		end
		local ret = {}
		ret.reward = rewards
		fireProtoMessage(roleID, ACTIVITY_CS_RESIGN_RET, "ActivityReSignInRet", ret)
		self._datas.count = self._datas.count + times
		self:req()
		g_ActivityMgr:getActivityList(roleID)
		self:cast2DB()
	end
	return result
end

function SignIn:gmSingIn(times)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return
	end
	local itemMgr = player:getItemMgr()
	times = times or 31
	times = math.min(self:getResign(), times)
	if times > 0 then
		local t = os.date("*t", os.time())
		local singData = g_DataMgr:getSignConfig(t.month)
		for day = self._datas.count + 1, self._datas.count + times do
			local item = singData[day]
			local count = item.num
			if item.itemID == ITEM_INGOT_ID then
				player:setIngot(player:getIngot() + count)
			elseif item.itemID == ITEM_BIND_INGOT_ID then
				player:setBindIngot(player:getBindIngot() + count)
			elseif item.itemID == ITEM_MONEY_ID then
				player:setMoney(player:getMoney() + count)
			else
				itemMgr:addBagItem(item.itemID, count, true, 0)
			end
		end
		self._datas.count = self._datas.count + times
		self:req()
		g_ActivityMgr:getActivityList(roleID)
		self:cast2DB()
	end
end

function SignIn:loadDBdata(datas)
	self._datas = datas
end

function SignIn:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), ACTIVITY_MODEL.SIGNIN, ACTIVITY_SIGNIN_ID, self._datas)
end
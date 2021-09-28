--AchieveServlet.lua

AchieveServlet = class(EventSetDoer, Singleton)

function AchieveServlet:__init()
	self._doer = {
		[ACHIEVE_CS_GETCOUNT] = AchieveServlet.doGetAchieveCount,
		[ACHIEVE_CS_GETACHIEVEDATA] = AchieveServlet.doGetAchieveData,
		[ACHIEVE_CS_GETTITLEDATA] = AchieveServlet.doGetTitleData,
		[ACHIEVE_CS_SETTITLE] = AchieveServlet.doSetTitle,
		[ACHIEVE_CS_DISLOADTITLE] = AchieveServlet.doDisLoadTitle,
	}
end

--获得已经得到的成就和称号数量
function AchieveServlet:doGetAchieveCount(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)

	if not player then return end
	local roleID = player:getID()
	local achievePlayer = g_achieveMgr:getAchievePlayer(player:getSerialID())
	if achievePlayer then
		local ret = {}
		ret.achieveCount = table.size(achievePlayer:getDoneAchieve())
		ret.titleCount = table.size(achievePlayer:getTitles())
		ret.achieveLevel = achievePlayer:getAchieveLevel()
		ret.achievePoint = achievePlayer:getCurrentPoint()
		ret.attrData = achievePlayer:getAchieveAttrString()
		fireProtoMessage(roleID, ACHIEVE_SC_GETCOUNTRET, "AchieveGetCountRet", ret)
	end
end

--获得已完成的成就数据
function AchieveServlet:doGetAchieveData(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then 
		return 
	end

	local roleID = player:getID()

	local achievePlayer = g_achieveMgr:getAchievePlayer(player:getSerialID())
	if achievePlayer and player then
		local achieveData = {}
		for achieveID, finishTime in pairs(achievePlayer:getDoneAchieves()) do
			table.insert(achieveData, {achieveID = achieveID, finishTime = finishTime})
		end

		local progress = {}
		for achieveID, value in pairs(achievePlayer:getAchieves()) do
			local achieveConfig = g_achieveMgr:getAchieveConfig(achieveID)
			if achieveConfig then
				table.insert(progress, {eventType = achieveConfig.q_groupid, progress = value})
			end
		end

		for groupID, value in pairs(achievePlayer:getDoneGroups()) do
			table.insert(progress, {eventType = groupID, progress = value})
		end

		local ret = {}
		ret.achieveData = achieveData
		ret.achieveProgress = progress
		fireProtoMessage(roleID, ACHIEVE_SC_GETACHIEVEDATARET, "AchieveGetAchieveDataRet", ret)
	end
end

--获取称号数据
function AchieveServlet:doGetTitleData(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then 
		return 
	end

	local achievePlayer = g_achieveMgr:getAchievePlayer(player:getSerialID())
	if achievePlayer then
		local achieveTitles = {}
		-- local attrData = {}

		-- local school = player:getSchool()

		-- attrData.q_max_hp = 0
		-- if school == 1 then
		-- 	attrData.q_attack_min = 0
		-- 	attrData.q_attack_max = 0
		-- elseif school == 2 then
		-- 	attrData.q_magic_attack_min = 0
		-- 	attrData.q_magic_attack_max = 0
		-- elseif school == 3 then
		-- 	attrData.q_sc_attack_min = 0
		-- 	attrData.q_sc_attack_max = 0
		-- end
		-- attrData.q_defence_min = 0
		-- attrData.q_defence_max = 0
		-- attrData.q_magic_defence_min = 0
		-- attrData.q_magic_defence_max = 0

		for titleID, finishTime in pairs(achievePlayer:getTitles()) do
			table.insert(achieveTitles, {titleID = titleID, finishTime = finishTime, isValidTitle = 0})
			local titleConfig = g_achieveMgr:getTitleConfig(titleID)
			if titleConfig then
				-- attrData.q_max_hp = (attrData.q_max_hp or 0) + (titleConfig.q_max_hp or 0)

				-- if school == 1 then
				-- 	attrData.q_attack_min = (attrData.q_attack_min or 0) + (titleConfig.q_attack_min or 0)
				-- 	attrData.q_attack_max = (attrData.q_attack_max or 0) + (titleConfig.q_attack_max or 0)
				-- elseif school == 2 then
				-- 	attrData.q_magic_attack_min = (attrData.q_magic_attack_min or 0) + (titleConfig.q_magic_attack_min or 0)
				-- 	attrData.q_magic_attack_max = (attrData.q_magic_attack_max or 0) + (titleConfig.q_magic_attack_max or 0)
				-- elseif school == 3 then
				-- 	attrData.q_sc_attack_min = (attrData.q_sc_attack_min or 0) + (titleConfig.q_sc_attack_min or 0)
				-- 	attrData.q_sc_attack_max = (attrData.q_sc_attack_max or 0) + (titleConfig.q_sc_attack_max or 0)
				-- end

				-- attrData.q_defence_min = (attrData.q_defence_min or 0) + (titleConfig.q_defence_min or 0)
				-- attrData.q_defence_max = (attrData.q_defence_max or 0) + (titleConfig.q_defence_max or 0)
				-- attrData.q_magic_defence_min = (attrData.q_magic_defence_min or 0) + (titleConfig.q_magic_defence_min or 0)
				-- attrData.q_magic_defence_max = (attrData.q_magic_defence_max or 0) + (titleConfig.q_magic_defence_max or 0)
				-- --attrData.q_crit = (attrData.q_crit or 0) + (titleConfig.q_crit or 0)
				-- --attrData.q_hit = (attrData.q_hit or 0) + (titleConfig.q_hit or 0)
				-- --attrData.q_dodge = (attrData.q_dodge or 0) + (titleConfig.q_dodge or 0)
				-- --attrData.battle = (attrData.battle or 0) + (titleConfig.battle or 0)
			end
		end

		local achieveTitleProgress = {}

		local ret = {}
		ret.attrData = ""
		ret.achieveTitle = achieveTitles
		ret.achieveTitleProgress = achieveTitleProgress
		fireProtoMessage(player:getID(), ACHIEVE_SC_GETTITLEDATARET, "AchieveGetTieleDataRet", ret)
	end
end

--设置称号
function AchieveServlet:doSetTitle(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	local req = self:decodeProto(pbc_string, "AchieveSetTitle")
	if not req or not player then return end
	local titleID = req.titleID
	local achievePlayer = g_achieveMgr:getAchievePlayer(player:getSerialID())
	if achievePlayer then
		achievePlayer:setCurTitle(titleID)
	end
end

--卸载称号
function AchieveServlet:doDisLoadTitle(buffer1)
	local params = buffer1:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)

	if not player then return end
	local achievePlayer = g_achieveMgr:getAchievePlayer(player:getSerialID())
	if achievePlayer and player then
		achievePlayer:setCurTitle(0)
	end
end

--装备强化
function AchieveServlet.upEquipment(roleSID, isSuc, isDown, isUseItem)
	g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.equipStrength, isSuc, isDown, isUseItem)
	g_ActivityMgr:equipmentUp(roleSID)
end

--穿戴装备通知
function AchieveServlet.installEquip(roleSID)
	g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.installEquip)
	g_ActivityMgr:equipmentUp(roleSID)
end

--called by c++ code	c++层和成就触发接口
function AchieveServlet.notifyC2Lua(roleSID, achieveType, conType, value)
	
end

--listen common event
function AchieveServlet:notify(roleSID, achieveType, conType, value)
	
end

--完成副本
--copyType(2、屠龙传说 3、多人守卫 4、拯救公主 5、勇闯天关)
function AchieveServlet:doneCopy(roleSID, copyType, value)
	-- self:notify(roleSID, AchieveType.Copy, AchieveEventType.DoneCopy, 1) 			--完成一次副本副本
	-- if copyType == 3 then
	-- 	self:notify(roleSID, AchieveType.Copy, AchieveEventType.SingleCopy, 1) 		--完成屠龙传说副本
	-- elseif copyType == 4 then
	-- 	self:notify(roleSID, AchieveType.Copy, AchieveEventType.MoreCopy, 1)		--完成多人守卫副本
	-- elseif copyType == 5 then
	-- 	self:notify(roleSID, AchieveType.Copy, AchieveEventType.PrincessCopy, 1)	--完成拯救公主副本
	-- elseif copyType == 6 then
	-- 	self:notify(roleSID, AchieveType.Copy, AchieveEventType.TowerCopy, 1)		--完成勇闯天关副本
	-- end
end

--勇闯天关全服第一
function AchieveServlet:setfastTower(roleSID, copyID)
	-- self:notify(roleSID, AchieveType.Copy, AchieveEventType.DoneTowerCopy, 1)
end

--屠龙传说副本全服第一
function AchieveServlet:setfastSingle(roleSID, copyID)
	self:notify(roleSID, AchieveType.Copy, AchieveEventType.DoneSingleCopy, 1)
end

--lastTime格式：{年，月，日}
function AchieveServlet:activenessReward(roleSID , aa)
	
end

--消耗元宝
function AchieveServlet.costIngotC2Lua(roleSID, costIngot)
	g_achieveSer:costIngot(roleSID, costIngot)
end

--消耗元宝
function AchieveServlet:costIngot(roleSID, costIngot)
	
end

--deal trigger event 成就激活判断处理逻辑
function AchieveServlet:dealEvent(achievePlayer, dealProtos, eventType, userData)

end

function AchieveServlet:decodeProto(pb_str, protoName)
	local protoData, errorCode = protobuf.decode(protoName, pb_str)
	if not protoData then
		print("decodeProto error! AchieveServlet:", protoName, errorCode)
		return
	end
	return protoData
end


function AchieveServlet:achieveNotify(roleSID, notifyType, ...)
	g_achieveMgr:dealAchieveNotify(roleSID, notifyType, ...)
end

function AchieveServlet.achieveNotifyC2Lua(roleSID, notifyType, ...)
	g_achieveMgr:dealAchieveNotify(roleSID, notifyType, ...)
end

-----------------------------------------
-- 成就通知


-- 金币改变
function AchieveServlet:onMoneyChange(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player == nil then
		return 
	end

	self:achieveNotify(roleSID, AchieveNotifyType.getGold, player:getMoney())
end

-- 使用技能
function AchieveServlet.useSkill(userID, targetID, skillID)
	if g_entityMgr:getMonster(userID) ~= nil then
		local user = g_entityMgr:getMonster(userID)
		if user == nil then
			return
		end

		local target = g_entityMgr:getPlayer(targetID)
		if target == nil then
			return
		end
		
		g_achieveSer:achieveNotify(target:getSerialID(), AchieveNotifyType.sufferSkill, 1, user:getModelID(), skillID)
	end
end

-- 使用物品
function AchieveServlet:useMat(player, matID, count)
	g_achieveMgr:useMat(player, matID, count)
end



function AchieveServlet.getInstance()
	return AchieveServlet()
end

g_eventMgr:addEventListener(AchieveServlet.getInstance())

g_achieveSer = AchieveServlet.getInstance()
--AchieveManager.lua
require "system.achievement.AchieveConstant"
require "system.achievement.AchieveConfig"
require "system.achievement.AchieveServlet"
require "system.achievement.AchievePlayer"

-- 求time1于time2相隔多少天
local function diffDay(time1, time2)
	local date1 = os.date("*t",time1)
	local date2 = os.date("*t",time2)
	if date1.year == date2.year then
		return math.abs(date1.yday - date2.yday)
	else
		date1.hour = 0
		date1.min = 0
		date1.sec = 0
		time1 = os.time(date1)

		date2.hour = 0
		date2.min = 0
		date2.sec = 0
		time2 = os.time(date2)

		return math.floor(math.abs(time1 - time2)/(24*3600))
	end
end

local function splitSetString(str)
	local strTab={}
	local sp=","
	while type(str)=="string" and string.len(str)>0 do
		local f=string.find(str,sp)
		local ele
		if f then
			ele=string.sub(str,1,f-1)
			str=string.sub(str,f+1)
		else
			ele=str
		end
		ele = tonumber(ele)
		strTab[ele] = true
		if not f then break	end
	end
	return strTab
end

AchieveManager = class(nil, Singleton, Timer)

function AchieveManager:__init(role)
	g_listHandler:addListener(self)

	self._achieveConfig  = {}		-- 成就配置
	self._achieveGroup = {}			-- 成就组
	self._achieveConfitionType = {}			-- 成就条件类型和成就组的映射
	self._titleConfig = {}			-- 称号配置
	self._achieveLevelConfig = {}	-- 成就等级配置
	self._titleAchieve = {}				-- 成就和对应的称号的映射
	self._specialTitleConfig = {}	-- 封号配置

	self._achievePlayer = {}		-- 玩家成就

	self._joinEnvoyTime = {}		-- 参加勇闯炼狱时间
	self._joinLuoxiaTime = {}		-- 参与落霞夺宝时间
	self._hurtFatcionBossTime = {}		-- 参与行会副本时间
	self._playerPKs = {}				-- 玩家pk值记录
end

function AchieveManager:update()
	
end

-- 获得成就配置
function AchieveManager:getAchieveConfig(achieveID)
	return self._achieveConfig[achieveID]
end

function AchieveManager:addAchievePlayer(roleSID, achievePlayer)
	self._achievePlayer[roleSID] = achievePlayer
end

function AchieveManager:getAchievePlayer(roleSID)
	return self._achievePlayer[roleSID]
end

function AchieveManager:getAchievePlayerBySID()

end

function AchieveManager:addPlayerInfo(player)
	if not self:getAchievePlayer(player:getSerialID()) then
		local achievePlayer = AchievePlayer(player)
		self:addAchievePlayer(player:getSerialID(), achievePlayer)
	end
end

-- 获得成就组对应的成就id
function AchieveManager:getGroupAchieveIDs(groupID)
	return self._achieveGroup[groupID]
end

-- 获得成就类型对应的组id
function AchieveManager:getAchieveConfitionGroupIDs(conditionType)
	return self._achieveConfitionType[conditionType]
end

-- 获得称号配置
function AchieveManager:getTitleConfig(titleID)
	return self._titleConfig[titleID]
end 

-- 获得成就对应的称号
function AchieveManager:getAchieveTitle(achieveID)
	return self._titleAchieve[achieveID]
end 

-- 获得成就等级配置
function AchieveManager:getAchieveLevelConfig()
	return self._achieveLevelConfig
end

--加载成就数据
function AchieveManager.loadAchieveDBData(player, cache_buf, roleSID)
	if not player then
		return
	end

	g_achieveMgr:addPlayerInfo(player)
	local achievePlayer = g_achieveMgr:getAchievePlayer(roleSID)
	if achievePlayer then
		achievePlayer:loadAchieveDBData(cache_buf)
	end
end

--加载成就进度数据
function AchieveManager.loadAchieveEventDBData(player, cache_buf, roleSID)
	g_achieveMgr:addPlayerInfo(player)
	if #cache_buf > 0 then
		local achievePlayer = g_achieveMgr:getAchievePlayer(roleSID)
		if achievePlayer then
			achievePlayer:loadAchieveEventDBData(cache_buf)
		end
	end
end

--加载称号数据
function AchieveManager.loadTitleDBData(player, cache_buf, roleSID)
	g_achieveMgr:addPlayerInfo(player)
	if player and #cache_buf > 0 then
		local achievePlayer = g_achieveMgr:getAchievePlayer(player:getSerialID())
		if achievePlayer then
			achievePlayer:loadTitleDBData(cache_buf)
		end
	end
end

-- 玩家登陆
function AchieveManager:onPlayerLoaded(player)
	if player then
		local roleSID = player:getSerialID()

		local achievePlayer = g_achieveMgr:getAchievePlayer(roleSID)
		if achievePlayer then
			achievePlayer:playerLoad()
		end

		self._playerPKs[roleSID] = player:getPK()

		self:updateSpecialTitle(roleSID)

		local playerFacitonID = player:getFactionID()
		if playerFacitonID ~= 0 then
			for i = 1, 8 do
				local factionID = g_manorWarMgr:getManorFacId(i)
				if factionID and factionID ~= 0 and factionID == playerFacitonID then
					if i == 1 then
						g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.winZhongzhouWar, 1)
					else
						g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.winManorWar, 1)
					end
				end
			end

			local shaFactionID = g_shaWarMgr:getShaFactionId()
			if not g_shaWarMgr:getOpenState() and shaFactionID and shaFactionID ~= 0 and playerFacitonID == shaFactionID then
				g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.winShaWar, 1)
			end
		end
	end
end

--玩家注销
function AchieveManager:onPlayerOffLine(player)
	self._achievePlayer[player:getSerialID()] = nil

	self._playerPKs[player:getSerialID()] = nil
end

-- 等级改变
function AchieveManager:onLevelChanged(player)
	if player then
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.levelUp, player:getLevel())

		self:updateSpecialTitle(player:getSerialID())
	end
end

-- 经验值改变
function AchieveManager:onExpChanged(player)
	if player then
		self:updateSpecialTitle(player:getSerialID())
	end
end

-- 战力改变
function AchieveManager:battleChanged(player, battle)
	local achievePlayer = self:getAchievePlayer(player:getSerialID())
	if achievePlayer and achievePlayer:getLoadAchieveFlag() then
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.fightAbility, battle)
	end
end

-- 获得物品
function AchieveManager:onAddItem(player, itemID)
	if player == nil then
		return
	end

	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.getItem, itemID)

	local achievePlayer = self:getAchievePlayer(player:getSerialID())
	if achievePlayer then
		achievePlayer:dealAddItemTitle(itemID)
	end
end

--获得坐骑
function AchieveManager:onAddRide(player, rideID)
	if player == nil then
		return
	end

	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.getRide, rideID)
end

-- 杀怪
function AchieveManager:onMonsterKill(monSID, roleID, monID, mapID)
	local player = g_entityMgr:getPlayer(roleID)
	if player == nil then
		return
	end

	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.killMonster, monSID, monID, mapID)
end

-- 伤害怪物
function AchieveManager:onMonsterHurt(monSID, roleID, hurt, monID)
	local player = g_entityMgr:getPlayer(roleID)
	if player == nil then
		return
	end

	local monster = g_entityMgr:getMonster(monID)
	if monster and monster:getTeXiao() == 3 and monster:getLevel() >= 30 then
		g_MainObjectMgr:notify(player:getSerialID(), MainObjectType.boss)
	end
end

-- 使用物品
function AchieveManager:useMat(player, matID, count)
	if player == nil then
		return
	end

	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.useItem, 1, matID)
end

-- 玩家死亡
function AchieveManager:onPlayerDied(player, killerID)
	if player == nil then
		return
	end

	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.playerDead, killerID)
end

--parse config data
function AchieveManager:parseAchieveData()
	local data = require "data.AchieveDB" or {}
	local size = #data
	local groupsTmp = {}

	self._achieveConfig = {}
	self._achieveGroup = {}
	self._achieveConfitionType = {}

	for i=1, size do
		self._achieveConfig[data[i].q_id] = data[i]

		for j = 1, AchieveCustomValueMax do
			local strTmp = "q_value"..j
			if data[i][strTmp] then
				data[i][strTmp] = tonumber(data[i][strTmp])
			end

			strTmp = "q_valueCmp"..j
			if data[i][strTmp] then
				data[i][strTmp] = tonumber(data[i][strTmp])
			end
		end

		for j = 1, AchieveValueSetMax do
			local strTmp = "q_valueset"..j
			local valueSet = data[i][strTmp]
			if valueSet then
				if valueSet == "" then
					data[i][strTmp] = nil
				else
					data[i][strTmp] = splitSetString(valueSet)
				end
			end
		end

		if data[i].q_groupid then
			if self._achieveGroup[data[i].q_groupid] == nil then
				self._achieveGroup[data[i].q_groupid] = {}
			end

			table.insert(self._achieveGroup[data[i].q_groupid], data[i].q_id)
		end

		if data[i].q_conditionType and data[i].q_groupid then
			if self._achieveConfitionType[data[i].q_conditionType] == nil then
				self._achieveConfitionType[data[i].q_conditionType] = {}
			end

			if groupsTmp[data[i].q_groupid] == nil then
				table.insert(self._achieveConfitionType[data[i].q_conditionType], data[i].q_groupid)
				groupsTmp[data[i].q_groupid] = true
			end
		end

		if data[i].q_conditionType == AchieveConditionType.addBuff and data[i].q_value2 then
			g_configMgr:addAchieveBuff(data[i].q_value2)
		end

		if data[i].q_conditionType == AchieveConditionType.sufferSkill and data[i].q_value2 then
			g_configMgr:addAchieveSkill(data[i].q_value2)
		end
	end
end

-- 解析称号配置
function AchieveManager:parseTitleData()
	local data = require "data.TitleDB" or {}
	local size = #data

	self._titleConfig = {}

	for i=1, size do
		local titleInfo = data[i]
		if titleInfo.q_needAchieves then
			if titleInfo.q_needAchieves == "" then
				titleInfo.q_needAchieves = nil
			else
				titleInfo.q_needAchieves = splitSetString(titleInfo.q_needAchieves)
			end

			for achieveID, _ in pairs(titleInfo.q_needAchieves) do
				if self._titleAchieve[achieveID] == nil then
					self._titleAchieve[achieveID] = {}
				end

				self._titleAchieve[achieveID][titleInfo.q_titleID] = true
			end
		end

		titleInfo.q_max_hp = titleInfo.q_max_hp and tonumber(titleInfo.q_max_hp)
		titleInfo.q_attack_min = titleInfo.q_attack_min and tonumber(titleInfo.q_attack_min)
		titleInfo.q_attack_max = titleInfo.q_attack_max and tonumber(titleInfo.q_attack_max)
		titleInfo.q_magic_attack_min = titleInfo.q_magic_attack_min and tonumber(titleInfo.q_magic_attack_min)
		titleInfo.q_magic_attack_max = titleInfo.q_magic_attack_max and tonumber(titleInfo.q_magic_attack_max)
		titleInfo.q_sc_attack_min = titleInfo.q_sc_attack_min and tonumber(titleInfo.q_sc_attack_min)
		titleInfo.q_sc_attack_max = titleInfo.q_sc_attack_max and tonumber(titleInfo.q_sc_attack_max)
		titleInfo.q_defence_min = titleInfo.q_defence_min and tonumber(titleInfo.q_defence_min)
		titleInfo.q_defence_max = titleInfo.q_defence_max and tonumber(titleInfo.q_defence_max)
		titleInfo.q_magic_defence_min = titleInfo.q_magic_defence_min and tonumber(titleInfo.q_magic_defence_min)
		titleInfo.q_magic_defence_max = titleInfo.q_magic_defence_max and tonumber(titleInfo.q_magic_defence_max)
		titleInfo.q_crit = titleInfo.q_crit and tonumber(titleInfo.q_crit)
		titleInfo.q_hit = titleInfo.q_hit and tonumber(titleInfo.q_hit)
		titleInfo.q_dodge = titleInfo.q_dodge and tonumber(titleInfo.q_dodge)

		self._titleConfig[titleInfo.q_titleID] = titleInfo
	end
end

-- 解析成就等级配置
function AchieveManager:parseAchieveLevelData()
	local data = require "data.AchieveLevelDB" or {}
	local size = #data

	self._achieveLevelConfig = {}

	for i = 1, size do
		local info = data[i]
		if info then
			if not self._achieveLevelConfig[info.q_achieveLevel] then
				self._achieveLevelConfig[info.q_achieveLevel] = {q_achieveLevel = info.q_achieveLevel, q_achievePoint = info.q_achievePoint, attr = {}}
			end

			local attr = self._achieveLevelConfig[info.q_achieveLevel].attr
			attr[info.q_school] = {}
			local attrInfo = attr[info.q_school]

			attrInfo.q_max_hp = info.q_max_hp and tonumber(info.q_max_hp)
			attrInfo.q_attack_min = info.q_attack_min and tonumber(info.q_attack_min)
			attrInfo.q_attack_max = info.q_attack_max and tonumber(info.q_attack_max)
			attrInfo.q_magic_attack_min = info.q_magic_attack_min and tonumber(info.q_magic_attack_min)
			attrInfo.q_magic_attack_max = info.q_magic_attack_max and tonumber(info.q_magic_attack_max)
			attrInfo.q_sc_attack_min = info.q_sc_attack_min and tonumber(info.q_sc_attack_min)
			attrInfo.q_sc_attack_max = info.q_sc_attack_max and tonumber(info.q_sc_attack_max)
			attrInfo.q_defence_min = info.q_defence_min and tonumber(info.q_defence_min)
			attrInfo.q_defence_max = info.q_defence_max and tonumber(info.q_defence_max)
			attrInfo.q_magic_defence_min = info.q_magic_defence_min and tonumber(info.q_magic_defence_min)
			attrInfo.q_magic_defence_max = info.q_magic_defence_max and tonumber(info.q_magic_defence_max)
			attrInfo.q_crit = info.q_crit and tonumber(info.q_crit)
			attrInfo.q_hit = info.q_hit and tonumber(info.q_hit)
			attrInfo.q_dodge = info.q_dodge and tonumber(info.q_dodge)
		end
	end
end

-- 解析封号
function AchieveManager:parseSpecialTitleData()
	local data = require "data.SpecialTitleDB" or {}
	local size = #data

	self._specialTitleConfig = {}

	for i = 1, size do
		local info = data[i]

		if not self._specialTitleConfig[info.q_school] then
			self._specialTitleConfig[info.q_school] = {}
		end

		table.insert(self._specialTitleConfig[info.q_school], info)
	end
end

-----------------------------------------
-- 成就通知
is_inAchieveNotify = false
is_inAchieveNotifyCount = 0

-- 处理成就通知
function AchieveManager:dealAchieveNotify(roleSID, notifyType, ...)
	if is_inAchieveNotify == true then
		print("is_inAchieveNotify degui", roleSID, notifyType, is_inAchieveNotifyCount)
		is_inAchieveNotify = false
		return
	end 
	is_inAchieveNotify = true
	is_inAchieveNotifyCount = is_inAchieveNotifyCount + 1


	local playerAchieve = self:getAchievePlayer(roleSID)

	if playerAchieve == nil then
		is_inAchieveNotify = false
		is_inAchieveNotifyCount = is_inAchieveNotifyCount - 1
		return
	end

	if not playerAchieve:getLoadAchieveFlag() then
		is_inAchieveNotify = false
		is_inAchieveNotifyCount = is_inAchieveNotifyCount - 1
		return
	end

	if AchieveNotifyFunc[notifyType] == nil then
		is_inAchieveNotify = false
		is_inAchieveNotifyCount = is_inAchieveNotifyCount - 1
		return
	end

	if AchieveNotifyFunc[notifyType].func == nil then
		is_inAchieveNotify = false
		is_inAchieveNotifyCount = is_inAchieveNotifyCount - 1
		return
	end

	if AchieveNotifyFunc[notifyType].func == "dealCommon" then
		self:dealCommon(roleSID, AchieveNotifyFunc[notifyType].conditionType, ...)
	else
		self[AchieveNotifyFunc[notifyType].func](self, roleSID, ...)
	end

	is_inAchieveNotify = false
	is_inAchieveNotifyCount = is_inAchieveNotifyCount - 1

	if notifyType == AchieveNotifyType.joinManorWar or notifyType == AchieveNotifyType.joinZhongzhouWar or notifyType == AchieveNotifyType.joinShaWar then
		g_MainObjectMgr:notify(roleSID, MainObjectType.faction)
	end
end

-- 处理通用成就
function AchieveManager:dealCommon(roleSID, conditionType, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	if conditionType == nil then
		return
	end

	local value = select(1, ...)

	local customValues = nil
	local count = select("#", ...)

	if count > 1 then
		customValues = {}
		for i = 2, count do
			local value = select(i, ...)
			table.insert(customValues, value)
		end
	end

	if value == nil then
		return
	end

	playerAchieve:dealAchieve(conditionType, {value = value, customValues = customValues})
end

-- 处理签到通知
function AchieveManager:dealSign(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local date = select(1, ...)

	if date == nil then
		return
	end

	local now = os.time()
	local signTime = os.time({year = date[1], month = date[2], day = date[3]})

	playerAchieve:dealAchieve(AchieveConditionType.sign,  {value = 1})

	if diffDay(now, signTime) <= 1 then
		playerAchieve:dealAchieve(AchieveConditionType.continueSign,  {value = 1})
	else
		playerAchieve:dealAchieve(AchieveConditionType.continueSign,  {achieveFail = true})
	end
end

-- 处理获得物品
function AchieveManager:dealGetItem(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local itemID = select(1, ...)

	if itemID == nil then
		return
	end

	local itemProto = g_entityMgr:getConfigMgr():getItemProto(itemID)
	if itemProto == nil then
		return
	end

	if itemProto.type == Item_Main_Class_Equip then
		playerAchieve:dealAchieve(AchieveConditionType.getEquip,  {value = 1, customValues = {itemProto.defaultColor}})
	end

	playerAchieve:dealAchieve(AchieveConditionType.getItem,  {value = 1, customValues = {itemID}, customSetValues = {itemID}})
end

-- 处理穿上装备
function AchieveManager:dealInstallEquip(roleSID, ...)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player == nil then
		return
	end

	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local itemMgr = player:getItemMgr()
	if itemMgr == nil then
		return
	end

	local suitCounts = {}
	for i = 1, Item_EquipPosition_Foot do
		local item = itemMgr:findItem(i, Item_BagIndex_EquipmentBar)
		if item then
			local equipProto = g_entityMgr:getConfigMgr():getEquipProto(item:getProtoID())
			if equipProto and equipProto.suitID > 0 then
				local oldValue = suitCounts[equipProto.suitID] or 0
				suitCounts[equipProto.suitID] = oldValue + 1
			end
		end
	end

	for suitID, count in pairs(suitCounts) do
		if count > 0 then
			playerAchieve:dealAchieve(AchieveConditionType.installSuit, {value = count, customValues = {suitID}})
		end
	end

	local strengthLevel = nil
	for i = 1, Item_EquipPosition_Foot do
		if i ~= Item_EquipPosition_Suit then
			local item = itemMgr:findItem(i, Item_BagIndex_EquipmentBar)
			if item then
				local equipProp = item:getEquipProp()
				if equipProp then
					equipStrengthLevel = equipProp:getStrengthLevel()

					if strengthLevel == nil then
						strengthLevel = equipStrengthLevel
					else
						if strengthLevel > equipStrengthLevel then
							strengthLevel = equipStrengthLevel
						end
					end
				end
			else
				strengthLevel = nil
				break
			end
		end
	end

	if strengthLevel then
		playerAchieve:dealAchieve(AchieveConditionType.allStrength, {value = strengthLevel})
	end

	g_MainObjectMgr:notify(roleSID, MainObjectType.equip)
end

-- 处理完成任务
function AchieveManager:dealFinishTask(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local task = select(1, ...)
	if task == nil then
		return
	end

	playerAchieve:dealAchieve(AchieveConditionType.finishTask, {value = 1, customValues = {task:getID(), task:getType()}})
end

-- 处理接受任务
function AchieveManager:dealAcceptTask(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local task = select(1, ...)
	if task == nil then
		return
	end

	if task:getType() == TaskType.Daily then
		local reward = task:getRewardID()
		local rewardProto = g_LuaTaskDAO:getDailyReward(task:getRewardID())
		if rewardProto then
			playerAchieve:dealAchieve(AchieveConditionType.accepDailytTask, {value = 1, customValues = {rewardProto.q_starLevel}})
		end
	end
end

-- 处理装备强化
function AchieveManager:dealEquipStrength(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local isSuc = select(1, ...)
	if isSuc == nil then
		return
	end

	local success = isSuc and 1 or 2

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local itemMgr = player:getItemMgr()
	if itemMgr == nil then
		return
	end

	playerAchieve:dealAchieve(AchieveConditionType.equipStrength, {value = 1, customValues = {success}})

	if isSuc then
		playerAchieve:dealAchieve(AchieveConditionType.continueEquipStrengthSuccess, {value = 1})
		playerAchieve:dealAchieve(AchieveConditionType.continueEquipStrengthFail,  {achieveFail = true})
	else
		playerAchieve:dealAchieve(AchieveConditionType.continueEquipStrengthFail, {value = 1})
		playerAchieve:dealAchieve(AchieveConditionType.continueEquipStrengthSuccess, {achieveFail = true})
	end

	local strengthLevel = nil
	for i = 1, Item_EquipPosition_Foot do
		if i ~= Item_EquipPosition_Suit then
			local item = itemMgr:findItem(i, Item_BagIndex_EquipmentBar)
			if item then
				local equipProp = item:getEquipProp()
				if equipProp then
					equipStrengthLevel = equipProp:getStrengthLevel()

					if strengthLevel == nil then
						strengthLevel = equipStrengthLevel
					else
						if strengthLevel > equipStrengthLevel then
							strengthLevel = equipStrengthLevel
						end
					end
				end
			else
				strengthLevel = 0
				break
			end
		end
	end

	if strengthLevel then
		playerAchieve:dealAchieve(AchieveConditionType.allStrength, {value = strengthLevel})
	end
end

-- 处理升级翅膀技能
function AchieveManager:dealUpWingSkill(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local wingInfo = g_wingMgr:getRoleWingInfoBySID(roleSID)
	local min = 0
	local max = 0

	local count = wingInfo:getSkillNum()
	for i = 1, count do
		local skill = wingInfo:getSkill(i)
		local level = skill.level
		if level < min then
			min = level
		end

		if level > max then
			max = level
		end

		playerAchieve:dealAchieve(AchieveConditionType.minWingSkill, {value = min})
		playerAchieve:dealAchieve(AchieveConditionType.minWingSkill, {value = max})
	end
end

-- 处理学习技能
function AchieveManager:dealLearnSkill(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local skillID = select(1, ...)
	if skillID == nil then
		return
	end

	local skillConfig = g_configMgr:getSkillConfig(skillID)
	if skillConfig == nil then
		return
	end

	playerAchieve:dealAchieve(AchieveConditionType.learnSkill, {value = 1, customValues = {skillConfig.skillType}})
end

-- 处理升级技能
function AchieveManager:dealUpSkill(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local skillstr = select(1, ...)
	if skillstr == nil then
		return
	end

	local newSkillLevel = select(2, ...)
	if newSkillLevel == nil then
		return
	end

	local b, skills = pcall(loadstring("return " .. skillstr))

	local minWingSkill = nil
	local maxWingSkill = 0

	local maxSkill = 0
	local count = 0

	local mainObjectSkillCount = 0

	local winSkill = {}
	for skillID, skillLevel in pairs(skills) do
		local skillConfig = g_configMgr:getSkillConfig(skillID)
		if skillConfig then
			if skillConfig.skillType == 7 then
				winSkill[skillID] = skillLevel

				if skillLevel > maxWingSkill then
					maxWingSkill = skillLevel
				end
			end

			if skillConfig.skillType == 1 then
				if skillLevel > maxSkill then
					maxSkill = skillLevel
				end

				if skillLevel >= 2 then
					mainObjectSkillCount = mainObjectSkillCount + 1
				end
			end
		end
	end

	for _, skillID in pairs(AchieveWingSkill) do
		if not winSkill[skillID] then
			minWingSkill = 0
			break
		else
			if minWingSkill == nil then
				minWingSkill = winSkill[skillID]
			else
				if minWingSkill > winSkill[skillID] then
					minWingSkill = winSkill[skillID]
				end
			end
		end
	end

	playerAchieve:dealAchieve(AchieveConditionType.minWingSkill, {value = minWingSkill})
	playerAchieve:dealAchieve(AchieveConditionType.maxWingSkill, {value = maxWingSkill})
	playerAchieve:dealAchieve(AchieveConditionType.upSkill1, {value = maxSkill})
	playerAchieve:dealAchieve(AchieveConditionType.upSkill2, {value = 1, customValues = {newSkillLevel}})

	if mainObjectSkillCount >= 2 then
		g_MainObjectMgr:notify(roleSID, MainObjectType.skill)
	end
end

-- 处理祝福装备
function AchieveManager:dealBlessEquip(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local result = select(1, ...)
	if result == nil then
		return
	end

	local luck = select(2, ...)
	if luck == nil then
		return
	end

	playerAchieve:dealAchieve(AchieveConditionType.blessEquip, {value = 1})
	if result == 1 then
		playerAchieve:dealAchieve(AchieveConditionType.blessEquipSuccess, {value = 1})
	end

	playerAchieve:dealAchieve(AchieveConditionType.blessEquipLuck, {value = luck})
end

-- 处理参加勇闯炼狱
function AchieveManager:dealJoinEnvoy(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	--[[
	local now = os.time()
	local joinTime = self._joinEnvoyTime[roleSID] or 0
	if diffDay(now, joinTime) == 0 then
		return
	end

	self._joinEnvoyTime[roleSID] = now
	]]

	playerAchieve:dealAchieve(AchieveConditionType.joinEnvoy, {value = 1})
end


-- 处理杀怪
function AchieveManager:dealKillMonster(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local monSID = select(1, ...)
	if monSID == nil then
		return
	end

	local monID = select(2, ...)
	if monID == nil then
		return
	end

	local mapID = select(3,	...)
	if mapID == nil then
		return
	end

	playerAchieve:dealAchieve(AchieveConditionType.killMonster, {value = 1, customSetValues = {monSID, mapID}})
end

-- 处理落霞夺宝
function AchieveManager:dealJoinLuoxia(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local now = os.time()
	local joinTime = self._joinLuoxiaTime[roleSID] or 0
	if diffDay(now, joinTime) == 0 then
		return
	end

	self._joinLuoxiaTime[roleSID] = now

	playerAchieve:dealAchieve(AchieveConditionType.joinLuoxia, {value = 1})
end

-- 处理获得坐骑
function AchieveManager:dealGetRide(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local rideID = select(1, ...)
	if rideID == nil then
		return
	end

	playerAchieve:dealAchieve(AchieveConditionType.getRide, {value = 1, customValues = {rideID}})
end

-- 处理玩家死亡
function AchieveManager:dealPlayerDead(roleSID, ...)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player == nil then
		return
	end

	local killerID = select(1, ...)
	if killerID == nil then
		return
	end

	local killer = g_entityMgr:getPlayer(killerID)
	if killer == nil then
		return
	end

	local killerAchieve = self:getAchievePlayer(killer:getSerialID())
	if killerAchieve == nil then
		return
	end

	local playerAchieve = self:getAchievePlayer(roleSID) 
	if playerAchieve then
		playerAchieve:dealAchieve(AchieveConditionType.beKillByPlayer, {value = 1})
	end

	if killer:getLevel() <= player:getLevel() then
		killerAchieve:dealAchieve(AchieveConditionType.killHigherPlayer, {value = 1})
	end

	if player:getPK() >= 4 then
		killerAchieve:dealAchieve(AchieveConditionType.killRedPlayer, {value = 1})
	end

	local factionID = g_manorWarMgr:getManorFacId(MANOR_MAINCITYWAR)
	if factionID ~= 0 and factionID == player:getFactionID() then
		local faction = g_factionMgr:getFaction(factionID)
		if faction and faction:getLeaderID() == player:getSerialID() then
			killerAchieve:dealAchieve(AchieveConditionType.killZhongzhouKing, {value = 1})
		end
	end

	local playerRelation = g_relationMgr:getRoleRelationInfoBySID(killer:getSerialID())
	if playerRelation then
		local enemy = playerRelation:getEnemy(player:getSerialID())
		if enemy then
			killerAchieve:dealAchieve(AchieveConditionType.killEnemy, {value = 1})
		end
	end

	local killerFactionID = killer:getFactionID()
	local playerFactionID = player:getFactionID()
	if killerFactionID ~= 0 and playerFactionID ~= 0 then
		local hostilityFaction = g_factionMgr:getHostilityFacList(killerFactionID)
		if table.contains(hostilityFaction, playerFactionID) then
			killerAchieve:dealAchieve(AchieveConditionType.killFactionEnemy, {value = 1})
		end
	end

	local scene = killer:getScene()
	if scene then
		killerAchieve:dealAchieve(AchieveConditionType.killPlayerInMap, {value = 1, customValues = {scene:getMapID()}})
	end

	local glamourData = g_RankMgr:getGlamour()
	if glamourData then
		if glamourData[1] == roleSID then
			killerAchieve:dealAchieve(AchieveConditionType.killCharming, {value = 1})
		end
	end
end

-- 处理pk值改变
function AchieveManager:dealPkChange(roleSID, ...)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player == nil then
		return
	end

	local playerAchieve = self:getAchievePlayer(roleSID) 
	if not playerAchieve then
		return
	end

	local pk = self._playerPKs[roleSID]
	if not pk then
		return
	end

	local newPk = select(1, ...)
	if newPk == nil then
		return
	end

	if pk < 2 and newPk >= 2 then
		playerAchieve:dealAchieve(AchieveConditionType.yellowName, {value = 1})
	end

	if pk < 4 and newPk >= 4 then
		playerAchieve:dealAchieve(AchieveConditionType.redName, {value = 1})
	end

	self._playerPKs[roleSID] = newPk
end

-- 处理玩家装备被爆
function AchieveManager:dealDropEquip(roleSID, ...)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player == nil then
		return
	end

	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local equipPos = select(1, ...)
	if equipPos == nil then
		return
	end

	local killerSID = select(2, ...)
	if killerSID == nil then
		return
	end

	local killer = g_entityMgr:getPlayerBySID(killerSID)
	if killer == nil then
		return
	end

	local killAchieve = self:getAchievePlayer(killerSID)
	if killAchieve == nil then
		return
	end

	killAchieve:dealAchieve(AchieveConditionType.dropItem, {value = 1})

	local itemMgr = player:getItemMgr()
	if itemMgr == nil then
		return
	end

	local item = itemMgr:findItem(equipPos, Item_BagIndex_EquipmentBar)
	if item == nil then
		return
	end

	local equipProto = g_entityMgr:getConfigMgr():getEquipProto(item:getProtoID())
	local itemProto = g_entityMgr:getConfigMgr():getItemProto(item:getProtoID())
	if equipProto and itemProto then
		killAchieve:dealAchieve(AchieveConditionType.dropEquip, {value = 1, customValues = {itemProto.defaultColor, equipProto.kind}, customSetValues = {equipProto.suitID}})
	end
end

-- 处理玩家包裹物品被爆
function AchieveManager:dealDropBagItem(roleSID, ...)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player == nil then
		return
	end

	local killerSID = select(1, ...)
	if killerSID == nil then
		return
	end

	local itemID = select(2, ...)
	if itemID == nil then
		return
	end 

	local killer = g_entityMgr:getPlayerBySID(roleSID)
	if killer == nil then
		return
	end

	local killAchieve = self:getAchievePlayer(killerSID)
	if killAchieve == nil then
		return
	end

	killAchieve:dealAchieve(AchieveConditionType.dropItem, {value = 1})

	local equipProto = g_entityMgr:getConfigMgr():getEquipProto(itemID)
	local itemProto = g_entityMgr:getConfigMgr():getItemProto(itemID)
	if equipProto and itemProto then
		killAchieve:dealAchieve(AchieveConditionType.dropEquip, {value = 1, customValues = {itemProto.defaultColor, equipProto.kind}, customSetValues = {equipProto.suitID}})
	end
end

-- 处理送花
function AchieveManager:dealGiveFlower(roleSID, ...)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player == nil then
		return
	end

	local targetSid = select(1, ...)
	if targetSid == nil then
		return
	end

	local gflowerNum = select(2, ...)
	if gflowerNum == nil then
		return
	end

	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	playerAchieve:dealAchieve(AchieveConditionType.giveFlower, {value = 1, customValues = {gflowerNum}})

	local targetPlayerAchieve = self:getAchievePlayer(targetSid)
	if targetPlayerAchieve == nil then
		return
	end

	targetPlayerAchieve:dealAchieve(AchieveConditionType.receiveFlower, {value = 1, customValues = {gflowerNum}})
end

-- 处理伤害行会boss
function AchieveManager:dealHurtFactionBoss(roleSID, ...)
	local playerAchieve = self:getAchievePlayer(roleSID)
	if playerAchieve == nil then
		return
	end

	local now = os.time()
	local hurtTime = self._hurtFatcionBossTime[roleSID] or 0
	if diffDay(now, hurtTime) == 0 then
		return
	end

	self._hurtFatcionBossTime[roleSID] = now
	playerAchieve:dealAchieve(AchieveConditionType.hurtFactionBoss, {value = 1})
end

-- 沙城结果
function AchieveManager:shaWarResultNotify(oldFactionID, factionID)
	local oldFaction = g_factionMgr:getFaction(oldFactionID)
	if oldFaction then
		local leader = g_entityMgr:getPlayerBySID(oldFaction:getLeaderID()) 
		if leader then
			local titleID = ShaCityTitle[leader:getSchool()]
			local leaderAchieve = self:getAchievePlayer(leader:getSerialID())
			if titleID and leaderAchieve then
				leaderAchieve:removeTitle(titleID)
			end
		end 
	end

	local faction = g_factionMgr:getFaction(factionID)
	if faction then
		local leader = g_entityMgr:getPlayerBySID(faction:getLeaderID()) 
		if leader then
			local titleID = ShaCityTitle[leader:getSchool()]
			local leaderAchieve = self:getAchievePlayer(leader:getSerialID())
			if titleID and leaderAchieve then
				leaderAchieve:addTitle(titleID)
			end
		end 
	end
end

-- 魅力榜通知
function AchieveManager:glamourRankNotify(oldRoleSID, newRoleSID)
	if oldRoleSID then
		local player = g_entityMgr:getPlayerBySID(oldRoleSID)
		if player then
			local achievePlayer = self:getAchievePlayer(player:getSerialID())
			local titleID = CharmingTitle[player:getSchool()]
			if achievePlayer and titleID then
				achievePlayer:removeTitle(titleID)
			end
		end
	end

	if newRoleSID then
		local player = g_entityMgr:getPlayerBySID(newRoleSID)
		if player then
			local achievePlayer = self:getAchievePlayer(player:getSerialID())
			local titleID = CharmingTitle[player:getSchool()]
			if achievePlayer and titleID then
				achievePlayer:addTitle(titleID)
			end
		end
	end
end

--获得头顶物品
function AchieveManager:onGotDropItem(player, itemID)
	if player then
		local playerAchieve = self:getAchievePlayer(player:getSerialID())
		if not playerAchieve then
			return
		end
		playerAchieve:dealAchieve(AchieveConditionType.getEnvoyItem, {value = 1, customSetValues = {player:getMapID()}})
	end
end

-- gm设置称号
function AchieveManager:GMaddTitle(roleSID, titleID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local playerAchieve = self:getAchievePlayer(roleSID)
	if not playerAchieve then
		return
	end

	if titleID ~= 0 then
		playerAchieve:addTitle(tonumber(titleID))
	else
		for _, titleConfig in pairs(self._titleConfig) do
			playerAchieve:addTitle(titleConfig.q_titleID)
		end
	end
end

-- 更新封号
function AchieveManager:updateSpecialTitle(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local school = player:getSchool()
	local specialTitleConfig = self._specialTitleConfig[school]
	if not specialTitleConfig then
		return
	end

	local titleID = 0
	for i = 1, #specialTitleConfig do
		local config = specialTitleConfig[i]
		if config then
			if player:getLevel() > config.q_lv or (player:getLevel() == config.q_lv and player:getXP()/player:getNextXP() >= config.q_exp * 0.01) then
				titleID = config.q_id
			else
				break
			end
		end
	end

	if titleID ~= 0 and titleID ~= player:getSpecialTitleID() then
		player:setSpecialTitleID(titleID)
	end
end

function AchieveManager.getInstance()
	return AchieveManager()
end

g_achieveMgr = AchieveManager.getInstance()
g_achieveMgr:parseAchieveData()
g_achieveMgr:parseTitleData()
g_achieveMgr:parseAchieveLevelData()
g_achieveMgr:parseSpecialTitleData()

local QUIHeroModel = class("QUIHeroModel")
local QStaticDatabase = import("..controllers.QStaticDatabase")

QUIHeroModel.EQUIPMENT_STATE_NONE = "EQUIPMENT_STATE_NONE" --无状态
QUIHeroModel.EQUIPMENT_STATE_BREAK = "EQUIPMENT_STATE_BREAK" --可突破
QUIHeroModel.EQUIPMENT_STATE_DROP = "EQUIPMENT_STATE_DROP" --可挑战
QUIHeroModel.EQUIPMENT_STATE_CHALLENGE = "EQUIPMENT_STATE_CHALLENGE" --可收集
QUIHeroModel.EQUIPMENT_STATE_COMPOSE = "EQUIPMENT_STATE_COMPOSE" --可合成

QUIHeroModel.SPEICAL_UPDATE = "SPEICAL_UPDATE" --更新特殊装备

QUIHeroModel.SKILL_STATE_UP = "SKILL_STATE_UP" --可升级
QUIHeroModel.SKILL_STATE_TOP = "SKILL_STATE_TOP" --到顶级
QUIHeroModel.SKILL_STATE_NO_LEVEL = "SKILL_STATE_NO_LEVEL" --等级不足
QUIHeroModel.SKILL_STATE_NO_MONEY = "SKILL_STATE_NO_MONEY" --可合成

QUIHeroModel.EQUIPMENT_MASTER = "enhance_master_" --装备强化大师
QUIHeroModel.JEWELRY_MASTER = "jewelry_master_"   --饰品强化大师
QUIHeroModel.EQUIPMENT_ENCHANT_MASTER = "zhuangbeifumo_master_" --装备觉醒大师
QUIHeroModel.JEWELRY_ENCHANT_MASTER = "shipingfumo_master_"   --饰品觉醒大师
QUIHeroModel.JEWELRY_BREAK_MASTER = "shipingtupo_master_" --饰品突破大师
QUIHeroModel.HERO_TRAIN_MASTER = "herotrain_master_" --培养大师
QUIHeroModel.GEMSTONE_MASTER = "baoshiqianghua_master_" --宝石强化大师
QUIHeroModel.GEMSTONE_BREAK_MASTER = "baoshitupo_master_" --宝石突破大师
QUIHeroModel.SPAR_STRENGTHEN_MASTER = "jingshiqianghua_master_" --宝石强化大师
QUIHeroModel.MAGICHERB_UPLEVEL_MASTER = "xianpinshengji_master_" --仙品升级大师


--[[
/**
 * 魂师信息
 */
message HeroInfo {
    required int32 actorId = 1;                                                 // 魂师ID
    optional int32 level = 2;                                                   // 魂师等级
    optional int32 exp = 3;                                                     // 魂师经验
    optional int32 breakthrough = 4;                                            // 魂师突破
    optional int32 grade = 5;                                                   // 魂师进阶
    optional int32 force = 6;                                                   // 魂师战斗力
    repeated HeroSkillSlot slots = 7;                                           // 魂师的技能
    repeated Equipment  equipments = 8;                                         // 装备
    optional int32 hp = 9 [default = -1];                                       // 魂师血量
    optional int32 skillCD = 10;                                                // 魂师技能CD
    repeated Combination combinations = 11;                                     // 羁绊
    optional HeroTrainAttr trainAttr = 12;                                      // 魂师培养加成的数据
    repeated HeroTrainAttr trainAttrPres = 13;                                  // 魂师培养属性预览数值
    optional int32 mp = 14;                                                     // 怒气值
    repeated int32 equipMasterLevel = 15;                                  		// 魂师装备大师等级
    optional int32 jewelryMasterLevel = 16;                                     // 魂师饰品大师等级
    repeated int32 equipEnchantMasterLevel = 17;                                // 魂师装备觉醒大师等级
    optional int32 jewelryEnchantMasterLevel = 18;                              // 魂师饰品觉醒大师等级
    optional int32 jewelryBreakMasterLevel = 19;                                // 魂师饰品突破大师等级
}
/**
 * 装备
 */
message Equipment {
    optional int32 itemId = 1;                                                  // 物品ID
    optional int32 level = 2;                                                   // 装备强化的等级
    optional int32 enchants = 3;                                                // 装备觉醒
    optional int32 enchant_exp = 4;                                             // 装备经验（饰品的强化）
}
]]
function QUIHeroModel:ctor(options)
	self._heroInfo = options.heroInfo
	self._isCanBreak = false
	self._characterInfo = db:getCharacterByID(self._heroInfo.actorId)
	self._breakConfig = db:getBreakthroughByTalent(self._characterInfo.talent) --突破配置表
    self._breakHeroConfig = db:getBreakthroughHeroByActorId(self._heroInfo.actorId) --突破数值表

	self:initHero()
end

--更新魂师信息
function QUIHeroModel:updateInfo(heroInfo)
	if self._heroInfo.actorId == heroInfo.actorId and self._heroInfo ~= heroInfo then
		self._heroInfo = heroInfo
		self:initHero()
	end
end

--获取信息
function QUIHeroModel:getHeroInfo()
	return self._heroInfo
end

--初始化魂师数据
function QUIHeroModel:initHero()
	self:initEquipment()
	self:initGemstone()
	self:initMount()
	self:initSkill()
	self:initTrain()
	self:initArtifact()
	self:initSpar()
	self:initMagicHerb()
	self:initSoulSpirit()
end

--初始化装备
function QUIHeroModel:initEquipment()
	self._equipmentBreak = {}
	self._equipments = {}
	for _,equipInfo in pairs(self._heroInfo.equipments) do
		local equipmentName,breakInfo = self:getEquipmentPosition(equipInfo.itemId)
		if breakInfo == nil then
			assert(false, "hero <"..self._heroInfo.actorId.."> can't find equipment id <"..equipInfo.itemId.."> in breakthrough config")
		end
		local nextBreakInfo = self:_getEquipmentBreakInfoByLevel(breakInfo.breakthrough_level+1)
		self._equipments[equipInfo.itemId] = {name = equipmentName, breakInfo = breakInfo}
		self._equipmentBreak[equipmentName] = {}
		self._equipmentBreak[equipmentName].info = equipInfo
		self._equipmentBreak[equipmentName].breakLevel = breakInfo.breakthrough_level
		self._equipmentBreak[equipmentName].pos = equipmentName
		self._equipmentBreak[equipmentName].nextBreakInfo = nextBreakInfo
		self._equipmentBreak[equipmentName].state = QUIHeroModel.EQUIPMENT_STATE_NONE
	end
	self:heroBreakHandler()
	self:heroMasterLevel()
end

--根据装备ID获取该装备在魂师身上的位置和突破信息
function QUIHeroModel:getEquipmentPosition(itemId)
	for _,equipmentName in pairs(EQUIPMENT_TYPE) do
		for _,breakInfo in pairs(self._breakConfig) do
			if breakInfo[equipmentName] == itemId then
				return equipmentName, breakInfo
			end
		end
	end
	return nil
end

--根据等级获取突破装备信息
function QUIHeroModel:_getEquipmentBreakInfoByLevel(level)
	for _,breakInfo in pairs(self._breakConfig) do
		if breakInfo.breakthrough_level == level then
			return breakInfo
		end
	end
	return nil
end

--计算魂师突破数据
function QUIHeroModel:heroBreakHandler(updateType)
	if updateType ~= QUIHeroModel.SPEICAL_UPDATE then
		self._isCanBreak = true
		self._needBreakItem = nil
		self._needBreakNum = 0
	end
	local equipUpdateState = false
	for _,value in pairs(self._equipmentBreak) do
		if updateType == QUIHeroModel.SPEICAL_UPDATE and value.pos ~= EQUIPMENT_TYPE.JEWELRY1 and value.pos ~= EQUIPMENT_TYPE.JEWELRY2 then

		else
			local oldState = value.state
			self._heroInfo.breakthrough = self._heroInfo.breakthrough or 0
			value.state = QUIHeroModel.EQUIPMENT_STATE_NONE
			--如果突破装备有未突破的则该魂师不能突破
			if value.pos ~= EQUIPMENT_TYPE.JEWELRY1 and value.pos ~= EQUIPMENT_TYPE.JEWELRY2 then
				if value.breakLevel <= self._heroInfo.breakthrough then
					self._needBreakNum = self._needBreakNum + 1
					if self._isCanBreak == true then
						self._isCanBreak = false
						if self._needBreakItem == nil then self._needBreakItem = value.info.itemId end
					end
				end
			end
			if value.nextBreakInfo ~= nil then --如果下一级装备不为空 
				local nextItemId = value.nextBreakInfo[value.pos]
				local nextItemConfig = db:getItemCraftByItemId(nextItemId)
				if self._heroInfo.breakthrough >= (nextItemConfig.hero_break or 0) and (value.info.level or 0) >= (nextItemConfig.strengthen_levels or 0) then
					local isHave,isComposite = remote.items:getItemIsHaveNumByID(nextItemId, 1, true)
					if isHave == true and self._heroInfo.breakthrough >= (nextItemConfig.hero_break or 0) then --如果有下级装备
						value.state = QUIHeroModel.EQUIPMENT_STATE_BREAK
					else --如果可以掉落且通关则可以掉落
						local isDrop,isPass = remote.items:getComposeItemIsCanDrop(nextItemId)
						if isDrop == true then
							if isPass == true then
								value.state = QUIHeroModel.EQUIPMENT_STATE_DROP
							else
								value.state = QUIHeroModel.EQUIPMENT_STATE_CHALLENGE
							end
						end
					end
				end
			end
			if oldState ~= value.state then
				equipUpdateState = true
			end
		end
	end
	return equipUpdateState
end

function QUIHeroModel:heroMasterLevel()
	self._equipMastreLevel = 0
	self._jewelryMastreLevel = 0
	self._equipEnchantMastreLevel = 0
	self._jewelryEnchantMastreLevel = 0
	self._jewelryBreakMastreLevel = 0

	local equipMinLevel = 1000000
	local jewelryMinLevel = 1000000
	local equipEnchantMinLevel = 1000000
	local jewelryEnchantMinLevel = 1000000
	local jewelryBreakMinLevel = 1000000
	for _, equipName in pairs(EQUIPMENT_TYPE) do
		if self._equipmentBreak[equipName] ~= nil then
			local level = self._equipmentBreak[equipName].info.level or 0
			local enchantLevel = self._equipmentBreak[equipName].info.enchants or 0
			local breakLevel = self._equipmentBreak[equipName].breakLevel or 0

			if (equipName == EQUIPMENT_TYPE.JEWELRY1 or equipName == EQUIPMENT_TYPE.JEWELRY2) and #self._heroInfo.equipments == 6 then
				jewelryMinLevel = jewelryMinLevel > level and level or jewelryMinLevel
				jewelryEnchantMinLevel = jewelryEnchantMinLevel > enchantLevel and enchantLevel or jewelryEnchantMinLevel
				jewelryBreakMinLevel = jewelryBreakMinLevel > breakLevel and breakLevel or jewelryBreakMinLevel
			elseif equipName ~= EQUIPMENT_TYPE.JEWELRY1 and equipName ~= EQUIPMENT_TYPE.JEWELRY2 then
				equipMinLevel = equipMinLevel > level and level or equipMinLevel
				equipEnchantMinLevel = equipEnchantMinLevel > enchantLevel and enchantLevel or equipEnchantMinLevel
			end
		end
	end

	equipMinLevel = equipMinLevel == 1000000 and 0 or equipMinLevel
	jewelryMinLevel = jewelryMinLevel == 1000000 and 0 or jewelryMinLevel
	equipEnchantMinLevel = equipEnchantMinLevel == 1000000 and 0 or equipEnchantMinLevel
	jewelryEnchantMinLevel = jewelryEnchantMinLevel == 1000000 and 0 or jewelryEnchantMinLevel
	jewelryBreakMinLevel = jewelryBreakMinLevel == 1000000 and 0 or jewelryBreakMinLevel

	self._equipMastreLevel = db:getStrengthenMasterByLevel("enhance_master_", equipMinLevel)
	self._jewelryMastreLevel = db:getStrengthenMasterByLevel("jewelry_master_", jewelryMinLevel)
	self._jewelryBreakMastreLevel = db:getStrengthenMasterByLevel("shipingtupo_master_", jewelryBreakMinLevel)
	if self._characterInfo.aptitude == APTITUDE.SS then
		self._equipEnchantMastreLevel = db:getStrengthenMasterByLevel("zhuangbeifumo_ss_master_", equipEnchantMinLevel)
		self._jewelryEnchantMastreLevel = db:getStrengthenMasterByLevel("shipingfumo_ss_master_", jewelryEnchantMinLevel)
	elseif self._characterInfo.aptitude == APTITUDE.SSR then
		self._equipEnchantMastreLevel = db:getStrengthenMasterByLevel("zhuangbeifumo_ssr_master_", equipEnchantMinLevel)
		self._jewelryEnchantMastreLevel = db:getStrengthenMasterByLevel("shipingfumo_ssr_master_", jewelryEnchantMinLevel)
	else
		self._equipEnchantMastreLevel = db:getStrengthenMasterByLevel("zhuangbeifumo_master_", equipEnchantMinLevel)
		self._jewelryEnchantMastreLevel = db:getStrengthenMasterByLevel("shipingfumo_master_", jewelryEnchantMinLevel)
	end

	self._heroInfo.equipMasterLevel = self._equipMastreLevel
	self._heroInfo.jewelryMasterLevel = self._jewelryMastreLevel
	self._heroInfo.equipEnchantMasterLevel = self._equipEnchantMastreLevel
	self._heroInfo.jewelryEnchantMasterLevel = self._jewelryEnchantMastreLevel
	self._heroInfo.jewelryBreakMasterLevel = self._jewelryBreakMastreLevel

	-- printTable(self._heroInfo)

end

function QUIHeroModel:getHeroEquipMasterLevel()
	return self._equipMastreLevel
end

function QUIHeroModel:getHeroJewelryMasterLevel()
	return self._jewelryMastreLevel
end

--解锁徽章时添加装备
function QUIHeroModel:unlockBadge()
	local equipment = {}
	local nextBreakInfo = self:_getEquipmentBreakInfoByLevel(0)
	equipment.level = 1
	equipment.enhance_exp = 0
	equipment.itemId = nextBreakInfo[EQUIPMENT_TYPE.JEWELRY1]
	table.insert(self._heroInfo.equipments, equipment)
	self:initEquipment()
end

--解锁徽章时添加装备
function QUIHeroModel:unlockGad()
	local equipment = {}
	local nextBreakInfo = self:_getEquipmentBreakInfoByLevel(0)
	equipment.level = 1
	equipment.enhance_exp = 0
	equipment.itemId = nextBreakInfo[EQUIPMENT_TYPE.JEWELRY2]
	table.insert(self._heroInfo.equipments, equipment)
	self:initEquipment()
end

--获取魂师是否可以突破
function QUIHeroModel:getCanBreak()
	return self._isCanBreak,self._needBreakItem,self._needBreakNum
end

--根据位置获取装备信息
function QUIHeroModel:getEquipmentInfoByPos(pos)
	return self._equipmentBreak[pos]
end

--根据id获取装备信息
function QUIHeroModel:getEquipmentInfoByItemId(itemId)
	local pos = self:getEquipmentPosition(itemId)
	return self:getEquipmentInfoByPos(pos)
end

--检查某个魂师是否有装备能突破 此处检查魂师等级
function QUIHeroModel:checkHerosEvolutionById()
	for pos,value in pairs(self._equipmentBreak) do
		if value.nextBreakInfo ~= nil then
			local itemConfig = db:getItemByID(value.nextBreakInfo[value.pos])
			local itemCraftConfig = db:getItemCraftByItemId(value.nextBreakInfo[value.pos])
			if value.state == QUIHeroModel.EQUIPMENT_STATE_BREAK and (itemConfig.level or 0) <= self._heroInfo.level and 
				itemCraftConfig.price <= remote.user.money then
				return value.info.itemId
			end
		end
	end
end

--[[
	检查某个魂师是否有装备可以突破
	只检查等级不检查材料是否满足
]]
function QUIHeroModel:getHerosEvolutionIdCheckWithLevel()
	for pos,value in pairs(self._equipmentBreak) do
		if value.nextBreakInfo ~= nil then
			local itemConfig = db:getItemByID(value.nextBreakInfo[value.pos])
			if (itemConfig.level or 0) <= self._heroInfo.level then
				return value.info.itemId
			end
		end
	end
end

---------------魂师经验------------------------

--魂师是否能升级
function QUIHeroModel:heroCanUpgrade()
	if self._heroInfo.level < remote.user.heroMaxLevel then
		return true
	else
		return false
	end
end

--检查吃的经验药水是否超标
function QUIHeroModel:checkEatItem(exp, count)
	local levelExp = 0
	local level = remote.user.heroMaxLevel
	while true do
		level = level - 1
		levelExp = levelExp + db:getExperienceByLevel(level)
		if level <= self._heroInfo.level then
			break
		end
	end
	local needCount = math.ceil((levelExp - self._heroInfo.exp)/exp)
	if needCount < count and needCount > 0 then
		return needCount
	end
	return count
end

--魂师吃经验
function QUIHeroModel:addExp(expNum)
	local addLevel = 0
	local addExp = 0
	if self:heroCanUpgrade() then --魂师未满级 或者满级经验未满时则可以升级
		local exp
		while true do
			exp = db:getExperienceByLevel(self._heroInfo.level)
			if exp <= (self._heroInfo.exp + expNum) then --需要升级
				if self._heroInfo.level < remote.user.heroMaxLevel then --未满级
					self._heroInfo.level  = self._heroInfo.level + 1
					addLevel = addLevel + 1
					addExp = addExp + (exp - self._heroInfo.exp)
					expNum = expNum - (exp - self._heroInfo.exp)
					self._heroInfo.exp = 0
				elseif self._heroInfo.level == remote.user.heroMaxLevel then --满级
					addExp = addExp + (exp - 1 - self._heroInfo.exp)
					self._heroInfo.exp = exp - 1
					break
				end
			else
				addExp = addExp + expNum
				self._heroInfo.exp = self._heroInfo.exp + expNum
				break
			end
		end
	else
		return false
	end 
	return true, addLevel, addExp
end

--xurui：检查魂师饰品是否可以升级
function QUIHeroModel:checkHerosJewelryById(expNum, equipPos)
	local addLevel = 0
	local addExp = 0
	local equipment = self._equipmentBreak[equipPos]
	if equipment ~= nil then
		while equipment.info.level <= remote.herosUtil:getJewelryStrengthenMaxLevel() do
			local expInfo = db:getJewelryStrengthenInfoByLevel(equipment.info.level + 1)
			if expInfo == nil then
				break
			end
			equipment.info.enhance_exp = equipment.info.enhance_exp and equipment.info.enhance_exp or 0
			if expInfo["enhance_exp1"] <= (equipment.info.enhance_exp + expNum) then --需要升级
					if equipment.info.level < remote.herosUtil:getJewelryStrengthenMaxLevel() then --未满级
						equipment.info.level  = equipment.info.level + 1
						addLevel = addLevel + 1
						addExp = addExp + (expInfo["enhance_exp1"] - equipment.info.enhance_exp)
						expNum = expNum - (expInfo["enhance_exp1"] - equipment.info.enhance_exp)
						equipment.info.enhance_exp = 0
					elseif equipment.info.level == remote.herosUtil:getJewelryStrengthenMaxLevel() then --满级
						addExp = addExp + (expInfo["enhance_exp1"] - equipment.info.enhance_exp)
						equipment.info.enhance_exp = expInfo["enhance_exp1"]
						break
					end
			else
				addExp = addExp + expNum
				equipment.info.enhance_exp = equipment.info.enhance_exp + expNum
				break
			end
		end
	else
		return false
	end
	if addLevel > 0 then
		self:heroMasterLevel()
	end
	return true, addLevel, addExp
end

---检测 戒指是否满足升级
function QUIHeroModel:checkHerosJewelryCanLevelUp( expNum, equipPos )
	-- body
	local equipment = self._equipmentBreak[equipPos]
	if equipment then
		local expInfo = db:getJewelryStrengthenInfoByLevel(equipment.info.level + 1)
		if expInfo == nil then 
			return 
		end
		local exp 
		if equipPos == EQUIPMENT_TYPE.JEWELRY1 then
			exp = expInfo.enhance_exp1
		else
			exp = expInfo.enhance_exp2
		end
		local curExp = equipment.info.enhance_exp and equipment.info.enhance_exp or 0
		local maxLevel = remote.herosUtil:getEquipmentStrengthenMaxLevel()

		if equipment.info.level < maxLevel then --未满级
			if curExp + expNum >= exp then
				return true, equipment.info.itemId
			end
		end
	end

end

function QUIHeroModel:getHeroLevel()
	return self._heroInfo.level or 1
end

----------------------魂师技能------------------------------

function QUIHeroModel:initSkill()
	-- if self._skills == nil then
	self._skills = {}
	self._skillToSlot = {}
    if self._breakHeroConfig ~= nil then
        for _,value in pairs(self._breakHeroConfig) do
        	local slotId = value.skill_id_3
            if slotId ~= nil then
            	self._skills[slotId] = {}
            	self._skills[slotId].slotId = slotId
            	self._skills[slotId].breakConfig = value
            	local skillId = db:getSkillByActorAndSlot(self._heroInfo.actorId, slotId)
            	self._skills[slotId].skillId = skillId
            	self._skillToSlot[skillId] = slotId
            end
        end
    end
	-- end
	for _,value in pairs(self._heroInfo.slots) do
		if self._skills[value.slotId] ~= nil and (self._skills[value.slotId].info == nil or self._skills[value.slotId].info.slotLevel ~= value.slotLevel) then
			self._skills[value.slotId].info = value
			local nextConfig = db:getSkillDataByIdAndLevel(self._skills[value.slotId].skillId, value.slotLevel+1)
			if nextConfig.level == value.slotLevel+1 then
				self._skills[value.slotId].nextConfig = nextConfig
			end
		end
	end
end

--[[
	根据skillId获取技能信息
	breakConfig --突破解锁技能的信息
	skillId --技能id
	slotId --技能槽位
	info --技能信息 未解锁则为空
	nextConfig --技能下一级信息 未解锁则为空
]]--
function QUIHeroModel:getSkillById(skillId)
	return self._skills[self._skillToSlot[skillId]]
end

function QUIHeroModel:getSkillBySlot(slotId)
	return self._skills[slotId]
end

--[[
	检查所有技能中是否能升级 
]]
function QUIHeroModel:checkAllSkillCanUpgrade()
	for _,slotId in pairs(self._skillToSlot) do
		local canUp = self:checkSkillCanUpgradeBySlotId(slotId)
		if canUp == true then
			return canUp, slotId, self._skills[slotId].nextConfig.item_cost
		end
	end
	return false
end

--[[
	检查技能是否能升级 
]]
function QUIHeroModel:checkSkillCanUpgradeBySlotId(slotId)
	local skillInfo = self._skills[slotId]
	local nextSkillConfig = skillInfo.nextConfig
	if nextSkillConfig == nil then
		return false, QUIHeroModel.SKILL_STATE_TOP
	elseif nextSkillConfig.hero_level > self._heroInfo.level then
		return false, QUIHeroModel.SKILL_STATE_NO_LEVEL
	elseif nextSkillConfig.item_cost > remote.user.money then
      	return false, QUIHeroModel.SKILL_STATE_NO_MONEY
	end
	return true, QUIHeroModel.SKILL_STATE_UP
end

--[[
	技能升级
]]
function QUIHeroModel:addSkillLevel(slotId)
	local skillInfo = self._skills[slotId]
	local nextSkillConfig = skillInfo.nextConfig
	if nextSkillConfig ~= nil then
		--造后台数据
		local data = {}
		data.money = remote.user.money - nextSkillConfig.item_cost
		data.heros = {}
		local heroInfo = clone(remote.herosUtil:getHeroByID(self._heroInfo.actorId))
		for _,slot in pairs(heroInfo.slots) do
			if slot.slotId == slotId then
				slot.slotLevel = slot.slotLevel + 1
			end
		end
		table.insert(data.heros, heroInfo)
		remote.herosUtil:setAdvancePoint(remote.herosUtil:getAdvancePoint()+1)
		--保存技能升级的cache
		if self._skillcache == nil then
			self._skillcache = {}
		end
		if self._skillcache[slotId] == nil then
			self._skillcache[slotId] = 1
		else
			self._skillcache[slotId] = self._skillcache[slotId] + 1
		end
		print("laytest 10002")
		remote:updateData(data)
	end
end

function QUIHeroModel:getSkillCache()
	return self._skillcache
end

function QUIHeroModel:resetSkillCache()
	self._skillcache = nil
end

-------------------培养--------------------------

function QUIHeroModel:initTrain()
	local trainId = self._characterInfo.train_id
	local trainConfig = QStaticDatabase:sharedDatabase():getTrainingAttribute(trainId, self._heroInfo.level)
	self._isCanTrain = false
	local attributes = self._heroInfo.trainAttr or {}
	if (attributes["hp"] or 0) < (trainConfig["hp_value"] or 0) then
		self._isCanTrain = true
		return
	end
	if (attributes["attack"] or 0) < (trainConfig["attack_value"] or 0) then
		self._isCanTrain = true
		return
	end
	if (attributes["armorPhysical"] or 0) < (trainConfig["armor_physical"] or 0) then
		self._isCanTrain = true
		return
	end
	if (attributes["armorMagic"] or 0) < (trainConfig["armor_magic"] or 0) then
		self._isCanTrain = true
		return
	end
end

function QUIHeroModel:getCanTrain()
	return self._isCanTrain == true
end

------------------------------------------宝石--------------------------------
function QUIHeroModel:initGemstone()
	self._gemstoneCanBreak = false
	self._gemstoneCanBetter = false
	self._gemstoneCanMix = false
	self._gemstoneCanRefine = false
	local gemstones = self._heroInfo.gemstones
	if gemstones == nil then
		gemstones = {}
	end
	self._gemstones = {}
	self._canGemstoneType = {true,true,true,true} --可装备的类型
	for i=1,4 do
		local gemstoneInfo = {}
		local config = app.unlock:getConfigByKey("UNLOCK_GEMSTONE_"..i)
		gemstoneInfo.state = remote.gemstone.GEMSTONE_NONE
		if config.hero_level > self._heroInfo.level or app.unlock:checkLock("UNLOCK_GEMSTONE") == false then
			gemstoneInfo.state = remote.gemstone.GEMSTONE_LOCK
		else
			for _,value in ipairs(gemstones) do
				if value.position == i then
					gemstoneInfo.info = value
					gemstoneInfo.state = remote.gemstone.GEMSTONE_WEAR
					local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(value.itemId)
					self._canGemstoneType[itemConfig.gemstone_type] = false
					break
				end
			end
		end
		table.insert(self._gemstones, gemstoneInfo)
	end
	self:gemstoneWearStateHandler()
	self:gemstoneMasterHandler()
	self:checkGemstoneAdvancedRedTips()
	self:checkGemstoneMixRedTips()
	self:checkGemstoneRefineRedTips()
end

--检查空宝石的格子是否可装备，并且附上可装备的类型
--检查有宝石的格子是否可以突破
function QUIHeroModel:gemstoneWearStateHandler()
	local canWearGemstones = remote.gemstone:getGemstonesByType(self._canGemstoneType)
	local isCan = #canWearGemstones > 0
	for _,gemstoneInfo in ipairs(self._gemstones) do
		gemstoneInfo.canType = self._canGemstoneType
		if gemstoneInfo.state == remote.gemstone.GEMSTONE_NONE and gemstoneInfo.info == nil then
			gemstoneInfo.state = remote.gemstone.GEMSTONE_CAN_WEAR
			gemstoneInfo.isCanWear = isCan
		elseif gemstoneInfo.state == remote.gemstone.GEMSTONE_WEAR then
			local itemConfig = db:getItemByID(gemstoneInfo.info.itemId)

			--是否有更好的宝石
			self._canGemstoneType[itemConfig.gemstone_type] = true
			local _canWearGemstones = remote.gemstone:getGemstonesByType(self._canGemstoneType, itemConfig.gemstone_quality)
			gemstoneInfo.isBetter = #_canWearGemstones > 0
			self._gemstoneCanBetter = self._gemstoneCanBetter or gemstoneInfo.isBetter
			self._canGemstoneType[itemConfig.gemstone_type] = false

		    -- 是否可以突破
			local items = {}
			local config = db:getGemstoneBreakThroughByLevel(gemstoneInfo.info.itemId, gemstoneInfo.info.craftLevel+1)
			if q.isEmpty(config) == false and config.money_type ~= nil then
				table.insert(items, {type = remote.items:getItemType(config.money_type), count = config.money_num})
			end
			if q.isEmpty(config) == false then
				local index = 1
				while true do
					local itemId = config["component_id_"..index]
					local itemCount = config["component_num_"..index]
					if itemId == nil then
						break
					end
					table.insert(items, {id = itemId, type = ITEM_TYPE.ITEM, count = itemCount})
					index = index + 1
				end
			end
			gemstoneInfo.isCanBreak = q.isEmpty(config) == false
			local mixLevel = gemstoneInfo.info.mix_level or 0
			--非ss魂骨 不能突破成金
			if (gemstoneInfo.info.godLevel or 1) < GEMSTONE_MAXADVANCED_LEVEL and mixLevel <= 0 and (gemstoneInfo.info.craftLevel or 0) >= S_GEMSTONE_MAXEVOLUTION_LEVEL then
				gemstoneInfo.isCanBreak = false
			end
			local nextMixConfig =  db:getGemstoneMixConfigByIdAndLv(gemstoneInfo.info.itemId, mixLevel + 1)
			if nextMixConfig == nil then
				gemstoneInfo.isCanMix = false
			end

			for _,item in ipairs(items) do
				if item.id == nil then
					if remote.user[item.type] < item.count then
						gemstoneInfo.isCanBreak = false
						break
					end
				else
					if remote.items:getItemsNumByID(item.id) < item.count or config.price > remote.user.money then
						gemstoneInfo.isCanBreak = false
						break
					end
				end
			end
			self._gemstoneCanBreak = self._gemstoneCanBreak or gemstoneInfo.isCanBreak
		end
	end
end

function QUIHeroModel:checkGemstoneAdvancedRedTips()
	self._gemstoneCanAdvanced = false
	for _, gemstoneInfo in ipairs(self._gemstones) do
		if gemstoneInfo.info then
			local advancedLevel = gemstoneInfo.info.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
			local nextLevelInfo = db:getGemstoneEvolutionBygodLevel(gemstoneInfo.info.itemId, advancedLevel + 1)
			if not q.isEmpty(nextLevelInfo) then
				self._gemstoneCanAdvanced = true
				if nextLevelInfo.evolution_consume_type_1 then
					local costNum1 = tonumber(nextLevelInfo.evolution_consume_1)
					local costItemid1 = nextLevelInfo.evolution_consume_type_1
					local haveNum1 = remote.items:getItemsNumByID(costItemid1)
					if haveNum1 < (costNum1 or 0) then
						self._gemstoneCanAdvanced = false
					end
				end

				if nextLevelInfo.evolution_consume_type_2 then
					local costNum2 = tonumber(nextLevelInfo.evolution_consume_2)
					local costItemid2 = nextLevelInfo.evolution_consume_type_2
					local haveNum2 = remote.items:getItemsNumByID(costItemid2)
					if haveNum2 < (costNum2 or 0) then
						self._gemstoneCanAdvanced = false
					end
				end
			end
		end
	end

	return self._gemstoneCanAdvanced
end

function QUIHeroModel:checkGemstoneMixRedTips()
	self._gemstoneCanMix = false
	local mixItemid = db:getConfigurationValue("GEMSTONE_MIX_ITEM") or 601007
	local haveNum = remote.items:getItemsNumByID(mixItemid)

	for _, gemstoneInfo in ipairs(self._gemstones) do
		if gemstoneInfo.info then
			gemstoneInfo.isCanMix = false
			local mixLevel = gemstoneInfo.info.mix_level or 0
			local nextMixConfig =  db:getGemstoneMixConfigByIdAndLv(gemstoneInfo.info.itemId, mixLevel + 1)
			if nextMixConfig then
				if tonumber(nextMixConfig.cost_num) <= haveNum and tonumber(nextMixConfig.cost_money) <= remote.user.money then
					gemstoneInfo.isCanMix = true
					if not self._gemstoneCanMix then
						self._gemstoneCanMix = true
					end
				end
			end
		end
	end
	return self._gemstoneCanMix
end

function QUIHeroModel:checkGemstoneRefineRedTips()
	self._gemstoneCanRefine = false
	local refineLock = app.unlock:checkLock("UNLOCK_GEMSTONE_REFINE",false)
	if not refineLock then
		return
	end

	-- 按类型选择所有拥有的碎片
	local piecesInfoList = {}
	for i=1,4 do
		local pieces = remote.gemstone:getStonePieceByTypeAndQuality(i)
		local totalExp = 0
		for _, info in ipairs(pieces) do
			info.selectedCount = info.count
		end
		table.insert(piecesInfoList, pieces)
	end

	for _, gemstoneInfo in ipairs(self._gemstones) do
		if gemstoneInfo.info and gemstoneInfo.info.mix_level and gemstoneInfo.info.mix_level > 0 then
			local refineLevel = gemstoneInfo.info.refine_level or 0
			local nextRefineInfo = remote.gemstone:getRefineConfigByIdAndLevel(gemstoneInfo.info.itemId, refineLevel + 1)

			-- 金币满足
			if tonumber(nextRefineInfo.cost_money) <= remote.user.money then
				local gemstoneType = db:getItemByID(gemstoneInfo.info.itemId).gemstone_type
				local levelInfo = remote.gemstone:getCurrentRefineInfoByItemList(gemstoneInfo.info.sid, piecesInfoList[gemstoneType])

				-- 升级满足
				if gemstoneInfo.info.mix_level >= nextRefineInfo.mix_limit and levelInfo.level > refineLevel then
					gemstoneInfo.isCanRefine = true
					if not self._gemstoneCanRefine then
						self._gemstoneCanRefine = true
					end
				end
			end
		end
	end

	return self._gemstoneCanRefine
end

function QUIHeroModel:getGemstoneCanBetter( ... )
	return self._gemstoneCanBetter
end

function QUIHeroModel:getGemstoneCanBreak( ... )
	return self._gemstoneCanBreak
end

function QUIHeroModel:getGemstoneCanAdvanced( ... )
	return self._gemstoneCanAdvanced
end

function QUIHeroModel:getGemstoneCanMix( ... )
	return self._gemstoneCanMix
end

function QUIHeroModel:getGemstoneCanRefine( ... )
	return self._gemstoneCanRefine
end

--宝石的大师处理
function QUIHeroModel:gemstoneMasterHandler()
	self._gemstoneMaster = 0
	self._gemstoneBreakMaster = 0
	if #self._gemstones == 4 then --没有4个宝石就不用看了
		local minStrengthLevel = nil
		local minBreakLevel = nil
		local notAllSS = false

		for _,gemstoneInfo in ipairs(self._gemstones) do
			if gemstoneInfo.info == nil then
				--如果宝石没装满也不用看了
				return
			end
			minBreakLevel = minBreakLevel or gemstoneInfo.info.craftLevel
			minBreakLevel = math.min(minBreakLevel, gemstoneInfo.info.craftLevel)
			minStrengthLevel = minStrengthLevel or gemstoneInfo.info.level
			minStrengthLevel = math.min(minStrengthLevel, gemstoneInfo.info.level)

			if (gemstoneInfo.info.godLevel or 1) < GEMSTONE_MAXADVANCED_LEVEL then
				notAllSS = true
			end
		end
		if minStrengthLevel ~= nil then
			self._gemstoneMaster = QStaticDatabase:sharedDatabase():getStrengthenMasterByLevel(QUIHeroModel.GEMSTONE_MASTER, minStrengthLevel)
		end
		if minBreakLevel ~= nil then
			self._gemstoneBreakMaster = QStaticDatabase:sharedDatabase():getStrengthenMasterByLevel(QUIHeroModel.GEMSTONE_BREAK_MASTER, minBreakLevel)
			if notAllSS then
				self._gemstoneBreakMaster =  math.min(self._gemstoneBreakMaster , S_GEMSTONE_MAXEVOLUTION_LEVEL)
			end
		end
	end
end

--根据位置检查宝石格子是否可装备
function QUIHeroModel:checkGemstoneCanWear(gemstonePos) 
	for i = 1, 4 do
		local gemstoneInfo = self:getGemstoneInfoByPos(i)
		if gemstoneInfo.state == remote.gemstone.GEMSTONE_CAN_WEAR and self._canGemstoneType[gemstonePos] then
			return true
		end
	end
	return false
end

--通过位置获取宝石信息
function QUIHeroModel:getGemstoneInfoByPos(pos)
	return self._gemstones[pos]
end

--是否可以是套装
function QUIHeroModel:checkCanSuit(itemId)
	local gemstones = self._heroInfo.gemstones or {}
	for _,gemstone in ipairs(gemstones) do
		if remote.gemstone:checkGemstoneIsSuit(gemstone.itemId, itemId) == true then
			return true
		end
	end
	return false
end

--检查宝石是否可以突破
function QUIHeroModel:checkHerosGemstoneRedTips()
	for _,gemstone in ipairs(self._gemstones) do
		if gemstone.isCanBreak == true or gemstone.isCanWear == true or gemstone.isBetter == true then
			return true
		end
	end
	return false
end

--------------------------------仙品-------------------------------

function QUIHeroModel:initMagicHerb()
	local magicHerbs = self._heroInfo.magicHerbs
	if magicHerbs == nil then
		magicHerbs = {}
	end
	self._magicHerbWearedInfo = {}	--已穿戴信息, key:pos, value:仙品后台数据
	self._magicHerbWearedBasis = {} --穿戴依据, key:pos, value:type、keyName
	self._magicHerbWearPosition = {1, 2, 3} --可穿戴位置
	self._magicStatus = {}  --仙品穿戴状态 key:pos, value:仙品状态

	for index, value in ipairs(magicHerbs) do
		local pos = value.position
		if pos == nil then
			pos = index
		end
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(value.itemId)
		local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(itemConfig.id)
		self._magicHerbWearedBasis[pos] = {type = magicHerbConfig.type, keyName = magicHerbConfig.name, aptitude = magicHerbConfig.aptitude, attribute = magicHerbConfig.attribute_type}
		self._magicHerbWearedInfo[pos] = value
	end

	local unlockStatus = remote.magicHerb:checkMagicHerbUnlock()
	for _, pos in ipairs(self._magicHerbWearPosition) do
		local data = self._magicHerbWearedBasis[pos]
		if unlockStatus == false then
			self._magicStatus[pos] = remote.magicHerb.STATE_LOCK
		elseif data == nil then
			self._magicStatus[pos] = remote.magicHerb.STATE_NO_WEAR
		elseif self:isBestMagicHerb(data.aptitude, data.attribute, data.type, pos) == false then
			self._magicStatus[pos] = remote.magicHerb.STATE_CAN_CHANGE
			-- print("STATE_CAN_CHANGE")
		else
			self._magicStatus[pos] = remote.magicHerb.STATE_IS_BEST
		end
	end

	self:updateMasterLevel()
end

-- 檢測是否最佳
function QUIHeroModel:isBestMagicHerb(aptitude, attribute, magicHerbType, pos)
	local maigcHerbItemList = remote.magicHerb:getMagicHerbItemList()
	for _, magicHerbItem in ipairs(maigcHerbItemList) do
		local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItem.itemId)
		local canWear = self:checkMagicHerbCanWear(pos, magicHerbConfig.attribute_type, magicHerbConfig.type)
		if canWear then
			if magicHerbConfig.aptitude > aptitude and (not magicHerbItem.actorId or magicHerbItem.actorId == 0) then
				return false
			end
		end
	end

	return true
end

--根据位置检查是否可装备。ps：仙品核心名字的判斷已經作廢
function QUIHeroModel:checkMagicHerbCanWear( posForWear, attribute, magicHerbType ) 
	for _, pos in ipairs(self._magicHerbWearPosition) do
		if pos ~= posForWear then
			local data = self._magicHerbWearedBasis[pos]
			-- 目标位置无论有没有信息，都可以无视，有则替换，无则装备。
			if data and (data.type ~= magicHerbType or data.attribute == attribute) then
				return false
			end
		end
	end
	-- print( "attribute_type = ", attribute, "type = ", magicHerbType ) 
	return true
end


function QUIHeroModel:checkMagicHerbCanWearByItemId( posForWear, itemId ) 

	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(itemId)

	for _, pos in ipairs(self._magicHerbWearPosition) do
		if pos ~= posForWear then
			local data = self._magicHerbWearedBasis[pos]
			-- 目标位置无论有没有信息，都可以无视，有则替换，无则装备。
			if data and (data.type ~= magicHerbConfig.magicHerbType or data.attribute == magicHerbConfig.attribute) then
				return false
			end
		end
	end
	-- print( "attribute_type = ", attribute, "type = ", magicHerbType ) 
	return true
end


--检查是否有空位可携带仙品
function QUIHeroModel:checkCanWearMagicHerb() 
	for _, pos in ipairs(self._magicHerbWearPosition) do
		if not self._magicHerbWearedBasis[pos] then
			return true
		end
	end
	return false
end

--检查英雄是否有装备仙品
function QUIHeroModel:isTakenMagicHerb() 
	return next(self._magicHerbWearedInfo) ~= nil
end

--检查英雄是否有装备S仙品
function QUIHeroModel:isTakenMagicHerbAptitudeS() 
	for _, pos in ipairs(self._magicHerbWearPosition) do
		local wearedInfo = self._magicHerbWearedInfo[pos]
		if wearedInfo then
			local maigcHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(wearedInfo.sid)
			local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(maigcHerbItemInfo.itemId)
			if maigcHerbItemInfo and magicHerbConfig and magicHerbConfig.aptitude == APTITUDE.S then
				return true
			end
		end
	end
	return false
end

--通过位置获取仙品信息
function QUIHeroModel:getMagicHerbWearedInfoByPos(pos)
	return self._magicHerbWearedInfo[pos]
end

--通过位置获取仙品装备信息
function QUIHeroModel:getMagicHerbWearedBasisByPos(pos)
	return self._magicHerbWearedBasis[pos]
end

--获取套装技能
function QUIHeroModel:getMagicHerbSuitSkill()
	local isSuit, suitType = self:isHasSuitMagicHerb()	
	if isSuit then
		local minAptitude = self:getMinAptitudeInSuit()
		local minBreed = self:getMinBreedInSuit()
		local magicHerbSuitConfig = remote.magicHerb:getMagicHerbSuitConfigByTypeAndAptitude(suitType, minAptitude,minBreed)
		if magicHerbSuitConfig then
			return magicHerbSuitConfig.skill, minAptitude , minBreed , magicHerbSuitConfig
		end
	end

	return nil, nil, nil
end

function QUIHeroModel:getMinAptitudeInSuit()
	local minAptitude = 9999 --保存成套三件里面的最低品质
	for _, pos in ipairs(self._magicHerbWearPosition) do
		local wearedInfo = self._magicHerbWearedInfo[pos]
		if wearedInfo then
			local maigcHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(wearedInfo.sid)
			local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(maigcHerbItemInfo.itemId)
			if maigcHerbItemInfo and magicHerbConfig and magicHerbConfig.aptitude < minAptitude then
				minAptitude = magicHerbConfig.aptitude
			end
		else
			minAptitude = 9999
			break
		end
	end

	return minAptitude
end

function QUIHeroModel:getMinBreedInSuit()
	local minBreedLv = 9999 --保存成套三件里面的最低品质
	for _, pos in ipairs(self._magicHerbWearPosition) do
		local wearedInfo = self._magicHerbWearedInfo[pos]
		if wearedInfo then
			local maigcHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(wearedInfo.sid)
			if maigcHerbItemInfo.breedLevel  and maigcHerbItemInfo.breedLevel < minBreedLv then
				minBreedLv = maigcHerbItemInfo.breedLevel 
			end
		else
			minBreedLv = 9999
			break
		end
	end

	return minBreedLv == 9999 and 0 or minBreedLv
end

function QUIHeroModel:getMinAptitudeInWeared()
	local minAptitude = nil --保存成套三件里面的最低品质
	for _, pos in ipairs(self._magicHerbWearPosition) do
		local wearedInfo = self._magicHerbWearedInfo[pos]
		if wearedInfo then
			local maigcHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(wearedInfo.sid)
			if maigcHerbItemInfo then
				local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(maigcHerbItemInfo.itemId)
				if magicHerbConfig and (not minAptitude or magicHerbConfig.aptitude < minAptitude) then
					minAptitude = magicHerbConfig.aptitude
				end
			end
		end
	end

	return minAptitude
end


--是否拥有套装
function QUIHeroModel:isHasSuitMagicHerb()
	local suitType = nil
	for _, pos in ipairs(self._magicHerbWearPosition) do
		local wearedInfo = self._magicHerbWearedInfo[pos]
		if wearedInfo then
			local wearedItemInfo = remote.magicHerb:getMaigcHerbItemBySid(wearedInfo.sid)
			local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(wearedItemInfo.itemId)
			if suitType ~= magicHerbConfig.type then
				if suitType == nil then
					suitType = magicHerbConfig.type
				else
					return false, suitType
				end
			end
		else
			return false, suitType
		end
	end
	return suitType ~= nil, suitType
end

function QUIHeroModel:checkHeroMagicHerbRedTips()
	for _, pos in ipairs(self._magicHerbWearPosition) do
		if self:checkHeroMagicHerbRedTipsByPos(pos) then
			-- print("pos = ", pos)
			return true
		end
	end
	return false
end

function QUIHeroModel:checkHeroMagicHerbRedTipsByPos(magicHerPos)
	local magicHerbList = remote.magicHerb:getMagicHerbItemList()
    local hasNoWear = false
    for i, magicHerb in pairs(magicHerbList) do
        if magicHerb and magicHerb.actorId == 0 then
			local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerb.itemId)
			local canWear = self:checkMagicHerbCanWear(pos, magicHerbConfig.attribute_type, magicHerbConfig.type)
        	if canWear then
	            hasNoWear = true
	            break
           	end
        end
    end
	if self._magicStatus[magicHerPos] == remote.magicHerb.STATE_NO_WEAR then
		-- print("pos = ", magicHerPos, hasNoWear, self._magicStatus[magicHerPos])
		return hasNoWear
	elseif self._magicStatus[magicHerPos] == remote.magicHerb.STATE_CAN_CHANGE then
		-- bug fixed dldl-22186
		-- 这里如果是可替换的情况，需要重新判断一下，因为仙品升星是前端记录，前端记录会在Model之后，所以可能不准。
		local data = self._magicHerbWearedBasis[magicHerPos]
		if data and self:isBestMagicHerb(data.aptitude, data.attribute, data.type, magicHerPos) == false then
			return hasNoWear
		end
	end

	return false
end

function QUIHeroModel:getMasterInfo(upLevel)
	if upLevel == nil then upLevel = 1 end

	local masterConfigs = db:getStaticByName("magic_herb_master")
	local minAptitude = self:getMinAptitudeInWeared() or 15
	local masterConfigList = masterConfigs[minAptitude]
	if not masterConfigList or masterConfigList[1].aptitude ~= minAptitude then
		masterConfigList = {}
		for _, masterConfig in pairs(masterConfigs) do
			for _, value in ipairs(masterConfig) do
				if value.aptitude == minAptitude then
					table.insert(masterConfigList, value)
				end
			end
		end
		table.sort(masterConfigList, function(a, b)
				return a.master_level < b.master_level
			end)
	end

	local preTbl = {}
	local curTbl = {}
	local nextTbl = {}

	for _, value in ipairs(masterConfigList) do
		local curLevel = self:getMasterLevelByType(self.MAGICHERB_UPLEVEL_MASTER)
		if value.master_level == curLevel then
			curTbl = value
		elseif value.master_level == curLevel + 1 then
			nextTbl = value
		elseif value.master_level == curLevel - upLevel then
			preTbl = value
		end
	end
	
	return curTbl, nextTbl, preTbl, next(nextTbl) == nil
end

--根据当前仙品强化大师等级获得强化大师当前等级和任意等级信息
function QUIHeroModel:getStrengthenMagicByMasterLevel(upLevel)

    local masterConfigs = db:getStaticByName("magic_herb_master")
    local minAptitude = self:getMinAptitudeInWeared() or 15
    local masterConfigList = masterConfigs[minAptitude]
    if not masterConfigList or masterConfigList[1].aptitude ~= minAptitude then
        masterConfigList = {}
        for _, masterConfig in pairs(masterConfigs) do
            for _, value in ipairs(masterConfig) do
                if value.aptitude == minAptitude then
                    table.insert(masterConfigList, value)
                end
            end
        end
        table.sort(masterConfigList, function(a, b)
                return a.master_level < b.master_level
            end)
    end

    local curTbl = {}
    local nextTbl = {}

    local curLevel = self:getMasterLevelByType(self.MAGICHERB_UPLEVEL_MASTER)
    if upLevel == nil then 
        upLevel = curLevel + 1
    else
        upLevel = curLevel + upLevel
    end
    for _, value in ipairs(masterConfigList) do
        if value.master_level == curLevel then
            curTbl = value
            if upLevel == curLevel then
            	nextTbl = value
            end
        elseif value.master_level == upLevel then
            nextTbl = value
        end
    end
    
    return curTbl, nextTbl, next(nextTbl) == nil
end

function QUIHeroModel:updateMasterLevel()
	self._magicHerbUpLevelMaster = 0
	-- _magicHerbWearedInfo雖然不是list，但是他的key也是123，所以可以用#。效果一樣
	if #self._magicHerbWearedInfo < #self._magicHerbWearPosition then 
		return
	end

	local minLevel
	for _, pos in ipairs(self._magicHerbWearPosition) do
		local info = self._magicHerbWearedInfo[pos]
		-- QPrintTable(info)
		if info then
			if not minLevel or info.level < minLevel then
				minLevel = info.level
			end
		else
			minLevel = nil
			break
		end
	end

	if not minLevel then
		return
	end

	local minAptitude = self:getMinAptitudeInWeared() or 15
	local masterConfig = remote.magicHerb:getMasterConfigByAptitudeAndMagicHerbLevel(minAptitude , minLevel)
	if masterConfig then
		self._magicHerbUpLevelMaster = masterConfig.master_level
	end

	-- local masterConfigs = QStaticDatabase.sharedDatabase():getStaticByName("magic_herb_master")
	-- local minAptitude = self:getMinAptitudeInWeared() or 15
	-- local masterConfigList = masterConfigs[minAptitude]
	-- if not masterConfigList or masterConfigList[1].aptitude ~= minAptitude then
	-- 	masterConfigList = {}
	-- 	for _, masterConfig in pairs(masterConfigs) do
	-- 		for _, value in ipairs(masterConfig) do
	-- 			if value.aptitude == minAptitude then
	-- 				table.insert(masterConfigList, value)
	-- 			end
	-- 		end
	-- 	end
	-- 	table.sort(masterConfigList, function(a, b)
	-- 			return a.master_level < b.master_level
	-- 		end)
	-- end

	-- for _, config in ipairs(masterConfigList) do
	-- 	if config.condition <= minLevel then
	-- 		self._magicHerbUpLevelMaster = config.master_level
	-- 	end
	-- end
end

--------------------------------暗器-------------------------------
function QUIHeroModel:initMount()
	-- body
	self._mountGradeTips = false
	self._mountDressGradeTips = false
	self._mountReformTips = false
	self._mountDressingTips = false
	self._mountGravegTips = false
	local mountInfo = self._heroInfo.zuoqi
	local lockConfig = app.unlock:getConfigByKey("UNLOCK_ZUOQI")
	if self._heroInfo.level < lockConfig.hero_level then
		self._mountState = remote.mount.STATE_LOCK
	else
		self._mountState = remote.mount.STATE_NO_WEAR
		if mountInfo == nil then
			self._mountState = remote.mount.STATE_CAN_WEAR
		else
			self._mountState = remote.mount.STATE_WEAR
			self._mountGradeTips = remote.mount:checkMountCanGrade(mountInfo)

			local character = db:getCharacterByID(mountInfo.zuoqiId)
			local config = db:getReformConfigByAptitudeAndLevel(character.aptitude, (mountInfo.reformLevel or 0) + 1)
			if config and config.consume_1 then
				local itemTbl = string.split(config.consume_1, "^")
				local soulCount = remote.items:getItemsNumByID(itemTbl[1])
				if soulCount >= tonumber(itemTbl[2]) then
					self._mountReformTips = true
				end
			end

			if character.aptitude >= APTITUDE.SS then
				if mountInfo.wearZuoqiInfo then
					self._mountDressGradeTips = remote.mount:checkMountCanGrade(mountInfo.wearZuoqiInfo)
				else
					self._mountDressingTips = remote.mount:checkNoEquipMountS()
				end
			end

			if character.aptitude == APTITUDE.SSR then
				self._mountGravegTips = remote.mount:checkCanGrave(mountInfo.zuoqiId)
			end
		end
	end
end

--获取暗器状态
function QUIHeroModel:getMountState()
	return self._mountState
end

--获取暗器升级
function QUIHeroModel:getMountGradeTip()
	return self._mountGradeTips
end

--获取暗器配件升级
function QUIHeroModel:getMountDressGradeTip()
	return self._mountDressGradeTips
end

--获取暗器升级
function QUIHeroModel:getMountReformTip()
	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MOUNT_REFORM) then
		return self._mountReformTips
	else
		return false
	end
end

--获取暗器可配件
function QUIHeroModel:getMountDressingTip()
	return self._mountDressingTips
end

--获取暗器可雕刻
function QUIHeroModel:getMountGraveTip( )
	return self._mountGravegTips
end

--检查宝石是否可以突破
function QUIHeroModel:checkHerosMountRedTips()
	local mountList = remote.mount:getMountByNoWearAndNoDress() or {}
	
	if (self._mountState == remote.mount.STATE_CAN_WEAR and #mountList > 0) or
		self._mountGradeTips or self:getMountReformTip() or self._mountDressGradeTips then
		return true
	end 
	return false
end

--------------------------------魂灵-------------------------------

function QUIHeroModel:initSoulSpirit()
	local soulSpiritInfo = self._heroInfo.soulSpirit
	
	if remote.soulSpirit:checkSoulSpiritUnlock() then
		self._soulSpiritState = remote.soulSpirit.STATE_NO_WEAR
		if soulSpiritInfo == nil then
			self._soulSpiritState = remote.soulSpirit.STATE_CAN_WEAR
		else
			self._soulSpiritState = remote.soulSpirit.STATE_WEAR
			if remote.soulSpirit:isGradeRedTipsById(soulSpiritInfo.id) then
				self._soulSpiritState = remote.soulSpirit.STATE_CAN_GRADE
			end
		end
	end
end

--获取魂灵状态
function QUIHeroModel:getSoulSpiritState()
	return self._soulSpiritState
end

function QUIHeroModel:checkSoulSpiritRedTips()
	if (self._soulSpiritState == remote.soulSpirit.STATE_CAN_WEAR and remote.soulSpirit:isFreeSoulSpirit()) or self._soulSpiritState == remote.soulSpirit.STATE_CAN_GRADE then
		return true
	end 
	return false
end

---------------------------------------武魂真身-----------------------------------
function QUIHeroModel:initArtifact()
	self._artifactState = remote.artifact.STATE_NO
	self._artifactUsePoint = 0
	self._artifactTotalPoint = 0
	self._artifactSkill = {}
	
	self._artifactId = remote.artifact:getArtiactByActorId(self._heroInfo.actorId)
	if self._artifactId == nil then
		return
	end

	local lockConfig = app.unlock:getConfigByKey("UNLOCK_ARTIFACT")
	local artifact = self._heroInfo.artifact
	if self._heroInfo.level < lockConfig.hero_level then
		self._artifactState = remote.artifact.STATE_LOCK
	else
		self._artifactState = remote.artifact.STATE_NO_WEAR
		if artifact == nil then
			local gradeConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, 1)
			if gradeConfig then
		        local soulCount = remote.items:getItemsNumByID(gradeConfig.soul_gem)
				if soulCount >= gradeConfig.soul_gem_count then
					self._artifactState = remote.artifact.STATE_CAN_WEAR
				end
			end
		else
			self._artifactState = remote.artifact.STATE_WEAR
			local breakLevel = artifact.artifactBreakthrough or 0
			local breakConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, breakLevel) or {}
			self._artifactTotalPoint = breakLevel or 0

			local gradeConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, breakLevel+1)
			if gradeConfig then
				local isSuperFull = true
				if gradeConfig[ITEM_TYPE.SUPER_STONE] then
					local superCount = remote.items:getItemsNumByID(tonumber(ITEM_TYPE.SUPER_STONE))
					if superCount < gradeConfig[ITEM_TYPE.SUPER_STONE] then
						isSuperFull = false
					end
				end
				local soulCount = remote.items:getItemsNumByID(gradeConfig.soul_gem)
		        if soulCount >= gradeConfig.soul_gem_count and isSuperFull and remote.user.money >= gradeConfig.money then
					self._artifactState = remote.artifact.STATE_CAN_BREAK
		        end
		    end
		end
	end
	self:initArtifactSkill()
end

--初始化技能 
function QUIHeroModel:initArtifactSkill()
	local haveSkills = {}
	if self._heroInfo.artifact ~= nil and self._heroInfo.artifact.artifactSkillList ~= nil then
		for _,skillInfo in ipairs(self._heroInfo.artifact.artifactSkillList) do
			haveSkills[skillInfo.skillId] = skillInfo
		end
	end
	if self._artifactId ~= nil then
		local skillConfig = remote.artifact:getSkillByArtifactId(self._artifactId)
		for slot, slotInfo in ipairs(skillConfig) do
			self._artifactSkill[slot] = {}
			local learnSkill = haveSkills[slotInfo.skill_id]
			if learnSkill ~= nil then
				self._artifactSkill[slot].learnSkill = learnSkill
				self._artifactUsePoint = self._artifactUsePoint + 1
			end
		end
		for slot, slotInfo in ipairs(skillConfig) do
			self._artifactSkill[slot].slotInfo = slotInfo
			if slotInfo.unlock_condition ~= nil then
				local isLight = true
				local conditions = string.split(tostring(slotInfo.unlock_condition), ";")
				for i, condition in pairs(conditions) do
					local skillInfo = self._artifactSkill[tonumber(condition)]
					if not skillInfo or not skillInfo.learnSkill then
						isLight = false
						break
					end
				end
				if isLight then
					self._artifactSkill[slot].isLock = false
				else
					self._artifactSkill[slot].isLock = true
				end
			else
				self._artifactSkill[slot].isLock = false
			end
		end
	end
end

--获取武魂真身技能状态
function QUIHeroModel:getArtifactSkill()
	return self._artifactSkill
end

--获取武魂真身技能状态
function QUIHeroModel:getArtifactSkillBySlot(slot)
	return self._artifactSkill[slot]
end

--获取武魂真身状态
function QUIHeroModel:getArtifactState()
	return self._artifactState
end

--获取已经使用的点数
function QUIHeroModel:getArtifactUsePoint()
	return self._artifactUsePoint
end

--获取已经获得的总点数
function QUIHeroModel:getArtifactTotalPoint()
	return self._artifactTotalPoint
end

--武魂真身红点
function QUIHeroModel:checkHerosArtifactRedTips()
	if self:getArtifactTotalPoint() > self:getArtifactUsePoint() then
		return true
	end	
	if self._artifactState == remote.artifact.STATE_CAN_WEAR then
		return remote.artifact.artifactWearShow
	end
	if self._artifactState == remote.artifact.STATE_CAN_BREAK then
		return remote.artifact.artifactGradeShow
	end

	return false
end

------------------------------------------------ 晶石 ----------------------------------------------------------

-- 1号位是榴石， 2号位是曜石
function QUIHeroModel:initSpar()
	-- body
	self._heroSparInfos = {}
	local sparInfo = {}
	if self._heroInfo.spar then
		for _, value in pairs(self._heroInfo.spar) do
			value.grade = value.grade or 0
			local itemInfo = db:getItemByID(value.itemId)
			if itemInfo.type == ITEM_CONFIG_TYPE.GARNET then
				sparInfo[1] = value
			else
				sparInfo[2] = value
			end
		end
	end

	for i = 1, 2 do
		if self._heroSparInfos[i] == nil then
			self._heroSparInfos[i] = {}
		end
		local unlockLevel = remote.spar:getUnlockHeroLevelByIndex(i)
		if (self._heroInfo.level < unlockLevel) then
			self._heroSparInfos[i].state = remote.spar.SPAR_LOCK
			self._heroSparInfos[i].isCanWear = false
			self._heroSparInfos[i].isCanGrade = false
			self._heroSparInfos[i].isBetter = false
			self._heroSparInfos[i].isCanAbsorb = false
		else
			if sparInfo[i] == nil then
				self._heroSparInfos[i].state = remote.spar.SPAR_CAN_WEAR
				self._heroSparInfos[i].isCanWear = self:checkCanWearSpar(i)
				self._heroSparInfos[i].isCanGrade = false
				self._heroSparInfos[i].isBetter = false
				self._heroSparInfos[i].isCanAbsorb = false
			else
				self._heroSparInfos[i].state = remote.spar.SPAR_WEAR
				self._heroSparInfos[i].isCanWear = false
				self._heroSparInfos[i].isCanGrade = self:sparCanUpGrade(sparInfo[i], i)
				self._heroSparInfos[i].isBetter = remote.spar:checkSparIsBetter(sparInfo[i].sparId, i)
				self._heroSparInfos[i].isCanAbsorb = self:sparCanAbsorbUp(sparInfo[i], i)
			end
		end
		self._heroSparInfos[i].info = sparInfo[i]
	end

	self:sparStrengthenMasterHandler()
end

function QUIHeroModel:sparCanUpGrade(sparInfo, index)
	local count = remote.spar:checkSparCanUpGrade(sparInfo.sparId, index)
	local gradeConfig = db:getGradeByHeroActorLevel(sparInfo.itemId, sparInfo.grade+1)
	if gradeConfig and count >= gradeConfig.soul_gem_count then
		return true
	end
	return false
end

function QUIHeroModel:sparCanAbsorbUp(sparInfo, index)

	local absorbLv = sparInfo.inheritLv  or 0
	local absorbConfig1 = db:getSparsAbsorbConfigBySparItemIdAndLv(sparInfo.itemId, absorbLv + 1 )
	if absorbConfig1 == nil then return false end 

	local sparItemList =  remote.spar:getSparItemIds(APTITUDE.S)
	local count = 0
	for i,v in ipairs(sparItemList) do
		local  spars , num = remote.spar:getCanAbsorbSparsByItemId(v)
		count = count + num
	end

	local befNum = remote.spar:getSparAbsorbTotalNumByItemIdAndLv(sparInfo.itemId, absorbLv )
	local totleNum = 0
	for k,v in pairs(sparInfo.consumeItems or {}) do
		totleNum = totleNum + v.count
	end

	local curExp = totleNum - befNum
	if (count + curExp ) >= (absorbConfig1.inherit_num or 1) then
		return true
	end
	print("sparCanAbsorbUp3")

	return false

end


function QUIHeroModel:checkCanWearSpar(index)
	local isCanWear = false
	local spars = remote.spar:getSparsByType(remote.spar:getSparItemTypeByIndex(index))
	if spars and next(spars) then
		for _, value in pairs(spars) do
			if value.actorId == nil or value.actorId == 0 then
				isCanWear = true
				break
			end
		end
	end

	return isCanWear
end

--获取晶石信息
function QUIHeroModel:getSparInfoByPos(index)
	return self._heroSparInfos[index]
end

function QUIHeroModel:sparStrengthenMasterHandler()
	self._sparStrengthenMaster = 0
	if #self._heroSparInfos == 2 then
		local minStrengthLevel = nil
		for _, sparInfo in ipairs(self._heroSparInfos) do
			if sparInfo.info == nil then
				return
			end
			minStrengthLevel = minStrengthLevel or sparInfo.info.level
			minStrengthLevel = math.min(minStrengthLevel, sparInfo.info.level)
		end
		if minStrengthLevel ~= nil then
			self._sparStrengthenMaster = db:getStrengthenMasterByLevel(QUIHeroModel.SPAR_STRENGTHEN_MASTER, minStrengthLevel)
		end
	end
end

function QUIHeroModel:updateSparStrengthLevel(expNum, index)
	local addLevel = 0
	local addExp = 0
	local sparInfo = self:getSparInfoByPos(index)
	if sparInfo == nil then return false end

	local sparType = "jewelry_exp1"
	if self._index == 2 then
		sparType = "jewelry_exp2"
	end

	local itemConfig = db:getItemByID(sparInfo.info.itemId)
	local maxLevel = math.min(remote.user.level*2, itemConfig.enhance_max)
	if sparInfo ~= nil then
		while sparInfo.info.level <= maxLevel do
			local expInfo = db:getJewelryStrengthenInfoByLevel(sparInfo.info.level + 1)
			if expInfo == nil then
				break
			end
			sparInfo.info.exp = sparInfo.info.exp and sparInfo.info.exp or 0
			if expInfo[sparType] <= (sparInfo.info.exp + expNum) then --需要升级
					if sparInfo.info.level < maxLevel then --未满级
						sparInfo.info.level  = sparInfo.info.level + 1
						addLevel = addLevel + 1
						addExp = addExp + (expInfo[sparType] - sparInfo.info.exp)
						expNum = expNum - (expInfo[sparType] - sparInfo.info.exp)
						sparInfo.info.exp = 0
					elseif sparInfo.info.level == maxLevel then --满级
						addExp = addExp + (expInfo[sparType] - sparInfo.info.exp)
						sparInfo.info.exp = expInfo[sparType]
						break
					end
			else
				addExp = addExp + expNum
				sparInfo.info.exp = sparInfo.info.exp + expNum
				break
			end
		end
	else
		return false
	end
	if addLevel > 0 then
		self:sparStrengthenMasterHandler()
	end
	return true, addLevel, addExp
end

function QUIHeroModel:getHeroSparMinGrade()
	local gradeLevel1 = self._heroSparInfos[1].info ~= nil and self._heroSparInfos[1].info.grade or 0
	local gradeLevel2 = self._heroSparInfos[2].info ~= nil and self._heroSparInfos[2].info.grade or 0
	local minGrade = math.min(gradeLevel1, gradeLevel2)

	return minGrade+1
end

function QUIHeroModel:checkHerosSparsRedTips()
	for _, value in pairs(self._heroSparInfos) do
		if value.isCanWear == true or value.isCanGrade or value.isBetter then
			return true
		end
	end
	return false
end

--根据位置检查晶石格子是否可装备
function QUIHeroModel:checkSparCanWear(index) 
	local sparInfo = self:getSparInfoByPos(index)
	if sparInfo.state == remote.spar.SPAR_CAN_WEAR and sparInfo.info == nil then
		return true
	end
	return false
end

---------------------------------------------------------------------------------------------------------------
function QUIHeroModel:getMasterLevelByType(masterType)
	if masterType == QUIHeroModel.EQUIPMENT_MASTER then
		return self._equipMastreLevel
	elseif masterType == QUIHeroModel.JEWELRY_MASTER then
		return self._jewelryMastreLevel
	elseif masterType == QUIHeroModel.EQUIPMENT_ENCHANT_MASTER then
		return self._equipEnchantMastreLevel
	elseif masterType == QUIHeroModel.JEWELRY_ENCHANT_MASTER then
		return self._jewelryEnchantMastreLevel
	elseif masterType == QUIHeroModel.JEWELRY_BREAK_MASTER then
		return self._jewelryBreakMastreLevel
	elseif masterType == QUIHeroModel.GEMSTONE_MASTER then
		return self._gemstoneMaster or 0
	elseif masterType == QUIHeroModel.GEMSTONE_BREAK_MASTER then
		return self._gemstoneBreakMaster or 0
	elseif masterType == QUIHeroModel.SPAR_STRENGTHEN_MASTER then
		return self._sparStrengthenMaster or 0
	elseif masterType == QUIHeroModel.MAGICHERB_UPLEVEL_MASTER then
		return self._magicHerbUpLevelMaster or 0
	end
	
	return 0
end

function QUIHeroModel:getSuperMasterTypeByType(masterType)
	local superMasterType = masterType 
	if self._characterInfo.aptitude == APTITUDE.SS then
		if masterType == "zhuangbeifumo_master_" then
			superMasterType = "zhuangbeifumo_ss_master_"
		elseif masterType == "shipingfumo_master_" then
			superMasterType = "shipingfumo_ss_master_"
		end
	elseif self._characterInfo.aptitude == APTITUDE.SSR then
		if masterType == "zhuangbeifumo_master_" then
			superMasterType = "zhuangbeifumo_ssr_master_"
		elseif masterType == "shipingfumo_master_" then
			superMasterType = "shipingfumo_ssr_master_"
		end
	end
	return superMasterType
end

--计算当前英雄到指定突破等级需要的物品数量
function QUIHeroModel:getHeroMaxBreakLevelNeedItems()
	local heroInfo = self:getHeroInfo()
	local items = {}
	local useItem = {}
	local level = heroInfo.breakthrough
	local needItems --突破所需的物品
	local canBreak --是否能突破（这里只判断最大等级）

	while true do
		level = level + 1
		needItems,useItem,canBreak = self:_countBreakLevelNeedItems(level, useItem)
		if canBreak == false or table.nums(needItems) > 0 then
			break
		end
		for k,v in pairs(useItem) do
			items[k] = v
		end
	end
	return items, needItems, canBreak, (level-heroInfo.breakthrough-1)
end

--计算当前英雄突破指定等级需要的物品
function QUIHeroModel:_countBreakLevelNeedItems(level, useItem)
	useItem = useItem or {}
	local heroInfo = self:getHeroInfo()
	local needItems = {}
	local equipment = {EQUIPMENT_TYPE.WEAPON,EQUIPMENT_TYPE.BRACELET,EQUIPMENT_TYPE.CLOTHES,EQUIPMENT_TYPE.SHOES}
	local isCanBreak = true
	local maxLevel = 0
	
	if heroInfo.breakthrough >= level then
		return needItems, useItem, false
	end
	local breakInfo = self:_getEquipmentBreakInfoByLevel(level)
	if breakInfo == nil then
		return needItems, useItem, false
	end

	--设置缺少的数量
	local setNeedItemCount = function (itemId, count)
		needItems[itemId] = (needItems[itemId] or 0) + count
	end

	--获取已经使用的数量
	local getItemUseCount = function (itemId)
		return useItem[itemId] or 0
	end

	--设置已经使用的数量
	local setItemUseCount = function (itemId, count)
		useItem[itemId] = (useItem[itemId] or 0) + count
	end

	--清除已经使用的物品
	local clearItemUseCount = function (itemId)
		useItem[itemId] = nil
	end

	--需要金币的处理
	local needMoneyFun = function (_needMoney)
		local _currentMoney = remote.user.money - getItemUseCount(ITEM_TYPE.MONEY)
		local _useMoney = math.min(_currentMoney, _needMoney)
		setItemUseCount(ITEM_TYPE.MONEY, _useMoney) --设置已经使用的数量
		_needMoney = _needMoney - _useMoney --计算还剩余需要的物品数量
		if _needMoney > 0 then
			setNeedItemCount(ITEM_TYPE.MONEY, _needMoney) --记录需要的物品数量
		end
	end

	--根据id，已经使用的物品，计算所需的物品和是否能突破
	local countItemFun 
	countItemFun = function (itemId, needCount)
		local itemCraftConfig = db:getItemCraftByItemId(itemId)
		local isCanBreak = true
		if itemCraftConfig == nil then
			setNeedItemCount(itemId, needCount) --记录需要的物品数量
			-- isCanBreak = false
		else
			local index = 1
			while true do
				local _itemId = itemCraftConfig["component_id_"..index]
				local _count = itemCraftConfig["component_num_"..index]
				if _itemId ~= nil then
					_count = _count * needCount
					--判断是否拥有该ID的物品
					local _currentCount = remote.items:getItemsNumByID(_itemId)
					if _currentCount > 0 then
						_currentCount = _currentCount - getItemUseCount(_itemId) --减去已经使用的物品数量
						local _useCount = math.min(_currentCount, _count) --计算当前需要使用的数量
						setItemUseCount(_itemId, _useCount) --设置已经使用的数量
						_count = _count - _useCount --计算还剩余需要的物品数量
					end
					if _count > 0 then --如果还需要物品数量，则寻找是否还可以合成
						isCanBreak = isCanBreak and countItemFun(_itemId, _count)
					end
				else
					break
				end
				index = index + 1
			end

			--计算所需的金币够不够
			needMoneyFun(itemCraftConfig.price or 0)
		end
		return isCanBreak
	end

	--计算突破装备所需
	for _,pos in ipairs(equipment) do
		local equipmentId = breakInfo[pos]
		if self._equipments[equipmentId] == nil then
			local itemConfig = db:getItemByID(equipmentId)
			maxLevel = math.max(maxLevel, itemConfig.level)
			isCanBreak = isCanBreak and countItemFun(equipmentId, 1)
		end
	end
	needMoneyFun(breakInfo.money or 0)

	--计算升级经验所需
	if maxLevel > remote.user.heroMaxLevel then
		isCanBreak = false
	elseif maxLevel > heroInfo.level then
		local needExp = 0
		for i=heroInfo.level,maxLevel-1 do
			needExp = needExp + db:getExperienceByLevel(i)
		end
		needExp = needExp - heroInfo.exp
		for _,_itemId in ipairs(remote.items.EXP_ITEMS) do
			clearItemUseCount(_itemId) --清除已经使用的数量
		end
		for _,_itemId in ipairs(remote.items.EXP_ITEMS) do
			local itemConfig = db:getItemByID(_itemId)
			local _needCount = math.ceil(needExp/itemConfig.exp)
			local _currentCount = remote.items:getItemsNumByID(_itemId)
			if _currentCount > 0 then
				_currentCount = _currentCount - getItemUseCount(_itemId) --减去已经使用的物品数量
				local _useCount = math.min(_needCount,_currentCount)
				setItemUseCount(_itemId, _useCount) --设置已经使用的数量
				needExp = needExp - _useCount * itemConfig.exp
			end
			if needExp <= 0 then
				break
			end
		end
		if needExp > 0 then
			local _itemId = remote.items.EXP_ITEMS[1]
			local _itemConfig = db:getItemByID(_itemId)
			local _needCount = math.ceil(needExp/_itemConfig.exp)
			setNeedItemCount(_itemId, _needCount) --记录需要的物品数量
		end
	end
	return needItems, useItem, isCanBreak
end

return QUIHeroModel
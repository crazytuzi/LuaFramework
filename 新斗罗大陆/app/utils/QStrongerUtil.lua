-- @Author: zhouxiaoshu
-- @Date:   2019-07-22 11:33:24
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-27 15:42:45

local QStrongerUtil = class("QStrongerUtil")
local QUIHeroModel = import("..models.QUIHeroModel")
local QQuickWay = import("..utils.QQuickWay")

QStrongerUtil.STAGE_SS = "STAGE_SS"
QStrongerUtil.STAGE_S = "STAGE_S"
QStrongerUtil.STAGE_AA = "STAGE_AA"
QStrongerUtil.STAGE_A = "STAGE_A"
QStrongerUtil.STAGE_B = "STAGE_B"

-- 显示的技能格子
local SKILL_SLOT = {
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[7] = true,
	[13] = true,
	[15] = true,
	[17] = true,
	[19] = true,
}
function QStrongerUtil:ctor()
end

function QStrongerUtil:didappear()
	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self,self._onUserPropHandler))

	self._levelRank = {}
	self._strongerData = db:getStaticByName("help_stronger")

	local levelRank = db:getConfiguration("help_stronger_rank").value
	local levelTbl = string.split(levelRank)
	for i, level in pairs(levelTbl) do
		self._levelRank[i] = tonumber(level)
	end
end

function QStrongerUtil:disappear()
end

function QStrongerUtil:loginEnd(success)
    self:resetData()

    if success then
    	success()
    end
end

function QStrongerUtil:_onUserPropHandler(event)
	self:resetData()
end

-- 重置数据
function QStrongerUtil:resetData()
	self._strongerList = {}			-- 变强列表		
	self._levelForce = {}			-- 等级战力
	self._sortId = 1				-- 排序规则

	-- 排序权重
	local teamLevel = remote.user.level or 1
	for i, level in pairs(self._levelRank) do
		if level <= teamLevel then
			self._sortId = i
		end
	end

	local levelStage = math.ceil(teamLevel/5)
	for i, value in pairs(self._strongerData) do
		local isUnlock = true
		if value.unlock then
			isUnlock = app.unlock:checkLock(value.unlock)
		end
		local stageTbl = string.split(value.standard or "", ";")
		value.standardValue = tonumber(stageTbl[levelStage]) or 0

		local rankTbl = string.split(value.rank or "", ";")
		value.weight = tonumber(rankTbl[self._sortId]) or 0

		if isUnlock and (not value.max_level or teamLevel <= value.max_level) then
			table.insert(self._strongerList, value)
		end

	end

	local teamConfig = db:getTeamConfigByTeamLevel(teamLevel)
	if teamConfig then
		local forceTbl = string.split(teamConfig.team_force or "100;90;80;70;60", ";")
		for i, force in pairs(forceTbl) do
			self._levelForce[i] = tonumber(force)
		end
	end
end

-- 计算当前值
function QStrongerUtil:checkStrongerStandard()
	-- 先创建id_name的表，并初始化为0
	local mapValue = {}
	for i, config in pairs(self._strongerData) do
        mapValue[config.id_name] = 0
    end

    -- 对应所有键复制
	mapValue["archaeology"] = self:getStandardArchaeology()
	mapValue["soul_trial"] = remote.user.soulTrial
	
	local heros, count = remote.herosUtil:getMaxForceHeros()
	for i, hero in pairs(heros) do
		if i > count then
			break
		end
		local heroInfo = remote.herosUtil:getHeroByID(hero.id)
		if heroInfo then
			mapValue["hero_grade"] = mapValue["hero_grade"] + heroInfo.grade + 1
			mapValue["hero_break"] = mapValue["hero_break"] + heroInfo.breakthrough + 1
			mapValue["hero_level"] = mapValue["hero_level"] + heroInfo.level
			mapValue["hero_train"] = mapValue["hero_train"] + self:getHeroTrainLevel(heroInfo)
			mapValue["gemstone_count"] = mapValue["gemstone_count"] + #(heroInfo.gemstones or {})

			for i, slot in pairs(heroInfo.slots or {}) do
				if SKILL_SLOT[slot.slotId] then
					mapValue["hero_skill"] = mapValue["hero_skill"] + slot.slotLevel
				end
			end
			for i, glyph in pairs(heroInfo.glyphs or {}) do
				mapValue["hero_glyph"] = mapValue["hero_glyph"] + glyph.level
			end
			if heroInfo.artifact then
				mapValue["artifact_grade"] = mapValue["artifact_grade"] + (heroInfo.artifact.artifactBreakthrough or 0)
				mapValue["artifact_level"] = mapValue["artifact_level"] + (heroInfo.artifact.artifactLevel or 0)
			end
			
			if #(heroInfo.spar or {}) == 2 then
				mapValue["spar_suit"] = mapValue["spar_suit"] + 1
			end
			for i, spar in pairs(heroInfo.spar or {}) do
				mapValue["spar_grade"] = mapValue["spar_grade"] + spar.grade + 1
			end

			if #(heroInfo.magicHerbs or {}) == 3 then
				mapValue["magic_herb_suit"] = mapValue["magic_herb_suit"] + 1
			end
			for i, magicHerb in pairs(heroInfo.magicHerbs or {}) do
				mapValue["magic_herb_grade"] = mapValue["magic_herb_grade"] + magicHerb.grade
			end
			for i, magicHerb in pairs(heroInfo.magicHerbs or {}) do
				mapValue["magic_herb_level"] = mapValue["magic_herb_level"] + magicHerb.level
			end
		end

		local heroModel = remote.herosUtil:getUIHeroByID(hero.id)
		if heroModel then
			mapValue["equip_enhance"] = mapValue["equip_enhance"] + heroModel:getMasterLevelByType(QUIHeroModel.EQUIPMENT_MASTER)
			mapValue["equip_enchant"] = mapValue["equip_enchant"] + heroModel:getMasterLevelByType(QUIHeroModel.EQUIPMENT_ENCHANT_MASTER)
			mapValue["jewelry_enhance"] = mapValue["jewelry_enhance"] + heroModel:getMasterLevelByType(QUIHeroModel.JEWELRY_MASTER)
			mapValue["jewelry_break"] = mapValue["jewelry_break"] + heroModel:getMasterLevelByType(QUIHeroModel.JEWELRY_BREAK_MASTER)
			mapValue["jewelry_enchant"] = mapValue["jewelry_enchant"] + heroModel:getMasterLevelByType(QUIHeroModel.JEWELRY_ENCHANT_MASTER)
			mapValue["gemstone_enhance"] = mapValue["gemstone_enhance"] + heroModel:getMasterLevelByType(QUIHeroModel.GEMSTONE_MASTER)
			mapValue["gemstone_break"] = mapValue["gemstone_break"] + heroModel:getMasterLevelByType(QUIHeroModel.GEMSTONE_BREAK_MASTER)
			mapValue["spar_enhance"] = mapValue["spar_enhance"] + heroModel:getMasterLevelByType(QUIHeroModel.SPAR_STRENGTHEN_MASTER)

			local equipInfo = heroModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1)
			if equipInfo and equipInfo.info then
				mapValue["jewelry1_enhance"] = mapValue["jewelry1_enhance"] + (equipInfo.info.level or 0)
				mapValue["jewelry1_break"] = mapValue["jewelry1_break"] + (equipInfo.breakLevel or 0) + 1
			end
		end
	end

	local mountList = remote.mount:getMountList()
	for _, mountInfo in pairs(mountList) do
		mapValue["mount_grade"] = mapValue["mount_grade"] + (mountInfo.grade or 0) + 1
		mapValue["mount_level"] = mapValue["mount_level"] + (mountInfo.enhanceLevel or 0)
	end

	local soulSpiritList = remote.soulSpirit:getMySoulSpiritInfoList()
	for _, soulSpiritInfo in pairs(soulSpiritList) do
		mapValue["spirit_grade"] = mapValue["spirit_grade"] + (soulSpiritInfo.grade or 0) + 1
		mapValue["spirit_level"] = mapValue["spirit_level"] + (soulSpiritInfo.level or 0)
	end

    -- 记录
    local showIdStr = app:getUserOperateRecord():getRecordByType("STRONGER_SHOW_ID") or ""
    local showIdsTbl = string.split(showIdStr, ";")
    local checkNew = function(id)
		local id = tostring(id)
		for i, showId in pairs(showIdsTbl) do
			if id == showId then
				return false
			end
		end
		return true
	end

	-- 是否有新的
    -- 把值对应赋给curValue
	local hasNew = false
	for i, stronger in pairs(self._strongerList) do
		local standard = mapValue[stronger.id_name] or 0
		stronger.curValue = standard
		stronger.isNew = checkNew(stronger.id)
		if stronger.isNew then
			hasNew = true
		end
	end
	
	return hasNew
end

function QStrongerUtil:getStrongerHelpList()
	self:checkStrongerStandard()
	return self._strongerList
end

function QStrongerUtil:getStrongerHelpById(id)
	for i, stronger in pairs(self._strongerList) do
		if id == stronger.id then
			return stronger
		end
	end
end

function QStrongerUtil:saveShowRecord()
	local idRecord = ""
	for i, stronger in pairs(self._strongerList) do
		idRecord = idRecord..stronger.id..";"
	end
	app:getUserOperateRecord():setRecordByType("STRONGER_SHOW_ID", idRecord)
end

function QStrongerUtil:getLevelForce()
	return self._levelForce
end

function QStrongerUtil:getStageByStandardByIdName(idName)
	local curStronger = nil
	for i, stronger in pairs(self._strongerList) do
		if idName == stronger.id_name then
			curStronger = stronger
			break
		end
	end
	return self:getStageByStandard(curStronger)
end

function QStrongerUtil:getStageByStandard(stronger)
	local resPath = QResPath("stronger_help_pic")
	if not stronger then
		return 1, resPath[2]
	end

	local value = (stronger.curValue or 0)/(stronger.standardValue or 999)
	local picPath = nil
	if value >= 1.2 then
		picPath = resPath[1]
	elseif value >= 1 then
		picPath = resPath[2]
	elseif value >= 0.9 then
		picPath = resPath[3]
	elseif value >= 0.75 then
		picPath = resPath[4]
	elseif value >= 0.6 then
		picPath = resPath[5]
	else
		picPath = resPath[6]
	end

	return value, picPath
end


function QStrongerUtil:getHeroTrainLevel(heroInfo)
	local trainAttr = heroInfo.trainAttr
    if not trainAttr then
    	return 0
    end
    local hpForce = db:getBattleForceBySingleAttribute("hp", trainAttr.hp or 0, heroInfo.level)
    local attackForce = db:getBattleForceBySingleAttribute("attack", trainAttr.attack or 0, heroInfo.level)
    local pdForce = db:getBattleForceBySingleAttribute("armor_physical", trainAttr.armorPhysical or 0, heroInfo.level)
    local mdForce = db:getBattleForceBySingleAttribute("armor_magic", trainAttr.armorMagic or 0, heroInfo.level)
    local forceChange =  math.ceil(hpForce + attackForce + pdForce + mdForce)

	local masterForce = 0
	local bonus = db:getTrainingBonus(heroInfo.actorId)
	for _, bonu in pairs(bonus) do
		if bonu.standard <= forceChange then
			masterForce = masterForce + app.master:getTrainMasterForce(bonu, heroInfo.actorId)
		end
	end
    return forceChange + masterForce
end

------------------------------------------------------------------
-- 斗罗武魂
function QStrongerUtil:getStandardArchaeology()
	local lastId = remote.archaeology:getLastEnableFragmentID()
	if lastId == 0 then
		return 0
	end
	local _, index = remote.archaeology:getLastEnableIndexByID(lastId)
	return index
end

-------------------------------------------------------------------

--[[
	我要變強的跳轉，我放到這裡了，因為戰鬥失敗也要用
	@info = {id_name = "hero_grade", shortcut = 15001}
]]
function QStrongerUtil:gotoByInfo(info)
	if not info or (not info.id_name and not info.shortcut) then return end
	
	if info.id_name == "archaeology" then
		QQuickWay:openArchaeology()
	elseif info.id_name == "soul_trial" then
		remote.soulTrial:openSoulTrial()
	elseif info.id_name == "hero_grade" or info.id_name == "hero_level" then
		QQuickWay:openHeroLevelUp()
	elseif info.id_name == "hero_train" then
		QQuickWay:openHeroTraining()
	elseif info.id_name == "hero_skill" then
		QQuickWay:openHeroSkill()
	elseif info.id_name == "hero_glyph" then
		QQuickWay:openHeroGlyph()
	elseif info.id_name == "magic_herb_suit" or info.id_name == "magic_herb_grade" or info.id_name == "magic_herb_level" then
		QQuickWay:openHeroMagicHerb()
	elseif info.id_name == "hero_break" then
		QQuickWay:openEquipmentEvolution()
	elseif info.id_name == "equip_enhance" then
		QQuickWay:openEquipmentStrong()
	elseif info.id_name == "equip_enchant" then
		QQuickWay:openEquipmentMagic()
	elseif info.id_name == "jewelry_enhance" or info.id_name == "jewelry1_enhance" then
		QQuickWay:openEquipmentStrong(nil, false, EQUIPMENT_TYPE.JEWELRY1)
	elseif info.id_name == "jewelry_break" or info.id_name == "jewelry1_break" then
		QQuickWay:openEquipmentEvolution(nil, false, EQUIPMENT_TYPE.JEWELRY1)
	elseif info.id_name == "jewelry_enchant" then
		QQuickWay:openEquipmentMagic(nil, false, EQUIPMENT_TYPE.JEWELRY1)
	elseif info.id_name == "gemstone_count" then
		QQuickWay:openGemStoneDetail(nil, true)
	elseif info.id_name == "gemstone_enhance" then
		QQuickWay:openGemStoneStrong(nil, true)
	elseif info.id_name == "gemstone_break" then
		QQuickWay:openGemStoneEvolution(nil, true)
	elseif info.id_name == "spar_suit" then
		QQuickWay:openSparDetail(nil, true)
	elseif info.id_name == "spar_enhance" then
		QQuickWay:openSparStrong(nil, true)
	elseif info.id_name == "spar_grade" then
		QQuickWay:openSparGrade(nil, true)
	elseif info.id_name == "artifact_grade" then
		QQuickWay:openArtifactGrade()
	elseif info.id_name == "artifact_level" then
		QQuickWay:openArtifactStrong()
	elseif info.id_name == "mount_grade" then
		QQuickWay:openMountGrade(nil, true)
	elseif info.id_name == "mount_level" then
		QQuickWay:openMountStrong(nil, true)
	elseif info.id_name == "spirit_grade" then
		QQuickWay:openSoulSpiritGrade()
	elseif info.id_name == "spirit_level" then
		QQuickWay:openSoulSpiritLevel()
	elseif info.shortcut then
		local shortcut = db:getShortcutByID(info.shortcut)
    	QQuickWay:clickGoto(shortcut)
    end
end

return QStrongerUtil

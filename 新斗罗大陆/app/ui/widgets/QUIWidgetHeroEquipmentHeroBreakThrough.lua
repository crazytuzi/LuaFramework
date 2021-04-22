--
-- Author: wkwang
-- Date: 2015-03-04 17:08:35
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroEquipmentHeroBreakThrough = class("QUIWidgetHeroEquipmentHeroBreakThrough", QUIWidget)

local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QHeroModel = import("...models.QHeroModel")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QQuickWay = import("...utils.QQuickWay")
local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")

QUIWidgetHeroEquipmentHeroBreakThrough.EVENT_BREAK_SUCC = "EVENT_BREAK_SUCC"

function QUIWidgetHeroEquipmentHeroBreakThrough:ctor(options)
	local ccbFile = "ccb/Widget_HeroEquipment_Evolution.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerEvolution", callback = handler(self, QUIWidgetHeroEquipmentHeroBreakThrough._onTriggerEvolution)},
		}
	QUIWidgetHeroEquipmentHeroBreakThrough.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self.materials = {}

end

function QUIWidgetHeroEquipmentHeroBreakThrough:resetAll()
	self._ccbOwner.node_old_head:removeAllChildren()
	self._ccbOwner.node_new_head:removeAllChildren()
end

function QUIWidgetHeroEquipmentHeroBreakThrough:setInfo(actorId)
	self._actorId = actorId
	local heroInfo = remote.herosUtil:getHeroByID(actorId)

	self:_updateAvatar(actorId, heroInfo)
	self:_updateHeroStats(actorId, heroInfo.breakthrough)
	self:_updateSkill(actorId, heroInfo.breakthrough)

	local characherConfig = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
	local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
	local breakthroughInfo = QStaticDatabase:sharedDatabase():getBreakthroughByTalentLevel(characterInfo.talent, remote.herosUtil:getHeroByID(actorId).breakthrough + 1)
	self._breakthroughCost = breakthroughInfo.money
	self._ccbOwner.tf_money:setString(self._breakthroughCost)
	if self._breakthroughCost > remote.user.money then
		self._ccbOwner.tf_money:setColor(UNITY_COLOR.red)
	else
		self._ccbOwner.tf_money:setColor(ccc3(109, 68, 39))
	end
end

function QUIWidgetHeroEquipmentHeroBreakThrough:_updateAvatar(actorId, heroInfo)
	if heroInfo ~= nil then
		local newHeroInfo = clone(heroInfo)
		newHeroInfo.breakthrough = heroInfo.breakthrough + 1

		local slotId = QStaticDatabase:sharedDatabase():getBreakthroughHeroByHeroActorLevel(actorId, newHeroInfo.breakthrough).skill_id_3
		if slotId then
			table.insert(newHeroInfo.slots, {slotId = slotId, slotLevel = 1})
		end

		-- Show avatar
		local oldHead = QUIWidgetHeroHead.new()
		self._ccbOwner.node_old_head:addChild(oldHead)
		oldHead:setHeroSkinId(heroInfo.skinId)
		oldHead:setHero(actorId)
		oldHead:setLevel(heroInfo.level)
		oldHead:setStar(heroInfo.grade)
		-- oldHead:showSabc()
		oldHead:setBreakthrough(heroInfo.breakthrough)
        oldHead:setGodSkillShowLevel(heroInfo.godSkillGrade, actorId)

		local heroName = QStaticDatabase:sharedDatabase():getCharacterByID(actorId).name
		local breakthroughLevel = 0
		local color = nil
		if heroInfo ~= nil then
			breakthroughLevel, color = remote.herosUtil:getBreakThrough(heroInfo.breakthrough)
		end
		if breakthroughLevel > 0 then
			heroName = heroName .."＋".. breakthroughLevel
		end
		self._ccbOwner.tf_old_name:setString(heroName)
		if color ~= nil then
			self._ccbOwner.tf_old_name:setColor(BREAKTHROUGH_COLOR_LIGHT[color])
		end

		local newHead = QUIWidgetHeroHead.new()
		self._ccbOwner.node_new_head:addChild(newHead)
		newHead:setHeroSkinId(heroInfo.skinId)
		newHead:setHero(actorId)
		newHead:setLevel(heroInfo.level)
		newHead:setStar(heroInfo.grade)
		-- newHead:showSabc()
		newHead:setBreakthrough(newHeroInfo.breakthrough)
        newHead:setGodSkillShowLevel(heroInfo.godSkillGrade, actorId)

		local heroName = QStaticDatabase:sharedDatabase():getCharacterByID(actorId).name
		local breakthroughLevel = 0
		local color = nil
		if newHeroInfo ~= nil then
			breakthroughLevel, color = remote.herosUtil:getBreakThrough(newHeroInfo.breakthrough)
		end
		if breakthroughLevel > 0 then
			heroName = heroName .."＋".. breakthroughLevel
		end
		self._ccbOwner.tf_new_name:setString(heroName)
		if color ~= nil then
			self._ccbOwner.tf_new_name:setColor(BREAKTHROUGH_COLOR_LIGHT[color])
		end
	end
end

function QUIWidgetHeroEquipmentHeroBreakThrough:_updateHeroStats(actorId, breakthroughLevel)
	local oldConfig = QStaticDatabase:sharedDatabase():getBreakthroughHeroByHeroActorLevel(actorId, breakthroughLevel)
	local newConfig = QStaticDatabase:sharedDatabase():getBreakthroughHeroByHeroActorLevel(actorId, breakthroughLevel + 1)
	local heroInfo = remote.herosUtil:getHeroByID(actorId)

	local hp1 = math.ceil((oldConfig.hp_value or 0) + (oldConfig.hp_grow or 0) * heroInfo.level)
	local hp2 = math.ceil((newConfig.hp_value or 0) + (newConfig.hp_grow or 0) * heroInfo.level)
	local attack1 = math.ceil((oldConfig.attack_value or 0) + (oldConfig.attack_grow or 0) * heroInfo.level)
	local attack2 = math.ceil((newConfig.attack_value or 0) + (newConfig.attack_grow or 0) * heroInfo.level)

	self._ccbOwner.tf_old_value1:setString(hp1)
	self._ccbOwner.tf_new_value1:setString(hp2)
	self._ccbOwner.tf_old_value2:setString(attack1)
	self._ccbOwner.tf_new_value2:setString(attack2)
end

function QUIWidgetHeroEquipmentHeroBreakThrough:_updateSkill(actorId, breakthroughLevel)
	self._ccbOwner.node_skill:setVisible(false)

	local config = QStaticDatabase:sharedDatabase():getBreakthroughHeroByHeroActorLevel(actorId, breakthroughLevel + 1)
	local slotId = config.skill_id_3
	if slotId then
		local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(actorId, slotId)
		local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(skillId)
		if skillConfig ~= nil then
			self._ccbOwner.node_skill:setVisible(true)
			if self._skillBox == nil then
				self._skillBox = QUIWidgetHeroSkillBox.new()
				self._skillBox:setLock(false)
				self._ccbOwner.node_skillicon:addChild(self._skillBox)
			end
			self._skillBox:setSkillID(skillId)
			self._ccbOwner.tf_skill_name:setString(skillConfig.name)
		end
	end
end

function QUIWidgetHeroEquipmentHeroBreakThrough:_onTriggerEvolution(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_break) == false then return end
	if remote.user.money < self._breakthroughCost then 
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
	end
    local oldHeroInfo = clone(remote.herosUtil:getHeroByID(self._actorId))
	app:getClient():breakthrough(self._actorId, function(data)
			if self.class ~= nil then
				self:dispatchEvent({name = QUIWidgetHeroEquipmentHeroBreakThrough.EVENT_BREAK_SUCC, oldHeroInfo = oldHeroInfo})
				self:dispatchEvent({name = QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE})
			end
		end)
end

return QUIWidgetHeroEquipmentHeroBreakThrough
--
-- Author: qinyuanji
-- Date: 2015-06-22
--
-- 从ccb看，这个界面暂时没有用到 by Kumo 2020年8月8日
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBreakthroughPreview = class("QUIDialogBreakthroughPreview", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetEquipmentBox = import("..widgets.QUIWidgetEquipmentBox")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")

function QUIDialogBreakthroughPreview:ctor(options)
 	local ccbFile = "ccb/Dialog_HeroBreakThroughtOverview.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogBreakthroughPreview._onTriggerClose)},
        {ccbCallbackName = "onTriggerEvolution", callback = handler(self, QUIDialogBreakthroughPreview._onTriggerEvolution)},
        {ccbCallbackName = "onTriggerClickEquip", callback = handler(self, QUIDialogBreakthroughPreview._onTriggerClickEquip)},
    }
    QUIDialogBreakthroughPreview.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._heros = options.heros
    self._pos = options.pos
    self._parentOptions = options.parentOptions
    self._actorId = self._heros[self._pos]
end

function QUIDialogBreakthroughPreview:viewWillAppear()
	QUIDialogBreakthroughPreview.super.viewWillAppear(self)

	self:setInfo(self._actorId)
end

function QUIDialogBreakthroughPreview:viewWillDisappear( ... )
	QUIDialogBreakthroughPreview.super.viewWillDisappear(self)
end

function QUIDialogBreakthroughPreview:setInfo(actorId)
	self._actorId = actorId
	local heroInfo = remote.herosUtil:getHeroByID(actorId)

	self:_updateAvatar(actorId, heroInfo)
	self:_updateHeroStats(actorId, heroInfo.breakthrough)
	self:_updateSkill(actorId, heroInfo.breakthrough)

    local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
    local breakthroughInfo = QStaticDatabase:sharedDatabase():getBreakthroughByTalentLevel(characterInfo.talent, remote.herosUtil:getHeroByID(actorId).breakthrough + 1)
    self._breakthroughCost = breakthroughInfo.money
    self._ccbOwner.tf_money:setString(self._breakthroughCost)
    if remote.user.money < self._breakthroughCost then
    	self._ccbOwner.tf_money:setColor(GAME_COLOR_LIGHT.warning)
    else
    	self._ccbOwner.tf_money:setColor(GAME_COLOR_LIGHT.stress)
    end

	local heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local isCanBreak,needBreakItem,needBreakNum = heroUIModel:getCanBreak()
	if isCanBreak == false then
		self._ccbOwner.tf_tips:setVisible(false)
		self._ccbOwner.tast:setVisible(false)
		self._ccbOwner.btn_tupo:setVisible(false)
		self._ccbOwner.no_break:setVisible(true)
		self._ccbOwner.word:setString(needBreakNum .. "件装备品质不足，无法突破魂师，请先")
		self:checkCanBreakEquip(heroUIModel._equipmentBreak, heroUIModel._heroInfo.breakthrough)
	end
end

function QUIDialogBreakthroughPreview:checkCanBreakEquip(equipmentBreak, breakthrough)
	if equipmentBreak[EQUIPMENT_TYPE.WEAPON].breakLevel <= breakthrough then
		self._breakItemId = equipmentBreak[EQUIPMENT_TYPE.WEAPON].info.itemId
    	self._equipmentPos = EQUIPMENT_TYPE.WEAPON
    elseif equipmentBreak[EQUIPMENT_TYPE.BRACELET].breakLevel <= breakthrough then
		self._breakItemId = equipmentBreak[EQUIPMENT_TYPE.BRACELET].info.itemId
    	self._equipmentPos = EQUIPMENT_TYPE.BRACELET
    elseif equipmentBreak[EQUIPMENT_TYPE.CLOTHES].breakLevel <= breakthrough then
		self._breakItemId = equipmentBreak[EQUIPMENT_TYPE.CLOTHES].info.itemId
    	self._equipmentPos = EQUIPMENT_TYPE.CLOTHES
    elseif equipmentBreak[EQUIPMENT_TYPE.SHOES].breakLevel <= breakthrough then
		self._breakItemId = equipmentBreak[EQUIPMENT_TYPE.SHOES].info.itemId
    	self._equipmentPos = EQUIPMENT_TYPE.SHOES
    end
end

function QUIDialogBreakthroughPreview:_updateAvatar(actorId, heroInfo)
	if heroInfo ~= nil then 
		local newHeroInfo = clone(heroInfo)
		newHeroInfo.breakthrough = heroInfo.breakthrough + 1

		-- Show avatar
		local oldHead = QUIWidgetHeroHead.new()
		self._ccbOwner.node_old_head:addChild(oldHead)
		oldHead:setHeroSkinId(heroInfo.skinId)
		oldHead:setHero(actorId)
		oldHead:setLevel(heroInfo.level)
		oldHead:setStar(heroInfo.grade)
		-- oldHead:showSabc()
		oldHead:setBreakthrough(heroInfo.breakthrough)
        oldHead:setGodSkillShowLevel(heroInfo.godSkillGrade)

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
			local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
			self._ccbOwner.tf_old_name:setColor(fontColor)
			self._ccbOwner.tf_old_name = setShadowByFontColor(self._ccbOwner.tf_old_name, fontColor)
		end

		local newHead = QUIWidgetHeroHead.new()
		self._ccbOwner.node_new_head:addChild(newHead)
		newHead:setHeroSkinId(heroInfo.skinId)
		newHead:setHero(actorId)
		newHead:setLevel(heroInfo.level)
		newHead:setStar(heroInfo.grade)
        newHead:setGodSkillShowLevel(heroInfo.godSkillGrade)
		-- newHead:showSabc()
		newHead:setBreakthrough(newHeroInfo.breakthrough)

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
			local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
			self._ccbOwner.tf_new_name:setColor(fontColor)
			self._ccbOwner.tf_new_name = setShadowByFontColor(self._ccbOwner.tf_new_name, fontColor)
		end
	end
end

function QUIDialogBreakthroughPreview:_updateHeroStats(actorId, breakthroughLevel)
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

function QUIDialogBreakthroughPreview:_updateSkill(actorId, breakthroughLevel)
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

function QUIDialogBreakthroughPreview:_onTriggerClickEquip()
	self:viewAnimationOutHandler()
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
        options = {itemId = self._breakItemId, equipmentPos = self._equipmentPos, heros = self._heros, pos = self._pos, parentOptions = self._parentOptions}})
end

function QUIDialogBreakthroughPreview:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogBreakthroughPreview:_onTriggerEvolution()
	if remote.herosUtil:checkHerosBreakthroughByID(self._actorId) == false then
		app.tip:floatTip("突破条件尚未满足")
		return
	end

    if remote.user.money < self._breakthroughCost then 
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
        return
    end
    self._confirmCallback = self:getOptions().confirmCallback
	self:_onTriggerClose()
end

function QUIDialogBreakthroughPreview:_onTriggerClose(e)
	if e ~= nil then app.sound:playSound("common_cancel") end
	self:playEffectOut()
end

function QUIDialogBreakthroughPreview:viewAnimationOutHandler()
	local confirmCallback = self._confirmCallback
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

	if confirmCallback then
		confirmCallback()
	end
end

return QUIDialogBreakthroughPreview
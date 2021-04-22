--
-- Author: xurui
-- Date: 2015-12-17 20:17:32
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroAdvance = class("QUIDialogHeroAdvance", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogHeroAdvance:ctor(options)
	local ccbFile = "ccb/Dialog_HeroBreakStar.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerAdvance", callback = handler(self, self._onTriggerAdvance)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerExchange", callback = handler(self, self._onTriggerExchange)},
	}
	QUIDialogHeroAdvance.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._isUpGrade = false

	if options then
		self._actorId = options.actorId
		self._callBack = options.callBack
	end

	self:setHeroInfo()
	self:setAdvanceCondition()
end

function QUIDialogHeroAdvance:viewDidAppear()
	QUIDialogHeroAdvance.super.viewDidAppear(self)
end 

function QUIDialogHeroAdvance:viewWillDisappear()
	QUIDialogHeroAdvance.super.viewWillDisappear(self)
end

function QUIDialogHeroAdvance:setHeroInfo()
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if heroInfo == nil then return end
	self._heroInfo = heroInfo

	local oldHeroInfo = clone(heroInfo)
	local oldHead = QUIWidgetHeroHead.new()
	self._ccbOwner.node_old_head:addChild(oldHead)
	oldHead:setHeroSkinId(oldHeroInfo.skinId)
	oldHead:setHero(self._actorId)
	oldHead:setStar(oldHeroInfo.grade)
	oldHead:hideSabc()
	oldHead:setBreakthrough(oldHeroInfo.breakthrough)
    oldHead:setGodSkillShowLevel(oldHeroInfo.godSkillGrade)
		
    local heroName = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId).name
    local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(oldHeroInfo.grade+1)
    self._ccbOwner.hero_name1:setString(heroName.."("..level..gardeName..")")

	local newHeroInfo = clone(heroInfo)
	newHeroInfo.grade = newHeroInfo.grade + 1
	local newHead = QUIWidgetHeroHead.new()
	self._ccbOwner.node_new_head:addChild(newHead)
	newHead:setHeroSkinId(newHeroInfo.skinId)
	newHead:setHero(self._actorId)
	newHead:setStar(newHeroInfo.grade)
	newHead:hideSabc()
	newHead:setBreakthrough(newHeroInfo.breakthrough)
    newHead:setGodSkillShowLevel(newHeroInfo.godSkillGrade)
	
    local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(newHeroInfo.grade+1)
    self._ccbOwner.hero_name2:setString(heroName.."("..level..gardeName..")")

	self:setHeroProp(heroInfo)
end

function QUIDialogHeroAdvance:setHeroProp(heroInfo)
    local oldHeroConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._heroInfo.actorId, heroInfo.grade)
    local newHeroConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._heroInfo.actorId, heroInfo.grade+1)

	self._ccbOwner.tf_old_value1:setString(math.floor(oldHeroConfig.attack_value or 0))
	self._ccbOwner.tf_new_value1:setString(math.floor(newHeroConfig.attack_value or 0))
	self._ccbOwner.tf_old_value2:setString(math.floor(oldHeroConfig.hp_value or 0))
	self._ccbOwner.tf_new_value2:setString(math.floor(newHeroConfig.hp_value or 0))
	self._ccbOwner.tf_old_value3:setString(math.floor(oldHeroConfig.attack_grow or 0))
	self._ccbOwner.tf_new_value3:setString(math.floor(newHeroConfig.attack_grow or 0))
	self._ccbOwner.tf_old_value4:setString(math.floor(oldHeroConfig.hp_grow or 0))
	self._ccbOwner.tf_new_value4:setString(math.floor(newHeroConfig.hp_grow or 0))

	local oldStringTilte = remote.herosUtil:getJobTitleByGradeLevelNum(heroInfo.grade+1)
	local newStringTilte = remote.herosUtil:getJobTitleByGradeLevelNum(heroInfo.grade+2)
	self._ccbOwner.tf_old_value5:setString(oldStringTilte or "三界外")
	self._ccbOwner.tf_new_value5:setString(newStringTilte or "三界外")
end

function QUIDialogHeroAdvance:setAdvanceCondition()
    local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._actorId, self._heroInfo.grade+1)
    if gradeConfig == nil then return end

    local itemBox = QUIWidgetItemsBox.new()
    self._ccbOwner.icon_node:addChild(itemBox)
    itemBox:setGoodsInfo(gradeConfig.soul_gem, "item", 0)
    itemBox:setSoulFragStar(false)
    itemBox:hideTalentIcon()
    itemBox:hideSabc()

    self._needSoulNum = gradeConfig.soul_gem_count
    self._haveSoulNum = remote.items:getItemsNumByID(gradeConfig.soul_gem)
    self._ccbOwner.soul_num:setString(self._haveSoulNum.."/"..self._needSoulNum)
    if self._needSoulNum > self._haveSoulNum then
		self._ccbOwner.soul_num:setColor(COLORS.m)
	else
		self._ccbOwner.soul_num:setColor(COLORS.k)
	end

    self._limitLevel = gradeConfig.hero_level_limit
    if self._limitLevel ~= nil then
		self._ccbOwner.tf_level:setString("LV"..(self._limitLevel or 0))
		self._ccbOwner.hero_level:setString("魂师"..self._limitLevel.."级")
	end
	if self._limitLevel > self._heroInfo.level then
		self._ccbOwner.hero_level:setColor(COLORS.m)
	else
		self._ccbOwner.hero_level:setColor(COLORS.k)
	end

	self._needMoney = gradeConfig.money
	self._ccbOwner.tf_money:setString(self._needMoney)
	if self._needMoney > remote.user.money then
		self._ccbOwner.tf_money:setColor(COLORS.m)
	else
		self._ccbOwner.tf_money:setColor(COLORS.k)
	end

	self._needItemNum = gradeConfig.item_num or 0
	self._haveItemNum = remote.items:getItemsNumByID(tonumber(gradeConfig.item_id)) or 0
	self._itemId = gradeConfig.item_id 
	if gradeConfig.item_id ~= 0 and gradeConfig.item_id ~= nil then
		local item = QUIWidgetItemsBox.new()
		self._ccbOwner.item_node:addChild(item)
		item:setGoodsInfo(gradeConfig.item_id, "item", 0)

		self._ccbOwner.item_num:setString(self._haveItemNum.."/"..self._needItemNum)
		if self._needItemNum > self._haveItemNum then
			self._ccbOwner.item_num:setColor(COLORS.m)
		else
			self._ccbOwner.item_num:setColor(COLORS.k)
		end
	else
		self._ccbOwner.item_1:setPositionX(-74)
		self._ccbOwner.item_2:setPositionX(94)
		self._ccbOwner.item_3:setVisible(false)
	end

	self._ccbOwner.node_btn_awake:setVisible(false)
	if gradeConfig.awake ~= nil and gradeConfig.awake == 1 then
		self._ccbOwner.node_btn_awake:setVisible(true)
	end
end

function QUIDialogHeroAdvance:_onTriggerAdvance(e, target)
	if q.buttonEventShadow(e, target) == false then return end
    app.sound:playSound("common_small")
  	if self._needSoulNum > self._haveSoulNum then	
		QQuickWay:addQuickWay(QQuickWay.HERO_DROP_WAY, self._actorId, self._needSoulNum)
		return
  	end
  	if self._limitLevel > self._heroInfo.level then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.HERO_LEVEL)
		return  
  	end
  	if self._needMoney > remote.user.money then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
  	end
  	if self._itemId ~= 0 and self._needItemNum > self._haveItemNum then
 		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId, self._needItemNum)
		return
	end
  	self._isUpGrade = true
  	self:_onTriggerClose()
end

function QUIDialogHeroAdvance:_backClickHandler()
	self:_onTriggerClose()
end 

function QUIDialogHeroAdvance:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	if e ~= nil then
    	app.sound:playSound("common_cancel")
	end
	self:playEffectOut()
end

function QUIDialogHeroAdvance:_onTriggerExchange(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_exchange) == false then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogExchangeHeroSoul",
		options = {actorId = self._actorId, needNum = self._needSoulNum}})
end

function QUIDialogHeroAdvance:viewAnimationOutHandler()
  	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

  	if self._isUpGrade then
    	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.HERO_ADVANCE_SUCCESS})
  	end
end 

return QUIDialogHeroAdvance
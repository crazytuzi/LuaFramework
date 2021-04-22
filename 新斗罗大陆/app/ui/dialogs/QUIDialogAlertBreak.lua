--
-- Author: wkwang
-- Date: 2015-03-27 11:14:44
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAlertBreak = class("QUIDialogAlertBreak", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetEquipmentBox = import("..widgets.QUIWidgetEquipmentBox")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIDialogAlertBreak.TYPE_HERO = "TYPE_HERO"
QUIDialogAlertBreak.TYPE_ITEM = "TYPE_ITEM"

function QUIDialogAlertBreak:ctor(options)
 	local ccbFile = "ccb/Dialog_BreakThrough_Tips.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogAlertBreak._onTriggerClose)},
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogAlertBreak._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogAlertBreak._onTriggerCancel)},
    }
    QUIDialogAlertBreak.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    self._typeName = options.typeName

    self._itemId = options.itemId
    self._actorId = options.actorId
    self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    self._ccbOwner.tf_num1:setString("")
    self._ccbOwner.tf_num2:setString("")

    self._ccbOwner.frame_tf_title:setString("突破提示")

	if self._typeName == QUIDialogAlertBreak.TYPE_HERO then
		self:showHeroInfo()
		self._ccbOwner.tf_tips1:setString("如果需要把魂师突破到")
		self._ccbOwner.tf_tips2:setString("则需要同时把魂师的所有装备突破到")
	elseif self._typeName == QUIDialogAlertBreak.TYPE_ITEM then
		self._ccbOwner.tf_tips1:setString("如果要把装备突破到")
		self._ccbOwner.tf_tips2:setString("请您先将魂师突破到")
		self:showItemInfo()
		self._ccbOwner.tf_break2:setPositionX(self._ccbOwner.tf_tips2:getPositionX() + self._ccbOwner.tf_tips2:getContentSize().width/2 + 20)
	end
end

function QUIDialogAlertBreak:showItemInfo()
	local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(self._actorId, self._itemId)
	local nextItemConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(self._itemId)
	self._ccbOwner.tf_break1 = setShadow5(self._ccbOwner.tf_break1)
	self._ccbOwner.tf_break2 = setShadow5(self._ccbOwner.tf_break2)
	self:setTFColor(self._ccbOwner.tf_break1, breaklevel)

	local breakthroughLevel,color = remote.herosUtil:getBreakThrough(nextItemConfig.hero_break or 0)
	self._ccbOwner.tf_break2:setColor(BREAKTHROUGH_COLOR_LIGHT[color])
	local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
	local str = characterInfo.name
	if breakthroughLevel > 0 then
		str = str .." ＋"..breakthroughLevel
	end
	self._ccbOwner.tf_break2:setString(str)

	local oldHead = QUIWidgetHeroHead.new()
	local newHead = QUIWidgetHeroHead.new()
	self._ccbOwner.node_icon1:addChild(oldHead)
	self._ccbOwner.node_icon2:addChild(newHead)
	oldHead:setHeroSkinId(self._heroInfo.skinId)
	oldHead:setHero(self._actorId)
	oldHead:setLevel(self._heroInfo.level)
	oldHead:setStar(self._heroInfo.grade)
    oldHead:setGodSkillShowLevel(self._heroInfo.godSkillGrade)
	-- oldHead:showSabc()
	newHead:setHeroSkinId(self._heroInfo.skinId)
	newHead:setHero(self._actorId)
	newHead:setLevel(self._heroInfo.level)
	newHead:setStar(self._heroInfo.grade)
    newHead:setGodSkillShowLevel(self._heroInfo.godSkillGrade)

	-- newHead:showSabc()
	newHead:setBreakthrough(nextItemConfig.hero_break or 0)
end

function QUIDialogAlertBreak:showHeroInfo()
    local breaklevel = self._heroInfo.breakthrough
	self:setTFColor(self._ccbOwner.tf_break1, breaklevel+1)
	self:setTFColor(self._ccbOwner.tf_break2, breaklevel+1)
	local itemBox1 = QUIWidgetEquipmentBox.new()
	itemBox1:setEquipmentInfo( QStaticDatabase:sharedDatabase():getItemByID(self._itemId), true, self._actorId)
	itemBox1:setEvolution(breaklevel)
	self._ccbOwner.node_icon1:addChild(itemBox1)

	local equipmentName = remote.herosUtil:getEquipeName(self._actorId, self._itemId)
	local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
	local breakthroughInfo = QStaticDatabase:sharedDatabase():getBreakthroughByTalentLevel(characterInfo.talent, self._heroInfo.breakthrough+1)
	if breakthroughInfo ~= nil then
		local itemBox2 = QUIWidgetEquipmentBox.new()
		itemBox2:setEquipmentInfo( QStaticDatabase:sharedDatabase():getItemByID(breakthroughInfo[equipmentName]), true, self._actorId)
		itemBox2:setEvolution(breaklevel+1)
		self._ccbOwner.node_icon2:addChild(itemBox2)
	end
end

function QUIDialogAlertBreak:setTFColor(tf1, breaklevel)
	local breakthroughLevel,color = remote.herosUtil:getBreakThrough(breaklevel)
	if color == nil then color = "white" end
	local str = q.colorToWord(color).."色"
	if breakthroughLevel > 0 then
		str = str .." ＋"..breakthroughLevel
	end
	tf1:setString(str)
	tf1:setColor(BREAKTHROUGH_COLOR_LIGHT[color])
end

function QUIDialogAlertBreak:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
	self:_onTriggerClose()
end

function QUIDialogAlertBreak:_onTriggerCancel(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_cancel) == false then return end
	self:_onTriggerClose()
end

function QUIDialogAlertBreak:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogAlertBreak:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogAlertBreak
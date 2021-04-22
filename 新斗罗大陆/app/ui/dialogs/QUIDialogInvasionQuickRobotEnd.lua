--
-- Author: Kumo
-- Date: 2014-07-17 14:08:11
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogInvasionQuickRobotEnd = class("QUIDialogInvasionQuickRobotEnd", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogInvasionQuickRobotEnd:ctor(options) 
 	local ccbFile = "ccb/Dialog_panjun_jiesuan.ccbi"
	local callBacks = {}
	QUIDialogInvasionQuickRobotEnd.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = options.isAnimation == nil and true or false
	self._callBack = options.callback

	local num, unit = q.convertLargerNumber(options.damage)
	self._ccbOwner.tf_damage:setString(num..(unit or ""))
	local num, unit = q.convertLargerNumber(options.meritorious)
	self._ccbOwner.tf_meritorious:setString(num..(unit or ""))

	self._ccbOwner.tf_damageRank_old:setString(options.damageOldRank)
	self._ccbOwner.tf_damageRank_new:setString(options.damageNewRank)
	local isShowDamageRank = options.damageOldRank ~= options.damageNewRank
	self._ccbOwner.node_damage_rank:setVisible(isShowDamageRank)
	self._ccbOwner.node_damage_rank:setPositionY(13)

	self._ccbOwner.tf_meritoriousRank_old:setString(options.meritOldRank)
	self._ccbOwner.tf_meritoriousRank_new:setString(options.meritNewRank)
	local isShowMeritoriousRank = options.meritOldRank ~= options.meritNewRank
	self._ccbOwner.node_meritorious_rank:setVisible(isShowMeritoriousRank)
	self._ccbOwner.node_meritorious_rank:setPositionY(-29)

	if not isShowMeritoriousRank and isShowDamageRank then
		self._ccbOwner.node_info:setPositionY(-23)
	elseif isShowMeritoriousRank and not isShowDamageRank then
		self._ccbOwner.node_meritorious_rank:setPositionY(13)
		self._ccbOwner.node_info:setPositionY(-23)
	elseif not isShowMeritoriousRank and not isShowDamageRank then
		self._ccbOwner.node_info:setPositionY(-44)
	else
		self._ccbOwner.node_info:setPositionY(0)
	end

	local itemsBox = QUIWidgetItemsBox.new()
    itemsBox:setVisible(false)
    itemsBox:setPromptIsOpen(true)
    itemsBox:resetAll()
    self:setBoxInfo(itemsBox, nil, ITEM_TYPE.INTRUSION_MONEY, options.baseRebelToken)
    self._ccbOwner.node_item1:addChild(itemsBox)

    itemsBox = QUIWidgetItemsBox.new()
    itemsBox:setVisible(false)
    itemsBox:setPromptIsOpen(true)
    itemsBox:resetAll()
    self:setBoxInfo(itemsBox, nil, ITEM_TYPE.INTRUSION_MONEY, options.addRebelToken - options.baseRebelToken)
    self._ccbOwner.node_item2:addChild(itemsBox)

    itemsBox = QUIWidgetItemsBox.new()
    itemsBox:setVisible(false)
    itemsBox:setPromptIsOpen(true)
    itemsBox:resetAll()
    self:setBoxInfo(itemsBox, nil, ITEM_TYPE.INTRUSION_MONEY, options.addRebelToken)
    self._ccbOwner.node_item3:addChild(itemsBox)
end

function QUIDialogInvasionQuickRobotEnd:setBoxInfo(box, itemID, itemType, num)
	if box ~= nil then
		box:setGoodsInfo(itemID,itemType,num)
		box:setVisible(true)
		
		if itemID ~= nil and remote.stores:checkItemIsNeed(itemID, num) then
			box:showGreenTips(true)
		end
	end
end

function QUIDialogInvasionQuickRobotEnd:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogInvasionQuickRobotEnd:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogInvasionQuickRobotEnd:viewAnimationOutHandler()
	local callBack = self._callBack
	self:popSelf()
	if callBack ~= nil then
		-- QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_EXIT_FROM_BATTLE, options = {}})
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_EXIT_FROM_QUICKBATTLE, options = {isQuick = true}})
		callBack()
	end
end

return QUIDialogInvasionQuickRobotEnd
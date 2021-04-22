-- @Author: liaoxianbo
-- @Date:   2019-07-22 17:37:35
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-08-05 14:37:22
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFinalAwards = class("QUIWidgetFinalAwards", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetFinalAwards.EVENT_SELECT_CLICK = "EVENT_SELECT_CLICK"
function QUIWidgetFinalAwards:ctor(options)
	local ccbFile = "ccb/Widget_monopoly_setaward.ccbi" --Widget_monopoly_setaward
    local callBacks = {
		{ccbCallbackName = "onTriggerUpClick", callback = handler(self, self._onTriggerUpClick)},
    }
    QUIWidgetFinalAwards.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetFinalAwards:setBoxInfo( index ,info)

	self._index = index
	self._ccbOwner.node_item:removeAllChildren()
	-- self._itemInfo = info
	self._itemSaveInfo = info
	local itemInfo = remote.monopoly:getLuckyDrawByKey(info)

	if itemInfo then
		local itemBox = QUIWidgetItemsBox.new()
		if itemInfo.id_1 == remote.monopoly.mainHeroItemId then
			itemInfo.id_1 = remote.monopoly:getMainHeroSoulItemId()
		end
		itemBox:setGoodsInfo(itemInfo.id_1, itemInfo.type_1, itemInfo.num_1)
		itemBox:setPromptIsOpen(true)
		self._ccbOwner.node_item:addChild(itemBox)
		if itemInfo.type_1 == "item" then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemInfo.id_1)
			if itemInfo then
				self._ccbOwner.tf_item_name:setString(itemInfo.name or "")
			end
		else
			local currencyInfo = remote.items:getWalletByType(itemInfo.type_1)
			if currencyInfo then
				self._ccbOwner.tf_item_name:setString(currencyInfo.nativeName or "")
			end
		end	
	end

	local setconfig = remote.monopoly:getOneSetMonopolyId(1)
	if setconfig and setconfig.finalAwardIndex == index then
		self:setSelectChoose(true)
	end
end

function QUIWidgetFinalAwards:_onTriggerUpClick(event )
	app.sound:playSound("common_switch")
    local checkState = self._ccbOwner.sp_on:isVisible()
    if checkState then return end
    self:setSelectChoose(not checkState)
    self:dispatchEvent( { name = QUIWidgetFinalAwards.EVENT_SELECT_CLICK ,index = self._index} )
end

function QUIWidgetFinalAwards:setSelectChoose(bState)
	self._ccbOwner.sp_on:setVisible(bState)
end

function QUIWidgetFinalAwards:getChooseState()
	local checkState = self._ccbOwner.sp_on:isVisible()
	return checkState
end

function QUIWidgetFinalAwards:getItemInfo()
	return remote.monopoly:getLuckyDrawByKey(self._itemSaveInfo)
end

function QUIWidgetFinalAwards:getItemSaveInfo()
	return self._itemSaveInfo
end

function QUIWidgetFinalAwards:getItemIndex( )
	return self._index
end
function QUIWidgetFinalAwards:onEnter()
end

function QUIWidgetFinalAwards:onExit()
end

function QUIWidgetFinalAwards:getContentSize()
	local size = self._ccbOwner.node_smark:getContentSize()	
	return size
end

return QUIWidgetFinalAwards

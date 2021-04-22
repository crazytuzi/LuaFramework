--
-- Author: xurui
-- Date: 2015-06-02 20:33:35
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTavernOverViewItemBox = class("QUIWidgetTavernOverViewItemBox", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")

function QUIWidgetTavernOverViewItemBox:ctor(options)
	local ccbFile = "ccb/Widget_TreasureChestDraw_Review_client2.ccbi"
	local callBacks = {}
	QUIWidgetTavernOverViewItemBox.super.ctor(self, ccbFile, callBacks, options)
	self._heightPlus = 65
end

function QUIWidgetTavernOverViewItemBox:setInfo(params)
	self._itemInfo = params.itemInfo
	if self._itemInfo.id then
		local count = self._itemInfo.count or 0
		self:setItemBox(self._itemInfo.id,count)
	end
	self._ccbOwner.node_probability:setVisible(false)

	if self._itemInfo.probability then
		self._ccbOwner.node_probability:setVisible(true)
		self._ccbOwner.item_probability:setString(name)
		self._heightPlus  = 85
	end

	if params.addTitle ~= nil then
		self:setPreviewTitle(params.addTitle, params.titleWord)
	end
end 

-- 添加title
function QUIWidgetTavernOverViewItemBox:setPreviewTitle(state, titleWord)
	if self._title ~= nil then
		self._title:removeFromParent()
		self._title = nil
	end
	if state == true then
		local ccbOwner = {}
	    self._title = CCBuilderReaderLoad("ccb/Dialog_fumo_yulan_title.ccbi", CCBProxy:create(), ccbOwner)
	    local contentSize = self:getContentSize()
	    self._title:setPosition(ccp(contentSize.width-125, contentSize.height - 157))
		self:getView():addChild(self._title)

		ccbOwner.tf_title:setString(titleWord or "")
	end
end

function QUIWidgetTavernOverViewItemBox:setItemBox(itemId , count)
	self._ccbOwner.item_box:removeAllChildren()

	local itemConfig = {}
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setPromptIsOpen(true)

	local name = ""
	local itemType = self._itemInfo.itemType
	if tonumber(itemId) == nil then
		itemConfig = remote.items:getWalletByType(itemId)
		name = itemConfig.nativeName
		itemType = itemId
	else
		itemConfig = QStaticDatabase:sharedDatabase():getItemByID(tonumber(itemId))
		if itemType == ITEM_TYPE.HERO or itemType == ITEM_TYPE.ZUOQI then
			itemConfig = QStaticDatabase:sharedDatabase():getCharacterByID(tonumber(itemId))
		end
		if itemConfig == nil then return end
		name = itemConfig.name
	end

	itemBox:setGoodsInfo(itemId, itemType, 0)
	if count and count > 0 then
		itemBox:setItemCount(count)
	end
	local color = remote.stores.itemQualityIndex[tonumber(itemConfig.colour)]
	if itemType == ITEM_TYPE.HERO or itemType == ITEM_TYPE.ZUOQI then
		itemBox:showSabc(remote.gemstone:getSABC(itemConfig.aptitude).lower)
		color = remote.gemstone:getSABC(itemConfig.aptitude).color
	end
	itemBox:hideTalentIcon()
	self._ccbOwner.item_box:addChild(itemBox)
	self._contentSize = itemBox:getContentSize()

	local oldContentSize = self._ccbOwner.item_nam:getContentSize()
	if itemConfig == nil then return end
	self._ccbOwner.item_nam:setString(name)

	if itemConfig.colour ~= nil or color ~= nil then
		local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
		self._ccbOwner.item_nam:setColor(fontColor)
		self._ccbOwner.item_nam = setShadowByFontColor(self._ccbOwner.item_nam, fontColor)
	end
end


function QUIWidgetTavernOverViewItemBox:getContentSize()
	local contentSize = self._ccbOwner.bg:getContentSize()
	return CCSize(contentSize.width, contentSize.height+self._heightPlus)
end

return QUIWidgetTavernOverViewItemBox
-- @Author: liaoxianbo
-- @Date:   2020-10-23 17:56:37
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-11-04 10:38:44
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogChosseCustomGift = class("QUIDialogChosseCustomGift", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetCustomShopItemBox = import("..widgets.QUIWidgetCustomShopItemBox")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")

local ITEM_BOX_POS = {
	{ccp(-50,238)},
	{ccp(-150,238),ccp(50,238)},
	{ccp(-200,238),ccp(-50,238),ccp(100,238)},
}

function QUIDialogChosseCustomGift:ctor(options)
	local ccbFile = "ccb/Dialog_Custom_shop_choose.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerPreview",callback = handler(self, self._onTriggerPreview)},
		{ccbCallbackName = "onTriggerCancel",callback = handler(self, self._onTriggerCancel)},
		{ccbCallbackName = "onTriggerOneKey",callback = handler(self, self._onTriggerOneKey)},
		{ccbCallbackName = "onTriggerNext",callback = handler(self, self._onTriggerNext)},
    }
    QUIDialogChosseCustomGift.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
    q.setButtonEnableShadow(self._ccbOwner.btn_yulan)
    q.setButtonEnableShadow(self._ccbOwner.btn_cancel)
    q.setButtonEnableShadow(self._ccbOwner.btn_onekey)
    q.setButtonEnableShadow(self._ccbOwner.btn_next)

	self._ccbOwner.frame_tf_title:setString("订制商品")

    self._itemPoolIds = options.itemPool or {}
    self._chooseCustomGiftInfo = options.info or {}

	self._customShopModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.CUSTOM_SHOP)
	self._historyItemList = self._customShopModule:getServerGiftInfoItemByIdType(self._chooseCustomGiftInfo.id,2)

	self._curtentItemList = self._customShopModule:getServerGiftInfoItemByIdType(self._chooseCustomGiftInfo.id,1)
    self:initDataView()

    self._isActionFly = false
    self:initListView()


end

function QUIDialogChosseCustomGift:viewDidAppear()
	QUIDialogChosseCustomGift.super.viewDidAppear(self)	
	self:setNextBtnState()
end

function QUIDialogChosseCustomGift:viewWillDisappear()
  	QUIDialogChosseCustomGift.super.viewWillDisappear(self)
end

function QUIDialogChosseCustomGift:resetAll()
	self._ccbOwner.node_onekey:setVisible(false)
	self._ccbOwner.node_haveItem:setVisible(false)
	self._ccbOwner.tf_empty_tips:setVisible(false)

	self._ccbOwner.node_itemPool:removeAllChildren()
	self._ccbOwner.node_item_des:removeAllChildren()
end

function QUIDialogChosseCustomGift:initDataView( )
	self:resetAll()

    self._itemPoolBox = {}
    self._itemPoolList = {}   
    self._curtentPoolId = 1
    self._curentChooseItem = nil 
    self._chooseItems = {}

	local itemBoxNum  = #self._itemPoolIds
	if itemBoxNum > 3 then
		itemBoxNum = 3
	end

	for ii=1,itemBoxNum do
		local key = tonumber(self._itemPoolIds[ii])
		if self._itemPoolBox[key] == nil then 
			self._itemPoolBox[key] = QUIWidgetCustomShopItemBox.new()
			self._ccbOwner.node_itemPool:addChild(self._itemPoolBox[key])
			self._itemPoolBox[key]:setPosition(ITEM_BOX_POS[itemBoxNum][ii])
			self._itemPoolBox[key]:setItemInfo(key,true)
	    	self._itemPoolBox[key]:addEventListener(QUIWidgetCustomShopItemBox.SHOW_POOL_ITEMS, handler(self, self._chooseItemPool))
	    end
	end

	if q.isEmpty(self._historyItemList) then
		self._ccbOwner.node_onekey:setVisible(false)
		self._ccbOwner.node_cancel:setPositionX(-141)
		self._ccbOwner.node_next:setPositionX(141)
	else
		self._ccbOwner.node_onekey:setVisible(true)
		self._ccbOwner.node_cancel:setPositionX(-235)
		self._ccbOwner.node_next:setPositionX(239)		
	end

	self:refresPoolItemInfo(self._curtentItemList)

	self:_chooseItemPool({poolId = self._itemPoolIds[1]})
	
end

function QUIDialogChosseCustomGift:_chooseItemPool(event)
	if self._isActionFly then return end
	local poolId = tonumber(event.poolId or 0)
	self._itemPoolList = self._customShopModule:getCustomShopContentById(poolId)

	self._curtentPoolId = poolId or 1	

	self:initListView(poolId)

	for _,v in pairs(self._itemPoolBox) do
		if v.setShowDownState then
			v:setShowDownState(false)
		end
	end

	if self._itemPoolBox[poolId] and self._itemPoolBox[poolId].setShowDownState then
		self._itemPoolBox[poolId]:setShowDownState(true)
	end

	if self._chooseItems[self._curtentPoolId] then
		self:_onFlyEvent({itemData = self._chooseItems[self._curtentPoolId].itemData,isDefault = true})
	else
		self:showItemDescribe()
	end	

	self:setNextBtnState()
end

function QUIDialogChosseCustomGift:initListView()
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
			contentOffsetX = 22,
			contentOffsetY = -5,
	        isVertical = true,
	        multiItems = 6,
	        spaceX = 10,
	        spaceY = -10,
	        enableShadow = false,
	      	ignoreCanDrag = true,  
	      	autoCenter = true,
	      	ignoreCanDrag = false,
	        totalNumber = #self._itemPoolList,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout_item, cfg)
	else
		self._listView:reload({totalNumber = #self._itemPoolList})
	end
	self._listView:setCanNotTouchMove(true)
end

function QUIDialogChosseCustomGift:_renderItemFunc( list, index, info )
    local isCacheNode = true
    local itemData = self._itemPoolList[index]
    local item = list:getItemFromCache(itemData.oType)
    if not item then
		item = QUIWidgetCustomShopItemBox.new()
		item:setScale(0.85)
	    item:addEventListener(QUIWidgetCustomShopItemBox.CHOOSE_FLAY_ACTION, handler(self, self._onFlyEvent))	
    	isCacheNode = false
    end
    item:setItemInfo(itemData,false)
    item:setChooseState(false)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
   
    return isCacheNode
end

function QUIDialogChosseCustomGift:showSelectAnimation(itemData,tagetItem,flyItem,callback)
	if not tagetItem or not flyItem then 
		if callback then
			callback()
		end
		return 
	end
    local icon = QUIWidgetItemsBox.new()
    icon:setGoodsInfo(itemData.id or 0,itemData.typeName, itemData.count)

    local p = flyItem:convertToWorldSpace(ccp(0, 0))
    p = self:getView():convertToNodeSpace(p)
    icon:setPosition(p.x+50, p.y-50)
    icon:setScale(0.8)
    self:getView():addChild(icon)

    local tP = tagetItem:convertToWorldSpace(ccp(0, 0))
    tP = self._ccbOwner.node_itemPool:convertToNodeSpace(tP)
    local targetP = ccp(tP.x+50, tP.y-50)
    local arr = CCArray:create()
    local bezierConfig = ccBezierConfig:new()
    bezierConfig.endPosition = targetP
    bezierConfig.controlPoint_1 = ccp(p.x + (targetP.x - p.x) * 0.333, p.y + (targetP.y- p.y) * 0.8)
    bezierConfig.controlPoint_2 = ccp(p.x + (targetP.x - p.x) * 0.667, p.y + (targetP.y- p.y) * 1)

    self._isActionFly = true
    local bezierTo = CCBezierTo:create(0.4, bezierConfig)
    arr:addObject(CCSpawn:createWithTwoActions(bezierTo, CCDelayTime:create(0.2)))
    arr:addObject(CCCallFunc:create(function()
            icon:removeFromParent()
			if callback then
				callback()
			end
			self._isActionFly = false            
        end))
    local seq = CCSequence:create(arr)
    icon:runAction(seq)
end

function QUIDialogChosseCustomGift:_onFlyEvent(event)
	local itemData = event.itemData or {}

	local chooseItemInfo = {}
	chooseItemInfo.itemData = itemData
	chooseItemInfo.poolId = self._curtentPoolId
	self._chooseItems[self._curtentPoolId] = chooseItemInfo

	local chooseItem = nil	
	for key,v in pairs(self._itemPoolList) do
		if self._listView then
			local item = self._listView:getItemByIndex(key)
			if item and item.setChooseState then
				item:setChooseState(false)
			end
			if (itemData.id ~= 0 and itemData.id ~= nil and v.id == itemData.id and v.count == itemData.count)
				or ((itemData.id == 0 or itemData.id == nil) and v.typeName == itemData.typeName and v.typeName ~= nil and v.count == itemData.count) then
				item:setChooseState(true)
				chooseItem = item			
			end
		end
	end

	local actionCallBack = function( )
		if self._itemPoolBox[self._curtentPoolId] then
			self._itemPoolBox[self._curtentPoolId]:refresItemInfo(itemData)
			self._itemPoolBox[self._curtentPoolId]:setShowDownState(true)
		end

		self:setNextBtnState()

		self:showItemDescribe(itemData)
	end

	if not event.isDefault then --执行飞的动画
		self:showSelectAnimation(itemData,self._itemPoolBox[self._curtentPoolId],chooseItem,function( )
			actionCallBack()
		end)
	else
		actionCallBack()
	end


end

function QUIDialogChosseCustomGift:setNextBtnState()
	if q.isEmpty(self._chooseItems[self._curtentPoolId]) then
		makeNodeFromNormalToGray(self._ccbOwner.node_next)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.node_next)
	end

	if table.nums(self._chooseItems) == #self._itemPoolIds then
		self._ccbOwner.tf_next:setString("完 成")
	else
		self._ccbOwner.tf_next:setString("下一个")
	end

end

function QUIDialogChosseCustomGift:showItemDescribe(itemData)

	self._curentChooseItem = itemData
	if q.isEmpty(itemData) then
		self._ccbOwner.node_haveItem:setVisible(false)
		self._ccbOwner.tf_empty_tips:setVisible(true)	
	else
		self._ccbOwner.node_haveItem:setVisible(true)
		self._ccbOwner.tf_empty_tips:setVisible(false)		
		local itemConfig = nil
		local isResource = false
		local itemType = itemData.typeName
		local itemId = itemData.id
		if itemType ~= ITEM_TYPE.HERO and itemId ~= nil then
			itemConfig = db:getItemByID(itemData.id)
		else
			isResource = true
			itemConfig = remote.items:getWalletByType(itemType)
		end
		
		self._ccbOwner.node_item_des:removeAllChildren()
		if q.isEmpty(itemConfig) == false then
			local des = itemConfig.description or ""
			local showName = itemConfig.name or ""
			if isResource then
				showName = itemConfig.nativeName or ""
			end
			self._ccbOwner.tf_itemName:setString(showName)
			local richText = QRichText.new(nil, 623)
			richText:setString(des)
		   	richText:setAnchorPoint(ccp(0.5, 1))
			self._ccbOwner.node_item_des:addChild(richText)
		end
	end
end

function QUIDialogChosseCustomGift:_onTriggerCancel()
	self:_onTriggerClose()
end

function QUIDialogChosseCustomGift:_onTriggerNext()
	if q.isEmpty(self._chooseItems[self._curtentPoolId]) then
		app.tip:floatTip("请先选择心仪的商品")
		return
	end
	local currItem = {}
	for _,v in pairs(self._chooseItems) do
		local itemData = v.itemData or {}
		if q.isEmpty(itemData) == false then
			local itemType = itemData.typeName or ITEM_TYPE.ITEM
			local itemId = itemData.id
			if itemType ~= ITEM_TYPE.HERO and itemId ~= nil and itemId ~= 0 then
				table.insert(currItem,itemId.."^"..(itemData.count or 0)..","..(v.poolId or 0))
			else
				table.insert(currItem,itemType.."^"..(itemData.count or 0)..","..(v.poolId or 0))
			end
		end
	end
	if table.nums(self._chooseItems) == #self._itemPoolIds then
		self._customShopModule:customShopChooseGiftRequest(self._chooseCustomGiftInfo.type,self._chooseCustomGiftInfo.id,currItem,function()
			if self:safeCheck() then
				self:popSelf()
			end
		end)
	else
		for _,v in pairs(self._itemPoolIds) do
			if q.isEmpty(self._chooseItems[tonumber(v)]) then
				self:_chooseItemPool({poolId = v})
				break
			end
		end
	end
end

function QUIDialogChosseCustomGift:_onTriggerPreview( )
	if q.isEmpty(self._curentChooseItem) then return end

	app.tip:itemTip(self._curentChooseItem.typeName, self._curentChooseItem.id)
end

function QUIDialogChosseCustomGift:refresPoolItemInfo(itemList)
	for _,v in pairs(itemList or {}) do
		local poolId = v.poolId or 0
		local itemData = v.itemData or {}
		if self._itemPoolBox[poolId] then
			self._itemPoolBox[poolId]:refresItemInfo(itemData)
			self._chooseItems[poolId] = v
		end
	end
end

function QUIDialogChosseCustomGift:_onTriggerOneKey( )
	
	if self._isActionFly then return end

	if q.isEmpty(self._historyItemList) then
		app.tip:floatTip("还没有历史订制")
		return
	end

	self:refresPoolItemInfo(self._historyItemList)


	self:setNextBtnState()
end

function QUIDialogChosseCustomGift:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogChosseCustomGift:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogChosseCustomGift:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogChosseCustomGift

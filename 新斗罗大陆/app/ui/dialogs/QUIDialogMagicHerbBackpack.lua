--
-- Author: Kumo.Wang
-- 仙品背包
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbBackpack = class("QUIDialogMagicHerbBackpack", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetItemsBox =  import("..widgets.QUIWidgetItemsBox")
local QUIWidgetMagicHerbBox =  import("..widgets.QUIWidgetMagicHerbBox")
local QUIWidgetBackPackInfo =  import("..widgets.QUIWidgetBackPackInfo")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBagArrow =  import("..widgets.QUIWidgetBagArrow")

QUIDialogMagicHerbBackpack.TAB_ALL = "TAB_ALL"
QUIDialogMagicHerbBackpack.TAB_CONSUM = "TAB_CONSUM"
QUIDialogMagicHerbBackpack.TAB_MAGICHERB = "TAB_MAGICHERB"

function QUIDialogMagicHerbBackpack:ctor(options)
	local ccbFile = "ccb/Dialog_MagicHerb_Packsack.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTabAll", callback = handler(self, QUIDialogMagicHerbBackpack._onTriggerTabAll)},
		{ccbCallbackName = "onTriggerTabConsum", callback = handler(self, QUIDialogMagicHerbBackpack._onTriggerTabConsum)},
		{ccbCallbackName = "onTriggerTabMagicHerb", callback = handler(self, QUIDialogMagicHerbBackpack._onTriggerTabMagicHerb)},
	}
	QUIDialogMagicHerbBackpack.super.ctor(self,ccbFile,callBacks,options)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()

    ui.tabButton(self._ccbOwner.node_tab_MagicHerb, "仙品")
    ui.tabButton(self._ccbOwner.node_tab_consum, "消耗")
	self._tabManager = ui.tabManager({self._ccbOwner.node_tab_MagicHerb, self._ccbOwner.node_tab_consum})

	self._packs = options.packs
	
	self._offsetY = -52
	self._offsetX = 62
	self._scrollShow = false
	self._totalCount = 10000
	self._virtualBox = {}

	self._cellH = self._ccbOwner.sprite_scroll_cell:getContentSize().height
	self._scrollH = self._ccbOwner.sprite_scroll_bar:getContentSize().height - self._cellH

	self._selectItemId = nil

	-- 初始化中间魂师页面滑动框
	self:_initPageSwipe()

end

function QUIDialogMagicHerbBackpack:startEnter()
	self:stopEnter()
    self._onFrameHandler = scheduler.scheduleGlobal(handler(self, self.onFrame), 0)
end

function QUIDialogMagicHerbBackpack:stopEnter()
    if self._onFrameHandler ~= nil then
    	scheduler.unscheduleGlobal(self._onFrameHandler)
    	self._onFrameHandler = nil
    end
end

function QUIDialogMagicHerbBackpack:viewDidAppear()
	QUIDialogMagicHerbBackpack.super.viewDidAppear(self)
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

    self._remoteProxy = cc.EventProxy.new(remote.items)
    self._remoteProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))
	self:addBackEvent()
	self:addArrowWidget(self._packs)
	
end

function QUIDialogMagicHerbBackpack:viewWillDisappear()
  	QUIDialogMagicHerbBackpack.super.viewWillDisappear(self)
  	
  	if self._selectItemId ~= nil then
  		self:getOptions().itemID = self._selectItemId
  	end

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
    self._remoteProxy:removeAllEventListeners()
	self:_removeAction()
	self:releaseBox()
	self:removeBackEvent()	
end

function QUIDialogMagicHerbBackpack:addArrowWidget(packs)
	local arr_node = QUIWidgetBagArrow.new({packs = packs})
	arr_node:setBagTag(5)
	self._ccbOwner.node_add_arr:addChild(arr_node)
end


-- 初始化中间的魂师选择框 swipe工能
function QUIDialogMagicHerbBackpack:_initPageSwipe()
	self._pageWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._pageHeight = self._ccbOwner.sheet_layout:getContentSize().height
	self._pageContent = CCNode:create()

	local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._pageWidth,self._pageHeight)
	local ccclippingNode = CCClippingNode:create()
	layerColor:setPositionX(self._ccbOwner.sheet_layout:getPositionX())
	layerColor:setPositionY(self._ccbOwner.sheet_layout:getPositionY())
	ccclippingNode:setStencil(layerColor)
	ccclippingNode:addChild(self._pageContent)

	self._ccbOwner.sheet:addChild(ccclippingNode)
	
	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self._ccbOwner.sheet,self._pageWidth, self._pageHeight, 0, -self._pageHeight, handler(self, self.onTouchEvent))

	self._isAnimRunning = false
	local options = self:getOptions()
	if options.tab ~= nil then
		self:_selectTab(options.tab)
	else
		self:_selectTab(QUIDialogMagicHerbBackpack.TAB_MAGICHERB)
	end
end

-- 处理各种touch event
function QUIDialogMagicHerbBackpack:onEvent(event)
	if event == nil or event.name == nil then
        return
    end
    if event.name == remote.items.EVENT_ITEMS_UPDATE then
    	if self._infoPanel ~= nil then
			local itemState = self._infoPanel:refreshInfo()
			if itemState == false then
				self._selectPosition = 0
			end
		end
		self:_selectTab(self.tab, true)
	end
end

function QUIDialogMagicHerbBackpack:onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		self:moveTo(event.distance.y, true)
  	elseif event.name == "began" then
  		self:_removeAction()
  		self._startY = event.y
  		self._pageY = self._pageContent:getPositionY()
    elseif event.name == "moved" then
    	local offsetY = self._pageY + event.y - self._startY
        if math.abs(event.y - self._startY) > 10 then
            self._isMove = true
        end
		self:moveTo(offsetY, false)
	elseif event.name == "ended" then
    	scheduler.performWithDelayGlobal(function ()
    		self._isMove = false
    		end,0)
    end
end

function QUIDialogMagicHerbBackpack:_removeAction()
	self:stopEnter()
	if self._actionHandler ~= nil then
		self._pageContent:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
end

function QUIDialogMagicHerbBackpack:moveTo(posY, isAnimation, isCheck)
	self._ccbOwner.sprite_scroll_cell:stopAllActions()
	self._ccbOwner.sprite_scroll_bar:stopAllActions()
	if 	self._totalHeight <= self._pageHeight or (math.abs(posY) < 1 and self._scrollShow == false) then
		self._ccbOwner.sprite_scroll_cell:setOpacity(0)
		self._ccbOwner.sprite_scroll_bar:setOpacity(0)
	else
		self._ccbOwner.sprite_scroll_cell:setOpacity(255)
		self._ccbOwner.sprite_scroll_bar:setOpacity(255)
		self._scrollShow = true
	end
	local contentY = self._pageContent:getPositionY()
	local targetY = posY
	if isAnimation == true or isCheck == true then
		if self._totalHeight <= self._pageHeight then
			targetY = 0
		elseif contentY + posY > self._totalHeight - self._pageHeight then
			targetY = self._totalHeight - self._pageHeight
		elseif contentY + posY < 0 then
			targetY = 0
		else
			targetY = contentY + posY
		end
	end
	if isAnimation == false then
		self._pageContent:setPositionY(targetY)
		self:onFrame()
		return 
	end

	self:_contentRunAction(0, targetY)
end

function QUIDialogMagicHerbBackpack:_contentRunAction(posX,posY)
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveTo:create(0.3, ccp(posX,posY)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
			self:_removeAction()
			self:onFrame()
			if self._totalHeight > self._pageHeight and self._scrollShow == true then
				self._ccbOwner.sprite_scroll_cell:runAction(CCFadeOut:create(0.3))
				self._ccbOwner.sprite_scroll_bar:runAction(CCFadeOut:create(0.3))
				self._scrollShow = false
			end
        end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._actionHandler = self._pageContent:runAction(ccsequence)
    self:startEnter()
end

function QUIDialogMagicHerbBackpack:_selectTab(tab, isRefresh)

	if tab ~= self.tab or isRefresh == true then
		self.tab = tab
		local options = self:getOptions()
		self:checkRedTips()
		options.tab = tab
		if self.tab == QUIDialogMagicHerbBackpack.TAB_ALL then
			self._ccbOwner.tab_tips1:setVisible(false)
			self._itemIds = remote.magicHerb:getAllItemIds()
		elseif self.tab == QUIDialogMagicHerbBackpack.TAB_CONSUM then
			self._tabManager:selected(self._ccbOwner.node_tab_consum)
			self._itemIds = remote.magicHerb:getConsumItemIds()
			self._ccbOwner.tab_tips2:setVisible(false)
		elseif tab == QUIDialogMagicHerbBackpack.TAB_MAGICHERB then
			self._tabManager:selected(self._ccbOwner.node_tab_MagicHerb)
			self._ccbOwner.tab_tips3:setVisible(false)
			self._itemIds = remote.magicHerb:getMagicHerbItemIds()
		end
		-- QPrintTable(self._itemIds)
		self._totalCount = #self._itemIds
		table.sort(self._itemIds, handler(self, self._sortItems))

		self:_initPage()
		
		if self._totalCount > 0 then
			local options = self:getOptions()
			local itemId = self._itemIds[1]
			if options.itemID ~= nil then
				itemId = options.itemID
				options.itemID = nil
			end
			if tonumber(itemId) then
				if remote.items:getItemsNumByID(itemId) == 0 then
					itemId = self._itemIds[1]
				end
				if tonumber(itemId) then
					self:itemClicked(nil, itemId)
				else
					local sid = itemId
					local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
					if magicHerbItemInfo then
						self:magicHerbItemClicked(nil, magicHerbItemInfo.itemId, sid)
					end
				end
			else
				local sid = itemId
				local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
				if magicHerbItemInfo then
					self:magicHerbItemClicked(nil, magicHerbItemInfo.itemId, sid)
				end
			end
			self:itemSelected(itemId)
			self:rollToSelectItem(itemId)
		end
	end
end

function QUIDialogMagicHerbBackpack:_sortItems(a, b)
	if tonumber(a) ~= tonumber(b) and (not tonumber(a) or not tonumber(b)) then
		-- 仙品往後排
		return tonumber(a) ~= nil
	else
		if tonumber(a) then
			-- 兩個都是物品
			local aItem = remote.items:getItemByID(a)
			local bItem = remote.items:getItemByID(b)
			-- 过期
			if aItem.overdue ~= bItem.overdue then
				return aItem.overdue
			end

			local aItemConfig = db:getItemByID(a)
			local bItemConfig = db:getItemByID(b)
			
			if aItemConfig.order ~= bItemConfig.order then
				return (aItemConfig.order or self._totalCount) < (bItemConfig.order or self._totalCount)
			end

			if aItemConfig.type ~= bItemConfig.type then
				return aItemConfig.type < bItemConfig.type
			end

			local aCount = remote.items:getItemsNumByID(a)
			local bCount = remote.items:getItemsNumByID(b)
			if aCount ~= bCount then
				return aCount > bCount
			end

			return a < b
		else
			-- 两个都是仙品
			local aMagicHerb = remote.magicHerb:getMaigcHerbItemBySid(a)
			local bMagicHerb = remote.magicHerb:getMaigcHerbItemBySid(b)
			local magicHerbConfigA = remote.magicHerb:getMagicHerbConfigByid(aMagicHerb.itemId) or {aptitude = 10 , id = aMagicHerb.itemId}
			local magicHerbConfigB = remote.magicHerb:getMagicHerbConfigByid(bMagicHerb.itemId) or {aptitude = 10 , id = bMagicHerb.itemId}


			if aMagicHerb.actorId ~= bMagicHerb.actorId then
				return (aMagicHerb.actorId  or 0) < (bMagicHerb.actorId or 0)
			end

			if magicHerbConfigA.aptitude ~= magicHerbConfigB.aptitude then
				return magicHerbConfigA.aptitude > magicHerbConfigB.aptitude
			elseif aMagicHerb.grade ~= bMagicHerb.grade then
				return aMagicHerb.grade > bMagicHerb.grade
			elseif aMagicHerb.level ~= bMagicHerb.level then
				return aMagicHerb.level > bMagicHerb.level
			elseif magicHerbConfigA.id ~= magicHerbConfigB.id then
				return magicHerbConfigA.id > magicHerbConfigB.id
			else
				return a < b
			end

			-- local aMagicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(a)
			-- local bMagicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(b)
			-- if aMagicHerbItemInfo.magicHerbInfo.actorId ~= bMagicHerbItemInfo.magicHerbInfo.actorId then
			-- 	return (aMagicHerbItemInfo.magicHerbInfo.actorId or 0) < (bMagicHerbItemInfo.magicHerbInfo.actorId or 0)
			-- end
			-- if aMagicHerbItemInfo.magicHerbConfig.aptitude ~= bMagicHerbItemInfo.magicHerbConfig.aptitude then
			-- 	return aMagicHerbItemInfo.magicHerbConfig.aptitude > bMagicHerbItemInfo.magicHerbConfig.aptitude
			-- elseif aMagicHerbItemInfo.magicHerbInfo.grade ~= bMagicHerbItemInfo.magicHerbInfo.grade then
			-- 	return aMagicHerbItemInfo.magicHerbInfo.grade > bMagicHerbItemInfo.magicHerbInfo.grade
			-- elseif aMagicHerbItemInfo.magicHerbInfo.level ~= bMagicHerbItemInfo.magicHerbInfo.level then
			-- 	return aMagicHerbItemInfo.magicHerbInfo.level > bMagicHerbItemInfo.magicHerbInfo.level
			-- elseif aMagicHerbItemInfo.magicHerbConfig.itemId ~= bMagicHerbItemInfo.magicHerbConfig.itemId then
			-- 	return aMagicHerbItemInfo.magicHerbConfig.itemId > bMagicHerbItemInfo.magicHerbConfig.itemId
			-- else
			-- 	return a < b
			-- end
		end
	end
end

function QUIDialogMagicHerbBackpack:rollToSelectItem(itemId)
	for _, v in ipairs(self._virtualBox) do
		if v.id == itemId then
			-- print("rollToSelectItem",self._pageContent:getPositionY(), v.posY)
			self:moveTo(self._pageContent:getPositionY() - v.posY - self._pageHeight/2, false, true)
			break
		end
	end
end

function QUIDialogMagicHerbBackpack:_initPage()
	--释放现有的BOX
	for index, value in pairs(self._virtualBox) do
		if value.box ~= nil then
			if tonumber(value.id) then
				local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(value.id)
				if itemConfig.type == ITEM_CONFIG_TYPE.MAGICHERB_WILD then
					-- 破碎仙品
					self:_setMagicHerbBox(value.box)
				else
					self:_setBox(value.box)
				end
			else
				self:_setMagicHerbBox(value.box)
			end
	    	value.box = nil
		end
	end
	self._virtualBox = {}
	self._ccbOwner.sprite_scroll_cell:setOpacity(0)
	self._ccbOwner.sprite_scroll_bar:setOpacity(0)
	local line = 4
	local posX = self._offsetX
	local posY = self._offsetY
	local cellWidth = 80
	local cellHeight = -80
	
	local index = 1
	local lastPosY = 0
	self._totalHeight = 0
	for i = 1, #self._itemIds, 1 do
		table.insert(self._virtualBox, {id = self._itemIds[i], posX = posX, posY = posY, index = i})
		lastPosY = posY
		if index%line == 0 then
			posX = self._offsetX
			posY = posY + cellHeight -14
		else
			posX = posX + cellWidth + 24
		end
		index = index + 1
	end
	self._totalHeight = math.abs(lastPosY + self._offsetY) + 50
	self._pageContent:setPosition(0, 0)
	self:onFrame()
end

function QUIDialogMagicHerbBackpack:onFrame()
	local contentY = self._pageContent:getPositionY()
	for index, value in pairs(self._virtualBox) do
		if value.posY + contentY < -self._pageHeight + self._offsetY or value.posY + contentY > -self._offsetY then
			if tonumber(value.id) then
				local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(value.id)
				if itemConfig.type == ITEM_CONFIG_TYPE.MAGICHERB_WILD then
					-- 破碎仙品
					self:_setMagicHerbBox(value.box)
				else
					self:_setBox(value.box)
				end
			else
				self:_setMagicHerbBox(value.box)
			end
	    	value.box = nil
		end
	end
	for index, value in pairs(self._virtualBox) do
		if value.posY + contentY >= -self._pageHeight + self._offsetY and value.posY + contentY <= -self._offsetY then
			if value.box == nil then
				if tonumber(value.id) then
					local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(value.id)
					if itemConfig.type == ITEM_CONFIG_TYPE.MAGICHERB_WILD then
						-- 破碎仙品
						value.box = self:getMagicHerbBox()
				    	value.box:setInPack(true)
				    	value.box:setItemByItemId(value.id)
				    	value.box:setIndex(value.index)
				    	value.box:hideName()
				    	value.box:setTouchEnabled(true)
					else
						value.box = self:getBox()
				    	value.box:resetAll()
				    	local count = remote.items:getItemsNumByID(value.id)
				    	value.box:setGoodsInfo(value.id, ITEM_TYPE.ITEM, count)
					    value.box:setIndex(value.index)
					    local itemInfo = remote.items:getItemByID(value.id)
					    value.box:setOverdue(itemInfo.overdue)
						local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(value.id)
						value.box:showRedTips(itemConfig.red_dot == 1)
					end
				else
					-- 仙品
					value.box = self:getMagicHerbBox()
			    	value.box:setInPack(true)
			    	value.box:setInfo(value.id)
			    	value.box:setIndex(value.index)
			    	value.box:hideName()
			    	value.box:setTouchEnabled(true)
				end
			    value.box:setPosition(value.posX, value.posY)
			    value.box:setVisible(true)
			end
		    if value.box ~= nil then
			    if value.box:getIndex() == self._selectPosition then
			    	value.box:selected(true)
			    else
			    	value.box:selected(false)
			    end
			end
		end
	end
	local cellHeight = self._cellH
	-- if self.tab == QUIDialogMagicHerbBackpack.TAB_MAGICHERB then
	-- 	cellHeight = cellHeight + 30
	-- end
	if 	self._totalHeight > self._pageHeight and contentY > 0 and contentY <= self._totalHeight - self._pageHeight then
		local cellY = self._scrollH  * (1 - math.abs(contentY) / math.abs(self._totalHeight - self._pageHeight)) + cellHeight/2
		self._ccbOwner.sprite_scroll_cell:setPositionY(cellY)
	end
end

--[[获取BOX从滑动容器中]]
function QUIDialogMagicHerbBackpack:getMagicHerbBox()
	local box = nil
	if self._boxCacheForMagicHerb ~= nil and #self._boxCacheForMagicHerb > 0 then
		box = self._boxCacheForMagicHerb[1]
		table.remove(self._boxCacheForMagicHerb, 1)
	else
		box = QUIWidgetMagicHerbBox.new()
		box:addEventListener(QUIWidgetMagicHerbBox.EVENT_CLICK, handler(self, self.itemClickHandler))
		self._pageContent:addChild(box)
		box:setVisible(false)
	end
	if box then
		box:setScale(0.9)
	end
	return box
end

--[[获取BOX从滑动容器中]]
function QUIDialogMagicHerbBackpack:getBox()
	local box = nil
	if self._boxCache ~= nil and #self._boxCache > 0 then
		box = self._boxCache[1]
		table.remove(self._boxCache,1)
	else
		box = QUIWidgetItemsBox.new()
		box:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self.itemClickHandler))
		self._pageContent:addChild(box)
		box:setVisible(false)
	end
	return box
end

--[[移除BOX从滑动容器中]]
function QUIDialogMagicHerbBackpack:_setBox(box)
	if box ~= nil then
		if self._boxCache == nil then
			self._boxCache = {}
		end
		table.insert(self._boxCache, box)
		box:setVisible(false)
	end
end

--[[移除BOX从滑动容器中]]
function QUIDialogMagicHerbBackpack:_setMagicHerbBox(box)
	if box ~= nil then
		if self._boxCacheForMagicHerb == nil then
			self._boxCacheForMagicHerb = {}
		end
		table.insert(self._boxCacheForMagicHerb, box)
		box:setVisible(false)
	end
end


--[[释放BOX到cache中]]
function QUIDialogMagicHerbBackpack:releaseBox()
	if self._boxCache ~= nil then
		self._boxCache = {}
	end
	if self._boxCacheForMagicHerb ~= nil then
		self._boxCacheForMagicHerb = {}
	end
	self._virtualBox = {}
end

function QUIDialogMagicHerbBackpack:itemClickHandler(event)
	if self._isMove == true then return end
	if event ~= nil then
		app.sound:playSound("common_item")
	end
	local id = self._itemIds[event.index]
	self._selectItemId = id
	if tonumber(id) then
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(id)
		if itemConfig.type == ITEM_CONFIG_TYPE.MAGICHERB_WILD then
			-- 破碎仙品
			self:itemClicked(event.index, event.itemId)
		else
			self:itemClicked(event.index, event.itemID)
		end
	else
		self:magicHerbItemClicked(event.index, event.itemId, event.sid)
	end
end

function QUIDialogMagicHerbBackpack:itemClicked(index, itemID)
	self._selectPosition = index
	local function _setItemId()
        self._infoPanel:setItemId(itemID)
    end

	if self._infoPanel == nil then
		self._infoPanel = QUIWidgetBackPackInfo.new()
		self._ccbOwner.node_info:addChild(self._infoPanel)
		self._infoPanel:setPositionX(-424)
		self._infoPanel:setPositionY(-15)
		self._infoPanel:setVisible(false)
		_setItemId()
		-- self._panelAction = self._infoPanel:runAction(CCMoveTo:create(0.3,ccp(0,0)))
	end
	if self._infoPanel:isVisible() == false then
		if self._panelAction ~= nil then
			self._infoPanel:stopAction(self._panelAction)		
			self._panelAction = nil
		end
		self._infoPanel:setVisible(true)
		self._infoPanel:setPositionX(-424)
		
        local arr = CCArray:create()
		arr:addObject(CCMoveTo:create(0.3,ccp(0,-15)))
        arr:addObject(CCCallFunc:create(_setItemId))
		self._panelAction = self._infoPanel:runAction(CCSequence:create(arr))
	else
		_setItemId()
	end
end

function QUIDialogMagicHerbBackpack:magicHerbItemClicked(index, itemID, sId)
	self._selectPosition = index
	local function _setMagicHerbItemId()
		-- print("self._infoPanel:setMagicHerbItemId(itemID, nil, sId)")
		if self._infoPanel then
			self._infoPanel:resetTouchRect()
        	self._infoPanel:setMagicHerbItemId(itemID, nil, sId)
    	end
    end
	if self._infoPanel == nil then
		self._infoPanel = QUIWidgetBackPackInfo.new()
		self._ccbOwner.node_info:addChild(self._infoPanel)
		self._infoPanel:setPositionX(-424)
		self._infoPanel:setPositionY(-15)
		self._infoPanel:setVisible(false)
		self._infoPanel:setMagicHerbItemId(itemID, nil, sId) -- 新创建时 直接刷新 防止出现显示错误
		-- self._panelAction = self._infoPanel:runAction(CCMoveTo:create(0.3,ccp(0,0)))
	end
	-- print("self._infoPanel:isVisible() = ", self._infoPanel:isVisible())
	if self._infoPanel:isVisible() == false then
		if self._panelAction ~= nil then
			self._infoPanel:stopAction(self._panelAction)		
			self._panelAction = nil
		end
		self._infoPanel:setVisible(true)
		self._infoPanel:setPositionX(-424)
		
		local arr = CCArray:create()
		arr:addObject(CCMoveTo:create(0.3,ccp(0,-15)))
        arr:addObject(CCCallFunc:create(_setMagicHerbItemId))
		self._panelAction = self._infoPanel:runAction(CCSequence:create(arr))
	else
		_setMagicHerbItemId()
	end
end

function QUIDialogMagicHerbBackpack:itemSelected(itemId)
	for index, value in pairs(self._virtualBox) do
	    if value.id == itemId then
			self._selectPosition = value.index
		end
	end
	self:onFrame()
end

function QUIDialogMagicHerbBackpack:checkRedTips()
	self._ccbOwner.tab_tips1:setVisible(false)
	self._ccbOwner.tab_tips2:setVisible(false)
	self._ccbOwner.tab_tips3:setVisible(false)
end

-- Tab 全部
function QUIDialogMagicHerbBackpack:_onTriggerTabAll(tag, menuItem)
	if self.tab ~= QUIDialogMagicHerbBackpack.TAB_ALL then
		app.sound:playSound("common_switch")
		self:hidePanel()
		self._selectItemId = nil
		self:_selectTab(QUIDialogMagicHerbBackpack.TAB_ALL)
	end
end

-- Tab 消耗
function QUIDialogMagicHerbBackpack:_onTriggerTabConsum(tag, menuItem)
	if self.tab ~= QUIDialogMagicHerbBackpack.TAB_CONSUM then
		app.sound:playSound("common_switch")
		self:hidePanel()
		self._selectItemId = nil
		self:_selectTab(QUIDialogMagicHerbBackpack.TAB_CONSUM)
	end
end

-- Tab 仙品
function QUIDialogMagicHerbBackpack:_onTriggerTabMagicHerb(tag, menuItem)
	if self.tab ~= QUIDialogMagicHerbBackpack.TAB_MAGICHERB then
		app.sound:playSound("common_switch")
		self:hidePanel()
		self._selectItemId = nil
		self:_selectTab(QUIDialogMagicHerbBackpack.TAB_MAGICHERB)
	end
end

function QUIDialogMagicHerbBackpack:hidePanel()
	self._selectPosition = 0
	if self._infoPanel ~= nil then
		self._infoPanel:setVisible(false)
	end
end

function QUIDialogMagicHerbBackpack:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogMagicHerbBackpack:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

-- 对话框退出
function QUIDialogMagicHerbBackpack:_onTriggerBack(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogMagicHerbBackpack:_onTriggerHome(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogMagicHerbBackpack
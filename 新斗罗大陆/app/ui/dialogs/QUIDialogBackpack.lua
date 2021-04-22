--
-- Author: wkwang
-- Date: 2014-10-28 10:08:39
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBackpack = class("QUIDialogBackpack", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetItemsBox =  import("..widgets.QUIWidgetItemsBox")
local QUIWidgetMagicHerbBox =  import("..widgets.QUIWidgetMagicHerbBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetBackPackInfo =  import("..widgets.QUIWidgetBackPackInfo")
local QRemote = import("...models.QRemote")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBagArrow =  import("..widgets.QUIWidgetBagArrow")

QUIDialogBackpack.TAB_ALL = "TAB_ALL"
QUIDialogBackpack.TAB_EQUIP = "TAB_EQUIP"
QUIDialogBackpack.TAB_SOUL = "TAB_SOUL"
QUIDialogBackpack.TAB_CONSUM = "TAB_CONSUM"

function QUIDialogBackpack:ctor(options)

	local ccbFile = "ccb/Dialog_Packsack.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerBack", 				callback = handler(self, QUIDialogBackpack._onTriggerBack)},
		-- {ccbCallbackName = "onTriggerHome", 				callback = handler(self, QUIDialogBackpack._onTriggerHome)},
		{ccbCallbackName = "onTriggerTabAll", 				callback = handler(self, QUIDialogBackpack._onTriggerTabAll)},
		{ccbCallbackName = "onTriggerTabEquip", 				callback = handler(self, QUIDialogBackpack._onTriggerTabEquip)},
		{ccbCallbackName = "onTriggerTabSoul", 				callback = handler(self, QUIDialogBackpack._onTriggerTabSoul)},
		{ccbCallbackName = "onTriggerTabConsum", 				callback = handler(self, QUIDialogBackpack._onTriggerTabConsum)},
	}
	QUIDialogBackpack.super.ctor(self,ccbFile,callBacks,options)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()

    ui.tabButton(self._ccbOwner.node_tab_all, "全部")
    ui.tabButton(self._ccbOwner.node_tab_consum, "消耗")
    ui.tabButton(self._ccbOwner.node_tab_soul, "碎片")
    ui.tabButton(self._ccbOwner.node_tab_equip, "材料")
	self._tabManager = ui.tabManager({self._ccbOwner.node_tab_all, self._ccbOwner.node_tab_consum, self._ccbOwner.node_tab_soul, self._ccbOwner.node_tab_equip})

	self._offsetY = -52
	self._offsetX = 62
	self._scrollShow = false
	self._totalCount = 10000
	self._virtualBox = {}

	self._cellH = self._ccbOwner.sprite_scroll_cell:getContentSize().height
	self._scrollH = self._ccbOwner.sprite_scroll_bar:getContentSize().height - self._cellH

	-- 初始化中间魂师页面滑动框
	self:_initPageSwipe()
	self:addArrowWidget(options.packs)
end

function QUIDialogBackpack:startEnter()
	self:stopEnter()
    self._onFrameHandler = scheduler.scheduleGlobal(handler(self, self.onFrame), 0)
end


function QUIDialogBackpack:stopEnter()
    if self._onFrameHandler ~= nil then
    	scheduler.unscheduleGlobal(self._onFrameHandler)
    	self._onFrameHandler = nil
    end
end

function QUIDialogBackpack:viewDidAppear()
	QUIDialogBackpack.super.viewDidAppear(self)
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

    self._remoteProxy = cc.EventProxy.new(remote.items)
    self._remoteProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))
	self:addBackEvent()
end

function QUIDialogBackpack:viewWillDisappear()
  	QUIDialogBackpack.super.viewWillDisappear(self)
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
    self._remoteProxy:removeAllEventListeners()
	self:_removeAction()
	self:releaseBox()
	self:removeBackEvent()	
end


function QUIDialogBackpack:addArrowWidget(packs)
	local arr_node = QUIWidgetBagArrow.new({packs=packs})
	arr_node:setBagTag(1)
	self._ccbOwner.node_add_arr:addChild(arr_node)
end



-- 初始化中间的魂师选择框 swipe工能
function QUIDialogBackpack:_initPageSwipe()
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
	print("options.tab=",options.tab)
	if options.tab ~= nil then
		self:_selectTab(options.tab)
	else
		self:_selectTab(QUIDialogBackpack.TAB_ALL)
	end
end

-- 处理各种touch event
function QUIDialogBackpack:onEvent(event)
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

function QUIDialogBackpack:onTouchEvent(event)
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

function QUIDialogBackpack:_removeAction()
	self:stopEnter()
	if self._actionHandler ~= nil then
		self._pageContent:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
end

function QUIDialogBackpack:moveTo(posY, isAnimation, isCheck)
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

function QUIDialogBackpack:_contentRunAction(posX,posY)
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

function QUIDialogBackpack:_selectTab(tab, isRefresh)
	if tab ~= self.tab or isRefresh == true then
		self.tab = tab
		local options = self:getOptions()
		self:checkRedTips()
		options.tab = tab
		if tab == QUIDialogBackpack.TAB_ALL then
			self._tabManager:selected(self._ccbOwner.node_tab_all)
			self._ccbOwner.tab_tips1:setVisible(false)
			self._items = remote.items:getItemsByCategory(ITEM_CONFIG_CATEGORY.MATERIAL, ITEM_CONFIG_CATEGORY.SOUL, ITEM_CONFIG_CATEGORY.CONSUM, 
				ITEM_CONFIG_CATEGORY.MOUNT_PIECE, ITEM_CONFIG_CATEGORY.MOUNT_MATERIAL)
		elseif tab == QUIDialogBackpack.TAB_EQUIP then
			self._tabManager:selected(self._ccbOwner.node_tab_equip)
			self._ccbOwner.tab_tips4:setVisible(false)
			self._items = remote.items:getItemsByCategory(ITEM_CONFIG_CATEGORY.MATERIAL, ITEM_CONFIG_CATEGORY.MOUNT_MATERIAL)
		elseif tab == QUIDialogBackpack.TAB_SOUL then
			self._tabManager:selected(self._ccbOwner.node_tab_soul)
			self._ccbOwner.tab_tips3:setVisible(false)
			self._items = remote.items:getItemsByCategory(ITEM_CONFIG_CATEGORY.SOUL, ITEM_CONFIG_CATEGORY.MOUNT_PIECE)
		elseif tab == QUIDialogBackpack.TAB_CONSUM then
			self._tabManager:selected(self._ccbOwner.node_tab_consum)
			self._ccbOwner.tab_tips2:setVisible(false)
			self._items = remote.items:getItemsByCategory(ITEM_CONFIG_CATEGORY.CONSUM)
		end

		self._totalCount = #self._items
		table.sort(self._items, handler(self, self.sortItems))

		self:_initPage()

		if self._totalCount > 0 then
			local options = self:getOptions()
			local itemId = options.itemID == nil and self._items[1].type or options.itemID
			if remote.items:getItemsNumByID(itemId) == 0 then
				itemId = self._items[1].type
			end
			self:itemClicked(nil, itemId)
			self:itemSelected(itemId)
			self:rollToSelectItem(itemId)
		end
	end
end

function QUIDialogBackpack:sortItems(a, b)
	-- 过期
	if a.overdue ~= b.overdue then
		return a.overdue
	end

	local itemInfo1 = QStaticDatabase:sharedDatabase():getItemByID(a.type)
	local itemInfo2 = QStaticDatabase:sharedDatabase():getItemByID(b.type)
	
	if itemInfo1.order ~= itemInfo2.order then
		return (itemInfo1.order or self._totalCount) < (itemInfo2.order or self._totalCount)
	end

	if itemInfo1.category ~= nil and itemInfo2.category ~= nil and itemInfo1.category ~= itemInfo2.category then
		return itemInfo1.category > itemInfo2.category
	elseif a.type ~= b.type then
		return a.type < b.type
	end

	return a.count > b.count
end

function QUIDialogBackpack:rollToSelectItem(itemId)
	for _,v in ipairs(self._virtualBox) do
		if v.info.type == itemId then
			-- print("rollToSelectItem",self._pageContent:getPositionY(), v.posY)
			self:moveTo(self._pageContent:getPositionY() - v.posY - self._pageHeight/2, false, true)
			break
		end
	end
end

function QUIDialogBackpack:_initPage()
	--释放现有的BOX
	for index,value in pairs(self._virtualBox) do
		if value.icon ~= nil then
			self:setBox(value.icon)
	    	value.icon = nil
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
	for i = 1, #self._items, 1 do
		table.insert(self._virtualBox, {info = self._items[i], posX = posX, posY = posY, index = i})
		lastPosY = posY
		if index%line == 0 then
			posX = self._offsetX
			posY = posY + cellHeight - 14
		else
			posX = posX + cellWidth + 24
		end
		index = index + 1
	end
	self._totalHeight = math.abs(lastPosY + self._offsetY) + 50
	self._pageContent:setPosition(0, 0)
	self:onFrame()
end

function QUIDialogBackpack:onFrame()
	local contentY = self._pageContent:getPositionY()
	for index,value in pairs(self._virtualBox) do
		if value.posY + contentY < -self._pageHeight + self._offsetY or value.posY + contentY > -self._offsetY then
			self:setBox(value.icon)
	    	value.icon = nil
		end
	end
	for index,value in pairs(self._virtualBox) do
		if value.posY + contentY >= -self._pageHeight + self._offsetY and value.posY + contentY <= -self._offsetY then
			if value.icon == nil then
		    	value.icon = self:getBox()
		    	value.icon:resetAll()
		    	value.icon:setGoodsInfo(value.info.type, ITEM_TYPE.ITEM, value.info.count,nil,true)
			    value.icon:setIndex(value.index)
			    value.icon:setOverdue(value.info.overdue)
			    
				local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.info.type)

				value.icon:showRedTips(itemInfo.red_dot == 1)

			    value.icon:setPosition(value.posX, value.posY)
			    value.icon:setVisible(true)
			end
		    if value.icon ~= nil then
			    if value.icon:getIndex() == self._selectPosition then
			    	value.icon:selected(true)
			    else
			    	value.icon:selected(false)
			    end
			end
		end
	end
	local cellHeight = self._cellH
	if 	self._totalHeight > self._pageHeight and contentY > 0 and contentY <= self._totalHeight - self._pageHeight then
		local cellY = self._scrollH  * (1 - math.abs(contentY) / math.abs(self._totalHeight - self._pageHeight)) + cellHeight/2
		self._ccbOwner.sprite_scroll_cell:setPositionY(cellY)
	end
end

--[[获取BOX从滑动容器中]]
function QUIDialogBackpack:getMagicHerbBox()
	local box = nil
	if self._boxCache ~= nil and #self._boxCache > 0 then
		box = self._boxCache[1]
		table.remove(self._boxCache,1)
	else
		box = QUIWidgetMagicHerbBox.new()
		box:addEventListener(QUIWidgetMagicHerbBox.EVENT_CLICK, handler(self, self.itemClickHandler))
		self._pageContent:addChild(box)
		box:setVisible(false)
	end
	return box
end

--[[获取BOX从滑动容器中]]
function QUIDialogBackpack:getBox()
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
function QUIDialogBackpack:setBox(box)
	if box ~= nil then
		if self._boxCache == nil then
			self._boxCache = {}
		end
		table.insert(self._boxCache, box)
		box:setVisible(false)
	end
end

--[[释放BOX到cache中]]
function QUIDialogBackpack:releaseBox()
	if self._boxCache ~= nil then
		self._boxCache = {}
	end

	self._virtualBox = {}
end

function QUIDialogBackpack:itemClickHandler(event)
	if self._isMove == true then return end
	if event ~= nil then
		app.sound:playSound("common_item")
	end
	self:itemClicked(event.index, event.itemID)
end

function QUIDialogBackpack:itemClicked(index, itemID)
	self._selectPosition = index
	if self._infoPanel == nil then
		self._infoPanel = QUIWidgetBackPackInfo.new()
		self._infoPanel:setPositionX(-424)
		self._infoPanel:setPositionY(-15)
		self._ccbOwner.node_info:addChild(self._infoPanel)
		self._infoPanel:runAction(CCMoveTo:create(0.3,ccp(0,-15)))
	end
	if self._infoPanel:isVisible() == false then
		if self._panelAction ~= nil then
			self._infoPanel:stopAction(self._panelAction)		
			self._panelAction = nil
		end
		self._infoPanel:setVisible(true)
		self._infoPanel:setPositionX(-424)
		self._panelAction = self._infoPanel:runAction(CCMoveTo:create(0.3,ccp(0,-15)))
	end
	self._infoPanel:setItemId(itemID)
	local options = self:getOptions()
	options.itemID = itemID
end

function QUIDialogBackpack:itemSelected(itemId)
	for index,value in pairs(self._virtualBox) do
	    if value.info.type == itemId then
			self._selectPosition = value.index
		end
	end
	self:onFrame()
end

function QUIDialogBackpack:checkRedTips()
	self._ccbOwner.tab_tips1:setVisible(remote.items:checkItemRedTipsByCategory(ITEM_CONFIG_CATEGORY.MATERIAL, ITEM_CONFIG_CATEGORY.SOUL, ITEM_CONFIG_CATEGORY.CONSUM))
	self._ccbOwner.tab_tips2:setVisible(remote.items:checkItemRedTipsByCategory(ITEM_CONFIG_CATEGORY.CONSUM))
	self._ccbOwner.tab_tips3:setVisible(remote.items:checkItemRedTipsByCategory(ITEM_CONFIG_CATEGORY.SOUL))
	self._ccbOwner.tab_tips4:setVisible(remote.items:checkItemRedTipsByCategory(ITEM_CONFIG_CATEGORY.MATERIAL))
end

-- Tab 全部
function QUIDialogBackpack:_onTriggerTabAll(tag, menuItem)
	if self.tab ~= QUIDialogBackpack.TAB_ALL then
		app.sound:playSound("common_switch")
		self:hidePanel()
		self:_selectTab(QUIDialogBackpack.TAB_ALL)
	end
end

-- Tab 全部
function QUIDialogBackpack:_onTriggerTabEquip(tag, menuItem)
	if self.tab ~= QUIDialogBackpack.TAB_EQUIP then
		app.sound:playSound("common_switch")
		self:hidePanel()
		self:_selectTab(QUIDialogBackpack.TAB_EQUIP)
	end
end
-- Tab 全部
function QUIDialogBackpack:_onTriggerTabSoul(tag, menuItem)
	if self.tab ~= QUIDialogBackpack.TAB_SOUL then
		app.sound:playSound("common_switch")
		self:hidePanel()
		self:_selectTab(QUIDialogBackpack.TAB_SOUL)
	end
end
-- Tab 全部
function QUIDialogBackpack:_onTriggerTabConsum(tag, menuItem)
	if self.tab ~= QUIDialogBackpack.TAB_CONSUM then
		app.sound:playSound("common_switch")
		self:hidePanel()
		self:_selectTab(QUIDialogBackpack.TAB_CONSUM)
	end
end

function QUIDialogBackpack:hidePanel()
	self._selectPosition = 0
	if self._infoPanel ~= nil then
		self._infoPanel:setVisible(false)
	end
end

function QUIDialogBackpack:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogBackpack:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

-- 对话框退出
function QUIDialogBackpack:_onTriggerBack(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogBackpack:_onTriggerHome(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogBackpack
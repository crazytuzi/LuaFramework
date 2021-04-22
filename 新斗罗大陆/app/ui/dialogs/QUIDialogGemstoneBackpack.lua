local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemstoneBackpack = class("QUIDialogGemstoneBackpack", QUIDialog)

local QListView = import("...views.QListView")
local QUIWidgetGemStonePieceBox = import("..widgets.QUIWidgetGemStonePieceBox")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetGemStoneBackPackInfo = import("..widgets.QUIWidgetGemStoneBackPackInfo")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBackPackInfo =  import("..widgets.QUIWidgetBackPackInfo")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetSparBackPackInfo = import("..widgets.spar.QUIWidgetSparBackPackInfo")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QUIWidgetSparPieceBox = import("..widgets.QUIWidgetSparPieceBox")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetBagArrow =  import("..widgets.QUIWidgetBagArrow")

QUIDialogGemstoneBackpack.TAB_GEMSTONE = "TAB_GEMSTONE"
QUIDialogGemstoneBackpack.TAB_PIECE = "TAB_PIECE"
QUIDialogGemstoneBackpack.TAB_SPAR = "TAB_SPAR"
QUIDialogGemstoneBackpack.TAB_SPAR_PIECE = "TAB_SPAR_PIECE"
QUIDialogGemstoneBackpack.TAB_MATERIAL = "TAB_MATERIAL"

function QUIDialogGemstoneBackpack:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_Packsack.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTabGemstone",	callback = handler(self, QUIDialogGemstoneBackpack._onTriggerTabGemstone)},
		{ccbCallbackName = "onTriggerTabPiece",	 callback = handler(self, QUIDialogGemstoneBackpack._onTriggerTabPiece)},
		{ccbCallbackName = "onTriggerTabMatrial",	callback = handler(self, QUIDialogGemstoneBackpack._onTriggerTabMatrial)},
		{ccbCallbackName = "onTriggerTabSpar",	 callback = handler(self, QUIDialogGemstoneBackpack._onTriggerTabSpar)},
		{ccbCallbackName = "onTriggerTabSparPiece",	callback = handler(self, QUIDialogGemstoneBackpack._onTriggerTabSparPiece)},
		{ccbCallbackName = "onTriggerClickShop",	callback = handler(self, QUIDialogGemstoneBackpack._onTirggerClickShop)},
		{ccbCallbackName = "onTriggerClickSparShop",	callback = handler(self, QUIDialogGemstoneBackpack._onTriggerClickSparShop)},
	}
	QUIDialogGemstoneBackpack.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	page:setScalingVisible(true)
    page.topBar:showWithMainPage()

    ui.tabButton(self._ccbOwner.btn_gemstone, "魂骨")
    ui.tabButton(self._ccbOwner.btn_piece, "魂骨".."\n碎片")
    ui.tabButton(self._ccbOwner.btn_spar, "外附".."\n魂骨")
    ui.tabButton(self._ccbOwner.btn_spar_piece, "外骨".."\n碎片")
    ui.tabButton(self._ccbOwner.btn_matrial, "消耗")
	self._tabManager = ui.tabManager({self._ccbOwner.btn_gemstone, self._ccbOwner.btn_piece, self._ccbOwner.btn_spar, self._ccbOwner.btn_spar_piece,self._ccbOwner.btn_matrial})


	self._itemInfo = {}

	self._ccbOwner.sprite_scroll_cell:setVisible(false)
	self._ccbOwner.sprite_scroll_bar:setVisible(false)
	
	self._packs = options.packs
end

function QUIDialogGemstoneBackpack:addArrowWidget(packs)
	local arr_node = QUIWidgetBagArrow.new({packs=packs})
	arr_node:setBagTag(2)
	self._ccbOwner.node_add_arr:addChild(arr_node)
end

function QUIDialogGemstoneBackpack:viewDidAppear()
    QUIDialogGemstoneBackpack.super.viewDidAppear(self)

    self._remoteProxy = cc.EventProxy.new(remote.items)
    self._remoteProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

	self._userProxy = cc.EventProxy.new(remote.user)
	self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))

    self:initListView()

    self:checkSparButton()

	local defaultTab = QUIDialogGemstoneBackpack.TAB_GEMSTONE
	if self._pieceTips == true then
		defaultTab = QUIDialogGemstoneBackpack.TAB_PIECE
	elseif self._materialTips == true then
		defaultTab = QUIDialogGemstoneBackpack.TAB_MATERIAL
	elseif self._sparPieceTips == true then
		defaultTab = QUIDialogGemstoneBackpack.TAB_SPAR_PIECE
	end
    local tab = defaultTab
    local selectPosition = 1
    self._selectItem = nil
	if self:getOptions() then
		tab = self:getOptions().tab or defaultTab
		self._selectItem = self:getOptions().selectItem or nil
		selectPosition = self:getOptions().selectPosition or 1
	end

	self:selectTab(tab, false, selectPosition)

    self:addBackEvent(true)
	self:addArrowWidget(self._packs)
end

function QUIDialogGemstoneBackpack:viewWillDisappear()
    QUIDialogGemstoneBackpack.super.viewWillDisappear(self)

	self._userProxy:removeAllEventListeners()
    self._remoteProxy:removeAllEventListeners()

	if self._timeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
    self:removeBackEvent()
end

function QUIDialogGemstoneBackpack:initListView()
	local totalNumber = #self._itemInfo
	local spaceX, spaceY, curOriginOffset = 24, 14, 10
	if self._selectTab == QUIDialogGemstoneBackpack.TAB_GEMSTONE then
		spaceX, spaceY, curOriginOffset = 10, 14, 10
	elseif self._selectTab == QUIDialogGemstoneBackpack.TAB_SPAR then 
		spaceX, spaceY, curOriginOffset = 8, 50, 10
	else
		spaceX, spaceY, curOriginOffset = 24, 14, 10
	end
	
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = false,
	        totalNumber = totalNumber,
	        enableShadow = false,
	        multiItems = 4,
	        spaceY = spaceY,
	        spaceX = spaceX,
	        curOriginOffset = curOriginOffset,
	        curOffset = 25,
	        cacheCond = 2,
	        headIndex = self._selectPosition
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = totalNumber, spaceX = spaceX, spaceY = spaceY, curOriginOffset = curOriginOffset, headIndex = self._selectPosition})
	end
end

function QUIDialogGemstoneBackpack:renderFunHandler(list, index, info)
    local isCacheNode = true
    local data = self._itemInfo[index]
    local backpackType = data.param.backpackType
    local item = list:getItemFromCache(backpackType)

    if not item then
    	item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end
    info.tag = backpackType
    info.item = item
    self:setItemInfo(item, data.param, backpackType)
    info.size = item._ccbOwner.parentNode:getContentSize()
    item:setClickBtnSize(info.size)
	item._itemBox:initGLLayer()

	list:registerBtnHandler(index, "btn_click", "_onTriggerClick")

	return isCacheNode
end

function QUIDialogGemstoneBackpack:setItemInfo( item, itemData, backpackType)
	if not item._itemBox then
		local itemBox
    	if backpackType == "gemstone" then
    		itemBox = QUIWidgetGemstonesBox.new()
    	elseif backpackType == "gemstonePiece" then
    		itemBox = QUIWidgetGemStonePieceBox.new()
    	elseif backpackType == "spar" then
    		itemBox = QUIWidgetSparBox.new()
    		itemBox:setScale(0.9)
    	elseif backpackType == "sparPiece" then
    		itemBox = QUIWidgetSparPieceBox.new()
    	elseif backpackType == "material" then
    		itemBox = QUIWidgetItemsBox.new()
    	end
		itemBox:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._clickEvent))
    	item._itemBox = itemBox
    	local contentSize = itemBox:getContentSize()
    	local offsetX = 8
    	if backpackType == "spar" then
    		offsetX = 3
    	end
        if backpackType == "gemstone" or backpackType == "spar" then 
        	item:setClickCallBack(function() 
				item._itemBox:_onTriggerTouch(CCControlEventTouchUpInside)
			end)
        else
        	offsetX = 20
			item:setClickCallBack(function() 
				item._itemBox:_onTriggerClick()
			end)
        end

        item._itemBox:setPosition(contentSize.width/2 + offsetX, contentSize.height/2)
        item._ccbOwner.parentNode:addChild(item._itemBox)
        item._ccbOwner.parentNode:setContentSize(contentSize)
        item:setClickBtnPosition(offsetX, 0)
	end
	if self._selectPosition then
		item._itemBox:setSelectPosition(self._selectPosition)
	end
	item._itemBox:setInfo(itemData)
end

-- 处理各种touch event
function QUIDialogGemstoneBackpack:onEvent(event)
	if event == nil or event.name == nil then
        return
    end
    if event.name == remote.items.EVENT_ITEMS_UPDATE then
    	if self._selectTab ~= QUIDialogGemstoneBackpack.TAB_MATERIAL then return end

    	if self._materialPanel ~= nil then
			local itemState = self._materialPanel:refreshInfo()
			if itemState == false then
				self._selectPosition = 1
			end
		end
		self:checkSparButton()
		self:selectTab(self._selectTab, false, self._selectPosition)
		-- self:checkRedTip()
	elseif event.name == remote.user.EVENT_USER_PROP_CHANGE then
		self:selectTab(self._selectTab, false, self._selectPosition)
		-- self:checkRedTip()
	end
end

function QUIDialogGemstoneBackpack:checkSparButton()
	if app.unlock:checkLock("UNLOCK_ZHUBAO", false) == false and remote.spar:checkSparBackPackItemNum() == false then
		self._ccbOwner.node_btn_spar:setVisible(false)
		self._ccbOwner.node_btn_spar_piece:setVisible(false)
		self._ccbOwner.node_btn_matrial:setPositionY(self._ccbOwner.node_btn_spar:getPositionY())
	end
end

function QUIDialogGemstoneBackpack:selectTab(tab, hidePanel, selectPosition)
	self._selectTab = tab
	self:getOptions().tab = tab
	self._itemInfo = {}
	self:checkRedTip()
	if self._contentListView then
		self._contentListView:clear()
	end
	
	self:setButtonStated()
	self._ccbOwner.node_no:setVisible(false)

	if hidePanel == nil then hidePanel = true end
	if hidePanel then
		self:hidePanel()
	end

	self._selectPosition = 1
	if selectPosition ~= nil then
		self._selectPosition = selectPosition
	end
	if self._selectItem ~= nil then
		self._selectPosition = nil
	end

	if self._selectTab == QUIDialogGemstoneBackpack.TAB_GEMSTONE then
		self._tabManager:selected(self._ccbOwner.btn_gemstone)
		self:setGemstones()
	elseif self._selectTab == QUIDialogGemstoneBackpack.TAB_PIECE then 
		self._tabManager:selected(self._ccbOwner.btn_piece)
		self._ccbOwner.piece_tips:setVisible(false)
		self:setPiece()
	elseif self._selectTab == QUIDialogGemstoneBackpack.TAB_SPAR then 
		self._tabManager:selected(self._ccbOwner.btn_spar)
		self._ccbOwner.sp_spar_tips:setVisible(false)
		self:setSparInfo()
	elseif self._selectTab == QUIDialogGemstoneBackpack.TAB_SPAR_PIECE then 
		self._tabManager:selected(self._ccbOwner.btn_spar_piece)
		self._ccbOwner.sp_spar_piece_tips:setVisible(false)
		self:setSparPieceInfo()
	elseif self._selectTab == QUIDialogGemstoneBackpack.TAB_MATERIAL then 
		self._tabManager:selected(self._ccbOwner.btn_matrial)
		self._ccbOwner.material_tips:setVisible(false)
		self:setMaterial()
	end

	for i = 1, #self._itemInfo do
		if self._selectItem and self._itemInfo[i].itemId == self._selectItem then
			self._selectPosition = i
			self._selectItem = nil
			self:getOptions().selectItem = nil
			break
		end
	end
	if q.isEmpty(self._itemInfo) == false and self._selectPosition ~= nil and self._selectPosition > 0 and self._itemInfo[self._selectPosition] then
		self:itemClicked(self._selectPosition, self._itemInfo[self._selectPosition].itemId)
	end
end 

function QUIDialogGemstoneBackpack:setButtonStated()
	local gemstone = self._selectTab == QUIDialogGemstoneBackpack.TAB_GEMSTONE
	self._ccbOwner.btn_gemstone:setHighlighted(gemstone)
	self._ccbOwner.btn_gemstone:setEnabled(not gemstone)

	local gemstonePiece = self._selectTab == QUIDialogGemstoneBackpack.TAB_PIECE
	self._ccbOwner.btn_piece:setHighlighted(gemstonePiece)
	self._ccbOwner.btn_piece:setEnabled(not gemstonePiece)

	local spar = self._selectTab == QUIDialogGemstoneBackpack.TAB_SPAR
	self._ccbOwner.btn_spar:setHighlighted(spar)
	self._ccbOwner.btn_spar:setEnabled(not spar)

	local sparPiece = self._selectTab == QUIDialogGemstoneBackpack.TAB_SPAR_PIECE
	self._ccbOwner.btn_spar_piece:setHighlighted(sparPiece)
	self._ccbOwner.btn_spar_piece:setEnabled(not sparPiece)

	local material = self._selectTab == QUIDialogGemstoneBackpack.TAB_MATERIAL
	self._ccbOwner.btn_matrial:setHighlighted(material)
	self._ccbOwner.btn_matrial:setEnabled(not material)

end

function QUIDialogGemstoneBackpack:setGemstones() 
	local gemstoneInfo = remote.gemstone:getGemstones()

	gemstoneInfo = self:filterGemstone(gemstoneInfo)
	if gemstoneInfo == nil or next(gemstoneInfo) == nil then
		self._ccbOwner.btn_shop:setVisible(true)
		self._ccbOwner.tf_shop_go:setString("魂师大人，当前没有魂骨，去魂骨商店看看吧～")
		self._ccbOwner.btn_spar_shop:setVisible(false)
		self._ccbOwner.node_no:setVisible(true)
		return 
	else
		self._ccbOwner.node_no:setVisible(false)
	end

	table.sort(gemstoneInfo, function(a, b)
			if a.actorId ~= nil and  b.actorId == nil then
				return false
			elseif a.actorId == nil and  b.actorId ~= nil then
				return true
			elseif a.actorId ~= nil and b.actorId ~= nil then
				if a.gemstoneQuality ~= b.gemstoneQuality then
					return a.gemstoneQuality > b.gemstoneQuality
				elseif a.level ~= b.level then
					return a.level > b.level
				elseif a.gemstoneType ~= b.gemstoneType then
					return a.gemstoneType < b.gemstoneType
				else
					return a.actorId < b.actorId
				end
			elseif a.actorId == nil and b.actorId == nil then
				if a.gemstoneQuality ~= b.gemstoneQuality then
					return a.gemstoneQuality > b.gemstoneQuality
				elseif a.level ~= b.level then
					return a.level > b.level
				elseif a.gemstoneType ~= b.gemstoneType then
					return a.gemstoneType < b.gemstoneType
				else
					return a.itemId < b.itemId
				end
			else
				return a.itemId < b.itemId
			end
		end)
	local itemInfos = {}
	for i = 1, #gemstoneInfo do
		local userState = false
		if gemstoneInfo[i].actorId ~= nil then
			userState = true
		end
		if itemInfos[i] == nil then
			itemInfos[i] = {}
		end
		itemInfos[i].param = {gemstoneInfo = gemstoneInfo[i], index = i, userState = userState, backpackType = "gemstone"}
		itemInfos[i].itemId = gemstoneInfo[i].itemId
	end

	self._itemInfo = itemInfos
	self:initListView()
end

function QUIDialogGemstoneBackpack:setPiece()
	self._pieceItem = {}
	local pieceInfo = QStaticDatabase:sharedDatabase():getItemsByCategory(ITEM_CONFIG_CATEGORY.GEMSTONE_PIECE)
	pieceInfo = self:filterGemstone(pieceInfo)
	
	table.sort(pieceInfo, function(a, b)
			local count1 = remote.items:getItemsNumByID(a.id)
			local count2 = remote.items:getItemsNumByID(b.id)
			if count1 ~= count2 then
				return count1 > count2
			elseif a.gemstone_quality ~= b.gemstone_quality then
				return a.gemstone_quality > b.gemstone_quality
			else
				return a.id < b.id
			end
		end)

	local itemInfos = {}
	for i = 1, #pieceInfo do 
		local count = remote.items:getItemsNumByID(pieceInfo[i].id) or 0
		local stoneInfo = remote.gemstone:getStoneCraftInfoByPieceId(pieceInfo[i].id) or {}
		local graryState = count <= 0
		local redTips = count >= (stoneInfo.component_num_1 or 0) and remote.user.money > stoneInfo.price

		if itemInfos[i] == nil then
			itemInfos[i] = {}
		end		
		itemInfos[i].param = {pieceInfo = pieceInfo[i], index = i, graryState = graryState, redTips = redTips, count = count, backpackType = "gemstonePiece"}
		itemInfos[i].itemId = pieceInfo[i].id
	end

	self._itemInfo = itemInfos
	self:initListView()
end

function QUIDialogGemstoneBackpack:setSparInfo()
	local sparInfo = {}

	local data = remote.spar:getSparsByType()

	if data == nil or next(data) == nil then
		self._ccbOwner.btn_shop:setVisible(false)
		self._ccbOwner.tf_shop_go:setString("魂师大人，当前没有外附魂骨，去地狱商店看看吧～")
		self._ccbOwner.btn_spar_shop:setVisible(true)
		self._ccbOwner.node_no:setVisible(true)
		return 
	else
		self._ccbOwner.node_no:setVisible(false)
	end

	-- data = self:filterRepeatSpar(data)
	for _, value in pairs(data) do
		-- sparInfo[#sparInfo+1] = value
		--排序属性赋值
		local itemInfo = db:getItemByID(value.itemId)

		if itemInfo then
			if value.itemId == 2020001 or value.itemId == 2030001 then
				value.sortValue = 99
			elseif itemInfo.gemstone_quality == APTITUDE.SS then
				value.sortValue = 2
			else
				value.sortValue = 1
			end
		else
			value.sortValue = 0
		end

		table.insert(sparInfo,value)
	end
	
	table.sort(sparInfo, function(a, b)
			if a.actorId > 0 and b.actorId == 0 then
				return false
			elseif a.actorId == 0 and b.actorId > 0 then
				return true
			else
				if a.sortValue ~= b.sortValue then
					return a.sortValue > b.sortValue
				elseif a.grade ~= b.grade then
					return a.grade > b.grade
				elseif a.level ~= b.level then
					return a.level > b.level
				elseif a.itemId ~= b.itemId then
					return a.itemId > b.itemId
				else
					return false
				end
				return false
			end
		end)

	local itemInfos = {}
	for i = 1, #sparInfo do 
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(sparInfo[i].itemId)
		local redTips = itemInfo.red_dot == 1
		local userState = false
		if sparInfo[i].actorId ~= nil and sparInfo[i].actorId ~= 0 then
			userState = true
		end
		if itemInfos[i] == nil then
			itemInfos[i] = {}
		end		
		itemInfos[i].param = {sparInfo = sparInfo[i], index = i, redTips = redTips, userState = userState, content = "拥有："..sparInfo[i].count, backpackType = "spar"}
		itemInfos[i].itemId = sparInfo[i].itemId
	end

	self._itemInfo = itemInfos
	self:initListView()
end

function QUIDialogGemstoneBackpack:setSparPieceInfo()
	local sparPieceInfo = QStaticDatabase:sharedDatabase():getItemsByCategory(ITEM_CONFIG_CATEGORY.SPAR_PIECE)
	
	table.sort(sparPieceInfo, function(a, b)
			local count1 = remote.items:getItemsNumByID(a.id)
			local count2 = remote.items:getItemsNumByID(b.id)
			if count1 ~= count2 then
				return count1 > count2
			elseif a.gemstone_quality ~= b.gemstone_quality then
				return a.gemstone_quality > b.gemstone_quality
			else
				return a.id < b.id
			end
		end)
	local itemInfos = {}
	for i = 1, #sparPieceInfo do 
		local count = remote.items:getItemsNumByID(sparPieceInfo[i].id) or 0
		local craftInfo = remote.items:getItemsByMaterialId(sparPieceInfo[i].id) or {}
		local graryState = count <= 0
		craftInfo = craftInfo[1] or {}
		local redTips = count >= (craftInfo.component_num_1 or 0) and remote.user.money > (craftInfo.price or 0)
		if itemInfos[i] == nil then
			itemInfos[i] = {}
		end	
		itemInfos[i].param = {pieceInfo = sparPieceInfo[i], index = i, graryState = graryState, redTips = redTips, count = count, backpackType = "sparPiece"}
		itemInfos[i].itemId = sparPieceInfo[i].id
	end

	self._itemInfo = itemInfos
	self:initListView()
end

function QUIDialogGemstoneBackpack:setMaterial()
	self._materialItem = {}

	local materialInfo = remote.items:getItemsByCategory(ITEM_CONFIG_CATEGORY.GEMSTONE_MATERIAL)
	if next(materialInfo) == nil then return end
	materialInfo = self:filterGemstone(materialInfo)

	table.sort(materialInfo, function(a, b)
			local itemInfo1 = QStaticDatabase:sharedDatabase():getItemByID(a.type)
			local itemInfo2 = QStaticDatabase:sharedDatabase():getItemByID(b.type)

			if itemInfo1.order ~= nil and itemInfo2.order ~= nil and itemInfo1.order ~= itemInfo2.order then
				return itemInfo1.order < itemInfo2.order
			elseif a.count ~= b.count then
				return a.count > b.count
			else
				return a.type > b.type
			end
		end)
	local itemInfos = {}
	for i = 1, #materialInfo do 
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(materialInfo[i].type)
		local redTips = itemInfo.red_dot == 1

		if itemInfos[i] == nil then
			itemInfos[i] = {}
		end			
		itemInfos[i].param = {itemID = materialInfo[i].type, itemType = ITEM_TYPE.ITEM, count = materialInfo[i].count, index = i, redTip = redTips, backpackType = "material"}
		itemInfos[i].itemId = materialInfo[i].type
	end
	self._itemInfo = itemInfos
	self:initListView()
end

function QUIDialogGemstoneBackpack:filterGemstone(infos)
	if infos == nil then return {} end
	local newInfos = {}
	for i = 1, #infos do
		local itemId = infos[i].itemId or infos[i].id or infos[i].type
		local itemInfo = db:getItemByID(itemId)
		if itemInfo.appear_1 == nil or itemInfo.appear_1 == true then
			newInfos[#newInfos+1] = infos[i]
		end
	end
	return newInfos
end 

function QUIDialogGemstoneBackpack:filterRepeatSpar(data)
	if data == nil then return {} end
	local newData = {}

	for key, value in pairs(data) do
		if newData[value.itemId] ~= nil then
			local isHave = false
			for _, item in pairs(newData[value.itemId]) do
				if item.grade == value.grade and item.level == value.level and item.exp == value.exp and item.actorId == 0 and value.actorId == 0 then
					isHave = true
					item.count = item.count + 1
					break
				end
			end
			if isHave == false then
				value.count = 1
				table.insert(newData[value.itemId], value)
			end
		else
			newData[value.itemId] = {}
			value.count = 1
			table.insert(newData[value.itemId], value)
		end
	end

	return newData
end

function QUIDialogGemstoneBackpack:checkRedTip()
	self._materialTips = remote.items:checkItemRedTipsByCategory(ITEM_CONFIG_CATEGORY.GEMSTONE_MATERIAL)
	self._ccbOwner.material_tips:setVisible(self._materialTips)

	self._pieceTips = remote.gemstone:checkPieceRedTip()
	self._ccbOwner.piece_tips:setVisible(self._pieceTips)

	self._sparPieceTips = remote.spar:checkSparPieceRedTip()
	if app.unlock:checkLock("UNLOCK_ZHUBAO", false) == false then
		self._sparPieceTips = false
	end

	self._ccbOwner.sp_spar_piece_tips:setVisible(self._sparPieceTips)

end

function QUIDialogGemstoneBackpack:_clickEvent(event) 
	if event == nil or self._isMove == true then return end
	app.sound:playSound("common_item")

	if self:safeCheck() then
		self:itemClicked(event.index, event.itemID, event.pos)
	end
end

function QUIDialogGemstoneBackpack:itemClicked(index, itemID, pos)
	self._selectPosition = index or pos
	self:getOptions().selectPosition = self._selectPosition
	local options = self:getOptions()
	options.itemID = itemID

	for i = 1, #self._itemInfo do
		local item = self._contentListView:getItemByIndex(i)
		if item and item._itemBox then
			local itemBox = item._itemBox
			itemBox:setSelectPosition(self._selectPosition)
			if itemBox:getIndex() == self._selectPosition then
				itemBox:selected(true)
			else
				itemBox:selected(false)
			end
		end
	end

	if self._selectTab == QUIDialogGemstoneBackpack.TAB_MATERIAL then 
		if self._materialPanel == nil then
			self._materialPanel = QUIWidgetBackPackInfo.new()
			self._ccbOwner.node_info:addChild(self._materialPanel)
			self._materialPanel:setPositionX(-424)
			self._materialPanelAction = self._materialPanel:runAction(CCMoveTo:create(0.3,ccp(0,-15)))
		end
		if self._materialPanel:isVisible() == false then
			self._materialPanel:setVisible(true)
			self._materialPanel:setPositionX(-424)
			self._materialPanelAction = self._materialPanel:runAction(CCMoveTo:create(0.3,ccp(0,-15)))
		end
		self._materialPanel:setItemId(itemID)
	elseif self._selectTab == QUIDialogGemstoneBackpack.TAB_SPAR or self._selectTab == QUIDialogGemstoneBackpack.TAB_SPAR_PIECE then 
		if self._sparPanel == nil then
			self._sparPanel = QUIWidgetSparBackPackInfo.new()
			self._ccbOwner.node_info:addChild(self._sparPanel)
			self._sparPanel:addEventListener(QUIWidgetSparBackPackInfo.CLICK_COMPOSE, handler(self, self._composeSpar))
			self._sparPanel:setPositionX(-424)
			self._sparPanelAction = self._sparPanel:runAction(CCMoveTo:create(0.3,ccp(0,0)))
		end
		if self._sparPanel:isVisible() == false then
			self._sparPanel:setVisible(true)
			self._sparPanel:setPositionX(-424)
			self._sparPanelAction = self._sparPanel:runAction(CCMoveTo:create(0.3,ccp(0,0)))
		end
		self._sparPanel:setItemId(itemID, self._selectTab, self._itemInfo[self._selectPosition].param.sparInfo)
	else
		if self._infoPanel == nil then
			self._infoPanel = QUIWidgetGemStoneBackPackInfo.new()
			self._ccbOwner.node_info:addChild(self._infoPanel)
			self._infoPanel:addEventListener(QUIWidgetGemStoneBackPackInfo.CLICK_COMPOSE, handler(self, self._composeStone))
			self._infoPanel:setPositionX(-424)
			self._infoPanelAction = self._infoPanel:runAction(CCMoveTo:create(0.3,ccp(0,0)))
		end
		if self._infoPanel:isVisible() == false then
			self._infoPanel:setVisible(true)
			self._infoPanel:setPositionX(-424)
			self._infoPanelAction = self._infoPanel:runAction(CCMoveTo:create(0.3,ccp(0,0)))
		end
		self._infoPanel:setItemId(itemID, self._selectTab, self._itemInfo[self._selectPosition].param.gemstoneInfo)
	end
end 

function QUIDialogGemstoneBackpack:hidePanel()
	self:getOptions().selectPosition = 0
	if self._infoPanel ~= nil then
		self._infoPanel:setVisible(false)
		if self._infoPanelAction ~= nil then
			self._infoPanel:stopAction(self._infoPanelAction)
			self._infoPanelAction = nil
		end
	end
	if self._materialPanel ~= nil then
		self._materialPanel:setVisible(false)
		if self._materialPanelAction ~= nil then
			self._materialPanel:stopAction(self._materialPanelAction)
			self._materialPanelAction = nil
		end
	end
	if self._sparPanel ~= nil then
		self._sparPanel:setVisible(false)
		if self._sparPanelAction ~= nil then
			self._sparPanel:stopAction(self._sparPanelAction)
			self._sparPanelAction = nil
		end
	end
end

function QUIDialogGemstoneBackpack:_composeStone(event)
	if event == nil or event.sid == nil then return end

	remote.gemstone:gemstoneComposeRequest(event.sid, handler(self, self._composeGemStoneSuccess))
end

function QUIDialogGemstoneBackpack:_composeSpar(event)
	if event == nil or event.itemId == nil then return end

	remote.spar:requestSparCraft(event.itemId, 1, handler(self, self._composeSparSuccess))
end

function QUIDialogGemstoneBackpack:_composeGemStoneSuccess(data)
	if self:safeCheck()	then
		local awards = {{id = data.gemstones[1].itemId, typeName = ITEM_TYPE.GEMSTONE, count = 1}}
	    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	            options = {awards = awards, isVip = isVip}},{isPopCurrentDialog = false} )
	    dialog:setTitle("恭喜您成功合成魂骨")

		self:selectTab(self._selectTab, false)
	    -- self:checkRedTip()
	end
end

function QUIDialogGemstoneBackpack:_composeSparSuccess(data)
	if self:safeCheck()	then
		local awards = {{id = data.sparCraftResponse.sparList[1].itemId, typeName = ITEM_TYPE.SPAR, count = 1}}
	    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	            options = {awards = awards}},{isPopCurrentDialog = false} )
	    dialog:setTitle("恭喜您成功合成外附魂骨")

		self:selectTab(self._selectTab, false)
	    -- self:checkRedTip()
	end
end

function QUIDialogGemstoneBackpack:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogGemstoneBackpack:_onScrollViewBegan()
	self._isMove = false
end

function QUIDialogGemstoneBackpack:_onTriggerTabGemstone()
	if self._selectTab == QUIDialogGemstoneBackpack.TAB_GEMSTONE then return end
	app.sound:playSound("common_switch")
	self:selectTab(QUIDialogGemstoneBackpack.TAB_GEMSTONE)
end

function QUIDialogGemstoneBackpack:_onTriggerTabPiece()
	if self._selectTab == QUIDialogGemstoneBackpack.TAB_PIECE then return end
	app.sound:playSound("common_switch")
	self:selectTab(QUIDialogGemstoneBackpack.TAB_PIECE)
end

function QUIDialogGemstoneBackpack:_onTriggerTabSpar()
	if self._selectTab == QUIDialogGemstoneBackpack.TAB_SPAR then return end
	app.sound:playSound("common_switch")
	self:selectTab(QUIDialogGemstoneBackpack.TAB_SPAR)
end

function QUIDialogGemstoneBackpack:_onTriggerTabSparPiece()
	if self._selectTab == QUIDialogGemstoneBackpack.TAB_SPAR_PIECE then return end
	app.sound:playSound("common_switch")
	self:selectTab(QUIDialogGemstoneBackpack.TAB_SPAR_PIECE)
end

function QUIDialogGemstoneBackpack:_onTriggerTabMatrial()
	if self._selectTab == QUIDialogGemstoneBackpack.TAB_MATERIAL then return end
	app.sound:playSound("common_switch")
	self:selectTab(QUIDialogGemstoneBackpack.TAB_MATERIAL)
end

function QUIDialogGemstoneBackpack:_onTirggerClickShop()
	if app.unlock:getUnlockGemStone(true) == false then
		return 
	end

	remote.stores:openShopDialog(SHOP_ID.silverShop)
end

function QUIDialogGemstoneBackpack:_onTriggerClickSparShop()
	if app.unlock:checkLock("UNLOCK_ZHUBAO") == false then
		return 
	end

	remote.stores:openShopDialog(SHOP_ID.sparShop)
end

function QUIDialogGemstoneBackpack:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogGemstoneBackpack:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

-- ¶Ô»°¿òÍË³ö
function QUIDialogGemstoneBackpack:_onTriggerBack(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- ¶Ô»°¿òÍË³ö
function QUIDialogGemstoneBackpack:_onTriggerHome(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogGemstoneBackpack
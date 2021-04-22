--
-- Author: Kumo.Wang
-- Date: 
-- 祝福界面
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSpecialRefine = class("QUIDialogSpecialRefine", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetSpecialRefineCell = import("..widgets.QUIWidgetSpecialRefineCell")
local QUIWidgetItemsBox = import("...ui.widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QRemote = import("...models.QRemote")

function QUIDialogSpecialRefine:ctor(options)
	local ccbFile = "ccb/Dialog_refine_zhufu.ccbi"
    local callBacks = {
    	{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},	
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogSpecialRefine.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithRefine()
    self.isAnimation = true
    self._itemId1 = 5000004 -- 精炼石物品id
    self._itemId2 = 5000005 -- 高级精炼石物品id
	self._pieceId1 = 5000001 -- 精炼石碎片id
    self._pieceId2 = 5000002 -- 高级精炼石碎片id
    self._actorId = options.actorId

    self._cells = {}
    self._seleceId = 0 -- 勾选的格子编号，0为未勾选

    self:_init()
end

function QUIDialogSpecialRefine:viewDidAppear()
    QUIDialogSpecialRefine.super.viewDidAppear(self)

    self._remoteProxy = cc.EventProxy.new(remote.items)
    self._remoteProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

    self._remoteProxy2 = cc.EventProxy.new(remote)
    self._remoteProxy2:addEventListener(QRemote.HERO_UPDATE_EVENT, handler(self, self.onEvent)) 
end

function QUIDialogSpecialRefine:viewWillDisappear()
    QUIDialogSpecialRefine.super.viewWillDisappear(self)

    self._remoteProxy:removeAllEventListeners()
    self._remoteProxy2:removeAllEventListeners()
end

function QUIDialogSpecialRefine:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSpecialRefine:onEvent( event )
	if not event or not event.name then return end

	if event.name == remote.items.EVENT_ITEMS_UPDATE then
		self:_updateBtn()
	elseif event.name == QRemote.HERO_UPDATE_EVENT then
		self:_updateAllCell()
	end
end

function QUIDialogSpecialRefine:responseHandler( response )
	-- QPrintTable(response)
	if response.api == "REFINE_ADVANCE_HERO" then
		self:_setAllCellDaley( true )
		app:getNavigationManager():pushViewController(app.topLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSpecialRefineReplaceAlert", options = { actorId = self._actorId, index = self._seleceId, 
			comfirmBack = function()
	            self:_showReplaceEffect()
	        end, 
	        callBack = function() 
	        	self:_setAllCellDaley( false )
	        end}})
	end
end

function QUIDialogSpecialRefine:_setAllCellDaley( boo )
	for _, cell in pairs(self._cells) do
		cell:setDaley( boo )
	end
end

function QUIDialogSpecialRefine:_showReplaceEffect()
	self._needReplaceTips = true
	for _, cell in pairs(self._cells) do
		cell:showReplaceEffect()
	end
end

function QUIDialogSpecialRefine:_onTriggerOK( event, target )
	app.sound:playSound("common_small")
	if self._needReplaceTips then return end
	if target == self._ccbOwner.btn_1 then
		local count = remote.items:getItemsNumByID( self._itemId1 )
		if count >= 1 then
			if self._seleceId > 0 then
				local tbl = {}
		        table.insert(tbl, {oType = "font", content = "是否使用一个精炼石洗出一条",size = 22,color = UNITY_COLOR.shit_yellow})
		        table.insert(tbl, {oType = "font", content = "橙色",size = 22,color = UNITY_COLOR.orange})
		        table.insert(tbl, {oType = "font", content = "或",size = 22,color = UNITY_COLOR.shit_yellow})
		        table.insert(tbl, {oType = "font", content = "红色",size = 22,color = UNITY_COLOR_LIGHT.red})
		        table.insert(tbl, {oType = "font", content = "属性",size = 22,color = UNITY_COLOR.shit_yellow})
				app:alert({content = tbl, title = "系统提示", colorful = true, 
		            callback = function(state)
			            if state == ALERT_TYPE.CONFIRM then
			                app:getClient():refineAdvanceHeroRequest( self._actorId, self._seleceId, 1, function (response)
						        self:responseHandler(response)
						    end)
			            end
		            end, isAnimation = false}, true, true)     
			else
				app.tip:floatTip("请先开启洗炼槽或者选择一条洗炼属性")
			end
		else
			local showWord = false
			if remote.items:getItemsNumByID(self._pieceId1) < 100 then
				showWord = true
			end

			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogItemDropInfo",
			    		options = {id = self._itemId1, count = count}}, {isPopCurrentDialog = false})
			-- QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId1, nil, nil, showWord, "道具合成数量不足，请查看获取途径~")
		end
	elseif target == self._ccbOwner.btn_2 then
		local count = remote.items:getItemsNumByID( self._itemId2 )
		if count >= 1 then
			if self._seleceId > 0 then
				local tbl = {}
		        table.insert(tbl, {oType = "font", content = "是否使用一个高级精炼石洗出一条",size = 22,color = UNITY_COLOR.shit_yellow})
		        table.insert(tbl, {oType = "font", content = "红色",size = 22,color = UNITY_COLOR_LIGHT.red})
		        table.insert(tbl, {oType = "font", content = "属性",size = 22,color = UNITY_COLOR.shit_yellow})
				app:alert({content = tbl, title = "系统提示", colorful = true,  
		            callback = function(state)
			            if state == ALERT_TYPE.CONFIRM then
			                app:getClient():refineAdvanceHeroRequest( self._actorId, self._seleceId, 2, function (response)
						        self:responseHandler(response)
						    end)
			            end
		            end, isAnimation = false}, true, true)  
			else
				app.tip:floatTip("请先开启洗炼槽或者选择一条洗炼属性")
			end
		else
			local showWord = false
			if remote.items:getItemsNumByID(self._pieceId2) < 150 then
				showWord = true
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogItemDropInfo",
			    		options = {id = self._itemId2, count = count}}, {isPopCurrentDialog = false})
			-- QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId2, nil, nil, showWord, "道具合成数量不足，请查看获取途径~")
		end
	end
end

function QUIDialogSpecialRefine:_onEvent( event )
	if event.name == QUIWidgetSpecialRefineCell.SELECT then
		if event.index == self._seleceId then
			self._seleceId = 0
		else
			self._seleceId = event.index
		end
		for _, cell in pairs( self._cells ) do
			cell:setSelect( self._seleceId )
		end
	elseif event.name == QUIWidgetSpecialRefineCell.OPEN then
		self._cells[event.index]:setDaley( true )
		app:getNavigationManager():pushViewController(app.topLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRefineOpenAlert", options = { actorId = self._actorId, 
			comfirmBack = self:safeHandler(function()
	            self._cells[event.index]:showOpenEffect()
	        end), 
	        callBack = self:safeHandler(function() 
	        	self._cells[event.index]:setDaley( false )
	        end)}})
	elseif event.name == QUIWidgetSpecialRefineCell.REPLACE_COMPLETE then
		if self._needReplaceTips then
			self._needReplaceTips = false
			app.tip:floatTip("属性保留成功")
		end
	end
end

function QUIDialogSpecialRefine:_init()
	local index = 1
	while true do
		local node = self._ccbOwner["node_"..index]
		if node then
			local cell = QUIWidgetSpecialRefineCell.new({ actorId = self._actorId, index = index })
			cell:addEventListener(QUIWidgetSpecialRefineCell.OPEN, handler(self, self._onEvent))
			cell:addEventListener(QUIWidgetSpecialRefineCell.SELECT, handler(self, self._onEvent))
			cell:addEventListener(QUIWidgetSpecialRefineCell.REPLACE_COMPLETE, handler(self, self._onEvent))
			node:addChild( cell )
			self._cells[index] = cell
			index = index + 1
		else
			break
		end
	end

	self:_updateBtn()
end

function QUIDialogSpecialRefine:_updateBtn()
	self._ccbOwner.node_item_1:removeAllChildren()
	self._ccbOwner.node_item_2:removeAllChildren()

 	local item1 = QUIWidgetItemsBox.new()
 	local count1 = remote.items:getItemsNumByID(self._itemId1)
    item1:setGoodsInfo(self._itemId1, ITEM_TYPE.ITEM, count1, true)
    self._ccbOwner.node_item_1:addChild(item1)

    local item2 = QUIWidgetItemsBox.new()
    local count2 = remote.items:getItemsNumByID(self._itemId2)
    item2:setGoodsInfo(self._itemId2, ITEM_TYPE.ITEM, count2, true)
    self._ccbOwner.node_item_2:addChild(item2)

    --xurui: set red tips
    self:checkRedTips()
end

function QUIDialogSpecialRefine:checkRedTips()
   	local tipState1 = false
   	local tipState2 = false
   	if remote.items:getItemsNumByID(self._itemId1) > 0 or remote.items:getItemsNumByID(self._pieceId1) >= 100 then
   		tipState1 = true
   	end
   	if remote.items:getItemsNumByID(self._itemId2) > 0 or remote.items:getItemsNumByID(self._pieceId2) >= 150 then
   		tipState2 = true
   	end
	self._ccbOwner.item_tips_1:setVisible(tipState1)
	self._ccbOwner.item_tips_2:setVisible(tipState2)
end

function QUIDialogSpecialRefine:_updateAllCell()
	for _, cell in pairs(self._cells) do
		cell:update()
	end
end

function QUIDialogSpecialRefine:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogSpecialRefine:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogSpecialRefine
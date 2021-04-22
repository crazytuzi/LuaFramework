--
-- Author: Kumo.Wang
-- Date: 
-- 洗炼界面
--
local QUIDialog = import(".QUIDialog")
local QUIDialogRefine = class("QUIDialogRefine", QUIDialog)

local QUIWidgetRefineCell = import("..widgets.QUIWidgetRefineCell")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRemote = import("...models.QRemote")
local QQuickWay = import("...utils.QQuickWay")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")

function QUIDialogRefine:ctor(options)
	local ccbFile = "ccb/Dialog_refine.ccbi"
    local callBacks = {
    	{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},	
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerAuto", callback = handler(self, self._onTriggerAuto)},
        {ccbCallbackName = "onTriggerReplace", callback = handler(self, self._onTriggerReplace)},	
    }
    QUIDialogRefine.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithRefine()
    self.isAnimation = true

    self._actorId = options.actorId

    self._locks = app:getUserOperateRecord():getRefineLockState(self._actorId) -- 获取所掉格子的index
    self._lockCount = table.nums(self._locks) or 0 -- 锁定的格子数量 0～6
    self._canRefine = true -- 是否可以洗炼。（全锁的情况不可以洗炼，没有格子开启也不可洗炼）
    self._totalIndex = 0 -- 格子的数量

    self._cells = {}

    self:_init()
end

function QUIDialogRefine:viewDidAppear()
    QUIDialogRefine.super.viewDidAppear(self)

    self._remoteProxy = cc.EventProxy.new(remote.items)
    self._remoteProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

    self._remoteProxy2 = cc.EventProxy.new(remote)
    self._remoteProxy2:addEventListener(QRemote.HERO_UPDATE_EVENT, handler(self, self.onEvent)) 
end

function QUIDialogRefine:viewWillDisappear()
    QUIDialogRefine.super.viewWillDisappear(self)

    self._remoteProxy:removeAllEventListeners()
    self._remoteProxy2:removeAllEventListeners()

    if self._autoScheduler then
		scheduler.unscheduleGlobal(self._autoScheduler)
		self._autoScheduler = nil
	end

	if self._btnScheduler then
		scheduler.unscheduleGlobal(self._btnScheduler)
		self._btnScheduler = nil
	end
end

function QUIDialogRefine:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogRefine:onEvent(event)
	if not event or not event.name then return end

	if event.name == remote.items.EVENT_ITEMS_UPDATE then
		self:_updateAllCell()
	elseif event.name == QRemote.HERO_UPDATE_EVENT then
		self:_updateAllCell()
	end
end

function QUIDialogRefine:responseHandler( response )
	-- QPrintTable(response)
	if response.api == "REFINE_HERO" then
		self:_updateAllCell()
		self:_updateReplaceBtn()
		self:_updateInfo()
	elseif response.api == "REFINE_HERO_APPLY" then
		self:_updateAllCell()
		self:_updateReplaceBtn()
		self:_updateInfo()
	elseif response.api == "REFINE_CLEAR" then
		self:_updateAllCell()
		self:_updateReplaceBtn()
		self:_updateInfo()
	end
end

function QUIDialogRefine:_onTriggerOK(event)
	app.sound:playSound("common_small")
	-- print("[Kumo] xilian ",event, self._btnScheduler, self._autoScheduler)
	if self._autoScheduler and event then
		-- 已经处于自动升级状态，并且主动点击洗炼按钮
		self:_stopAuto()
		return
	end
	
	if not self._canRefine then
		app.tip:floatTip("至少需要一条未锁定的属性才可以洗炼")
		self:_stopAuto()
		return
	end

	local refineMoneyPrice = QStaticDatabase.sharedDatabase():getConfigurationValue( "xilian_xiaohao" )
	if refineMoneyPrice > remote.user.refineMoney then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.REFINE_MONEY)
		if self._autoScheduler then
			-- 已经处于自动升级状态
			self:_stopAuto()
			return
		end
		return
	end
	local tokenPrice = QStaticDatabase.sharedDatabase():getConfigurationValue( "xilian_suoding" )
	local tokenPriceAll = tokenPrice * self._lockCount
	if tokenPriceAll > remote.user.token then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil, nil, nil, false)
		if self._autoScheduler then
			-- 已经处于自动升级状态
			self:_stopAuto()
			return
		end
		return
	end

	if self._isRefine and not self._autoScheduler and event then
		return
	end

	local tbl = {}
	if self._locks and table.nums(self._locks) then
		for _, index in pairs(self._locks) do
			table.insert(tbl, index)
		end
	end

	if self._autoScheduler then
		if self._colorAutoStop then
			self._colorAutoStop = false
			self:_stopAuto()
			-- app:alert({content = "获得了红色洗炼属性，确定要继续洗炼吗？", title = "系统提示", 
	  --           comfirmBack = function()
	  --               self:_startAuto()
	  --           end, callBack = function() end, isAnimation = false}, true, true)   
	  		app.tip:floatTip("洗练获得红色属性，停止一键洗练", nil, nil, 2)
	  		return
	  	end
   	else
   		if self._colorStop then
   			self._colorStop = false
            app:alert({content = "获得了红色洗炼属性，确定要继续洗炼吗？", title = "系统提示", btnDesc = {"继续"}, 
	            callback = function(state)
	            	if state == ALERT_TYPE.CONFIRM then
	            		self:_onTriggerOK()
	            	end
	            end, isAnimation = false}, true, true)   
            return    
		end
	end

	if self._autoScheduler then
		if self._forceAutoStop then
			self._forceAutoStop = false
			self:_stopAuto()
		-- 	app:alert({content = "洗炼后增加属性比当前增加战力高，确定要继续洗炼吗？", title = "系统提示", 
	 --            comfirmBack = function()
	 --                self:_startAuto()
	 --            end, callBack = function() end, isAnimation = false}, true, true)   
	 		app.tip:floatTip("洗练后战力提升，停止一键洗练", nil, nil, 2)
	 		return
	 	end
	else
		if self._forceStop then
			self._forceStop = false
			app:alert({content = "洗炼后增加属性比当前增加战力高，确定要继续洗炼吗？", title = "系统提示", btnDesc = {"继续"}, 
	            callback = function(state)
	            	if state == ALERT_TYPE.CONFIRM then
	            		self:_onTriggerOK()
	            	end
	            end, callBack = function() end, isAnimation = false}, true, true) 
			return
		end
	end

	-- QPrintTable(tbl)
	self:_setAllCellDaley()
	if self._btnScheduler then
		scheduler.unscheduleGlobal(self._btnScheduler)
		self._btnScheduler = nil
	end
	if not self._autoScheduler then
		self:_updateAllBtnsState(false)
		self._btnScheduler = scheduler.scheduleGlobal(self:safeHandler( function()
				self:_updateAllBtnsState(true)
			end), 1)
		self._isRefine = true
	else
		self:_updateAllBtnsState(true)
	end
	app:getClient():refineHeroRequest( self._actorId, tbl, self:safeHandler( function (response)
			self:_cleanAllStop()
			self:_showRefineEffect()
	        self:responseHandler(response)
	        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_REFINE_SUCCESS})
	    end))
end

function QUIDialogRefine:_onTriggerAuto()
	app.sound:playSound("common_small")
	if self._autoScheduler then
		-- 已经处于自动升级状态
		self:_stopAuto()
	else
		-- 开始自动升级
		self:_startAuto()
	end
end

function QUIDialogRefine:_startAuto()
	-- 开始自动升级
	if self._autoScheduler then 
		self._ccbOwner.tf_auto:setString("停  止")
		return 
	end
	self._ccbOwner.tf_auto:setString("停  止")
	self._autoScheduler = scheduler.scheduleGlobal(self:safeHandler( function()
			self:_onTriggerOK()
		end ), 1)
	self:_onTriggerOK()
end

function QUIDialogRefine:_stopAuto()
	-- 已经处于自动升级状态
	if not self._autoScheduler then 
		self._ccbOwner.tf_auto:setString("一键洗炼")
		return 
	end

	if self._autoScheduler then
		scheduler.unscheduleGlobal(self._autoScheduler)
		self._autoScheduler = nil
	end
	self._ccbOwner.tf_auto:setString("一键洗炼")
end

function QUIDialogRefine:_onTriggerReplace()
	app.sound:playSound("common_small")
	if self._autoScheduler then
		-- 已经处于自动升级状态
		self:_stopAuto()
		return
	end

	if self._replceAlert then
		self._replceAlert = false
		app:alert({content = "当前战力大于洗炼后的战力，是否要替换属性？", title = "系统提示", 
	            callback = function(state)
	            	if state == ALERT_TYPE.CONFIRM then
	            		self:_onTriggerReplace()
	            	end
	            end, isAnimation = false}, true, true) 
		return
	end

	if not self:_checkReplace() then
		app.tip:floatTip("无属性可替换，请先洗炼")
		return
	else
		self:_setAllCellDaley()
		app:getClient():refineHeroApplyRequest( self._actorId, function (response)
				self:_cleanAllStop()
				self:_showReplaceEffect()
		        self:responseHandler(response)
	        	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_REFINE_REPLACE_SUCCESS})
	    	end)
	end
end

function QUIDialogRefine:_cleanAllStop()
	self._forceStop = false
	self._forceAutoStop = false
	self._colorStop = false
	self._colorAutoStop = false
	self._replceAlert = false
end

function QUIDialogRefine:_checkReplace()
	local heroInfo = clone(remote.herosUtil:getHeroByID(self._actorId))
	if not heroInfo.refineHeroInfo then
		local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID(self._actorId)
		if refineHeroInfo then
			heroInfo.refineHeroInfo = {}
			heroInfo.refineHeroInfo = { openGrid = refineHeroInfo.openGrid, refineAttrsPre = refineHeroInfo.refineAttrsPre }
		end
	end

	if heroInfo.refineHeroInfo and heroInfo.refineHeroInfo.refineAttrsPre and #heroInfo.refineHeroInfo.refineAttrsPre > 0 then
		return true
	else
		return false
	end
end

function QUIDialogRefine:_setAllCellDaley()
	for _, cell in pairs(self._cells) do
		cell:setDaley( true )
	end
end

function QUIDialogRefine:_showReplaceEffect()
	self._needReplaceTips = true
	for _, cell in pairs(self._cells) do
		cell:showReplaceEffect()
	end
end

function QUIDialogRefine:_showRefineEffect()
	for _, cell in pairs(self._cells) do
		cell:showRefineEffect()
	end
end

function QUIDialogRefine:_onEvent( event )
	if event.name == QUIWidgetRefineCell.CHANGE_LOCK then
		self:_stopAuto()
		app:getClient():refineHeroClearRequest( self._actorId, function (response)
				self:_cleanAllStop()
		        self:responseHandler(response)
	    	end)
		if event.isLock then
			if not self._locks[ event.index ] then
				self._locks[ event.index ] = event.index
				self._lockCount = self._lockCount + 1
			end
		else
			if self._locks[ event.index ] then
				self._locks[ event.index ] = nil
				self._lockCount = self._lockCount - 1
			end
		end
		self:_updateRefineBtn()
		self:_updateInfo()

		--xurui: 客户端保存洗炼锁定状态
		app:getUserOperateRecord():setRefineLockState(self._actorId, self._locks)
	elseif event.name == QUIWidgetRefineCell.OPEN then
		self._cells[event.index]:setDaley( true )
		app:getNavigationManager():pushViewController(app.topLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRefineOpenAlert", options = { actorId = self._actorId, 
			comfirmBack = function()
	            self._cells[event.index]:showOpenEffect()
	        end, 
	        callBack = function() 
	        	self._cells[event.index]:setDaley( false )
	        end}})
	elseif event.name == QUIWidgetRefineCell.STOP then
		self._colorAutoStop = true
		self._colorStop = true
		-- if self._autoScheduler then
		-- 	self:_stopAuto()
		-- 	app:alert({content = "获得了红色洗炼属性，确定要继续洗炼吗？", title = "系统提示", 
	 --            comfirmBack = function()
	 --                self:_startAuto()
	 --            end, callBack = function() end, isAnimation = false}, true, true)          
		-- end
	elseif event.name == QUIWidgetRefineCell.REPLACE_COMPLETE then
		if self._needReplaceTips then
			self._needReplaceTips = false
			app.tip:floatTip("属性替换成功")
		end
	elseif event.name == QUIWidgetRefineCell.REFINE_COMPLETE then
		self._isRefine = false
	end
end

function QUIDialogRefine:_init()
	local index = 1
	while true do
		local node = self._ccbOwner["node_"..index]
		if node then
			if not self._cells[index] then
				local cell = QUIWidgetRefineCell.new({ actorId = self._actorId, index = index , isLock = self._locks[index]})
				cell:addEventListener(QUIWidgetRefineCell.CHANGE_LOCK, handler(self, self._onEvent))
				cell:addEventListener(QUIWidgetRefineCell.OPEN, handler(self, self._onEvent))
				cell:addEventListener(QUIWidgetRefineCell.STOP, handler(self, self._onEvent))
				cell:addEventListener(QUIWidgetRefineCell.REPLACE_COMPLETE, handler(self, self._onEvent))
				cell:addEventListener(QUIWidgetRefineCell.REFINE_COMPLETE, handler(self, self._onEvent))
				node:addChild( cell )
				self._cells[index] = cell
			end
			index = index + 1
		else
			break
		end
	end

	self:_updateInfo()
	self:_updateRefineBtn()
	self:_updateReplaceBtn()
end

function QUIDialogRefine:_updateInfo()
	local refineMoneyPrice = QStaticDatabase.sharedDatabase():getConfigurationValue( "xilian_xiaohao" )
	local tokenPrice = QStaticDatabase.sharedDatabase():getConfigurationValue( "xilian_suoding" )
	self._ccbOwner.tf_refineMoney:setString( refineMoneyPrice.." / "..remote.user.refineMoney )
	self._ccbOwner.tf_token:setString( (tokenPrice * self._lockCount).." / "..remote.user.token )

	local heroInfo = clone(remote.herosUtil:getHeroByID(self._actorId))
	if not heroInfo.refineHeroInfo then
		local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID(self._actorId)
		if refineHeroInfo then
			heroInfo.refineHeroInfo = {}
			heroInfo.refineHeroInfo = { openGrid = refineHeroInfo.openGrid, refineAttrsPre = refineHeroInfo.refineAttrsPre }
		end
	end
	local ap = remote.herosUtil:createHeroProp(heroInfo)
	local forceNow = ap:getBattleForce(true)
	ap:removeRefineProp()
	local forceBase = ap:getBattleForce(true)
	local willProp = self:_getWillRefineProp()
	ap:addWillRefineProp( willProp )
	local forceWill = ap:getBattleForce(true)
	ap:removeRefineProp()
	ap:addRefineProp()
	local numNow, unitNow = q.convertLargerNumber( forceNow - forceBase )
	self._ccbOwner.tf_force_now:setString(numNow..(unitNow or ""))

	local numWill, unitWill = q.convertLargerNumber( forceWill - forceBase )
	self._ccbOwner.tf_force_will:setString(numWill..(unitWill or ""))

	if forceNow < forceWill then
		self._ccbOwner.ccb_up:setVisible(true)
		self._ccbOwner.ccb_down:setVisible(false)
		self._forceAutoStop = true
		self._forceStop = true
		-- if self._autoScheduler then
		-- 	self:_stopAuto()

		-- 	app:alert({content = "洗炼后增加属性比当前增加战力高，确定要继续洗炼吗？", title = "系统提示", 
	 --            comfirmBack = function()
	 --                self:_startAuto()
	 --            end, callBack = function() end, isAnimation = false}, true, true)   
		-- end
	elseif forceNow > forceWill and forceWill ~= forceBase then
		self._replceAlert = true
		self._ccbOwner.ccb_up:setVisible(false)
		self._ccbOwner.ccb_down:setVisible(true)
	else
		self._ccbOwner.ccb_up:setVisible(false)
		self._ccbOwner.ccb_down:setVisible(false)
	end
end

function QUIDialogRefine:_getWillRefineProp()
	local heroInfo = remote.herosUtil:getHeroByID( self._actorId )
	if not heroInfo.refineHeroInfo then
		local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID(self._actorId)
		if refineHeroInfo then
			heroInfo.refineHeroInfo = {}
			heroInfo.refineHeroInfo = { openGrid = refineHeroInfo.openGrid, refineAttrsPre = refineHeroInfo.refineAttrsPre }
		end
	end
	if not heroInfo.refineHeroInfo then return {} end
	local willProp = heroInfo.refineHeroInfo.refineAttrsPre or {}
	local tbl = {}
	local isNeed = false
	for _, value in pairs(willProp) do
		if not self._locks[value.grid] then
			table.insert(tbl, value)
		else
			isNeed = true
		end
	end

	if isNeed then
		local nowProp = heroInfo.refineAttrs
		for _, value in pairs(nowProp) do
			if self._locks[value.grid] then
				table.insert(tbl, value)
			end
		end
	end

	return tbl
end


function QUIDialogRefine:_updateRefineBtn( boo )
	local totalIndex = 0
	for _, cell in pairs(self._cells) do
		if cell:isOpen() then
			totalIndex = totalIndex + 1
		end
	end
	-- print("[Kumo] QUIDialogRefine:_updateRefineBtn() ", totalIndex)
	if self._lockCount >= totalIndex then
		self:_stopAuto()
		self._canRefine = false
		-- makeNodeFromNormalToGray( self._ccbOwner.node_btn_ok )
		-- makeNodeFromNormalToGray( self._ccbOwner.node_btn_auto )
		-- self._ccbOwner.btn_ok:setEnabled(false)
		-- self._ccbOwner.btn_auto:setEnabled(false)
	else
		self._canRefine = true
		-- makeNodeFromGrayToNormal( self._ccbOwner.node_btn_ok )
		-- makeNodeFromGrayToNormal( self._ccbOwner.node_btn_auto )
		-- self._ccbOwner.btn_ok:setEnabled(true)
		-- self._ccbOwner.btn_auto:setEnabled(true)
	end

	if self._lockCount == 0 then
		self._ccbOwner.node_token:setVisible(false)
		self._ccbOwner.node_refineMoney:setPositionX(80)
	else
		self._ccbOwner.node_token:setVisible(true)
		self._ccbOwner.node_refineMoney:setPositionX(0)
	end
end

function QUIDialogRefine:_updateReplaceBtn()
	-- local heroInfo = remote.herosUtil:getHeroByID( self._actorId ) 
	-- if heroInfo.refineHeroInfo and heroInfo.refineHeroInfo.refineAttrsPre and table.nums( heroInfo.refineHeroInfo.refineAttrsPre ) > 0 then
	-- 	makeNodeFromGrayToNormal( self._ccbOwner.node_btn_replace )
	-- 	self._ccbOwner.btn_replace:setEnabled(true)
	-- else
	-- 	makeNodeFromNormalToGray( self._ccbOwner.node_btn_replace )
	-- 	self._ccbOwner.btn_replace:setEnabled(false)

	-- end
end

function QUIDialogRefine:_updateAllBtnsState( boo )
	if boo then
		makeNodeFromGrayToNormal( self._ccbOwner.node_btn_ok )
		makeNodeFromGrayToNormal( self._ccbOwner.node_btn_auto )
		makeNodeFromGrayToNormal( self._ccbOwner.node_btn_replace )
		self._ccbOwner.btn_ok:setEnabled(boo)
		self._ccbOwner.btn_auto:setEnabled(boo)
		self._ccbOwner.btn_replace:setEnabled(boo)
	else
		makeNodeFromNormalToGray( self._ccbOwner.node_btn_ok )
		makeNodeFromNormalToGray( self._ccbOwner.node_btn_auto )
		makeNodeFromNormalToGray( self._ccbOwner.node_btn_replace )
		self._ccbOwner.btn_ok:setEnabled(boo)
		self._ccbOwner.btn_auto:setEnabled(boo)
		self._ccbOwner.btn_replace:setEnabled(boo)
	end
end

function QUIDialogRefine:_updateAllCell()
	for _, cell in pairs(self._cells) do
		cell:update()
	end
end

function QUIDialogRefine:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogRefine:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogRefine
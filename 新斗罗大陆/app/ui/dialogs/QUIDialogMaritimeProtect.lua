-- @Author: xurui
-- @Date:   2016-12-29 17:57:13
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-04 16:54:13
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMaritimeProtect = class("QUIDialogMaritimeProtect", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetMaritimeProtectClient = import("..widgets.QUIWidgetMaritimeProtectClient")
local QListView = import("...views.QListView")
local QUIWidgetSmallAwardsAlert = import("..widgets.QUIWidgetSmallAwardsAlert")
local QRichText = import("...utils.QRichText")

QUIDialogMaritimeProtect.TAB_PROTECT = "TAB_PROTECT"
QUIDialogMaritimeProtect.TAB_JOIN_PROTECT = "TAB_JOIN_PROTECT"

function QUIDialogMaritimeProtect:ctor(options)
	local ccbFile = "ccb/Dialog_Haishang_baohu.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerGoUnion", callback = handler(self, self._onTriggerGoUnion)},
		{ccbCallbackName = "onTriggerProtect", callback = handler(self, self._onTriggerProtect)},
		{ccbCallbackName = "onTriggerJoinProtect", callback = handler(self, self._onTriggerJoinProtect)},
		{ccbCallbackName = "onTriggerConfirmJoinProtect", callback = handler(self, self._onTriggerConfirmJoinProtect)}
	}
	QUIDialogMaritimeProtect.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._selectInfo = {}
	if options then
		self._callBack = options.callBack
		self._selectInfo = options.selectInfo or {}
		self._tab = options.tab or QUIDialogMaritimeProtect.TAB_JOIN_PROTECT
		self._openType = options.openType
	end

	self._protectClient = {}
	
    q.setButtonEnableShadow(self._ccbOwner.btn_confirm)
    q.setButtonEnableShadow(self._ccbOwner.btn_join)
    q.setButtonEnableShadow(self._ccbOwner.btn_join_union)
	self:initListView()
end

function QUIDialogMaritimeProtect:viewDidAppear()
	QUIDialogMaritimeProtect.super.viewDidAppear(self)

	self._maritimeProxy = cc.EventProxy.new(remote.maritime)
    self._maritimeProxy:addEventListener(remote.maritime.EVENT_UPDATE_MYINFO, handler(self, self.setJoinProtectInfo))

	self:selectTab()
end

function QUIDialogMaritimeProtect:viewWillDisappear()
	QUIDialogMaritimeProtect.super.viewWillDisappear(self)

	if self._myShipScheduler then
		scheduler.unscheduleGlobal(self._myShipScheduler)
		self._myShipScheduler = nil
	end
	
    if self._maritimeProxy ~= nil then
    	self._maritimeProxy:removeAllEventListeners()
    	self._maritimeProxy = nil
    end
end

function QUIDialogMaritimeProtect:selectTab()
	self:getOptions().tab = self._tab

	self:_setButtonState()
	if self._dataListView then
		self._dataListView:setVisible(false)
	end
	self._protectClient = {}

	self._ccbOwner.node_protect_bg:setVisible(false)
	self._ccbOwner.node_join_protect_bg:setVisible(false)

	self._ccbOwner.node_tf_content:removeAllChildren()
	self._ccbOwner.node_tf_content:setString("")
	local richText = QRichText.new({
            {oType = "font", content = "加入保护可以将您信息显示在", size = 24},
            {oType = "font", content = "寻求保护", size = 24,color = COLORS.M},
            {oType = "font", content = "的列表中，同宗门成员可以选择",size = 24},
            {oType = "font", content = "由您来保护他们的仙品", size = 24,color = COLORS.M},
            {oType = "font", content = "（不影响自己运送）是否加入？", size = 24},
        },350)
	self._ccbOwner.node_tf_content:addChild(richText)

	if self._tab == QUIDialogMaritimeProtect.TAB_PROTECT then
		self._ccbOwner.node_protect_bg:setVisible(true)
		self._ccbOwner.node_no_union:setVisible(false)

		remote.maritime:requestGetMaritimeEscortList(function(data)
				if data.maritimeJoinEscortListResponse then
					self:initListView(data.maritimeJoinEscortListResponse.escortFighters)
				end
			end, function (data)
				if data.error == "MARITIME_ESCORT_LIST_NO_CONSORTIA" then
					self._ccbOwner.node_no_union:setVisible(true)
					self._ccbOwner.node_tips1:setVisible(true)
					self._ccbOwner.tf_tips2:setVisible(false)
				end
			end)

	elseif self._tab == QUIDialogMaritimeProtect.TAB_JOIN_PROTECT then
		self._ccbOwner.node_join_protect_bg:setVisible(true)

		self:setJoinProtectInfo()
	end
end

function QUIDialogMaritimeProtect:initListView(protecters)
	if protecters == nil or next(protecters) == nil then
		self._ccbOwner.node_no_union:setVisible(true)
		self._ccbOwner.node_tips1:setVisible(false)
		self._ccbOwner.tf_tips2:setVisible(true)
		return
	end

	self._protecters = protecters

    if not self._dataListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._protecters[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetMaritimeProtectClient.new()
	            	isCacheNode = false
	            end

	            local selectState = false
				if q.isEmpty(self._selectInfo) == false and self._selectInfo.userId == itemData.userId then
					selectState = true
				end
	            item:setInfo({info = itemData, selectState = selectState})
	            info.item = item
	            info.size = item:getContentSize()
				
            	list:registerBtnHandler(index, "btn_select2", handler(self, self._clickClient))

	            return isCacheNode
	        end,
	        ignoreCanDrag = true,
	        enableShadow = false,
	        isVertical = true,
	        totalNumber = #self._protecters,
	        spaceY = 0,
	        -- curOffset = 30,
	    }  
	    self._dataListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._dataListView:refreshData()
	end
	self._dataListView:setVisible(true)
end

function QUIDialogMaritimeProtect:setJoinProtectInfo()
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()

	local myInfo = remote.maritime:getMyMaritimeInfo()
	self._protecterNum = configuration["maritime_protect"].value - (myInfo.escortCnt or 0)

	self._ccbOwner.tf_join_protect_num:setString("剩余保护次数："..self._protecterNum)

	--设置保护倒计时/获得仙品刷新令的
	if myInfo.escortStatus == 1 then --护送倒计时显示
		self._ccbOwner.node_project_ing:setVisible(false)
		self._ccbOwner.node_join_project:setVisible(false)
		self._ccbOwner.node_project_time:setVisible(true)
		local lastTime = remote.maritime:getMaritemeEscortTime()										
		if lastTime > q.serverTime() then
			-- self._ccbOwner.tf_project_time:setString(q.timeToHourMinuteSecond(lastTime,false))
			self:myShipScheduler(lastTime)
		else
			self._ccbOwner.node_project_time:setVisible(false)
		end
	elseif myInfo.escortStatus == 2 then --显示护送中
		self._ccbOwner.node_join_project:setVisible(false)
		self._ccbOwner.node_project_time:setVisible(false)
		self._ccbOwner.node_project_ing:setVisible(true)
	else
		self._ccbOwner.node_project_ing:setVisible(false)
		self._ccbOwner.node_join_project:setVisible(true)
		self._ccbOwner.node_project_time:setVisible(false)
		self._ccbOwner.tf_awards_num:setString("1张仙品刷新令")
		self._ccbOwner.tf_awards_num:setVisible(true)
	end

end

function QUIDialogMaritimeProtect:myShipScheduler(endTime)
	if self._myShipScheduler then
		scheduler.unscheduleGlobal(self._myShipScheduler)
		self._myShipScheduler = nil
	end

	if endTime - q.serverTime() > 0 then
		local date = q.timeToHourMinuteSecond(endTime - q.serverTime())
		self._ccbOwner.tf_project_time:setString(date or "")
		self._myShipScheduler = scheduler.performWithDelayGlobal(function ()
			self:myShipScheduler(endTime)
		end, 1)
	else
		self._ccbOwner.node_project_time:setVisible(false)
		self:setJoinProtectInfo()
	end
end

function QUIDialogMaritimeProtect:_clickClient( x, y, touchNode, listView )
    local touchIndex = listView:getCurTouchIndex()
	local item = listView:getItemByIndex(touchIndex)
	self._selectInfo = item:getClientInfo()
	remote.maritime:setProtecter(self._selectInfo)
	self:initListView(self._protecters)
end

function QUIDialogMaritimeProtect:_setButtonState()
	-- if self._openType and self._openType == "DialogMartimeMain" then
	-- 	self._ccbOwner.btn_protect:setHighlighted(false)
	-- 	self._ccbOwner.btn_protect:setEnabled(false)
	-- 	self._ccbOwner.btn_protect:setTouchEnabled(false)
	-- 	self._ccbOwner.btn_join_protect:setHighlighted(false)
	-- 	self._ccbOwner.btn_join_protect:setEnabled(false)
	-- 	return true
	-- end

	local projectTab = self._tab == QUIDialogMaritimeProtect.TAB_PROTECT
	self._ccbOwner.btn_protect:setHighlighted(projectTab)
	self._ccbOwner.btn_protect:setEnabled(not projectTab)

	local joinTab = self._tab == QUIDialogMaritimeProtect.TAB_JOIN_PROTECT
	self._ccbOwner.btn_join_protect:setHighlighted(joinTab)
	self._ccbOwner.btn_join_protect:setEnabled(not joinTab)
end

function QUIDialogMaritimeProtect:_onTriggerProtect()
	if self._openType and self._openType == "DialogMartimeMain" then
		app.tip:floatTip("在运送界面才能选择保护者")
		return true
	end
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogMaritimeProtect.TAB_PROTECT then return end
	self._tab = QUIDialogMaritimeProtect.TAB_PROTECT
	
	self:selectTab()
end

function QUIDialogMaritimeProtect:_onTriggerJoinProtect()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogMaritimeProtect.TAB_JOIN_PROTECT then return end
	self._tab = QUIDialogMaritimeProtect.TAB_JOIN_PROTECT
	
	self:selectTab()
end

function QUIDialogMaritimeProtect:_onTriggerConfirm()
	app.sound:playSound("common_small")
	self:sunOnTriggerClose(true)
end

function QUIDialogMaritimeProtect:_onTriggerConfirmJoinProtect()
	app.sound:playSound("common_small")
	if self._protecterNum <= 0 then
		app.tip:floatTip("魂师大人，保护次数已用完~")
		self:sunOnTriggerClose(true)
	else
		remote.maritime:requestMaritimeJoinEscort(function ()
			if self:safeCheck() then
				self:sunOnTriggerClose(true)
        		local awards = { {id = 9000001, typeName = ITEM_TYPE.ITEM, count = 1} }
				local awardsAlert = QUIWidgetSmallAwardsAlert.new({awards = awards, callBack = function()
					if awardsAlert ~= nil then
						awardsAlert:removeFromParentAndCleanup(true)
						awardsAlert = nil
					end
				end})
				app.tutorialNode:addChild(awardsAlert)
				awardsAlert:setPosition(ccp(display.width/2, display.height/2))
			end
		end, function ()
			self:sunOnTriggerClose(true)
		end)
	end
end

function QUIDialogMaritimeProtect:_onTriggerGoUnion()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnion", options = {initButton = "onTriggerJoin"}})
end

function QUIDialogMaritimeProtect:_backClickHandler()
    self:sunOnTriggerClose()
end

function QUIDialogMaritimeProtect:sunOnTriggerClose(noSound)

	if noSound ~= true then
		app.sound:playSound("common_close")
	end
	self:playEffectOut()
end

function QUIDialogMaritimeProtect:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end	
	self:playEffectOut()
end

function QUIDialogMaritimeProtect:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()
	if callback then
		callback()
	end
end


return QUIDialogMaritimeProtect
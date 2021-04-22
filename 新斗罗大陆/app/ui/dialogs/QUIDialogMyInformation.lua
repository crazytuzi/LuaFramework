--
-- Author: xurui
-- Date: 2016-8-28
--
local QUIDialog = import(".QUIDialog")
local QUIDialogMyInformation = class("QUIDialogMyInformation", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogChooseHead = import("..dialogs.QUIDialogChooseHead")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetMyInformation = import("..widgets.QUIWidgetMyInformation")
local QUIWidgetSystemSetting = import("..widgets.QUIWidgetSystemSetting")
local QUIWidgetChatSetting = import("..widgets.QUIWidgetChatSetting")
local QUIWidgetSelectBtn = import("..widgets.QUIWidgetSelectBtn")
local QScrollView = import("...views.QScrollView") 
local QListView = import("...views.QListView")

QUIDialogMyInformation.TAB_USER_INFO = "TAB_USER_INFO"
QUIDialogMyInformation.TAB_SYSTEM_SET = "TAB_SYSTEM_SET"
QUIDialogMyInformation.TAB_CHAT_SET = "TAB_CHAT_SET"

function QUIDialogMyInformation:ctor(options)
	local ccbFile = "ccb/Dialog_Rongyao_wanjia.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
		{ccbCallbackName = "onTriggerSystem", callback = handler(self, self._onTriggerSystem)},
		{ccbCallbackName = "onTriggerChat", callback = handler(self, self._onTriggerChat)},
	}
	QUIDialogMyInformation.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page.topBar:showWithHeroOverView()

	local btnList = {
		{id = 1, btnName = "玩家信息", btnType = QUIDialogMyInformation.TAB_USER_INFO, isOpen = true},
		{id = 2, btnName = "系统设置", btnType = QUIDialogMyInformation.TAB_SYSTEM_SET, isOpen = true},
		{id = 3, btnName = "动态设置", btnType = QUIDialogMyInformation.TAB_CHAT_SET, isOpen = remote.userDynamic:checkDynamicUnlock()},
	}
	self._btnList = {}
	for i, btn in pairs(btnList) do
		if btn.isOpen then
			table.insert(self._btnList, btn)
		end
	end

	self._ccbOwner.frame_tf_title:setString("我的信息")
	self._tabType = options.tab or QUIDialogMyInformation.TAB_USER_INFO
	
	self._currentPage = nil
	self:setScrollView()
end

function QUIDialogMyInformation:viewDidAppear()
	QUIDialogMyInformation.super.viewDidAppear(self)

   	self._headPropProxy = cc.EventProxy.new(remote.headProp)
	self._headPropProxy:addEventListener(remote.headProp.AVATAR_CHANGE, handler(self, self.onEvent))

    self._bindingPhoneProxy = cc.EventProxy.new(remote.bindingPhone)
    self._bindingPhoneProxy:addEventListener(remote.bindingPhone.EVENT_UPDATE_BINDINGPHONE, handler(self, self.checkRedTip))

    QNotificationCenter.sharedNotificationCenter():addEventListener("QUIDialogMyInformation_OpenScrollViewTouch", self.changeScrollViewTouch, self)

	self:selectTab()

	self:addBackEvent(true)
end 

function QUIDialogMyInformation:viewWillDisappear()
	QUIDialogMyInformation.super.viewWillDisappear(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener("QUIDialogMyInformation_OpenScrollViewTouch", self.changeScrollViewTouch, self)
	if self._headPropProxy then
		self._headPropProxy:removeAllEventListeners()
	end

	if self._bindingPhoneProxy then
    	self._bindingPhoneProxy:removeAllEventListeners()
   		self._bindingPhoneProxy = nil
	end
	
	self:removeBackEvent()
end 

function QUIDialogMyInformation:changeScrollViewTouch(event)
    if event == nil or event.actorView ~= self._heroView then
        return
    end	
	local eventOpen = event.open or 1
	print("eventOpen"..eventOpen)
	self._scrollView:setTouchState(eventOpen == 1)
end

function QUIDialogMyInformation:initBtnListView()
	for i, v in pairs(self._btnList) do
		v.isSelected = self._tabType == v.btnType
		v.isTips = self:checkRedTip(v.id)
	end
	-- body
	if not self._btnlistViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._btnList[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetSelectBtn.new()
            		item:addEventListener(QUIWidgetSelectBtn.EVENT_CLICK, handler(self, self.btnItemClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
	            return isCacheNode
	        end,
	        curOriginOffset = 5,
	        curOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 5,
	        totalNumber = #self._btnList,
		}
		self._btnlistViewLayout = QListView.new(self._ccbOwner.sheet_menu,cfg)
	else
		self._btnlistViewLayout:reload({totalNumber = #self._btnList})
	end
end

function QUIDialogMyInformation:setScrollView()
	self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._ccbOwner.sheet_layout:getContentSize(), {sensitiveDistance = 10})
	-- self._scrollView:setGradient(true)
	self._scrollView:setVerticalBounce(true)
end

function QUIDialogMyInformation:btnItemClickHandler(event)
	local info = event.info or {}
	local btnType = QUIDialogMyInformation.TAB_USER_INFO
	for i, v in pairs(self._btnList) do
		if v.id == info.id then
			btnType = v.btnType
			break
		end
	end
	self._tabType = btnType
	self:selectTab()
end

function QUIDialogMyInformation:selectTab()
	if self._currentPage then
		self._currentPage:setVisible(false)
	end

	if self._tabType == QUIDialogMyInformation.TAB_USER_INFO then
		if self._infoClient == nil then
			self._infoClient = QUIWidgetMyInformation.new()
			self._ccbOwner.client_node:addChild(self._infoClient)
		end
		self._infoClient:setVisible(true)
		self._infoClient:setUserInfo()
		self._currentPage = self._infoClient
	elseif self._tabType == QUIDialogMyInformation.TAB_SYSTEM_SET then 
		if self._systemInfo == nil then
			self._systemInfo = QUIWidgetSystemSetting.new()
			self._scrollView:addItemBox(self._systemInfo)
			local contentSzie = self._systemInfo:getContentSize()
			self._systemInfo:setPositionX(-5)
			self._scrollView:setRect(0, -contentSzie.height, 0, 0)	
		end
		self._systemInfo:setVisible(true)
		self._currentPage = self._systemInfo
	elseif self._tabType == QUIDialogMyInformation.TAB_CHAT_SET then 
		if self._chatSetting == nil then
			self._chatSetting = QUIWidgetChatSetting.new()
			self._ccbOwner.client_node:addChild(self._chatSetting)
		end
		self._chatSetting:setVisible(true)
		self._chatSetting:setInfo()
		self._currentPage = self._chatSetting
	end

	self:checkRedTip()
	self:initBtnListView()
end

function QUIDialogMyInformation:checkRedTip(id)
	if id == 2 then
		return remote.bindingPhone:checkRedTips()
	end
	return false
end

function QUIDialogMyInformation:onEvent(event)
	if event.name == remote.headProp.AVATAR_CHANGE then 
		if self:safeCheck() and self._infoClient ~= nil then
	    	self._infoClient:setAvatar()
	    end
	end
end

function QUIDialogMyInformation:onTriggerBackHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMyInformation:onTriggerHomeHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogMyInformation
-- @Author: liaoxianbo
-- @Date:   2020-10-23 17:03:00
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-11-04 11:54:55
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityCustomShop = class("QUIDialogActivityCustomShop", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetCustomShopContent = import("..widgets.QUIWidgetCustomShopContent")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIDialogActivityCustomShop.PAID_GIFT = 1 --付费礼包
QUIDialogActivityCustomShop.TOKEN_GIFT = 2 --钻石礼包

function QUIDialogActivityCustomShop:ctor(options)
	local ccbFile = "ccb/Dialog_Custom_shop_main.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerTokenTab", callback = handler(self, self._onTriggerTokenTab)},
		{ccbCallbackName = "onTriggerPaidTab", callback = handler(self, self._onTriggerPaidTab)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
    }
    QUIDialogActivityCustomShop.super.ctor(self, ccbFile, callBacks, options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
    if page.topBar and page.topBar.showWithMainPage then
    	page.topBar:showWithMainPage()
    end
    

    CalculateUIBgSize(self._ccbOwner.sp_bg)
    q.setButtonEnableShadow(self._ccbOwner.btn_help)
    
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self._curtentTab = options.curtentTab or QUIDialogActivityCustomShop.PAID_GIFT


	self._customShopModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.CUSTOM_SHOP)
	self._allitemList = self._customShopModule:getCustomShopList() or {}
	self._curtentItemList = {}
	self:updateData(self._curtentTab)

	self:setTimeCountdown()
end

function QUIDialogActivityCustomShop:updateData(tab)
	self._curtentTab = tab
	local options = self:getOptions()
	options.curtentTab = self._curtentTab

	self:setBtnState()
	self._curtentItemList = {}
	for _,v in pairs(self._allitemList) do
		if tab == v.type then
			local itemInfo = self._customShopModule:analyGiftInfoServerItem(v)
			if q.isEmpty(itemInfo) == false then
				table.insert(self._curtentItemList,itemInfo)
			end
		end
	end

	table.sort( self._curtentItemList, function(a,b)
		if a.sellout ~= b.sellout then
			return a.sellout == false
		elseif a.itemConfig and b.itemConfig then
			local idA = a.itemConfig.id
			local idB = b.itemConfig.id

			if idA~= idB then
				return idA < idB
			end
		end
	end )

	self:_initListView()
end

function QUIDialogActivityCustomShop:viewDidAppear()
	QUIDialogActivityCustomShop.super.viewDidAppear(self)

  	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.CUSTOM_SHOP_UPDATE, handler(self, self.updateInfo))
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.CUSTOM_SHOP_ACTIVITY_CLOSE, handler(self, self.closeCustomShop))

	self:addBackEvent(true)
	
end

function QUIDialogActivityCustomShop:viewWillDisappear()
  	QUIDialogActivityCustomShop.super.viewWillDisappear(self)

	self:removeBackEvent()

    if self._activityRoundsEventProxy ~= nil then
        self._activityRoundsEventProxy:removeAllEventListeners()
        self._activityRoundsEventProxy = nil
    end
end

function QUIDialogActivityCustomShop:closeCustomShop(  )
	app.tip:floatTip("魂师大人，当前活动已结束")
	self:popSelf()
end
function QUIDialogActivityCustomShop:setTimeCountdown()
    local timeStr = ""
    local startTimeTbl = q.date("*t", (self._customShopModule.startAt or 0))
    local endTimeTbl = q.date("*t", (self._customShopModule.endAt or 0))
    timeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
        startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
        endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min)
    self._ccbOwner.tf_lastTime:setString(timeStr)
    q.autoLayerNode({self._ccbOwner.tf_lastTime,self._ccbOwner.btn_help},"x",5)
end

function QUIDialogActivityCustomShop:updateInfo( )		
	self:updateData(self._curtentTab)
	self:_initListView()
end

function QUIDialogActivityCustomShop:_initListView()
	if not self._listView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._curtentItemList[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetCustomShopContent.new()

	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()
	            list:unRegisterTouchHandler(index)
	            list:registerBtnHandler(index, "btn_buy", "onTriggerBuy", nil, true)
	            list:registerBtnHandler(index, "btn_click", "onTriggerClick", nil, true)
	            return isCacheNode
	        end,
	        spaceX = -8,
	        enableShadow = true,
	        leftShadow = self._ccbOwner.sp_left,
	        rightShadow = self._ccbOwner.sp_right,	        
	        isVertical = false,
	        totalNumber = #self._curtentItemList,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listView:reload({totalNumber = #self._curtentItemList})
	end
end

function QUIDialogActivityCustomShop:setBtnState()
    self._ccbOwner.btn_fflb:setEnabled(self._curtentTab ~= self.PAID_GIFT)
    self._ccbOwner.btn_fflb:setHighlighted(self._curtentTab == self.PAID_GIFT)
    self._ccbOwner.btn_zslb:setEnabled(self._curtentTab ~= self.TOKEN_GIFT)
    self._ccbOwner.btn_zslb:setHighlighted(self._curtentTab == self.TOKEN_GIFT)
end

function QUIDialogActivityCustomShop:_onTriggerTokenTab( )
	if self._curtentTab == self.TOKEN_GIFT then
		return
	end
	
	self:updateData(self.TOKEN_GIFT)
end

function QUIDialogActivityCustomShop:_onTriggerPaidTab( )
	if self._curtentTab == self.PAID_GIFT then
		return
	end
	self:updateData(self.PAID_GIFT)
end

function QUIDialogActivityCustomShop:_onTriggerHelp()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogCustomShopRule"})
end

function QUIDialogActivityCustomShop:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogActivityCustomShop

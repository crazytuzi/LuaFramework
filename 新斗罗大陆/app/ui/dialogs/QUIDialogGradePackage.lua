-- @Author: liaoxianbo
-- @Date:   2019-07-08 10:34:41
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-07 14:43:18
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGradePackage = class("QUIDialogGradePackage", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGradePackage = import("..widgets.QUIWidgetGradePackage")
local QUIWidgetGradePackageButton = import("..widgets.QUIWidgetGradePackageButton")
local QPayUtil = import("...utils.QPayUtil")
local QListView = import("...views.QListView")

function QUIDialogGradePackage:ctor(options)
	local ccbFile = "ccb/Dialog_activity_gradepackage.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogGradePackage.super.ctor(self, ccbFile, callBacks, options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page:setScalingVisible(true)
    page.topBar:showWithMainPage()

    if options then
    	self._callBack = options.callBack
    end
    self._curSelectBtnIndex = 1

    self:_init()
    self:initBtnListView()
end

function QUIDialogGradePackage:viewDidAppear()
	QUIDialogGradePackage.super.viewDidAppear(self)
	-- self:addBackEvent(true)
	self:addBackEvent(false)

    self._gradePackageProxy = cc.EventProxy.new(remote.gradePackage)
    self._gradePackageProxy:addEventListener(remote.gradePackage.EVENT_RECHARGE, handler(self, self.rechargedSucess))
end

function QUIDialogGradePackage:viewWillDisappear()
  	QUIDialogGradePackage.super.viewWillDisappear(self)

	self:removeBackEvent()

    if self._gradePackageProxy ~= nil then 
        self._gradePackageProxy:removeAllEventListeners()
        self._gradePackageProxy = nil
    end

    if self._rechargeProgress then
    	scheduler.unscheduleGlobal(self._rechargeProgress)
    	self._rechargeProgress = nil
    end
end

function QUIDialogGradePackage:_init()
	--切圖
	local size = self._ccbOwner.node_menu_bg_mask:getContentSize()
	local lyImageMask = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
	local ccclippingNode = CCClippingNode:create()
	lyImageMask:setPositionX(self._ccbOwner.node_menu_bg_mask:getPositionX())
	lyImageMask:setPositionY(self._ccbOwner.node_menu_bg_mask:getPositionY())
	lyImageMask:ignoreAnchorPointForPosition(self._ccbOwner.node_menu_bg_mask:isIgnoreAnchorPointForPosition())
	lyImageMask:setAnchorPoint(self._ccbOwner.node_menu_bg_mask:getAnchorPoint())
	ccclippingNode:setStencil(lyImageMask)
	ccclippingNode:setInverted(false)
	self._ccbOwner.sp_menu_bg:retain()
	self._ccbOwner.sp_menu_bg:removeFromParent()
	ccclippingNode:addChild(self._ccbOwner.sp_menu_bg)
	self._ccbOwner.node_menu_bg:addChild(ccclippingNode)
	self._ccbOwner.sp_menu_bg:release()
end

function QUIDialogGradePackage:initBtnListView( recharge)
	self._data = remote.gradePackage:getGradePackageInfo()
	if not self._data or next(self._data) == nil then
		self:popSelf()
		return
	end
	if recharge ~= true then
		self._curSelectBtnIndex = 1
	end
	if not self._btnListView then
	    -- body
	    local clickBtnItemHandler = handler(self, self.onClickBtnItem)
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._data[index]
	            if not item then
	                item = QUIWidgetGradePackageButton.new()
	                isCacheNode = false
	            end
	            item:setInfo(data)
	            info.item = item
	            info.size = item:getContentSize()

	            list:registerBtnHandler(index, "btn_click", clickBtnItemHandler)
	            
	            if self._curSelectBtnIndex == index then
	                item:setSelect(true)
	            else
	                item:setSelect(false)
	            end
	            return isCacheNode
	        end,
	        headIndex = self._curSelectBtnIndex,
	        -- spaceY = 25,
	        enableShadow = false,
	        ignoreCanDrag = true,
	        totalNumber = #self._data,
	        curOffset = 20,
	    }  
	    self._btnListView = QListView.new(self._ccbOwner.node_menu_list_view, cfg)
	else
		self._btnListView:reload({totalNumber = #self._data})
	end
   
    if #self._data > 0 then
    	if recharge then
    		if self._curSelectBtnIndex > 8 then
    			self._btnListView:startScrollToIndex(self._curSelectBtnIndex, false, 100)
    		end
    	-- else
    	-- 	self._curSelectBtnIndex = 1
    	end
        self:refreshContent()
    end
end


function QUIDialogGradePackage:onClickBtnItem( x, y, touchNode, listView )
    app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()

    if self._curSelectBtnIndex and self._curSelectBtnIndex ~= touchIndex then
        local oldItem = listView:getItemByIndex(self._curSelectBtnIndex)
        if oldItem then
            oldItem:setSelect(false)
        end
    end

    local item = listView:getItemByIndex(touchIndex)
    if item then
        item:setSelect(true)
    end

    if self._curSelectBtnIndex ~= touchIndex then
        self._curSelectBtnIndex = touchIndex
        remote.gradePackage.showSelectBtnIndex = touchIndex
        self:refreshContent()
    end
end

function QUIDialogGradePackage:refreshContent()
    self._ccbOwner.node_other:setVisible(true)

    if self._contentWidget ~= nil then
        self._ccbOwner.node_other:removeChild(self._contentWidget)
        self._contentWidget = nil
    end
    local btnItemInfo = self._data[self._curSelectBtnIndex]

    if btnItemInfo then
		self._selectInfo = remote.gradePackage:getContentListByKey(btnItemInfo.btnLimtLevel)
	else
		self._selectInfo = {}
	end

	self._contentWidget = QUIWidgetGradePackage.new()
    self._ccbOwner.node_other:addChild(self._contentWidget)
    self._contentWidget:setInfo(self._selectInfo,btnItemInfo.unlockTime,self)
end


function QUIDialogGradePackage:fastBuy(price,itemId)
	if price == nil or price == 0 then return end
	app.sound:playSound("common_small")

	if ENABLE_CHARGE_BY_WEB and CHARGE_WEB_URL then
		QPayUtil.payOffine(price, 4,itemId)
	else
		app:showLoading()
	    if self._rechargeProgress then
	    	scheduler.unscheduleGlobal(self._rechargeProgress)
	    	self._rechargeProgress = nil
	    end
		self._rechargeProgress = scheduler.performWithDelayGlobal(function ( ... )
			app:hideLoading()
		end, 5)
		if FinalSDK.isHXIOS() then
			QPayUtil:hjPayOffline(price, 4, nil,itemId)
		else
			QPayUtil:pay(price, 4, nil,itemId)
		end
	end
	-- self:popSelf()
end

function QUIDialogGradePackage:rechargedSucess(event)
	local id = event.itemId 
	local itemInfo = QStaticDatabase.sharedDatabase():getLevelRewardInfoById(id)
	if itemInfo and itemInfo.reward then

		local rewardId = itemInfo.reward

		local s, e = string.find(rewardId, "%^")
		local itemId = string.sub(rewardId, 1, s - 1)
		local count = string.sub(rewardId, e + 1)
		local itemType = remote.items:getItemType(itemId)
		local awards = {}
		if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
			table.insert(awards, {id = itemId, typeName = itemType, count = tonumber(count)})
		else
			table.insert(awards, {id = itemId, typeName = ITEM_TYPE.ITEM, count = tonumber(count)})
		end
		remote.gradePackage:requestGetGradePackage(id,itemInfo.exchange_num,function(data)
			if self:safeCheck() then
				self:initBtnListView(true)
		        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		        options = {awards = awards}},{isPopCurrentDialog = false} )
		        dialog:setTitle("")	
	       	end		
		end)
	end	

end
function QUIDialogGradePackage:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGradePackage:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogGradePackage

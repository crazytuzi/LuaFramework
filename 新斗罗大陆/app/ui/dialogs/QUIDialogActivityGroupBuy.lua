--
-- zxs
-- 团购
--
local QUIDialog = import(".QUIDialog")
local QUIDialogActivityGroupBuy = class("QUIDialogActivityGroupBuy", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActivityGroupBuy = import("..widgets.QUIWidgetActivityGroupBuy")
local QUIWidgetActivityGroupBuyButton = import("..widgets.QUIWidgetActivityGroupBuyButton")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")

--初始化
function QUIDialogActivityGroupBuy:ctor(options)
	local ccbFile = "Dialog_Groupbuy_Main.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerScore", callback = handler(self, QUIDialogActivityGroupBuy._onTriggerScore)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, QUIDialogActivityGroupBuy._onTriggerRule)},
	}
	QUIDialogActivityGroupBuy.super.ctor(self,ccbFile,callBacks,options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page:setScalingVisible(false)
	if page.topBar then
   	 	page.topBar:showWithMainPage()
   	end

	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITYGROUPBUY) then
		app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITYGROUPBUY)
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.GROUPBUY_UPDATE})
	end

   	self._lastItemNum = 0
	self._curIndex = options.curIndex or 1
	self._groupBuy = remote.activityRounds:getGroupBuy()
	self:render()
end

function QUIDialogActivityGroupBuy:viewDidAppear()
	QUIDialogActivityGroupBuy.super.viewDidAppear(self)
	self:addBackEvent(false)
	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.GROUPBUY_UPDATE, handler(self, self.updateData))
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.GROUPBUY_GOODSCHANGE, handler(self, self.onGoodsChange))
end

function QUIDialogActivityGroupBuy:viewWillDisappear()
	QUIDialogActivityGroupBuy.super.viewWillDisappear(self)
	self:removeBackEvent()
	self._activityRoundsEventProxy:removeAllEventListeners()
	self._activityRoundsEventProxy = nil
	
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

function QUIDialogActivityGroupBuy:render( )
	self:initListView()
	self:refreshContent()

	self._ccbOwner.node_arrow:setVisible(false)
	if #self._data > 4 then
		self._ccbOwner.node_arrow:setVisible(true)
	end
end

function QUIDialogActivityGroupBuy:initListView()
	self._data = self._groupBuy:getData().goodsInfo or {}
	if not self._listView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._data[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetActivityGroupBuyButton.new()
	                isCacheNode = false
	            end

	            local isSelected = false
	            if self._curIndex == index then
	            	isSelected = true
	            end
	            item:setInfo(data, isSelected)
	           
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_click", handler(self, self.selectItem))

	            return isCacheNode
	        end,
	     	curOffset = -10,
	     	-- curOriginOffset = 10,
	      	spaceY = 0,
	        enableShadow = false,
	        headIndex = self._curIndex,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
	        contentOffsetX = 8,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
		self._lastItemNum = #self._data
	else
		if self._lastItemNum == #self._data then
			self._listView:refreshData() 
		else
			self._listView:reload({totalNumber = #self._data, headIndex = self._curIndex}) 
			self._lastItemNum = #self._data
		end
	end
end

function QUIDialogActivityGroupBuy:selectItem( x, y, touchNode, listView )
	app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()

    if self._curIndex and self._curIndex ~= touchIndex then
        local oldItem = listView:getItemByIndex(self._curIndex)
        if oldItem then
            oldItem:setSelected(false)
        end
    end

    local item = listView:getItemByIndex(touchIndex)
    if item then
        item:setSelected(true)
    end

    if self._curIndex ~= touchIndex then
        self._curIndex = touchIndex
        self:refreshContent()
    end
end

function QUIDialogActivityGroupBuy:refreshContent(  )
	local curData = self._data[self._curIndex] or {}
	if not curData.price then
		return 
	end

	local groupData = self._groupBuy:getData()
	if not self._content then
		self._content = QUIWidgetActivityGroupBuy.new()
		self._ccbOwner.node_info:addChild(self._content)
	end
	self._content:setInfo(curData)	

	self:updateGroupData()

	local isRed = self._groupBuy:checkScoreRedTips()
	self._ccbOwner.sp_red_tips:setVisible(isRed)
end

function QUIDialogActivityGroupBuy:updateData( event )
	self._groupBuy = remote.activityRounds:getGroupBuy()
	if self._groupBuy.isOpen == false then
		app:alert({content = "该活动下线了", title = "系统提示", callback = function (  )
            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
        end},false,true)
	end

	self:render()
end

function QUIDialogActivityGroupBuy:updateGroupData()
    local groupData = self._groupBuy:getData()
	local date = q.date("*t", groupData.endAt)
	if self._groupBuy.isActivityNotEnd == false then
		date = q.date("*t", groupData.showEndAt)
		self._ccbOwner.tf_time_desc:setString("领奖结束时间：")
	else
		self._ccbOwner.tf_time_desc:setString("购买结束时间：")
	end
	self._ccbOwner.tf_time:setString(string.format("%s月%s日%s:%s分", date.month, date.day, date.hour, date.min))
	self._ccbOwner.tf_score:setString(groupData.curScore)
end

function QUIDialogActivityGroupBuy:onGoodsChange()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._scheduler = scheduler.performWithDelayGlobal(function ()
		local groupBuy = remote.activityRounds:getGroupBuy()
		if groupBuy and groupBuy.isOpen and groupBuy.isActivityNotEnd then
			groupBuy:groupBuyInfoChange()
		end
	end, 1)
	
end

function QUIDialogActivityGroupBuy:_onTriggerScore()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogActivityGroupBuyScore"})
end

function QUIDialogActivityGroupBuy:_onTriggerRule()
 	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityGroupBuyHelp", 
        options = {}})
end

return QUIDialogActivityGroupBuy

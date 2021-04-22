--[[	
	文件名称：QUIWidgetActivityFundAward.lua
	创建时间：2017-01-18 14:25:27
	作者：nieming
	描述：QUIWidgetActivityFundAward
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityFundAward = class("QUIWidgetActivityFundAward", QUIWidget)
local QListView = import("...views.QListView")
local QUIWidgetActivityMonthFundItem = import(".QUIWidgetActivityMonthFundItem")
local QUIViewController = import("...ui.QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIWidgetActivityFundAward:ctor(options)
	local ccbFile = "Widget_jijinfali.ccbi"
	local callBacks = {
	}
	QUIWidgetActivityFundAward.super.ctor(self,ccbFile,callBacks,options)
	if not options then
   		options = {}
   	end
    
    self.parent = options.parent
    if self.parent then
    	self.originDistance = self.parent:getOptions().monthFundDistance
    end

    -- modify by Kumo。月基金可領取獎勵從活動開始時間算，因此這裡的時間顯示也從原來的領獎開始時間變為活動開始時間。
	self._ccbOwner.activityTime:setString(string.format("%s~%s", q.timeToMonthDayHourMin(remote.activityMonthFund.startTime), q.timeToMonthDayHourMin(remote.activityMonthFund.endTime)))
	self._data = {}
end

function QUIWidgetActivityFundAward:setInfo(info)
	self.info = info
    local richTextNode = QRichText.new(nil, 700)
	if self.info.activityId == remote.activityMonthFund.TYPE_1 then
		-- richTextNode:setString({
  --           {oType = "font", content = "双月卡魂师",size = 20,color = ccc3(255,255,255)},
  --           {oType = "font", content = "仅单笔充值268元", size = 20,color = ccc3(0,251,0)},
  --           {oType = "font", content = "即可领取月基金（立即返利", size = 20,color = ccc3(255,255,255)},
  --           {oType = "font", content = "2000钻石", size = 20,color = ccc3(0,251,0)},
  --           {oType = "font", content = "，活动期间可累计获得价值", size = 20,color = ccc3(255,255,255)},
  --           {oType = "font", content = "30倍", size = 20,color = ccc3(0,251,0)},
  --           {oType = "font", content = "的资源返利！）",size = 20,color = ccc3(255,255,255)},
  --       })
        richTextNode:setString({
            {oType = "font", content = "20天内，每天激活一份可领取奖励，每份奖励仅可领取一次。",size = 20,color = ccc3(255,255,255)},
        })
    elseif self.info.activityId == remote.activityMonthFund.TYPE_2 then
	    -- richTextNode:setString({
     --        {oType = "font", content = "双月卡用户",size = 20,color = ccc3(255,255,255)},
     --        {oType = "font", content = "仅单笔充值128元", size = 20,color = ccc3(0,251,0)},
     --        {oType = "font", content = "即可领取月基金（立即返利", size = 20,color = ccc3(255,255,255)},
     --        {oType = "font", content = "1000钻石", size = 20,color = ccc3(0,251,0)},
     --        {oType = "font", content = "，活动期间可累计获得价值", size = 20,color = ccc3(255,255,255)},
     --        {oType = "font", content = "3800元", size = 20,color = ccc3(0,251,0)},
     --        {oType = "font", content = "的资源返利！）",size = 20,color = ccc3(255,255,255)},
	    --     })
	    richTextNode:setString({
            {oType = "font", content = "20天内，每天激活一份可领取奖励，每份奖励仅可领取一次。",size = 20,color = ccc3(255,255,255)},
        })
	end

	richTextNode:setPositionY(-richTextNode:getContentSize().height)
	self._ccbOwner.richText:addChild(richTextNode)
	self._data = remote.activityMonthFund:getAwardsList(self.info.activityId)

	if self.parent then
    	self.originDistance = self.parent:getOptions().monthFundDistance
    end
	self:initListView()
end

function QUIWidgetActivityFundAward:clickItem( x, y, touchNode, listView )
    app.sound:playSound("common_switch")

    local touchIndex = listView:getCurTouchIndex()
    local data = self._data[touchIndex]
    local item = listView:getItemByIndex(touchIndex)

    if self.parent then
    	self.parent:getOptions().monthFundDistance = listView:getItemPosToTopDistance(touchIndex)
    end

    local awards = {}
    table.insert( awards, data.award )
    
    local loginDays = remote.activityMonthFund:getLoginDays()
    if loginDays >= data.awardIndex and not remote.activityMonthFund:isTakenAward(self.info.activityId, data.awardIndex) then
		remote.activityMonthFund:getAwards(data.awardIndex, self.info.activityId,function ( )
			local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards}},{isPopCurrentDialog = false} )
			dialog:setTitle("恭喜您获得基金返利奖励")
		end)
	else
		app.tip:itemTip(item._itemBox._itemType, item._itemBox._itemID)
	end

end

function QUIWidgetActivityFundAward:initListView(  )
	local selectIndex = 1
	for i = 1, #self._data do
		if remote.activityMonthFund:isTakenAward(self.info.activityId, self._data[i].awardIndex) == nil then
			selectIndex = i
			break
		end
	end
	selectIndex = selectIndex > #self._data and #self._data or selectIndex

	if not self._awardListView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	          	local data = self._data[index]

	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetActivityMonthFundItem.new({activityId = self.info.activityId})
	                isCacheNode = false
	            end
	            item:setInfo(data)
	            info.item = item
	            info.size = item:getContentSize()
	            --注册事件
                -- list:registerItemBoxPrompt(index, 1, item._itemBox, nil)
                list:registerBtnHandler(index, "bg_2", handler(self, self.clickItem))
	         
	            return isCacheNode
	        end,
	        multiItems = 7,
	        isVertical = true,
	        spaceX = -10,
	        spaceY = -3,
	        contentOffsetX = -5,
	        enableShadow = false,
	        totalNumber = #self._data,
	    }  
    	self._awardListView = QListView.new(self._ccbOwner.listViewLayer,cfg)
	else
		self._awardListView:reload({totalNumber = #self._data, headIndexPosOffset = self.originDistance})
	end
	self._awardListView:startScrollToIndex(selectIndex, false, 500)
end

function QUIWidgetActivityFundAward:onEnter()
	self:initListView()
end

return QUIWidgetActivityFundAward

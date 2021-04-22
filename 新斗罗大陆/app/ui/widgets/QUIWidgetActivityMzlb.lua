-- @Author: liaoxianbo
-- @Date:   2019-06-03 15:41:14
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-11-06 15:22:26
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityMzlb = class("QUIWidgetActivityMzlb", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QActivity = import("...utils.QActivity")
local QListView = import("...views.QListView")
local QUIWidgetActivityMzlbCell = import("..widgets.QUIWidgetActivityMzlbCell")

function QUIWidgetActivityMzlb:ctor(options)
	local ccbFile = "ccb/Widget_Activity_mzlb.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetActivityMzlb.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	remote.activityVipGift:updateRecord()
	remote.activityVipGift:hideWeekVipGiftTips()

	app:getUserOperateRecord():recordeCurrentTime("activity_"..QActivity.TYPE_VIP_GIFT_WEEK)

end

function QUIWidgetActivityMzlb:setInfo()

	self._weekRecord = remote.activityVipGift:getWeekRecord()
	
	local vipgiftList = db:getVipGiftWeekList()
	local curentvipLevel = app.vipUtil:VIPLevel()
    self._vipGiftWeeklist = {}
    self._canBuyGiftWeek = {}
    self._yiGoumaiWeekGift = {}
    for _,value in pairs(vipgiftList) do
    	local isRecord = false
    	for _,record in pairs(self._weekRecord) do
    		if tonumber(value.id) == tonumber(record.id) then
    			isRecord = true
    			local lastBuyTime = tonumber(value.exchange_number) - tonumber(record.count) 
    			if lastBuyTime <= 0 then
    				table.insert(self._yiGoumaiWeekGift,value)
    			else
    				table.insert(self._canBuyGiftWeek,value)
    			end
    		end
    	end
    	if not isRecord then
    		table.insert(self._canBuyGiftWeek,value)
    	end
    end
    table.sort(self._canBuyGiftWeek,function(a,b) 
    	return tonumber(a.vip_id) < tonumber(b.vip_id) 
    end)

    table.sort(self._yiGoumaiWeekGift,function(a,b) 
    	return tonumber(a.vip_id) < tonumber(b.vip_id) 
    end)

    self._vipGiftWeeklist = self._canBuyGiftWeek 

    for _,value in pairs(self._yiGoumaiWeekGift) do
      	table.insert(self._vipGiftWeeklist,value)
    end  
    
	self:initListView()
end

function QUIWidgetActivityMzlb:initListView()
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._vipGiftWeeklist[index]

	            local item = list:getItemFromCache(data.oType)
	            if not item then
	                item = QUIWidgetActivityMzlbCell.new()
	                isCacheNode = false
	            end
	            item:addEventListener(QUIWidgetActivityMzlbCell.UPDATE_BUYSTATE, handler(self, self._onEvent))
	            item:setInfo(data,self)
                info.item = item
                info.size = item:getContentSize()
                item:registerItemBoxPrompt(index, list)
                list:registerTouchHandler(index,"onTouchListView")
                list:registerBtnHandler(index, "btn_ok", "onTriggerBuy", nil, true)
	            return isCacheNode
	        end,
        	spaceY = 2,
	        isVertical = true,
	        enableShadow = false,
	        totalNumber = #self._vipGiftWeeklist,
	    }  
		self._listView = QListView.new(self._ccbOwner.content_sheet_layout,cfg)
	else
		self._listView:refreshData()
	end 
end

function QUIWidgetActivityMzlb:getContentListView()
	return self._listView
end
function QUIWidgetActivityMzlb:_onEvent(event)
	if event.name == QUIWidgetActivityMzlbCell.UPDATE_BUYSTATE then
		remote.activityVipGift:requestByMyVipWeekGift(event.index,function(data)
			if self:getCCBView() then
			    remote.activityVipGift:switchRecord(data.vipGiftWeekBuyResponse)
			    self:setInfo()
			    self:_showVipWeekGiftAwrdsInfo(event.awards)
			end

		end,function()
			app.tip:floatTip("购买失败",100)
		end)
	end
end

function QUIWidgetActivityMzlb:_showVipWeekGiftAwrdsInfo(awards)
	if awards == nil or next(awards) == nil then return end
	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = awards, isSort = true ,callBack = nil}}, {isPopCurrentDialog = false} )	    
    dialog:setTitle("")
end

function QUIWidgetActivityMzlb:onEnter()
end

function QUIWidgetActivityMzlb:onExit()
end

function QUIWidgetActivityMzlb:getContentSize()
end

return QUIWidgetActivityMzlb

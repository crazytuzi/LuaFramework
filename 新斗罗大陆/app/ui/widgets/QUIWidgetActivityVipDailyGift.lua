-- @Author: liaoxianbo
-- @Date:   2019-05-31 17:06:53
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-01 15:10:29
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityVipDailyGift = class("QUIWidgetActivityVipDailyGift", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetActivityVipDailyGift:ctor(options)
	local ccbFile = "ccb/Widget_Activity_mzfl.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerYulan", callback = handler(self,self._onTriggerYulan)},
    }
    QUIWidgetActivityVipDailyGift.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	remote.activityVipGift:updateRecord()
	self._dailyRecord = remote.activityVipGift:getDailyRecord()
	self:checkReadTips()

end

function QUIWidgetActivityVipDailyGift:checkReadTips()

	local curentvipLevel = app.vipUtil:VIPLevel()
	local notGetVipgift = false
	for _,value in pairs(self._dailyRecord) do
		if tonumber(value.count) > 0 then
			notGetVipgift = true
			break
		end
	end
	self:updateBtnState(notGetVipgift)
end

function QUIWidgetActivityVipDailyGift:setInfo()
	local vipLevel = app.vipUtil:VIPLevel()
	self._ccbOwner.tf_vip_level:setString(string.format("VIP%d",vipLevel))
	local giftList = db:getVipGiftDailyListByLevel(vipLevel)
	self._awards = self:switchAwards(giftList)
	self:showAwards()
end

function QUIWidgetActivityVipDailyGift:showAwards()
	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			-- body
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemBox._itemID)
			if itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
				local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId( itemBox._itemID )
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroDetailInfoNew", options = {actorId = actorId}}, {isPopCurrentDialog = false})
			else
				app.tip:itemTip(itemBox._itemType, itemBox._itemID)
			end
		end

		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._awards[index]

	            local item = list:getItemFromCache(data.oType)
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end
	            self:setItemInfo(item,data,index)
                info.item = item
                info.size = item._ccbOwner.parentNode:getContentSize()
	            --注册事件
	            list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        curOriginOffset = 6,
	        isVertical = false,
	        autoCenter = true,
	        enableShadow = false,
	        totalNumber = #self._awards,

	    }  
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._awards})
	end 
end

function QUIWidgetActivityVipDailyGift:setItemInfo( item, data ,index)
	if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setPosition(ccp(48,57))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,110))

	end
	local id = data.id 
	local count = tonumber(data.count)
	local itemType = remote.items:getItemType(id)

	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		item._itemBox:setGoodsInfo(id, itemType, count)

	else
		item._itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)
		if data.isNeedShowItemCount then
			local num = remote.items:getItemsNumByID(id) or 0
			item._itemBox:setItemCount(string.format("%d/%d",num, count))
		end

	end
end

function QUIWidgetActivityVipDailyGift:switchAwards( giftList )
	if not giftList or table.nums(giftList) == 0 then return end
	local a = string.split(giftList.awards, ";")
    local tbl = {}
    local awardList = {}
    for _, value in pairs(a) do
        tbl = {}
        local s, e = string.find(value, "%^")
        local idOrType = string.sub(value, 1, s - 1)
        local itemCount = tonumber(string.sub(value, e + 1))
        local itemType = remote.items:getItemType(idOrType)
        if itemType == nil then
            itemType = ITEM_TYPE.ITEM
        end        
		table.insert(awardList, {id = idOrType, typeName = itemType, count = itemCount})
    end
    return awardList
end

function QUIWidgetActivityVipDailyGift:_onTriggerConfirm(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_confim) == false then return end
	app.sound:playSound("common_small")
	remote.activityVipGift:requestMyVipDailyGift(function(data )
		-- if self:getCCBView() then
	    	local items = data.items
		    remote.activityVipGift:switchRecord(data.vipGiftDailyGainResponse)
			local wallet = {}
			remote.user:update( wallet )
			if data.items and next(data.items) then
		    	remote.items:setItems( items ) 
		    end	
		    self:_showVipGiftAwrdsInfo(self._awards)
		    self:updateBtnState(true)			
		-- end
	end,function()
		app.tip:floatTip("不满足领取条件",100)
	end)
end

function QUIWidgetActivityVipDailyGift:_onTriggerYulan(event)
    if q.buttonEventShadow(event, self._ccbOwner.bt_yulan) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogShowVipDailyGift"})
end

function QUIWidgetActivityVipDailyGift:_showVipGiftAwrdsInfo(awards)
	if awards == nil or next(awards) == nil then return end
	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = awards,callBack = nil}}, {isPopCurrentDialog = false} )	    
    dialog:setTitle("")
end

function QUIWidgetActivityVipDailyGift:updateBtnState(flag)
	
	self._ccbOwner.node_receive:setVisible(not flag)
	self._ccbOwner.sp_received:setVisible(flag)
end
function QUIWidgetActivityVipDailyGift:onEnter()
end

function QUIWidgetActivityVipDailyGift:onExit()
end

function QUIWidgetActivityVipDailyGift:getContentSize()
end

return QUIWidgetActivityVipDailyGift

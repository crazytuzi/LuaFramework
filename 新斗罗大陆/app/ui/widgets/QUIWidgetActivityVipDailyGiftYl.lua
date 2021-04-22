-- @Author: liaoxianbo
-- @Date:   2019-06-03 10:10:37
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-01 15:33:26
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityVipDailyGiftYl = class("QUIWidgetActivityVipDailyGiftYl", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetActivityVipDailyGiftYl:ctor(options)
	local ccbFile = "ccb/Widget_Activity_flyl_client.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetActivityVipDailyGiftYl.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end
function QUIWidgetActivityVipDailyGiftYl:setDataInfo(vipGiftInfo,parent)
	self._widgetVipDailyGif = parent
	local viplvel = tonumber(vipGiftInfo.vip)
	local str = string.format("VIP%d专属每日福利",viplvel)
	self._awards = self:switchAwards(vipGiftInfo)
	self._ccbOwner.tf_name:setString(str)
	local curentvipLevel = app.vipUtil:VIPLevel()
	self._ccbOwner.node_dazhe:removeAllChildren()
    self._ccbOwner.node_title:setPositionX(-65)
	if curentvipLevel == viplvel then
		local ccbProxy = CCBProxy:create()
        local ccbOwner = {}
        local dazheWidget = CCBuilderReaderLoad("Widget_dazhe.ccbi", ccbProxy, ccbOwner)
        ccbOwner.chengDisCountBg:setVisible(false)
        ccbOwner.lanDisCountBg:setVisible(true)
        ccbOwner.ziDisCountBg:setVisible(false)
        ccbOwner.hongDisCountBg:setVisible(false)
        ccbOwner.discountStr:setString("当前福利")
        ccbOwner.discountStr:setColor(ccc3(255, 250, 204))
        ccbOwner.discountStr:setOutlineColor(ccc3(61, 118, 19))
        ccbOwner.discountStr:setFontSize(18)
        self._ccbOwner.node_dazhe:addChild(dazheWidget)
        self._ccbOwner.node_dazhe:setScale(0.9)
        self._ccbOwner.node_title:setPositionX(-25)
	end

	self:initListView()
end

function QUIWidgetActivityVipDailyGiftYl:initListView()
	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, false)
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

	            -- item:setGoodsInfo(data.id, data.typeName, data.count)
	            self:setItemInfo(item,data,index)
	            item:setScale(0.8)
                info.item = item
                -- info.size = item:getContentSize()
                info.size = item._ccbOwner.parentNode:getContentSize()

                list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        isVertical = false,
	        spaceX = -10,
	        enableShadow = false,
	        totalNumber = #self._awards,

	    }  
		self._listView = QListView.new(self._ccbOwner.item_sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._awards})
	end 
end

function QUIWidgetActivityVipDailyGiftYl:setItemInfo( item, data ,index)
	if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setPosition(ccp(45, 50))
		item._itemBox:setScale(0.8)
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(80,88))
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

function QUIWidgetActivityVipDailyGiftYl:switchAwards( giftList )
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

function QUIWidgetActivityVipDailyGiftYl:registerItemBoxPrompt( index, list )
	if self._itemBox then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
		end
		list:registerItemBoxPrompt(index, 1, self._itemBox, nil, showItemInfo)
	end
end

function QUIWidgetActivityVipDailyGiftYl:onTouchListView(event)
	if not event then
		return
	end

	if event.name == "moved" then
		local contentListView = self._widgetVipDailyGif:getContentListView()
		if contentListView then
			local curGesture = contentListView:getCurGesture() 
			if curGesture then
				if curGesture == QListView.GESTURE_V then
					self._listView:setCanNotTouchMove(true)
				elseif curGesture == QListView.GESTURE_H then
					contentListView:setCanNotTouchMove(true)
				end
			end
		end
	elseif  event.name == "ended" then
		local contentListView = self._widgetVipDailyGif:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end

function QUIWidgetActivityVipDailyGiftYl:onEnter()
end

function QUIWidgetActivityVipDailyGiftYl:onExit()
end

function QUIWidgetActivityVipDailyGiftYl:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

return QUIWidgetActivityVipDailyGiftYl

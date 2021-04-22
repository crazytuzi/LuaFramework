-- @Author: xurui
-- @Date:   2017-01-03 20:00:52
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-04 12:01:34
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMaritimeAwardsClient = class("QUIWidgetMaritimeAwardsClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSilverMineBox = import("..widgets.QUIWidgetSilverMineBox")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetMaritimeAwardsClient.CLICK_AWARD = "CLICK_AWARD"

function QUIWidgetMaritimeAwardsClient:ctor(options)
	local ccbFile = "ccb/Widget_Haishang_jiangli.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClickAwards", callback = handler(self, self._onTriggerClickAwards)},
	}
	QUIWidgetMaritimeAwardsClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._awards = {}
	self._isReady = false

	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	self._rebberyItem = configuration["maritime_proportion"].value
end

function QUIWidgetMaritimeAwardsClient:onEnter()
end

function QUIWidgetMaritimeAwardsClient:onExit()
end

function QUIWidgetMaritimeAwardsClient:_initListView()
    if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.reandFunHandler),
	        isVertical = false,
	        totalNumber = #self.awardsInfo,
	        spaceX = 5,
	        curOffset = 10,
	        contentOffsetY = -8,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self.awardsInfo})
	end

end

function QUIWidgetMaritimeAwardsClient:reandFunHandler( list, index, info )
    local isCacheNode = true
    local item = list:getItemFromCache()
    local isGoldPickaxe = false

    if not item then
        item = QUIWidgetSilverMineBox.new()
        isCacheNode = false
    end
	local scale_ = 1
    item:setCurScale(scale_)
	local data = string.split(self.awardsInfo[index], "^")
	local itemType = ITEM_TYPE.ITEM
	if tonumber(data[1]) == nil then
		itemType = data[1]
	end
    item:update(tonumber(data[1]), itemType, tonumber(data[2]))
    info.item = item
    info.size = item:getContentSize() 
    info.size.width = info.size.width + 10
	info.size.width = info.size.width * scale_
	info.size.height = info.size.height * scale_

    list:registerItemBoxPrompt(index, 1, item:getItemBox(), nil, nil)

	table.insert(self._awards, {id = tonumber(data[1]), typeName = itemType, count = tonumber(data[2])})
    return isCacheNode
end

function QUIWidgetMaritimeAwardsClient:setInfo(param)
	self._info = param.info or {}
	self._parent = param.parent

	local time = q.date("%m-%d %H:%M", self._info.endAt/1000)
	local shipInfo = remote.maritime:getMaritimeShipInfoByShipId(self._info.shipId)

	self._ccbOwner.tf_ship_time:setString(time .. (shipInfo.ship_name or ""))

	if self._info.rewards then
		local awardStr = self._info.rewards
		self.awardsInfo = string.split(awardStr, ";")
		self:_initListView()
	end

	if self._info.lootedCnt and self._info.lootedCnt > 0 then
		self._ccbOwner.tf_robbery_content:setString("（被抢劫"..self._info.lootedCnt.."次，损失：")

		local items = string.split(self.awardsInfo[1], "^")
		if self._lostItemIcon == nil then
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(tonumber(items[1]))
			if itemConfig and itemConfig.icon_1 ~= nil then
				self._lostItemIcon = CCSprite:create(itemConfig.icon_1)
				self._lostItemIcon:setScale(0.5)
				self._ccbOwner.node_lost_item:addChild(self._lostItemIcon)
			end
		end
		local shipAwards = remote.maritime:getMaritimeShipAwardsInfoByShipId(self._info.shipId, remote.user.level)	
		local count = math.ceil( tonumber(shipAwards.num_1) * self._rebberyItem )
		self._ccbOwner.tf_lost_num:setString((count * self._info.lootedCnt).."）")
	else
		self._ccbOwner.node_lost_num:setVisible(false)
	end

	if self._info.status == 2 then
		self._ccbOwner.sp_ready:setVisible(true)
		self._ccbOwner.sp_done:setVisible(false)
		self._ccbOwner.done_banner:setVisible(true)
		self._isReady = true
	else
		self._ccbOwner.sp_ready:setVisible(false)
		self._ccbOwner.sp_done:setVisible(true)
		self._ccbOwner.done_banner:setVisible(false)
		self._isReady = false
	end
end

function QUIWidgetMaritimeAwardsClient:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetMaritimeAwardsClient:onTouchListView( event )
	if not event then
		return
	end

	if event.name == "moved" then
		local contentListView = self._parent:getContentListView()
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
		local contentListView = self._parent:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end

function QUIWidgetMaritimeAwardsClient:_onTriggerClickAwards()
	if self._isReady == false then return end
	self:dispatchEvent({name = QUIWidgetMaritimeAwardsClient.CLICK_AWARD, info = self._info, awards = self._awards})
end

return QUIWidgetMaritimeAwardsClient
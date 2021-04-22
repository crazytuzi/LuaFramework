--
-- Kumo.Wang
-- 新首充界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFirstRechargeNew = class("QUIWidgetFirstRechargeNew", QUIWidget)

local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QListView = import("...views.QListView")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIWidgetFirstRechargeNew:ctor(options)
	local ccbFile = "ccb/Widget_FirstRecharge.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		-- {ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
	QUIWidgetFirstRechargeNew.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetFirstRechargeNew:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetFirstRechargeNew:setInfo(info)
	if not info or next(info) == nil then return end
	self._info = info

	local autoNodes = {}
	if info.id == 1 then
		self._ccbOwner.tf_title1:setString("首次充值")
	else
		self._ccbOwner.tf_title1:setString("累充")
	end
	QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("firstRecharge")[info.id])
	self._ccbOwner.tf_title2:setString("送：")
	table.insert(autoNodes, self._ccbOwner.tf_title1)
	table.insert(autoNodes, self._ccbOwner.sp_title)
	table.insert(autoNodes, self._ccbOwner.tf_title2)
	q.autoLayerNode(autoNodes, "x", 2)


	local tbl = string.split(tostring(info.reward_value), ";")
	self._ccbOwner.tf_desc1:setString("价值")
	self._ccbOwner.tf_desc2:setString(tbl[1])
	self._ccbOwner.tf_desc3:setString(info.reward_str)
	autoNodes = {}
	table.insert(autoNodes, self._ccbOwner.tf_desc1)
	table.insert(autoNodes, self._ccbOwner.tf_desc2)
	table.insert(autoNodes, self._ccbOwner.sp_token)
	table.insert(autoNodes, self._ccbOwner.tf_desc3)
	q.autoLayerNode(autoNodes, "x", 2)
	

	self._ccbOwner.btn_go:setVisible(false)
	self._ccbOwner.btn_ok:setVisible(false)
	self._ccbOwner.sp_done:setVisible(false)
	self._ccbOwner.sp_tips_ok:setVisible(false)

	local currentRMBNum = QVIPUtil:rechargedRMBNum()
	local needRMBNum = info.add_recharge
	local showRMBNum = 0
	if currentRMBNum >= needRMBNum then
		showRMBNum = needRMBNum
		if info.isComplete then
			self._ccbOwner.sp_done:setVisible(true)
		else
			self._ccbOwner.btn_ok:setVisible(true)
			self._ccbOwner.sp_tips_ok:setVisible(true)
		end
	else
		showRMBNum = currentRMBNum
		self._ccbOwner.btn_go:setVisible(true)
	end
	self._ccbOwner.tf_info:setString("("..showRMBNum.."/"..needRMBNum..")")

	self._data = {}
	local index = 1
	while true do
		local rewardStr = info["reward_"..index]
		if rewardStr then
			local tbl = string.split(rewardStr, "^")
			local itemType = ITEM_TYPE.ITEM
		    if tonumber(tbl[1]) == nil then
		        itemType = remote.items:getItemType(tbl[1])
		    end
		    local isEffect = info["effect"..index] == 1
		    table.insert(self._data, {id = tonumber(tbl[1]), itemType = itemType, count = tonumber(tbl[2]), isEffect = isEffect})
			index = index + 1
		else
			break
		end
	end
	
	self:_initListView()
end

function QUIWidgetFirstRechargeNew:_initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
			isVertical = false,
	        enableShadow = false,
	        spaceX = -20,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.itemsListView, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIWidgetFirstRechargeNew:_renderItemCallBack(list, index, info)
	local function showItemInfo(x, y, itemBox, listView)
		app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
	end

    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end

    local itemX = 45
    local itemY = 60
    if not item._itemEffect then
    	item._itemEffect = QUIWidget.new("ccb/effects/leiji_light.ccbi")
    	item._itemEffect:setScale(0.5)
		item._itemEffect:setPosition(ccp(itemX, itemY))
		item._ccbOwner.parentNode:addChild(item._itemEffect)
    end
    item._itemEffect:setVisible(data.isEffect)

    if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setScale(0.8)
		item._itemBox:setPosition(ccp(itemX, itemY))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,100))
	end
	item._itemBox:setGoodsInfo(data.id, data.itemType, data.count)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end

function QUIWidgetFirstRechargeNew:onTouchListView( event )
	if not event then
		return
	end
	
	if self._listView then
		self._listView:onTouch(event)
	end
end

function QUIWidgetFirstRechargeNew:onTriggerOK()
	app:getClient():getFirstRechargeRewardRequest(self._info.id, function()
			if self._ccbView then
				self:_showRewards()
			end
		end)
end

function QUIWidgetFirstRechargeNew:onTriggerGo()
    app.sound:playSound("common_small")
	if ENABLE_CHARGE() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

function QUIWidgetFirstRechargeNew:_showRewards()
    local awards = {}
    for _, data in ipairs(self._data) do
        table.insert(awards, {id = data.id, count = data.count, typeName = data.itemType})
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = awards, callBack = function()
            app:getNavigationManager():getController(app.middleLayer):getTopDialog():update()
            app:getNavigationManager():getController(app.mainUILayer):getTopPage():_checkFirstRechargeState()
            app:getNavigationManager():getController(app.mainUILayer):getTopPage():quickButtonAutoLayout()
        end }},{isPopCurrentDialog = false})
    
end

return QUIWidgetFirstRechargeNew
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInvasionChest = class("QUIWidgetInvasionChest", QUIWidget)
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("..QUIViewController")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")

QUIWidgetInvasionChest.EVENT_OPEN_CHEST = "EVENT_OPEN_CHEST"
QUIWidgetInvasionChest.EVENT_OPEN_CHEST_END = "EVENT_OPEN_CHEST_END"

function QUIWidgetInvasionChest:ctor(options)
	local ccbFile = "ccb/Widget_Panjun_Baoxiang.ccbi"
  	local callBacks = {
      {ccbCallbackName = "onTriggerChest", callback = handler(self, QUIWidgetInvasionChest._onTriggerChest)},
  }
	QUIWidgetInvasionChest.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._text1Update = QTextFiledScrollUtils.new()
	self._text2Update = QTextFiledScrollUtils.new()
	self._effectTime = 0.5
end

function QUIWidgetInvasionChest:onExit()
	QUIWidgetInvasionChest.super.onExit(self)
	self._text1Update:stopUpdate()
	self._text2Update:stopUpdate()
end

function QUIWidgetInvasionChest:setInfo(index)
	self._index = index
	self._chestId = remote.invasion.CHEST[self._index]
	self._keyId = remote.invasion.KEY[self._index]
	for i=1,3 do
	    self._ccbOwner["sp_chest"..i]:setVisible(false)
	    self._ccbOwner["sp_key"..i]:setVisible(false)
	end
	self._ccbOwner["sp_chest"..index]:setVisible(true)
	self._ccbOwner["sp_key"..index]:setVisible(true)
end

function QUIWidgetInvasionChest:refreshInfo()
	self._chestCount = remote.items:getItemsNumByID(self._chestId)
	self._keyCount = remote.items:getItemsNumByID(self._keyId)
	self._ccbOwner.sp_mask:setVisible(self._chestCount == 0)
	self._ccbOwner.sp_key_mask:setVisible(self._keyCount == 0)
	self._ccbOwner.tf_chest_count:setString(self._chestCount)
	self._ccbOwner.tf_key_count:setString(self._keyCount)
	self._ccbOwner.node_effect:setVisible(self._chestCount > 0 and self._keyCount > 0)

	local itemInfo
	local shopItems = remote.stores:getStoresById(SHOP_ID.itemShop)
	for i, v in pairs(shopItems) do
		if v.id == self._keyId then
			itemInfo = v
			break
		end
	end
	
	self._ccbOwner.node_sale:setVisible(false)
	local sale = remote.stores:getSaleByShopItemInfo(itemInfo)
	if self._chestCount > 0 and self._keyCount == 0 then
		self:setSaleState(sale)
	end
end

function QUIWidgetInvasionChest:setSaleState(sale)
	if sale == 0 then return end

	if self._index == 1 and sale <= 3 then
		self._ccbOwner.node_sale:setVisible(true)
		self._ccbOwner.tf_sale:setString(string.format("%s折", sale))
	elseif sale <= 2.5 then
		self._ccbOwner.node_sale:setVisible(true)
		self._ccbOwner.tf_sale:setString(string.format("%s折", sale))
	end
end

function QUIWidgetInvasionChest:updateInfoForAnimation()
	self._text1Update:stopUpdate()
	self._text2Update:stopUpdate()
	local chestCount = remote.items:getItemsNumByID(self._chestId)
	self._ccbOwner.sp_mask:setVisible(chestCount == 0)
	if self._chestCount < chestCount then
		self._text1Update:addUpdate(self._chestCount, chestCount, function (value)
			self._ccbOwner.tf_chest_count:setString(math.ceil(value))
		end, self._effectTime, function ()
				self._ccbOwner.tf_chest_count:setString(chestCount)
				self._ccbOwner.node_effect:setVisible(self._chestCount > 0 and self._keyCount > 0)
		end)
		self._chestCount = chestCount
	else
		self._chestCount = chestCount
		self._ccbOwner.tf_chest_count:setString(chestCount)
		self._ccbOwner.node_effect:setVisible(self._chestCount > 0 and self._keyCount > 0)
	end

	local keyCount = remote.items:getItemsNumByID(self._keyId)
	self._ccbOwner.sp_key_mask:setVisible(keyCount == 0)
	if self._keyCount < keyCount then
		self._text2Update:addUpdate(self._keyCount, keyCount, function (value)
			self._ccbOwner.tf_key_count:setString(math.ceil(value))
		end, self._effectTime, function ()
				self._ccbOwner.tf_key_count:setString(keyCount)
			self._ccbOwner.node_effect:setVisible(self._chestCount > 0 and self._keyCount > 0)
		end)
		self._keyCount = keyCount
	else
		self._keyCount = keyCount
		self._ccbOwner.tf_key_count:setString(keyCount)
		self._ccbOwner.node_effect:setVisible(self._chestCount > 0 and self._keyCount > 0)
	end
end

function QUIWidgetInvasionChest:openEffect(awards)
	local ccbFile = nil
	local title = ""
	if self._index == 3 then
		ccbFile = "ccb/effects/zhanchang_baoxiang_effect2.ccbi"
		title = "黄金宝箱"
	elseif self._index == 2 then
		ccbFile = "ccb/effects/zhanchang_baoxiang_effect2_3.ccbi"
		title = "白银宝箱"
	elseif self._index == 1 then
		ccbFile = "ccb/effects/zhanchang_baoxiang_effect2_2.ccbi"
		title = "青铜宝箱"
	end
	self._ccbOwner["sp_chest"..self._index]:setVisible(false)
	local animationPlayer = QUIWidgetAnimationPlayer.new()
	animationPlayer:setPosition(ccp(0,-30))
	animationPlayer:playAnimation(ccbFile, nil, function ()
		self._ccbOwner["sp_chest"..self._index]:setVisible(true)
		self:refreshInfo()
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards, callBack = function ()
    			if self.dispatchEvent then
					self:dispatchEvent({name = QUIWidgetInvasionChest.EVENT_OPEN_CHEST_END})
				end
    		end}},{isPopCurrentDialog = false} )
   		dialog:setTitle(title.."奖励")
	end)
	self:addChild(animationPlayer)
end

function QUIWidgetInvasionChest:_onTriggerChest()
    app.sound:playSound("common_small")
	if self._chestCount == 0 then
		return
	end
	if self._keyCount == 0 then
		remote.stores:buyMallItemById(self._keyId, function()
				self:refreshInfo()
			end)
		return
	end
	self:dispatchEvent({name = QUIWidgetInvasionChest.EVENT_OPEN_CHEST})

	if self._keyCount == 1 or self._chestCount == 1 then
		remote.invasion:intrusionOpenBossBoxRequest(self._index, 1,nil, function (data)
	        remote.user:addPropNumForKey("todayIntrusionBoxOpenCount")
			local awards = {}
			for _,value in ipairs(data.intrusionOpenBossBoxResponse.luckyDraw.prizes) do
				table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
			end
			self:openEffect(awards)
		end,function ()
			self:dispatchEvent({name = QUIWidgetInvasionChest.EVENT_OPEN_CHEST_END})
		end)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyInvasionChest",
	    		options = {index = self._index, callback = function (data, nums)
			        remote.user:addPropNumForKey("todayIntrusionBoxOpenCount", nums)
					local awards = {}
					for _,value in ipairs(data.intrusionOpenBossBoxResponse.luckyDraw.prizes) do
						table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
					end
					self:openEffect(awards)
	    		end, cancelBack = function ()
	    			self:dispatchEvent({name = QUIWidgetInvasionChest.EVENT_OPEN_CHEST_END})
	    		end}},{isPopCurrentDialog = false} )
	end
	-- remote.invasion:intrusionOpenBossBoxRequest(self._index, function (data)
 --        remote.user:addPropNumForKey("todayIntrusionBoxOpenCount")
	-- 	local awards = {}
	-- 	for _,value in ipairs(data.intrusionOpenBossBoxResponse.luckyDraw.prizes) do
	-- 		table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
	-- 	end
	-- 	self:openEffect(awards)
	-- end,function ()
	-- 	self:dispatchEvent({name = QUIWidgetInvasionChest.EVENT_OPEN_CHEST_END})
	-- end)
end

return QUIWidgetInvasionChest
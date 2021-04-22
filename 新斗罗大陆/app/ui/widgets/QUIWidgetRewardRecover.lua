--
-- Author: Kumo
-- Date: 2014-11-24 16:39:45
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRewardRecover = class("QUIWidgetRewardRecover", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetRewardRecover.EVENT_CLICK = "QUIWIDGETREWARDRECOVER_EVENT_CLICK"

function QUIWidgetRewardRecover:ctor(options)
	local ccbFile = "ccb/Widget_fulizhuihui_client.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerConfirm",  callback = handler(self, self._onTriggerConfirm)},
		-- {ccbCallbackName = "onTriggerItemInfo",  callback = handler(self, self._onTriggerItemInfo)},
	}
	QUIWidgetRewardRecover.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._isCanShowItemInfo = true
	self._canBuy = true
end

function QUIWidgetRewardRecover:onEnter()
	self._isCanShowItemInfo = true
end

function QUIWidgetRewardRecover:onExit()   
end

function QUIWidgetRewardRecover:ininGLLayer(glLayerIndex)
    self._glLayerIndex = glLayerIndex or 1
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_item, self._glLayerIndex)
    if self._itemBox then
        self._glLayerIndex = self._itemBox:initGLLayer(self._glLayerIndex)
    end
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_title, self._glLayerIndex) -- 55
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_count, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_price, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_token, self._glLayerIndex) 
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_itemInfo, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.ccb_dazhe, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.chengDisCountBg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_chengDisCount, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.lanDisCountBg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_lanDisCount, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.ziDisCountBg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_ziDisCount, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.hongDisCountBg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_hongDisCount, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.discountStr, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_buy, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_buy, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_buy, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_sellOut, self._glLayerIndex)

    return self._glLayerIndex
end

function QUIWidgetRewardRecover:init( award, parent ) 
	-- QPrintTable(award)
	self._award = award
	self._parent = parent
	self._energyNum = nil
	-- 道具显示
	self._itemBox = QUIWidgetItemsBox.new()
	if tonumber(self._award.item) then
		local itemType = ITEM_TYPE.ITEM
		local itemTypeNum = remote.rewardRecover:getItemTypeById(self._award.item)
		if itemTypeNum == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
	        itemType = ITEM_TYPE.GEMSTONE_PIECE
	    elseif itemTypeNum == ITEM_CONFIG_TYPE.GEMSTONE then
	    	itemType = ITEM_TYPE.GEMSTONE
	    end
	    self._itemType = itemType
	    self._itemID = tonumber(self._award.item)
		self._itemBox:setGoodsInfo(tonumber(self._award.item), itemType, tonumber(self._award.num))
	else
		self._itemType = self._award.item
	    self._itemID = nil
	    if self._award.item == "energy" then
	    	-- 购买体力的话，需要先判断当前体力是不是上限了，所以要特别标记下
	    	self._energyNum = tonumber(self._award.num)
	    end
		self._itemBox:setGoodsInfo(nil, self._award.item, tonumber(self._award.num))
	end
	self._itemBox:setPromptIsOpen(true)
	-- self._itemBox:showEffect()
	self._itemBox:setGloryTowerType(false)
	self._ccbOwner.node_item:removeAllChildren()
	self._ccbOwner.node_item:addChild( self._itemBox )

	-- 价格显示
	self._ccbOwner.tf_price:setString(self._award.price)
	self._ccbOwner.sp_token:setPositionX(self._ccbOwner.tf_price:getPositionX() - self._ccbOwner.tf_price:getContentSize().width / 2 - 20)

	-- 丝带显示
	self:setDazheType(self._award.discount_show or 0, self._award.discount_show_colour or 0)

	-- 购买次数显示
	self:updateCount()
end

function QUIWidgetRewardRecover:updateCount()
	local tbl = remote.rewardRecover:getPayRewardTakenInfoTbl()
	local count = self._award.buy_times - (tbl[tostring(self._award.id)] or 0)
	if count <= 0 then
		count = 0
		self._canBuy = false
		-- makeNodeFromNormalToGray(self._ccbOwner.node_buy)
		self._ccbOwner.node_buy:setVisible(false)
		self._ccbOwner.sp_sellOut:setVisible(true)
		-- self._ccbOwner.btn_buy:setEnabled(false)
	else
		self._canBuy = true
		makeNodeFromGrayToNormal(self._ccbOwner.node_buy)
		self._ccbOwner.node_buy:setVisible(true)
		self._ccbOwner.sp_sellOut:setVisible(false)
		-- self._ccbOwner.btn_buy:setEnabled(true)
	end
	self._ccbOwner.tf_count:setString(count.."/"..self._award.buy_times)
end

function QUIWidgetRewardRecover:_onTriggerConfirm()
	if self._canBuy and not self._isOverTime then
		self:dispatchEvent({name = QUIWidgetRewardRecover.EVENT_CLICK, target = self, id = self._award.id, energyNum = self._energyNum})
	else
		if self._isOverTime then
			app.tip:floatTip("魂师大人，福利追回已结束～")
		else
			app.tip:floatTip("魂师大人，您已经没有购买次数啦～")
		end
	end
end

function QUIWidgetRewardRecover:_onTriggerItemInfo()
	if not self._isCanShowItemInfo then return end
	app.sound:playSound("common_small")
	app.tip:itemTip(self._itemType, self._itemID)
end

function QUIWidgetRewardRecover:setCanShowItemInfo(b)
	self._isCanShowItemInfo = b
end

function QUIWidgetRewardRecover:overTime()
	makeNodeFromNormalToGray(self._ccbOwner.node_buy)
	self._ccbOwner.node_buy:setVisible(true)
	self._ccbOwner.sp_sellOut:setVisible(false)
	self._isOverTime = true
end

function QUIWidgetRewardRecover:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetRewardRecover:setDazheType( int, colorType )
	if tonumber(int) > 0 then
		if not colorType then colorType = 0 end
		self._ccbOwner.lanDisCountBg:setVisible(false)
		self._ccbOwner.ziDisCountBg:setVisible(false)
		self._ccbOwner.chengDisCountBg:setVisible(false)
		self._ccbOwner.hongDisCountBg:setVisible(false)
		if tonumber(colorType) == 1 then
			-- 蓝
			self._ccbOwner.lanDisCountBg:setVisible(true)
		elseif tonumber(colorType) == 2 then
			-- 紫
			self._ccbOwner.ziDisCountBg:setVisible(true)
		elseif tonumber(colorType) == 3 then
			-- 橙
			self._ccbOwner.chengDisCountBg:setVisible(true)
		elseif tonumber(colorType) == 4 then
			-- 红
			self._ccbOwner.hongDisCountBg:setVisible(true)
		else
			-- 蓝
			self._ccbOwner.lanDisCountBg:setVisible(true)
		end
		self._ccbOwner.discountStr:setString(int.."折")
		self._ccbOwner.ccb_dazhe:setVisible(true)
	else
		self._ccbOwner.ccb_dazhe:setVisible(false)
	end
end

return QUIWidgetRewardRecover
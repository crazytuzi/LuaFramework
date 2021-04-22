local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMetalAbyssFinalShop = class("QUIWidgetMetalAbyssFinalShop", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetMetalAbyssFinalShop.EVENT_BUY_REWARD = "EVENT_BUY_REWARD"

function QUIWidgetMetalAbyssFinalShop:ctor(options)
	local ccbFile = "ccb/Widget_MetalAbyss_FinalShop.ccbi"
  	local callBacks = {
      {ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
  }
	QUIWidgetMetalAbyssFinalShop.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
  	self._itemIcon = nil
    q.setButtonEnableShadow(self._ccbOwner.btn_buy)

end

function QUIWidgetMetalAbyssFinalShop:onEnter()
	QUIWidgetMetalAbyssFinalShop.super.onEnter(self)
end

function QUIWidgetMetalAbyssFinalShop:onExit()
	QUIWidgetMetalAbyssFinalShop.super.onExit(self)
	
end

--[[
	curDiscount 折扣
	costNum 	购买价格
	name 		货品名称

	count 		购买数量
	id 			道具id
	itemType	道具类型

	canBuy		能不能买

--]]


function QUIWidgetMetalAbyssFinalShop:setInfo(info)
	-- QPrintTable(info)
	self._info = info
	if self._itemIcon == nil then
		self._itemIcon =  QUIWidgetItemsBox.new()
		self._ccbOwner.node_prize_1:addChild(self._itemIcon)
	end
	self._itemIcon:setGoodsInfo(self._info.id, self._info.itemType, self._info.count)
	self._itemIcon:setPromptIsOpen(true)


	local havenum = remote.items:getItemsNumByID(self._info.id)

	self._ccbOwner.tf_num:setString(havenum)
	self._ccbOwner.tf_num:setVisible(false)
	self._ccbOwner.tf_desc1:setVisible(false)
	self._ccbOwner.tf_desc2:setVisible(false)


	self._ccbOwner.tf_name:setString(self._itemIcon:getItemName() or "吧啦吧啦吧啦")
	local width = self._ccbOwner.tf_name:getContentSize().width
	if width <= 130 then
		self._ccbOwner.tf_name:setScale(1)
	else
		self._ccbOwner.tf_name:setScale(130/width)
	end


	local curDiscount = self._info.curDiscount or 100 
	if curDiscount >= 100 then
		self._ccbOwner.node_sale:setVisible(false)
	else
		self._ccbOwner.node_sale:setVisible(true)
		self._ccbOwner.discountStr:setString(string.format("%s折", curDiscount))
	end
	if info.costType == nil or info.costNum == nil  then
		self._ccbOwner.tf_free:setVisible(true)
		self._ccbOwner.sp_icon:setVisible(false)
		self._ccbOwner.tf_buy:setVisible(false)
	else
		self._ccbOwner.tf_buy:setVisible(true)
		self._ccbOwner.sp_icon:setVisible(true)		
		self._ccbOwner.tf_free:setVisible(false)
		self._ccbOwner.tf_buy:setString(self._info.costNum)
		local path = remote.items:getWalletByType(info.costType).alphaIcon
		QSetDisplayFrameByPath(self._ccbOwner.sp_icon,path)
		self._ccbOwner.sp_icon:setScale(0.5)	
		local width = 40
		width = width + self._ccbOwner.tf_buy:getContentSize().width
		self._ccbOwner.npde_cost:setPositionX(- width * 0.5 )	

	end
	self._ccbOwner.node_buy:setVisible(false)
	self._ccbOwner.sp_bought:setVisible(false)
	self._ccbOwner.sp_getten:setVisible(false)

	if self._info.canBuy then
		self._ccbOwner.node_buy:setVisible(true)
	elseif info.costType == nil or info.costNum == nil  then
		self._ccbOwner.sp_getten:setVisible(true)
	else
		self._ccbOwner.sp_bought:setVisible(true)
	end
end

function QUIWidgetMetalAbyssFinalShop:registerItemBoxPrompt( index, list )
	if self._itemIcon then
		list:registerItemBoxPrompt(index,1,self._itemIcon)
	end
end


function QUIWidgetMetalAbyssFinalShop:_onTriggerGet(event)
	self:dispatchEvent({name = QUIWidgetMetalAbyssFinalShop.EVENT_BUY_REWARD, info = self._info})
end

function QUIWidgetMetalAbyssFinalShop:getContentSize()
    local size = self._ccbOwner.node_size:getContentSize()
    return size
end

return QUIWidgetMetalAbyssFinalShop
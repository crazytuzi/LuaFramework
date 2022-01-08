--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local ShopItemCell = class("ShopItemCell", BaseLayer)

function ShopItemCell:ctor(type,data)
    self.super.ctor(self,data)
    self.type = type
    self:init("lua.uiconfig_mango_new.shop.ShopItemCell")
end

function ShopItemCell:initUI(ui)
	self.super.initUI(self,ui)

	self.btn_node	 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.btn_icon	 		= TFDirector:getChildByPath(ui, 'btn_icon')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.txt_name 			= TFDirector:getChildByPath(ui, 'txt_name')
	self.txt_number			= TFDirector:getChildByPath(ui, 'txt_number')
	self.img_sold_out 		= TFDirector:getChildByPath(ui, 'img_sold_out')

	--价格
	self.img_res_icon 		= TFDirector:getChildByPath(ui, 'img_res_icon')
	self.txt_price 			= TFDirector:getChildByPath(ui, 'txt_price')


	self.img_zhekou 		= TFDirector:getChildByPath(ui, 'img_zhekou')
	self.bg_time 			= TFDirector:getChildByPath(ui, 'bg_time')
	self.txt_time 			= TFDirector:getChildByPath(ui, 'LabelBMFont_ShopItemCell_1')

	self.btn_node.logic = self

	self.img_zhekou:setVisible(false)
	self.bg_time:setVisible(false)
end

function ShopItemCell:removeUI()
	self.super.removeUI(self)

	self.txt_name 			= nil
	self.txt_number			= nil
	self.btn_icon	 		= nil
	self.img_icon  			= nil
	self.img_res_icon  		= nil
	self.btn_node 			= nil
	self.id 				= nil
	self.txt_price 			= nil
	self.img_sold_out 		= nil

	self.img_zhekou			= nil
	self.bg_time			= nil
	self.txt_time			= nil
	self.end_time			= nil
end

function ShopItemCell:setData( data )
	self.id = data.id
	self.commodityData = data

	local template =  data:getTemplate()
	self.template = template
	local name = nil
	local icon = nil
	local name = template.name
	local quality = template.quality
	local icon = template:GetPath()
	local icon_bg = GetBackgroundForGoods(template)

	self.txt_name:setText(name)
	--self.txt_name:setColor(GetColorByQuality(quality))
	self.img_icon:setTexture(icon)
	self.btn_icon:setTextureNormal(icon_bg)
	self.img_res_icon:setTexture(GetResourceIcon(data:getShopEntry().res_type))

	local itemInfo = {type = EnumDropType.GOODS,itemid = data:getShopEntry().goods_id}
	Public:addPieceImg(self.img_icon, itemInfo);


    --秘籍添加红点 king MartialManager:dropRewardRedPoint(itemInfo)
    self.itemInfo = itemInfo
    CommonManager:setRedPoint(self.img_icon, MartialManager:dropRewardRedPoint(itemInfo), "dropRewardRedPoint", ccp(10,10))

	self:refreshUI()
end

function ShopItemCell:setLogic(logiclayer)
	self.logic = logiclayer
end

function ShopItemCell:refreshUI()
	--print("ShopItemCell:refreshUI()" , self.commodityData)
	if self.commodityData == nil  then
		return false
	end

	local remaining = self.commodityData:getNumber()
	local enabled = self.commodityData:isEnabled()
	self.txt_number:setText(remaining)
	local singlePrice = self.commodityData:getPrice()
	local totalPrice = self.commodityData:getTotalPrice()
	self.txt_price:setText(singlePrice)

	--print("commodityData enabled : ",enabled,remaining)

	if enabled then
		self.img_sold_out:setVisible(false)
		self.btn_node:setTouchEnabled(true)
		self.btn_icon:setGrayEnabled(false)

		--动态修改商店价格字体颜色，标注是否能够购买
		local shopEntry = self.commodityData:getShopEntry()
		local currentResValue = MainPlayer:getResValueByType(shopEntry.res_type)
		if singlePrice > currentResValue then
			self.txt_price:setColor(ccc3(255, 0, 0))
		else
			self.txt_price:setColor(ccc3(255, 255, 255))
		end
		CommonManager:setRedPoint(self.img_icon, MartialManager:dropRewardRedPoint(self.itemInfo), "dropRewardRedPoint", ccp(10,10))

	else
		self.img_sold_out:setVisible(true)
		self.btn_node:setTouchEnabled(false)
		self.btn_icon:setGrayEnabled(true)
		CommonManager:setRedPoint(self.img_icon, false, "dropRewardRedPoint", ccp(10,10))
	end

	self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle))
end

function ShopItemCell.iconBtnClickHandle(sender)
	local self = sender.logic
	if self.logic then
		self.logic:tableCellClick(self)
	end
	
	MallManager:openRandomStoreShoppingLayer( self.logic.type,self.commodityData)
end

function ShopItemCell:setChoice( b )
    self.img_select:setVisible(b)
end

function ShopItemCell:registerEvents()
	self.super.registerEvents(self)

end
function ShopItemCell:removeEvents()
    self.super.removeEvents(self)
    self.btn_node:removeMEListener(TFWIDGET_CLICK)
end

function ShopItemCell:getSize()
	return self.ui:getSize()
end

return ShopItemCell

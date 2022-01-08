--[[
******天书道具cell*******

    -- by Chikui Peng
    -- 2016/3/28
]]

local AdventureItemCell = class("AdventureItemCell", BaseLayer)

function AdventureItemCell:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.shop.ShopItemCell")
end

function AdventureItemCell:initUI(ui)
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
	self.txt_time 			= TFDirector:getChildByPath(ui, 'LabelBMFont_AdventureItemCell_1')

	self.btn_node.logic = self

	self.img_zhekou:setVisible(false)
	self.bg_time:setVisible(false)
	self.img_sold_out:setVisible(false)
	self.txt_number:setText("")
end

function AdventureItemCell:removeUI()
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

function AdventureItemCell:setData(type,data)
	self.id = data.id
	self.commodityData = data
	self.type = type
	self.template = ItemData:objectByID(data.res_id)
	local name = self.template.name
	local quality = self.template.quality
	local icon = self.template:GetPath()
	local icon_bg = GetBackgroundForGoods(self.template)

	self.txt_name:setText(name)
	self.img_icon:setTexture(icon)
	self.btn_icon:setTextureNormal(icon_bg)
	self.img_res_icon:setTexture(GetResourceIconForGeneralHead(self.type))

	self:refreshUI()
end

function AdventureItemCell:setLogic(logiclayer)
	self.logic = logiclayer
end

function AdventureItemCell:refreshUI()
	--print("AdventureItemCell:refreshUI()" , self.commodityData)
	if self.commodityData == nil  then
		return false
	end
	local singlePrice = self.commodityData.consume_number

	self.txt_price:setText(singlePrice)

	self.btn_node:setTouchEnabled(true)
	self.btn_icon:setGrayEnabled(false)

	local currentResValue = BagManager:getItemNumById(self.commodityData.consume_id)
	if singlePrice > currentResValue then
		self.canBuy = false
		self.txt_price:setColor(ccc3(255, 0, 0))
	else
		self.canBuy = true
		self.txt_price:setColor(ccc3(255, 255, 255))
	end

	self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle))
end

function AdventureItemCell.iconBtnClickHandle(sender)
	local self = sender.logic
	if self.logic then
		self.logic:tableCellClick(self)
	end
	PlayerGuideManager:showNextGuideStep()
	local layer = require('lua.logic.mall.AdventureShoppingLayer'):new(self.commodityData,self.type)
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
	AlertManager:show()
end

function AdventureItemCell:registerEvents()
	self.super.registerEvents(self)

end
function AdventureItemCell:removeEvents()
    self.super.removeEvents(self)
    self.btn_node:removeMEListener(TFWIDGET_CLICK)
end

function AdventureItemCell:getSize()
	return self.ui:getSize()
end

return AdventureItemCell

--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local GiftsItemCell = class("GiftsItemCell", BaseLayer)

function GiftsItemCell:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.shop.GiftsItemCell")
end

function GiftsItemCell:initUI(ui)
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
	self.isLimiteTime = false

end

function GiftsItemCell:removeUI()
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

function GiftsItemCell:setData( data )
	self.id = data.id
	self.commodityData = data

	local template =  data:getTemplate()
	self.template = template
	local name = nil
	local icon = nil
	local icon_bg = nil
	local quality = QualityType.DING
	if data:isGoods()  then
		if template == nil then
			print("goods template not found : ",data)
		end
		name = template.name
		quality = template.quality
		icon = template:GetPath()
		icon_bg = GetBackgroundForGoods(template)
	elseif data:isRole() then
		if template == nil then
			print("goods template not found : ",data)
		end
		name = template.name
		quality = template.quality
		icon = template:getIconPath()
		icon_bg = GetColorIconByQuality(quality)
	else
		name = GetResourceName(data.res_type)
		icon = GetResourceIcon(data.res_type)
		icon_bg = GetColorIconByQuality(quality)
	end
	
	self.txt_name:setText(name)
	-- self.txt_name:setColor(GetColorByQuality(quality))
	self.img_icon:setTexture(icon)
	self.btn_icon:setTextureNormal(icon_bg)
	self.img_res_icon:setTexture(GetResourceIcon(data.consume_type))

	local itemInfo = {type = EnumDropType.GOODS,itemid = data.res_id}
	Public:addPieceImg(self.img_icon, itemInfo);



	self:setLimitIcon()
	-- self:refreshUI()

    -- --秘籍添加红点 king -- MartialManager:dropRewardRedPoint(itemInfo)
    self.itemInfo = itemInfo
    CommonManager:setRedPoint(self.img_icon, MartialManager:dropRewardRedPoint(itemInfo), "dropRewardRedPoint", ccp(10,10))

    self:refreshUI()
end

function GiftsItemCell:setLimitIcon()
	local shop = ShopData:objectByID(self.id)
	if shop == nil then 
		print("无法找到该商品 id=="..self.id)
		return
	end

	if shop.old_price and shop.old_price > 0 then
		self.img_zhekou:setVisible(true)
	else
		self.img_zhekou:setVisible(false)
	end

	if shop:isLimiteTime() then
		self.bg_time:setVisible(true)
		-- self.end_time = timestampTodata(v.end_time)
		-- v 是怎么来的
		self.end_time = timestampTodata(shop.end_time)
		self.isLimiteTime = true
	else
		self.bg_time:setVisible(false)
	end

end

function GiftsItemCell:setLogic(logiclayer)
	self.logic = logiclayer
end

--是否可购买
function GiftsItemCell:isEnabled()
	local shop = ShopData:objectByID(self.id)
	if shop == nil then 
		print("无法找到该商品 id=="..self.id)
		return false
	end

	--local maxNumYouCanBuy = MallManager:calculateMaxNumberCanBuy(self.id)
	--if maxNumYouCanBuy < 1 then
	--	return false
	--end

	if shop:isLimited() then
		local now_count = MallManager:getPurchasedCount(self.id)
		local max_num = shop:getMaxNum(MainPlayer:getVipLevel())
		--max_num = math.min(max_num,maxNumYouCanBuy)
		--print("shop limited : ",max_num,now_count)
		if now_count >= max_num then
			return false
		end
	end

	return true
end

function GiftsItemCell:refreshUI()
	if self.commodityData == nil  then
		return false
	end

	local enabled = self:isEnabled()
	self.txt_number:setText(self.commodityData.number)
	--local totalPrice = self.commodityData.consume_number
	local totalPrice = MallManager:getTotalPrice(self.id,1)
	self.txt_price:setText(totalPrice)

	if enabled then
		self.img_sold_out:setVisible(false)
		self.btn_node:setTouchEnabled(true)
		self.btn_icon:setGrayEnabled(false)

		--动态修改商店价格字体颜色，标注是否能够购买
		local shop = ShopData:objectByID(self.id)
		local currentResValue = MainPlayer:getResValueByType(shop.consume_type)
		if totalPrice > currentResValue then
			self.txt_price:setColor(ccc3(255, 0, 0))
		else
			self.txt_price:setColor(ccc3(255, 255, 255))
		end
		if self.itemInfo then
			CommonManager:setRedPoint(self.img_icon, MartialManager:dropRewardRedPoint(self.itemInfo), "dropRewardRedPoint", ccp(10,10))
		end
	else
		self.img_sold_out:setVisible(true)
		self.btn_node:setTouchEnabled(false)
		self.btn_icon:setGrayEnabled(true)
		CommonManager:setRedPoint(self.img_icon, false, "dropRewardRedPoint", ccp(10,10))
	end
	
	self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle))
	
end

function GiftsItemCell.iconBtnClickHandle(sender)
	local self = sender.logic
	if self.logic then
		self.logic:tableCellClick(self)
	end
	MallManager:openShoppingLayer(self.id)
end

function GiftsItemCell:setChoice( b )
    self.img_select:setVisible(b)
end

function GiftsItemCell:registerEvents()
	self.super.registerEvents(self)

end
function GiftsItemCell:removeEvents()
    self.super.removeEvents(self)
    self.btn_node:removeMEListener(TFWIDGET_CLICK)
end

function GiftsItemCell:getSize()
	return self.ui:getSize()
end

local function getTimeStrForNum(num)
    if num < 10 then
        return "0" .. tostring(num);
    end
    return tostring(num);
end

function GiftsItemCell:updateTime(now_time)
	print("self.isLimiteTime = ", self.isLimiteTime)
	if self.isLimiteTime == false then
		return -1
	end
	local second = self.end_time - now_time
	if second <= 0 then
		self.bg_time:setVisible(false)
		return 1
	end
    local hour =  math.floor(second / 3600);
    local minute =  math.floor((second % 3600) / 60);
    second =  math.floor(second % 60);

    local str = getTimeStrForNum(hour) ..":".. getTimeStrForNum(minute)

    print("str = ",str)
    self.txt_time:setText(str)
    return 0
end

return GiftsItemCell

-- AdventureShoppingLayer
-- Author: david.dai
-- Date: 2014-06-16 11:14:56
--

local AdventureShoppingLayer = class("AdventureShoppingLayer", BaseLayer)

CREATE_PANEL_FUN(AdventureShoppingLayer)


function AdventureShoppingLayer:ctor(data,type)
    self.super.ctor(self,data)
    self.commodityData = data
    self.type = type
    self:init("lua.uiconfig_mango_new.shop.ShoppingLayer")
end

function AdventureShoppingLayer:initUI(ui)
	self.super.initUI(self,ui)

	--操作按钮
	self.btn_close				= TFDirector:getChildByPath(ui, 'btn_close')
	self.btn_add				= TFDirector:getChildByPath(ui, 'btn_add')
	self.btn_reduce				= TFDirector:getChildByPath(ui, 'btn_reduce')
	self.txt_num 				= TFDirector:getChildByPath(ui, 'txt_numnow')
	self.btn_buy 				= TFDirector:getChildByPath(ui, 'btn_buy')

	--动态信息控件
	self.txt_name				= TFDirector:getChildByPath(ui, 'txt_name')
	self.img_quality			= TFDirector:getChildByPath(ui, 'img_quality_bg')
	self.img_icon				= TFDirector:getChildByPath(ui, 'img_icon')
	
	self.txt_desc				= TFDirector:getChildByPath(ui, 'txt_desc')


	self.old_price_bg 			= TFDirector:getChildByPath(ui, 'img_price_bg')
	self.old_img_res_icon 			= TFDirector:getChildByPath(self.old_price_bg, 'img_res_icon')
	self.old_txt_price				= TFDirector:getChildByPath(self.old_price_bg, 'txt_price')
	self.old_price_bg:setVisible(false)

	self.txt_numnow				= TFDirector:getChildByPath(self.ui, 'txt_num')
	self.slider_shop				= TFDirector:getChildByPath(self.ui, 'slider_shop')
	self.bg_jindushuzhi				= TFDirector:getChildByPath(self.ui, 'bg_jindushuzhi')
	self.txt_buy_limit_tips 	= TFDirector:getChildByPath(ui, 'txt_buy_limit_tips')
	self.txt_buy_limit_tips:setVisible(false)


	self.now_price_bg 			= TFDirector:getChildByPath(ui, 'img_newprice_bg')
	self.img_res_icon 			= TFDirector:getChildByPath(self.now_price_bg, 'img_res_icon')
	self.txt_price				= TFDirector:getChildByPath(self.now_price_bg, 'txt_price')

	--剩余购买个数信息
	self.lbl_remaining_title 	= TFDirector:getChildByPath(ui, 'lbl_remaining_title')
	self.txt_remaining_num 		= TFDirector:getChildByPath(ui, 'txt_remaining_num')
	

	self.img_zhekou 		= TFDirector:getChildByPath(ui, 'img_zhekou')
	self.bg_time 			= TFDirector:getChildByPath(ui, 'bg_time')
	self.txt_time 			= TFDirector:getChildByPath(ui, 'LabelBMFont_ShopItemCell_1')


	self.txt_own_num				= TFDirector:getChildByPath(self.ui, 'txt_own_num')
	self.lbl_own_title				= TFDirector:getChildByPath(self.ui, 'lbl_own_title')
	
	self.img_zhekou:setVisible(false)
	self.bg_time:setVisible(false)

	--为按钮绑定处理逻辑属性，指向self
	self.btn_close.logic = self
	self.btn_add.logic = self
	self.btn_reduce.logic = self
	self.slider_shop.logic = self
	self.btn_buy.logic = self
	-- self.txt_num:setText(1)
	self.bg_jindushuzhi:setVisible(false)

end

function AdventureShoppingLayer:removeUI()
	--操作按钮
	self.btn_close				= nil
	self.img_res_icon 			= nil
	self.btn_add				= nil
	self.btn_reduce				= nil
	self.txt_num 				= nil
	self.btn_buy 				= nil

	--动态信息控件
	self.txt_name				= nil
	self.img_quality			= nil
	self.img_icon				= nil
	
	self.txt_desc				= nil

	self.txt_price				= nil
	self.txt_buy_limit_tips 	= nil

	--剩余购买个数信息
	self.lbl_remaining_title 	= nil
	self.txt_remaining_num 		= nil

	self.img_zhekou		= nil
	self.bg_time		= nil
	self.txt_time		= nil
	--调用父类方法
	self.super.removeUI(self)
end


function AdventureShoppingLayer:onShow()
	self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function AdventureShoppingLayer:refreshBaseUI()
end

function AdventureShoppingLayer:refreshUI()
	local goodsData = ItemData:objectByID(self.commodityData.res_id)
	if goodsData == nil  then
		print("道具表无此数据 id == " .. self.commodityData.res_id)
		return
	end

	self.txt_name:setText(goodsData.name)
	self.txt_desc:setText(goodsData.details)
	self.img_quality:setTexture(GetBackgroundForGoods(goodsData))
	self.img_icon:setTexture(goodsData:GetPath())
	self.img_res_icon:setTexture(GetResourceIconForGeneralHead(self.type))

	self.txt_remaining_num:setText(BagManager:getItemNumById(self.commodityData.consume_id))
	self.lbl_remaining_title:setText(localizable.youli_shop_txt2)
	self:setShopNum(self.num or 1)
	
	local remainingNumber = self:getRemainingNumber()
	local percent = math.ceil(self.num/remainingNumber*100)
	self.slider_shop:setPercent(percent)

	self.txt_own_num:setVisible(false)
	self.lbl_own_title:setVisible(false)
end

function AdventureShoppingLayer:setCommodityData(data)
	self.commodityData = data
end

function AdventureShoppingLayer.reduceButtonClickHandle(sender)
	local count = tonumber(sender.logic.txt_num:getText())
	count = count - 1
	if count > 0 then
		sender.logic:setShopNum(count)
	end

	local percent = math.ceil(count/sender.logic:getRemainingNumber()*100)
	sender.logic.slider_shop:setPercent(percent)
end

function AdventureShoppingLayer.addButtonClickHandle(sender)
	local count = tonumber(sender.logic.txt_num:getText())
	count = count + 1
	sender.logic:setShopNum(count)

	local percent = math.ceil(count/sender.logic:getRemainingNumber()*100)
	sender.logic.slider_shop:setPercent(percent)
end



--设置按钮状态
function AdventureShoppingLayer:setButtonState(addEnabled,reduceEnabled,buyEnabled)
	self.btn_buy:setTouchEnabled(buyEnabled)
	self.btn_buy:setGrayEnabled(not buyEnabled)

	if buyEnabled then
		Public:addBtnWaterEffect(self.btn_buy, true,1)
	else
		Public:addBtnWaterEffect(self.btn_buy, false)
	end
	
	self.btn_reduce:setTouchEnabled(reduceEnabled)
	self.btn_reduce:setGrayEnabled(not reduceEnabled)


	self.btn_add:setTouchEnabled(addEnabled)
	self.btn_add:setGrayEnabled(not addEnabled)

end

function AdventureShoppingLayer:getRemainingNumber()
	local singlePrice = self.commodityData.consume_number
	if singlePrice == 0 then return 1 end
	local currentResValue = BagManager:getItemNumById(self.commodityData.consume_id)
	local maxNum = math.floor(currentResValue/singlePrice)
	if maxNum <= 0 then
		maxNum = 1
	end
	return maxNum
end

function AdventureShoppingLayer:setShopNum( num )
	local remainingNumber = self:getRemainingNumber()
	if remainingNumber <= 0 then
		self.txt_num:setText(0)
		self.txt_numnow:setText(0)
		self.txt_price:setText(0)
		self:setButtonState(false,false,false)
		self.txt_price:setColor(ccc3(255, 0, 0))
		return 
	end

	if num < 1 then
		num = 1
	end

	if num > remainingNumber then
		num = remainingNumber
	end

	self.num = num

	local singlePrice = self.commodityData.consume_number

	local totalPrice = singlePrice * num
	self.txt_num:setText(num)
	self.txt_numnow:setText(num)
	self.txt_price:setText(totalPrice)
	local singlePrice = self.commodityData.consume_number
	local currentResValue = BagManager:getItemNumById(self.commodityData.consume_id)
	if currentResValue < singlePrice * num then
		self.txt_price:setColor(ccc3(255, 0, 0))
	else
		self.txt_price:setColor(ccc3(255, 255, 255))
	end
	--self.txt_num:setColor(ccc3(0, 255, 0))
	local canAdd = remainingNumber > num
	local canReduce = remainingNumber > 1 and num > 1
	self:setButtonState(canAdd,canReduce,true)
end

function AdventureShoppingLayer.buyButtonClickHandle(sender)
	local self = sender.logic
	local num =  tonumber(self.txt_num:getText())

	if num < 1 then
		--toastMessage("购买个数不可小于1")
		toastMessage(localizable.AdventureShop_text1)
		return
	end
	local singlePrice = self.commodityData.consume_number
	local currentResValue = BagManager:getItemNumById(self.commodityData.consume_id)
	if currentResValue < num * singlePrice then 
		local item = ItemData:objectByID(self.commodityData.consume_id)
		toastMessage(item.name..localizable.youli_shop_txt1)
		return
	end

	local singlePrice = self.commodityData.consume_number
	local totalPrice = singlePrice * num

	if totalPrice <= BagManager:getItemNumById(self.commodityData.consume_id) then
		showLoading()
		AdventureManager:buyTianShu(self.commodityData,num)
	end
end

function AdventureShoppingLayer.sliderTouchBeginHandle(sender)
	local self = sender.logic
	self.bg_jindushuzhi:setVisible(true)
	self:freshSliderNum()
end

function AdventureShoppingLayer.sliderTouchMoveHandle(sender)
	local self = sender.logic
	self:freshSliderNum()
end

function AdventureShoppingLayer.sliderTouchEndHandle(sender)
	local self = sender.logic
	if self:getRemainingNumber() <= 0 then 
		return 
	end
	local percent = math.ceil(self.num/self:getRemainingNumber()*100)
	self.slider_shop:setPercent(percent)
	self.bg_jindushuzhi:setVisible(false)
end


function AdventureShoppingLayer:freshSliderNum()
	local percent = self.slider_shop:getPercent()/100
	local num = math.ceil(percent*self:getRemainingNumber())
	num = math.max(num,1)
	self:setShopNum(num)
	local width = self.slider_shop:getSize().width
	local temp = math.ceil(width*percent)
	self.bg_jindushuzhi:setPositionX(temp - width/2)
end

--刷新回调
function AdventureShoppingLayer:refreshCallback()
    self:refreshUI()
end

function AdventureShoppingLayer:registerEvents()
	self.super.registerEvents(self)

	ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
	self.btn_close:setClickAreaLength(100);

	self.btn_add:addMEListener(TFWIDGET_CLICK, audioClickfun(self.addButtonClickHandle),1)
	self.btn_reduce:addMEListener(TFWIDGET_CLICK, audioClickfun(self.reduceButtonClickHandle),1)
	self.btn_buy:addMEListener(TFWIDGET_CLICK, audioClickfun(self.buyButtonClickHandle),1)

     --购买成功通知
     self.buySuccessCallback = function (event)
         --self:refreshCallback()
         hideLoading()
         AlertManager:close()
     end

    TFDirector:addMEGlobalListener(AdventureManager.adventureShopBuy, self.buySuccessCallback)

	self.slider_shop:addMEListener(TFWIDGET_TOUCHBEGAN, audioClickfun(self.sliderTouchBeginHandle),1)
	self.slider_shop:addMEListener(TFWIDGET_TOUCHMOVED, audioClickfun(self.sliderTouchMoveHandle),1)
	self.slider_shop:addMEListener(TFWIDGET_TOUCHENDED, audioClickfun(self.sliderTouchEndHandle),1)

end

function AdventureShoppingLayer:removeEvents()
    self.btn_add:removeMEListener(TFWIDGET_CLICK)
	self.btn_reduce:removeMEListener(TFWIDGET_CLICK)
	self.btn_buy:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(AdventureManager.adventureShopBuy, self.buySuccessCallback)


	self.slider_shop:removeMEListener(TFWIDGET_TOUCHBEGAN)
	self.slider_shop:removeMEListener(TFWIDGET_TOUCHMOVED)
	self.slider_shop:removeMEListener(TFWIDGET_TOUCHENDED)

    self.super.removeEvents(self)
end

return AdventureShoppingLayer;

require "app.cfg.shop_time_recharge_info"

local RechargeItem = class("RechargeItem",function()
	return CCSItemCellBase:create("ui_layout/shop_ShopRechargeItem.json")
	end)


function RechargeItem:ctor(...)
	self:enableLabelStroke("Label_num1", Colors.strokeBrown,1)
	self:enableLabelStroke("Label_num2", Colors.strokeBrown,1)
	self:enableLabelStroke("Label_num3", Colors.strokeBrown,1)
	self:enableLabelStroke("Label_price", Colors.strokeBrown,1)
	-- self:setTouchEnabled(true)
	self._rechargeFunc = nil
	self._priceLabel = self:getLabelByName("Label_price")
	self._tipsLabel = self:getLabelByName("Label_desc")
	self._priceImg = self:getImageViewByName("Image_price")

	self._bgImg = self:getImageViewByName("Image_bg")
	self._yuanImg = self:getImageViewByName("Image_yuan")
	self._rechargeBtn = self:getButtonByName("Button_recharge")
	self:registerBtnClickEvent("Button_recharge",function()
		if self._rechargeFunc then
			self._rechargeFunc()
		end
		end)
end

function RechargeItem:setRechargeFunc(func)
	self._rechargeFunc = func
end

function RechargeItem:update(item)
	local data = item.data
	if data == nil then
		return
	end
	--判断是月卡还是普通商品
	-- if item.type == 1 then   --月卡
	-- 	--显示月卡的提示文字
	-- 	self._tipsLabel = self:getLabelByName("Label_tips_month_card")
	-- 	self:showWidgetByName("Label_tips_month_card",true)
	-- 	self:showWidgetByName("Label_tips",false)

	-- 	self._bgImage:loadTextureNormal("board_red.png",UI_TEX_TYPE_PLIST)
	-- 	self:showWidgetByName("Image_shouchong",false)
	-- 	self._tipsLabel:setColor(Colors.lightColors.TIPS_01)
	-- 	self._nameBgImage:loadTexture("ui/shop/yueka_bg.png")

	-- 	if self._richText then
	-- 		self._richText:setVisible(false)
	-- 	end

	-- 	if G_Me.shopData:monthCardPurchasability(data.id) then  --可购买
	-- 		self:showWidgetByName("Image_putong",true)
	-- 		self:showWidgetByName("Image_yuekaStatus",false)
	-- 		-- self._tipsLabel:setText("每天可领取" .. data.gold_back .. "元宝")
	-- 		self._tipsLabel:setText(G_lang:get("LANG_MONTH_CARD_PURCHASE_TIPS",{gold=data.recharge_gold,day_gold=data.gold_back}))

	-- 	elseif G_Me.shopData:getMonthCardLeftDay(data.id) > 0 then  --剩余天数 > 0
	-- 		--显示的文字要居中
	-- 		self:showWidgetByName("Label_tips_month_card",false)
	-- 		self:showWidgetByName("Label_tips",true)
	-- 		self._tipsLabel = self:getLabelByName("Label_tips")
			
	-- 		self:showWidgetByName("Image_putong",false)
	-- 		self:showWidgetByName("Image_yuekaStatus",true)
	-- 		local leftDay = G_Me.shopData:getMonthCardLeftDay(data.id)

	-- 		local appstoreVersion = (G_Setting:get("appstore_version") == "1")
	-- 		self._tipsLabel:setText(G_lang:get("LANG_RECHARGE_MONTH_CARD_GOLD",{num=data.gold_back,days=leftDay}))

	-- 		if G_Me.shopData:useEnabled(data.id) then
	-- 			--可用
	-- 			self._monthCardStatusImage:loadTexture(G_Path.getTextPath("jqfb_dianjilingqu.png"))
	-- 		else
	-- 			--不可用
	-- 			self._monthCardStatusImage:loadTexture(G_Path.getTextPath("jqfb_yilingqu.png"))
	-- 		end
	-- 	end
	-- else
	local isPrivilegeShow = false
	if G_Me.timePrivilegeData ~= nil and G_Me.timePrivilegeData.getRealRechargeId ~= nil then
		local rechageId = 0
		rechageId, _ = G_Me.timePrivilegeData:getRealRechargeId()
		isPrivilegeShow = rechageId == data.id
	end
	local firstRecharge = G_Me.shopData:firstRecharge(data.id)
	local bgName = isPrivilegeShow and "ui/shop/chongzhi_bg1.png" or "ui/shop/chongzhi_bg2.png"
	self._bgImg:loadTexture(bgName)
	self:showWidgetByName("Image_shouchong",firstRecharge)
-- ,{gold=data.gift_gold_first}
-- ,{gold=data.gift_gold}
	local rechargeText = firstRecharge and G_lang:get("LANG_RECHARGE_GIFT_GOLD_1") or G_lang:get("LANG_RECHARGE_GIFT_GOLD_2")
	self._tipsLabel:setText(rechargeText)

	self._priceImg:loadTexture("ui/text/txt/cz_yuanbao_"..data.recharge_gold..".png")
	
	local twoItem = firstRecharge and data.gift_type_first > 0
	self:getPanelByName("Panel_item1"):setVisible(not twoItem)
	self:getPanelByName("Panel_item2"):setVisible(twoItem)

	local totalYuan = firstRecharge and data.gift_gold_first or data.gift_gold
	totalYuan = isPrivilegeShow and totalYuan + G_Me.timePrivilegeData:getExtraGold() or totalYuan

	local updateItem = function ( index,type,value,size,show )
		local goods = G_Goods.convert(type,value)
		self:getImageViewByName("Image_icon"..index):loadTexture(goods.icon)
		self:getLabelByName("Label_num"..index):setText("x"..size)
		self:getImageViewByName("Image_youhui"..index):setVisible(show)
		self:getButtonByName("Button_board"..index):loadTextureNormal(G_Path.getEquipColorImage(goods.quality))
		self:getImageViewByName("Image_ball"..index):loadTexture(G_Path.getEquipIconBack(goods.quality))
		self:registerBtnClickEvent("Button_board"..index, function ( widget )
		    require("app.scenes.common.dropinfo.DropInfo").show(type, value)  
		end)  
	end

	if twoItem then
		updateItem(2,2,0,totalYuan,isPrivilegeShow)
		updateItem(3,data.gift_type_first,data.gift_value_first,data.gift_size_first,false)
	else
		updateItem(1,2,0,totalYuan,isPrivilegeShow)
	end

	self._priceLabel:setText(data.size)
	local x1 = self._yuanImg:getContentSize().width
	local x2 = self._priceLabel:getContentSize().width
	self._yuanImg:setPositionX(-x2/2)
	self._priceLabel:setPositionX(x1/2)
	-- -- 是否显示优惠标签
	-- if isPrivilegeShow then
	-- 	self._shouChongImage:loadTexture(G_Path.getTextPath("sc_youhui.png"))
	-- 	self:showWidgetByName("Image_shouchong",true)
	-- 	local privilegeGiftGoldNum = 0
	-- 	if G_Me.timePrivilegeData.getExtraGold ~= nil then
	-- 		privilegeGiftGoldNum = G_Me.timePrivilegeData:getExtraGold()
	-- 	end
	-- 	rechargeText =G_lang:get("LANG_PRIVILEGE_RECHARGE_GIFT_GOLD",{content1 = rechargeText, gold = privilegeGiftGoldNum or 0})
	-- 	self._tipsLabel:setVisible(false)
	-- 	self._richText:appendXmlContent(rechargeText)
	-- 	self._richText:reloadData()
	-- 	self._richText:setVisible(true)
	-- end

	-- end
	--默认7
	-- self._itemImage:loadTexture(G_Path.getRechargeIcon(data.res_id))
	-- self._priceLabel:setText(G_lang:get("LANG_PRICE_TAG",{price=data.size}))


end


return RechargeItem
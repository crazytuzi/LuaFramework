local GComponentBuy = {}

local buyButtons = {
	"btn_buy_dec", "btn_buy_inc", "btn_buy_max", "btn_commit", "btn_cancel"
}


function GComponentBuy:initView(extend)
	self.buyItem = nil -- 购买物品id
	self.itemPrice = 0
	self.buyNum = 1
	self.totalCost = 0
	self.commitCallFunc = nil

	local function updateItemNumAndCost()
		self.xmlTips:getWidgetByName("lbl_buy_num"):setString(self.buyNum)
		self.xmlTips:getWidgetByName("lbl_price_total"):setString(self.buyNum * self.itemPrice)
	end

	local function decBuyItemNum()
		if self.buyNum > 1 then
			self.buyNum = self.buyNum - 1
			updateItemNumAndCost()
		end
	end

	local function incBuyItemNum()
		if (self.buyNum + 1) * self.itemPrice <= GameSocket.mCharacter.mVCoin then
			self.buyNum = self.buyNum + 1
			updateItemNumAndCost()
		end
	end

	local function pushBuyButton(sender)
		local btnName = sender:getName()
		if btnName == "btn_buy_dec" then
			decBuyItemNum()
		elseif btnName == "btn_buy_inc" then
			incBuyItemNum()
		elseif btnName == "btn_buy_max" then
			self.buyNum = math.floor(GameSocket.mCharacter.mVCoin / self.itemPrice)
			updateItemNumAndCost()
		elseif btnName == "btn_commit" then
			if self.commitCallFunc then
				self.commitCallFunc(self.buyNum)
			end
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		elseif btnName == "btn_cancel" then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		end
	end

	local function initBuyButtons()
		local btnBuy
		for _,v in ipairs(buyButtons) do
			btnBuy = self.xmlTips:getWidgetByName(v)
			if btnBuy then
				GUIFocusPoint.addUIPoint(btnBuy, pushBuyButton)
			end
		end
	end

	local function updateItemInfo()
		if self.buyItem then
			local itemDef = GameSocket:getItemDefByID(self.buyItem)
			if itemDef then
				local lblItemName = self.xmlTips:getWidgetByName("lbl_item_name")
				lblItemName:setString(itemDef.mName)
				if not self.itemPrice then
					self.itemPrice = itemDef.mPrice
				end
				local lblPriceNum = self.xmlTips:getWidgetByName("lbl_price_num")
				lblPriceNum:setString(itemDef.mPrice)
			end
		end
	end

	if self.xmlTips then
		--GameUtilSenior.asyncload(self.xmlTips, "tips_bg", "ui/image/prompt_bg.png")
		--GameUtilSenior.asyncload(self.xmlTips, "img_buy_innerbg", "ui/image/img_buy_innerBg.jpg")
		initBuyButtons()
		if extend.itemId then
			self.buyItem = extend.itemId
			local itemBg = self.xmlTips:getWidgetByName("item_bg")
			GUIItem.getItem({parent=itemBg, typeId=extend.itemId})
			updateItemInfo()
		end
		if extend.itemPrice then
			self.itemPrice = extend.itemPrice
		end
		if extend.commitCallFunc then
			self.commitCallFunc = extend.commitCallFunc
		end

		updateItemNumAndCost()
		
		cc.EventProxy.new(GameSocket,self.xmlTips)
			:addEventListener(GameMessageCode.EVENT_NOTIFY_GETITEMDESP, function (event)
				if self.buyItem == event.type_id then
					updateItemInfo()
				end
			end)
	end
end
return GComponentBuy
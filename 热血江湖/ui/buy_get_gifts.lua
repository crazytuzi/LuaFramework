-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------

wnd_buy_get_gifts = i3k_class("wnd_buy_get_gifts",ui.wnd_base)
local e_Type_vip_store_yuanbao = 1
local e_Type_vip_store_bangyuan = 0
local e_Type_vip_store_hongli = 3
local e_Type_vip_store_longhun = 4
local SALE_COUNT_TEXT 		= 1
local marketType =
{
	{currency = -g_BASE_ITEM_DIAMOND, icon = 32, isSuo = false}, --元宝商城
	{currency = g_BASE_ITEM_DIAMOND, icon = 32, isSuo = true}, --绑元商城
	{currency = g_BASE_ITEM_DIVIDEND, icon = 3850, isSuo = false}, --红利商城
	{currency = g_BASE_ITEM_DRAGON_COIN, icon = 5005, isSuo = false}, -- 龙魂币
}

function wnd_buy_get_gifts:ctor()
	self._item_count = 0
	self._item_count_filter = 0
	self._firstTimes = true
	self._extraGifts = {}
	self.market = 1
end

function wnd_buy_get_gifts:refresh(sendcommond, item, limitTimes, extraGifts)
	SALE_COUNT_TEXT = 1
	self.sendcommond = sendcommond	--发送协议与参数
	self.item = item		--物品信息
	self.limitTimes = limitTimes	--限购次数，可能为空
	if self.limitTimes then
		self.max_bt:setVisible(true)
	else
		self.jia10:setVisible(true)
	end
	self:judgeMarketType()
	self:showInfo();
	self:showExtraGifts(extraGifts)
end

function wnd_buy_get_gifts:configure(...)
	local screenSize = cc.Director:getInstance():getWinSize();
	local rootSize = self._layout.root:getContentSize();
	local widget = self._layout.vars
	self.item_bg = widget.item_bg
	self.item_icon = widget.item_icon
	self.item_name = widget.item_name
	self.item_type = widget.item_type
	self.item_des = widget.item_des
	self.sale_count = widget.sale_count
	self.item_price = widget.item_price
	self.item_price_icon = widget.item_price_icon
	self.item_currency_icon = widget.item_currency
	self.extraCount = widget.extraCount
	self.sale_count:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.sale_count:addEventListener(function(eventType)
		if eventType == "ended" then
			local num = tonumber(self.sale_count:getText()) or 1
			if self.limitTimes and num > self.limitTimes then
				num = self.limitTimes
			end
			local have = g_i3k_game_context:GetBaseItemCanUseCount(marketType[self.market].currency)
			if num * self.item.finalprice > have then
				num = math.floor(have/self.item.finalprice)
			end
			if num < 1 then
				num = 1
			end
			if num > g_edit_box_max then
				num = g_edit_box_max
			end
			SALE_COUNT_TEXT = num
			self.sale_count:setText(SALE_COUNT_TEXT)
			self.extraCount:setText(string.format("x%s", SALE_COUNT_TEXT * self._extraGifts[1].count))
			self.item_price:setText(SALE_COUNT_TEXT * self.item.finalprice)
		end
	end)
	self.max_bt = widget.max
	self.jia10 = widget.jia10
	self.max_bt:setVisible(false)
	self.jia10:setVisible(false)
	self.sale_count:setText(SALE_COUNT_TEXT)
	widget.jian:onTouchEvent(self, self.jianButton)
	widget.jia:onTouchEvent(self, self.jiaButton)
	widget.max:onTouchEvent(self, self.maxButton)
	widget.jia10:onTouchEvent(self, self.jia10Button)
	widget.cancel:onTouchEvent(self, self.cancelButton)
	widget.ok:onTouchEvent(self, self.okButton)
end

function wnd_buy_get_gifts:judgeMarketType()
	if self.sendcommond.free == e_Type_vip_store_yuanbao then
		self.market = 1
	elseif self.sendcommond.free == e_Type_vip_store_bangyuan then
		self.market = 2
	elseif self.sendcommond.free == e_Type_vip_store_hongli then
		self.market = 3
	elseif self.sendcommond.free == e_Type_vip_store_longhun then
		self.market = 4
	end
end

function wnd_buy_get_gifts:showInfo()
	local have = g_i3k_game_context:GetBaseItemCanUseCount(marketType[self.market].currency)
	self._item_count = math.floor(have/self.item.finalprice)--拥有的货币可购买的数量
	self._item_count_filter = self.market == 1 and self._item_count + 1 or g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)/self.item.finalprice + 1
	if self.limitTimes and self.limitTimes < self._item_count then
		self._item_count = self.limitTimes
	end
	self._layout.vars.getStr:setText(g_i3k_db.i3k_db_get_common_item_source(self.item.iid))
	self.item_des:setText(g_i3k_db.i3k_db_get_common_item_desc(self.item.iid))
	local itemname = i3k_db.i3k_db_get_common_item_name(self.item.iid) or ""
	self.sendcommond.itemname = itemname;
	if self.item.icount > 1 then
		itemname = itemname.."*"..self.item.icount
	end
	self.item_name:setText(itemname)
	self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self.item.iid)))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.item.iid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.item.iid,i3k_game_context:IsFemaleRole()))
	self.item_price_icon:setVisible(marketType[self.market].isSuo)
	self.item_currency_icon:setImage(g_i3k_db.i3k_db_get_icon_path(marketType[self.market].icon))
	self.sale_count:setText(SALE_COUNT_TEXT)
	self.item_price:setText(SALE_COUNT_TEXT*self.item.finalprice);
	self.item_type:hide()
end

function wnd_buy_get_gifts:showExtraGifts(extraGifts)
	local widget = self._layout.vars
	self._extraGifts = {}
	for k, v in pairs(extraGifts.gifts) do
		if self.item.iid == v.gitem.id then
			table.insert(self._extraGifts, {id = v.iid, count = v.icount})
			widget.title:setText(i3k_get_string(1156, extraGifts.title))
			widget.content:setText(i3k_get_string(1157))
			widget.extraDesc:setText(i3k_get_string(1158))
			widget.extraBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.iid))
			widget.extraIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.iid))
			widget.extraCount:setText(string.format("x%s", v.icount * SALE_COUNT_TEXT))
			widget.extraBtn:onClick(self, self.onItem, v.iid)
			return
		end
	end
end

function wnd_buy_get_gifts:onItem(sender, id)
	g_i3k_ui_mgr:OpenUI(eUIID_ItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_ItemInfo, id, true)
end

function wnd_buy_get_gifts:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_BuyGetGifts)
	end
end

function wnd_buy_get_gifts:jianButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if tonumber(SALE_COUNT_TEXT) > 1 then
			SALE_COUNT_TEXT = SALE_COUNT_TEXT - 1
			self.sale_count:setText(SALE_COUNT_TEXT);
			self.extraCount:setText(string.format("x%s", SALE_COUNT_TEXT * self._extraGifts[1].count))
			self.item_price:setText(SALE_COUNT_TEXT*self.item.finalprice);
		end
	end
end

function wnd_buy_get_gifts:jiaButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.limitTimes and SALE_COUNT_TEXT < self.limitTimes then
			SALE_COUNT_TEXT = SALE_COUNT_TEXT + 1
			self.sale_count:setText(SALE_COUNT_TEXT)
			self.extraCount:setText(string.format("x%s", SALE_COUNT_TEXT * self._extraGifts[1].count))
			self.item_price:setText(SALE_COUNT_TEXT*self.item.finalprice)
		elseif not self.limitTimes then
			SALE_COUNT_TEXT = SALE_COUNT_TEXT + 1
			self.sale_count:setText(SALE_COUNT_TEXT);
			self.extraCount:setText(string.format("x%s", SALE_COUNT_TEXT * self._extraGifts[1].count))
			self.item_price:setText(SALE_COUNT_TEXT*self.item.finalprice);
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(436))
		end
	end
end

--限购里
function wnd_buy_get_gifts:maxButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.limitTimes and SALE_COUNT_TEXT < self.limitTimes then
			SALE_COUNT_TEXT = self.limitTimes
			self.sale_count:setText(SALE_COUNT_TEXT);
			self.extraCount:setText(string.format("x%s", SALE_COUNT_TEXT * self._extraGifts[1].count))
			self.item_price:setText(SALE_COUNT_TEXT*self.item.finalprice);
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(436))
		end
	end
end

function wnd_buy_get_gifts:jia10Button(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local count = 10
		if self._firstTimes then
			count = 9
			self._firstTimes = false
		end
		if self._item_count then
			SALE_COUNT_TEXT = SALE_COUNT_TEXT + count
			self.sale_count:setText(SALE_COUNT_TEXT);--数量
			self.extraCount:setText(string.format("x%s", SALE_COUNT_TEXT * self._extraGifts[1].count))
			self.item_price:setText(SALE_COUNT_TEXT*self.item.finalprice);--总价
		end
	end
end

function wnd_buy_get_gifts:cancelButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if l_fCancelCallBack then
			l_fCancelCallBack()
		end
		g_i3k_ui_mgr:CloseUI(eUIID_BuyGetGifts)
	end
end

function wnd_buy_get_gifts:okButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if SALE_COUNT_TEXT > 0 then
			if self:canAfford(SALE_COUNT_TEXT * self.item.finalprice) then
				if self:canBuyVIP(self.item) then
					if self.limitTimes == 0 then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(214))
					else
						local test = {}
						test[self.item.iid] = SALE_COUNT_TEXT * self.item.icount
						if #self._extraGifts > 0 then
							test[self._extraGifts[1].id] = SALE_COUNT_TEXT * self._extraGifts[1].count
						end
						if g_i3k_game_context:IsBagEnough(test) then
							self.sendcommond.count = SALE_COUNT_TEXT
							if SALE_COUNT_TEXT >= self._item_count_filter then
								local effectiveTime = self.sendcommond.effectiveTime
								local id = self.sendcommond.id
								local gid = self.sendcommond.gid
								local count = self.sendcommond.count
								local free = self.sendcommond.free
								local price = self.sendcommond.price
								local itemname = self.sendcommond.itemname
								local finalcount = SALE_COUNT_TEXT * self.item.icount
								local currencyType = marketType[self.market].currency
								local callfunction = function(ok)
									if ok then
										i3k_sbean.mall_buy(effectiveTime,id,gid,count,currencyType,price,itemname,finalcount)
									end
								end
								local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
								local msg = ""
								if have == 0 then
									msg = i3k_get_string(217,self.item.finalprice*count)
								else
									msg = i3k_get_string(299,have,(self.item.finalprice*count-have))--have,(self.sendcommond.price-have))
								end
								g_i3k_ui_mgr:ShowCustomMessageBox2("购买", "取消", msg, callfunction)
							else
								local currencyType = marketType[self.market].currency
								i3k_sbean.mall_buy(self.sendcommond.effectiveTime,self.sendcommond.id,self.sendcommond.gid,self.sendcommond.count,currencyType,self.sendcommond.price,self.sendcommond.itemname,SALE_COUNT_TEXT *self.item.icount)
							end
							g_i3k_ui_mgr:CloseUI(eUIID_BuyGetGifts)
						else
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(215))
							g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "isNeedRefreshLog")
							g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "setStoreList",false)
						end
					end
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(213,self.item.vipReq))
				end
			else
				local fun = (function(ok)
					if ok then
						g_i3k_logic:OpenChannelPayUI()
					end
				end)
				if self.sendcommond.free == e_Type_vip_store_hongli then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3079))
				elseif self.sendcommond.free == e_Type_vip_store_longhun then
					g_i3k_ui_mgr:ShowCustomMessageBox2("去储值", "以后再说", "你的龙魂币不够哦，需要充值吗", fun)
				else
					g_i3k_ui_mgr:ShowCustomMessageBox2("去储值", "以后再说", "你的元宝不够哦，需要储值吗", fun)
				end
			end
		end
	end
end

function wnd_buy_get_gifts:canAfford(price)
	local have = g_i3k_game_context:GetBaseItemCanUseCount(marketType[self.market].currency)
	if have >= price then
		return true
	end
	return false;
end

function wnd_buy_get_gifts:canBuyVIP(Item)
	if Item.vipReq then
		local viplvl = g_i3k_game_context:GetVipLevel()
		if viplvl < Item.vipReq then
			return false;
		end
	end
	return true;
end

function wnd_create(layout, ...)
	local wnd = wnd_buy_get_gifts.new()
	wnd:create(layout, ...)
	return wnd
end

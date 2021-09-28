-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------

wnd_head_preview = i3k_class("wnd_head_preview",ui.wnd_base)
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

function wnd_head_preview:ctor()
	self._item_count = 0
	self._item_count_filter = 0
	self._firstTimes = true
	self.market = 1
end

function wnd_head_preview:refresh(sendcommond, item, limitTimes)
	SALE_COUNT_TEXT = 1
	self.sendcommond = sendcommond	--发送协议与参数
	self.item = item		--物品信息
	self.limitTimes = limitTimes	--限购次数，可能为空

	self:judgeMarketType()
	self:showInfo()
	self:showHeadPreview()
end

function wnd_head_preview:configure(...)
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
			self.item_price:setText(SALE_COUNT_TEXT * self.item.finalprice)
		end
	end)
	self.jia10 = widget.jia10
	self.jia10:setVisible(false)

	self.sale_count:setText(SALE_COUNT_TEXT)
	widget.jian:onTouchEvent(self, self.jianButton)
	widget.jia:onTouchEvent(self, self.jiaButton)
	widget.cancel:onTouchEvent(self, self.cancelButton)
	widget.ok:onTouchEvent(self, self.okButton)

	self.headFrame = widget.headFrame
	self.headIcon = widget.tximage
	self.name_desc = widget.name_desc
end

function wnd_head_preview:judgeMarketType()
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

function wnd_head_preview:showInfo()
	local have = g_i3k_game_context:GetBaseItemCount(marketType[self.market].currency)
	self._item_count = self.market == 2 and math.floor(g_i3k_game_context:GetBaseItemCanUseCount(marketType[self.market].currency)/self.item.finalprice) or math.floor(have/self.item.finalprice)
	self._item_count_filter = self.market == 2 and math.floor(g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)/self.item.finalprice) + 1 or self._item_count + 1
	if self.limitTimes and self.limitTimes < self._item_count then
		self._item_count = self.limitTimes
	end
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

function wnd_head_preview:showHeadPreview()
	local itemID = self.item.iid
	local headID = nil
	for _, v in pairs(i3k_db_personal_icon) do
		if itemID == v.needItemId then
			headID = v.ID
			break
		end
	end
	if headID then
		self.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(headID, false))
		self.headFrame:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
		self.name_desc:setText(g_i3k_db.i3k_db_get_common_item_name(self.item.iid) or "")
	end
end

function wnd_head_preview:jianButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:PopupTipMessage("不能再少了")
	end
end

function wnd_head_preview:jiaButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:PopupTipMessage("一次只能买一个哦")
	end
end

--限购里
function wnd_head_preview:maxButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.limitTimes and SALE_COUNT_TEXT < self.limitTimes then
			SALE_COUNT_TEXT = self.limitTimes
			self.sale_count:setText(SALE_COUNT_TEXT);
			self.item_price:setText(SALE_COUNT_TEXT*self.item.finalprice);
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(436))
		end
	end
end

function wnd_head_preview:cancelButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_Head_Preview)
	end
end

function wnd_head_preview:okButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if SALE_COUNT_TEXT > 0 then
			if self:canAfford(SALE_COUNT_TEXT * self.item.finalprice) then
				if self:canBuyVIP(self.item) then
					if self.limitTimes == 0 then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(214))
					else
						local test = {}
						test[self.item.iid] = SALE_COUNT_TEXT * self.item.icount
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
										i3k_sbean.mall_buy(effectiveTime,id,gid,count,currencyType,price,itemname,finalcount, self.item.iid)
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
								i3k_sbean.mall_buy(self.sendcommond.effectiveTime,self.sendcommond.id,self.sendcommond.gid,self.sendcommond.count,currencyType,self.sendcommond.price,self.sendcommond.itemname,SALE_COUNT_TEXT *self.item.icount, self.item.iid)
							end
							g_i3k_ui_mgr:CloseUI(eUIID_Head_Preview)
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

function wnd_head_preview:canAfford(price)
	local have = g_i3k_game_context:GetBaseItemCanUseCount(marketType[self.market].currency)
	if have >= price then
		return true
	end
	return false;
end

function wnd_head_preview:canBuyVIP(Item)
	if Item.vipReq then
		local viplvl = g_i3k_game_context:GetVipLevel()
		if viplvl < Item.vipReq then
			return false;
		end
	end
	return true;
end

function wnd_create(layout, ...)
	local wnd = wnd_head_preview.new()
	wnd:create(layout, ...)
	return wnd
end

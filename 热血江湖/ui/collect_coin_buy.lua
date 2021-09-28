-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------

wnd_collect_coin_buy = i3k_class("wnd_collect_coin_buy",ui.wnd_base)

local SALE_COUNT_TEXT = 1

local marketType =
{
	[g_BUYCOLLECTCOIN_TYPE] = {currency = g_BASE_ITEM_DRAGON_COIN, icon = 5005, isSuo = false}, -- 购买纪念金币
	-- {currency = -g_BASE_ITEM_DIAMOND, icon = 32, isSuo = false}, --元宝商城
	-- {currency = g_BASE_ITEM_DIAMOND, icon = 32, isSuo = true}, --绑元商城
	-- {currency = g_BASE_ITEM_DIVIDEND, icon = 3850, isSuo = false}, --红利商城
}

function wnd_collect_coin_buy:ctor()
	self._item_count = 0
end

function wnd_collect_coin_buy:configure(...)
    local widget = self._layout.vars
    self.item_name = widget.item_name
    self.item_bg = widget.item_bg
    self.item_icon = widget.item_icon
    self.item_des = widget.item_des

    widget.jian:onTouchEvent(self, self.jianButton)
    self.sale_count = widget.sale_count
    self.sale_count:setText(SALE_COUNT_TEXT)
    widget.jia:onTouchEvent(self, self.jiaButton)
    self.jia10 = widget.jia10
    widget.jia10:onTouchEvent(self, self.jia10Button)
    widget.jia10:setVisible(false)
    self.max_bt = widget.max
    widget.max:onTouchEvent(self, self.maxButton)
    widget.max:setVisible(false)
    self.item_price = widget.item_price
    self.item_currency_icon = widget.item_currency
    self.item_price_icon = widget.item_price_icon
    widget.cancel:onTouchEvent(self, self.cancelButton)
    widget.ok:onTouchEvent(self, self.okButton)

    self._layout.vars.item_type:setVisible(false)
    self._layout.vars.getStr:setVisible(false)

    self.sale_count:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
    self.sale_count:addEventListener(function(eventType)
        if eventType == "ended" then
            local num = tonumber(self.sale_count:getText()) or 1
            if self.data.limitTimes and num > self.data.limitTimes then
                num = self.data.limitTimes
            end
            --local have = g_i3k_game_context:GetBaseItemCanUseCount(marketType[self.data.buyType].currency)
            -- if num * self.data.unitPrice > have then
            --     num = math.floor(have / self.data.unitPrice)
            -- end
            if num < 1 then
                num = 1
            end
            if num > g_edit_box_max then
                num = g_edit_box_max
            end
            SALE_COUNT_TEXT = num
            self.sale_count:setText(SALE_COUNT_TEXT)
            self.item_price:setText(SALE_COUNT_TEXT * self.data.unitPrice)
        end
    end)
end

function wnd_collect_coin_buy:refresh(data)
    self.data = data

	SALE_COUNT_TEXT = 1

	self:showInfo()
end

function wnd_collect_coin_buy:showInfo()
    local itemname = i3k_db.i3k_db_get_common_item_name(self.data.itemId)
    self.item_name:setText(itemname)
    self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self.data.itemId)))
    self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.data.itemId))
    self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.data.itemId))
    self.item_des:setText(g_i3k_db.i3k_db_get_common_item_desc(self.data.itemId))

    --self._layout.vars.getStr:setText(g_i3k_db.i3k_db_get_common_item_source(self.data.itemId))
	if self.data.limitTimes then    --限购次数
		self.max_bt:setVisible(true)
	else
		self.jia10:setVisible(true)
    end
    self.sale_count:setText(SALE_COUNT_TEXT)
    self.item_price:setText(SALE_COUNT_TEXT * self.data.unitPrice);
    self.item_currency_icon:setImage(g_i3k_db.i3k_db_get_icon_path(marketType[self.data.buyType].icon))
    self.item_price_icon:setVisible(marketType[self.data.buyType].isSuo)

	local have = g_i3k_game_context:GetBaseItemCount(marketType[self.data.buyType].currency)
	self._item_count = math.floor(have / self.data.unitPrice)
    
    if self.data.limitTimes and self.data.limitTimes < self._item_count then
		self._item_count = self.limitTimes
	end
end

function wnd_collect_coin_buy:jianButton(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if tonumber(SALE_COUNT_TEXT) > 1 then
			SALE_COUNT_TEXT = SALE_COUNT_TEXT - 1
			self.sale_count:setText(SALE_COUNT_TEXT)
			self.item_price:setText(SALE_COUNT_TEXT * self.data.unitPrice)
		end
	end
end

function wnd_collect_coin_buy:jiaButton(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.data.limitTimes and SALE_COUNT_TEXT < self.data.limitTimes then
			SALE_COUNT_TEXT = SALE_COUNT_TEXT + 1
			self.sale_count:setText(SALE_COUNT_TEXT)
			self.item_price:setText(SALE_COUNT_TEXT * self.data.unitPrice)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(436))
		end
	end
end

function wnd_collect_coin_buy:maxButton(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.data.limitTimes and SALE_COUNT_TEXT < self.data.limitTimes then
			SALE_COUNT_TEXT = self.data.limitTimes
			self.sale_count:setText(SALE_COUNT_TEXT);
			self.item_price:setText(SALE_COUNT_TEXT * self.data.unitPrice);
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(436))
		end
	end
end

function wnd_collect_coin_buy:jia10Button(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
        local count = SALE_COUNT_TEXT + 10
        if count < self.data.limitTimes then
            SALE_COUNT_TEXT = count
            self.sale_count:setText(SALE_COUNT_TEXT)
			self.item_price:setText(SALE_COUNT_TEXT * self.data.unitPrice)
        else
            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(436))
        end
	end
end

function wnd_collect_coin_buy:cancelButton(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if l_fCancelCallBack then
			l_fCancelCallBack()
		end
		g_i3k_ui_mgr:CloseUI(eUIID_JnCoinBuyTips)
	end
end

function wnd_collect_coin_buy:okButton(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:specialCheck(self.okButtonImpl)
	end
end

function wnd_collect_coin_buy:specialCheck(func)--okButtonImpl
	local name = g_i3k_game_context:checkSteedPackages(self.data.itemId)
	if name then
		local cb = function(ok)
			if ok then 
				func(self)
			end
		end
		g_i3k_ui_mgr:ShowCustomMessageBox2("购买", "取消", i3k_get_string(18903, name), cb)
	else
		func(self)
	end
end

function wnd_collect_coin_buy:okButtonImpl()
	if SALE_COUNT_TEXT > 0 then
		if self:canAfford(SALE_COUNT_TEXT * self.data.unitPrice) then
            if self.data.limitTimes > 0 then
				if self.data.buyType == g_BUYCOLLECTCOIN_TYPE then
                    i3k_sbean.syncBuycomCoin(SALE_COUNT_TEXT)
                end
            else
                g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(214))
            end
		else
			local free = marketType[self.data.buyType].currency
			local fun = (function(ok)
				if ok then
					if free == g_BASE_ITEM_DRAGON_COIN then
						g_i3k_logic:OpenChannelPayUI(nil, g_CHANNEL_LONGHUNBI_TYPE)
					else
						g_i3k_logic:OpenChannelPayUI()
					end
				end
			end)
			if free == g_BASE_ITEM_DIVIDEND then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3079))
			elseif free == g_BASE_ITEM_DRAGON_COIN then
				g_i3k_ui_mgr:ShowCustomMessageBox2("去储值", "以后再说", "你的龙魂币不够哦，需要充值吗", fun)
			else
				g_i3k_ui_mgr:ShowCustomMessageBox2("去储值", "以后再说", "你的元宝不够哦，需要储值吗", fun)
			end
		end	
	end
end

function wnd_collect_coin_buy:canAfford(price)
	local have = g_i3k_game_context:GetBaseItemCanUseCount(marketType[self.data.buyType].currency)
	if have >= price then
		return true
	end
	return false
end

function wnd_collect_coin_buy:canBuyVIP(Item)
	if Item.vipReq then
		local viplvl = g_i3k_game_context:GetVipLevel()
		if viplvl < Item.vipReq then
			return false;
		end
	end
	return true;
end

function wnd_create(layout, ...)
	local wnd = wnd_collect_coin_buy.new()
	wnd:create(layout, ...)
	return wnd
end

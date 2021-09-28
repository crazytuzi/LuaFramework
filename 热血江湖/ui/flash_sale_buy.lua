-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base")--add_sub")

-------------------------------------------------------
flash_sale_buy = i3k_class("flash_sale_buy",ui.wnd_base)
local e_Type_vip_store_yuanbao = -1
local e_Type_vip_store_bangyuan = 1
local SALE_COUNT_TEXT = 1 --输入框默认为1
local currency_icon = 32  --货币图标元宝

function flash_sale_buy:ctor()
	self._item_count = 0 --购买数量
	self._item_count_filter = 0 --最大数量+1
	self._firstTimes = true		--是否第一次点击加减按钮
end
function flash_sale_buy:refresh(info)
	SALE_COUNT_TEXT = 1
	self.item = info.items				--物品信息表
	self.limitTimes = info.limitTimes	--限购次数
	self.moneyid = info.moneyid  		--货币类型
	self.finalprice = info.nowprice		--单个价格
	self.levelReq = info.levelReq		--需求等级
	self.info = info
	self.jia10:setVisible(true)
	self:showInfo();
end
function flash_sale_buy:configure()
	local widget = self._layout.vars
	self.item_bg = widget.item_bg
	self.item_des = widget.item_des
	self.sale_count = widget.sale_count

	self.sale_count:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.sale_count:addEventListener(function(eventType)
		if eventType == "ended" then
		local str = tonumber(self.sale_count:getText()) or 1
		    if not self.limitTimes then
		    	self:judge(str)
			elseif tonumber(str)<= self.limitTimes then
				self:judge(str)
			else
				str = self.limitTimes
				self:judge(str)
		    end

		 end
	end)


	self.jian_bt = widget.jian
	self.jia_bt = widget.jia
	self.jia10 = widget.jia10
	self.cancel_bt = widget.cancel
	self.ok_bt = widget.ok
	self.item_price = widget.item_price
	self.item_price_icon = widget.item_price_icon
	self.item_currency_icon = widget.item_currency
	self.jia10:setVisible(false)

	self.sale_count:setText(SALE_COUNT_TEXT)
	self.jian_bt:onTouchEvent(self, self.jianButton)
	self.jia_bt:onTouchEvent(self, self.jiaButton)
	self.jia10:onTouchEvent(self, self.jia10Button)
	self.cancel_bt:onTouchEvent(self, self.cancelButton)
	self.ok_bt:onTouchEvent(self, self.okButton)
end
function flash_sale_buy:judge(num)
	if num < 1 then
		num = 1
	end
    if not self:canAfford(num*self.finalprice) then
	  	if self.moneyid == e_Type_vip_store_yuanbao then
		    local have = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
			num = math.floor(have/self.finalprice)
			if num <= 1 then
			    num = 1
		    end
		elseif self.moneyid == e_Type_vip_store_bangyuan then
			local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
			local havefree = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
			num = math.floor((have+havefree)/self.finalprice)
			if num <= 1 then
				num = 1
			end
		end
    end
	if num > g_edit_box_max then
		num = g_edit_box_max
	end
    SALE_COUNT_TEXT = num
    self.sale_count:setText(SALE_COUNT_TEXT)
    self.item_price:setText(SALE_COUNT_TEXT*self.finalprice)
end
function flash_sale_buy:showInfo(  )
	if self.moneyid == e_Type_vip_store_yuanbao then
		local have = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
		self._item_count = math.floor(have/self.finalprice)--拥有的元宝可购买的数量
		self._item_count_filter = self._item_count + 1
	elseif self.moneyid == e_Type_vip_store_bangyuan then
		local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
		local havefree = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
		self._item_count = math.floor((have+havefree)/self.finalprice)
		self._item_count_filter = math.floor(have/self.finalprice) + 1
	end
	if self.limitTimes and self.limitTimes < self._item_count then
		self._item_count = self.limitTimes
	end
	self.item_des:setText("你确定购买"..self.info.goodsname.."礼包？")
	if self.moneyid == e_Type_vip_store_yuanbao then
		self.item_price_icon:hide()
		self.item_currency_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon))  --元宝图标
	elseif self.moneyid == e_Type_vip_store_bangyuan then
		self.item_price_icon:show()
		self.item_currency_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon))
	end
	self.sale_count:setText(SALE_COUNT_TEXT)
	self.item_price:setText(SALE_COUNT_TEXT*self.finalprice);
end
function flash_sale_buy:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_Flash_Sale_Buy)
	end
end
function flash_sale_buy:jianButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if tonumber(SALE_COUNT_TEXT) > 1 then
			SALE_COUNT_TEXT = SALE_COUNT_TEXT - 1
			if SALE_COUNT_TEXT < 1 then
				SALE_COUNT_TEXT = 1
			end
			self.sale_count:setText(SALE_COUNT_TEXT);
			self.item_price:setText(SALE_COUNT_TEXT*self.finalprice);
		end
	end
end

function flash_sale_buy:jiaButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if (self.limitTimes and SALE_COUNT_TEXT < self.limitTimes) or not self.limitTimes then
			--i3k_log("--jiaButton = -------",self.limitTimes,SALE_COUNT_TEXT)----
			SALE_COUNT_TEXT = SALE_COUNT_TEXT + 1
			if SALE_COUNT_TEXT > g_edit_box_max then
				SALE_COUNT_TEXT = g_edit_box_max
			end
			self.sale_count:setText(SALE_COUNT_TEXT)
			self.item_price:setText(SALE_COUNT_TEXT*self.finalprice)

		--[[elseif not self.limitTimes then--]]

		--if self._item_count   then--and SALE_COUNT_TEXT < self._item_count
			--[[SALE_COUNT_TEXT = SALE_COUNT_TEXT + 1
			self.sale_count:setText(SALE_COUNT_TEXT);
			self.item_price:setText(SALE_COUNT_TEXT*self.finalprice);--]]
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(436))
		end
	end
end
function flash_sale_buy:jia10Button(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		--if self._item_count and self.current_num < self._item_count  then
		local count = 10
		if self._firstTimes then
			count = 9
			self._firstTimes = false
		end
		if self._item_count  then--and SALE_COUNT_TEXT < self._item_count
			--[[
			if SALE_COUNT_TEXT > self._item_count then
				SALE_COUNT_TEXT = self._item_count
			end]]
			if self.limitTimes and (SALE_COUNT_TEXT + count) > self.limitTimes then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(436))
			end
			SALE_COUNT_TEXT = SALE_COUNT_TEXT + count
			if SALE_COUNT_TEXT > g_edit_box_max then
				SALE_COUNT_TEXT = g_edit_box_max
			end
			self.sale_count:setText(SALE_COUNT_TEXT);--数量
			self.item_price:setText(SALE_COUNT_TEXT*self.finalprice);--总价

		end
	end
end

function flash_sale_buy:cancelButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_Flash_Sale_Buy)
	end
end

function flash_sale_buy:okButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if tonumber(SALE_COUNT_TEXT) > 0 then
			if self:canAfford(SALE_COUNT_TEXT *self.finalprice) then
				if self.limitTimes == 0 then --限购次数
					return g_i3k_ui_mgr:PopupTipMessage("您今日已经没有购买次数")
				end
				if g_i3k_game_context:GetLevel() < self.levelReq then --等级需求
					return g_i3k_ui_mgr:PopupTipMessage(string.format("您的等级不够，需要%d%s",self.levelReq,"级方可购买"))
				end
				if self:getSelfBuyTimes(self.info) == 0 then --贵族需求
					return g_i3k_ui_mgr:PopupTipMessage(string.format("您的贵族等级不够，需要贵族%d%s",self.info.v2t[1].vip,"方可购买"))
				end
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlashSale, "onBuy" , self.info, SALE_COUNT_TEXT)

			else--有数量不足支付
				if self.moneyid < 0 then
					local str = self.moneyid == -1 and "您的元宝不足"
					return g_i3k_ui_mgr:PopupTipMessage(str)
				else
					local str = self.moneyid == 1 and "您的绑定元宝不足"
					return g_i3k_ui_mgr:PopupTipMessage(str)
				end
			end
		end
	end
end
function flash_sale_buy:canAfford(price)
	if self.moneyid == e_Type_vip_store_yuanbao then
		local have = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
		if have >= price then
			return true
		end
	elseif self.sendcommond.free == e_Type_vip_store_bangyuan then
		local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
		local fhave = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
		if have+fhave >= price then
			return true
		end
	end
	return false;
end
local t = 
{
	[e_Type_vip_store_yuanbao] = -g_BASE_ITEM_DIAMOND,
	[e_Type_vip_store_bangyuan] = g_BASE_ITEM_DIAMOND,
}
function flash_sale_buy:toCurrencyType(free)
	return t[free] or g_BASE_ITEM_DIAMOND
end
function flash_sale_buy:getSelfBuyTimes(info)
	local curTimes = 0
	for i = #info.v2t, 1, -1 do
		if g_i3k_game_context:GetVipLevel() >= info.v2t[i].vip then
			vipEnough = true
			curTimes = info.v2t[i].times
			break
		end
	end
	return curTimes
end
function flash_sale_buy:onShow()

end


function wnd_create(layout, ...)
	local wnd = flash_sale_buy.new()
	wnd:create(layout, ...)
	return wnd
end

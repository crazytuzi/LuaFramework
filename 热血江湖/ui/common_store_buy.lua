-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------杂货店

commonstroe_buy = i3k_class("commonstroe_buy",ui.wnd_add_sub)
moneyiconlist = {32,30}
local SALE_COUNT_TEXT 		= 1
function commonstroe_buy:ctor()
	self.groupid=0
	self._item_count = 0
	self._firstTimes = true
end

function commonstroe_buy:refresh(item,gid)
	SALE_COUNT_TEXT = 1
	self.groupid=gid
	self.item = item		--物品信息
	self._pkpunish = g_i3k_game_context:GetPKPunish()--pk惩罚
	self:showInfo();
	self.current_add_num = self._item_count
	self:updateRefreshData()
	local cfg = g_i3k_db.i3k_db_get_base_item_cfg(self.item.buytype)
	local t = {}
	t[self.item.linkitemid] = (self.current_num + 1) * self.item.itemcount
	self.addCoinBtn:setVisible(math.abs(self.item.buytype) == g_BASE_ITEM_COIN)
	self._max_str = g_i3k_game_context:IsBagEnough(t) and i3k_get_string(self.item.buytype > 0 and 917 or 3013,cfg.name) or i3k_get_string(123)
end

function commonstroe_buy:configure(...)
	local screenSize = cc.Director:getInstance():getWinSize();
	local rootSize = self._layout.root:getContentSize();
	local widget = self._layout.vars
	self.item_bg = widget.item_bg
	self.item_icon = widget.item_icon
	self.item_name = widget.item_name
	self.item_type = widget.item_type
	self.item_des = widget.item_count
	self.sale_count = widget.sale_count
	self.sale_count:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.sale_count:addEventListener(function(eventType)
		if eventType == "ended" then
		    local str = tonumber(self.sale_count:getText()) or 1
		    self:judge(str)
	    end
	end)
	self.jian_bt = widget.jian
	self.jia_bt = widget.jia
	self.max_bt = widget.max
	self.cancel_bt = widget.cancel
	self.ok_bt = widget.ok
	self.item_price = widget.item_price
	self.item_price_icon = widget.item_price_icon
	self.item_price_lock_icon = widget.item_price_lock_icon
	if self.sale_count then self.sale_count:setText(SALE_COUNT_TEXT) end
	if self.cancel_bt then self.cancel_bt:onTouchEvent(self, self.cancelButton) end
	if self.ok_bt then self.ok_bt:onTouchEvent(self, self.okButton) end
	self.add_btn = widget.jia
	self.sub_btn = widget.jian
	self.max_btn = widget.max
	self._count_label = self.sale_count
	--self.current_add_num = 100 	--当前能够增加到的最大值
	self.addCoinBtn = widget.addCoinBtn
	self.addCoinBtn:onClick(self, self.onAddCoinBtn)
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.jia10Button)
end
function commonstroe_buy:setSaleMoneyCount(count)
	self.sale_count:setText(count)
end
function commonstroe_buy:judge(num)
	local have = 0;
	if math.abs(self.item.buytype) == g_BASE_ITEM_DIAMOND then
		have = g_i3k_game_context:GetDiamondCanUse(self.item.buytype < 0)
	elseif math.abs(self.item.buytype) == g_BASE_ITEM_COIN then
		have = g_i3k_game_context:GetMoneyCanUse(self.item.buytype < 0)
	end
	local limitbuy
	limitbuy = math.floor(have/self.item.itemprice)
	if num > limitbuy then
		num = limitbuy
	end
	if num > g_edit_box_max then
		num = g_edit_box_max
	end
	if num < 1 then
		num = 1
	end
	self.current_num = num
	self.sale_count:setText(self.current_num)
	self.item_price:setText(self.current_num*self.item.itemprice)
end
function commonstroe_buy:showInfo()
	self.item_price_lock_icon:hide()
	self.item_type:hide()
	self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self.item.linkitemid)))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.item.linkitemid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.item.linkitemid,i3k_game_context:IsFemaleRole()))
	if self.item.itemcount > 1 then
		self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(self.item.linkitemid).."*"..self.item.itemcount)
	else
		self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(self.item.linkitemid))
	end
	if self.item.buytype > 0 then
		self.item_price_lock_icon:show()
	end
	self.item_price_icon:setImage(g_i3k_db.i3k_db_get_icon_path(moneyiconlist[math.abs(self.item.buytype)]))
	self.item_price:setText(self.item.itemprice*SALE_COUNT_TEXT*(1+self._pkpunish))---
	self.item_des:setText(g_i3k_db.i3k_db_get_common_item_desc(self.item.linkitemid))
	self.sale_count:setText(SALE_COUNT_TEXT)
	local have = 0;
	if math.abs(self.item.buytype) == g_BASE_ITEM_DIAMOND then
		have = g_i3k_game_context:GetDiamondCanUse(self.item.buytype < 0)
	elseif math.abs(self.item.buytype) == g_BASE_ITEM_COIN then
		have = g_i3k_game_context:GetMoneyCanUse(self.item.buytype < 0)
	end
	local allCell = g_i3k_game_context:GetBagSize()
	local useCell = g_i3k_game_context:GetBagUseCell()
	local stack_max = g_i3k_db.i3k_db_get_bag_item_stack_max(self.item.linkitemid)
	local can_count
	if allCell == useCell then
		local count = g_i3k_game_context:GetBagItemCount(self.item.linkitemid)
		can_count = math.floor((stack_max - count % stack_max) / self.item.itemcount)
	else
		can_count = math.floor(stack_max*(allCell - useCell )/self.item.itemcount)
	end

	if can_count == 0 then
		can_count = 1
	end
	self._item_count = math.floor(have/(self.item.itemprice*(1+self._pkpunish)))---
	if self._item_count > can_count then
		self._item_count = can_count
	end
end

function commonstroe_buy:jia10Button(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local count = 10
		if self._firstTimes then
			count = 9
			self._firstTimes = false
		end
		local t =
		{
			[self.item.linkitemid] = (self.current_num + count) * self.item.itemcount
		}

		if not g_i3k_game_context:IsBagEnough(t) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
			return
		end
		if self._item_count >= self.current_num + count then
			self.current_num = self.current_num + count
			self.sale_count:setText(self.current_num)
			self.item_price:setText(self.current_num*self.item.itemprice*(1+self._pkpunish));
		else
			local cfg = g_i3k_db.i3k_db_get_base_item_cfg(self.item.buytype)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(self.item.buytype > 0 and 917 or 3013,cfg.name))
		end
	end
end

function commonstroe_buy:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_CommmonStoreBuy)
	end
end

function commonstroe_buy:updatePrice(current_num,price,punish)
	local cfg = g_i3k_db.i3k_db_get_base_item_cfg(self.item.buytype)
	self.item_price:setText(current_num*price*(1+punish))
	local t = {}
	t[self.item.linkitemid] = (self.current_num + 1) * self.item.itemcount
	self._max_str = g_i3k_game_context:IsBagEnough(t) and i3k_get_string(self.item.buytype > 0 and 917 or 3013,cfg.name) or i3k_get_string(123)
end

function commonstroe_buy:updateRefreshData()
	self._fun = function ()
		--self.item_price:setText(self.current_num*self.item.itemprice*(1+self._pkpunish))
		--i3k_log("-- fun-------",self.current_num*self.item.itemprice*(1+self._pkpunish))----
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CommmonStoreBuy,"updatePrice",self.current_num,self.item.itemprice,self._pkpunish)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CommmonStoreBuy,"setSaleMoneyCount",self.current_num)
	end
end

function commonstroe_buy:cancelButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if l_fCancelCallBack then
			l_fCancelCallBack()
		end
		g_i3k_ui_mgr:CloseUI(eUIID_CommmonStoreBuy)
	end
end

function commonstroe_buy:okButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if tonumber(self.current_num) > 0 then
			if self:canAfford(self.current_num *self.item.itemprice*(1+self._pkpunish)) then

						local test = {}
						test[self.item.linkitemid] = self.current_num*self.item.itemcount--
						if g_i3k_game_context:IsBagEnough(test) then
							i3k_sbean.store_buy(self.item.id,self.current_num,self.current_num*self.item.itemcount,self.groupid)---
						else
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(215))
						end
			else
				local cfg = g_i3k_db.i3k_db_get_base_item_cfg(self.item.buytype)
				local tips = i3k_get_string(self.item.buytype > 0 and 917 or 3013,cfg.name)
				g_i3k_ui_mgr:PopupTipMessage(tips)
			end
			g_i3k_ui_mgr:CloseUI(eUIID_CommmonStoreBuy)
		end
	end
end

function commonstroe_buy:canAfford(price)
	local have = 0;
	if math.abs(self.item.buytype) == g_BASE_ITEM_DIAMOND then
		have = g_i3k_game_context:GetDiamondCanUse(self.item.buytype < 0)
	elseif math.abs(self.item.buytype) == g_BASE_ITEM_COIN then
		have = g_i3k_game_context:GetMoneyCanUse(self.item.buytype < 0)
	end
	if have >= price then
		return true
	end
	return false;
end

function commonstroe_buy:onShow()

end

function commonstroe_buy:onAddCoinBtn(sender)
	self:onCloseUI()
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_create(layout, ...)
	local wnd = commonstroe_buy.new()
	wnd:create(layout, ...)
	return wnd
end

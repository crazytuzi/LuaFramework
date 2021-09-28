-------------------------------------------------------
module(..., package.seeall)

local require = require
local ui = require("ui/base")
-------------------------------------------------------

wnd_buyBaseItem = i3k_class("wnd_buyBaseItem",ui.wnd_base)

local SALE_COUNT_TEXT = 1
local imageTab = {[32] = 3260, [31] = 3261, [33] = 3262, [47] = 4539, [g_BASE_ITEM_BAGUA_ENERGY] = 5757, [g_BASE_ITEM_PET_EQUIP_SPIRIT] = 7661, [g_BASE_ITEM_STONE_ENERGY] = 9563}
function wnd_buyBaseItem:ctor()
	self.item_id = nil
	self._firstTimes = true
end

function wnd_buyBaseItem:configure()
	local widgets = self._layout.vars
	self.sale_count = widgets.sale_count
	self.sale_count:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.sale_count:addEventListener(
		function(eventType)
			if eventType == "ended" then
				local str = tonumber(self.sale_count:getText()) or 1
		    	self:judgecanbuy(str)
		    end
		end)
	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian
	self.max_btn = widgets.max
	self.add_btn:onTouchEvent(self, self.jiaButton)
	self.sub_btn:onTouchEvent(self,self.jianButton)
	self.max_btn:onTouchEvent(self,self.jia10Button)
	widgets.buyBtn:onClick(self, self.okButton)
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_buyBaseItem:refresh(id)
	SALE_COUNT_TEXT = 1
	self.item_id = id
	local cfg = g_i3k_db.i3k_db_get_base_item_cfg(id)
	self._layout.vars.get_desc:setText(cfg.get_way)
	self._layout.vars.icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.isCanbuy,i3k_game_context:IsFemaleRole()))
	self._layout.vars.icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.id,i3k_game_context:IsFemaleRole()))
	self._layout.vars.count1:setText(cfg.price)
	self._layout.vars.count2:setText(cfg.addCount)
	self._layout.vars.title_desc:setImage(g_i3k_db.i3k_db_get_icon_path(imageTab[cfg.id]))
	self._layout.vars.suo1:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(cfg.isCanbuy))
	self._layout.vars.suo2:setVisible(false)
	local count = g_i3k_game_context:GetBaseItemCanUseCount(cfg.isCanbuy)
	self._item_count = math.floor(count / cfg.price)
	self.sale_count:setText(SALE_COUNT_TEXT)
	local nCfg = g_i3k_db.i3k_db_get_base_item_cfg(cfg.isCanbuy)
end

function wnd_buyBaseItem:judgecanbuy(num)
	local cfg = g_i3k_db.i3k_db_get_base_item_cfg(self.item_id)
	local have = g_i3k_game_context:GetBaseItemCanUseCount(cfg.isCanbuy)
	if have < num*cfg.price then
		num = math.floor(have / cfg.price)
	end
	if num > g_edit_box_max then
		num = g_edit_box_max
	end
	if num < 1 then
		num = 1
	end
	SALE_COUNT_TEXT = num
	self.sale_count:setText(SALE_COUNT_TEXT);
	local cfg = g_i3k_db.i3k_db_get_base_item_cfg(self.item_id)
	self._layout.vars.count1:setText(SALE_COUNT_TEXT*cfg.price)
	self._layout.vars.count2:setText(SALE_COUNT_TEXT*cfg.addCount)
end
function wnd_buyBaseItem:jianButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if SALE_COUNT_TEXT > 1 then
			SALE_COUNT_TEXT = SALE_COUNT_TEXT - 1
			if SALE_COUNT_TEXT < 1 then
				SALE_COUNT_TEXT = 1
			end
			self.sale_count:setText(SALE_COUNT_TEXT);
			local cfg = g_i3k_db.i3k_db_get_base_item_cfg(self.item_id)
			self._layout.vars.count1:setText(SALE_COUNT_TEXT*cfg.price)
			self._layout.vars.count2:setText(SALE_COUNT_TEXT*cfg.addCount)
		end
	end
end

function wnd_buyBaseItem:jiaButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local cfg = g_i3k_db.i3k_db_get_base_item_cfg(self.item_id)
		if self._item_count >= SALE_COUNT_TEXT + 1 then
			SALE_COUNT_TEXT = SALE_COUNT_TEXT + 1
			if SALE_COUNT_TEXT > g_edit_box_max then
				SALE_COUNT_TEXT = g_edit_box_max
			end
			self.sale_count:setText(SALE_COUNT_TEXT);
			self._layout.vars.count1:setText(SALE_COUNT_TEXT*cfg.price)
			self._layout.vars.count2:setText(SALE_COUNT_TEXT*cfg.addCount)
		else
			local nCfg = g_i3k_db.i3k_db_get_base_item_cfg(cfg.isCanbuy)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(cfg.isCanbuy > 0 and 917 or 3013, nCfg.name))
		end
	end
end

function wnd_buyBaseItem:jia10Button(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local count = 10
		if self._firstTimes then
			count = 9
			self._firstTimes = false
		end
		local cfg = g_i3k_db.i3k_db_get_base_item_cfg(self.item_id)
		if self._item_count >= SALE_COUNT_TEXT + count then
			SALE_COUNT_TEXT = SALE_COUNT_TEXT + count
			if SALE_COUNT_TEXT > g_edit_box_max then
				SALE_COUNT_TEXT = g_edit_box_max
			end
			self.sale_count:setText(SALE_COUNT_TEXT);--数量
			self._layout.vars.count1:setText(SALE_COUNT_TEXT*cfg.price)
			self._layout.vars.count2:setText(SALE_COUNT_TEXT*cfg.addCount)
		else
			local nCfg = g_i3k_db.i3k_db_get_base_item_cfg(cfg.isCanbuy)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(cfg.isCanbuy > 0 and 917 or 3013, nCfg.name))
		end
	end
end

function wnd_buyBaseItem:okButton(sender)
	local cfg = g_i3k_db.i3k_db_get_base_item_cfg(self.item_id)
	if self._item_count <= 0 then
		local nCfg = g_i3k_db.i3k_db_get_base_item_cfg(cfg.isCanbuy)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(cfg.isCanbuy > 0 and 917 or 3013, nCfg.name))
		return
	end
	local callfunction = function(ok)
		if ok then
			i3k_sbean.base_dummygoods_quick_buy(self.item_id,SALE_COUNT_TEXT)
			g_i3k_ui_mgr:CloseUI(eUIID_BuyBaseItem)
		end
	end
	local have = g_i3k_game_context:GetBaseItemCount(cfg.isCanbuy)
	if have >= SALE_COUNT_TEXT * cfg.price or math.abs(cfg.isCanbuy) == g_BASE_ITEM_COIN then
		callfunction(true)
	else
		local msg = ""
		if have == 0 then
			msg = i3k_get_string(217,SALE_COUNT_TEXT * cfg.price)
		else
			msg = i3k_get_string(299,have,SALE_COUNT_TEXT * cfg.price-have)
		end
		g_i3k_ui_mgr:ShowCustomMessageBox2("购买", "取消", msg, callfunction)
	end

end

function wnd_create(layout)
	local wnd = wnd_buyBaseItem.new()
	wnd:create(layout)
	return wnd
end

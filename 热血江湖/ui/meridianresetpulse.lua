-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_meridianResetPulse = i3k_class("wnd_meridianResetPulse",ui.wnd_base)
local Item = "ui/widgets/mxczt"
function wnd_meridianResetPulse:ctor()
	self._id = 0;
	self._items = {}
	self._value = 0;
end

function wnd_meridianResetPulse:configure(...)
	local widgets	= self._layout.vars
	self.itemScroll = widgets.itemScroll;
	self.desc		= widgets.desc;
	widgets.ok:onClick(self, self.OnReset)	
	widgets.cancel:onClick(self, self.onCloseUI)	
end

function wnd_meridianResetPulse:refresh(id, value)
	self._id = id;
	self._value = value;
	self:updateItemScroll()
end

function wnd_meridianResetPulse:OnReset(sender)
	local item = i3k_db_meridians.common.resetItem;
	if self:isCanUse(item) and self._id > 0 then
		if self._value > 0 and self._value >= i3k_db_meridians.common.resetScroe then
			local tmp_str = i3k_get_string(16885)
			local fun = (function(ok)
				if ok then
					i3k_sbean.resetPulse(self._id, self._items)
				end
			end)
			g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1139), i3k_get_string(1140), tmp_str, fun)
		else
			i3k_sbean.resetPulse(self._id, self._items)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16889))
	end
end

function wnd_meridianResetPulse:isCanUse(item)
	local count = 0
	local items = {}
	if item then
		for _,e in ipairs(item) do
			local UseCount = g_i3k_game_context:GetCommonItemCanUseCount(e.id)
			if e.id > 0 then
				count = count + 1;
				if UseCount >= e.count then
					table.insert(items, e);
				end
			end
		end
		if count == #items then
			self._items = items;
			return true;
		end
	end
	return false;
end

function wnd_meridianResetPulse:updateItemScroll()
	local item = i3k_db_meridians.common.resetItem;
	self.desc:setText("重置会生成新的脉象，每天5点重置");
	self.itemScroll:removeAllChildren()
	for _, e in ipairs(item) do
		if e.id > 0 then
			local node = require(Item)()
			local widget = node.vars
			widget.lock:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.id))
			local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.id))
			widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.id,i3k_game_context:IsFemaleRole()))
			widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.id))
			if e.id == g_BASE_ITEM_DIAMOND or e.id == g_BASE_ITEM_COIN then
				widget.num:setText(e.count)
			else
				widget.num:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.id) .."/".. e.count)
			end
			widget.num:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.id) >= e.count))
			widget.btn:onClick(self, self.onItemTips, e.id);
			self.itemScroll:addItem(node)
		end
	end
end

function wnd_meridianResetPulse:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout)
	local wnd = wnd_meridianResetPulse.new()
	wnd:create(layout)
	return wnd
end

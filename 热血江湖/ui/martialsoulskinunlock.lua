-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_martialSoulSkinUnlock = i3k_class("wnd_martialSoulSkinUnlock", ui.wnd_base)

function wnd_martialSoulSkinUnlock:ctor()
	self._soul = nil;
end

function wnd_martialSoulSkinUnlock:configure()
	local widgets = self._layout.vars;
	widgets.cancelBtn:onClick(self, self.onCloseUI)
	self.okBtn = widgets.okBtn;
	self.desc = widgets.desc
	self.suo = widgets.suo_icon; 
	self.bt	= widgets.bt;
	self.item_icon	= widgets.item_icon;
	self.item_bg	= widgets.item_bg;
	self.item_name	= widgets.item_name;
	self.item_count = widgets.item_count;
end

function wnd_martialSoulSkinUnlock:refresh(soul)
	self._soul = soul;
	self:udptaeItem()
end

function wnd_martialSoulSkinUnlock:udptaeItem()
	if self._soul then
		local needItemId = self._soul.data.needItemID
		self.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(needItemId))
		self.desc:setText(i3k_get_string(1072, self._soul.data.name))
		local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needItemId))
		self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needItemId,i3k_game_context:IsFemaleRole()))
		self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needItemId))
		self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(needItemId))
		self.item_name:setTextColor(name_colour)
		if needItemId == g_BASE_ITEM_DIAMOND or needItemId == g_BASE_ITEM_COIN then
			self.item_count:setText(needItemCount)
		else
			self.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(needItemId) .."/".. self._soul.data.needItemCount)
		end
		self.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(needItemId) >= self._soul.data.needItemCount))
		self.okBtn:onClick(self, self.Confirm, self._soul)
		self.bt:onClick(self, self.onItemTips, needItemId);
	end
end

function wnd_martialSoulSkinUnlock:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_martialSoulSkinUnlock:Confirm(sender, soul)
	local UseCount = g_i3k_game_context:GetCommonItemCanUseCount(soul.data.needItemID)
	if  UseCount >= soul.data.needItemCount then
		i3k_sbean.weaponSoulUnlock(soul)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1070))
	end
end

function wnd_create(layout)
	local wnd = wnd_martialSoulSkinUnlock.new();
		wnd:create(layout);
	return wnd;
end
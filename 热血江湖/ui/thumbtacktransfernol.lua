module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_thumbtackTransferNol = i3k_class("wnd_thumbtackTransferNol", ui.wnd_base)

function wnd_thumbtackTransferNol:ctor()
	self._index = 0
	self._mapID = 0
end

function wnd_thumbtackTransferNol:configure()
	local widgets = self._layout.vars
	widgets.ok:onClick(self, self.onOKBt)
	widgets.quxiao:onClick(self, self.onCloseUI)
	widgets.tips_btn:onClick(self, self.onTipsBt)
	widgets.itemBt:onClick(self, self.onItemBt)
	self._tips_img = widgets.tips_img
end

function wnd_thumbtackTransferNol:onTipsBt()
	local visible = self._tips_img:isVisible()
	self._tips_img:setVisible(not visible)
	local value = g_i3k_game_context:getThumbtackNomalFlag()
	g_i3k_game_context:setThumbtackNomalFlag(not value)
end

function wnd_thumbtackTransferNol:refresh(index, mapID)
	self._index = index
	self._mapID = mapID
	local widgets = self._layout.vars
	local itemID = i3k_db_common.activity.transNeedItemId
	widgets.needImage:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
	widgets.needcount:setText(1)
	widgets.frame:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_cfg(itemID).rank))
	local mapName = i3k_db_dungeon_base[self._mapID].desc
	mapName = mapName .. index
	widgets.desc:setText(i3k_get_string(17290, mapName))
end

function wnd_thumbtackTransferNol:onOKBt()
	if not g_i3k_game_context:CheckCanTrans(i3k_db_common.activity.transNeedItemId, 1) then
		g_i3k_ui_mgr:PopupTipMessage("传送失败")
		self:onCloseUI()
		return
	end
			
	g_i3k_game_context:doThumbtackTransfer(self._index, self._mapID)
end

function wnd_thumbtackTransferNol:onItemBt()
	local itemID = i3k_db_common.activity.transNeedItemId
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout)
	local wnd = wnd_thumbtackTransferNol.new();
	wnd:create(layout);
	return wnd;
end

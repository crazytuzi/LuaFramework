module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_thumbtackTransferVip = i3k_class("wnd_thumbtackTransferVip", ui.wnd_base)

function wnd_thumbtackTransferVip:ctor()
	self._index = 0
	self._mapID = 0
end

function wnd_thumbtackTransferVip:configure()
	local widgets = self._layout.vars
	widgets.ok:onClick(self, self.onOKBt)
	widgets.quxiao:onClick(self, self.onCloseUI)
	widgets.tips_btn:onClick(self, self.onTipsBt)
	self._tips_img = widgets.tips_img
end

function wnd_thumbtackTransferVip:refresh(index, mapID)
	self._index = index
	self._mapID = mapID
	local mapName = i3k_db_dungeon_base[mapID].desc
	mapName = mapName .. index
	self._layout.vars.desc:setText(i3k_get_string(17290, mapName))
end

function wnd_thumbtackTransferVip:onTipsBt()
	local visible = self._tips_img:isVisible()
	self._tips_img:setVisible(not visible)
	local value = g_i3k_game_context:getThumbtackVipFlag()
	g_i3k_game_context:setThumbtackVipFlag(not value)
end

function wnd_thumbtackTransferVip:onOKBt()
	g_i3k_game_context:doThumbtackTransfer(self._index, self._mapID)
	self:onCloseUI()
	g_i3k_ui_mgr:CloseUI(eUIID_ThumbtackScollUI)
	g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
end

function wnd_create(layout)
	local wnd = wnd_thumbtackTransferVip.new();
	wnd:create(layout);
	return wnd;
end

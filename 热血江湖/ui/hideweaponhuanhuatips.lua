
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_hideWeaponHuanhuaTips = i3k_class("wnd_hideWeaponHuanhuaTips",ui.wnd_base)

function wnd_hideWeaponHuanhuaTips:ctor()

end

function wnd_hideWeaponHuanhuaTips:configure()
	
end

function wnd_hideWeaponHuanhuaTips:refresh(imgID, desc, tipsPos)
	local widgets = self._layout.vars
	self:updateText(imgID, desc)
	local pos = tipsPos.pos
	widgets.tips_root:setPosition(pos.x - tipsPos.width / 2, pos.y - tipsPos.height / 2)
end

function wnd_hideWeaponHuanhuaTips:updateText(imgID, desc)
	local widgets = self._layout.vars
	widgets.title:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
	widgets.desc:setText(desc)
end 

function wnd_create(layout, ...)
	local wnd = wnd_hideWeaponHuanhuaTips.new()
	wnd:create(layout, ...)
	return wnd;
end


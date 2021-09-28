-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_catch_spirit_guide = i3k_class("wnd_catch_spirit_guide", ui.wnd_base)

function wnd_catch_spirit_guide:ctor()
	self._curPage = 1
end

function wnd_catch_spirit_guide:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.leftBtn:onClick(self, self.onLeftBtn)
	self._layout.vars.rightBtn:onClick(self, self.onRightBtn)
end

function wnd_catch_spirit_guide:refresh()
	self:updateGuideIcon()
end

function wnd_catch_spirit_guide:updateGuideIcon()
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_catch_spirit_base.dungeon.guideIcons[self._curPage]))
	self._layout.vars.desc:setText(i3k_get_string(i3k_db_catch_spirit_base.dungeon.guideText[self._curPage]))
	self._layout.vars.leftBtn:setVisible(self._curPage > 1)
	self._layout.vars.rightBtn:setVisible(self._curPage < #i3k_db_catch_spirit_base.dungeon.guideIcons)
end

function wnd_catch_spirit_guide:onLeftBtn(sender)
	if self._curPage > 1 then
		self._curPage = self._curPage - 1
		self:updateGuideIcon()
	end
end

function wnd_catch_spirit_guide:onRightBtn(sender)
	if self._curPage < #i3k_db_catch_spirit_base.dungeon.guideIcons then
		self._curPage = self._curPage + 1
		self:updateGuideIcon()
	end
end

function wnd_create(layout)
	local wnd = wnd_catch_spirit_guide.new()
	wnd:create(layout)
	return wnd
end
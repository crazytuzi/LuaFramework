-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_show_roleTitles_tips = i3k_class("wnd_show_roleTitles_tips",ui.wnd_base)


local SYDJJL_WIDGET = "ui/widgets/sydjjlt"
local RowitemCount = 3

function wnd_show_roleTitles_tips:ctor()
	
end

function wnd_show_roleTitles_tips:configure()
	local widgets = self._layout.vars

	widgets.ok:onClick(self, self.onCloseUI)
end

function wnd_show_roleTitles_tips:refresh(id, callback)
	self._callback = callback
	local delay = cc.DelayTime:create(0.15)--序列动作 动画播了0.15秒后显示奖励
	local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
		self._layout.anis.c_dakai.play()
	end), delay, cc.CallFunc:create(function ()
		self:updateScroll(id)
	end))
	self:runAction(seq)
end

function wnd_show_roleTitles_tips:updateScroll(id)
	local info = i3k_db_title_base[id]
	self._layout.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(info.iconbackground))
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(info.name))
	self._layout.vars.jumpBtn:onClick(self, self.jumpBtn)
end

function wnd_show_roleTitles_tips:jumpBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ShowRoleTitleTips)
	if i3k_game_get_map_type() == g_FIELD or i3k_game_get_map_type() == g_FACTION_GARRISON then
		g_i3k_logic:OpenRoleTitleUI()
	else
		g_i3k_ui_mgr:PopupTipMessage("当前未处于大地图，查看失败")
	end
end

function wnd_create(layout)
	local wnd = wnd_show_roleTitles_tips.new()
	wnd:create(layout)
	return wnd
end

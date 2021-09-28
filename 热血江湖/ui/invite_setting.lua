-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_invite_setting = i3k_class("wnd_invite_setting", ui.wnd_base)

local ITEM = "ui/widgets/yaoqingszt"
local SETTINGS = {
	[g_INVITE_SET_FRIEND] = {txt = "本次登录期间忽略好友邀请", during = math.huge},
	[g_INVITE_SET_TEAM] = {txt = string.format("%d分钟内不再接受组队邀请",i3k_db_common.RefuseTeamInvitationTime/60), during = i3k_db_common.RefuseTeamInvitationTime},
	[g_INVITE_SET_SOLO] = {txt = i3k_get_string(15554,math.floor(i3k_db_common.qiecuo.refuseTime/60)), during = i3k_db_common.qiecuo.refuseTime},
}
local TIME_SPAN = 1 --1s判断一次是否到时间自动取消设置
function wnd_invite_setting:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._timer = 0
end

function wnd_invite_setting:refresh()
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	self.settings = {}
	for i,v in ipairs(SETTINGS) do
		local ui = require(ITEM)()
		ui.vars.txt:setText(v.txt)
		ui.vars.btn:onClick(self, self.onClickBtnClick, i)
		self.settings[i] = ui.vars.flag
		scroll:addItem(ui)
	end
	self:judgeAutoCancelSelect()
	self:updateState()
end

function wnd_invite_setting:updateState()
	for i,v in ipairs(self.settings) do
		v:setVisible(g_i3k_game_context:getInviteListSettting(i))
	end
end

function wnd_invite_setting:onClickBtnClick(sender, type)
	local show = g_i3k_game_context:getInviteListSettting(type)
	i3k_sbean.set_invite_list_setting(type, not show)
end

function wnd_invite_setting:onUpdate(dTime)
	self._timer = self._timer + dTime
	if self._timer > TIME_SPAN then
		self:judgeAutoCancelSelect()
		self._timer = 0
	end
end

function wnd_invite_setting:judgeAutoCancelSelect()
	local isChanged = false
	for i,v in ipairs(self.settings) do
		local sel, time = g_i3k_game_context:getInviteListSettting(i)
		if sel and i3k_game_get_time() - time > SETTINGS[i].during then
			g_i3k_game_context:updateInviteListSetting(i)
			isChanged = true
		end
	end
	if isChanged then
		self:updateState()
	end
end

function wnd_create(layout)
	local wnd = wnd_invite_setting.new()
	wnd:create(layout)
	return wnd
end

-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_friendsInviteAnswer = i3k_class("wnd_friendsInviteAnswer", ui.wnd_base)

function wnd_friendsInviteAnswer:ctor()
	self._friendId = 0
	self._select = g_i3k_game_context:getInviteListSettting(g_INVITE_SET_FRIEND) and 1 or 0
end

function wnd_friendsInviteAnswer:configure()
	local widget = self._layout.vars
	widget.ok:onClick(self, self.onOKBt)
	widget.cancel:onClick(self, self.onCancelBt)
	widget.select:onClick(self, self.onSlectBt)
end

function wnd_friendsInviteAnswer:onOKBt(sender)
	i3k_sbean.agreeaddFriend(self._friendId, self._select)
	self:onCloseUI()
end

function wnd_friendsInviteAnswer:onSlectBt(sender)
	self._select = self._select == 0 and 1 or 0
	self._layout.vars.selectImg:setVisible(self._select == 1)
end

function wnd_friendsInviteAnswer:onCancelBt(sender)
	if self._select ~= 0 then
		i3k_sbean.agreeaddFriend(0, self._select)
	end
	
	--g_i3k_ui_mgr:PopupTipMessage("拒绝成功")
	self:onCloseUI()
end

function wnd_friendsInviteAnswer:refresh(friendId, playerName)
	self._friendId = friendId
	local widget = self._layout.vars
	widget.desc:setText(i3k_get_string(1814, playerName))
	widget.yes_name:setText(i3k_get_string(1815))
	widget.no_name:setText(i3k_get_string(1816))
	widget.selectImg:setVisible(self._select == 1)
end

function wnd_create(layout)
	local wnd = wnd_friendsInviteAnswer.new()
	wnd:create(layout)
	return wnd
end


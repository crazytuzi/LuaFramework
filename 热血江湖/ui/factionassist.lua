
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_factionAssist = i3k_class("wnd_factionAssist",ui.wnd_base)

function wnd_factionAssist:ctor()
	self._isJoin = false
end

function wnd_factionAssist:configure()
	self.ui = self._layout.vars
	self.ui.close_btn:onClick(self, self.onCloseUI)
	self.ui.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(1394))
	end)

	self.ui.joinBtn:onClick(self, self.onJoinBtn) --登记/解除登记 btn
end

function wnd_factionAssist:refresh(members)
	self:loadAssistMemberInfo(members)
end

function wnd_factionAssist:loadAssistMemberInfo(members)
	self.ui.scroll:removeAllChildren()

	self._isJoin = false
	local myRoleId = g_i3k_game_context:GetRoleId()

	for _, e in ipairs(self:sortMembersInfo(members)) do
		local node = require("ui/widgets/lixianzhuzhant")()
		local roleInfo = e.info.role
		node.vars.name:setText(roleInfo.name)
		node.vars.lvlLabel:setText(roleInfo.level)
		node.vars.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(roleInfo.headIcon, false))
		node.vars.headBorder:setImage(g_i3k_get_head_bg_path(roleInfo.bwType, roleInfo.headBorder))
		node.vars.occupation:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[roleInfo.type].classImg))
		node.vars.fightPower:setText(roleInfo.fightPower)
		node.vars.assistTimes:setText(e.info.assistTimes .. "次")
		if roleInfo.id == myRoleId then
			self._isJoin = true
		end
		self.ui.scroll:addItem(node)
	end

	self.ui.tips:setText(self._isJoin and i3k_get_string(1388, i3k_db_faction_assist.daySectMoney) or i3k_get_string(1387))
	self.ui.btnLabel:setText(self._isJoin and "解除登记" or "我要登记")
end

function wnd_factionAssist:sortMembersInfo(members)
	local tmp = {}
	for _, v in ipairs(members) do
		local order = v.assistTimes * 10^9 + v.role.fightPower
		table.insert(tmp, {order = order, info = v})
	end
	table.sort(tmp, function (a,b)
		return a.order > b.order
	end)
	return tmp
end

--登记/解除登记
function wnd_factionAssist:onJoinBtn(sender)
	local desc = self._isJoin and i3k_get_string(1390) or i3k_get_string(1389, i3k_db_faction_assist.daySectMoney)
	local func = function(ok)
		if ok then
			if self._isJoin then
				i3k_sbean.sect_assist_quit()
			else
				i3k_sbean.sect_assist_join()
			end
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(desc, func)
end

function wnd_create(layout, ...)
	local wnd = wnd_factionAssist.new()
	wnd:create(layout, ...)
	return wnd;
end


module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_sworn_call_friends = i3k_class("wnd_sworn_call_friends", ui.wnd_base)

function wnd_sworn_call_friends:ctor()
	self._data = {}
	self._roleData = {}
end

function wnd_sworn_call_friends:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.reward_btn:onClick(self, self.onRewardBtn)
	self._layout.vars.sworn_team_btn:onClick(self, self.onSwornTeamBtn)
end

function wnd_sworn_call_friends:refresh(data, roleData)
	self._data = data
	self._roleData = roleData
	self:setDescriptrion()
	self:setHelpFightData()
end

function wnd_sworn_call_friends:setDescriptrion()
	local textNode = require("ui/widgets/jiebaijst1")()
	textNode.vars.content:setText(i3k_get_string(5436))
	self._layout.vars.scroll1:addItem(textNode)
	g_i3k_ui_mgr:AddTask(self, {textNode}, function(ui)
		local textUI = textNode.vars.content
		local size = textNode.rootVar:getContentSize()
		local height = textUI:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		textNode.rootVar:changeSizeInScroll(ui._layout.vars.scroll1, width, height, true)
	end, 1)
	local descNode = require("ui/widgets/jiebaijst1")()
	descNode.vars.content:setText(i3k_get_string(5437))
	self._layout.vars.scroll2:addItem(descNode)
	g_i3k_ui_mgr:AddTask(self, {descNode}, function(ui)
		local textUI = descNode.vars.content
		local size = descNode.rootVar:getContentSize()
		local height = textUI:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		descNode.rootVar:changeSizeInScroll(ui._layout.vars.scroll2, width, height, true)
	end, 1)
	self._layout.vars.bonus_text:setText(i3k_get_string(5438))
end

function wnd_sworn_call_friends:setHelpFightData()
	local roleId = g_i3k_game_context:GetRoleId()
	self._layout.vars.need_fight_count:setText(i3k_get_string(5417)..math.max(i3k_db_sworn_system.helpFightRewardTimes - self._roleData.dayUseMapRewardTimes, 0))
	self._layout.vars.have_fight_count:setText(i3k_get_string(5418)..self._data.roles[roleId].dayMapHelpTimes)
	if self._roleData.dayUseMapRewardTimes >= i3k_db_sworn_system.helpFightRewardTimes then
		self._layout.vars.reward_icon:hide()
		self._layout.vars.reward_get_icon:show()
		self._layout.anis.c_bx5.stop()
	elseif self._data.roles[roleId].dayMapRewardTimes > 0 then
		self._layout.anis.c_bx5.play()
		self._layout.vars.reward_icon:show()
		self._layout.vars.reward_get_icon:hide()
	else
		self._layout.anis.c_bx5.stop()
		self._layout.vars.reward_icon:show()
		self._layout.vars.reward_get_icon:hide()
	end
end

function wnd_sworn_call_friends:onRewardBtn(sender)
	local roleId = g_i3k_game_context:GetRoleId()
	local canGetTimes = math.min(i3k_db_sworn_system.helpFightRewardTimes - self._roleData.dayUseMapRewardTimes, self._data.roles[roleId].dayMapRewardTimes)
	if canGetTimes > 0 then
		i3k_sbean.sworn_help_map_reward_take(canGetTimes)
	else
		g_i3k_ui_mgr:ShowCommonItemInfo(i3k_db_sworn_system.helpFightRewardId)
	end
end

function wnd_sworn_call_friends:onSwornTeamBtn(sender)
	g_i3k_logic:OpenDungeonUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "onZuduiBtnClick")
	g_i3k_ui_mgr:CloseUI(eUIID_SwornModify)
	g_i3k_ui_mgr:CloseUI(eUIID_SwornCallFriends)
end

function wnd_create(layout)
	local wnd = wnd_sworn_call_friends.new()
	wnd:create(layout)
	return wnd
end
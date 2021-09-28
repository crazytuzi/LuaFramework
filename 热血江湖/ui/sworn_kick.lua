module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_sworn_kick = i3k_class("wnd_sworn_kick", ui.wnd_base)

local HD_WIDGETS = "ui/widgets/jiebaiqljrt"

local REASONS = {5420, 5421, 5422, 5423}

function wnd_sworn_kick:ctor()
	self._kickId = nil
	self._kickName = nil
	self._kickReason = nil
end

function wnd_sworn_kick:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.kick_btn:onClick(self, self.onKickBtn)
	for i = 1, 4 do
		self._layout.vars["choose_btn"..i]:onClick(self, self.onChooseReasonBtn, i)
	end
end

function wnd_sworn_kick:refresh(data)
	self:setKickFriends(data)
	self:setKickReasons()
end

function wnd_sworn_kick:setKickFriends(data)
	self._layout.vars.scroll:removeAllChildren()
	local teamMember = g_i3k_game_context:GetAllTeamMembers()
	local swornFriends = self:sortSwornFriends(data.roles)
	local isBigger = 1
	for k, v in ipairs(swornFriends) do
		if v.role.id == g_i3k_game_context:GetRoleId() then
			isBigger = 0
		end
		if not teamMember[v.role.id] then
			local node = require(HD_WIDGETS)()
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(v.role.headIcon,g_i3k_db.eHeadShapeCircie)
			local orderInfo = g_i3k_db.i3k_db_get_title_orderSeatId_bySelfIndex(k, v.role.gender, isBigger)
			node.vars.role_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
			node.vars.name2:setVisible(true)
			node.vars.name2:setText(v.role.name)
			node.vars.role_btn:onClick(self, self.changeKickId, {node = node, id = v.role.id, name = v.role.name})
			node.vars.title_txt:show()
			node.vars.title_txt:setText(orderInfo.notes)
			node.vars.leader_mark2:hide()
			node.vars.choose_icon:hide()
			self._layout.vars.scroll:addItem(node)
		end
	end
end

function wnd_sworn_kick:sortSwornFriends(players)
	local members = {}
	for k, v in pairs(players) do
		table.insert(members, v)
	end
	table.sort(members, function(a, b)
		if a.birthday ~= b.birthday then
			return a.birthday < b.birthday
		else
			return a.role.id < b.role.id
		end
	end)
	return members
end

function wnd_sworn_kick:changeKickId(sender, info)
	if self._kickId then
		if self._kickId ~= info.id then
			local children = self._layout.vars.scroll:getAllChildren()
			for k, v in ipairs(children) do
				v.vars.choose_icon:hide()
			end
			info.node.vars.choose_icon:show()
			self._kickId = info.id
			self._kickName = info.name
		end
	else
		info.node.vars.choose_icon:show()
		self._kickId = info.id
		self._kickName = info.name
	end
end

function wnd_sworn_kick:setKickReasons()
	for i = 1, 4 do
		self._layout.vars["choose_icon"..i]:hide()
		self._layout.vars["reason"..i]:setText(i3k_get_string(REASONS[i]))
	end
end

function wnd_sworn_kick:onChooseReasonBtn(sender, index)
	if self._kickReason then
		if self._kickReason ~= index then
			for i = 1, 4 do
				self._layout.vars["choose_icon"..i]:hide()
			end
			self._layout.vars["choose_icon"..index]:show()
			self._kickReason = index
		end
	else
		self._layout.vars["choose_icon"..index]:show()
		self._kickReason = index
	end
end

function wnd_sworn_kick:onKickBtn(sender)
	if not self._kickId then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5453))
		return
	end
	if not self._kickReason then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5454))
		return
	end
	local callback = function(isOk)
		if isOk then
			i3k_sbean.sworn_kick_role(self._kickId, REASONS[self._kickReason])
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5429, self._kickName), callback)
end

function wnd_create(layout)
	local wnd = wnd_sworn_kick.new()
	wnd:create(layout)
	return wnd
end

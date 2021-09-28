module(..., package.seeall)

local require = require;

local ui = require("ui/chatBase");

-------------------------------------------------------
wnd_swornDate = i3k_class("wnd_swornDate", ui.wnd_chatBase)--wnd_chatBase

local HD_WIDGETS = "ui/widgets/jiebailc1t"
local InputMaxNum = 8
function wnd_swornDate:ctor()
	self._chatState = global_team
	self.isJoin = 0
	self._swornData = nil
	self._isCanCollect = true
end

function wnd_swornDate:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self.input = widgets.input_label
	self.input:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.input:setMaxLength(InputMaxNum)
	widgets.ok_btn:onClick(self, self.inputFinished)
	widgets.editBox:setMaxLength(i3k_db_common.inputlen.chatlen)
	widgets.sendBtn:onClick(self, self.sendMessage)
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_swornDate:refresh(isJoin, data, oldMember)
	self.isJoin = isJoin
	self._swornData = data
	self._layout.vars.closeBtn:show()
	self:onUpdateScroll(oldMember)
	self:onRefreshChatLog()
end

function wnd_swornDate:onUpdateScroll(oldMember)--小队的成员
	self.scroll:removeAllChildren()
	local players = {}
	if self._swornData then
		for k, v in pairs(self._swornData.roles) do
			table.insert(players, {id = v.role.id, headIcon = v.role.headIcon, name = v.role.name, gender = v.role.gender, birthday = v.birthday})
		end
		players = self:sortPlayers(players)
	elseif self.isJoin ~= 0 then
		for k, v in pairs(g_i3k_game_context:GetAllTeamMembers()) do
			if oldMember and oldMember[v.overview.id] then
				table.insert(players, {id = v.overview.id, headIcon = v.overview.headIcon, name = v.overview.name, gender = v.overview.gender, birthday = oldMember[v.overview.id]})
			end
		end
		if next(players) then
			players = self:sortPlayers(players)
		end
	else
		for k, v in pairs(g_i3k_game_context:GetAllTeamMembers()) do
			table.insert(players, {id = v.overview.id, headIcon = v.overview.headIcon, name = v.overview.name, gender = v.overview.gender})
		end
	end
	local isBigger = 1
	for k, v in ipairs(players) do
		local isSelf = false
		local node = require(HD_WIDGETS)()
		if v.id == g_i3k_game_context:GetRoleId() then
			isBigger = 0
			isSelf = true
		end
		self:updateCell(node, v, k, isSelf, isBigger)
		self.scroll:addItem(node)
	end
end

function wnd_swornDate:sortPlayers(players)
	table.sort(players, function(a, b)
		if a.birthday ~= b.birthday then
			return a.birthday < b.birthday
		else
			return a.id < b.id
		end
	end)
	return players
end

function wnd_swornDate:updateCell(node, player, cell_index, isSelf, isBigger)
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(player.headIcon,g_i3k_db.eHeadShapeCircie)
	node.vars.role_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
	node.vars.name2:show()
	node.vars.name2:setText(player.name)
	if self._swornData or self.isJoin ~= 0 then
		node.vars.leader_mark2:hide()
		local orderInfo = g_i3k_db.i3k_db_get_title_orderSeatId_bySelfIndex(cell_index, player.gender, (isSelf and cell_index == 1) and 1 or isBigger)
		node.vars.title_txt:setText(orderInfo.notes)
		node.vars.title_txt:show()
	else
		node.vars.title_txt:hide()
		node.vars.leader_mark2:show()
		node.vars.leader_mark2:setVisible(g_i3k_game_context:GetTeamLeader() == player.id)
	end
end

function wnd_swornDate:sendMessage(sender)
	local teamMember = g_i3k_game_context:GetAllTeamMembers()
	if not next(teamMember) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5455))
		return
	end
	local message = self._layout.vars.editBox:getText()
	local textcount = i3k_get_utf8_len(message)
	if textcount > i3k_db_common.inputlen.chatlen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(747))
	elseif self:canSendMessage() then
		self._layout.vars.editBox:setText("")
		self:checkInput(false, global_team, message, g_i3k_game_context:GetRoleId())
	end
end

function wnd_swornDate:onRefreshChatLog()
	local chatScroll = self._layout.vars.msgScroll
	chatScroll:removeAllChildren()
	local contentSize = chatScroll:getContentSize()
	chatScroll:setContainerSize(contentSize.width, contentSize.height)
	local chatData = g_i3k_game_context:GetChatData()--获取数据
	for i,v in chatData[global_team + 1]:ipairs() do
		self:createSowrnChatItem(v)
	end
end

function wnd_swornDate:receiveNewMsg(message)
	if message.type == global_team then
		self:createSowrnChatItem(message)
	end
end

function wnd_swornDate:createSowrnChatItem(message)
	self:createChatItem(message, self._layout.vars.msgScroll)
end

function wnd_swornDate:inputFinished()
	if self._isCanCollect then
		local inputText = self.input:getText()
		local timeStamp = g_i3k_checkIsValidBirthday(inputText)
		if timeStamp then
			--下一个流程
			if self._swornData then
				i3k_sbean.sworn_change_birthday(timeStamp)
			else
				i3k_sbean.sworn_sign_birthday(self.isJoin, timeStamp)
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5416))
	end
end

function wnd_swornDate:setCollectBtnState(state)
	self._isCanCollect = false
end

function wnd_create(layout)
	local wnd = wnd_swornDate.new()
	wnd:create(layout)
	return wnd
end

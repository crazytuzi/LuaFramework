module(..., package.seeall)

local require = require;

local ui = require("ui/chatBase");

-------------------------------------------------------
wnd_setSwornPrefix = i3k_class("wnd_setSwornPrefix", ui.wnd_chatBase)--wnd_chatBase

local HD_WIDGETS = "ui/widgets/jiebailc1t"
function wnd_setSwornPrefix:ctor()
	self._chatState = global_team
end

function wnd_setSwornPrefix:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self.input = widgets.input_label
	self.input:setInputMode(EDITBOX_INPUT_MODE_SINGLELINE)
	--self.input:setMaxLength(i3k_db_sworn_system.numLimitPrefix)
	self.wait_desc = widgets.wait_desc
	self.ok_btn = widgets.ok_btn
	widgets.ok_btn:onClick(self, self.inputFinished)
	widgets.editBox:setMaxLength(i3k_db_common.inputlen.chatlen)
	widgets.sendBtn:onClick(self, self.sendMessage)
end

function wnd_setSwornPrefix:refresh(players)
	self._layout.vars.sworn_desc:setText(i3k_get_string(5399, i3k_db_sworn_system.numLimitPrefix))
	local leaderId = g_i3k_game_context:GetTeamLeader()
	if leaderId == g_i3k_game_context:GetRoleId() then
		self.wait_desc:setVisible(false)
	else
		self.wait_desc:show()
		self.wait_desc:setText(i3k_get_string(5400))
		self.ok_btn:setVisible(false)
	end
	local members = self:sortMembers(players)
	self:onUpdateScroll(members)
end

function wnd_setSwornPrefix:sortMembers(players)
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

function wnd_setSwornPrefix:onUpdateScroll(players)--结拜成员
	self.scroll:removeAllChildren()
	local isBigger = 1
	for k, v in ipairs(players) do
		local isSelf = false
		local node = require(HD_WIDGETS)()
		if v.role.id == g_i3k_game_context:GetRoleId() then
			isBigger = 0
			isSelf = true
		end
		self:updateCell(node, v, k, isBigger, isSelf)
		self.scroll:addItem(node)
	end
end

function wnd_setSwornPrefix:updateCell(node, player, cell_index, isBigger, isSelf)
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(player.role.headIcon,g_i3k_db.eHeadShapeCircie)
	node.vars.role_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
	node.vars.name2:setVisible(true)
	node.vars.name2:setText(player.role.name)
	node.vars.title_txt:setVisible(true)
	local orderInfo = g_i3k_db.i3k_db_get_title_orderSeatId_bySelfIndex(cell_index, player.role.gender, (isSelf and cell_index == 1) and 1 or isBigger)
	node.vars.title_txt:setText(orderInfo.notes)
end

function wnd_setSwornPrefix:sendMessage(sender)
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

function wnd_setSwornPrefix:onRefreshChatLog()
	local chatScroll = self._layout.vars.msgScroll
	chatScroll:removeAllChildren()
	local contentSize = chatScroll:getContentSize()
	chatScroll:setContainerSize(contentSize.width, contentSize.height)
	local chatData = g_i3k_game_context:GetChatData()--获取数据
	for i,v in chatData[global_team + 1]:ipairs() do
		self:createSowrnChatItem(v)
	end
end

function wnd_setSwornPrefix:receiveNewMsg(message)
	if message.type == global_team then
		self:createSowrnChatItem(message)
	end
end

function wnd_setSwornPrefix:createSowrnChatItem(message)
	self:createChatItem(message, self._layout.vars.msgScroll)
end

function wnd_create(layout)
	local wnd = wnd_setSwornPrefix.new()
	wnd:create(layout)
	return wnd
end

function wnd_setSwornPrefix:inputFinished()
	local inputPrefix = self:checkIsValidSwornPrefix()
	if inputPrefix then
		--结拜结束
		i3k_sbean.create_sworn_end(inputPrefix)
	end
end

--字符串先写死，等流程走完策划统一配
function wnd_setSwornPrefix:checkIsValidSwornPrefix()
	local inputText = self.input:getText()
	local lenInput = i3k_get_utf8_len(inputText)
	if lenInput > i3k_db_sworn_system.numLimitPrefix then
		local str = i3k_get_string(5393, i3k_db_sworn_system.numLimitPrefix)
		g_i3k_ui_mgr:PopupTipMessage(str)
		return false
	end

	if lenInput == 0 then
		local str = i3k_get_string(5394)
		g_i3k_ui_mgr:PopupTipMessage(str)
		return false
	end
	return inputText
end


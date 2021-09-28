-------------------------------------------------------
module(..., package.seeall)

local require = require;

--local ui = require("ui/base");
local ui = require("ui/chatBase")
-------------------------------------------------------
wnd_priviteChat = i3k_class("wnd_priviteChat", ui.wnd_chatBase)
textColor = {friendsColor = "FFF1E178" ,strangerColor = "FFFF330B"}
function wnd_priviteChat:ctor()
	self._chatState = 4
	self._exist = {}
	self._TargetId = 0
	self._msgType = 0
end

function wnd_priviteChat:configure()
	self._layout.vars.close:onClick(self, self.closeCB)
	--self._layout.vars.bqVoice:onClick(self, self.selectBq)
	--self._layout.vars.bqWord:onClick(self, self.selectBq)
	self._layout.vars.sendVoice:onTouchEvent(self,self.createVoiceUrl)
	local toWord = self._layout.vars.toWord
	local toVoice = self._layout.vars.toVoice
	local chatModeBtn = {toWord, toVoice}
	local bqBtn = {self._layout.vars.bqVoice, self._layout.vars.bqWord}
	for i = 1 , #chatModeBtn do
		bqBtn[i]:setTag(i)
		bqBtn[i]:onClick(self, self.selectBq)
		chatModeBtn[i]:setTag(i)
		chatModeBtn[i]:onClick(self, self.toWordsOrVoice)
	end
	self._layout.vars.sendWord:setTag(1+10000)
	self._layout.vars.sendWord:onClick(self, self.sendMessage)

	self._layout.vars.editBox:setMaxLength(i3k_db_common.inputlen.chatlen)
end

function wnd_priviteChat:onShow()
	if g_i3k_game_context:isEmpty() then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onHideChatRedPoint")
	end

	g_i3k_game_context:reduceMsg(global_recent)
	g_i3k_game_context:reduceMsg(global_cross)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onHideChatRedPoint")
	g_i3k_game_context:setPrivateChatUIOpenState(true)
end

function wnd_priviteChat:addtoRecentdata(player)
	local isHave = false
	local recentData = g_i3k_game_context:GetRecentChatData()
	for i,v in ipairs(recentData) do
		if v.id==player.id then
			isHave = true
			break;
		end
	end
	if not isHave then
		g_i3k_game_context:addRecentChatData(player)
	end
end

function wnd_priviteChat:addHeadItem(msgInfo, index, pid)
	local Id = math.abs(msgInfo.id)
	local slrt = require("ui/widgets/slrt")()
	slrt.vars.name:setText(msgInfo.name)
	if g_i3k_game_context:GetIsCrossFriend(math.abs(msgInfo.id)) then
		msgInfo.msgType = global_cross
		slrt.vars.elationship:setText("跨服好友")
		slrt.vars.elationship:setTextColor(g_i3k_get_orange_color())
	else
		msgInfo.msgType = global_recent
		local value = g_i3k_game_context:GetFriendsDataByID(Id)
		if value then
			slrt.vars.elationship:setText("好友")--设置好友类型,好友/陌生人
			slrt.vars.elationship:setTextColor(g_i3k_get_orange_color())
		end
	end
	slrt.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(msgInfo.iconId, true))
	slrt.vars.txb_img:setImage(g_i3k_get_head_bg_path(msgInfo.bwType, msgInfo.headBorder))
	slrt.vars.iconBtn:setTag(msgInfo.id)
	slrt.vars.iconBtn:onClick(self, self.choosePlayer, msgInfo)
	slrt.vars.jrBtn:onClick(self, self.toChatFC, msgInfo)
	if pid and Id == pid then
		slrt.vars.root:setImage(g_i3k_db.i3k_db_get_icon_path(706))
	end
	self._exist[Id] = true
	self._layout.vars.scroll:addItem(slrt)
end

function wnd_priviteChat:refreshListScroll(player)--刷新好友列表
	local recentData = g_i3k_game_context:GetRecentChatData()
	local listScroll = self._layout.vars.scroll
	listScroll:removeAllChildren()
	self._exist = { }
	if recentData and player and player.id then
		if g_i3k_game_context:GetIsCrossFriend(math.abs(player.id)) then
			self._msgType = global_cross
		else
			self._msgType = global_recent
		end
		local pid = math.abs(player.id)
		for i,v in ipairs(recentData) do
			local slrt = self:addHeadItem(v, i, pid)
		end
	end
end

function wnd_priviteChat:refreshContentList(player)--刷新内容
	local recentData = g_i3k_game_context:GetRecentChatData()
	local contentScroll = self._layout.vars.contentScroll
	self:stopFinishPlay()
	contentScroll:removeAllChildren()
	if recentData and player and player.id then
		local message
		for i,v in ipairs(recentData) do
			if math.abs(v.id)==math.abs(player.id) then
				message = v
				break;
			end
		end
		self._TargetId = math.abs(player.id)
		if message then
			for i,v in ipairs(message.msgContent) do
				self:createItem(message,v)
			end
		end
	end
end

function wnd_priviteChat:refresh(player)
	if player then
		local index = nil
		local recentData = g_i3k_game_context:GetRecentChatData()
		for i,v in ipairs(recentData) do
			if player.id == v.id then
				index = i
			end
		end
		if not index then
			player.msgContent = {}
			self:addtoRecentdata(player)
		else
			player = recentData[index]
		end
	else
		local recentData = g_i3k_game_context:GetRecentChatData()
		player = recentData[1]
	end
	self:refreshListScroll(player)
	self:refreshContentList(player)
end

function wnd_priviteChat:canSendMsg()
	--根据时间戳判断一下是否能发送
	local canSend = true
	local sendTime = g_i3k_game_context:GetPriviteSendTime()
	local now = i3k_game_get_time()
	if sendTime then
		if now-sendTime<i3k_db_common.chat.timePrivite then
			canSend = false
		end
	end
	return canSend
end

function wnd_priviteChat:sendMessage(sender)
	if self._TargetId == 0 then
		g_i3k_ui_mgr:PopupTipMessage("没有聊天对象")
		return
	end
	local tag = sender:getTag()-10000
	if tag==1 then
		local editBox = self._layout.vars.editBox
		local message = editBox:getText()
		local canSend = self:canSendMsg()

		local isCmdString = string.sub(message, 0, 2)
		local isCmd = false
		if isCmdString=="@#" then
			isCmd = true
			canSend = true
		end
		local textcount = i3k_get_utf8_len(message)
		if textcount > i3k_db_common.inputlen.chatlen then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(747))
		elseif canSend then
			editBox:setText("")
			self:checkInput(isCmd, self._msgType, message, self._TargetId)
		else
			g_i3k_ui_mgr:PopupTipMessage("发言冷却时间未到")
		end

	else
		--sendVoice
	end
end


function wnd_priviteChat:sendVoiceUrl(url, sec)
	if self:canSendMsg() then
		--local sec = math.ceil(ui.ChatBase_Record_Sec)
		url = "#V"..url.."#"..sec.."#"
		local roleId = self._TargetId
		self:checkInput(false,4,url,roleId)
	else
		g_i3k_ui_mgr:PopupTipMessage("发言冷却时间未到")
	end
end

function wnd_priviteChat:updateSelectItemBtn(index)
	local listScroll = self._layout.vars.scroll
	local childrens = listScroll:getAllChildren()
	for k,v in ipairs(childrens) do
		if v.vars.iconBtn:getTag() == index then
			v.vars.root:setImage(g_i3k_db.i3k_db_get_icon_path(706))
		else
			v.vars.root:setImage(g_i3k_db.i3k_db_get_icon_path(707))
		end
	end
end

function wnd_priviteChat:choosePlayer(sender, info)
	local id = sender:getTag()
	if self._TargetId == math.abs(id) then
		return;
	end
	self._msgType = info.msgType
	local player = {}
	player.id = id
	self:stopFinishPlay()
	self:updateSelectItemBtn(info.id)
	self:refreshContentList(player)
end

function wnd_priviteChat:toWordsOrVoice(sender)
	self:changeChatMode(sender:getTag())
end

function wnd_priviteChat:changeChatMode(flag)
	if flag == 1 then
		self._layout.vars.wordDeck:show()
		self._layout.vars.voiceDeck:hide()
		self:cancelRecord()
	else
		self._layout.vars.wordDeck:hide()
		self._layout.vars.voiceDeck:show()
	end
end

function wnd_priviteChat:selectBq(sender)
	local tag = sender:getTag()
	if tag == 1 then
		self:changeChatMode(tag)
	end
	g_i3k_ui_mgr:OpenUI(eUIID_SelectBq)
	g_i3k_ui_mgr:RefreshUI(eUIID_SelectBq,eUIID_PriviteChat)
end

--添加点击哪个头像就弹出右侧对应的对话列表
function wnd_priviteChat:toChatFC(sender, player)
	if player.msgType == global_cross then
		g_i3k_ui_mgr:OpenUI(eUIID_ChatFC)
		g_i3k_ui_mgr:RefreshUI(eUIID_ChatFC, player, true)
	else
		i3k_sbean.query_rolebrief(math.abs(player.id), {isPriviteChat = true, msgType = player.msgType})
	end
end

function wnd_priviteChat:closeCB(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_SelectBq)
	g_i3k_ui_mgr:CloseUI(eUIID_PriviteChat)
end

function wnd_priviteChat:receiveNewMsg(message, msgContent)
	if self._TargetId == math.abs(message.id) or message.id <0 then
		self:createItem(message, msgContent)
	end
	if self._TargetId == 0 then
		self._TargetId = math.abs(message.id)
	end
	if message.id > 0 then
		local index = g_i3k_game_context:GetRecentChatDataIndexWithMsg(message)
		if index then
			if not self._exist[message.id] then
				self:addHeadItem(message, index, self._TargetId)
			end
		end
	end
end

function wnd_priviteChat:createItem(message,content)
	local contentScroll = self._layout.vars.contentScroll
	local childrens = contentScroll:getAllChildren()
	if #childrens==0 then
		g_i3k_game_context:SetPriviteMsgTime(content.time)
		local timer = require("ui/widgets/slsjt")()
		timer.vars.timeText:setText(g_i3k_logic:GetTime(content.time))
		contentScroll:addItem(timer)
	else
		local msgTime = g_i3k_game_context:GetPriviteMsgTime()
		local timeValue = content.time - msgTime
		if timeValue > 100 then
			local timer = require("ui/widgets/slsjt")()
			timer.vars.timeText:setText(g_i3k_logic:GetTime(content.time))
			contentScroll:addItem(timer)
		end
	end

	if content.isVoice then
		self:sendVoice(contentScroll,message,content)
	else
		local ltxx
		local iconId = nil
		local bwType = 0
		local headBorder = 0
		if content.isFromSelf then
			ltxx = require("ui/widgets/slt3")()
			iconId = g_i3k_game_context:GetRoleHeadIconId()
			bwType = g_i3k_game_context:GetTransformBWtype()
			headBorder = g_i3k_game_context:GetRoleHeadFrameId()
		else
			ltxx = require("ui/widgets/slt1")()
			iconId = message.iconId
			bwType = message.bwType
			headBorder = message.headBorder
		end

		ltxx.vars.txb_img:setImage(g_i3k_get_head_bg_path(bwType, headBorder))
		local showText = self:onOthertype(contentScroll,content,ltxx,3,true)
		ltxx.vars.text:setText(showText)
		g_i3k_ui_mgr:AddTask(self, {ltxx}, function(ui)
			local nheight = ltxx.vars.text:getInnerSize().height
			local tSizeH = ltxx.vars.text:getSize().height
			if nheight > tSizeH then
				local imgSize = ltxx.vars.bg_img:getContentSize()
				local rSize = ltxx.rootVar:getContentSize()
		 		local delta = nheight - tSizeH
		 		if ltxx.vars.downImg then
		 			ltxx.vars.downImg:setPositionY(ltxx.vars.downImg:getPositionY()-delta)
		 		end
				ltxx.vars.bg_img:setContentSize(imgSize.width, imgSize.height + delta)
				ltxx.rootVar:changeSizeInScroll(contentScroll, rSize.width, rSize.height + delta, true)
		 	end
		 	contentScroll:jumpToListPercent(100)
		end,1)
		ltxx.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		contentScroll:addItem(ltxx)
		self:setBgImage(ltxx, content.fromId, message.vipLvl, message.chatBox)
	end
end

function wnd_priviteChat:specialOperate(callfunc, id)
	if id == self._TargetId then
		self._TargetId = 0
		self:refresh()
	else
		local player = {id = self._TargetId}
		self:refreshListScroll(player)
		self:refreshContentList(player)
	end
	if callfunc then
		callfunc()
	end
end

function wnd_priviteChat:onHide()
	self:stopFinishPlay()
	self:cancelRecord()
	g_i3k_game_context:setPrivateChatUIOpenState(false)
end

function wnd_create(layout, ...)
	local wnd = wnd_priviteChat.new();
	wnd:create(layout, ...);

	return wnd;
end

-------------------------------------------------------
module(..., package.seeall)

local require = require;

--local ui = require("ui/base");
local ui = require("ui/chatBase")
-------------------------------------------------------
wnd_chat = i3k_class("wnd_chat", ui.wnd_chatBase)
local tabtextColor = {normalColor = "FF9b7a53",strokeColor1 = "ff2b6a56",selectedColor = "FF326852", strokeColor2 = "FFD1CB6F"}
local spanScollMsgType = {[12] = true, [14] = true}

function wnd_chat:ctor()
	self._chatState = global_world
	self._isVoice = false
	self._newMsgCount = 0
	self._oldMsgCount = 0
	self.before_scroll = 0
	self.after_scroll = 0
	self.channel_name = ""
	self._isLockScreen = false
	self._currLockScroll = nil
end

function wnd_chat:configure()
	self._layout.vars.back:onClick(self, self.onBackClick)
	self._layout.vars.kk1:onClick(self, self.backGroundCB)
	self._layout.vars.action_btn:onClick(self, self.onActionBtn)
	self._layout.vars.snapShotBtn:onClick(self, self.onSnapShotBtn)
	self._layout.vars.pigeonPost:onClick(self, self.openPigeonPostSend)
	if i3k_game_get_os_type() == eOS_TYPE_OTHER then
		self._layout.vars.btnBroadcast:hide()
	else
		self._layout.vars.btnBroadcast:onClick(self, self.onBroadcast)
	end

	local system = self._layout.vars.system
	local world = self._layout.vars.world
	local sect = self._layout.vars.sect
	local team = self._layout.vars.team
	local recent = self._layout.vars.recent
	local span = self._layout.vars.span
	self._tabbar = {system, world, sect, team, recent,span}

	for i,v in ipairs(self._tabbar) do
		v:setTag(i)
		v:onClick(self, self.tabbarCB)
	end

	local systext = self._layout.vars.systext
	local worldtext = self._layout.vars.wordtext
	local secttext = self._layout.vars.secttext
	local teamtext = self._layout.vars.teamtext
	local recenttext = self._layout.vars.recenttext
	local spanText = self._layout.vars.spanText
	self._tabtext = {systext, worldtext, secttext, teamtext, recenttext, spanText}

	local systemLight = self._layout.vars.systemLight
	local worldLight = self._layout.vars.worldLight
	local sectLight = self._layout.vars.sectLight
	local teamLight = self._layout.vars.teamLight
	local recentLight = self._layout.vars.recentLight
	local spanLight =  self._layout.vars.recentLight
	self._tabLight = {systemLight, worldLight, sectLight, teamLight, recentLight, spanLight}

	self._layout.vars.word:show()
	self._layout.vars.voice:hide()
	self._layout.vars.cantTalk:hide()

	self._inputTypeUI = {self._layout.vars.word, self._layout.vars.voice, self._layout.vars.cantTalk}

	local send1 = self._layout.vars.sendWord
	local send2 = self._layout.vars.sendVoice

	send1:onClick(self, self.sendMessage)
	send2:onTouchEvent(self, self.createVoiceUrl)

	self._layout.vars.toVoicebtn:setTag(1)                         --语音
	self._layout.vars.toWords:setTag(2)
	self._layout.vars.toVoicebtn:onClick(self, self.toVoiceOrWord)
	self._layout.vars.toWords:onClick(self, self.toVoiceOrWord)

	self._layout.vars.bqVoice:onClick(self, self.selectBq)         --加号
	self._layout.vars.bqWord:onClick(self, self.selectBq)

	self._layout.vars.sectredPoint:hide()                          --红点
	self._layout.vars.teamredPoint:hide()
	self._layout.vars.spanRed:hide()
	self._layout.vars.recentRed:hide()

	if i3k_chat_state_BattleOrTeam() then --self:isBattle()
		if i3k_game_get_map_type() == g_PRINCESS_MARRY  then
			self._tabtext[4]:setText(i3k_get_string(18029))
		else
		self._tabtext[4]:setText("战场")
		end
	end

	local widgets = self._layout.vars
	self.widgets = widgets
	widgets.lock_screen_btn:onClick(self,self.lockScreen)

	self.new_msg_btn = widgets.new_msg_btn
	self.new_msg_btn:onClick(self,self.browseNewMsg)       --浏览
	self.new_msg_red_point = widgets.new_msg_red_point
	self.new_msg_text = widgets.new_msg_text
	self.lock_screen_image = widgets.lock_screen_image
	
	self._diffSeverImage = widgets.diffSeverImage
	self._diffSeverImageScoll = widgets.scroll3
	
	widgets.scroll:onScrollEvent(self,self.moveListener)
	widgets.scroll:onTouchEvent(self,self.scrollTouch)
	widgets.scroll2:onScrollEvent(self,self.moveListener)
	widgets.scroll2:onTouchEvent(self,self.scrollTouch)

	widgets.editBox:setMaxLength(i3k_db_common.inputlen.chatlen)
	widgets.chatBubble:onClick(self, self.openChatBubble)
	--快捷购买大喇叭
	widgets.buyHornBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowCommonItemInfo(i3k_db_common.chat.worldNeedId)
	end)
end

function wnd_chat:isNotLockScreen()
	self.lock_screen_image:setImage(g_i3k_db.i3k_db_get_icon_path(2673))
	self._isLockScreen = false
	self._oldMsgCount = self._newMsgCount + self._oldMsgCount
	self._newMsgCount = 0
end

function wnd_chat:isLockScreen()
	self.lock_screen_image:setImage(g_i3k_db.i3k_db_get_icon_path(2672))
	self._isLockScreen = true
end

function wnd_chat:lockScreen(sender)
	if self._isLockScreen then
		self:isNotLockScreen()
	else
		self:isLockScreen()
	end
end

function wnd_chat:browseNewMsg(sender)
	self.new_msg_btn:setVisible(false)
	self._currLockScroll:jumpToChildWithIndex(self._oldMsgCount + 2)
	self:isNotLockScreen()
end

function wnd_chat:setNewMsgCount()
	self._newMsgCount = self._newMsgCount + 1
end

function wnd_chat:setNewMsgText()
	if self.new_msg_btn:isVisible() then
		local context = self._newMsgCount.."条新消息"
		self.new_msg_text:setText(context)
	end
end

function wnd_chat:moveListener(sender,eventType)
	if eventType == ccui.ScrollviewEventType.bounceBottom then
		self.new_msg_btn:setVisible(false)
		self:isNotLockScreen()
	end
end

function wnd_chat:scrollTouch(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		self.before_scroll = self._currLockScroll:getListPercent()
	elseif eventType == ccui.TouchEventType.moved then
		self.after_scroll = sender:getListPercent()
		if self.before_scroll > self.after_scroll and not self._isLockScreen then
			self:isLockScreen()
		end
	end
end

function wnd_chat:setInputType(tag,...)
	local widgets = self._layout.vars
	for i,v in pairs(self._inputTypeUI) do
		v:hide()
	end
	if tag==1 then
		if self._isVoice then
			self._inputTypeUI[2]:show()
		else
			self._inputTypeUI[1]:show()
			widgets.laba:hide()  --喇叭
			widgets.buyHornBtn:hide()
			local posx = self._layout.vars.editBox:getPositionX()
			if self._chatState == global_world then
				widgets.laba:show()
				widgets.buyHornBtn:show()
				self:updatelb()
				if posx ~= 0 then
					self._layout.vars.editBox:setPositionX(155)
				end
			else
				if posx ~= 0  then
					self._layout.vars.editBox:setPositionX(105)
				end
			end
		end
	elseif tag==2 then
		self._inputTypeUI[3]:show()
		self._layout.vars.cantTalkLabel:setText(...)
	else
		self._inputTypeUI[3]:show()
	end
end

function wnd_chat:setTabLight()
	local state = self._chatState+1
	if self._chatState == global_battle and state == 6 then
		state = 4
	elseif state > 6 then
		state = state - 1
	end
	self.channel_name = string.ltrim(self._tabtext[state]:getText())
	for i,v in ipairs(self._tabbar) do

		-- if self._chatState == 6 then
		-- 	state = 6
		-- end
		if i== state then
			v:stateToPressed()
			self._tabLight[i]:show()
			self._tabtext[i]:setTextColor(tabtextColor.selectedColor)
--			self._tabtext[i]:enableOutline(tabtextColor.strokeColor2)
		else
			v:stateToNormal()
			self._tabtext[i]:setTextColor(tabtextColor.normalColor)
--			self._tabtext[i]:enableOutline(tabtextColor.strokeColor1)
			self._tabLight[i]:hide()
		end
	end
end

function wnd_chat:onShow()
	g_i3k_game_context:setChatUIOpenState(true)
end

function wnd_chat:refresh(chatState)
	self._chatState = chatState or global_world
	self:onHideRedPoint()
	self:reloadScroll()
	self:checkActionBtnStatus()
	self:setTabLight()
	self:refreshInputType()
end

function wnd_chat:refreshInputType()
	self:setInputType(1)--默认
	if self._chatState == global_system then
		local text = "本频道不能发言，请去其他频道。"
		self:setInputType(2,text)
	elseif self._chatState == global_world then
		self:setInputType(1)
	elseif self._chatState == global_sect then
		local sectId = g_i3k_game_context:GetSectId()
		if sectId <= 0 then
			local text = "您当前没有加入帮派，无法发言"
			self:setInputType(2,text)
		end
	elseif self._chatState == global_team then
		local teamId = g_i3k_game_context:GetTeamId()
		if teamId == 0 then
			local text = "您当前没有队伍，无法发言"
			self:setInputType(2,text)
		end
	elseif self._chatState == global_battle then

	elseif self._chatState == global_span then

	end
	g_i3k_ui_mgr:CloseUI(eUIID_SelectBq)
end

function wnd_chat:tabbarCB(sender)
	self.new_msg_btn:setVisible(false)
	self._newMsgCount = 0
	self._oldMsgCount = 0
	self:isNotLockScreen()

	self:closeFC()

	local tag = sender:getTag()
	if tag == 6 then
	else
		tag = tag - 1
	end
	if tag ~= self._chatState then
		self:stopFinishPlay()
		self._chatState = tag
		local isbattle = i3k_chat_state_BattleOrTeam()         --self:isBattle()
		if tag == global_team and isbattle then
			self._chatState = global_battle
		end
		self:setTabLight()
		self:refreshInputType()
		self:reloadScroll()
	end
end

function wnd_chat:sendMessage(sender)
	self:closeFC()
	local editBox = self._layout.vars.editBox
	local message = editBox:getText()
	local needItemId = i3k_db_common.chat.worldNeedId
	local canSend,isHaveItem,isSpanItem = self:checkSend(self._chatState)
	local isCmdString = string.sub(message, 0, 2)
	local isCmd = false
	if message == "@#i3kh" then
		g_i3k_ui_mgr:CloseUI(eUIID_GMEntrance)
		return
	end
	if isCmdString == "@#" then
		isCmd = true
		canSend = true
		canSend = self:showDebug(message)
		canSend = self:closeui(message,canSend)
		if not g_i3k_game_context:GetCLoseAllUiDebug() then
			canSend = self:recordDebug(message,canSend)
		end
	end
	local textcount = i3k_get_utf8_len(message)
	if textcount > i3k_db_common.inputlen.chatlen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(747))
	elseif canSend then
		local roleId = g_i3k_game_context:GetRoleId()
		local cfg = g_i3k_game_context:GetUserCfg()
  		local isSpanTips = cfg:GetIsSpanTips()
		if self._chatState == 6 and isSpanTips == 1 then
			local vipLvl = g_i3k_game_context:GetVipLevel()
			if vipLvl >= i3k_db_common.chat.isOpenSpanLvl then
				g_i3k_ui_mgr:OpenUI(eUIID_SpanTips)
				g_i3k_ui_mgr:RefreshUI(eUIID_SpanTips,isCmd,self._chatState,message,roleId)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(790, i3k_db_common.chat.isOpenSpanLvl))
			end
		else
			editBox:setText("")
			self:checkInput(isCmd,self._chatState,message,roleId)
		end
	elseif not isCmd then
		if self._chatState == global_world then
			if isHaveItem then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(137, g_i3k_db.i3k_db_get_common_item_name(needItemId)))
			end
		elseif self._chatState == global_span then
			if isSpanItem then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(791))   --真言道具不足
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
		end
	end
end

--打开debug测试窗口
function wnd_chat:showDebug(message)
	local canSend = true
	local orderStr = "@#showdebug"
	local str = string.match(message,orderStr)
	if str and string.len(message) == string.len(orderStr) then
		canSend = false
		g_i3k_ui_mgr:OpenUI(eUIID_OtherTest)
	end
	return canSend;
end
--关闭页面本地命令
function wnd_chat:closeui(message,canSend)
	--local canSend = true
	local orderStr = "@#closeui "
	local str = string.match(message,orderStr)
	local index = tonumber(string.sub(message,string.len(orderStr)))
	if str and index then
		canSend = false
		g_i3k_game_context:SetCloseAllUiDebug(true)
		if index == 0 then
			g_i3k_ui_mgr:CloseAllOpenedUI()
		else
			g_i3k_ui_mgr:CloseUI(index)
		end
	end
	return canSend;
end
--运营记录战斗界面
function wnd_chat:recordDebug(message,canSend)
	local orderStr = "@#recorddebug"
	local str = string.match(message,orderStr)
	if str and string.len(message) == string.len(orderStr) then
		canSend = false
		g_i3k_game_context:SetRecoardDebug(true)
		g_i3k_ui_mgr:CloseAllOpenedUI()
		g_i3k_ui_mgr:OpenUI(eUIID_BattleBase)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onlyShowSkillItem")
		g_i3k_ui_mgr:OpenUI(eUIID_Yg)
	end
	return canSend;
end

function wnd_chat:touxiangClicked(sender,currentMsg)
	if (currentMsg.type == 0 and not currentMsg.isRoom) or currentMsg.help == true or currentMsg.fromId < 0 then
		return;
	end
	local playerId = math.abs(currentMsg.fromId)
	local roleId = g_i3k_game_context:GetRoleId()
	if playerId ~= roleId then
		i3k_sbean.query_rolebrief(playerId, {chat = true, srcSectId = currentMsg.srcSectId})
	end
end

-- 将动作按钮移至聊天界面中。
function wnd_chat:onActionBtn(sender)
	self:onBack()
	local is_model = g_i3k_game_context:IsInMissionMode()
	if not is_model then
		g_i3k_ui_mgr:OpenUI(eUIID_SocialAction)
		g_i3k_ui_mgr:RefreshUI(eUIID_SocialAction)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1599))
	end
end

function wnd_chat:onSnapShotBtn(sender)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:DigMineCancel()
		hero:ClearFindwayStatus()
	end
	g_i3k_game_context:SetAutoFight(false)
	-- g_i3k_game_handler:EnableObjHitTest(true, false)-- 禁用触屏操作
	g_i3k_logic:ShowBattleUI(false)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Yg, "show")
	g_i3k_ui_mgr:OpenUI(eUIID_SnapShot)
	self:onBack()
end

function wnd_chat:onBroadcast(sender)
	self:onBack()
	g_i3k_game_handler:RKStartBroadcast()
end

function wnd_chat:checkActionBtnStatus()
	local condition = g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.actionLvl
	local mapCondition = i3k_game_get_map_type() == g_FIELD or  i3k_game_get_map_type() == g_HOME_LAND or i3k_game_get_map_type() == g_HOMELAND_HOUSE
	local isInSpring = g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId
	local isFish = g_i3k_game_context:GetHomeLandFishStatus() --是否钓鱼
	if condition and mapCondition and not isInSpring and not isFish then
		self._layout.vars.action_btn:show()
	else
		self._layout.vars.action_btn:hide()
	end
end

function wnd_chat:toVoiceOrWord(sender)
	if sender:getTag() == 1 then
		self._isVoice = true
		g_i3k_ui_mgr:CloseUI(eUIID_SelectBq)
	else
		self._isVoice = false
		self:cancelRecord()
	end
	self:setInputType(1)
end

function wnd_chat:onBackClick(sender)
	self:onBack()
end

function wnd_chat:onBack()
	g_i3k_ui_mgr:CloseUI(eUIID_SelectBq)
	self.new_msg_btn:setVisible(false)
	self:closeFC()
	local rootVar = self._layout.rootVar
	local jiantou = self._layout.vars.jiantou
	if rootVar then
		--g_i3k_game_context:setChatUIOpenState(false)
		local pos = rootVar:getPosition()
		local width = rootVar:getContentSize().width
		local move = rootVar:createMoveTo(0.2, -width/2 - jiantou:getContentSize().width/2, pos.y)
		local closeui = function()g_i3k_ui_mgr:CloseUI(eUIID_Chat) end
		local SeqAction = rootVar:createSequence(move,cc.CallFunc:create(closeui))
		rootVar:runAction(SeqAction)
	end
end

function wnd_chat:backGroundCB(sender)
	self:closeFC()
end

function wnd_chat:closeFC()
	g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
end

function wnd_chat:updateRecentBtn()
	local recentData = g_i3k_game_context:GetRecentChatData()
	if #recentData==0 then
		self._tabbar[5]:hide()
	else
		self._tabbar[5]:show()
	end
end

function wnd_chat:reloadScroll()
	if self._chatState ~= global_recent and self._chatState ~= global_cross then
		self:updateRecentBtn()
		self:updateChannelredPoint()
	 	self:onHidebattleRedPoint()
	 	self:setChatScroll()
		self:setSpanSystemScoll()
		
		local chatData = g_i3k_game_context:GetChatData()      --获取数据	

		for i,v in chatData[self._chatState + 1]:ipairs() do
			self:createChatItem(v)
		end
	else                                                   --私聊
		g_i3k_ui_mgr:OpenUI(eUIID_PriviteChat)
		g_i3k_ui_mgr:RefreshUI(eUIID_PriviteChat)
		self:onBack()
	end
end

function wnd_chat:onShowRedPoint()
	local redPoint = self._layout.vars.recentRed
	redPoint:show()
end

function wnd_chat:onHideRedPoint()
	local redPoint = self._layout.vars.recentRed
	redPoint:hide()
end

function wnd_chat:onHidebattleRedPoint()
	local sectRed = self._layout.vars.sectredPoint
	local teamRed = self._layout.vars.teamredPoint
	local recentRed = self._layout.vars.recentRed
	local spanRed = self._layout.vars.spanRed
	if self._chatState == global_world then
		g_i3k_game_context:reduceMsg(global_world)
		g_i3k_game_context:reduceMsg(global_system)
	elseif self._chatState == global_system then
		g_i3k_game_context:reduceMsg(global_system)
	elseif self._chatState == global_sect then
		sectRed:hide()
		g_i3k_game_context:reduceMsg(global_sect)
	elseif self._chatState == global_team then
		teamRed:hide()
		g_i3k_game_context:reduceMsg(global_team)
	elseif self._chatState == global_recent then
		recentRed:hide()
		g_i3k_game_context:reduceMsg(global_recent)
	elseif self._chatState == global_battle then
		teamRed:hide()
		g_i3k_game_context:reduceMsg(global_battle)
	elseif self._chatState == global_span then
		spanRed:hide()
		g_i3k_game_context:reduceMsg(global_span)
	elseif self._chatState == global_cross then
		recentRed:hide()
		g_i3k_game_context:reduceMsg(global_cross)
	end

	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onHideChatRedPoint")
end

function wnd_chat:updateChannelredPoint()
	local MsgLog = g_i3k_game_context:GetChatMsg()
	for i,e in pairs(MsgLog) do
		local msgtype = i - 1
		if msgtype ~= self._chatState and #e > 0 then
			if msgtype == global_sect then  --判定当前BTN的状态
				self._layout.vars.sectredPoint:show()
			elseif msgtype == global_team then
				self._layout.vars.teamredPoint:show()
			elseif msgtype == global_recent or msgtype == global_cross then
				self._layout.vars.recentRed:show()
			elseif msgtype == global_battle then
				if i3k_chat_state_BattleOrTeam() then
					self._layout.vars.teamredPoint:show()
				else
					g_i3k_game_context:reduceMsg(global_battle)
				end
			elseif msgtype == global_span then
				self._layout.vars.spanRed:show()
			end
		end
	end
	self:onHidebattleRedPoint()
end

function wnd_chat:selectBq(sender)
	if self._isVoice then
		self._isVoice = false
		self:setInputType(1)
		self:cancelRecord()
	end
	g_i3k_ui_mgr:OpenUI(eUIID_SelectBq)
	g_i3k_ui_mgr:RefreshUI(eUIID_SelectBq, eUIID_Chat)
end

function wnd_chat:receiveNewMsg(message)
	self:updateChannelredPoint()            --当有新消息时刷新一遍红点

	if (self._chatState == global_world and message.type ~= global_system ) or self._chatState == message.type then
		self:createChatItem(message)--单独刷新
	end
end

function wnd_chat:SetLockScreenInfo(message)
	local isShow = self._isLockScreen
	if message.fromId == g_i3k_game_context:GetRoleId() and isShow then
		self:browseNewMsg()
	end

	if not isShow then
		self._oldMsgCount = self._oldMsgCount + 1
	end

	if isShow and message.fromId ~= g_i3k_game_context:GetRoleId()then
		self.new_msg_btn:setVisible(true)
		self:setNewMsgCount()
		self:setNewMsgText()
	end
end

function wnd_chat:createChatItem(message)
	local scroll, isLockScreen = self:getChatScroll( self.widgets.scroll, self._isLockScreen, message)

	if scroll == self._currLockScroll then
		self:SetLockScreenInfo(message)
	end
	if message.msgType == 2 then               --赠花
		self:sendFlower(scroll,message,2,isLockScreen)
	elseif message.msgType == 8 then -- 示爱道具
		self:addShowLoveItem(scroll, message, 2, isLockScreen)
	elseif message.msgType == 12 then -- 心情日记送礼	
		if self:isInSpanScoll(message.msgType) then
			self:diarySendGift(self._diffSeverImageScoll, message, 2, isLockScreen)
			self:refreshSpanScollPosition(true, 100)
		else
			self:diarySendGift(scroll, message, 2, isLockScreen)
		end
	elseif message.msgType ==  14 then -- 世界告白
		if self:isInSpanScoll(message.msgType) then
			self:addWorldShowLove(self._diffSeverImageScoll, message, 2, isLockScreen)
			self:refreshSpanScollPosition(true, 100)
		else
			self:addWorldShowLove(scroll, message, 2, isLockScreen)
		end	
	elseif message.isVoice then                --语音消息
		self:sendVoice(scroll,message,nil,isLockScreen)
	else
		local roleId = g_i3k_game_context:GetRoleId()
		local node = nil
		if message.fromId == roleId or message.fromId < 0 then
			if message.sectDescType and message.sectDescType == 1 then
				node = require("ui/widgets/lttbpf")()
			else
				node = require("ui/widgets/lttf")()
			end
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(g_i3k_game_context:GetRoleHeadIconId(), true))
			node.vars.txb_img:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
		else
			if message.sectDescType and message.sectDescType == 1 then
				node = require("ui/widgets/lttbp")()
			else
				node = require("ui/widgets/ltt1")()
			end
			if (message.type == global_system and not message.isRoom) or message.help == true or message.factionThing or message.isSectSpring then
				node.vars.newIcon:setImage(g_i3k_db.i3k_db_get_icon_path(message.iconId))
			else
				node.vars.newIcon:hide()
				node.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(message.iconId, true))
			end
			node.vars.txb_img:setImage(g_i3k_get_head_bg_path(message.bwType, message.headBorder))
		end

		local showText =  self:onOthertype(scroll,message,node,2,true)
		if message.syncType == 10 then
			node.rootVar:onClick(self,self.openBossUI)
		end
		if message.msgType == 11 then
			node.rootVar:onClick(self, self.openMoodDiary, message)
		end
		if message.msgType == 15 then
			node.rootVar:onClick(self, self.openConstellationTestResult, message)
		end
		if message.sectGarrisonBossId then
			node.rootVar:onClick(self, self.gotoGarrisonBoss, message.sectGarrisonBossId)
		end
		if message.syncType or message.isWoodMan or message.isSectSpring then
			showText = string.gsub(showText,"<c=hlgreen>","<c=green>")
		end
		node.vars.text:setText(showText)

		g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
			local nheight = node.vars.text:getInnerSize().height
			local tSizeH = node.vars.text:getSize().height

			if nheight > tSizeH then
				local imgSize = node.vars.bg_img:getContentSize()
				local rSize = node.rootVar:getContentSize()
		 		local delta = nheight - tSizeH

		 		if node.vars.downImg then
		 			node.vars.downImg:setPositionY(node.vars.downImg:getPositionY()-delta)
		 		end
				node.vars.bg_img:setContentSize(imgSize.width, imgSize.height + delta)
				node.rootVar:changeSizeInScroll(scroll, rSize.width, rSize.height + delta, true)
		 	end

			self:WhatJumpToListPersont(isLockScreen,scroll)
		end,1)

		self:itemSetImage(message,node)
		self:SetPlayerName(node,message,true)
		if message.type ~= 6 then
			node.vars.btn:onClick(self, self.touxiangClicked,message)
		end
		scroll:addItem(node)
		self:SetVipIcon(node,message.fromId,message.vipLvl)
		if not message.sectDescType or message.sectDescType ~= 1 then
			self:setBgImage(node, message.fromId, message.vipLvl, message.chatBox)
		end
	end
end

function wnd_chat:updatelb()
	if self._chatState == global_world then
		local lbnum = self._layout.vars.lbNum
		lbnum:setText(self:getlbNum())
	end
end

function wnd_chat:onHide()
	self:stopFinishPlay()
	self:cancelRecord()
	g_i3k_game_context:setChatUIOpenState(false)
end

function wnd_chat:isBattle()
	if i3k_game_get_map_type() == g_FORCE_WAR then
		return true;
	end
end

function wnd_chat:setChatScroll()
	local widgets = self._layout.vars
	widgets.scroll1:removeAllChildren()
	widgets.scroll2:removeAllChildren()
	widgets.scroll:removeAllChildren()
	if self._chatState == global_system or self._chatState == global_world then
		widgets.scrollRoot:hide()
		widgets.scrollRoot1:show()
		local str = self._chatState == global_world and {"跨服消息", "本服综合"} or {"系统消息", "组队消息"}
		widgets.titlename2:setText(str[1])
		widgets.titlename3:setText(str[2])
		self._currLockScroll = widgets.scroll2
	else
		widgets.scrollRoot1:hide()
		widgets.scrollRoot:show()
		widgets.titlename:setText((self.channel_name or "").."频道")
		self._currLockScroll = widgets.scroll
	end
end

function wnd_chat:getChatScroll(scroll, isLockScreen, message)
	if self._chatState == global_system then
		if message.isRoom then
			scroll = self.widgets.scroll2
		else
			scroll = self.widgets.scroll1
			isLockScreen = false
		end
	elseif self._chatState == global_world then
		if message.type == global_span then
			scroll = self.widgets.scroll1
			isLockScreen = false
		else
			scroll = self.widgets.scroll2
		end
	end
	return scroll, isLockScreen
end

function wnd_chat:openChatBubble()
	i3k_sbean.role_chat_box_syncReq()
end

function wnd_chat:openPigeonPostSend(sender)
	if g_i3k_game_context:GetLevel() >= i3k_db_pigeon_post.openLvl then
		g_i3k_ui_mgr:OpenUI(eUIID_PigeonPostSend)
		g_i3k_ui_mgr:RefreshUI(eUIID_PigeonPostSend)
		g_i3k_ui_mgr:CloseUI(eUIID_Chat)
	else
		g_i3k_ui_mgr:PopupTipMessage("等级不足")
	end
end

function wnd_chat:setSpanSystemScoll()
	local chatData = g_i3k_game_context:GetChatData()
	local spandata = chatData[global_span + 1]
	
	if chatData == nil or spandata == nil then 
		self._diffSeverImage:setVisible(false)
	end
		
	if self._chatState == global_span and spandata._count > 0 then
		local flag = false
		
		for _, v in spandata:ipairs() do 
			if spanScollMsgType[v.msgType] then
				flag = true
				break
			end
		end
		
		if flag then
			self._diffSeverImage:setVisible(true)
			self._diffSeverImageScoll:removeAllChildren()
		else			
			self._diffSeverImage:setVisible(false)
		end
	else
		self._diffSeverImage:setVisible(false)
	end
end

function wnd_chat:isInSpanScoll(msgType)
	if msgType == nil then return false end
	return spanScollMsgType[msgType] and self._chatState == global_span	
end

function wnd_chat:refreshSpanScollPosition(isShow, percent)
	if self._diffSeverImage:isVisible() ~= isShow then
		self._diffSeverImage:setVisible(isShow)
	end
		
	if self._diffSeverImageScoll:getListPercent() ~= percent then
		self._diffSeverImageScoll:jumpToListPercent(percent)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_chat.new();
	wnd:create(layout, ...);
	return wnd;
end

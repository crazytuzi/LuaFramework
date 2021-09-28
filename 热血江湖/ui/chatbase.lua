-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_chatBase = i3k_class("wnd_chatBase",ui.wnd_base)
local flowerNumColor = {"ff1dd7ff","ffffffff","0xfffc1d","0xff5932"}
local namecolor = "ff65944d"
local anis_is_play = true
local itemImageTbl = {
	[1] = 2667, 
	[2] = 2669, 
	[3] = 2670, 
	[4] = 2668, 
	[5] = 2675, 
	[6] = 2671,
	[7] = 2888, 
	[8] = 2675, 
	[9] = 7712,
	[10] = 9981,
}

function wnd_chatBase:ctor()
--	self._uiLayer = nil;
	self._chatState = global_world
	self._currSender = nil
	self._OtherVInfo = nil
	self.voiceInfo = nil
end

function wnd_chatBase:configure()
end

function wnd_chatBase:refresh()

end

function wnd_chatBase:toVoice(sender)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(487))
end

function wnd_chatBase:cancelRecord()
	if g_i3k_ui_mgr:GetUI(eUIID_Volume) then
		g_i3k_ui_mgr:CloseUI(eUIID_Volume)
		g_i3k_game_handler:StopVoiceRecord(true)
		i3k_game_cancel_voice_state(g_VOICE_RECORDING_VOICE_MSG)
	end
end

function wnd_chatBase:createVoiceUrl(sender, eventType)
	if not self:canSendMessage() then
		return
	end
	if eventType == ccui.TouchEventType.began then
		if i3k_game_set_voice_state(g_VOICE_RECORDING_VOICE_MSG) then
			local startResult = g_i3k_game_handler:StartVoiceRecord()
			if startResult ~= false then --旧版本的引擎是nil，所以只能这么判断了
				g_i3k_ui_mgr:OpenUI(eUIID_Volume)
				g_i3k_ui_mgr:RefreshUI(eUIID_Volume)
			else
				i3k_game_cancel_voice_state(g_VOICE_RECORDING_VOICE_MSG)
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3058))
		end
	elseif eventType == ccui.TouchEventType.ended then
		i3k_game_cancel_voice_state(g_VOICE_RECORDING_VOICE_MSG)
		g_i3k_game_handler:StopVoiceRecord(false)
		g_i3k_ui_mgr:CloseUI(eUIID_Volume)
	elseif eventType == ccui.TouchEventType.canceled then
		i3k_game_cancel_voice_state(g_VOICE_RECORDING_VOICE_MSG)
		g_i3k_game_handler:StopVoiceRecord(true)
		g_i3k_ui_mgr:CloseUI(eUIID_Volume)
	end
end

function wnd_chatBase:canSendMessage()
	local canSend,isHaveItem = self:checkSend(self._chatState)

	if canSend then
		return true
	else
		if self._chatState == global_world then
			if isHaveItem then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(137, g_i3k_db.i3k_db_get_common_item_name(i3k_db_common.chat.worldNeedId)))
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
		end
		return false
	end
end

function wnd_chatBase:sendVoiceUrl(url, sec)
	--local sec = string.format("%.1f",ChatBase_Record_Sec)
	url = "#V"..url.."#"..sec.."#"
	local roleId = g_i3k_game_context:GetRoleId()

	self:checkInput(false,self._chatState,url,roleId)
end

function wnd_chatBase:parseStr(message,preStr,proStr,repPreStr,flag)
	local newtable = {}
	local index=0
	local index1=0
	local len = string.len(message)
	for i=1,len do
		index = string.find(message,preStr,index)
		if index == nil then
			break;
		end
		index1 = string.find(message,proStr,index+2)
		if index1 == nil then
			break
		end
		local str = string.sub(message,index+2,index1-1)
		if str then
			local id = tonumber(str)
			if id then
				local text = ""
				if flag == 1 then--表情
					text = g_i3k_db.i3k_db_get_icon_path(1400+id)
				elseif flag == 0 then
					local index2 = index+2
					text = g_i3k_db.i3k_db_get_common_item_name(id)
					newtable[id] = text
				elseif flag == 2 then
					text = "申请入队"
					newtable[id] = text
				end
				message = string.gsub(message,str,text)
			end
		end
		index = index1
	end
	message=string.gsub(message,preStr,repPreStr)
	return message,newtable
end

function wnd_chatBase:checkInput(isCmd,sendType,message,sendId,msgTab,flag,isTips)
	local cantSend = false
	local messageType = sendType
	if isCmd then
--		g_i3k_ui_mgr:PopupTipMessage("这是GM cmd命令")
	else
		if self.inviteInfo and self.inviteInfo == 1 then
			local targetTeamId = g_i3k_game_context:GetTeamId()
			local newStr = string.format("#T%d#",targetTeamId)
			message = string.gsub(message, "%[申请入队%]",newStr)
		end

		if self.equipInfo and self.equipInfo.equipName then
			message = string.gsub(message, "%[".. self.equipInfo.equipName .."%]", self.equipInfo.msg)
		end
	end

	if cantSend then
		g_i3k_ui_mgr:PopupTipMessage("包含非法字符")
	elseif message == "" then
		g_i3k_ui_mgr:PopupTipMessage("输入不能为空")
	else
		if string.sub(message, 0, 2) ~= "@#" and messageType == global_world and g_i3k_game_context:GetLevel() < i3k_db_common.chat.limitLvl then
			return g_i3k_ui_mgr:PopupTipMessage(string.format("等级到达<c=hlred>%d级</c>之后开放世界发言", i3k_db_common.chat.limitLvl))
		end
		self.equipInfo = nil
		self.inviteInfo = nil
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SelectBq, "clearEquipList")
		local send = i3k_sbean.msg_send_req.new()
		local gsName = i3k_game_get_server_name(i3k_game_get_login_server_id())
		send.type = messageType
		send.id = math.abs(sendId)
		send.msg = string.ltrim(message)
		send.gsName = gsName
		if isTips == 0 then
			send.isTips =  isTips
		end
		if string.find(message, "@#profiler") then --转换 profiler
			local isProfiler = g_i3k_game_context:getVoiceState()
			g_i3k_game_context:setVoiceState(not isProfiler)
			return g_i3k_ui_mgr:PopupTipMessage(isProfiler and "关闭profiler模式" or "开启profiler模式")
		end
		if string.find(message, "@#luajitlog") then
			return g_i3k_ui_mgr:PopupTipMessage(g_i3k_cache_jit_log)
		end
		i3k_game_send_str_cmd(send, i3k_sbean.msg_send_res.getName())
	end
end

function wnd_chatBase:getlbNum()--获取喇叭的数量
	local needItemId = i3k_db_common.chat.worldNeedId
	local num = g_i3k_game_context:GetCommonItemCanUseCount(needItemId)
	return num
end

function wnd_chatBase:getZyfNum()--获取真言符的数量
	local needItemId = i3k_db_common.chat.spanNeedId
	local num = g_i3k_game_context:GetCommonItemCanUseCount(needItemId)
	return num
end

function wnd_chatBase:checkTime(sendTime, limitTime)
	if sendTime == nil then
		return true
	end
	if i3k_game_get_time() - sendTime>=limitTime then
		return true
	end
	return false
end

function wnd_chatBase:checkSend(state)
	local canSend = false
	local isHaveItem = false
	local isSpanItem = false
	local timeNow = i3k_game_get_time()
	if state==global_world then--大喇叭
		local count = self:getlbNum()
		if count>0 then
			isHaveItem = true
		end
		if isHaveItem then
			canSend = self:checkTime(g_i3k_game_context:GetWorldSendTime(), i3k_db_common.chat.timeWorld)
		end
	elseif state==global_team or state == global_battle then
		--判断时间间隔，用时间戳判断
		canSend = self:checkTime(g_i3k_game_context:GetTeamSendTime(), i3k_db_common.chat.timeTeamSect)
	elseif state==global_sect then
		canSend = self:checkTime(g_i3k_game_context:GetSectSendTime(), i3k_db_common.chat.timeTeamSect)
	elseif state == global_recent or state == global_cross then
		canSend = self:checkTime(g_i3k_game_context:GetPriviteSendTime(), i3k_db_common.chat.timePrivite)
	----------------------------------------------------------
	elseif state == global_span then
		local count = self:getZyfNum()
		if count > 0 then
			isSpanItem = true
		end
		if isSpanItem then
			canSend = self:checkTime(g_i3k_game_context:GetSpanSendTime(), i3k_db_common.chat.timeSpan)
		end
	elseif state == global_room then
		canSend = self:checkTime(g_i3k_game_context:GetRoomSendTime(), i3k_db_common.chat.timeTeamSect)
	end
	---------------------------------------------------------
	return canSend,isHaveItem,isSpanItem
end

function wnd_chatBase:setEquipTableValue(equipInfo)
	--self.msgTab = tab
	self.equipInfo = equipInfo
end

function wnd_chatBase:remmberInviteFlag(inviteInfo)
	--self.flag = value
	self.inviteInfo = inviteInfo
end

function wnd_chatBase:sendVoice(scroll,message,privateContent,isLockScreen)
	local roleId = g_i3k_game_context:GetRoleId()
	local node = nil
	if privateContent then
		local iconId
		local bwType = 0
		local headBorder = 0
		if privateContent.isFromSelf then
			node = require("ui/widgets/slt4")()
			iconId=g_i3k_game_context:GetRoleHeadIconId()
			bwType = g_i3k_game_context:GetTransformBWtype()
			headBorder = g_i3k_game_context:GetRoleHeadFrameId()
		else
			node = require("ui/widgets/slt2")()
			iconId = message.iconId
			bwType = message.bwType
			headBorder = message.headBorder
		end
		node.vars.frame:setImage(g_i3k_get_head_bg_path(bwType, headBorder))
		node.vars.redPoint:hide()
		node.vars.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))

		local playAnis = node.anis and node.anis.c_bofang
		local url = privateContent.voiceUrl
		local anim = node.vars.anim
		if privateContent.isRead then
			node.vars.msgSec:setText("已读")
		else
			node.vars.msgSec:setText(privateContent.voiceSec.."\'\'")
		end
		node.vars.playBtn:onClick(self, self.playVoice, {url = url, anis = playAnis, anim = anim, msg = privateContent, msgui = node.vars.msgSec})
	else
		local playerName = ""
		if message.fromId == roleId or message.fromId < 0 then
			node = require("ui/widgets/ltt2f")()
			playerName = g_i3k_game_context:GetRoleName()
			node.vars.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(g_i3k_game_context:GetRoleHeadIconId(), true))
			node.vars.frame:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
		else
			node = require("ui/widgets/ltt2")()
			playerName = message.fromName
			node.vars.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(message.iconId, true))
			node.vars.frame:setImage(g_i3k_get_head_bg_path(message.bwType, message.headBorder))
		end
		node.vars.redPoint:hide()
		node.vars.chatTime:setText(g_i3k_logic:GetTime(message.time))
		node.vars.fromName:setText(playerName)

		self:itemSetImage(message,node)

		local playAnis = node.anis and node.anis.c_bofang
		local url = message.voiceUrl
		local anim = node.vars.anim
		node.vars.headBtn:onClick(self, self.touxiangClicked, message)
		if message.msgContent and (message.type == global_recent or message.type == global_cross) and message.msgContent.isRead then
			message.isRead = true
		end
		if message.isRead then
			node.vars.msgSec:setText("已读")
		else
			node.vars.msgSec:setText(message.voiceSec.."\'\'")
		end
		node.vars.playBtn:onClick(self, self.playVoice, {url = url, anis = playAnis, anim = anim, msg = message, msgui = node.vars.msgSec})
	end
	scroll:addItem(node)
	self:WhatJumpToListPersont(isLockScreen,scroll)
	if not privateContent then
		self:SetVipIcon(node,message.fromId,message.vipLvl)
	end
end

function wnd_chatBase:sendFlower(scroll,message,flage,isLockScreen)
	local sendFlowerData = message.sendFlowersData
	local flowerNum = sendFlowerData.count
	local getRoleName = sendFlowerData.roleName
	local getRoleId = sendFlowerData.roleId
	local selfName = message.fromName
	local selfId = message.fromId
	local index = #i3k_db_sendflower_chat
	for i,v in ipairs(i3k_db_sendflower_chat) do
		if flowerNum < v.minflowerNum then
			index = i-1
			break;
		end
	end
	if index > 0 then
		local node = nil
		local textId = i3k_db_sendflower_chat[index].textID
		local bgImgId = i3k_db_sendflower_chat[index].bgImgID+3
		local color = flowerNumColor[bgImgId-2]
		local showText = i3k_db_string[textId]
		showText = string.format("<c=%s>%s</c>送<c=%s>%s</c><c=%s>%s</c>朵鲜花，%s",namecolor,selfName,namecolor,getRoleName,color,flowerNum,showText)
		if flage == 2 then
			if bgImgId == 3 then
				node = require("ui/widgets/ltt1")()
				node.vars.newIcon:setImage(g_i3k_db.i3k_db_get_icon_path(2427))
				node.vars.fromName:setText("")
				node.vars.chattime:setText(g_i3k_logic:GetTime(message.time))
				node.vars.text:setText(showText)
			else
				node = require("ui/widgets/ltt"..bgImgId)()
				if index > 2 then
					local effectflage = index%2
					if effectflage == 1 then
						node.anis.c_hao.play()
					elseif effectflage == 0 then
						node.anis.c_ci.play()
					end
				end
				node.vars.b:setText(showText)
			end
		elseif flage == 1 then
			node = require("ui/widgets/zdltt")()
			node.vars.b:setText(showText)
		end

		self:itemSetImage(message,node)

		scroll:addItem(node)
		self:WhatJumpToListPersont(isLockScreen,scroll)
	end
end

-- 示爱道具
function wnd_chatBase:addShowLoveItem(scroll, message, flag, isLockScreen )
	local showLoveItem = message.showLoveItem -- i3k_sbean.SendShowLoveItemInfo
	local sendRoleId = showLoveItem.sendRoleId
	local sendRoleName = showLoveItem.sendRName
	local beUsedRId = showLoveItem.beUsedRId
	local beUsedRName = showLoveItem.beUsedRName
	local itemID = showLoveItem.itemID
	local mapID = showLoveItem.mapID
	local line = showLoveItem.line
	local pos = showLoveItem.pos
	local selfName = message.fromName
	local selfId = message.fromId
	local mapInfo = {mapId = mapID, pos = i3k_logic_pos_to_world_pos(pos), mapLine = line}
	-- message.fromId == g_i3k_game_context:GetRoleId() -- 自己发送的消息

	local mapName = i3k_db_dungeon_base[mapID].desc
	local itemCfg = g_i3k_db.i3k_db_get_common_item_cfg(itemID)
	local msgID = 16956 -- 普通
	if itemID ~= i3k_db_show_love_item.typeNormalID then
		msgID = 16957 -- 豪华
	end
	local node = nil
	local showText = i3k_get_string(msgID, sendRoleName, mapName, beUsedRName, itemCfg.name)
	if flag == 2 then -- 在战斗ui中，flag=1，打开了聊天界面，flag=2
		node = require("ui/widgets/lttsa")()
		node.vars.b:setText("<t=1>"..showText.."</t>")   -- 寻路已经要带<t=1> 这个字段
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(2427))
		self:itemSetImage(message, node)
		node.vars.b:setTag(mapID)
		node.vars.b:onRichTextClick(self, self.searchPath, mapInfo)
	else
		node = require("ui/widgets/zdltt2")()
		node.vars.content:setText(showText)
		node.vars.fromName:hide()
		self:itemSetImage(message, node)
		node.vars.content:setRichTextFormatedEventListener(function(sender)
			local nheight = node.vars.content:getInnerSize().height
			local tSizeH = node.vars.content:getSize().height

			if nheight > tSizeH then
				local size = node.rootVar:getContentSize()
				node.rootVar:changeSizeInScroll(scroll, size.width, size.height + nheight - tSizeH, true)
		 	end
			-- scroll:jumpToListPercent(100)
			node.vars.content:setRichTextFormatedEventListener(nil)
		end)
	end
	self:WhatJumpToListPersont(isLockScreen, scroll)
	scroll:addItem(node)
end

-- 世界告白
function wnd_chatBase:addWorldShowLove(scroll, message, flag, isLockScreen )

	local node = nil
	local fromName = message.fromName
	local toName = message.roleName
	local msg = message.msgBless
	local refFestivalBless = message.refFestivalBless
	local showText = i3k_get_string(17239, fromName, toName, msg)

	if flag == 2 then -- 在战斗ui中，flag=1，打开了聊天界面，flag=2
		node = require("ui/widgets/lttsa")()
		node.vars.b:setText("<t=1>"..showText.."</t>")   -- 寻路已经要带<t=1> 这个字段
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(2427))
		self:itemSetImage(message, node)
		-- node.vars.b:setTag(mapID)
		node.vars.b:onRichTextClick(self, self.worldBless, message)
	else
		node = require("ui/widgets/zdltt2")()
		node.vars.content:setText(showText)
		node.vars.fromName:hide()
		self:itemSetImage(message, node)
		node.vars.content:setRichTextFormatedEventListener(function(sender)
			local nheight = node.vars.content:getInnerSize().height
			local tSizeH = node.vars.content:getSize().height

			if nheight > tSizeH then
				local size = node.rootVar:getContentSize()
				node.rootVar:changeSizeInScroll(scroll, size.width, size.height + nheight - tSizeH, true)
		 	end
			-- scroll:jumpToListPercent(100)
			node.vars.content:setRichTextFormatedEventListener(nil)
		end)
	end
	self:WhatJumpToListPersont(isLockScreen, scroll)
	scroll:addItem(node)
end


--心情日记送礼
function wnd_chatBase:diarySendGift(scroll, message, flag, isLockScreen)
	local diaryGift = message.moodDiarySendPopularity
	local sendRname = diaryGift.sendRname
	local receiveRname = diaryGift.receiveRname
	local itemId = diaryGift.itemId
	local itemCnt = diaryGift.itemCnt
	local popularity = i3k_db_new_item[itemId].args1 * itemCnt
	local node = nil


	if flag == 2 then
		if popularity >= i3k_db_mood_diary_cfg.allGsBroadCastCondition then
			node = require("ui/widgets/liwulaba2")()
			node.anis.c_hao.play()
			node.vars.text:setText(i3k_get_string(17175, sendRname, receiveRname, g_i3k_db.i3k_db_get_common_item_name(itemId), itemCnt, popularity))
		else
			node = require("ui/widgets/liwulaba1")()
			node.anis.c_hao.play()
			node.vars.text:setText(i3k_get_string(17174, sendRname, receiveRname, g_i3k_db.i3k_db_get_common_item_name(itemId), itemCnt, popularity))
		end
	else
		node = require("ui/widgets/zdltt2")()
		node.vars.fromName:hide()
		if popularity >= i3k_db_mood_diary_cfg.allGsBroadCastCondition then
			node.vars.content:setText(i3k_get_string(17175, sendRname, receiveRname, g_i3k_db.i3k_db_get_common_item_name(itemId), itemCnt, popularity))
		else
			node.vars.content:setText(i3k_get_string(17174, sendRname, receiveRname, g_i3k_db.i3k_db_get_common_item_name(itemId), itemCnt, popularity))
		end
		node.vars.content:setRichTextFormatedEventListener(function(sender)
			local nheight = node.vars.content:getInnerSize().height
			local tSizeH = node.vars.content:getSize().height
			if nheight > tSizeH then
				local size = node.rootVar:getContentSize()
				node.rootVar:changeSizeInScroll(scroll, size.width, size.height + nheight - tSizeH, true)
		 	end
			node.vars.content:setRichTextFormatedEventListener(nil)
		end)
	end
	self:itemSetImage(message, node)
	self:WhatJumpToListPersont(isLockScreen, scroll)
	scroll:addItem(node)
end

function wnd_chatBase:itemSetImage(message,node)
	if message.isRoom then
		if message.roomType == gRoom_Competition then 
			node.vars.set_image:setImage(g_i3k_db.i3k_db_get_icon_path(itemImageTbl[3]))--帮派邀请
		else
			node.vars.set_image:setImage(g_i3k_db.i3k_db_get_icon_path(3206))--房间组队
		end
	else
		local messageType = message.type
		if  i3k_game_get_map_type() == g_PRINCESS_MARRY and messageType  == global_battle then 
			node.vars.set_image:setImage(g_i3k_db.i3k_db_get_icon_path(8859)) --莫雨争花
		else
			node.vars.set_image:setImage(g_i3k_db.i3k_db_get_icon_path(itemImageTbl[messageType + 1]))
		end
	end
end

function wnd_chatBase:WhatJumpToListPersont(isLockScreen,scroll)
	if isLockScreen then                      --判断是否锁屏
	else
		scroll:jumpToListPercent(100)
	end
end

function wnd_chatBase:createChatItem(message, chatScroll)
	if message.msgType == 2 then--赠花
		self:sendFlower(chatScroll,message,1)
	elseif message.msgType == 8 then -- 示爱道具
		self:addShowLoveItem(chatScroll, message, 1)
	elseif message.msgType == 12 then -- 心情日记送礼
		self:diarySendGift(chatScroll, message, 1)
	elseif message.msgType ==  14 then -- 世界告白
		self:addWorldShowLove(chatScroll, message, 1)
	else
		local node = require("ui/widgets/zdltt2")()
		local showText =  self:onOthertype(scroll,message,node,1)
		node.vars.content:setText(showText)
		node.vars.content:setRichTextFormatedEventListener(function(sender)
			local nheight = node.vars.content:getInnerSize().height
			local tSizeH = node.vars.content:getSize().height

			if nheight > tSizeH then
				local size = node.rootVar:getContentSize()
				node.rootVar:changeSizeInScroll(chatScroll, size.width, size.height + nheight - tSizeH, true)
		 	end
			chatScroll:jumpToListPercent(100)
			node.vars.content:setRichTextFormatedEventListener(nil)
		end)

		self:SetPlayerName(node,message)
		self:itemSetImage(message,node)
		chatScroll:addItem(node)
		chatScroll:jumpToListPercent(100)
		--self:SetVipIconWhenBattleBase(node,message.fromId,message.vipLvl)
	end
end

function wnd_chatBase:onOthertype(scroll,message,node,flag,judge)
	--flag 表示ui的类型 battlebase的聊天ui为0
	local showText = message.msg

	if message.marriageId then
		showText = i3k_get_string(16906,message.fromName, message.otherName)
		showText = "<t=1>"..showText.."</t>"
		if flag == 2 then
			node.vars.text:onRichTextClick(self, self.lookMarriageCard, message.marriageId)
		end
	end

	if message.isSolo then
		if message.soloresult == 0 then
			showText = i3k_get_string(15552,message.soloname)
		elseif message.soloresult == 1 then
			showText = i3k_get_string(15550,message.soloname)
		elseif message.soloresult == 2 then
			showText = i3k_get_string(15551,message.soloname)
		end
	end

	if message.isWoodMan then
		showText = i3k_get_string(965, g_i3k_db.i3k_db_get_monster_name(message.monsterId), message.damage)
		showText = string.format("%s%s%s","<t=1>", showText, "</t>")
		if flag == 2 then
			node.vars.text:onRichTextClick(self, self.gotoWoodMan, message.monsterId)
		end
	end

	if message.jinLanCardID then
		showText = "<t=1>"..i3k_get_string(5502, message.fromName).."</t>"
		if flag == 2 then
			node.vars.text:onRichTextClick(self, function()
				i3k_sbean.get_sworn_card(message.jinLanCardID, true, message.fromId)
			end)
		end
	end

	if message.isJoinSect then
		if message.sectDescType == 0 then
			showText = "<t=1>"..i3k_get_string(16901, string.format("%s:%s", message.sectName, message.sectDesc)).."</t>"
		else
			showText = i3k_get_string(16902, string.format("%s:%s", message.sectName, message.sectDesc))
		end
		if flag == 2 then
			if message.sectDescType == 0 then
				node.vars.text:onRichTextClick(self, self.joinSect, message.sectId)
			else
				node.vars.joinBtn:onClick(self, self.openRecruit, message)
			end
		end
	end

	if message.syncType and message.syncType == 26 then
		if flag == 2 then
			local tp = tonumber(message.rollArgs[5])
			local idx = tonumber(message.rollArgs[6])
			node.vars.text:onRichTextClick(self, self.gotoStelePos, {steleType = tp, index = idx})
		end
	end

	if message.msgType == 1 then
		isBq = true
		local bqStr = ""
		local DiySkillData = message.DiySkillData
		DiySkillData.diyskill.fromName = message.fromName
		for k,v in pairs(DiySkillData.icons) do
			bqStr = bqStr .."#".. v
		end
		if judge then
			showText = "<t=1><c=green>【自创武功--" .. DiySkillData.diyskill.name .. "】</c></t>" .. bqStr
		else
			showText = "<t=1><c=FFAEFF66>【自创武功--" .. DiySkillData.diyskill.name .. "】</c></t>" .. bqStr
		end
		if flag ==2 then
			node.vars.text:onRichTextClick(self, self.showKungfuPanel,DiySkillData.diyskill)
		end
	end

	if message.msgType == 9 then
		showText = "<t=1>"..i3k_get_string(17089,message.fromName).."</t>"
		if flag ==2 then
			node.vars.text:onRichTextClick(self, self.tripWizardPhoto, message.wizardTripPhoto)
		end
	end

	if message.msgType == 11 then
		showText = "<t=1>"..i3k_get_string(17182, message.fromName).."</t>"
	end
	
	if message.msgType == 15 then
		showText = "<t=1>" .. string.format("%s分享了他的星语星愿测试结果，快来围观吧！<c=green>【点击查看】</c>", message.fromName) .. "</t>"
	end

	if message.isVoice then
		showText = "<t=1>点击播放<c=FFAEFF66>【语音消息】</c></t>"
		local url = message.voiceUrl
		if flag == 2 or flag == 3 then
			--node.vars.text:onRichTextClick(self, self.playVoice, url)
		end
	end

	if message.isRoom then
		local mapId = message.rMapId
		if message.roomType == gRoom_Dungeon then
			if mapId == 0 then
				showText = "<t=2>"..i3k_get_string(15197,message.fromName).."</t>"
			else
				showText = string.format("<t=1>%s等级%s以上<c=green>【申请加入】</c></t>",i3k_db_new_dungeon[mapId].name, i3k_db_new_dungeon[mapId].reqLvl)
			end
		elseif message.roomType == gRoom_NPC_MAP then
			showText = string.format("<t=1>%s等级%s以上<c=green>【申请加入】</c></t>",i3k_db_NpcDungeon[mapId].name, i3k_db_NpcDungeon[mapId].openLevel)
		elseif message.roomType == gRoom_TOWER_DEFENCE then
			local cfg = i3k_db_defend_cfg[mapId]
			showText = string.format("<t=1>%s等级%s以上<c=green>【申请加入】</c></t>", cfg.descName, cfg.needLevel)
		elseif message.roomType == gRoom_Competition then
			local count
			for i,v in ipairs(i3k_db_dual_meet.gameScale) do
				if v.mapID == mapId then
					count = v.memberNumber
					break
				end
			end
			showText = i3k_get_string(18800, message.roomId, count, count)
		end
		if flag == 2 then
			node.vars.text:onRichTextClick(self, self.joinDungeonRoom, {mapId = mapId, roomId = message.roomId, rmtype = message.roomType})
		end
	end

	if message.isPos and message.mapLine then--接收内容中包含坐标信息做特殊处理
		local mapId = message.mapId
		local pos = message.pos
		local mapName = i3k_db_dungeon_base[mapId].desc
		local mapInfo = {mapId = mapId,pos = pos, mapLine = message.mapLine}
		if judge then
			showText = "<t=1>快来<c=green>【"..mapName.."】</c></t>"
		else
			showText = "<t=1>快来<c=FFAEFF66>【"..mapName.."】</c></t>"
		end
		--FFFEFF66
		if flag == 2 or flag == 3 then
			node.vars.text:setTag(mapId)
			node.vars.text:onRichTextClick(self, self.searchPath,mapInfo)
		end
	end

	if message.rollPoint then
		if message.fromId == g_i3k_game_context:GetRoleId() or message.fromId < 0 then
			showText = i3k_get_string(17165, message.rollPoint)
		else
			showText = i3k_get_string(17164, message.fromName, message.rollPoint)
		end
	end

	if message.masterId then
		showText = string.format("<t=1>%s</t>", i3k_get_string(5501, message.sharerName))
		if flag == 2 then
			node.vars.text:setTag(tonumber(message.masterId))
			node.vars.text:onRichTextClick(self, self.shareMasterCard)
		end
	end

	local isEquip = string.match(showText,"#I")
	local isInvite = string.match(showText,"#T")
	if isEquip or isInvite then
		local data = {}
		data[1] = {}
		if isEquip then
			local index = string.find(showText,"#I",0)
			local endIndex = string.find(showText,"#",index+1)
			local index1 = string.find(showText,",",index+2)
			local str = string.sub(showText,index+2,index1-1)
			local ItemId = tonumber(str)
			if ItemId < 0 then
				showText = string.gsub(showText, str, tostring(-ItemId))
				endIndex = string.find(showText,"#",index+1)
			end
			local rank = g_i3k_db.i3k_db_get_common_item_rank(ItemId)
			local itemName = g_i3k_db.i3k_db_get_common_item_name(ItemId)
			local color = g_i3k_get_color_by_rank(rank)
			if not judge and rank == 1 then
				color = "FFFFFFFF"
			end
			local str1 = (message.equips.naijiu and message.equips.naijiu >= 0) and "<t=1><c=".. color ..">【『传世』" or "<t=1><c=".. color ..">【"
			--showText = self:parseStr(showText,"#I",",",str1,0)
			str1 = str1 .. itemName .. "】</c></t>"
			local showText1 = showText
			showText = string.gsub(showText, string.sub(showText,index, endIndex), str1)
			if flag ==2 or flag == 3 then
				local equiptab = {}
				equiptab.ItemId = ItemId
				equiptab.equip = message.equips
				data[1] = equiptab
			end
		end
		
		local index = string.find(showText,"#T")
		
		if isInvite and index then
			local tab = nil
			local len1 = string.find(showText,"#",index+1)
			local teamId = tonumber(string.sub(showText,index+2,len1-1))
			local str = nil
			if judge then
				str = "<t=2><c=green>【"
			else
				str = "<t=2><c=FFAEFF66>【"
			end
			str = str.."申请入队".."】</c></t>"
			showText = string.gsub(showText, string.sub(showText,index, len1), str)
			if flag ==2 or flag == 3 then
				data[2] = teamId
				data[3] = math.abs(message.fromId)
			end
		end

		if flag == 2 or flag == 3 then
			node.vars.text:onRichTextClick(self,self.callbackFunc,data)
		end
	end

	local isBq = string.match(showText,"#%d")
	if isBq then
		showText = string.gsub(showText,"#%d+", function(str)
			local id = string.sub(str,2,-1)
			local intId = tonumber(id)
			if intId > 0 and intId <= #i3k_db_emoji then
				local repStr = g_i3k_db.i3k_db_get_icon_path(i3k_db_emoji[intId].iconId)
				return "<e=".. repStr .. "/>"
			end
		end)
	end

	-- 所有 #* 开头的解析，应该放在这里，不应该放在game_context.parseChatData中
	local isCardPacket = string.match(showText,"#C")
	if isCardPacket then
		local cardID, cardBackID = string.match(showText, "#C(%d+),(%d+)")
		local cfg = g_i3k_db.i3k_db_cardPacket_get_card_cfg(tonumber(cardID))
		showText = i3k_get_string(50124, cfg.name) -- "图鉴卡牌【"..cfg.name .."】"
		if flag == 2 or flag == 3 then 
			local info = {cardID = tonumber(cardID), cardBackID = tonumber(cardBackID)}
			node.rootVar:onClick(self, self.onCardPacket, info)
		end
	end

	return showText
end

--自创武功
function wnd_chatBase:showKungfuPanel(sender,tag,kungfuData)
	if tag == 1 and kungfuData then
		g_i3k_ui_mgr:OpenUI(eUIID_KungfuDetail)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_KungfuDetail,"onShowDetailData", kungfuData)
	end
end

function wnd_chatBase:callbackFunc(sender,tag,data)
	if tag == 1 then--装备
		local value = data[1].equip
		local id = data[1].ItemId
		if id > 10000000 or id < -10000000 then
			if value then
				g_i3k_ui_mgr:ShowCommonEquipInfo(value,true)
			end
		else
			g_i3k_ui_mgr:ShowCommonItemInfo(id)
		end
	elseif tag == 2 then--邀请
		if data[4] == 5 then
			if i3k_game_get_map_type() ~= g_FIELD then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15339))
			end
			if g_i3k_game_context:GetLevel() < i3k_db_rightHeart.openlevel then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15194))
			end
		end
		local value = data[2]
		if value then
			local targetTeamId = g_i3k_game_context:GetTeamId()
			if targetTeamId == 0 then
				if value == 0 then
					local roleId = g_i3k_game_context:GetRoleId()
					if roleId ~= data[3] then
						i3k_sbean.invite_role_join_team(data[3])
					else
						g_i3k_ui_mgr:PopupTipMessage("自己不能加自己为队友")
					end
				else
					g_i3k_ui_mgr:PopupTipMessage("申请已发送，请等待回复")
					local apply = i3k_sbean.team_apply_req.new()
					apply.teamId = value
					i3k_game_send_str_cmd(apply, i3k_sbean.team_apply_res.getName())
				end
			else
				g_i3k_ui_mgr:PopupTipMessage("您现在已有队伍")
			end
		end
	end
end

function wnd_chatBase:shareMasterCard(sender, masterId)
	local masterId = sender:getTag()
	i3k_sbean.master_card_sync(masterId, true)
end

function wnd_chatBase:searchPath(sender,tag,mapInfo)
	-----------------------------------------------
	local mapType = i3k_game_get_map_type()
	if mapType ~= g_FIELD then
   		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(746))
   		return
	end
	------------------------------------------------
	if tag == 1 then
		if mapInfo then
			g_i3k_game_context:findPathChangeLine(mapInfo.mapId, mapInfo.pos, mapInfo.mapLine)
		end
	end
end

function wnd_chatBase:playVoice(sender, voiceInfo)
	if not self._currSender then
		self._currSender = sender
		self:startPlayRecord(voiceInfo)
	elseif self._currSender == sender then
		g_i3k_game_handler:StopPlayVoiceRecord()
	else
		self._OtherVInfo = voiceInfo
		self._currSender = sender
		self:startPlayRecord(voiceInfo)
	end
end

function wnd_chatBase:startPlayRecord(voiceInfo)
	if voiceInfo.url then
		if not self._OtherVInfo then
			self.voiceInfo = voiceInfo
		end
		g_i3k_game_handler:PlayVoiceRecord(voiceInfo.url)

		if voiceInfo.msgui then
			voiceInfo.msgui:setText("已读")
			local msg = voiceInfo.msg
			msg.isRead = true
			if (msg.type == global_recent or msg.type == global_cross) and msg.msgContent then
				msg.msgContent.isRead = true
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("参数错误")
	end
end

function wnd_chatBase:playVoiceAnis()
	i3k_game_set_voice_state(g_VOICE_PLAYING_VOICE_MSG)
	anis_is_play = true
	local info = nil
	if self._OtherVInfo then
		info = self._OtherVInfo
	elseif self.voiceInfo then
		info = self.voiceInfo
	end

	if info then
		info.anim:hide()
		info.anis.play()
	end
end

function wnd_chatBase:finishPlay()
	if not anis_is_play then
		return
	end
	if not self._OtherVInfo then
		i3k_game_cancel_voice_state(g_VOICE_PLAYING_VOICE_MSG)
		self._currSender = nil
	end

	if self.voiceInfo then
		local info = self.voiceInfo
		info.anis.stop()
		info.anim:show()
		self.voiceInfo = nil
	end

	if self._OtherVInfo then
		self.voiceInfo = self._OtherVInfo
		self._OtherVInfo = nil
	end
end

function wnd_chatBase:stopFinishPlay()
	anis_is_play = false
	self.voiceInfo = nil
	self._OtherVInfo = nil
	self._currSender = nil
	i3k_game_cancel_voice_state(g_VOICE_RECORDING_VOICE_MSG)
end

function wnd_chatBase:openBossUI(sender)
	local maptype = i3k_game_get_map_type()
	if maptype == g_FIELD then
		g_i3k_logic:OpenWorldBossUI(true)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_UntilBossUI)
	end
end

function wnd_chatBase:SetVipIcon(node,messageId,vipLvl)
	vipLvl = vipLvl or 0
	local roleId = g_i3k_game_context:GetRoleId()
	if messageId < 0 or messageId == roleId then
		vipLvl = g_i3k_game_context:GetVipLevel()
	end

	local iconPath = i3k_db_kungfu_vip[vipLvl].vipIconId
	if iconPath > 0 then
		node.vars.vipIcon:setImage(g_i3k_db.i3k_db_get_icon_path(iconPath))
	end
end

function wnd_chatBase:setBgImage(node, messageId,vipLvl, boxId)
	vipLvl = vipLvl or 0
	boxId = boxId or 0
	local roleId = g_i3k_game_context:GetRoleId()
	local cfg

	if messageId < 0 or messageId == roleId then
		vipLvl = g_i3k_game_context:GetVipLevel()
		boxId = g_i3k_game_context:getChatBubbleCurrId()
	end

	if boxId > 0 then
		cfg = i3k_db_chatBubble[boxId]
		node.vars.bg_img:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconId))
		local upImg = 0
		local downImg = 0
		if messageId < 0 or messageId == roleId then
			upImg = cfg.upRotate > 0 and cfg.upRotate or cfg.upImg
			downImg = cfg.downRotate > 0 and cfg.downRotate or cfg.downImg
		else
			upImg = cfg.upImg
			downImg = cfg.downImg
		end
		if node.vars.upImg then
			if upImg > 0 then
				node.vars.upImg:show():setImage(g_i3k_db.i3k_db_get_icon_path(upImg))
			end
			if downImg > 0 then
				node.vars.downImg:show():setImage(g_i3k_db.i3k_db_get_icon_path(downImg))
			end
		end
	else
		local bgIconPath = i3k_db_kungfu_vip[vipLvl].vipBgIcon
		if bgIconPath > 0 then
			node.vars.bg_img:setImage(g_i3k_db.i3k_db_get_icon_path(bgIconPath))
		end
	end
end

function wnd_chatBase:SetVipIconWhenBattleBase(node,messageId,vipLvl)
	local iconPath
	if not vipLvl then
		return
	else
		iconPath = i3k_db_kungfu_vip[vipLvl].vipIconId
	end
	if iconPath > 0 then
		node.vars.vipIcon:setImage(g_i3k_db.i3k_db_get_icon_path(iconPath))
		node.vars.fromName:setPositionX(node.vars.fromName:getPositionX() + 30)
	end
end

--截取中英混合的UTF8字符串，endIndex可缺省
function wnd_chatBase:SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = self:SubStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = self:SubStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then
        return string.sub(str, self:SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, self:SubStringGetTrueIndex(str, startIndex), self:SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

--获取中英混合UTF8字符串的真实字符数量
function wnd_chatBase:SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat
        lastCount = self:SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

function wnd_chatBase:SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat
        lastCount = self:SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end

--返回当前字符实际占用的字符数
function wnd_chatBase:SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<223 then
        byteCount = 2
    elseif curByte>=224 and curByte<239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

function wnd_chatBase:SetPlayerName(node,message,chattime)
	if message.type == 6 then
		local serviceText = message.gsName
		local playerName = message.fromName
		-- serviceText = self:SubStringUTF8(serviceText, 5)
		local index = string.find(serviceText, "_") or 0
		serviceText = string.sub(serviceText, index+1)
		playerName = "["..serviceText.."]"..playerName
		node.vars.fromName:setText(playerName)
	else
		local playerName = message.fromName
		if message.fromId < 0 then
			playerName = g_i3k_game_context:GetRoleName()
		end
		node.vars.fromName:setText(playerName)
	end
	if chattime then
		node.vars.chattime:setText(g_i3k_logic:GetTime(message.time,true))
	end
end

function wnd_chatBase:joinDungeonRoom(sender,tag,args)
	if not args.mapId or not args.roomId then
		return
	end

	if args.rmtype == gRoom_NPC_MAP then
		g_i3k_game_context:enterNpcDungeonRoom(args.mapId, args.roomId)
		return
	end

	if args.rmtype == gRoom_TOWER_DEFENCE then
		g_i3k_game_context:enterDefenceDungeonRoom(args.mapId, args.roomId)
		return
	end
	if args.rmtype == gRoom_Competition then
		if i3k_check_resources_downloaded(args.mapId) then
			i3k_sbean.competition_sync_room(args.roomId)
		end
		return
	end
	if args.mapId == 0 then
		g_i3k_game_context:enterRightHeartRoom(args.mapId, args.roomId)
		return
	end

	g_i3k_game_context:MroomEnterReq(args.mapId, args.roomId)
end

function wnd_chatBase:gotoStelePos(sender, tag, args)
	local needId = i3k_db_common.activity.transNeedItemId
	if g_i3k_game_context:CheckCanTrans(needId, 1) then
		g_i3k_game_context:TransportCallBack(args.steleType, args.index, 4)
	else
		local cfg = i3k_db_steleAct.stale[args.steleType][args.index]
		g_i3k_game_context:SeachPathWithMap(cfg.mapId, cfg.pos)
	end
end

function wnd_chatBase:joinSect(sender, tag, args)
	if g_i3k_game_context:GetFactionSectId() > 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3049))
	end
	local data = i3k_sbean.sect_apply_req.new()
	data.sectId = args
	i3k_game_send_str_cmd(data,i3k_sbean.sect_apply_res.getName())
end

function wnd_chatBase:openRecruit(sender, args)
	i3k_sbean.sect_msg_info(args)
end

function wnd_chatBase:tripWizardPhoto(sender, tag, wizardTripPhoto)
	if wizardTripPhoto and wizardTripPhoto.photoID then
		if not g_i3k_ui_mgr:GetUI(eUIID_TripWizardPhotoShow) then
			g_i3k_ui_mgr:OpenUI(eUIID_TripWizardPhotoShow)
			g_i3k_ui_mgr:RefreshUI(eUIID_TripWizardPhotoShow, g_Share, wizardTripPhoto.photoID, wizardTripPhoto.sendRoleName)
		end
	end
end

function wnd_chatBase:worldBless(sender,tag,  message)
	local fromName = message.fromName
	local toName = message.roleName
	local msg = message.msgBless
	local refFestivalBless = message.refFestivalBless
	local info = {fromName = fromName, toName = toName,  msg = msg, refFestivalBless = refFestivalBless}
	g_i3k_ui_mgr:OpenUI(eUIID_ShowLoveWish)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShowLoveWish, info)
end

function wnd_chatBase:gotoWoodMan(sender, tag, monsterId)
	local func1 = function(ok)
		if ok then
			g_i3k_game_context:GotoMonsterPos(monsterId)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(969, g_i3k_db.i3k_db_get_monster_name(monsterId)), func1)
end

function wnd_chatBase:lookMarriageCard(sender, tag, marriageId)
	i3k_sbean.marriage_card_syncReq(marriageId)
end

function wnd_chatBase:gotoGarrisonBoss(sender, bossId)
	local mapType = i3k_game_get_map_type()
	if mapType and mapType == g_FACTION_GARRISON then
		g_i3k_game_context:SeachPathWithMap(i3k_db_faction_garrison.openCondition.dungeonId, i3k_db_faction_garrsion_boss[bossId].position)
	end
end

function wnd_chatBase:openMoodDiary(sender, message)
	if message.fromId == g_i3k_game_context:GetRoleId() then
		i3k_sbean.mood_diary_open_main_page(1)
	else
		i3k_sbean.mood_diary_open_main_page(2, message.fromId)
	end
end

function wnd_chatBase:onCardPacket(sender, info)
	local cardID = info.cardID
	local cardBackID = info.cardBackID
	g_i3k_logic:OpenCardPacketShare(cardID, cardBackID)
end


function wnd_chatBase:openConstellationTestResult(sender, message)
	g_i3k_ui_mgr:OpenUI(eUIID_ConstellationTestResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_ConstellationTestResult, message.refConstellationTest.testScore, message.refConstellationTest.gender, message.refConstellationTest.groupID, message.fromName, true)
end

-------------------------------Chatitem-------------------------
function wnd_chatBase:onRefreshChatLog()
	local chatScroll = self.chatLog
	chatScroll:removeAllChildren()
	local contentSize = chatScroll:getContentSize()
	chatScroll:setContainerSize(contentSize.width, contentSize.height)
	local chatData = g_i3k_game_context:GetChatData()--获取数据
	for i,v in chatData[2]:ipairs() do
		self:createBattleBaseChatItem(v)
	end
end

function wnd_chatBase:receiveNewMsg(message)
	self:createBattleBaseChatItem(message)
end

function wnd_chatBase:createBattleBaseChatItem(message)
	if self.chatLog:getChildrenCount() >=  g_Battle_Base_Chat_Count then
		self.chatLog:removeChildAtIndex(1)
	end
	self:createChatItem(message, self.chatLog)
	self.lastChatType = message.type
end
-----------------chatItems ----------------------------------

function wnd_create(layout)
	local wnd = wnd_chatBase.new();
		wnd:create(layout);

	return wnd;
end

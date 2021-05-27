ChatCtrl = ChatCtrl or BaseClass(BaseController)

function ChatCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCChannelChatAck, "OnChannelChat")
	self:RegisterProtocol(SCSystemTipsMsg, "OnSystemMsg")
	self:RegisterProtocol(SCPrivateChat, "OnPrivateChat")
	self:RegisterProtocol(SCSurplusHornCount, "OnSurplusHornCount")
    self:RegisterProtocol(SCCleanUpChat, "OnCleanUpChat")
end

-- 频道消息处理
function ChatCtrl:OnChannelChat(protocol)
	local msg_info = ChatData.CreateMsgInfo()
	msg_info.role_id = protocol.role_id
	msg_info.channel_type = protocol.channel_type
	msg_info.name = protocol.name
	msg_info.content = protocol.content
	msg_info.sex = protocol.sex
	msg_info.flag = protocol.flag
	msg_info.zhuansheng = protocol.zhuansheng
	msg_info.fengshen_lv = protocol.fengshen_lv
	msg_info.sbk_occupation = protocol.sbk_occupation
	msg_info.identifying_code = protocol.identifying_code
	msg_info.camp_id = protocol.camp_id
	msg_info.vip = protocol.vip
	msg_info.camp_occupation = protocol.camp_occupation
	msg_info.content_type = protocol.content_type

    if msg_info.channel_type ~= CHANNEL_TYPE.SYSTEM then
		msg_info.content = ChatFilter.Instance:Filter(msg_info.content)
	end
	self.data:AddChannelMsg(msg_info)
	if not self.view:IsOpen() and protocol.channel_type == CHANNEL_TYPE.TEAM then
		GlobalEventSystem:Fire(MainUIEventType.CHAT_REMIND_CHANGE, ChatViewIndex.Team, true)
	end
	if msg_info.channel_type == CHANNEL_TYPE.SPEAKER then
		self.view:Flush(0, "speaker")
		MainuiCtrl.Instance:OpenHorn(msg_info)
	else
		if msg_info.name == RoleData.Instance:GetAttr("name") then
			self.view:Flush()
		else
			self.view:Flush(0, "add_chat", {[msg_info.channel_type] = msg_info.channel_type})
		end
	end

	GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
end

-- 系统消息
function ChatCtrl:OnSystemMsg(protocol)
	local type_t = ChatData.FormattingMsgType(protocol.tips_type)
	local msg_info = ChatData.CreateMsgInfo()
	msg_info.channel_type = CHANNEL_TYPE.SYSTEM
	msg_info.tips_type = protocol.tips_type
	msg_info.content = protocol.content
	msg_info.content_type = protocol.content_type
	for k,v in pairs(type_t) do
		if v == tagTipmsgType.ttTipmsgWindow then
			SystemHint.Instance:FloatingLabel(msg_info.content)
			-- Log("服务端提示：", msg_info.content)
		elseif v == tagTipmsgType.ttFlyTip then
			SystemHint.Instance:FloatingTopRightText(protocol.content)
			-- Log("服务端提示：", msg_info.content)
		elseif v == tagTipmsgType.ttChatWindow then
			self.data:AddChannelMsg(msg_info)
			self.view:Flush()
			GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
		elseif v == tagTipmsgType.ttScreenCenter then
			SysMsgCtrl.Instance:RollingEffect(protocol.content, GUNDONGYOUXIAN.HEARSAY_TYPE)
		elseif v == tagTipmsgType.ttAboveChatWindow then
--			SysMsgCtrl.Instance:AboveChatWindowRollingEffect(protocol.content, GUNDONGYOUXIAN.HEARSAY_TYPE)
			SysMsgCtrl.Instance:textEffect("bossOpen")
		elseif v == tagTipmsgType.ttMessage then
			self.data:AddChannelMsg(msg_info)
			self.view:Flush()
			GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
		else
			self.data:AddChannelMsg(msg_info)
			self.view:Flush()
			GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
		end
	end
end

function ChatCtrl:OnPrivateChat(protocol)
	local msg_info = ChatData.CreateMsgInfo()
	msg_info.role_id = protocol.role_id
	msg_info.channel_type = CHANNEL_TYPE.PRIVATE
	msg_info.name = protocol.name
	msg_info.content = protocol.content
	msg_info.sex = protocol.sex
	msg_info.flag = protocol.flag
	msg_info.zhuansheng = protocol.zhuansheng
	msg_info.fengshen_lv = protocol.fengshen_lv
	msg_info.vip = protocol.vip
	msg_info.identifying_code = protocol.identifying_code
	msg_info.content_type = protocol.content_type

	msg_info.content = ChatFilter.Instance:Filter(msg_info.content)


	self.data:AddChannelMsg(msg_info)
	if not self.view:IsOpen() then
		GlobalEventSystem:Fire(MainUIEventType.CHAT_REMIND_CHANGE, ChatViewIndex.Private, true)
	end
	if msg_info.name == RoleData.Instance:GetAttr("name") then
		self.view:Flush()
	else
		self.view:Flush(0, "add_chat", {[CHANNEL_TYPE.PRIVATE] = CHANNEL_TYPE.PRIVATE})
	end

	GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
end

function ChatCtrl:OnSurplusHornCount(protocol)
	self.data:SetSurplusHorn(protocol.count)
	self.view:Flush(0, "horn_count")
end

-- end

function ChatCtrl:SendChannelChat(type, content, content_type)
	local is_can_chat, reason_txt = ChatData.Instance:IsCanChat() 
	if not is_can_chat then
		SysMsgCtrl.Instance:ErrorRemind(reason_txt)
		return
	end

	if "" == content then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		return
	end
    if cc.PLATFORM_OS_WINDOWS ~= PLATFORM then
        --新加的一些聊天限制
        --时间间隔
    --    if "1" == self.data:GetChatLimitData("ten_second") then
    --        if nil ~= self.last_time then
    --            local diff = os.time() - self.last_time
    --            if diff < 10 then
    --		        SysMsgCtrl.Instance:ErrorRemind(Language.Chat.TimeLimit)
    --		        return
    --            end
    --	    end
    --    end
        --内容重复
        if "1" == self.data:GetChatLimitData("continuous") then
            if nil ~= self.last_content then
                if content == self.last_content then
		            SysMsgCtrl.Instance:ErrorRemind(Language.Chat.DuplicateContent)
		            return
                end
	        end
        end
        --屏蔽词
        if "1" == self.data:GetChatLimitData("block_word") then
            if ChatFilter.Instance:IsIllegal(content, false) then 
                SysMsgCtrl.Instance:ErrorRemind(Language.Chat.Filter)
                return
            end
        end
        --vip level limit
        local new_server = self.data:GetChatLimitData("new_server")
        if new_server ~= nil then
	        local vip_level = tonumber(new_server.vip)
	        local role_level = tonumber(new_server.level)
	        if (role_level ~= nil and RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < role_level) then
	            local errMsg = string.format(Language.Chat.LevelLimit, role_level)
	            SysMsgCtrl.Instance:ErrorRemind(errMsg)
	        elseif (vip_level ~= nil and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE) < vip_level) then
	            local errMsg = string.format(Language.Chat.VipLimit, vip_level)
	            SysMsgCtrl.Instance:ErrorRemind(errMsg)
	            return
	        end
	    end
    --    if "1" == self.data:GetChatLimitData("ten_second") then
    --        self.last_time = os.time()
    --    end
        if "1" == self.data:GetChatLimitData("continuous") then
            self.last_content = content
        end
    end

    local chat_type = ChatData.UploadChannelType(type);
	local role_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) or 0
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_name = RoleData.Instance:GetAttr("name")
	--聊天上报
	if MainProber.Step2 then
		
		MainProber:Step2(20100, AgentAdapter:GetPlatName() or MainProber.user_id, MainProber.server_id, MainProber.role_name, MainProber.role_id, role_level, role_money, chat_type, mime.b64(content))
		if AgentMs.ReportChatAndMailMsgToYooXun then
			AgentMs:ReportChatAndMailMsgToYooXun(0, mime.unb64(MainProber.role_name), "", MainProber.server_id, chat_type, content, 1)
		end
		if AgentMs.ReportChatMsgToShiPo then
			AgentMs:ReportChatMsgToShiPo(MainProber.server_id, role_name, MainProber.role_id, role_level, role_money, chat_type, content, "")
		end
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSChatReq)
	protocol.channel_type = type
	protocol.content = content
	protocol.content_type = content_type or CHAT_CONTENT_TYPE.TEXT
	protocol:EncodeAndSend()

	-- GlobalEventSystem:Fire(OtherEventType.SEND_CHAT_DATA, {channel_type = type, content = content, target_role_id = target_role_id, target_name = target_name, content_type = content_type})

	--聊天推送
	local viplv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	if nil ~= GLOBAL_CONFIG.param_list.chat_report_url and "" ~=  GLOBAL_CONFIG.param_list.chat_report_url then
		AgentMs:PushChatMsg(MainProber.server_id, MainProber.role_id, role_name, role_level, role_money, chat_type, content, nil, viplv, nil, nil)
	end
end

function ChatCtrl:AddMyPrivate(target_name, content, content_type)
	local msg_info = ChatData.CreateMsgInfo()
	msg_info.channel_type = CHANNEL_TYPE.PRIVATE
	msg_info.name = RoleData.Instance:GetAttr("name")
	msg_info.to_name = target_name
	msg_info.content = content
	msg_info.sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	msg_info.flag = 0
	msg_info.zhuansheng = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	msg_info.fengshen_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_APOTHEOSIZE_LEVEL)
	msg_info.identifying_code = 0
	msg_info.content_type = content_type

	msg_info.content = ChatFilter.Instance:Filter(msg_info.content)

	self.data:AddChannelMsg(msg_info)
	self.view:Flush()

	GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)

end
function ChatCtrl:SendSingleChat(target_role_id, target_name, content, content_type)
	local is_can_chat, reason_txt = ChatData.Instance:IsCanChat() 
	if not is_can_chat then
		SysMsgCtrl.Instance:ErrorRemind(reason_txt)
		return
	end
	
	if MainProber.Step2 then
		if AgentMs.ReportChatAndMailMsgToYooXun then
			AgentMs:ReportChatAndMailMsgToYooXun(target_role_id, mime.unb64(MainProber.role_name), target_name, MainProber.server_id, 5, content, 1)
		end
	end
	local role_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_name = RoleData.Instance:GetAttr("name")
	local viplv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	local to_role_level = SocietyData.Instance:GetFriendLevelByName(target_name)
	if AgentMs.ReportChatMsgToShiPo then
		AgentMs:ReportChatMsgToShiPo(MainProber.server_id, role_name, MainProber.role_id, role_level, role_money, 5, content, target_role_id, target_name)
	end

	if nil ~= GLOBAL_CONFIG.param_list.chat_report_url and "" ~=  GLOBAL_CONFIG.param_list.chat_report_url then
		if target_role_id ~= -1 then
			AgentMs:PushChatMsg(MainProber.server_id, MainProber.role_id, role_name, role_level, role_money, 5, content, target_role_id, viplv, target_name, to_role_level)
		end
	end


	self:AddMyPrivate(target_name, content, content_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPrivateChatReq)
	protocol.target_name = target_name
	protocol.content = content
	protocol.content_type = content_type
	protocol:EncodeAndSend()

	-- GlobalEventSystem:Fire(OtherEventType.SEND_CHAT_DATA, {channel_type = CHANNEL_TYPE.PRIVATE, content = content, target_role_id = target_role_id, target_name = target_name, content_type = content_type})
end

function ChatCtrl:SendCurrentTransmit(is_auto_buy, speaker_msg, content_type, speaker_type)
	-- local protocol = ProtocolPool.Instance:GetProtocol(CSSpeaker)
	-- protocol.is_auto_buy = is_auto_buy
	-- protocol.content_type = content_type or 0
	-- protocol.speaker_msg = speaker_msg
	-- protocol.speaker_type = speaker_type or 0
	-- protocol:EncodeAndSend()
end

function ChatCtrl.SendHelpTranReq(role_handle, scene_id, pos_x, pos_y)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendHelpTranReq)
	protocol.role_handle = role_handle
	protocol.scene_id = scene_id
	protocol.pos_x = pos_x
	protocol.pos_y = pos_y
	protocol:EncodeAndSend()
end

function ChatCtrl:OnCleanUpChat(protocol)
    local channel_id = protocol.channel_id
    self.data:RemoveChannelMsg(channel_id)
	self.view:Flush()
    GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, channel_id)
end
require("scripts/game/chat/chat_data")
require("scripts/game/chat/chat_view")
require("scripts/game/chat/chat_record_view")
require("scripts/game/chat/chat_record_mgr")
require("scripts/game/chat/chat_protocol")
require("scripts/game/chat/chat_transmit")
require("scripts/game/chat/chat_filter")
require("scripts/game/chat/chat_msg_input")
require("scripts/game/chat/blacklist_view")
require("scripts/game/chat/add_blacklist_view")
-- require("scripts/game/chat/chat_channel_select")

ChatCtrl = ChatCtrl or BaseClass(BaseController)

function ChatCtrl:__init()
	if ChatCtrl.Instance then
		ErrorLog("[ChatCtrl]:Attempt to create singleton twice!")
	end
	ChatCtrl.Instance = self

	self.chatFilter = ChatFilter.New()
	self.data = ChatData.New()
	self.record_mgr = ChatRecordMgr.New()
	self.view = ChatView.New(ViewDef.Chat)
	self.face_view = ChatFaceView.New()				-- 表情
	self.item_view = ChatItemView.New()				-- 物品

	ViewManager.Instance:RegisterView(self.view, ViewDef.Chat.Synthesize)
	ViewManager.Instance:RegisterView(self.view, ViewDef.Chat.Nearby)
	ViewManager.Instance:RegisterView(self.view, ViewDef.Chat.World)
	ViewManager.Instance:RegisterView(self.view, ViewDef.Chat.Guild)
	ViewManager.Instance:RegisterView(self.view, ViewDef.Chat.Troops)
	ViewManager.Instance:RegisterView(self.view, ViewDef.Chat.PrivateChat)
	self:RegisterAllProtocols()
end

function ChatCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.face_view:DeleteMe()
	self.face_view = nil

	self.item_view:DeleteMe()
	self.item_view = nil

	if self.alert_system_dialog then
		self.alert_system_dialog:DeleteMe()
		self.alert_system_dialog = nil
	end

	self.data:DeleteMe()
	self.data = nil
	self.chatFilter:DeleteMe()

	self.record_mgr:DeleteMe()
	self.record_mgr = nil

	self.tran_alert = nil

	ChatCtrl.Instance = nil
end

-- 添加私聊
function ChatCtrl:AddPrivateRequset(role_name, role_id)
	if role_name == "" or nil == role_name then
		return
	end
	role_id = role_id or 0

	-- 判断等级是否足够
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < CHANNEL_LV[CHANNEL_TYPE.PRIVATE] then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, CHANNEL_LV[CHANNEL_TYPE.PRIVATE]))
		return
	end

	local name = self.data:AddNearChatRole(role_name, role_id, CHANNEL_TYPE.PRIVATE, true)
    self.data.private_select_name = role_name
	ViewManager.Instance:OpenViewByDef(ViewDef.Chat.PrivateChat)
--    ViewManager.Instance:FlushViewByDef(ViewDef.Chat.PrivateChat, ChatViewIndex.Private, "select_role", {name = name or role_name})
	-- ViewManager.Instance:FlushView(ViewName.Chat, ChatViewIndex.Private, "add_private", {name = name or role_name})
end

function ChatCtrl:AddPrivateResponse(user_info)
	if nil == user_info then
		return
	end

	if not self:IsOwns(user_info.role_id) then
		if nil == self.data:GetPrivateObjByRoleId(user_info.role_id) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.CreatePrivateSucess)
		end
		local private_obj = ChatData.CreatePrivateObj()
		private_obj.role_id = user_info.role_id
		private_obj.username = user_info.role_name
		private_obj.sex = user_info.sex
		private_obj.camp = user_info.camp
		private_obj.prof = user_info.prof
		private_obj.avatar_key_small = user_info.avatar_key_small
		private_obj.level = user_info.level
		self.data:AddPrivateObj(private_obj.role_id, private_obj)
		self.view:OpenPrivate(ChatData.Instance:GetPrivateIndex(user_info.role_id))
	else
		Log("不能添加自己")
	end
end

function ChatCtrl:IsOwns(from_uid)
	return from_uid == GameVoManager.Instance:GetMainRoleVo().role_id
end

function ChatCtrl:Open(tab_index, param_t)
	self.view:Open(tab_index)

	if param_t ~= nil and param_t.sub_view_name == SubViewName.SmallLabaSend then --大喇叭
		self.view:Close()
		self.view:OpenLabaSendView(1)
	end

	if param_t ~= nil and param_t.sub_view_name == SubViewName.BigLabaSend then --小喇叭
		self.view:Close()
		self.view:OpenLabaSendView(0)
	end
end

function ChatCtrl:OpenTransmitPopView()
	self.view.transmit_pop_view:OpenTransmitPop(1)
end

function ChatCtrl:ClaerChannelContent(index)
	self.view:ClaerChannelContent(index)
end

function ChatCtrl:OpenBlacklistView()
	-- self.blacklist_view:Open()
end

function ChatCtrl:OpenAddBlacklistView()
	-- self.add_blacklist_view:Open()
end

-- 添加一条系统消息
function ChatCtrl:AddSystemMsg(content, time)
	if self.data:IsPingBiChannel(CHANNEL_TYPE.SYSTEM) then
		return
	end
	time = time or TimeCtrl.Instance:GetServerTime()
	local msg_info = ChatData.CreateMsgInfo()
	msg_info.channel_type = CHANNEL_TYPE.SYSTEM
	msg_info.content = content
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", time))

	self.data:AddChannelMsg(msg_info)
	self.view:RefreshChannel()
	GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
end

function ChatCtrl:OpenPrivate(index)
	self.view:OpenPrivate(index)
end

function ChatCtrl:IsPrivateOpen()
	return self.view:IsPrivateOpen()
end

function ChatCtrl:IsTransmitOpen()
	return self.view:IsTransmitOpen()
end

function ChatCtrl:OpenFace()
	self.face_view:Open()
end

function ChatCtrl:CloseFace()
	self.face_view:Close()
end

function ChatCtrl:OpenItem()
	self.item_view:Open()
end

function ChatCtrl:CloseItem()
	self.item_view:Close()
end

function ChatCtrl:GetMainRolePos()
	self.view:GetMainRolePos()
end

function ChatCtrl:GetEditTextByCurPanel()
	if self:IsTransmitOpen() then
		return self.view:GetTransmitInputEdit()
	else
		return self.view:GetInputEdit()
	end
end

function ChatCtrl:SendPrivateChatMsg(to_uid, to_name, text, content_type)
    if "1" == self.data:GetChatLimitData("private_chat") then
	    if not SocietyData.Instance:IsFriend(to_name) then
		    SysMsgCtrl.Instance:ErrorRemind(Language.Chat.CanNotPrivateChatNotFriend)
		    return
	    end
    end
	local len = string.len(text)
	if len <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		return
	end
	-- if len >= COMMON_CONSTS.MAX_CHAT_MSG_LEN then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Chat.ContentToLong)
	-- 	return
	-- end
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
                if text == self.last_content then
		            SysMsgCtrl.Instance:ErrorRemind(Language.Chat.DuplicateContent)
		            return
                end
	        end
        end
        --屏蔽词
        if "1" == self.data:GetChatLimitData("block_word") then
            if ChatFilter.Instance:IsIllegal(text, false) then 
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
            self.last_content = text
        end
    end

	if ChatData.ExamineEditText(text, 0) == false then return end
	-- 私聊聊天上报
	if MainProber.Step2 then
		local chat_type = ChatData.UploadChannelType(CHANNEL_TYPE.PRIVATE);
		local role_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) or 0
		local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local sent_name = mime.b64(to_name)
		MainProber:Step2(20100, AgentAdapter:GetPlatName() or MainProber.user_id, MainProber.server_id, MainProber.role_name, MainProber.role_id, role_level, role_money, chat_type, mime.b64(text), sent_name)
	end

	local to_role_id = SocietyData.Instance:GetFriendIdByName(to_name)
	self:SendSingleChat(to_role_id, to_name, text, content_type)
end

function ChatCtrl:GetRandomContent()
	local config = Config.chat_stranger_auto.chat
	local max_count = #config
	local random_num = math.random(1,max_count)
	local content = Language.Chat.DefaultRandomContent
	if config[random_num] then
		content = config[random_num].chat_item or Language.Chat.DefaultRandomContent
	end
	return content
end

function ChatCtrl:ClickHelpTran(role_handle, scene_id, pos_x, pos_y)
	self.tran_alert = self.tran_alert or Alert.New()
	self.tran_alert:SetLableString(Language.Chat.HelpTranTips)
	self.tran_alert:SetOkFunc(function()
		ChatCtrl.SendHelpTranReq(role_handle, scene_id, pos_x, pos_y)
	end)
	self.tran_alert:Open()
end
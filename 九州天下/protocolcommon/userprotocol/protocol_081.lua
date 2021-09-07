
-- 8100 频道聊天返回  --0：世界，1：阵营，2：场景，3：组队，4：仙盟
SCChannelChatAck = SCChannelChatAck or BaseClass(BaseProtocolStruct)

function SCChannelChatAck:__init()
	self.msg_type = 8100
end

function SCChannelChatAck:Decode()
	self.from_uid = MsgAdapter.ReadInt()								-- 角色uid
	self.from_origin_uid = MsgAdapter.ReadInt()							-- 角色在原服的uid
	self.username = MsgAdapter.ReadStrN(32)
	self.sex = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.authority_type = MsgAdapter.ReadChar()
	self.content_type = MsgAdapter.ReadChar()
	self.tuhaojin_color = MsgAdapter.ReadChar()							-- 土豪金颜色，0 表示未激活
	self.bigchatface_status = MsgAdapter.ReadChar()						-- 聊天大表情，0 表示未激活
	self.personalize_window_bubble_type = MsgAdapter.ReadChar()			-- 气泡框，0 表示未激活
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()

	self.personalize_window_avatar_type = MsgAdapter.ReadChar()			-- 头像框，0表示未激活
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()

	self.level = MsgAdapter.ReadShort()
	self.vip_level = MsgAdapter.ReadChar()
	self.channel_type = MsgAdapter.ReadChar()
	self.msg_timestamp = MsgAdapter.ReadUInt()
	self.from_type = MsgAdapter.ReadInt()
	self.msg_length = MsgAdapter.ReadUInt()
	self.content = MsgAdapter.ReadStrN(self.msg_length)
end

--8101  私人聊天返回
SCSingleChatAck = SCSingleChatAck or BaseClass(BaseProtocolStruct)

function SCSingleChatAck:__init()
	self.msg_type = 8101
end

function SCSingleChatAck:Decode()
	self.from_uid = MsgAdapter.ReadInt()
	self.username = MsgAdapter.ReadStrN(32)
	self.guildname = MsgAdapter.ReadStrN(32)
	self.sex = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	self.vip_level = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.authority_type = MsgAdapter.ReadChar()
	self.content_type = MsgAdapter.ReadChar()
	self.level = MsgAdapter.ReadShort()
	self.tuhaojin_color = MsgAdapter.ReadChar()								-- 土豪金颜色，0 表示未激活
	self.bigchatface_status = MsgAdapter.ReadChar()							-- 聊天大表情，0 表示未激活
	self.personalize_window_bubble_type = MsgAdapter.ReadChar()				-- 气泡框，0 表示未激活
	self.personalize_window_avatar_type = MsgAdapter.ReadChar()				-- 头像框，0 表示未激活
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()
	self.msg_timestamp = MsgAdapter.ReadUInt()
	self.msg_length = MsgAdapter.ReadUInt()
	self.content = MsgAdapter.ReadStrN(self.msg_length)
end

--8102  通知私聊对象不在线
SCSingleChatUserNotExist = SCSingleChatUserNotExist or BaseClass(BaseProtocolStruct)

function SCSingleChatUserNotExist:__init()
	self.msg_type = 8102
end

function SCSingleChatUserNotExist:Decode()
	self.to_uid = MsgAdapter.ReadInt()
end

-- 获取等级限制
SCOpenLevelLimit = SCOpenLevelLimit or BaseClass(BaseProtocolStruct)

function SCOpenLevelLimit:__init()
	self.msg_type = 8103
	self.ignore_level_limit = 0
	self.open_level = {}
end

function SCOpenLevelLimit:Decode()
	self.ignore_level_limit = MsgAdapter.ReadInt()
	self.open_level = {}
	for i = 0, CHAT_OPENLEVEL_LIMIT_TYPE.MAX - 1 do
		self.open_level[i] = MsgAdapter.ReadInt()
	end
end


--8150  请求频道聊天
CSChannelChatReq = CSChannelChatReq or BaseClass(BaseProtocolStruct)

function CSChannelChatReq:__init()
	self.msg_type = 8150

	self.content_type = 0
	self.channel_type = 0
	self.from_type = 0
	self.content = ""
end

function CSChannelChatReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.content_type)
	MsgAdapter.WriteChar(self.from_type)
	MsgAdapter.WriteShort(self.channel_type)
	MsgAdapter.WriteStr(self.content)
end

--8151  请求私人聊天
CSSingleChatReq = CSSingleChatReq or BaseClass(BaseProtocolStruct)

function CSSingleChatReq:__init()
	self.msg_type = 8151

	self.content_type = 0
	self.to_uid = 0;
	self.content = "";
end

function CSSingleChatReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.content_type)
	MsgAdapter.WriteChar(0)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.to_uid)
	MsgAdapter.WriteStr(self.content)
end
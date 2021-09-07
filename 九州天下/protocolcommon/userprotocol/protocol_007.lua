-- 服务器返回错误信息
SCNoticeNumAck = SCNoticeNumAck or BaseClass(BaseProtocolStruct)
function SCNoticeNumAck:__init()
	self.msg_type = 700
	self.result = 0
end

function SCNoticeNumAck:Decode()
	self.result = MsgAdapter.ReadInt()
end

--服务器小喇叭返回
SCSpeaker = SCSpeaker or BaseClass(BaseProtocolStruct)
function SCSpeaker:__init()
	self.msg_type = 703
end

function SCSpeaker:Decode()
	self.from_uid = MsgAdapter.ReadInt()
	self.username = MsgAdapter.ReadStrN(32)
	self.sex = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	self.content_type = MsgAdapter.ReadChar()
	self.camp_post = MsgAdapter.ReadChar()
	self.guild_post = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.authourity_type = MsgAdapter.ReadChar()
	self.vip_level = MsgAdapter.ReadChar()
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()
	self.plat_name = MsgAdapter.ReadStrN(64)
	self.server_id = MsgAdapter.ReadInt()
	self.speaker_type = MsgAdapter.ReadChar()
	self.tuhaojin_color = MsgAdapter.ReadChar()			-- 土豪金颜色，0 表示未激活
	self.bigchatface_status = MsgAdapter.ReadShort()	-- 聊天大表情，0 表示未激活
	self.personalize_window_type = MsgAdapter.ReadChar()
	self.personalize_window_bubble_type = MsgAdapter.ReadChar()
	self.personalize_window_avatar_type = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()

	self.speaker_msg_length = MsgAdapter.ReadUInt()
	self.speaker_msg = MsgAdapter.ReadStrN(self.speaker_msg_length)
end

--系统消息传闻等
SCSystemMsg = SCSystemMsg or BaseClass(BaseProtocolStruct)
function SCSystemMsg:__init()
	self.msg_type = 701
end

function SCSystemMsg:Decode()
	self.send_time = MsgAdapter.ReadUInt()
	self.msg_type = MsgAdapter.ReadShort()
	self.msg_length = MsgAdapter.ReadShort()
	self.display_pos = MsgAdapter.ReadInt()
	self.color = MsgAdapter.ReadInt()
	self.content = MsgAdapter.ReadStrN(self.msg_length)
end

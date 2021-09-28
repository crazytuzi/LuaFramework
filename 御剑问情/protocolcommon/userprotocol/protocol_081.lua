
-- 8100 频道聊天返回  --0：世界，1：阵营，2：场景，3：组队，4：仙盟
SCChannelChatAck = SCChannelChatAck or BaseClass(BaseProtocolStruct)

function SCChannelChatAck:__init()
    self.msg_type = 8100
end

function SCChannelChatAck:Decode()
    self.from_uid = MsgAdapter.ReadInt()
    self.username = MsgAdapter.ReadStrN(32)
    self.sex = MsgAdapter.ReadChar()
    self.camp = MsgAdapter.ReadChar()
    self.prof = MsgAdapter.ReadChar()
    self.authority_type = MsgAdapter.ReadChar()
    self.content_type = MsgAdapter.ReadChar()
    self.tuhaojin_color = MsgAdapter.ReadChar()                     -- 土豪金颜色，0 表示未激活
    self.bigchatface_status = MsgAdapter.ReadChar()                 -- 聊天大表情，0 表示未激活
    self.personalize_window_bubble_type = MsgAdapter.ReadChar()     -- 气泡框，0 表示未激活
    self.avatar_key_big = MsgAdapter.ReadUInt()
    self.avatar_key_small = MsgAdapter.ReadUInt()
    self.role_id = MsgAdapter.ReadUInt()
    self.plat_id = MsgAdapter.ReadUInt()
    self.uuid = self.role_id + (self.plat_id * (2 ^ 32))
    self.level = MsgAdapter.ReadShort()
    self.vip_level = MsgAdapter.ReadChar()
    self.channel_type = MsgAdapter.ReadChar()

    self.guild_signin_count = MsgAdapter.ReadShort()
    self.is_msg_record = MsgAdapter.ReadChar()
    self.use_head_frame = MsgAdapter.ReadChar()

    self.msg_timestamp = MsgAdapter.ReadUInt()
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
    self.role_id = MsgAdapter.ReadUInt()
    self.plat_id = MsgAdapter.ReadUInt()
    self.uuid = self.role_id + (self.plat_id * (2 ^ 32))
    self.username = MsgAdapter.ReadStrN(32)
    self.sex = MsgAdapter.ReadChar()
    self.camp = MsgAdapter.ReadChar()
    self.vip_level = MsgAdapter.ReadChar()
    self.prof = MsgAdapter.ReadChar()
    self.authority_type = MsgAdapter.ReadChar()
    self.content_type = MsgAdapter.ReadChar()
    self.level = MsgAdapter.ReadShort()
    self.tuhaojin_color = MsgAdapter.ReadChar()                     -- 土豪金颜色，0 表示未激活
    self.bigchatface_status = MsgAdapter.ReadChar()                 -- 聊天大表情，0 表示未激活
    self.personalize_window_bubble_type = MsgAdapter.ReadChar()     -- 气泡框，0 表示未激活
    self.use_head_frame = MsgAdapter.ReadChar()
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

--8103  聊天限制条件
SCOpenLevelLimit = SCOpenLevelLimit or BaseClass(BaseProtocolStruct)

function SCOpenLevelLimit:__init()
    self.msg_type = 8103
    self.ignore_level_limit = 0
    self.is_forbid_audio_chat = 0

    -- 聊天限制条件类型 CHAT_LIMIT_CONDITION_TYPE_AND=0:同时满足角色等级和vip等级，
    -- CHAT_LIMIT_CONDITION_TYPE_OR=1:满足其中一个条件
    self.chat_limit_condition_type = 0
    self.open_level = {}
    self.vip_level_list = {}
end

function SCOpenLevelLimit:Decode()
    self.ignore_level_limit = MsgAdapter.ReadInt()
    self.is_forbid_audio_chat = MsgAdapter.ReadShort()
    self.is_forbid_change_avatar = MsgAdapter.ReadShort()
    self.chat_limit_condition_type = MsgAdapter.ReadInt()
    self.open_level = {}
    for i = 0, CHAT_OPENLEVEL_LIMIT_TYPE.MAX - 1 do
        self.open_level[i] = MsgAdapter.ReadInt()
    end

    for i = 0, CHAT_OPENLEVEL_LIMIT_TYPE.MAX - 1 do
        self.vip_level_list[i] = MsgAdapter.ReadShort()
    end
end

--8104  通知有玩家被封禁
SCForbidChatInfo = SCForbidChatInfo or BaseClass(BaseProtocolStruct)
function SCForbidChatInfo:__init()
    self.msg_type = 8104
end

function SCForbidChatInfo:Decode()
    local forbid_uid_count = MsgAdapter.ReadInt()

    self.forbid_uid_list = {}
    for i = 1, forbid_uid_count do
        table.insert(self.forbid_uid_list, MsgAdapter.ReadInt())
    end
end

-- 个人禁言信息
SCForbidUserInfo = SCForbidUserInfo or BaseClass(BaseProtocolStruct)
function SCForbidUserInfo:__init()
    self.msg_type = 8105
end

function SCForbidUserInfo:Decode()
   self.forbid_talk_end_timestamp = MsgAdapter.ReadUInt()
end

--8150  请求频道聊天
CSChannelChatReq = CSChannelChatReq or BaseClass(BaseProtocolStruct)

function CSChannelChatReq:__init()
    self.msg_type = 8150

    self.content_type = 0
    self.channel_type = 0
    self.content = ""
end

function CSChannelChatReq:Encode()
    MsgAdapter.WriteBegin(self.msg_type)
    MsgAdapter.WriteChar(self.content_type)
    MsgAdapter.WriteChar(0)
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

--8152  请求封禁列表
CSForbidChatInfo = CSForbidChatInfo or BaseClass(BaseProtocolStruct)

function CSForbidChatInfo:__init()
    self.msg_type = 8152
end

function CSForbidChatInfo:Encode()
    MsgAdapter.WriteBegin(self.msg_type)
end
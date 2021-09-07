
-- 随机在线玩家列表
SCRandomRoleListRet = SCRandomRoleListRet or BaseClass(BaseProtocolStruct)
function SCRandomRoleListRet:__init()
	self.msg_type = 9302
end

function SCRandomRoleListRet:Decode()
	self.count = MsgAdapter.ReadInt()
	self.auto_addfriend_list = {}

	for i = 1, self.count do
		self.auto_addfriend_list[i] = {}
		self.auto_addfriend_list[i].user_id = MsgAdapter.ReadInt()
		self.auto_addfriend_list[i].gamename = MsgAdapter.ReadStrN(32)
		self.auto_addfriend_list[i].avatar = MsgAdapter.ReadChar()
		self.auto_addfriend_list[i].sex = MsgAdapter.ReadChar()
		self.auto_addfriend_list[i].prof = MsgAdapter.ReadChar()
		self.auto_addfriend_list[i].camp = MsgAdapter.ReadChar()
		self.auto_addfriend_list[i].capability = MsgAdapter.ReadInt()
		self.auto_addfriend_list[i].level = MsgAdapter.ReadInt()
		self.auto_addfriend_list[i].avatar_key_big = MsgAdapter.ReadUInt()
		self.auto_addfriend_list[i].avatar_key_small = MsgAdapter.ReadUInt()
		self.auto_addfriend_list[i].is_select = true
	end
end

-- 活动状态
SCActivityStatus = SCActivityStatus or BaseClass(BaseProtocolStruct)
function SCActivityStatus:__init()
	self.msg_type = 9303
end

function SCActivityStatus:Decode()
	self.activity_type = MsgAdapter.ReadShort()
	self.status = MsgAdapter.ReadChar()
	self.is_broadcast = MsgAdapter.ReadChar()
	self.next_status_switch_time = MsgAdapter.ReadUInt()
	self.param_1 = MsgAdapter.ReadUInt()
	self.param_2 = MsgAdapter.ReadUInt()
	self.open_type = MsgAdapter.ReadUInt()
end

-- 活动房间状态
SCActivityRoomStatusAck = SCActivityRoomStatusAck or BaseClass(BaseProtocolStruct)
function SCActivityRoomStatusAck:__init()
	self.msg_type = 9304
end

function SCActivityRoomStatusAck:Decode()
	self.activity_type = MsgAdapter.ReadInt()
	self.room_user_max = MsgAdapter.ReadInt()
	self.room_status_list = {}
	for i = 1, COMMON_CONSTS.ACTIVITY_ROOM_MAX do
		local room_status = {}
		room_status.is_open = MsgAdapter.ReadInt()
		room_status.role_num = MsgAdapter.ReadInt()
		room_status.index = i - 1
		self.room_status_list[i] = room_status
	end
end

-- 福利boss活动信息
SCCommonActivityInfo = SCCommonActivityInfo or BaseClass(BaseProtocolStruct)
function SCCommonActivityInfo:__init()
	self.msg_type = 9317
end

function SCCommonActivityInfo:Decode()
	self.common_activity_type = MsgAdapter.ReadInt() or 0
	self.status = MsgAdapter.ReadInt() or 0
	self.param_1 = MsgAdapter.ReadUInt() or 0
	MsgAdapter.ReadUInt()
end

-- 	请求随机在线玩家列表
CSGetRandomRoleList = CSGetRandomRoleList or BaseClass(BaseProtocolStruct)
function CSGetRandomRoleList:__init()
	self.msg_type = 9353
end

function CSGetRandomRoleList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求活动房间信息
CSActivityRoomStatusReq = CSActivityRoomStatusReq or BaseClass(BaseProtocolStruct)
function CSActivityRoomStatusReq:__init()
	self.msg_type = 9373
	self.activity_type = 0
end

function CSActivityRoomStatusReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.activity_type)
end
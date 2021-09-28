
-- 返回服务器繁忙,超过人数
SCServerBusy = SCServerBusy or BaseClass(BaseProtocolStruct)
function SCServerBusy:__init()
	self.msg_type = 1002
end

function SCServerBusy:Decode()

end

-- 进入场景请求
CSUserEnterGSReq = CSUserEnterGSReq or BaseClass(BaseProtocolStruct)
function CSUserEnterGSReq:__init()
	self.msg_type = 1050

	self.scene_id = 0
	self.scene_key = 0
	self.last_scene_id = 0
	self.role_id = 0
	self.role_name = ""
	self.time = 0
	self.is_login = 0
	self.server_id = 0
	self.key = ""
	self.plat_name = ""
	self.is_micro_pc = 0
	self.plat_spid = ""
end

function CSUserEnterGSReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.scene_id)
	MsgAdapter.WriteInt(self.scene_key)
	MsgAdapter.WriteInt(self.last_scene_id)
	MsgAdapter.WriteInt(self.role_id)
	MsgAdapter.WriteStrN(self.role_name, 32)
	MsgAdapter.WriteInt(self.time)
	MsgAdapter.WriteChar(self.is_login)
	MsgAdapter.WriteChar(0)
	MsgAdapter.WriteShort(self.server_id)
	MsgAdapter.WriteStrN(self.key, 32)
	MsgAdapter.WriteStrN(self.plat_name, 64)
	MsgAdapter.WriteInt(self.is_micro_pc)
	MsgAdapter.WriteStrN(self.plat_spid, 4)
end

-- 断开当前服务器
CSUserLogout = CSUserLogout or BaseClass(BaseProtocolStruct)
function CSUserLogout:__init()
	self.msg_type = 1051
end

function CSUserLogout:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 传送请求
CSTransportReq = CSTransportReq or BaseClass(BaseProtocolStruct)
function CSTransportReq:__init()
	self.msg_type = 1052

	self.transport_index = 0
end

function CSTransportReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.transport_index)
end

-- 心跳包
CSHeartBeat = CSHeartBeat or BaseClass(BaseProtocolStruct)
function CSHeartBeat:__init()
	self.msg_type = 1053
end

function CSHeartBeat:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 进入场景返回
SCUserEnterGSAck = SCUserEnterGSAck or BaseClass(BaseProtocolStruct)
function SCUserEnterGSAck:__init()
	self.msg_type = 1000
end

function SCUserEnterGSAck:Decode()
	self.result = MsgAdapter.ReadInt()
end


-- 拉取阵营信息
CSGetCampInfo = CSGetCampInfo or BaseClass(BaseProtocolStruct)
function CSGetCampInfo:__init()
	self.msg_type = 10250
end

function CSGetCampInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 拉取阵营返回
SCCampInfo = SCCampInfo or BaseClass(BaseProtocolStruct)
function SCCampInfo:__init()
	self.msg_type = 10200
end

function SCCampInfo:Decode()
	self.camp_info = {}
	self.camp_info_power = {}
	for i=1,4 do
		local camp = MsgAdapter.ReadInt()
		local value = MsgAdapter.ReadInt()
		local power = MsgAdapter.ReadLL()
		if camp > 0 then
			self.camp_info[camp] = value
			self.camp_info_power[camp] = power
		end
	end
end

CSWorldBossHPInfoReq = CSWorldBossHPInfoReq or BaseClass(BaseProtocolStruct)
function CSWorldBossHPInfoReq:__init()
	self.msg_type = 10110
end

function CSWorldBossHPInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCWorldBossHPInfo = SCWorldBossHPInfo or BaseClass(BaseProtocolStruct)
function SCWorldBossHPInfo:__init()
	self.msg_type = 10111
	self.boss_id = 0
	self.cur_hp = 0
	self.max_hp = 0
	self.shield_hp = 0
end

function SCWorldBossHPInfo:Decode()
	self.boss_id = MsgAdapter.ReadInt()
	self.cur_hp = MsgAdapter.ReadInt()
	self.max_hp = MsgAdapter.ReadInt()
	self.shield_hp = MsgAdapter.ReadInt()
end
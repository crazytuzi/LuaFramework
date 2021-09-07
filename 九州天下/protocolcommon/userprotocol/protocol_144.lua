-- 请求连服信息
CSCampBattleServerGroupInfoReq = CSCampBattleServerGroupInfoReq or BaseClass(BaseProtocolStruct)
function CSCampBattleServerGroupInfoReq:__init()
	self.msg_type = 14401
end

function CSCampBattleServerGroupInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 连服信息返回
SCCampBattleServerGroupInfoAck = SCCampBattleServerGroupInfoAck or BaseClass(BaseProtocolStruct)
function SCCampBattleServerGroupInfoAck:__init()
	self.msg_type = 14402
end

function SCCampBattleServerGroupInfoAck:Decode()
	self.server_group_list = {}
	for i = 1, SERVER_GROUP_TYPE.SERVER_GROUP_TYPE_MAX do
		local vo = {}
		vo.count = MsgAdapter.ReadInt()
		vo.server_id_list = {}
		for i = 1, 32 do
			vo.server_id_list[i] = MsgAdapter.ReadInt()
		end
		self.server_group_list[i] = vo
	end
end
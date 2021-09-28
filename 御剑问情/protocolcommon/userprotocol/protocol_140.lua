--通知返回原服
SCReturnOriginalServer = SCReturnOriginalServer or BaseClass(BaseProtocolStruct)
function SCReturnOriginalServer:__init()
	self.msg_type = 14000
end

function SCReturnOriginalServer:Decode()

end

--下发跨服排行榜列表
SCGetCrossPersonRankListAck = SCGetCrossPersonRankListAck or BaseClass(BaseProtocolStruct)
function SCGetCrossPersonRankListAck:__init()
	self.msg_type = 14001
	self.rank_list = {}
end

function SCGetCrossPersonRankListAck:Decode()
	self.rank_list = {}
	self.rank_type = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	for i = 1, count do
		local role = {}
		role.plat_type = MsgAdapter.ReadInt()
		role.user_id = MsgAdapter.ReadInt()
		role.user_name = MsgAdapter.ReadStrN(32)
		role.level = MsgAdapter.ReadInt()
		role.prof = MsgAdapter.ReadChar()
		role.sex = MsgAdapter.ReadChar()
		role.camp = MsgAdapter.ReadChar()
		role.reserved = MsgAdapter.ReadChar()
		role.exp = MsgAdapter.ReadLL()
		role.rank_value = MsgAdapter.ReadLL()
		role.flexible_ll = MsgAdapter.ReadLL()
		role.flexible_name = MsgAdapter.ReadStrN(32)
		role.server_id = MsgAdapter.ReadInt()
		self.rank_list[i] = role
	end
end

-- 获取跨服排行榜列表
CSCrossGetPersonRankList = CSCrossGetPersonRankList or BaseClass(BaseProtocolStruct)
function CSCrossGetPersonRankList:__init()
	self.msg_type = 14050
	self.rank_type = 3
end

function CSCrossGetPersonRankList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end
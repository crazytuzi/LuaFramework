--===================================请求==================================

--===================================下发==================================

--帮会红包信息 
SCGuildRecInfo = SCGuildRecInfo or BaseClass(BaseProtocolStruct)
function SCGuildRecInfo:__init()
	self:InitMsgType(63, 1)
	self.team = 0
	self.sent_name = ""
	self.icon = 0
	self.sex = 0
	self.get_gold = 0
	self.message = ""
	self.total_num = 0
	self.hb_num = 0
	self.rec_hb_role_num = 0
	self.all_hb_rec_info = {}
end

function SCGuildRecInfo:Decode()
	self.team = MsgAdapter.ReadUChar()
	self.sent_name = MsgAdapter.ReadStr()
	self.icon = MsgAdapter.ReadUInt()
	self.sex = MsgAdapter.ReadUInt()
	self.get_gold = MsgAdapter.ReadInt()
	self.message = MsgAdapter.ReadStr()
	self.total_num = MsgAdapter.ReadInt()
	self.hb_num = MsgAdapter.ReadUShort()
	self.rec_hb_role_num = MsgAdapter.ReadUChar()
	self.all_hb_rec_info = {}
	for i = 1, self.rec_hb_role_num do
		local data = {
			name = MsgAdapter.ReadStr(),
			dx = MsgAdapter.ReadUInt(),
			sex = MsgAdapter.ReadUInt(),
			gold_num = MsgAdapter.ReadInt()
		}
		table.insert(self.all_hb_rec_info, data)
	end
end

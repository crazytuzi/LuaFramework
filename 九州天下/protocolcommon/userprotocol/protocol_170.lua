--限购礼包
CSRecordRmbBuy = CSRecordRmbBuy or BaseClass(BaseProtocolStruct)
function CSRecordRmbBuy:__init()
	self.msg_type = 17000
	self.buy_type = 0
	self.param = 0
end

function CSRecordRmbBuy:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.buy_type)
	MsgAdapter.WriteInt(self.param)
end
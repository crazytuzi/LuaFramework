--金钱改变返回
SCMoneyChange = SCMoneyChange or BaseClass(BaseProtocolStruct)
function SCMoneyChange:__init()
	self.msg_type = 2000
end

function SCMoneyChange:Decode()
	self.gold = MsgAdapter.ReadLL()
	self.bind_gold = MsgAdapter.ReadLL()
	self.coin = MsgAdapter.ReadLL()
	self.bind_coin = MsgAdapter.ReadLL()
end

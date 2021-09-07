-- 放一些通用的协议

-- 抽奖结果
SCDrawResult = SCDrawResult or BaseClass(BaseProtocolStruct)
function SCDrawResult:__init()
	self.msg_type = 3100
end

function SCDrawResult:Decode()
	self.draw_reason = MsgAdapter.ReadInt()			-- 抽奖原因 DRAW_REASON
	self.draw_count = MsgAdapter.ReadInt()			-- 抽奖次数
	self.item_count = MsgAdapter.ReadInt()			-- 奖励物品数量
	self.item_info_list = {}
	for i = 1, self.item_count do
		local item = {}
		item.item_id = MsgAdapter.ReadInt()
		item.num = MsgAdapter.ReadShort()
		item.is_bind = MsgAdapter.ReadShort()
		self.item_info_list[i] = item	-- 奖励物品
	end
end
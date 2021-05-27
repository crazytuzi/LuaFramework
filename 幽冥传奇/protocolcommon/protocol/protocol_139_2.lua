-------------------------------------------
-- 请求
-------------------------------------------

-- 挖矿请求
CSDigOreReq = CSDigOreReq or BaseClass(BaseProtocolStruct)
function CSDigOreReq:__init()
	self:InitMsgType(139, 55)
	self.opt_type = 0 			-- 类型：1:进入矿洞  2:开采 3:提升品质4:快速完成  5 :领取挖矿奖励 6:掠夺矿工 7:掠夺矿工战斗结束 8:领取掠夺奖励
	self.opt_idx = 0 			-- 类型：操作类型 开采2：表示矿位索引（从1开始) 领取挖矿奖励 5：表示领取类型索引(从1开始) 掠夺矿工6：表示矿位索引值
end

function CSDigOreReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opt_type)
	if self.opt_type == 2 or self.opt_type == 5 or self.opt_type == 6 then
		MsgAdapter.WriteUChar(self.opt_idx)
	end
end

-- 10亿红包请求
CSZsVipRedpackerReq = CSZsVipRedpackerReq or BaseClass(BaseProtocolStruct)
function CSZsVipRedpackerReq:__init()
	self:InitMsgType(139, 56)
end

function CSZsVipRedpackerReq:Encode()
	self:WriteBegin()
end

-------------------------------------------
-- 下发
-------------------------------------------

--下发10亿红包基本数据
SCZsVipRedpackerInfo = SCZsVipRedpackerInfo or BaseClass(BaseProtocolStruct)
function SCZsVipRedpackerInfo:__init()
	self:InitMsgType(139, 66)
	self.done_num = 0				--幸运红包已爆次数
	self.tq_done_num = 0				--特权卡红包已爆次数
	self.tq_add_num = 0				--特权卡附加次数
	self.award_type = 0				--奖励类型 0 非奖励 1 红包 2 大红包
end

function SCZsVipRedpackerInfo:Decode()
	self.done_num = MsgAdapter.ReadUChar()
	self.tq_done_num = MsgAdapter.ReadUChar()
	self.tq_add_num = MsgAdapter.ReadUChar()
	self.award_type = MsgAdapter.ReadUChar()
end

--下发挖矿基本数据
SCDigOreBaseInfo = SCDigOreBaseInfo or BaseClass(BaseProtocolStruct)
function SCDigOreBaseInfo:__init()
	self:InitMsgType(139, 220)
	self.dig_num = 0				--已挖矿次数
	self.plunder_num = 0			--已掠夺次数
	self.start_dig_time = 0			--开始挖矿时间
	self.resum_dig_num_time = 0		--次数恢复结束时间
	self.quality = 0				--品质
end

function SCDigOreBaseInfo:Decode()
	self.dig_num = MsgAdapter.ReadUChar()
	self.plunder_num = MsgAdapter.ReadUChar()
	self.start_dig_time = CommonReader.ReadServerUnixTime()
	self.resum_dig_num_time = MsgAdapter.ReadUInt()
	self.quality = MsgAdapter.ReadUChar()
end

--下发矿位数据
SCDigOreSlotInfo = SCDigOreSlotInfo or BaseClass(BaseProtocolStruct)
function SCDigOreSlotInfo:__init()
	self:InitMsgType(139, 221)
	self.digslot_list = {} 
end

function SCDigOreSlotInfo:Decode()
	self.digslot_list = {} 
	for i = 1, MsgAdapter.ReadUChar() do
		local vo = {
			slot = MsgAdapter.ReadUChar(),
			quality = MsgAdapter.ReadUChar(),
			start_dig_time = CommonReader.ReadServerUnixTime(),
			role_name = MsgAdapter.ReadStr(),
			gilde_name = MsgAdapter.ReadStr(),
		}
		self.digslot_list[vo.slot] = vo
	end
end

--下发新增矿位数据
SCDigOreAddSlotInfo = SCDigOreAddSlotInfo or BaseClass(BaseProtocolStruct)
function SCDigOreAddSlotInfo:__init()
	self:InitMsgType(139, 222)
	self.slot_info = {}
end

function SCDigOreAddSlotInfo:Decode()
	self.slot_info = {
		slot = MsgAdapter.ReadUChar(),
		quality = MsgAdapter.ReadUChar(),
		start_dig_time = CommonReader.ReadServerUnixTime(),
		role_name = MsgAdapter.ReadStr(),
		gilde_name = MsgAdapter.ReadStr(),
	}
end

--下发删除矿位数据
SCDigOreDelSlotInfo = SCDigOreDelSlotInfo or BaseClass(BaseProtocolStruct)
function SCDigOreDelSlotInfo:__init()
	self:InitMsgType(139, 223)
	self.slot = 0
end

function SCDigOreDelSlotInfo:Decode()
	self.slot = MsgAdapter.ReadUChar()
end

--下发掠夺装备信息
SCDigOreFireInfo = SCDigOreFireInfo or BaseClass(BaseProtocolStruct)
function SCDigOreFireInfo:__init()
	self:InitMsgType(139, 224)
	self.power = 0 			
	self.cloth = 0
	self.weapon = 0
	self.sex = 0
	self.HP = 0
end

function SCDigOreFireInfo:Decode()
	self.power = MsgAdapter.ReadUInt()
	self.weapon = MsgAdapter.ReadUInt()
	self.cloth = MsgAdapter.ReadUInt()
	self.sex = MsgAdapter.ReadUChar()
	self.HP = MsgAdapter.ReadUInt()
end

--下发掠夺成功奖励数据
SCDigOreFireSuccesInfo = SCDigOreFireSuccesInfo or BaseClass(BaseProtocolStruct)
function SCDigOreFireSuccesInfo:__init()
	self:InitMsgType(139, 225)
	self.quality_idx = 0 			
	self.rate = 0
end

function SCDigOreFireSuccesInfo:Decode()
	self.quality_idx = MsgAdapter.ReadUChar()
	self.rate = MsgAdapter.ReadUShort()
end
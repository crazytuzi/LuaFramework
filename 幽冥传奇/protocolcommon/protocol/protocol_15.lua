--===================================请求==================================

-- 拾取物品
CSPickUpItemReq = CSPickUpItemReq or BaseClass(BaseProtocolStruct)
function CSPickUpItemReq:__init()
	self:InitMsgType(15, 9)
	self.obj_id = 0
end

function CSPickUpItemReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.obj_id)
end

--===================================下发==================================

-- 掉落物品出现
SCVisibleObjEnterFallItem = SCVisibleObjEnterFallItem or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterFallItem:__init()
	self:InitMsgType(15, 10)
	self.obj_id = 0
	self.item_name = ""
	self.item_id = 0		-- (65535代表元宝, 0代表金币)
	self.item_num = 0
	self.zhuanshen_level = 0
	self.quanghua_level = 0
	self.item_type = 0
	self.level = 0
	self.zhuan = 0
	self.pos_x  = 0
	self.pos_y  = 0
	self.icon_id = 0
	self.color = 0
	self.is_remind = 0
	self.dir = 0
	self.lock_time = 0
	self.fall_time = 0
	self.expire_time = 0
end

function SCVisibleObjEnterFallItem:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.item_name = MsgAdapter.ReadStr()
	self.item_id = MsgAdapter.ReadUShort()
	self.item_num = MsgAdapter.ReadUShort()
	self.zhuanshen_level = MsgAdapter.ReadUChar()
	self.quanghua_level = MsgAdapter.ReadUChar()
	self.item_type = MsgAdapter.ReadUChar()
	self.level = MsgAdapter.ReadInt()
	self.zhuan = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.icon_id = MsgAdapter.ReadUShort()
	self.color = MsgAdapter.ReadUInt()
	self.is_remind = MsgAdapter.ReadUChar()
	self.dir = MsgAdapter.ReadInt()
	self.lock_time = MsgAdapter.ReadUInt() + TimeCtrl.Instance:GetServerTime()
	self.fall_time = CommonReader.ReadServerUnixTime()
	self.expire_time = MsgAdapter.ReadLL() / 1000
end

-- 修改掉落物的剩余拾取时间
SCFallItemReviseTime = SCFallItemReviseTime or BaseClass(BaseProtocolStruct)
function SCFallItemReviseTime:__init()
	self:InitMsgType(15, 12)
	self.obj_id = 0
end

function SCFallItemReviseTime:Decode()
	self.obj_id = MsgAdapter.ReadLL()
end
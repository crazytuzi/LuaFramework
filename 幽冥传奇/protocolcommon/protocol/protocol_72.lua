--时装新系统

--放入形象
CSSendXingXiangGuan = CSSendXingXiangGuan or BaseClass(BaseProtocolStruct)
function  CSSendXingXiangGuan:__init()
	self:InitMsgType(72, 1)
	self.series = 0;
end

function CSSendXingXiangGuan:Encode( ... )
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

--收回装备
CSSHouhuiEquip = CSSHouhuiEquip or BaseClass(BaseProtocolStruct)
function CSSHouhuiEquip:__init( ... )
	self:InitMsgType(72,2)
	self.series = 0;
end

function CSSHouhuiEquip:Encode( )
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

--幻化
CSHuanhuaEquip = CSHuanhuaEquip or BaseClass(BaseProtocolStruct)
function CSHuanhuaEquip:__init(  )
	self:InitMsgType(72,3)
	self.series = 0;
end

function CSHuanhuaEquip:Encode( )
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

--取消幻化
CSCancelHuanHuaEquip   = CSCancelHuanHuaEquip or BaseClass(BaseProtocolStruct)
function CSCancelHuanHuaEquip:__init(  )
	self:InitMsgType(72,4)
	self.series = 0;
end

function CSCancelHuanHuaEquip:Encode( )
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

-- 请求真气升级形象
CS_72_5 = CS_72_5 or BaseClass(BaseProtocolStruct)
function CS_72_5:__init()
	self:InitMsgType(72, 5)
	self.series = 0;
end

function CS_72_5:Encode( )
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

---===========服务器下发=========-------------
--所有时装数据
SCAllFashionData = SCAllFashionData or BaseClass(BaseProtocolStruct)
function SCAllFashionData:__init( ... )
	self:InitMsgType(72,1)
	self.fashion_list = {}
	self.fashion_count = 0
end

function SCAllFashionData:Decode()
	self.fashion_list = {}
	self.fashion_count = MsgAdapter.ReadUShort()
	for i = 1, self.fashion_count do
		local vo = {}
		vo = CommonReader.ReadItemData();
		self.fashion_list[i] = vo
	end
end

--添加装备
SCAddFashionEquip = SCAddFashionEquip or BaseClass(BaseProtocolStruct)
function SCAddFashionEquip:__init( ... )
	self:InitMsgType(72,2)
	self.item_data = {}
end

function SCAddFashionEquip:Decode( ... )
	self.item_data = CommonReader.ReadItemData()
end

--回收装备
SCAddRecycleEquip = SCAddRecycleEquip or BaseClass(BaseProtocolStruct)
function SCAddRecycleEquip:__init()
	self:InitMsgType(72,3)
	self.series = 0
end

function SCAddRecycleEquip:Decode()
	self.series = CommonReader.ReadSeries()
end

--更新物品数据变化
SCUpdateEquip = SCUpdateEquip or BaseClass(BaseProtocolStruct)
function SCUpdateEquip:__init()
	self:InitMsgType(72,4)
	self.item_data = {}
end

function SCUpdateEquip:Decode()
	self.item_data = CommonReader.ReadItemData()
end


-- 一个装备数据
TradingEquipInfo = BaseClass()
function TradingEquipInfo:__init()
	self.id = 0 -- 实例id(或背包中物品bid)
	self.bid = 0 -- 表id
	self.equipType = 0 -- 部位
	self.holeNum = 0 -- 孔位数
	self.attrs = {} -- 附加属性消息{[k]=v}
	self.score = 0 -- 评分
	self.isBinding = 0 -- 绑定
	self.isOnBag = false -- 是否在背包中
end
function TradingEquipInfo:Update( data )
	if not data then return end
	self.id = toLong(data.playerEquipmentId)
	self.bid = data.equipmentId or 0
	self.equipType = data.equipType or 0
	self.holeNum = data.holeNum or 0
	self.score = data.score or 0
	self.isBinding = data.isBinding or 0
	self.attrs = {}
	SerialiseProtobufList( data.addPropertyMsg, function ( data )
		table.insert(self.attrs, {data.propertyId, data.propertyValue})
	end)
end
function TradingEquipInfo:SetEquipInfo( info )
	self.id = info.id
	self.bid = info.bid
	self.equipType = info.equipType
	self.holeNum = info.holeNum
	self.attrs = info.attrs
	self.score = info.score
	self.isBinding = info.isBinding
	self.isOnBag = true
end
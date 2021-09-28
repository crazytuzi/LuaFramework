-- 一个装备数据
EquipInfo = BaseClass()
function EquipInfo:__init( data, wakanLevel )
	self.id = 0 -- 实例id(或背包中物品bid)
	self.bid = 0 -- 表id
	self.equipType = 0 -- 部位
	self.state = 0 -- 物品状态 GoodsVo相同
	self.holeNum = 0 -- 孔位数
	self.attrs = {} -- 附加属性消息{[k]=v}
	self.score = 0 -- 评分
	self.isBinding = 0 -- 绑定
	self.cfg = nil
	self:Update(data)

	if wakanLevel then
		self.wakanLevel = wakanLevel
	end
end
function EquipInfo:Update( data )
	if not data then return end
	self.id = toLong(data.playerEquipmentId or 0)
	self.bid = data.equipmentId or 0
	self.equipType = data.equipType or 0
	self.state = data.state or 0
	self.holeNum = data.holeNum or 0
	self.score = data.score or 0
	self.isBinding = data.isBinding or 0
	self.attrs = {}
	self.cfg = nil
	SerialiseProtobufList( data.addPropertyMsg, function ( data )
		table.insert(self.attrs, {data.propertyId, data.propertyValue})
	end)
end
function EquipInfo:GetCfgData()
	self.cfg = self.cfg or GoodsVo.GetEquipCfg(self.bid)
	return self.cfg
end
function EquipInfo:ToGoodsVo()
	local vo = GoodsVo.New()
	vo:SetCfg(GoodsVo.GoodType.equipment , self.bid, 1, self.isBinding)
	vo.equipId = self.id
	return vo
end
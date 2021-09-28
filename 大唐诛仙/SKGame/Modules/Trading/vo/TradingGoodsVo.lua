TradingGoodsVo = BaseClass()
-- 对象类
function TradingGoodsVo:__init()
	self.id = 0 -- 实例id
	self.bid = 0 -- (物品｜装备) 表id
	self.goodsType = 2 -- 物品类别 (1:装备 2：药品 3：材料)	 12对应表goodsType (1.equipment表， 2. item表， 其他:TradingGoodsVo对应)
	self.equipId = 0 -- 装备实例id(goodsType = 1时)(查询装备的实例id)
	self.itemIndex = 0 -- 物品索引下标(格子) 对应PkgCell gid 格子id
	self.num = 0 -- 数量
	self.isBinding = 0
	self.state = 0 -- 物品状态 (1:背包 2:穿戴 4:(交易行)出售, 其他:空)
	self.price = 0
	self.overTime = 0
	self.isOnBag = false -- 是否在背包中
end
function TradingGoodsVo:Update(data, type)
	if not data then return end
	self.id = toLong(data.playerBagId)
	self.goodsType = data.goodsType or 2
	self.itemIndex = data.itemIndex or 0
	self.num = data.num or 0
	self.isBinding = data.isBinding or 0
	self.price = data.price or 0
	self.overTime = toLong(data.overTime)
	self.state = data.state or 0

	if self.goodsType == 1 then
		self.equipId = data.itemId or data.equipId or 0
		local info = nil
		if type == TradingConst.itemType.shelf then
			info = TradingModel:GetInstance():GetMyInfo(data.itemId)
		elseif type == TradingConst.itemType.sysSell then
			info = TradingModel:GetInstance():GetSysInfo(data.itemId)
		else
			info = TradingModel:GetInstance():GetPkgInfo(data.itemId)
		end
		if info then
			self.bid = info.bid or data.bid or 0
		end
	else
		self.bid = toLong(data.itemId or data.bid)
	end
end
function TradingGoodsVo:SetDataByGoodsVo(vo)
	if not vo then return end
	self.id = vo.id
	self.bid = vo.bid
	self.goodsType = vo.goodsType
	self.equipId = vo.equipId
	self.itemIndex = vo.itemIndex
	self.num = vo.num
	self.isBinding = vo.isBinding
	self.state = vo.state
	self.isOnBag = true
end
-- 获取cfg
function TradingGoodsVo:GetCfgData()
	self.cfg = self.cfg or GoodsVo.GetCfg(self.goodsType, self.bid)
	return self.cfg
end
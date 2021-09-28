--斗神印Vo
RuneVo =BaseClass()

function RuneVo:__init()
	self.itemId = 0 --物品表中的id
	self.level = 0	--等级
	self.cnt = 0 	--数量
	self.icon = ""
	self.itemIndex = 0 --物品格子位置
	self.playerBagId = 0 --物品自增编号，相当于每个玩家
	self.rare = 0 --稀有度
	self.isBinding = 0 --不绑定
end

function RuneVo:GetCfg()
	return GetCfgData("item"):Get(self.itemId) or {}
end

function RuneVo:ToString()

end

function RuneVo:InitVo(goodsVoObj)
	if not TableIsEmpty(goodsVoObj) then
		self.itemId = goodsVoObj.bid
		self.cnt = goodsVoObj.num 
		self.itemIndex = goodsVoObj.itemIndex
		self.playerBagId = goodsVoObj.id
		self.isBinding = goodsVoObj.isBinding

		local goodsCfg = goodsVoObj:GetCfgData()
		self.level = goodsCfg.itemLv or 0
		self.rare = goodsCfg.rare or 0
		self.icon = goodsCfg.icon or ""
	end
end

function RuneVo:GetItemId()
	return self.itemId
end

function RuneVo:GetLevel()
	return self.level
end

function RuneVo:GetCnt()
	return self.cnt
end

function RuneVo:GetPlayerBagId()
	return self.playerBagId
end

function RuneVo:__delete()
	self.itemId = nil
	self.level = nil
	self.cnt = nil
	self.icon = nil
	self.itemIndex = nil
	self.playerBagId = 0
	self.rare = 0
	self.isBinding = 0
end
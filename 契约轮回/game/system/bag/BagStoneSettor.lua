--
-- @Author: chk
-- @Date:   2018-08-22 10:57:14


--设置背包物品的信息
BagStoneSettor = BagStoneSettor or class("BagStoneSettor",BaseBagGoodsSettor)
local BagStoneSettor = BagStoneSettor

BagStoneSettor.__cache_count=50
function BagStoneSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "StoneItem"
	self.layer = layer


	BagStoneSettor.super.Load(self)
end
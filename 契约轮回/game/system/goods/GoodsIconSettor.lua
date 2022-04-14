
GoodsIconSettor = GoodsIconSettor or class("GoodsIconSettor",BaseIconSettor)
local this = GoodsIconSettor

function GoodsIconSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "GoodsIcon"
    self.layer = nil

    -- self.equipPanel = nil

    GoodsIconSettor.super.Load(self)
end
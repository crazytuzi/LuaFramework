--
-- @Author: chk
-- @Date:   2018-09-30 11:13:46
--
GoodsAttrItemSettor = GoodsAttrItemSettor or class("GoodsAttrItemSettor",BaseEquipAttrItemSettor)
local GoodsAttrItemSettor = GoodsAttrItemSettor

function GoodsAttrItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "GoodsAttrItem"
	self.layer = nil

	-- self.model = 2222222222222end:GetInstance()
	--print("BaseEquipAttrItemSettorBaseEquipAttrItemSettor" , BaseEquipAttrItemSettor)
	GoodsAttrItemSettor.super.Load(self)
	--BaseWidget.Load(self)
end

function GoodsAttrItemSettor:dctor()
end

function GoodsAttrItemSettor:LoadCallBack()
	GoodsAttrItemSettor.super.LoadCallBack(self)
end

function GoodsAttrItemSettor:AddEvent()
	GoodsAttrItemSettor.super.AddEvent(self)
end

function GoodsAttrItemSettor:SetData(data)

end

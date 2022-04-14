--
-- @Author: chk
-- @Date:   2018-09-17 22:29:14
--
GoodsDetailViewOnly = GoodsDetailViewOnly or class("GoodsDetailViewOnly",BaseGoodsTipView)
local GoodsDetailViewOnly = GoodsDetailViewOnly

function GoodsDetailViewOnly:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "GoodsDetailView"
	self.layer = layer


	BaseWidget.Load(self)
end

function GoodsDetailViewOnly:dctor()
end

function GoodsDetailViewOnly:LoadCallBack()
	GoodsDetailViewOnly.super.LoadCallBack(self)

	SetVisible(self.btnContain.gameObject,false)
	self.btnWidth = 0
end

function GoodsDetailViewOnly:AddEvent()
	self:AddClickCloseBtn()

	self.events[#self.events+1] = GlobalEvent:AddListener(GoodsEvent.CreateAttEnd,handler(self,self.DealCreateAttEnd))
end

function GoodsDetailViewOnly:SetData(data)

end
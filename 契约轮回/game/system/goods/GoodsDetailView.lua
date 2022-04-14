--
-- @Author: chk
-- @Date:   2018-08-31 18:54:49
--
GoodsDetailView = GoodsDetailView or class("GoodsDetailView",BaseGoodsTipView)
local GoodsDetailView = GoodsDetailView

function GoodsDetailView:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "GoodsDetailView"
	self.layer = nil


	GoodsDetailView.super.Load(self)

	self.btnWidth = 120
end

function GoodsDetailView:dctor()
end



function GoodsDetailView:LoadCallBack()
	GoodsDetailView.super.LoadCallBack(self)

    SetLocalPositionZ(self.transform,0)
	--self:UpdateInfo(self.model.goodsItem)
end

--处理销毁装备
function GoodsDetailView:DealDestroyGoods(item)
	if item.uid == self.model.goodsItem.uid then

	end
end

function GoodsDetailView:OpenCallBack()
	self:UpdateView()
end

function GoodsDetailView:UpdateView( )

end

function GoodsDetailView:CloseCallBack(  )

end



--
-- @Author: chk
-- @Date:   2018-09-02 02:36:13
--
GoodsOperateBtnSettor = GoodsOperateBtnSettor or class("GoodsOperateBtnSettor",BaseWidget)
local GoodsOperateBtnSettor = GoodsOperateBtnSettor

function GoodsOperateBtnSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "GoodsOperateBtn"
	--self.layer = layer

	-- self.model = 2222222222222end:GetInstance()

	self.btnName = nil

	GoodsOperateBtnSettor.super.Load(self)


end

function GoodsOperateBtnSettor:dctor()
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
end

function GoodsOperateBtnSettor:LoadCallBack()
	self.nodes = {
		"Text",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function GoodsOperateBtnSettor:AddEvent()
end

function GoodsOperateBtnSettor:SetData(data)
	self.btnName = data.name
	GetText(self.Text).text = data.name
	self.call_back = data.callBack
	self.callBackParam = data.callBackParam
	local function call_back()
		self.call_back(self.callBackParam)
	end
	AddClickEvent(self.gameObject,call_back)
end

function GoodsOperateBtnSettor:UpdateReddot(visible)

	--不需要显示红点 并且没实例化过红点的 就不需要后续处理了
	if not visible and not self.reddot then
		return
	end

	self.reddot = self.reddot or RedDot(self.transform)
	SetLocalPositionZ(self.reddot.transform,0)
	SetAnchoredPosition(self.reddot.transform, 49, 27.5)
	SetVisible(self.reddot, visible)
end



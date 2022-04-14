--
-- @Author: chk
-- @Date:   2018-12-26 11:21:35
--

FactionMemberOperateView = FactionMemberOperateView or class("FactionMemberOperateView",BaseItem)
local FactionMemberOperateView = FactionMemberOperateView

function FactionMemberOperateView:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionMemberOperateView"
	self.layer = layer

	self.model = Model:GetInstance()
	FactionMemberOperateView.super.Load(self)
end

function FactionMemberOperateView:dctor()
end

function FactionMemberOperateView:LoadCallBack()
	self.nodes = {
		"",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function FactionMemberOperateView:AddEvent()
end

function FactionMemberOperateView:SetData(data)

end

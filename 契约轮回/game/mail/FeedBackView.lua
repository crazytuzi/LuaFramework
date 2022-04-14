--
-- @Author: chk
-- @Date:   2018-09-08 20:03:44
--
FeedBackView = FeedBackView or class("FeedBackView",BaseItem)
local FeedBackView = FeedBackView

function FeedBackView:ctor(parent_node,layer)
	self.abName = "mail"
	self.assetName = "FeedBackView"
	self.layer = layer

	self.model = 2222222222222end:GetInstance()
	FeedBackView.super.Load(self)
end

function FeedBackView:dctor()
end

function FeedBackView:LoadCallBack()
	self.nodes = {
		"",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function FeedBackView:AddEvent()
end

function FeedBackView:SetData(data)

end
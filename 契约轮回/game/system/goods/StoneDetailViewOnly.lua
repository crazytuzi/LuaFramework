--
-- @Author: chk
-- @Date:   2018-09-17 22:35:08
--
StoneDetailViewOnly = StoneDetailViewOnly or class("StoneDetailViewOnly",BaseGoodsTipView)
local StoneDetailViewOnly = StoneDetailViewOnly

function StoneDetailViewOnly:ctor(parent_node,layer)
	self.abName = "goods"
	self.assetName = "StoneDetailViewOnly"
	self.layer = layer


	StoneDetailViewOnly.super.Load(self)
end

function StoneDetailViewOnly:dctor()
end

function StoneDetailViewOnly:LoadCallBack()
    self.nodes = {
        "bg",
        "fram",
        "nameTxt",
        "icon",
        "lv/lvValue",
        "type/typeValue",
        "ScrollView",
        "ScrollView/Viewport/Content",
    }
    self:GetChildren(self.nodes)
    self:GetRectTransform()
    self:AddEvent()

    self:UpdateInfo(self.model.goodsItem)
end

function StoneDetailViewOnly:AddEvent()
    self:AddClickCloseBtn()
end

function StoneDetailViewOnly:SetData(data)

end

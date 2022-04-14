-- @Author: lwj
-- @Date:   2019-08-12 17:45:39 
-- @Last Modified time: 2019-08-12 17:45:41

WeddingRecoItem = WeddingRecoItem or class("WeddingRecoItem", BaseCloneItem)
local WeddingRecoItem = WeddingRecoItem

function WeddingRecoItem:ctor(parent_node, layer)
    WeddingRecoItem.super.Load(self)
end

function WeddingRecoItem:dctor()
end

function WeddingRecoItem:LoadCallBack()
    --self.model = CanMdyModel.GetInstance()
    self.nodes = {
        "des",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)

    self:AddEvent()
end

function WeddingRecoItem:AddEvent()

end

function WeddingRecoItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function WeddingRecoItem:UpdateView()
    self.des.text = string.format(ConfigLanguage.OpenHigh.WeddingRecoText, self.data.role_name)
end
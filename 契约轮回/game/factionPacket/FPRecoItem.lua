-- @Author: lwj
-- @Date:   2019-05-15 11:35:53
-- @Last Modified time: 2019-05-15 11:35:54

FPRecoItem = FPRecoItem or class("FPRecoItem", BaseCloneItem)
local FPRecoItem = FPRecoItem

function FPRecoItem:ctor(parent_node, layer)
    FPRecoItem.super.Load(self)
end

function FPRecoItem:dctor()
end

function FPRecoItem:LoadCallBack()
    self.model = FPacketModel.GetInstance()
    self.nodes = {
        "name_con/name", "name_con/token", "money_icon", "money", "bg",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.money = GetText(self.money)
    self.money_icon = GetImage(self.money_icon)

    self:AddEvent()
end

function FPRecoItem:AddEvent()

end

function FPRecoItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function FPRecoItem:UpdateView()
    self.name.text = self.data.role.name
    self.money.text = self.data.money
    GoodIconUtil.GetInstance():CreateIcon(self, self.money_icon, tostring(self.data.gold_type), true)
    SetVisible(self.token, self.data.is_european)
    SetVisible(self.bg, self.data.index % 2 == 0)
end

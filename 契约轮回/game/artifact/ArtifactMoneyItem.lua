---
--- Created by  Administrator
--- DateTime: 2020/6/23 15:56
---
ArtifactMoneyItem = ArtifactMoneyItem or class("ArtifactMoneyItem", BaseCloneItem)
local this = ArtifactMoneyItem

function ArtifactMoneyItem:ctor(obj, parent_node, parent_panel)
    ArtifactMoneyItem.super.Load(self)
   -- self.events = {}
end

function ArtifactMoneyItem:dctor()
    --GlobalEvent:RemoveTabListener(self.events)
    if self.role_data_event then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.role_data_event)
        self.role_data_event = nil
    end
end

function ArtifactMoneyItem:LoadCallBack()
    self.nodes = {
        "moeny","icon",
    }
    self:GetChildren(self.nodes)
    self.moneyIcon = GetImage(self.icon)
    self.moeny = GetText(self.moeny)
    self:InitUI()
    self:AddEvent()
end

function ArtifactMoneyItem:InitUI()

end

function ArtifactMoneyItem:AddEvent()
    --local function call_back()
    --    self.moeny.text = RoleInfoModel:GetInstance():GetRoleValue(self.data[1])
    --end
    --self.role_data_event = RoleInfoModel:GetInstance():GetMainRoleData():BindData(self.data[1], call_back)
end

function ArtifactMoneyItem:SetData(data)
    self.data = data
    GoodIconUtil:CreateIcon(self, self.moneyIcon, self.data[2], true)
    self.moeny.text = RoleInfoModel:GetInstance():GetRoleValue(self.data[1]) or 0
    local function call_back()
        self.moeny.text = RoleInfoModel:GetInstance():GetRoleValue(self.data[1]) or 0
    end
    self.role_data_event = RoleInfoModel:GetInstance():GetMainRoleData():BindData(self.data[1], call_back)
end
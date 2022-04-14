---
--- Created by  Administrator
--- DateTime: 2019/7/11 14:39
---
WeddingInvitationItem = WeddingInvitationItem or class("WeddingInvitationItem", BaseCloneItem)
local this = WeddingInvitationItem

function WeddingInvitationItem:ctor(obj, parent_node, parent_panel)
    WeddingInvitationItem.super.Load(self)
    self.events = {}
end

function WeddingInvitationItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function WeddingInvitationItem:LoadCallBack()
    self.nodes = {
        "name","des","okBtn"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()
end

function WeddingInvitationItem:InitUI()

end

function WeddingInvitationItem:AddEvent()
    
    local function call_back()
        MarryController:GetInstance():RequsetGuestInvite(self.data.base.id)
    end
    AddClickEvent(self.okBtn.gameObject,call_back)
end

function WeddingInvitationItem:SetData(data,type)
    self.data = data
    self.type = type
    if self.data.base then
        self.id = self.data.base.id
    else
        self.id = self.data.id
    end
    self:SetInfo()
end

function WeddingInvitationItem:SetInfo()
    if self.data.base then
        self.name.text = self.data.base.name
    else
        self.name.text = self.data.name
    end
   --= self.data.base.name or self.data.name
    --local state = self.model:GetGuestState()
    if self.type == 1 then  --未邀请
        SetVisible(self.okBtn,true)
        SetVisible(self.des,false)
    else
        SetVisible(self.okBtn,false)
        SetVisible(self.des,true)
    end
end
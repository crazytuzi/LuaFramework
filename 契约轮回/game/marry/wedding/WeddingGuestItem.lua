---
--- Created by  Administrator
--- DateTime: 2019/7/16 11:45
---
WeddingGuestItem = WeddingGuestItem or class("WeddingGuestItem", BaseCloneItem)
local this = WeddingGuestItem

function WeddingGuestItem:ctor(obj, parent_node, parent_panel)
    WeddingGuestItem.super.Load(self)
    self.events = {}
end

function WeddingGuestItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
end

function WeddingGuestItem:LoadCallBack()
    self.nodes = {
        "okBtn","roleObj/role_bg/role_icon","refuseBtn","roleObj/name","powerObj/power",
        "roleObj/role_bg/level_bg/level",
    }
    self:GetChildren(self.nodes)
   -- self.role_icon = GetImage(self.role_icon)
    self.name = GetText(self.name)
    self.power = GetText(self.power)
    self.lv = GetText(self.level)
    self:InitUI()
    self:AddEvent()
end

function WeddingGuestItem:InitUI()

end

function WeddingGuestItem:AddEvent()
    local function call_back()  --同意
        MarryController:GetInstance():RequsetInvitationRequestAccept({self.data.id})
    end
    AddButtonEvent(self.okBtn.gameObject,call_back)

    local function call_back()  --拒绝
        MarryController:GetInstance():RequsetInvitationRequestRefuse(self.data.id)
    end
    AddButtonEvent(self.refuseBtn.gameObject,call_back)
end

function WeddingGuestItem:SetData(data)
    self.data = data
    self.name.text = self.data.name
    self.power.text = self.data.power
    self.lv.text = self.data.level
    --local icon = "img_role_head_1"
    --if self.data.gender == 2 then
    --    icon = "img_role_head_2"
    --end
    --lua_resMgr:SetImageTexture(self,self.role_icon, 'main_image', icon, true)
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    param["is_hide_frame"] = true
    param["size"] = 61
    param["uploading_cb"] = uploading_cb
    param["role_data"] = self.data
    self.role_icon1 = RoleIcon(self.role_icon)
    self.role_icon1:SetData(param)
end
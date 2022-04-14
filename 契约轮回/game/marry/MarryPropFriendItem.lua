---
--- Created by  Administrator
--- DateTime: 2019/6/11 11:21
---
MarryPropFriendItem = MarryPropFriendItem or class("MarryPropFriendItem", BaseCloneItem)
local this = MarryPropFriendItem

function MarryPropFriendItem:ctor(obj, parent_node, parent_panel)
    MarryPropFriendItem.super.Load(self)
    self.model = MarryModel:GetInstance()
    self.events = {}
end

function MarryPropFriendItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
end

function MarryPropFriendItem:LoadCallBack()
    self.nodes = {
        "vip","intimacy","okBtn","role_bg/role_icon","name","role_bg/level_bg/level",

    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.vip  = GetText(self.vip)
    self.intimacy = GetText(self.intimacy)
    self.level = GetText(self.level)
    --self.role_icon = GetImage(self.role_icon)
    self:InitUI()
    self:AddEvent()
end

function MarryPropFriendItem:InitUI()

end

function MarryPropFriendItem:AddEvent()

    local function call_back()
        local  panel = lua_panelMgr:GetPanel(MarryPropFriendPanel)
        if not panel then
            return
        end
        panel:Close()
        self.model:Brocast(MarryEvent.ClickPropFriendItem,self.data)
    end
    AddClickEvent(self.okBtn.gameObject,call_back)
end

function MarryPropFriendItem:SetData(data)
    self.data = data
    self:SetInfo()
end

function MarryPropFriendItem:SetInfo()
    self.name.text = self.data.base.name
    self.intimacy.text = "Intimacy:"..self.data.intimacy
    self.level.text = self.data.base.level
    self.vip.text = "V"..self.data.base.viplv
    --local icon = "img_role_head_1"
    --if self.data.base.gender == 2 then
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
    param["role_data"] = self.data.base
    self.role_icon1 = RoleIcon(self.role_icon)
    self.role_icon1:SetData(param)
    dump(self.data.base)
end
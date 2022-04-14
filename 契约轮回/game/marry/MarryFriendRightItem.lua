---
--- Created by  Administrator
--- DateTime: 2019/6/3 16:01
---
MarryFriendRightItem = MarryFriendRightItem or class("MarryFriendRightItem", BaseCloneItem)
local this = MarryFriendRightItem

function MarryFriendRightItem:ctor(obj, parent_node, parent_panel)
    MarryFriendRightItem.super.Load(self)
    self.events = {}
    self.tagItems = {}
end

function MarryFriendRightItem:dctor()
    if self.lv_item then
        self.lv_item:destroy()
        self.lv_item = nil
    end
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.tagItems) do
        v:destroy()
    end
    self.tagItems = {}
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
end

function MarryFriendRightItem:LoadCallBack()
    self.nodes = {
        "bg", "down/vip", "firendBtn", "down/name", "head", "down/level", "down/tagsContent",
    }
    self:GetChildren(self.nodes)
    self.vip = GetText(self.vip)
    self.name = GetText(self.name)
    --self.head =GetImage(self.head)
    self:InitUI()
    self:AddEvent()
end

function MarryFriendRightItem:InitUI()

end

function MarryFriendRightItem:AddEvent()

    local function call_back()
        MarryController:GetInstance():RequsetMakeFriend(self.data.base.id)
    end
    AddButtonEvent(self.firendBtn.gameObject, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.bg):Open(self.data.base)
    end
    AddClickEvent(self.bg.gameObject, call_back)
end

function MarryFriendRightItem:SetData(data)
    self.data = data
    self:UpdateInfo()
    -- dump()
end
function MarryFriendRightItem:UpdateInfo()
    self.vip.text = "VIP" .. self.data.base.viplv
    self.name.text = self.data.base.name
    if self.lv_item then
        self.lv_item:destroy()
        self.lv_item = nil
    end
    self.lv_item = LevelShowItem(self.level, "UI")
    self.lv_item:SetData(16, self.data.base.level, "FFFFFF", "815043")
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.head):Open(self.data.base)
    end
    local param = {}
    param['is_can_click'] = true
    param['click_fun'] = call_back
    param["is_squared"] = true
    param["is_hide_frame"] = true
    param["size"] = 136
    param["role_data"] = self.data.base
    self.role_icon = RoleIcon(self.head)
    self.role_icon:SetData(param)
    dump(self.data.base)
    self:UpdateTags()

end

function MarryFriendRightItem:UpdateTags()
    for i, v in pairs(self.data.tags) do
        local item = self.tagItems[i]
        if not item then
            item = MarryFriendTagItem(self.tagsContent, "UI")
            self.tagItems[i] = item
        end
        item:SetData(v, 2)
    end
end
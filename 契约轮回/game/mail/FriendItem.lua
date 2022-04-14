FriendItem = FriendItem or class("FriendItem", BaseItem)
local FriendItem = FriendItem

function FriendItem:ctor(parent_node, layer)
    self.abName = "mail"
    self.assetName = "FriendItem"
    self.layer = layer

    self.model = FriendModel:GetInstance()
    FriendItem.super.Load(self)
end

function FriendItem:dctor()
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
    self.love_icon = nil
end

function FriendItem:LoadCallBack()
    self.nodes = {
        "Name", "Level", "vip", "love_bg/love1", "love_bg/love2", "love_bg/love3", "love_bg/love4", "love_bg/love5", "love_bg/love6",
        "love_bg/love7", "love_bg/love8", "love_bg/love9", "love_bg/love10", "love_bg", "icon"
    }
    self:GetChildren(self.nodes)
    self.Level = GetText(self.Level)
    self.Name = GetText(self.Name)
    self.vip = GetText(self.vip)
    --self.role_icon = GetImage(self.role_icon)
    self.love_icon = { self.love1, self.love2, self.love3, self.love4, self.love5, self.love6, self.love7, self.love8, self.love9, self.love10 }

    self:AddEvent()
    self:UpdateView()
end

function FriendItem:AddEvent()

    local function call_back(target, x, y)
        local panel = lua_panelMgr:GetPanelOrCreate(FriendlyTipsPanel)
        panel:SetData(self.data)
        panel:Open()
    end
    AddClickEvent(self.love_bg.gameObject, call_back)
end

--data:role_id
function FriendItem:SetData(data)
    self.data = data
    local noupdateicon = (self.data ~= nil)
    if self.is_loaded then
        self:UpdateView(noupdateicon)
    end
end

function FriendItem:UpdateView(noupdateicon)
    local friend = self.model:GetPFriend(self.data)
    if friend then
        local role = friend.base
        self:UpdateRoleInfo(role, noupdateicon, friend.is_online)
        local level = self:GetFriendValueName(friend.intimacy)
        if level > 1 then
            for i = 2, level do
                SetVisible(self.love_icon[i - 1], true)
            end
        end
    end
end

function FriendItem:UpdateRoleInfo(role, noupdateicon, is_online)
    self.Level.text = GetLevelShow(role.level)
    self.Name.text = role.name
    if not noupdateicon then
        local function call_back(target, x, y)
            self:OpenMenu(self.data)
        end
        local param = {}
        param['is_can_click'] = true
        param['click_fun'] = call_back
        param["is_squared"] = false
        param["is_hide_frame"] = false
        param["size"] = 62
        param["role_data"] = role
        if not self.role_icon then
            self.role_icon = RoleIcon(self.icon)
        end
        self.role_icon:SetData(param)
        self.role_icon:SetIconGray(not is_online)
    end
    self.vip.text = string.format(ConfigLanguage.Common.Vip, role.viplv)
end

function FriendItem:OpenMenu(role_id)
    local friend = self.model:GetPFriend(role_id)
    if friend then
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.icon)
        panel:Open(friend.base)
    end
end

function FriendItem:GetFriendValueName(intimacy)
    local level = 1
    for i = 1, #Config.db_flower_honey do
        local intimacy_item = Config.db_flower_honey[i]
        if intimacy >= intimacy_item.honey then
            level = intimacy_item.level
        end
    end
    return level
end
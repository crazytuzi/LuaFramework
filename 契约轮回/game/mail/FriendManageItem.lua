FriendManageItem = FriendManageItem or class("FriendManageItem", BaseItem)
local FriendManageItem = FriendManageItem
local floor = math.floor

function FriendManageItem:ctor(parent_node, layer)
    self.abName = "mail"
    self.assetName = "FriendManageItem"
    self.layer = layer

    self.model = FriendModel:GetInstance()
    FriendManageItem.super.Load(self)
end

function FriendManageItem:dctor()
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
end

function FriendManageItem:LoadCallBack()
    self.nodes = {
        "icon_bg", "name", "level", "status", "Toggle",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.level = GetText(self.level)
    self.status = GetText(self.status)
    self.toggle = GetToggle(self.Toggle)

    self:AddEvent()
    self:UpdateView()
end

function FriendManageItem:AddEvent()

    local function call_back(target, value)
        if value then
            self.model:AddManageRole(self.data.base.id)
        else
            self.model:RemoveManageRole(self.data.base.id)
        end
    end
    AddValueChange(self.toggle.gameObject, call_back)

    local function call_back(days)
        if not self.data.is_online then
            if days > 0 then
                local interdays = math.floor((os.time() - self.data.logout) / (3600 * 24))
                self.toggle.isOn = interdays >= days
            else
                self.toggle.isOn = false
            end
        end
    end
    self.event_id = self.model:AddListener(FriendEvent.FilterDays, call_back)
end

--data:p_friend
function FriendManageItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function FriendManageItem:UpdateView()
    local role = self.data.base
    local param = {}
    param['is_can_click'] = false
    param["is_squared"] = false
    param["is_hide_frame"] = false
    param["size"] = 60
    param["role_data"] = role
    if not self.role_icon then
        self.role_icon = RoleIcon(self.icon_bg)
    end
    self.role_icon:SetData(param)

    self.level.text = string.format(ConfigLanguage.Mail.Level, role.level)
    if self.data.is_online then
        self.status.text = ConfigLanguage.Mail.Online
    else
        local now = os.time()
        local logout = self.data.logout
        self.status.text = self:GetStatusText(now, logout)
    end
    self.name.text = role.name
    self.toggle.isOn = false
end

function FriendManageItem:GetStatusText(now, logout)
    local inter_sec = now - logout
    local day = floor(inter_sec / (3600 * 24))
    local hour = floor(inter_sec / 3600)
    local min = floor(inter_sec / 60)
    if day > 7 then
        return ConfigLanguage.Mail.OverSevenDays
    elseif day > 0 then
        return string.format(ConfigLanguage.Mail.DayText, day)
    elseif hour > 0 then
        return string.format(ConfigLanguage.Mail.HourText, hour)
    elseif min > 0 then
        return string.format(ConfigLanguage.Mail.MinText, min)
    else
        return string.format(ConfigLanguage.Mail.SecText, inter_sec)
    end
end
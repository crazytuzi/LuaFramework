AddFriendItem = AddFriendItem or class("AddFriendItem", BaseItem)
local AddFriendItem = AddFriendItem

function AddFriendItem:ctor(parent_node, layer)
    self.abName = "mail"
    self.assetName = "AddFriendItem"
    self.layer = layer

    --self.model = 2222222222222end:GetInstance()
    AddFriendItem.super.Load(self)
end

function AddFriendItem:dctor()
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
end

function AddFriendItem:LoadCallBack()
    self.nodes = {
        "icon_bg", "level_bg", "level_bg/level", "name", "vip", "power", "addbtn", "added",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self.level = GetText(self.level)
    self.name = GetText(self.name)
    self.vip = GetText(self.vip)
    self.power = GetText(self.power)
    self.lv_img = GetImage(self.level_bg)

    self:UpdateView()
end

function AddFriendItem:AddEvent()
    local function call_back(target, x, y)
        FriendController:GetInstance():RequestAddFriend(self.data.id)
        SetVisible(self.addbtn, false)
        SetVisible(self.added, true)
    end
    AddClickEvent(self.addbtn.gameObject, call_back)
end

--data:p_role_base
function AddFriendItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function AddFriendItem:UpdateView()
    SetVisible(self.addbtn, true)
    SetVisible(self.added, false)
    --self.level.text = self.data.level
    SetTopLevelImg(self.data.level, self.lv_img, self, self.level)
    local param = {}
    param['is_can_click'] = false
    param["is_squared"] = false
    param["is_hide_frame"] = false
    param["size"] = 60
    param["role_data"] = self.data
    if not self.role_icon then
        self.role_icon = RoleIcon(self.icon_bg)
    end
    self.role_icon:SetData(param)

    self.vip.text = string.format(ConfigLanguage.Common.Vip, self.data.viplv)
    self.power.text = self.data.power
    self.name.text = self.data.name
end
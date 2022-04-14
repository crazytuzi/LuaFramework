FriendApplyItem = FriendApplyItem or class("FriendApplyItem", BaseItem)
local FriendApplyItem = FriendApplyItem

function FriendApplyItem:ctor(parent_node, layer)
    self.abName = "mail"
    self.assetName = "FriendApplyItem"
    self.layer = layer

    --self.model = 2222222222222end:GetInstance()
    FriendApplyItem.super.Load(self)
end

function FriendApplyItem:dctor()
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
end

function FriendApplyItem:LoadCallBack()
    self.nodes = {
        "icon_bg", "level_bg/level", "name", "vip", "power", "blackbtn", "addbtn", "deletebtn",
    }
    self:GetChildren(self.nodes)
    self.level = GetText(self.level)
    self.name = GetText(self.name)
    self.vip = GetText(self.vip)
    self.power = GetText(self.power)
    self:AddEvent()

    self:UpdateView()
end

function FriendApplyItem:AddEvent()
    local function call_back(target, x, y)
        FriendController:GetInstance():RequestAccept(self.data.id)
    end
    AddClickEvent(self.addbtn.gameObject, call_back)

    local function call_back(target, x, y)
        FriendController:GetInstance():RequestAddBlack(self.data.id)
    end
    AddClickEvent(self.blackbtn.gameObject, call_back)

    local function call_back(target, x, y)
        FriendController:GetInstance():RequestRefuse(self.data.id)
    end
    AddClickEvent(self.deletebtn.gameObject, call_back)
end

--data:p_role_base
function FriendApplyItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function FriendApplyItem:UpdateView()
    self.level.text = self.data.level
    self.vip.text = string.format(ConfigLanguage.Common.Vip, self.data.viplv)
    self.power.text = self.data.power

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
    self.name.text = self.data.name
end
UpShelfThreeItem = UpShelfThreeItem or class("UpShelfThreeItem",BaseCloneItem)
local UpShelfThreeItem = UpShelfThreeItem

function UpShelfThreeItem:ctor(obj,parent_node,layer)
    --self.abName = "market"
    --self.assetName = "BuyMarketLeftItem"
    --self.layer = layer
    --self.parentPanel = parent_node;
    UpShelfThreeItem.super.Load(self)
    self.model = MarketModel:GetInstance()
    --BuyMarketLeftItem.super.Load(self)
end
function UpShelfThreeItem:dctor()
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
end

function UpShelfThreeItem:LoadCallBack()
    self.nodes =
    {
        "friendIcon",
        "role_icon",
        "friendName",
        "friendVip",
        "select",
        "click",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.friendName = GetText(self.friendName)
    self.friendVip = GetText(self.friendVip)
   -- self.role_icon = GetImage(self.role_icon)
    self:InitUI()
    self:AddEvent()
end


function UpShelfThreeItem:InitUI()

end

function UpShelfThreeItem:AddEvent()
    function call_back()
        GlobalEvent:Brocast(MarketEvent.UpShelfMarketClickRole,self.data)
       -- UpShelfMarketClickRole
    end
    AddButtonEvent(self.click.gameObject,call_back)
end

function UpShelfThreeItem:SetData(data)
    self.data = data
    self:UpdateItem()
end
function UpShelfThreeItem:UpdateItem()
    local friend = FriendModel:GetInstance():GetPFriend(self.data)
    if friend then
        local role = friend.base
        self:UpdateRoleInfo(role)
    end
end

function UpShelfThreeItem:UpdateRoleInfo(role)
    self.friendName.text = role.name
    --if role.gender == 1 then
    --    lua_resMgr:SetImageTexture(self,self.role_icon, 'main_image', 'img_role_head_1',true)
    --else
    --    lua_resMgr:SetImageTexture(self,self.role_icon, 'main_image', 'img_role_head_2',true)
    --end
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    --param["is_squared"] = true
    --param["is_hide_frame"] = true
    param["size"] = 65
    param["uploading_cb"] = uploading_cb
    param["role_data"] = role
    self.role_icon1 = RoleIcon(self.role_icon)
    self.role_icon1:SetData(param)
    self.friendVip.text = string.format(ConfigLanguage.Common.Vip, role.viplv)
end

function UpShelfThreeItem:SetSelect(isShow)
    SetVisible(self.select,isShow)
end
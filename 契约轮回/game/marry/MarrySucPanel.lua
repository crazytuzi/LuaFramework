---
--- Created by  Administrator
--- DateTime: 2019/6/12 17:05
---
MarrySucPanel = MarrySucPanel or class("MarrySucPanel", BasePanel)
local this = MarrySucPanel

function MarrySucPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "MarrySucPanel"
    self.image_ab = "marry_image";
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.model = MarryModel:GetInstance()
    self.role =  RoleInfoModel.GetInstance():GetMainRoleData()
end

function MarrySucPanel:Open(data)
    self.data = data
    MarrySucPanel.super.Open(self)
end

function MarrySucPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)

    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    if self.role_icon2 then
        self.role_icon2:destroy()
        self.role_icon2 = nil
    end
end

function MarrySucPanel:LoadCallBack()
    self.nodes = {
        "closeBtn","okBtn","myObj/role_bg/role_icon","enemyObj/enemy_bg/enemy_icon",
        "myObj/role_bg/level_bg/level",
        "enemyObj/enemy_bg/level_bg/enemyLevel","myObj/myName","enemyObj/enemyName",
    }
    self:GetChildren(self.nodes)
    --self.enemy_icon = GetImage(self.enemy_icon)
    self.enemyLevel = GetText(self.enemyLevel)
    self.enemyName = GetText(self.enemyName)

   -- self.role_icon = GetImage(self.role_icon)
    self.level = GetText(self.level)
    self.myName = GetText(self.myName)

    
    self:InitUI()
    self:AddEvent()
end

function MarrySucPanel:InitUI()
    local role = self.data.proposer
    local accepter = self.data.accepter
    self.level.text = role.level
    self.myName.text = role.name
    --local icon = "img_role_head_1"
    --if role.gender == 2 then
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
    param["size"] = 85
    param["uploading_cb"] = uploading_cb
    param["role_data"] = role
    self.role_icon1 = RoleIcon(self.role_icon)
    self.role_icon1:SetData(param)

    self.enemyLevel.text = accepter.level
    self.enemyName.text = accepter.name

    if self.role_icon2 then
        self.role_icon2:destroy()
        self.role_icon2 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    param["is_hide_frame"] = true
    param["size"] = 85
    param["uploading_cb"] = uploading_cb
    param["role_data"] = accepter
    self.role_icon2 = RoleIcon(self.enemy_icon)
    self.role_icon2:SetData(param)
    --local eicon = "img_role_head_1"
    --if accepter.gender == 2 then
    --    eicon = "img_role_head_2"
    --end
    --lua_resMgr:SetImageTexture(self,self.enemy_icon, 'main_image', eicon, true)

end

function MarrySucPanel:AddEvent()
    
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)
    
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(WeddingAppointmentPanel):Open()
        self:Close()
    end
    AddClickEvent(self.okBtn.gameObject,call_back)

end
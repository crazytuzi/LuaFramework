---
--- Created by  Administrator
--- DateTime: 2019/11/20 14:49
---
CompeteMatchLeftRoleItem = CompeteMatchLeftRoleItem or class("CompeteMatchLeftRoleItem", BaseCloneItem)
local this = CompeteMatchLeftRoleItem

function CompeteMatchLeftRoleItem:ctor(obj, parent_node, parent_panel)
    CompeteMatchLeftRoleItem.super.Load(self)
    self.events = {}
    self.model = CompeteModel:GetInstance()
end

function CompeteMatchLeftRoleItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
end

function CompeteMatchLeftRoleItem:LoadCallBack()
    self.nodes = {
        "nameObj","nameObj/name","roleIconParent"
    }
    self:GetChildren(self.nodes)
    SetVisible(self.nameObj,false)
    self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()
end

function CompeteMatchLeftRoleItem:InitUI()

end

function CompeteMatchLeftRoleItem:AddEvent()

end
--posType  1 左 2右 3中
function CompeteMatchLeftRoleItem:SetData(groupPos,rolePos,posType)
    self.groupPos = groupPos --分组坐标
    self.rolePos = rolePos  --角色分组坐标
    self.posType = posType
    local num = math.floor(self.groupPos / 100)
    local y = 0
    if num == 1 then
        y = 83
    elseif num == 2 then
        y = 170
    elseif num == 3 then
        y = 320
    end


    if groupPos == 0 and rolePos == 0 and posType == 0 then --冠军
        SetLocalPosition(self.nameObj,90,-50,0)
    else
        if posType == 2 then

                if rolePos == 2 then
                    SetLocalPositionY(self.transform,self.transform.position.y - y)
                end


            if num == 1 then
                SetLocalPosition(self.nameObj,153,0,0)
            else
                SetLocalPosition(self.nameObj,70,-50,0)
            end
        elseif posType == 1 then

                if rolePos == 2 then
                    SetLocalPositionY(self.transform,self.transform.position.y - y)
                end

            if num == 1 then
                SetLocalPosition(self.nameObj,0,0,0)
            else
                SetLocalPosition(self.nameObj,90,-50,0)
            end
        else
            if rolePos == 2 then
                SetLocalPositionX(self.transform,self.transform.position.x + 220)
            end
            SetLocalPosition(self.nameObj,70,-50,0)
        end

    end

   -- self.isNull = isNull --是否轮空
end

function CompeteMatchLeftRoleItem:UpdateInfo(roleData,isNull)
    self.role_data = roleData
    if not roleData then
        SetVisible(self.nameObj,false)
        SetVisible(self.roleIconParent,false)
        return
    end
    SetVisible(self.roleIconParent,true)
    SetVisible(self.nameObj,true)


    if self.model.isCross then --跨服
        self.name.text = "S."..roleData.role.zoneid..roleData.role.name
    else
        self.name.text = roleData.role.name
    end
    --if self.role_icon1 then
    --    self.role_icon1:destroy()
    --    self.role_icon1 = nil
    --end

    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    --param["is_hide_frame"] = true
    param["size"] = 70
    param["uploading_cb"] = uploading_cb
    param["role_data"] = roleData.role
    param["is_can_click"] = true
    local function Click_fun()
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.roleIconParent)
        panel:Open(roleData.role)
    end
    param["click_fun"] = handler(self,self.Click,roleData)
    if not self.role_icon1  then
        self.role_icon1 = RoleIcon(self.roleIconParent)
    end
    self.role_icon1:SetData(param)
end

function CompeteMatchLeftRoleItem:Click(roleData)
    local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.roleIconParent)
    panel:Open(self.role_data.role)
end
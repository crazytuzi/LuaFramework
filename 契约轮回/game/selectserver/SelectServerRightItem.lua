---
--- Created by  Administrator
--- DateTime: 2019/2/21 11:47
---
SelectServerRightItem = SelectServerRightItem or class("SelectServerRightItem", BaseCloneItem)
local this = SelectServerRightItem

function SelectServerRightItem:ctor(obj, parent_node, parent_panel)
    SelectServerRightItem.super.Load(self)
    self.model = SelectServerModel:GetInstance()
    self.events = {}
end

function SelectServerRightItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function SelectServerRightItem:LoadCallBack()
    self.nodes = {
        "serverName","sign","isNew","bg","noData","haveData","haveData/head","haveData/roleLv","haveData/roleName"
    }
    self:GetChildren(self.nodes)
    self.serverName = GetText(self.serverName)
    self.sign = GetImage(self.sign)
    self.roleLv = GetText(self.roleLv)
    self.roleName = GetText(self.roleName)
    self.head = GetImage(self.head)
    self:InitUI()
    self:AddEvent()
end

function SelectServerRightItem:InitUI()

end

function SelectServerRightItem:AddEvent()
    local function call_back()
        self.model.curSer = self.data
        GlobalEvent:Brocast(SelectServerEvent.SelectServerRightClick,nil)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end
function SelectServerRightItem:SetData(data)
    self.data = data
    self:SetInfo()
end

function SelectServerRightItem:SetInfo()
    self.serverName.text = self.data.name
    self:SetFlag()
    self:SetRoleData()
end
function SelectServerRightItem:SetFlag()
    local flag = self.model:GetServerState(self.data)
    if flag == 0 then  --维护
        SetVisible(self.isNew,false)
        lua_resMgr:SetImageTexture(self, self.sign, "selectserver_image", "selectSer_gray", true);

    elseif flag == 1 then --流畅
        SetVisible(self.isNew,false)
        lua_resMgr:SetImageTexture(self, self.sign, "selectserver_image", "selectSer_green", true);
    elseif flag == 2 then --推挤
        SetVisible(self.isNew,false)
        lua_resMgr:SetImageTexture(self, self.sign, "selectserver_image", "selectSer_green", true);
    else --火爆
        SetVisible(self.isNew,false)
        lua_resMgr:SetImageTexture(self, self.sign, "selectserver_image", "selectSer_red", true);
    end
end

function SelectServerRightItem:SetRoleData()
    local isHaveDate,tab = self.model:IsLatelySer(self.data.sid)
    if isHaveDate then
        SetVisible(self.haveData,true)
        SetVisible(self.noData,false)
        self.roleName.text = tab.name
        self.roleLv.text ="Level"..tab.level
        self:SetHead(tab)
    else
        SetVisible(self.haveData,false)
        SetVisible(self.noData,true)
    end
end
function SelectServerRightItem:SetHead(tab)
    local key = tab.career.."@"..tab.wake
    if Config.db_wake[key] then
        local headName = Config.db_wake[key].pic
        lua_resMgr:SetImageTexture(self, self.head, "main_image", headName, true);
    end

end
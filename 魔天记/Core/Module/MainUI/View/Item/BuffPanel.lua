require "Core.Module.Common.UIComponent"
require "Core.Module.MainUI.View.Item.BuffItem"

BuffPanel = class("BuffPanel", UIComponent)

local ShowMaxBuff = 6;

function BuffPanel:New(transform)
    self = { };
    setmetatable(self, { __index = BuffPanel });
    if (transform) then
        self:Init(transform);
    end
    return self;
end

function BuffPanel:SetRole(role)
    if (self._role ~= role) then
        if (self._buffCtrl) then
            self._buffCtrl:RemoveListener(self, BuffPanel._BuffChangeHandler)
            self._buffCtrl = nil;
        end
        self:_CleraAllBuff();
        if (role) then
            self._buffCtrl = role:GetBuffController()
            if (self._buffCtrl) then
                self:_InitAllBuff();
                self._buffCtrl:AddListener(self, BuffPanel._BuffChangeHandler);
            end
        end
        self._role = role
    end
end

function BuffPanel:_BuffChangeHandler(event, buff)
    if (event == BuffController.EVENT_ADDBUFF) then
        self:_AddBuff(buff);
    elseif (event == BuffController.EVENT_REMOVEBUFF) then
        self:_RemoveBuff();
    elseif (event == BuffController.EVENT_REMOVEALLBUFF) then
        self:_RemoveBuff();
    end
end

function BuffPanel:_InitAllBuff()
    local buffs = self:_GetShowBuffs();
    local len = #buffs;
    for i = 1, len do
        self:_AddBuff(buffs[i]);
    end
end

function BuffPanel:_CleraAllBuff()
    if (self._items) then
        local len = #self._items;
        for i = 1, len do
            local item = self._items[i];
            item:SetBuff(nil)
        end
    end
end

function BuffPanel:_GetShowBuffs()
    local rBuff = {};
    if (self._buffCtrl) then
        local buffs = self._buffCtrl:GetBuffs();
        local len = #buffs;
        for i = 1, len do            
            local buff = buffs[i];
            if (buff.info.icon_id ~= "") then
                table.insert(rBuff,buff);
            end
        end
    end
    return rBuff
end

function BuffPanel:_RefAllBuff()
    if (self._buffCtrl) then
        local len = #self._items;
        local buffs = self:_GetShowBuffs();
        local sIndex = #buffs - len;
        if (sIndex < 0) then sIndex = 0 end
        for i = 1, len do
            local item = self._items[i];
            item:SetBuff(buffs[sIndex + i])
        end
    else
        self:_CleraAllBuff()
    end
end



function BuffPanel:_AddBuff(buff)
    if (self._buffCtrl and buff.info.icon_id ~= "") then
        local len = #self._items;
        if (len < ShowMaxBuff) then
            local buffs = self:_GetShowBuffs();
            if (#buffs > len) then
                local item = BuffItem:New(NGUITools.AddChild(self._gameObject, self._itemPrefab).transform, buff);
                table.insert(self._items, item);
                self:_ttt();
            else
                self:_RefAllBuff();
            end
        else
            self:_RefAllBuff();
        end
    end
end

function BuffPanel:_RemoveBuff()
    self:_RefAllBuff();
end

function BuffPanel:_ttt()
    if (self._buffCtrl) then
        local len = #self._items;
        for i = 1, len do
            local item = self._items[i];
            local pt = item.transform.localPosition;
            pt.x =(i - 1) * 32;
            Util.SetLocalPos(item.transform, pt);
        end
    end
end

function BuffPanel:_Init()
    self._items = { };
    self._itemPrefab = UIUtil.GetChildByName(self._transform, "buffItem").gameObject;
    Util.SetLocalPos(self._itemPrefab, Vector3.New(0, -18, 0));
    self._onClick = function(go) self:_OnClick() end
    UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
end

function BuffPanel:_OnClick()
    if (#self:_GetShowBuffs() > 0) then
        ModuleManager.SendNotification(BuffListNotes.OPEN_BUFFLIST, { role = self._role, pt = self._itemPrefab.transform.position });
    end
end

function BuffPanel:Update()
    if (self._role and self._items) then
        local len = #self._items;
        for i = 1, len do
            local item = self._items[i];
            item:Update();
        end
    end
end

function BuffPanel:_Dispose()
    if (self._items) then
        local len = #self._items;
        self:SetRole(nil);
        for i = 1, len do
            local item = self._items[i];
            item:Dispose()
        end
        UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
        self._onClick = nil;
        self._items = nil;
    end
end

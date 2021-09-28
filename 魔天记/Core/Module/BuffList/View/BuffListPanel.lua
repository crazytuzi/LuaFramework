require "Core.Module.Common.Panel"
require "Core.Module.BuffList.View.Item.BuffListItem"

BuffListPanel = class("BuffListPanel", Panel);
function BuffListPanel:New()
    self = { };
    setmetatable(self, { __index = BuffListPanel });
    return self
end 

function BuffListPanel:_Init()
    if self:HasMask() then
        local sp = UIUtil.GetComponent(self._trsMask.gameObject, "UISprite");
        if (sp) then
            sp.color = Color.New(1, 1, 1, 1 / 0xFF)
        end
    end
    self:_InitReference();
    self:_InitListener();
end

function BuffListPanel:GetUIOpenSoundName( )
    return ""
end

function BuffListPanel:_InitReference()
    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, BuffListItem);
    self._timer = Timer.New( function(val) self:_OnTimeHandler(val) end, 0.3, -1, false);
    self._timer:Start();
end

function BuffListPanel:_InitListener()

end

function BuffListPanel:_OnTimeHandler()
    if (self._buffCtrl) then
        local items = self._phalanx:GetItems()
        if (items) then
            for k, v in ipairs(items) do
                v.itemLogic:Update()
            end
        end
    end
end

function BuffListPanel:ClosePanel()
    ModuleManager.SendNotification(BuffListNotes.CLOSE_BUFFLIST);
end

function BuffListPanel:_OnClickMask()
    self:ClosePanel();
end

function BuffListPanel:SetData(data)
    Util.SetPos(self._trsContent, data.pt);
    self:SetRole(data.role)
end

function BuffListPanel:SetRole(role)
    if (self._role ~= role) then
        if (self._buffCtrl) then
            self._buffCtrl:RemoveListener(self, BuffListPanel._BuffChangeHandler)
            self._buffCtrl = nil;
        end
        if (role) then
            self._buffCtrl = role:GetBuffController()
        end
        self:_BuffChangeHandler();
        if (self._buffCtrl) then
            self._buffCtrl:AddListener(self, BuffListPanel._BuffChangeHandler);
        end
        self._role = role
    end
end

function BuffListPanel:_GetShowBuffs()
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

function BuffListPanel:_BuffChangeHandler()
    if (self._buffCtrl) then
        local buffs = self:_GetShowBuffs();
        if (#buffs > 0) then
            self._phalanx:Build(#buffs, 1, buffs);
            self._scrollView:ResetPosition();
        else
            self:ClosePanel();
        end
    end
end

function BuffListPanel:_Dispose()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    self:SetRole(nil);
    self:_DisposeListener();
    self:_DisposeReference();
end

function BuffListPanel:_DisposeListener()

end

function BuffListPanel:_DisposeReference()
    self._trsList = nil;
    self._scrollView = nil;
    self._scrollPanel = nil;
    self._phalanx:Dispose();
    self._phalanx = nil;
end
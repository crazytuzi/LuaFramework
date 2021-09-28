require "Core.Module.Common.Panel"

MobaoNoticePanel = class("MobaoNoticePanel", Panel);
function MobaoNoticePanel:New()
    self = { };
    setmetatable(self, { __index = MobaoNoticePanel });
    return self
end

function MobaoNoticePanel:IsFixDepth()
    return true
end

function MobaoNoticePanel:_Opened()
    self._uiEffect = UIUtil.GetUIEffect("ui_trump_active", self._trsContent, self._imgIcon, 1);     
end

function MobaoNoticePanel:GetUIOpenSoundName( )
    return ""
end

function MobaoNoticePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function MobaoNoticePanel:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgIcon");
    self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName")
end

function MobaoNoticePanel:_InitListener()
    self._onClickItem = function(go) self:_OnClickItem(self) end
    UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end

function MobaoNoticePanel:_OnClickItem()
    ModuleManager.SendNotification(NewTrumpNotes.OPEN_MOBAO_ACTIVE, self.data)
    ModuleManager.SendNotification(NewTrumpNotes.CLOSE_MOBAO_NOTICE)
end


function MobaoNoticePanel:UpdatePanel(data)
    self.data = data
    if (self.data) then
        self._imgIcon.spriteName = tostring(self.data.icon)
        self._txtName.text = tostring(self.data.name)
        self._txtName.color = ColorDataManager.GetColorByQuality(self.data.quality)
    end
end

function MobaoNoticePanel:_Dispose()
    UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
    if (self._uiEffect) then
        Resourcer.Recycle(self._uiEffect, false);
        self._uiEffect = nil;
    end
    self:_DisposeReference();
end

function MobaoNoticePanel:_DisposeReference()
    self._imgIcon = nil;
    self._txtName = nil
end

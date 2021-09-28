require "Core.Module.Common.Panel"

NewTrumpNoticePanel = class("NewTrumpNoticePanel", Panel);
function NewTrumpNoticePanel:New()
    self = { };
    setmetatable(self, { __index = NewTrumpNoticePanel });
    return self
end

function NewTrumpNoticePanel:IsFixDepth()
    return true
end

function NewTrumpNoticePanel:_Opened()
    self._uiEffect = UIUtil.GetUIEffect("ui_trump_active", self._trsContent, self._imgIcon, 1);     
end

function NewTrumpNoticePanel:GetUIOpenSoundName( )
    return ""
end

function NewTrumpNoticePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function NewTrumpNoticePanel:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgIcon");
    self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName")
end

function NewTrumpNoticePanel:_InitListener()
    self._onClickItem = function(go) self:_OnClickItem(self) end
    UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end

function NewTrumpNoticePanel:_OnClickItem()
    NewTrumpProxy.SendActiveTrump(self.data.id)
    ModuleManager.SendNotification(NewTrumpNotes.CLOSE_NEWTRUMPNOTICEPANEL)
end


function NewTrumpNoticePanel:UpdatePanel(data)
    self.data = data
    if (self.data) then
        self._imgIcon.spriteName = tostring(self.data.configData.icon)
        self._txtName.text = tostring(self.data.configData.name)
        self._txtName.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
    end
end

function NewTrumpNoticePanel:_Dispose()
    UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
    if (self._uiEffect) then
        Resourcer.Recycle(self._uiEffect, false);
        self._uiEffect = nil;
    end
    self:_DisposeReference();
end

function NewTrumpNoticePanel:_DisposeReference()
    self._imgIcon = nil;
    self._txtName = nil
end

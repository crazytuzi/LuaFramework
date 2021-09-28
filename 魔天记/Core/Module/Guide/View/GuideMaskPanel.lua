require "Core.Module.Common.Panel"

GuideMaskPanel = class("GuideMaskPanel", Panel);
function GuideMaskPanel:New()
    self = { };
    setmetatable(self, { __index = GuideMaskPanel });
    return self
end


function GuideMaskPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function GuideMaskPanel:_InitReference()
    --    self._setAnchor = UIUtil.GetComponent(self._trsContent, "SetAnchor")
    self._imgMask1 = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgMask1");
    self._imgMask2 = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgMask2");
    self._imgMask3 = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgMask3");
    self._imgMask4 = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgMask4");
    
end

 
 
function GuideMaskPanel:_InitListener()

end

function GuideMaskPanel:_Dispose()
    self:_DisposeReference();
end

function GuideMaskPanel:_DisposeReference()
    self._imgMask1 = nil;
    self._imgMask2 = nil;
    self._imgMask3 = nil;
    self._imgMask4 = nil;
end

function GuideMaskPanel:UpdatePanel(widget)
    self.widget = widget
    local width = widget.width
    local height = widget.height
    Util.SetLocalPos(self._imgMask1, - width * 0.5, 0, 0)
    Util.SetLocalPos(self._imgMask2, width * 0.5, 0, 0)
    Util.SetLocalPos(self._imgMask3, 0, height * 0.5, 0)
    Util.SetLocalPos(self._imgMask4, 0, - height * 0.5, 0)
    self._imgMask3.width = width
    self._imgMask4.width = width
    local widgetPos = widget.cachedTransform.position
    --        log(widgetPos)
    --    self._setAnchor:Set(widget)
    --    local temp = UICamera.currentCamera:WorldToScreenPoint(widgetPos);
    --    local widgetPos = UICamera.currentCamera:ScreenToWorldPoint(temp)
    --    log(widgetPos)
       Util.SetPos(self._trsContent, widgetPos.x, widgetPos.y, widgetPos.z)
end

function GuideMaskPanel:_OnClickItem()
    GuideManager.DoNextStep()
    ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDEMASKPANEL)
end
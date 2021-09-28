require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Guide.GuideNotes"
require "Core.Module.Guide.View.GuideMaskPanel"
require "Core.Module.Guide.View.GuideClickPanel"
require "Core.Module.Guide.View.GuideSelectRolePanel";


GuideMediator = Mediator:New();
function GuideMediator:OnRegister()

end

function GuideMediator:_ListNotificationInterests()
    return
    {
        GuideNotes.OPEN_GUIDEMASKPANEL,
        GuideNotes.CLOSE_GUIDEMASKPANEL,
        GuideNotes.UPDATE_GUIDEMASKPANEL,
        GuideNotes.CLOSE_GUIDE,
        GuideNotes.OPEN_GUIDE_CLICK,
        GuideNotes.CLOSE_GUIDE_CLICK,
        GuideNotes.OPEN_GUIDE_SELECT_ROLE,
        GuideNotes.CLOSE_GUIDE_SELECT_ROLE,
    }
end  

function GuideMediator:_HandleNotification(notification)
    if (notification:GetName() == GuideNotes.OPEN_GUIDEMASKPANEL) then
        if (self._guideMaskPanel == nil) then
            self._guideMaskPanel = PanelManager.BuildPanel(ResID.UI_GUIDEMASKPAENL, GuideMaskPanel);
        end
        self._guideMaskPanel:UpdatePanel(notification:GetBody())
    elseif notification:GetName() == GuideNotes.CLOSE_GUIDEMASKPANEL then
        if (self._guideMaskPanel ~= nil) then
            PanelManager.RecyclePanel(self._guideMaskPanel, ResID.UI_GUIDEMASKPAENL)
            self._guideMaskPanel = nil
        end
    elseif notification:GetName() == GuideNotes.UPDATE_GUIDEMASKPANEL then
        if (self._guideMaskPanel ~= nil) then
            self._guideMaskPanel:UpdatePanel(notification:GetBody())
        end
    elseif notification:GetName() == GuideNotes.CLOSE_GUIDE then
        --关闭所有引导界面.
        self:RemoveClickPanel();

    elseif notification:GetName() == GuideNotes.OPEN_GUIDE_CLICK then
        if (self._clickPanel == nil) then
            self._clickPanel = PanelManager.BuildPanel(ResID.UI_GUIDECLICKPAENL, GuideClickPanel);
        end
        local p = notification:GetBody();
        self._clickPanel:UpdateGuide(p);
    elseif notification:GetName() == GuideNotes.CLOSE_GUIDE_CLICK then
        self:RemoveClickPanel();

     elseif notification:GetName() == GuideNotes.OPEN_GUIDE_SELECT_ROLE then
        if (self._selectPanel == nil) then
            self._selectPanel = PanelManager.BuildPanel(ResID.UI_GUIDESELECTROLEPANEL, GuideSelectRolePanel);
        end
        local p = notification:GetBody();
        self._selectPanel:UpdateGuide(p);
    elseif notification:GetName() == GuideNotes.CLOSE_GUIDE_SELECT_ROLE then
        if (self._selectPanel ~= nil) then
            PanelManager.RecyclePanel(self._selectPanel, ResID.UI_GUIDESELECTROLEPANEL)
            self._selectPanel = nil
        end
    end

end

function GuideMediator:OnRemove()

end

function GuideMediator:RemoveClickPanel()
    if (self._clickPanel ~= nil) then
        PanelManager.RecyclePanel(self._clickPanel, ResID.UI_GUIDECLICKPAENL)
        self._clickPanel = nil
    end
    if (self._selectPanel ~= nil) then
        PanelManager.RecyclePanel(self._selectPanel, ResID.UI_GUIDESELECTROLEPANEL)
        self._selectPanel = nil
    end
end


require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.XLTInstance.XLTInstanceNotes"
require "Core.Module.XLTInstance.View.XLTInstancePanel"
require "Core.Module.XLTInstance.View.XLTChuangGuanAwardPanel"
require "Core.Module.XLTInstance.View.XLTSaoDangAwardPanel"
require "Core.Module.XLTInstance.View.XLTInstanceDecPanel"

XLTInstanceMediator = Mediator:New();
function XLTInstanceMediator:OnRegister()

end

function XLTInstanceMediator:_ListNotificationInterests()
    return {
        [1] = XLTInstanceNotes.OPEN_XLTINSTANCE_PANEL,
        [2] = XLTInstanceNotes.CLOSE_XLTINSTANCE_PANEL,

        [3] = XLTInstanceNotes.OPEN_XLTCHUANGGUANAWARDPANEL,
        [4] = XLTInstanceNotes.CLOSE_XLTCHUANGGUANAWARDPANEL,

        [5] = XLTInstanceNotes.OPEN_XLTSAODANGAWARDPANEL,
        [6] = XLTInstanceNotes.CLOSE_XLTSAODANGAWARDPANEL,

        [7] = XLTInstanceNotes.OPEN_XLTINSTANCEDECPANEL,
        [8] = XLTInstanceNotes.CLOSE_XLTINSTANCEDECPANEL,

    };
end

function XLTInstanceMediator:_HandleNotification(notification)

    if notification:GetName() == XLTInstanceNotes.OPEN_XLTINSTANCE_PANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_XLTINSTANCEPANEL, XLTInstancePanel,true);
        end
    elseif notification:GetName() == XLTInstanceNotes.CLOSE_XLTINSTANCE_PANEL then

        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_XLTINSTANCEPANEL)
            self._panel = nil
        end

        -------------------------------------------------------------
    elseif notification:GetName() == XLTInstanceNotes.OPEN_XLTCHUANGGUANAWARDPANEL then
        if (self._chuangGuanAwardPanel == nil) then
            self._chuangGuanAwardPanel = PanelManager.BuildPanel(ResID.UI_XLTCHUANGGUANAWARDPANEL, XLTChuangGuanAwardPanel);
        end
    elseif notification:GetName() == XLTInstanceNotes.CLOSE_XLTCHUANGGUANAWARDPANEL then
        if (self._chuangGuanAwardPanel ~= nil) then
            PanelManager.RecyclePanel(self._chuangGuanAwardPanel)
            self._chuangGuanAwardPanel = nil
        end

        ------------------------- XLTSaoDangAwardPanel --------------------------------------
    elseif notification:GetName() == XLTInstanceNotes.OPEN_XLTSAODANGAWARDPANEL then
        if (self._saoDangAwardPanel == nil) then
            self._saoDangAwardPanel = PanelManager.BuildPanel(ResID.UI_XLTSAODANGAWARDPANEL, XLTSaoDangAwardPanel);
        end
    elseif notification:GetName() == XLTInstanceNotes.CLOSE_XLTSAODANGAWARDPANEL then
        if (self._saoDangAwardPanel ~= nil) then
            PanelManager.RecyclePanel(self._saoDangAwardPanel)
            self._saoDangAwardPanel = nil
        end



        -----------------------------------------------------------------------------

    elseif notification:GetName() == XLTInstanceNotes.OPEN_XLTINSTANCEDECPANEL then
        if (self._instanceDecPanel == nil) then
            self._instanceDecPanel = PanelManager.BuildPanel(ResID.UI_XLTINSTANCEDECPANEL, XLTInstanceDecPanel);
        end
    elseif notification:GetName() == XLTInstanceNotes.CLOSE_XLTINSTANCEDECPANEL then
        if (self._instanceDecPanel ~= nil) then
            PanelManager.RecyclePanel(self._instanceDecPanel)
            self._instanceDecPanel = nil
        end








    end

end

function XLTInstanceMediator:OnRemove()

end


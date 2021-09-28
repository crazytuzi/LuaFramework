require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.XMBoss.XMBossNotes"

require "Core.Module.XMBoss.View.XMBossPanel"
require "Core.Module.XMBoss.View.XMHuoDongJinDuRankPanel"
require "Core.Module.XMBoss.View.XMBossShouLingJieShaoPanel"
require "Core.Module.XMBoss.View.XMBossGameResultPanel"
require "Core.Module.XMBoss.View.XMBossAwardPanel"
require "Core.Module.XMBoss.View.XMBossJoinInfosPanel"
require "Core.Module.XMBoss.View.XMBossFuLiPanel"

XMBossMediator = Mediator:New();
function XMBossMediator:OnRegister()

end

function XMBossMediator:_ListNotificationInterests()
    return {
        [1] = XMBossNotes.OPEN_XMBOSSPANEL,
        [2] = XMBossNotes.CLOSE_XMBOSSPANEL,

        [3] = XMBossNotes.OPEN_XMHUODONGJINDURANKPANEL,
        [4] = XMBossNotes.CLOSE_XMHUODONGJINDURANKPANEL,

        [5] = XMBossNotes.OPEN_XMBOSSSHOULINGJIESHAOPANEL,
        [6] = XMBossNotes.CLOSE_XMBOSSSHOULINGJIESHAOPANEL,

        [7] = XMBossNotes.OPEN_XMBOSSGAMERESULTPANEL,
        [8] = XMBossNotes.CLOSE_XMBOSSGAMERESULTPANEL,

        [9] = XMBossNotes.OPEN_XMBOSSAWARDPANEL,
        [10] = XMBossNotes.CLOSE_XMBOSSAWARDPANEL,


        [11] = XMBossNotes.OPEN_XMBOSSJOININFOSPANEL,
        [12] = XMBossNotes.CLOSE_XMBOSSJOININFOSPANEL,

        [13] = XMBossNotes.OPEN_XMBOSSFULIPANEL,
        [14] = XMBossNotes.CLOSE_XMBOSSFULIPANEL,


    };
end

function XMBossMediator:_HandleNotification(notification)

    if notification:GetName() == XMBossNotes.OPEN_XMBOSSPANEL then
        if (self._XMBossPanel == nil) then
            self._XMBossPanel = PanelManager.BuildPanel(ResID.UI_XMBOSSPANEL, XMBossPanel,true);
        end


    elseif notification:GetName() == XMBossNotes.CLOSE_XMBOSSPANEL then

        if (self._XMBossPanel ~= nil) then
            PanelManager.RecyclePanel(self._XMBossPanel, ResID.UI_XMBOSSPANEL)
            self._XMBossPanel = nil
        end

        -----------------------------------------------------------------------------------------------------------------------
    elseif notification:GetName() == XMBossNotes.OPEN_XMHUODONGJINDURANKPANEL then
        if (self._XMHuoDongJinDuRankPanel == nil) then
            self._XMHuoDongJinDuRankPanel = PanelManager.BuildPanel(ResID.UI_XMHUODONGJINDURANKPANEL, XMHuoDongJinDuRankPanel);
        end


    elseif notification:GetName() == XMBossNotes.CLOSE_XMHUODONGJINDURANKPANEL then

        if (self._XMHuoDongJinDuRankPanel ~= nil) then
            PanelManager.RecyclePanel(self._XMHuoDongJinDuRankPanel, ResID.UI_XMHUODONGJINDURANKPANEL)
            self._XMHuoDongJinDuRankPanel = nil
        end


        -----------------------------------------------------------------------------------------------------------------------------
    elseif notification:GetName() == XMBossNotes.OPEN_XMBOSSSHOULINGJIESHAOPANEL then
        if (self._XMBossShouLingJieShaoPanel == nil) then
            self._XMBossShouLingJieShaoPanel = PanelManager.BuildPanel(ResID.UI_XMBOSSSHOULINGJIESHAOPANEL, XMBossShouLingJieShaoPanel);
        end


    elseif notification:GetName() == XMBossNotes.CLOSE_XMBOSSSHOULINGJIESHAOPANEL then

        if (self._XMBossShouLingJieShaoPanel ~= nil) then
            PanelManager.RecyclePanel(self._XMBossShouLingJieShaoPanel, ResID.UI_XMBOSSSHOULINGJIESHAOPANEL)
            self._XMBossShouLingJieShaoPanel = nil
        end

        --------------------------------------------------------------------------------------------------------------------------------------
    elseif notification:GetName() == XMBossNotes.OPEN_XMBOSSGAMERESULTPANEL then
        if (self._XMBossGameResultPanel == nil) then
            self._XMBossGameResultPanel = PanelManager.BuildPanel(ResID.UI_XMBOSSGAMERESULTPANEL, XMBossGameResultPanel);
        end
        local plData = notification:GetBody();
        self._XMBossGameResultPanel:SetData(plData);

    elseif notification:GetName() == XMBossNotes.CLOSE_XMBOSSGAMERESULTPANEL then

        if (self._XMBossGameResultPanel ~= nil) then
            PanelManager.RecyclePanel(self._XMBossGameResultPanel)
            self._XMBossGameResultPanel = nil
        end


        -----------------------------------------------------------------------------------------------------------
    elseif notification:GetName() == XMBossNotes.OPEN_XMBOSSAWARDPANEL then
        if (self._XMBossAwardPanel == nil) then
            self._XMBossAwardPanel = PanelManager.BuildPanel(ResID.UI_XMBOSSAWARDPANEL, XMBossAwardPanel);
        end

        local plData = notification:GetBody();
        self._XMBossAwardPanel:SetData(plData);

    elseif notification:GetName() == XMBossNotes.CLOSE_XMBOSSAWARDPANEL then

        if (self._XMBossAwardPanel ~= nil) then
            PanelManager.RecyclePanel(self._XMBossAwardPanel)
            self._XMBossAwardPanel = nil
        end




        -----------------------------------------------------------------------------------------------------------
    elseif notification:GetName() == XMBossNotes.OPEN_XMBOSSJOININFOSPANEL then
        if (self._XMBossJoinInfosPanel == nil) then
            self._XMBossJoinInfosPanel = PanelManager.BuildPanel(ResID.UI_XMBOSSJOININFOSPANEL, XMBossJoinInfosPanel);
        end

    elseif notification:GetName() == XMBossNotes.CLOSE_XMBOSSJOININFOSPANEL then

        if (self._XMBossJoinInfosPanel ~= nil) then
            PanelManager.RecyclePanel(self._XMBossJoinInfosPanel)
            self._XMBossJoinInfosPanel = nil
        end

        ---------------------------------------------------------------------------------------------

    elseif notification:GetName() == XMBossNotes.OPEN_XMBOSSFULIPANEL then
        if (self._XMBossFuLiPanel == nil) then
            self._XMBossFuLiPanel = PanelManager.BuildPanel(ResID.UI_XMBOSSFULIPANEL, XMBossFuLiPanel);
        end

    elseif notification:GetName() == XMBossNotes.CLOSE_XMBOSSFULIPANEL then

        if (self._XMBossFuLiPanel ~= nil) then
            PanelManager.RecyclePanel(self._XMBossFuLiPanel)
            self._XMBossFuLiPanel = nil
        end



    end


end

function XMBossMediator:OnRemove()

end


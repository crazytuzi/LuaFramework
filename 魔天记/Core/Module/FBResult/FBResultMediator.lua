require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.FBResult.FBResultNotes"

require "Core.Module.FBResult.View.SingleFBWinResultPanel"
require "Core.Module.FBResult.View.SingleFBFailResultPanel"
require "Core.Module.FBResult.View.TeamFBWinResultPanel"
require "Core.Module.FBResult.View.TeamFBFailResultPanel"
require "Core.Module.FBResult.View.PVPFBWinResultPanel"
require "Core.Module.FBResult.View.PVPFBFailResultPanel"

require "Core.Module.FBResult.View.XLTFailResultPanel"
require "Core.Module.FBResult.View.XLTWinResultPanel"
require "Core.Module.FBResult.View.EndlessTryResultPanel"

FBResultMediator = Mediator:New();
function FBResultMediator:OnRegister()

end

function FBResultMediator:_ListNotificationInterests()
    return {
        FBResultNotes.OPEN_SINGLEFBWINRESULTPANEL,
        FBResultNotes.CLOSE_SINGLEFBWINRESULTPANEL,

        FBResultNotes.OPEN_SINGLEFBFAILRESULTPANEL,
        FBResultNotes.CLOSE_SINGLEFBFAILRESULTPANEL,

        FBResultNotes.OPEN_TEAMFBWINRESULTPANEL,
        FBResultNotes.CLOSE_TEAMFBWINRESULTPANEL,

        FBResultNotes.OPEN_TEAMFBFAILRESULTPANEL,
        FBResultNotes.CLOSE_TEAMFBFAILRESULTPANEL,

        FBResultNotes.OPEN_PVPFBWINPANEL,
        FBResultNotes.CLOSE_PVPFBWINPANEL,

        FBResultNotes.OPEN_PVPFBFAILRESULTPANEL,
        FBResultNotes.CLOSE_PVPFBFAILRESULTPANEL,

        FBResultNotes.OPEN_XLTFAILRESULTPANEL,
        FBResultNotes.CLOSE_XLTFAILRESULTPANEL,

        FBResultNotes.OPEN_XLTWINRESULTPANEL,
        FBResultNotes.CLOSE_XLTWINRESULTPANEL,

        FBResultNotes.OPEN_INSPIRETRY_WIN_PANEL,
        FBResultNotes.CLOSE_INSPIRETRY_WIN_PANEL,
    };
end

--[[
S <-- 19:53:59.506, 0x030A, 0, {"instId":"750004","fItems":[{"am":2,"spId":301003},{"am":100,"spId":4},{"am":1000,"spId":1},{"am":1,"spId":301004}],"star":[5,2,1],"it":1,"time":40,"items":[{"am":2,"spId":301003},{"am":100,"spId":4},{"am":1000,"spId":1},{"am":1,"spId":301004}],"win":1,"harts":[{"s":99,"t":1,"h":11772,"id":"20100244","icon_id":"101000","l":81,"n":"赖义宇"}],"scene":{"x":-35,"y":55,"z":-955,"sid":"709999"}}
UnityEngine.Debug:Log(Object)
]]
function FBResultMediator:_HandleNotification(notification)
    local nn = notification:GetName()
    if nn == FBResultNotes.OPEN_SINGLEFBWINRESULTPANEL then


        if (self._singleFBWinResultPanel == nil) then
            PanelManager.HideAllPanels();
            self._singleFBWinResultPanel = PanelManager.BuildPanel(ResID.UI_SINGLEFBWINRESULTPANEL, SingleFBWinResultPanel, false);

            local data = notification:GetBody();
            self._singleFBWinResultPanel:SetData(data);

        end


    elseif nn == FBResultNotes.CLOSE_SINGLEFBWINRESULTPANEL then

        if (self._singleFBWinResultPanel ~= nil) then
            PanelManager.RevertAllPanels();
            PanelManager.RecyclePanel(self._singleFBWinResultPanel, ResID.UI_SINGLEFBWINRESULTPANEL)
            self._singleFBWinResultPanel = nil;
        end

    elseif nn == FBResultNotes.OPEN_SINGLEFBFAILRESULTPANEL then

        if (self._singleFBFailResultPanel == nil) then
            PanelManager.HideAllPanels();
            self._singleFBFailResultPanel = PanelManager.BuildPanel(ResID.UI_SINGLEFBFAILRESULTPANEL, SingleFBFailResultPanel, false);

            local data = notification:GetBody();
            self._singleFBFailResultPanel:SetData(data);

        end


    elseif nn == FBResultNotes.CLOSE_SINGLEFBFAILRESULTPANEL then

        if (self._singleFBFailResultPanel ~= nil) then
            PanelManager.RevertAllPanels();
            PanelManager.RecyclePanel(self._singleFBFailResultPanel, ResID.UI_SINGLEFBFAILRESULTPANEL)
            self._singleFBFailResultPanel = nil;
        end

        ---------------
    elseif nn == FBResultNotes.OPEN_TEAMFBWINRESULTPANEL then

        if (self._teamFBWinResultPanel == nil) then
            PanelManager.HideAllPanels();
            self._teamFBWinResultPanel = PanelManager.BuildPanel(ResID.UI_TEAMFBWINRESULTPANEL, TeamFBWinResultPanel, false);

            local data = notification:GetBody();
            self._teamFBWinResultPanel:SetData(data);
        end


    elseif nn == FBResultNotes.CLOSE_TEAMFBWINRESULTPANEL then

        if (self._teamFBWinResultPanel ~= nil) then
            PanelManager.RevertAllPanels();
            PanelManager.RecyclePanel(self._teamFBWinResultPanel, ResID.UI_TEAMFBWINRESULTPANEL)
            self._teamFBWinResultPanel = nil;
        end

        ---------------------------
    elseif nn == FBResultNotes.OPEN_TEAMFBFAILRESULTPANEL then

        if (self._teamFBFailResultPanel == nil) then
            PanelManager.HideAllPanels();
            self._teamFBFailResultPanel = PanelManager.BuildPanel(ResID.UI_TEAMFBFAILRESULTPANEL, TeamFBFailResultPanel, false);

            local data = notification:GetBody();
            self._teamFBFailResultPanel:SetData(data);

        end


    elseif nn == FBResultNotes.CLOSE_TEAMFBFAILRESULTPANEL then

        if (self._teamFBFailResultPanel ~= nil) then
            PanelManager.RevertAllPanels();
            PanelManager.RecyclePanel(self._teamFBFailResultPanel, ResID.UI_TEAMFBFAILRESULTPANEL)
            self._teamFBFailResultPanel = nil;
        end

        -----------------------------------
    elseif nn == FBResultNotes.OPEN_PVPFBWINPANEL then

        if (self._pvpFBWinPanel == nil) then
            PanelManager.HideAllPanels();
            self._pvpFBWinPanel = PanelManager.BuildPanel(ResID.UI_PVPFBWINRESULTPANEL, PVPFBWinResultPanel, false);

            local data = notification:GetBody();
            self._pvpFBWinPanel:SetData(data);
        end


    elseif nn == FBResultNotes.CLOSE_PVPFBWINPANEL then

        if (self._pvpFBWinPanel ~= nil) then
            PanelManager.RevertAllPanels();
            PanelManager.RecyclePanel(self._pvpFBWinPanel, ResID.UI_PVPFBWINRESULTPANEL)
            self._pvpFBWinPanel = nil;
        end

        ------------------------------------------

    elseif nn == FBResultNotes.OPEN_PVPFBFAILRESULTPANEL then

        if (self._pvpFBFailResultPanel == nil) then
            PanelManager.HideAllPanels();
            self._pvpFBFailResultPanel = PanelManager.BuildPanel(ResID.UI_PVPFBFAILRESULTPANEL, PVPFBFailResultPanel, false);

            local data = notification:GetBody();
            self._pvpFBFailResultPanel:SetData(data);
        end


    elseif nn == FBResultNotes.CLOSE_PVPFBFAILRESULTPANEL then

        if (self._pvpFBFailResultPanel ~= nil) then
            PanelManager.RevertAllPanels();
            PanelManager.RecyclePanel(self._pvpFBFailResultPanel, ResID.UI_PVPFBWINRESULTPANEL)
            self._pvpFBFailResultPanel = nil;
        end


        ----------------------------------------
    elseif nn == FBResultNotes.OPEN_XLTFAILRESULTPANEL then

        if (self._xltFailResultPanel == nil) then
            PanelManager.HideAllPanels();
            self._xltFailResultPanel = PanelManager.BuildPanel(ResID.UI_XLTFAILRESULTPANEL, XLTFailResultPanel, false);

            local data = notification:GetBody();
            self._xltFailResultPanel:SetData(data);
        end


    elseif nn == FBResultNotes.CLOSE_XLTFAILRESULTPANEL then

        if (self._xltFailResultPanel ~= nil) then
            PanelManager.RevertAllPanels();
            PanelManager.RecyclePanel(self._xltFailResultPanel, ResID.UI_XLTFAILRESULTPANEL)
            self._xltFailResultPanel = nil;
        end

        -----------------------------------------------

    elseif nn == FBResultNotes.OPEN_XLTWINRESULTPANEL then

        if (self._XLTWinResultPanel == nil) then
            PanelManager.HideAllPanels();
            self._XLTWinResultPanel = PanelManager.BuildPanel(ResID.UI_XLTWINRESULTPANEL, XLTWinResultPanel, false);

            local data = notification:GetBody();
            self._XLTWinResultPanel:SetData(data);
        end


    elseif nn == FBResultNotes.CLOSE_XLTWINRESULTPANEL then

        if (self._XLTWinResultPanel ~= nil) then
            PanelManager.RevertAllPanels();
            PanelManager.RecyclePanel(self._XLTWinResultPanel, ResID.UI_XLTWINRESULTPANEL)
            self._XLTWinResultPanel = nil;
        end

    elseif nn == FBResultNotes.OPEN_INSPIRETRY_WIN_PANEL then

        if (self._endlessPanel == nil) then
            PanelManager.HideAllPanels();
            self._endlessPanel = PanelManager.BuildPanel(ResID.UI_ENDLESSTRY_RESULT, EndlessTryResultPanel, false);

            local data = notification:GetBody();
            self._endlessPanel:SetData(data);
        end


    elseif nn == FBResultNotes.CLOSE_INSPIRETRY_WIN_PANEL then

        if (self._endlessPanel ~= nil) then
            PanelManager.RevertAllPanels();
            PanelManager.RecyclePanel(self._endlessPanel, ResID.UI_ENDLESSTRY_RESULT)
            self._endlessPanel = nil;
        end

    end

end

function FBResultMediator:OnRemove()

end


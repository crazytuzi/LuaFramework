require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Activity.ActivityNotes"
require "Core.Module.Activity.View.ActivityPanel"
require "Core.Module.Activity.View.ActivityNotifyPanel";
local ActivityTipPanel = require "Core.Module.Activity.View.ActivityTipPanel";

local ActivityOpenTimeLogPanel = require "Core.Module.Activity.View.ActivityOpenTimeLogPanel";

ActivityMediator = Mediator:New();
function ActivityMediator:OnRegister()

end

function ActivityMediator:_ListNotificationInterests()
    return {
        [1] = ActivityNotes.OPEN_ACTIVITY,
        [2] = ActivityNotes.CLOSE_ACTIVITY,
        [3] = ActivityNotes.OPEN_ACTIVITYNOTIFY,
        [4] = ActivityNotes.CLOSE_ACTIVITYNOTIFY,
        [5] = ActivityNotes.OPEN_ACTIVITYOPENTIMELOGPANEL,
        [6] = ActivityNotes.CLOSE_ACTIVITYOPENTIMELOGPANEL,

        [7] = ActivityNotes.OPEN_ACTIVITY_TIP,
        [8] = ActivityNotes.CLOSE_ACTIVITY_TIP
    };
end



function ActivityMediator:_HandleNotification(notification)

    if notification:GetName() == ActivityNotes.OPEN_ACTIVITY then

        if (self._activityPanel == nil) then
            self._activityPanel = PanelManager.BuildPanel(ResID.UI_ACTIVITYPANEL, ActivityPanel, true);
        end

        self.open_act_plData = notification:GetBody();
        self._activityPanel:SetOpenSubPanel(self.open_act_plData.type, self.open_act_plData.id, true);


    elseif notification:GetName() == ActivityNotes.CLOSE_ACTIVITY then
        if (self._activityPanel ~= nil) then
            PanelManager.RecyclePanel(self._activityPanel, ResID.UI_ACTIVITYPANEL)
            self._activityPanel = nil
        end

    elseif notification:GetName() == ActivityNotes.OPEN_ACTIVITYNOTIFY then
        if (self._notifyPanel == nil) then
            self._notifyPanel = PanelManager.BuildPanel(ResID.UI_ARATHISCENETIPSPANEL, ActivityNotifyPanel, false);
        end
        self._notifyPanel:SetData(notification:GetBody())

    elseif notification:GetName() == ActivityNotes.CLOSE_ACTIVITYNOTIFY then
        if (self._notifyPanel ~= nil) then
            PanelManager.RecyclePanel(self._notifyPanel, ResID.UI_ARATHISCENETIPSPANEL)
            self._notifyPanel = nil
        end

        -------------------------------------------------
    elseif notification:GetName() == ActivityNotes.OPEN_ACTIVITYOPENTIMELOGPANEL then
        if (self._activityOpenTimeLogPanel == nil) then
            self._activityOpenTimeLogPanel = PanelManager.BuildPanel(ResID.UI_ACTIVITYOPENTIMELOGPANEL, ActivityOpenTimeLogPanel, false);
        end


    elseif notification:GetName() == ActivityNotes.CLOSE_ACTIVITYOPENTIMELOGPANEL then
        if (self._activityOpenTimeLogPanel ~= nil) then
            PanelManager.RecyclePanel(self._activityOpenTimeLogPanel, ResID.UI_ACTIVITYOPENTIMELOGPANEL)
            self._activityOpenTimeLogPanel = nil
        end


         -------------------------------------------------
           elseif notification:GetName() == ActivityNotes.OPEN_ACTIVITY_TIP then
        if (self._activityTipPanel == nil) then
            self._activityTipPanel = PanelManager.BuildPanel(ResID.UI_ACTIVITYTIPPANEL, ActivityTipPanel, false);
        end

        self._activityTipPanel:Show(notification:GetBody());
        
    elseif notification:GetName() == ActivityNotes.CLOSE_ACTIVITY_TIP then
        if (self._activityTipPanel ~= nil) then
            PanelManager.RecyclePanel(self._activityTipPanel, ResID.UI_ACTIVITYTIPPANEL)
            self._activityTipPanel = nil
        end



    end

end

function ActivityMediator:OnRemove()

end


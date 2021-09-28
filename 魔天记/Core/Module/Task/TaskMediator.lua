require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Task.TaskNotes"
require "Core.Module.Task.View.TaskPanel"
require "Core.Module.Task.View.RewardTaskPanel"
require "Core.Module.Task.View.TaskActionPanel"

TaskMediator = Mediator:New();
function TaskMediator:OnRegister()

end

function TaskMediator:_ListNotificationInterests()
    return {
        [1] = TaskNotes.OPEN_TASKPANEL,
        [2] = TaskNotes.CLOSE_TASKPANEL,
        [3] = TaskNotes.OPEN_TASKACTIONPANEL,
        [4] = TaskNotes.CLOSE_TASKACTIONPANEL,
        [5] = TaskNotes.DOACTION_TASKACTIONPANEL,
        [6] = TaskNotes.OPEN_REWARDTASKPANEL,
        [7] = TaskNotes.CLOSE_REWARDTASKPANEL
    };
end

function TaskMediator:_HandleNotification(notification)
    if notification:GetName() == TaskNotes.OPEN_TASKPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_TASKPANEL, TaskPanel, true);            
        end
        local param = notification:GetBody();
        param = param or TaskConst.Type.MAIN;
        self._panel:SetSelectType(param);
    elseif notification:GetName() == TaskNotes.CLOSE_TASKPANEL then
        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel);
            self._panel = nil;
        end
    elseif notification:GetName() == TaskNotes.DOACTION_TASKACTIONPANEL then
        if (self._actionPanel ~= nil) then
            self._actionPanel:TryDoAction();
        end
    elseif notification:GetName() == TaskNotes.OPEN_TASKACTIONPANEL then
        if (self._actionPanel == nil) then
            self._actionPanel = PanelManager.BuildPanel(ResID.UI_TASKACTIONPANEL, TaskActionPanel);
        end
        local d = notification:GetBody();
        self._actionPanel:SetData(d[1], d[2]);
    elseif notification:GetName() == TaskNotes.CLOSE_TASKACTIONPANEL then
        if (self._actionPanel ~= nil) then
            PanelManager.RecyclePanel(self._actionPanel);
            self._actionPanel = nil;
        end
    elseif notification:GetName() == TaskNotes.OPEN_REWARDTASKPANEL then
        if (self._rewardPanel == nil) then
            self._rewardPanel = PanelManager.BuildPanel(ResID.UI_REWARDTASKPANEL, RewardTaskPanel);
        end
    elseif notification:GetName() == TaskNotes.CLOSE_REWARDTASKPANEL then
        if (self._rewardPanel ~= nil) then
            PanelManager.RecyclePanel(self._rewardPanel);
            self._rewardPanel = nil;
        end
    end
end

function TaskMediator:OnRemove()
    
end

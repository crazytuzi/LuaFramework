require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Dialog.DialogNotes"
require "Core.Module.Dialog.View.DialogPanel";
require "Core.Module.Dialog.View.DialogQAPanel";
require "Core.Module.Dialog.View.DialogSubPanel";
require "Core.Module.Dialog.DialogSet";

DialogMediator = Mediator:New();
function DialogMediator:OnRegister()
    
end

function DialogMediator:_ListNotificationInterests()
    return {
        [1] = DialogNotes.OPEN_DIALOGPANEL,
        [2] = DialogNotes.CLOSE_DIALOGPANEL,
        [3] = DialogNotes.CLOSE_ALL_DIALOGPANEL;
        [4] = DialogNotes.OPEN_SUB_DIALOGPANEL,
        [5] = DialogNotes.CLOSE_SUB_DIALOGPANEL,
        [6] = DialogNotes.SHOW_SKIP_BTN
    }
end

function DialogMediator:_HandleNotification(notification)
    local t = notification:GetName()
    if t == DialogNotes.OPEN_DIALOGPANEL then

        local param = notification:GetBody();
        MainUIProxy.SetMainUIOperateEnable(false);
        if (type(param) == "table" and param.__cname == "DialogSet") then
            self._ds = param;
        else
            local npcId = param;
            self._ds = DialogSet.InitWithNpc(npcId);
            SequenceManager.TriggerEvent(SequenceEventType.Base.TALK_TO_NPC_PRE, npcId);
        end

        if (self._panel == nil and not self._ds.isPlot ) then
            --如果不是剧情对话.
            PanelManager.HideAllPanels(true);
        end
        
        if self._ds.type == DialogSet.Type.Question then
            if (self._qaPanel == nil) then
                self._qaPanel = PanelManager.BuildPanel(ResID.UI_DIALOGQAPANEL, DialogQAPanel, false, DialogNotes.CLOSE_ALL_DIALOGPANEL);
            end
        else
            if (self._panel == nil) then
                self._panel = PanelManager.BuildPanel(ResID.UI_DIALOGPANEL, DialogPanel, false, DialogNotes.CLOSE_ALL_DIALOGPANEL, true);
            end
        end

        self:OpenDsFirst();
        
    elseif t == DialogNotes.CLOSE_DIALOGPANEL then

        if(self._ds and #self._ds.data > 0) then
            self:OpenDsFirst();
        else
            self:CloseDs();
        end

    elseif t == DialogNotes.CLOSE_ALL_DIALOGPANEL then
        
        self:CloseDs();

    elseif t == DialogNotes.OPEN_SUB_DIALOGPANEL then
        if (self._subDialog == nil) then
            self._subDialog = PanelManager.BuildPanel(ResID.UI_DIALOG_SUB_PANEL, DialogSubPanel, false, nil, true)
        end
        local param = notification:GetBody()
        self._subDialog:SetData(param[1], param[2])
    elseif t == DialogNotes.CLEAR_SUB_DIALOGPANEL then
        if self._subDialog then
            self._subDialog:ClearText()
        end
    elseif t == DialogNotes.CLOSE_SUB_DIALOGPANEL then
        if (self._subDialog ~= nil) then
            --local p = notification:GetBody()
            --if not p or self._subDialog:GetContent() == p then--用于对证字幕删除
                PanelManager.RecyclePanel(self._subDialog)
                self._subDialog = nil
            --end
        end
    elseif t == DialogNotes.SHOW_SKIP_BTN then
        if (self._subDialog ~= nil) then self._subDialog:ShowSkipBtn() end
        if (self._panel ~= nil) then self._panel:ShowSkipBtn() end
    end
end

function DialogMediator:OpenDsFirst()
    local d = self._ds.data[1];
    if (d == nil) then
        error("dialog data is nil!");
        return;
    end
    if self._ds.type == DialogSet.Type.Question then
        if (self._qaPanel) then
            self._qaPanel:Update(d);
        end
    else
        if (self._panel) then
            self._panel:Update(d);
        end
    end
    table.remove(self._ds.data, 1);
end

function DialogMediator:CloseDs()
    if (self._panel ~= nil) then
        PanelManager.RecyclePanel(self._panel);
        self._panel = nil;
    end

    if (self._qaPanel ~= nil) then
        PanelManager.RecyclePanel(self._qaPanel);
        self._qaPanel = nil;
    end
    
    if self._ds then
        local npcId = self._ds.npcId;
        if (npcId > 0) then
            SequenceManager.TriggerEvent(SequenceEventType.Base.TALK_TO_NPC, npcId);
        end
    
        SequenceManager.TriggerEvent(SequenceEventType.Base.TALK_END);

        if self._ds.isNewTask then
            SequenceManager.TriggerEvent(SequenceEventType.Base.TASK_ACESS_DIALOG_END, self._ds.taskId);   
        end

        if not self._ds.isPlot then PanelManager.RevertAllPanels() end

        if self._ds.onEnd then
            self._ds.onEnd();
        end

        self._ds = nil;
    end

    MainUIProxy.SetMainUIOperateEnable(true)
end

function DialogMediator:OnRemove()
    
end



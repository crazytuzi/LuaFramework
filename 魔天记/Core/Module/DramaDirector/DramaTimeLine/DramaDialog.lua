require "Core.Module.Scene.DialogBubblePanel"

DramaDialog = class("DramaDialog", DramaAbs);
DramaDialog.SPEAKTIME = 0.25 * 0.1
DramaDialog.CLOSEDELAY = 3

function DramaDialog:_Init()
end

function DramaDialog:_Begin(fixed)
    if fixed then return end
    local t = self.config[DramaAbs.EvenType]
    local p1 = self.config[DramaAbs.EvenParam1]
    local p2 = self.config[DramaAbs.EvenParam2]
    if t == DramaEventType.DialogSubtitle then
        ModuleManager.SendNotification(DialogNotes.OPEN_SUB_DIALOGPANEL,{ p1[1], DramaTimer.CanSkip()})
    elseif t == DramaEventType.DialogRole then        
        ModuleManager.SendNotification(DialogNotes.OPEN_DIALOGPANEL, self:GetDialogData(p1[1], p2[1]))
        DramaDialog.currentDialog = self
    elseif t == DramaEventType.DialogBubble then
        local roleType = p2[2]
        local r = DramaRole.GetDramaRole( p2[1] , roleType, self._hero)
        self.dialog = DialogBubblePanel:New():SetData(p1[1], r)
    end
end
--组织对话内容
function DramaDialog:GetDialogData(p1, p2)
    local dialogs = {};
    local contents = string.split(p1, "$")
    local ids = string.split(p2, "$")
    for i,v in ipairs(contents) do
        local d = DialogData.New();
        d:InitWithStr(ids[i], v, DramaDialog.SPEAKTIME, DramaDialog.CLOSEDELAY, false)
        d.ShowSkipBtn = DramaTimer.CanSkip()
        dialogs[i] = d;
    end
    return DialogSet.InitPlot(dialogs, DramaDialog.OnComplete, true);
end

function DramaDialog.OnComplete()
    if not DramaDialog.currentDialog then return end
    self = DramaDialog.currentDialog
    DramaDialog.currentDialog = nil
    if self.endTime and self.endTime.running then
        --DramaTimer.AccelEvent(self.endTime:GetRemainTime())
        self.endTime:Stop()
        self.endTime = nil
    end
    self:End()
end


function DramaDialog:_Dispose()
    local t = self.config[DramaAbs.EvenType]
    local p1 = self.config[DramaAbs.EvenParam1]
    if t == DramaEventType.DialogSubtitle then
        --ModuleManager.SendNotification(DialogNotes.CLOSE_SUB_DIALOGPANEL,  p1[1])
        ModuleManager.SendNotification(DialogNotes.CLEAR_SUB_DIALOGPANEL)
    elseif t == DramaEventType.DialogRole then
        ModuleManager.SendNotification(DialogNotes.CLOSE_DIALOGPANEL)
        DramaDialog.currentDialog = nil
    elseif t == DramaEventType.DialogBubble then
        if self.dialog then
            self.dialog:Dispose()
            self.dialog = nil
        end
    end
end
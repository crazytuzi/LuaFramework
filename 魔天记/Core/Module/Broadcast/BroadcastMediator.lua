require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Broadcast.BroadcastNotes"
require "Core.Module.Broadcast.View.BroadcastPanel"

BroadcastMediator = Mediator:New();
function BroadcastMediator:OnRegister()
    self.operateTips = { };
    UpdateBeat:Add(self.Update, self);
end

function BroadcastMediator:_ListNotificationInterests()
    return {
        [1] = BroadcastNotes.OPEN_BROADCASTPANEL,
        [2] = BroadcastNotes.CLOSE_BROADCASTPANEL,
    };
end

function BroadcastMediator:_HandleNotification(notification)
    if notification:GetName() == BroadcastNotes.OPEN_BROADCASTPANEL then
        local plData = notification:GetBody();
        local _broadcastPanel = self:Get_OperateTipBroadcastPanel();
        _broadcastPanel:Start(plData);

    elseif notification:GetName() == BroadcastNotes.CLOSE_BROADCASTPANEL then

        local _broadcastPanel = notification:GetBody();
        local index = _broadcastPanel:GetIndex();
        PanelManager.RecyclePanel(_broadcastPanel,ResID.UI_BROADCASTPANEL);
        self.operateTips[index] = nil;

    end
end

function BroadcastMediator:Get_OperateTipBroadcastPanel()


    for i = 1, 3 do
        if self.operateTips[i] == nil then
            self.operateTips[i] = PanelManager.BuildPanel(ResID.UI_BROADCASTPANEL, BroadcastPanel);
            self.operateTips[i]:SetIndex(i);
            return self.operateTips[i];
        end
    end

    --  到这里表示 已经有3条同时显示了
    -- 需要获取最早显示的对象
    -- Get_CurrCount
    local min_count = 99999;
    local min_obj = nil;

    for i = 1, 3 do
        if self.operateTips[i] ~= nil then
            local ct = self.operateTips[i]:Get_CurrCount();
            if ct < min_count then
                min_obj = self.operateTips[i];
            end
        end
    end

    return min_obj;

end


function BroadcastMediator:Update()

    local dtime = Timer.deltaTime * 1000;
    for i = 1, 3 do
        if self.operateTips[i] ~= nil then
            self.operateTips[i]:Update(dtime);
        end
    end

end

function BroadcastMediator:GetOldoperateTip()



end

function BroadcastMediator:OnRemove()
    UpdateBeat:Remove(self.Update, self)
end


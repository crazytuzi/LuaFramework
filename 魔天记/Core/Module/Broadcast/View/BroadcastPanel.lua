require "Core.Module.Common.Panel"


BroadcastPanel = Panel:New();
BroadcastPanel.Tcount = 0;

function BroadcastPanel:IsFixDepth()
    return true;
end

function BroadcastPanel:GetUIOpenSoundName( )
    return ""
end


function BroadcastPanel:_Init()
    self:_InitReference();
    self:_InitListener();

    self._currTime = 0;
    self._currCount = BroadcastPanel.Tcount;
    BroadcastPanel.Tcount = BroadcastPanel.Tcount + 1;
end

function BroadcastPanel:_InitReference()
    self._txt_msgLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_msgLabel");
end

function BroadcastPanel:_InitListener()
end

function BroadcastPanel:_Dispose()
    self:_DisposeReference();

    self._txt_msgLabel = nil;


end

function BroadcastPanel:_DisposeReference()
end


function BroadcastPanel:Start(data)


    local act_type = data.act_type;
    local msgType = data.msgType;
    local color = data.color
    self._txt_msgLabel.text = data.txt;

    if msgType == BroadcastNotes.MSG_TYPE_SAMPLE then
        self._txt_msgLabel.color = Color.New(0xff / 255.0, 0xd7 / 255.0, 0x00 / 255.0, 0xff / 255.0);
        Util.SetLocalPos(self._transform, 0, 200, 0)
        --        self._transform.localPosition = Vector3.New(0, 200, 0);
    elseif msgType == BroadcastNotes.MSG_TYPE_ERROR then
        self._txt_msgLabel.color = Color.New(0xff / 255.0, 0x0 / 255.0, 0x00 / 255.0, 0xff / 255.0);
        Util.SetLocalPos(self._transform, 0, 200, 0)
        --        self._transform.localPosition = Vector3.New(0, 200, 0);
    end
    if (color) then
        self._txt_msgLabel.color = color
    end
    self._start_x = self._transform.localPosition.x;
    self._start_y = self._transform.localPosition.y;
    self._curr_y = self._start_y;
    self._currTime = 2000;

end

function BroadcastPanel:Update(dtime)

    self._currTime = self._currTime - dtime;

    if (self._currTime <= 200 and self._currTime > 0) then
        Util.SetLocalPos(self._transform, self._start_x, self._curr_y, 0)
        --        self._transform.localPosition = Vector3.New(self._start_x, self._curr_y, 0);
        self._curr_y = self._curr_y + 5;

    elseif (self._currTime <= 0) then
        self:Stop();
    end

end



function BroadcastPanel:Stop()
    ModuleManager.SendNotification(BroadcastNotes.CLOSE_BROADCASTPANEL, self);
end

function BroadcastPanel:SetIndex(index)
    self._index = index;
end

function BroadcastPanel:GetIndex()
    return self._index;
end

function BroadcastPanel:Get_CurrCount()
    return self._currCount;
end
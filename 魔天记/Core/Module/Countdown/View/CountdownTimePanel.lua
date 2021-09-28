require "Core.Module.Common.Panel"

CountdownTimePanel = Panel:New();

function CountdownTimePanel:_Init()
    if self:HasMask() then
        local sp = UIUtil.GetComponent(self._trsMask.gameObject, "UISprite");
        if (sp) then
            sp.color = Color.New(1, 1, 1, 1 / 0xFF)
        end
    end
    self:_InitReference();
    -- self:_InitListener();
end

function CountdownTimePanel:GetUIOpenSoundName( )
    return ""
end


function CountdownTimePanel:IsPopup()
    return false;
end

function CountdownTimePanel:_InitReference()
    self._txtElseTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtElseTime");
    self._timer = Timer.New( function(val) self:_OnUpdata(val) end, 0.2, -1, false);
end

-- function CountdownTimePanel:_InitListener()

-- end

function CountdownTimePanel:_Dispose()
    -- self:_DisposeListener();
    self:_DisposeReference();
end

-- function CountdownTimePanel:_DisposeListener()

-- end

function CountdownTimePanel:_DisposeReference()
    self._timer:Stop();
    self._timer = nil;
    self._txtElseTime = nil
    self._title = nil;
    self._handler = nil;
    self._cancelHandler = nil;
    self._suspend = nil;
end

function CountdownTimePanel:_OnUpdata()
    if (self._elseTime) then
        local currTime = os.time() - self._startTime;
        if (currTime > self._elseTime) then
            self._txtElseTime.text = self._title .. "0";
            self._elseTime = nil;
            if (self._handler) then
                self._handler()
            end
            ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNTIMENPANEL)
        else
            if (self._suspend and self._suspend()) then
                if (self._cancelHandler) then
                    self._cancelHandler()
                end
                ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNTIMENPANEL)
            else
                self._txtElseTime.text = self._title ..(self._elseTime - currTime);
            end
        end
    end
end

function CountdownTimePanel:SetData(data)
    if (data and data.time) then
        if (data.title) then
            self._title = data.title
        else
            self._title = "";
        end
        if (data.handler) then
            self._handler = data.handler
        else
            self._handler = nil
        end
        if (data.cancelHandler) then
            self._cancelHandler = data.cancelHandler
        else
            self._cancelHandler = nil
        end
        if (data.suspend) then
            self._suspend = data.suspend
        else
            self._suspend = nil
        end
        self._startTime = os.time();
        self._elseTime = data.time;
        if (not self._timer.running) then
            self._timer:Start();
        end
    else
        self._timer = nil;
    end
end

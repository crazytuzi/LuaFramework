require "Core.Module.Common.Panel"

CountdownBarPanel = Panel:New()

function CountdownBarPanel:_Init()
    --    if self:HasMask() then
    --        local sp = UIUtil.GetComponent(self._trsMask.gameObject, "UISprite");
    --        if (sp) then
    --            sp.color = Color.New(1, 1, 1, 1/0xFF)
    --        end
    --    end
    self:_InitReference();
    -- self:_InitListener();
end


function CountdownBarPanel:GetUIOpenSoundName( )
    return ""
end

function CountdownBarPanel:IsPopup()
    return false;
end

function CountdownBarPanel:_InitReference()
    self._progress = UIUtil.GetChildByName(self._trsContent, "UISlider", "progress");
    self._txtProgress = UIUtil.GetChildByName(self._progress, "UILabel", "txtProgress");
    self._timer = Timer.New( function(val) self:_OnUpdata(val) end, 0, -1, false);
end

-- function CountdownBarPanel:_InitListener()

-- end

function CountdownBarPanel:_Dispose()
    -- self:_DisposeListener();
    self:_DisposeReference();
end

-- function CountdownBarPanel:_DisposeListener()

-- end

function CountdownBarPanel:_DisposeReference()
    self._timer:Stop();
    self._timer = nil;
    self._txtElseTime = nil
    self._title = nil;
    self._handler = nil;
    self._cancelHandler = nil;
    self._suspend = nil;
end

function CountdownBarPanel:_OnUpdata()
    if (self._elseTime) then
        self._currTime = self._currTime - Timer.deltaTime;
        if (self._currTime > 0) then
            if (self._suspend and self._suspend()) then --���ȡ��
                if (self._cancelHandler) then
                    self._cancelHandler()--ȡ��
                end
                ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNBARNPANEL)
            else                
                self._progress.value = self._currTime / self._elseTime
            end
        else
            self._progress.value = 0
            if (self._handler) then
                self._handler()--���
            end
            ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNBARNPANEL)
        end
    end
end

function CountdownBarPanel:SetData(data)
    if (data and data.time) then
        if (data.title) then
            self._txtProgress.text = data.title
        else
            self._txtProgress.text = "";
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
        self._elseTime = data.time;
        self._currTime = data.time;
        self._progress.value = 1;
        if (not self._timer.running) then
            self._timer:Start();
        end
    else
        self._timer = nil;
    end
end

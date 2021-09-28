-- 倒计时组件
DownTimer = class("DownTimer")
DownTimer.DOWN_TIME_START = "DOWN_TIME_START"
DownTimer.DOWN_TIME_END = "DOWN_TIME_END"
--label文本显示器,downTime倒计总时间,prefix前缀文字,endMsg倒计后显示信息,endMsgDuratioin保持时间
--,heartBeatTime跳动间隔,onComplete完成回调
function DownTimer:InitData(label, downTime, prefix, endMsg, endMsgDuration, heartBeatTime, onComplete)
    self._label = label
    self._label.gameObject:SetActive(true)
    self._prefix = prefix
    self._downTime = downTime
    self._endMsg = endMsg
    self._totalTime = endMsg and downTime + endMsgDuration or downTime
    if not heartBeatTime then heartBeatTime = 1 end
    self._onComplete = onComplete
    self._timeCount = 0
    self:ClearTimer()
    --Warning(self._totalTime .. "_____" .. heartBeatTime)
    self._timer = Timer.New( function () self:_OnTime() end, heartBeatTime, math.ceil(self._totalTime / heartBeatTime), false)
    self._timer:AddCompleteListener(function() self:_OnComplete() end)
    self._timer:Start()
    self._lastTime = GetTime()
    self:_OnTime()
end
function DownTimer:_OnTime()
    local ct = GetTime()
    self._timeCount = self._timeCount + (ct - self._lastTime)
    self._lastTime = ct
    local text = nil
    local remain = self._downTime - self._timeCount
    --Warning(remain)
    if remain > 0 then
        text = self._prefix .. GetTimeByStr1(remain)
    else 
        text = self._endMsg
    end
    self._label.text = text
end
function DownTimer:_OnComplete()
    --Warning("DownTimer:_OnComplete__" .. tostring(self._OnComplete))
    if self._onComplete then
        self._onComplete()
        self._onComplete = nil
    end
    self:Clear()
end

function DownTimer:Clear()
    --Warning("DownTimer:Clear__" .. tostring(self._label))
    if self._label then 
        self._label.gameObject:SetActive(false)
        self._label = nil
    end
    self._onComplete = nil
    self:ClearTimer()
end 
function DownTimer:ClearTimer()
    if self._timer then
        self._timer:Stop()
        self._timer = nil
    end
end 

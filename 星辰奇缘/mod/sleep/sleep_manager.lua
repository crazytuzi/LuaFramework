-- 省电模式
SleepManager = SleepManager or BaseClass()

function SleepManager:__init()
    if SleepManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    SleepManager.Instance = self

    self.IsWakeUp = true -- 省电模式

    self.IsPause = false -- 后台标记

    -- 省电模式下的亮度
    self.SleepLight = 10

    self.OnResumeEvent = EventLib.New()
end

function SleepManager:__delete()
    self.OnResumeEvent:DeleteMe()
    self.OnResumeEvent = nil
end

-- 恢复正常模式
function SleepManager:OnWakeUp()
    Application.targetFrameRate = 45
    if not self.IsWakeUp then
        SoundManager.Instance:OnWakeUp()
    end
    self.IsWakeUp = true
end

-- 进入省电模式
function SleepManager:OnSleep()
    if self.IsWakeUp then
        SoundManager.Instance:OnSleep()
    end
    self.IsWakeUp = false
end

-- 进入后台
function SleepManager:OnPause()
    self.IsPause = true
    -- Log.Debug(string.format("进入后台 Time = %s", os.time()))
end

-- 重新激活
function SleepManager:OnResume()
    self.IsPause = false
    -- Log.Debug(string.format("重新激活 Time = %s", os.time()))
    self.OnResumeEvent:Fire()
end

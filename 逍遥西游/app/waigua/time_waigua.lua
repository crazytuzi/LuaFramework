if Waigua_Time then
  Waigua_Time.Clear()
end
Waigua_Time = {}
function Waigua_Time.init()
  Waigua_Time.TimeCallBack = 10
  Waigua_Time.MaxDirtyTime = 5
  Waigua_Time.DirtyTimes = 0
  Waigua_Time.LastCallBackTime = nil
  Waigua_Time._scheduleHandler = scheduler.scheduleGlobal(Waigua_Time.CallBack, Waigua_Time.TimeCallBack)
end
function Waigua_Time.Clear()
  scheduler.unscheduleGlobal(Waigua_Time._scheduleHandler)
end
function Waigua_Time.CallBack(dt)
  if Waigua_Time.LastCallBackTime ~= nil then
    if os.time() - Waigua_Time.LastCallBackTime < Waigua_Time.TimeCallBack - 2 then
      Waigua_Time.DirtyTimes = Waigua_Time.DirtyTimes + 1
    else
      Waigua_Time.DirtyTimes = 0
    end
  end
  if Waigua_Time.DirtyTimes > Waigua_Time.MaxDirtyTime then
    Waigua_Time.LastCallBackTime = nil
    if netcommand.login then
      netcommand.login.netErrorMsg({})
    end
  end
  Waigua_Time.LastCallBackTime = os.time()
end
Waigua_Time.init()
gamereset.registerResetFunc(function()
  Waigua_Time.Clear()
  Waigua_Time.init()
end)

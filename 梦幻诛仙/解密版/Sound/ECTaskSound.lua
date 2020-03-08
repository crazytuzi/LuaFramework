local ECGame = require("Main.ECGame")
local TaskEvents = require("Event.TaskEvents")
local ECTaskDef = require("Task.ECTaskDef")
local ECSoundMan = require("Sound.ECSoundMan")
local TASK_SERVER_NOTIFY = ECTaskDef.TASK_SERVER_NOTIFY
local l_taskSoundMap = {
  [TASK_SERVER_NOTIFY.TASK_SVR_NOTIFY_NEW] = 157,
  [TASK_SERVER_NOTIFY.TASK_SVR_NOTIFY_COMPLETE] = 158
}
ECGame.EventManager:addHandler(TaskEvents.SimpleNotifyEvent, function(sender, event)
  local soundId = l_taskSoundMap[event.notifyType]
  if soundId then
    local ECTaskInterface = require("Task.ECTaskInterface")
    local taskView = ECTaskInterface.Instance():GetTaskView(event.taskId)
    if taskView and taskView.bShowPrompt then
      ECSoundMan.Instance():Play2DSoundByID(soundId)
    end
  end
end)

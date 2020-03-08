local Lplus = require("Lplus")
local TaskInitEvent = Lplus.Class("TaskEvent.TaskInitEvent").Commit()
local SimpleNotifyEvent = Lplus.Class("TaskEvents.SimpleNotifyEvent")
do
  local def = SimpleNotifyEvent.define
  def.field("number").taskId = 0
  def.field("number").notifyType = 0
  def.final("number", "number", "=>", SimpleNotifyEvent).new = function(taskId, notifyType)
    local obj = SimpleNotifyEvent()
    obj.taskId = taskId
    obj.notifyType = notifyType
    return obj
  end
end
SimpleNotifyEvent.Commit()
local OnUpdateEvent = Lplus.Class("TaskEvents.OnUpdateEvent").Commit()
local OnStorageUpdateEvent = Lplus.Class("TaskEvents.OnStorageUpdateEvent")
local def = OnStorageUpdateEvent.define
def.field("number").storageIndex = 0
def.final("number", "=>", OnStorageUpdateEvent).new = function(storageIndex)
  local obj = OnStorageUpdateEvent()
  obj.storageIndex = storageIndex
  return obj
end
OnStorageUpdateEvent.Commit()
local AboutToAcceptTask = Lplus.Class("TaskEvents.AboutToAcceptTask")
do
  local def = AboutToAcceptTask.define
  def.field("number").taskId = 0
  def.final("number", "=>", AboutToAcceptTask).new = function(taskId)
    local obj = AboutToAcceptTask()
    obj.taskId = taskId
    return obj
  end
end
AboutToAcceptTask.Commit()
local TaskOpenPanel = Lplus.Class("TaskEvents.TaskOpenPanel")
do
  local def = TaskOpenPanel.define
  def.field("number").taskId = 0
  def.field("string").mode = ""
  def.final("number", "string", "=>", TaskOpenPanel).new = function(taskId, mode)
    local obj = TaskOpenPanel()
    obj.taskId = taskId
    obj.mode = mode
    return obj
  end
end
TaskOpenPanel.Commit()
return {
  TaskInitEvent = TaskInitEvent,
  SimpleNotifyEvent = SimpleNotifyEvent,
  OnUpdateEvent = OnUpdateEvent,
  OnStorageUpdateEvent = OnStorageUpdateEvent,
  AboutToAcceptTask = AboutToAcceptTask,
  TaskOpenPanel = TaskOpenPanel
}

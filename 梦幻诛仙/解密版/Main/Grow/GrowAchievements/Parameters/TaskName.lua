local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Parameter = import(".Parameter")
local TaskName = Lplus.Extend(Parameter, CUR_CLASS_NAME)
local TaskInterface = require("Main.task.TaskInterface")
local def = TaskName.define
def.override("number", "=>", "string").ToString = function(self, value)
  local taskCfg = TaskInterface.GetTaskCfg(value)
  local str = "Task name not get yet."
  if taskCfg then
    str = taskCfg.taskName
  end
  return str
end
return TaskName.Commit()

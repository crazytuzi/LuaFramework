local Lplus = require("Lplus")
local GameInfo = require("Utility.GameInfo")
local TableProxy = require("Utility.TableProxy")
local ECTaskInterface = Lplus.ForwardDeclare("ECTaskInterface")
local l_taskInterface
local TaskData = Lplus.Class()
do
  local def = TaskData.define
  def.final("number", "=>", TaskData).new = function(taskId)
    local obj = TaskData()
    obj.m_id = taskId
    return obj
  end
  def.method("=>", "number").id = function(self)
    return self.m_id
  end
  def.method("=>", "table").full_info = function(self)
    return self:getFullInfo()
  end
  def.method("=>", "table").view = function(self)
    return self:getView()
  end
  def.method("=>", "number").finish_count = function(self)
    local count = ECTaskInterface.GetFinishCount(self.m_id)
    return count
  end
  def.method("number", "=>", "string").monster_info = function(self, index)
    local ECTaskUtility = require("Task.ECTaskUtility")
    return ECTaskUtility.FormatTargetMonster(index, self:getFullInfo())
  end
  def.method("number", "=>", "string").monster_num = function(self, index)
    local ECTaskUtility = require("Task.ECTaskUtility")
    return ECTaskUtility.FormatTargetMonsterNum(index, self:getFullInfo())
  end
  def.method("number", "=>", "string").item_info = function(self, index)
    local ECTaskUtility = require("Task.ECTaskUtility")
    return ECTaskUtility.FormatTargetItem(index, self:getFullInfo())
  end
  def.method("number", "=>", "string").item_num = function(self, index)
    local ECTaskUtility = require("Task.ECTaskUtility")
    return ECTaskUtility.FormatTargetItemNum(index, self:getFullInfo())
  end
  def.method("number", "=>", "string").event_info = function(self, index)
    local ECTaskUtility = require("Task.ECTaskUtility")
    return ECTaskUtility.FormatTargetEvent(index, self:getFullInfo())
  end
  def.method("number", "=>", "string").event_num = function(self, index)
    local ECTaskUtility = require("Task.ECTaskUtility")
    return ECTaskUtility.FormatTargetEventNum(index, self:getFullInfo())
  end
  def.method("=>", "string").time_limit = function(self, index)
    local ECTaskUtility = require("Task.ECTaskUtility")
    return ECTaskUtility.FormatTaskTimeLeft(self:getFullInfo())
  end
  def.method("=>", "string").idle_time_left = function(self, index)
    local ECTaskUtility = require("Task.ECTaskUtility")
    return ECTaskUtility.FormatTaskIdleTimeLeft(self:getFullInfo())
  end
  def.field("number").m_id = 0
  def.field("table").m_fullInfo = nil
  def.method("=>", "table").getFullInfo = function(self)
    local fullInfo = self.m_fullInfo
    if not fullInfo then
      fullInfo = l_taskInterface:GetTaskFullInfo(self.m_id)
      self.m_fullInfo = fullInfo
    end
    return fullInfo
  end
  def.method("=>", "table").getView = function(self)
    return l_taskInterface:GetTaskView(self.m_id)
  end
end
TaskData.Commit()
GameInfo.set("task", TaskData.new)
local GameInfo_task = Lplus.Class()
do
  local def = GameInfo_task.define
  def.static(ECTaskInterface).setTaskInterface = function(taskinterface)
    l_taskInterface = taskinterface
  end
  def.static("number").setupCurrentTask = function(taskId)
    local curTaskData = TaskData.new(taskId)
    GameInfo.set("curtask", curTaskData)
  end
  def.static().clearCurrentTask = function()
    GameInfo.set("curtask", nil)
  end
end
return GameInfo_task.Commit()

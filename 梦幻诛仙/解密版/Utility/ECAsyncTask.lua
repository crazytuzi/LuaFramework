local Lplus = require("Lplus")
local Task = require("Utility.Task")
local ECAsyncTask = Lplus.Class("ECAsyncTask")
do
  local def = ECAsyncTask.define
  def.static(Task, "number", "=>", Task).AddTimelimit = function(task, timeout)
    if timeout >= 0 then
      do
        local timer = GameUtil.AddGlobalTimer(timeout, true, function()
          task:cancel()
        end)
        task:continueWith(function()
          GameUtil.RemoveGlobalTimer(timer)
        end)
      end
    end
    return task
  end
  def.static("number", "=>", Task).WaitForTime = function(seconds)
    return Task.createOneStepEx(function(task)
      return function(task, resumeEntry)
        GameUtil.AddGlobalTimer(seconds, true, function()
          resumeEntry()
        end)
      end
    end, function()
      return "stop"
    end)
  end
  def.static("string", "=>", Task).LoadResource = function(path)
    return Task.createOneStep(function(task)
      return function(task, resumeEntry)
        GameUtil.AsyncLoad(path, function(asset)
          if task:isActive() then
            task:setResult(asset)
            resumeEntry()
          end
        end)
      end
    end, function()
      return "stop"
    end)
  end
  local CreatePanelEvent = require("Event.GUIEvents").CreatePanelEvent
  def.static("string", "number", "=>", Task).WaitForPanelCreate = function(panelName, timeout)
    local eventHandler
    local ECGame = require("Main.ECGame")
    local task = Task.createOneStepEx(function(task)
      return function(task, resumeEntry)
        function eventHandler(sender, event)
          if event.name == panelName then
            ECGame.EventManager:removeHandler(CreatePanelEvent, eventHandler)
            resumeEntry()
          end
        end
        ECGame.EventManager:addHandler(CreatePanelEvent, eventHandler)
      end
    end, function()
      return "stop"
    end)
    return ECAsyncTask.AddTimelimit(task, timeout)
  end
  def.static("number", "=>", Task).FindNearestNPCByTid = function(tid)
    local task = Task.createStepsEx(function(task, step)
      if step < 50 then
        local ECGame = require("Main.ECGame")
        local npc = ECGame.Instance().m_CurWorld.m_NPCMan:FindNearestNPCByTid(tid)
        if npc then
          return "end", npc
        else
          return task:completeSub(ECAsyncTask.WaitForTime(0.1))
        end
      else
        task:cancel()
        return "end"
      end
    end, function()
      return "stop"
    end)
    return task
  end
  def.static("number", "=>", Task).FindNearestMatterByTid = function(tid)
    local task = Task.createStepsEx(function(task, step)
      if step < 50 then
        local ECGame = require("Main.ECGame")
        local matter = ECGame.Instance().m_CurWorld.m_MatterMan:FindNearestMatterByTid(tid)
        if matter then
          return "end", matter
        else
          return task:completeSub(ECAsyncTask.WaitForTime(0.1))
        end
      else
        task:cancel()
        return "end"
      end
    end, function()
      return "stop"
    end)
    return task
  end
end
return ECAsyncTask.Commit()

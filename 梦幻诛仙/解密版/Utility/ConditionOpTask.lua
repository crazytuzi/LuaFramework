local Lplus = require("Lplus")
local Task = require("Utility.Task")
local ConditionOp = require("Utility.ConditionOp")
local Callbacks = require("Utility.Callbacks")
local ConditionOpTask = Lplus.Class("ConditionOpTask")
do
  local def = ConditionOpTask.define
  def.static(ConditionOp, "=>", Task).waitForSingleOp = function(op)
    return ConditionOpTask.waitForMultipleOp({op})
  end
  def.static("table", "=>", Task).waitForMultipleOp = function(opArr)
    local cleaner = Callbacks()
    local finished = false
    local task = Task.createStepsEx(function(task, step)
      if finished then
        return "end"
      end
      local iWaitOnlyCondOp, iWaitCondOp = ConditionOpTask.selectWaitableOp(opArr)
      if iWaitOnlyCondOp >= 0 then
        do
          local op = opArr[iWaitOnlyCondOp]
          cleaner:add(function()
            op:stopWaiting()
          end)
          return function(task, resumeEntry)
            op:wait(function()
              if ConditionOpTask.checkWaitableOpArr(opArr) then
                finished = true
              end
              resumeEntry()
            end)
          end
        end
      elseif iWaitCondOp >= 0 then
        do
          local op = opArr[iWaitCondOp]
          cleaner:add(function()
            op:stopWaiting()
          end)
          return function(task, resumeEntry)
            op:wait(function()
              resumeEntry()
            end)
          end
        end
      elseif ConditionOpTask.checkWaitableOpArr(opArr) then
        return "end"
      else
        return function(task, resumeEntry)
          local waitTimeStep = 0.1
          local waitTimer = GameUtil.AddGlobalTimer(waitTimeStep, false, function()
            if ConditionOpTask.checkWaitableOpArr(opArr) then
              finished = true
              GameUtil.RemoveGlobalTimer(waitTimer)
              resumeEntry()
            end
          end)
          cleaner:add(function()
            GameUtil.RemoveGlobalTimer(waitTimer)
          end)
        end
      end
    end, function()
      cleaner:invoke()
      cleaner:clear()
      return "stop"
    end)
    return task
  end
  def.static("table", "=>", "number", "number").selectWaitableOp = function(opArr)
    local iWaitOnlyCondOp
    for i = 1, #opArr do
      local op = opArr[i]
      if op:canWait() and not op:hasState() then
        if iWaitOnlyCondOp then
          error(("wait opArr has multiple wait only condition op (#%d, #%d)"):format(iWaitOnlyCondOp, i), 2)
        end
        iWaitOnlyCondOp = i
      end
    end
    if iWaitOnlyCondOp then
      return iWaitOnlyCondOp, -1
    end
    for i = 1, #opArr do
      local op = opArr[i]
      if op:canWait() and (not op:hasState() or not op:getState()) then
        return -1, i
      end
    end
    return -1, -1
  end
  def.static("table", "=>", "boolean").checkWaitableOpArr = function(opArr)
    for i = 1, #opArr do
      local condOp = opArr[i]
      if condOp:hasState() and not condOp:getState() then
        return false
      end
    end
    return true
  end
end
ConditionOpTask.Commit()
return ConditionOpTask

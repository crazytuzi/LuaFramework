



local _M = {}
_M.__index = _M

local Helper = require"Zeus.Logic.Helper"

function _M.CompleteRequest(q,mult,npcid,cb)
  local kind = GameUtil.TryEnumToInt(q.Type)
  Pomelo.TaskHandler.submitTaskRequest(q.TemplateID,kind,mult,tostring(npcid),function (ex,sjson)
    if cb then
      cb(ex)
    end
  end)
end

function _M.DiscardRequest(q,cb)
  local kind = GameUtil.TryEnumToInt(q.Type)
  Pomelo.TaskHandler.discardTaskRequest(q.TemplateID,kind,function (ex,sjson)
    if cb then
      cb(ex)
    end
  end)
end

function _M.AcceptRequest(q,npcid,cb)
  local kind = GameUtil.TryEnumToInt(q.Type)
  Pomelo.TaskHandler.acceptTaskRequest(q.TemplateID,kind,tostring(npcid),function (ex,sjson)
    if cb then
      cb(ex)
    end
  end)
end

function _M.QuickFinishRequest(q,npcid,cb)
  local kind = GameUtil.TryEnumToInt(q.Type)
  Pomelo.TaskHandler.quickFinishRequest(q.TemplateID,kind,tostring(npcid or 0),function (ex,sjson)
    if cb then
      cb(ex)
    end
  end)
end

function _M.UpdateQuestState(q,cb)
  local kind = GameUtil.TryEnumToInt(q.Type)
  Pomelo.TaskHandler.updateTaskStatusRequest(q.TemplateID,kind,function (ex,sjson)
    if cb then
      cb(ex)
    end
  end)
end

function _M.RefreshRefineSoulRequest(q,cb)
  Pomelo.TaskHandler.refreshSoulTaskRequest(q.TemplateID,function (ex,sjson)
    if not ex and cb then
      cb()
    end
  end)
end

function _M.TaskFuncDeskRequest(npcid,cb)
  Pomelo.TaskHandler.taskFuncDeskRequest(npcid,function (ex,sjson)
    if not ex and cb then
      cb()
    end
  end)
end

function _M.AcceptLoopTaskRequest(npcid,cb,failcb)
    Pomelo.TaskHandler.acceptLoopTaskRequest(npcid,function (ex,sjson)
    if not ex and cb then
      cb()
    else
      if failcb then
        failcb()
      end
    end
  end)
end

function _M.AcceptTeacherTaskRequest(npcid,cb)
    Pomelo.TaskHandler.acceptDailyTaskRequest(npcid,function (ex,sjson)
    if not ex and cb then
      cb()
    end
  end)
end

return _M

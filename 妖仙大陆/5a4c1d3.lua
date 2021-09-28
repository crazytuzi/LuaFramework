



local _M = {}
_M.__index = _M

local NPCManager = DataMgr.Instance.NPCManager

function _M.GetNPC(id)
  return NPCManager:GetNPC(id)
end

function _M.RequestInteractive(id)
  Pomelo.NpcHandler.recoverByNpcRequest(tostring(id),function (err)
    
  end,XmdsNetManage.PackExtData.New(false,true))
end

function _M.RequestSteal(id, cb)
	
	
	
	
	
	
	Pomelo.StealHandler.stealRequest(id,function (ex,sjson)
		if not ex and cb then
			cb(sjson:ToData())
		end
	end)
end

return _M

local _M = {}
_M.__index = _M



function _M.getLllsion2InfoRequest(cb)
	Pomelo.FightLevelHandler.getLllsion2InfoRequest(function (ex,sjson)
		if not ex then
			local param = sjson:ToData()
			cb(param)
		end
	end)
end

function _M.EnterLllsion2Request()
  Pomelo.FightLevelHandler.enterLllsion2Request(function (ex,sjson)
    
    
    
    
  end)
end

return _M

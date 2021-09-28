
local _M = {}
_M.__index = _M

local cjson = require "cjson"
local helper = require "Zeus.Logic.Helper"
















function _M.RequestRevelryGetColumn(cb)
  
  Pomelo.ActivityRevelryHandler.revelryGetColumnRequest(function( ex, sjson )
    if ex ~= nil then
      
    end
    if cb ~= nil then
      cb(sjson:ToData())
    end
  end, nil)
end

function _M.RequestRevelryGetRank(id,cb)
  
  Pomelo.ActivityRevelryHandler.revelryGetRankInfoRequest(id, function( ex, sjson )
    
    
    if ex ~= nil then
      
    end
    if cb ~= nil then
      cb(sjson:ToData())
    end
  end, nil)
end

function _M.RequestRevelryExchange(id,num,cb)
  
  Pomelo.ActivityRevelryHandler.revelryExchangeRequest(id,num, function( ex )
    
    
    if ex ~= nil then
      
    end
    if cb ~= nil then
      cb()
    end
  end, nil)
end

function _M.initial()

end

function _M.fin()

end

function _M.InitNetWork()

end

return _M

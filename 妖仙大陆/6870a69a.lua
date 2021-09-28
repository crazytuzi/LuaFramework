
local _M = {}
_M.__index = _M
local cjson = require "cjson" 

function _M.GetExchangeLabelRequest(c2s_npcId, cb)
  Pomelo.ExchangeHandler.getExchangeLabelRequest(c2s_npcId, function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.getExchangeListRequest(c2s_npcId,c2s_typeId,cb)
  Pomelo.ExchangeHandler.getExchangeListRequest(c2s_npcId,c2s_typeId, function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.exchangeItemRequest(c2s_typeId,c2s_itemId,c2s_num,c2s_npcId,cb)
  Pomelo.ExchangeHandler.exchangeItemRequest(c2s_typeId,c2s_itemId,c2s_num,c2s_npcId, function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.allyFightExchangeRequest(c2s_npcId,c2s_typeId,cb)
  Pomelo.ExchangeHandler.allyFightExchangeRequest(c2s_npcId,c2s_typeId, function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

return _M

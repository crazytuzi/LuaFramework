local _M = {}
_M.__index = _M

local Helper = require"Zeus.Logic.Helper"
local cjson = require"cjson"
local ServerTime = require"Zeus.Logic.ServerTime"

function _M.Equip(code, cb)
  Pomelo.FashionHandler.equipFashionRequest(code, true, function(ex, sjson)
      if ex then return end
      local data = sjson:ToData()
      
      cb(data)
  end) 
end

function _M.Unequip(code, cb)
  Pomelo.FashionHandler.equipFashionRequest(code, false, function(ex, sjson)
      if ex then return end
      local data = sjson:ToData()
      
      cb(data)
  end) 
end

function _M.GetFashionsRequest(cb)
  Pomelo.FashionHandler.getFashionsRequest(function(ex, sjson)
      if ex then return end
      local msg = sjson:ToData()
      
      
      local data =  {
          code1 = msg.code1 or {},
          code2 = msg.code2 or {},
          code3 = msg.code3 or {},
          flagcode1 = msg.flagcode1 or {},
          flagcode2 = msg.flagcode2 or {},
          flagcode3 = msg.flagcode3 or {},
          equiped_code1 = msg.equiped_code1 or "",
          equiped_code2 = msg.equiped_code2 or "",
          equiped_code3 = msg.equiped_code3 or "",
      }
      cb(data)
  end)
end

function _M.DeleteFashionFlagRequest(code, cb)
  Pomelo.FashionHandler.deleteFashionFlagRequest(code, function(ex, sjson)
      if ex then return end
      
      
      cb()
  end)
end

function GlobalHooks.DynamicPushs.OnFashionGetPush(ex, json)
      if ex then return end
      local data = sjson:ToData()
      
      
end

function _M.initial()

end

function _M.InitNetWork()
  Pomelo.FashionHandler.onFashionGetPush(GlobalHooks.DynamicPushs.OnFashionGetPush)
end

return _M

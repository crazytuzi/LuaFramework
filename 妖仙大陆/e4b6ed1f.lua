local _M = {}
_M.__index = _M
local cjson = require "cjson" 
local Util      = require "Zeus.Logic.Util"

function _M.requestMallScoreItemList(cb)
  Pomelo.IntergalMallHandler.getMallScoreItemListRequest(-1,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param.s2c_tabitems)
    end
  end)
end


function _M.requestBuyIntergalItem(tabid,itemid,num,cb)
  Pomelo.IntergalMallHandler.buyIntergalItemRequest(tabid,itemid,num,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param.lastcount,param.currencyNum,param.total_num)
    end
  end)
end

function _M.InitNetWork()
    
end


return _M

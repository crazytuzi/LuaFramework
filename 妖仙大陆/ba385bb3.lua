local _M = {}
_M.__index = _M
local cjson = require "cjson" 
local Util      = require "Zeus.Logic.Util"


function _M.requestFateInfo(cb)
	Pomelo.XianYuanHandler.applyXianYuanRequest(function(ex,sjson)
    if not ex then
    	
      local param = sjson:ToData()
      cb(param.totalXianYuan,param.xianYuanGetInfo)
    end
  end)
end

function _M.InitNetWork()

end

return _M

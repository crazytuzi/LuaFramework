

local _M = {}
_M.__index = _M

local upstairsmsg = nil
local UpStairsList = nil

function _M.upLevelRequest(cb)
	Pomelo.UpLevelHandler.upLevelRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      upstairsmsg = msg.s2c_upData
      
      cb(msg.s2c_hasNext)
    end
  end)
end

function _M.upInfoRequest(cb)
  Pomelo.UpLevelHandler.upInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      upstairsmsg = msg.s2c_upData
      cb()
    end
  end)
end

function _M.Getupstairsmsg()
  return upstairsmsg
end

function _M.GetUpStairsList()
  return UpStairsList
end

function _M.InitNetWork()
  UpStairsList = GlobalHooks.DB.Find("UpLevelExp", {})
end

return _M




local _M = {}
_M.__index = _M
local cjson = require"cjson"

function GlobalHooks.DynamicPushs.suitPropertyUpPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
    if msg.s2c_msg and msg.s2c_property then
      local node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUISuitTips)
      if lua_obj==nil then
        node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISuitTips,0)
      end
      lua_obj:SetAttValue(msg)
    end
  end
end

function _M.InitNetWork()
  Pomelo.PlayerHandler.suitPropertyUpPush(GlobalHooks.DynamicPushs.suitPropertyUpPush)
end

return _M

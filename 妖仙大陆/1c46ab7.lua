local _M = {}
_M.__index = _M
local cjson = require "cjson"  

function _M.medalListRequest(cb)
  Pomelo.MedalHandler.medalListRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.gainMedalRequest(c2s_medalItemId,cb)
  Pomelo.MedalHandler.gainMedalRequest(c2s_medalItemId,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.getMedalInfoRequest(cb)
  Pomelo.MedalHandler.getMedalInfoRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.getMedalInfoByCodeRequest(c2s_medalItemId,cb)
  Pomelo.MedalHandler.getMedalInfoByCodeRequest(c2s_medalItemId,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end, XmdsNetManage.PackExtData.New(false, true))
end

function GlobalHooks.DynamicPushs.MedalTitleChangePush(ex, json)
  
  if ex == nil then
      local param = json:ToData()
      
      
      local node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIMedalUpdate)
      if  lua_obj == nil then
        node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIMedalUpdate, 0)
      end
      lua_obj.InitInfo(param)
  end
end

function _M.InitNetWork()
    Pomelo.GameSocket.medalTitleChangePush(GlobalHooks.DynamicPushs.MedalTitleChangePush)
end

return _M

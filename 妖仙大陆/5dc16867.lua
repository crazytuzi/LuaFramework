

local _M = {}
_M.__index = _M

local ShopInfo = nil

function _M.exchangeShopItemRequest(id,cb) 
  Pomelo.GuildShopHandler.exchangeShopItemRequest(id,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function _M.getGuildShopInfoRequest(cb)
  Pomelo.GuildShopHandler.getGuildShopInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      ShopInfo = msg.s2c_shopInfo
      cb()
    end
  end)
end

function _M.GetMyShopInfo()
  return ShopInfo
end

function GlobalHooks.DynamicPushs.shopRefreshPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
    if msg.type == 1 then
      EventManager.Fire('Guild.PushChangShop',{})
    end
  end
end

function _M.InitNetWork()
  Pomelo.GuildShopHandler.shopRefreshPush(GlobalHooks.DynamicPushs.shopRefreshPush)
end

function _M.initial()

end

return _M

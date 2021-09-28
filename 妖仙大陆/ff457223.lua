local _M = {}
_M.__index = _M

function _M.SyncAuctionInfoRequest(cb)
  Pomelo.AuctionHandler.syncAuctionInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb()
    end
  end)
end

function _M.CancelSyncAuctionInfoRequest()
  Pomelo.AuctionHandler.cancelSyncAuctionInfoRequest(function (ex,sjson)
    if not ex then
      
    end
  end)
end

function _M.AuctionListRequest(index, cb)
  Pomelo.AuctionHandler.auctionListRequest(index, function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb(msg)
    end
  end)
end

function _M.AuctionRequest(id, price, cb)
  Pomelo.AuctionHandler.auctionRequest(id, price, function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb()
    end
  end)
end

function _M.AuctionLogRequest(cb)
  Pomelo.AuctionHandler.auctionLogRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb(msg)
    end
  end)
end

function GlobalHooks.DynamicPushs.AuctionItemPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
    EventManager.Fire('Event.GuildAuction.Update', {update = "Update", data = msg})
  end
end

function GlobalHooks.DynamicPushs.AddAuctionItemPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
    EventManager.Fire('Event.GuildAuction.Update', {update = "Add", data = msg})
  end
end

function GlobalHooks.DynamicPushs.RemoveAuctionItemPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
    EventManager.Fire('Event.GuildAuction.Update', {update = "Remove", data = msg})
  end
end

function _M.InitNetWork()
  Pomelo.AuctionHandler.auctionItemPush(GlobalHooks.DynamicPushs.AuctionItemPush)
  Pomelo.AuctionHandler.addAuctionItemPush(GlobalHooks.DynamicPushs.AddAuctionItemPush)
  Pomelo.AuctionHandler.removeAuctionItemPush(GlobalHooks.DynamicPushs.RemoveAuctionItemPush)
end

return _M

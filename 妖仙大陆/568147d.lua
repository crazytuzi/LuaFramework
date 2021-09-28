

local _M = {}
_M.__index = _M

local RecycleBuyMsg = {}

local GoodsInfo = {}

function _M.BuyPageRequest(c2s_SellIndex,cb)
  Pomelo.SaleHandler.buyPageRequest(c2s_SellIndex,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      RecycleBuyMsg = msg.s2c_buyItems
      cb()
    end
  end)
end

function _M.BuyItemRequest(c2s_typeId,c2s_itemId,c2s_num,cb)
  Pomelo.SaleHandler.buyItemRequest(c2s_typeId,c2s_itemId,c2s_num,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb()
    end
  end)
end

function _M.SellItemsRequest(c2s_sellGrids,cb)
  Pomelo.SaleHandler.sellItemsRequest(c2s_sellGrids,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function _M.RebuyItemRequest(c2s_gridIndex,num,cb)
  Pomelo.SaleHandler.rebuyItemRequest(c2s_gridIndex,num,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb()
    end
  end)
end

function _M.autoBuyItemByCodeRequest(c2s_typeId,c2s_itemCode,c2s_num,cb, errorcb)
  Pomelo.SaleHandler.autoBuyItemByCodeRequest(c2s_typeId,c2s_itemCode,c2s_num, function (ex,sjson)
    if ex then 
      cb() 
    else
      local data = sjson:ToData()
      errorcb(data)
    end
  end, XmdsNetManage.PackExtData.New(true, true, nil))
end

function _M.GetRecycleBuyMsg()
  return RecycleBuyMsg
end

function _M.SetGoodsInfo(Info)
  GoodsInfo = Info
end

function _M.GetGoodsInfo()
  return GoodsInfo
end

function GlobalHooks.DynamicPushs.PushMail(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
  end
end

function _M.InitNetWork()
  Pomelo.MailHandler.onGetMailPush(GlobalHooks.DynamicPushs.PushMail)
end

return _M

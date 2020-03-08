local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ItemPriceHelper = Lplus.Class(MODULE_NAME)
local def = ItemPriceHelper.define
local MD5_STR_LEN = 32
local inited = false
local reqs
def.static().Init = function()
  if inited then
    return
  end
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ItemPriceHelper.OnLeaveWorld)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResItemYuanbaoPrice", ItemPriceHelper.OnSResItemYuanbaoPrice)
  inited = true
end
def.static("table", "function").GetItemsYuanbaoPriceAsync = function(itemIds, callback)
  local itemIds_set = {}
  for k, v in pairs(itemIds) do
    itemIds_set[v] = v
  end
  local reqId = ItemPriceHelper.GetItemIdsReqId(itemIds_set)
  reqs = reqs or {}
  local req
  if reqs[reqId] == nil then
    req = {
      timestamp = os.time()
    }
    req.callbacks = {
      [callback] = callback
    }
    reqs[reqId] = req
    ItemPriceHelper._CReqItemYuanbaoPrice(itemIds_set)
  else
    req = reqs[reqId]
    req.callbacks[callback] = callback
  end
end
def.static("table", "=>", "string").GetItemIdsReqId = function(itemIds)
  local strTable = {}
  for i, itemId in pairs(itemIds) do
    table.insert(strTable, itemId)
  end
  table.sort(strTable, function(l, r)
    return l < r
  end)
  local reqId = table.concat(strTable)
  if #reqId > MD5_STR_LEN then
    reqId = GameUtil.md5(reqId)
  end
  return reqId
end
def.static("table")._CReqItemYuanbaoPrice = function(itemIds)
  local itemIdVector = {}
  for k, v in pairs(itemIds) do
    itemIdVector[#itemIdVector + 1] = v
  end
  local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPrice").new(itemIdVector)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  reqs = nil
end
def.static("table").OnSResItemYuanbaoPrice = function(p)
  if reqs == nil then
    return
  end
  local itemIds_set = {}
  for k, v in pairs(p.itemid2yuanbao) do
    itemIds_set[k] = k
  end
  local reqId = ItemPriceHelper.GetItemIdsReqId(itemIds_set)
  local req = reqs[reqId]
  if req == nil then
    return
  end
  reqs[reqId] = nil
  for k, v in pairs(req.callbacks) do
    v(p.itemid2yuanbao)
  end
end
return ItemPriceHelper.Commit()

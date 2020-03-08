local Lplus = require("Lplus")
local OneClickStarUpEasy = Lplus.Class("OneClickStarUpEasy")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local def = OneClickStarUpEasy.define
def.static("=>", OneClickStarUpEasy).new = function()
  local self = OneClickStarUpEasy()
  return self
end
def.method("table", "number", "number", "=>", "table", "table").Calculate = function(self, fabaoItem, key, targetFabaoId)
  local starUpCfg = ItemUtils.GetFabaoItem(fabaoItem.id)
  local fabaoCfgs, fragmentId, cansupply = self:PrepareCfg(starUpCfg.classId)
  local bagFabaoInfo = self:GetBagFabaoInfo(fabaoCfgs, key)
  local costFabao = {}
  local costStone = {}
  local curStar = fabaoCfgs[fabaoItem.id].star or 0
  local targetStar = fabaoCfgs[targetFabaoId].star or 0
  if curStar >= targetStar then
    return nil, nil
  end
  for i = curStar, targetStar - 1 do
    local curId = self:GetIdByStar(fabaoCfgs, i)
    local targetId = self:GetIdByStar(fabaoCfgs, i + 1)
    self:StartUp(fabaoCfgs, bagFabaoInfo, costFabao, costStone, curId, targetId, fragmentId)
  end
  local cost, supply = self:TrimFabaoCost(costFabao, costStone)
  local costSort = {}
  local supplySort = {}
  for k, v in pairs(cost) do
    for k1, v1 in pairs(v) do
      table.insert(costSort, {
        key = k1,
        id = v1.id,
        num = v1.count,
        bagId = k
      })
    end
  end
  table.sort(costSort, function(a, b)
    return a.id < b.id
  end)
  for k, v in pairs(supply) do
    table.insert(supplySort, {id = k, num = v})
  end
  table.sort(supplySort, function(a, b)
    return a.id < b.id
  end)
  return costSort, supplySort
end
def.method("table", "table", "=>", "table", "table").TrimFabaoCost = function(self, costFabao, costStone)
  local ItemModule = require("Main.Item.ItemModule")
  local cost = {}
  local supply = {}
  local fabaoCost = {}
  cost[ItemModule.FABAOBAG] = fabaoCost
  for k, v in ipairs(costFabao) do
    if v.supply then
      if supply[v.id] then
        supply[v.id] = supply[v.id] + v.supply
      else
        supply[v.id] = v.supply
      end
    elseif v.key then
      if fabaoCost[v.key] then
        fabaoCost[v.key].count = fabaoCost[v.key].count + 1
      else
        fabaoCost[v.key] = {
          count = 1,
          id = v.id
        }
      end
    end
  end
  local itemCost = {}
  cost[ItemModule.BAG] = itemCost
  local keys = {}
  for k, v in pairs(costStone) do
    keys[k] = k
  end
  local stones = ItemModule.Instance():GetItemsByItemIds(ItemModule.BAG, keys)
  local costStoneClone = clone(costStone)
  for k, v in pairs(stones) do
    local id = v.id
    local num = v.number
    local needNum = costStoneClone[id]
    if needNum > 0 then
      if needNum - num > 0 then
        if itemCost[k] then
          itemCost[k].count = itemCost[k].count + num
        else
          itemCost[k] = {count = num, id = id}
        end
        costStoneClone[id] = needNum - num
      else
        if itemCost[k] then
          itemCost[k].count = itemCost[k].count + needNum
        else
          itemCost[k] = {count = needNum, id = id}
        end
        costStoneClone[id] = 0
      end
    end
  end
  for k, v in pairs(costStoneClone) do
    if v > 0 then
      supply[k] = v
    end
  end
  return cost, supply
end
def.method("table", "number", "=>", "number").GetIdByStar = function(self, fabaoCfgs, star)
  for k, v in pairs(fabaoCfgs) do
    if v.star == star then
      return k
    end
  end
  return 0
end
def.method("table", "table", "table", "table", "number", "number", "number").StartUp = function(self, fabaoCfgs, bagFabaoInfo, costFabao, costStone, curId, targetId, fragmentId)
  local curCfg = fabaoCfgs[curId]
  local targetCfg = fabaoCfgs[targetId]
  local needStone = clone(targetCfg.stones)
  self:MinusStoneCost(needStone, curCfg.stones)
  local needFragmentCount = targetCfg.pieceNum - curCfg.pieceNum
  for i = #bagFabaoInfo, 1, -1 do
    local item = bagFabaoInfo[i]
    local cfg = fabaoCfgs[item.id]
    if cfg.star <= curCfg.star then
      local bagFabao = table.remove(bagFabaoInfo, i)
      table.insert(costFabao, bagFabao)
      needFragmentCount = needFragmentCount - cfg.pieceNum
      self:MinusStoneCost(needStone, cfg.stones or {})
      if needFragmentCount <= 0 then
        break
      end
    end
  end
  if needFragmentCount > 0 then
    table.insert(costFabao, {id = fragmentId, supply = needFragmentCount})
  end
  self:PlusStoneCost(costStone, needStone)
end
def.method("table", "table").MinusStoneCost = function(self, source, minus)
  for k, v in pairs(minus) do
    if source[k] then
      source[k] = source[k] - v >= 0 and source[k] - v or 0
    end
  end
end
def.method("table", "table").PlusStoneCost = function(self, source, plus)
  for k, v in pairs(plus) do
    if source[k] then
      source[k] = source[k] + v
    else
      source[k] = v
    end
  end
end
def.method("table", "number", "=>", "table").GetBagFabaoInfo = function(self, fabaoCfgs, exceptKey)
  local relatedIds = {}
  for k, v in pairs(fabaoCfgs) do
    relatedIds[k] = k
  end
  local ItemModule = require("Main.Item.ItemModule")
  local bagFabaoInfo = {}
  local fabaos = ItemModule.Instance():GetItemsByItemIds(ItemModule.FABAOBAG, relatedIds)
  for k, v in pairs(fabaos) do
    if k ~= exceptKey then
      for i = 1, v.number do
        table.insert(bagFabaoInfo, {
          id = v.id,
          key = k
        })
      end
    end
  end
  table.sort(bagFabaoInfo, function(a, b)
    local cfga = fabaoCfgs[a.id]
    local cfgb = fabaoCfgs[b.id]
    return cfga.pieceNum < cfgb.pieceNum
  end)
  return bagFabaoInfo
end
def.method("number", "=>", "table", "number", "boolean").PrepareCfg = function(self, classId)
  local cfgs = {}
  local fragmentId = 0
  local cansupply = true
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAO_ITEM)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local cid = record:GetIntValue("classId")
    if cid == classId then
      local id = record:GetIntValue("id")
      local cfg = OneClickStarUpEasy.GetOneClickCfg(id)
      if cfg then
        local star = record:GetIntValue("rank")
        cfg.star = star
        cfgs[id] = cfg
        if star == 1 then
          fragmentId = record:GetIntValue("fragmentId")
          cansupply = record:GetCharValue("canUseYuanBao") ~= 0
          cfgs[fragmentId] = {pieceNum = 1, star = 0}
        end
      end
    end
  end
  return cfgs, fragmentId, cansupply
end
def.static("number", "=>", "table").GetOneClickCfg = function(fabaoId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAO_ONE_CLICK_STARUP_CFG, fabaoId)
  if record == nil then
    return nil
  end
  local fragmentNum = record:GetIntValue("fabaoFragmentNum")
  local stones = {}
  local rec = record:GetStructValue("stoneStruct")
  local size = rec:GetVectorSize("stoneList")
  for i = 0, size - 1 do
    local entry = rec:GetVectorValueByIdx("stoneList", i)
    local id = entry:GetIntValue("stoneId")
    local num = entry:GetIntValue("stoneNum")
    stones[id] = num
  end
  return {pieceNum = fragmentNum, stones = stones}
end
return OneClickStarUpEasy.Commit()

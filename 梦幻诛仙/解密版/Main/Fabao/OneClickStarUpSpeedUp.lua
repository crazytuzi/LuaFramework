local Lplus = require("Lplus")
local OneClickStarUpSpeedUp = Lplus.Class("OneClickStarUpSpeedUp")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local ChainTable = require("Utility.ChainTable")
local TepFaBaoInfo = require("netio.protocol.mzm.gsp.fabao.TepFaBaoInfo")
local def = OneClickStarUpSpeedUp.define
def.static("=>", OneClickStarUpSpeedUp).new = function()
  local self = OneClickStarUpSpeedUp()
  return self
end
def.field("table").fabaoCfg = nil
def.field("table").relatedItem = nil
def.field("table").finalfabao = nil
def.field("boolean").onlySameName = false
def.field("boolean").justFine = false
def.field("table").starUpFabao = nil
def.method("number", "table").SetStarUpFabao = function(self, bagKey, item)
  local fabaoCfg = ItemUtils.GetFabaoItem(item.id)
  local simpleFabao = self:CreateSimpleFabaoData(item, bagKey, fabaoCfg.classId)
  self.starUpFabao = simpleFabao
  self:UpdateCfg()
  self:UpdateRelatedItem()
end
def.method("boolean", "boolean").SetStrategy = function(self, osn, jf)
  self.onlySameName = osn
  self.justFine = jf
end
def.method("=>", "table", "table", "table", "table", "table").GetResult = function(self)
  if self.finalfabao then
    do
      local costFabao = {}
      local needFabao = {}
      local stoneNeed = {}
      local function parserCombineTree(fabao)
        if fabao.combine == true then
          if fabao.key ~= self.starUpFabao.key then
            if costFabao[fabao.key] then
              costFabao[fabao.key].num = costFabao[fabao.key].num + 1
            else
              costFabao[fabao.key] = {
                num = 1,
                id = fabao.id
              }
            end
          end
          local fabaoInfo = TepFaBaoInfo.new(fabao.key, fabao.id, 1, fabao.score, nil)
          return fabaoInfo
        elseif fabao.combine == false then
          if needFabao[fabao.id] then
            needFabao[fabao.id].num = needFabao[fabao.id].num + 1
          else
            needFabao[fabao.id] = {num = 1}
          end
          local fabaoInfo = TepFaBaoInfo.new(-1, fabao.id, 1, fabao.score, nil)
          return fabaoInfo
        elseif type(fabao.combine) == "table" then
          local cfg = self.fabaoCfg[fabao.family][fabao.star]
          local stoneId = cfg.stone
          local stoneNum = cfg.num
          if stoneNeed[stoneId] == nil then
            stoneNeed[stoneId] = 0
          end
          stoneNeed[stoneId] = stoneNeed[stoneId] + stoneNum
          local fabaoInfo = TepFaBaoInfo.new(-1, fabao.id, 1, fabao.score, nil)
          local sourceF = parserCombineTree(fabao.combine.source)
          table.insert(fabaoInfo.before, sourceF)
          local iter = ChainTable.headIter(fabao.combine)
          while true do
            local v = iter()
            if v then
              local costF = parserCombineTree(v)
              local lastF = fabaoInfo.before[#fabaoInfo.before]
              if #costF.before == 0 and #lastF.before == 0 and costF.score == 0 and lastF.score == 0 and costF.item_key == lastF.item_key and costF.fabao_cfgid == lastF.fabao_cfgid then
                costF.num = costF.num + 1
              else
                table.insert(fabaoInfo.before, costF)
              end
            else
              break
            end
          end
          return fabaoInfo
        end
      end
      local tepFaBaoInfo = parserCombineTree(self.finalfabao)
      local ItemModule = require("Main.Item.ItemModule")
      local needStone = {}
      local costStone = {}
      for k, v in pairs(stoneNeed) do
        local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, k)
        if v <= num then
          costStone[k] = v > 0 and v or nil
        else
          costStone[k] = num > 0 and num or nil
          needStone[k] = v - num > 0 and v - num or nil
        end
      end
      return costFabao, needFabao, costStone, needStone, tepFaBaoInfo
    end
  end
  return nil, nil, nil, nil, nil
end
local lastResume = 0
local AddJustFine = function(justFine)
  if justFine then
    justFine.addition = justFine.addition + 1
  end
end
local MinusJustFine = function(justFine)
  if justFine then
    justFine.addition = justFine.addition - 1
  end
end
local IsJustFine = function(justFine)
  if justFine then
    if justFine.addition <= 0 then
      return true
    else
      return false
    end
  else
    return false
  end
end
local function PromoteFabao(starUpFabao, bag, start, fabaoCfg, justFine)
  local cfg = fabaoCfg[starUpFabao.family][starUpFabao.star]
  local leftScore = cfg.need - starUpFabao.score
  local combine = ChainTable.new()
  combine.source = starUpFabao
  local iter = start
  while leftScore > 0 do
    if iter then
      local fabao = iter.value
      if fabao.star <= starUpFabao.star then
        ChainTable.remove(bag, iter)
        local add = fabaoCfg[fabao.family][fabao.star].add
        leftScore = leftScore - add
        ChainTable.insertTail(combine, fabao)
      end
      iter = iter.next
    else
      local cfg2 = fabaoCfg[starUpFabao.family][0]
      leftScore = leftScore - cfg2.add
      ChainTable.insertTail(combine, {
        family = starUpFabao.family,
        star = 0,
        score = 0,
        combine = false,
        id = cfg2.id,
        key = nil
      })
      AddJustFine(justFine)
    end
    local clock = os.clock()
    if clock - lastResume > 0.015 then
      lastResume = coroutine.yield()
    end
  end
  local nextCfg = fabaoCfg[starUpFabao.family][starUpFabao.star + 1]
  local targetFabao = {
    family = starUpFabao.family,
    star = starUpFabao.star + 1,
    score = -leftScore,
    combine = combine,
    id = nextCfg.id,
    key = nil
  }
  return targetFabao
end
local function ReturnFabao(fabao, more, start, justFine)
  local clock = os.clock()
  if clock - lastResume > 0.015 then
    lastResume = coroutine.yield()
  end
  if fabao.combine == true then
    ChainTable.insertBefore(more, start, fabao)
  elseif fabao.combine == false then
    MinusJustFine(justFine)
  elseif type(fabao.combine) == "table" then
    local iter = ChainTable.headIter(fabao.combine)
    while true do
      local v = iter()
      if v then
        ReturnFabao(v, more, start, justFine)
      else
        break
      end
    end
    ReturnFabao(fabao.combine.source, more, start, justFine)
  end
end
local function RefillFabao(targetFabao, more, start, fabaoCfg, justFine)
  if type(targetFabao.combine) == "table" then
    local sourceFabao = targetFabao.combine.source
    local cfg = fabaoCfg[sourceFabao.family][sourceFabao.star]
    local leftScore = cfg.need - sourceFabao.score
    local iter = targetFabao.combine.head
    while leftScore > 0 do
      local fabao = iter.value
      local add = fabaoCfg[fabao.family][fabao.star].add
      leftScore = leftScore - add
      iter = iter.next
    end
    while iter do
      ChainTable.remove(targetFabao.combine, iter)
      ReturnFabao(iter.value, more, start, justFine)
      iter = iter.next
    end
  end
end
local function MergeFabao(targetFabao, more, start, fabaoCfg, justFine)
  if type(targetFabao.combine) == "table" then
    if IsJustFine(justFine) then
      return
    end
    local iter = targetFabao.combine.head
    local sourceFabao = targetFabao.combine.source
    while true do
      if iter and iter ~= targetFabao.combine.tail then
        local fabao = iter.value
        if fabao.star < sourceFabao.star then
          local upFabao = PromoteFabao(fabao, targetFabao.combine, iter.next, fabaoCfg)
          iter.value = upFabao
          MergeFabao(upFabao, targetFabao.combine, iter.next, fabaoCfg, justFine)
          RefillFabao(targetFabao, more, start, fabaoCfg, justFine)
          if IsJustFine(justFine) then
            return
          end
        else
          iter = iter.next
        end
        break
      end
    end
  end
end
local function coroutineCalc(starUpFabao, relatedItem, fabaoCfg, justFine)
  lastResume = coroutine.yield()
  local finalFabao = PromoteFabao(starUpFabao, relatedItem, relatedItem.head, fabaoCfg, justFine)
  lastResume = coroutine.yield()
  MergeFabao(finalFabao, relatedItem, relatedItem.head, fabaoCfg, justFine)
  return finalFabao
end
def.method("function").Calculate = function(self, finishCallbcak)
  if self.starUpFabao and self.relatedItem then
    do
      local justFine
      if self.justFine then
        justFine = {addition = 0}
      end
      local coro = coroutine.create(coroutineCalc)
      local r, final
      r, final = coroutine.resume(coro, self.starUpFabao, self.relatedItem, self.fabaoCfg, justFine)
      if not r then
        error(final)
        return
      end
      local timer = 0
      local times = 0
      timer = GameUtil.AddGlobalTimer(0, false, function()
        times = times + 1
        if coroutine.status(coro) == "dead" then
          GameUtil.RemoveGlobalTimer(timer)
          self.finalfabao = final
          if finishCallbcak then
            warn("times:", times)
            finishCallbcak()
          end
        else
          r, final = coroutine.resume(coro, os.clock())
          if not r then
            GameUtil.RemoveGlobalTimer(timer)
            error(final)
          end
        end
      end)
    end
  end
end
def.method("number", "number", "number", "number", "=>", "boolean").CanUse = function(self, family, fabaoType, otherFamily, otherFabaoType)
  if self.onlySameName then
    return family == otherFamily
  else
    return fabaoType == otherFabaoType
  end
end
def.method().UpdateCfg = function(self)
  if self.starUpFabao then
    self.fabaoCfg = {}
    local starUpCfg = ItemUtils.GetFabaoItem(self.starUpFabao.id)
    local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAO_ITEM)
    local count = DynamicDataTable.GetRecordsCount(entrys)
    DynamicDataTable.FastGetRecordBegin(entrys)
    for i = 0, count - 1 do
      local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
      local fabaoType = record:GetIntValue("fabaoType")
      local classId = record:GetIntValue("classId")
      if self:CanUse(starUpCfg.classId, starUpCfg.fabaoType, classId, fabaoType) then
        local id = record:GetIntValue("id")
        local classId = record:GetIntValue("classId")
        local star = record:GetIntValue("rank")
        local add = record:GetIntValue("rankExp")
        local rankId = record:GetIntValue("rankId")
        local needExp, needStone, needNum = FabaoUtils.GetFabaoLevelUpNeedExpById(rankId)
        if self.fabaoCfg[classId] == nil then
          self.fabaoCfg[classId] = {}
        end
        if star == 1 then
          local fragmentId = record:GetIntValue("fragmentId")
          local fragmentNum = record:GetIntValue("fragmentCount")
          local canFill = record:GetCharValue("canUseYuanBao") ~= 0
          local fragmentCfg = ItemUtils.GetFabaoFragmentItem(fragmentId)
          local add = fragmentCfg.rankExp
          local needExp = (fragmentNum - 1) * add
          self.fabaoCfg[classId][0] = {
            add = add,
            need = needExp,
            stone = 0,
            num = 0,
            id = fragmentId
          }
        end
        self.fabaoCfg[classId][star] = {
          add = add,
          need = needExp,
          stone = needStone,
          num = needNum,
          id = id
        }
      end
    end
  end
end
def.method().UpdateRelatedItem = function(self)
  if self.fabaoCfg then
    local itemIds = {}
    local piecesIds = {}
    for k, v in pairs(self.fabaoCfg) do
      for k1, v1 in pairs(v) do
        if k1 == 0 then
          piecesIds[v1.id] = k
        else
          itemIds[v1.id] = k
        end
      end
    end
    local ItemModule = require("Main.Item.ItemModule")
    self.relatedItem = {}
    local fabaos = ItemModule.Instance():GetItemsByItemIds(ItemModule.FABAOBAG, itemIds)
    for k, v in pairs(fabaos) do
      if k ~= self.starUpFabao.key then
        for i = 1, v.number do
          local simpleFabao = self:CreateSimpleFabaoData(v, k, itemIds[v.id])
          table.insert(self.relatedItem, simpleFabao)
        end
      end
    end
    local pieces = ItemModule.Instance():GetItemsByItemIds(ItemModule.FABAOBAG, piecesIds)
    for k, v in pairs(pieces) do
      for i = 1, v.number do
        local simplePiece = self:CreatePieceData(v, k, piecesIds[v.id])
        table.insert(self.relatedItem, simplePiece)
      end
    end
    self:SortBag()
    local bagTbl = self.relatedItem
    self.relatedItem = ChainTable.new()
    for k, v in ipairs(bagTbl) do
      ChainTable.insertTail(self.relatedItem, v)
    end
  end
end
def.method().SortBag = function(self)
  if self.relatedItem then
    table.sort(self.relatedItem, function(a, b)
      local a_add = self.fabaoCfg[a.family][a.star].add
      local b_add = self.fabaoCfg[b.family][b.star].add
      return a_add > b_add
    end)
  end
end
def.method("table", "number", "number", "=>", "table").CreateSimpleFabaoData = function(self, fabao, key, family)
  if fabao and fabao.extraMap then
    local score = fabao.extraMap[ItemXStoreType.FABAO_CUR_EXP] or 0
    local fabaoCfg = ItemUtils.GetFabaoItem(fabao.id)
    local star = fabaoCfg.rank
    return {
      family = family,
      star = star,
      score = score,
      combine = true,
      id = fabao.id,
      key = key
    }
  else
    return nil
  end
end
def.method("table", "number", "number", "=>", "table").CreatePieceData = function(self, piece, key, family)
  local fragmentCfg = ItemUtils.GetFabaoFragmentItem(piece.id)
  return {
    family = family,
    star = 0,
    score = 0,
    combine = true,
    id = piece.id,
    key = key
  }
end
def.method("table").PrintFabao = function(self, fabao)
  local tbl = {}
  self:PrettyFabao(fabao, 0, tbl)
  warn(table.concat(tbl, "\n"))
end
def.method("table", "number", "table").PrettyFabao = function(self, obj, level, tbl)
  table.insert(tbl, string.rep("\t", level) .. "<" .. obj.family .. "," .. obj.star .. "," .. obj.score .. ">")
  if obj.combine == true then
    table.insert(tbl, string.rep("\t", level) .. "[true]")
  elseif obj.combine == false then
    table.insert(tbl, string.rep("\t", level) .. "[false]")
  elseif type(obj.combine) == "table" then
    table.insert(tbl, string.rep("\t", level) .. "[")
    self:PrettyFabao(obj.combine.source, level + 1, tbl)
    table.insert(tbl, string.rep("\t", level + 1) .. "&")
    local iter = ChainTable.headIter(obj.combine)
    while true do
      local v = iter()
      if v then
        self:PrettyFabao(v, level + 1, tbl)
        table.insert(tbl, string.rep("\t", level + 1) .. "+")
      else
        break
      end
    end
    table.insert(tbl, string.rep("\t", level) .. "]")
  end
end
return OneClickStarUpSpeedUp.Commit()

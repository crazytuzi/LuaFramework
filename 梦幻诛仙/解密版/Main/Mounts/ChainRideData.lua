local Lplus = require("Lplus")
local ChainRideData = Lplus.Class("ChainRideData")
local def = ChainRideData.define
def.field("table").seatToIndex = nil
def.field("table").indexToCfg = nil
def.field("table").groupToIndex = nil
def.static("number", "=>", ChainRideData).CreateChainRideData = function(rideId)
  local cfg = ChainRideData.LoadChainRideData(rideId)
  if cfg then
    local seatToIndex = {}
    local indexToCfg = {}
    local groupToIndex = {}
    local relations = {}
    for k, v in ipairs(cfg) do
      if v.seat > 0 then
        seatToIndex[v.seat] = v.index
      end
      indexToCfg[v.index] = v
      if not groupToIndex[v.group] then
        groupToIndex[v.group] = {}
      end
      groupToIndex[v.group][v.index] = v.index
      if not relations[v.prevNode] then
        relations[v.prevNode] = {}
      end
      relations[v.prevNode][v.index] = v.index
    end
    for k, v in pairs(indexToCfg) do
      v.children = relations[k]
    end
    local data = ChainRideData()
    data.seatToIndex = seatToIndex
    data.indexToCfg = indexToCfg
    data.groupToIndex = groupToIndex
    return data
  else
    return nil
  end
end
def.static("number", "=>", "table").LoadChainRideData = function(mountId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MOUNTS_CHAIN_CFG, mountId)
  if not record then
    return nil
  end
  local cfg = {}
  local nodeStruct = record:GetStructValue("nodeStruct")
  local nodeSize = DynamicRecord.GetVectorSize(nodeStruct, "nodeList")
  for i = 0, nodeSize - 1 do
    local rec = nodeStruct:GetVectorValueByIdx("nodeList", i)
    local index = rec:GetIntValue("index")
    local modelId = rec:GetIntValue("modelCfgId")
    local boneEffectCfgId = rec:GetIntValue("boneEffectCfgId")
    local precursorIndex = rec:GetIntValue("precursorIndex")
    local offsetX = rec:GetFloatValue("offsetX")
    local offsetY = rec:GetFloatValue("offsetY")
    local seatIndex = rec:GetIntValue("seatIndex")
    local seatGroupId = rec:GetIntValue("seatGroupId")
    table.insert(cfg, {
      index = index,
      modelId = modelId,
      boneEffectId = boneEffectCfgId,
      prevNode = precursorIndex,
      xOffset = offsetX,
      yOffset = -offsetY,
      seat = seatIndex,
      group = seatGroupId
    })
  end
  return cfg
end
def.method("number", "=>", "table").GetIndexCfg = function(self, rideIndex)
  return self.indexToCfg[rideIndex]
end
def.method("number", "=>", "number").GetIndexBySeat = function(self, seat)
  local index = self.seatToIndex[seat]
  if index then
    return index
  else
    return 0
  end
end
def.method("number", "=>", "table").GetIndexByGroup = function(self, group)
  return self.groupToIndex[group]
end
def.method("number", "number", "=>", "table").GetNeedCreateByIndex = function(self, from, to)
  local relatedGroup = {}
  local createIndexs = {}
  if self:_GetCreateTreeByIndex(relatedGroup, createIndexs, from, to) then
    return createIndexs
  else
    return nil
  end
end
def.method("table", "table", "number", "number", "=>", "boolean")._GetCreateTreeByIndex = function(self, relatedGroup, createIndexs, from, to)
  if createIndexs[to] then
    return true
  end
  local newRelatedGroup = {}
  while true do
    if to == from or createIndexs[to] then
      break
    end
    local toCfg = self:GetIndexCfg(to)
    if toCfg then
      createIndexs[to] = to
      if not relatedGroup[toCfg.group] then
        newRelatedGroup[toCfg.group] = toCfg.group
        relatedGroup[toCfg.group] = toCfg.group
      end
      to = toCfg.prevNode
    else
      return false
    end
  end
  if next(newRelatedGroup) then
    for k, v in pairs(newRelatedGroup) do
      local groupIndex = self:GetIndexByGroup(k)
      if groupIndex then
        for k1, v1 in pairs(groupIndex) do
          if not self:_GetCreateTreeByIndex(relatedGroup, createIndexs, from, k1) then
            return false
          end
        end
      else
        return false
      end
    end
  end
  return true
end
def.method("=>", "number").GetHeadIndex = function(self)
  for k, v in pairs(self.indexToCfg) do
    if v.prevNode == 0 then
      return k
    end
  end
  return 0
end
ChainRideData.Commit()
return ChainRideData

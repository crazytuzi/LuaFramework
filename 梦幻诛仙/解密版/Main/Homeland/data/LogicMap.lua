local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local LogicMap = Lplus.Class(CUR_CLASS_NAME)
local def = LogicMap.define
local instance
LogicMap.TYPE_VALUE = {
  BLOCK = 1,
  CARPET = 2,
  WALL_DECORATE = 4,
  GROUND_OBJECT = 8,
  WALL = 32,
  MASK = 64
}
def.field("table").bytes = nil
def.field("number").width = 0
def.field("number").height = 0
def.const("number").HEAD_LENTH = 28
def.field("number").cellWidth = 16
def.field("number").cellHeight = 16
def.static("=>", LogicMap).Instance = function()
  if instance == nil then
    instance = LogicMap.New()
  end
  return instance
end
def.static("=>", LogicMap).New = function()
  local obj = LogicMap()
  return obj
end
def.method().Destroy = function(self)
  self.bytes = nil
  self.width = 0
  self.height = 0
end
def.method("=>", "boolean").IsLoaded = function(self)
  return self.bytes ~= nil and self.width > 0 and 0 < self.height
end
def.method("string").Load = function(self, path)
  if path == "" then
    return
  end
  local data = GameUtil.ReadFileAllContent(path)
  local bytes = data and data:get_bytes()
  if bytes then
    self.height = bit.lshift(bytes[8], 24) + bit.lshift(bytes[7], 16) + bit.lshift(bytes[6], 8) + bytes[5]
    self.width = bit.lshift(bytes[12], 24) + bit.lshift(bytes[11], 16) + bit.lshift(bytes[10], 8) + bytes[9]
  end
  self.bytes = bytes or {}
end
def.method("number", "number", "=>", "boolean").IsBlock = function(self, x, y)
  return self:IsThisCellType(x, y, LogicMap.TYPE_VALUE.BLOCK)
end
def.method("number", "number", "=>", "boolean").IsMask = function(self, x, y)
  local cx = math.floor(x / self.cellWidth)
  local cy = math.floor(y / self.cellHeight)
  return self:IsThisCellType(cx, cy, LogicMap.TYPE_VALUE.MASK)
end
def.method("number", "number").SetBlock = function(self, x, y)
  self:SetCell(x, y, LogicMap.TYPE_VALUE.BLOCK)
end
def.method("number", "number").RemoveBlock = function(self, x, y)
  self:RemoveCell(x, y, LogicMap.TYPE_VALUE.BLOCK)
end
def.method("number", "number").SetMask = function(self, x, y)
  self:SetCell(x, y, LogicMap.TYPE_VALUE.MASK)
end
def.method("number", "number").RemoveMask = function(self, x, y)
  self:RemoveCell(x, y, LogicMap.TYPE_VALUE.MASK)
end
def.method("number", "number", "number").SetCell = function(self, x, y, cellType)
  if self.bytes == nil then
    if MapScene.SetLogicDataBit then
      local scene = gmodule.moduleMgr:GetModule(ModuleId.MAP).scene
      MapScene.SetLogicDataBit(scene, x, y, cellType)
    end
    return
  end
  local idx = self:GetCellIdx(x, y)
  local data = self.bytes[idx]
  if data == nil then
    return
  end
  self.bytes[idx] = bit.bor(data, cellType)
end
def.method("number", "number", "number").RemoveCell = function(self, x, y, cellType)
  if self.bytes == nil then
    if MapScene.RemoveLogicDataBit then
      local scene = gmodule.moduleMgr:GetModule(ModuleId.MAP).scene
      MapScene.RemoveLogicDataBit(scene, x, y, cellType)
    end
    return
  end
  local idx = self:GetCellIdx(x, y)
  local data = self.bytes[idx]
  if data == nil then
    return
  end
  self.bytes[idx] = bit.band(data, bit.bnot(cellType))
end
def.method("number", "number", "number", "=>", "boolean").IsThisCellType = function(self, x, y, typeValue)
  if self.bytes == nil then
    if MapScene.CheckLogicDataBit then
      local scene = gmodule.moduleMgr:GetModule(ModuleId.MAP).scene
      return MapScene.CheckLogicDataBit(scene, x, y, typeValue)
    else
      return false
    end
  end
  local idx = self:GetCellIdx(x, y)
  local data = self.bytes[idx]
  if data == nil then
    return false
  end
  return bit.band(data, typeValue) > 0
end
def.method("number", "number", "=>", "boolean").IsCellExist = function(self, x, y)
  if self.bytes == nil then
    if MapScene.GetLogicMapData then
      local scene = gmodule.moduleMgr:GetModule(ModuleId.MAP).scene
      return MapScene.GetLogicMapData(scene, x, y, cellType) ~= nil
    else
      return false
    end
  end
  local idx = self:GetCellIdx(x, y)
  local data = self.bytes[idx]
  if data == nil then
    return false
  end
  return true
end
def.method("number", "number", "=>", "number").GetCellIdx = function(self, x, y)
  local idx = y * self.width + x + LogicMap.HEAD_LENTH + 1
  return idx
end
def.method("number", "number", "number", "number", "=>", "boolean").CheckBlockInBound = function(self, start_x, start_y, width, height)
  local cx, cy = start_x, start_y
  if not self:IsCellExist(cx, cy) then
    return false
  end
  local cx, cy = start_x + width - 1, start_y + height - 1
  if not self:IsCellExist(cx, cy) then
    return false
  end
  return true
end
def.method("number", "number", "number", "number", "table", "=>", "boolean").CheckBlockData = function(self, start_x, start_y, width, height, boxdata)
  local v
  for j = 0, height - 1 do
    for i = 1, width do
      v = boxdata[j * width + i]
      local cx, cy = start_x + i - 1, start_y + j
      if not self:IsCellExist(cx, cy) then
        return false
      end
      if bit.band(v, LogicMap.TYPE_VALUE.BLOCK) ~= 0 and (self:IsBlock(cx, cy) or self:IsThisCellType(cx, cy, LogicMap.TYPE_VALUE.WALL)) then
        return false
      elseif bit.band(v, LogicMap.TYPE_VALUE.CARPET) ~= 0 and (self:IsThisCellType(cx, cy, LogicMap.TYPE_VALUE.CARPET) or self:IsBlock(cx, cy) and not self:IsThisCellType(cx, cy, LogicMap.TYPE_VALUE.GROUND_OBJECT)) then
        return false
      elseif bit.band(v, LogicMap.TYPE_VALUE.WALL_DECORATE) ~= 0 and (self:IsThisCellType(cx, cy, LogicMap.TYPE_VALUE.WALL_DECORATE) or not self:IsThisCellType(cx, cy, LogicMap.TYPE_VALUE.WALL)) then
        return false
      end
    end
  end
  return true
end
def.method("number", "number", "number", "number", "table").SetBlockData = function(self, start_x, start_y, width, height, boxdata)
  local v
  for j = 0, height - 1 do
    for i = 1, width do
      v = boxdata[j * width + i]
      self:SetCell(start_x + i - 1, start_y + j, v)
    end
  end
end
def.method("number", "number", "number", "number", "table").ClearBlockData = function(self, start_x, start_y, width, height, boxdata)
  local v
  for j = 0, height - 1 do
    for i = 1, width do
      v = boxdata[j * width + i]
      self:RemoveCell(start_x + i - 1, start_y + j, v)
    end
  end
end
def.method("number", "number", "number", "number", "table", "=>", "boolean").CheckMapMask = function(self, start_x, start_y, width, height, boxdata)
  local v
  for j = 0, height - 1 do
    for i = 1, width do
      v = boxdata[j * width + i]
      local cx, cy = start_x + i - 1, start_y + j
      if not self:IsCellExist(cx, cy) then
        return true
      end
      if bit.band(v, LogicMap.TYPE_VALUE.BLOCK) ~= 0 and self:IsThisCellType(cx, cy, LogicMap.TYPE_VALUE.MASK) and not self:IsThisCellType(cx, cy, LogicMap.TYPE_VALUE.GROUND_OBJECT) then
        return true
      end
    end
  end
  return false
end
def.method("number", "number", "=>", "number", "number").FindAdjacentValidPoint = function(self, x, y)
  local cx = math.floor(x / self.cellWidth)
  local cy = math.floor(y / self.cellHeight)
  if self:IsBlock(cx, cy) then
    local dist = self.height
    if self.height > self.width then
      dist = self.width
    end
    local tcx, tcy, fx, fy = 0, 0, 0, 0
    local i, j, k = 0, 0, 0
    for i = 1, dist do
      if cx - i < 0 or cx + i > self.width or cy - i < 0 or cy + i > self.height then
        break
      end
      for j = -i, i do
        for k = -i, i do
          if j == i or j == -i or k == i or k == -i then
            tcx = cx + j
            tcy = cy + k
            if tcx >= 0 and tcy >= 0 and tcx < self.width and tcy < self.height and not self:IsBlock(tcx, tcy) and (fx == 0 and fy == 0 or math.abs(fx) * math.abs(fx) + math.abs(fy) * math.abs(fy) > math.abs(k) * math.abs(k) + math.abs(j) * math.abs(j)) then
              fx = j
              fy = k
            end
          end
        end
      end
      if fx ~= 0 or fy ~= 0 then
        tcx = cx + fx
        tcy = cy + fy
        return (tcx + 0.5) * self.cellWidth, (tcy + 0.5) * self.cellHeight
      end
    end
  end
  return x, y
end
return LogicMap.Commit()

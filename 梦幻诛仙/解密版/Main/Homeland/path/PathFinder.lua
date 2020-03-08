local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local PathFinder = Lplus.Class(CUR_CLASS_NAME)
local def = PathFinder.define
local LogicMap = require("Main.Homeland.data.LogicMap")
local instance
def.field("table").openXList = nil
def.field("table").openYList = nil
def.field("table").openIdxList = nil
def.field("table").closeList = nil
def.field("table").parentX = nil
def.field("table").parentY = nil
def.field("table").Gcost = nil
def.field("table").Hcost = nil
def.field("table").Fcost = nil
def.static("=>", PathFinder).Instance = function()
  if instance == nil then
    instance = PathFinder()
  end
  return instance
end
def.method("number", "number", "number", "number", "number", "=>", "table").FindPath = function(self, start_x, start_y, target_x, target_y, cellDistance)
  local lgc = LogicMap.Instance()
  local start_cell_x = math.floor(start_x / lgc.cellWidth)
  local start_cell_y = math.floor(start_y / lgc.cellHeight)
  if lgc:IsBlock(start_cell_x, start_cell_y) then
    local new_x, new_y = lgc:FindAdjacentValidPoint(start_x, start_y)
    return {
      [0] = {x = start_x, y = start_y},
      [1] = {x = new_x, y = new_y}
    }
  end
  local dest_cell_x = math.floor(target_x / lgc.cellWidth)
  local dest_cell_y = math.floor(target_y / lgc.cellHeight)
  if lgc:IsBlock(dest_cell_x, dest_cell_y) then
    local new_tar_x, new_tar_y = lgc:FindAdjacentValidPoint(target_x, target_y)
    if target_x == new_tar_x and target_y == target_y then
      return nil
    end
    target_x = new_tar_x
    target_y = new_tar_y
    dest_cell_x = math.floor(target_x / lgc.cellWidth)
    dest_cell_y = math.floor(target_y / lgc.cellHeight)
  end
  local path = self:_DoFindPath(start_cell_x, start_cell_y, dest_cell_x, dest_cell_y)
  if path == nil or #path <= 1 then
    return nil
  end
  if cellDistance > 0 then
    if #path - cellDistance <= 1 then
      return nil
    end
    while cellDistance > 0 do
      table.remove(path, 1)
      cellDistance = cellDistance - 1
    end
    target_x = (self.parentX[path[1]] + 0.5) * lgc.cellWidth
    target_y = (self.parentY[path[1]] + 0.5) * lgc.cellHeight
  end
  local result = self:SmoothPath(start_x, start_y, target_x, target_y, path)
  return result
end
def.method("number", "number", "number", "number", "=>", "table")._DoFindPath = function(self, start_x, start_y, target_x, target_y)
  if start_x == target_x and start_y == target_y then
    return nil
  end
  if LogicMap.Instance():IsBlock(target_x, target_y) then
    return nil
  end
  local lgc = LogicMap.Instance()
  PathFinder.Instance()
  instance.openIdxList = {}
  instance.openXList = {}
  instance.openYList = {}
  instance.Gcost = {}
  instance.Hcost = {}
  instance.Fcost = {}
  instance.parentX = {}
  instance.parentY = {}
  local openList = {}
  local closedList = {}
  local openIdx = 1
  self.openIdxList[1] = openIdx
  self.openXList[1] = start_x
  self.openYList[1] = start_y
  local parent_x, parent_y = 0, 0
  local a, b = 0, 0
  local addCost, tempGcost = 0, 0
  self.Gcost[start_y * lgc.width + start_x] = 0
  local arrayPos = 0
  local pathfound = false
  while #self.openIdxList > 0 do
    do
      local idx = self.openIdxList[1]
      parent_x = self.openXList[idx]
      parent_y = self.openYList[idx]
      closedList[parent_y * lgc.width + parent_x] = true
      self.openIdxList[1] = self.openIdxList[#self.openIdxList]
      self.openIdxList[#self.openIdxList] = nil
      self:AdjustHeap(self.openIdxList)
      for b = parent_y - 1, parent_y + 1 do
        for a = parent_x - 1, parent_x + 1 do
          if a >= 0 and b >= 0 and a < lgc.width and b < lgc.height then
            arrayPos = b * lgc.width + a
            if not closedList[arrayPos] and not lgc:IsBlock(a, b) then
              if not openList[arrayPos] then
                openIdx = openIdx + 1
                if openIdx > 1024 then
                  return nil
                end
                self.openIdxList[#self.openIdxList + 1] = openIdx
                self.openXList[openIdx] = a
                self.openYList[openIdx] = b
                if math.abs(a - parent_x) == 1 and math.abs(b - parent_y) == 1 then
                  addCost = 14
                else
                  addCost = 10
                end
                if self.Gcost[arrayPos] == nil then
                  self.Gcost[arrayPos] = 0
                end
                self.Gcost[arrayPos] = self.Gcost[arrayPos] + addCost
                self.Hcost[openIdx] = 10 * (math.abs(a - target_x) + math.abs(b - target_y))
                self.Fcost[openIdx] = self.Gcost[arrayPos] + self.Hcost[openIdx]
                self.parentX[arrayPos] = parent_x
                self.parentY[arrayPos] = parent_y
                self:BubbleUpHeap(self.openIdxList, #self.openIdxList)
                openList[arrayPos] = true
              else
                if math.abs(a - parent_x) == 1 and math.abs(b - parent_y) == 1 then
                  addCost = 14
                else
                  addCost = 10
                end
                tempGcost = self.Gcost[parent_y * lgc.width + parent_x] + addCost
                if self.Gcost[arrayPos] == nil then
                  warn("self.Gcost[arrayPos] is nil : ", b, a)
                  self.Gcost[arrayPos] = 0
                end
                if tempGcost < self.Gcost[arrayPos] then
                  self.parentX[arrayPos] = parent_x
                  self.parentY[arrayPos] = parent_y
                  self.Gcost[arrayPos] = tempGcost
                  local openIdx_i
                  for opx = 1, #self.openIdxList do
                    openIdx_i = self.openIdxList[opx]
                    if self.openXList[openIdx_i] == a and self.openYList[openIdx_i] == b then
                      self.Fcost[openIdx_i] = self.Gcost[arrayPos] + self.Hcost[openIdx_i]
                      self:BubbleUpHeap(self.openIdxList, opx)
                      break
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    do break end
    do break end
    if openList[target_y * lgc.width + target_x] then
      pathfound = true
      break
    end
  end
  if pathfound then
    local path = {}
    local path_x, path_y = target_x, target_y
    local pos = 0
    while path_x ~= start_x or path_y ~= start_y do
      pos = path_y * lgc.width + path_x
      path[#path + 1] = pos
      path_x = self.parentX[pos]
      path_y = self.parentY[pos]
    end
    path[#path + 1] = 0
    return path
  end
  return nil
end
def.method("table").AdjustHeap = function(self, heap)
  local u, v = 1, 1
  local temp
  while true do
    u = v
    if 2 * u + 1 <= #heap then
      if self.Fcost[heap[u]] >= self.Fcost[heap[2 * u]] then
        v = 2 * u
      end
      if self.Fcost[heap[v]] >= self.Fcost[heap[2 * u + 1]] then
        v = 2 * u + 1
      end
    elseif 2 * u <= #heap and self.Fcost[heap[u]] >= self.Fcost[heap[2 * u]] then
      v = 2 * u
    end
    if u ~= v then
      temp = heap[u]
      heap[u] = heap[v]
      heap[v] = temp
    else
      break
    end
  end
end
def.method("table", "number").BubbleUpHeap = function(self, heap, idx)
  local temp, p_idx
  while idx > 1 do
    p_idx = math.floor(idx / 2)
    if self.Fcost[heap[idx]] < self.Fcost[heap[p_idx]] then
      temp = heap[p_idx]
      heap[p_idx] = heap[idx]
      heap[idx] = temp
      idx = p_idx
    else
      break
    end
  end
end
def.method("number", "number", "number", "number", "=>", "number").IsCellConnected = function(self, src_x, src_y, dest_x, dest_y)
  local dx = math.abs(src_x - dest_x)
  local dy = math.abs(src_y - dest_y)
  if dx == 0 then
    local ay = 1
    if dest_y < src_y then
      ay = -1
    end
    local y = src_y
    for i = 0, dy do
      if LogicMap.Instance():IsBlock(src_x, y) then
        return -1
      end
      y = y + ay
    end
    return 1
  end
  if dy == 0 then
    local ax = 1
    if dest_x < src_x then
      ax = -1
    end
    local x = src_x
    for i = 0, dx do
      if LogicMap.Instance():IsBlock(x, src_y) then
        return -1
      end
      x = x + ax
    end
    return 1
  end
  return 0
end
def.method("number", "number", "number", "number", "=>", "boolean").IsPointConnected = function(self, src_x, src_y, dest_x, dest_y)
  local lgc = LogicMap.Instance()
  local src_cx = math.floor(src_x / lgc.cellWidth)
  local src_cy = math.floor(src_y / lgc.cellHeight)
  local dest_cx = math.floor(dest_x / lgc.cellWidth)
  local dest_cy = math.floor(dest_y / lgc.cellHeight)
  local ret = self:IsCellConnected(src_cx, src_cy, dest_cx, dest_cy)
  if ret ~= 0 then
    return ret > 0
  end
  local dpx = math.abs(src_x - dest_x)
  local dpy = math.abs(src_y - dest_y)
  local dcx = math.abs(src_cx - dest_cx)
  local dcy = math.abs(src_cy - dest_cy)
  local acx, acy = 1, 1
  if src_cx > dest_cx then
    acx = -1
  end
  if src_cy > dest_cy then
    acy = -1
  end
  local dis_x = src_x % lgc.cellWidth
  if src_x < dest_x then
    dis_x = lgc.cellWidth - dis_x
  end
  local dis_y = src_y % lgc.cellHeight
  if src_y < dest_y then
    dis_y = lgc.cellHeight - dis_y
  end
  local k = dpy / dpx
  local delta_x, step_y, delta_y, last_delta_y = 0, 0, 0, 0
  local cx, cy = src_cx, src_cy
  for i = 1, dcx do
    delta_x = delta_x + dis_x
    if i == dcx then
      delta_x = dpx
    end
    last_delta_y = delta_y
    delta_y = k * delta_x
    step_y = step_y + delta_y - last_delta_y
    while true do
      if lgc:IsBlock(cx, cy) then
        return false
      end
      if dis_y > step_y then
        break
      end
      cy = cy + acy
      step_y = step_y - dis_y
      dis_y = lgc.cellHeight
    end
    cx = cx + acx
    dis_x = lgc.cellWidth
  end
  return true
end
def.method("number", "number", "number", "number", "table", "=>", "table").SmoothPath = function(self, src_x, src_y, dest_x, dest_y, path)
  local lgc = LogicMap.Instance()
  local result = {}
  local begin_pt, end_pt = {}, {}
  result[0] = {x = src_x, y = src_y}
  local pathIdx = #path
  local keyPointIdx
  while pathIdx > 1 do
    if pathIdx == #path then
      begin_pt.x = src_x
      begin_pt.y = src_y
    else
      begin_pt.x = (self.parentX[path[pathIdx]] + 0.5) * lgc.cellWidth
      begin_pt.y = (self.parentY[path[pathIdx]] + 0.5) * lgc.cellHeight
    end
    for keyPointIdx = 1, pathIdx - 1 do
      if keyPointIdx <= 1 then
        end_pt = {x = dest_x, y = dest_y}
      else
        end_pt.x = (self.parentX[path[keyPointIdx]] + 0.5) * lgc.cellWidth
        end_pt.y = (self.parentY[path[keyPointIdx]] + 0.5) * lgc.cellHeight
      end
      if keyPointIdx == pathIdx - 1 or self:IsPointConnected(begin_pt.x, begin_pt.y, end_pt.x, end_pt.y) then
        table.insert(result, end_pt)
        pathIdx = keyPointIdx
        break
      end
    end
  end
  return result
end
return PathFinder.Commit()

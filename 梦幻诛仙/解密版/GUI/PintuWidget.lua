local Lplus = require("Lplus")
local PintuWidget = Lplus.Class("PintuWidget")
local GUIUtils = require("GUI.GUIUtils")
local Vector3 = require("Types.Vector3")
local Rect = require("Types.Rect")
local MathHelper = require("Common.MathHelper")
local def = PintuWidget.define
def.field("userdata").m_root = nil
def.field("number").m_iconId = 0
def.field("number").m_slice = 0
def.field("function").m_callback = nil
def.field("number").m_length = 0
def.field("boolean").m_active = false
def.field("userdata").m_template = nil
def.field("table").m_positions = nil
def.field("table").m_tiles = nil
def.field("number").m_select = 0
def.field("boolean").m_lock = false
def.static("userdata", "number", "number", "function", "=>", PintuWidget).Create = function(root, iconId, slice, winCallback)
  if IsNil(root) then
    return nil
  end
  if iconId <= 0 then
    return nil
  end
  if slice < 2 then
    return nil
  end
  local widget = root:GetComponent("UIWidget")
  if widget == nil then
    return nil
  end
  local template = root:FindDirect("Template")
  if template == nil then
    return
  end
  local w = widget:get_width()
  local h = widget:get_height()
  local pintu = PintuWidget()
  pintu.m_root = root
  pintu.m_iconId = iconId
  pintu.m_slice = slice
  pintu.m_callback = winCallback
  pintu.m_length = w > h and w or h
  pintu.m_active = false
  pintu:InitTemplate(function()
    pintu:GenenrateTile()
  end)
  return pintu
end
def.method("function").InitTemplate = function(self, cb)
  local perTileLen = self.m_length / self.m_slice
  local halfPerTileLen = perTileLen / 2
  local halfLen = self.m_length / 2
  self.m_template = self.m_root:FindDirect("Template")
  self.m_template:GetComponent("TweenPosition"):set_enabled(false)
  local uiTexture = self.m_template:GetComponent("UITexture")
  uiTexture:set_width(perTileLen)
  uiTexture:set_height(perTileLen)
  local select = self.m_template:FindDirect("Img_Toggle")
  local uiSprite = select:GetComponent("UISprite")
  uiSprite:set_width(perTileLen * 1.2)
  uiSprite:set_height(perTileLen * 1.2)
  self.m_template:FindDirect("Img_Toggle"):SetActive(false)
  self.m_positions = {}
  for i = 1, self.m_slice * self.m_slice do
    local lineIndex = math.floor((i - 1) / self.m_slice)
    local y = halfPerTileLen + lineIndex * perTileLen
    local x = halfPerTileLen + (i - 1) % self.m_slice * perTileLen
    self.m_positions[i] = {
      x = x - halfLen,
      y = y - halfLen
    }
  end
  GUIUtils.FillIcon(uiTexture, self.m_iconId, function()
    self.m_template:SetActive(false)
    cb()
  end)
end
def.method().GenenrateTile = function(self)
  self.m_tiles = {}
  local l = 1 / self.m_slice
  for i = 1, self.m_slice * self.m_slice do
    local lineIndex = math.floor((i - 1) / self.m_slice)
    local tile = Object.Instantiate(self.m_template, "GameObject")
    tile.parent = self.m_root
    tile.name = "Tile_" .. i
    tile.localScale = Vector3.Vector3.one
    local rect = Rect.Rect.new((i - 1) % self.m_slice * l, lineIndex * l, l, l)
    local uiTexture = tile:GetComponent("UITexture")
    uiTexture:set_uvRect(rect)
    self.m_tiles[i] = {index = i, obj = tile}
  end
  MathHelper.ShuffleTable(self.m_tiles)
  if self.m_root.isnil then
    return
  end
  for k, v in ipairs(self.m_tiles) do
    local pos = self.m_positions[k]
    v.obj.localPosition = Vector3.Vector3.new(pos.x, pos.y, 0)
    v.obj:SetActive(true)
  end
  self:CheckFinish()
end
def.method("string").onClick = function(self, id)
  if self.m_active and not self.m_lock and string.find(id, "Tile_") == 1 then
    local index = tonumber(string.sub(id, 6))
    if index then
      local pos = self:FindPosition(index)
      if pos > 0 then
        if 0 < self.m_select then
          if self.m_select == pos then
            self:UnselectPos()
          elseif self:IsAdjacent(self.m_select, pos) then
            self:SwitchPos(self.m_select, pos)
          else
            self:UnselectPos()
            self:SelectPos(pos)
          end
        else
          self:SelectPos(pos)
        end
      end
    end
  end
end
def.method("number").SelectPos = function(self, pos)
  local tile = self.m_tiles[pos]
  if tile then
    self.m_select = pos
    local obj = tile.obj
    if obj and not obj.isnil then
      obj:FindDirect("Img_Toggle"):SetActive(true)
    end
  end
end
def.method().UnselectPos = function(self)
  local tile = self.m_tiles[self.m_select]
  if tile then
    local obj = tile.obj
    if obj and not obj.isnil then
      obj:FindDirect("Img_Toggle"):SetActive(false)
    end
  end
  self.m_select = 0
end
def.method("number", "number", "=>", "boolean").IsAdjacent = function(self, a, b)
  local ax, ay = (a - 1) % self.m_slice + 1, math.floor((a - 1) / self.m_slice) + 1
  local bx, by = (b - 1) % self.m_slice + 1, math.floor((b - 1) / self.m_slice) + 1
  if ax == bx and math.abs(ay - by) == 1 then
    return true
  elseif ay == by and math.abs(ax - bx) == 1 then
    return true
  else
    return false
  end
end
def.method("number", "number").SwitchPos = function(self, a, b)
  self:UnselectPos()
  local aPos = self.m_positions[a]
  local bPos = self.m_positions[b]
  local aObj = self.m_tiles[a].obj
  local bObj = self.m_tiles[b].obj
  self.m_tiles[a], self.m_tiles[b] = self.m_tiles[b], self.m_tiles[a]
  TweenPosition.Begin(aObj, 0.2, Vector3.Vector3.new(bPos.x, bPos.y, 0))
  TweenPosition.Begin(bObj, 0.2, Vector3.Vector3.new(aPos.x, aPos.y, 0))
  self.m_lock = true
  GameUtil.AddGlobalTimer(0.2, true, function()
    self.m_lock = false
    self:CheckFinish()
  end)
end
def.method("number", "=>", "number").FindPosition = function(self, index)
  for k, v in ipairs(self.m_tiles) do
    if v.index == index then
      return k
    end
  end
  return 0
end
def.method("boolean").SetActive = function(self, active)
  self.m_active = active
  if self.m_select > 0 then
    self:UnselectPos()
  end
end
def.method().CleanWidget = function(self)
  local count = self.m_root:get_childCount()
  for i = 0, count - 1 do
    local child = obj:GetChild(i)
    if child.name ~= "Template" then
      Object.DestroyImmediate(child)
    end
  end
end
def.method().CheckFinish = function(self)
  warn("CheckFinish", pretty(self.m_tiles))
  for k, v in ipairs(self.m_tiles) do
    if k ~= v.index then
      return
    end
  end
  self:SetActive(false)
  if self.m_callback then
    self.m_callback()
  end
end
PintuWidget.Commit()
return PintuWidget

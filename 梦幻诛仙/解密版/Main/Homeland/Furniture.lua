local Lplus = require("Lplus")
local Furniture = Lplus.Class("Furniture")
local def = Furniture.define
local EC = require("Types.Vector3")
local ECGame = Lplus.ForwardDeclare("ECGame")
local FurniturePosEnum = require("consts.mzm.gsp.item.confbean.FurniturePosEnum")
local LogicMap = require("Main.Homeland.data.LogicMap")
local instance_id = 1
local OPPO_DIR = Quaternion.Euler(EC.Vector3.new(0, 180, 0))
local INVALID_COLOR = Color.Color(0.8745098039215686, 0, 0.0196078431372549, 1)
local VALID_COLOR = Color.Color(0.1843137254901961, 0.8901960784313725, 0.3333333333333333, 1)
local FunitureCellType = {
  MASK = 1,
  BLOCK = 2,
  CARPET = 4,
  WALL_DECORATE = 8
}
local CellTypeMapLogicMapValue = {
  [FunitureCellType.BLOCK] = bit.bor(LogicMap.TYPE_VALUE.BLOCK, LogicMap.TYPE_VALUE.GROUND_OBJECT),
  [FunitureCellType.MASK] = bit.bor(LogicMap.TYPE_VALUE.MASK, LogicMap.TYPE_VALUE.GROUND_OBJECT),
  [FunitureCellType.CARPET] = LogicMap.TYPE_VALUE.CARPET,
  [FunitureCellType.WALL_DECORATE] = LogicMap.TYPE_VALUE.WALL_DECORATE
}
def.const("table").STATUS = {EDIT = 1, FINISH = 2}
def.field("number").m_id = 0
def.field("table").m_data = nil
def.field("userdata").m_model = nil
def.field("number").m_status = ModelStatus.NONE
def.field("number").m_editStatus = 0
def.field("table").m_confirmDlg = nil
def.field("number").m_itemId = 0
def.field("userdata").m_uuid = nil
def.field("table").m_pos = nil
def.field("table").m_laydownpos = nil
def.field("number").m_dir = 1
def.field("number").m_laydowndir = 1
def.field("table").m_dirdata = nil
def.field("userdata").m_curMaterial = nil
def.field("userdata").m_normalMaterial = nil
def.field("number").m_layer = 0
def.field("boolean").m_dirty = false
def.field("boolean").m_transparent = false
def.final("string", "=>", Furniture).new = function(datapath)
  local obj = Furniture()
  if datapath and datapath ~= "" then
    obj.m_data = dofile(datapath)
  end
  obj.m_id = instance_id
  instance_id = instance_id + 1
  return obj
end
def.method("function").Load = function(self, onloaded)
  if self.m_data == nil then
    SafeCallback(onloaded, nil)
    return
  end
  if self.m_model then
    self.m_model:Destroy()
    self.m_model = nil
  end
  self.m_status = ModelStatus.LOADING
  local dirdata = self:GetCurDirData()
  AsyncLoadArray({
    dirdata.RendererPath
  }, function(objList)
    if self.m_status == ModelStatus.DESTROY then
      SafeCallback(onloaded, nil)
      return
    end
    self.m_model = Object.Instantiate(objList[1], "GameObject")
    self.m_curMaterial = self.m_model:GetComponent("MeshRenderer").material
    self.m_model:SetLayer(ClientDef_Layer.Default)
    self.m_model.parent = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND).rootNode
    GameUtil.AddECObjectComponent(self, self.m_model, false)
    self.m_status = ModelStatus.NORMAL
    self:UpdateDir()
    local campos = ECGame.Instance():Get2dCameraPos()
    if self.m_pos == nil then
      self.m_pos = {
        x = campos.x,
        y = world_height - campos.y
      }
    end
    self:UpdatePos()
    self:UpdateTransparent()
    SafeCallback(onloaded, self)
  end)
end
def.method().Update = function(self)
  if self.m_confirmDlg and self.m_model then
    local cam2dpos = ECGame.Instance():Get2dCameraPos()
    local diff = self.m_model.localPosition - cam2dpos
    diff.y = diff.y + 100
    self.m_confirmDlg:SetPos(diff)
    if self.m_dirty then
      local localPosition = self.m_model.localPosition
      local cell_x = math.floor(localPosition.x / LogicMap.Instance().cellWidth)
      local cell_y = math.floor((world_height - localPosition.y) / LogicMap.Instance().cellHeight)
      local dir_data = self:GetCurDirData()
      local start_x = cell_x + math.floor(dir_data.CellOffset[1] / 16)
      local start_y = cell_y - math.floor(dir_data.CellOffset[2] / 16)
      if LogicMap.Instance():CheckBlockData(start_x, start_y, dir_data.CellWidth, dir_data.CellHeight, dir_data.Cells) == false then
        self:SetInvalid(true)
      else
        self:SetInvalid(false)
      end
      self.m_dirty = false
    end
  end
end
def.method().Destroy = function(self)
  if self.m_model then
    self.m_model:Destroy()
  end
  if self.m_confirmDlg then
    self.m_confirmDlg:HideDlg()
  end
  self.m_data = nil
  self.m_status = ModelStatus.DESTROY
  self.m_dirdata = nil
  self.m_curMaterial = nil
  self.m_normalMaterial = nil
end
def.method().StartEdit = function(self)
  self.m_editStatus = Furniture.STATUS.EDIT
  if self.m_confirmDlg == nil then
    self.m_confirmDlg = require("Main.Homeland.ui.DlgConfirm").new(self.m_id)
  end
  self.m_confirmDlg:ShowDlg()
  GameUtil.AsyncLoad(RESPATH.SHADER_FURNITURE_BOUND_COLOR, function(shader)
    if shader == nil then
      return
    end
    local newMat = Material.Material(shader)
    if self.m_model then
      if self.m_normalMaterial == nil then
        self.m_normalMaterial = self.m_model:GetComponent("MeshRenderer").material
      end
      local mainTex = self.m_normalMaterial:GetTexture("_MainTex")
      local maskTex = self.m_normalMaterial:GetTexture("_MaskTex")
      newMat:SetTexture("_MainTex", mainTex)
      newMat:SetTexture("_MaskTex", maskTex)
      self.m_model:GetComponent("MeshRenderer").material = newMat
      self.m_curMaterial = newMat
      self:UpdatePos()
    end
  end)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.START_EDIT, {
    self.m_id
  })
end
def.method().EndEdit = function(self)
  self.m_editStatus = Furniture.STATUS.FINISH
  if self.m_confirmDlg then
    self.m_confirmDlg:HideDlg()
  end
  if self.m_model and self.m_normalMaterial then
    self.m_model:GetComponent("MeshRenderer").material = self.m_normalMaterial
    self.m_curMaterial = self.m_normalMaterial
    self:UpdatePos()
  end
  self.m_laydownpos = self.m_pos
  self.m_laydowndir = self.m_dir
end
def.method("=>", "boolean").IsEditable = function(self)
  return self.m_editStatus == Furniture.STATUS.EDIT
end
def.virtual().OnClick = function(self)
end
def.virtual().OnLongTouch = function(self)
  self:StartEdit()
end
def.virtual().OnTouchBegin = function(self)
end
def.virtual().OnTouchEnd = function(self)
end
def.method().Opposite = function(self)
  self:Turn()
end
def.method().Turn = function(self)
  local maxDir = #self.m_data.Directions
  local lastDir = self.m_dir
  if maxDir < lastDir + 1 then
    self.m_dir = 1
  else
    self.m_dir = lastDir + 1
  end
  local lastDirection = self.m_data.Directions[lastDir]
  local direction = self.m_data.Directions[self.m_dir]
  if lastDirection.SrcIndex ~= direction.SrcIndex then
    if self.m_model and self.m_pos == nil then
      self.m_pos = {}
      self.m_pos.x = self.m_model.localPosition.x
      self.m_pos.y = world_height - self.m_model.localPosition.y
    end
    self:Load(nil)
  else
    self:UpdateDir()
  end
end
def.method("number").SetDir = function(self, dir)
  self:_SetDir(dir)
  self:UpdateDir()
end
def.method("number")._SetDir = function(self, dir)
  local dir = math.min(math.max(1, dir), #self.m_data.Directions)
  self.m_dir = dir
end
def.method("=>", "number").GetDir = function(self, dir)
  return self.m_dir
end
def.method("=>", "number").GetLayDownDir = function(self, dir)
  return self.m_laydowndir
end
def.method().UpdateDir = function(self)
  if self.m_model == nil then
    return
  end
  local direction = self.m_data.Directions[self.m_dir]
  local localRotation = Quaternion.identity
  if direction.Mirror then
    localRotation = OPPO_DIR
  end
  self.m_model.transform.localRotation = localRotation
  self.m_dirty = true
end
def.method("=>", "table").GetCurDirData = function(self)
  return self:GetDirData(self.m_dir)
end
def.method("number", "=>", "table").GetDirData = function(self, dir)
  if self.m_dirdata and self.m_dirdata.dir == dir then
    return self.m_dirdata
  end
  local direction = self.m_data.Directions[dir]
  local sourceDirection = self.m_data.SourceDirections[direction.SrcIndex]
  local dirdata = sourceDirection
  dirdata.CellWidth = dirdata.CellsSize[1]
  dirdata.CellHeight = dirdata.CellsSize[2]
  if dirdata.Mirror == nil then
    local Cells = dirdata.Cells
    for i = 1, dirdata.CellWidth * dirdata.CellHeight do
      if bit.band(Cells[i], FunitureCellType.BLOCK) == FunitureCellType.BLOCK and (self.m_layer == FurniturePosEnum.CARPET or self.m_layer == FurniturePosEnum.WALL_DECORATE) then
        Cells[i] = bit.bxor(Cells[i], FunitureCellType.BLOCK)
      end
      local logicData = 0
      for k, v in pairs(CellTypeMapLogicMapValue) do
        if bit.band(Cells[i], k) ~= 0 then
          logicData = bit.bor(logicData, v)
        end
      end
      Cells[i] = logicData
    end
  end
  dirdata.Mirror = dirdata.Mirror or false
  if direction.Mirror ~= dirdata.Mirror then
    dirdata.CellOffset[1] = -(dirdata.CellOffset[1] + self.m_data.CellWidth * dirdata.CellWidth) + self.m_data.CellWidth
    dirdata.Cells = self:Opposite2DArray(dirdata.Cells, dirdata.CellWidth, dirdata.CellHeight)
    dirdata.Mirror = direction.Mirror
  end
  self.m_dirdata = dirdata
  self.m_dirdata.dir = dir
  return dirdata
end
def.method("table", "number", "number", "=>", "table").Opposite2DArray = function(self, array, width, height)
  local temp
  for i = 0, height - 1 do
    for j = 1, math.floor(width / 2) do
      temp = array[i * width + j]
      array[i * width + j] = array[i * width + width - j + 1]
      array[i * width + width - j + 1] = temp
    end
  end
  return array
end
def.method("number", "number").SetPos = function(self, x, y)
  if self.m_status == ModelStatus.DESTROY then
    return
  end
  self.m_pos = {x = x, y = y}
  if self.m_status ~= ModelStatus.NORMAL then
    return
  end
  self:UpdatePos()
end
def.method().UpdatePos = function(self)
  if self.m_pos == nil then
    return
  end
  local m = self.m_model
  local x = self.m_pos.x
  local y = math.max(0, world_height - self.m_pos.y)
  if self.m_curMaterial and not self.m_curMaterial.isnil then
    local renderQueue = self:CalcRenderQueue(x, y, self.m_layer)
    self.m_curMaterial.renderQueue = renderQueue
  end
  m.localPosition = EC.Vector3.new(x, y, 0)
  self.m_dirty = true
end
def.method("=>", "table").GetLayDownPos = function(self)
  return self.m_laydownpos
end
def.method("=>", "userdata").GetUUID = function(self)
  return self.m_uuid
end
def.method("=>", "number").GetCfgID = function(self)
  return self.m_itemId
end
def.method("number", "number", "number", "=>", "number").CalcRenderQueue = function(self, x, y, layer)
  local dir_data = self:GetCurDirData()
  local renderQueue = 3000
  if self.m_layer == FurniturePosEnum.GROUND_FURNITURE then
    local startY = 0
    local endY = 0
    local width = dir_data.CellWidth
    local height = dir_data.CellHeight
    for h = 1, height do
      for w = 1, width do
        local idx = (h - 1) * width + w
        if bit.band(dir_data.Cells[idx], LogicMap.TYPE_VALUE.BLOCK) == LogicMap.TYPE_VALUE.BLOCK then
          if startY == 0 then
            startY = h
          end
          endY = h
        end
      end
    end
    if startY == 0 then
      startY = height
      endY = startY
    end
    local col = bit.rshift(startY + endY, 1)
    local z = (y + dir_data.CellOffset[2] - (col - 1) * self.m_data.CellHeight) / world_height
    renderQueue = 5000 - math.ceil(2000 * z)
  elseif self.m_layer == FurniturePosEnum.CARPET then
    renderQueue = renderQueue + 5
  elseif self.m_layer == FurniturePosEnum.FLOOR_TILE then
    renderQueue = renderQueue + 4
  elseif self.m_layer == FurniturePosEnum.WALL_DECORATE then
    renderQueue = renderQueue + 3
  elseif self.m_layer == FurniturePosEnum.WALL then
    renderQueue = renderQueue + 2
  end
  return renderQueue
end
def.method("=>", "number").GetRenderQueue = function(self)
  if self.m_curMaterial and not self.m_curMaterial.isnil then
    return self.m_curMaterial.renderQueue
  end
  return 0
end
def.method("boolean").SetInvalid = function(self, isInvalid)
  if self.m_curMaterial == nil or self.m_curMaterial.isnil then
    return
  end
  if self.m_curMaterial ~= self.m_normalMaterial then
    local color = isInvalid and INVALID_COLOR or VALID_COLOR
    self.m_curMaterial.color = color
  end
end
def.method("number").SetLayer = function(self, layer)
  self.m_layer = layer
end
def.method("boolean").SetTransparent = function(self, transparent)
  self.m_transparent = transparent
  if self.m_curMaterial == nil or self.m_curMaterial.isnil then
    return
  end
  self:UpdateTransparent()
end
def.method().UpdateTransparent = function(self)
  if self.m_transparent then
    self.m_curMaterial:SetFloat("_Transparent", 0.55)
  else
    self.m_curMaterial:SetFloat("_Transparent", 1)
  end
end
return Furniture.Commit()

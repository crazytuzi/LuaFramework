local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local ChessCell = Lplus.Extend(ECModel, "ChessCell")
local EquipUtils = require("Main.Equip.EquipUtils")
local def = ChessCell.define
local t_vec = EC.Vector3.new()
ChessCell.Scale = 20
def.field("number").row = 0
def.field("number").col = 0
def.final("number", "number", "=>", ChessCell).new = function(row, col)
  local obj = ChessCell()
  obj.row = row
  obj.col = col
  obj.m_IsTouchable = true
  obj.clickPriority = 0
  obj:Init(700301152)
  obj.defaultLayer = ClientDef_Layer.Player
  obj.m_bUncache = true
  return obj
end
def.override("number", "=>", "boolean").Init = function(self, id)
  self.mModelId = id
  if id <= 0 then
    return false
  end
  local node2d_name = "node2d_ChessCell_" .. tostring(id)
  if self.m_node2d then
    self.m_node2d.name = node2d_name
  else
    self.m_node2d = GameObject.GameObject(node2d_name)
  end
  return true
end
local t_dir_vec = EC.Vector3.new(0, 0, 0)
def.override().OnLoadGameObject = function(self)
  local model = self.m_model
  if model == nil then
    warn("[ChessPiece]model is nil for res path: ", self.m_resName)
    return
  end
  model:SetLayer(self.defaultLayer)
  model.localPosition = Map2DPosTo3D(self.m_node2d.localPosition.x, self.m_node2d.localPosition.y)
  t_dir_vec.y = self.m_ang
  model.localRotation = Quaternion.Euler(t_dir_vec)
  if self.m_color then
    self:SetModelColor(self.m_color)
  end
  self:SetScale(ChessCell.Scale)
  self:SetTouchable(true)
  self:DoOnLoadCallback()
end
def.override().Destroy = function(self)
  if self:IsDestroyed() then
    return
  end
  ECModel.Destroy(self)
end
def.override().OnClick = function(self)
  ECModel.OnClick(self)
  Event.DispatchEvent(ModuleId.CHESS, gmodule.notifyId.CHESS.CLICK_CELL, {
    self.row,
    self.col
  })
end
local t_pos = EC.Vector3.new(0, 0, 0)
def.override("number", "number").SetPos = function(self, row, col)
  self.row = row
  self.col = col
  local x, y = require("Main.Chess.ChessMgr").Instance():GetCellPos(row, col)
  local model = self.m_model
  if model then
    model.localPosition = Map2DPosTo3D(x, y)
  end
  self.m_node2d.localPosition = t_pos:Assign(x, y, 0)
end
ChessCell.Commit()
return ChessCell

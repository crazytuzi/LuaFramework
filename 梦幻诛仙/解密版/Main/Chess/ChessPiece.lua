local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local ChessPiece = Lplus.Extend(ECModel, "ChessPiece")
local ChessUtils = require("Main.Chess.ChessUtils")
local def = ChessPiece.define
local t_vec = EC.Vector3.new()
def.field("number").index = 0
def.field("number").owner = 0
def.field("number").row = 0
def.field("number").col = 0
def.field("boolean").isTurnedOver = false
def.field("number").scale = 1
def.final("number", "number", "string", "userdata", "=>", ChessPiece).new = function(index, modelId, name, nameColor)
  local obj = ChessPiece()
  obj.m_IsTouchable = true
  obj.index = index
  obj:Init(modelId)
  obj.defaultLayer = ClientDef_Layer.NPC
  obj:SetName(name, nameColor)
  obj.m_bUncache = true
  return obj
end
def.override("number", "=>", "boolean").Init = function(self, id)
  self.mModelId = id
  if id <= 0 then
    return false
  end
  local node2d_name = "node2d_ChessPiece_" .. tostring(id)
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
  model.localScale = EC.Vector3.one * self.scale
  self:Play(ActionName.Stand)
  if self.m_color then
    self:SetModelColor(self.m_color)
  end
  self:SetTouchable(true)
  if self.m_uiNameHandle == nil then
    local ECPate = require("GUI.ECPate")
    local pate = ECPate.new()
    pate:CreateNameBoard(self)
  else
    self:ResetNamePate()
  end
  self:DoOnLoadCallback()
end
def.override().Destroy = function(self)
  if self:IsDestroyed() then
    return
  end
  self.index = 0
  self.owner = 0
  self.row = 0
  self.col = 0
  self.isTurnedOver = false
  ECModel.Destroy(self)
end
def.method("number", "number", "function").MoveTo = function(self, x, y, callback)
  if self.m_model == nil then
    return
  end
  local move = self.m_model:GetComponent("CommonMove")
  if move == nil then
    move = self.m_model:AddComponent("CommonMove")
    move:Set2dTo3dCo(1 / math.sin(cam_3d_rad))
  end
  if callback ~= nil then
    move:RegMoveEndFunc(callback)
  end
  move:MoveTo(self.m_node2d, x, y, 0.5, true, 0)
end
def.override().OnClick = function(self)
  ECModel.OnClick(self)
  Event.DispatchEvent(ModuleId.CHESS, gmodule.notifyId.CHESS.CLICK_PIECE, {
    self.row,
    self.col
  })
end
def.method("table").FaceToTarget = function(self, target)
  if target == nil or target.m_model == nil or self.m_model == nil then
    return
  end
  local tar_dir = target.m_model.forward
  self.m_model.forward = -tar_dir
end
def.method("table").LookAtTarget = function(self, target)
  if target == nil or target.m_model == nil or self.m_model == nil then
    return
  end
  local tpos = target:GetPos()
  self:LookAtPos(tpos.x, tpos.y)
end
def.method("number", "number").LookAtPos = function(self, x, y)
  local m2dPos = self:GetPos()
  if m2dPos == nil then
    return
  end
  local m3dPos = EC.Vector3.new()
  local t3dPos = EC.Vector3.new()
  Set2DPosTo3D(m2dPos.x, m2dPos.y, m3dPos)
  Set2DPosTo3D(x, y, t3dPos)
  local dir = t3dPos - m3dPos
  dir:Normalize()
  self:SetForward(dir)
end
def.method("number").SetNewModel = function(self, modelId)
  if self.mModelId <= 0 then
    return
  end
  self.mModelId = modelId
  if self.m_model then
    self.m_model:Destroy()
    self.m_model = nil
  end
end
def.method("number").TurnOver = function(self, index)
  self.index = index
  self.isTurnedOver = true
  local cfg = ChessUtils.GetChessPieceCfg(self.index)
  if cfg == nil then
    return
  end
  self:SetNewModel(cfg.modelId)
  self:SetName(cfg.name, nil)
  self.scale = cfg.modelScale
  self.m_ang = 120
  GameUtil.AddGlobalTimer(0.5, true, function()
    if self.index == 0 then
      return
    end
    self:LoadCurrentModel2()
  end)
end
def.method().ResetNamePate = function(self)
  local target = self.m_uiNameHandle
  if target == nil or target.isnil then
    return
  end
  local follow = target:GetComponent("HUDFollowTarget")
  if follow then
    follow.target = self.m_model.transform
  end
end
ChessPiece.Commit()
return ChessPiece

local Lplus = require("Lplus")
local UIModelWrap = Lplus.Class("UIModelWrap")
local def = UIModelWrap.define
local ECModel = require("Model.ECModel")
def.field("table")._cachedProtocols = nil
def.field(ECModel)._model = nil
def.field(ECModel)._lastModel = nil
def.field("string")._resourcePath = ""
def.field("userdata")._theUIModle = nil
def.field("boolean")._bUncache = true
def.field("number")._defaultDir = 180
def.field("number")._defaultScale = 1
def.field("string")._defaultAct = ActionName.Stand
def.field("string")._defaultIdleAct = ActionName.Stand
def.field("boolean")._bMono = false
def.field("boolean")._bAutoAdjust = false
def.field("boolean")._bUpdating = false
def.static("userdata", "=>", UIModelWrap).new = function(theUIModle)
  local ret = UIModelWrap()
  ret._theUIModle = theUIModle
  return ret
end
def.method().Destroy = function(self)
  self:DestroyInfoLastModel()
  self:DestroyInfoModel()
end
def.method().DestroyInfoModel = function(self)
  if self._model ~= nil then
    self._model:Destroy()
    self._model = nil
  end
  self._resourcePath = ""
  Timer:RemoveIrregularTimeListener(self.OnUpdate)
  self._bUpdating = false
end
def.method().DestroyInfoLastModel = function(self)
  if self._lastModel ~= nil then
    self._lastModel:Destroy()
    self._lastModel = nil
  end
end
def.method("string").Load = function(self, resourcePath)
  if self._resourcePath == resourcePath then
    return
  end
  self:DestroyInfoModel()
  self._resourcePath = resourcePath
  if self._model == nil then
    self._model = ECModel.new(1)
    self._model.m_bUncache = self._bUncache
  end
  local function fnCallBack(ret)
    if self._model == nil then
      print("** --------------- _model error!!!!!!!!!!!!!!!!!!!!!")
      return
    end
    if self._model.m_model == nil then
      print("** --------------- _model.m_model error!!!!!!!!!!!!!!!!!!!!!")
      return
    end
    if self._lastModel ~= nil and self._lastModel.m_model ~= self._model.m_model then
      self:DestroyInfoLastModel()
    end
    self._lastModel = self._model
    local m = self._model.m_model
    m.parent = nil
    m:SetLayer(ClientDef_Layer.UI_Model1)
    self._model:SetDir(self._defaultDir)
    local function PlayAnimCallback(model)
      self:PlayDefaultAct()
    end
    if self._defaultAct ~= ActionName.Stand then
      local res = self._model:PlayAnim(self._defaultAct, PlayAnimCallback)
      if res == true and self._bUpdating == false then
        Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
        self._bUpdating = true
      end
    else
      self:PlayDefaultAct()
    end
    self._model:SetScale(self._defaultScale)
    self._theUIModle.modelGameObject = m
    self._model:CloseAlphaBase()
    if self._bMono == true then
      self._model:TurnToStone()
    else
      self._model:RecoverFromStone()
    end
    self:_DoAdjustScale()
  end
  if self._model.m_model == nil then
    self._model:Load(resourcePath, fnCallBack)
  else
    if self._model ~= nil then
      self._model:Destroy()
      self._model = ECModel.new(1)
    end
    self._model:Load(resourcePath, fnCallBack)
    self._resourcePath = resourcePath
  end
end
def.method().PlayDefaultAct = function(self)
  if self._model ~= nil then
    Timer:RemoveIrregularTimeListener(self.OnUpdate)
    self._bUpdating = false
    self._model:Play(self._defaultAct)
  end
end
def.method("boolean").SetColored = function(self, colored)
  local bMono = not colored
  if bMono == self._bMono then
    return
  end
  self._bMono = bMono
  if self._model ~= nil then
    if self._bMono == true then
      self._model:TurnToStone()
    else
      self._model:RecoverFromStone()
    end
  end
end
def.method("boolean").SetAutoAdjustScale = function(self, auto)
  if auto == self._bAutoAdjust then
    return
  end
  self._bAutoAdjust = auto
  if self._model ~= nil and self._model.m_model ~= nil then
    self:_DoAdjustScale()
  end
end
def.method()._DoAdjustScale = function(self)
  if self._bAutoAdjust == true then
    local boxCollider = self._model.m_model:GetComponent("BoxCollider")
    local mountOffset = 0
    local standardHeight = 1.58
    if boxCollider ~= nil then
      local size = boxCollider:get_size()
      local s = math.max(size.x, size.y, size.z)
      if standardHeight < s then
        local scale = standardHeight / s * 0.9
        self._model:SetScale(scale)
      end
    end
  end
end
def.method("number").OnUpdate = function(self, dt)
  self._model:Update(dt)
end
UIModelWrap.Commit()
return UIModelWrap

local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local ECUIModel = require("Model.ECUIModel")
local AircraftData = require("Main.Aircraft.data.AircraftData")
local FlyModule = require("Main.Fly.FlyModule")
local AircraftUIModel = Lplus.Extend(ECUIModel, "AircraftUIModel")
local def = AircraftUIModel.define
def.field("table")._aircraftCfg = nil
def.field("number")._colorId = 0
def.field("userdata")._uiModel = nil
def.field("boolean")._canExceedBound = false
def.field(ECUIModel)._roleModel = nil
def.field("number")._timerId = 0
def.final("number", "number", "userdata", "=>", AircraftUIModel).new = function(aircraftId, colorId, uiModel)
  local obj = AircraftUIModel()
  obj:Init(aircraftId)
  obj._aircraftCfg = AircraftData.Instance():GetAircraftCfg(aircraftId)
  obj._colorId = colorId
  obj._uiModel = uiModel
  return obj
end
def.override("number", "=>", "boolean").Init = function(self, aircraftId)
  ECUIModel.Init(self, aircraftId)
  return true
end
local doCallback = function(cb, ret)
  if cb then
    cb(ret)
  end
end
def.method("function").LoadWithCB = function(self, cb)
  local modelId = self._aircraftCfg.modelId
  self.mModelId = modelId
  self:ClearTimer()
  local modelPath = _G.GetModelPath(modelId)
  self:LoadUIModel(modelPath, function(ret)
    if ret == nil then
      doCallback(cb, nil)
      return
    end
    if _G.IsNil(self._uiModel) then
      warn("[ERROR][AircraftUIModel:LoadWithCB] self._uiModel nil!")
      return
    end
    if self._aircraftCfg.uiShowDelay and self._aircraftCfg.uiShowDelay > 0 then
      do
        local oldlayer = self.m_model.layer
        self.m_model:SetLayer(_G.ClientDef_Layer.Invisible)
        self._uiModel.modelGameObject = self.m_model
        self._timerId = GameUtil.AddGlobalLateTimer(self._aircraftCfg.uiShowDelay / 1000, true, function()
          if not _G.IsNil(self.m_model) then
            self.m_model:SetLayer(oldlayer)
          end
          self._timerId = 0
        end)
      end
    else
      self._uiModel.modelGameObject = self.m_model
    end
    self:SetDir(self._aircraftCfg.slantValue)
    if self._uiModel.mCanOverflow ~= nil then
      self._uiModel.mCanOverflow = true
      local camera = self._uiModel:get_modelCamera()
      if not _G.IsNil(camera) then
        camera:set_orthographic(true)
      end
    end
    self:Play(FlyModule.FlyIdleAnimation)
    self:_DoDye(self._colorId)
    doCallback(cb, ret)
  end)
end
def.method(ECUIModel).AttachRole = function(self, roleModel)
  if _G.IsNil(self.m_model) then
    warn("[ERROR][AircraftUIModel:AttachRole] attach fail, self.m_model nil!")
    return
  end
  if _G.IsNil(roleModel) then
    warn("[ERROR][AircraftUIModel:AttachRole] attach fail, roleModel nil!")
    return
  end
  self:DetachRole()
  local animationName
  local FeijianType = require("consts.mzm.gsp.feijian.confbean.FeiJianType")
  if self._aircraftCfg.feijianType == FeijianType.FOOT then
    animationName = ActionName.FightStand
  elseif self._aircraftCfg.feijianType == FeijianType.RIDE then
    animationName = ActionName.SitStand
  elseif self._aircraftCfg.feijianType == FeijianType.BODY_SIT then
    animationName = ActionName.SitStand
  elseif self._aircraftCfg.feijianType == FeijianType.BODY_STAND then
    animationName = ActionName.FightStand
  else
    animationName = ActionName.FightStand
  end
  if animationName then
    self._roleModel = roleModel
    self:AttachModel(FlyModule.FlyTag, self._roleModel, "HH_Point")
    self._roleModel:Play(animationName)
    self._roleModel:SetVisible(true)
    if not _G.IsNil(self._roleModel.mECFabaoComponent) then
      self._roleModel.mECFabaoComponent:SetVisible(true)
    end
  end
end
def.method().DetachRole = function(self)
  if self._roleModel then
    self._roleModel:SetVisible(false)
    if not _G.IsNil(self._roleModel.mECFabaoComponent) then
      self._roleModel.mECFabaoComponent:SetVisible(false)
    end
    self:Detach(FlyModule.FlyTag)
    self._roleModel = nil
  end
end
def.method("number").Dye = function(self, colorId)
  if colorId == self._colorId then
    return
  end
  self._colorId = colorId
  if not self:IsInLoading() then
    self:_DoDye(self._colorId)
  end
end
def.method("number")._DoDye = function(self, colorId)
  if colorId > 0 then
    local colorcfg = GetModelColorCfg(colorId)
    self:SetColoration(colorcfg)
  else
    self:SetColoration(nil)
  end
end
def.override().Destroy = function(self)
  if self:IsDestroyed() then
    return
  end
  self:ClearTimer()
  ECUIModel.Destroy(self)
end
def.method().ClearTimer = function(self)
  if self._timerId > 0 then
    GameUtil.RemoveGlobalTimer(self._timerId)
    self._timerId = 0
  end
end
def.method("boolean").SetCanExceedBound = function(self, canExceed)
  self._canExceedBound = canExceed
  self:UpdateUIModelMode()
end
def.method().UpdateUIModelMode = function(self)
  if _G.IsNil(self._uiModel) then
    return
  end
  self._uiModel.mCanOverflow = self._canExceedBound
  if self._canExceedBound then
    local camera = self._uiModel:get_modelCamera()
    if camera then
      camera:set_orthographic(true)
    else
      warn("[ERROR][AircraftUIModel:UpdateUIModelMode] modelcamera is nil")
    end
  end
end
return AircraftUIModel.Commit()

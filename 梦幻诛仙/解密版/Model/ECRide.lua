local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local ECRoleModel = require("Model.ECRoleModel")
local ECFxMan = require("Fx.ECFxMan")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountActionEnum = require("consts.mzm.gsp.mounts.confbean.MountActionEnum")
local ECRide = Lplus.Extend(ECRoleModel, "ECRide")
local def = ECRide.define
def.field("table").owner = nil
def.field("number").level = 0
def.field("number").dyeId = 0
def.field("number").rideId = 0
def.field("table").effects = nil
def.field("table").passenger = nil
def.field("table").actionList = nil
def.final("table", "number", "number", "number", "=>", ECRide).new = function(owner, rideId, level, dyeId)
  local obj = ECRide()
  obj.owner = owner
  obj.defaultParentNode = owner.defaultParentNode
  obj.defaultLayer = owner.defaultLayer
  obj.rideId = rideId
  obj.level = level
  obj.dyeId = dyeId
  obj.effects = {}
  obj:Init(0)
  return obj
end
def.override().OnClick = function(self)
  if self.owner then
    self.owner:OnClick()
  end
end
def.override("=>", "string").GetName = function(self)
  if self.owner then
    return self.owner:GetName()
  end
  return self.m_Name
end
def.virtual("function").LoadHead = function(self, cb)
  self:LoadRide(cb)
end
def.virtual("function").LoadRide = function(self, cb)
  local function OnRideLoad(ret)
    if ret then
      self:SetLevel(self.level)
      self:SetDye(self.dyeId)
      if self.owner then
        self:SetTouchable(self.owner:IsTouchable())
      end
      if self.passenger then
        for k, v in pairs(self.passenger) do
          self:RealAttachRole(v, k)
        end
      end
    end
    cb()
  end
  local mountCfg = MountsUtils.GetMountsDetailInfo(self.rideId, self.level, self.dyeId)
  if mountCfg == nil then
    cb()
    return
  end
  self.actionList = mountCfg.actionList
  local modelPath = GetModelPath(mountCfg.mountsModelId)
  self:Load2(modelPath, OnRideLoad, true)
end
def.virtual("table").AttachDriver = function(self, driver)
  self:AttachModelEx("Ride", driver, "Bip01 ZuoQi", EC.Vector3.zero, EC.Vector3.new(90, -90, 0))
end
def.virtual("number").SetLevel = function(self, level)
  self.level = level
  if self.m_model and not self.m_model.isnil then
    local mountCfg = MountsUtils.GetMountsDetailInfo(self.rideId, self.level, self.dyeId)
    if mountCfg then
      for k, v in pairs(mountCfg.ornament) do
        local ornament = self.m_model:FindDirect(k)
        if ornament then
          ornament:SetActive(v)
        end
      end
      self:ClearEffect()
      for k, v in pairs(mountCfg.boneEffects) do
        self:AddBoneEffect(v)
      end
    end
  end
end
def.virtual("number").AddBoneEffect = function(self, boneEffectId)
  local boneEffect = GetBoneAddEffect(boneEffectId)
  if boneEffect ~= nil then
    local FXModule = require("Main.FX.FXModule")
    for k, v in ipairs(boneEffect.boneaddeffect) do
      do
        local effres = GetEffectRes(v.effect)
        local bone = v.bone
        local position = EC.Vector3.zero
        local rotation = Quaternion.identity
        local duration = -1
        local parent = self.m_model:FindChild(bone)
        local highres = false
        local effect = ECFxMan.Instance():PlayAsChild(effres.path, parent, position, rotation, duration, highres, self.defaultLayer)
        if effect then
          effect:SetLayer(self.defaultLayer)
          effect:GetComponent("FxOne"):set_Stable(true)
          FXModule.Instance():AddManagedFx(effect)
          table.insert(self.effects, effect)
          effect:SetActive(false)
          GameUtil.AddGlobalTimer(0.1, true, function()
            if effect.isnil then
              return
            end
            effect:SetActive(true)
          end)
        end
      end
    end
  end
end
def.virtual().ClearEffect = function(self)
  for k, v in pairs(self.effects) do
    ECFxMan.Instance():Stop(v)
  end
  self.effects = {}
end
def.virtual("number").SetDye = function(self, dyeId)
  self.dyeId = dyeId
  if self.m_model and not self.m_model.isnil then
    local mountCfg = MountsUtils.GetMountsDetailInfo(self.rideId, self.level, self.dyeId)
    if mountCfg then
      local mountColor = GetModelColorCfg(mountCfg.colorId)
      if mountColor then
        self:SetColoration(mountColor)
      end
    end
  end
end
def.override().Destroy = function(self)
  if self.passenger then
    for k, v in pairs(self.passenger) do
      self:RealDetachRole(v, k)
    end
  end
  self:ClearEffect()
  ECRoleModel.Destroy(self)
end
def.virtual().RemoveAllPassenger = function(self)
  if self.passenger then
    local ks = table.keys(self.passenger)
    for k, v in ipairs(ks) do
      self:RemovePassengerByIndex(v)
    end
  end
end
def.virtual("number").RemovePassengerByIndex = function(self, index)
  if self.passenger then
    local role = self.passenger[index]
    if role then
      self.passenger[index] = nil
      role:RemoveState(RoleState.PASSENGER)
      self:RealDetachRole(role, index)
    end
  end
end
def.virtual("table", "number").RealDetachRole = function(self, role, index)
  if self.m_status == ModelStatus.NORMAL then
    local boneName = string.format("Bip01 ZuoQi%02d", index)
    self:Detach(boneName)
    if role.defaultParentNode then
      role:SetParentNode(role.defaultParentNode)
    end
    role.nameOffset = default_name_offset
    if role.m_uiNameHandle then
      role.m_uiNameHandle:GetComponent("HUDFollowTarget").offset = EC.Vector3.new(0, role.nameOffset, 0)
    end
    if role.mShadowObj and not role.mShadowObj.isnil then
      role.mShadowObj:SetActive(true)
    end
    if role.m_node2d and not role.m_node2d.isnil then
      local pos = EC.Vector3.new()
      local curX = role.m_node2d.localPosition.x
      local curY = role.m_node2d.localPosition.y
      Set2DPosTo3D(curX, world_height - curY, pos)
      local mountRotation = self.m_model and not self.m_model.isnil and self.m_model.localRotation
      if role.m_model and not role.m_model.isnil then
        role.m_model.localScale = Model_Default_Scale
        if mountRotation then
          role.m_model.localRotation = mountRotation
        end
        role.m_model.localPosition = pos
      end
      role:SetStance()
      role:ReturnMount()
    end
    role:SetMagicMarkVisible(true)
  end
end
def.virtual("table", "number").AddPassenger = function(self, role, index)
  if self.passenger and self.passenger[index] then
    return
  end
  if self.passenger == nil then
    self.passenger = {}
  end
  self.passenger[index] = role
  role:SetState(RoleState.PASSENGER)
  if self.m_status == ModelStatus.DESTROY or self.m_status == ModelStatus.NONE then
  elseif self.m_status == ModelStatus.NORMAL then
    self:RealAttachRole(role, index)
  elseif self.m_status == ModelStatus.LOADING then
    self:AddOnLoadCallbackQueue("AddPassenger", function()
      self:RealAttachRole(role, index)
    end)
  end
end
def.virtual("table", "number").RealAttachRole = function(self, role, index)
  if role.m_status == ModelStatus.DESTROY or role.m_status == ModelStatus.NONE then
  elseif role.m_status == ModelStatus.NORMAL then
    if self.m_status == ModelStatus.DESTROY or self.m_status == ModelStatus.NONE then
    elseif self.m_status == ModelStatus.NORMAL then
      role:SetToGround()
      if not role:IsInState(RoleState.FLY) and role:IsOnMount() then
        role:LeaveMount()
      end
      local boneName = string.format("Bip01 ZuoQi%02d", index)
      self:AttachModelEx(boneName, role, boneName, EC.Vector3.zero, EC.Vector3.new(90, -90, 0))
      local commonMove = role:GetOrAddMovePathComp()
      commonMove:Stop()
      commonMove:set_IsAnimate(false)
      commonMove:set_MoveAnimationName(ActionName.Run)
      commonMove:set_StandAnimationName(ActionName.Stand)
      commonMove:set_enabled(false)
      if self.owner then
        if self.owner:IsInState(RoleState.RUN) then
          role:PlayWithDefault(self:GetRunActionName(index), ActionName.Stand)
        else
          role:PlayWithDefault(self:GetStandActionName(index), ActionName.Stand)
        end
      else
        role:PlayWithDefault(self:GetStandActionName(index), ActionName.Stand)
      end
      local modelOffset = role.m_model and role.m_model.position.y or 1
      role.nameOffset = default_name_offset - modelOffset
      if role.m_uiNameHandle then
        role.m_uiNameHandle:GetComponent("HUDFollowTarget").offset = EC.Vector3.new(0, role.nameOffset, 0)
      end
      if role.mShadowObj and not role.mShadowObj.isnil then
        role.mShadowObj:SetActive(false)
      end
      role:SetMagicMarkVisible(false)
    elseif self.m_status == ModelStatus.LOADING then
      self:AddOnLoadCallbackQueue("AddPassenger", function()
        self:RealAttachRole(role, index)
      end)
    end
  elseif role.m_status == ModelStatus.LOADING then
    role:AddOnLoadCallback("RealAttachRole", function()
      self:RealAttachRole(role, index)
    end)
  end
end
def.virtual("=>", "number").GetPassengerCount = function(self)
  if self.passenger then
    return table.nums(self.passenger)
  else
    return 0
  end
end
def.virtual("=>", "boolean").HasPassenger = function(self)
  return self.passenger ~= nil and next(self.passenger) ~= nil
end
def.virtual("=>", "table").GetPassengers = function(self)
  if self.passenger then
    return self.passenger
  else
    return {}
  end
end
def.method("number", "=>", "string").GetStandActionName = function(self, index)
  if self.actionList then
    local actionEnum = self.actionList[index]
    if actionEnum then
      if actionEnum == MountActionEnum.STAND then
        return ActionName.Stand
      elseif actionEnum == MountActionEnum.MOUNT then
        return ActionName.Ride_Stand
      else
        return ActionName.Ride_Stand
      end
    else
      return ActionName.Ride_Stand
    end
  else
    return ActionName.Ride_Stand
  end
end
def.method("number", "=>", "string").GetRunActionName = function(self, index)
  if self.actionList then
    local actionEnum = self.actionList[index]
    if actionEnum then
      if actionEnum == MountActionEnum.STAND then
        return ActionName.Stand
      elseif actionEnum == MountActionEnum.MOUNT then
        return ActionName.Ride_Run
      else
        return ActionName.Ride_Run
      end
    else
      return ActionName.Ride_Run
    end
  else
    return ActionName.Ride_Run
  end
end
def.virtual().StartRun = function(self)
  if self.passenger then
    for k, v in pairs(self.passenger) do
      v:PlayWithDefault(self:GetRunActionName(k), ActionName.Stand)
    end
  end
end
def.virtual().EndRun = function(self)
  if self.passenger then
    for k, v in pairs(self.passenger) do
      v:PlayWithDefault(self:GetStandActionName(k), ActionName.Stand)
    end
  end
end
def.virtual("number", "table").SetMagicMarkForRole = function(self, markId, role)
  ECRoleModel.SetMagicMark(role, markId)
  ECRoleModel.SetMagicMarkVisible(role, false)
end
def.virtual("boolean", "table").SetMagicMarkVisibleForRole = function(self, visible, role)
  ECRoleModel.SetMagicMarkVisible(role, false)
end
return ECRide.Commit()

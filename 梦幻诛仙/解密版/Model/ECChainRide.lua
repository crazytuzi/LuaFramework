local Lplus = require("Lplus")
local ECRide = require("Model.ECRide")
local ECChainRide = Lplus.Extend(ECRide, "ECChainRide")
local EC = require("Types.Vector3")
local MathHelper = require("Common.MathHelper")
local ECRoleModel = require("Model.ECRoleModel")
local ECFxMan = require("Fx.ECFxMan")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountActionEnum = require("consts.mzm.gsp.mounts.confbean.MountActionEnum")
local ChainRideData = require("Main.Mounts.ChainRideData")
local ECModel = require("Model.ECModel")
local def = ECChainRide.define
def.field("table").m_nextNodes = nil
def.field("number").m_index = 0
def.field(ChainRideData).m_cfg = nil
def.field(ECChainRide).m_root = nil
def.final("table", "number", "number", "number", "number", ChainRideData, "=>", ECRide).new = function(owner, rideId, level, dyeId, index, cfg)
  local obj = ECChainRide()
  obj.m_IsTouchable = owner.m_IsTouchable
  obj.owner = owner
  obj.defaultParentNode = owner.defaultParentNode
  obj.defaultLayer = owner.defaultLayer
  obj.rideId = rideId
  obj.level = level
  obj.dyeId = dyeId
  obj.effects = {}
  obj.m_cfg = cfg
  obj.m_index = index
  obj.m_nextNodes = {}
  local mountCfg = MountsUtils.GetMountsCfgById(rideId)
  if mountCfg then
    obj.actionList = clone(mountCfg.actionList)
  end
  obj:Init(index)
  return obj
end
def.method(ECChainRide).SetRootNode = function(self, root)
  self.m_root = root
end
def.override().OnClick = function(self)
  if self.owner then
    self.owner:OnClick()
  end
end
def.override("number").Update = function(self, tick)
  if self.owner:IsInState(RoleState.RUN) then
    self:UpdateNext(tick)
  end
end
local perpendicular = EC.Vector3.new()
def.method("number").UpdateNext = function(self, tick)
  local forward = self:GetForward()
  for k, v in pairs(self.m_nextNodes) do
    local nodeCfg = v.m_cfg:GetIndexCfg(v.m_index)
    if nodeCfg then
      local forward2 = v:GetForward()
      if forward and forward2 then
        local interpolation = tick * 10
        local dir = EC.Vector3.Lerp(forward, forward2, interpolation)
        dir:Normalize()
        v.m_model.forward = dir
        perpendicular.x, perpendicular.z = dir.z, -dir.x
        v.m_model.localPosition = self.m_model.localPosition + dir * nodeCfg.yOffset + perpendicular * nodeCfg.xOffset
      end
    end
    v:UpdateNext(tick)
  end
end
def.override("function").LoadHead = function(self, cb)
  local function createGroup()
    local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
    if nodeCfg then
      local idxs = self.m_cfg:GetIndexByGroup(nodeCfg.group)
      for k, v in pairs(idxs) do
        local createNodes = self.m_cfg:GetNeedCreateByIndex(self.m_index, k)
        if createNodes and next(createNodes) then
          self:CreateChild(createNodes)
        end
      end
    end
  end
  local function OnRideLoad(ret)
    if ret then
      self:SetLevel(self.level)
      self:SetDye(self.dyeId)
      local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
      if nodeCfg and self.passenger then
        self:RealAttachRole(self.passenger, nodeCfg.seat)
      end
      for k, v in pairs(self.m_nextNodes) do
        if v.m_status == ModelStatus.DESTROY or v.m_status == ModelStatus.NONE then
          v:LoadRide(function()
            self:Set3DPos(self:Get3DPos())
          end)
        end
      end
      createGroup()
      if cb then
        cb()
      end
    elseif cb then
      cb()
    end
  end
  local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
  if nodeCfg == nil then
    if cb then
      cb()
    end
    return
  end
  local modelPath = GetModelPath(nodeCfg.modelId)
  self:Load2(modelPath, OnRideLoad, true)
end
def.override("function").LoadRide = function(self, cb)
  local function OnRideLoad(ret)
    if ret then
      self:SetLevel(self.level)
      self:SetDye(self.dyeId)
      local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
      if nodeCfg and self.passenger then
        self:RealAttachRole(self.passenger, nodeCfg.seat)
      end
      for k, v in pairs(self.m_nextNodes) do
        if v.m_status == ModelStatus.DESTROY or v.m_status == ModelStatus.NONE then
          v:LoadRide(function()
            self:Set3DPos(self:Get3DPos())
          end)
        end
      end
      if cb then
        cb()
      end
    elseif cb then
      cb()
    end
  end
  local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
  if nodeCfg == nil then
    if cb then
      cb()
    end
    return
  end
  local modelPath = GetModelPath(nodeCfg.modelId)
  self:Load2(modelPath, OnRideLoad, true)
end
def.override("=>", "number").GetModelLength = function(self)
  local length = 0
  local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
  if nodeCfg and 0 < nodeCfg.prevNode then
    length = length - nodeCfg.yOffset
  end
  if next(self.m_nextNodes) then
    local maxChildLength = 0
    for k, v in pairs(self.m_nextNodes) do
      local l = v:GetModelLength()
      if maxChildLength < l then
        maxChildLength = l
      end
    end
    length = length + maxChildLength
  elseif self.m_model and not self.m_model.isnil then
    local boxCollider = self.m_model:GetComponent("BoxCollider")
    if boxCollider then
      local size = boxCollider:get_size()
      length = length + size.z / 2
    end
  end
  return length
end
def.override("table").AttachDriver = function(self, driver)
  local driverIndex = self.m_cfg:GetIndexBySeat(1)
  if driverIndex < 0 then
    return
  end
  local createNodes = self.m_cfg:GetNeedCreateByIndex(self.m_index, driverIndex)
  if createNodes and next(createNodes) then
    self:CreateChild(createNodes)
  end
  self:RawAttachRoleToIndex(driver, driverIndex)
end
def.method("table", "number").RawAttachRoleToIndex = function(self, role, index)
  if self.m_index == index then
    self.passenger = role
    if self.m_status == ModelStatus.DESTROY or self.m_status == ModelStatus.NONE then
    elseif self.m_status == ModelStatus.NORMAL then
      self:AttachModelEx("Ride", role, "Bip01 ZuoQi", EC.Vector3.zero, EC.Vector3.new(90, -90, 0))
    elseif self.m_status == ModelStatus.LOADING then
      self:AddOnLoadCallbackQueue("AddPassenger", function()
        self:AttachModelEx("Ride", role, "Bip01 ZuoQi", EC.Vector3.zero, EC.Vector3.new(90, -90, 0))
      end)
    end
  else
    for k, v in pairs(self.m_nextNodes) do
      v:RawAttachRoleToIndex(role, index)
    end
  end
end
def.method("table").CreateChild = function(self, relatedNode)
  local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
  if nodeCfg then
    if nodeCfg.children then
      for k, v in pairs(nodeCfg.children) do
        if relatedNode[k] and not self.m_nextNodes[k] then
          local node = ECChainRide.new(self.owner, self.rideId, self.level, self.dyeId, k, self.m_cfg)
          node:SetRootNode(self.m_root)
          self.m_nextNodes[k] = node
          node:LoadRide(function()
            self:Set3DPos(self:Get3DPos())
          end)
        end
      end
    end
    for k, v in pairs(self.m_nextNodes) do
      v:CreateChild(relatedNode)
    end
  end
end
def.override("table").Set3DPos = function(self, pos)
  if pos == nil then
    return
  end
  ECRide.Set3DPos(self, pos)
  local forward = self:GetForward()
  local pos = self:Get3DPos()
  if pos and forward then
    for k, v in pairs(self.m_nextNodes) do
      local nodeCfg = v.m_cfg:GetIndexCfg(v.m_index)
      if nodeCfg then
        perpendicular.x, perpendicular.z = forward.z, -forward.x
        local offsetPos = pos + forward * nodeCfg.yOffset + perpendicular * nodeCfg.xOffset
        ECRide.SetRotation(v, self:GetRotation())
        v:Set3DPos(offsetPos)
      end
    end
  end
end
def.override("number").SetDir = function(self, ang)
  ECModel.SetDir(self, ang)
  self:Set3DPos(self:Get3DPos())
end
def.override("userdata").SetRotation = function(self, rotation)
  ECRide.SetRotation(self, rotation)
  self:Set3DPos(self:Get3DPos())
end
def.override("string", "=>", "boolean").Play = function(self, aniname)
  for k, v in pairs(self.m_nextNodes) do
    ECModel.Play(v, aniname)
  end
  return ECRide.Play(self, aniname)
end
def.override("number").SetLevel = function(self, level)
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
      local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
      if nodeCfg then
        self:AddBoneEffect(nodeCfg.boneEffectId)
      end
    end
  end
  for k, v in pairs(self.m_nextNodes) do
    v:SetLevel(level)
  end
end
def.override("number").SetDye = function(self, dyeId)
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
  for k, v in pairs(self.m_nextNodes) do
    v:SetDye(dyeId)
  end
end
def.override().Destroy = function(self)
  for k, v in pairs(self.m_nextNodes) do
    v:Destroy()
  end
  if self.passenger then
    local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
    if nodeCfg then
      self:RealDetachRole(self.passenger, nodeCfg.seat)
    end
  end
  self:ClearEffect()
  ECRoleModel.Destroy(self)
end
def.override("=>", "string").GetName = function(self)
  if self.owner then
    return self.owner:GetName()
  else
    return self.m_Name
  end
end
def.override().RemoveAllPassenger = function(self)
  if self.passenger then
    local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
    if nodeCfg and nodeCfg.seat ~= 1 then
      self:RemovePassengerByIndex(nodeCfg.seat)
    end
  end
  for k, v in pairs(table.values(self.m_nextNodes)) do
    v:RemoveAllPassenger()
  end
end
def.override("number").RemovePassengerByIndex = function(self, seat)
  local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
  if nodeCfg then
    if self.passenger and nodeCfg.seat == seat then
      local role = self.passenger
      self.passenger = nil
      role:RemoveState(RoleState.PASSENGER)
      self:RealDetachRole(role, seat)
      self:TryDeleteGroup(nodeCfg.group)
      return
    end
    for k, v in pairs(self.m_nextNodes) do
      v:RemovePassengerByIndex(seat)
    end
  end
end
def.method("number").TryDeleteGroup = function(self, group)
  if self.m_root then
    local toBeDelete = {}
    if self.m_root:CanDeleteGroup(group) >= 0 then
      self.m_root:DeleteGroup(group, toBeDelete)
    end
    if next(toBeDelete) then
      for k, v in pairs(toBeDelete) do
        self:TryDeleteGroup(k)
      end
    end
  end
end
def.override("table", "number").RealDetachRole = function(self, role, index)
  if role == nil then
    return
  end
  self:Detach("Ride")
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
  end
  local magicMarkId = self.magicMarkId
  if magicMarkId > 0 then
    ECRoleModel.SetMagicMark(role, magicMarkId)
    ECRoleModel.SetMagicMark(self, 0)
  end
  role:Play(ActionName.Stand)
  if index ~= 1 then
    role:ReturnMount()
  end
end
def.method("number", "=>", "number").CanDeleteGroup = function(self, group)
  local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
  if nodeCfg then
    if nodeCfg.group == group and nodeCfg.prevNode == 0 then
      return -1
    end
    if next(self.m_nextNodes) then
      if nodeCfg.group == group then
        local canDelete = 1
        for k, v in pairs(self.m_nextNodes) do
          if 0 >= v:CanDeleteGroup(group) then
            canDelete = -1
            break
          end
        end
        return canDelete
      else
        local canDelete = 0
        for k, v in pairs(self.m_nextNodes) do
          if 0 > v:CanDeleteGroup(group) then
            canDelete = -1
            break
          end
        end
        return canDelete
      end
    else
      return nodeCfg.group == group and 1 or 0
    end
  else
    return 0
  end
end
def.method("number", "table", "=>", "boolean").DeleteGroup = function(self, group, toBeDelete)
  local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
  if nodeCfg then
    if nodeCfg.group == group then
      self:Destroy()
      return true
    else
      local deleteIndex = {}
      for k, v in pairs(self.m_nextNodes) do
        local delete = v:DeleteGroup(group, toBeDelete)
        if delete then
          table.insert(deleteIndex, k)
        end
      end
      for k, v in ipairs(deleteIndex) do
        self.m_nextNodes[v] = nil
      end
      if not next(self.m_nextNodes) then
        toBeDelete[nodeCfg.group] = nodeCfg.group
      end
      return false
    end
  else
    return false
  end
end
def.method("number", "=>", "boolean").HasSeat = function(self, seat)
  local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
  if nodeCfg then
    if nodeCfg.seat == seat then
      return true
    else
      for k, v in pairs(self.m_nextNodes) do
        if v:HasSeat(seat) then
          return true
        end
      end
      return false
    end
  else
    return false
  end
end
def.override("table", "number").AddPassenger = function(self, role, seat)
  local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
  if nodeCfg then
    if nodeCfg.seat == seat then
      if self.passenger then
        return
      end
      self.passenger = role
      role:SetState(RoleState.PASSENGER)
      if self.m_status == ModelStatus.DESTROY or self.m_status == ModelStatus.NONE then
      elseif self.m_status == ModelStatus.NORMAL then
        self:RealAttachRole(role, nodeCfg.seat)
      elseif self.m_status == ModelStatus.LOADING then
        self:AddOnLoadCallbackQueue("AddPassenger", function()
          self:RealAttachRole(role, nodeCfg.seat)
        end)
      end
    elseif self:HasSeat(seat) then
      for k, v in pairs(self.m_nextNodes) do
        v:AddPassenger(role, seat)
      end
    else
      local nodeIndex = self.m_cfg:GetIndexBySeat(seat)
      if nodeIndex <= 0 then
        return
      end
      local createNodes = self.m_cfg:GetNeedCreateByIndex(self.m_index, nodeIndex)
      if createNodes and next(createNodes) then
        self:CreateChild(createNodes)
      end
      for k, v in pairs(self.m_nextNodes) do
        v:AddPassenger(role, seat)
      end
    end
  end
end
def.override("table", "number").RealAttachRole = function(self, role, index)
  if role.m_status == ModelStatus.DESTROY or role.m_status == ModelStatus.NONE then
  elseif role.m_status == ModelStatus.NORMAL then
    if self.m_status == ModelStatus.DESTROY or self.m_status == ModelStatus.NONE then
    elseif self.m_status == ModelStatus.NORMAL then
      if index ~= 1 then
        role:SetToGround()
        if not role:IsInState(RoleState.FLY) and role:IsOnMount() then
          role:LeaveMount()
        end
      end
      local boneName = "Bip01 ZuoQi"
      self:AttachModelEx("Ride", role, boneName, EC.Vector3.zero, EC.Vector3.new(90, -90, 0))
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
      if 0 < role.magicMarkId then
        ECRoleModel.SetMagicMark(self, role.magicMarkId)
        ECRoleModel.SetMagicMark(role, 0)
      end
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
def.override("=>", "number").GetPassengerCount = function(self)
  local count = 0
  if self.passenger then
    count = count + 1
  end
  for k, v in pairs(self.m_nextNodes) do
    count = count + v:GetPassengerCount()
  end
  return count
end
def.override("=>", "boolean").HasPassenger = function(self)
  if self.passenger then
    return true
  else
    for k, v in pairs(self.m_nextNodes) do
      if v:HasPassenger() then
        return true
      end
    end
  end
  return false
end
def.override("=>", "table").GetPassengers = function(self)
  local passengers = {}
  if self.passenger then
    table.insert(passengers, self.passenger)
  end
  for k, v in pairs(self.m_nextNodes) do
    local nextPassengers = v:GetPassengers()
    for k, v in ipairs(nextPassengers) do
      table.insert(passengers, v)
    end
  end
  return passengers
end
def.override().StartRun = function(self)
  self:Play(ActionName.Run)
  if self.passenger then
    local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
    if nodeCfg then
      local actionName = self:GetRunActionName(nodeCfg.seat)
      self.passenger:PlayWithDefault(actionName, ActionName.Stand)
    end
  end
  for k, v in pairs(self.m_nextNodes) do
    v:StartRun()
  end
end
def.override().EndRun = function(self)
  self:Play(ActionName.Stand)
  if self.passenger then
    local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
    if nodeCfg then
      self.passenger:PlayWithDefault(self:GetStandActionName(nodeCfg.seat), ActionName.Stand)
    end
  end
  for k, v in pairs(self.m_nextNodes) do
    v:EndRun()
  end
end
def.override("number").SetMagicMark = function(self, markId)
  local nodeCfg = self.m_cfg:GetIndexCfg(self.m_index)
  if nodeCfg then
    if nodeCfg.prevNode == 0 then
      self.magicMarkId = markId
    end
    if nodeCfg.seat == 1 then
      ECRoleModel.SetMagicMark(self, markId)
    else
      for k, v in pairs(self.m_nextNodes) do
        v:SetMagicMark(markId)
      end
    end
  end
end
def.override("number", "table").SetMagicMarkForRole = function(self, markId, role)
  if self.passenger == role then
    ECRoleModel.SetMagicMark(self, markId)
    ECRoleModel.SetMagicMark(role, 0)
  else
    for k, v in pairs(self.m_nextNodes) do
      v:SetMagicMarkForRole(markId, role)
    end
  end
end
def.override("boolean", "table").SetMagicMarkVisibleForRole = function(self, visible, role)
  if self.passenger == role then
    ECRoleModel.SetMagicMarkVisible(self, visible)
  else
    for k, v in pairs(self.m_nextNodes) do
      v:SetMagicMarkVisibleForRole(visible, role)
    end
  end
end
ECChainRide.Commit()
return ECChainRide

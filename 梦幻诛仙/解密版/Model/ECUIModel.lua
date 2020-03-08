local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local ECRoleModel = require("Model.ECRoleModel")
local ECRide = require("Model.ECRide")
local ECFxMan = require("Fx.ECFxMan")
local ECPartComponent = require("Model.ECPartComponent")
local ECWingComponent = require("Model.ECWingComponent")
local ECFollowComponent = require("Model.ECFollowComponent")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local ECUIModel = Lplus.Extend(ECRoleModel, "ECUIModel")
local EquipUtils = require("Main.Equip.EquipUtils")
local def = ECUIModel.define
local parentNode = GameObject.GameObject("UIModel Root")
def.const("userdata").UIModelRoot = parentNode
def.field("table").m_uiModel = nil
def.field("table").initModelInfo = nil
def.field("userdata").m_rightWeaponFx = nil
def.field("userdata").m_leftWeaponFx = nil
def.field("table").m_connectedGOs = nil
def.final("number", "=>", ECUIModel).new = function(id)
  local obj = ECUIModel()
  obj:Init(id)
  return obj
end
def.override("number").Update = function(self, ticks)
  ECRoleModel.Update(self, ticks)
  if self.mECPartComponent ~= nil then
    self.mECPartComponent:Update(ticks)
    self.mECPartComponent:CloseAlpha()
  end
  if self.mECWingComponent ~= nil then
    self.mECWingComponent:Update(ticks)
  end
  if self.mECFabaoComponent ~= nil then
    self.mECFabaoComponent:Update(ticks)
  end
  self:CloseAlpha()
end
def.override("number", "=>", "boolean").Init = function(self, id)
  ECRoleModel.Init(self, id)
  self.parentNode = parentNode
  self.defaultParentNode = parentNode
  self.defaultLayer = ClientDef_Layer.UI_Model1
  self.m_bUncache = true
  self.m_ang = 180
  return true
end
def.method("function").ReturnMount = function(self, callback)
  if self.mount then
    if self.mount.m_status == ModelStatus.DESTROY or self.mount.m_status == ModelStatus.NONE then
      self.mount:LoadRide(function()
        if self.mount and self.mount.m_model and not self.mount.m_model.isnil then
          local roleRotation = self.m_model and not self.m_model.isnil and Quaternion.Euler(EC.Vector3.new(0, self.m_model.localRotation.eulerAngles.y, 0)) or Quaternion.Euler(EC.Vector3.zero)
          self.mount:AttachModelEx("Ride", self, "Bip01 ZuoQi", EC.Vector3.zero, EC.Vector3.new(90, -90, 0))
          self:Play(ActionName.Ride_Stand)
          self.mount:Play(ActionName.Stand)
          self:SetDir(180)
          if self.mShadowObj and not self.mShadowObj.isnil then
            self.mShadowObj:SetActive(false)
          end
        end
        callback(self.mount)
      end)
    else
      callback(self.mount)
    end
  else
    callback(self.mount)
  end
end
def.method("number", "number", "number", "function").TrySetMount = function(self, mountId, level, colorId, callback)
  self.mount = ECRide.new(self, mountId, level, colorId, nil)
  if self:IsLoaded() then
    self:ReturnMount(callback)
  end
end
def.method("table", "function").TrySetMountByModelInfo = function(self, modelInfo, callback)
  local mountId = modelInfo.extraMap[ModelInfo.MOUNTS_ID]
  local mountColorId = modelInfo.extraMap[ModelInfo.MOUNTS_COLOR_ID] or 0
  local mountLevel = modelInfo.extraMap[ModelInfo.MOUNTS_RANK] or 1
  if mountId > 0 then
    if self.mount then
      self.mount:Destroy()
    end
    self:TrySetMount(mountId, mountLevel, mountColorId, callback)
  elseif self.mount then
    self.mount:Destroy()
    self.mount = nil
  end
end
def.override().Destroy = function(self)
  if self:IsDestroyed() then
    return
  end
  self.attachModelInfo = nil
  if self.mECPartComponent then
    self.mECPartComponent:Destroy()
    self.mECPartComponent = nil
  end
  if self.mECFabaoComponent then
    self.mECFabaoComponent:Destroy()
    self.mECFabaoComponent = nil
  end
  if self.mECWingComponent then
    self.mECWingComponent:Destroy()
    self.mECWingComponent = nil
  end
  self:ClearWeaponFXs()
  if self.m_connectedGOs then
    for i, v in ipairs(self.m_connectedGOs) do
      if not v.isnil then
        GameObject.Destroy(v)
      end
    end
    self.m_connectedGOs = nil
  end
  ECRoleModel.Destroy(self)
  if self.mount then
    self.mount:Destroy()
    self.mount = nil
  end
end
def.override("boolean").SetVisible = function(self, v)
  ECRoleModel.SetVisible(self, v)
end
def.override().OnClick = function(self)
end
def.method("string", "function", "=>", "boolean").LoadUIModel = function(self, path, cb)
  self:Load(path, function(ret)
    self:CloseAlpha()
    if ret == nil then
      self:DoCallback(cb, nil)
      return
    end
    if self.mount == nil then
      self:OnLoadGameObject()
      self:DoCallback(cb, ret)
    else
      self:OnLoadRoleAndMount(cb)
    end
  end)
  return true
end
def.method("function").OnLoadRoleAndMount = function(self, cb)
  self:OnLoadGameObject()
  self:ReturnMount(function(mount)
    if mount and mount.m_model then
      self:DoCallback(cb, self)
    else
      self:DoCallback(cb, nil)
    end
  end)
end
def.override().OnLoadGameObject = function(self)
  if self.m_model == nil then
    warn("ECUIModel OnLoadGameObject: m_model is nil for: ", self.mModelId)
    return
  end
  ECRoleModel.OnLoadGameObject(self)
  local m = self.m_model
  m.parent = self.parentNode
  m.transform.position = EC.Vector3.new(0, 0, -100)
  m.localScale = EC.Vector3.one
  m:SetLayer(ClientDef_Layer.UI_Model1)
  self:CloseAlphaBase()
  self:SetVisible(self.m_visible)
  self:SetOrnament(self.showOrnament)
  if self.attachModelInfo then
    local modelInfo = self.attachModelInfo
    self.attachModelInfo = nil
    SetModelExtra(self, modelInfo)
  end
  self:Play(ActionName.Stand)
end
def.method("function", "table").DoCallback = function(self, cb, ret)
  if cb then
    cb(ret)
  end
end
def.override("number", "number").SetWeapon = function(self, id, lightLevel)
  SetModelWeapon(self, id, lightLevel)
end
def.override("number").SetWeaponColor = function(self, lv)
  SetModelWeaponColor(self, lv)
end
def.override("table").SetWeaponModel = function(self, modelInfo)
  SetModelWeaponAppearance(self, modelInfo)
end
def.override("number", "number").SetWing = function(self, id, dyeId)
  if self.mECWingComponent == nil then
    self.mECWingComponent = ECWingComponent.new(self)
    self.mECWingComponent.defaultLayer = ClientDef_Layer.UI_Model1
  else
    self.mECWingComponent:SetCharModel(self)
  end
  if self.mECWingComponent then
    if id > 0 then
      self.mECWingComponent:LoadRes(id, dyeId)
    else
      self.mECWingComponent:Destroy()
    end
  end
end
def.method("number", "number").SetWingEX = function(self, id, dyeId)
  if self.mECWingComponent == nil then
    self.mECWingComponent = ECWingComponent.new(self)
    self.mECWingComponent.defaultLayer = ClientDef_Layer.UI_Model1
  end
  if self.mECWingComponent then
    if id > 0 then
      self.mECWingComponent:LoadResBase(id, dyeId)
    else
      self.mECWingComponent:Destroy()
    end
  end
end
def.method("=>", ECModel).GetWing = function(self)
  if self.mECWingComponent == nil then
    return nil
  end
  return self.mECWingComponent.m_wing
end
def.override("number").SetFabao = function(self, id)
  if self.mECFabaoComponent == nil then
    self.mECFabaoComponent = ECFollowComponent.new(self)
    self.mECFabaoComponent.defaultLayer = ClientDef_Layer.UI_Model1
  end
  if self.mECFabaoComponent then
    if id > 0 then
      self.mECFabaoComponent:LoadRes(id)
    else
      self.mECFabaoComponent:Destroy()
    end
  end
end
def.override("string", "=>", "boolean").Play = function(self, aniname)
  if self.mECPartComponent then
    self.mECPartComponent:PlayAnimation(aniname, ActionName.Stand)
  end
  return ECModel.Play(self, aniname)
end
def.override("string", "number").CrossFade = function(self, aniname, fade)
  if self.mECPartComponent then
    self.mECPartComponent:PlayAnimation(aniname, ActionName.Stand)
  end
  return ECModel.CrossFade(self, aniname, fade)
end
def.override("number").SetAlpha = function(self, val)
  ECRoleModel.SetAlpha(self, val)
  if self.mECPartComponent then
    self.mECPartComponent:SetAlpha(val)
  end
  if self.mECWingComponent then
    self.mECWingComponent:SetAlpha(val)
  end
  if val > 0.5 then
    self:ActivateWeaponFXs(true)
  else
    self:ActivateWeaponFXs(false)
  end
end
def.override("number").ChangeAlpha = function(self, val)
  ECModel.ChangeAlpha(self, val)
  if self.mECPartComponent then
    self.mECPartComponent:ChangeAlpha(val)
  end
  if self.mECWingComponent then
    self.mECWingComponent:ChangeAlpha(val)
  end
  if val > 0.5 then
    self:ActivateWeaponFXs(true)
  else
    self:ActivateWeaponFXs(false)
  end
end
def.override().CloseAlpha = function(self)
  ECRoleModel.CloseAlpha(self)
  if self.mECPartComponent then
    self.mECPartComponent:CloseAlpha()
  end
  if self.mECWingComponent then
    self.mECWingComponent:CloseAlpha()
  end
  self:ActivateWeaponFXs(false)
end
def.method("string").AttachEffectToWeapon = function(self, resname)
  if resname == nil then
    return
  end
  local partInfo
  if self.mModelId == 700300007 then
    partInfo = {
      bones = {
        left = "Bip01_LeftWeapon03",
        right = "Bip01_RightWeapon03"
      }
    }
  end
  if self.mECPartComponent == nil and partInfo == nil then
    return
  end
  if self.mECPartComponent then
    partInfo = {}
    local weaponId = self.mECPartComponent.weaponId
    local info = EquipUtils.GetEquipBasicInfo(weaponId)
    partInfo.weaponType = info.weaponType
    partInfo.bones = {}
    local WeaponType = require("consts.mzm.gsp.item.confbean.WeaponType")
    if info.weaponType == WeaponType.RIGHT or partInfo.weaponType == WeaponType.BOTH then
      partInfo.bones.right = ECPartComponent.RIGHT_WEAPON_BONE_NAME
    end
    if info.weaponType == WeaponType.LEFT or partInfo.weaponType == WeaponType.BOTH then
      partInfo.bones.left = ECPartComponent.LEFT_WEAPON_BONE_NAME
    end
  end
  if partInfo then
    if partInfo.bones.right then
      self.m_rightWeaponFx = self:AttachEffectToBone(resname, partInfo.bones.right)
    end
    if partInfo.bones.left then
      self.m_leftWeaponFx = self:AttachEffectToBone(resname, partInfo.bones.left)
    end
  end
end
def.method().ClearWeaponFXs = function(self)
  if self.m_leftWeaponFx then
    GameObject.Destroy(self.m_leftWeaponFx)
    self.m_leftWeaponFx = nil
  end
  if self.m_rightWeaponFx then
    GameObject.Destroy(self.m_rightWeaponFx)
    self.m_rightWeaponFx = nil
  end
end
def.method("boolean").ActivateWeaponFXs = function(self, isActive)
  if self.m_leftWeaponFx then
    self.m_leftWeaponFx:SetActive(isActive)
  end
  if self.m_rightWeaponFx then
    self.m_rightWeaponFx:SetActive(isActive)
  end
end
def.method("userdata").ConnectToGO = function(self, go)
  self.m_connectedGOs = self.m_connectedGOs or {}
  table.insert(self.m_connectedGOs, go)
end
def.method("table").LoadModelInfo = function(self, modelInfo)
  if self.m_model then
    SetModelExtra(self, modelInfo)
  else
    self.attachModelInfo = modelInfo
  end
end
def.method("=>", "userdata").GetMainModel = function(self)
  if self.mount then
    return self.mount.m_model
  else
    return self.m_model
  end
end
def.override("number").SetDir = function(self, ang)
  if self.mount then
    ECModel.SetDir(self.mount, ang)
    self.m_ang = ang
  else
    ECModel.SetDir(self, ang)
  end
end
def.method("number").ChangeModel = function(self, modelId)
  if self.m_model == nil then
    return
  end
  self.mModelId = modelId
  self.m_ang = self:GetDir()
  local pos3d = self.m_model.localPosition
  local s = self.m_model.localScale
  local r = self.m_model.localRotation
  local cbs = self.onLoadCallback
  self.onLoadCallback = nil
  self:Destroy()
  self.onLoadCallback = cbs
  local modelpath, modelcolor = GetModelPath(modelId)
  self.colorId = modelcolor
  self.attachModelInfo = nil
  local function ResetModelTransform()
    if self.m_model == nil then
      return
    end
    self.m_model.localPosition = pos3d
    self.m_model.localScale = s
    self.m_model.localRotation = r
  end
  local function OnLoaded()
    if self.m_model == nil then
      self:Destroy()
      return
    end
    ECRoleModel.OnLoadGameObject(self)
    self.m_ani.enabled = false
    self.m_ani.enabled = true
    if self.attachModelInfo then
      local modelInfo = self.attachModelInfo
      self.attachModelInfo = nil
      SetModelExtra(self, modelInfo)
    end
    if self:IsInLoading() then
      self:AddOnLoadCallback("ResetModelTransform", ResetModelTransform)
      return
    else
      ResetModelTransform()
    end
    self:DoOnLoadCallback()
  end
  self:Load2(modelpath, OnLoaded, true)
end
ECUIModel.Commit()
return ECUIModel

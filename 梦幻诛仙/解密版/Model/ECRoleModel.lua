local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECPartComponent = require("Model.ECPartComponent")
local ECWingComponent = require("Model.ECWingComponent")
local ECFollowComponent = require("Model.ECFollowComponent")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local ECRoleModel = Lplus.Extend(ECModel, "ECRoleModel")
local EquipUtils = require("Main.Equip.EquipUtils")
local def = ECRoleModel.define
local t_vec = EC.Vector3.new()
def.field("table").mECPartComponent = nil
def.field("table").mECWingComponent = nil
def.field("table").mECFabaoComponent = nil
def.field("table").mount = nil
def.field("table").attachModelInfo = nil
def.field("number").lightLevel = 0
def.field("table").m_accessories = nil
def.field("table").attachedModels = nil
def.field("number").magicMarkId = 0
def.field("boolean").showOrnament = false
def.field("number").orgIconId = 0
def.field("table").weaponInfo = nil
def.field("number").changeModelPriority = 0
def.final("number", "=>", ECRoleModel).new = function(id)
  local obj = ECRoleModel()
  obj:Init(id)
  return obj
end
def.override("number", "=>", "boolean").Init = function(self, id)
  return ECModel.Init(self, id)
end
def.override().Destroy = function(self)
  if self:IsDestroyed() then
    return
  end
  self.weaponInfo = nil
  self.magicMarkId = 0
  self.attachModelInfo = nil
  self:RemoveAllAttachedModel()
  self:RemoveAllAccessory()
  if self.m_uiNameHandle then
    local icon = self.m_uiNameHandle:FindDirect("Pate/Title/Texture_Icon")
    if icon then
      local uiTexture = icon:GetComponent("UITexture")
      uiTexture.mainTexture = nil
    end
  end
  ECModel.Destroy(self)
end
def.override().OnLoadGameObject = function(self)
  ECModel.OnLoadGameObject(self)
  if self.lightLevel > 0 then
    _G.SetModelLightEffect(self, self.lightLevel)
  end
end
def.override("number").Update = function(self, ticks)
  ECModel.Update(self, ticks)
end
def.override().OnClick = function(self)
  ECModel.OnClick(self)
end
def.override("string", "userdata").SetName = function(self, name, color)
  ECModel.SetName(self, name, color)
  self:SetOrganizationIcon(self.orgIconId)
end
def.method("number").SetOrganizationIcon = function(self, orgIconId)
  self.orgIconId = orgIconId
  if self.m_uiNameHandle == nil then
    return
  end
  local icon = self.m_uiNameHandle:FindDirect("Pate/Title/Texture_Icon")
  if icon then
    local uiTexture = icon:GetComponent("UITexture")
    require("GUI.GUIUtils").FillIcon(uiTexture, orgIconId)
    icon:SetActive(orgIconId > 0)
  end
end
def.override().ResetAction = function(self)
  if self.mECWingComponent then
    self.mECWingComponent:ResetAction()
  end
  ECModel.ResetAction(self)
end
def.override("boolean").SetVisible = function(self, v)
  ECModel.SetVisible(self, v)
  self:SetMagicMarkVisible(v)
end
def.override("boolean").SetShowModel = function(self, v)
  ECModel.SetShowModel(self, v)
  self:SetMagicMarkVisible(v)
end
def.override("number").SetAlpha = function(self, val)
  ECModel.SetAlpha(self, val)
  if self.attachedModels then
    for _, model in pairs(self.attachedModels) do
      model:SetAlpha(val)
    end
  end
end
def.override().CloseAlpha = function(self)
  ECModel.CloseAlphaBase(self)
  if self.attachedModels then
    for _, model in pairs(self.attachedModels) do
      model:CloseAlphaBase()
    end
  end
end
def.method("string", "userdata", "string", "number", "=>", "boolean").AddAccessory = function(self, key, obj, bonename, offsetH)
  if obj == nil or self.m_model == nil then
    return false
  end
  if self.m_accessories == nil then
    self.m_accessories = {}
  end
  local bone = self.m_model:FindDirect(bonename)
  if bone == nil then
    return false
  end
  obj.parent = bone
  obj.layer = self.m_model.layer
  obj.localPosition = EC.Vector3.new(0, offsetH, 0)
  obj.localRotation = Quaternion.Euler(EC.Vector3.zero)
  self.m_accessories[key] = obj
  return true
end
def.method("string", "=>", "userdata").GetAccessory = function(self, key)
  return self.m_accessories and self.m_accessories[key]
end
def.method("string").RemoveAccessory = function(self, key)
  if self.m_accessories == nil then
    return
  end
  local obj = self.m_accessories[key]
  if obj == nil then
    return
  end
  obj:Destroy()
  self.m_accessories[key] = nil
end
def.method().RemoveAllAccessory = function(self)
  if self.m_accessories == nil then
    return
  end
  for k, v in pairs(self.m_accessories) do
    if v and not v.isnil then
      v:Destroy()
    end
  end
  self.m_accessories = nil
end
def.method("boolean").SetOrnament = function(self, visible)
  self.showOrnament = visible
  if self.m_model == nil then
    return
  end
  local ornament = self.m_model:FindDirect("Ornament")
  if ornament then
    ornament:SetActive(self.showModel and self.showOrnament)
  end
end
def.method("string", "number", "string", "number").AddAttachedModel = function(self, resPath, part, boneName, offsetH)
  if self.attachedModels == nil then
    self.attachedModels = {}
  end
  local mark_model = self.attachedModels[resPath]
  if mark_model and (not _G.IsNil(mark_model.m_model) or mark_model:IsInLoading()) then
    return
  end
  local function DoAddEffect()
    if _G.IsNil(self.m_model) then
      return
    end
    if not self.m_visible or not self.showModel then
      return
    end
    if self.magicMarkId == 0 then
      return
    end
    if self.attachedModels == nil then
      self.attachedModels = {}
    end
    local cur_model = self.attachedModels[resPath]
    if cur_model and not cur_model:IsDestroyed() then
      return
    end
    local offsetY = offsetH
    local boxCollider = self.m_model:GetComponent("BoxCollider")
    local box_height = 0
    if boxCollider ~= nil then
      local size = boxCollider:get_size()
      box_height = size.y
    end
    local parent = self.m_model
    if part == BODY_PART.HEAD then
      offsetY = box_height + offsetH
    elseif part == BODY_PART.BODY then
      offsetY = box_height / 2 + offsetH
    elseif part == BODY_PART.BONE then
      offsetY = offsetH
      parent = self.m_model:FindChild(boneName)
    end
    local model = ECModel.new(0)
    self.attachedModels[resPath] = model
    model.parentNode = parent
    model.defaultLayer = self.defaultLayer
    model:Load(resPath, function()
      if self:IsDestroyed() then
        self:RemoveAttachedModel(resPath)
        return
      end
      if not _G.IsNil(model.m_model) then
        model.m_model.localPosition = t_vec:Assign(0, offsetY, 0)
        model.m_model.localRotation = Quaternion.identity
        self:SetMagicMarkVisible(self.m_visible and self.showModel)
      end
    end)
  end
  if self.m_model == nil and self:IsInLoading() then
    self:AddOnLoadCallback("add_attached_model", DoAddEffect)
  else
    DoAddEffect()
  end
end
def.method("string").RemoveAttachedModel = function(self, resPath)
  if self.attachedModels == nil then
    return
  end
  local model = self.attachedModels[resPath]
  if model then
    model:Destroy()
  end
  self.attachedModels[resPath] = nil
end
def.method().RemoveAllAttachedModel = function(self)
  if self.attachedModels == nil then
    return
  end
  for k, v in pairs(self.attachedModels) do
    v:Destroy()
  end
  self.attachedModels = nil
end
def.virtual("number").SetMagicMark = function(self, markId)
  if self:IsDestroyed() then
    return
  end
  if self.magicMarkId == markId then
    return
  end
  if self.magicMarkId > 0 then
    if self:IsInLoading() then
      self:RemoveOnLoadCallback("add_attached_model")
    end
    local respath = _G.GetModelPath(self.magicMarkId)
    if respath then
      self:RemoveAttachedModel(respath)
    end
  end
  self.magicMarkId = markId
  if markId <= 0 then
    return
  end
  local respath = _G.GetModelPath(markId)
  if respath then
    self:AddAttachedModel(respath, BODY_PART.FEET, "", 0)
  end
end
def.virtual("boolean").SetMagicMarkVisible = function(self, visible)
  if self.magicMarkId > 0 then
    local respath = _G.GetModelPath(self.magicMarkId)
    if respath then
      if visible then
        self:AddAttachedModel(respath, BODY_PART.FEET, "", 0)
      else
        self:RemoveAttachedModel(respath)
      end
    end
  end
end
def.virtual("number", "number").SetWeapon = function(self, id, lightLevel)
end
def.method("boolean").ShowWeapon = function(self, isShow)
  if self.mECPartComponent then
    self.mECPartComponent:SetVisible(isShow)
  end
end
def.virtual("number").SetWeaponColor = function(self, lv)
end
def.virtual("table").SetWeaponModel = function(self, modelinfo)
end
def.virtual("number", "number").SetWing = function(self, id, dyeId)
end
def.method("number").SetWingColor = function(self, dyeId)
  if self.mECWingComponent then
    self.mECWingComponent:SetColor(dyeId)
  end
end
def.virtual("number").SetFabao = function(self, id)
end
def.virtual("=>", "number").GetFeijianId = function(self)
  return 0
end
def.virtual("=>", "number").GetFeijianColorId = function(self)
  return 0
end
def.virtual("number", "number").SetFeijianId = function(self, feijianId, colorId)
end
def.virtual("number").SetFeijianColorId = function(self, colorId)
end
ECRoleModel.Commit()
return ECRoleModel

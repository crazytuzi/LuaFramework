local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local MathHelper = require("Common.MathHelper")
local ECModel = require("Model.ECModel")
local ECRoleModel = require("Model.ECRoleModel")
local ECFxMan = require("Fx.ECFxMan")
local ECPartComponent = require("Model.ECPartComponent")
local ECWingComponent = require("Model.ECWingComponent")
local ECFollowComponent = require("Model.ECFollowComponent")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local FlyModule = require("Main.Fly.FlyModule")
local ECRide = require("Model.ECRide")
local ECChainRide = require("Model.ECChainRide")
local ChainRideData = require("Main.Mounts.ChainRideData")
local BitMap = require("Common.BitMap")
local ECPlayer = Lplus.Extend(ECRoleModel, "ECPlayer")
local FlagPosList
local loadingRes = {}
local t_vec = EC.Vector3.new()
local def = ECPlayer.define
local MOUNT_TOPICON_OFFSET = 0.6
def.field(ECModel).feijianModel = nil
def.field("userdata").feijianEffect = nil
def.field("userdata").roleId = nil
def.field("userdata").teamId = nil
def.field("number").m_roleType = 0
def.field("table").movePath = nil
def.field("number").pathIdx = 0
def.field("function").runpathCallback = nil
def.field("number").runSpeed = 180
def.field("number").followSpeed = 0
def.field("table").pet = nil
def.field("table").escortTarget = nil
def.field("number").followIdx = 0
def.field("userdata").m_topIcon = nil
def.field("userdata").m_topIconCacheRoot = nil
def.field("userdata").m_topButton = nil
def.field("number").titleIcon = 0
def.field("number").flagIcon = 0
def.field("string")._currTitleEffectPath = ""
def.field("userdata").teamIcon = nil
def.field("userdata").battleIcon = nil
def.field("number").idleTime = -1
def.field("table").m_callWhenBeginRun = function()
  return {}
end
def.field("table").m_callWhenEndRun = function()
  return {}
end
def.field("table").state = nil
def.field("table").m_attachedEffects = nil
def.field("table").childEffects = nil
def.field("userdata").movePathComp = nil
def.field("number").feijianId = 0
def.field("number").feijianColorId = 0
def.field("number").replaceFeijianId = 0
def.field("table").flyStrategy = nil
def.field("number").flyState = 0
def.field("table").flyPoint = nil
def.const("table").FlyState = {
  Up = 1,
  Flight = 2,
  Down = 3
}
def.field("boolean").checkAlpha = true
def.field("boolean").enableIdleAct = true
def.field("table").extraInfo = nil
def.field("table").backupModelInfo = nil
def.field("table").backupModel = nil
def.field("userdata").m_ballCooldownPate = nil
def.field("number").m_curCooldown = 0
def.field("number").m_maxEndTime = 0
def.field("number").m_maxDuration = 0
def.final("userdata", "number", "string", "userdata", "number", "=>", ECPlayer).new = function(roleId, modelId, name, nameColor, roleType)
  local obj = ECPlayer()
  obj.m_roleType = roleType
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj:Init(modelId)
  obj.roleId = roleId
  obj.flyState = 0
  obj:SetName(name, nameColor)
  return obj
end
local map_scene
def.override("number").Update = function(self, ticks)
  ECRoleModel.Update(self, ticks)
  self:UpdateIdleStatus(ticks)
  self:CheckIdle(ticks)
  if self.mECWingComponent ~= nil then
    self.mECWingComponent:Update(ticks)
  end
  if not map_scene then
    map_scene = gmodule.moduleMgr:GetModule(ModuleId.MAP).scene
  end
  if self.checkAlpha then
    local x, y, z = self.m_node2d:GetPosXYZ()
    if not self:IsInState(RoleState.FLY) and self:IsTransparent(x, y) then
      if self.m_IsAlpha == false then
        self:SetAlpha(0.55)
        if self.mECPartComponent then
          self.mECPartComponent:SetAlpha(0.55)
        end
        if self.mECWingComponent then
          self.mECWingComponent:SetAlpha(0.55)
        end
        if self.mECFabaoComponent then
          self.mECFabaoComponent:SetAlpha(0.55)
        end
      end
      if self.mount then
        self.mount:SetAlpha(0.55)
      end
    elseif self.m_IsAlpha == true then
      self:CloseAlpha()
      if self.mECPartComponent then
        self.mECPartComponent:CloseAlpha()
      end
      if self.mECWingComponent then
        self.mECWingComponent:CloseAlpha()
      end
      if self.mECFabaoComponent then
        self.mECFabaoComponent:CloseAlpha()
      end
      if self.mount then
        self.mount:CloseAlpha()
      end
    end
  end
  local pet = self:GetPet()
  if pet then
    pet:Update(ticks)
  end
  local escortTarget = self:GetEscortTarget()
  if escortTarget then
    escortTarget:Update(ticks)
  end
  if self.huggedRole and self.huggedRole.m_node2d and not self.huggedRole.m_node2d.isnil then
    self.huggedRole.m_node2d.localPosition = self.m_node2d.localPosition
  end
  if self.mount and self.mount:HasPassenger() then
    local ps = self.mount:GetPassengers()
    for k, v in pairs(ps) do
      if v.m_node2d and not v.m_node2d.isnil then
        v.m_node2d.localPosition = self.m_node2d.localPosition
      end
    end
  end
  if self.mount then
    self.mount:Update(ticks)
  end
  if self.backupModel then
    ECModel.Update(self.backupModel, ticks)
  end
  if not _G.IsNil(self.m_ballCooldownPate) then
    self:UpdateBallCooldownPate()
  end
end
local LogicMap = require("Main.Homeland.data.LogicMap")
def.method("number", "number", "=>", "boolean").IsTransparent = function(self, x, y)
  if gmodule.moduleMgr:GetModule(ModuleId.HERO).isInHomeland and LogicMap.Instance():IsLoaded() then
    return LogicMap.Instance():IsMask(x, y)
  elseif map_scene then
    return MapScene.IsTransparent(map_scene, x, y)
  end
  return false
end
def.method("=>", "boolean").IsInBlock = function(self)
  if self.m_node2d == nil then
    return false
  end
  return MapScene.IsBarrierXY(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, self.m_node2d.localPosition.x, self.m_node2d.localPosition.y)
end
def.override("number", "=>", "boolean").Init = function(self, id)
  self.m_create_node2d = true
  self.m_IsTouchable = true
  ECRoleModel.Init(self, id)
  self.m_color = nil
  return true
end
def.override().Destroy = function(self)
  if self:IsDestroyed() then
    return
  end
  self:ClearBackup()
  self:RemoveAllChildEffect()
  self:RemoveAllEffect()
  if self.m_topIcon then
    if self.m_topIconCacheRoot then
      self.m_topIcon:FindDirect("Pate/Img_Chengwei"):GetComponent("UITexture").mainTexture = nil
      local ECPate = require("GUI.ECPate")
      ECPate.AddToCache(self.m_topIcon, self.m_topIconCacheRoot)
      self.m_topIconCacheRoot = nil
    else
      self.m_topIcon:Destroy()
    end
    self.m_topIcon = nil
  end
  self:DestroyTopButton("")
  self:DestroyBallCooldownPate()
  self:RemovePet()
  self:RemoveEscortTarget()
  if self.teamIcon then
    self.teamIcon:Destroy()
    self.teamIcon = nil
  end
  if self.battleIcon then
    self.battleIcon:Destroy()
    self.battleIcon = nil
  end
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
    self.m_callWhenBeginRun.Wing = nil
    self.m_callWhenEndRun.Wing = nil
    self.mECWingComponent = nil
  end
  if self.feijianModel then
    self:RemoveFlyComponent()
    local roleAttach = self.feijianModel:GetAttach(FlyModule.FlyTag)
    if roleAttach ~= nil then
      self.feijianModel:Detach(FlyModule.FlyTag)
    end
    self.feijianModel:Destroy()
    self.feijianModel = nil
  end
  if self.feijianEffect then
    ECFxMan.Instance():Stop(self.feijianEffect)
    self.feijianEffect = nil
  end
  self.flyState = 0
  if self.flyStrategy then
    self.flyStrategy:Destroy()
    self.flyStrategy = nil
  end
  if self.mount then
    self:LeaveMount()
    self.mount = nil
  end
  self.movePathComp = nil
  if self.m_model and not self.m_model.isnil then
    self.m_model.localScale = EC.Vector3.one
  end
  self:UnHug()
  self:EndInteraction()
  ECRoleModel.Destroy(self)
end
def.method().DestroyModel = function(self)
  if self.mECPartComponent then
    self.mECPartComponent:Destroy()
  end
  if self.mECWingComponent then
    self.mECWingComponent:Destroy()
  end
  if self.mECFabaoComponent then
    self.mECFabaoComponent:StopFollow()
  end
  if self.feijianEffect then
    ECFxMan.Instance():Stop(self.feijianEffect)
    self.feijianEffect = nil
  end
  local node2d = self.m_node2d
  local namepate = self.m_uiNameHandle
  self.m_node2d = nil
  self.m_uiNameHandle = nil
  ECRoleModel.Destroy(self)
  self.m_node2d = node2d
  self.m_uiNameHandle = namepate
end
def.override("boolean").SetVisible = function(self, v)
  ECRoleModel.SetVisible(self, v)
  self:ShowAttachments(self.m_visible)
  self:SetStance()
  if self.feijianModel then
    self.feijianModel:SetActive(self.m_visible)
    self.feijianModel.m_visible = v
  end
  if self.mount then
    self.mount:SetActive(self.m_visible)
    self.mount.m_visible = v
  end
end
def.override("boolean").SetTouchable = function(self, v)
  if self.mount then
    self.mount:SetTouchable(v)
  end
  ECRoleModel.SetTouchable(self, v)
end
def.override().SetStance = function(self)
  if self.interaction then
    self:EndInteraction()
  end
  if self.mount == nil then
    self:Play(ActionName.Stand)
  else
    self.mount:Play(ActionName.Stand)
    self.mount:EndRun()
    self:PlayWithDefault(self.mount:GetStandActionName(1), ActionName.Stand)
  end
end
def.method("boolean").ShowAttachments = function(self, v)
  self:ShowHudParts(v)
  if self.mECFabaoComponent then
    self.mECFabaoComponent:SetVisible(v)
  end
  if self.mECWingComponent then
    self.mECWingComponent:SetVisible(v)
  end
  if self.battleIcon and not self.battleIcon.isnil then
    self.battleIcon:SetActive(v)
  end
  if self.teamIcon and not self.teamIcon.isnil then
    self.teamIcon:SetActive(v)
  end
  if self.m_attachedEffects then
    for _, v in pairs(self.m_attachedEffects) do
      if v and not v.isnil then
        v:SetActive(v)
      end
    end
  end
end
def.method("boolean").ShowHudParts = function(self, v)
  if self.m_uiDialogHandle then
    self.m_uiDialogHandle:SetActive(v)
  end
  if self.m_topIcon then
    self.m_topIcon:SetActive(v)
  end
  if not v then
    self:StopTalk()
  end
end
def.virtual("userdata").SetTeamId = function(self, teamId)
  self.teamId = teamId
  if self.teamId == nil then
    self:SetTeamNum(0)
  end
end
def.override("boolean").SetShowModel = function(self, v)
  self:ShowAttachments(v)
  if self.feijianModel then
    self.feijianModel:SetShowModel(v)
  end
  if self.mount then
    if v and self.m_visible and self.m_model and not self.m_model.activeSelf then
      self.m_model:SetActive(true)
    end
    self.mount:SetShowModel(v)
  end
  local pet = self:GetPet()
  if pet then
    pet:SetShowModel(v)
  end
  ECRoleModel.SetShowModel(self, v)
end
def.method("userdata").ResetPate = function(self, target)
  if target == nil or target.isnil then
    return
  end
  local follow = target:GetComponent("HUDFollowTarget")
  if follow then
    follow.target = self.m_model.transform
  end
end
def.override("number").SetLayer = function(self, layer)
  self.defaultLayer = layer
  if self.m_model and not self.m_model.isnil then
    self.m_model:SetLayer(self.defaultLayer)
  end
  if self.mECFabaoComponent then
    self.mECFabaoComponent:SetLayer(self.defaultLayer)
  end
  if self.mECWingComponent then
    self.mECWingComponent:SetLayer(self.defaultLayer)
  end
  if self.mECPartComponent then
    self.mECPartComponent:SetLayer(self.defaultLayer)
  end
  if self.mount then
    self.mount:SetLayer(self.defaultLayer)
  end
end
def.method("number").ChangeModel = function(self, modelId)
  if self.m_model == nil then
    return
  end
  self:EndInteraction()
  self:HideBackup()
  if self.teamIcon then
    self.teamIcon.parent = nil
  end
  if self.feijianModel then
    self:Detach(FlyModule.FlyTag)
  end
  if self.huggedRole then
    local flyStrategy = self:GetOrCreateFlyStrategy()
    flyStrategy:Unhug()
  end
  local visible = self.m_visible
  local showModel = self.showModel
  self.mModelId = modelId
  self.m_ang = self:GetDir()
  local s = self.m_model.localScale
  local r = self.m_model.localRotation
  local cbs = self.onLoadCallback
  self.onLoadCallback = nil
  self:DestroyModel()
  self.onLoadCallback = cbs
  local modelpath, modelcolor = GetModelPath(modelId)
  self.colorId = modelcolor
  local function OnNewModelLoaded()
    if self.m_model == nil or self.m_model.isnil then
      self:Destroy()
      return
    end
    if self.m_topIcon then
      self:ResetPate(self.m_topIcon)
    end
    if self.m_topButton then
      self:ResetPate(self.m_topButton)
    end
    if self.m_ballCooldownPate then
      self:ResetPate(self.m_ballCooldownPate)
    end
    if self.teamIcon and not self.teamIcon.isnil then
      self.teamIcon.parent = self.m_model
      self:ResetTeamIcon()
    end
    local pos = self:GetPos()
    if pos then
      self.m_model.localPosition = Map2DPosTo3D(pos.x, world_height - pos.y)
    end
    self.m_model.localScale = s
    self.m_model.localRotation = r
    self:ReturnMount()
    if self:IsInState(RoleState.FLY) then
      self:ResetFly()
    end
    self:ReloadAllChildEffect()
    if self.movePath and #self.movePath > 0 then
      local movePath = self.movePath
      local pathIdx = self.pathIdx
      local runpathCallback = self.runpathCallback
      if self:IsInState(RoleState.FLY) then
        local moveEnd = movePath[#movePath]
        self:FlyTo(moveEnd.x, moveEnd.y, runpathCallback)
      else
        local newPath = {}
        for i = #movePath - pathIdx + 1, #movePath do
          table.insert(newPath, movePath[i])
        end
        self:RunPath(newPath, self.runSpeed, runpathCallback)
      end
    else
      self:SetStance()
    end
    self:SetPate()
    self:ResetTopIcons()
    self:ResetTopEffects(false)
    if 0 < self.lightLevel then
      _G.SetModelLightEffect(self, self.lightLevel)
    end
  end
  local function OnLoaded()
    if self.m_model == nil or self.m_model.isnil then
      self:Destroy()
      return
    end
    ECRoleModel.OnLoadGameObject(self)
    self.m_ani.enabled = false
    self.m_ani.enabled = true
    self:CreateHUD()
    if self.mECPartComponent then
      self.mECPartComponent:AttachToModel(self)
    end
    if self.mECWingComponent then
      self.mECWingComponent:AttachToModel(self)
    end
    if self.mECFabaoComponent then
      self.mECFabaoComponent:ResetCharModel(self)
    end
    if self.huggedRole then
      local flyStrategy = self:GetOrCreateFlyStrategy()
      flyStrategy:Hug()
    end
    if self.attachModelInfo then
      local modelInfo = self.attachModelInfo
      self.attachModelInfo = nil
      SetModelExtra(self, modelInfo)
    end
    if self:IsInLoading() then
      self:AddOnLoadCallback("OnNewModelLoaded", OnNewModelLoaded)
      return
    else
      OnNewModelLoaded()
    end
    self:DoOnLoadCallback()
  end
  self:Load2(modelpath, OnLoaded, true)
  if not visible then
    self:SetVisible(false)
  end
  if not showModel then
    self:SetShowModel(false)
  end
end
def.override().OnClick = function(self)
  ECRoleModel.OnClick(self)
  if self.roleId and self.m_roleType == RoleType.ROLE and self.roleId:eq(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) then
    return
  end
  local showSelectEffect = false
  if self.m_roleType == RoleType.ROLE then
    if self.showModel == false then
      return
    end
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_ROLE, {
      self.roleId
    })
  elseif self.m_roleType == RoleType.NPC then
    showSelectEffect = true
    if self.roleId == nil then
      return
    end
    local npcid = self.roleId:ToNumber()
    local extraInfo = self.extraInfo
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcid, extraInfo})
  elseif self.m_roleType == RoleType.MONSTER then
    showSelectEffect = true
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_MONSTER, {
      self.roleId:ToNumber()
    })
  elseif self.m_roleType == RoleType.PET then
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_PET, {
      self.roleId
    })
  elseif self.m_roleType == RoleType.DOUDOU then
    showSelectEffect = true
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_DOUDOU, {
      self.roleId:ToNumber()
    })
  elseif self.m_roleType == RoleType.CHILD then
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_CHILD, {
      self.roleId,
      self.extraInfo
    })
  elseif self.m_roleType == RoleType.POKEMON then
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_POKEMON, {
      self.roleId
    })
  end
  if not showSelectEffect then
    return
  end
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroMgr.selectEffect then
    ECFxMan.Instance():Stop(heroMgr.selectEffect)
  end
  local effres = GetEffectRes(702020020)
  if effres then
    local playObject = self.mount and self.mount.m_model or self.m_model
    heroMgr.selectEffect = ECFxMan.Instance():PlayAsChild(effres.path, playObject, EC.Vector3.new(0, 0, 0), Quaternion.identity, -1, false, ClientDef_Layer.Player)
    heroMgr.selectEffectTime = 3
  end
end
def.override().OnLoadGameObject = function(self)
  ECRoleModel.OnLoadGameObject(self)
  if self.m_model == nil then
    warn("ECPlayer OnLoadGameObject: m_model is nil for: ", self.mModelId)
    return
  end
  if self.attachModelInfo then
    local modelInfo = self.attachModelInfo
    self.attachModelInfo = nil
    SetModelExtra(self, modelInfo)
  end
  self:SetOrnament(self.showOrnament)
  self:CreateHUD()
  if self.mECWingComponent ~= nil then
    self.mECWingComponent:Update(0)
  end
  if self.teamIcon then
    self:ResetTeamIcon()
  end
end
def.method().CreateHUD = function(self)
  local noName = false
  if self.m_uiNameHandle then
    local follow = self.m_uiNameHandle:GetComponent("HUDFollowTarget")
    follow.target = self.m_model.transform
  else
    noName = true
  end
  local noTop = false
  if self.m_topIcon then
    local follow = self.m_topIcon:GetComponent("HUDFollowTarget")
    follow.target = self.m_model.transform
  else
    noTop = true
  end
  if noName or noTop then
    GameUtil.AddGlobalTimer(0, true, function()
      local ECPate = require("GUI.ECPate")
      local pate = ECPate.new()
      if self.m_uiNameHandle == nil then
        pate:CreateNameBoard(self)
      end
      if self.m_topIcon == nil then
        pate:CreateTopBoard(self, nil)
      end
    end)
  end
end
def.method("=>", "userdata").GetOrAddMovePathComp = function(self)
  local comp = self.movePathComp
  if comp then
    return comp
  end
  if self.m_node2d == nil then
    return nil
  end
  comp = self.m_node2d:AddComponent("CommonMovePath")
  self.movePathComp = comp
  return comp
end
def.method().DestroyMovePathComp = function(self)
  if self.movePathComp then
    Object.Destroy(self.movePathComp)
    self.movePathComp = nil
  end
end
def.method("boolean").SetMoveAnim = function(self, v)
  if self.m_model == nil then
    return
  end
  if self.m_model.isnil then
    return
  end
  local movePath = self.movePathComp
  if movePath then
    movePath.IsAnimate = v
  end
end
def.method("boolean").Pause = function(self, v)
  if self.m_model == nil then
    return
  end
  if self.m_model.isnil then
    return
  end
  local movePath = self.movePathComp
  if movePath then
    movePath:Pause(v)
  end
  self:OnRunPause(v)
end
def.method("string", "number", "string", "number").AddChildEffect = function(self, effectPath, part, boneName, offsetH)
  if self.childEffects == nil then
    self.childEffects = {}
  end
  local eff_fx = self.childEffects[effectPath]
  if eff_fx then
    return
  end
  local effect_data = {
    effectPath = effectPath,
    part = part,
    boneName = boneName,
    offsetH = offsetH
  }
  self.childEffects[effectPath] = effect_data
  self:LoadChildEffect(effect_data)
end
def.method("table").LoadChildEffect = function(self, effectData)
  if effectData == nil then
    return
  end
  local function DoAddChildEffect()
    if self.m_model == nil or self.m_model.isnil or self.childEffects == nil then
      return
    end
    local effect_data = self.childEffects[effectData.effectPath]
    if effect_data == nil then
      return
    end
    local mountOffset = 0
    if self.mount and self.mount.m_model then
      mountOffset = MOUNT_TOPICON_OFFSET
    end
    local offsetY = effectData.offsetH - mountOffset
    local boxCollider = self.m_model:GetComponent("BoxCollider")
    local box_height = 0
    if boxCollider ~= nil then
      local size = boxCollider:get_size()
      box_height = size.y
    end
    local parent = self.m_model
    if effectData.part == BODY_PART.HEAD then
      offsetY = offsetY + box_height
    elseif effectData.part == BODY_PART.BODY then
      offsetY = offsetY + box_height / 2
    elseif effectData.part == BODY_PART.BONE then
      offsetY = effectData.offsetH
      parent = self.m_model:FindChild(effectData.boneName)
    end
    local fx = effect_data.fx
    if fx and not fx.isnil then
      ECFxMan.Instance():Stop(fx)
      fx = nil
    end
    fx = ECFxMan.Instance():PlayAsChild(effectData.effectPath, parent, EC.Vector3.new(0, offsetY, 0), Quaternion.identity, -1, false, self.defaultLayer)
    if fx then
      fx:GetComponent("FxOne").stable = true
      effect_data.fx = fx
    end
  end
  if self.m_model == nil and self:IsInLoading() then
    self:AddOnLoadCallback("add_child_effect_" .. effectData.effectPath, DoAddChildEffect)
  else
    DoAddChildEffect()
  end
end
def.method("string").StopChildEffect = function(self, effectPath)
  if self.childEffects == nil then
    return
  end
  local effect_data = self.childEffects[effectPath]
  if effect_data == nil then
    return
  end
  local fx = effect_data.fx
  if fx and not fx.isnil then
    ECFxMan.Instance():Stop(fx)
  end
  self.childEffects[effectPath] = nil
end
def.method().RemoveAllChildEffect = function(self)
  if self.childEffects == nil then
    return
  end
  for k, v in pairs(self.childEffects) do
    if v.fx and not v.fx.isnil then
      ECFxMan.Instance():Stop(v.fx)
    end
  end
  self.childEffects = nil
end
def.method().ReloadAllChildEffect = function(self)
  if self.childEffects == nil then
    return
  end
  for k, v in pairs(self.childEffects) do
    self:LoadChildEffect(v)
  end
end
def.method("number", "number").AddTop3DEffect = function(self, effid, offsetH)
  local res = _G.GetEffectRes(effid)
  if res == nil then
    return
  end
  self:AddChildEffect(res.path, BODY_PART.HEAD, "", offsetH)
end
def.method("number").RemoveTop3DEffect = function(self, effid)
  local res = _G.GetEffectRes(effid)
  if res == nil then
    return
  end
  self:StopChildEffect(res.path)
end
def.method("boolean").ResetTopEffects = function(self, isOnMount)
  if self.childEffects == nil then
    return
  end
  local offset = MOUNT_TOPICON_OFFSET
  if isOnMount then
    offset = -MOUNT_TOPICON_OFFSET
  end
  for k, v in pairs(self.childEffects) do
    if v.fx and not v.fx.isnil then
      local lastpos = v.fx.localPosition
      v.fx.localPosition = lastpos + EC.Vector3.new(0, offset, 0)
    end
  end
end
def.virtual("string", "number", "=>", "userdata").AddEffectWithRotation = function(self, effectPath, part)
  local pos
  local model = self.m_model
  if model and not model.isnil then
    pos = model.localPosition
    local bc = self.m_model:GetComponent("BoxCollider")
    if bc then
      local height = bc.size.y
      pos.y = pos.y + height / 2
    end
  else
    pos = Map2DPosTo3D(self.m_node2d.localPosition.x, world_height - self.m_node2d.localPosition.y)
  end
  if pos == nil then
    warn("effect pos is nil: " .. effectPath)
    return nil
  end
  return ECFxMan.Instance():Play(effectPath, pos, self.m_model.localRotation, -1, false, self.defaultLayer)
end
def.virtual("string", "number", "=>", "userdata").AddEffect = function(self, effectPath, part)
  local pos = Map2DPosTo3D(self.m_node2d.localPosition.x, world_height - self.m_node2d.localPosition.y)
  if self.m_model and not self.m_model.isnil then
    local bc = self.m_model:GetComponent("BoxCollider")
    if bc then
      local height = bc.size.y
      if part == BODY_PART.HEAD then
        pos.y = pos.y + height + 0.5
      elseif part == BODY_PART.BODY then
        pos.y = pos.y + height / 2
      end
    end
  end
  return ECFxMan.Instance():Play(effectPath, pos, Quaternion.identity, -1, false, self.defaultLayer)
end
def.virtual("string", "number", "=>", "userdata").AddEffectWithOffset = function(self, effectPath, offset)
  if self.m_model == nil then
    return nil
  end
  if self.m_model.isnil then
    return nil
  end
  local pos = self.m_node2d.localPosition
  pos.y = pos.y + offset
  local effpos = Map2DPosTo3D(pos.x, world_height - pos.y)
  return ECFxMan.Instance():Play(effectPath, effpos, Quaternion.identity, -1, false, self.defaultLayer)
end
def.method("string").AddTitleEffect = function(self, resourcePath)
  if self._currTitleEffectPath == resourcePath then
    return
  end
  if self._currTitleEffectPath and self._currTitleEffectPath ~= "" then
    self:RemoveEffect(self._currTitleEffectPath)
    self._currTitleEffectPath = ""
  end
  local function DoAddEffect()
    local boxCollider = self.m_model:GetComponent("BoxCollider")
    local mountOffset = 0
    if self.mount and self.mount:IsObjLoaded() then
      mountOffset = -MOUNT_TOPICON_OFFSET
    end
    if boxCollider ~= nil then
      local size = boxCollider:get_size()
      self:AttachEffect(resourcePath, size.y + 0.4 + mountOffset)
    else
      self:AttachEffect(resourcePath, 1.6 + mountOffset)
    end
  end
  self._currTitleEffectPath = resourcePath
  if self.m_model == nil or self.m_model:get_isnil() then
    self:AddOnLoadCallback("add_title_effect", DoAddEffect)
  else
    DoAddEffect()
  end
end
local attach_effect_pos = EC.Vector3.new(0, 0, 0)
def.method("string", "number").AttachEffect = function(self, effectPath, offsetY)
  if self.m_attachedEffects and self.m_attachedEffects[effectPath] then
    return
  end
  local effparent = self.m_topIcon and self.m_topIcon:FindDirect("Pate/Img_Effect")
  local eff
  if effparent then
    attach_effect_pos.y = offsetY
    eff = ECFxMan.Instance():PlayAsChild(effectPath, effparent, attach_effect_pos, Quaternion.identity, -1, false, ClientDef_Layer.PateText)
  end
  if eff then
    eff.localScale = EC.Vector3.new(64, 64, 1)
    eff:GetComponent("FxOne").stable = true
    if self.m_attachedEffects == nil then
      self.m_attachedEffects = {}
    end
    self.m_attachedEffects[effectPath] = eff
    eff:SetActive(self.m_visible)
  end
end
def.method("dynamic").RemoveEffect = function(self, key)
  if self.m_attachedEffects == nil then
    return
  end
  local eff = self.m_attachedEffects[key]
  if eff then
    ECFxMan.Instance():Stop(eff)
    self.m_attachedEffects[key] = nil
  end
end
def.method().RemoveAllEffect = function(self)
  if self.m_attachedEffects == nil then
    return
  end
  for k, v in pairs(self.m_attachedEffects) do
    ECFxMan.Instance():Stop(v)
  end
  self.m_attachedEffects = nil
end
def.override("=>", "number").GetModelLength = function(self)
  if self:IsOnMount() then
    return self.mount:GetModelLength()
  end
  return ECModel.GetModelLength(self)
end
def.method("string", "userdata").SetHeadText = function(self, text, color)
  if self.m_model == nil or self.m_model.isnil then
    if self:IsInLoading() then
      self:AddOnLoadCallback("headtext", function()
        self:SetHeadText(text, color)
      end)
    else
      return
    end
  end
  if self.m_topIcon == nil or self.m_topIcon.isnil then
    local ECPate = require("GUI.ECPate")
    local pate = ECPate.new()
    pate:CreateTopBoard(self, function()
      self:SetHeadText(text, color)
    end)
  else
    local label = self.m_topIcon:FindDirect("Pate/Label_Info")
    if label == nil then
      return
    end
    if color then
      local r = color.r * 255
      local g = color.g * 255
      local b = color.b * 255
      label:GetComponent("UILabel").text = string.format("[%02x%02x%02x]%s[-]", r, g, b, text)
    else
      label:GetComponent("UILabel").text = text
    end
  end
end
def.virtual("number").SetTeamNum = function(self, num)
  if self.m_topIcon then
    local label = self.m_topIcon:FindDirect("Pate/Label_Info")
    if label == nil then
      return
    end
    if num > 0 then
      label:GetComponent("UILabel").text = string.format("(%d/%d)", num, Team_Max_Size)
    else
      label:GetComponent("UILabel").text = ""
    end
  end
end
def.method().ResetTeamNum = function(self)
  local num = 0
  if self.teamId then
    num = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetTeamSize(self.teamId)
  end
  self:SetTeamNum(num)
end
def.virtual("number").SetTitleIcon = function(self, iconId)
  self.titleIcon = iconId
  if self.m_topIcon then
    do
      local icon = self.m_topIcon:FindDirect("Pate/Img_Chengwei")
      if icon == nil then
        return
      end
      if iconId == 0 then
        if self._currTitleEffectPath and self._currTitleEffectPath ~= "" then
          self:RemoveOnLoadCallback("add_title_effect")
          self:RemoveEffect(self._currTitleEffectPath)
          self._currTitleEffectPath = ""
        end
        icon:SetActive(false)
        self:ResetTopIcons()
        return
      end
      icon:SetActive(true)
      self:ResetTopIcons()
      local uiTexture = icon:GetComponent("UITexture")
      local resourcePath, resourceType = GetIconPath(self.titleIcon)
      if resourcePath == "" then
        warn(" resourcePath == \"\" iconId = " .. self.titleIcon)
      end
      if resourceType == 1 then
        self:AddTitleEffect(resourcePath)
        return
      end
      GameUtil.AsyncLoad(resourcePath, function(tex)
        if not tex then
          return
        end
        if icon and not icon:get_isnil() then
          local widget = icon:GetComponent("UIWidget")
          widget.width = tex.width
          widget.height = tex.height
        end
        if uiTexture and not uiTexture:get_isnil() then
          uiTexture.mainTexture = tex
        end
      end)
    end
  end
end
def.virtual("number").SetFlagIcon = function(self, iconId)
  self.flagIcon = iconId
  if self.m_topIcon then
    local icon = self.m_topIcon:FindDirect("Pate/Img_Sign")
    if icon == nil then
      return
    end
    if iconId == 0 then
      icon:SetActive(false)
      return
    end
    icon:SetActive(true)
    local texture = icon:GetComponent("UITexture")
    require("GUI.GUIUtils").FillIcon(texture, iconId)
    self:ResetTopIcons()
  end
end
local ICON_POS = EC.Vector3.new(0, 0, 0)
local PATE_POS = EC.Vector3.new(0, 0, 0)
local TEAM_LABEL_OFFSET = EC.Vector3.new(0, -10, 0)
def.method().ResetTopIcons = function(self)
  if self.m_topIcon == nil then
    return
  end
  local pate = self.m_topIcon:FindDirect("Pate")
  local title = pate:FindDirect("Img_Chengwei")
  local icon = pate:FindDirect("Img_Sign")
  local effComtainer = pate:FindDirect("Img_Effect")
  local teamlabel = pate:FindDirect("Label_Info")
  local widgetTitle = title:GetComponent("UIWidget")
  local widgetIcon = icon:GetComponent("UIWidget")
  local isSit = self:HasAnimClip(ActionName.SitStand)
  PATE_POS.x = pate.localPosition.x
  PATE_POS.z = pate.localPosition.z
  if self.mount and self.mount:IsObjLoaded() and not isSit then
    PATE_POS.y = 36 * pate.localScale.y
  else
    PATE_POS.y = 0
  end
  pate.localPosition = PATE_POS
  if FlagPosList == nil then
    FlagPosList = {
      title.localPosition,
      icon.localPosition,
      teamlabel.localPosition
    }
  end
  effComtainer.localPosition = title.localPosition
  if 0 < self.titleIcon or 0 < effComtainer.childCount then
    teamlabel.localPosition = FlagPosList[2] + TEAM_LABEL_OFFSET
  else
    teamlabel.localPosition = FlagPosList[3] + TEAM_LABEL_OFFSET
  end
  if self.teamIcon and not self.teamIcon.isnil then
    local box = self.m_model and self.m_model:GetComponent("BoxCollider")
    local h = box and box.size.y or 1.6
    if 0 < self.titleIcon then
      h = h + 0.7
    end
    if self.mount and self.mount:IsObjLoaded() and isSit then
      h = h - MOUNT_TOPICON_OFFSET
    end
    ICON_POS.y = h + 0.4
    self.teamIcon.localPosition = ICON_POS
  end
  if self.battleIcon and not self.battleIcon.isnil then
    local box = self.m_model and self.m_model:GetComponent("BoxCollider")
    local h = box and box.size.y or 1.6
    local offset = h + 0.2
    if self.teamIcon then
      offset = h + 1.4
    elseif 0 < self.titleIcon then
      offset = h + 0.7
    end
    if self.mount and self.mount:IsObjLoaded() and isSit then
      offset = offset - MOUNT_TOPICON_OFFSET
    end
    ICON_POS.y = offset
    self.battleIcon.localPosition = ICON_POS
  end
end
def.virtual("string").AddTopEffect = function(self, respath)
  local effname = respath
  local effComtainer = self.m_topIcon:FindDirect("Pate/Img_Effect")
  if effComtainer.childCount > 0 then
    local effInst = effComtainer:GetChild(0)
    if effInst.name == effname then
      return
    else
      effInst:Destroy()
    end
  end
  local function OnLoadEffect(obj)
    if loadingRes[respath] == nil then
      return
    end
    local eff = Object.Instantiate(obj, "GameObject")
    eff:SetLayer(ClientDef_Layer.PateText, true)
    eff.name = effname
    eff.parent = effComtainer
    eff.localPosition = EC.Vector3.zero
    eff.localScale = EC.Vector3.one
    eff:SetActive(self.m_visible and self.showModel and self.showPart)
    self:ResetTopIcons()
    loadingRes[respath] = nil
  end
  loadingRes[respath] = 1
  GameUtil.AsyncLoad(respath, OnLoadEffect)
end
local IconScale = EC.Vector3.new(2, 2, 2)
def.method().ResetTeamIcon = function(self)
  if self.teamIcon and not self.teamIcon.isnil then
    if self:IsDestroyed() then
      self.teamIcon:Destroy()
      self.teamIcon = nil
      return
    end
    self.teamIcon.parent = self.m_model
    self.teamIcon.localScale = IconScale
    self.teamIcon.localRotation = Quaternion.identity
    self:ResetTopIcons()
  end
end
def.method().ResetBattleIcon = function(self)
  if self.battleIcon and not self.battleIcon.isnil then
    if self:IsDestroyed() or not self:IsInState(RoleState.BATTLE) and not self:IsInState(RoleState.WATCH) then
      self.battleIcon:Destroy()
      self.battleIcon = nil
      return
    end
    self.battleIcon.parent = self.m_model
    self.battleIcon.localScale = IconScale
    self:ResetTopIcons()
  end
end
def.virtual("string").SetTeamIcon = function(self, respath)
  if self.teamIcon then
    if self.teamIcon.name == respath then
      return
    end
    self.teamIcon:Destroy()
    self.teamIcon = nil
  end
  if respath == nil or respath == "" then
    self:SetTeamNum(0)
    return
  end
  local function OnLoadEffect(obj)
    if self.teamIcon then
      self.teamIcon:Destroy()
      self.teamIcon = nil
    end
    if self:IsDestroyed() or self.teamId == nil or self:IsInState(RoleState.FOLLOW) then
      return
    end
    local eff = Object.Instantiate(obj, "GameObject")
    eff:SetLayer(self.defaultLayer)
    eff.name = respath
    eff:SetActive(self.m_visible and self.showModel)
    self.teamIcon = eff
    self:SetTeamNum(gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetTeamSize(self.teamId))
    self:ResetTeamIcon()
  end
  if self.m_model == nil and self:IsInLoading() then
    self:AddOnLoadCallback("SetTeamIcon", function()
      GameUtil.AsyncLoad(respath, OnLoadEffect)
    end)
  else
    GameUtil.AsyncLoad(respath, OnLoadEffect)
  end
end
def.virtual("string").SetBattleIcon = function(self, respath)
  self:EndInteraction()
  if self.battleIcon and not self.battleIcon.isnil then
    if self.battleIcon.name == respath then
      return
    end
    self.battleIcon:Destroy()
    self.battleIcon = nil
  end
  if respath == nil or respath == "" then
    return
  end
  local function OnLoadEffect(obj)
    if self.battleIcon then
      self.battleIcon:Destroy()
    end
    if self:IsDestroyed() or not self:IsInState(RoleState.BATTLE) and not self:IsInState(RoleState.WATCH) then
      return
    end
    local eff = Object.Instantiate(obj, "GameObject")
    eff:SetLayer(self.defaultLayer)
    eff.name = respath
    eff.parent = self.m_model
    eff:SetActive(self.m_visible and self.showModel)
    self.battleIcon = eff
    self:ResetBattleIcon()
  end
  if self.m_model == nil and self:IsInLoading() then
    self:AddOnLoadCallback("SetBattleIcon", function()
      GameUtil.AsyncLoad(respath, OnLoadEffect)
    end)
  else
    GameUtil.AsyncLoad(respath, OnLoadEffect)
  end
end
def.virtual("string").RemoveTopEffect = function(self, effname)
  loadingRes[effname] = nil
  if self.m_topIcon == nil then
    return
  end
  local effComtainer = self.m_topIcon:FindDirect("Pate/Img_Effect")
  if effComtainer.childCount > 0 then
    local effInst = effComtainer:GetChild(0)
    if effInst.name == effname then
      effInst:Destroy()
    end
  end
end
def.override("number").SetMagicMark = function(self, markId)
  if self:IsOnMount() then
    self.mount:SetMagicMark(markId)
  elseif self:IsInState(RoleState.PASSENGER) then
    local master = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetPassengerMaster(self)
    if master and master.mount then
      master.mount:SetMagicMarkForRole(markId, self)
    end
  else
    ECRoleModel.SetMagicMark(self, markId)
    self:SetMagicMarkVisible(not self:IsInState(RoleState.FLY))
  end
end
def.override("boolean").SetMagicMarkVisible = function(self, visible)
  if self:IsOnMount() then
    self.mount:SetMagicMarkVisible(visible)
  elseif self:IsInState(RoleState.PASSENGER) then
    local master = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetPassengerMaster(self)
    if master and master.mount then
      master.mount:SetMagicMarkVisibleForRole(visible, self)
    end
  else
    ECRoleModel.SetMagicMarkVisible(self, visible)
  end
end
def.virtual("table").AddPet = function(self, pet)
  self.pet = pet
end
def.virtual("table").AddEscortTarget = function(self, escortTarget)
  self.escortTarget = escortTarget
end
def.virtual().RemovePet = function(self)
  if self.pet then
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):RoleStopFollow(self.pet)
    self.pet:Destroy()
    self.pet = nil
  end
end
def.virtual().RemoveEscortTarget = function(self)
  if self.escortTarget then
    self:Detach("hug")
    self.escortTarget:Destroy()
    self.escortTarget = nil
  end
end
def.virtual("=>", "table").GetPet = function(self)
  return self.pet
end
def.virtual("=>", "table").GetEscortTarget = function(self)
  return self.escortTarget
end
local t_pos = EC.Vector3.new()
def.override("number", "number").SetPos = function(self, x, y)
  if self.m_node2d == nil then
    return
  end
  if self.mount then
    Set2DPosTo3D(x, world_height - y, t_pos)
    self.mount:Set3DPos(t_pos)
    self.m_node2d.localPosition = t_pos:Assign(x, y, 0)
  else
    ECModel.SetPos(self, x, y)
  end
end
def.override("number", "number").Set2DPos = function(self, x, y)
  if self.m_node2d == nil then
    return
  end
  if self.mount then
    self.mount:Set2DPos(x, y)
    ECModel.Set2DPos(self, x, y)
  else
    ECModel.Set2DPos(self, x, y)
  end
end
def.override("number").SetDir = function(self, ang)
  if self.feijianModel then
    ECModel.SetDir(self.feijianModel, ang)
    self.m_ang = ang
  elseif self:IsOnMount() then
    ECModel.SetDir(self.mount, ang)
    self.m_ang = ang
  else
    ECModel.SetDir(self, ang)
  end
end
def.override("=>", "number").GetDir = function(self)
  if self:IsOnMount() then
    return ECModel.GetDir(self.mount)
  else
    return ECModel.GetDir(self)
  end
end
def.override("=>", "table").Get3DPos = function(self)
  if self.feijianModel then
    if self.feijianModel:IsLoaded() then
      return ECModel.Get3DPos(self.feijianModel)
    else
      return ECModel.Get3DPos(self)
    end
  elseif self.mount then
    if self.mount:IsLoaded() then
      return ECModel.Get3DPos(self.mount)
    else
      return ECModel.Get3DPos(self)
    end
  else
    return ECModel.Get3DPos(self)
  end
end
def.override("table").Set3DPos = function(self, pos)
  if self.feijianModel then
    local height = 3
    self.feijianModel:Set3DPos(EC.Vector3.new(pos.x, height, pos.z))
  elseif self:IsOnMount() then
    self.mount:Set3DPos(pos)
  else
    ECModel.Set3DPos(self, pos)
  end
end
def.override("table").SetForward = function(self, forward)
  if self.feijianModel then
    return ECModel.SetForward(self.feijianModel, forward)
  elseif self.mount then
    return ECModel.SetForward(self.mount, forward)
  else
    return ECModel.SetForward(self, forward)
  end
end
def.virtual("number", "number").LookAt = function(self, x, y)
  local pos = self:GetPos()
  local xt = x - pos.x
  local yt = pos.y - y
  if xt == 0 and yt == 0 then
    return
  end
  if xt == 0 then
    if yt > 0 then
      self:SetDir(0)
      return
    end
    self:SetDir(180)
    return
  end
  if yt == 0 then
    if xt > 0 then
      self:SetDir(90)
      return
    end
    self:SetDir(-90)
    return
  end
  local radian = math.atan2(xt, yt)
  local degree = radian / math.pi * 180
  self:SetDir(degree)
end
def.method("table").LookAtTarget = function(self, target)
  local m2dPos = self:GetPos()
  local t2dPos = target:GetPos()
  local m3dPos = EC.Vector3.new()
  local t3dPos = EC.Vector3.new()
  if m2dPos and t2dPos then
    Set2DPosTo3D(m2dPos.x, world_height - m2dPos.y, m3dPos)
    Set2DPosTo3D(t2dPos.x, world_height - t2dPos.y, t3dPos)
  else
    return
  end
  local dir = t3dPos - m3dPos
  dir:Normalize()
  self:SetForward(dir)
end
def.override("number").SetWeaponColor = function(self, lv)
  SetModelWeaponColor(self, lv)
end
def.method("number").CheckIdle = function(self, tick)
  if self.idleTime < -1 then
    return
  end
  local model = self.m_model
  if model == nil then
    return
  end
  if self.movePath == nil then
    if self.idleTime == -1 then
      self:SetIdleTime()
    end
  else
    self.idleTime = -1
  end
end
def.method("number").UpdateIdleStatus = function(self, tick)
  if self.idleTime <= 0 then
    return
  end
  self.idleTime = self.idleTime - tick
  if self.idleTime <= 0 then
    self:PlayIdle()
    self:SetIdleTime()
  end
end
def.virtual().PlayIdle = function(self)
  if not self.enableIdleAct then
    self.idleTime = -2
    return
  end
  if self.movePath == nil and not self.mount and self:HasAnimClip(ActionName.Idle1) and not self:ContainsState(RoleState.FLY, RoleState.BEHUG, RoleState.SINGLEBATTLE_DEATH, RoleState.PASSENGER) then
    local commonMove = self:GetOrAddMovePathComp()
    commonMove:set_enabled(false)
    self:PlayAnim(ActionName.Idle1, function()
      self:CrossFade(ActionName.Stand, 0.1)
      if self.mECPartComponent then
        self.mECPartComponent:PlayAnimation(ActionName.Stand, ActionName.Stand)
      end
    end)
    if self.mECPartComponent then
      self.mECPartComponent:PlayAnimation(ActionName.Idle1, ActionName.Stand)
    end
  end
end
def.method().SetIdleTime = function(self)
  self.idleTime = 10 + math.random(20)
end
def.method("string").PlayAnimationThenStand = function(self, aniname)
  local commonMove = self:GetOrAddMovePathComp()
  commonMove:set_enabled(false)
  self:PlayAnim(aniname, function()
    self:SetStance()
  end)
end
def.virtual("=>", ECPlayer).DuplicatePlayer = function(self)
  local ret = ECPlayer()
  ret.m_roleType = self.m_roleType
  ret:Init(self.mModelId)
  local m = Object.Instantiate(self.m_model, "GameObject")
  ret.m_model = m
  ret.m_asset = GameUtil.CloneUserData(self.m_asset)
  ret.m_ani = m:GetComponentInChildren("Animation")
  ret.m_status = 0
  ret.m_resName = self.m_resName
  ret.m_renderers = m:GetRenderersInChildren()
  ret.m_visible = true
  GameUtil.AddECObjectComponent(ret, ret.m_model, false)
  m:SetLayer(self.defaultLayer)
  ret.m_node2d.localPosition = self.m_node2d.localPosition
  m.localPosition = self.m_model.localPosition
  m.localRotation = self.m_model.localRotation
  ret:Play("Stand_c")
  ret.m_ang = self.m_ang
  ret.defaultParentNode = self.defaultParentNode
  ret.parentNode = ret.defaultParentNode
  if ret.parentNode then
    ret.m_model.transform.parent = ret.parentNode.transform
    ret.m_node2d.transform.parent = ret.parentNode.transform
  end
  ret.m_Name = self.m_Name
  ret.m_uNameColor = self.m_uNameColor
  ret.mShadowObj = ret.m_model:FindDirect("characterShadow")
  if ret.mShadowObj then
    ret.mShadowObj.transform.localScale = EC.Vector3.one
    ret.mShadowObj.transform.localPosition = EC.Vector3.zero
    ret.mShadowObj:SetActive(true)
  end
  return ret
end
def.override().SetPate = function(self)
  if self.m_topIcon then
    local follow = self.m_topIcon:GetComponent("HUDFollowTarget")
    local offset = self:GetBoxHeight() + 0.4
    if self.mount and self.mount:IsObjLoaded() then
      offset = offset - MOUNT_TOPICON_OFFSET
    end
    local scale = 1
    if self:IsInState(RoleState.FLY) then
      scale = 1.5
    end
    follow.offset = t_vec:Assign(0, offset * scale, 0)
    if self.teamId and gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsTeamLeader(self.roleId, self.teamId) then
      self:SetTeamNum(gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetTeamSize(self.teamId))
    end
  end
end
def.method("=>", "boolean").SetToGround = function(self)
  self:EndInteraction()
  if self:IsInState(RoleState.FLY) or self.flyState ~= 0 then
    if self.m_model == nil or self.m_model.isnil or self.m_node2d == nil then
      return false
    end
    if self:IsInState(RoleState.BEHUG) then
      return false
    end
    self:RemoveState(RoleState.FLY)
    self:RemoveFlyComponent()
    self:SetModelIsRender(true)
    if self:IsTouchable() then
      self:SetCanClick(true)
    end
    if self:IsMe() then
      require("Main.ECGame").Instance():ToGroundLayer()
      FlyModule.Instance():StopCloud("fly")
      Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, nil)
    end
    self.flyState = 0
    self.flyPoint = nil
    self:StopAnimAndCallback()
    self.runpathCallback = nil
    self:SetAnimCullingType(1)
    self:SetLayer(ClientDef_Layer.Player)
    if self.mECFabaoComponent then
      self.mECFabaoComponent:FlyDown()
      self.mECFabaoComponent:SetLayer(ClientDef_Layer.Player)
    end
    if self.feijianModel then
      local roleAttach = self.feijianModel:GetAttach(FlyModule.FlyTag)
      if roleAttach ~= nil then
        self.feijianModel:Detach(FlyModule.FlyTag)
      end
      self.feijianModel:Destroy()
      self.feijianModel = nil
    end
    if self.defaultParentNode then
      self.m_model.transform.parent = self.defaultParentNode.transform
    end
    ECFxMan.Instance():Stop(self.feijianEffect)
    self.feijianEffect = nil
    if self.mount then
      self:ReturnMount()
    else
      local curX = self.m_node2d.localPosition.x
      local curY = self.m_node2d.localPosition.y
      Set2DPosTo3D(curX, world_height - curY, t_pos)
      self.m_model.localPosition = t_pos
      self.m_model.localScale = Model_Default_Scale
      local commonMove = self:GetOrAddMovePathComp()
      commonMove:set_enabled(true)
      commonMove:set_IsAnimate(true)
      commonMove:set_MoveAnimationName(ActionName.Run)
      commonMove:set_StandAnimationName(ActionName.Stand)
      self.nameOffset = default_name_offset
      if self.m_uiNameHandle then
        self.m_uiNameHandle:GetComponent("HUDFollowTarget").offset = EC.Vector3.new(0, self.nameOffset, 0)
      end
      if self.mShadowObj and not self.mShadowObj.isnil then
        self.mShadowObj:SetActive(true)
      end
      self:Play(ActionName.Stand)
    end
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ResetTeamFollowList(self.teamId, false)
    return true
  else
    return false
  end
end
def.method("table", "number", "function").RunPath = function(self, path, speed, cb)
  if self:IsInState(RoleState.BEHUG) or self:IsInState(RoleState.PASSENGER) then
    return
  end
  if self.m_model == nil and self:IsInLoading() then
    self.movePath = path
    self.pathIdx = #path
    self.runpathCallback = cb
    self:AddOnLoadCallback("runpath", function()
      self:RunPath(self.movePath, speed, self.runpathCallback)
    end)
    return
  end
  self:EndInteraction()
  self:SetToGround()
  local commonMove = self:GetOrAddMovePathComp()
  if commonMove == nil then
    return
  end
  commonMove:set_IsAnimate(true)
  if self.mount and self.mount:IsDestroyed() then
    self:ReturnMount()
  end
  if self.mount ~= nil and self.mount.m_model == nil and self.mount:IsInLoading() then
    self.movePath = path
    self.pathIdx = #path
    self.runpathCallback = cb
    self.mount:AddOnLoadCallback("runpath", function()
      self:RunPath(self.movePath, speed, self.runpathCallback)
    end)
    return
  end
  self:HideBackup()
  if self.mount then
    if path ~= nil and #path > 0 then
      self:SetState(RoleState.RUN)
      self.mount:Play(commonMove:get_MoveAnimationName())
      self.mount:StartRun()
      self:PlayWithDefault(self.mount:GetRunActionName(1), ActionName.Stand)
    end
    self:_RunPath(path, speed, self.mount.m_model, cb)
  else
    if path ~= nil and #path > 0 then
      self:SetState(RoleState.RUN)
      self:Play(commonMove:get_MoveAnimationName())
    end
    self:_RunPath(path, speed, self.m_model, cb)
  end
end
def.method("table", "number", "userdata", "function")._RunPath = function(self, path, speed, model, cb)
  if path == nil or #path == 0 or self.m_node2d == nil or model == nil or model.isnil then
    return
  end
  self.runpathCallback = cb
  local function OnEnd()
    self:OnMoveToKeyPoint()
    if self.pathIdx == 0 then
      local excb = self.runpathCallback
      self.runpathCallback = nil
      self:OnRunEnd(excb)
    end
  end
  local movePath = self:GetOrAddMovePathComp()
  self.pathIdx = #path
  movePath:set_enabled(true)
  movePath:Set2dTo3dCo(1 / math.sin(cam_3d_rad))
  movePath:SetWorldHeight(world_height)
  movePath:ClearPath()
  for i, v in ipairs(path) do
    movePath:AddPathNode(v.x, v.y, 0)
  end
  movePath:RegMoveEndFunc(OnEnd)
  self:OnRunBegin()
  movePath:BeginPath(speed, model)
  self.movePath = path
  if self.mECPartComponent then
    self.mECPartComponent:PlayAnimation(ActionName.Stand, ActionName.Stand)
  end
  self.idleTime = -1
  self:ShowWeapon(true)
  require("Main.Chat.ui.DlgAction").Instance():StopActionEffect(self)
end
def.method("=>", "boolean").IsMoving = function(self)
  return self.movePath ~= nil and #self.movePath > 0
end
def.method("boolean").RunByWalk = function(self, walk)
  if walk then
    local commonMove = self:GetOrAddMovePathComp()
    if commonMove then
      local walk_c = "Walk_c"
      commonMove:set_MoveAnimationName(walk_c)
      if self:IsInState(RoleState.RUN) and self:HasAnimClip(walk_c) then
        self:Play(walk_c)
      end
    end
  else
    local commonMove = self:GetOrAddMovePathComp()
    if commonMove then
      commonMove:set_MoveAnimationName(ActionName.Run)
    end
  end
end
def.method().OnMoveToKeyPoint = function(self)
  self.pathIdx = self.pathIdx - 1
end
def.method().OnRunBegin = function(self)
  for k, v in pairs(self.m_callWhenBeginRun) do
    SafeCall(self.m_callWhenBeginRun[k])
  end
end
def.method("boolean").OnRunPause = function(self, pause)
  if pause then
    for k, v in pairs(self.m_callWhenEndRun) do
      SafeCall(self.m_callWhenEndRun[k])
    end
  else
    for k, v in pairs(self.m_callWhenBeginRun) do
      SafeCall(self.m_callWhenBeginRun[k])
    end
  end
end
def.method("function").OnRunEnd = function(self, ex_cb)
  self:RemoveState(RoleState.RUN)
  self.movePath = nil
  self.pathIdx = 0
  for k, v in pairs(self.m_callWhenEndRun) do
    local cb = self.m_callWhenEndRun[k]
    SafeCall(cb)
  end
  if ex_cb then
    SafeCall(ex_cb)
  end
end
def.method().Stop = function(self)
  if self.m_model == nil or self.m_model.isnil then
    self:RemoveOnLoadCallback("runpath")
    return
  end
  if self:IsInState(RoleState.PATROL) then
    warn(string.format("unexpected stop: %s", debug.traceback()))
  end
  if self:IsInState(RoleState.FLY) then
    self:ResetFly()
  else
    local moveComp = self.movePathComp
    if moveComp then
      moveComp:Stop()
      moveComp.enabled = false
    end
  end
  self:OnRunEnd(nil)
end
def.method().Die = function(self)
  if self.m_model == nil or self.m_model.isnil then
    if self:IsInLoading() then
      self:AddOnLoadCallback("die", function()
        self:Die()
      end)
    end
  else
    local commonMove = self:GetOrAddMovePathComp()
    commonMove:set_enabled(false)
    self:LeaveMount()
    self:Play(ActionName.Death1)
  end
end
def.method().Dead = function(self)
  if self.m_model == nil or self.m_model.isnil then
    if self:IsInLoading() then
      self:AddOnLoadCallback("die", function()
        self:Dead()
      end)
    end
  else
    local commonMove = self:GetOrAddMovePathComp()
    commonMove:set_enabled(false)
    self:LeaveMount()
    self:PlayAnimAtTime(ActionName.Death1, 1)
  end
end
def.method().Reborn = function(self)
  if self.m_model == nil or self.m_model.isnil then
    if self:IsInLoading() then
      self:AddOnLoadCallback("die", function()
        self:Reborn()
      end)
    end
  else
    self:ReturnMount()
    self:Play(ActionName.Stand)
  end
end
def.method().Action = function(self)
  if self.m_model == nil or self.m_model.isnil then
    if self:IsInLoading() then
      self:AddOnLoadCallback("action", function()
        self:Action()
      end)
    end
  else
    local commonMove = self:GetOrAddMovePathComp()
    commonMove:set_enabled(false)
    self:LeaveMount()
    self:Play(ActionName.Magic)
  end
end
def.method().CancelAction = function(self)
  if self.m_model == nil or self.m_model.isnil then
    if self:IsInLoading() then
      self:AddOnLoadCallback("die", function()
        self:Reborn()
      end)
    end
  else
    self:ReturnMount()
    self:Play(ActionName.Stand)
  end
end
def.method("number", "string").SetTopButton = function(self, iconId, btnName)
  self:DestroyTopButton("")
  local ECPate = require("GUI.ECPate")
  local pate = ECPate.new()
  pate:CreateTopButton(self, iconId, btnName)
end
def.method("string").DestroyTopButton = function(self, name)
  if self.m_topButton and not self.m_topButton.isnil and (name == "" or self.m_topButton:FindDirect(name)) then
    self.m_topButton:Destroy()
    self.m_topButton = nil
  end
end
def.method("string").OnTopButtonClick = function(self, id)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_TOP_BTN, {
    roleId = self.roleId,
    btn = id
  })
end
def.virtual().SetFlyChange = function(self)
  local isFly = self:IsInState(RoleState.FLY)
  if self.m_topIcon then
    local follow = self.m_topIcon:GetComponent("HUDFollowTarget")
    local offset = self:GetBoxHeight() + 0.4
    local scale = 1
    if isFly then
      scale = 1.5
    end
    follow.offset = t_vec:Assign(0, offset * scale, 0)
  end
  ScaleModelWeaponEffect(self, isFly)
end
def.method("dynamic", "=>", "boolean").IsInState = function(self, s)
  if self.state == nil then
    return false
  end
  if type(s) == "number" then
    return self.state.Check(s)
  elseif type(s) == "table" and s.data and s.Set and s.Unset and s.Check then
    return BitMap.Contains(self.state, s)
  else
    return false
  end
end
def.method("varlist", "=>", "boolean").ContainsState = function(self, ...)
  local states = {
    ...
  }
  for k, v in pairs(states) do
    if self:IsInState(v) then
      return true
    end
  end
  return false
end
def.method("number").SetState = function(self, s)
  if self.state == nil then
    self.state = BitMap.new()
  end
  self.state.Set(s)
  if s == RoleState.FLY then
    self:SetFlyChange()
  end
end
def.method("number").RemoveState = function(self, s)
  if self.state == nil then
    return
  end
  self.state.Unset(s)
  if s == RoleState.FLY then
    self:SetFlyChange()
  end
end
def.method("=>", "table").GetState = function(self)
  if self.state == nil then
    self.state = BitMap.new()
  end
  return self.state
end
def.method("table").LoadModelInfo = function(self, modelInfo)
  if self.m_model then
    SetModelExtra(self, modelInfo)
  else
    self.attachModelInfo = modelInfo
  end
end
def.virtual("=>", "number").GetRoleHeight = function(self)
  if not self.mount and self.m_model and not self.m_model.isnil then
    return self.m_model.position.y
  else
    return 0
  end
end
def.override("=>", "number").GetFeijianId = function(self)
  if self.replaceFeijianId > 0 then
    return self.replaceFeijianId
  end
  if 0 < self.feijianId then
    return self.feijianId
  end
  if self.attachModelInfo and self.attachModelInfo.extraMap then
    return self.attachModelInfo.extraMap[ModelInfo.AIRCRAFT] or 0
  end
  return self.feijianId
end
def.override("=>", "number").GetFeijianColorId = function(self)
  if self.replaceFeijianId > 0 then
    return 0
  end
  if 0 < self.feijianColorId then
    return self.feijianColorId
  end
  if self.attachModelInfo and self.attachModelInfo.extraMap then
    return self.attachModelInfo.extraMap[ModelInfo.AIRCRAFT_COLOR_ID] or 0
  end
  return self.feijianColorId
end
def.method("=>", "table").GetOrCreateFlyStrategy = function(self)
  if self.flyStrategy then
    if self.feijianModel then
      return self.flyStrategy
    end
    if not self.flyStrategy.dirty then
      return self.flyStrategy
    end
    self.flyStrategy:Destroy()
  end
  local feijianId = self:GetFeijianId()
  local feijianColorId = self:GetFeijianColorId()
  self.flyStrategy = FlyModule.Instance():GetFlyStrategy(feijianId, feijianColorId, self)
  return self.flyStrategy
end
def.override("number", "number").SetFeijianId = function(self, feijianId, colorId)
  self.feijianId = feijianId
  self.feijianColorId = colorId
  if self.flyStrategy then
    self.flyStrategy:SetDirty()
  end
end
def.override("number").SetFeijianColorId = function(self, colorId)
  self.feijianColorId = colorId
  if self.flyStrategy then
    self.flyStrategy:SetColorId(self.feijianColorId)
  end
  if self.feijianModel then
    self.feijianModel.colorId = colorId
    local colorcfg = GetModelColorCfg(self.feijianColorId)
    self.feijianModel:SetColoration(colorcfg)
  end
end
def.method("number").SetReplaceFeijianId = function(self, replaceFeijianId)
  self.replaceFeijianId = replaceFeijianId
  if self.flyStrategy then
    self.flyStrategy:SetDirty()
  end
end
def.override("number", "number").SetWeapon = function(self, id, lightLevel)
  SetModelWeapon(self, id, lightLevel)
end
def.override("table").SetWeaponModel = function(self, modelInfo)
  SetModelWeaponAppearance(self, modelInfo)
end
def.override("number", "number").SetWing = function(self, id, dyeId)
  if self.mECWingComponent == nil then
    local ECWingComponent = require("Model.ECWingComponent")
    self.mECWingComponent = ECWingComponent.new(self)
  else
    self.mECWingComponent:SetCharModel(self)
  end
  if self.mECWingComponent then
    if id > 0 then
      self.mECWingComponent:LoadRes(id, dyeId)
      function self.m_callWhenBeginRun.Wing()
        if self.mECWingComponent then
          self.mECWingComponent:Run()
        end
      end
      function self.m_callWhenEndRun.Wing()
        if self.mECWingComponent then
          self.mECWingComponent:Stand()
        end
      end
    else
      self.mECWingComponent:Destroy()
      self.m_callWhenBeginRun.Wing = nil
      self.m_callWhenEndRun.Wing = nil
    end
  end
end
def.override("number").SetFabao = function(self, id)
  if self.mECFabaoComponent == nil then
    local ECFollowComponent = require("Model.ECFollowComponent")
    self.mECFabaoComponent = ECFollowComponent.new(self)
  end
  if self.mECFabaoComponent then
    if id > 0 then
      self.mECFabaoComponent:LoadRes(id)
    else
      self.mECFabaoComponent:Destroy()
    end
  end
end
def.method().LeaveMount = function(self)
  if self.mount then
    local commonMove = self:GetOrAddMovePathComp()
    commonMove:Stop()
    commonMove:set_IsAnimate(false)
    commonMove:set_MoveAnimationName(ActionName.Run)
    commonMove:set_StandAnimationName(ActionName.Stand)
    self:Play(ActionName.Stand)
    self.nameOffset = default_name_offset
    if self.m_uiNameHandle then
      self.m_uiNameHandle:GetComponent("HUDFollowTarget").offset = EC.Vector3.new(0, self.nameOffset, 0)
    end
    local roleAttach = self.mount:GetAttach("Ride")
    if roleAttach ~= nil then
      self.mount:Detach("Ride")
    end
    if self.defaultParentNode then
      self:SetParentNode(self.defaultParentNode)
    end
    if self.mShadowObj and not self.mShadowObj.isnil then
      self.mShadowObj:SetActive(true)
    end
    if self.m_node2d and not self.m_node2d.isnil then
      local pos = EC.Vector3.new()
      local curX = self.m_node2d.localPosition.x
      local curY = self.m_node2d.localPosition.y
      Set2DPosTo3D(curX, world_height - curY, pos)
      local mountRotation = self.mount.m_model and not self.mount.m_model.isnil and self.mount.m_model.localRotation
      if self.m_model and not self.m_model.isnil then
        self.m_model.localScale = Model_Default_Scale
        if mountRotation then
          self.m_model.localRotation = mountRotation
        end
        self.m_model.localPosition = pos
      end
    end
    local magicMarkId = self.mount.magicMarkId
    self.mount:Destroy()
    self.m_callWhenBeginRun.Mount = nil
    self.m_callWhenEndRun.Mount = nil
    if self.m_model then
      self:SetPate()
      self:ResetTopIcons()
      self:ResetTopEffects(false)
    end
    if magicMarkId > 0 then
      self:SetMagicMark(magicMarkId)
    end
  end
end
def.method().ReturnMount = function(self)
  if self:IsInState(RoleState.FLY) or self.flyState ~= 0 or self:IsInState(RoleState.PASSENGER) then
    return
  end
  if self.mount then
    if self.interaction ~= nil then
      self:EndInteraction()
    end
    self:HideBackup()
    local function mountLoaded()
      if self and self.mount and self.mount.m_model and not self.mount.m_model.isnil then
        local roleRotation = self.m_model and not self.m_model.isnil and Quaternion.Euler(EC.Vector3.new(0, self.m_model.localRotation.eulerAngles.y, 0)) or Quaternion.Euler(EC.Vector3.zero)
        self.mount:AttachDriver(self)
        if not self.m_visible then
          self.mount:SetVisible(false)
        end
        if not self.showModel then
          self.mount:SetShowModel(false)
        end
        self.mount:SetTouchable(self:IsTouchable())
        local commonMove = self:GetOrAddMovePathComp()
        commonMove:Stop()
        commonMove:set_IsAnimate(false)
        commonMove:set_MoveAnimationName(ActionName.Run)
        commonMove:set_StandAnimationName(ActionName.Stand)
        commonMove:set_enabled(false)
        self:PlayWithDefault(self.mount:GetStandActionName(1), ActionName.Stand)
        self.mount:Play(ActionName.Stand)
        self.mount:EndRun()
        local ride_action = self.mount:GetStandActionName(1)
        if ride_action == ActionName.Stand then
          MOUNT_TOPICON_OFFSET = 0
        else
          MOUNT_TOPICON_OFFSET = 0.6
        end
        self:SetPate()
        self:ResetTopIcons()
        self:ResetTopEffects(true)
        local modelOffset = self.m_model and self.m_model.position.y or 1
        self.nameOffset = default_name_offset - modelOffset
        if self.m_uiNameHandle then
          self.m_uiNameHandle:GetComponent("HUDFollowTarget").offset = EC.Vector3.new(0, self.nameOffset, 0)
        end
        if self.m_node2d and not self.m_node2d.isnil then
          local curX = self.m_node2d.localPosition.x
          local curY = self.m_node2d.localPosition.y
          local mountPos = EC.Vector3.new()
          Set2DPosTo3D(curX, world_height - curY, mountPos)
          self.mount:Set3DPos(mountPos)
          self.mount:SetRotation(roleRotation)
        end
        if self.mShadowObj and not self.mShadowObj.isnil then
          self.mShadowObj:SetActive(false)
        end
        function self.m_callWhenBeginRun.Mount()
          self:PlayWithDefault(self.mount:GetRunActionName(1), ActionName.Stand)
          self.mount:StartRun()
        end
        function self.m_callWhenEndRun.Mount()
          self:PlayWithDefault(self.mount:GetStandActionName(1), ActionName.Stand)
          self.mount:EndRun()
        end
        if 0 < self.magicMarkId then
          self.mount:SetMagicMark(self.magicMarkId)
          ECRoleModel.SetMagicMark(self, 0)
        end
      end
    end
    if self.mount.m_status == ModelStatus.DESTROY or self.mount.m_status == ModelStatus.NONE then
      self.mount:LoadHead(mountLoaded)
    elseif self.mount.m_status == ModelStatus.NORMAL then
      mountLoaded()
    elseif self.mount.m_status == ModelStatus.LOADING then
      self.mount:AddOnLoadCallback("returnmount", mountLoaded)
    end
  end
end
def.method("=>", "boolean").IsOnMount = function(self)
  return self.mount ~= nil and (self.mount:IsInLoading() or self.mount:IsObjLoaded())
end
def.method("number", "number", "number").SetMount = function(self, rideId, level, dyeId)
  self:UnMount()
  if rideId ~= 0 then
    local chainRideData = ChainRideData.CreateChainRideData(rideId)
    if chainRideData then
      local headIndex = chainRideData:GetHeadIndex()
      if headIndex > 0 then
        self.mount = ECChainRide.new(self, rideId, level, dyeId, headIndex, chainRideData)
        self.mount:SetRootNode(self.mount)
      end
    else
      self.mount = ECRide.new(self, rideId, level, dyeId)
    end
    local pos = self:GetPos()
    self.mount:SetDir(self.m_ang)
    self.mount:Set2DPos(pos.x, pos.y)
    if self:IsInState(RoleState.FLY) or self.flyState ~= 0 or self:IsInState(RoleState.PASSENGER) then
      return
    end
    if self.m_model == nil and self:IsInLoading() then
      self:AddOnLoadCallbackQueue("Ride", function()
        self:ReturnMount()
      end)
    else
      self:ReturnMount()
    end
  end
end
def.method().UnMount = function(self)
  if self.interaction ~= nil then
    self:EndInteraction()
  end
  if self.mount then
    self.mount:RemoveAllPassenger()
    if self:IsInState(RoleState.FLY) or self.flyState ~= 0 or self:IsInState(RoleState.PASSENGER) then
      self.mount = nil
    else
      self:LeaveMount()
      self.mount = nil
    end
  else
    self:RemoveOnLoadCallbackQueue("Ride")
  end
end
def.method("number").SetMountColor = function(self, colorId)
  if self.mount then
    self.mount:SetDye(colorId)
  end
end
def.method("number").SetMountLevel = function(self, level)
  if self.mount then
    self.mount:SetLevel(level)
  end
end
def.method("table", "number").AttachToMount = function(self, role, index)
  if role == nil or index <= 0 then
    return
  end
  if self.mount then
    self.mount:AddPassenger(role, index)
  end
end
def.method("number").DetachIndexFromMount = function(self, index)
  if self.mount then
    self.mount:RemovePassengerByIndex(index)
  end
end
def.method().DetachAllFromMount = function(self)
  if self.mount then
    self.mount:RemoveAllPassenger()
  end
end
def.method("=>", "boolean").IsPassenger = function(self)
  return self:IsInState(RoleState.PASSENGER)
end
def.method("=>", "number").GetPassengersCount = function(self)
  if self.mount then
    return self.mount:GetPassengerCount()
  else
    return 0
  end
end
def.method("=>", "table").GetPassengers = function(self)
  if self.mount then
    return self.mount:GetPassengerCount()
  else
    return {}
  end
end
def.method("number", "number", "number", "=>", "table", "number").MakeFlyPathFixedTime = function(self, x, y, t)
  local curX = self.m_node2d.localPosition.x
  local curY = self.m_node2d.localPosition.y
  local path = {}
  path[0] = {x = curX, y = curY}
  path[1] = {x = x, y = y}
  local distance = MathHelper.Distance(curX, curY, x, y)
  local speed = distance / t
  return path, speed
end
def.method("number", "number", "=>", "table").MakeFlyPath = function(self, x, y)
  local curX = self.m_node2d.localPosition.x
  local curY = self.m_node2d.localPosition.y
  local path = {}
  path[0] = {x = curX, y = curY}
  path[1] = {x = x, y = y}
  return path
end
def.virtual("number", "number", "table", "function")._flyUp = function(self, x, y, feijianCfg, callback)
  self:RemoveState(RoleState.RUN)
  local strategy = self:GetOrCreateFlyStrategy()
  if strategy then
    self:SetMagicMarkVisible(false)
    self:HideBackup()
    strategy:FlyUp(x, y, callback)
    return
  end
end
def.virtual("number", "number", "table", "function")._flyTo = function(self, x, y, feijianCfg, callback)
  self:RemoveState(RoleState.RUN)
  local strategy = self:GetOrCreateFlyStrategy()
  if strategy then
    self:HideBackup()
    strategy:FlyTo(x, y, callback)
    return
  end
end
def.virtual("number", "number", "table", "function")._flyAt = function(self, x, y, feijianCfg, callback)
  self:RemoveState(RoleState.RUN)
  local strategy = self:GetOrCreateFlyStrategy()
  if strategy then
    self:SetMagicMarkVisible(false)
    self:HideBackup()
    strategy:FlyAt(x, y, callback)
    return
  end
end
def.virtual("number", "number", "table", "function")._flyDown = function(self, x, y, feijianCfg, callback)
  self:RemoveState(RoleState.RUN)
  local strategy = self:GetOrCreateFlyStrategy()
  if strategy then
    strategy:FlyDown(x, y, function()
      self:SetMagicMarkVisible(true)
      self:HideBackup()
      if callback then
        callback()
      end
    end)
    return
  end
end
def.method("=>", "boolean").IsMe = function(self)
  if self.m_roleType ~= RoleType.ROLE then
    return false
  end
  local myid = GetMyRoleID()
  return self.roleId ~= nil and myid ~= nil and self.roleId:eq(myid)
end
def.method("=>", "boolean").IsOnGround = function(self)
  return not self:IsInState(RoleState.FLY) and self.flyState == 0
end
def.method("number", "number", "function").FlyAt = function(self, x, y, cb)
  if self.interaction ~= nil then
    self:EndInteraction()
  end
  if self:IsInState(RoleState.BEHUG) then
    return
  end
  local ECGame = require("Main.ECGame")
  if self.m_node2d then
    self:SetState(RoleState.FLY)
    self:Set2DPos(x, y)
    local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(self:GetFeijianId())
    self:_flyAt(x, y, feijianCfg, function()
      if cb then
        cb()
      end
    end)
    if self:IsMe() then
      Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, nil)
    end
  else
    warn("Nothing to Fly")
  end
end
def.method().ReFly = function(self)
  if self:IsInState(RoleState.FLY) and self.feijianModel and self.feijianModel:IsObjLoaded() and self.flyState == ECPlayer.FlyState.Flight then
    if self.movePath and #self.movePath > 0 then
      local movePath = self.movePath
      local pathIdx = self.pathIdx
      local runpathCallback = self.runpathCallback
      local moveEnd = movePath[#movePath]
      self:FlyTo(moveEnd.x, moveEnd.y, runpathCallback)
    else
      self:ResetFly()
    end
  end
end
def.method().ResetFly = function(self)
  if self:IsInState(RoleState.BEHUG) then
    return
  end
  local ECGame = require("Main.ECGame")
  if self.m_node2d then
    local curX = self.m_node2d.localPosition.x
    local curY = self.m_node2d.localPosition.y
    local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(self:GetFeijianId())
    self:_flyAt(curX, curY, feijianCfg, nil)
  else
    warn("Nothing to Fly")
  end
end
def.method("function", "=>", "number", "number").FlyUp = function(self, cb)
  if self:IsInState(RoleState.BEHUG) then
    return -1, -1
  end
  self:EndInteraction()
  local isMe = self:IsMe()
  local ECGame = require("Main.ECGame")
  if self.m_node2d then
    self:SetState(RoleState.FLY)
    if self:GetPassengersCount() > 0 then
      gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ResetTeamFollowList(self.teamId, true)
    end
    local curX = self.m_node2d.localPosition.x
    local curY = self.m_node2d.localPosition.y
    if curY < fly_y_min then
      curY = fly_y_min or curY
    end
    local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(self:GetFeijianId())
    if isMe then
      Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, nil)
    end
    self:_flyUp(curX, curY, feijianCfg, function()
      if cb then
        cb()
      end
    end)
    return curX, curY
  else
    warn("Nothing to Fly")
    return -1, -1
  end
end
def.method("function", "=>", "number", "number").FlyDown = function(self, cb)
  if self:IsInState(RoleState.BEHUG) then
    return -1, -1
  end
  self:EndInteraction()
  local isMe = self:IsMe()
  local ECGame = require("Main.ECGame")
  if self.m_node2d then
    self:RemoveState(RoleState.FLY)
    local curX = self.m_node2d.localPosition.x
    local curY = self.m_node2d.localPosition.y
    if MapScene.IsBarrierXY(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, curX, curY) then
      local pt = MapScene.FindAdjacentValidPoint(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, curX, curY)
      if pt then
        curX = pt:x()
        curY = pt:y()
      else
        warn("no land point", curX, curY)
        return -1, -1
      end
    end
    local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(self:GetFeijianId())
    if isMe then
      Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, nil)
    end
    self:_flyDown(curX, curY, feijianCfg, function()
      gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ResetTeamFollowList(self.teamId, false)
      if cb then
        cb()
      end
    end)
    return curX, curY
  else
    warn("Nothing to Fly")
    return -1, -1
  end
end
def.method("number", "number", "function").FlyTo = function(self, x, y, cb)
  if self:IsInState(RoleState.BEHUG) then
    return
  end
  self:EndInteraction()
  local isMe = self:IsMe()
  local ECGame = require("Main.ECGame")
  if self.m_node2d then
    self:SetState(RoleState.FLY)
    local curX = self.m_node2d.localPosition.x
    local curY = self.m_node2d.localPosition.y
    local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(self:GetFeijianId())
    if isMe then
      Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, nil)
    end
    self:_flyTo(x, y, feijianCfg, function()
      if cb then
        cb()
      end
    end)
  else
    warn("Nothing to Fly")
  end
end
def.method("number", "number", "function").FlyUpTo = function(self, x, y, cb)
  if self:IsInState(RoleState.BEHUG) then
    return
  end
  self:EndInteraction()
  local isMe = self:IsMe()
  local ECGame = require("Main.ECGame")
  if self.m_node2d then
    self:SetState(RoleState.FLY)
    if self:GetPassengersCount() > 0 then
      gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ResetTeamFollowList(self.teamId, true)
    end
    do
      local curX = self.m_node2d.localPosition.x
      local curY = self.m_node2d.localPosition.y
      local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(self:GetFeijianId())
      local upDis = feijianCfg.velocity * fly_up_ani_time
      local upX, upY = MathHelper.CalcCoordByTwoPointAndDistance1(curX, curY, x, y, upDis)
      if isMe then
        Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, nil)
      end
      self:_flyUp(upX, upY, feijianCfg, function()
        self:_flyTo(x, y, feijianCfg, function()
          if cb then
            cb()
          end
        end)
      end)
    end
  else
    warn("Nothing to Fly")
  end
end
def.method("number", "number", "function").FlyUpToDown = function(self, x, y, cb)
  if self:IsInState(RoleState.BEHUG) then
    return
  end
  self:EndInteraction()
  local isMe = self:IsMe()
  local ECGame = require("Main.ECGame")
  if self.m_node2d then
    self:SetState(RoleState.FLY)
    if self:GetPassengersCount() > 0 then
      gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ResetTeamFollowList(self.teamId, true)
    end
    if MapScene.IsBarrierXY(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, x, y) then
      local pt = MapScene.FindAdjacentValidPoint(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, curX, curY)
      x = pt:x()
      y = pt:y()
    end
    do
      local curX = self.m_node2d.localPosition.x
      local curY = self.m_node2d.localPosition.y
      local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(self:GetFeijianId())
      local diffX = x - curX
      local diffY = y - curY
      local fullDis = math.sqrt(diffX * diffX + diffY * diffY)
      local upDis = feijianCfg.velocity * fly_up_ani_time
      local downDis = feijianCfg.velocity * fly_down_ani_time
      if fullDis < upDis + downDis then
        upDis = fullDis * 0.5
        downDis = upDis
      end
      local upX, upY = MathHelper.CalcCoordByTwoPointAndDistance1(curX, curY, x, y, upDis)
      local downX, downY = MathHelper.CalcCoordByTwoPointAndDistance2(curX, curY, x, y, downDis)
      if isMe then
        Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, nil)
      end
      self:_flyUp(upX, upY, feijianCfg, function()
        self:_flyTo(downX, downY, feijianCfg, function()
          self:RemoveState(RoleState.FLY)
          if isMe then
            Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, nil)
          end
          self:_flyDown(x, y, feijianCfg, function()
            gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ResetTeamFollowList(self.teamId, false)
            if cb then
              cb()
            end
          end)
        end)
      end)
    end
  else
    warn("Nothing to Fly")
  end
end
def.method("number", "number", "function").FlyToDown = function(self, x, y, cb)
  if self:IsInState(RoleState.BEHUG) then
    return
  end
  self:EndInteraction()
  local isMe = self:IsMe()
  local ECGame = require("Main.ECGame")
  if self.m_node2d then
    self:SetState(RoleState.FLY)
    if MapScene.IsBarrierXY(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, x, y) then
      local pt = MapScene.FindAdjacentValidPoint(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, curX, curY)
      x = pt:x()
      y = pt:y()
    end
    do
      local curX = self.m_node2d.localPosition.x
      local curY = self.m_node2d.localPosition.y
      local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(self:GetFeijianId())
      local downDis = feijianCfg.velocity * fly_down_ani_time
      local downX, downY = MathHelper.CalcCoordByTwoPointAndDistance2(curX, curY, x, y, downDis)
      if isMe then
        Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, nil)
      end
      self:_flyTo(downX, downY, feijianCfg, function()
        self:RemoveState(RoleState.FLY)
        if isMe then
          Event.DispatchEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, nil)
        end
        self:_flyDown(x, y, feijianCfg, function()
          gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ResetTeamFollowList(self.teamId, false)
          if cb then
            cb()
          end
        end)
      end)
    end
  else
    warn("Nothing to Fly")
  end
end
def.method("number", "number", "table").FollowFly = function(self, x, y, target)
  if self.m_roleType == RoleType.PET then
    return
  end
  local flyState = target.flyState
  local function followRun()
    if target and target.movePath ~= nil and #target.movePath > 0 then
      self:RunPath(target.movePath, self.followSpeed, nil)
    end
  end
  if self.flyState == 0 then
    if flyState == 0 then
    elseif flyState == ECPlayer.FlyState.Up then
      self:FlyUpTo(x, y, nil)
    elseif flyState == ECPlayer.FlyState.Flight then
      self:FlyUpTo(x, y, nil)
    elseif flyState == ECPlayer.FlyState.Down then
    end
  elseif self.flyState == ECPlayer.FlyState.Up then
    if flyState == 0 then
      self:FlyDown(followRun)
    elseif flyState == ECPlayer.FlyState.Up then
    elseif flyState == ECPlayer.FlyState.Flight then
    elseif flyState == ECPlayer.FlyState.Down then
      self:FlyToDown(x, y, nil)
    end
  elseif self.flyState == ECPlayer.FlyState.Flight then
    if flyState == 0 then
      self:FlyToDown(x, y, followRun)
    elseif flyState == ECPlayer.FlyState.Up then
    elseif flyState == ECPlayer.FlyState.Flight then
      self:FlyTo(x, y, nil)
    elseif flyState == ECPlayer.FlyState.Down then
      self:FlyToDown(x, y, nil)
    end
  elseif self.flyState ~= ECPlayer.FlyState.Down or flyState == 0 then
  elseif flyState == ECPlayer.FlyState.Up then
    self:FlyUpTo(x, y, nil)
  elseif flyState == ECPlayer.FlyState.Flight then
    self:FlyTo(x, y, nil)
  elseif flyState == ECPlayer.FlyState.Down then
  end
end
def.virtual("number", "number", "table", "function")._cgFlyUp = function(self, x, y, feijianCfg, callback)
  local ECGame = require("Main.ECGame")
  local skyScale = 1.5
  local function OnActionDone()
    if self.feijianModel == nil or self.feijianModel.m_model == nil or self.feijianModel.m_model.isnil or self.m_model == nil or self.m_model.isnil then
      if self and self.feijianModel then
        self.feijianModel:Destroy()
        self.feijianModel = nil
      end
      return
    end
    self.flyState = ECPlayer.FlyState.Flight
    self.flyPoint = nil
    self:SetLayer(ClientDef_Layer.FlyPlayer)
    self.feijianModel:SetLayer(ClientDef_Layer.FlyPlayer)
    if self.mECFabaoComponent then
      self.mECFabaoComponent:SetLayer(ClientDef_Layer.FlyPlayer)
    end
    self.m_model.localScale = EC.Vector3.new(skyScale, skyScale, skyScale)
    local commonMove = self:GetOrAddMovePathComp()
    commonMove:set_enabled(true)
    local animationName = self:HasAnimClip(FlyModule.FlyIdleAnimation) and FlyModule.FlyIdleAnimation or ActionName.Stand
    if self:IsInState(RoleState.HUG) then
      animationName = FlyModule.FlyIdleHugAnimation
    end
    commonMove:set_MoveAnimationName(animationName)
    commonMove:set_StandAnimationName(animationName)
    self:Play(animationName)
    commonMove:set_IsAnimate(true)
    self.feijianModel:Play(FlyModule.FlyIdleAnimation)
    self.nameOffset = -1.2
    if self.m_uiNameHandle then
      self.m_uiNameHandle:GetComponent("HUDFollowTarget").offset = EC.Vector3.new(0, self.nameOffset, 0)
    end
    if callback then
      callback()
    end
  end
  local function OnLoadFeijianDone(ret)
    if ret == nil or self.feijianModel == nil or self.feijianModel.m_model == nil or self.feijianModel.m_model.isnil or self.m_model == nil or self.m_model.isnil then
      return
    end
    if self:IsMe() then
      ECGame.Instance():ToSkyLayer()
      FlyModule.Instance():FlowCloud(0.001, "fly")
    end
    if not self.showModel then
      self.feijianModel:SetActive(false)
    end
    self:StopAnimAndCallback()
    self.flyState = ECPlayer.FlyState.Up
    self.flyPoint = {x = x, y = y}
    local upHeight = 3
    local commonMove = self:GetOrAddMovePathComp()
    commonMove:set_enabled(true)
    commonMove:set_IsAnimate(false)
    self.feijianModel:SetAnimCullingType(0)
    self:SetAnimCullingType(0)
    if self.showModel then
      self:AddEffectWithOffset(RESPATH.Feijian_Jump_Effect, 0)
    end
    local feijianAttach = self:GetAttach(FlyModule.FlyTag)
    if feijianAttach ~= self.feijianModel then
      self:AttachModel(FlyModule.FlyTag, self.feijianModel, "Root")
    end
    if feijianCfg.effectPath and self.feijianEffect == nil then
      self.feijianEffect = self.feijianModel:AttachEffectToBone(feijianCfg.effectPath, "Bip01")
      if self.feijianEffect then
        self.feijianEffect.transform.localRotation = Quaternion.Euler(EC.Vector3.new(0, 0, 0))
        self.feijianEffect:SetLayer(ClientDef_Layer.FlyPlayer)
        local FXModule = require("Main.FX.FXModule")
        FXModule.Instance():AddManagedFx(self.feijianEffect)
      end
    end
    local curX = self.m_node2d.localPosition.x
    local curY = self.m_node2d.localPosition.y
    local tweenCallback, runpathCallback
    if curX == x and curY == y then
      tweenCallback = OnActionDone
    else
      runpathCallback = OnActionDone
    end
    if self.m_model and not self.m_model.isnil then
      self:SetLayer(ClientDef_Layer.FlyPlayer)
      local y = self.m_model.transform.localPosition.y
      local y2 = 0 + upHeight
      YGameObjectTween.TweenGameObjectY(self.m_model, y, y2, fly_up_time, fly_up_ani_time, tweenCallback)
      ScaleGameObjectTween.TweenGameObjectScale(self.m_model, self.m_model.transform.localScale, EC.Vector3.new(skyScale, skyScale, skyScale), fly_up_time)
    end
    if self.mShadowObj and not self.mShadowObj.isnil then
      local shadowPosition = self.mShadowObj.transform.localPosition
      local shadowToPosition = EC.Vector3.new(shadowPosition.x, (0 - upHeight) / skyScale, shadowPosition.z)
      PositionGameObjectTween.TweenGameObjectPosition(self.mShadowObj, shadowPosition, shadowToPosition, fly_up_time)
    end
    if self.mECFabaoComponent then
      self.mECFabaoComponent:FlyUp()
    end
    local pet = self:GetPet()
    if pet then
      local PubroleModule = require("Main.Pubrole.PubroleModule")
      PubroleModule.Instance():RoleStopFollow(pet)
      self:RemovePet()
    end
    if curX == x and curY == y then
      self.feijianModel:Play(FlyModule.FlyUpAnimation)
      local animationName = self:HasAnimClip(FlyModule.FlyUpAnimation) and FlyModule.FlyUpAnimation or ActionName.Stand
      self:Play(animationName)
      local upSpeed = 0
      self.movePath, upSpeed = self:MakeFlyPathFixedTime(x, y, fly_up_ani_time)
      if self.m_model == nil or self.m_model.isnil then
        local moveComp = self.movePathComp
        if moveComp then
          moveComp:Stop()
          moveComp.enabled = false
        end
      end
    else
      self.feijianModel:Play(FlyModule.FlyUpAnimation)
      local animationName = self:HasAnimClip(FlyModule.FlyUpAnimation) and FlyModule.FlyUpAnimation or ActionName.Stand
      self:Play(animationName)
      local upSpeed = 0
      self.movePath, upSpeed = self:MakeFlyPathFixedTime(x, y, fly_up_ani_time)
      self:_RunPath(self.movePath, upSpeed, self.m_model, runpathCallback)
    end
  end
  local function doFly()
    if self.feijianModel == nil then
      self.feijianModel = ECModel.new(0)
      self.feijianModel:Load(feijianCfg.modelPath, OnLoadFeijianDone)
    elseif not self.feijianModel:IsObjLoaded() then
      self.feijianModel:Destroy()
      self.feijianModel = ECModel.new(0)
      self.feijianModel:Load(feijianCfg.modelPath, OnLoadFeijianDone)
    else
      OnLoadFeijianDone(self.feijianModel)
    end
  end
  if self.m_model == nil and self:IsInLoading() then
    self:AddOnLoadCallback("feijian", doFly)
  else
    doFly()
  end
end
def.virtual("number", "number", "table", "function")._cgFlyDown = function(self, x, y, feijianCfg, callback)
  local skyScale = 1.5
  local ECGame = require("Main.ECGame")
  local function OnActionDone()
    if self.feijianModel == nil or self.feijianModel.m_model == nil or self.feijianModel.m_model.isnil or self.m_model == nil or self.m_model.isnil then
      if self and self.feijianModel then
        self.feijianModel:Destroy()
        self.feijianModel = nil
      end
      return
    end
    self.flyState = 0
    self.flyPoint = nil
    if self.showModel then
      self:AddEffectWithOffset(RESPATH.Feijian_Jump_Effect, 0)
    end
    self:SetAnimCullingType(1)
    local commonMove = self:GetOrAddMovePathComp()
    commonMove:set_enabled(true)
    commonMove:set_IsAnimate(true)
    commonMove:set_MoveAnimationName("Run_c")
    commonMove:set_StandAnimationName("Stand_c")
    self:Play("Stand_c")
    self.nameOffset = default_name_offset
    if self.m_uiNameHandle then
      self.m_uiNameHandle:GetComponent("HUDFollowTarget").offset = EC.Vector3.new(0, self.nameOffset, 0)
    end
    self:DestroyChild(FlyModule.FlyTag)
    self.feijianModel = nil
    ECFxMan.Instance():Stop(self.feijianEffect)
    self.feijianEffect = nil
    if callback then
      callback()
    end
  end
  local function OnLoadFeijianDone(ret)
    if ret == nil or self.feijianModel == nil or self.feijianModel.m_model == nil or self.feijianModel.m_model.isnil or self.m_model == nil or self.m_model.isnil then
      return
    end
    if self:IsMe() then
      ECGame.Instance():ToGroundLayer()
      FlyModule.Instance():StopCloud("fly")
    end
    if not self.showModel then
      self.feijianModel:SetActive(false)
    end
    self:StopAnimAndCallback()
    self.flyState = ECPlayer.FlyState.Down
    self.flyPoint = {x = x, y = y}
    local commonMove = self:GetOrAddMovePathComp()
    commonMove:set_enabled(true)
    commonMove:set_IsAnimate(false)
    self.feijianModel:SetAnimCullingType(0)
    self:SetAnimCullingType(0)
    self:SetLayer(ClientDef_Layer.Player)
    self.feijianModel:SetLayer(ClientDef_Layer.Player)
    local feijianAttach = self:GetAttach(FlyModule.FlyTag)
    if feijianAttach ~= self.feijianModel then
      self:AttachModel(FlyModule.FlyTag, self.feijianModel, "Root")
    end
    if feijianCfg.effectPath and self.feijianEffect == nil then
      self.feijianEffect = self.feijianModel:AttachEffectToBone(feijianCfg.effectPath, "Bip01")
      if self.feijianEffect then
        self.feijianEffect.transform.localRotation = Quaternion.Euler(EC.Vector3.new(0, 0, 0))
        self.feijianEffect:SetLayer(ClientDef_Layer.FlyPlayer)
        local FXModule = require("Main.FX.FXModule")
        FXModule.Instance():AddManagedFx(self.feijianEffect)
      end
    end
    if self.mECFabaoComponent then
      self.mECFabaoComponent:FlyDown()
      self.mECFabaoComponent:SetLayer(ClientDef_Layer.Player)
    end
    local curX = self.m_node2d.localPosition.x
    local curY = self.m_node2d.localPosition.y
    local tweenCallback, runpathCallback
    if curX == x and curY == y then
      tweenCallback = OnActionDone
    else
      runpathCallback = OnActionDone
    end
    if self.m_model and not self.m_model.isnil then
      local y = self.m_model.transform.localPosition.y
      YGameObjectTween.TweenGameObjectY(self.m_model, y, 0, fly_down_time, fly_down_ani_time, tweenCallback)
      ScaleGameObjectTween.TweenGameObjectScale(self.m_model, self.m_model.transform.localScale, Model_Default_Scale, fly_down_time)
    end
    if self.mShadowObj and not self.mShadowObj.isnil then
      local shadowPosition = self.mShadowObj.transform.localPosition
      local shadowToPosition = EC.Vector3.new(shadowPosition.x, 0, shadowPosition.z)
      PositionGameObjectTween.TweenGameObjectPosition(self.mShadowObj, shadowPosition, shadowToPosition, fly_down_time)
    end
    if curX == x and curY == y then
      self.feijianModel:Play(FlyModule.FlyDownAnimation)
      local animationName = self:HasAnimClip(FlyModule.FlyDownAnimation) and FlyModule.FlyDownAnimation or ActionName.Stand
      self:Play(animationName)
      local downSpeed = 0
      self.movePath, downSpeed = self:MakeFlyPathFixedTime(x, y, fly_down_ani_time)
      if self.m_model == nil or self.m_model.isnil then
        local moveComp = self.movePathComp
        if moveComp then
          moveComp:Stop()
          moveComp.enabled = false
        end
      end
    else
      self.feijianModel:Play(FlyModule.FlyDownAnimation)
      local animationName = self:HasAnimClip(FlyModule.FlyDownAnimation) and FlyModule.FlyDownAnimation or ActionName.Stand
      self:Play(animationName)
      local downSpeed = 0
      self.movePath, downSpeed = self:MakeFlyPathFixedTime(x, y, fly_down_ani_time)
      self:_RunPath(self.movePath, downSpeed, self.m_model, runpathCallback)
    end
  end
  local function doFly()
    if self.feijianModel == nil then
      self.feijianModel = ECModel.new(0)
      self.feijianModel:Load(feijianCfg.modelPath, OnLoadFeijianDone)
    elseif not self.feijianModel:IsObjLoaded() then
      self.feijianModel:Destroy()
      self.feijianModel = ECModel.new(0)
      self.feijianModel:Load(feijianCfg.modelPath, OnLoadFeijianDone)
    else
      OnLoadFeijianDone(self.feijianModel)
    end
  end
  if self.m_model == nil and self:IsInLoading() then
    self:AddOnLoadCallback("feijian", doFly)
  else
    doFly()
  end
end
def.method("boolean", "number").cgFlyUp = function(self, isMe, feijianId)
  local ECGame = require("Main.ECGame")
  if self.m_node2d then
    self:SetState(RoleState.FLY)
    local curX = self.m_node2d.localPosition.x
    local curY = self.m_node2d.localPosition.y
    local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(feijianId)
    if isMe then
      ECGame.Instance():ToSkyLayer()
      FlyModule.Instance():FlowCloud(0, "cg")
    end
    self:_cgFlyUp(curX, curY, feijianCfg, function()
      self:DestroyMovePathComp()
    end)
  else
    warn("Nothing to Fly")
  end
end
def.method("boolean", "number").cgFlyDown = function(self, isMe, feijianId)
  local ECGame = require("Main.ECGame")
  if self.m_node2d then
    self:RemoveState(RoleState.FLY)
    local curX = self.m_node2d.localPosition.x
    local curY = self.m_node2d.localPosition.y
    local feijianCfg = FlyModule.Instance():GetFeijianCfgByFeijianId(feijianId)
    if isMe then
      ECGame.Instance():ToGroundLayer()
      FlyModule.Instance():StopCloud("cg")
    end
    self:_cgFlyDown(curX, curY, feijianCfg, function()
      self:DestroyMovePathComp()
    end)
  else
    warn("Nothing to Fly")
  end
end
def.method().RemoveFlyComponent = function(self)
  if self.feijianModel then
    if self.feijianModel.mShadowObj and not self.feijianModel.mShadowObj.isnil then
      local tweenComp = self.feijianModel.mShadowObj:GetComponent("PositionGameObjectTween")
      if tweenComp then
        Object.DestroyImmediate(tweenComp)
      end
    end
    if self.feijianModel.m_model and not self.feijianModel.m_model.isnil then
      local tweenComp = self.feijianModel.m_model:GetComponent("YGameObjectTween")
      if tweenComp then
        Object.DestroyImmediate(tweenComp)
      end
      tweenComp = nil
      tweenComp = self.feijianModel.m_model:GetComponent("ScaleGameObjectTween")
      if tweenComp then
        Object.DestroyImmediate(tweenComp)
      end
    end
  end
end
def.field("table").huggedRole = nil
def.field("function").moveAfter = nil
def.method("function").SetMoveAfter = function(self, cb)
  self.moveAfter = cb
end
def.method().DoMoveAfter = function(self)
  local cb = self.moveAfter
  self.moveAfter = nil
  if cb then
    cb()
  end
end
def.method("table").Hug = function(self, huggedRole)
  if huggedRole == nil then
    return
  end
  self:SetState(RoleState.HUG)
  huggedRole:SetState(RoleState.BEHUG)
  self.huggedRole = huggedRole
  local flyStrategy = self:GetOrCreateFlyStrategy()
  flyStrategy:Hug()
end
def.method().UnHug = function(self)
  if self.huggedRole == nil then
    return
  end
  self:RemoveState(RoleState.HUG)
  self.huggedRole:RemoveState(RoleState.BEHUG)
  local flyStrategy = self:GetOrCreateFlyStrategy()
  flyStrategy:Unhug()
  self.huggedRole = nil
end
def.method("table").SetBackupModelInfo = function(self, modelInfo)
  self.backupModelInfo = modelInfo
end
def.method().ClearBackup = function(self)
  self.backupModelInfo = nil
  self:HideBackup()
end
def.method().HideBackup = function(self)
  if self.backupModel then
    self:Detach("backup")
    self.backupModel:Destroy()
    self.backupModel = nil
    self:SetModelIsRender(true)
  end
end
def.method("function").ShowBackup = function(self, cb)
  if self.backupModelInfo then
    local modelId = self.backupModelInfo.modelid
    if modelId then
      if self.backupModel and (self.backupModel:IsLoaded() or self.backupModel:IsInLoading()) then
        if self.backupModel:IsLoaded() then
          if cb then
            cb()
          end
        elseif self.backupModel:IsInLoading() then
          self:AddOnLoadCallback(function()
            if self.m_model and not self.m_model.isnil and cb then
              cb()
            end
          end)
        end
      else
        if self.backupModel then
          self.backupModel:Destroy()
        end
        self.backupModel = ECModel.new(modelId)
        self.backupModel:SetLayer(self.defaultLayer)
        local modelPath, modelColor = _G.GetModelPath(modelId)
        self.backupModel.colorId = modelColor
        self.backupModel:Load2(modelPath, function()
          if self.m_model and not self.m_model.isnil then
            if self.backupModel and self.backupModel.m_model and not self.backupModel.m_model.isnil then
              self:AttachModelToSelf("backup", self.backupModel)
              self:SetModelIsRender(false)
            end
            if cb then
              cb()
            end
          else
            self:HideBackup()
          end
        end, true)
      end
    end
  end
end
def.method("string", "function").PlayWithBackUp = function(self, aniName, cb)
  if not self:PlayAnim(aniName, cb) then
    if self.m_model == nil or self.m_model.isnil then
      return
    end
    self:ShowBackup(function()
      if self.backupModel and self.backupModel.m_model and not self.backupModel.m_model.isnil then
        self.backupModel:PlayAnim(aniName, cb)
      end
    end)
  else
    self:HideBackup()
  end
end
def.field(ECPlayer).interaction = nil
def.field("boolean").bIsSticked = false
def.field("string").effectPath = ""
def.method("=>", "table").GetInteractionRole = function(self)
  return self.interaction
end
def.method("=>", "boolean").GetIsSticked = function(self)
  return self.bIsSticked
end
def.method("table", "string").SetInteraction = function(self, pRole, boneName)
  if boneName ~= "" then
    self.interaction = pRole
    self.bIsSticked = true
    pRole.interaction = self
    pRole.bIsSticked = true
    local commonMove = pRole:GetOrAddMovePathComp()
    if commonMove then
      commonMove:set_enabled(false)
    end
    if pRole.m_model and not pRole.m_model.isnil then
      pRole.m_model.transform.localPosition = EC.Vector3.zero
      pRole.m_model.transform.localScale = EC.Vector3.one
      pRole.m_model.transform.localRotation = Quaternion.Euler(EC.Vector3.zero)
    end
    if pRole.mShadowObj and not pRole.mShadowObj.isnil then
      pRole.mShadowObj:SetActive(false)
    end
    ECRoleModel.SetMagicMarkVisible(pRole, false)
    self:AttachModel("interaction", pRole, boneName)
    if pRole.feijianModel then
      pRole.feijianModel:SetModelIsRender(false)
    end
    if pRole.m_model and not pRole.m_model.isnil then
      local panda = pRole.m_model:FindDirect(ECModel.Name.Panda)
      if panda then
        panda:SetActive(false)
      end
    end
    pRole:SetBoneIsRender(false)
  else
    self.interaction = pRole
    self.bIsSticked = false
    pRole.interaction = self
    pRole.bIsSticked = false
  end
end
def.method().EndInteraction = function(self)
  if self.interaction then
    local interactionRole = self.interaction
    self.interaction = nil
    if self.bIsSticked then
      local attachRole = self:Detach("interaction")
      if attachRole and interactionRole.m_model and not interactionRole.m_model.isnil then
        local pos = interactionRole:GetPos()
        interactionRole:SetParentNode(interactionRole.defaultParentNode)
        if pos then
          interactionRole.m_model.transform.localRotation = self.m_model.localRotation
          interactionRole.m_model.transform.localScale = Model_Default_Scale
          if interactionRole:IsInState(RoleState.FLY) then
            interactionRole:FlyAt(pos.x, pos.y, nil)
          else
            interactionRole:SetPos(pos.x, pos.y)
          end
        end
        if interactionRole.mShadowObj and not interactionRole.mShadowObj.isnil then
          interactionRole.mShadowObj:SetActive(true)
        end
        if interactionRole.m_model and not interactionRole.m_model.isnil then
          local panda = interactionRole.m_model:FindDirect(ECModel.Name.Panda)
          if panda then
            panda:SetActive(true)
          end
        end
        interactionRole:SetBoneIsRender(true)
        ECRoleModel.SetMagicMarkVisible(interactionRole, true)
      end
    else
    end
    self:StopAnimAndCallback()
    self:HideBackup()
    self:ShowWeapon(true)
    if self.feijianModel then
      self.feijianModel:SetModelIsRender(true)
    end
    self.bIsSticked = false
    interactionRole:EndInteraction()
    self:RecoveryRole()
    if self.effectPath ~= "" then
      self:StopChildEffect(self.effectPath)
      self.effectPath = ""
    end
  end
end
def.method().RecoveryRole = function(self)
  if self:IsInState(RoleState.FLY) then
    self:ResetFly()
  else
    if self.mount then
      self:ReturnMount()
    else
      self:SetStance()
    end
    local m2dPos = self:GetPos()
    if m2dPos ~= nil then
      self:SetPos(m2dPos.x, m2dPos.y)
    end
  end
end
def.method("number", "number").ShowBallCooldownPate = function(self, endTime, duration)
  warn("[ECPlayer:ShowBallCooldownPate] endTime, curTime, duration:", os.date("%c", endTime), os.date("%c", _G.GetServerTime()), duration)
  if endTime > _G.GetServerTime() and duration > 0 then
    self.m_maxEndTime = endTime
    self.m_maxDuration = duration
    if _G.IsNil(self.m_ballCooldownPate) then
      local ECPate = require("GUI.ECPate")
      local pate = ECPate.new()
      pate:CreateBallCooldown(self, endTime, duration)
    else
      self:UpdateBallCooldownPate()
    end
  else
    warn("[ERROR][ECPlayer:ShowBallCooldownPate] Destroy on invalid time input.")
    self:DestroyBallCooldownPate()
  end
end
def.method().UpdateBallCooldownPate = function(self)
  if not _G.IsNil(self.m_ballCooldownPate) then
    if self.m_maxEndTime > _G.GetServerTime() and self.m_maxDuration > 0 then
      local cooldown = self.m_maxEndTime - _G.GetServerTime()
      if self.m_curCooldown ~= cooldown then
        local GUIUtils = require("GUI.GUIUtils")
        self.m_curCooldown = cooldown
        local Slider_Exp = self.m_ballCooldownPate:FindDirect("Slider_Exp")
        local Label_Num = Slider_Exp:FindDirect("Label_Num")
        local progress = self.m_maxDuration > 0 and self.m_curCooldown / self.m_maxDuration or 0
        progress = math.min(1, progress)
        GUIUtils.SetProgress(Slider_Exp, GUIUtils.COTYPE.SLIDER, progress)
        GUIUtils.SetText(Label_Num, string.format(textRes.Aagr.ARENA_MAX_COOLDOWN, self.m_curCooldown))
      end
    else
      warn("[ECPlayer:UpdateBallCooldownPate] Destroy on countdown end.")
      self:DestroyBallCooldownPate()
    end
  end
end
def.method("=>", "boolean").IsBallCooldowning = function(self)
  if self.m_maxEndTime >= _G.GetServerTime() and self.m_maxDuration > 0 then
    return true
  else
    return false
  end
end
def.method().DestroyBallCooldownPate = function(self)
  if not _G.IsNil(self.m_ballCooldownPate) then
    self.m_ballCooldownPate:Destroy()
    self.m_ballCooldownPate = nil
  end
  self.m_curCooldown = 0
  self.m_maxEndTime = 0
  self.m_maxDuration = 0
end
ECPlayer.Commit()
return ECPlayer

local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local ECRoleModel = require("Model.ECRoleModel")
local ECPartComponent = require("Model.ECPartComponent")
local ECWingComponent = require("Model.ECWingComponent")
local ECFollowComponent = require("Model.ECFollowComponent")
local AttachType = require("consts.mzm.gsp.skill.confbean.EffectGuaDian")
local FightModel = Lplus.Extend(ECRoleModel, "FightModel")
local UIEffectType = require("consts.mzm.gsp.skill.confbean.UIEffectType")
local def = FightModel.define
FightModel.Label_Time_Type = {TIMEOUT = -1, PERMANENT = -2}
def.field("number").fighterId = -1
def.field("number").m_roleType = 0
def.field("userdata").m_uiHpHandle = nil
def.field("userdata").m_topIcon = nil
def.field("userdata").m_topIconCacheRoot = nil
def.field("userdata").m_commandPanel = nil
def.field("userdata").m_buffPanel = nil
def.field("number").titleIcon = 0
def.field("number").flagIcon = 0
def.field("number").hp = 1
def.field("number").mp = 1
def.field("number").labelTime = FightModel.Label_Time_Type.TIMEOUT
def.field("userdata").m_selectIcon = nil
def.field("number").dissolveTime = -1
def.field("number").dissolveDuration = 1
def.field("function").endCallback = nil
def.field("boolean").showHP = true
def.field("userdata").dissolveColor = nil
def.field("table").initModelInfo = nil
def.field("number").shatterTime = -1
def.field("number").shatterDuration = 1
def.field("table").renders = nil
def.field("userdata").flyMountModel = nil
def.field("table").uiBuffEffects = nil
def.field("table").topIcons = nil
def.field("string").stand_stance = ActionName.FightStand
def.field("boolean").isDead = false
def.final("number", "string", "userdata", "number", "=>", FightModel).new = function(id, name, nameColor, roleType)
  local obj = FightModel()
  obj.m_roleType = roleType
  obj.m_IsTouchable = true
  obj:Init(id)
  obj.defaultLayer = ClientDef_Layer.FightPlayer
  obj:SetName(name, nameColor)
  obj.m_bUncache = true
  return obj
end
def.override("number", "=>", "boolean").Init = function(self, id)
  self.mModelId = id
  if id <= 0 then
    return false
  end
  local node2d_name = "node2d_fight_" .. tostring(id)
  if self.m_node2d then
    self.m_node2d.name = node2d_name
  else
    self.m_node2d = GameObject.GameObject(node2d_name)
  end
  return true
end
def.override().Destroy = function(self)
  if self:IsDestroyed() then
    return
  end
  self:AttachShadow()
  self:AttachFlyMount()
  self:RemoveAllBuffEffect()
  if self.m_model then
    local flyTw = self.m_model:GetComponent("FlyFightTweener")
    if flyTw then
      Object.Destroy(flyTw)
    end
  end
  if self.m_uiHpHandle then
    self.m_uiHpHandle:Destroy()
    self.m_uiHpHandle = nil
  end
  if self.m_topIcon then
    self.m_topIcon:Destroy()
    self.m_topIcon = nil
  end
  if self.m_selectIcon then
    self.m_selectIcon:Destroy()
    self.m_selectIcon = nil
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
    self.mECWingComponent = nil
  end
  if self.m_commandPanel then
    self.m_commandPanel:Destroy()
    self.m_commandPanel = nil
  end
  if self.m_buffPanel then
    self.m_buffPanel:Destroy()
    self.m_buffPanel = nil
  end
  ECRoleModel.Destroy(self)
end
def.override("boolean").SetVisible = function(self, v)
  if v == self.m_visible then
    return
  end
  self.m_visible = v
  if self.m_uiNameHandle then
    self.m_uiNameHandle:SetActive(v)
  end
  if self.m_renderers then
    for _, rs in pairs(self.m_renderers) do
      rs.enabled = v
    end
  end
  if self.m_uiHpHandle then
    if v == true then
      self.m_uiHpHandle:SetActive(self.showHP)
    else
      self.m_uiHpHandle:SetActive(false)
    end
  end
  if self.m_topIcon then
    self.m_topIcon:SetActive(v)
  end
  if self.mECFabaoComponent then
    self.mECFabaoComponent:SetVisible(v)
  end
  if self.mECWingComponent then
    self.mECWingComponent:SetVisible(v)
  end
  if self.mECPartComponent then
    self.mECPartComponent:SetVisible(v)
  end
  if self.m_commandPanel then
    self.m_commandPanel:SetActive(v)
  end
  if visible and self.m_ani then
    self.m_ani.enabled = false
    self.m_ani.enabled = true
  end
end
def.override().OnClick = function(self)
  ECRoleModel.OnClick(self)
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SELECT_TARGET, {
    self.fighterId
  })
end
def.override().OnLongTouch = function(self)
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LONG_TOUCH_TARGET, {
    self.fighterId,
    self
  })
end
def.override().OnLoadGameObject = function(self)
  local model = self.m_model
  if model == nil then
    warn("[Fight]model is nil for res path: ", self.m_resName)
    return
  end
  if self.m_color then
    self:SetModelColor(self.m_color)
  else
    self:SetColoration(nil)
  end
  model:SetLayer(self.defaultLayer)
  model.localPosition = Map2DPosTo3D(self.m_node2d.localPosition.x, self.m_node2d.localPosition.y)
  model.localRotation = Quaternion.Euler(EC.Vector3.new(0, self.m_ang, 0))
  self:SetOrnament(false)
  if self.attachModelInfo then
    SetModelExtra(self, self.attachModelInfo)
  end
  self:SetTouchable(true)
  local ECPate = require("GUI.ECPate")
  local pate = ECPate.new()
  pate:CreateNameBoard(self)
  pate:CreateHpBoard(self)
  pate:CreateTopBoard(self, nil)
  pate:CreateFightBuffBoard(self)
  self:SetHp(self.hp)
  self:SetStance()
  pate:CreateSelectBoard(self)
  if not self.showModel then
    self:SetShowModel(self.showModel)
  end
  pate:CreateCommandBoard(self)
  self:DoOnLoadCallback()
  if 0 < self.m_roleType then
    Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.MODEL_LOADED, {
      id = self.fighterId,
      model = self
    })
  end
end
def.method("table").LoadModelInfo = function(self, modelInfo)
  if self.m_model then
    SetModelExtra(self, modelInfo)
    if self.m_model.localScale.x ~= 1 then
      self:ResetHpPate()
    end
  else
    self.attachModelInfo = modelInfo
  end
end
def.method().ResetModelPos = function(self)
  if _G.IsNil(self.m_model) or _G.IsNil(self.m_model.parent) then
    return
  end
  local root = self.m_model:FindChild("Root/Bip01 Pelvis")
  if root == nil then
    return
  end
  local pos = root.position - self.m_model.parent.position
  local x, y = WorldPosTo2D(pos)
  self:SetPos(x, y)
end
def.method().ResetHpPate = function(self)
  if self.m_uiHpHandle == nil then
    return
  end
  local hud = self.m_uiHpHandle
  local follow = hud:GetComponent("HUDFollowTarget")
  local offsetH = self:GetBoxHeight() * self.m_model.localScale.x + 0.4
  follow.offset = EC.Vector3.new(0, offsetH, 0)
end
def.method("number").LoadWing = function(self, wingId)
  if self.mECWingComponent == nil then
    self.mECWingComponent = ECWingComponent.new(self)
  end
  self.mECWingComponent:LoadRes(wingId)
end
def.override().SetStance = function(self)
  if self.m_model == nil or self.m_model.isnil then
    return
  end
  if self.m_roleType == 0 then
    self:Play(ActionName.Stand)
  elseif not self.isDead then
    self:Play(self.stand_stance)
  else
    self:PlayAnimAtTime(ActionName.Death1, 1)
    if self.mECWingComponent then
      self.mECWingComponent:Death()
    end
  end
end
def.method().Stand = function(self)
  self:Play(self.stand_stance)
  if self.mECWingComponent then
    self.mECWingComponent:Stand()
  end
end
local t_pos = EC.Vector3.new(0, 0, 0)
def.override("number", "number").SetPos = function(self, x, y)
  local model = self.m_model
  if model then
    model.localPosition = Map2DPosTo3D(x, y)
  end
  self.m_node2d.localPosition = t_pos:Assign(x, y, 0)
end
def.method("number", "number", "function", "number", "boolean", "number").MoveTo = function(self, x, y, callback, duration, bSetDir, type)
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
  move:MoveTo(self.m_node2d, x, y, duration, bSetDir, type)
end
def.method().StopMoving = function(self)
  if self.m_model == nil then
    return
  end
  local move = self.m_model:GetComponent("CommonMove")
  if move then
    Object.Destroy(move)
  end
end
def.method("number").SetHp = function(self, hp)
  self.hp = hp
  if self.m_uiHpHandle == nil or self.m_uiHpHandle:get_isnil() then
    return
  end
  if not self.showHP then
    self.m_uiHpHandle:SetActive(false)
    return
  end
  self.m_uiHpHandle:SetActive(true)
  local bar = self.m_uiHpHandle:FindChild("Prog_HP")
  local slider = bar:GetComponent("UISlider")
  slider.value = hp
  bar:FindChild("Foreground_HP"):SetActive(hp > 0)
end
def.method("number").SetMp = function(self, mp)
  self.mp = mp
  if self.m_uiHpHandle == nil or self.m_uiHpHandle.isnil then
    return
  end
  if not self.showHP then
    self.m_uiHpHandle:SetActive(false)
    return
  end
  self.m_uiHpHandle:SetActive(true)
  local bar = self.m_uiHpHandle:FindChild("Prog_MP")
  local slider = bar:GetComponent("UISlider")
  slider.value = mp
  bar:FindChild("Foreground_MP"):SetActive(mp > 0)
end
def.method("boolean").ShowMpBar = function(self, v)
  if self.m_uiHpHandle == nil or self.m_uiHpHandle.isnil then
    return
  end
  local bar = self.m_uiHpHandle:FindChild("Prog_MP")
  bar:SetActive(v)
end
def.method("boolean").SetHpVisible = function(self, v)
  self.showHP = v
  if self.m_uiHpHandle == nil then
    return
  end
  self.m_uiHpHandle:SetActive(v)
end
def.method("number", "number").ShowTitleIcon = function(self, iconId, duration)
  if self.m_topIcon == nil then
    self.topIcons = {}
    self.topIcons.id = iconId
    self.topIcons.duration = duration
    return
  end
  if duration <= 0 then
    duration = FightModel.Label_Time_Type.PERMANENT
  end
  self.labelTime = duration
  self:SetTitleIcon(iconId)
end
def.method("number").SetTitleIcon = function(self, iconId)
  if self.m_topIcon == nil then
    return
  end
  local icon = self.m_topIcon:FindChild("Img_Chengwei")
  if icon == nil then
    return
  end
  if iconId == 0 then
    if self.titleIcon == 0 then
      self.labelTime = FightModel.Label_Time_Type.TIMEOUT
      icon:SetActive(false)
      return
    else
      iconId = self.titleIcon
      self.labelTime = FightModel.Label_Time_Type.PERMANENT
    end
  end
  icon.localScale = EC.Vector3.new(2, 2, 2)
  icon.localPosition = EC.Vector3.new(0, 20, 0)
  local uiTexture = icon:GetComponent("UITexture")
  local bundlePath = GetIconPath(iconId)
  if bundlePath == nil or bundlePath == "" then
    warn("[Fight]Title icon path is nil or empty for id: ", iconId)
    return
  end
  GameUtil.AsyncLoad(bundlePath, function(tex)
    if self.labelTime == FightModel.Label_Time_Type.TIMEOUT then
      return
    end
    if tex then
      if uiTexture and not uiTexture:get_isnil() then
        uiTexture.mainTexture = tex
        icon:SetActive(true)
        local widget = icon:GetComponent("UIWidget")
        widget.width = tex.width / 2
        widget.height = tex.height / 2
      end
    else
      warn(bundlePath .. " load fail")
    end
  end)
end
def.method("number").SetFlagIcon = function(self, iconId)
end
def.override("number").Update = function(self, ticks)
  ECRoleModel.Update(self, ticks)
  if self.mECWingComponent then
    self.mECWingComponent:Update(ticks)
  end
  self:UpdateDissolve(ticks)
  self:UpdateShatter(ticks)
  if self.labelTime < 0 then
    return
  end
  self.labelTime = self.labelTime - ticks
  if self.labelTime <= 0 then
    self.labelTime = FightModel.Label_Time_Type.TIMEOUT
    self:SetTitleIcon(0)
  end
end
def.override("number").SetAlpha = function(self, val)
  ECRoleModel.SetAlpha(self, val)
  if self.mECPartComponent then
    self.mECPartComponent:SetAlpha(val)
  end
  if self.mECWingComponent then
    self.mECWingComponent:SetAlpha(val)
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
end
def.override().CloseAlpha = function(self)
  ECRoleModel.CloseAlpha(self)
  if self.mECPartComponent then
    self.mECPartComponent:CloseAlpha()
  end
  if self.mECWingComponent then
    self.mECWingComponent:CloseAlpha()
  end
end
def.method("string", "number", "=>", "userdata").AddEffect = function(self, effectPath, part)
  local pos
  if self.m_model then
    pos = EC.Vector3.new(self.m_model.localPosition.x, self.m_model.localPosition.y + self:GetBodyPartHeight(part), self.m_model.localPosition.z)
  elseif self.m_node2d then
    pos = self.m_node2d.localPosition
    pos = Map2DPosTo3D(pos.x, world_height - pos.y)
  end
  return require("Main.Fight.FightMgr").Instance():PlayEffect(effectPath, nil, pos, Quaternion.identity)
end
def.method("string", "number", "number", "=>", "userdata").AddChildEffect = function(self, effectPath, part, rotationOffset)
  if self.m_model == nil then
    return nil
  end
  local offset = self:GetBodyPartHeight(part)
  local pos = EC.Vector3.new(0, offset, 0)
  local rotation = Quaternion.identity
  if rotationOffset ~= 0 then
    rotation = Quaternion.Euler(EC.Vector3.new(0, rotationOffset, 0))
  end
  local fx = require("Main.Fight.FightMgr").Instance():PlayEffect(effectPath, self.m_model, pos, rotation)
  if fx == nil then
    warn("can not request effect: " .. effectPath)
    return nil
  end
  return fx
end
def.method("string", "number", "=>", "userdata").AddEffectWithOffset = function(self, effectPath, offset)
  if self.m_node2d == nil then
    return
  end
  local pos = self.m_node2d.localPosition
  pos.y = pos.y + offset
  local effpos = Map2DPosTo3D(pos.x, world_height - pos.y)
  return require("Main.Fight.FightMgr").Instance():PlayEffect(effectPath, nil, effpos, Quaternion.identity)
end
def.method("string", "number", "=>", "userdata").AddEffectWithRotation = function(self, effectPath, part)
  local pos
  local model = self.m_model
  if model == nil then
    return nil
  end
  if model then
    pos = EC.Vector3.new(self.m_model.localPosition.x, self.m_model.localPosition.y + self:GetBodyPartHeight(part), self.m_model.localPosition.z)
  else
    pos = Map2DPosTo3D(self.m_node2d.localPosition.x, world_height - self.m_node2d.localPosition.y)
  end
  if pos == nil then
    warn("effect pos is nil: " .. effectPath)
    return nil
  end
  return require("Main.Fight.FightMgr").Instance():PlayEffect(effectPath, nil, pos, self.m_model.localRotation)
end
def.method("number", "=>", "number").GetBodyPartHeight = function(self, part)
  if self.m_model == nil then
    return 0
  end
  local bc = self.m_model:GetComponent("BoxCollider")
  if bc then
    if part == AttachType.BODY then
      return bc.size.y / 2
    elseif part == AttachType.HEAD then
      return bc.size.y + 0.5
    end
  end
  return 0
end
def.method("userdata", "function").Dissolve = function(self, color, cb)
  self.dissolveColor = color
  self:SetDissolve()
  self.dissolveDuration = 1.5
  self.dissolveTime = 0
  self.endCallback = cb
end
def.method("number").UpdateDissolve = function(self, dt)
  if self.dissolveTime < 0 then
    return
  end
  self.dissolveTime = self.dissolveTime + dt
  if self.dissolveTime > self.dissolveDuration then
    self.dissolveTime = self.dissolveDuration
  end
  local dv = 2.5 * (1 - self.dissolveTime / self.dissolveDuration)
  if dv < 0 then
    dv = 0
  end
  self:ChangeDissolve(dv)
  if dv == 0 then
    self.dissolveTime = -1
    self.dissolveColor = nil
    self:ResetAllRenders()
    if self.endCallback then
      self.endCallback()
      self.endCallback = nil
      self.dissolveColor = nil
    end
  end
end
def.method().SetDissolve = function(self)
  if self.m_model == nil then
    return
  end
  ECRoleModel.ResetShaders(self)
  self:GetAllRenders()
  for i = 1, #self.renders do
    local render = self.renders[i]
    if render ~= nil and not render.isnil then
      local srcMat = render.material
      if srcMat ~= nil and render.gameObject.name ~= "characterShadow" and string.find(srcMat.shader.name, "/Character") then
        local oldName = srcMat.shader.name
        local shaderName
        local s, e = string.find(oldName, "_Transparent")
        if s then
          shaderName = string.sub(oldName, 1, s) .. "Dissolve"
        else
          shaderName = "Hidden/" .. oldName .. "_Dissolve"
        end
        local newShader = ECModel.dissolveShaderList[shaderName]
        if newShader ~= nil then
          srcMat.shader = newShader
          srcMat:SetTexture("_DissolveTex", ECModel.dissolvesTexture.tex)
          srcMat:SetTexture("_DissolveRam", ECModel.dissolvesTexture.ramTex)
          srcMat:SetColor("_DissolveColor", self.dissolveColor)
          srcMat:SetFloat("_DissolveAmount", 2.5)
        else
          warn("set dissolve shader failed: ", shaderName)
        end
      end
    end
  end
end
def.method("number").ChangeDissolve = function(self, val)
  if self.m_model == nil or self.renders == nil then
    return
  end
  for i = 1, #self.renders do
    local render = self.renders[i]
    if render ~= nil and not render.isnil then
      local srcMat = render.material
      if srcMat ~= nil then
        srcMat:SetFloat("_DissolveAmount", val)
      end
    end
  end
end
def.method("number", "number", "number", "function").Shatter = function(self, f, a, duration, cb)
  self:SetShatter(f, a)
  self.shatterDuration = duration
  self.shatterTime = 0
  self.endCallback = cb
end
def.method("number").UpdateShatter = function(self, dt)
  if self.shatterTime < 0 then
    return
  end
  self.shatterTime = self.shatterTime + dt
  if self.shatterTime > self.shatterDuration then
    self.shatterTime = self.shatterDuration
  end
  local dv = 1 - self.shatterTime / self.shatterDuration
  if dv < 0 then
    dv = 0
  end
  if self.renders then
    for i = 1, #self.renders do
      local render = self.renders[i]
      if render ~= nil and not render.isnil then
        local srcMat = render.material
        if srcMat ~= nil then
          srcMat:SetFloat("_Transparent", dv)
        end
      end
    end
  end
  if dv == 0 then
    self.shatterTime = -1
    self:ResetAllRenders()
    if self.endCallback then
      self.endCallback()
      self.endCallback = nil
    end
  end
end
def.method("number", "number").SetShatter = function(self, f, a)
  if self.m_model == nil then
    return
  end
  self:GetAllRenders()
  for i = 1, #self.renders do
    local render = self.renders[i]
    if render ~= nil and not render.isnil then
      local srcMat = render.material
      if srcMat ~= nil and render.gameObject.name ~= "characterShadow" and string.find(srcMat.shader.name, "/Character") then
        local oldName = srcMat.shader.name
        local shaderName
        local s, e = string.find(oldName, "_Transparent")
        if s then
          shaderName = string.sub(oldName, 1, s) .. "Distortion"
        else
          shaderName = "Hidden/" .. oldName .. "_Distortion"
        end
        local newShader = ECModel.dissolveShaderList[shaderName]
        if newShader ~= nil then
          srcMat.shader = newShader
          srcMat:SetFloat("_WavePower", f)
          srcMat:SetFloat("_WaveFreq", a)
        else
          warn("set dissolve shader failed: ", oldName, shaderName)
        end
      end
    end
  end
end
def.override().SetPate = function(self)
  if self.m_topIcon then
    local follow = self.m_topIcon:GetComponent("HUDFollowTarget")
    follow.offset = EC.Vector3.new(0, 2.4, 0)
    if self.topIcons then
      self:ShowTitleIcon(self.topIcons.id, self.topIcons.duration)
      self.topIcons = nil
    end
  end
end
def.method().GetAllRenders = function(self)
  self.renders = {}
  if self.m_renderers == nil then
    return
  end
  for i = 1, #self.m_renderers do
    table.insert(self.renders, self.m_renderers[i])
  end
  if self.mECPartComponent then
    if self.mECPartComponent.rightHand and self.mECPartComponent.rightHand.m_model and not self.mECPartComponent.rightHand.m_model.isnil and self.mECPartComponent.rightHand.m_renderers then
      for i = 1, #self.mECPartComponent.rightHand.m_renderers do
        local r = self.mECPartComponent.rightHand.m_renderers[i]
        if r and not r.isnil then
          table.insert(self.renders, r)
        end
      end
    end
    if self.mECPartComponent.leftHand and self.mECPartComponent.leftHand.m_model and not self.mECPartComponent.leftHand.m_model.isnil and self.mECPartComponent.leftHand.m_renderers then
      for i = 1, #self.mECPartComponent.leftHand.m_renderers do
        local r = self.mECPartComponent.leftHand.m_renderers[i]
        if r and not r.isnil then
          table.insert(self.renders, r)
        end
      end
    end
  end
end
def.method().ResetAllRenders = function(self)
  self:ResetShaders()
  if self.mECPartComponent then
    if self.mECPartComponent.rightHand then
      self.mECPartComponent.rightHand:ResetShaders()
    end
    if self.mECPartComponent.leftHand then
      self.mECPartComponent.leftHand:ResetShaders()
    end
  end
  self.renders = nil
end
def.method("string").SetCommand = function(self, cmdstr)
  if self.m_commandPanel == nil or self.m_commandPanel.isnil then
    return
  end
  self.m_commandPanel:FindDirect("Pate/Label_ZhiHui"):SetActive(true)
  self.m_commandPanel:FindDirect("Pate/Label_ZhiHui"):GetComponent("UILabel").text = cmdstr
end
def.method().RemoveCommand = function(self)
  if self.m_commandPanel == nil or self.m_commandPanel.isnil then
    return
  end
  self.m_commandPanel:FindDirect("Pate/Label_ZhiHui"):SetActive(false)
end
def.method("number").SetFormationNumber = function(self, num)
  if self.m_commandPanel == nil or self.m_commandPanel.isnil then
    return
  end
  self.m_commandPanel:FindDirect("Pate/Label_Num"):SetActive(true)
  self.m_commandPanel:FindDirect("Pate/Label_Num"):GetComponent("UILabel").text = num
end
def.method().RemoveFormationNumber = function(self)
  if self.m_commandPanel == nil or self.m_commandPanel.isnil then
    return
  end
  self.m_commandPanel:FindDirect("Pate/Label_Num"):SetActive(false)
end
def.method().DetachShadow = function(self)
  if self.m_model == nil then
    return
  end
  if self.mShadowObj == nil then
    self.mShadowObj = self.m_model:FindDirect("characterShadow")
  end
  if self.mShadowObj then
    self.mShadowObj.transform.parent = self.m_model.transform.parent
    self.mShadowObj.localPosition = self.m_model.localPosition
  end
end
def.method("=>", "boolean").DetachFlyMount = function(self)
  if self.flyMountModel and not self.flyMountModel.isnil and self.m_model and not self.m_model.isnil then
    self.flyMountModel.transform.parent = self.m_model.transform.parent
    self.flyMountModel.localPosition = self.m_model.localPosition
    local comp = self.m_model:GetComponent("FlyFightTweener")
    if comp then
      comp.enabled = false
      local tw = self.flyMountModel:AddComponent("FlyFightTweener")
      tw:Init(comp.time)
    end
    return true
  end
  return false
end
def.method().AttachShadow = function(self)
  if self.m_model == nil then
    return
  end
  if self.mShadowObj then
    self.mShadowObj.transform.parent = self.m_model.transform
    self.mShadowObj.localPosition = EC.Vector3.zero
  end
end
def.method("=>", "boolean").AttachFlyMount = function(self)
  if self.flyMountModel and not self.flyMountModel.isnil and self.m_model and not self.m_model.isnil then
    self.flyMountModel.transform.parent = self.m_model.transform
    self.flyMountModel.localPosition = EC.Vector3.zero
    local comp = self.flyMountModel:GetComponent("FlyFightTweener")
    local tw = self.m_model:GetComponent("FlyFightTweener")
    if tw then
      tw.enable = true
    else
      tw = self.m_model:AddComponent("FlyFightTweener")
      tw:Init(comp.time)
    end
    Object.Destroy(comp)
    return true
  end
  return false
end
def.override("=>", "number").GetFeijianId = function(self)
  if self.initModelInfo then
    return self.initModelInfo.extraMap[self.initModelInfo.AIRCRAFT] or 0
  end
  return 0
end
def.method().AddSelectEffect = function(self)
  local effcfg = GetEffectRes(FightConst.SELECT_EFFECT)
  if effcfg then
    self:AddChildEffect(effcfg.path, AttachType.FOOT, 0)
  end
end
def.override("number", "number").SetWeapon = function(self, id, lightLevel)
  SetModelWeapon(self, id, lightLevel)
end
def.override("number").SetWeaponColor = function(self, lv)
  SetModelWeaponColor(self, lv)
end
def.override("number", "number").SetWing = function(self, id, dyeId)
  if self.mECWingComponent == nil then
    local ECWingComponent = require("Model.ECWingComponent")
    self.mECWingComponent = ECWingComponent.new(self)
  end
  if self.mECWingComponent then
    if id > 0 then
      self.mECWingComponent:LoadRes(id, dyeId)
    else
      self.mECWingComponent:Destroy()
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
def.method("table").SetBuff = function(self, buffs)
  if self.m_buffPanel == nil then
    return
  end
  local uiPanel = self.m_buffPanel:FindDirect("Pate/Grid")
  if uiPanel == nil then
    return
  end
  local uiGrid = uiPanel:GetComponent("UIGrid")
  local template = uiPanel:FindDirect("BuffIcon")
  template:SetActive(false)
  local newBuff = {}
  for _, v in pairs(buffs) do
    local buffPanelName = string.format("BuffIcon_%d", v)
    local buffPanel = uiPanel:FindDirect(buffPanelName)
    if buffPanel == nil then
      buffPanel = Object.Instantiate(template)
      buffPanel.name = buffPanelName
      uiGrid:AddChild(buffPanel.transform)
      buffPanel.localScale = EC.Vector3.one
    end
    buffPanel:SetActive(true)
    if self.uiBuffEffects == nil or self.uiBuffEffects[v] == nil then
      newBuff[v] = {parent = buffPanel}
      local effpath = self:GetBuffPath(v)
      if effpath ~= "" then
        do
          local effkey = v
          local function OnLoadEffect(obj)
            if self.m_model == nil then
              return
            end
            local effdata = newBuff[effkey]
            if effdata == nil or _G.IsNil(effdata.parent) then
              return
            end
            local eff = Object.Instantiate(obj, "GameObject")
            eff:SetLayer(ClientDef_Layer.PateText, true)
            eff.parent = effdata.parent
            eff.localPosition = EC.Vector3.zero
            eff.localScale = EC.Vector3.one
            effdata.obj = eff
          end
          GameUtil.AsyncLoad(effpath, OnLoadEffect)
        end
      end
    else
      newBuff[v] = self.uiBuffEffects[v]
    end
  end
  if self.uiBuffEffects then
    for k, v in pairs(self.uiBuffEffects) do
      if newBuff[k] == nil then
        if v.obj and not v.obj.isnil then
          v.obj:Destroy()
        end
        if v.parent and not v.parent.isnil then
          uiGrid:RemoveChild(v.parent.transform)
          v.parent:Destroy()
        end
        self.uiBuffEffects[k] = nil
        uiGrid.repositionNow = true
      end
    end
  end
  self.uiBuffEffects = newBuff
  uiGrid:Reposition()
end
def.method("number", "=>", "string").GetBuffPath = function(self, effType)
  local effId = 0
  if effType == UIEffectType.ATK_UP then
    effId = 702017201
  elseif effType == UIEffectType.ATK_DOWN then
    effId = 702017202
  elseif effType == UIEffectType.DEF_UP then
    effId = 702017203
  elseif effType == UIEffectType.DEF_DOWN then
    effId = 702017204
  elseif effType == UIEffectType.SPEED_UP then
    effId = 702017205
  elseif effType == UIEffectType.SPEED_DOWN then
    effId = 702017206
  end
  if effId > 0 then
    local effcfg = GetEffectRes(effId)
    return effcfg.path
  else
    return ""
  end
end
def.method("number").RemoveBuffEffect = function(self, id)
  if self.uiBuffEffects == nil then
    return
  end
  local eff = self.uiBuffEffects[id]
  local effobj = eff and eff.obj
  if effobj then
    effobj:Destroy()
  end
  self.uiBuffEffects[id] = nil
end
def.method().RemoveAllBuffEffect = function(self)
  if self.uiBuffEffects == nil then
    return
  end
  for k, v in pairs(self.uiBuffEffects) do
    if v.obj then
      v.obj:Destroy()
    end
  end
  self.uiBuffEffects = nil
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
def.method("string", "userdata", "=>", FightModel).Clone = function(self, name, nameColor)
  if self.m_asset == nil or self.m_asset.isnil then
    return nil
  end
  local ret = FightModel.new(self.mModelId, name, nameColor, self.m_roleType)
  local m = Object.Instantiate(self.m_asset, "GameObject")
  ret.m_model = m
  ret.m_asset = GameUtil.CloneUserData(self.m_asset)
  ret.m_ani = m:GetComponentInChildren("Animation")
  ret.m_status = ModelStatus.NORMAL
  ret.m_resName = self.m_resName
  ret.m_renderers = m:GetRenderersInChildren()
  ret.m_visible = true
  ret.showModel = true
  ret.m_model.localRotation = self.m_model.localRotation
  ret.m_model.localScale = m.localScale
  ret.m_title = self.m_title
  ret.m_showTitle = self.m_showTitle
  ret:InitOriginalModelInfo()
  ret.m_model:SetLayer(self.defaultLayer)
  ret.srcShaders = {}
  local rs = ret.m_renderers
  local shadowRenderIdx
  for i = 1, #rs do
    local render = rs[i]
    if render.gameObject.name == "characterShadow" then
      shadowRenderIdx = i
    else
      local srcMat = render:get_material()
      ret.srcShaders[render.gameObject.name] = srcMat.shader
    end
  end
  if shadowRenderIdx then
    table.remove(ret.m_renderers, shadowRenderIdx)
  end
  ret.parentNode = self.parentNode
  ret.defaultParentNode = self.defaultParentNode
  if self.m_node2d then
    ret.m_node2d = GameObject.GameObject("node2d_" .. tostring(self.mModelId))
  end
  if ret.parentNode then
    local tran = ret.parentNode.transform
    ret.m_model.transform.parent = tran
    if ret.m_node2d ~= nil then
      ret.m_node2d.transform.parent = tran
    end
  end
  if ret.m_node2d ~= nil then
    if not ret.m_IsTouchable then
      local box = ret.m_model:GetComponent("BoxCollider")
      if box then
        box.enabled = false
      end
    else
      GameUtil.AddECObjectComponent(ret, ret.m_model, false)
    end
  end
  return ret
end
FightModel.Commit()
return FightModel

local _Debug = false
local function log(...)
  if _Debug then
    print("[SelectRolePanel]: ", ...)
  end
end
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SelectRolePanel = Lplus.Extend(ECPanelBase, "SelectRolePanel")
local def = SelectRolePanel.define
local LoginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
local LoginModuleClass = require("Main.Login.LoginModule")
local LoginUtility = require("Main.Login.LoginUtility")
local ECUIModel = require("Model.ECUIModel")
local GUIUtils = require("GUI.GUIUtils")
local EC = {}
EC.Vector3 = require("Types.Vector3").Vector3
def.const("number").MAX_ROLE_NUM = 3
def.field("table").modelList = nil
def.field("table").preModelList = nil
def.field("boolean").isDrag = false
def.field("number").dragDistance = 0
def.field("number").modelCount = 0
def.field("boolean").modelLoaded = false
def.field("userdata").selectedRoleId = nil
def.field("table").modelSwitchData = nil
def.field("table").modelPosData = nil
def.field("boolean").isTweening = false
def.field("boolean").needMoreTrans = false
def.field("string").nextTransModelName = ""
def.field("userdata").bgScene = nil
def.field("userdata").m_BGCameraObj = nil
def.field("userdata").m_selectRoleScene = nil
def.field("number").animatedTime = 12
def.field("number").timerId = 0
def.field("boolean").isLoging = false
def.field("table").uiObjs = nil
local instance
def.static("=>", SelectRolePanel).Instance = function()
  if instance == nil then
    instance = SelectRolePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  Time.timeScale = 1
  if self.m_panel then
    self:DestroyPanel()
  end
  self:AsyncLoadBackground()
  self:CreatePanel(RESPATH.PREFAB_LOGIN_SELECT_ROLE_PANEL_RES, 1)
  require("Main.Login.LoginUtility").Preload()
  require("Main.ECGame").Instance():SetGameState(_G.GameState.ChooseRole)
end
def.override().OnCreate = function(self)
  Time.timeScale = 1
  LoginUtility.DestroyLoginBackground()
  LoginUtility.HideWorldRelated()
  self:Init()
  self:AsyncLoadModels()
  self.timerId = GameUtil.AddGlobalTimer(self.animatedTime, false, function()
    self:Update()
  end)
  self:SetBackground()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_SUCCESS, SelectRolePanel.OnLoginRoleSucess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ROLE_INFO_UPDATE, SelectRolePanel.OnRoleInfoUpdate)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, SelectRolePanel.OnResetUI)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_SUCCESS, SelectRolePanel.OnLoginRoleSucess)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ROLE_INFO_UPDATE, SelectRolePanel.OnRoleInfoUpdate)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, SelectRolePanel.OnResetUI)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
  self:Clear()
end
def.override("=>", "boolean").OnMoveBackward = function(self)
  self:onClick("Btn_Back")
  return true
end
def.method("string").onClick = function(self, id)
  if id == "Btn_LoadIn" then
    self:OnStartGameButtonClick()
  elseif id == "Btn_Back" then
    self:OnBackButtonClick()
  elseif id == "Btn_Creat" then
    self:OnCreateRoleButtonClick()
  elseif id == "Btn_Delete" then
    self:OnDeleteRoleButtonClick()
  elseif string.sub(id, 1, 6) == "Model_" then
    local model = self.m_panel:FindChild(id)
    local root = model.transform.parent.parent.parent.gameObject
    local index = tonumber(string.sub(root.name, -1, -1))
    self:OnRoleSelected(id)
  end
end
def.method("string", "string").onTweenerFinish = function(self, id, id2)
  print("onTweenerFinish", self, id, id2)
end
def.method().Init = function(self)
  self.uiObjs = {}
  self.modelCount = 0
  self.isTweening = false
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Character_Root = Img_Bg0:FindDirect("Character_Root")
  self.uiObjs.Character_Root = Character_Root
  self.uiObjs.charRoots = {}
  local charTemplate
  for i = 1, SelectRolePanel.MAX_ROLE_NUM do
    local rooti = Character_Root:FindDirect("Character_Root_" .. i)
    local char = rooti:FindDirect("Character_" .. i)
    if char then
      charTemplate = char
    else
      char = GameObject.Instantiate(charTemplate)
      char.name = "Character_" .. i
      char.transform.parent = rooti.transform
      char.transform.localPosition = EC.Vector3.zero
      char.transform.localScale = EC.Vector3.one
    end
    self.uiObjs.charRoots[i] = rooti
    GUIUtils.SetActive(char:FindDirect("Img_BgName"), false)
    GUIUtils.SetActive(char:FindDirect("Img_School"), false)
    GUIUtils.SetActive(char:FindDirect("UIParticleContainer"), false)
    GUIUtils.SetActive(char:FindDirect("Img_BgName/UI_Panel_ChooseCharecter_JueSeXuanZhong"), false)
  end
  for i = 1, SelectRolePanel.MAX_ROLE_NUM do
    local rooti = Character_Root:FindDirect("Character_Root_" .. i)
    local char = rooti:FindDirect("Character_" .. i)
    local Img_Bg = char:FindDirect("Img_Bg")
    Img_Bg:GetComponent("UISprite").enabled = false
    Img_Bg:FindDirect("Model").name = "Model_" .. i
  end
  local roleList = LoginModule:GetRoleList()
  local lastLoginRole = LoginModule:GetLastLoginRole()
  self.selectedRoleId = lastLoginRole.roleid
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().Clear = function(self)
  if self.modelList ~= nil then
    for k, v in pairs(self.modelList) do
      if v.model then
        local m = v.model.m_model
        if m then
          local pedestal = m:FindDirect("pedestal")
          if pedestal then
            GameObject.Destroy(pedestal)
          end
        end
        v.model:Destroy()
      end
    end
  end
  self:DestroySelectRoleScene()
  self.modelList = nil
  self.bgScene = nil
  self.modelLoaded = false
  self.animatedTime = 12
  self.isLoging = false
  self.modelPosData = nil
  self.uiObjs = nil
end
def.method().AsyncLoadModels = function(self)
  local roleList = LoginModule:GetRoleList()
  self.preModelList = {}
  local roleAmount = #roleList
  self.modelCount = roleAmount
  for i, role in ipairs(roleList) do
    do
      local modelPath, modelId = LoginUtility.GetCreateRoleModelPath(role.basic.occupation, role.basic.gender)
      local model = ECUIModel.new(modelId)
      self.preModelList[role.roleid] = model
      local function OnLoaded(ret)
        if self.m_panel == nil then
          return
        end
        local m = model.m_model
        local ani = m:GetComponent("Animation")
        if ani then
          ani.cullingType = AnimationCullingType.AlwaysAnimate
        end
        model:SetDir(180)
        model:SetPos(0, 0)
        model:Play("Stand_c")
        self:AddRoleModel(i, role)
      end
      _G.LoadModelWithCallBack(model, role.modelInfo, false, false, OnLoaded)
    end
  end
end
def.method().AsyncLoadBackground = function(self)
  local resPath = RESPATH.PREFAB_SELECT_ROLE_DYNAMIC_BG_RES
  GameUtil.AsyncLoad(resPath, function(ass)
    if ass == nil then
      return
    end
    self.bgScene = GameObject.Instantiate(ass)
    if self:IsShow() then
      self:SetBackground()
    end
  end)
end
def.method().SetBackground = function(self)
  if self.bgScene == nil then
    return
  end
  self.m_selectRoleScene = GameObject.GameObject("SelectRoleScene")
  self.m_selectRoleScene.transform.parent = nil
  self.m_selectRoleScene.transform.localPosition = EC.Vector3.new(-200, 0, 0)
  self.bgScene.transform.parent = self.m_selectRoleScene.transform
  self.bgScene.transform.localPosition = EC.Vector3.zero
  self.bgScene.transform.localScale = EC.Vector3.one
  self.bgScene.transform.localRotation = Quaternion.Euler(EC.Vector3.new(0, 180, 0))
  self.bgScene:SetLayer(_G.ClientDef_Layer.Building)
  GUIUtils.ScaleToNoBorder(self.bgScene, 2)
  self:SetBGCamera()
  GUIUtils.SetActive(self.m_panel:FindDirect("Texture_Bg1"), false)
  self.uiObjs.Character_Root.transform.localPosition = EC.Vector3.new(20, -20, 0)
end
def.method().SetBGCamera = function(self)
  local camobj = GameObject.GameObject("BGCamera")
  local cam = camobj:AddComponent("Camera")
  cam.clearFlags = CameraClearFlags.Depth
  cam.orthographic = true
  cam.orthographicSize = 2.54
  cam.nearClipPlane = -30
  cam.farClipPlane = 10
  cam.depth = 1
  cam:set_cullingMask(get_cull_mask(ClientDef_Layer.Building))
  camobj.transform.parent = self.m_selectRoleScene.transform
  camobj.localPosition = EC.Vector3.new(0, 2.55, 0)
  camobj.localRotation = Quaternion.Euler(EC.Vector3.new(0, 0, 0))
  self.m_BGCameraObj = camobj
end
def.method().DestroySelectRoleScene = function(self)
  if self.m_BGCameraObj then
    GameObject.Destroy(self.m_BGCameraObj)
    self.m_BGCameraObj = nil
  end
  if self.bgScene then
    GameObject.Destroy(self.bgScene)
    self.bgScene = nil
  end
  if self.m_selectRoleScene then
    GameObject.Destroy(self.m_selectRoleScene)
    self.m_selectRoleScene = nil
  end
end
def.method("number", "table").AddRoleModel = function(self, index, role)
  if self.m_panel == nil then
    return
  end
  local uiModel = self:GetUIModelObject(index)
  local angle = 12
  uiModel.mDepressionAngle = angle
  if uiModel.mCanOverflow ~= nil then
    uiModel.mCanOverflow = true
    local camera = uiModel:get_modelCamera()
    camera:set_orthographic(true)
    camera.transform.localRotation = Quaternion.Euler(EC.Vector3.new(angle, 0, 0))
  end
  local model = self.preModelList[role.roleid]
  uiModel.modelGameObject = model.m_model
  self.preModelList[role.roleid] = nil
  self:SetRoleInfo(index, role)
  self.modelList = self.modelList or {}
  self.modelList[uiModel.gameObject.name] = {
    model = model,
    roleId = role.roleid
  }
  self.modelPosData = self.modelPosData or {}
  self.modelPosData[index] = uiModel.gameObject.name
  if index == 1 then
    local audioId = require("Main.Login.data.AudioData").GetRoleAudio(role.basic.occupation, role.basic.gender)
    require("Sound.ECSoundMan").Instance():Play2DInterruptSoundByID(audioId)
    self:UpdateDelBtnText()
    self:FocusOnCharRoot(index)
  end
end
def.method("number", "table").SetRoleInfo = function(self, index, role)
  local content = string.format(textRes.Common[3] .. " %s", role.basic.level, role.basic.name)
  local char = self.m_panel:FindChild("Character_Root_" .. index)
  char:FindChild("Img_BgName"):SetActive(true)
  char:FindChild("Label_Name"):GetComponent("UILabel"):set_text(content)
  char:FindChild("Img_School"):SetActive(true)
  local sprite = char:FindChild("Img_School"):GetComponent("UISprite")
  local spriteName = require("Main.Login.LoginUtility").GetOccupationImageSpriteName(role.basic.occupation)
  sprite:set_spriteName(spriteName)
  local Label_Delete = char:FindChild("Label_Delete")
  log("role.delEndtime = ", role.delEndtime)
  if role.delEndtime > 0 then
    Label_Delete:SetActive(true)
    local label = Label_Delete:GetComponent("UILabel")
    local curTime = os.time()
    local delTime = role.delEndtime - (curTime - role.ctime)
    local min = delTime / 60 % 60
    local hour = delTime / 3600 % 24
    local day = math.floor(delTime / 3600 / 24)
    label.text = string.format(textRes.Login[32], day, hour, min)
  else
    Label_Delete:SetActive(false)
  end
end
def.method("number", "=>", "userdata").GetUIModelObject = function(self, num)
  local name = string.format("Model_%d", num, num)
  local uiModel = self.m_panel:FindChild(name):GetComponent("UIModel")
  return uiModel
end
def.method("string").onDragStart = function(self, id)
end
def.method("string").onDragEnd = function(self, id)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.modelList[id] and self.modelList[id].model then
    local model = self.modelList[id].model
    model:SetDir(model.m_ang - dx / 2)
  end
end
def.method().OnStartGameButtonClick = function(self)
  if self.isLoging then
    return
  end
  local roleId = self.selectedRoleId
  local result = LoginModule:LoginRole(roleId)
  if result == LoginModuleClass.CResult.SUCCESS then
    self.isLoging = true
  end
end
def.method().OnBackButtonClick = function(self)
  self:HidePanel()
  LoginModule:Back2Login()
end
def.method().OnCreateRoleButtonClick = function(self)
  local roleNum = #LoginModule:GetRoleList()
  if roleNum < SelectRolePanel.MAX_ROLE_NUM then
    self:HidePanel()
    require("Main.Login.ui.CreateRolePanel").Instance():ShowPanel()
  else
    Toast(textRes.Login[10])
  end
end
def.method().OnDeleteRoleButtonClick = function(self)
  local roleInfo = LoginModule:GetRoleInfo(self.selectedRoleId)
  if roleInfo.delEndtime == 0 then
    if self.isLoging then
      return
    end
    LoginModule:DeleteRole(self.selectedRoleId)
  else
    LoginModule:CancelDeleteRole(self.selectedRoleId)
  end
end
def.method("string").OnRoleSelected = function(self, id)
  if self.modelList == nil then
    return
  end
  local modelInfo = self.modelList[id]
  if modelInfo == nil then
    return
  end
  local index = tonumber(string.sub(id, #"Model_" + 1, -1))
  self:FocusOnCharRoot(index)
  for k, modelInfo in pairs(self.modelList) do
    if k == id then
      modelInfo.model:CrossFade(ActionName.Idle1, 0.2)
      modelInfo.model:CrossFadeQueued(ActionName.Stand, 0.2)
    else
      modelInfo.model:CrossFade(ActionName.Stand, 0.2)
    end
  end
  self.selectedRoleId = modelInfo.roleId
  LoginModule.lastLoginRoleId = self.selectedRoleId
  local roleList = LoginModule:GetRoleList()
  local sRole
  for i, role in ipairs(roleList) do
    if self.selectedRoleId == role.roleid then
      sRole = role
      table.remove(roleList, i)
      table.insert(roleList, 1, role)
      break
    end
  end
  local audioId = require("Main.Login.data.AudioData").GetRoleAudio(sRole.basic.occupation, sRole.basic.gender)
  require("Sound.ECSoundMan").Instance():Play2DInterruptSoundByID(audioId)
  self:UpdateDelBtnText()
end
def.method("number").FocusOnCharRoot = function(self, index)
  for i = 1, SelectRolePanel.MAX_ROLE_NUM do
    local charRoot = self.uiObjs.charRoots[i]
    local char = charRoot:FindDirect("Character_" .. i)
    local fxObjContainer = char:FindDirect("UIParticleContainer")
    local fxObj = char:FindDirect("Img_BgName/UI_Panel_ChooseCharecter_JueSeXuanZhong")
    if i == index then
      GUIUtils.SetActive(fxObjContainer, true)
      GUIUtils.SetActive(fxObj, true)
    else
      GUIUtils.SetActive(fxObjContainer, false)
      GUIUtils.SetActive(fxObj, false)
    end
  end
end
def.method("string").onCommonPlayTweenFinish = function(self, id)
  if id == "Character_Root" then
    for i, v in ipairs(self.modelSwitchData) do
      local fromRoot = self.m_panel:FindChild("Character_Root_" .. v.from)
      local Img_Bg = fromRoot:FindChild("Img_Bg")
      local fromObject = Img_Bg.transform.parent.gameObject
      local toRoot = self.m_panel:FindChild("Character_Root_" .. v.to)
      fromObject.transform:set_parent(toRoot.transform)
    end
    if self.needMoreTrans then
      self.needMoreTrans = false
      self.OnRoleSelected(self.nextTransModelName)
    end
    self.isTweening = false
  end
end
def.static("table", "table").OnLoginRoleSucess = function()
end
def.static("table", "table").OnRoleInfoUpdate = function(params)
  local roleId = params[1]
  instance:UpdateRolesInfo()
  instance:UpdateDelBtnText()
end
def.method().UpdateRolesInfo = function(self)
  for i = 1, SelectRolePanel.MAX_ROLE_NUM do
    local modelName = self.modelPosData[i]
    local roleId
    if modelName and self.modelList[modelName] then
      roleId = self.modelList[modelName].roleId
    end
    if roleId then
      local roleInfo = LoginModule:GetRoleInfo(roleId)
      self:SetRoleInfo(i, roleInfo)
    else
    end
  end
end
def.method().Update = function(self)
  if self.modelList == nil then
    return
  end
  if not self.isTweening then
    self:UpdateRolesInfo()
  end
  for k, modelInfo in pairs(self.modelList) do
    if modelInfo.roleId == self.selectedRoleId and modelInfo.model:IsPlaying(ActionName.Stand) then
      local uiModel = self:GetUIModelObject(1)
      local camera = uiModel:get_modelCamera()
      camera.depth = camera.depth
      break
    end
  end
end
def.method().UpdateDelBtnText = function(self)
  local roleId = self.selectedRoleId
  local delBtnText = textRes.Login[33]
  if LoginModule:IsRoleDeleting(roleId) then
    delBtnText = textRes.Login[34]
  end
  self.m_panel:FindDirect("Img_Bg0/Btn_Delete/Label_Delete"):GetComponent("UILabel").text = delBtnText
end
def.static("table", "table").OnResetUI = function()
  local self = instance
  self:ResetUI()
end
def.method().ResetUI = function(self)
  self.isLoging = false
end
return SelectRolePanel.Commit()

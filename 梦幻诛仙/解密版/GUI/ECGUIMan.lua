local Lplus = require("Lplus")
local EC = require("Types.Vector")
local ECFlashTipMan = require("GUI.FlashTipMan")
local GUIManEvents = require("Event.GUIManEvents")
local ECPanelBase = require("GUI.ECPanelBase")
local ECPanelScreenTint = require("CG.CGEventScreenTint")
local ECGUIMan = Lplus.Class("ECGUIMan")
local def = ECGUIMan.define
def.field("boolean").m_LockForever = false
def.field("userdata").m_DebugInput = nil
def.field("userdata").m_UIRoot = nil
def.field("userdata").m_hudTopBoardDepth = nil
def.field("userdata").m_hudTopBoard = nil
def.field("userdata").m_hudTopBoardCache = nil
def.field("table").m_hudTopBoardList = function()
  return {}
end
def.field("userdata").m_camera = nil
def.field("userdata").m_hudCamera = nil
def.field("userdata").m_uiCamera = nil
def.field("userdata").m_ui2Camera = nil
def.field("userdata").m_uiFXCamera = nil
def.field("userdata").m_uiRootCom = nil
def.field("table").m_panelMap = function()
  return {}
end
def.field("table").m_AllGuiResList = nil
def.field("table").m_TempGuiResList = nil
def.field("userdata").m_hudCameraGo = nil
def.field("userdata").m_uifxRoot = nil
def.field("userdata").m_uifxCamera = nil
def.field("userdata").m_uilock = nil
def.field("userdata").m_hudCamera2 = nil
def.field("userdata").m_hudCameraGo2 = nil
def.field("number").lockTimer = 0
def.field("boolean").m_bPreloadUI = false
def.field("table").m_outTouchMap = nil
def.field("table").m_lastShowFrames = nil
def.field("number").m_lastShowIdx = 1
def.method(ECPanelBase).SetOutTouchDisappear = function(self, panel)
  table.insert(self.m_outTouchMap, panel)
end
local EXCEPTPANEL = {panel_guide = true}
def.method("string").NotifyDisappear = function(self, panelName)
  if EXCEPTPANEL[panelName] then
    return
  end
  local remove = {}
  for k, v in pairs(self.m_outTouchMap) do
    if v ~= nil and v.m_panelName ~= panelName then
      v:DestroyPanel()
      remove[k] = true
    end
  end
  for i = #self.m_outTouchMap, 1, -1 do
    if remove[i] then
      table.remove(self.m_outTouchMap, i)
    end
  end
end
def.field("table").m_uiLevelMap = nil
def.method(ECPanelBase, "number", "=>", "boolean").TestUIPriority = function(self, ui, level)
  if self.m_uiLevelMap[level] == nil then
    return true
  end
  if level == 1 then
    local prevUI = self.m_uiLevelMap[1][#self.m_uiLevelMap[1]]
    if prevUI ~= nil and prevUI:IsShow() == true then
      return ui.m_priority >= prevUI.m_priority
    end
  end
  return true
end
def.method(ECPanelBase, "number").AddUI = function(self, ui, level)
  if self.m_uiLevelMap[level] == nil then
    self.m_uiLevelMap[level] = {}
  end
  if level == 1 then
    local prevUI = self.m_uiLevelMap[1][#self.m_uiLevelMap[1]]
    if prevUI ~= nil then
      prevUI:RawShow(false)
    end
    if self.m_uiLevelMap[2] ~= nil then
      local levelMapClone = {}
      for k, v in ipairs(self.m_uiLevelMap[2]) do
        table.insert(levelMapClone, v)
      end
      for k, v in ipairs(levelMapClone) do
        v:DestroyPanel()
      end
      self.m_uiLevelMap[2] = {}
    end
  end
  table.insert(self.m_uiLevelMap[level], ui)
end
def.method(ECPanelBase, "number").RemoveUI = function(self, ui, level)
  if self.m_uiLevelMap[level] == nil then
    return
  end
  local curUI
  local index = 0
  for i = #self.m_uiLevelMap[level], 1, -1 do
    if self.m_uiLevelMap[level][i] == ui then
      index = i
      curUI = ui
      break
    end
  end
  if curUI == nil then
    return
  end
  if level == 1 and index == #self.m_uiLevelMap[level] then
    local prevUI = self.m_uiLevelMap[1][index - 1]
    if prevUI ~= nil then
      prevUI:RawShow(true)
    end
    if self.m_uiLevelMap[2] ~= nil then
      local levelMapClone = {}
      for k, v in ipairs(self.m_uiLevelMap[2]) do
        table.insert(levelMapClone, v)
      end
      for k, v in ipairs(levelMapClone) do
        v:DestroyPanel()
      end
      self.m_uiLevelMap[2] = {}
    end
  end
  table.remove(self.m_uiLevelMap[level], index)
end
def.method("boolean").ShowAllUI = function(self, hide)
  for i = 0, 2 do
    local uis = self.m_uiLevelMap[i]
    if uis ~= nil then
      if i == 1 and #uis > 0 then
        uis[#uis]:RawShow(hide)
      else
        for k, v in ipairs(uis) do
          v:RawShow(hide)
        end
      end
    end
  end
end
def.method("boolean", ECPanelBase).ShowAllUIExceptMe = function(self, hide, me)
  for i = 0, 2 do
    local uis = self.m_uiLevelMap[i]
    if uis ~= nil then
      if i == 1 and #uis > 0 then
        uis[#uis]:RawShow(hide)
      else
        for k, v in ipairs(uis) do
          if v ~= me then
            v:RawShow(hide)
          end
        end
      end
    end
  end
end
def.method("number").DestroyUIAtLevel = function(self, level)
  for i = level, 2 do
    if self.m_uiLevelMap[i] ~= nil then
      local curLevelUIList = self.m_uiLevelMap[i]
      local uiCount = #curLevelUIList
      for i = uiCount, 1, -1 do
        local ui = curLevelUIList[i]
        if ui then
          ui:DestroyPanel()
        end
      end
    end
  end
end
def.method("=>", "boolean").MoveBackward = function(self)
  local hasMove = false
  for i = 2, -1, -1 do
    if self.m_uiLevelMap[i] ~= nil then
      local curLevelUIList = self.m_uiLevelMap[i]
      local uiCount = #curLevelUIList
      for i = uiCount, 1, -1 do
        local ui = curLevelUIList[i]
        if ui and ui:OnMoveBackward() then
          hasMove = true
        end
      end
    end
  end
  return hasMove
end
def.method().DestroyUIForReconnect = function(self)
  for i = 0, 2 do
    if self.m_uiLevelMap[i] ~= nil then
      local curLevelUIList = self.m_uiLevelMap[i]
      local uiCount = #curLevelUIList
      for i = uiCount, 1, -1 do
        local ui = curLevelUIList[i]
        if ui and not ui:IsAliveInReconnect() then
          ui:DestroyPanel()
        end
      end
    end
  end
end
local man
def.static("=>", ECGUIMan).new = function()
  man = ECGUIMan()
  man.m_AllGuiResList = {}
  man.m_TempGuiResList = {}
  man.m_outTouchMap = {}
  man.m_uiLevelMap = {}
  return man
end
def.static("=>", ECGUIMan).Instance = function()
  return man
end
def.method().Init = function(self)
  local UIRoot = GUIRoot.GetUIRootObj()
  GameObject.DontDestroyOnLoad(UIRoot)
  UIRoot.layer = 5
  self.m_UIRoot = UIRoot
  local uiRootCom = GUIRoot.GetUIRoot()
  uiRootCom.scalingStyle = 1
  if Screen.width / Screen.height < 1.49 then
    uiRootCom.manualHeight = 768
  else
    uiRootCom.manualHeight = 640
  end
  uiRootCom.minimumHeight = 640
  uiRootCom.maximumHeight = 800
  self.m_uiRootCom = uiRootCom
  local cameraGo = GUIRoot.GetCameraObj()
  cameraGo.parent = UIRoot
  cameraGo.localPosition = EC.Vector3.zero
  cameraGo.localScale = EC.Vector3.one
  cameraGo.layer = ClientDef_Layer.UI
  local maxDepth = 100
  local camera = GUIRoot.GetCamera()
  camera.depth = CameraDepth.UI
  camera.cullingMask = ui_default_cull_mask
  camera.orthographicSize = 1
  camera.orthographic = true
  camera.nearClipPlane = -2
  camera.farClipPlane = 2
  camera.clearFlags = CameraClearFlags.Depth
  self.m_uiCamera = GUIRoot.GetUICamera()
  self.m_camera = camera
  require("GUI.ToastTip").Init()
  require("GUI.AnnouncementTip").Init()
  require("GUI.InteractiveAnnouncementTip").PreInit()
  require("GUI.RareItemAnnouncementTip").PreInit()
  local hudTopBoardGo = GameObject.GameObject("HUD TopBoard Root")
  local hbroot = hudTopBoardGo:AddComponent("UIRoot")
  hbroot.scalingStyle = 1
  hbroot.manualHeight = 640
  hudTopBoardGo.layer = ClientDef_Layer.PateText
  self.m_hudTopBoard = hudTopBoardGo
  local hudTopBoardCache = GameObject.GameObject("HUD TopBoard Cache")
  hudTopBoardCache:SetActive(false)
  self.m_hudTopBoardCache = hudTopBoardCache
  GameUtil.AddGlobalTimer(10, false, function()
    local activelist = {}
    local hudlist = self.m_hudTopBoardList
    local oldcount = #hudlist
    for i = 1, oldcount do
      local hud = hudlist[i]
      if hud.childCount == 0 then
        if hud.name ~= "group_depth" then
          hud.parent = hudTopBoardCache
        end
      else
        activelist[#activelist + 1] = hud
      end
    end
    self.m_hudTopBoardList = activelist
  end)
  local hudCameraGo = GameObject.GameObject("HUD Camera")
  local camera = hudCameraGo:AddComponent("Camera")
  camera.depth = CameraDepth.HUD
  camera.cullingMask = bit.lshift(1, ClientDef_Layer.PateText)
  camera.clearFlags = CameraClearFlags.Nothing
  self.m_hudCamera = camera
  self.m_hudCameraGo = hudCameraGo
  camera.localPosition = EC.Vector3.new(0, 0, -500)
  camera.orthographic = true
  local ECGame = require("Main.ECGame")
  camera.orthographicSize = ECGame.Instance().m_2DWorldCam.orthographicSize
  camera.nearClipPlane = ECGame.Instance().m_2DWorldCam.nearClipPlane
  camera.farClipPlane = ECGame.Instance().m_2DWorldCam.farClipPlane
  local hudTopBoardDepth = GameObject.GameObject("HUD TopBoard Root(Depth)")
  local hbroot = hudTopBoardDepth:AddComponent("UIRoot")
  hbroot.scalingStyle = 1
  hbroot.manualHeight = 640
  hudTopBoardDepth.layer = ClientDef_Layer.PateTextDepth
  self.m_hudTopBoardDepth = hudTopBoardDepth
  local hudCameraGo2 = GameObject.GameObject("HUD Camera2")
  local camera2 = hudCameraGo2:AddComponent("Camera")
  camera2.depth = CameraDepth.HUD2
  camera2.cullingMask = bit.lshift(1, ClientDef_Layer.PateTextDepth)
  camera2.clearFlags = CameraClearFlags.Depth
  self.m_hudCamera2 = camera2
  self.m_hudCameraGo2 = hudCameraGo2
  camera2.localPosition = EC.Vector3.new(0, 0, -500)
  camera2.orthographic = true
  camera2.orthographicSize = ECGame.Instance().m_2DWorldCam.orthographicSize
  camera2.nearClipPlane = ECGame.Instance().m_2DWorldCam.nearClipPlane
  camera2.farClipPlane = ECGame.Instance().m_2DWorldCam.farClipPlane
  self.m_hudCamera2.enabled = true
  UIModel.cameraDepth = CameraDepth.UIMODEL
  local cameraGo = GameObject.GameObject("UI2 Camera")
  cameraGo.parent = UIRoot
  cameraGo.localPosition = EC.Vector3.zero
  cameraGo.localScale = EC.Vector3.one
  cameraGo.layer = ClientDef_Layer.UI2
  local camera = cameraGo:AddComponent("Camera")
  camera.depth = CameraDepth.UI2
  camera.cullingMask = bit.lshift(1, ClientDef_Layer.UI2)
  camera.orthographicSize = 1
  camera.orthographic = true
  camera.nearClipPlane = -7
  camera.farClipPlane = 7
  camera.clearFlags = CameraClearFlags.Depth
  self.m_ui2Camera = camera
  local cameraGo = GameObject.GameObject("UIFX Camera")
  cameraGo.parent = UIRoot
  cameraGo.localPosition = EC.Vector3.zero
  cameraGo.localScale = EC.Vector3.one
  cameraGo.layer = ClientDef_Layer.UIFX
  local camera = cameraGo:AddComponent("Camera")
  camera.depth = CameraDepth.UIFX
  camera.cullingMask = bit.lshift(1, ClientDef_Layer.UIFX)
  camera.orthographicSize = 1
  camera.orthographic = true
  camera.nearClipPlane = -7
  camera.farClipPlane = 7
  camera.clearFlags = CameraClearFlags.Depth
  self.m_uiFXCamera = camera
  self:_CreateUILock()
  local CG = require("CG.CG")
  CG.Instance().srcFlyOrthographicSize = ECGame.Instance().m_Fly3DCamComponent.orthographicSize
  CG.Instance().src2dOrthSize = ECGame.Instance().m_2DWorldCam.orthographicSize
  CG.Instance().src3dOrthSize = ECGame.Instance().m_2DWorldCam.orthographicSize
  HUDFollowTarget.uiCamera = self.m_hudCamera
  HUDFollowTarget.gameCamera = ECGame.Instance().m_Main3DCamComponent
  HUDFollowTarget.gameCameraObj = ECGame.Instance().m_2DWorldCamObj
  HUDFollowTarget.cam2d = ECGame.Instance().m_2DWorldCam
  HUDFollowTarget.mRootTrans = self.m_hudTopBoard.transform
  local GUIEvents = require("Event.GUIEvents")
  ECGame.EventManager:addHandler(GUIEvents.DestroyPanelEvent, ECGUIMan.OnPanelDestroy)
  require("Main.Common.URLBtnHelper").Instance():Init()
  require("Main.Common.TipsBtnHelper").Instance():Init()
end
def.method().Release = function(self)
  if self.m_UIRoot then
    Object.Destroy(self.m_UIRoot)
  end
end
local hudtop_depth = 1000
def.method("=>", "userdata")._CreateHudTopBoardGroup = function(self)
  local hudTopGroup, child
  if self.m_hudTopBoardCache.childCount > 0 then
    child = self.m_hudTopBoardCache:GetChild(0)
  end
  if child and child.name ~= "group_depth" then
    hudTopGroup = child
    hudTopGroup.parent = self.m_hudTopBoard
    hudTopGroup.localScale = EC.Vector3.one
  else
    hudTopGroup = GameObject.GameObject("group")
    hudTopGroup.parent = self.m_hudTopBoard
    hudTopGroup.localPosition = EC.Vector3.zero
    hudTopGroup.localScale = EC.Vector3.one
    hudTopGroup.layer = ClientDef_Layer.PateText
    local bhpanel = hudTopGroup:AddComponent("UIPanel")
    bhpanel.depth = hudtop_depth
    hudtop_depth = hudtop_depth + 1
    bhpanel:unbind()
  end
  self.m_hudTopBoardList[#self.m_hudTopBoardList + 1] = hudTopGroup
  return hudTopGroup
end
def.method("=>", "userdata")._GetHudTopBoardGroupWithDepth = function(self)
  local hudTopGroup
  for i = 1, self.m_hudTopBoardDepth.childCount do
    local group = self.m_hudTopBoardDepth:GetChild(i - 1)
    if group.childCount < 25 then
      hudTopGroup = group
      break
    end
  end
  if hudTopGroup == nil then
    hudTopGroup = GameObject.GameObject("group_depth")
    hudTopGroup.parent = self.m_hudTopBoardDepth
    hudTopGroup.localPosition = EC.Vector3.zero
    hudTopGroup.localScale = EC.Vector3.one
    hudTopGroup:SetLayer(ClientDef_Layer.PateTextDepth)
    local bhpanel = hudTopGroup:AddComponent("UIPanel")
    bhpanel.depth = 900
    bhpanel:unbind()
  end
  return hudTopGroup
end
def.method("=>", "userdata").GetHudTopBoardRoot = function(self)
  local best
  local curlist = self.m_hudTopBoardList
  for i = 1, #curlist do
    local child = curlist[i]
    if child.childCount < 25 and child.name ~= "group_depth" then
      best = child
      break
    end
  end
  best = best or self:_CreateHudTopBoardGroup()
  return best
end
def.method("string", "=>", "userdata").CreateHudByHp = function(self, name)
  local g = GameObject.GameObject(name)
  local go = self:_GetHudTopBoardGroupWithDepth()
  g.parent = go
  g.localPosition = EC.Vector3.zero
  g.localScale = EC.Vector3.one
  return g
end
def.method("string", "=>", "userdata").CreateHud = function(self, name)
  local g = GameObject.GameObject(name)
  local go = self:GetHudTopBoardRoot()
  g.parent = go
  g.localPosition = EC.Vector3.zero
  g.localScale = EC.Vector3.one
  return g
end
def.method("boolean").SetHudTouchable = function(self, touch)
  if not self.m_hudCameraGo or self.m_hudCameraGo.isnil then
    return
  end
  local uiCam = self.m_hudCameraGo:GetComponent("UICamera")
  if uiCam then
    uiCam.enabled = touch
  elseif touch then
    local cam = self.m_hudCameraGo:AddComponent("UICamera")
  end
end
def.static("=>", "number").GetMaxCameraDepth = function()
  local cameras = Camera.allCameras
  local maxDepth = -100
  for _, cam in ipairs(cameras) do
    if maxDepth < cam.depth then
      maxDepth = cam.depth
    end
  end
  return maxDepth
end
def.method(ECPanelBase, "string").RegisterPanel = function(self, panel, panelName)
  self.m_panelMap[panelName] = panel
end
def.method("string", "=>", ECPanelBase).FindPanelByName = function(self, panelName)
  return self.m_panelMap[panelName]
end
def.method("=>", "varlist").EachPanel = function(self)
  return pairs(self.m_panelMap)
end
local preload = false
def.method().PreLoadRes = function(self)
  if preload then
    return
  end
  preload = true
end
def.method().PreLoadAllGuis = function(self)
  if self.m_bPreloadUI then
    return
  end
  self.m_bPreloadUI = true
  local list = self.m_AllGuiResList
  GameUtil.AsyncLoad(RESPATH.Panel_Map_Radar, function(obj)
    list[#list + 1] = obj
  end)
  GameUtil.AsyncLoad(RESPATH.Panel_Equip_Underwear, function(obj)
    list[#list + 1] = obj
  end)
  GameUtil.AsyncLoad(RESPATH.Panel_Char, function(obj)
    local inst = Object.Instantiate(obj, "GameObject")
    local uiRoot = GameObject.Find("/UI Root(2D)")
    inst.parent = uiRoot
    inst.localPosition = EC.Vector3.zero
    inst.localScale = EC.Vector3.one
    inst:SetActive(false)
    local ECPanelChar = require("GUI.ECPanelChar")
    ECPanelChar.Instance().m_panelHide = inst
  end)
  GameUtil.AsyncLoad(RESPATH.Panel_Menu, function(obj)
    list[#list + 1] = obj
  end)
end
def.method()._CreateAllGuis = function(self)
  local tstart = Time.realtimeSinceStartup
  local ECAtlasMan = require("GUI.AtlasMan")
  local ECPanelTaskGuide = require("GUI.ECPanelTaskGuide")
  local ECPanelSkill = require("GUI.ECPanelSkill")
  local ECPanelDebugInput = require("GUI.ECPanelDebugInput")
  local ECPanelCharHead = require("GUI.ECPanelCharHead")
  local ECPanelMenu = require("GUI.ECPanelMenu")
  local ECPanelAutoFight = require("GUI.ECPanelAutoFight")
  local ECPanelMapRadar = require("GUI.ECPanelMapRadar")
  local ECPanelChatSmall = require("Chat.ECPanelChatSmall")
  local ECPanelActivityEntry = require("GUI.ECPanelActivityEntry")
  local ECPanelExp = require("GUI.ECPanelExp")
  local ECPanelRideBtn = require("GUI.ECPanelRideBtn")
  local ECPanelCamReset = require("GUI.ECPanelCamReset")
  local ECPanelBroadcast = require("GUI.ECPanelBroadcast")
  local ECPanelChallengeEntry = require("GUI.ECPanelChallengeEntry")
  local ECPanelMenuOther = require("GUI.ECPanelMenuOther")
  local ECPanelMenuBtn = require("GUI.ECPanelMenuBtn")
  local ECPanelVoiceBtn = require("Chat.ECPanelVoiceBtn")
  local ECPanelFacilityInfo = require("GUI.ECPanelFacilityInfo")
  local ECPanelActivityNew = require("GUI.ECPanelActivityNew")
  ECPanelSkill.Instance():CreatePanel(RESPATH.Panel_Skill)
  ECPanelCharHead.Instance():CreatePanel(RESPATH.Panel_CharHead)
  ECPanelTaskGuide.Instance():Create()
  ECPanelAutoFight.Instance():CreatePanel(RESPATH.Panel_AutoFight)
  ECPanelChatSmall.Instance():CreatePanel(RESPATH.Panel_ChatSmall)
  ECPanelActivityEntry.Instance():Create()
  ECPanelChallengeEntry.Instance():Create()
  ECPanelMenuOther.Instance():Create()
  ECPanelExp.Instance():CreatePanel(RESPATH.Panel_Exp)
  ECPanelCamReset.Instance():CreatePanel(RESPATH.Panel_CamReset)
  ECPanelMenuBtn.Instance():CreatePanel(RESPATH.Panel_MenuBtn)
  ECPanelVoiceBtn.Instance():CreatePanel(RESPATH.Panel_VoiceBtn)
  ECPanelFacilityInfo.Instance():CreatePanel(RESPATH.Panel_FacilityInfo)
  ECPanelMapRadar.Instance():CreatePanel(RESPATH.Panel_Map_Radar)
end
def.method()._EnterLoginStage = function(self)
  Application.set_targetFrameRate(60)
  GameUtil.SetLoadTimeLimit(0.015)
  GameUtil.SetDefaultSyncIO(false)
  GameUtil.SetDefaultCreateImmidiate(false)
  warn("_EnterLoginStage: " .. Time.realtimeSinceStartup)
  local ECPanelLogin = require("GUI.ECPanelLogin")
  ECPanelLogin.Instance():CreatePanel(RESPATH.Panel_Login)
  local ECPanelVoiceBtn = require("Chat.ECPanelVoiceBtn")
  ECPanelVoiceBtn.Instance():PreRegEvent()
end
def.method()._LeaveLoginStage = function(self)
  local ECPanelLogin = require("GUI.ECPanelLogin")
  ECPanelLogin.Instance():DestroyPanel()
  local ECPanelServerListNew = require("GUI.ECPanelServerListNew")
  ECPanelServerListNew.Instance():DestroyPanel()
  local ECPanelCreateCharacter = require("GUI.ECPanelCreateCharacter")
  ECPanelCreateCharacter.Instance():DestroyPanel()
  local ECPanelRoleChoose = require("GUI.ECPanelRoleChoose")
  ECPanelRoleChoose.Instance():DestroyPanel()
end
def.method().RegistEventHOOK = function(self)
  local ECPanelBase = require("GUI.ECPanelBase")
  local ECEventTable = require("GUI.ECEventTable")
  for k, v in pairs(ECEventTable) do
    ECPanelBase.AddEventHook(k, v)
  end
end
def.method().UnRegistEventHOOK = function(self)
  local ECPanelBase = require("GUI.ECPanelBase")
  local ECEventTable = require("GUI.ECEventTable")
  for k, v in pairs(ECEventTable) do
    ECPanelBase.RemoveEventHook(k, v)
  end
end
def.method().OnCreateCharacter = function(self)
  local ECPanelRoleChoose = require("GUI.ECPanelRoleChoose")
  ECPanelRoleChoose.Instance():DestroyPanel()
  local ECPanelCreateCharacter = require("GUI.ECPanelCreateCharacter")
  ECPanelCreateCharacter.Instance():ShowPanel()
end
def.method().CancelCreateCharacter = function(self)
  local ECGame = require("Main.ECGame")
  ECGame.Instance().m_Network:Close()
  local ECPanelCreateCharacter = require("GUI.ECPanelCreateCharacter")
  ECPanelCreateCharacter.Instance():DestroyPanel()
  local ECPanelLogin = require("GUI.ECPanelLogin")
  ECPanelLogin.Instance():CreatePanel(RESPATH.Panel_Login)
end
def.method("userdata", "table", "=>", "table").ScreenToGUI = function(self, control, screenPt)
  local wpt = self.m_camera:ScreenToWorldPoint(EC.Vector3.new(screenPt.x, screenPt.y, self.m_camera.nearClipPlane))
  local lpt = control:InverseTransformPoint(wpt)
  local lefttop
  local widget = control:GetComponent("UIWidget")
  if widget then
    local localCorners = widget.localCorners
    lefttop = localCorners[2]
  else
    local box = control:GetComponent("BoxCollider")
    local center = box.center
    local size = box.size
    lefttop = EC.Vector3.new(-size.x / 2 + center.x, size.y / 2 + center.y, 0)
  end
  return EC.Vector2.new(lpt.x - lefttop.x, lefttop.y - lpt.y)
end
def.method().EnterPanelTopmostMode = function(self)
  if self.m_camera then
    self.m_camera.cullingMask = ui_topmost_cull_mask
  end
  if self.m_ui2Camera then
    self.m_ui2Camera.cullingMask = ui_topmost_cull_mask
  end
  UIModel.root2attachCamera:SetActive(false)
end
def.method().LeavePanelTopmostMode = function(self)
  if self.m_camera then
    self.m_camera.cullingMask = ui_default_cull_mask
  end
  if self.m_ui2Camera then
    self.m_ui2Camera.cullingMask = bit.lshift(1, ClientDef_Layer.UI2)
  end
  UIModel.root2attachCamera:SetActive(true)
end
def.method().OnSuccessReconnected = function(self)
  local level = -1
  for i = level, 2 do
    if self.m_uiLevelMap[i] ~= nil then
      local curLevelUIList = self.m_uiLevelMap[i]
      local uiCount = #curLevelUIList
      for i = uiCount, 1, -1 do
        local ui = curLevelUIList[i]
        if ui then
          ui:OnGUIChange(false, false)
        end
      end
    end
  end
end
def.method("string").pushShowFrames = function(self, frameName)
  local count = 5
  if self.m_lastShowFrames == nil then
    self.m_lastShowFrames = {}
  end
  if 5 <= self.m_lastShowIdx then
    self.m_lastShowIdx = 1
  else
    self.m_lastShowIdx = self.m_lastShowIdx + 1
  end
  self.m_lastShowFrames[self.m_lastShowIdx] = frameName
end
def.method("=>", "table").getLastShowFrames = function(self)
  return self.m_lastShowFrames
end
def.method("boolean").LockUIForever = function(self, lock)
  if self.m_uilock and not self.m_uilock.isnil then
    self.m_uilock:SetActive(lock)
    self.m_LockForever = lock
  end
end
def.method("boolean").LockUI = function(self, lock)
  if self.m_LockForever then
    return
  end
  if self.m_uilock and not self.m_uilock.isnil then
    self.m_uilock:SetActive(lock)
    if lock then
      GameUtil.RemoveGlobalTimer(self.lockTimer)
      self.lockTimer = GameUtil.AddGlobalTimer(4, true, function()
        if self.m_uilock and not self.m_uilock.isnil then
          self.m_uilock:SetActive(false)
        end
      end)
    else
      GameUtil.RemoveGlobalTimer(self.lockTimer)
    end
  end
end
def.method()._CreateUILock = function(self)
  if self.m_UIRoot then
    local uilockPanel = GameObject.GameObject("uilock")
    uilockPanel.parent = self.m_UIRoot
    uilockPanel.localPosition = EC.Vector3.zero
    uilockPanel.localScale = EC.Vector3.one
    uilockPanel:SetLayer(ClientDef_Layer.UI)
    local panel = uilockPanel:AddComponent("UIPanel")
    panel:set_depth(320000)
    local uilockWidget = GameObject.GameObject("uilock")
    uilockWidget.parent = uilockPanel
    uilockWidget.localPosition = EC.Vector3.zero
    uilockWidget.localScale = EC.Vector3.one
    uilockWidget:SetLayer(ClientDef_Layer.UI)
    uilockWidget:AddComponent("BoxCollider")
    local widget = uilockWidget:AddComponent("UIWidget")
    widget:set_autoResizeBoxCollider(true)
    widget:set_width(1920)
    widget:set_height(1080)
    widget:set_depth(0)
    self.m_uilock = uilockPanel
    self.m_uilock:SetActive(false)
  end
end
def.method("boolean").EnableUIFXCamera = function(self, isEnable)
  if self.m_uiFXCamera == nil then
    return
  end
  self.m_uiFXCamera:set_enabled(isEnable)
end
def.static("table", "table").OnPanelDestroy = function(sender, arg)
  require("GUI.GUIUtils").RemoveLightEffectAtPanel(arg.name)
end
ECGUIMan.Commit()
man = ECGUIMan.new()
return ECGUIMan

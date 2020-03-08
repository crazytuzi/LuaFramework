local Lplus = require("Lplus")
local TaskModule = Lplus.ForwardDeclare("TaskModule")
local ECGUIMan = require("GUI.ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local ECModel = require("Model.ECModel")
local UIModelWrap = require("Model.UIModelWrap")
local GUIUtils = require("GUI.GUIUtils")
local TaskTalk = Lplus.Extend(ECPanelBase, "TaskTalk")
local Vector = require("Types.Vector")
local def = TaskTalk.define
local inst
def.static("=>", TaskTalk).Instance = function()
  if inst == nil then
    inst = TaskTalk()
    inst:Init()
  end
  return inst
end
def.field("number")._TargetNPCID = 0
def.field("string")._TargetText = ""
def.field("number")._FadeTotalTime = 0.3
def.field("number")._FadeRamainTime = 0
def.field("number")._FadeValue = 1
def.field("number")._topHeight = 1
def.field("number")._bottomHeight = 1
def.field("boolean")._isFading = false
def.field("number")._textRemainTime = 3
def.field("string")._lastResourcePath = ""
def.field("boolean")._touchable = true
def.field("boolean").isshowing = false
def.field(UIModelWrap)._theUIModelWrap = nil
def.method().Init = function(self)
  self.m_TrigGC = true
  self.m_HideOnDestroy = true
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_TASK_TALK, -1)
    self:SetOutTouchDisappear()
  end
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.method("boolean").SetTouchable = function(self, Touchable)
  self._touchable = Touchable
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, TaskTalk.OnEnterFight)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, TaskTalk.OnDramaStart)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TaskTalk.OnLeaveWorld)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local screenHeight = ECGUIMan.Instance().m_uiRootCom:get_activeHeight()
  self.m_panel:FindDirect("Img_ChatCommon/Group_Text"):SetActive(false)
  local Img_ChatCommon = self.m_panel:FindDirect("Img_ChatCommon")
  self._bottomHeight = Img_ChatCommon:GetComponent("UIWidget"):get_height()
  local Img_BgTop = self.m_panel:FindDirect("Img_BgTop")
  self._topHeight = Img_BgTop:GetComponent("UIWidget"):get_height()
  local Img_Head = self.m_panel:FindDirect("Img_ChatCommon/Group_Text/Img_Head")
  local Model = self.m_panel:FindDirect("Img_ChatCommon/Group_Model/Model")
  local uiModel = Model:GetComponent("UIModel")
  uiModel:set_orthographic(true)
  uiModel.mCanOverflow = true
  self._theUIModelWrap = UIModelWrap.new(uiModel)
  self._theUIModelWrap._bUncache = true
  local screenHeight = ECGUIMan.Instance().m_uiRootCom:get_activeHeight()
  local screenWidth = screenHeight / Screen.height * Screen.width
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, TaskTalk.OnEnterFight)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, TaskTalk.OnDramaStart)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TaskTalk.OnLeaveWorld)
  self._theUIModelWrap:Destroy()
  self._touchable = true
  self.isshowing = false
  local ProtocolsCache = require("Main.Common.ProtocolsCache")
  ProtocolsCache.Instance():ReleaseCachedProtocols()
  warn("TaskTalk.OnDestroy")
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TalkShow, nil)
    ECGUIMan.Instance():ShowAllUI(false)
    self._isFading = false
    self:_SetNPCID()
    self.m_panel:FindDirect("Img_ChatCommon/Label_Text"):GetComponent("NGUIHTML"):ForceHtmlText("")
    self:FadeIn()
  else
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TalkHide, nil)
    local ProtocolsCache = require("Main.Common.ProtocolsCache")
    ProtocolsCache.Instance():ReleaseCachedProtocols()
    warn("TaskTalk.OnShow(false)")
    ECGUIMan.Instance():ShowAllUI(true)
    if self._theUIModelWrap ~= nil then
      self._theUIModelWrap:Destroy()
    end
    self.isshowing = false
  end
end
def.method().FadeOut = function(self)
  if self._isFading == true or self:IsShow() == false then
    return
  end
  self._FadeRamainTime = self._FadeTotalTime
  self._FadeValue = 1
  self._isFading = true
  local Img_ChatCommon = self.m_panel:FindDirect("Img_ChatCommon")
  Img_ChatCommon:FindDirect("Img_BgName"):SetActive(false)
  Img_ChatCommon:FindDirect("Label_Text"):SetActive(false)
  Timer:RegisterIrregularTimeListener(self.OnUpdateFadeOut, self)
  local Img_BgTop = self.m_panel:FindDirect("Img_BgTop")
  Img_BgTop:SetActive(true)
end
def.method().FadeIn = function(self)
  if self._isFading == true or self:IsShow() == false then
    return
  end
  self._FadeRamainTime = self._FadeTotalTime
  self._FadeValue = 1
  self._isFading = true
  local Img_ChatCommon = self.m_panel:FindDirect("Img_ChatCommon")
  Img_ChatCommon:FindDirect("Img_BgName"):SetActive(true)
  Img_ChatCommon:FindDirect("Label_Text"):SetActive(true)
  Timer:RegisterIrregularTimeListener(self.OnUpdateFadeIn, self)
  local Img_BgTop = self.m_panel:FindDirect("Img_BgTop")
  Img_BgTop:SetActive(true)
  self:OnUpdateFadeIn(0)
end
def.method("number").OnUpdateFadeOut = function(self, dt)
  if self:IsShow() == false then
    Timer:RemoveIrregularTimeListener(self.OnUpdateFadeOut)
    return
  end
  self._FadeRamainTime = self._FadeRamainTime - dt
  self._FadeValue = self._FadeRamainTime / self._FadeTotalTime
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local screenHeight = ECGUIMan.Instance().m_uiRootCom:get_activeHeight()
  local Img_ChatCommon = self.m_panel:FindDirect("Img_ChatCommon")
  local bottomY = -screenHeight * 0.5 + self._bottomHeight * 0.5 - (1 - self._FadeValue) * self._bottomHeight
  local bottomX = Img_ChatCommon.transform.localPosition.x
  Img_ChatCommon.transform:set_localPosition(Vector.Vector3.new(bottomX, bottomY, 0))
  local Img_BgTop = self.m_panel:FindDirect("Img_BgTop")
  local topY = screenHeight * 0.5 - self._topHeight * 0.5 + (1 - self._FadeValue) * self._topHeight
  local topX = Img_BgTop.transform.localPosition.x
  Img_BgTop.transform:set_localPosition(Vector.Vector3.new(topX, topY, 0))
  if self._FadeValue <= 0 then
    self._isFading = false
    Timer:RemoveIrregularTimeListener(self.OnUpdateFadeOut)
    self:HideDlg()
  end
end
def.method("number").OnUpdateFadeIn = function(self, dt)
  if self:IsShow() == false then
    Timer:RemoveIrregularTimeListener(self.OnUpdateFadeIn)
    return
  end
  self._FadeRamainTime = self._FadeRamainTime - dt
  self._FadeValue = self._FadeRamainTime / self._FadeTotalTime
  self._FadeValue = math.max(self._FadeValue, -1.0E-12)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local screenHeight = ECGUIMan.Instance().m_uiRootCom:get_activeHeight()
  local Img_ChatCommon = self.m_panel:FindDirect("Img_ChatCommon")
  local bottomY = -screenHeight * 0.5 + self._bottomHeight * 0.5 - self._FadeValue * self._bottomHeight
  local bottomX = Img_ChatCommon.transform.localPosition.x
  Img_ChatCommon.transform:set_localPosition(Vector.Vector3.new(bottomX, bottomY, 0))
  local Img_BgTop = self.m_panel:FindDirect("Img_BgTop")
  local topY = screenHeight * 0.5 - self._topHeight * 0.5 + self._FadeValue * self._topHeight
  local topX = Img_BgTop.transform.localPosition.x
  Img_BgTop.transform:set_localPosition(Vector.Vector3.new(topX, topY, 0))
  if PlayerIsInFight() == true then
    self._isFading = false
    Timer:RemoveIrregularTimeListener(self.OnUpdateFadeIn)
    self:HideDlg()
    return
  end
  if self._FadeValue <= 0 then
    self._isFading = false
    Timer:RemoveIrregularTimeListener(self.OnUpdateFadeIn)
    local Target = Img_ChatCommon:FindDirect("Target")
    local Label_Text = Img_ChatCommon:FindDirect("Label_Text")
    local TargetWidget = Target:GetComponent("UIWidget")
    local LabelWidget = Label_Text:GetComponent("UIWidget")
    local labelHtml = Label_Text:GetComponent("NGUIHTML")
    local srcWidth = TargetWidget:get_width()
    local srcHeight = TargetWidget:get_height()
    LabelWidget:set_width(srcWidth)
    LabelWidget:set_height(srcHeight)
    local dstWidth = LabelWidget:get_width()
    local dstHeight = LabelWidget:get_height()
    local srcPosition = TargetWidget.transform.localPosition
    local dstPosition = LabelWidget.transform.localPosition
    dstPosition.x = srcPosition.x
    dstPosition.y = srcPosition.y
    dstPosition.z = srcPosition.z
    LabelWidget.transform:set_localPosition(Vector.Vector3.new(srcPosition.x - srcWidth * 0.5, srcPosition.y + srcHeight * 0.5, srcPosition.z))
    labelHtml:set_maxLineWidth(srcWidth)
    self:_SetText()
  end
end
def.method("number").OnUpdateTextTime = function(self, dt)
  self._textRemainTime = self._textRemainTime - dt
  if self._textRemainTime <= 0 then
    if self._isFading == true or self:IsShow() == false then
      return
    end
    TaskModule.Instance():ShowNextNPCText()
  end
end
def.method("number").SetNPCID = function(self, npcID)
  self._TargetNPCID = npcID
  if self:IsShow() then
    self:_SetNPCID()
  end
end
def.method()._SetNPCID = function(self)
  local NPCInterface = require("Main.npc.NPCInterface")
  local npcCfg
  if self._TargetNPCID ~= 0 then
    npcCfg = NPCInterface.GetNPCCfg(self._TargetNPCID)
  end
  local PubroleInterface = require("Main.Pubrole.PubroleInterface")
  local Group_Text = self.m_panel:FindDirect("Img_ChatCommon/Group_Text")
  local Img_Head = Group_Text:FindDirect("Img_Head")
  local Group_Model = self.m_panel:FindDirect("Img_ChatCommon/Group_Model")
  local function fnSetPortrait(headidx)
    local resourcePath, resourceType = GetIconPath(headidx)
    if resourceType == 1 then
      Group_Text:SetActive(false)
      Group_Model:SetActive(true)
      if resourcePath == "" then
        warn(" resourcePath == \"\" iconId = " .. headidx)
      end
      self._theUIModelWrap:Load(resourcePath)
    else
      Group_Text:SetActive(true)
      Group_Model:SetActive(false)
      self._theUIModelWrap:Destroy()
      local uiTexture = Img_Head:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, headidx)
    end
  end
  if npcCfg ~= nil then
    local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    local theNPC = pubroleModule:GetNpc(self._TargetNPCID)
    local displayNama = npcCfg.npcName
    if theNPC then
      local name = theNPC:GetName()
      if name and name ~= "" then
        displayNama = name
      end
    end
    self.m_panel:FindDirect("Img_ChatCommon/Img_BgName/Label_Name"):GetComponent("UILabel"):set_text(displayNama)
    local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    local theNPC = pubroleModule:GetNpc(self._TargetNPCID)
    local changedModelId = 0
    if theNPC ~= nil then
      changedModelId = theNPC:GetChangedModelId()
    end
    if changedModelId == 0 then
      changedModelId = npcCfg.monsterModelTableId
    end
    local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, changedModelId)
    local headidx = DynamicRecord.GetIntValue(modelinfo, "halfBodyIconId")
    fnSetPortrait(headidx)
  else
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local modelID = PubroleInterface.FindModelIDByOccupationId(heroProp.occupation, heroProp.gender)
    local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelID)
    local headidx = DynamicRecord.GetIntValue(modelinfo, "halfBodyIconId")
    fnSetPortrait(headidx)
    self.m_panel:FindDirect("Img_ChatCommon/Img_BgName/Label_Name"):GetComponent("UILabel"):set_text(heroProp.name)
  end
end
def.method("string").SetText = function(self, text)
  self._TargetText = text
  if self:IsShow() then
    self:_SetText()
  end
end
def.method()._SetText = function(self)
  local targetText = string.gsub(self._TargetText, "%[(.-)%]", function(instr)
    if instr == "-" then
      return "</font>"
    end
    return "<font color=#" .. instr .. ">"
  end)
  targetText = "<p align=left valign=middle linespacing=10><font size=22>" .. targetText .. "</font></p>"
  local Label_Text = self.m_panel:FindDirect("Img_ChatCommon/Label_Text")
  UIDelayShow.DelayShow(Label_Text, 1)
  if _G.isDebugBuild then
    GameUtil.BeginSamp("TaskForceHtmlText")
    Label_Text:GetComponent("NGUIHTML"):ForceHtmlText(targetText)
    GameUtil.EndSamp()
  else
    Label_Text:GetComponent("NGUIHTML"):ForceHtmlText(targetText)
  end
  self._textRemainTime = 3
end
def.method("string").onClick = function(self, id)
  if self._isFading == true or self:IsShow() == false then
    return
  end
  if PlayerIsInFight() == true then
    self:FadeOut()
    return
  end
  if self._touchable == false then
    return
  end
  TaskModule.Instance():ShowNextNPCText()
end
def.method()._Hide = function(self)
  self._isFading = false
  Timer:RemoveIrregularTimeListener(self.OnUpdateFadeIn)
  Timer:RemoveIrregularTimeListener(self.OnUpdateFadeOut)
  self:HideDlg()
end
def.static("table", "table").OnEnterFight = function()
  local self = inst
  self:_Hide()
end
def.static("table", "table").OnDramaStart = function()
  local self = inst
  self:_Hide()
end
def.static("table", "table").OnLeaveWorld = function()
  local self = inst
  self:_Hide()
end
TaskTalk.Commit()
return TaskTalk

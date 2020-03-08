local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UISoaring = Lplus.Extend(ECPanelBase, "UISoaring")
local SoaringModule = Lplus.ForwardDeclare("SoaringModule")
local GUIUtils = require("GUI.GUIUtils")
local def = UISoaring.define
local instance
def.field("table")._uiGOs = nil
def.field("number")._iSubtaskNum = 0
def.field("table")._ctrlListItems = nil
def.static("=>", UISoaring).Instance = function()
  if instance == nil then
    instance = UISoaring()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self._iSubtaskNum = 0
  if self._uiGOs ~= nil then
    self._uiGOs = nil
  end
  if self._ctrlListItems ~= nil then
    self._ctrlListItems = nil
  end
end
def.method().InitUI = function(self)
  local listTask = self.m_panel:FindDirect("Img_Bg/List_Task")
  local imgBgDark = self.m_panel:FindDirect("Img_Bg/Img_BgDark")
  local tweenRotation = imgBgDark:GetComponent("TweenRotation")
  local fx = self.m_panel:FindDirect("Img_Bg/Fx")
  local imgBaGuaRoot = imgBgDark:FindDirect("Group_Gua")
  local imgBgLight = imgBgDark:FindDirect("Img_BgLight")
  self._uiGOs = self._uiGOs or {}
  self._uiGOs.listTask = listTask
  self._uiGOs.imgBaGuaRoot = imgBaGuaRoot
  self._uiGOs.imgBgLight = imgBgLight
  self._uiGOs.tweenRotation = tweenRotation
  self._uiGOs.fx = fx
  tweenRotation.enabled = false
  fx:SetActive(false)
  self:InitUITaskList()
  self:UpdateWholeBaGuaGraph()
  if self:IsActivityCompleted() then
    self:DisplayEffect()
  end
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_UI_SOARING, 0)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  if self:IsActivityCompleted() then
    Event.DispatchEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.DISPLAY_MAP_EFF, nil)
  end
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  warn(">>>>id = " .. id .. "<<<<")
  if id == "Btn_Close" then
    self:HidePanel()
  elseif string.find(id, "Img_Task_%d") ~= nil then
    local idx = tonumber(string.sub(id, string.find(id, "%d")))
    self:OnClickTaskByIdx(idx)
    self:HidePanel()
  end
end
def.method("number").OnClickTaskByIdx = function(self, idx)
  local arrActIds = SoaringModule.GetSubtaskArray()
  local actId = arrActIds[idx]
  local ClassTask = SoaringModule.GetTaskClassByActId(actId)
  if ClassTask ~= nil then
    ClassTask.Instance():OnTodoTask()
  end
end
def.method().InitUITaskList = function(self)
  self._iSubtaskNum = SoaringModule.Instance():GetSubtaskCount()
  self._ctrlListItems = GUIUtils.InitUIList(self._uiGOs.listTask, self._iSubtaskNum)
  self:UpdateUITasksList()
end
local NPCInterface = require("Main.npc.NPCInterface")
def.method().UpdateUITasksList = function(self)
  local countSubtask = self._iSubtaskNum
  local arrNPCIds = SoaringModule.GetArrayNPCIds()
  for i = 1, countSubtask do
    local npcCfg = NPCInterface.GetNPCCfg(arrNPCIds[i])
    local itemGO = self._ctrlListItems[i]
    local imgNPC = itemGO:FindDirect(("Img_Head_%d"):format(i))
    local btnTaskName = itemGO:FindDirect(("Img_Task_%d"):format(i))
    local lblTaskName = btnTaskName:FindDirect(("Label_Task_%d"):format(i))
    GUIUtils.SetText(lblTaskName, "   " .. npcCfg.npcName)
    local record = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, npcCfg.monsterModelTableId)
    local headIcon = record:GetIntValue("headerIconId")
    GUIUtils.SetTexture(imgNPC, headIcon)
  end
end
def.method().UpdateWholeBaGuaGraph = function(self)
  local countSubtask = self._iSubtaskNum
  local arrActIds = SoaringModule.GetSubtaskArray()
  for i = 1, countSubtask do
    local actId = arrActIds[i]
    local ClassTask = SoaringModule.GetTaskClassByActId(actId)
    local bIsFinish = SoaringModule.GetActivityCompletedByActId(actId)
    self:UpdateBaGuaGraphByIdx(i, bIsFinish)
    local itemGO = self._ctrlListItems[i]
    local imgFinish = itemGO:FindDirect(("Img_Finish_%d"):format(i))
    GUIUtils.SetActive(imgFinish, bIsFinish)
  end
end
def.method("number", "boolean").UpdateBaGuaGraphByIdx = function(self, idx, bActive)
  local img = self._uiGOs.imgBaGuaRoot:FindDirect(("Img_%02d"):format(idx))
  img:SetActive(bActive)
end
local GUIFxMan = require("Fx.GUIFxMan")
def.method().DisplayEffect = function(self)
  local fx = self._uiGOs.fx
  fx:SetActive(true)
  local tweenRotation = self._uiGOs.tweenRotation
  tweenRotation.enabled = true
  self._uiGOs.imgBgLight:SetActive(true)
end
def.method("=>", "boolean").IsActivityCompleted = function(self)
  local soaringActId = SoaringModule.Instance():GetActivityId()
  local bCompleted = SoaringModule.GetActivityCompletedByActId(soaringActId)
  return bCompleted
end
return UISoaring.Commit()

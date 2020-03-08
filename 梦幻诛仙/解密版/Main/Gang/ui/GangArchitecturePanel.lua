local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangModule = require("Main.Gang.GangModule")
local GangArchitecturePanel = Lplus.Extend(ECPanelBase, "GangArchitecturePanel")
local def = GangArchitecturePanel.define
local instance
def.static("=>", GangArchitecturePanel).Instance = function()
  if instance == nil then
    instance = GangArchitecturePanel()
  end
  return instance
end
def.field("number")._curIndex = 0
def.field("table")._uiObjs = nil
def.static().ShowDlg = function()
  if not GangModule.Instance():HasGang() then
    if GangArchitecturePanel.Instance():IsShow() then
      GangArchitecturePanel.Instance():DestroyPanel()
    end
    return
  end
  if GangArchitecturePanel.Instance():IsShow() then
    return
  end
  GangArchitecturePanel.Instance():CreatePanel(RESPATH.PREFAB_GANG_ARCHITECTURE_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.DutyGridObj = self.m_panel:FindDirect("Img_Bg0/Group_Info/Group_Btn")
  local uiGrid = self._uiObjs.DutyGridObj:GetComponent("UIGrid")
  local gridChildList = uiGrid:GetChildList()
  local gridItemCount = uiGrid:GetChildListCount()
  self._uiObjs.DutyBtns = {}
  for i = 1, gridItemCount do
    table.insert(self._uiObjs.DutyBtns, gridChildList[i].gameObject)
  end
  self._uiObjs.OriginDutyNameLabel = self.m_panel:FindDirect("Img_Bg0/Group_Info/Group_Job/Label_Info")
  self._uiObjs.CurrentDutyNameLabel = self.m_panel:FindDirect("Img_Bg0/Group_Info/Group_CustomJob/Label_Info")
  self._uiObjs.DutyDescLabel = self.m_panel:FindDirect("Img_Bg0/Group_Info/Label_Details")
  self._uiObjs.RenameButton = self.m_panel:FindDirect("Img_Bg0/Btn_ChangeName")
end
def.override("boolean").OnShow = function(self, show)
  self:_HandleEventListeners(show)
  if show then
    self:_CheckToggle(1)
    self:_UpdateRename()
  end
end
def.method("number")._CheckToggle = function(self, index)
  local toggleBtn = self._uiObjs.DutyBtns[index]
  if toggleBtn then
    GUIUtils.Toggle(toggleBtn, true)
  else
    warn("[GangArchitecturePanel:_CheckToggle] toggleBtn nil at index:", index)
  end
end
def.method("number", "boolean")._ShowDutyByIndex = function(self, index, bForce)
  if false == bForce and index == self._curIndex then
    return
  end
  self._curIndex = index
  local dutyCfg = self:_GetDutyCfgByIndex(index)
  if dutyCfg then
    local curDutyRename = GangData.Instance():GetDutyName(dutyCfg.id)
    GUIUtils.SetText(self._uiObjs.OriginDutyNameLabel, dutyCfg.dutyName)
    GUIUtils.SetText(self._uiObjs.CurrentDutyNameLabel, curDutyRename)
    GUIUtils.SetText(self._uiObjs.DutyDescLabel, dutyCfg.dutyDesc)
  else
    warn("[GangArchitecturePanel:_ShowDutyByIndex] dutyCfg nil for index:", index)
  end
end
def.method("number", "=>", "table")._GetDutyCfgByIndex = function(self, index)
  local dutyCfg
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GANG_DUTY_CFG)
  DynamicDataTable.FastGetRecordBegin(entries)
  local entry = DynamicDataTable.FastGetRecordByIdx(entries, index - 1)
  if entry then
    dutyCfg = {}
    dutyCfg.id = DynamicRecord.GetIntValue(entry, "id")
    dutyCfg.dutyName = DynamicRecord.GetStringValue(entry, "templatename")
    dutyCfg.dutyDesc = DynamicRecord.GetStringValue(entry, "description")
  else
    warn("[GangArchitecturePanel:_GetDutyCfgByIndex] entry nil for index:", index - 1)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return dutyCfg
end
def.method()._UpdateRename = function(self)
  self._uiObjs.RenameButton:SetActive(self:_CanRenameGang())
end
def.method("=>", "boolean")._CanRenameGang = function(self)
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(_G.GetHeroProp().id)
  if nil == memberInfo then
    warn("[GangArchitecturePanel:_CanRenameGang] role gang memberInfo nil.")
    return false
  end
  local dutyCfg = GangUtility.GetAuthority(memberInfo.duty)
  if dutyCfg then
    return dutyCfg.isCanModifyName
  else
    warn("[GangArchitecturePanel:_CanRenameGang] dutyCfg nil for duty:", memberInfo.duty)
    return false
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._curIndex = 0
  self._uiObjs = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:OnBtn_Close()
  else
    if id == "Btn_ChangeName" then
      self:OnBtn_Change()
    else
    end
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Change = function(self)
  if self:_CanRenameGang() then
    local ManagementGangPanel = require("Main.Gang.ui.GangManagment.ManagementGangPanel")
    ManagementGangPanel.ShowManagementGangPanel(function()
      self:_ShowDutyByIndex(self._curIndex, true)
    end, ManagementGangPanel.NodeId.DUTYNAME)
  else
    warn("[GangArchitecturePanel:OnBtn_Change] role can not rename gang.")
    self._uiObjs.RenameButton:SetActive(false)
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  local togglePrefix = "Btn_"
  if active and string.find(id, togglePrefix) then
    local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    warn(string.format("[GangArchitecturePanel:onToggle] toggle [%d] checked.", index))
    self:_ShowDutyByIndex(index, false)
  end
end
def.method("boolean")._HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, GangArchitecturePanel.OnGangDutyChange)
    eventFunc(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, GangArchitecturePanel.OnGangDutyChange)
    eventFunc(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemeberQuited, GangArchitecturePanel.OnGangDutyChange)
    eventFunc(ModuleId.GANG, gmodule.notifyId.Gang.Gang_DutyNameChange, GangArchitecturePanel.OnGangDutyChange)
  end
end
def.static("table", "table").OnGangDutyChange = function(param, context)
  warn("[GangArchitecturePanel:OnGangDutyChange] Gang Duty Change!")
  GangArchitecturePanel.Instance():_OnGangDutyChange()
end
def.method()._OnGangDutyChange = function(self)
  if GangModule.Instance():HasGang() then
    self:_ShowDutyByIndex(self._curIndex, true)
    self:_UpdateRename()
  else
    self:DestroyPanel()
  end
end
GangArchitecturePanel.Commit()
return GangArchitecturePanel

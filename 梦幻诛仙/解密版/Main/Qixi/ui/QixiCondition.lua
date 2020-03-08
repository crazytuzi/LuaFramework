local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QixiCondition = Lplus.Extend(ECPanelBase, "QixiCondition")
local def = QixiCondition.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
def.static("=>", QixiCondition).Instance = function()
  if dlg == nil then
    dlg = QixiCondition()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_QIXI_CONDITION, 1)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowConditions()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, QixiCondition.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, QixiCondition.OnLeaveFight)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, QixiCondition.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, QixiCondition.OnLeaveFight)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method().ShowConditions = function(self)
  if self.m_panel == nil then
    return
  end
  local list = self.m_panel:FindDirect("Img_Bg/Group_Center/List_Condition")
  local uiList = list:GetComponent("UIList")
  uiList.itemCount = 3
  uiList:Resize()
  local isAllReady = true
  for i = 1, 3 do
    local item_panel = list:FindDirect("Group_List_" .. i)
    if item_panel then
      item_panel:FindDirect("Label_Condition_" .. i):GetComponent("UILabel").text = textRes.activity.Qixi.condition[i]
      local g = item_panel:FindDirect("Group_Result_" .. i)
      local isReady = self:CheckCondition(i)
      g:FindDirect("Img_Right_" .. i):SetActive(isReady)
      g:FindDirect("Img_Wrong_" .. i):SetActive(not isReady)
      isAllReady = isAllReady and isReady
    end
  end
  local btn = self.m_panel:FindDirect("Img_Bg/Btn_Attend")
  btn:GetComponent("BoxCollider").enabled = isAllReady
  if not isAllReady then
    btn:FindDirect("Btn_CanAttend"):SetActive(false)
    btn:FindDirect("Btn_CannotAttend"):SetActive(true)
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if dlg.m_panel then
    dlg.m_panel:SetActive(false)
  end
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  if dlg.m_panel then
    dlg.m_panel:SetActive(true)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Attend" then
    self:DestroyPanel()
    local pro = require("netio.protocol.mzm.gsp.chinesevalentine.CPreviewChineseValentineReq").new()
    gmodule.network.sendProtocol(pro)
    require("Main.Qixi.ui.QixiInstruction").Instance():ShowDlg()
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method("number", "=>", "boolean").CheckCondition = function(self, idx)
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  if idx == 1 then
    return members ~= nil and #members == 2
  elseif idx == 2 then
    for i = 1, #members do
      if members[i].level < 30 then
        return false
      end
    end
    return true
  elseif idx == 3 then
    local TeamMember = require("netio.protocol.mzm.gsp.team.TeamMember")
    for i = 1, #members do
      if members[i].status ~= TeamMember.ST_NORMAL then
        return false
      end
    end
    return true
  end
end
QixiCondition.Commit()
return QixiCondition

local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgSetCommand = Lplus.Extend(ECPanelBase, "DlgSetCommand")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local GUIUtils = require("GUI.GUIUtils")
local def = DlgSetCommand.define
local FightMgr = require("Main.Fight.FightMgr")
local CmdType = require("consts.mzm.gsp.fight.confbean.CommandType")
local dlg
def.field("number").selectedCmdType = 0
def.static("=>", DlgSetCommand).Instance = function()
  if dlg == nil then
    dlg = DlgSetCommand()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgSetCommand.OnCloseSecondLevelUI)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.UPDATE_COMMAND, DlgSetCommand.UpdateCommand)
end
def.method().ShowDlg = function(self)
  if self:IsShow() then
    self:ShowCommands()
    return
  end
  self:CreatePanel(RESPATH.DLG_SET_COMMAND, 1)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgSetCommand.OnCloseSecondLevelUI)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.UPDATE_COMMAND, DlgSetCommand.UpdateCommand)
end
def.static("table", "table").OnCloseSecondLevelUI = function()
  dlg:Hide()
end
def.static("table", "table").UpdateCommand = function()
  dlg:ShowCommands()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_Mine"):GetComponent("UIToggle")
  if toggle.value then
    self.selectedCmdType = CmdType.FRIEND
  else
    self.selectedCmdType = CmdType.ENERMY
  end
  self:ShowCommands()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Tab_Enemy" then
    self.selectedCmdType = CmdType.ENERMY
    self:ShowCommands()
  elseif id == "Tab_Mine" then
    self.selectedCmdType = CmdType.FRIEND
    self:ShowCommands()
  elseif string.find(id, "Btn_ZhiHui") then
    local idx = tonumber(string.sub(id, string.len("Btn_ZhiHui") + 1))
    local count = FightMgr.Instance().commandItems[self.selectedCmdType].count
    if idx > count then
      require("Main.Fight.ui.DlgCommandEdit").Instance():ShowDlg(self.selectedCmdType, idx - count - 1)
    end
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.method().ShowCommands = function(self)
  if FightMgr.Instance().commandItems == nil then
    return
  end
  local commandItems = FightMgr.Instance().commandItems[self.selectedCmdType]
  if commandItems == nil then
    return
  end
  local btn
  local panel = self.m_panel:FindDirect("Img_Bg0/Group_Btn")
  local cmdNum = #commandItems
  for i = 1, 6 do
    btn = panel:FindDirect("Btn_ZhiHui" .. i)
    if btn then
      if i <= cmdNum then
        btn:FindDirect("Label"):GetComponent("UILabel").text = commandItems[i].name
        btn:FindDirect("Img_Pen"):SetActive(commandItems[i].idx > commandItems.count)
      else
        btn:FindDirect("Label"):GetComponent("UILabel").text = ""
        btn:FindDirect("Img_Pen"):SetActive(true)
      end
    end
  end
end
DlgSetCommand.Commit()
return DlgSetCommand

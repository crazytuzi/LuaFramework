local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local EquipModule = require("Main.Equip.EquipModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local SwornMgr = require("Main.Sworn.SwornMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local TeamData = require("Main.Team.TeamData").Instance()
local ECLuaString = require("Utility.ECFilter")
local SwornAnnocementPanel = Lplus.Extend(ECPanelBase, "SwornAnnocementPanel")
local def = SwornAnnocementPanel.define
def.field("table").m_UIGO = nil
def.field("string").m_Content = ""
local instance
def.static("=>", SwornAnnocementPanel).Instance = function()
  if not instance then
    instance = SwornAnnocementPanel()
  end
  return instance
end
def.method("string").ShowPanel = function(self, desc)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_Content = desc
  self:CreatePanel(RESPATH.PREFAB_JIE_YI_ANNO_PANEL, GUILEVEL.NORMAL)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
  GameUtil.AddGlobalTimer(5, true, function()
    self:DestroyPanel()
  end)
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
end
def.method("string").onClick = function(self, id)
  self:DestroyPanel()
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Label = self.m_panel:FindDirect("Img_Bg/Label")
end
def.method().Update = function(self)
  local labelGO = self.m_UIGO.Label
  GUIUtils.SetText(labelGO, self.m_Content)
end
return SwornAnnocementPanel.Commit()

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
local ModifyNamePanel = Lplus.Extend(ECPanelBase, "ModifyNamePanel")
local def = ModifyNamePanel.define
local LIMIT_WORD_NUM = 2
def.field("table").m_UIGO = nil
local instance
def.static("=>", ModifyNamePanel).Instance = function()
  if not instance then
    instance = ModifyNamePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_JIE_YI_CHANGE_PANEL, GUILEVEL.MUTEX)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
end
def.method().ModifySwornName = function(self)
  local name1 = GUIUtils.GetUIInputValue(self.m_UIGO.Input1)
  local name2 = GUIUtils.GetUIInputValue(self.m_UIGO.Input2)
  warn(name1, "SetSwornName", name2)
  if not name1 or not name2 then
    return
  end
  if name1:len() == 0 or name2:len() == 0 then
    Toast(textRes.Sworn[13])
    return
  end
  if ECLuaString.Len(name1) > LIMIT_WORD_NUM or ECLuaString.Len(name2) > LIMIT_WORD_NUM then
    Toast(textRes.Sworn[74]:format(LIMIT_WORD_NUM))
    return
  end
  local params = {}
  params.name1 = name1
  params.name2 = name2
  SwornMgr.ChangeSwornNameReq(params)
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Refuse" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:ModifySwornName()
    self:DestroyPanel()
  end
end
def.method("string", "userdata").onSubmit = function(self, id, uiInput)
  local inputStr = uiInput:get_value()
  local realLen = ECLuaString.Len(inputStr)
  if "Img_Input1" == id then
    if realLen > LIMIT_WORD_NUM then
      local realStr = ECLuaString.SubStr(inputStr, 1, LIMIT_WORD_NUM)
      uiInput:set_value(realStr)
      Toast(textRes.Sworn[74]:format(LIMIT_WORD_NUM))
    end
  elseif "Img_Input2" == id and realLen > LIMIT_WORD_NUM then
    local realStr = ECLuaString.SubStr(inputStr, 1, LIMIT_WORD_NUM)
    uiInput:set_value(realStr)
    Toast(textRes.Sworn[74]:format(LIMIT_WORD_NUM))
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.MemberNum = self.m_panel:FindDirect("Group_Name/Img_Label/Label_Num")
  self.m_UIGO.NeedMoney = self.m_panel:FindDirect("Img_BgUseMoney/Label_Num")
  self.m_UIGO.Money = self.m_panel:FindDirect("Img_BgHaveMoney/Label_Num")
  self.m_UIGO.Input1 = self.m_panel:FindDirect("Group_Name/Img_Input1")
  self.m_UIGO.Input2 = self.m_panel:FindDirect("Group_Name/Img_Input2")
end
def.method().Update = function(self)
  local numGO = self.m_UIGO.MemberNum
  local needMoneyGO = self.m_UIGO.NeedMoney
  local moneyGO = self.m_UIGO.Money
  local members = SwornMgr.GetSwornMember()
  local count = #members
  local needMoney = SwornMgr.GetSwornConst("CHANGE_SWORNNAME_NEED_GOLD")
  local money = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  GUIUtils.SetText(numGO, SwornMgr.GetNumberDesc(count))
  GUIUtils.SetText(needMoneyGO, tostring(needMoney))
  GUIUtils.SetText(moneyGO, Int64.tostring(money))
end
return ModifyNamePanel.Commit()

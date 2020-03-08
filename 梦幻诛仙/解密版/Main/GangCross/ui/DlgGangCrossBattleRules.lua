local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgGangCrossBattleRules = Lplus.Extend(ECPanelBase, "DlgGangCrossBattleRules")
local def = DlgGangCrossBattleRules.define
local dlg
def.static("=>", DlgGangCrossBattleRules).Instance = function()
  if dlg == nil then
    dlg = DlgGangCrossBattleRules()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self:IsShow() then
    self:ShowInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_GANG_BATTLE_RULES, 2)
    self:SetModal(true)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowInfo()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Hide()
  end
end
def.method().ShowInfo = function(self)
  local entries = DynamicData.GetTable("data/cfg/mzm.gsp.gang.confbean.CGangConflictRuleCfg.bny")
  local count = DynamicDataTable.GetRecordsCount(entries)
  local listPanel = self.m_panel:FindDirect("Img_Bg/Img_Bg1/Scroll View/List")
  local uiList = listPanel:GetComponent("UIList")
  if count == 0 then
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  uiList.itemCount = count
  uiList:Resize()
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    if record == nil then
      return
    end
    local title = record:GetStringValue("title")
    local content = record:GetStringValue("content")
    local subPanel = listPanel:FindDirect("Group_Content_" .. i)
    subPanel:FindDirect("Title_" .. i .. "/Label_Title_" .. i):GetComponent("UILabel").text = title
    subPanel:FindDirect("Label_Content_" .. i):GetComponent("UILabel").text = content
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
DlgGangCrossBattleRules.Commit()
return DlgGangCrossBattleRules

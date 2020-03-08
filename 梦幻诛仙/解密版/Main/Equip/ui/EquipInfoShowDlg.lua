local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local EquipInfoShowDlg = Lplus.Extend(ECPanelBase, "EquipInfoShowDlg")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local def = EquipInfoShowDlg.define
def.field("table")._equip = nil
def.field("string")._titleName = ""
def.field("table")._tag = nil
def.field("string")._strenNameContent = ""
def.field("string")._strenValContent = ""
def.field("string")._transNameContent = ""
def.field("string")._transValContent = ""
def.field("table")._position = nil
def.field("string")._transProStr = ""
def.field("number")._strenNum = 0
def.field("table").m_HunPreInfo = nil
def.field("number").m_EquipId = 0
def.override().OnCreate = function(self)
  self:UpdateInfo()
end
def.static("string", "number", "table", "table", "string", "string", "table", "string", "number", "table").ShowEquipInfo = function(titleName, equipId, equip, tag, strenNameContent, strenValContent, position, proNumStr, strenNum, hunPreInfo)
  local dlg = EquipInfoShowDlg()
  dlg._titleName = titleName
  dlg._equip = equip
  dlg._tag = tag
  dlg._strenNameContent = strenNameContent
  dlg._strenValContent = strenValContent
  dlg._position = position
  dlg._transProStr = proNumStr
  dlg._strenNum = strenNum
  dlg.m_HunPreInfo = hunPreInfo
  dlg.m_EquipId = equipId
  dlg:CreatePanel(RESPATH.PREFAB_EQUIP_INFO_PANEL, 2)
  dlg:SetOutTouchDisappear()
end
def.method().UpdateInfo = function(self)
  self:UpdateTitle()
  self:UpdateEquipInfo()
  self:UpdateContent()
  self:ShowCompare()
  local tipFrame = self.m_panel:FindDirect("Table_BgEquipPreview")
  local bg = tipFrame:GetComponent("UISprite")
  if self._position.auto then
    local x, y = require("Common.MathHelper").ComputeTipsAutoPosition(self._position.sourceX, self._position.sourceY, self._position.sourceW, self._position.sourceH, bg:get_width(), bg:get_height(), 0, 1)
    tipFrame:set_localPosition(Vector.Vector3.new(x, y + bg:get_height() / 2, 0))
    self.m_panel:FindDirect("Btn_Close"):SetActive(false)
  else
    self.m_panel:set_localPosition(Vector.Vector3.new(self._position.sourceX, self._position.sourceY - 30, 0))
  end
end
def.method().ShowCompare = function(self)
  if self._tag == nil or self._tag.wearPos == nil then
    return
  end
  local comparekey, itemCompare = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, self._tag.wearPos)
  if -1 ~= comparekey then
    local source = self.m_panel:FindDirect("Table_BgEquipPreview")
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = source:GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowTips(itemCompare, ItemModule.EQUIPBAG, comparekey, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y - sprite:get_height() / 2, sprite:get_width(), sprite:get_height(), 0)
  end
end
def.method().UpdateTitle = function(self)
  local tipFrame = self.m_panel:FindDirect("Table_BgEquipPreview")
  local label = tipFrame:FindDirect("Group_Top/Img_Bg/Label_Title"):GetComponent("UILabel")
  label:set_text(self._titleName)
end
def.method().UpdateEquipInfo = function(self)
  if nil == self._equip then
    warn("pre euqip is nil~~~")
    return
  end
  local tipFrame = self.m_panel:FindDirect("Table_BgEquipPreview")
  local equipInfo = tipFrame:FindDirect("Group_Top/Equip_Info")
  local uiSprite = equipInfo:FindDirect("Img_Item/Img_Icon"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiSprite, self._equip.iconId)
  equipInfo:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(self._equip.name)
  local strLv = self._equip.useLevel .. textRes.Equip[30]
  equipInfo:FindDirect("Label_Lv"):GetComponent("UILabel"):set_text(strLv)
  equipInfo:FindDirect("Label_Type"):GetComponent("UILabel"):set_text(self._equip.typeName)
end
def.method().UpdateContent = function(self)
  local tipFrame = self.m_panel:FindDirect("Table_BgEquipPreview")
  local Equip_Info = tipFrame:FindDirect("Group_Top/Equip_Info")
  local strenNameLabel = Equip_Info:FindDirect("Label_LingContent1")
  local strenValLabel = Equip_Info:FindDirect("Label_LingContent2")
  local HunListView = tipFrame:FindDirect("Scroll View_HunContent/List_HunContent")
  local Group_Tips = tipFrame:FindDirect("Group_Tips")
  local Group_Quality = Group_Tips:FindDirect("Group_Quality")
  strenNameLabel:GetComponent("UILabel"):set_text(self._strenNameContent)
  strenValLabel:GetComponent("UILabel"):set_text(self._strenValContent)
  local Label_AddNum = Equip_Info:FindDirect("Title_Ling/Label_AddNum")
  if 0 < self._strenNum then
    Label_AddNum:SetActive(true)
    Label_AddNum:GetComponent("UILabel"):set_text(string.format("+%d", self._strenNum))
  else
    Label_AddNum:SetActive(false)
  end
  self:UpdateHunListPreView(HunListView)
  self:UpdateHunColorAndNumView(Group_Quality)
end
def.method("userdata").UpdateHunColorAndNumView = function(self, QualityGroup)
  local EquipUtils = require("Main.Equip.EquipUtils")
  local hunNumList = EquipUtils.GetHunNumList(self.m_EquipId)
  local labelList = {
    [1] = QualityGroup:FindDirect("Label_WhiteNum"):GetComponent("UILabel"),
    [2] = QualityGroup:FindDirect("Label_GreenNum"):GetComponent("UILabel"),
    [3] = QualityGroup:FindDirect("Label_BlueNum"):GetComponent("UILabel"),
    [4] = QualityGroup:FindDirect("Label_PurpleNum"):GetComponent("UILabel"),
    [5] = QualityGroup:FindDirect("Label_OrangeNum"):GetComponent("UILabel")
  }
  for i = 1, 5 do
    local hunNum = hunNumList[i]
    if hunNum == nil then
      hunNum = 0
    end
    labelList[i]:set_text(hunNum)
  end
end
def.method("userdata").UpdateHunListPreView = function(self, hunListView)
  if hunListView == nil then
    return
  end
  local curHunCfg = self.m_HunPreInfo
  if curHunCfg == nil then
    return
  end
  local uiList = hunListView:GetComponent("UIList")
  uiList.renameControl = true
  local hunNum = #curHunCfg
  local items = GUIUtils.InitUIList(hunListView, hunNum)
  for i = 1, hunNum do
    local item = items[i]
    local hunInfo = curHunCfg[i]
    local hunNameLabel = item:FindDirect(string.format("Label_HunContent1_%d", i)):GetComponent("UILabel")
    local hunValueLabel = item:FindDirect(string.format("Label_HunContent2_%d", i)):GetComponent("UILabel")
    local usefulSprite = item:FindDirect(string.format("Img_Useful_%d", i))
    hunNameLabel.text = hunInfo.hunName
    hunValueLabel.text = hunInfo.hunValue
    if hunInfo.IsRecommend then
      usefulSprite:SetActive(true)
    else
      usefulSprite:SetActive(false)
    end
  end
  GUIUtils.Reposition(hunListView, "UIList", 0)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
    self = nil
  elseif id == "Btn_SkillKu" then
    local GrowGuidePanel = require("Main.Grow.ui.GrowGuidePanel")
    local BaodianNode = require("Main.Grow.ui.BaodianNode")
    local BaodianSkillPanel = require("Main.Grow.ui.BaodianSkillPanel")
    local paramsInfo = {
      targetBaodianNode = BaodianNode.BaodianNodes.Skill_Node,
      subTargetBaodianNode = BaodianSkillPanel.NodeId.Equip
    }
    GrowGuidePanel.Instance():ShowDlgEx(GrowGuidePanel.NodeId.Encyclopedia, paramsInfo)
  end
end
EquipInfoShowDlg.Commit()
return EquipInfoShowDlg

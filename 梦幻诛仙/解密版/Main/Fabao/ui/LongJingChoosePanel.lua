local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local LongJingChoosePanel = Lplus.Extend(ECPanelBase, "LongJingChoosePanel")
local def = LongJingChoosePanel.define
def.field("number").m_MainAttrId = -1
def.field("number").m_MainLevel = -1
def.field("number").m_SelectIndex = -1
def.field("table").m_CanSelectLongJingList = nil
def.field("function").m_CallBack = nil
local instance
def.static("=>", LongJingChoosePanel).Instance = function()
  if nil == instance then
    instance = LongJingChoosePanel()
    instance.m_MainAttrId = -1
    instance.m_MainLevel = -1
    instance.m_SelectIndex = -1
    instance.m_CanSelectLongJingList = nil
  end
  return instance
end
def.method("number", "number", "function").ShowPanel = function(self, mainAttrId, mainLevel, cb)
  if self:IsShow() then
    return
  end
  self.m_MainAttrId = mainAttrId
  self.m_MainLevel = mainLevel
  self.m_CallBack = cb
  self:CreatePanel(RESPATH.PREFAB_LONGJING_CHOOSE_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateData()
  self:UpdateUI()
end
def.method().UpdateData = function(self)
  self.m_CanSelectLongJingList = require("Main.Fabao.FabaoUtils").GetLongJingByAttrIdAndLevel(self.m_MainAttrId, self.m_MainLevel)
end
def.method().UpdateUI = function(self)
  local listView = self.m_panel:FindDirect("Img_Bg/Img_BgItem/Scroll View/Grid")
  local num = self.m_CanSelectLongJingList and #self.m_CanSelectLongJingList or 0
  local items = GUIUtils.InitUIList(listView, num, false)
  for i = 1, num do
    local itemObj = items[i]
    itemObj.name = string.format("longjingItem_%d", i)
    local uiTexture = itemObj:FindDirect(string.format("Texture_%d", i)):GetComponent("UITexture")
    local nameLabel = itemObj:FindDirect(string.format("Label_Name_%d", i)):GetComponent("UILabel")
    itemObj:FindDirect(string.format("Label_Nun_%d", i)):SetActive(false)
    local longjing = self.m_CanSelectLongJingList[i]
    GUIUtils.FillIcon(uiTexture, longjing.iconId)
    nameLabel:set_text(longjing.name)
  end
  self.m_msgHandler:Touch(listView)
  GUIUtils.Reposition(listView, "UIList", 0.01)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif string.find(id, "longjingItem_") then
    self:OnClickSelectLongJingBtn(clickObj)
  elseif "Btn_Get" == id then
    self:OnClickComfirmChooseBtn()
  end
end
def.method("userdata").OnClickSelectLongJingBtn = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  local index = tonumber(strs[2])
  self.m_SelectIndex = index
  local selectLongjing = self.m_CanSelectLongJingList[index]
  if selectLongjing then
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(selectLongjing.id, clickObj, -1, true)
  end
end
def.method().OnClickComfirmChooseBtn = function(self)
  warn("~~~~~~OnClickComfirmChooseBtn~~~~~", self.m_SelectIndex, self.m_CanSelectLongJingList[self.m_SelectIndex])
  if -1 == self.m_SelectIndex or nil == self.m_CanSelectLongJingList[self.m_SelectIndex] then
    Toast(textRes.Fabao[125])
    return
  end
  if self.m_CallBack then
    self.m_CallBack(self.m_CanSelectLongJingList[self.m_SelectIndex])
  end
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self.m_MainAttrId = -1
  self.m_MainLevel = -1
  self.m_SelectIndex = -1
  self.m_CanSelectLongJingList = nil
  self.m_CallBack = nil
end
LongJingChoosePanel.Commit()
return LongJingChoosePanel

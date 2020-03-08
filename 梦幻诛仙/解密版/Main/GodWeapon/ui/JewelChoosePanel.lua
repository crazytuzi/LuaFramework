local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
local JewelChoosePanel = Lplus.Extend(ECPanelBase, "JewelChoosePanel")
local def = JewelChoosePanel.define
local ItemUtils = require("Main.Item.ItemUtils")
local txtConst = textRes.GodWeapon.Jewel
def.field("number").m_SelectIndex = -1
def.field("table")._uiStatus = nil
def.field("table")._canSelJewelList = nil
def.field("function").m_CallBack = nil
local instance
def.static("=>", JewelChoosePanel).Instance = function()
  if nil == instance then
    instance = JewelChoosePanel()
    instance._canSelJewelList = nil
  end
  return instance
end
def.method("number", "number", "function").ShowPanel = function(self, itemId, mainLevel, cb)
  if self:IsShow() then
    return
  end
  self._uiStatus = {}
  self._uiStatus.itemId = itemId
  self._uiStatus.mainLv = mainLevel
  self._uiStatus.selIdx = -1
  self.m_CallBack = cb
  self:CreatePanel(RESPATH.PREFAB_LONGJING_CHOOSE_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  local lblTitle = self.m_panel:FindDirect("Img_Bg/Img_Title/Label")
  GUIUtils.SetText(lblTitle, txtConst[51])
  self:UpdateData()
  self:UpdateUI()
end
def.method().UpdateData = function(self)
  local allClsJewels = JewelUtils.GetJewelsBasicCfgByEquipType(0, -1)
  self._canSelJewelList = {}
  for i = 1, #allClsJewels do
    local jewel = allClsJewels[i]
    if jewel.itemId ~= self._uiStatus.itemId and jewel.level == self._uiStatus.mainLv then
      table.insert(self._canSelJewelList, jewel)
    end
  end
end
def.method().UpdateUI = function(self)
  local listView = self.m_panel:FindDirect("Img_Bg/Img_BgItem/Scroll View/Grid")
  local num = self._canSelJewelList and #self._canSelJewelList or 0
  local items = GUIUtils.InitUIList(listView, num, false)
  for i = 1, num do
    local itemObj = items[i]
    itemObj.name = string.format("JewelItem_%d", i)
    local uiTexture = itemObj:FindDirect(string.format("Texture_%d", i)):GetComponent("UITexture")
    local nameLabel = itemObj:FindDirect(string.format("Label_Name_%d", i)):GetComponent("UILabel")
    itemObj:FindDirect(string.format("Label_Nun_%d", i)):SetActive(false)
    local jewel = self._canSelJewelList[i]
    local itemBase = ItemUtils.GetItemBase(jewel.itemId)
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    nameLabel:set_text(itemBase.name)
  end
  self.m_msgHandler:Touch(listView)
  GUIUtils.Reposition(listView, "UIList", 0.01)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif string.find(id, "JewelItem_") then
    self:OnClickSelectJewelBtn(clickObj)
  elseif "Btn_Get" == id then
    self:OnClickComfirmChooseBtn()
  end
end
def.method("userdata").OnClickSelectJewelBtn = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  local index = tonumber(strs[2])
  self._uiStatus.selIdx = index
  local selJewel = self._canSelJewelList[index]
  if selJewel then
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(selJewel.itemId, clickObj, -1, true)
  end
end
def.method().OnClickComfirmChooseBtn = function(self)
  local selIdx = self._uiStatus.selIdx or -1
  if -1 == selIdx or nil == self._canSelJewelList[selIdx] then
    Toast(txtConst[50])
    return
  end
  if self.m_CallBack then
    self.m_CallBack(self._canSelJewelList[selIdx])
  end
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self._uiStatus = nil
  self._canSelJewelList = nil
  self.m_CallBack = nil
end
JewelChoosePanel.Commit()
return JewelChoosePanel

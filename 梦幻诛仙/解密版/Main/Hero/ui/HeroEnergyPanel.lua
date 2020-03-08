local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local HeroEnergyPanel = Lplus.Extend(ECPanelBase, "HeroEnergyPanel")
local HeroEnergyMgr = require("Main.Hero.mgr.HeroEnergyMgr")
local ConsumeEnergy = require("Main.Hero.op.ConsumeEnergy")
local GUIUtils = require("GUI.GUIUtils")
local def = HeroEnergyPanel.define
local Vector = require("Types.Vector")
def.field("table").sourceItemList = nil
def.field("table").sourceItemDataList = nil
def.field("table").sourceItemStateList = nil
def.field("table").consumeItemList = nil
def.field("table").consumeItemDataList = nil
def.field("number").selectedActivityIndex = 0
def.field("table").uiObjs = nil
local instance
def.static("=>", HeroEnergyPanel).Instance = function()
  if instance == nil then
    instance = HeroEnergyPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_HERO_ENERGY_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.selectedActivityIndex = 0
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, HeroEnergyPanel.OnEnergyChanged)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, HeroEnergyPanel.OnEnergyChanged)
  self:Clear()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, #"Label_Num_") == "Label_Num_" then
    self:OnEnergySourceItemObjClicked(obj)
  elseif id == "Btn_Go" then
    self:OnParticipateActivityButtonClick()
  elseif id == "Btn_Left" then
    self:OnBtnLeftObjClicked(obj)
  elseif id == "Btn_Right" then
    self:OnBtnRightObjClicked(obj)
  elseif id == "Btn_Make" then
    self:OnBtnMakeObjClicked(obj)
  elseif id == "Btn_Add" then
    self:OnAddEnergyBtnClick()
  elseif id == "Btn_Tips" then
    self:OnEnergyTipButtonClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Img_BgSlider = self.uiObjs.Img_Bg0:FindDirect("Group_Slider/Img_BgSlider")
  self.uiObjs.Grid_Left = self.uiObjs.Img_Bg0:FindDirect("Group_Left/Scroll View_Left/Grid_Left")
  self.uiObjs.Img_BgLabel = self.uiObjs.Grid_Left:FindDirect("Img_BgLabel")
  self.uiObjs.Img_BgLabel:SetActive(false)
  self.uiObjs.Img_BgLabel:FindDirect("Img_Select"):SetActive(true)
  self.uiObjs.Grid_Right = self.uiObjs.Img_Bg0:FindDirect("Group_Right/Scroll View_Right/Grid_Right")
  self.uiObjs.Img_Bg = self.uiObjs.Grid_Right:FindDirect("Img_Bg")
  self.uiObjs.Img_Bg:SetActive(false)
  self.sourceItemList = {}
  self.consumeItemList = {}
  self.sourceItemStateList = {}
end
def.method().UpdateUI = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  self:SetEnergyBar(heroProp.energy, heroProp:GetMaxEnergy())
  self:SetEnergySourceList()
  self:SetEnergyConsumeList()
end
def.method("number", "number").SetEnergyBar = function(self, value, maxValue)
  self.uiObjs.Img_BgSlider:GetComponent("UISlider"):set_value(value / maxValue)
  local ui_Label_Num = self.uiObjs.Img_BgSlider:FindDirect("Label_Num")
  ui_Label_Num:GetComponent("UILabel"):set_text(string.format("%d/%d", value, maxValue))
end
def.method().SetEnergySourceList = function(self)
  local sourceDataList = HeroEnergyMgr.Instance():GetEnergySourceDataList()
  self.sourceItemDataList = {}
  local viewDataList = {}
  local amount = 0
  for i, sourceData in ipairs(sourceDataList) do
    local awardType = sourceData.awardType
    local awardedValue = sourceData.awardedValue
    local remainCount = sourceData:GetRemianCount()
    local maxVigor = HeroEnergyMgr.Instance():CalcMaxAwardEnergy(awardType, awardedValue, remainCount)
    if maxVigor > 0 then
      amount = amount + 1
      local fulldesc = sourceData:GetFullDesc()
      local viewData = {
        fulldesc,
        awardedValue,
        maxVigor
      }
      viewDataList[amount] = viewData
      self.sourceItemStateList[amount] = {active = true}
      self.sourceItemDataList[amount] = sourceData
    end
  end
  self:PrepareEnergySourceItem(self.uiObjs.Grid_Left, amount)
  for index, viewData in ipairs(viewDataList) do
    self:SetEnergySourceItem(index, unpack(viewData))
  end
end
def.method("userdata", "number").PrepareEnergySourceItem = function(self, gridObj, amount)
  local grid = gridObj:GetComponent("UIGrid")
  local count = grid:GetChildListCount()
  local max = amount < count and count or amount
  for i = 1, max do
    if i > count then
      local template = self.uiObjs.Img_BgLabel
      self:AddEnergySourceItem(grid, template, i)
    elseif amount < i then
      self:RemoveEnergySourceItem(i)
    end
  end
  grid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "userdata", "number").AddEnergySourceItem = function(self, grid, template, index)
  local item = GameObject.Instantiate(template)
  item.name = "Label_Num_" .. index
  item.transform.parent = grid.gameObject.transform
  item.transform.localScale = Vector.Vector3.one
  item:SetActive(true)
  table.insert(self.sourceItemList, item)
end
def.method("number").RemoveEnergySourceItem = function(self, index)
  local item = self.sourceItemList[index]
  GameObject.Destroy(item)
  self.sourceItemList[index] = nil
end
def.method("number", "string", "number", "number").SetEnergySourceItem = function(self, index, fulldesc, rewarded, maxReward)
  local item = self.sourceItemList[index]
  local Label_Name = item:FindDirect("Label_Name")
  GUIUtils.SetText(Label_Name, fulldesc)
  local Label_Num = item:FindDirect("Label_Num")
  GUIUtils.SetText(Label_Num, string.format("%d/%d", rewarded, maxReward))
  if maxReward <= rewarded and rewarded ~= 0 then
    self.sourceItemStateList[index] = {active = false}
    GUIUtils.SetActive(Label_Num, false)
    GUIUtils.SetActive(item:FindDirect("Img_Finished"), true)
  else
    GUIUtils.SetActive(item:FindDirect("Img_Finished"), false)
  end
end
def.method("userdata").OnEnergySourceItemObjClicked = function(self, obj)
  local uiToggle = obj:GetComponent("UIToggle")
  if uiToggle.value then
    local id = obj.name
    local index = tonumber(string.sub(id, #"Label_Num_" + 1, -1))
    self.selectedActivityIndex = index
  else
    self.selectedActivityIndex = 0
  end
end
def.method().OnParticipateActivityButtonClick = function(self)
  if PlayerIsInFight() then
    Toast(textRes.Common[30])
    return
  end
  if self.selectedActivityIndex == 0 then
    Toast(textRes.Hero[28])
    return
  end
  if not self.sourceItemStateList[self.selectedActivityIndex].active then
    Toast(textRes.Hero[36])
    return
  end
  local sourceData = self.sourceItemDataList[self.selectedActivityIndex]
  if sourceData:GoToGetEnergy() then
    require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
  end
end
def.method().SetEnergyConsumeList = function(self)
  if self.consumeItemDataList == nil then
    self.consumeItemDataList = HeroEnergyMgr.Instance():GetConsumeEnergyList()
  end
  self:UpdateEnergyConsumeList()
end
def.method().UpdateEnergyConsumeList = function(self)
  local amount = #self.consumeItemDataList
  self:PrepareEnergyConsumeItem(self.uiObjs.Grid_Right, amount)
  for i, v in ipairs(self.consumeItemDataList) do
    self:SetEnergyConsumeItem(i, v)
  end
end
def.method("userdata", "number").PrepareEnergyConsumeItem = function(self, gridObj, amount)
  local grid = gridObj:GetComponent("UIGrid")
  local count = grid:GetChildListCount()
  local max = amount < count and count or amount
  for i = 1, max do
    if i > count then
      local template = self.uiObjs.Img_Bg
      self:AddEnergyConsumeItem(grid, template, i)
    elseif amount < i then
      self:RemoveEnergyConsumeItem(i)
    end
  end
  grid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "userdata", "number").AddEnergyConsumeItem = function(self, grid, template, index)
  local item = GameObject.Instantiate(template)
  item.name = "ConsumeItem_" .. index
  item.transform.parent = grid.gameObject.transform
  item.transform.localScale = Vector.Vector3.one
  item:SetActive(true)
  table.insert(self.consumeItemList, item)
end
def.method("number").RemoveEnergyConsumeItem = function(self, index)
  local item = self.consumeItemList[index]
  GameObject.Destroy(item)
  self.consumeItemList[index] = nil
end
def.method("number", ConsumeEnergy).SetEnergyConsumeItem = function(self, index, consumeItemData)
  local item = self.consumeItemList[index]
  local count = #consumeItemData.itemList
  if count > 1 then
    item:FindDirect("Group_Btn"):SetActive(true)
    if consumeItemData.selectedIndex == 1 then
      item:FindDirect("Group_Btn/Btn_Left"):SetActive(false)
    else
      item:FindDirect("Group_Btn/Btn_Left"):SetActive(true)
    end
    if consumeItemData.selectedIndex == count then
      item:FindDirect("Group_Btn/Btn_Right"):SetActive(false)
    else
      item:FindDirect("Group_Btn/Btn_Right"):SetActive(true)
    end
  else
    item:FindDirect("Group_Btn"):SetActive(false)
  end
  local selectedItemData = consumeItemData.itemList[consumeItemData.selectedIndex]
  item:FindDirect("Label_RightName"):GetComponent("UILabel"):set_text(selectedItemData.name)
  item:FindDirect("Btn_Make/Label_Make"):GetComponent("UILabel"):set_text(consumeItemData.opName)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local text
  if heroProp.energy >= selectedItemData.consume then
    text = string.format(textRes.Hero[27], "-", selectedItemData.consume)
  else
    text = string.format(textRes.Hero[27], "FF0000", selectedItemData.consume)
  end
  item:FindDirect("Label_UseNum"):GetComponent("UILabel"):set_text(text)
  local uiTexture = item:FindDirect("Img_BgIcon/Texture_Icon"):GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, selectedItemData.iconId)
  local levelLabel = item:FindDirect("Img_BgIcon/Label"):GetComponent("UILabel")
  local text = selectedItemData.level
  if selectedItemData.level < 0 then
    text = ""
  end
  levelLabel.text = text
end
def.method("userdata").OnBtnRightObjClicked = function(self, obj)
  local item = obj.transform.parent.parent
  local index = tonumber(string.sub(item.name, #"ConsumeItem_" + 1, -1))
  local consumeItemData = self.consumeItemDataList[index]
  consumeItemData.selectedIndex = consumeItemData.selectedIndex + 1
  self:SetEnergyConsumeItem(index, consumeItemData)
end
def.method("userdata").OnBtnLeftObjClicked = function(self, obj)
  local item = obj.transform.parent.parent
  local index = tonumber(string.sub(item.name, #"ConsumeItem_" + 1, -1))
  local consumeItemData = self.consumeItemDataList[index]
  consumeItemData.selectedIndex = consumeItemData.selectedIndex - 1
  self:SetEnergyConsumeItem(index, consumeItemData)
end
def.method("userdata").OnBtnMakeObjClicked = function(self, obj)
  local item = obj.transform.parent
  local index = tonumber(string.sub(item.name, #"ConsumeItem_" + 1, -1))
  self.consumeItemDataList[index]:Call()
end
def.method().OnEnergyTipButtonClicked = function(self)
  local text = require("Main.Hero.HeroUtility").GetEnergyTipText()
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tmpPosition = {
    x = 0,
    y = 0,
    z = 0
  }
  CommonUITipsDlg.Instance():ShowDlg(text, tmpPosition)
end
def.method().OnAddEnergyBtnClick = function(self)
  local MallPanel = require("Main.Mall.ui.MallPanel")
  local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
  local VIGOUR_ITEM_ID = require("Main.Hero.HeroUtility").Instance():GetRoleCommonConsts("VIGOUR_ITEM_ID")
  local itemId = VIGOUR_ITEM_ID
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Treasure, itemId, MallType.PRECIOUS_MALL)
end
def.static("table", "table").OnEnergyChanged = function()
  local self = instance
  self:UpdateUI()
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.sourceItemList = nil
  self.consumeItemList = nil
  self.consumeItemDataList = nil
end
return HeroEnergyPanel.Commit()

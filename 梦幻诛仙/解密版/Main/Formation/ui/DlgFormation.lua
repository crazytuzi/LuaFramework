local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgFormation = Lplus.Extend(ECPanelBase, "DlgFormation")
local def = DlgFormation.define
local FormationModule = Lplus.ForwardDeclare("FormationModule")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local FormationUtils = require("Main.Formation.FormationUtils")
def.field("number").openFormation = 0
def.field("number").selectFormation = 0
def.field("number").showLevel = 1
def.field("table").learnFormations = nil
def.field("table").unlearnFormations = nil
def.field("function").callback = nil
def.field("number").infoState = 0
def.field("table").AdvanceItemInfo = nil
def.field("boolean").canAddExp = true
def.method("number").SelectFormation = function(self, formationId)
  if formationId == 0 then
    self:SelectFirst()
  else
    self.selectFormation = formationId
  end
  if self.m_panel ~= nil then
    self:ToggleFormationInfo(0)
  end
end
def.method("number").OpenFormation = function(self, formationId)
  self.openFormation = formationId
  if self.m_panel ~= nil then
    self:UpdateFormationList()
    self:ToggleFormationInfo(0)
    if self.callback ~= nil then
      self.callback(self.openFormation)
      if PlayerIsInFight() then
        Toast(textRes.Formation[14])
      elseif formationId == 0 then
        Toast(textRes.Formation[18])
      else
        Toast(textRes.Formation[17])
      end
    end
  end
end
def.method("function").SetToggleCallback = function(self, callback)
  self.callback = callback
end
def.override().OnCreate = function(self)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdatePanel()
  end
end
def.method().UpdateAll = function(self)
  self:UpdateFormationList()
  self:UpdateAdvanceInfo()
  self:UpdateFormationInfo()
end
def.method().UpdatePanel = function(self)
  self:UpdateFormationList()
  self:ToggleFormationInfo(0)
end
def.method().UpdateFormationList = function(self)
  self.learnFormations, self.unlearnFormations = FormationModule.Instance():GetSepFormationList()
  local bookGrid = self.m_panel:FindDirect("Img_List/Scroll View/Grid_Book")
  while bookGrid:get_childCount() > 1 do
    Object.DestroyImmediate(bookGrid:GetChild(bookGrid:get_childCount() - 1))
  end
  local template = bookGrid:FindDirect("Img_Book01")
  template:SetActive(false)
  local list = self:GetIdSortList(self.learnFormations)
  for k, v in ipairs(list) do
    local itemNew = Object.Instantiate(template)
    itemNew.parent = bookGrid
    itemNew:set_localScale(Vector.Vector3.one)
    itemNew:SetActive(true)
    itemNew.name = string.format("Img_Book_%s", v)
    self:SetFormationItem(itemNew, self.learnFormations[v], true)
  end
  list = self:GetIdSortList(self.unlearnFormations)
  for k, v in ipairs(list) do
    local itemNew = Object.Instantiate(template)
    itemNew.parent = bookGrid
    itemNew:set_localScale(Vector.Vector3.one)
    itemNew:SetActive(true)
    itemNew.name = string.format("Img_Book_%s", v)
    self:SetFormationItem(itemNew, self.unlearnFormations[v], false)
  end
  bookGrid:GetComponent("UIGrid"):Reposition()
  local selectItem = bookGrid:FindDirect(string.format("Img_Book_%s", self.selectFormation))
  selectItem:GetComponent("UIToggle"):set_value(true)
  GameUtil.AddGlobalLateTimer(0.1, true, function()
    if self.m_panel and not self.m_panel.isnil and not selectItem.isnil then
      local scrollView = self.m_panel:FindDirect("Img_List/Scroll View")
      scrollView:GetComponent("UIScrollView"):DragToMakeVisible(selectItem.transform, 8)
    end
  end)
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "table", "boolean").SetFormationItem = function(self, item, formation, islearned)
  if islearned then
    local icon = item:FindDirect("Img_BgIcon/Icon_Book"):GetComponent("UITexture")
    GUIUtils.FillIcon(icon, formation.icon)
    GUIUtils.SetTextureEffect(icon, GUIUtils.Effect.Normal)
    local name = item:FindDirect("Label_Name"):GetComponent("UILabel")
    name:set_text(formation.name)
    local learned = item:FindDirect("Group_Learned")
    learned:SetActive(true)
    local level = FormationModule.Instance():GetFormationLevel(formation.id)
    local levelLabel = learned:FindDirect("Label_Lv"):GetComponent("UILabel")
    levelLabel:set_text(string.format(textRes.Formation[12], level))
    local isCurrent = self.openFormation == formation.id
    learned:FindDirect("Img_Use"):SetActive(isCurrent)
    local itemId = FormationUtils.GetNeedBook(formation.id)
    local hasbook = ItemModule.Instance():GetItemCountById(itemId) > 0
    local advanceLabel, advanceImg, fullLabel = learned:FindDirect("Label_Advance"), learned:FindDirect("Img_Advance"), learned:FindDirect("Label_Full")
    local formationConst = FormationUtils.GetFormationConst()
    if level >= formationConst.maxLevel then
      fullLabel:SetActive(true)
      advanceLabel:SetActive(false)
      advanceImg:SetActive(false)
    elseif hasbook then
      fullLabel:SetActive(false)
      advanceLabel:SetActive(true)
      advanceImg:SetActive(true)
    else
      fullLabel:SetActive(false)
      advanceLabel:SetActive(false)
      advanceImg:SetActive(false)
    end
    item:FindDirect("Group_Learning"):SetActive(false)
    item:FindDirect("Group_NoLearn"):SetActive(false)
  else
    local icon = item:FindDirect("Img_BgIcon/Icon_Book"):GetComponent("UITexture")
    GUIUtils.FillIcon(icon, formation.icon)
    GUIUtils.SetTextureEffect(icon, GUIUtils.Effect.Gray)
    local name = item:FindDirect("Label_Name"):GetComponent("UILabel")
    name:set_text(formation.name)
    item:FindDirect("Group_Learned"):SetActive(false)
    local itemId = FormationUtils.GetNeedBook(formation.id)
    local hasbook = ItemModule.Instance():GetItemCountById(itemId) > 0
    item:FindDirect("Group_Learning"):SetActive(hasbook)
    item:FindDirect("Group_NoLearn"):SetActive(not hasbook)
  end
end
def.method().UpdateFormationInfo = function(self)
  if self.learnFormations[self.selectFormation] ~= nil then
    local on = self.selectFormation == self.openFormation
    self.m_panel:FindDirect("Btn_Learn"):SetActive(false)
    self.m_panel:FindDirect("Btn_Switch"):SetActive(true)
    self.m_panel:FindDirect("Btn_Switch"):GetComponent("UIToggle"):set_value(on)
  elseif self.unlearnFormations[self.selectFormation] ~= nil then
    self.m_panel:FindDirect("Btn_Learn"):SetActive(true)
    self.m_panel:FindDirect("Btn_Switch"):SetActive(false)
  end
  self:SetFormationKZ(self.selectFormation)
  local lv = FormationModule.Instance():GetFormationLevel(self.selectFormation)
  self.showLevel = lv > 0 and lv or FormationUtils.GetFormationConst().initLevel
  self:SetFormationEffect(self.selectFormation, self.showLevel)
  self:SetExp()
end
def.method("number", "number").SetFormationEffect = function(self, formationId, level)
  local effectTitle = self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Img_BgZfTitle/Label_ZfTitle"):GetComponent("UILabel")
  effectTitle:set_text(string.format(textRes.Formation[11], level))
  local constCfg = FormationUtils.GetFormationConst()
  local formationCfg = FormationUtils.GetFormationCfg(formationId)
  local maxLevel = constCfg.maxLevel
  local minLevel = constCfg.initLevel
  local btnLeft = self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Img_BgZfTitle/Group_BtnLR/Btn_Left")
  local btnRight = self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Img_BgZfTitle/Group_BtnLR/Btn_Right")
  if level <= minLevel then
    btnLeft:GetComponent("UIButton"):set_isEnabled(false)
  else
    btnLeft:GetComponent("UIButton"):set_isEnabled(true)
  end
  if level >= maxLevel then
    btnRight:GetComponent("UIButton"):set_isEnabled(false)
  else
    btnRight:GetComponent("UIButton"):set_isEnabled(true)
  end
  local effectList = self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Grid_ZfEffect")
  for i = 1, 5 do
    local effectLabel = effectList:FindDirect(string.format("Img_ZfEffect%02d/Label_Effect", i)):GetComponent("UILabel")
    local effectAStr = ""
    local effectBStr = ""
    if formationCfg.effectInfo[i].AEffect > 0 then
      local aPropCfg = formationCfg.effectInfo[i].AEffect > 0 and GetCommonPropNameCfg(formationCfg.effectInfo[i].AEffect) or nil
      local aValue = (formationCfg.effectInfo[i].AInit + (level - minLevel) * formationCfg.effectInfo[i].AGrow) / 100
      local isGood = aPropCfg.isGood and aValue >= 0 or not aPropCfg.isGood and aValue < 0
      local symbol = aValue >= 0 and "+" or ""
      local aValueStr = isGood and string.format("[1d7b40]%s%.1f%%[-]", symbol, aValue) or string.format("[ff0000]%s%.1f%%[-]", symbol, aValue)
      effectAStr = string.format("%s %s ", aPropCfg.propName, aValueStr)
    end
    if 0 < formationCfg.effectInfo[i].BEffect then
      local bPropCfg = formationCfg.effectInfo[i].BEffect and GetCommonPropNameCfg(formationCfg.effectInfo[i].BEffect) or nil
      local bValue = (formationCfg.effectInfo[i].BInit + (level - minLevel) * formationCfg.effectInfo[i].BGrow) / 100
      local isGood = bPropCfg.isGood and bValue >= 0 or not bPropCfg.isGood and bValue < 0
      local symbol = bValue >= 0 and "+" or ""
      local bValueStr = isGood and string.format("[1d7b40]%s%.1f%%[-]", symbol, bValue) or string.format("[ff0000]%s%.1f%%[-]", symbol, bValue)
      effectBStr = string.format([[

%s %s ]], bPropCfg.propName, bValueStr)
    end
    effectLabel:set_text(effectAStr .. effectBStr)
  end
end
def.method("number").SetFormationKZ = function(self, formationId)
  local formationCfg = FormationUtils.GetFormationCfg(formationId)
  local kzGrid = self.m_panel:FindDirect("Img_BgTop/Group_Kz/Grid_Kz")
  while kzGrid:get_childCount() > 1 do
    Object.DestroyImmediate(kzGrid:GetChild(kzGrid:get_childCount() - 1))
  end
  local template = kzGrid:FindDirect("Img_BgKz01")
  template:SetActive(false)
  for k, v in pairs(formationCfg.KZInfo) do
    local kzformationCfg = FormationUtils.GetFormationCfg(k)
    local itemNew = Object.Instantiate(template)
    itemNew.parent = kzGrid
    itemNew:set_localScale(Vector.Vector3.one)
    itemNew:SetActive(true)
    itemNew.name = string.format("Img_BgKz_%s", k)
    local name = itemNew:FindDirect("Label_Name"):GetComponent("UILabel")
    name:set_text(kzformationCfg.name)
    local icon = itemNew:FindDirect("Icon_Zf"):GetComponent("UITexture")
    GUIUtils.FillIcon(icon, kzformationCfg.icon)
    local effect = itemNew:FindDirect("Label_Effect"):GetComponent("UILabel")
    effect:set_text(string.format("[1d7b40]%.1f%%[-]", v.value / 100))
  end
  kzGrid:GetComponent("UIGrid"):Reposition()
  local bkGrid = self.m_panel:FindDirect("Img_BgTop/Group_Bk/Grid_Bk")
  while bkGrid:get_childCount() > 1 do
    Object.DestroyImmediate(bkGrid:GetChild(bkGrid:get_childCount() - 1))
  end
  local template = bkGrid:FindDirect("Img_BgBk01")
  template:SetActive(false)
  for k, v in pairs(formationCfg.BKInfo) do
    local bkformationCfg = FormationUtils.GetFormationCfg(k)
    local itemNew = Object.Instantiate(template)
    itemNew.parent = bkGrid
    itemNew:set_localScale(Vector.Vector3.one)
    itemNew:SetActive(true)
    itemNew.name = string.format("Img_BgBk_%s", k)
    local name = itemNew:FindDirect("Label_Name"):GetComponent("UILabel")
    name:set_text(bkformationCfg.name)
    local icon = itemNew:FindDirect("Icon_Zf"):GetComponent("UITexture")
    GUIUtils.FillIcon(icon, bkformationCfg.icon)
    local effect = itemNew:FindDirect("Label_Effect"):GetComponent("UILabel")
    effect:set_text(string.format("[ff0000]%.1f%%[-]", v.value / 100))
  end
  bkGrid:GetComponent("UIGrid"):Reposition()
end
def.method().SetExp = function(self)
  local formationCfg = FormationUtils.GetFormationCfg(self.selectFormation)
  local formationConst = FormationUtils.GetFormationConst()
  local level = FormationModule.Instance():GetFormationLevel(self.selectFormation)
  local exp = FormationModule.Instance():GetFormationExp(self.selectFormation)
  if level == 0 then
    self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Group_NoLearn"):SetActive(true)
    self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Group_Exp"):SetActive(false)
    self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Group_NoAdvance"):SetActive(false)
  else
    self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Group_NoLearn"):SetActive(false)
    if level >= formationConst.maxLevel then
      self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Group_NoAdvance"):SetActive(true)
      self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Group_Exp"):SetActive(false)
    else
      self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Group_Exp"):SetActive(true)
      self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Group_NoAdvance"):SetActive(false)
      local needExp = formationConst.LevelUpExp[level]
      local expLabel = self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Group_Exp/Slider_Exp/Label_Num"):GetComponent("UILabel")
      expLabel:set_text(string.format("%d/%d", exp, needExp))
      local slider = self.m_panel:FindDirect("Img_BgDetail/Group_Zf/Group_Exp/Slider_Exp"):GetComponent("UISlider")
      slider.value = exp / needExp
    end
  end
end
def.method().UpdateAdvanceInfo = function(self)
  if self.infoState == 1 then
    self:SetItemInfo()
    self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Group_NoItem"):SetActive(false)
    self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Group_UseItem"):SetActive(true)
    self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Btn_Confirm"):SetActive(true)
    self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Btn_Back"):SetActive(true)
    self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Slider_Exp"):SetActive(true)
    self:SetItemGrid()
    self:SetAdvanceExp()
  end
end
def.method().SetAdvanceExp = function(self)
  local formationCfg = FormationUtils.GetFormationCfg(self.selectFormation)
  local formationConst = FormationUtils.GetFormationConst()
  local level = FormationModule.Instance():GetFormationLevel(self.selectFormation)
  local fullLabel = self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Label_Full")
  local slider = self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Slider_Exp")
  if level >= formationConst.maxLevel then
    fullLabel:SetActive(true)
    slider:SetActive(false)
    return
  else
    fullLabel:SetActive(false)
    slider:SetActive(true)
  end
  local exp = FormationModule.Instance():GetFormationExp(self.selectFormation)
  local addexp = 0
  for k, v in ipairs(self.AdvanceItemInfo) do
    local exp = v.select * FormationUtils.CalcAddExp(v.id, self.selectFormation)
    addexp = addexp + exp
  end
  local needExp = formationConst.LevelUpExp[level]
  slider:GetComponent("UISlider").value = exp / needExp
  local addSlider = slider:FindDirect("Slider_ExpAdd")
  if addexp > 0 then
    addSlider:SetActive(true)
    addSlider:GetComponent("UISlider").value = (exp + addexp) / needExp
  else
    addSlider:SetActive(false)
  end
  local expLabel = self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Slider_Exp/Label_Num"):GetComponent("UILabel")
  if addexp > 0 then
    expLabel:set_text(string.format("%d[00ff00](+%d)[-]/%d", exp, addexp, needExp))
  else
    expLabel:set_text(string.format("%d/%d", exp, needExp))
  end
  if addexp >= FormationUtils.MaxLevelNeedExp(level, exp) then
    self.canAddExp = false
  else
    self.canAddExp = true
  end
end
def.method().SetItemInfo = function(self)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local books = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.ZHENFA_ITEM)
  local fragments = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.ZHENFA_FRAGMENT_ITEM)
  local items = {}
  for k, v in pairs(books) do
    if items[v.id] == nil then
      items[v.id] = {
        id = v.id,
        num = v.number,
        select = 0
      }
    else
      items[v.id].num = items[v.id].num + v.number
    end
  end
  for k, v in pairs(fragments) do
    if items[v.id] == nil then
      items[v.id] = {
        id = v.id,
        num = v.number,
        select = 0
      }
    else
      items[v.id].num = items[v.id].num + v.number
    end
  end
  self.AdvanceItemInfo = {}
  for k, v in pairs(items) do
    table.insert(self.AdvanceItemInfo, v)
  end
  local itemId = FormationUtils.GetNeedBook(self.selectFormation)
  local function comp(itemInfo1, itemInfo2)
    if itemInfo1.id == itemId then
      return true
    end
    if itemInfo2.id == itemId then
      return false
    end
    return itemInfo1.id < itemInfo2.id
  end
  table.sort(self.AdvanceItemInfo, comp)
  if items[itemId] == nil then
    local item = {
      id = itemId,
      num = 0,
      select = 0
    }
    table.insert(self.AdvanceItemInfo, 1, item)
  end
end
def.method().SetItemGrid = function(self)
  local itemGrid = self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Group_UseItem/Img_BgAdcance/Scroll View_Item/Grid_Items")
  while itemGrid:get_childCount() > 1 do
    Object.DestroyImmediate(itemGrid:GetChild(itemGrid:get_childCount() - 1))
  end
  local template = itemGrid:FindDirect("Img_BgItem")
  template:SetActive(false)
  for k, v in ipairs(self.AdvanceItemInfo) do
    local itemNew = Object.Instantiate(template)
    itemNew.parent = itemGrid
    itemNew:set_localScale(Vector.Vector3.one)
    itemNew:SetActive(true)
    itemNew.name = string.format("Img_BgItem_%d", k)
    local btn_reduce = itemNew:FindDirect("Btn_Reduce")
    btn_reduce.name = string.format("Btn_Reduce_%d", k)
    btn_reduce:SetActive(false)
    self:SetItem(itemNew, v)
  end
  itemGrid:GetComponent("UIGrid"):Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "table").SetItem = function(self, item, info)
  item:GetComponent("UIToggle"):set_value(false)
  local itemBase = ItemUtils.GetItemBase(info.id)
  local name = item:FindDirect("Label_ItemName"):GetComponent("UILabel")
  name:set_text(itemBase.name)
  local uitexture = item:FindDirect("Icon_Item"):GetComponent("UITexture")
  GUIUtils.FillIcon(uitexture, itemBase.icon)
  local num = item:FindDirect("Label_Num"):GetComponent("UILabel")
  num:set_text(string.format("%d", info.num))
end
def.method().UpdateItemGrid = function(self)
  local itemGrid = self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Group_UseItem/Img_BgAdcance/Scroll View_Item/Grid_Items")
  for k, v in ipairs(self.AdvanceItemInfo) do
    local item = itemGrid:FindDirect(string.format("Img_BgItem_%d", k))
    local btn_reduce = item:FindDirect(string.format("Btn_Reduce_%d", k))
    if v.select > 0 then
      item:GetComponent("UIToggle"):set_value(true)
      btn_reduce:SetActive(true)
    else
      item:GetComponent("UIToggle"):set_value(false)
      btn_reduce:SetActive(false)
    end
    self:UpdateItem(item, v)
  end
  self:SetAdvanceExp()
end
def.method("userdata", "table").UpdateItem = function(self, item, info)
  local select = info.select > 0
  item:GetComponent("UIToggle"):set_value(select)
  local num = item:FindDirect("Label_Num"):GetComponent("UILabel")
  if select then
    num:set_text(string.format("%d/%d", info.select, info.num))
  else
    num:set_text(string.format("%d", info.num))
  end
end
def.method("number").ToggleFormationInfo = function(self, st)
  if st == 1 then
    self.m_panel:FindDirect("Img_BgDetail/Group_Advance"):SetActive(true)
    self.infoState = 1
    self:UpdateAdvanceInfo()
  elseif st == 0 then
    self.m_panel:FindDirect("Img_BgDetail/Group_Advance"):SetActive(false)
    self.infoState = 0
    self:UpdateFormationInfo()
  end
end
def.method("table", "=>", "table").GetIdSortList = function(self, map)
  local list = {}
  for k, v in pairs(map) do
    table.insert(list, v.id)
  end
  table.sort(list)
  return list
end
def.method().ShowKZTips = function(self)
  local DlgFormationRelation = require("Main.Formation.ui.DlgFormationRelation")
  local dlg = DlgFormationRelation()
  dlg:ShowTips(self.selectFormation)
end
def.method("string").onClick = function(self, id)
  print("onClick", id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Img_Book_") then
    local idStr = string.sub(id, 10)
    local id = tonumber(idStr)
    self:SelectFormation(id)
  elseif id == "Btn_Learn" then
    local itemId = FormationUtils.GetNeedBook(self.selectFormation)
    local hasbook = ItemModule.Instance():GetItemCountById(itemId) > 0
    if hasbook then
      FormationModule.Instance():LearnFormationById(self.selectFormation)
    else
      local itemBase = ItemUtils.GetItemBase(itemId)
      Toast(string.format(textRes.Formation[3], itemBase.name))
      local source = self.m_panel:FindDirect("Btn_Learn")
      local position = source:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local sprite = source:GetComponent("UISprite")
      ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
    end
  elseif id == "Btn_Switch" then
    local toggle = self.m_panel:FindDirect("Btn_Switch"):GetComponent("UIToggle")
    if toggle:get_value() then
      self:OpenFormation(self.selectFormation)
      local ECMSDK = require("ProxySDK.ECMSDK")
      ECMSDK.SendTLogToServer(_G.TLOGTYPE.FORMATION, {
        self.selectFormation
      })
    else
      self:OpenFormation(0)
    end
  elseif id == "Btn_Left" then
    self.showLevel = self.showLevel - 1
    self:SetFormationEffect(self.selectFormation, self.showLevel)
  elseif id == "Btn_Right" then
    self.showLevel = self.showLevel + 1
    self:SetFormationEffect(self.selectFormation, self.showLevel)
  elseif id == "Btn_Advance" then
    self:ToggleFormationInfo(1)
  elseif id == "Btn_Confirm" then
    local formationConst = FormationUtils.GetFormationConst()
    local level = FormationModule.Instance():GetFormationLevel(self.selectFormation)
    if level >= formationConst.maxLevel then
      Toast(textRes.Formation[21])
    else
      FormationModule.Instance():AdvanceFormation(self.AdvanceItemInfo, self.selectFormation)
    end
  elseif id == "Btn_Back" then
    self:ToggleFormationInfo(0)
  elseif string.find(id, "Img_BgItem_") then
    local formationConst = FormationUtils.GetFormationConst()
    local level = FormationModule.Instance():GetFormationLevel(self.selectFormation)
    if level >= formationConst.maxLevel then
      Toast(textRes.Formation[15])
    elseif self.canAddExp then
      local str = string.sub(id, 12)
      local index = tonumber(str)
      local itemInfo = self.AdvanceItemInfo[index]
      if itemInfo and 0 >= itemInfo.num then
        local itemGrid = self.m_panel:FindDirect("Img_BgDetail/Group_Advance/Group_UseItem/Img_BgAdcance/Scroll View_Item/Grid_Items")
        local source = itemGrid:FindDirect("Img_BgItem_" .. index)
        if source == nil then
          return
        end
        local position = source:get_position()
        local screenPos = WorldPosToScreen(position.x, position.y)
        local sprite = source:GetComponent("UISprite")
        ItemTipsMgr.Instance():ShowBasicTips(itemInfo.id, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
        return
      end
      self.AdvanceItemInfo[index].select = self.AdvanceItemInfo[index].select == self.AdvanceItemInfo[index].num and self.AdvanceItemInfo[index].num or self.AdvanceItemInfo[index].select + 1
      self:UpdateItemGrid()
    else
      Toast(textRes.Formation[7])
    end
  elseif string.find(id, "Btn_Reduce_") then
    local str = string.sub(id, 12)
    local index = tonumber(str)
    self.AdvanceItemInfo[index].select = self.AdvanceItemInfo[index].select == 0 and 0 or self.AdvanceItemInfo[index].select - 1
    self:UpdateItemGrid()
  elseif id == "Btn_Tips" then
    local tip = require("Main.Common.TipsHelper").GetHoverTip(FormationUtils.GetFormationConst().LevelUpTip)
    require("GUI.CommonUITipsDlg").ShowCommonTip(tip, {x = 0, y = 0})
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  elseif id == "Img_BgTop" then
  elseif id == "Modal" then
    self:DestroyPanel()
  end
end
def.method().SelectFirst = function(self)
  local learnFormations, unlearnFormations = FormationModule.Instance():GetSepFormationList()
  local list = self:GetIdSortList(learnFormations)
  if #list > 0 then
    self.selectFormation = list[1]
    return
  end
  list = self:GetIdSortList(unlearnFormations)
  if #list > 0 then
    self.selectFormation = list[1]
    return
  end
end
def.method("string").onDoubleClick = function(self, id)
  if string.find(id, "Img_BgItem_") then
    local formationConst = FormationUtils.GetFormationConst()
    local level = FormationModule.Instance():GetFormationLevel(self.selectFormation)
    if level >= formationConst.maxLevel then
    elseif self.canAddExp then
      do
        local str = string.sub(id, 12)
        local index = tonumber(str)
        local itemInfo = self.AdvanceItemInfo[index]
        if itemInfo.num <= 0 then
          return
        end
        local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
        local function callback(id)
          if id == 1 then
            local curNum = self.AdvanceItemInfo[index].select
            for i = curNum, itemInfo.num - 1 do
              if self.canAddExp then
                self.AdvanceItemInfo[index].select = self.AdvanceItemInfo[index].select + 1
                self:SetAdvanceExp()
              else
                break
              end
            end
            self:UpdateItemGrid()
          end
        end
        local itemBase = ItemUtils.GetItemBase(itemInfo.id)
        local strs = string.format(textRes.Formation[24], itemBase.name)
        CommonConfirmDlg.ShowConfirm("", strs, callback, {})
      end
    end
  else
  end
end
DlgFormation.Commit()
return DlgFormation

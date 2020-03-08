local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local EquipInheritNode = Lplus.Extend(TabNode, "EquipInheritNode")
local def = EquipInheritNode.define
local EquipStrenTransData = require("Main.Equip.EquipStrenTransData")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local EquipInfoShowDlg = require("Main.Equip.ui.EquipInfoShowDlg")
local EquipTransChooseDlg = require("Main.Equip.ui.EquipTransChooseDlg")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local EquipSocialPanel = Lplus.ForwardDeclare("EquipSocialPanel")
def.field("table")._equipInheritSelected = nil
def.field("table")._equipInheritConsume = nil
def.field("number")._equipInheritMainNum = 0
def.field("number")._equipInheritConsumeNum = 0
def.field("table").mPreMainItem = nil
def.field("table").mPreConsumeItem = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.static("number", "table").EquipBindCallback = function(i, tag)
  if 1 == i then
    local dlg = tag.id
    dlg:RealEquipPlay()
  elseif 0 == i then
    return
  end
end
def.method("table", "table").SetPreInhertInfo = function(self, conitem, mainitem)
  self.mPreMainItem = mainitem
  self.mPreConsumeItem = conitem
end
def.method().RealEquipPlay = function(self)
  if self.m_node:get_activeInHierarchy() then
    self:RealInheritEquip()
  end
end
def.method("table").FillSoleList = function(self, exproList)
  local compareGrid = self.m_node:FindDirect("Img_CC_BgCompare")
  local grid1 = compareGrid:FindDirect("Img_CC_Bg01")
  local uiList = grid1:FindDirect("Grid_CC_Attribute01"):GetComponent("UIList")
  uiList:set_itemCount(#exproList)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local solesUI = uiList:get_children()
  for i = 1, #solesUI do
    local soleUI = solesUI[i]
    local soleInfo = exproList[i]
    self:FillSoleInfo(soleInfo, i, soleUI)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("table", "number", "userdata").FillSoleInfo = function(self, exproInfo, index, soleNew)
  if not exproInfo.isEmpty then
    self:SetEmptyHunItemView(soleNew, index, false, true)
    local color = EquipUtils.GetProColorEx(exproInfo.itemId, exproInfo.pro, exproInfo.floatVal, exproInfo.proValue)
    local typeInfo = "[" .. color .. "]" .. exproInfo.name .. ": +" .. exproInfo.value
    soleNew:FindDirect(string.format("Label_CC_Attribute01_1_%d", index)):GetComponent("UILabel"):set_text(typeInfo)
    soleNew:FindDirect(string.format("Img_CC_%d/Img_CC_X_%d", index, index)):SetActive(false)
    soleNew:FindDirect(string.format("Img_CC_%d/Img_CC_Select_%d", index, index)):SetActive(false)
    soleNew:FindDirect(string.format("Img_CC_%d", index)):SetActive(true)
    local usefulSprite = soleNew:FindDirect(string.format("Img_CC_%d/Img_CC_Useful_%d", index, index))
    local isRecommend = exproInfo.isRecommend
    if isRecommend then
      usefulSprite:SetActive(true)
    else
      usefulSprite:SetActive(false)
    end
  else
    self:SetEmptyHunItemView(soleNew, index, true, true)
  end
end
def.method("userdata", "number", "boolean", "boolean").SetEmptyHunItemView = function(self, itemObj, index, isEmpty, isLeft)
  if itemObj and not itemObj.isnil then
    if isLeft then
      local attrLabel = itemObj:FindDirect(string.format("Label_CC_Attribute01_1_%d", index))
      local usefulSprite = itemObj:FindDirect(string.format("Img_CC_%d/Img_CC_Useful_%d", index, index))
      if isEmpty then
        attrLabel:GetComponent("UILabel"):set_text(textRes.Equip[116])
        usefulSprite:SetActive(false)
      end
    else
      local attrLabel = itemObj:FindDirect(string.format("Label_CC_AttributeRight01_%d", index))
      local usefulSprite = itemObj:FindDirect(string.format("Img_CC_%d/Img_CC_Useful_%d", index, index))
      if isEmpty then
        attrLabel:GetComponent("UILabel"):set_text(textRes.Equip[116])
        usefulSprite:SetActive(false)
      end
    end
  end
end
def.method("table").FillChooseList = function(self, exproList)
  local compareGrid = self.m_node:FindDirect("Img_CC_BgCompare")
  local grid2 = compareGrid:FindDirect("Img_CC_Bg02")
  local groupGrid = grid2:FindDirect("Group_CC_Equip02")
  local uiList = groupGrid:FindDirect("Grid_CC_AttributeRight"):GetComponent("UIList")
  uiList:set_itemCount(#exproList)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local solesUI = uiList:get_children()
  for i = 1, #solesUI do
    local soleUI = solesUI[i]
    local soleInfo = exproList[i]
    self:FillChooseInfo(soleInfo, i, soleUI)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("table", "number", "userdata").FillChooseInfo = function(self, exproInfo, index, soleNew)
  self:SetEmptyHunItemView(soleNew, index, exproInfo.isEmpty, false)
  if exproInfo.isEmpty then
    return
  end
  local color = EquipUtils.GetProColorEx(exproInfo.itemId, exproInfo.pro, exproInfo.floatVal, exproInfo.proValue)
  local typeInfo = "[" .. color .. "]" .. exproInfo.name .. ": +" .. exproInfo.value
  soleNew:FindDirect(string.format("Label_CC_AttributeRight01_%d", index)):GetComponent("UILabel"):set_text(typeInfo)
  soleNew:FindDirect(string.format("Img_CC_%d", index)):SetActive(true)
  local usefunSprite = soleNew:FindDirect(string.format("Img_CC_%d/Img_CC_Useful_%d", index, index))
  local isRecommend = exproInfo.isRecommend
  if isRecommend then
    usefunSprite:SetActive(true)
  else
    usefunSprite:SetActive(false)
  end
end
def.method("number").OnEquipListClick = function(self, index)
  self:FillEquipInheritFrame(index)
end
def.method("number", "userdata").ClearTransSoles = function(self, num, gridTemplate)
  if 0 == num then
    return
  end
  gridTemplate:GetChild(0):SetActive(false)
  for i = 2, num do
    local template = gridTemplate:GetChild(i - 1)
    Object.Destroy(template)
  end
end
def.method("=>", "number").GetEquipInheritSelectedKey = function(self)
  return self._equipInheritSelected.key
end
def.method("number").FillEquipInheritFrame = function(self, index)
  local compareGrid = self.m_node:FindDirect("Img_CC_BgCompare")
  local grid1 = compareGrid:FindDirect("Img_CC_Bg01")
  local grid2 = compareGrid:FindDirect("Img_CC_Bg02")
  local emptyGroup = grid2:FindDirect("Group_CC_Equip02Empty")
  emptyGroup:SetActive(true)
  local equipGroup = grid2:FindDirect("Group_CC_Equip02")
  equipGroup:SetActive(false)
  emptyGroup:FindDirect("Label_CC_Tips"):SetActive(true)
  emptyGroup:FindDirect("Label_CC_Tips"):GetComponent("UILabel"):set_text(textRes.Equip[38])
  local equipGrid = self.m_node:FindDirect("Img_CC_BgEquipMake")
  local equipStrenTransList = EquipStrenTransData.Instance():GetInheritEquips()
  local equip = equipStrenTransList[index]
  self._equipInheritSelected = equip
  self._equipInheritConsume = nil
  self._equipInheritConsumeNum = 0
  if equip == nil then
    return
  end
  local _, inheritNeedSilver = EquipUtils.GetEquipTransNeedItemInfo(self._equipInheritSelected.useLevel)
  self._equipInheritSelected.needCooperNum = inheritNeedSilver
  equipGrid:FindDirect("Img_CC_BgUseMoney/Label_CC_UseMoneyNum"):GetComponent("UILabel"):set_text(inheritNeedSilver)
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(inheritNeedSilver) == true then
    equipGrid:FindDirect("Img_CC_BgUseMoney/Label_CC_UseMoneyNum"):GetComponent("UILabel"):set_textColor(Color.red)
  end
  self:UpdateInheritSilverNum()
  local equip1 = grid1:FindDirect("Img_CC_BgEquip01")
  local equipIcon = equip1:FindDirect("Icon_CC_Equip01")
  equipIcon:SetActive(true)
  local equipIconTex = equipIcon:GetComponent("UITexture")
  GUIUtils.FillIcon(equipIconTex, self._equipInheritSelected.iconId)
  local bgSprite = equip1:FindDirect("Icon_CC_BgEquip01"):GetComponent("UISprite")
  GUIUtils.SetSprite(bgSprite, ItemUtils.GetItemFrame(self._equipInheritSelected, nil))
  GUIUtils.SetText(equip1:FindDirect("Label_CC_EquipName01"), ItemUtils.GetItemName(self._equipInheritSelected, nil))
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipInheritSelected.bagId, self._equipInheritSelected.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  equip1:FindDirect("Label_PinFen"):GetComponent("UILabel"):set_text(string.format(textRes.Equip[41], score))
  local tbl = {}
  for k, v in pairs(equipItem.exproList) do
    if 0 == v.proType or 0 == v.proValue then
      table.insert(tbl, {
        itemId = equipItem.id,
        isEmpty = true
      })
    else
      local str = EquipModule.GetProRandomName(v.proType)
      local pro = EquipModule.GetProTypeID(v.proType)
      local val, realVal, floatValue = EquipModule.GetProRealValue(v.proType, v.proValue)
      local isRecommend = EquipUtils.IsRecommendProType(v.proType, self._equipInheritSelected.id)
      table.insert(tbl, {
        itemId = equipItem.id,
        isEmpty = false,
        name = str,
        value = val,
        pro = pro,
        realVal = realVal,
        floatVal = floatValue,
        proValue = v.proValue,
        islock = v.islock,
        isRecommend = isRecommend
      })
    end
  end
  self._equipInheritMainNum = #tbl
  self:FillSoleList(tbl)
end
def.method("string").UpdateStrenLevelAfterInherit = function(self, strenLevel)
  local strStrenLev = "+" .. strenLevel
  local compareGrid = self.m_node:FindDirect("Img_CC_BgCompare")
  local grid1 = compareGrid:FindDirect("Img_CC_Bg01")
  local equip1 = grid1:FindDirect("Img_CC_BgEquip01")
  equip1:FindDirect("Label_CC_LingNum01"):GetComponent("UILabel"):set_text(strStrenLev)
end
def.method().UpdateInheritSilverNum = function(self)
  local equipGrid = self.m_node:FindDirect("Img_CC_BgEquipMake")
  local haveSilverLabel = equipGrid:FindDirect("Img_CC_BgHaveMoney/Label_CC_HaveMoneyNum"):GetComponent("UILabel")
  local needSilverLabel = equipGrid:FindDirect("Img_CC_BgUseMoney/Label_CC_UseMoneyNum"):GetComponent("UILabel")
  local _, needSillver = EquipUtils.GetEquipTransNeedItemInfo(self._equipInheritSelected.useLevel)
  local haveSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  if haveSilver:lt(needSillver) then
    needSilverLabel:set_textColor(Color.red)
  else
    needSilverLabel:set_textColor(Color.Color(0.30980392156862746, 0.18823529411764706, 0.09411764705882353, 1))
  end
  haveSilverLabel:set_text(Int64.tostring(haveSilver))
  needSilverLabel:set_text(needSillver)
end
def.method().UpdateBtnState = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local CC_Btn = self.m_node:FindDirect("Img_CC_BgEquipMake/Btn_CC_Make")
  GameUtil.AddGlobalLateTimer(1, true, function()
    if self.m_panel ~= nil and false == self.m_panel.isnil then
      CC_Btn:GetComponent("UIButton"):set_isEnabled(true)
    end
  end)
end
def.method("table").UpdateEquipInheritInfo = function(self, newExproList)
  warn("UpdateEquipInheritInfo~~~ ", newExproList)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local compareGrid = self.m_node:FindDirect("Img_CC_BgCompare")
  local grid2 = compareGrid:FindDirect("Img_CC_Bg02")
  local groupGrid = grid2:FindDirect("Group_CC_Equip02")
  local equip2 = groupGrid:FindDirect("Img_CC_BgEquip02")
  local scoreObj2 = groupGrid:FindDirect("Sprite")
  require("Fx.GUIFxMan").Instance():PlayAsChild(scoreObj2, RESPATH.EQUIP_INHERIT_HIDE_EFFECT, 0, 0, -1, false)
  local gridTemplate2 = groupGrid:FindDirect("Grid_CC_AttributeRight")
  local equipGrid = self.m_node:FindDirect("Img_CC_BgEquipMake")
  local consumeIndex = math.ceil(self._equipInheritConsumeNum / 2)
  local soleConsumeObj = gridTemplate2:FindDirect(string.format("Group_CC_AttributeRight01_%d", consumeIndex))
  require("Fx.GUIFxMan").Instance():PlayAsChild(soleConsumeObj, RESPATH.EQUIP_INHERIT_HIDE_EFFECT, 0, 0, -1, false)
  self:UpdateBtnState()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  if PlayerIsInFight() and self._equipInheritSelected.bagId == BagInfo.EQUIPBAG then
    Toast(textRes.Equip[100])
  end
  self._equipInheritConsume = nil
  self._equipInheritConsumeNum = 0
  GameUtil.AddGlobalTimer(0.9, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    local grid1 = compareGrid:FindDirect("Img_CC_Bg01")
    local equip1 = grid1:FindDirect("Img_CC_BgEquip01")
    local scoreObj1 = grid1:FindDirect("Sprite")
    require("Fx.GUIFxMan").Instance():PlayAsChild(scoreObj1, RESPATH.EQUIP_INHERIT_SHOW_EFFECT, 0, 0, -1, false)
    local attributeGrid = grid1:FindDirect("Grid_CC_Attribute01")
    local mainIndex = math.ceil(self._equipInheritMainNum / 2)
    local soleMainObj = attributeGrid:FindDirect(string.format("Group_CC_Attribute01_%d", mainIndex))
    require("Fx.GUIFxMan").Instance():PlayAsChild(soleMainObj, RESPATH.EQUIP_INHERIT_SHOW_EFFECT, 0, 0, -1, false)
    grid2:FindDirect("Group_CC_Equip02Empty"):SetActive(true)
    grid2:FindDirect("Group_CC_Equip02"):SetActive(false)
    self._equipInheritConsume = nil
    self._equipInheritConsumeNum = 0
    GameUtil.AddGlobalTimer(0.65, true, function()
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      for k, v in pairs(newExproList) do
        local attribute = attributeGrid:FindDirect(string.format("Group_CC_Attribute01_%d", k))
        if 0 == v.proType or 0 == v.proValue then
          self:SetEmptyHunItemView(attribute, k, true, true)
        else
          self:SetEmptyHunItemView(attribute, k, false, true)
          local str = EquipModule.GetProRandomName(v.proType)
          local val, realVal, floatValue = EquipModule.GetProRealValue(v.proType, v.proValue)
          local pro = EquipModule.GetProTypeID(v.proType)
          local color = EquipUtils.GetProColorEx(self._equipInheritSelected.id, pro, floatValue, v.proValue)
          local info = "[" .. color .. "]" .. str .. ":+" .. val
          local isRecommend = EquipUtils.IsRecommendProType(v.proType, self._equipInheritSelected.id)
          attribute:FindDirect(string.format("Label_CC_Attribute01_1_%d", k)):GetComponent("UILabel"):set_text(info)
          attribute:FindDirect(string.format("Img_CC_%d", k)):SetActive(true)
          local usefulSprite = attribute:FindDirect(string.format("Img_CC_%d/Img_CC_Useful_%d", k, k)):SetActive(isRecommend)
        end
      end
    end)
  end)
end
def.method("table", "number", "number").RefeshEquipInheritInfo = function(self, newExproList, level, bSelect)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local compareGrid = self.m_node:FindDirect("Img_CC_BgCompare")
  local grid2 = compareGrid:FindDirect("Img_CC_Bg02")
  local groupGrid = grid2:FindDirect("Group_CC_Equip02")
  local equip2 = groupGrid:FindDirect("Img_CC_BgEquip02")
  local scoreObj2 = groupGrid:FindDirect("Sprite")
  require("Fx.GUIFxMan").Instance():PlayAsChild(scoreObj2, RESPATH.EQUIP_INHERIT_HIDE_EFFECT, 0, 0, -1, false)
  local gridTemplate2 = groupGrid:FindDirect("Grid_CC_AttributeRight")
  local equipGrid = self.m_node:FindDirect("Img_CC_BgEquipMake")
  if bSelect == 1 then
    local consumeIndex = math.ceil(self._equipInheritConsumeNum / 2)
    local soleConsumeObj = gridTemplate2:FindDirect(string.format("Group_CC_AttributeRight_%d", consumeIndex))
    require("Fx.GUIFxMan").Instance():PlayAsChild(soleConsumeObj, RESPATH.EQUIP_INHERIT_HIDE_EFFECT, 0, 0, -1, false)
  end
  self:UpdateBtnState()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  if PlayerIsInFight() and self._equipInheritSelected.bagId == BagInfo.EQUIPBAG then
    Toast(textRes.Equip[94])
  end
  GameUtil.AddGlobalTimer(0.9, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    local grid1 = compareGrid:FindDirect("Img_CC_Bg01")
    local equip1 = grid1:FindDirect("Img_CC_BgEquip01")
    local scoreObj1 = grid1:FindDirect("Sprite")
    require("Fx.GUIFxMan").Instance():PlayAsChild(scoreObj1, RESPATH.EQUIP_INHERIT_SHOW_EFFECT, 0, 0, -1, false)
    local attributeGrid = grid1:FindDirect("Grid_CC_Attribute01")
    if bSelect == 1 then
      local mainIndex = math.ceil(self._equipInheritMainNum / 2)
      local soleMainObj = attributeGrid:FindDirect(string.format("Group_CC_Attribute01_%d", mainIndex))
      require("Fx.GUIFxMan").Instance():PlayAsChild(soleMainObj, RESPATH.EQUIP_INHERIT_SHOW_EFFECT, 0, 0, -1, false)
    end
    grid2:FindDirect("Group_CC_Equip02Empty"):SetActive(true)
    grid2:FindDirect("Group_CC_Equip02"):SetActive(false)
    self._equipInheritConsume = nil
    self._equipInheritConsumeNum = 0
    GameUtil.AddGlobalTimer(0.65, true, function()
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      for k, v in pairs(newExproList) do
        local str = EquipModule.GetProRandomName(v.proType)
        local val, realVal, floatValue = EquipModule.GetProRealValue(v.proType, v.proValue)
        local pro = EquipModule.GetProTypeID(v.proType)
        local color = EquipUtils.GetProColorEx(self._equipInheritSelected.id, pro, floatValue, v.proValue)
        local info = "[" .. color .. "]" .. str .. ":+" .. val
        local attribute = attributeGrid:FindDirect(string.format("Group_CC_Attribute01_%d", k))
        attribute:FindDirect(string.format("Label_CC_Attribute01_1_%d", k)):GetComponent("UILabel"):set_text(info)
        attribute:FindDirect(string.format("Img_CC_%d", k)):SetActive(false)
      end
    end)
  end)
end
def.method().OnInheritAddClick = function(self)
  if nil ~= self._equipInheritSelected then
    if self._equipInheritSelected.exproList == nil or #self._equipInheritSelected.exproList < 1 then
      Toast(textRes.Equip[99])
      return
    end
    local costEquips = EquipTransChooseDlg.IfHaveCostEquips(false, self._equipInheritSelected)
    if #costEquips > 0 then
      local tag = {id = self}
      EquipTransChooseDlg.ShowEquipChoose(self._equipInheritSelected, EquipInheritNode.AddInheritChooseCallback, tag, false)
    else
      Toast(textRes.Equip[26])
    end
  end
end
def.static("table", "table").AddInheritChooseCallback = function(tag, equipChoose)
  local dlg = tag.id
  local compareGrid = dlg.m_node:FindDirect("Img_CC_BgCompare")
  local grid2 = compareGrid:FindDirect("Img_CC_Bg02")
  grid2:FindDirect("Group_CC_Equip02Empty"):SetActive(false)
  grid2:FindDirect("Group_CC_Equip02"):SetActive(true)
  dlg:FillInheritChooseEquip(equipChoose)
end
def.method("table").FillInheritChooseEquip = function(self, equip)
  if nil == equip then
    return
  end
  self._equipInheritConsume = equip
  local compareGrid = self.m_node:FindDirect("Img_CC_BgCompare")
  local equipGrid = self.m_node:FindDirect("Img_CC_BgEquipMake")
  local grid2 = compareGrid:FindDirect("Img_CC_Bg02")
  local groupGrid = grid2:FindDirect("Group_CC_Equip02")
  local equip2 = groupGrid:FindDirect("Img_CC_BgEquip02")
  local equipIcon = equip2:FindDirect("Icon_CC_Equip02")
  equipIcon:SetActive(true)
  local euqipIconTex = equipIcon:GetComponent("UITexture")
  GUIUtils.FillIcon(euqipIconTex, equip.iconId)
  local bgSprite = equip2:FindDirect("Icon_CC_BgEquip02"):GetComponent("UISprite")
  bgSprite:set_spriteName(ItemUtils.GetItemFrame(self._equipInheritConsume, nil))
  equip2:FindDirect("Label_CC_EquipName02"):GetComponent("UILabel"):set_text(ItemUtils.GetItemName(self._equipInheritConsume, nil))
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(equip.bagId, equip.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  equip2:FindDirect("Label_PinFenNum"):GetComponent("UILabel"):set_text(string.format(textRes.Equip[41], score))
  local tbl = {}
  for k, v in pairs(equip.exproList) do
    if 0 == v.proType or 0 == v.proValue then
      table.insert(tbl, {
        itemId = equipItem.id,
        isEmpty = true
      })
    else
      local str = EquipModule.GetProRandomName(v.proType)
      local pro = EquipModule.GetProTypeID(v.proType)
      local val, realVal, floatValue = EquipModule.GetProRealValue(v.proType, v.proValue)
      local isRecommend = EquipUtils.IsRecommendProType(v.proType, equipItem.id)
      table.insert(tbl, {
        itemId = equipItem.id,
        isEmpty = false,
        name = str,
        value = val,
        pro = pro,
        realVal = realVal,
        floatVal = floatValue,
        proValue = v.proValue,
        islock = v.islock,
        isRecommend = isRecommend
      })
    end
  end
  self._equipInheritConsumeNum = #tbl
  self:FillChooseList(tbl)
end
def.method().OnEquipInheritClick = function(self)
  if self._equipInheritConsume == nil then
    Toast(textRes.Equip[31])
    return
  end
  if self._equipInheritConsume.exproList == nil or #self._equipInheritConsume.exproList < 1 then
    Toast(textRes.Equip[105])
    return
  end
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(self._equipInheritSelected.needCooperNum) == true then
    GoToBuySilver(false)
    return
  end
  self:RealInheritEquip()
end
def.method().RealInheritEquip = function(self)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local consumeEquip = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipInheritConsume.bagId, self._equipInheritConsume.key)
  local consumeStrenLevel = consumeEquip.extraMap[ItemXStoreType.STRENGTH_LEVEL]
  if consumeStrenLevel ~= nil and consumeStrenLevel > 0 then
    local function callback(id, tag)
      if id == 1 then
        self:RealtoFuHun()
      end
    end
    CommonConfirmDlg.ShowConfirm("", textRes.Equip[102], callback, nil)
  else
    self:RealtoFuHun()
  end
end
def.method().RealtoFuHun = function(self)
  local function callback(select, tag)
    if 1 == select then
      self:SendFuHunProtocol()
    end
  end
  CommonConfirmDlg.ShowConfirm("", textRes.Equip[119], callback, nil)
end
def.method().SendFuHunProtocol = function(self)
  if self.m_node and false == self.m_node.isnil and self.m_node:get_activeInHierarchy() then
    local CC_Btn = self.m_node:FindDirect("Img_CC_BgEquipMake/Btn_CC_Make")
    CC_Btn:GetComponent("UIButton"):set_isEnabled(false)
    EquipSocialPanel.Instance():DelayCheckBtnEnableState(CC_Btn)
    local CProtocol = require("netio.protocol.mzm.gsp.item.CEquipTransferHun")
    local mainEquipkey = self._equipInheritSelected.key
    local mainEquipBagId = self._equipInheritSelected.bagId
    local consumeEquipKey = self._equipInheritConsume.key
    local p = CProtocol.new(consumeEquipKey, mainEquipBagId, mainEquipkey)
    gmodule.network.sendProtocol(p)
  end
end
def.method().OnEquipInheritPreview = function(self)
  local equipGrid = self.m_node:FindDirect("Img_CC_BgEquipMake")
  local strenNameContent, strenValContent, transNameContent, transValContent, randomContent, strenNum = EquipUtils.GetEquipInheritPreviewContent(self._equipInheritSelected, self._equipInheritConsume, equipGrid:FindDirect("Btn_CC_Use"):GetComponent("UIToggle"):get_isChecked())
  local title = textRes.Equip[17] .. textRes.Equip[19]
  local tag = {
    id = self._equipInheritSelected.id,
    key = self._equipInheritSelected.key
  }
  local position = {auto = false}
  EquipInfoShowDlg.ShowEquipInfo(title, self._equipInheritSelected, tag, strenNameContent, strenValContent, transNameContent, transValContent, position, randomContent, strenNum)
end
def.override().OnShow = function(self)
  if self.mPreConsumeItem == nil or self.mPreMainItem == nil then
    self:OnEquipListClick(1)
    EquipSocialPanel.Instance():SelectFromEquipStrenTrans(1)
  else
    do
      local equipStrenTransList = EquipStrenTransData.Instance():GetInheritEquips()
      local selectIndex = -1
      local selectIndex2 = -1
      for k, v in pairs(equipStrenTransList) do
        if v.uuid:eq(self.mPreMainItem.uuid[1]) then
          selectIndex = k
        end
        if v.uuid:eq(self.mPreConsumeItem.uuid[1]) then
          selectIndex2 = k
        end
      end
      if selectIndex == -1 or selectIndex2 == -1 then
        self:OnEquipListClick(1)
        EquipSocialPanel.Instance():SelectFromEquipStrenTrans(1)
        return
      end
      self:OnEquipListClick(selectIndex)
      EquipSocialPanel.Instance():SelectFromEquipStrenTrans(selectIndex)
      local choosEquip = equipStrenTransList[selectIndex2]
      local compareGrid = self.m_node:FindDirect("Img_CC_BgCompare")
      local grid2 = compareGrid:FindDirect("Img_CC_Bg02")
      grid2:FindDirect("Group_CC_Equip02Empty"):SetActive(false)
      grid2:FindDirect("Group_CC_Equip02"):SetActive(true)
      self:FillInheritChooseEquip(choosEquip)
      self.mPreMainItem = nil
      self.mPreConsumeItem = nil
      warn("OnShow~~~~", equipStrenTransList[selectIndex].name, equipStrenTransList[selectIndex2].name)
      local gridTemplate = self.m_panel:FindDirect("Img_BgEquip/EquipList/Scroll View_EquipList/Grid_EquipList")
      local str = string.format("Img_BgEquip01_%d", selectIndex)
      local list = gridTemplate:GetComponent("UIList"):get_children()
      local eqpUI
      for i = 1, #list do
        eqpUI = list[i]
        if eqpUI.name == str then
          eqpUI:GetComponent("UIToggle"):set_isChecked(true)
        else
          eqpUI:GetComponent("UIToggle"):set_isChecked(false)
        end
      end
      if selectIndex > 4 then
        GameUtil.AddGlobalTimer(0.1, true, function()
          if self.m_panel and false == self.m_panel.isnil then
            local uiScrollView = self.m_panel:FindDirect("Img_BgEquip/EquipList/Scroll View_EquipList"):GetComponent("UIScrollView")
            uiScrollView:DragToMakeVisible(eqpUI.transform, 8)
          end
        end)
      end
    end
  end
end
def.override().OnHide = function(self)
end
def.method().UpdateSoles = function(self)
  local equipGrid = self.m_node:FindDirect("Img_CC_BgEquipMake")
  local compareGrid = self.m_node:FindDirect("Img_CC_BgCompare")
  local grid1 = compareGrid:FindDirect("Img_CC_Bg01")
  local grid2 = compareGrid:FindDirect("Img_CC_Bg02")
  local gridTemplate1 = grid1:FindDirect("Grid_CC_Attribute01"):GetComponent("UIList"):get_children()
  local groupGrid = grid2:FindDirect("Group_CC_Equip02")
  local gridTemplate2 = groupGrid:FindDirect("Grid_CC_AttributeRight"):GetComponent("UIList"):get_children()
  local exproList = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipInheritSelected.bagId, self._equipInheritSelected.key).exproList
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_CC_Add" then
    GoToBuySilver(false)
  elseif id == "Btn_CC_BgAdd" then
    self:OnInheritAddClick()
  elseif id == "Btn_CC_Tips" then
    EquipUtils.ShowInheritInfoDlg()
  elseif id == "Btn_CC_Make" then
    self:OnEquipInheritClick()
  elseif id == "Icon_CC_Equip02" then
    self:OnInheritAddClick()
  end
end
def.method().OnRefreshView = function(self)
end
EquipInheritNode.Commit()
return EquipInheritNode

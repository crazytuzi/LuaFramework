local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local EquipMakeNode = Lplus.Extend(TabNode, "EquipMakeNode")
local def = EquipMakeNode.define
local EquipMakeData = require("Main.Equip.EquipMakeData")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local EquipInfoShowDlg = require("Main.Equip.ui.EquipInfoShowDlg")
local GUIUtils = require("GUI.GUIUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.field("number")._curEquipLevelKey = 1
def.field("number")._curEquipLevel = 0
def.field("table")._equipsForMake = nil
def.field("table")._equipLevelsForMake = nil
def.field("table")._equipMakeSelected = nil
def.field("boolean")._bMakeByGold = false
def.field("boolean")._isFirstMakeByGold = true
def.field("number")._goldNum = 0
def.field("boolean")._bWaitgoldNum = false
def.field("table")._itemToNumTbl = nil
def.const("number")._equipMakeItemNum = 3
def.const("number")._equipMakePagePerNum = 6
def.field("table")._needItemTbl = nil
def.field("number").successKey = 0
def.field("table").successItemInfo = nil
def.field("table").selectMakeEquipInfo = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self._equipsForMake = {}
  self._equipLevelsForMake = {}
  self._equipMakeSelected = {}
  self._needItemTbl = {}
  self:PrepareMakeEquips()
  self._isFirstMakeByGold = true
end
def.method().ShowMainEquipDlg = function(self)
  self:FillEquipMakeList(false)
  self:FillEquipMakeFrame(1)
  self:UpdateListBtn()
end
def.method("number", "number").SetEquipMakeInfo = function(self, type, level)
  self.selectMakeEquipInfo = {}
  self.selectMakeEquipInfo.type = type
  self.selectMakeEquipInfo.level = level
end
def.method("number", "number").SetMakeEquip = function(self, wearpos, level)
  self._curEquipLevel = level
  for k, v in pairs(self._equipLevelsForMake) do
    if v == level then
      self._curEquipLevelKey = k
    end
  end
  local levelEquips = self._equipsForMake[self._curEquipLevel]
  local selectIndex = 1
  if levelEquips then
    for k, v in pairs(levelEquips) do
      if v.equipInfo.wearpos == wearpos then
        selectIndex = k
      end
    end
  end
  self:FillEquipMakeList(false)
  self:FillEquipMakeFrame(selectIndex)
  self:UpdateListBtn()
  if selectIndex > 4 then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if self.m_panel and false == self.m_panel.isnil then
        local grid = self.m_node:FindDirect("Img_DZ_BgEquipList/Grid_DZ_EquipList")
        local group = grid:FindDirect(string.format("Img_DZ_BgEquip0%d", selectIndex))
        local uiScrollView = grid:GetComponent("UIScrollView")
        uiScrollView:DragToMakeVisible(group.transform, 8)
      end
    end)
  end
end
def.method("table", "number").FillMatchEquips = function(self, levels_equips, roleLevel)
  for i in pairs(levels_equips) do
    local equips = levels_equips[i]
    for j in pairs(equips) do
      local equip = equips[j]
      local levelIncrease = EquipUtils.GetEquipMakeDelta()
      local equipLevel = equip.equipInfo.useLevel
      if equipLevel <= roleLevel + levelIncrease then
        if nil == self._equipsForMake[equipLevel] then
          self._equipsForMake[equipLevel] = {}
          table.insert(self._equipLevelsForMake, equipLevel)
        end
        self._equipsForMake[equipLevel][#self._equipsForMake[equipLevel] + 1] = equip
      end
    end
  end
end
def.method().PrepareMakeEquips = function(self)
  self._equipsForMake = {}
  self._equipLevelsForMake = {}
  local prop = require("Main.Hero.Interface").GetHeroProp()
  local menpai = prop.occupation
  local level = prop.level
  local sex = prop.gender
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local menpai_sexKey = menpai .. "_" .. sex
  local no_sexKey = occupation.ALL .. "_" .. sex
  local menpai_noKey = menpai .. "_" .. gender.ALL
  local no_noKey = occupation.ALL .. "_" .. gender.ALL
  local menpai_sexEquips = EquipMakeData.Instance():GetMakeEquips(menpai_sexKey)
  local no_sexEquips = EquipMakeData.Instance():GetMakeEquips(no_sexKey)
  local menpai_noEquips = EquipMakeData.Instance():GetMakeEquips(menpai_noKey)
  local no_noEquips = EquipMakeData.Instance():GetMakeEquips(no_noKey)
  if nil ~= menpai_sexEquips then
    self:FillMatchEquips(menpai_sexEquips, level)
  end
  if nil ~= no_sexEquips then
    self:FillMatchEquips(no_sexEquips, level)
  end
  if nil ~= menpai_noEquips then
    self:FillMatchEquips(menpai_noEquips, level)
  end
  if nil ~= no_noEquips then
    self:FillMatchEquips(no_noEquips, level)
  end
  table.sort(self._equipLevelsForMake)
  for idx, lev in pairs(self._equipLevelsForMake) do
    table.sort(self._equipsForMake[lev], function(a, b)
      local equipInfo1 = EquipUtils.GetEquipBasicInfo(a.eqpId)
      local equipInfo2 = EquipUtils.GetEquipBasicInfo(b.eqpId)
      return equipInfo1.wearpos < equipInfo2.wearpos
    end)
  end
  local maxMakeEquipLevel = self._equipLevelsForMake[#self._equipLevelsForMake] or 0
  if level >= maxMakeEquipLevel then
    self._curEquipLevelKey = #self._equipLevelsForMake
  else
    for idx, lev in pairs(self._equipLevelsForMake) do
      if level < lev then
        self._curEquipLevelKey = idx
        break
      end
    end
    if 0 < self._curEquipLevelKey - 1 then
      self._curEquipLevelKey = self._curEquipLevelKey - 1
    end
  end
  if nil ~= self._equipLevelsForMake[self._curEquipLevelKey] then
    self._curEquipLevel = self._equipLevelsForMake[self._curEquipLevelKey]
  end
end
def.method("number").FillEquipMakeFrame = function(self, index)
  if nil == self._equipsForMake or nil == self._equipsForMake[self._curEquipLevel] or index > #self._equipsForMake[self._curEquipLevel] then
    return
  end
  self._bWaitgoldNum = false
  self._goldNum = 0
  self._bMakeByGold = false
  self._needItemTbl = {}
  local replaceObj = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Replace"):GetComponent("UIToggle")
  if replaceObj:get_isChecked() then
    replaceObj:set_isChecked(false)
  end
  local equip = self._equipsForMake[self._curEquipLevel][index]
  self._equipMakeSelected = equip
  local grid = self.m_node:FindDirect("Img_DZ_BgEquipList/Grid_DZ_EquipList")
  grid:FindDirect(string.format("Img_DZ_BgEquip0%d", index)):GetComponent("UIToggle"):set_isChecked(true)
  self.m_node:FindDirect("Img_DZ_BgPreview/Label_DZ_EquipPreviewName01"):GetComponent("UILabel"):set_text(equip.equipInfo.name)
  local strLv = equip.equipInfo.useLevel .. textRes.Equip[30]
  self.m_node:FindDirect("Img_DZ_BgPreview/Label_DZ_EquipPreviewLv01"):GetComponent("UILabel"):set_text(strLv)
  self.m_node:FindDirect("Img_DZ_BgPreview/Label_DZ_EquipPreviewType03"):GetComponent("UILabel"):set_text(equip.equipInfo.typeName)
  local equipIcon = self.m_node:FindDirect("Img_DZ_BgPreview/Img_DZ_BgEquipPreview/Icon_DZ_BgEquipPreview")
  self.m_node:FindDirect("Img_DZ_BgPreview/Img_DZ_BgEquipPreview/Ing_DZ_EquipPreviewS"):SetActive(true)
  self.successKey = 0
  self.successItemInfo = nil
  local equipIconTex = equipIcon:GetComponent("UITexture")
  GUIUtils.FillIcon(equipIconTex, equip.equipInfo.iconId)
  self.m_node:FindDirect("Img_DZ_BgPreview/Label_DZ_AttributeName01"):GetComponent("UILabel"):set_text(EquipModule.GetAttriName(equip.equipInfo.attrA))
  self.m_node:FindDirect("Img_DZ_BgPreview/Label_DZ_AttributeName02"):GetComponent("UILabel"):set_text(EquipModule.GetAttriName(equip.equipInfo.attrB))
  local attrARange = "+" .. equip.equipInfo.attrAvaluemin .. "~" .. equip.equipInfo.attrAvaluemax
  local attrBRange = "+" .. equip.equipInfo.attrBvaluemin .. "~" .. equip.equipInfo.attrBvaluemax
  self.m_node:FindDirect("Img_DZ_BgPreview/Label_DZ_AttributeName01/Label_DZ_AttributeNum01"):GetComponent("UILabel"):set_text(attrARange)
  self.m_node:FindDirect("Img_DZ_BgPreview/Label_DZ_AttributeName02/Label_DZ_AttributeNum02"):GetComponent("UILabel"):set_text(attrBRange)
  equip = EquipUtils.FillSelectedEquipMakeInfo(equip)
  local itemGrid = self.m_node:FindDirect("Img_DZ_BgMake")
  for i = 0, EquipMakeNode._equipMakeItemNum - 1 do
    local itemInfo = equip.makeNeedItem[i]
    if nil == itemInfo then
      break
    end
    local have = ItemModule.Instance():GetItemCountById(itemInfo.itemId)
    local item = itemInfo
    local textColor = Color.green
    if have < item.itemNum then
      local higherItemId = self:GetHigherLevelItem(itemInfo.itemId)
      if 0 ~= higherItemId then
        have = ItemModule.Instance():GetItemCountById(higherItemId)
        item.itemId = higherItemId
        item.icon, item.name = EquipUtils.GetItemInfo(higherItemId)
        local haveHigher = ItemModule.Instance():GetItemCountById(higherItemId)
        if haveHigher < item.itemNum then
          table.insert(self._needItemTbl, {
            id = item.itemId,
            num = item.itemNum - have
          })
          textColor = Color.red
          self._bMakeByGold = true
        end
      else
        table.insert(self._needItemTbl, {
          id = item.itemId,
          num = item.itemNum - have
        })
        textColor = Color.red
        self._bMakeByGold = true
      end
    end
    local curItem = itemGrid:FindDirect(string.format("Img_DZ_BgEquipMakeItem0%d", i + 1))
    local itemIcon = curItem:FindDirect(string.format("Icon_DZ_EquipMakeItem0%d", i + 1))
    local itemIdLabel = curItem:FindDirect(string.format("Lable_DZ_Key%d", i + 1))
    itemIdLabel:GetComponent("UILabel"):set_text(item.itemId)
    itemIcon:SetActive(true)
    local itemIconTex = itemIcon:GetComponent("UITexture")
    GUIUtils.FillIcon(itemIconTex, item.icon)
    local matCfg = EquipUtils.GetEquipMakeMaterialInfo(item.itemId)
    itemGrid:FindDirect(string.format("Label_DZ_EquipMakeName0%d", i + 1)):GetComponent("UILabel"):set_text(matCfg.equipmakeshowname)
    itemGrid:FindDirect(string.format("Label_DZ_EquipMakeName%d%d", i + 1, i + 1)):GetComponent("UILabel"):set_text(string.format(textRes.Equip[301], matCfg.materialLevel))
    local needAndHave = have .. "/" .. item.itemNum
    curItem:FindDirect(string.format("Label_DZ_EquipMakeItem0%d", i + 1)):GetComponent("UILabel"):set_text(needAndHave)
    curItem:FindDirect(string.format("Label_DZ_EquipMakeItem0%d", i + 1)):GetComponent("UILabel"):set_textColor(textColor)
  end
  itemGrid:FindDirect("Img_DZ_BgUseMoney/Label_DZ_UseMoneyNum"):GetComponent("UILabel"):set_text(equip.silverNum)
  itemGrid:FindDirect("Img_DZ_BgHaveMoney/Label_DZ_HaveMoneyNum"):GetComponent("UILabel"):set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)))
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(equip.silverNum) == true then
    itemGrid:FindDirect("Img_DZ_BgUseMoney/Label_DZ_UseMoneyNum"):GetComponent("UILabel"):set_textColor(Color.red)
  end
  self:UpdateEquipMakeWay()
end
def.method().RequireForGoldNum = function(self)
  if false == self._bWaitgoldNum then
    local itemIDs = {}
    for k, itemInfo in pairs(self._needItemTbl) do
      table.insert(itemIDs, itemInfo.id)
    end
    local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPriceWithId").new(self._equipMakeSelected.id, itemIDs)
    gmodule.network.sendProtocol(p)
    self._bWaitgoldNum = true
    local replaceObj = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Replace"):GetComponent("UIToggle")
    if replaceObj:get_isChecked() then
      replaceObj:set_isChecked(false)
    end
    local obj = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Make"):GetComponent("UIButton")
    obj:set_isEnabled(false)
  end
end
def.method("number", "table").SetEquipMakeItemNeedGold = function(self, id, itemid2yuanbao)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if self._equipMakeSelected.id == id and self._bWaitgoldNum then
    self._goldNum = 0
    for k, info in pairs(self._needItemTbl) do
      if itemid2yuanbao[info.id] ~= nil then
        self._goldNum = self._goldNum + info.num * itemid2yuanbao[info.id]
      end
    end
    local replaceObj = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Replace"):GetComponent("UIToggle")
    replaceObj:set_isChecked(true)
    self:UpdateEquipMakeWay()
  end
  self._bWaitgoldNum = false
  local obj = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Make"):GetComponent("UIButton")
  obj:set_isEnabled(true)
end
def.method("number", "number").EquipMakeItemGoldDifferent = function(self, eqpId, serverNeedYuanbao)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local bIsChecked = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Replace"):GetComponent("UIToggle"):get_isChecked()
  if self._equipMakeSelected.eqpId == eqpId and true == self._bMakeByGold and bIsChecked then
    self._goldNum = serverNeedYuanbao
    local replaceObj = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Replace"):GetComponent("UIToggle")
    replaceObj:set_isChecked(true)
    self:UpdateEquipMakeWay()
    local tag = {id = self}
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.Equip[53], self._goldNum), EquipMakeNode.GoldMakeEquipCallback, tag)
  end
end
def.method("number", "=>", "number").GetHigherLevelItem = function(self, itemId)
  local tblSrc = EquipUtils.GetEquipMakeMaterialInfo(itemId)
  local higherItemId = 0
  local higherItemLv = 0
  if require("consts.mzm.gsp.item.confbean.MaterialType").FU == tblSrc.materialType then
    local items = ItemModule.Instance():GetItems()
    for k, v in pairs(items) do
      local tblDst = EquipUtils.GetEquipMakeMaterialInfo(v.id)
      if nil ~= tblDst and nil ~= tblSrc and require("consts.mzm.gsp.item.confbean.MaterialType").FU == tblDst.materialType and tblDst.materialLevel > tblSrc.materialLevel and tblDst.materialWearPos == tblSrc.materialWearPos then
        if 0 == higherItemId then
          higherItemId = v.id
          higherItemLv = tblDst.materialLevel
        elseif 0 ~= higherItemId and higherItemLv > tblDst.materialLevel then
          higherItemId = v.id
          higherItemLv = tblDst.materialLevel
        end
      end
    end
  end
  return higherItemId
end
def.method().JudgeEquipCanMake = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local levelEquips = self._equipsForMake[self._curEquipLevel]
  if nil == levelEquips then
    return
  end
  for i = 1, #levelEquips do
    local bIsEquipCanMake = EquipUtils.GetIsEquipCanMake(levelEquips[i].makeCfgId, EquipMakeNode._equipMakeItemNum)
    local grid = self.m_node:FindDirect("Img_DZ_BgEquipList/Grid_DZ_EquipList")
    local equip = grid:FindDirect(string.format("Img_DZ_BgEquip0%d", i))
    equip:FindDirect(string.format("Img_DZ_EquipMark0%d", i)):SetActive(bIsEquipCanMake)
  end
end
def.method().OnPopupListChange = function(self)
  if self.selectMakeEquipInfo == nil then
    self:FillEquipMakeList(true)
    self:FillEquipMakeFrame(1)
    self:UpdateListBtn()
  end
end
def.method().UpdateEquipMakeWay = function(self)
  local bIsChecked = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Replace"):GetComponent("UIToggle"):get_isChecked()
  self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Make/Label_DZ_Make"):SetActive(true)
  self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Make/Group_MoneyMake"):SetActive(false)
  if true == self._bMakeByGold and bIsChecked then
    self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Make/Label_DZ_Make"):SetActive(false)
    self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Make/Group_MoneyMake"):SetActive(true)
    self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Make/Group_MoneyMake/Label_DZ_MoneyMake"):GetComponent("UILabel"):set_text(self._goldNum)
  elseif false == self._bMakeByGold and true == bIsChecked then
    self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Replace"):GetComponent("UIToggle"):set_isChecked(false)
    Toast(textRes.Equip[27])
  end
end
def.method().RefeshEquipMakeItemNum = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local equip = self._equipMakeSelected
  self._bMakeByGold = false
  self._needItemTbl = {}
  local itemGrid = self.m_node:FindDirect("Img_DZ_BgMake")
  for i = 0, EquipMakeNode._equipMakeItemNum - 1 do
    local itemInfo = equip.makeNeedItem[i]
    if nil == itemInfo then
      break
    end
    local have = ItemModule.Instance():GetItemCountById(itemInfo.itemId)
    local needAndHave = have .. "/" .. itemInfo.itemNum
    local item = itemGrid:FindDirect(string.format("Img_DZ_BgEquipMakeItem0%d", i + 1))
    item:FindDirect(string.format("Label_DZ_EquipMakeItem0%d", i + 1)):GetComponent("UILabel"):set_text(needAndHave)
    local textColor = Color.green
    if have < itemInfo.itemNum then
      table.insert(self._needItemTbl, {
        id = itemInfo.itemId,
        num = itemInfo.itemNum - have
      })
      textColor = Color.red
      self._bMakeByGold = true
    end
    item:FindDirect(string.format("Label_DZ_EquipMakeItem0%d", i + 1)):GetComponent("UILabel"):set_textColor(textColor)
  end
  local obj = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Replace"):GetComponent("UIToggle")
  if obj:get_isChecked() then
    if self._bMakeByGold then
      self:RequireForGoldNum()
    else
      obj:set_isChecked(false)
      self:UpdateEquipMakeWay()
    end
  end
end
def.method().RefeshSilverNum = function(self)
  local itemGrid = self.m_node:FindDirect("Img_DZ_BgMake")
  local haveSilverLabel = itemGrid:FindDirect("Img_DZ_BgHaveMoney/Label_DZ_HaveMoneyNum"):GetComponent("UILabel")
  local needSilverLabel = itemGrid:FindDirect("Img_DZ_BgUseMoney/Label_DZ_UseMoneyNum"):GetComponent("UILabel")
  local equip = self._equipMakeSelected
  local equipMakeInfo = EquipUtils.FillSelectedEquipMakeInfo(equip)
  local needSilver = equipMakeInfo.silverNum
  local haveSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  if haveSilver:lt(needSilver) then
    needSilverLabel.textColor = Color.red
  else
    needSilverLabel.textColor = Color.Color(0.30980392156862746, 0.18823529411764706, 0.09411764705882353, 1)
  end
  needSilverLabel:set_text(needSilver)
  haveSilverLabel:set_text(Int64.tostring(haveSilver))
end
def.method("number", "table").ShowEquipMakeSuccessFrame = function(self, key, info)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local obj = self.m_node:FindDirect("Img_DZ_BgPreview/Img_DZ_BgEquipPreview")
  require("Fx.GUIFxMan").Instance():PlayAsChild(obj, RESPATH.EQUIP_MAKE_SUCCEED_EFFECT, 0, 0, -1, false)
  ItemModule.Instance():BlockItemGetEffect(true)
  self.successKey = key
  self.successItemInfo = info
  GameUtil.AddGlobalTimer(1.5, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    if self.successItemInfo ~= nil then
      self.m_node:FindDirect("Img_DZ_BgPreview/Img_DZ_BgEquipPreview/Ing_DZ_EquipPreviewS"):SetActive(false)
      ItemModule.Instance():BlockItemGetEffect(false)
      if self.m_node and not self.m_node.isnil and self.m_node:get_activeInHierarchy() then
        self:OnEquipMakedClick()
      end
    end
  end)
  GameUtil.AddGlobalTimer(5, true, function()
    ItemModule.Instance():BlockItemGetEffect(false)
  end)
end
def.method().RealMakeEquip = function(self)
  local isUseGold = 0
  local bIsChecked = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Replace"):GetComponent("UIToggle"):get_isChecked()
  if true == self._bMakeByGold and bIsChecked then
    isUseGold = 1
  end
  local needItem = {}
  for i = 0, EquipMakeNode._equipMakeItemNum - 1 do
    local itemInfo = self._equipMakeSelected.makeNeedItem[i]
    if nil == itemInfo then
      break
    end
    needItem[itemInfo.itemId] = ItemModule.Instance():GetItemCountById(itemInfo.itemId)
  end
  if self._curEquipLevel < EquipMakeData.Instance():GetMakeEquipMaxLevel() then
    local p = require("netio.protocol.mzm.gsp.item.CEquipMake").new(self._equipMakeSelected.eqpId, self._equipMakeSelected.id, isUseGold, ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER), needItem, self._goldNum)
    gmodule.network.sendProtocol(p)
  else
    Toast(textRes.Equip[217])
  end
end
def.static("number", "table").GoldMakeEquipCallback = function(i, tag)
  if 1 == i then
    local dlg = tag.id
    dlg:PrepareToMake()
  elseif 0 == i then
    return
  end
end
def.static("number", "table").SilverMakeEquipCallback = function(i, tag)
  if 1 == i then
    GoToBuySilver(false)
  elseif 0 == i then
    return
  end
end
def.method().PrepareToMake = function(self)
  if true == self._bMakeByGold then
    local yuanbao = ItemModule.Instance():GetAllYuanBao()
    if Int64.lt(yuanbao, self._goldNum) then
      local MallPanel = require("Main.Mall.ui.MallPanel")
      require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
      Toast(textRes.Equip[52])
      return
    end
  end
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(self._equipMakeSelected.silverNum) == true then
    CommonConfirmDlg.ShowConfirm("", textRes.Equip[51], EquipMakeNode.SilverMakeEquipCallback, nil)
    return
  end
  self:RealMakeEquip()
end
def.method().JudgeMaterialEnough = function(self)
  if false == self._bMakeByGold then
    self:PrepareToMake()
  else
    local bIsChecked = self.m_node:FindDirect("Img_DZ_BgMake/Btn_DZ_Replace"):GetComponent("UIToggle"):get_isChecked()
    if false == bIsChecked then
      if #self._needItemTbl > 0 then
        local itemId = self._needItemTbl[1].id
        local itemGrid = self.m_node:FindDirect("Img_DZ_BgMake")
        local clickobj = itemGrid:FindDirect("Btn_DZ_Make")
        self:ShowItemTips(itemId, clickobj)
      end
      return
    elseif self._isFirstMakeByGold then
      self._isFirstMakeByGold = false
      local tag = {id = self}
      local content = textRes.Equip[8] .. self._goldNum .. textRes.Equip[6] .. textRes.Equip[9]
      CommonConfirmDlg.ShowConfirm(textRes.Equip[6], content, EquipMakeNode.GoldMakeEquipCallback, tag)
    else
      self:PrepareToMake()
    end
  end
end
def.method().OnEquipMakeBtnClick = function(self)
  self:JudgeMaterialEnough()
end
def.method("boolean").FillEquipMakeList = function(self, bIsPopListInit)
  local levelEquips = self._equipsForMake[self._curEquipLevel]
  if nil == levelEquips then
    return
  end
  local equipGrid = self.m_node:FindDirect("Img_DZ_BgEquipList/Grid_DZ_EquipList")
  for i = 1, #levelEquips do
    local equipItem = equipGrid:FindDirect(string.format("Img_DZ_BgEquip0%d", i))
    local equip = levelEquips[i].equipInfo
    equipItem:FindDirect(string.format("Label_DZ_EquipName0%d", i)):GetComponent("UILabel"):set_text(equip.name)
    local strLv = equip.useLevel .. textRes.Equip[30]
    equipItem:FindDirect(string.format("Label_DZ_EquipLv0%d", i)):GetComponent("UILabel"):set_text(strLv)
    equipItem:FindDirect(string.format("Label_DZ_EquipType0%d", i)):GetComponent("UILabel"):set_text(equip.typeName)
    local equipIcon = equipItem:FindDirect(string.format("Icon_DZ_Equip0%d", i))
    equipIcon:SetActive(true)
    local equipIconTex = equipIcon:GetComponent("UITexture")
    GUIUtils.FillIcon(equipIconTex, equip.iconId)
    equipItem:FindDirect(string.format("Img_DZ_EquipMark0%d", i)):SetActive(false)
    equipItem:FindDirect(string.format("Img_DZ_EquipSelect0%d", i)):SetActive(true)
    equipItem:GetComponent("UIToggle"):set_isChecked(false)
  end
  self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Down"):SetActive(true)
  self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Up"):SetActive(false)
  self:JudgeEquipCanMake()
  if bIsPopListInit then
    return
  end
  local popList = self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu"):GetComponent("UIPopupList")
  if 0 ~= #self._equipLevelsForMake then
    popList:set_items(self._equipLevelsForMake)
    popList:set_selectIndex(self._curEquipLevelKey - 1)
    popList:set_value(self._equipLevelsForMake[self._curEquipLevelKey])
  else
    popList:SetActive(false)
  end
end
def.override("string", "string", "number").onSelect = function(self, id, selected, index)
  if id == "Btn_DZ_Menu" and index ~= -1 then
    self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Down"):SetActive(true)
    self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Up"):SetActive(false)
    self._curEquipLevelKey = index + 1
    self._curEquipLevel = tonumber(selected)
    self:OnPopupListChange()
    self:setEquipMakeLevelLimit()
  end
end
def.method().OnEquipMakeLevelMenuClick = function(self)
  if self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Down"):get_activeInHierarchy() and self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Up"):get_activeInHierarchy() == false then
    self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Down"):SetActive(false)
    self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Up"):SetActive(true)
  elseif false == self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Down"):get_activeInHierarchy() and self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Up"):get_activeInHierarchy() then
    self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Down"):SetActive(true)
    self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu/Img_DZ_Up"):SetActive(false)
  end
end
def.method().OnEquipMakePreviewClick = function(self)
  local strenNameContent, strenValContent = EquipUtils.GetStrenPreContentByEquip(self._equipMakeSelected)
  local hunCfg = EquipUtils.GetTransNameAndValueCfg(self._equipMakeSelected)
  local hunMaxNum = EquipUtils.GetEquipMaxHunNum(self._equipMakeSelected.eqpId)
  local title = textRes.Equip[18] .. textRes.Equip[19]
  local position = {
    auto = false,
    sourceX = 449,
    sourceY = 50
  }
  EquipInfoShowDlg.ShowEquipInfo(title, self._equipMakeSelected.eqpId, self._equipMakeSelected.equipInfo, nil, strenNameContent, strenValContent, position, tostring(hunMaxNum), 0, hunCfg)
end
def.method().OnEquipMakeTabSelect = function(self)
  if self.selectMakeEquipInfo ~= nil then
    self:SetMakeEquip(self.selectMakeEquipInfo.type, self.selectMakeEquipInfo.level)
    self.selectMakeEquipInfo = nil
  else
    self:ShowMainEquipDlg()
  end
end
def.override().OnShow = function(self)
  if self.m_node and self.m_node.isnil == false then
    local Btn_DZ_EffectRemake = self.m_node:FindDirect("Img_DZ_BgPreview/Btn_DZ_EffectRemake")
    if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIP_SKILL_REFRESH) then
      Btn_DZ_EffectRemake:SetActive(true)
    else
      Btn_DZ_EffectRemake:SetActive(false)
    end
  end
  self:UpdateEquipBlessStatus()
  self:OnEquipMakeTabSelect()
  self:setEquipMakeLevelLimit()
  Event.RegisterEventWithContext(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_Bless_Notify_Change, EquipMakeNode.OnEquipBlessNotifyChange, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_Bless_Notify_Change, EquipMakeNode.OnEquipBlessNotifyChange)
end
def.method().UpdateEquipBlessStatus = function(self)
  local Btn_DZ_Bless = self.m_node:FindDirect("Img_DZ_BgPreview/Btn_DZ_Bless")
  local Img_Red = Btn_DZ_Bless:FindDirect("Img_Red")
  if require("Main.Equip.EquipBlessMgr").Instance():IsOpen() then
    Btn_DZ_Bless:SetActive(true)
    Img_Red:SetActive(require("Main.Equip.EquipBlessMgr").Instance():HasNotify())
  else
    Btn_DZ_Bless:SetActive(false)
    Img_Red:SetActive(false)
  end
end
def.method().setEquipMakeLevelLimit = function(self)
  local Label_Tips = self.m_node:FindDirect("Label_Tips")
  if self._curEquipLevel == 100 then
    Label_Tips:SetActive(true)
  else
    Label_Tips:SetActive(false)
  end
end
def.method("userdata").OnEquipMakeNeedItemClick = function(self, clickobj)
  local id = clickobj.name
  local indexStr = string.sub(id, string.len("Img_DZ_BgEquipMakeItem0") + 1)
  local index = tonumber(indexStr)
  local itemId = tonumber(clickobj:FindDirect(string.format("Lable_DZ_Key%d", index)):GetComponent("UILabel"):get_text())
  self:ShowItemTips(itemId, clickobj)
end
def.method("number", "userdata").ShowItemTips = function(self, itemId, clickobj)
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
end
def.method().UpdateListBtn = function(self)
  if self._curEquipLevelKey - 1 > 0 then
    self.m_node:FindDirect("Img_DZ_BgEquipList/Btn_Left"):SetActive(true)
  else
    self.m_node:FindDirect("Img_DZ_BgEquipList/Btn_Left"):SetActive(false)
  end
  if self._curEquipLevelKey + 1 <= #self._equipLevelsForMake then
    self.m_node:FindDirect("Img_DZ_BgEquipList/Btn_Right"):SetActive(true)
  else
    self.m_node:FindDirect("Img_DZ_BgEquipList/Btn_Right"):SetActive(false)
  end
end
def.method().OnLeftListSelect = function(self)
  if self._curEquipLevelKey - 1 > 0 then
    local tmp = self._curEquipLevelKey - 1
    local popList = self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu"):GetComponent("UIPopupList")
    popList:set_selectIndex(tmp - 1)
    popList:set_value(self._equipLevelsForMake[tmp])
  end
end
def.method().OnRightListSelect = function(self)
  if self._curEquipLevelKey + 1 <= #self._equipLevelsForMake then
    local tmp = self._curEquipLevelKey + 1
    local popList = self.m_node:FindDirect("Img_DZ_BgEquipList/Panel_Menu/Btn_DZ_Menu"):GetComponent("UIPopupList")
    popList:set_selectIndex(tmp - 1)
    popList:set_value(self._equipLevelsForMake[tmp])
  end
end
def.method().OnEquipMakedClick = function(self)
  local obj = self.m_node:FindDirect("Img_DZ_BgPreview")
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent("UISprite")
  local itemBase = require("Main.Item.ItemUtils").GetEquipBase(self.successItemInfo.id)
  local _, posItem = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, itemBase.wearpos)
  if posItem and posItem.uuid[1] == self.successItemInfo.uuid[1] then
    ItemTipsMgr.Instance():ShowTips(self.successItemInfo, 0, 0, 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
  else
    ItemTipsMgr.Instance():ShowTips(self.successItemInfo, ItemModule.BAG, self.successKey, ItemTipsMgr.Source.EquipMake, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_DZ_Menu" then
    self:OnEquipMakeLevelMenuClick()
  elseif string.find(id, "Img_DZ_BgEquip0") then
    local indexStr = string.sub(id, string.len("Img_DZ_BgEquip0") + 1)
    local index = tonumber(indexStr)
    self:FillEquipMakeFrame(index)
  elseif string.find(id, "Img_DZ_BgEquipMakeItem0") then
    self:OnEquipMakeNeedItemClick(clickobj)
  elseif id == "Btn_DZ_Replace" then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      self:RequireForGoldNum()
    else
      self._goldNum = 0
      self._bWaitgoldNum = false
      self:UpdateEquipMakeWay()
    end
  elseif id == "Btn_DZ_Preview" then
    self:OnEquipMakePreviewClick()
  elseif id == "Btn_DZ_Make" then
    self:OnEquipMakeBtnClick()
  elseif id == "Btn_DZ_Add" then
    GoToBuySilver(false)
  elseif id == "Btn_Left" then
    self:OnLeftListSelect()
  elseif id == "Btn_Right" then
    self:OnRightListSelect()
  elseif id == "Icon_DZ_BgEquipPreview" then
    local Ing_DZ_EquipPreviewS = clickobj.parent:FindDirect("Ing_DZ_EquipPreviewS")
    if false == Ing_DZ_EquipPreviewS:get_activeInHierarchy() then
      self:OnEquipMakedClick()
    end
  elseif id == "Btn_DZ_EffectRemake" then
    local EquipEffectResetPanel = require("Main.Equip.ui.EquipEffectResetPanel")
    EquipEffectResetPanel.Instance():ShowPanel()
  elseif id == "Btn_DZ_Bless" then
    local EquipBlessPanel = require("Main.Equip.ui.EquipBlessPanel")
    EquipBlessPanel.Instance():ShowPanel()
  end
end
def.method().OnRefreshView = function(self)
end
def.method("table").OnEquipBlessNotifyChange = function(self, params)
  self:UpdateEquipBlessStatus()
end
EquipMakeNode.Commit()
return EquipMakeNode

local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local EquipTransNode = Lplus.Extend(TabNode, "EquipTransNode")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = EquipTransNode.define
local EquipStrenTransData = require("Main.Equip.EquipStrenTransData")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local EquipTransChooseDlg = require("Main.Equip.ui.EquipTransChooseDlg")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local EquipSocialPanel = Lplus.ForwardDeclare("EquipSocialPanel")
def.field("table")._equipTransSelected = nil
def.field("table")._equipTransConsume = nil
def.field("number")._equipTransConsumeNum = 0
def.field("number")._replaceSoleIndex = -1
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
def.method().RealEquipPlay = function(self)
  if self.m_node:get_activeInHierarchy() then
    self:RealTransEquip()
  end
end
def.method("number").FillEquipTransFrame = function(self, index)
  local compareGrid = self.m_node:FindDirect("Img_FH_BgCompare")
  local grid1 = compareGrid:FindDirect("Img_FH_Bg01")
  local grid2 = compareGrid:FindDirect("Img_FH_Bg02")
  grid2:FindDirect("Group_FH_Equip02Empty"):SetActive(true)
  grid2:FindDirect("Group_FH_Equip02Info"):SetActive(false)
  grid2:FindDirect("Group_FH_Equip02Empty/Label_FH_Tips"):GetComponent("UILabel"):set_text(textRes.Equip[37])
  local equipStrenTransList = EquipStrenTransData.Instance():GetTransEquips()
  local equip = equipStrenTransList[index]
  self._equipTransSelected = equip
  if equip == nil then
    return
  end
  local transItemId = EquipUtils.GetEquipTransNeedItemId()
  local record1 = require("Main.Item.ItemUtils").GetItemBase(transItemId)
  local iconId = 0
  local name = ""
  if record1 ~= nil then
    iconId = record1.icon
    name = record1.name
  end
  local equipGrid = self.m_node:FindDirect("Img_FH_BgEquipMake")
  local itemIcon = equipGrid:FindDirect("Img_FH_BgEquipMakeItem01/Icon_FH_EquipMakeItem01")
  itemIcon:SetActive(true)
  local itemIconTex = itemIcon:GetComponent("UITexture")
  GUIUtils.FillIcon(itemIconTex, iconId)
  equipGrid:FindDirect("Label_FH_EquipMakeName01"):GetComponent("UILabel"):set_text(name)
  self:UpdateTransItemNum()
  self:UpdateTransSilverNum()
  local equipIcon = grid1:FindDirect("Img_FH_BgEquip01/Icon_FH_Equip01")
  equipIcon:SetActive(true)
  local equipIconTex = equipIcon:GetComponent("UITexture")
  GUIUtils.FillIcon(equipIconTex, self._equipTransSelected.iconId)
  grid1:FindDirect("Img_FH_BgEquip01/Label_FH_EquipName01"):GetComponent("UILabel"):set_text(self._equipTransSelected.name)
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipTransSelected.bagId, self._equipTransSelected.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  local compareGrid = self.m_node:FindDirect("Img_FH_BgCompare")
  local grid1 = compareGrid:FindDirect("Img_FH_Bg01")
  grid1:FindDirect("Img_FH_BgEquip01/Label_FH_EquipScore01"):GetComponent("UILabel"):set_text(string.format(textRes.Equip[41], score))
  local tbl = {}
  for k, v in pairs(equipItem.exproList) do
    local str = EquipModule.GetProRandomName(v.proType)
    local pro = EquipModule.GetProTypeID(v.proType)
    local val, realVal = EquipModule.GetProRealValue(v.proType, v.proValue)
    table.insert(tbl, {
      name = str,
      value = val,
      pro = pro,
      realVal = realVal,
      isLock = v.islock,
      proValue = v.proValue
    })
  end
  self:FillSoleList(tbl)
end
def.method().UpdateCurEquipInfo = function(self)
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipTransSelected.bagId, self._equipTransSelected.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  local compareGrid = self.m_node:FindDirect("Img_FH_BgCompare")
  local grid1 = compareGrid:FindDirect("Img_FH_Bg01")
  grid1:FindDirect("Img_FH_BgEquip01/Label_FH_EquipScore01"):GetComponent("UILabel"):set_text(string.format(textRes.Equip[41], score))
  local tbl = {}
  for k, v in pairs(equipItem.exproList) do
    local str = EquipModule.GetProRandomName(v.proType)
    local pro = EquipModule.GetProTypeID(v.proType)
    local val, realVal = EquipModule.GetProRealValue(v.proType, v.proValue)
    table.insert(tbl, {
      name = str,
      value = val,
      pro = pro,
      realVal = realVal,
      isLock = v.islock,
      proValue = v.proValue
    })
  end
  local uiList = grid1:FindDirect("Grid_FH_Attribute01"):GetComponent("UIList")
  local solesUI = uiList:get_children()
  for i = 1, #solesUI do
    local soleUI = solesUI[i]
    local soleInfo = tbl[i]
    self:FillSoleInfo(soleInfo, i, soleUI)
  end
end
def.method().UpdateTransItemNum = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local transItemNum, transNeedSilver = EquipUtils.GetEquipTransNeedItemInfo(self._equipTransSelected.useLevel)
  self._equipTransSelected.needCooperNum = transNeedSilver
  local transItemId = EquipUtils.GetEquipTransNeedItemId()
  local have = ItemModule.Instance():GetItemCountById(transItemId)
  local needAndHave = have .. "/" .. transItemNum
  local equipGrid = self.m_node:FindDirect("Img_FH_BgEquipMake")
  equipGrid:FindDirect("Img_FH_BgEquipMakeItem01/Label_FH_EquipMakeItem01"):GetComponent("UILabel"):set_text(needAndHave)
  local textColor = Color.green
  self._equipTransSelected.bneedItemEnough = true
  if transItemNum > have then
    textColor = Color.red
    self._equipTransSelected.bneedItemEnough = false
  end
  equipGrid:FindDirect("Img_FH_BgEquipMakeItem01/Label_FH_EquipMakeItem01"):GetComponent("UILabel"):set_textColor(textColor)
  equipGrid:FindDirect("Img_FH_BgUseMoney/Label_FH_UseMoneyNum"):GetComponent("UILabel"):set_text(transNeedSilver)
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(transNeedSilver) == true then
    equipGrid:FindDirect("Img_FH_BgUseMoney/Label_FH_UseMoneyNum"):GetComponent("UILabel"):set_textColor(Color.red)
  end
end
def.method().UpdateTransSilverNum = function(self)
  local equipGrid = self.m_node:FindDirect("Img_FH_BgEquipMake")
  equipGrid:FindDirect("Img_FH_BgHaveMoney/Label_FH_HaveMoneyNum"):GetComponent("UILabel"):set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)))
end
def.method("table").FillSoleList = function(self, exproList)
  local compareGrid = self.m_node:FindDirect("Img_FH_BgCompare")
  local grid1 = compareGrid:FindDirect("Img_FH_Bg01")
  local uiList = grid1:FindDirect("Grid_FH_Attribute01"):GetComponent("UIList")
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
  local color = EquipUtils.GetProColor(exproInfo.proValue)
  local typeInfo = "[" .. color .. "]" .. exproInfo.name .. ":+" .. exproInfo.value
  soleNew:FindDirect(string.format("Label_FH_UseeSelectTips01_%d", index)):GetComponent("UILabel"):set_text(typeInfo)
  soleNew:GetComponent("UIToggle"):set_isChecked(false)
  if 1 == exproInfo.isLock then
    soleNew:GetComponent("UIToggle"):set_isChecked(true)
  end
  local Img_Bg = soleNew:FindDirect(string.format("Img_Bg_%d", index))
  local Img_Bg2 = soleNew:FindDirect(string.format("Img_Bg2_%d", index))
  if index % 2 == 0 then
    Img_Bg:SetActive(false)
    Img_Bg2:SetActive(true)
  else
    Img_Bg:SetActive(true)
    Img_Bg2:SetActive(false)
  end
end
def.method("table").FillChooseEquip = function(self, equip)
  local grid2 = self.m_node:FindDirect("Img_FH_BgCompare/Img_FH_Bg02")
  local info2 = grid2:FindDirect("Group_FH_Equip02Info")
  local chooseIcon = info2:FindDirect("Img_FH_BgEquip02/Icon_FH_Equip02")
  chooseIcon:SetActive(true)
  local chooseIconTex = chooseIcon:GetComponent("UITexture")
  GUIUtils.FillIcon(chooseIconTex, equip.iconId)
  info2:FindDirect("Img_FH_BgEquip02/Label_FH_EquipName02"):GetComponent("UILabel"):set_text(equip.name)
  self._equipTransConsume = equip
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipTransConsume.bagId, self._equipTransConsume.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  info2:FindDirect("Img_FH_BgEquip02/Label_FH_EquipScore02"):GetComponent("UILabel"):set_text(string.format(textRes.Equip[41], score))
  local tbl = {}
  for k, v in pairs(equip.exproList) do
    local str = EquipModule.GetProRandomName(v.proType)
    local pro = EquipModule.GetProTypeID(v.proType)
    local val, realVal = EquipModule.GetProRealValue(v.proType, v.proValue)
    table.insert(tbl, {
      name = str,
      value = val,
      pro = pro,
      realVal = realVal,
      proValue = v.proValue
    })
  end
  self._equipTransConsumeNum = #tbl
  self:FillChooseList(tbl)
end
def.method("table").FillChooseList = function(self, exproList)
  local grid2 = self.m_node:FindDirect("Img_FH_BgCompare/Img_FH_Bg02")
  local info2 = grid2:FindDirect("Group_FH_Equip02Info")
  local uiList = info2:FindDirect("Grid_FH_AttributeRight"):GetComponent("UIList")
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
  self._replaceSoleIndex = -1
end
def.method("table", "number", "userdata").FillChooseInfo = function(self, exproInfo, index, soleNew)
  local color = EquipUtils.GetProColor(exproInfo.proValue)
  local typeInfo = "[" .. color .. "]" .. exproInfo.name .. ":+" .. exproInfo.value
  soleNew:FindDirect(string.format("Label_FH_AttributeRight01_%d", index)):GetComponent("UILabel"):set_text(typeInfo)
  soleNew:GetComponent("UIToggle"):set_isChecked(false)
end
def.static("table", "table").AddChooseCallback = function(tag, equipChoose)
  local dlg = tag.id
  local compareGrid = dlg.m_node:FindDirect("Img_FH_BgCompare")
  local grid2 = compareGrid:FindDirect("Img_FH_Bg02")
  grid2:FindDirect("Group_FH_Equip02Empty"):SetActive(false)
  grid2:FindDirect("Group_FH_Equip02Info"):SetActive(true)
  dlg:FillChooseEquip(equipChoose)
end
def.method().OnTransAddClick = function(self)
  if nil ~= self._equipTransSelected then
    local costEquips = EquipTransChooseDlg.IfHaveCostEquips(true, self._equipTransSelected)
    if #costEquips > 0 then
      local tag = {id = self}
      EquipTransChooseDlg.ShowEquipChoose(self._equipTransSelected, EquipTransNode.AddChooseCallback, tag, true)
    else
      Toast(textRes.Equip[26])
    end
  end
end
def.method("number").OnEquipListClick = function(self, index)
  self:FillEquipTransFrame(index)
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
def.method().RealTransEquip = function(self)
  local transItemId = EquipUtils.GetEquipTransNeedItemId()
  local have = ItemModule.Instance():GetItemCountById(transItemId)
  local tbl = {}
  tbl[transItemId] = have
  local p = require("netio.protocol.mzm.gsp.item.CEquipTransferHun").new(self._equipTransConsume.key, self._replaceSoleIndex, self._equipTransSelected.bagId, self._equipTransSelected.key, ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER), tbl)
  gmodule.network.sendProtocol(p)
  self:UpdateSelectCost()
end
def.method().ShowCostEquipEffect = function(self)
end
def.method().UpdateSelectCost = function(self)
  local grid2 = self.m_node:FindDirect("Img_FH_BgCompare/Img_FH_Bg02")
  local info2 = grid2:FindDirect("Group_FH_Equip02Info")
  local gridTemplate = info2:FindDirect("Grid_FH_AttributeRight")
  local obj = gridTemplate:FindDirect(string.format("FH_AttributeRight01_%d", self._replaceSoleIndex))
  require("Fx.GUIFxMan").Instance():PlayAsChild(obj, RESPATH.EQUIP_TRANS_RIGHT_EFFECT, 0, 0, -1, false)
end
def.method("number", "table").RefeshEquipTrans = function(self, index, newInfo)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self:RefeshEquipTransInfo(index, newInfo)
end
def.method("number", "table").RefeshEquipTransInfo = function(self, index, newInfo)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local compareGrid = self.m_node:FindDirect("Img_FH_BgCompare")
  local grid1 = compareGrid:FindDirect("Img_FH_Bg01")
  local attributeGrid1 = grid1:FindDirect("Grid_FH_Attribute01")
  local soleNew = attributeGrid1:FindDirect(string.format("Btn_FH_Use01_%d", index))
  local str = EquipModule.GetProRandomName(newInfo.proType)
  local pro = EquipModule.GetProTypeID(newInfo.proType)
  local val, realVal = EquipModule.GetProRealValue(newInfo.proType, newInfo.proValue)
  local color = EquipUtils.GetProColor(newInfo.proValue)
  local grid2 = compareGrid:FindDirect("Img_FH_Bg02")
  local info2 = grid2:FindDirect("Group_FH_Equip02Info")
  local gridTemplate = info2:FindDirect("Grid_FH_AttributeRight")
  Timer:RemoveIrregularTimeListener(self.UpdateSelectCost)
  local objR = attributeGrid1:FindDirect(string.format("Btn_FH_Use01_%d", index)):FindDirect(string.format("Label_FH_UseeSelectTips01_%d", index))
  require("Fx.GUIFxMan").Instance():PlayAsChild(objR, RESPATH.EQUIP_TRANS_LEFT_EFFECT, 0, 0, -1, false)
  GameUtil.AddGlobalTimer(1, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    gridTemplate:GetComponent("UIList"):set_itemCount(0)
    gridTemplate:GetComponent("UIList"):Resize()
    grid2:FindDirect("Group_FH_Equip02Empty"):SetActive(true)
    grid2:FindDirect("Group_FH_Equip02Info"):SetActive(false)
    self._equipTransConsume = nil
    self._equipTransConsumeNum = 0
    GameUtil.AddGlobalTimer(0.5, true, function()
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      local info = "[" .. color .. "]" .. str .. ":+" .. val
      soleNew:FindDirect(string.format("Label_FH_UseeSelectTips01_%d", index)):GetComponent("UILabel"):set_text(info)
      local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipTransSelected.bagId, self._equipTransSelected.key)
      local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
      grid1:FindDirect("Img_FH_BgEquip01/Label_FH_EquipScore01"):GetComponent("UILabel"):set_text(string.format(textRes.Equip[41], score))
      soleNew:GetComponent("UIToggle"):set_isChecked(false)
      self._replaceSoleIndex = -1
    end)
  end)
end
def.method().FailedEquipTrans = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local compareGrid = self.m_node:FindDirect("Img_FH_BgCompare")
  local grid2 = compareGrid:FindDirect("Img_FH_Bg02")
  local info2 = grid2:FindDirect("Group_FH_Equip02Info")
  local gridTemplate = info2:FindDirect("Grid_FH_AttributeRight")
  Timer:RemoveIrregularTimeListener(self.UpdateSelectCost)
  GameUtil.AddGlobalTimer(1, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    grid2:FindDirect("Group_FH_Equip02Empty"):SetActive(true)
    grid2:FindDirect("Group_FH_Equip02Info"):SetActive(false)
    self._equipTransConsume = nil
    self._equipTransConsumeNum = 0
    self._replaceSoleIndex = -1
  end)
end
def.method().OnEquipTransClick = function(self)
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(self._equipTransSelected.needCooperNum) == true then
    GoToBuySilver(false)
    return
  end
  if false == self._equipTransSelected.bneedItemEnough then
    local equipGrid = self.m_node:FindDirect("Img_FH_BgEquipMake")
    local clickobj = equipGrid:FindDirect("Btn_FH_Make")
    self:OnEquipTransNeedItemClick(clickobj)
    return
  end
  local equip = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipTransSelected.bagId, self._equipTransSelected.key)
  if #equip.exproList < 1 then
    Toast(textRes.Equip[14])
    return
  end
  if -1 == self._replaceSoleIndex then
    Toast(textRes.Equip[15])
    return
  end
  if nil == self._equipTransConsume then
    Toast(textRes.Equip[31])
    return
  end
  local flag = equip.flag
  if require("netio.protocol.mzm.gsp.item.ItemInfo").BIND ~= flag then
    local tag = {id = self}
    local content = textRes.Equip[16] .. textRes.Equip[20] .. textRes.Equip[16] .. textRes.Equip[9]
    CommonConfirmDlg.ShowConfirm(textRes.Equip[29], content, EquipTransNode.EquipBindCallback, tag)
  else
    self:RealTransEquip()
  end
end
def.method("=>", "number").GetEquipTransSelectedKey = function(self)
  return self._equipTransSelected.key
end
def.override().OnShow = function(self)
  self:OnEquipListClick(1)
  EquipSocialPanel.Instance():SelectFromEquipStrenTrans(1)
end
def.override().OnHide = function(self)
end
def.method("userdata").OnEquipTransNeedItemClick = function(self, clickobj)
  local itemId = EquipUtils.GetEquipTransNeedItemId()
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
end
def.static("number", "table").BuyGoldCallback = function(i, tag)
  if 1 == i then
    GoToBuyGold(false)
  elseif 0 == i then
    return
  end
end
def.static("number", "table").EquipAddLockCallback = function(i, tag)
  if 1 == i then
    local self = tag.id
    local cost = tag.cost
    local moneyType = tag.moneyType
    local clickobj = tag.obj
    local bEnough = false
    if moneyType == 0 then
    elseif moneyType == 1 then
      local yuanbao = ItemModule.Instance():GetAllYuanBao()
      bEnough = yuanbao:lt(cost) == false
    elseif moneyType == 2 then
      bEnough = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD):lt(cost) == false
    elseif moneyType == 3 then
      bEnough = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(cost) == false
    elseif moneyType == 4 then
      local curBanggong = GangModule.Instance():GetHeroCurBanggong()
      bEnough = cost < curBanggong == true
    end
    if bEnough == false then
      Toast(string.format(textRes.Equip[59], textRes.Equip.MoneyType[moneyType]))
      clickobj:GetComponent("UIToggle"):set_isChecked(false)
    else
      local p = require("netio.protocol.mzm.gsp.item.CLockHunReq").new(self._equipTransSelected.bagId, self._equipTransSelected.uuid, tag.index)
      gmodule.network.sendProtocol(p)
      require("Fx.GUIFxMan").Instance():PlayAsChild(clickobj, RESPATH.EQUIP_STREN_LIGHT_ON_EFFECT, 0, 0, -1, false)
    end
  elseif 0 == i then
    local clickobj = tag.obj
    clickobj:GetComponent("UIToggle"):set_isChecked(false)
    return
  end
end
def.static("number", "table").EquipRemoveLockCallback = function(i, tag)
  if 1 == i then
    local self = tag.id
    local clickobj = tag.obj
    local p = require("netio.protocol.mzm.gsp.item.CUnLockHunReq").new(self._equipTransSelected.bagId, self._equipTransSelected.uuid, tag.index)
    gmodule.network.sendProtocol(p)
    require("Fx.GUIFxMan").Instance():PlayAsChild(clickobj, RESPATH.EQUIP_STREN_LIGHT_ON_EFFECT, 0, 0, -1, false)
  elseif 0 == i then
    local clickobj = tag.obj
    clickobj:GetComponent("UIToggle"):set_isChecked(true)
    return
  end
end
def.method("userdata").OnLockSoleClick = function(self, clickobj)
  local id = clickobj.name
  local index = tonumber(string.sub(id, #"Btn_FH_Use01_" + 1, -1))
  if clickobj:GetComponent("UIToggle"):get_isChecked() then
    local equipSoles = 0
    local lockSoles = 0
    local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipTransSelected.bagId, self._equipTransSelected.key)
    for k, v in pairs(equipItem.exproList) do
      equipSoles = equipSoles + 1
      if 1 == v.islock then
        lockSoles = lockSoles + 1
      end
    end
    if lockSoles >= equipSoles - 1 then
      Toast(string.format(textRes.Equip[54], equipSoles - 1))
      clickobj:GetComponent("UIToggle"):set_isChecked(false)
      return
    end
    local cost, moneyType = EquipUtils.GetLockSoleCost(self._equipTransSelected.useLevel, lockSoles)
    local tag = {}
    tag.id = self
    tag.index = index
    tag.obj = clickobj
    tag.cost = cost
    tag.moneyType = moneyType
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.Equip[55], cost, textRes.Equip.MoneyType[moneyType]), EquipTransNode.EquipAddLockCallback, tag)
  else
    local tag = {}
    tag.id = self
    tag.index = index
    tag.obj = clickobj
    CommonConfirmDlg.ShowConfirm("", textRes.Equip[56], EquipTransNode.EquipRemoveLockCallback, tag)
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_FH_Add" then
    GoToBuySilver(false)
  elseif string.sub(id, 1, #"Btn_FH_Use01_") == "Btn_FH_Use01_" then
    self:OnLockSoleClick(clickobj)
  elseif id == "Btn_FH_BgAdd" then
    self:OnTransAddClick()
  elseif id == "Btn_FH_Make" then
    self:OnEquipTransClick()
  elseif id == "Icon_FH_Equip02" then
    self:OnTransAddClick()
  elseif id == "Img_FH_BgEquipMakeItem01" then
    self:OnEquipTransNeedItemClick(clickobj)
  elseif id == "Btn_FH_Tips" then
    EquipUtils.ShowTransInfoDlg()
  elseif string.sub(id, 1, #"FH_AttributeRight01_") == "FH_AttributeRight01_" then
    if clickobj:GetComponent("UIToggle"):get_value() then
      local index = tonumber(string.sub(id, #"FH_AttributeRight01_" + 1, -1))
      self._replaceSoleIndex = index
    else
      self._replaceSoleIndex = -1
    end
  end
end
def.method().OnRefreshView = function(self)
end
EquipTransNode.Commit()
return EquipTransNode

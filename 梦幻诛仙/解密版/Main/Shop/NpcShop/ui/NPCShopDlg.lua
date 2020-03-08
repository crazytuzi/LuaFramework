local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local NPCTradeData = require("Main.Shop.NpcShop.NPCTradeData")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local NpcShopDlg = Lplus.Extend(ECPanelBase, "NpcShopDlg")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local TaskInterface = require("Main.task.TaskInterface")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local NPCShopModule = Lplus.ForwardDeclare("NPCShopModule")
local NPCShopUtils = require("Main.Shop.NpcShop.NPCShopUtils")
local def = NpcShopDlg.define
local dlg
def.field("table")._itemList = nil
def.field("boolean")._bShopTemplateFill = false
def.field("table")._curSelectItem = nil
def.field("boolean")._bIsByTask = false
def.field("number")._indexByTask = -1
def.field("number").digitalEntered = 0
def.field("string")._shopName = ""
def.field("string")._artFontIconId = ""
def.field("number")._priceType = 0
def.field("number")._maxBuyNum = 0
def.field("number").incPropTime = 0
def.field("number").decPropTime = 0
def.field("number").pressedTime = 0
def.field("number").lastNeedIndex = 0
def.static("=>", NpcShopDlg).Instance = function()
  if nil == dlg then
    dlg = NpcShopDlg()
    dlg.m_TrigGC = true
  end
  return dlg
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self._itemList = {}
  self._curSelectItem = {}
  self:FillShopItems(NPCShopModule.Instance():GetServiceId())
  if self._bIsByTask then
    self:FillItemSelectFromTask()
  else
    self:FillItemSelectFromNPCService()
  end
  self:UpdateShopItemsState()
  self.lastNeedIndex = 0
end
def.override().OnDestroy = function(self)
end
def.method("number").FillShopItems = function(self, serviceId)
  local shop = NPCTradeData.GetStoreCfg(serviceId)
  self._itemList = shop.itemList
  self._shopName = shop.shopName
  self._artFontIconId = shop.artFontIconId
  self._priceType = shop.priceType
  self._maxBuyNum = shop.maxBuyNum
  self._bShopTemplateFill = false
  local bg = self.m_panel:FindDirect("Img_Bg0")
  local uiSprite = bg:FindDirect("Img_BgTitleEquip/Label_TitleEquip01"):GetComponent("UISprite")
  NPCShopUtils.FillIcon(self._artFontIconId, uiSprite)
  local gridTemplate = bg:FindDirect("Img_Bg1/Img_BgItems/Scroll View_Items/Grid_Items")
  local itemTemplate = gridTemplate:FindDirect("Img_BgItem01")
  if 0 == #self._itemList then
    itemTemplate:SetActive(false)
    return
  end
  local count = 1
  gridTemplate:GetChild(0):SetActive(true)
  self:FillShopList(count, itemTemplate, gridTemplate)
  local uiGrid = gridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number", "userdata", "userdata").FillShopList = function(self, count, itemTemplate, gridTemplate)
  local index = 1
  if false == self._bShopTemplateFill then
    index = 2
    if #self._itemList > 0 then
      self:FillItemInfo(1, count, itemTemplate, gridTemplate)
      self._bShopTemplateFill = true
    end
  else
    index = 1
  end
  for i = index, #self._itemList do
    count = count + 1
    local itemNew = Object.Instantiate(itemTemplate)
    self:FillItemInfo(i, count, itemNew, gridTemplate)
  end
end
def.method("number", "number", "userdata", "userdata").FillItemInfo = function(self, index, count, itemNew, gridTemplate)
  itemNew:set_name(string.format("Img_BgItem0%d", index))
  itemNew.parent = gridTemplate
  itemNew:set_localScale(Vector.Vector3.one)
  local itemBase = ItemUtils.GetItemBase(self._itemList[index])
  itemNew:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(itemBase.name)
  local sellMoney = NPCShopUtils.GetItemSellNum(self._itemList[index])
  itemNew:FindDirect("Img_BgPrice/Label_Price"):GetComponent("UILabel"):set_text(sellMoney)
  local iconSprite = itemNew:FindDirect("Img_BgIcon/Img_Icon"):GetComponent("UITexture")
  GUIUtils.FillIcon(iconSprite, itemBase.icon)
  itemNew:FindDirect("Img_BgIcon/Img_Sign"):SetActive(false)
  itemNew:GetComponent("UIToggle"):set_isChecked(false)
end
def.method("number", "number").SetItemSelectConst = function(self, index, requireNum)
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local group = bg:FindDirect("Group_Buy")
  local itemBase = ItemUtils.GetItemBase(self._itemList[index])
  local costs = 0
  local sellMoney = NPCShopUtils.GetItemSellNum(self._itemList[index])
  self.digitalEntered = requireNum
  group:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel"):set_text(self.digitalEntered)
  costs = sellMoney * self.digitalEntered
  group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_text(costs)
  if self:GetAndUpdateSilverNum():lt(costs) then
    group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_textColor(Color.red)
  else
    group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_textColor(Color.white)
  end
end
def.method("=>", "userdata").GetAndUpdateSilverNum = function(self)
  local haveMoney = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local group = bg:FindDirect("Group_Buy")
  group:FindDirect("Label_Have/Img_BgHave/Label_HaveNum"):GetComponent("UILabel"):set_text(Int64.tostring(haveMoney))
  return haveMoney
end
def.method().UpdateHaveAndNeedSilver = function(self)
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local group = bg:FindDirect("Group_Buy")
  local costNum = group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):get_text()
  costNum = tonumber(costNum)
  if self:GetAndUpdateSilverNum():lt(costNum) then
    group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_textColor(Color.red)
  else
    group:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_textColor(Color.white)
  end
end
def.method().UpdateShopItemsState = function(self)
  local requirements = NPCShopModule.Instance():GetTaskRequirements()
  local bg = self.m_panel:FindDirect("Img_Bg0")
  local gridTemplate = bg:FindDirect("Img_Bg1/Img_BgItems/Scroll View_Items/Grid_Items")
  for i = 1, #self._itemList do
    local template = gridTemplate:GetChild(i - 1)
    local bRequire = false
    local itemId = self._itemList[i]
    if nil ~= requirements[itemId] then
      bRequire = true
    end
    template:FindDirect("Img_BgIcon/Img_Sign"):SetActive(bRequire)
  end
end
def.method().FillItemSelectFromNPCService = function(self)
  local bHaveRequire = NPCShopModule.Instance():GetIsHaveRequire()
  local itemSelectIndex = 1
  local itemRequireNum = 1
  if nil ~= self._curSelectItem and nil ~= self._curSelectItem.index then
    itemSelectIndex = self._curSelectItem.index
  end
  if bHaveRequire then
    local requirements = NPCShopModule.Instance():GetTaskRequirements()
    for i = 1, #self._itemList do
      local itemId = self._itemList[i]
      if nil ~= requirements[itemId] then
        itemSelectIndex = i
        itemRequireNum = requirements[itemId]
        break
      end
    end
  end
  self._bIsByTask = false
  self._indexByTask = -1
  self._curSelectItem = {}
  self._curSelectItem.index = itemSelectIndex
  self._curSelectItem.requireId = self._itemList[itemSelectIndex]
  self._curSelectItem.requireNum = itemRequireNum
  self:FillItemSelectDetail(itemSelectIndex)
  self:MoveToNeedIndex(itemSelectIndex)
  self:SetItemSelectConst(itemSelectIndex, itemRequireNum)
end
def.method().FillItemSelectFromTask = function(self)
  local taskInterfaceInstance = TaskInterface.Instance()
  local RequirementID = 0
  local NeedCount = 0
  local itemSelectIndex = 1
  local requirement = NPCShopModule.Instance():GetCurRequirementByTask()
  for k, v in pairs(requirement) do
    RequirementID = k
    NeedCount = v
    if v <= 0 then
      NeedCount = 1
    end
  end
  for i = 1, #self._itemList do
    if RequirementID == self._itemList[i] then
      itemSelectIndex = i
      break
    end
  end
  self._bIsByTask = true
  self._indexByTask = itemSelectIndex
  self._curSelectItem = {}
  self._curSelectItem.index = itemSelectIndex
  self._curSelectItem.requireId = self._itemList[itemSelectIndex]
  self._curSelectItem.requireNum = NeedCount
  self:FillItemSelectDetail(itemSelectIndex)
  self:MoveToNeedIndex(itemSelectIndex)
  self:SetItemSelectConst(itemSelectIndex, NeedCount)
end
def.method("number").FillItemSelectDetail = function(self, index)
  local itemBase = ItemUtils.GetItemBase(self._itemList[index])
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local detail = bg:FindDirect("Img_BgDetail")
  detail:FindDirect("Label_DetailName"):GetComponent("UILabel"):set_text(itemBase.name)
  local iconSprite = detail:FindDirect("Img_BgIconDetail/Img_IconDetail"):GetComponent("UITexture")
  GUIUtils.FillIcon(iconSprite, itemBase.icon)
  local descStr = itemBase.desc
  if NPCShopModule.SERVICEID_CAOYAO == NPCShopModule.Instance()._serviceId then
    local effectDesc = NPCShopUtils.GetMedecineItemDesc(self._itemList[index])
    if effectDesc ~= "" then
      descStr = descStr .. "\n" .. effectDesc
    end
  end
  detail:FindDirect("Label_Detail"):GetComponent("UILabel"):set_text(descStr)
  local integer, _ = math.modf(self._itemList[index] * 1.0E-5)
  if tostring(integer) == textRes.NPCStore[25] or tostring(integer) == textRes.NPCStore[26] then
    local level = itemBase.useLevel
    if tostring(integer) == textRes.NPCStore[26] then
      level = NPCShopUtils.GetEquipMaterialItemLevel(self._itemList[index])
    end
    detail:FindDirect("Label_DetailLv"):SetActive(true)
    local strLv = level .. textRes.NPCStore[27]
    detail:FindDirect("Label_DetailLv"):GetComponent("UILabel"):set_text(strLv)
    detail:FindDirect("Label_DetailType"):SetActive(true)
    detail:FindDirect("Label_DetailType"):GetComponent("UILabel"):set_text(itemBase.itemTypeName)
  else
    detail:FindDirect("Label_DetailLv"):SetActive(false)
    detail:FindDirect("Label_DetailType"):SetActive(false)
  end
  local gridTemplate = bg:FindDirect("Img_BgItems/Scroll View_Items/Grid_Items")
  local itemSale = gridTemplate:GetChild(index - 1)
  itemSale:GetComponent("UIToggle"):set_isChecked(true)
end
def.method("number").OnItemSelect = function(self, index)
  self:FillItemSelectDetail(index)
  local requirements = NPCShopModule.Instance():GetTaskRequirements()
  local needCount = 1
  local itemId = self._itemList[index]
  if nil ~= requirements[itemId] then
    needCount = requirements[itemId]
  end
  if self._indexByTask == index then
    self._bIsByTask = true
  else
    self._bIsByTask = false
  end
  self._curSelectItem = {}
  self._curSelectItem.index = index
  self._curSelectItem.requireId = self._itemList[index]
  self._curSelectItem.requireNum = needCount
  self:SetItemSelectConst(index, needCount)
end
def.method().OnBuyClick = function(self)
  local npcId = NPCShopModule.Instance():GetNpcId()
  local serviceId = NPCShopModule.Instance():GetServiceId()
  local itemId = self._curSelectItem.requireId
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local group = bg:FindDirect("Group_Buy")
  local itemCount = group:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel"):get_text()
  local clientGold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local clientSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local needMoney = NPCShopUtils.GetItemSellNum(itemId) * itemCount
  if clientSilver:lt(needMoney) then
    local ComfirmDlg = require("GUI.CommonConfirmDlg")
    local callback = function(id, tag)
      if id == 1 then
        GoToBuySilver(false)
      end
    end
    ComfirmDlg.ShowConfirm("", textRes.NPCStore[28], callback, nil)
  else
    local p = require("netio.protocol.mzm.gsp.npc.CBuyItemReq").new(npcId, serviceId, itemId, itemCount, clientGold, clientSilver)
    gmodule.network.sendProtocol(p)
  end
end
def.method().SuccessedBuyItem = function(self)
  local have = ItemModule.Instance():GetItemCountById(self._curSelectItem.requireId)
  if have >= self._curSelectItem.requireNum then
    local requirement = NPCShopModule.Instance():GetCurRequirementByTask()
    for k, v in pairs(requirement) do
      if v > 0 then
        NPCShopModule.Instance():UpdateCurRequirementsByTask(self._curSelectItem.requireId)
      end
    end
    if self._bIsByTask and NPCShopModule.Instance():IsCurRequirementsByTaskOver() then
      self:Hide()
      return
    end
    NPCShopModule.Instance():RemoveRequirement(self._curSelectItem.requireId)
    NPCShopModule.Instance():UpdateRequirement()
    self:FillItemSelectFromNPCService()
    self:UpdateShopItemsState()
  else
    self:SetItemSelectConst(self._curSelectItem.index, self._curSelectItem.requireNum)
  end
end
def.static("number", "table").OnDigitalKeyboardCallback = function(value, tag)
  local self = tag.self
  self.digitalEntered = value
  self:UpdateEnteredValue()
  self:SetEnteredValue()
end
def.method().UpdateEnteredValue = function(self)
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  if self.digitalEntered > self._maxBuyNum then
    Toast(string.format(textRes.NPCStore[22], self._maxBuyNum))
    self.digitalEntered = self._maxBuyNum
    CommonDigitalKeyboard.Instance():SetEnteredValue(self.digitalEntered)
  elseif self.digitalEntered < 1 then
    Toast(textRes.NPCStore[21])
    self.digitalEntered = 1
    CommonDigitalKeyboard.Instance():SetEnteredValue(0)
  else
    CommonDigitalKeyboard.Instance():SetEnteredValue(self.digitalEntered)
  end
end
def.method().SetEnteredValue = function(self)
  local bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local group = bg:FindDirect("Group_Buy")
  group:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel"):set_text(self.digitalEntered)
  self:SetItemSelectConst(self._curSelectItem.index, self.digitalEntered)
end
def.method().OnSetNumBtnClick = function(self)
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  CommonDigitalKeyboard.Instance():ShowPanelEx(-1, NpcShopDlg.OnDigitalKeyboardCallback, {self = self})
  CommonDigitalKeyboard.Instance():SetPos(-26, -1)
end
def.method().OnMinusNumClick = function(self)
  if self.digitalEntered - 1 < 1 then
    Toast(textRes.NPCStore[21])
    self.digitalEntered = 1
  else
    self.digitalEntered = self.digitalEntered - 1
  end
  self:SetEnteredValue()
end
def.method().OnAddNumClick = function(self)
  if self.digitalEntered + 1 > self._maxBuyNum then
    Toast(string.format(textRes.NPCStore[22], self._maxBuyNum))
    self.digitalEntered = self._maxBuyNum
  else
    self.digitalEntered = self.digitalEntered + 1
  end
  self:SetEnteredValue()
end
def.method("number").OnIncPropTimer = function(self, dt)
  self.pressedTime = self.pressedTime + dt
  if self.pressedTime < 0.5 then
    return
  end
  local interval = 0.1
  self.incPropTime = self.incPropTime + dt
  if interval <= self.incPropTime then
    self:OnAddNumClick()
    self.incPropTime = self.incPropTime - interval
  end
end
def.method("number").OnDecPropTimer = function(self, dt)
  self.pressedTime = self.pressedTime + dt
  if self.pressedTime < 0.5 then
    return
  end
  local interval = 0.1
  self.decPropTime = self.decPropTime + dt
  if interval <= self.decPropTime then
    self:OnMinusNumClick()
    self.decPropTime = self.decPropTime - interval
  end
end
def.method("string", "boolean").ItemNumOnPress = function(self, id, state)
  if id == "Btn_Add" then
    if state == true then
      self.pressedTime = 0
      Timer:RegisterIrregularTimeListener(self.OnIncPropTimer, self)
    else
      Timer:RemoveIrregularTimeListener(self.OnIncPropTimer)
      self.pressedTime = 0
    end
  elseif id == "Btn_Minus" then
    if state == true then
      self.pressedTime = 0
      Timer:RegisterIrregularTimeListener(self.OnDecPropTimer, self)
    else
      Timer:RemoveIrregularTimeListener(self.OnDecPropTimer)
      self.pressedTime = 0
    end
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  self:ItemNumOnPress(id, state)
end
def.method("number").MoveToNeedIndex = function(self, index)
  local num = math.abs(index - self.lastNeedIndex)
  if num > 8 then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if self.m_panel and false == self.m_panel.isnil then
        local bg = self.m_panel:FindDirect("Img_Bg0")
        local gridTemplate = bg:FindDirect("Img_Bg1/Img_BgItems/Scroll View_Items/Grid_Items")
        local group = gridTemplate:GetChild(index - 1)
        local uiScrollView = bg:FindDirect("Img_Bg1/Img_BgItems/Scroll View_Items"):GetComponent("UIScrollView")
        uiScrollView:DragToMakeVisible(group.transform, 10)
      end
    end)
  end
  self.lastNeedIndex = index
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if nil ~= string.find(id, "Img_BgItem0") then
    local indexStr = string.sub(id, string.len("Img_BgItem0") + 1)
    local index = tonumber(indexStr)
    self:OnItemSelect(index)
  elseif "Btn_Buy" == id then
    self:OnBuyClick()
  elseif "Btn_Close" == id then
    self:Hide()
  elseif "Label_Num" == id then
    self:OnSetNumBtnClick()
  elseif "Btn_Minus" == id then
    self:OnMinusNumClick()
  elseif "Btn_Add" == id then
    self:OnAddNumClick()
  elseif "Modal" == id then
    self:Hide()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
NpcShopDlg.Commit()
return NpcShopDlg

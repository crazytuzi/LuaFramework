local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TabNode = require("GUI.TabNode")
local TreasureNode = Lplus.Extend(TabNode, "TreasureNode")
local Vector = require("Types.Vector")
local MallData = require("Main.Mall.data.MallData")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local MallUtility = require("Main.Mall.MallUtility")
local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
local PageEnum = require("consts.mzm.gsp.mall.confbean.PageEnum")
local GUIUtils = require("GUI.GUIUtils")
local MallPanel = Lplus.ForwardDeclare("MallPanel")
local ECUIModel = require("Model.ECUIModel")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local FashionUtils = require("Main.Fashion.FashionUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = TreasureNode.define
def.field(MallData).data = nil
def.field("table").uiTbl = nil
def.field("number").selectMallType = 0
def.field("number").selectItemId = 0
def.field("number").digitalEntered = 1
def.field("number").incPropTime = 0
def.field("number").decPropTime = 0
def.field("number").pressedTime = 0
def.field("table").model = nil
def.field("number").modelTryFashionId = 0
def.field("boolean").isDrag = false
local TabInfos = {
  [MallType.DAILY_LIMIT_MALL] = {
    spriteName = "Btn Activity"
  }
}
local instance
def.static("=>", TreasureNode).Instance = function()
  if instance == nil then
    instance = TreasureNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.data = MallData.Instance()
  self.selectMallType = MallType.PRECIOUS_MALL
  self.selectItemId = 0
end
def.override().OnShow = function(self)
  self.uiTbl = MallUtility.FillTreasureNodeUI(self.uiTbl, self.m_node)
  self:FillMallItemsList(true)
  Event.RegisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.LimitItemNumChanged, TreasureNode.UpdateLimitNum)
  Event.RegisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.SucceedBuyItem, TreasureNode.SucceedBuyItem)
  Event.RegisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateItems, TreasureNode.UpdateItems)
  Event.RegisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateSelectedInfo, TreasureNode.UpdateSelectedInfo)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, TreasureNode.OnMoneyChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, TreasureNode.OnMoneyChanged)
end
def.override().OnHide = function(self)
  self:Clear()
  self:DestroyRelateModel()
  Event.UnregisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.LimitItemNumChanged, TreasureNode.UpdateLimitNum)
  Event.UnregisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.SucceedBuyItem, TreasureNode.SucceedBuyItem)
  Event.UnregisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateItems, TreasureNode.UpdateItems)
  Event.UnregisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateSelectedInfo, TreasureNode.UpdateSelectedInfo)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, TreasureNode.OnMoneyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, TreasureNode.OnMoneyChanged)
end
def.method().Clear = function(self)
  self.digitalEntered = 1
  self.incPropTime = 0
  self.decPropTime = 0
  self.pressedTime = 0
  self.modelTryFashionId = 0
end
def.static("table", "table").UpdateLimitNum = function(params, tbl)
  local self = instance
  if self.selectMallType == MallType.LIMIT_MALL or self.selectMallType == MallType.DAILY_LIMIT_MALL then
    self:FillSelectItemInfo()
    local mallList = self.data:GetAllMallItemsList()
    local mallItemList = {}
    for k, v in pairs(mallList) do
      local pageType = MallUtility.GetPageTypeByMallType(v.malltype)
      if pageType == PageEnum.PAGE_1 and v.malltype == self.selectMallType then
        mallItemList = v.itemid2count
      end
    end
    self:FillMallItems(mallItemList, false)
  end
end
def.static("table", "table").SucceedBuyItem = function(params, tbl)
  local self = instance
  self.incPropTime = 0
  self.decPropTime = 0
  self.pressedTime = 0
  self:FillSelectItemInfo()
end
def.static("table", "table").UpdateItems = function(params, tbl)
  local self = instance
  self:FillSelectItemInfo()
  local mallList = self.data:GetAllMallItemsList()
  local mallItemList = {}
  for k, v in pairs(mallList) do
    local pageType = MallUtility.GetPageTypeByMallType(v.malltype)
    if pageType == PageEnum.PAGE_1 and v.malltype == self.selectMallType then
      mallItemList = v.itemid2count
    end
  end
  self:FillMallItemList(mallItemList)
  self.selectItemId = 0
  self.digitalEntered = 1
  self:FillSelectItemInfo()
end
def.static("table", "table").UpdateSelectedInfo = function(p1, p2)
  if instance then
    instance:FillSelectItemInfo()
  end
end
def.static("table", "table").OnMoneyChanged = function(p1, p2)
  local self = instance
  if self.selectMallType == MallType.FASHION_DRESS then
    self:FillSelectFashionPice()
  else
    self:FillSelectItemPrice()
  end
end
def.method("boolean").FillMallItemsList = function(self, bFillBtn)
  self.digitalEntered = 1
  self.incPropTime = 0
  self.decPropTime = 0
  self.pressedTime = 0
  local mallList = self.data:GetAllMallItemsList()
  local btnList = {}
  local mallItemList = {}
  for k, v in pairs(mallList) do
    local pageType = MallUtility.GetPageTypeByMallType(v.malltype)
    if pageType == PageEnum.PAGE_1 then
      table.insert(btnList, v.malltype)
      if v.malltype == self.selectMallType then
        mallItemList = v.itemid2count
      end
    end
  end
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FASHION_DRESS) then
    for idx, mallType in ipairs(btnList) do
      if mallType == MallType.FASHION_DRESS then
        table.remove(btnList, idx)
        break
      end
    end
  end
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_DAILY_LIMIT_MALL) then
    for idx, mallType in ipairs(btnList) do
      if mallType == MallType.DAILY_LIMIT_MALL then
        table.remove(btnList, idx)
        break
      end
    end
  end
  local TrumpetMgr = require("Main.Chat.Trumpet.TrumpetMgr")
  if not TrumpetMgr.Instance():IsFeatureOpen(false) then
    do
      local newMallList = {}
      for k, v in pairs(mallItemList) do
        newMallList[k] = v
      end
      TrumpetMgr.Instance():Foreach(function(itemid)
        newMallList[itemid] = nil
      end)
      mallItemList = newMallList
    end
  else
  end
  table.sort(btnList, function(a, b)
    local cfgA = MallUtility.GetMallInfo(a)
    local cfgB = MallUtility.GetMallInfo(b)
    return cfgA.sort < cfgB.sort
  end)
  if bFillBtn then
    self:FillMallButtons(btnList)
  end
  self:FillMallItemList(mallItemList)
  self:FillSelectItemInfo()
end
def.method("table").FillMallButtons = function(self, btnList)
  local uiList = self.uiTbl.List_Class:GetComponent("UIList")
  uiList:set_itemCount(#btnList + 1)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local buttons = uiList:get_children()
  for i = 1, #btnList do
    local btnUI = buttons[i]
    local btnInfo = btnList[i]
    self:FillBtnInfo(btnUI, i, btnInfo)
  end
  local btnJifen = buttons[#btnList + 1]
  btnJifen.name = "Btn_Jifen"
  btnJifen:GetComponent("UIToggle").group = 0
  local labelJifen = btnJifen:FindDirect(string.format("Label_%d", #btnList + 1)):GetComponent("UILabel")
  if labelJifen then
    labelJifen:set_text(textRes.Mall[7])
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("userdata", "number", "number").FillBtnInfo = function(self, btnUI, index, btnInfo)
  local btnName = btnUI:FindDirect(string.format("Label_%d", index)):GetComponent("UILabel")
  local btnType = btnUI:FindDirect(string.format("Label_Type_%d", index))
  local tabInfo = TabInfos[btnInfo]
  if tabInfo and tabInfo.spriteName then
    local btnSprite = btnUI:GetComponent("UISprite")
    btnSprite:set_spriteName(tabInfo.spriteName)
  end
  local tbl = MallUtility.GetMallInfo(btnInfo)
  if tbl ~= nil then
    btnName:set_text(tbl.mallName)
  end
  btnType:SetActive(false)
  btnType:GetComponent("UILabel"):set_text(btnInfo)
  if btnInfo == MallType.DAILY_LIMIT_MALL then
    btnUI:FindDirect(string.format("Img_Red_%d", index)):SetActive(MallData.Instance():isShowDailyPurchaseRedPoint())
  end
  if self.selectMallType == btnInfo then
    btnUI:GetComponent("UIToggle"):set_value(true)
  else
    btnUI:GetComponent("UIToggle"):set_value(false)
  end
end
def.method("table").FillMallItemList = function(self, mallItemList)
  local count = 0
  for k, v in pairs(mallItemList) do
    count = count + 1
  end
  self:ClearItemObjects()
  GameUtil.AddGlobalTimer(0.01, true, function()
    if self.m_base.m_panel and false == self.m_base.m_panel.isnil then
      self:CreateItemObjects(count)
      self:FillMallItems(mallItemList, false)
      self:MoveToSelectItemId()
    end
  end)
end
def.method().ClearItemObjects = function(self)
  local gridTemplate = self.uiTbl.Grid_Items
  local itemTemplate = gridTemplate:FindDirect("Img_BgItem")
  local gridComponent = gridTemplate:GetComponent("UIGrid")
  itemTemplate:SetActive(false)
  local gridItemCount = gridComponent:GetChildListCount()
  local gridChildList = gridComponent:GetChildList()
  for i = 1, gridItemCount do
    GameObject.Destroy(gridChildList[i].gameObject)
    gridChildList[i] = nil
  end
end
def.method("number").CreateItemObjects = function(self, curItemListNum)
  local gridTemplate = self.uiTbl.Grid_Items
  local itemTemplate = gridTemplate:FindDirect("Img_BgItem")
  itemTemplate:SetActive(false)
  for j = 1, curItemListNum do
    MallUtility.AddLastGroup(j, "Img_BgItem%d", gridTemplate, itemTemplate)
  end
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not gridTemplate.isnil then
      local uiGrid = gridTemplate:GetComponent("UIGrid")
      uiGrid:Reposition()
    end
    if self.m_base.m_panel and false == self.m_base.m_panel.isnil then
      self.uiTbl["Scroll View_Items"]:GetComponent("UIScrollView"):ResetPosition()
    end
    self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
  end)
end
def.method("table", "boolean").FillMallItems = function(self, mallItemList, bOnlyUpdateNum)
  local gridTemplate = self.uiTbl.Grid_Items
  local sortTbl = {}
  for k, v in pairs(mallItemList) do
    local key = string.format("%d_%d", k, self.selectMallType)
    local sort = MallUtility.GetItemSort(key)
    table.insert(sortTbl, {sort = sort, id = k})
  end
  table.sort(sortTbl, function(a, b)
    return a.sort < b.sort
  end)
  for k, v in ipairs(sortTbl) do
    local itemUI = gridTemplate:FindDirect(string.format("Img_BgItem%d", k))
    self:FillItemInfo(itemUI, k, v.id, self.selectMallType == MallType.LIMIT_MALL, bOnlyUpdateNum)
  end
end
def.method("userdata", "number", "number", "boolean", "boolean").FillItemInfo = function(self, itemUI, index, itemId, half, bOnlyUpdateNum)
  local label = itemUI:FindDirect("Img_BgIcon/Label")
  local num = self.data:GetItemLeft(self.selectMallType, itemId)
  if num ~= -1 then
    label:SetActive(true)
    label:GetComponent("UILabel"):set_text(num)
  else
    label:SetActive(false)
  end
  if bOnlyUpdateNum then
    return
  end
  local Label_Name = itemUI:FindDirect("Label_Name"):GetComponent("UILabel")
  local Label_ItemId = itemUI:FindDirect("Label_ItemId")
  local Label_Price = itemUI:FindDirect("Img_BgPrice/Label_Price"):GetComponent("UILabel")
  local Img_Icon = itemUI:FindDirect("Img_BgIcon/Img_Icon"):GetComponent("UITexture")
  local itemBase = ItemUtils.GetItemBase(itemId)
  Label_ItemId:SetActive(false)
  Label_ItemId:GetComponent("UILabel"):set_text(itemId)
  Label_Name:set_text(itemBase.name)
  local key = string.format("%d_%d", itemId, self.selectMallType)
  local price = MallUtility.GetItemPrice(key)
  Label_Price:set_text(price)
  GUIUtils.FillIcon(Img_Icon, itemBase.icon)
  local edge = itemUI:FindDirect("Img_BgIcon"):GetComponent("UISprite")
  edge:set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
  if itemId == self.selectItemId then
    itemUI:GetComponent("UIToggle"):set_value(true)
  else
    itemUI:GetComponent("UIToggle"):set_value(false)
  end
  local halfTag = itemUI:FindDirect("Img_HalfPrize")
  if half then
    halfTag:SetActive(true)
  else
    halfTag:SetActive(false)
  end
end
def.method().FillSelectItemInfo = function(self)
  if self.selectItemId == 0 then
    self.uiTbl.Group_NoChoice:SetActive(true)
    local Group_Buy = self.uiTbl.Group_NoChoice:FindDirect("Group_Buy")
    local num = Group_Buy:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel")
    local cost = Group_Buy:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel")
    local have = Group_Buy:FindDirect("Label_Have/Img_BgHave/Label_HaveNum"):GetComponent("UILabel")
    local yuanbao = ItemModule.Instance():GetAllYuanBao()
    num:set_text(0)
    cost:set_text(0)
    have:set_text(Int64.tostring(yuanbao))
    self.uiTbl.Group_ItemInfo:SetActive(false)
    self.uiTbl.Group_Fashion:SetActive(false)
  else
    self.uiTbl.Group_NoChoice:SetActive(false)
    if self.selectMallType == MallType.FASHION_DRESS then
      self.uiTbl.Group_ItemInfo:SetActive(false)
      self.uiTbl.Group_Fashion:SetActive(true)
      self:FillSelectFashionBasic()
      self:FillSelectFashionPice()
    else
      self.uiTbl.Group_Fashion:SetActive(false)
      self.uiTbl.Group_ItemInfo:SetActive(true)
      self:FillSelectItemBasic()
      self:FillSelectItemPrice()
    end
  end
end
def.method().FillSelectItemBasic = function(self)
  local itemBase = ItemUtils.GetItemBase(self.selectItemId)
  local Label_DetailName = self.uiTbl.Group_Detail:FindDirect("Img_Title/Label_DetailName"):GetComponent("UILabel")
  local Label_DetailType = self.uiTbl.Group_Detail:FindDirect("Img_Title/Label_DetailType"):GetComponent("UILabel")
  local Label_DetailContent = self.uiTbl.Group_Detail:FindDirect("Label_DetailContent"):GetComponent("UILabel")
  Label_DetailName:set_text(itemBase.name)
  Label_DetailType:set_text("[01b35b]" .. textRes.Item[8002] .. itemBase.itemTypeName)
  local desc = itemBase.desc
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.FABAO_LONGJING_ITEM then
    local EquipModule = require("Main.Equip.EquipModule")
    local longjingCfg = ItemUtils.GetLongJingItem(self.selectItemId)
    local attrIds = longjingCfg.attrIds
    local attrValues = longjingCfg.attrValues
    local strTable = {}
    local attrNum = #attrIds
    for i = 1, attrNum do
      local attrId = attrIds[i]
      local attrValue = attrValues[i]
      if attrId and 0 ~= attrId and attrValue then
        local attrName = require("Main.Fabao.FabaoUtils").GetFabaoProName(attrId)
        table.insert(strTable, string.format("%s + %d\n", attrName, attrValue))
      end
    end
    desc = desc .. "\n" .. textRes.Item[8312] .. strTable
  end
  Label_DetailContent:set_text(desc)
  local PriceInfo = self.uiTbl.Group_Detail:FindDirect("PriceInfo")
  if self.selectMallType == MallType.LIMIT_MALL then
    PriceInfo:SetActive(true)
    local keyOld = string.format("%d_%d", self.selectItemId, MallType.PRECIOUS_MALL)
    local priceOld = MallUtility.GetItemPrice(keyOld)
    if priceOld == 0 then
      keyOld = string.format("%d_%d", self.selectItemId, MallType.FUNCTION_MALL)
      priceOld = MallUtility.GetItemPrice(keyOld)
    end
    local keyNew = string.format("%d_%d", self.selectItemId, MallType.LIMIT_MALL)
    local priceNew = MallUtility.GetItemPrice(keyNew)
    local Group_OldPrice = PriceInfo:FindDirect("Group_OldPrice")
    Group_OldPrice:FindDirect("Label2"):GetComponent("UILabel"):set_text(priceOld)
    local Group_NewPrice = PriceInfo:FindDirect("Group_NewPrice")
    Group_NewPrice:FindDirect("Label2"):GetComponent("UILabel"):set_text(priceNew)
    local mallInfo = MallUtility.GetMallInfo(self.selectMallType)
    local refreshStr = MallUtility.GetRefeshTimeStr(mallInfo.refreshtime)
    PriceInfo:FindDirect("Label_Refresh"):GetComponent("UILabel"):set_text(refreshStr)
    local num = self.data:GetItemLeft(self.selectMallType, self.selectItemId)
    PriceInfo:FindDirect("Label_LeftNum"):GetComponent("UILabel"):set_text(num)
    PriceInfo:FindDirect("Label_LeftItem"):GetComponent("UILabel"):set_text(textRes.Mall[100])
  elseif self.selectMallType == MallType.DAILY_LIMIT_MALL then
    PriceInfo:SetActive(true)
    local key = string.format("%d_%d", self.selectItemId, MallType.DAILY_LIMIT_MALL)
    local oldPrice = MallUtility.GetItemOldPrice(key)
    local nowPrice = MallUtility.GetItemPrice(key)
    local Group_OldPrice = PriceInfo:FindDirect("Group_OldPrice")
    Group_OldPrice:FindDirect("Label2"):GetComponent("UILabel"):set_text(oldPrice)
    local Group_NewPrice = PriceInfo:FindDirect("Group_NewPrice")
    Group_NewPrice:FindDirect("Label2"):GetComponent("UILabel"):set_text(nowPrice)
    local mallInfo = MallUtility.GetMallInfo(self.selectMallType)
    local refreshStr = MallUtility.GetRefeshTimeStr(mallInfo.refreshtime)
    PriceInfo:FindDirect("Label_Refresh"):GetComponent("UILabel"):set_text(refreshStr)
    local num = self.data:GetItemLeft(self.selectMallType, self.selectItemId)
    PriceInfo:FindDirect("Label_LeftNum"):GetComponent("UILabel"):set_text(num)
    PriceInfo:FindDirect("Label_LeftItem"):GetComponent("UILabel"):set_text(textRes.Mall[101])
  else
    PriceInfo:SetActive(false)
  end
end
def.method().FillSelectItemPrice = function(self)
  local Label_Num = self.uiTbl.Group_Buy:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel")
  local Label_CostNum = self.uiTbl.Group_Buy:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel")
  Label_Num:set_text(self.digitalEntered)
  local key = string.format("%d_%d", self.selectItemId, self.selectMallType)
  local price = MallUtility.GetItemPrice(key)
  local cost = price * self.digitalEntered
  Label_CostNum:set_text(cost)
  local yuanbao = ItemModule.Instance():GetAllYuanBao()
  local Label_HaveNum = self.uiTbl.Group_Buy:FindDirect("Label_Have/Img_BgHave/Label_HaveNum"):GetComponent("UILabel")
  Label_HaveNum:set_text(Int64.tostring(yuanbao))
  if yuanbao:lt(cost) then
    Label_CostNum:set_textColor(Color.red)
  else
    Label_CostNum:set_textColor(Color.white)
  end
end
def.method().FillSelectFashionBasic = function(self)
  local itemBase = ItemUtils.GetItemBase(self.selectItemId)
  local fashionName = self.uiTbl.Group_Fashion:FindDirect("Label"):GetComponent("UILabel")
  fashionName:set_text(itemBase.name)
  local fashionItem = FashionUtils.GetFashionItemByUnlockItemId(self.selectItemId)
  if fashionItem then
    self:SetFashionInfoDisplay(true)
    if not self:ExistHeroModel() then
      self:CreateHeroModel()
    else
      self:TryFashion()
    end
  else
    self:SetFashionInfoDisplay(false)
    self:FillNotFashionItem(itemBase)
  end
end
def.method("boolean").SetFashionInfoDisplay = function(self, fashion)
  self.uiTbl.Group_Fashion:FindDirect("Model"):SetActive(fashion)
  self.uiTbl.Group_Fashion:FindDirect("Bg_ModelDi"):SetActive(fashion)
  self.uiTbl.Group_Fashion:FindDirect("Btn_Huan"):SetActive(fashion)
  self.uiTbl.Group_Fashion:FindDirect("Group_Detail"):SetActive(not fashion)
end
def.method("table").FillNotFashionItem = function(self, itemBase)
  local fashionType = self.uiTbl.Group_Fashion:FindDirect("Group_Detail/Label_DetailType"):GetComponent("UILabel")
  fashionType:set_text(itemBase.itemTypeName)
  local descLbl = self.uiTbl.Group_Fashion:FindDirect("Group_Detail/Label_DetailContent"):GetComponent("UILabel")
  descLbl:set_text(itemBase.desc)
end
def.method().FillSelectFashionPice = function(self)
  local Label_CostNum = self.uiTbl.Group_Fashion:FindDirect("Group_Buy/Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel")
  local key = string.format("%d_%d", self.selectItemId, self.selectMallType)
  local cost = MallUtility.GetItemPrice(key)
  Label_CostNum:set_text(cost)
  local yuanbao = ItemModule.Instance():GetAllYuanBao()
  local Label_HaveNum = self.uiTbl.Group_Fashion:FindDirect("Group_Buy/Label_Have/Img_BgHave/Label_HaveNum"):GetComponent("UILabel")
  Label_HaveNum:set_text(Int64.tostring(yuanbao))
  if yuanbao:lt(cost) then
    Label_CostNum:set_textColor(Color.red)
  else
    Label_CostNum:set_textColor(Color.white)
  end
end
def.method("=>", "boolean").ExistHeroModel = function(self)
  return self.model ~= nil
end
def.method().CreateHeroModel = function(self)
  local fashionModel = self.uiTbl.Group_Fashion:FindDirect("Model")
  local uiModel = fashionModel:GetComponent("UIModel")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
  if self.model ~= nil then
    self.model:Destroy()
  end
  self.model = ECUIModel.new(modelId)
  self.model.m_bUncache = true
  local modelInfo = self:GetInitModelInfo()
  self.model:AddOnLoadCallback("TreasureNode", function()
    if self.m_node == nil or self.m_node.isnil then
      self.model:Destroy()
      self.model = nil
      return
    end
    if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil or uiModel == nil or uiModel.isnil then
      return
    end
    uiModel.modelGameObject = self.model.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end)
  _G.LoadModel(self.model, modelInfo, 0, 0, 180, false, false)
end
def.method("=>", "table").GetInitModelInfo = function(self)
  local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
  if modelInfo == nil then
    return nil
  end
  local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
  local fakeModelInfo = _G.CloneModelInfo(modelInfo)
  fakeModelInfo.extraMap[ModelInfo.EXTERIOR_ID] = 0
  local fashionItem = FashionUtils.GetFashionItemByUnlockItemId(self.selectItemId)
  if fashionItem then
    local dyeColor = FashionUtils.GetFashionDyeColor(fashionItem.id)
    fakeModelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = fashionItem.id
    fakeModelInfo.extraMap[ModelInfo.HAIR_COLOR_ID] = dyeColor.hairId
    fakeModelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID] = dyeColor.clothId
    self.modelTryFashionId = fashionItem.id
  end
  return fakeModelInfo
end
def.method().TryFashion = function(self)
  if self.model ~= nil then
    local fashionItem = FashionUtils.GetFashionItemByUnlockItemId(self.selectItemId)
    if fashionItem then
      self:PutOnFashion(fashionItem.id)
    end
  end
end
def.method("number").PutOnFashion = function(self, id)
  FashionUtils.SetFashion(self.model, id)
  self.modelTryFashionId = id
end
def.method().SwapHeroModel = function(self)
  if self.model ~= nil then
    local equipFashionId = self.modelTryFashionId
    local fashionItem = FashionUtils.GetFashionItemByUnlockItemId(self.selectItemId)
    local fashionData = require("Main.Fashion.FashionData").Instance()
    if equipFashionId == fashionItem.id then
      self:PutOnFashion(fashionData.currentFashionId)
    else
      self:PutOnFashion(fashionItem.id)
    end
  end
end
def.method("number").OnItemSelect = function(self, itemId)
  self.selectItemId = itemId
  self.digitalEntered = 1
  self:FillSelectItemInfo()
end
def.method().MoveToSelectItemId = function(self)
  local gridTemplate = self.uiTbl.Grid_Items
  local gridComponent = gridTemplate:GetComponent("UIGrid")
  local gridItemCount = gridComponent:GetChildListCount()
  for i = 1, gridItemCount do
    local itemUI = gridTemplate:GetChild(i)
    local labelItemId = tonumber(itemUI:FindDirect("Label_ItemId"):GetComponent("UILabel"):get_text())
    if labelItemId == self.selectItemId then
      self:MoveToSelectIndex(i)
    end
  end
end
def.method("number").MoveToSelectIndex = function(self, index)
  if index > 8 then
    GameUtil.AddGlobalLateTimer(0.1, true, function()
      if self.m_base.m_panel and false == self.m_base.m_panel.isnil then
        local gridTemplate = self.uiTbl.Grid_Items
        local group = gridTemplate:GetChild(index)
        local uiScrollView = self.uiTbl["Scroll View_Items"]:GetComponent("UIScrollView")
        uiScrollView:DragToMakeVisible(group.transform, 8)
      end
    end)
  end
end
def.method("number").SelectItem = function(self, itemId)
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self.m_base.m_panel and false == self.m_base.m_panel.isnil then
      local gridTemplate = self.uiTbl.Grid_Items
      local gridComponent = gridTemplate:GetComponent("UIGrid")
      local gridItemCount = gridComponent:GetChildListCount()
      for i = 1, gridItemCount do
        local itemUI = gridTemplate:GetChild(i)
        local labelItemId = tonumber(itemUI:FindDirect("Label_ItemId"):GetComponent("UILabel"):get_text())
        if labelItemId == itemId then
          itemUI:GetComponent("UIToggle"):set_value(true)
          self:MoveToSelectIndex(i)
        else
          itemUI:GetComponent("UIToggle"):set_value(false)
        end
      end
    end
  end)
  self.selectItemId = itemId
  self.digitalEntered = 1
  self:FillSelectItemInfo()
end
def.method().OnSetNumBtnClick = function(self)
  if self.selectItemId == 0 then
    Toast(textRes.Mall[5])
    return
  end
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  CommonDigitalKeyboard.Instance():ShowPanelEx(-1, TreasureNode.OnDigitalKeyboardCallback, {self = self})
  CommonDigitalKeyboard.Instance():SetPos(-26, -1)
end
def.static("number", "table").OnDigitalKeyboardCallback = function(value, tag)
  local self = tag.self
  self.digitalEntered = value
  self:UpdateEnteredValue()
  self:SetEnteredValue()
end
def.method().UpdateEnteredValue = function(self)
  local itemBase = ItemUtils.GetItemBase(self.selectItemId)
  local num = self.data:GetItemLeft(self.selectMallType, self.selectItemId)
  local max = itemBase.pilemax
  if num ~= -1 then
    max = num
  end
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  if max < self.digitalEntered then
    Toast(string.format(textRes.NPCStore[22], max))
    self.digitalEntered = max
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
  local Label_Num = self.uiTbl.Group_Buy:FindDirect("Label_NumBuy/Btn_Num/Label_Num"):GetComponent("UILabel")
  Label_Num:set_text(self.digitalEntered)
  self:FillSelectItemPrice()
end
def.method().OnMinusNumClick = function(self)
  if self.selectItemId == 0 then
    Toast(textRes.Mall[5])
    return
  end
  if self.digitalEntered - 1 < 1 then
    Toast(textRes.NPCStore[21])
    self.digitalEntered = 1
  else
    self.digitalEntered = self.digitalEntered - 1
  end
  self:SetEnteredValue()
end
def.method().OnAddNumClick = function(self)
  if self.selectItemId == 0 then
    Toast(textRes.Mall[5])
    return
  end
  local itemBase = ItemUtils.GetItemBase(self.selectItemId)
  local num = self.data:GetItemLeft(self.selectMallType, self.selectItemId)
  local max = itemBase.pilemax
  if num ~= -1 then
    max = num
  end
  if max < self.digitalEntered + 1 then
    Toast(string.format(textRes.NPCStore[22], max))
    self.digitalEntered = max
  else
    self.digitalEntered = self.digitalEntered + 1
  end
  self:SetEnteredValue()
end
def.override("string", "boolean").onPress = function(self, id, state)
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
def.static("number", "table").BuyYuanbaoCallback = function(i, tag)
  if i == 1 then
    local dlg = tag.id
    if dlg and dlg.m_panel and false == dlg.m_panel.isnil then
      MallPanel.Instance():SetToggleState(MallPanel.NodeId.PAY, true)
      MallPanel.Instance():SwitchTo(MallPanel.NodeId.PAY)
    end
  end
end
def.method().OnBuyClick = function(self)
  if IsCrossingServer() then
    ToastCrossingServerForbiden()
    return
  end
  if self.selectItemId == 0 then
    Toast(textRes.Mall[5])
    return
  end
  local key = string.format("%d_%d", self.selectItemId, self.selectMallType)
  local price = MallUtility.GetItemPrice(key)
  local cost = price * self.digitalEntered
  local yuanbao = ItemModule.Instance():GetAllYuanBao()
  if yuanbao:lt(cost) then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local tag = {id = self}
    CommonConfirmDlg.ShowConfirm("", textRes.Gang[59], TreasureNode.BuyYuanbaoCallback, tag)
    return
  end
  local yuanbao = ItemModule.Instance():GetAllYuanBao()
  if self.selectMallType == MallType.PRECIOUS_MALL then
    local p = require("netio.protocol.mzm.gsp.mall.CBuyPreciousItemReq").new(self.selectItemId, self.digitalEntered, yuanbao)
    gmodule.network.sendProtocol(p)
  elseif self.selectMallType == MallType.LIMIT_MALL then
    local p = require("netio.protocol.mzm.gsp.mall.CBuyLimitItemReq").new(self.selectItemId, self.digitalEntered, yuanbao)
    gmodule.network.sendProtocol(p)
  elseif self.selectMallType == MallType.FUNCTION_MALL then
    local p = require("netio.protocol.mzm.gsp.mall.CBuyFunctionItemReq").new(self.selectItemId, self.digitalEntered, yuanbao)
    gmodule.network.sendProtocol(p)
  elseif self.selectMallType == MallType.FASHION_DRESS then
    do
      local itemModule = ItemModule.Instance()
      local bindYuanbao = itemModule:getBindYuanBao()
      local cashaYuanbao = itemModule:getCashYuanBao()
      local function buyFashionItem(selectItemId, digitalEntered)
        local p = require("netio.protocol.mzm.gsp.mall.CBuyFashionDressItemReq").new(selectItemId, digitalEntered, yuanbao)
        gmodule.network.sendProtocol(p)
      end
      if Int64.gt(bindYuanbao, 0) then
        local bindYuanbaoNum = tonumber(bindYuanbao:tostring())
        local showBindYuanbaoNum = math.min(bindYuanbaoNum, cost)
        CommonConfirmDlg.ShowConfirmCoundDown("", string.format(textRes.Fashion[28], cost, showBindYuanbaoNum), "", "", 0, 10, function(selection, tag)
          if selection == 1 then
            buyFashionItem(self.selectItemId, self.digitalEntered)
          end
        end, nil)
      else
        buyFashionItem(self.selectItemId, self.digitalEntered)
      end
    end
  elseif self.selectMallType == MallType.DAILY_LIMIT_MALL then
    local p = require("netio.protocol.mzm.gsp.mall.CBuyCurrentLimitItemReq").new(MallType.DAILY_LIMIT_MALL, self.selectItemId, self.digitalEntered, yuanbao)
    gmodule.network.sendProtocol(p)
    warn("-------send CBuyCurrentLimitItemReq:", self.selectItemId, self.digitalEntered, yuanbao)
  end
end
def.method("number").OnTypeSelect = function(self, type)
  if self.selectMallType == MallType.FASHION_DRESS and type ~= MallType.FASHION_DRESS then
    self:DestroyRelateModel()
  end
  self.selectItemId = 0
  self.selectMallType = type
  self:FillMallItemsList(false)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if nil ~= string.find(id, "Img_BgItem") then
    local itemId = clickobj:FindDirect("Label_ItemId"):GetComponent("UILabel"):get_text()
    self:OnItemSelect(tonumber(itemId))
  elseif "Btn_Buy" == id then
    self:OnBuyClick()
  elseif "Label_Num" == id then
    self:OnSetNumBtnClick()
  elseif "Btn_Minus" == id then
    self:OnMinusNumClick()
  elseif "Btn_Add" == id then
    self:OnAddNumClick()
  elseif string.sub(id, 1, #"Btn_Class_") == "Btn_Class_" then
    local index = tonumber(string.sub(id, #"Btn_Class_" + 1, -1))
    local type = clickobj:FindDirect(string.format("Label_Type_%d", index)):GetComponent("UILabel"):get_text()
    if tonumber(type) == MallType.DAILY_LIMIT_MALL then
      clickobj:FindDirect(string.format("Img_Red_%d", index)):SetActive(false)
      MallData.Instance():SetDailyPurchaseRedPoint(false)
      Event.DispatchEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateDailyPurchaseRedPoint, nil)
    end
    self:OnTypeSelect(tonumber(type))
  elseif id == "Btn_Jifen" then
    self:OpenJifenPanel()
  elseif id == "Btn_AddYuanbao" then
    MallPanel.Instance():SwitchTo(MallPanel.NodeId.PAY)
    MallPanel.Instance():SetToggleState(MallPanel.NodeId.PAY, true)
  elseif id == "Btn_Huan" then
    self:SwapHeroModel()
  elseif id == "Img_Icon" then
    local item = clickobj.parent.parent
    local itemId = item:FindDirect("Label_ItemId"):GetComponent("UILabel"):get_text()
    self:ShowItemTips(tonumber(itemId), item)
  end
end
def.method().OpenJifenPanel = function(self)
  local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
    TokenType.JINGJICHANG_JIFEN
  })
  self.uiTbl.List_Class:FindDirect("Btn_Jifen"):GetComponent("UIToggle").value = false
end
def.method("number", "userdata").ShowItemTips = function(self, itemId, source)
  if self.selectMallType == MallType.FASHION_DRESS then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, source, 0, false)
  end
end
def.method().DestroyRelateModel = function(self)
  if self.model ~= nil then
    self.model:Destroy()
    self.model = nil
  end
end
def.override("string").onDragStart = function(self, id)
  warn(id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true then
    self.model:SetDir(self.model.m_ang - dx / 2)
  end
end
def.method().OnVisible = function(self)
  self:ResetModelAnimation()
end
def.method().ResetModelAnimation = function(self)
  if self.model then
    self.model:Play("Stand_c")
  end
end
return TreasureNode.Commit()

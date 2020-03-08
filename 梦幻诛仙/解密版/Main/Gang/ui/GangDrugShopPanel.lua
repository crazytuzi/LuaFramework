local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangDrugShopPanel = Lplus.Extend(ECPanelBase, "GangDrugShopPanel")
local def = GangDrugShopPanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local GangModule = require("Main.Gang.GangModule")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
def.field("number").selectItemId = 0
def.field("boolean").bWaitToShow = false
def.static("=>", GangDrugShopPanel).Instance = function(self)
  if nil == instance then
    instance = GangDrugShopPanel()
  end
  return instance
end
def.static().ShowGangDrugPanel = function()
  GangDrugShopPanel.Instance().selectItemId = 0
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGetYaoDianInfoReq").new())
  GangDrugShopPanel.Instance().bWaitToShow = true
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ShowDrugShop, GangDrugShopPanel.OnShowDrugShop)
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_DrugShopInfoChanged, GangDrugShopPanel.OnDrugShopInfoChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, GangDrugShopPanel.OnSilverMoneyChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BanggongChanged, GangDrugShopPanel.OnBanggongChanged)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ShowDrugShop, GangDrugShopPanel.OnShowDrugShop)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_DrugShopInfoChanged, GangDrugShopPanel.OnDrugShopInfoChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, GangDrugShopPanel.OnSilverMoneyChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BanggongChanged, GangDrugShopPanel.OnBanggongChanged)
end
def.static("table", "table").OnShowDrugShop = function(p)
  if GangDrugShopPanel.Instance().bWaitToShow then
    GangDrugShopPanel.Instance().bWaitToShow = false
    GangDrugShopPanel.Instance():SetModal(true)
    GangDrugShopPanel.Instance():CreatePanel(RESPATH.PREFAB_DRUG_SHOP_PANEL, 0)
    if GangData.Instance():GetDrugListRefresh() then
      GangData.Instance():SetDrugListRefresh(false)
    end
  elseif GangDrugShopPanel.Instance().m_panel and false == GangDrugShopPanel.Instance().m_panel.isnil then
    GangDrugShopPanel.Instance():FillItemList()
  end
end
def.static("table", "table").OnBanggongChanged = function(self, params, context)
  local self = instance
  self:UpdateGangMoney()
end
def.static("table", "table").OnSilverMoneyChanged = function(self, params, context)
  local self = instance
  self:UpdateSilver()
end
def.static("table", "table").OnDrugShopInfoChanged = function(p)
  local self = instance
  self:FillItemList()
end
def.method().UpdateInfo = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local Img_BgItems = Img_Bg:FindDirect("Img_BgItems")
  local Img_BgDetail = Img_Bg:FindDirect("Img_BgDetail")
  local Group_Buy = Img_Bg:FindDirect("Group_Buy")
  local Img_BgEmpty = Img_Bg:FindDirect("Img_BgEmpty")
  self:FillItemList()
  self:UpdateDetialItemInfo()
  self:UpdateHaveMoney()
end
def.method().UpdateHaveMoney = function(self)
  self:UpdateGangMoney()
  self:UpdateSilver()
end
def.method().UpdateGangMoney = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local Group_Buy = Img_Bg:FindDirect("Group_Buy")
  local curBanggong = GangModule.Instance():GetHeroCurBanggong()
  local banggongLabel = Group_Buy:FindDirect("Label_OwnG/Img_BgOwnG/Label_OwnGNum"):GetComponent("UILabel")
  banggongLabel:set_text(curBanggong)
  banggongLabel:set_textColor(Color.white)
  if self.selectItemId ~= 0 then
    local gangInfo = GangData.Instance():GetGangBasicInfo()
    local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
    if curBanggong < pharmacyTbl.itemBangGongPrice then
      banggongLabel:set_textColor(Color.red)
    end
  end
end
def.method().UpdateSilver = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local Group_Buy = Img_Bg:FindDirect("Group_Buy")
  local silverLabel = Group_Buy:FindDirect("Label_Own/Img_BgOwn/Label_OwnNum"):GetComponent("UILabel")
  silverLabel:set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)))
  silverLabel:set_textColor(Color.white)
  if self.selectItemId ~= 0 then
    local gangInfo = GangData.Instance():GetGangBasicInfo()
    local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
    if Int64.gt(pharmacyTbl.itemSilverPrice, Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER))) then
      silverLabel:set_textColor(Color.red)
    end
  end
end
def.method().FillItemList = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local Img_BgItems = Img_Bg:FindDirect("Img_BgItems")
  local ScrollView = Img_BgItems:FindDirect("Scroll View_Items")
  local list = GangData.Instance():GetDrugList()
  local amount = #list
  local Grid_Items = ScrollView:FindDirect("Grid_Items"):GetComponent("UIList")
  Grid_Items:set_itemCount(amount)
  Grid_Items:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not Grid_Items.isnil then
      Grid_Items:Reposition()
    end
  end)
  local itemUIs = Grid_Items:get_children()
  for i = 1, amount do
    local itemUI = itemUIs[i]
    local itemInfo = list[i]
    self:FillItemInfo(itemUI, i, itemInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "number", "table").FillItemInfo = function(self, itemUI, index, itemInfo)
  local Label_Name = itemUI:FindDirect(string.format("Label_Name_%d", index)):GetComponent("UILabel")
  local Img_BgPrice = itemUI:FindDirect(string.format("Img_BgPrice_%d", index))
  local Img_BgIcon = itemUI:FindDirect(string.format("Img_BgIcon_%d", index))
  local Label_RequirementID = itemUI:FindDirect(string.format("Label_RequirementID_%d", index))
  Label_RequirementID:SetActive(false)
  Label_RequirementID:GetComponent("UILabel"):set_text(itemInfo.itemId)
  local Label_Price = Img_BgPrice:FindDirect(string.format("Label_Price_%d", index)):GetComponent("UILabel")
  local Label_Gang = Img_BgPrice:FindDirect(string.format("Label_Gang_%d", index)):GetComponent("UILabel")
  local Img_Icon = Img_BgIcon:FindDirect(string.format("Img_Icon_%d", index)):GetComponent("UITexture")
  local Img_Sign = Img_BgIcon:FindDirect(string.format("Img_Sign_%d", index))
  local Label_Num = Img_BgIcon:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel")
  Img_Sign:SetActive(false)
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemInfo.itemId)
  Label_Name:set_text(itemBase.name)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
  Label_Price:set_text(pharmacyTbl.itemSilverPrice)
  Label_Gang:set_text(pharmacyTbl.itemBangGongPrice)
  Label_Num:set_text(itemInfo.itemNum)
  GUIUtils.FillIcon(Img_Icon, itemBase.icon)
end
def.method().FillSelectItemInfo = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local Img_BgDetail = Img_Bg:FindDirect("Img_BgDetail")
  local Group_Buy = Img_Bg:FindDirect("Group_Buy")
  local Label_DetailName = Img_BgDetail:FindDirect("Label_DetailName"):GetComponent("UILabel")
  local Img_IconDetail = Img_BgDetail:FindDirect("Img_BgIconDetail/Img_IconDetail"):GetComponent("UITexture")
  local Label_Detail = Img_BgDetail:FindDirect("Label_Detail"):GetComponent("UILabel")
  local Label_DetailType = Img_BgDetail:FindDirect("Label_DetailType"):GetComponent("UILabel")
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(self.selectItemId)
  Label_DetailName:set_text(itemBase.name)
  GUIUtils.FillIcon(Img_IconDetail, itemBase.icon)
  Label_Detail:set_text(itemBase.desc)
  Label_DetailType:set_text(itemBase.itemTypeName)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
  Group_Buy:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_text(pharmacyTbl.itemSilverPrice)
  Group_Buy:FindDirect("Label_CostG/Img_BgCostG/Label_CostGNum"):GetComponent("UILabel"):set_text(pharmacyTbl.itemBangGongPrice)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method("number").OnItemSelect = function(self, itemId)
  self.selectItemId = itemId
  self:UpdateDetialItemInfo()
  self:UpdateHaveMoney()
end
def.method().UpdateDetialItemInfo = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local Img_BgDetail = Img_Bg:FindDirect("Img_BgDetail")
  local Group_Buy = Img_Bg:FindDirect("Group_Buy")
  local Img_BgEmpty = Img_Bg:FindDirect("Img_BgEmpty")
  if self.selectItemId == 0 then
    Img_BgEmpty:SetActive(true)
    Img_BgDetail:SetActive(false)
    Group_Buy:FindDirect("Label_Cost/Img_BgCost/Label_CostNum"):GetComponent("UILabel"):set_text(0)
    Group_Buy:FindDirect("Label_CostG/Img_BgCostG/Label_CostGNum"):GetComponent("UILabel"):set_text(0)
  else
    Img_BgEmpty:SetActive(false)
    Img_BgDetail:SetActive(true)
    self:FillSelectItemInfo()
  end
end
def.static("number", "table").BuySilverCallback = function(i, tag)
  if i == 1 then
    GoToBuySilver(false)
  end
end
def.method().OnBuyClick = function(self)
  if self.selectItemId == 0 then
    Toast(textRes.Gang[146])
    return
  end
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local pharmacyTbl = GangUtility.GetPharmacyGangBasicCfg(gangInfo.pharmacyLevel)
  if Int64.gt(pharmacyTbl.itemSilverPrice, ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)) then
    local tag = {id = self}
    CommonConfirmDlg.ShowConfirm("", textRes.Gang[114], GangDrugShopPanel.BuySilverCallback, tag)
    return
  end
  local curBanggong = GangModule.Instance():GetHeroCurBanggong()
  if curBanggong < pharmacyTbl.itemBangGongPrice then
    local bHasGang = GangModule.Instance():HasGang()
    if false == bHasGang then
      return
    end
    Toast(textRes.Gang[115])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CBuyYaoCaiReq").new(self.selectItemId))
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:Hide()
  elseif string.sub(id, 1, #"Img_BgItem_") == "Img_BgItem_" then
    local index = tonumber(string.sub(id, #"Img_BgItem_" + 1, -1))
    local itemId = clickobj:FindDirect(string.format("Label_RequirementID_%d", index)):GetComponent("UILabel"):get_text()
    self:OnItemSelect(tonumber(itemId))
  elseif "Modal" == id then
    self:Hide()
  elseif "Btn_Buy" == id then
    self:OnBuyClick()
  end
end
return GangDrugShopPanel.Commit()

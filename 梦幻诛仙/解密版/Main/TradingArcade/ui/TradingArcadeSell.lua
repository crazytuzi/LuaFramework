local Lplus = require("Lplus")
local TradingArcadeTabGroup = require("Main.TradingArcade.ui.TradingArcadeTabGroup")
local ECPanelBase = require("GUI.ECPanelBase")
local INotify = import(".INotify")
local TradingArcadeSell = Lplus.Extend(TradingArcadeTabGroup, "TradingArcadeSell").Implement(INotify)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local Vector = require("Types.Vector")
local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
local ItemModule = require("Main.Item.ItemModule")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local TradingArcadeNode = Lplus.ForwardDeclare("TradingArcadeNode")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local def = TradingArcadeSell.define
def.const("table").TabBag = {Item = 1, Pet = 2}
def.const("number").TRADING_HISTORY_TIPS_ID = 701600502
def.field("boolean").m_isUIInited = false
def.field("table").uiObjs = nil
def.field("number").lastTabBag = 1
def.field("table").bagItems = nil
def.field("table").sellList = nil
def.field("number").publicTimeTimer = 0
def.field("table").itemTip = nil
def.field("number").selItemIndex = 0
local instance
def.static("=>", TradingArcadeSell).Instance = function(self)
  if instance == nil then
    instance = TradingArcadeSell()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TradingArcadeTabGroup.Init(self, base, node)
end
def.method("=>", "boolean").HasNotify = function(self)
  return SellServiceMgr.Instance():HasNotify()
end
def.method("=>", "boolean").InitUI = function(self)
  if self.m_isUIInited then
    return false
  end
  self.uiObjs = {}
  self.uiObjs.Img_BgSellItem = self.m_node:FindDirect("Img_BgSellItem")
  self.uiObjs.ScrollView_SellItem = self.uiObjs.Img_BgSellItem:FindDirect("Scroll View_SellItem")
  self.uiObjs.Grid_SellItem = self.uiObjs.ScrollView_SellItem:FindDirect("Grid_SellItem")
  self.uiObjs.Img_BgSellItemTeamplate = self.uiObjs.Grid_SellItem:FindDirect("Img_BgSellItem01")
  self.uiObjs.Img_BgSellItemTeamplate:SetActive(false)
  self.uiObjs.Label_TanWei = self.uiObjs.Img_BgSellItem:FindDirect("Label_TanWei/Label")
  self.uiObjs.Group_BtnSell = self.m_node:FindDirect("Group_BtnSell")
  self.uiObjs.Img_BgMoney = self.uiObjs.Group_BtnSell:FindDirect("Img_BgMoney")
  self.uiObjs.Label_MoneyNum = self.uiObjs.Img_BgMoney:FindDirect("Label_MoneyNum")
  self.uiObjs.Img_GetMoney = self.uiObjs.Group_BtnSell:FindDirect("Img_GetMoney")
  self.uiObjs.Label_GetMoneyNum = self.uiObjs.Img_GetMoney:FindDirect("Label_MoneyNum")
  self.uiObjs.ScrollView_Task = self.m_node:FindDirect("Scroll View_Task")
  self.uiObjs.Grid_Item = self.uiObjs.ScrollView_Task:FindDirect("Grid_Item")
  self.uiObjs.Grid_Item_Template = self.uiObjs.Grid_Item:FindDirect("Item_001")
  GUIUtils.SetActive(self.uiObjs.Grid_Item_Template, false)
  self.uiObjs.Grid_Pet = self.uiObjs.ScrollView_Task:FindDirect("Grid_Pet")
  self.uiObjs.Grid_Pet_Template = self.uiObjs.Grid_Pet:FindDirect("Pet_001")
  GUIUtils.SetActive(self.uiObjs.Grid_Pet_Template, false)
  self.uiObjs.Group_NoItem = self.uiObjs.ScrollView_Task:FindDirect("Group_NoItem")
  self.uiObjs.Group_NoPet = self.uiObjs.ScrollView_Task:FindDirect("Group_NoPet")
  self.uiObjs.Tab_Item = self.m_node:FindDirect("Tab_Item")
  self.uiObjs.Tab_Pet = self.m_node:FindDirect("Tab_Pet")
  self.m_node.parent:FindDirect("Btn_Search"):SetActive(false)
  self.m_isUIInited = true
  return true
end
def.override().OnShow = function(self)
  if self:InitUI() then
    self:UpdateMoneyNum()
    self:InitSellList()
    self:UpdateSellList()
    self:UpdateSellGridNum()
    self:SwitchToTabBag(self.lastTabBag)
  end
  self:StartPublicTimeTimer()
  Event.RegisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, TradingArcadeSell.OnSelfSellGoodsUpdate)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, TradingArcadeSell.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_ADDED, TradingArcadeSell.OnPetChanged)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_DELETED, TradingArcadeSell.OnPetChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, TradingArcadeSell.OnMoneyGoldChanged)
end
def.override().OnHide = function(self)
  self.m_isUIInited = false
  self.uiObjs = nil
  self.sellList = nil
  self.bagItems = nil
  self:StopPublicTimeTimer()
  self.itemTip = nil
  self.selItemIndex = 0
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, TradingArcadeSell.OnSelfSellGoodsUpdate)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, TradingArcadeSell.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_ADDED, TradingArcadeSell.OnPetChanged)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_DELETED, TradingArcadeSell.OnPetChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, TradingArcadeSell.OnMoneyGoldChanged)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  local out = {}
  if id == "Tab_Item" then
    self:SwitchToTabBag(TradingArcadeSell.TabBag.Item)
  elseif id == "Tab_Pet" then
    self:SwitchToTabBag(TradingArcadeSell.TabBag.Pet)
  elseif string.find(id, "rarity_item_") then
    self:OnBagItemObjClick(clickobj)
  elseif string.find(id, "rarity_pet_") then
    self:OnBagPetObjClick(clickobj)
  elseif id == "Img_BgItem" then
    self:OnGoodsImgBgObjClick(clickobj)
  elseif string.find(id, "Img_BgSellItem_") then
    self:OnSellGoodsClick(clickobj)
  elseif id == "Btn_Collect" then
    self:AutoGetMoney()
  elseif id == "Btn_Add" then
    _G.GoToBuyGold()
  elseif id == "Btn_Record" then
    self:OnTradingHistoryBtnClick()
  elseif id == "Btn_Tips" then
    self:OnTradingHistoryQuestionBtnClick()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  elseif id == "Label_Shoucang" then
    self:OnConcernNumLabelClick(clickobj)
  end
end
def.method("string", "string", "table", "=>", "boolean").GetObjIndex = function(self, id, name, out)
  if string.sub(id, 1, #name) == name then
    out.index = tonumber(string.sub(id, #name + 1, -1))
    return true
  end
  return false
end
def.method("userdata").SetHaveGoldNum = function(self, num)
  GUIUtils.SetText(self.uiObjs.Label_MoneyNum, tostring(num))
end
def.method("userdata").SetGianGoldNum = function(self, num)
  GUIUtils.SetText(self.uiObjs.Label_GetMoneyNum, tostring(num))
end
def.method("number", "number").SetSellGridNum = function(self, num, max)
  local text = string.format("%d/%d", num, max)
  GUIUtils.SetText(self.uiObjs.Label_TanWei, text)
end
def.method().UpdateMoneyNum = function(self)
  local haveNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  self:SetHaveGoldNum(Int64.new(haveNum))
  local gain = SellServiceMgr.Instance():GetAfterTaxIncome()
  self:SetGianGoldNum(Int64.new(gain))
end
def.method().UpdateSellGridNum = function(self)
  local use = SellServiceMgr.Instance():GetSellGoodsNum()
  local max = SellServiceMgr.Instance():GetMaxSellGoodsNum()
  self:SetSellGridNum(use, max)
end
def.method().InitSellList = function(self)
  self.sellList = {}
  local maxSellNum = SellServiceMgr.Instance():GetMaxSellGoodsNum()
  self:ResizeGridList(self.uiObjs.Grid_SellItem, self.uiObjs.Img_BgSellItemTeamplate, maxSellNum, "Img_BgSellItem_")
  for i = 1, maxSellNum do
    self:SetSellListItemInfo(i, nil)
  end
end
def.method().UpdateSellList = function(self)
  local sellList = SellServiceMgr.Instance():GetSellList()
  self.sellList = sellList
  self:SetSellList(sellList)
end
def.method("table").SetSellList = function(self, sellList)
  local maxSellNum = SellServiceMgr.Instance():GetMaxSellGoodsNum()
  for i = 1, maxSellNum do
    local v = sellList[i]
    self:SetSellListItemInfo(i, v)
  end
end
def.method("userdata", "userdata", "number", "string").ResizeGridList = function(self, grid, template, size, prefixName)
  local childCount = grid.childCount - 1
  if size > childCount then
    for i = childCount + 1, size do
      local itemGO = GameObject.Instantiate(template)
      itemGO:SetActive(true)
      itemGO.name = prefixName .. i
      itemGO.transform.parent = grid.transform
      itemGO.transform.localScale = Vector.Vector3.one
      self.m_base.m_msgHandler:Touch(itemGO)
    end
  elseif size < childCount then
    for j = childCount, size + 1, -1 do
      local itemGO = grid:GetChild(j)
      GameObject.Destroy(itemGO)
    end
  end
  grid:GetComponent("UIGrid"):Reposition()
end
def.method("number", "table").SetSellListItemInfo = function(self, index, goods)
  local itemObj = self.uiObjs.Grid_SellItem:GetChild(index)
  local Group_Empty = itemObj:FindDirect("Group_Empty")
  local Group_SellItem = itemObj:FindDirect("Group_SellItem")
  Group_Empty:SetActive(false)
  Group_SellItem:SetActive(true)
  local Label_ItemName = Group_SellItem:FindDirect("Label_ItemName")
  local Label_Price = Group_SellItem:FindDirect("Label_Price")
  local Img_Price = Group_SellItem:FindDirect("Img_Price")
  local Img_BgItem = Group_SellItem:FindDirect("Img_BgItem")
  local Texture_Icon = Img_BgItem:FindDirect("Texture_Icon")
  local Label_Num = Img_BgItem:FindDirect("Label")
  local Label_CountDown = Group_SellItem:FindDirect("Label_CountDown")
  local Img_Sign = Group_SellItem:FindDirect("Img_Sign")
  local uiTexture = Texture_Icon:GetComponent("UITexture")
  local Label_Shoucang = Group_SellItem:FindDirect("Label_Shoucang")
  if goods == nil then
    GUIUtils.Toggle(itemObj, false)
    GUIUtils.SetActive(Img_Price, false)
    GUIUtils.SetActive(Img_Sign, false)
    GUIUtils.SetActive(Label_Shoucang, false)
    GUIUtils.SetText(Label_ItemName, "")
    GUIUtils.SetText(Label_Price, "")
    GUIUtils.SetText(Label_CountDown, "")
    GUIUtils.SetText(Label_Num, "")
    GUIUtils.SetTexture(Texture_Icon, 0)
    GUIUtils.SetSprite(Img_BgItem, "Cell_00")
    return
  end
  GUIUtils.SetActive(Img_Price, true)
  GUIUtils.SetActive(Img_Sign, true)
  GUIUtils.SetActive(Label_Shoucang, true)
  GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
  if goods:IsInState(GoodsData.State.STATE_SELLED) and not goods:IsInState(GoodsData.State.STATE_SELL) or 0 >= goods.num then
    GUIUtils.SetSprite(Img_Sign, TradingArcadeNode.SpriteName.Selled)
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
  elseif 0 < goods:GetGainMoney() then
    GUIUtils.SetSprite(Img_Sign, TradingArcadeNode.SpriteName.Get)
  elseif goods:IsInState(GoodsData.State.STATE_EXPIRE) then
    GUIUtils.SetSprite(Img_Sign, TradingArcadeNode.SpriteName.Expire)
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
  else
    GUIUtils.SetSprite(Img_Sign, TradingArcadeNode.SpriteName.Nil)
  end
  local name = goods:GetName()
  local icon = goods:GetIcon()
  local iconId = icon.iconId
  local bgSpriteName = icon.bgSprite
  local rdText = icon.rdText
  local num = goods.num
  local price = goods.price
  local remainSeconds = goods:GetPublicRemainTime()
  local countDownText = ""
  if remainSeconds > 0 then
    local t = _G.Seconds2HMSTime(remainSeconds)
    countDownText = string.format(textRes.TradingArcade[16], t.h, t.m)
  end
  GUIUtils.SetText(Label_ItemName, name)
  TradingArcadeUtils.SetPriceLabel(Label_Price, price)
  GUIUtils.SetTexture(Texture_Icon, iconId)
  GUIUtils.SetSprite(Img_BgItem, bgSpriteName)
  GUIUtils.SetText(Label_Num, rdText)
  GUIUtils.SetText(Label_CountDown, countDownText)
  local roleNum = goods:GetStateRoleNum()
  if roleNum > 0 then
    GUIUtils.SetText(Label_Shoucang, roleNum)
  else
    GUIUtils.SetActive(Label_Shoucang, false)
  end
end
def.method("number").SwitchToTabBag = function(self, tab)
  self.lastTabBag = tab
  if tab == TradingArcadeSell.TabBag.Item then
    GUIUtils.Toggle(self.uiObjs.Tab_Item, true)
    self:UpdateRarityItemList()
  else
    GUIUtils.Toggle(self.uiObjs.Tab_Pet, true)
    self:UpdateRarityPetList()
  end
end
def.method().UpdateRarityItemList = function(self)
  local itemList = SellServiceMgr.Instance():GetRarityItemList()
  self.bagItems = itemList
  self:SetRarityItemList(itemList)
  local isEmpty = #itemList == 0
  GUIUtils.SetActive(self.uiObjs.Group_NoItem, isEmpty)
  GUIUtils.SetActive(self.uiObjs.Group_NoPet, false)
end
def.method("table").SetRarityItemList = function(self, itemList)
  self:ResizeGridList(self.uiObjs.Grid_Item, self.uiObjs.Grid_Item_Template, #itemList, "rarity_item_")
  for i, v in ipairs(itemList) do
    self:SetRarityItemInfo(i, v)
  end
end
def.method("number", "table").SetRarityItemInfo = function(self, index, item)
  local itemObj = self.uiObjs.Grid_Item:GetChild(index)
  local Img_Bg = itemObj:FindDirect("Img_Bg")
  local Img_Icon = itemObj:FindDirect("Img_Icon")
  local Label_Num = itemObj:FindDirect("Label_Num")
  local itemBase = ItemUtils.GetItemBase(item.id)
  local namecolor = 0
  local num = item.number
  local iconId = 0
  if itemBase then
    namecolor = itemBase.namecolor
    iconId = itemBase.icon
  end
  GUIUtils.SetItemCellSprite(Img_Bg, namecolor)
  GUIUtils.SetTexture(Img_Icon, iconId)
  GUIUtils.SetText(Label_Num, num)
end
def.method().UpdateRarityPetList = function(self)
  local petList = SellServiceMgr.Instance():GetRarityPetList()
  self.bagItems = petList
  self:SetRarityPetList(petList)
  local isEmpty = #petList == 0
  GUIUtils.SetActive(self.uiObjs.Group_NoItem, false)
  GUIUtils.SetActive(self.uiObjs.Group_NoPet, isEmpty)
end
def.method("table").SetRarityPetList = function(self, petList)
  self:ResizeGridList(self.uiObjs.Grid_Pet, self.uiObjs.Grid_Pet_Template, #petList, "rarity_pet_")
  for i, v in ipairs(petList) do
    self:SetRarityPetInfo(i, v)
  end
end
def.method("number", "table").SetRarityPetInfo = function(self, index, pet)
  local itemObj = self.uiObjs.Grid_Pet:GetChild(index)
  local Img_Bg = itemObj:FindDirect("Img_Bg")
  local Img_Icon = itemObj:FindDirect("Img_Icon")
  local Label_Num = itemObj:FindDirect("Label_Num")
  local num = pet.level
  local iconId = pet:GetHeadIconId()
  local bgSpriteName = pet:GetHeadIconBGSpriteName()
  GUIUtils.SetSprite(Img_Bg, bgSpriteName)
  GUIUtils.SetTexture(Img_Icon, iconId)
  GUIUtils.SetText(Label_Num, num)
end
def.static("table", "table").OnSelfSellGoodsUpdate = function(params, context)
  local goods = params[1]
  local self = instance
  self:UpdateSellList()
  self:UpdateSellGridNum()
  self:UpdateMoneyNum()
end
def.static("table").OnSelfSellItemDetailUpdate = function(goods)
  local self = instance
  if self.uiObjs == nil then
    return
  end
  if goods == nil then
    return
  end
  if self.itemTip == nil then
    return
  end
  if self.itemTip.goods ~= goods then
    return
  end
  local obj = self.itemTip.obj
  if obj.isnil then
    return
  end
  local autoQuery = false
  self:ShowItemTip(goods, obj, autoQuery)
end
def.static("table").OnSelfSellPetDetailUpdate = function(goods)
  local self = instance
  if self.uiObjs == nil then
    return
  end
  if goods == nil then
    return
  end
  local autoQuery = false
  self:ShowPetInfo(goods, autoQuery)
end
def.method("=>", "boolean").CheckSellGrid = function(self)
  if SellServiceMgr.Instance():IsSellGridFull() then
    Toast(textRes.TradingArcade[31])
    return false
  end
  return true
end
def.method("userdata").OnBagItemObjClick = function(self, obj)
  local strs = string.split(obj.name, "_")
  local index = tonumber(strs[3])
  self.selItemIndex = index
  local item = self.bagItems[index]
  if item == nil then
    return
  end
  if self:CheckSellGrid() == false then
    return
  end
  self:_SellItem(item)
end
def.method("number").SelectBagItem = function(self, index)
  self.selItemIndex = index
  if index == 0 then
    local childCount = self.uiObjs.Grid_Item.childCount
    for i = 1, childCount - 1 do
      local child = self.uiObjs.Grid_Item:GetChild(i)
      GUIUtils.Toggle(child, false)
    end
    return
  end
  local itemObj = self.uiObjs.Grid_Item:GetChild(index)
  if itemObj then
    GUIUtils.Toggle(itemObj, true)
    GameUtil.AddGlobalTimer(0, true, function(...)
      GameUtil.AddGlobalTimer(0, true, function(...)
        if itemObj.isnil then
          return
        end
        self.uiObjs.ScrollView_Task:GetComponent("UIScrollView"):DragToMakeVisible(itemObj.transform, 4)
      end)
    end)
  end
end
def.method("number", "number").SellItem = function(self, itemKey, itemId)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
  if item and item.id == itemId then
    self:_SellItem(item)
  end
end
def.method("table")._SellItem = function(self, item)
  require("Main.TradingArcade.ui.SellItemPanel").ShowPanel(item, function(dir)
    local nextIndex = self.selItemIndex + dir
    if nextIndex < 1 then
      Toast(textRes.TradingArcade[25])
    elseif nextIndex > #self.bagItems then
      Toast(textRes.TradingArcade[26])
    else
      self:SelectBagItem(nextIndex)
      local item = self.bagItems[nextIndex]
      if item == nil then
        return
      end
      self:_SellItem(item)
    end
  end)
end
def.method("userdata").OnBagPetObjClick = function(self, obj)
  local strs = string.split(obj.name, "_")
  local index = tonumber(strs[3])
  local pet = self.bagItems[index]
  if pet == nil then
    return
  end
  if self:CheckSellGrid() == false then
    return
  end
  require("Main.TradingArcade.ui.SellPetPanel").ShowPanel(pet)
end
def.method("userdata").OnGoodsImgBgObjClick = function(self, obj)
  local strs = string.split(obj.parent.parent.name, "_")
  local index = tonumber(strs[3])
  local goods = self.sellList[index]
  if goods == nil then
    return
  end
  if goods.type == GoodsData.Type.Item then
    self:ShowItemTip(goods, obj, true)
  elseif goods.type == GoodsData.Type.Pet then
    self:ShowPetInfo(goods, true)
  end
end
def.method(GoodsData, "userdata", "boolean").ShowItemTip = function(self, goods, obj, autoQuery)
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = obj:GetComponent("UIWidget")
  local item = goods.itemInfo
  local itemId = goods.itemId
  self.itemTip = nil
  if item == nil then
    self.itemTip = {goods = goods, obj = obj}
    if TradingArcadeUtils.NeedQueryItemDetail(itemId) and autoQuery then
      SellServiceMgr.Instance():QueryGoodsDetail(goods, TradingArcadeSell.OnSelfSellItemDetailUpdate)
    else
      local item = {
        id = itemId,
        flag = 0,
        extraMap = {},
        extraInfoMap = {},
        extraProps = {}
      }
      local itemTip = ItemTipsMgr.Instance():ShowTips(item, 0, 0, ItemTipsMgr.Source.TradingArcadeSell, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
      local context = {
        marketId = goods.marketId,
        refId = goods:GetRefId(),
        price = goods.price,
        goods = goods
      }
      itemTip:SetOperateContext(context)
    end
  else
    local itemTip = ItemTipsMgr.Instance():ShowTips(item, 0, 0, ItemTipsMgr.Source.TradingArcadeSell, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    local context = {
      marketId = goods.marketId,
      refId = goods:GetRefId(),
      price = goods.price
    }
    itemTip:SetOperateContext(context)
  end
end
def.method(GoodsData, "boolean").ShowPetInfo = function(self, goods, autoQuery)
  local PetInfoPanel = require("Main.Pet.ui.PetInfoPanel")
  if goods.petInfo then
    PetInfoPanel.Instance().level = 2
    PetInfoPanel.Instance():ShowPanelByPetInfo(goods.petInfo)
    do
      local context = {
        marketId = goods.marketId,
        refId = goods:GetRefId(),
        price = goods.price,
        sellerRoleId = goods.sellerRoleId
      }
      PetInfoPanel.Instance():SetShareCallback(function(pos)
        TradingArcadeUtils.ShowShareOptionsPanel(context, pos)
      end)
    end
  elseif autoQuery then
    SellServiceMgr.Instance():QueryGoodsDetail(goods, TradingArcadeSell.OnSelfSellPetDetailUpdate)
  end
end
def.method("userdata").OnSellGoodsClick = function(self, obj)
  local strs = string.split(obj.name, "_")
  local index = tonumber(strs[3])
  local goods = self.sellList[index]
  if goods == nil then
    return
  end
  if goods.num <= 0 then
    SellServiceMgr.Instance():GetGoodsMoney(goods)
  elseif 0 < goods:GetGainMoney() then
    SellServiceMgr.Instance():GetGoodsMoney(goods)
  elseif goods:IsInState(GoodsData.State.STATE_EXPIRE) then
    if goods.type == GoodsData.Type.Item then
      require("Main.TradingArcade.ui.ReSellItemPanel").ShowPanel(goods)
    elseif goods.type == GoodsData.Type.Pet then
      require("Main.TradingArcade.ui.ReSellPetPanel").ShowPanel(goods, self)
    end
  else
    require("Main.TradingArcade.ui.UnsheleveGoodsPanel").ShowPanel(goods)
  end
end
def.method("userdata").OnConcernNumLabelClick = function(self, obj)
  local name = obj.parent.parent.name
  local strs = string.split(name, "_")
  local index = tonumber(strs[3])
  local goods = self.sellList[index]
  if goods == nil then
    warn("OnConcernNumLabelClick goods is nil for index " .. index)
    return
  end
  local roleNum = goods:GetStateRoleNum()
  if roleNum <= 0 then
    print("OnConcernNumLabelClick roleNum is zero")
    return
  end
  local text = ""
  local goodsType = goods.type
  local marketId = goods.marketId
  local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
  TradingArcadeProtocol.CQueryAuctionConcernNumReq(marketId, goodsType, function(p)
    goods.concernRoleNum = p.concernNum
    goods.bidRoleNum = p.auctionNum
    TradingArcadeUtils.ShowGoodsStateRoleNum(goods)
    if self.uiObjs == nil then
      return
    end
    self:UpdateSellList()
  end)
end
def.method().AutoGetMoney = function(self)
  local money = SellServiceMgr.Instance():GetAfterTaxIncome()
  if money <= 0 then
    Toast(textRes.TradingArcade[28])
    return
  end
  SellServiceMgr.Instance():AutoGetMoney()
end
def.method().StartPublicTimeTimer = function(self)
  if self.publicTimeTimer ~= 0 then
    return
  end
  self.publicTimeTimer = GameUtil.AddGlobalTimer(60, false, function()
    if self.uiObjs == nil then
      return
    end
    self:UpdateSellList()
  end)
end
def.method().StopPublicTimeTimer = function(self)
  if self.publicTimeTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.publicTimeTimer)
    self.publicTimeTimer = 0
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local goods = params[1]
  local self = instance
  if self.lastTabBag == TradingArcadeSell.TabBag.Item then
    self:UpdateRarityItemList()
  end
end
def.static("table", "table").OnPetChanged = function(params, context)
  local goods = params[1]
  local self = instance
  if self.lastTabBag == TradingArcadeSell.TabBag.Pet then
    self:UpdateRarityPetList()
  end
end
def.static("table", "table").OnMoneyGoldChanged = function(params, context)
  local goods = params[1]
  local self = instance
  self:UpdateMoneyNum()
end
def.method().OnTradingHistoryBtnClick = function(self)
  require("Main.TradingArcade.ui.TradingLogPanel").ShowPanel()
end
def.method().OnTradingHistoryQuestionBtnClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(TradingArcadeSell.TRADING_HISTORY_TIPS_ID) or ""
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method().OnTimer = function(self)
end
TradingArcadeSell.Commit()
return TradingArcadeSell

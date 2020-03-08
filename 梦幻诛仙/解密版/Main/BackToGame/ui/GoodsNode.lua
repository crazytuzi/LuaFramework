local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local GoodsNode = Lplus.Extend(TabNode, "GoodsNode")
local ECPanelBase = require("GUI.ECPanelBase")
local BTGLimitSell = require("Main.BackToGame.mgr.BTGLimitSell")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local BackGameGiftRefreshType = require("consts.mzm.gsp.activity3.confbean.BackGameGiftRefreshType")
local Vector3 = require("Types.Vector3")
local Vector2 = require("Types.Vector2")
local def = GoodsNode.define
def.field("table").m_goodsData = nil
def.field("number").m_selectTier = 1
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.LimitSellUpdate, GoodsNode.OnUpdate, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, GoodsNode.OnYuanBaoChanged, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, GoodsNode.OnYuanBaoChanged, self)
  self.m_goodsData = BTGLimitSell.Instance():GetGoodsData()
  self:UpdateYuanbao()
  self:UpdateTab()
  self:SelectTab(1)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.LimitSellUpdate, GoodsNode.OnUpdate)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, GoodsNode.OnYuanBaoChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, GoodsNode.OnYuanBaoChanged)
  self.m_goodsData = nil
  self.m_selectTier = 1
end
def.method("table").OnYuanBaoChanged = function(self, param)
  self:UpdateYuanbao()
end
def.method("table").OnUpdate = function(self, param)
  self.m_goodsData = BTGLimitSell.Instance():GetGoodsData()
  self:UpdateGoods(false)
end
def.override("string").onClick = function(self, id)
  if id == "Btn_AddYuanbao" then
    local MallPanel = require("Main.Mall.ui.MallPanel")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
  elseif string.sub(id, 1, 10) == "Btn_Class_" then
    local index = tonumber(string.sub(id, 11))
    if index then
      self:SelectTab(index)
    end
  elseif string.sub(id, 1, 15) == "Img_BgItemList_" then
    local index = tonumber(string.sub(id, 16))
    if index then
      self:ShowBuyItem(index)
    end
  elseif string.sub(id, 1, 11) == "Img_BgItem_" then
    local index = tonumber(string.sub(id, 12))
    if index then
      local items = self:GetGoods()
      local item = items[index]
      if item then
        local icon = self.m_node:FindDirect(string.format("Group_GoodsList/Scroll View_Goods/List_Goods/Group_Item_%d/Img_BgItem%d", index, index))
        if icon then
          ItemTipsMgr.Instance():ShowBasicTipsWithGO(item.itemId, icon, 0, false)
        end
      end
    end
  end
end
def.method().UpdateYuanbao = function(self)
  local moneyLbl = self.m_node:FindDirect("Group_Money/Label_HaveNum")
  local cash = ItemModule.Instance():GetAllYuanBao()
  moneyLbl:GetComponent("UILabel"):set_text(cash:tostring())
end
def.method().UpdateTab = function(self)
  local scroll = self.m_node:FindDirect("Group_List/ScrollList_Class")
  local list = scroll:FindDirect("List_Class")
  local listCmp = list:GetComponent("UIList")
  local count = #self.m_goodsData
  if count > 1 then
    scroll:SetActive(true)
    listCmp:set_itemCount(count)
    listCmp:Resize()
    local items = listCmp:get_children()
    for i = 1, #items do
      local uiGo = items[i]
      self:FillTab(uiGo, i)
      self.m_base.m_msgHandler:Touch(uiGo)
    end
    self:UpdateGoodsView(280)
  else
    scroll:SetActive(false)
    self:UpdateGoodsView(335)
  end
end
def.method("number").UpdateGoodsView = function(self, height)
  local Group_GoodsList = self.m_node:FindDirect("Group_GoodsList")
  local widget = Group_GoodsList:GetComponent("UIWidget")
  widget:set_height(height)
  Group_GoodsList:FindDirect("Scroll View_Goods"):GetComponent("UIPanel"):UpdateAnchors()
  Group_GoodsList:FindDirect("Sprite"):GetComponent("UISprite"):UpdateAnchors()
end
def.method("userdata", "number").FillTab = function(self, uiGo, index)
  local lbl = uiGo:FindDirect(string.format("Label_%d", index))
  local name = textRes.BackToGame.LimitSell.Tab[index]
  lbl:GetComponent("UILabel"):set_text(name)
end
def.method("number").SelectTab = function(self, tab)
  if self.m_goodsData[tab] then
    self.m_selectTier = tab
  else
    self.m_selectTier = 1
  end
  local list = self.m_node:FindDirect("Group_List/ScrollList_Class/List_Class")
  local tab = list:FindDirect("Btn_Class_" .. tab)
  if tab then
    tab:GetComponent("UIToggle").value = true
  end
  self:UpdateGoods(true)
end
def.method("=>", "table").GetGoods = function(self)
  return self.m_goodsData[self.m_selectTier] or {}
end
def.method("boolean").UpdateGoods = function(self, resetScroll)
  local scroll = self.m_node:FindDirect("Group_GoodsList/Scroll View_Goods")
  local list = scroll:FindDirect("List_Goods")
  local listCmp = list:GetComponent("UIList")
  local goods = self:GetGoods()
  local count = #goods
  scroll:SetActive(true)
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = goods[i]
    self:FillItem(uiGo, info, i)
    self.m_base.m_msgHandler:Touch(uiGo)
  end
  if resetScroll then
    GameUtil.AddGlobalTimer(0.01, true, function()
      GameUtil.AddGlobalTimer(0.01, true, function()
        if not scroll.isnil then
          scroll:GetComponent("UIPanel"):set_clipOffset(Vector2.Vector2.zero)
          scroll.localPosition = Vector3.Vector3.zero
          scroll:GetComponent("UIScrollView"):ResetPosition()
        end
      end)
    end)
  end
end
def.method("userdata", "table", "number").FillItem = function(self, uiGo, info, index)
  local name = uiGo:FindDirect(string.format("Label_ItemName_%d", index))
  local num = uiGo:FindDirect(string.format("Label_ItemLimit_%d", index))
  local bg = uiGo:FindDirect(string.format("Img_BgItem_%d", index))
  local icon = bg:FindDirect(string.format("Texture_ItemIcon_%d", index))
  local precent = uiGo:FindDirect(string.format("Img_Sign_%d/Label_SaleNum_%d", index, index))
  local originPrice = uiGo:FindDirect(string.format("Group_OriPri_%d/Label_OriPrice_%d", index, index))
  local discountPrice = uiGo:FindDirect(string.format("Group_CurPri_%d/Label_CurPri_%d", index, index))
  local itemBase = ItemUtils.GetItemBase(info.itemId)
  name:GetComponent("UILabel"):set_text(itemBase.name)
  if info.refreshType == BackGameGiftRefreshType.DAILY then
    num:GetComponent("UILabel"):set_text(string.format(textRes.BackToGame.LimitSell[2], info.times, info.buyCount))
  elseif info.refreshType == BackGameGiftRefreshType.NONE then
    num:GetComponent("UILabel"):set_text(string.format(textRes.BackToGame.LimitSell[5], info.times, info.buyCount))
  else
    num:GetComponent("UILabel"):set_text("")
  end
  bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
  GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
  precent:GetComponent("UILabel"):set_text(string.format(textRes.BackToGame.LimitSell[3], math.floor(info.price / info.originalPrice * 10)))
  originPrice:GetComponent("UILabel"):set_text(tostring(info.originalPrice))
  discountPrice:GetComponent("UILabel"):set_text(tostring(info.price))
end
def.method("number").ShowBuyItem = function(self, index)
  local items = self:GetGoods()
  local item = items[index]
  if item then
    local leftNum = item.buyCount - BTGLimitSell.Instance():GetBuyTimes(item.id)
    if leftNum <= 0 then
      if item.refreshType == BackGameGiftRefreshType.DAILY then
        Toast(textRes.BackToGame.LimitSell[4])
      else
        Toast(textRes.BackToGame.LimitSell[6])
      end
      return
    end
    local uiCfg = {}
    local itemBase = ItemUtils.GetItemBase(item.itemId)
    uiCfg.id = item.itemId
    uiCfg.icon = itemBase.icon
    uiCfg.name = itemBase.name
    uiCfg.typeName = itemBase.itemTypeName
    uiCfg.level = -1
    uiCfg.desc = itemBase.desc
    uiCfg.price = item.price
    uiCfg.moneyIcon = "Img_Money"
    uiCfg.numToBuy = 1
    uiCfg.avaliableNum = item.buyCount - BTGLimitSell.Instance():GetBuyTimes(item.id)
    function uiCfg.funcCaculateTotalPrice(num)
      return num * item.price
    end
    function uiCfg.buyCallback(num)
      local needYuanbao = num * item.price
      local myYuabao = ItemModule.Instance():GetAllYuanBao()
      if myYuabao:lt(needYuanbao) then
        _G.GotoBuyYuanbao()
        return
      end
      BTGLimitSell.Instance():Buy(item.id, num)
    end
    local UIBuyConfirmPanel = require("Main.Mall.ui.UIBuyConfirmPanel")
    UIBuyConfirmPanel.Instance():ShowPanel(uiCfg)
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_BUY_GIFT)
  return open
end
GoodsNode.Commit()
return GoodsNode

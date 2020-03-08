local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemNode = Lplus.Extend(TabNode, "ItemNode")
local def = ItemNode.define
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local PresentData = require("Main.Present.data.PresentData")
local FriendData = require("Main.friend.FriendData")
local PresentUtility = require("Main.Present.PresentUtility")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemSourceEnum = require("netio.protocol.mzm.gsp.item.ItemSourceEnum")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local PresentPanel = Lplus.ForwardDeclare("PresentPanel")
local MallUtility = require("Main.Mall.MallUtility")
local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
def.field("table").uiTbl = nil
def.field("table").itemList = nil
def.field("table").selectList = nil
def.field(PresentData).data = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.data = PresentData.Instance()
  self.uiTbl = PresentUtility.FillPresentItemUI(self.uiTbl, self.m_node)
  self:InitItems()
  self.selectList = {}
end
def.method().InitItems = function(self)
  self.itemList = {}
  local bagInfo = ItemModule.Instance():GetItemsByBagId(ItemModule.BAG)
  for k, v in pairs(bagInfo) do
    local itemBase = ItemUtils.GetItemBase(v.id)
    local source = v.extraMap[ItemXStoreType.ITEM_SOURCE]
    if itemBase ~= nil then
      local itemTypeCfg = ItemUtils.GetItemTypeCfg(itemBase.itemType)
      local isGiveLimitItem = ItemUtils.IsGiveLimitItem(v.id)
      if not isGiveLimitItem and v.flag ~= require("netio.protocol.mzm.gsp.item.ItemInfo").BIND and itemBase.isProprietary == false and itemTypeCfg.canGive and source ~= ItemSourceEnum.SHANGHUI then
        v.count = v.number
        v.key = k
        table.insert(self.itemList, v)
      end
    else
      print("error item id = ", v.id)
    end
  end
end
def.override().OnShow = function(self)
  self:FillItemsList(false)
  self:FillSelectList()
  self:FillPresentTimesInfo()
end
def.method("boolean").FillItemsList = function(self, bOnlyUpdateNum)
  local list = self.itemList
  local uiList = self.uiTbl.Grid_Bag:GetComponent("UIList")
  uiList:set_itemCount(#list)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local itemsUI = uiList:get_children()
  for i = 1, #itemsUI do
    local itemUI = itemsUI[i]
    local itemInfo = list[i]
    self:FillItemInfo(itemUI, i, itemInfo, bOnlyUpdateNum)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("userdata", "number", "table", "boolean").FillItemInfo = function(self, itemUI, index, itemInfo, bOnlyUpdateNum)
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  local Label_Num = itemUI:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel")
  Label_Num:set_text(itemInfo.count)
  if bOnlyUpdateNum then
    return
  end
  local Img_PinzhiBg = itemUI:FindDirect(string.format("Img_PinzhiBg_%d", index))
  local Texture_Icon = itemUI:FindDirect(string.format("Texture_Icon_%d", index)):GetComponent("UITexture")
  GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
  if itemBase.type == ItemType.MAGIC_MATERIAL then
    Img_PinzhiBg:SetActive(true)
    local fumoCfg = require("Main.Skill.LivingSkillUtility").GetEnchantingPropInfo(itemInfo.id)
    local Label_Pinzhi = Img_PinzhiBg:FindDirect(string.format("Label_Pinzhi_%d", index)):GetComponent("UILabel")
    Label_Pinzhi:set_text(fumoCfg.drugPro)
  elseif itemBase.type == ItemType.IN_FIGHT_DRUG then
    Img_PinzhiBg:SetActive(true)
    local inFightDrugCfg = require("Main.Skill.LivingSkillUtility").GetInFightDrugItemInfo(itemInfo.id)
    local Label_Pinzhi = Img_PinzhiBg:FindDirect(string.format("Label_Pinzhi_%d", index)):GetComponent("UILabel")
    Label_Pinzhi:set_text(inFightDrugCfg.drugPro)
  else
    Img_PinzhiBg:SetActive(false)
  end
  local price = MallUtility.GetPriceByItemId(itemInfo.id)
  if price > 0 then
    local historyYuanbao = ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_CASH)
    if historyYuanbao == nil then
      historyYuanbao = Int64.new(0)
    end
    local presentMax, _ = PresentUtility.GetMallPresentMax(historyYuanbao)
    if presentMax > 0 then
      GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Normal)
    else
      GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Gray)
    end
  else
    GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Normal)
  end
  itemUI:GetComponent("UIToggle"):set_isChecked(false)
end
def.method().FillSelectList = function(self)
  local uiList = self.uiTbl.Grid_Present:GetComponent("UIList")
  uiList:set_itemCount(#self.selectList)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local presentsUI = uiList:get_children()
  for i = 1, #presentsUI do
    local presentUI = presentsUI[i]
    local presentInfo = self.selectList[i]
    self:FillPresentInfo(presentUI, i, presentInfo)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("userdata", "number", "table").FillPresentInfo = function(self, presentUI, index, presentInfo)
  local itemBase = ItemUtils.GetItemBase(presentInfo.id)
  local Img_PinzhiBg = presentUI:FindDirect(string.format("Img_PinzhiBg_%d", index))
  local Texture_Icon = presentUI:FindDirect(string.format("Texture_Icon_%d", index)):GetComponent("UITexture")
  local Label_Num = presentUI:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel")
  GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
  Label_Num:set_text(presentInfo.num)
  if itemBase.type == ItemType.MAGIC_MATERIAL then
    Img_PinzhiBg:SetActive(true)
    local fumoCfg = require("Main.Skill.LivingSkillUtility").GetEnchantingPropInfo(itemInfo.id)
    local Label_Pinzhi = Img_PinzhiBg:FindDirect(string.format("Label_Pinzhi_%d", index)):GetComponent("UILabel")
    Label_Pinzhi:GetComponent("UILabel"):set_text(fumoCfg.drugPro)
  elseif itemBase.type == ItemType.IN_FIGHT_DRUG then
    Img_PinzhiBg:SetActive(true)
    local inFightDrugCfg = require("Main.Skill.LivingSkillUtility").GetInFightDrugItemInfo(itemInfo.id)
    local Label_Pinzhi = Img_PinzhiBg:FindDirect(string.format("Label_Pinzhi_%d", index)):GetComponent("UILabel")
    Label_Pinzhi:GetComponent("UILabel"):set_text(inFightDrugCfg.drugPro)
  else
    Img_PinzhiBg:SetActive(false)
  end
end
def.method().ClearSelect = function(self)
  self.selectList = {}
end
def.method().UpdatePresentTimes = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local friendInfo = PresentPanel.Instance().friendsList[PresentPanel.Instance().selectFriendIndex]
  local dVal = heroProp.level - friendInfo.roleLevel
  local itemMax = PresentUtility.GetItemPresentMax(dVal)
  local itemNum, yuanbaoVal = self.data:GetItemMallByRoleId(friendInfo.roleId)
  local selectNum, selectYuanbao = self:GetSelectNumAndYuanbao()
  local rateItem = (itemNum + selectNum) / itemMax
  self.uiTbl.Img_BgSlider1:GetComponent("UISlider"):set_sliderValue(rateItem)
  self.uiTbl.Img_BgSlider1:FindDirect("Label"):GetComponent("UILabel"):set_text(string.format("%d/%d", itemNum + selectNum, itemMax))
end
def.method().UpdatePresentYuanbao = function(self)
  local historyYuanbao = ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_CASH)
  if historyYuanbao == nil then
    historyYuanbao = Int64.new(0)
  end
  local presentMax, _ = PresentUtility.GetMallPresentMax(historyYuanbao)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local friendInfo = PresentPanel.Instance().friendsList[PresentPanel.Instance().selectFriendIndex]
  local itemNum, yuanbaoVal = self.data:GetItemMallByRoleId(friendInfo.roleId)
  local selectNum, selectYuanbao = self:GetSelectNumAndYuanbao()
  local add = Int64.add(yuanbaoVal, selectYuanbao)
  local rateMall = Int64.new(0)
  if presentMax > 0 then
    rateMall = Int64.div(add, presentMax)
  end
  self.uiTbl.Img_BgSlider2:GetComponent("UISlider"):set_sliderValue(Int64.tostring(rateMall))
  self.uiTbl.Img_BgSlider2:FindDirect("Label"):GetComponent("UILabel"):set_text(string.format("%s/%d", Int64.tostring(add), presentMax))
end
def.method().FillPresentTimesInfo = function(self)
  self:UpdatePresentTimes()
  self:UpdatePresentYuanbao()
end
def.override().OnHide = function(self)
end
def.method("table").InsertToSelect = function(self, itemInfo)
  for k, v in pairs(self.selectList) do
    if v.key == itemInfo.key then
      v.num = v.num + 1
      return
    end
  end
  local item = itemInfo
  item.num = 1
  table.insert(self.selectList, item)
end
def.method("table").RemoveFromSelect = function(self, itemInfo)
  for k, v in pairs(self.selectList) do
    if v.key == itemInfo.key then
      if v.num > 1 then
        v.num = v.num - 1
      else
        table.remove(self.selectList, k)
      end
      return
    end
  end
end
def.method("=>", "number", "number").GetSelectNumAndYuanbao = function(self)
  local num = 0
  local allPrice = 0
  for k, v in pairs(self.selectList) do
    local price = MallUtility.GetPriceByItemId(v.id)
    if price > 0 then
      allPrice = allPrice + price * v.num
    else
      num = num + v.num
    end
  end
  return num, allPrice
end
def.method("userdata").OnSelectItemClick = function(self, clickobj)
  local id = clickobj.name
  local index = tonumber(string.sub(id, #"Img_BgItem_" + 1, -1))
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local friendInfo = PresentPanel.Instance().friendsList[PresentPanel.Instance().selectFriendIndex]
  local dVal = heroProp.level - friendInfo.roleLevel
  local itemMax = PresentUtility.GetItemPresentMax(dVal)
  local itemNum, yuanbaoVal = self.data:GetItemMallByRoleId(friendInfo.roleId)
  local selectNum, selectYuanbao = self:GetSelectNumAndYuanbao()
  if itemMax <= selectNum + itemNum then
    clickobj:GetComponent("UIToggle"):set_isChecked(false)
    Toast(textRes.Present[4])
    return
  end
  local itemInfo = self.itemList[index]
  local source = itemInfo.extraMap[ItemXStoreType.ITEM_SOURCE]
  local historyYuanbao = ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_CASH)
  if historyYuanbao == nil then
    historyYuanbao = Int64.new(0)
  end
  local presentMax, yuanbaoMin = PresentUtility.GetMallPresentMax(historyYuanbao)
  local price = MallUtility.GetPriceByItemId(itemInfo.id)
  if Int64.new(selectYuanbao) + yuanbaoVal >= Int64.new(presentMax) and price > 0 then
    Toast(textRes.Present[5])
    clickobj:GetComponent("UIToggle"):set_isChecked(false)
    return
  end
  if 1 <= itemInfo.count then
    local remainYuanbao = presentMax - selectYuanbao
    if price > 0 and price > remainYuanbao then
      if historyYuanbao >= Int64.new(yuanbaoMin) then
        Toast(textRes.Present[5])
      else
        Toast(string.format(textRes.Present[3], yuanbaoMin))
      end
      clickobj:GetComponent("UIToggle"):set_isChecked(false)
    else
      itemInfo.count = itemInfo.count - 1
      self:InsertToSelect(itemInfo)
      self:FillItemsList(true)
      self:FillSelectList()
      self:FillPresentTimesInfo()
      local itemBase = ItemUtils.GetItemBase(itemInfo.id)
      Toast(string.format(textRes.Present[1], itemBase.name))
      ItemNode.ShowExtraTip(itemBase, itemInfo)
    end
  else
    Toast(textRes.Present[2])
    clickobj:GetComponent("UIToggle"):set_isChecked(false)
  end
end
local G_tblExtraItemTip = {}
def.static("number", "function").RegisterExtraSelectItemTip = function(itemType, func)
  G_tblExtraItemTip[itemType] = func
end
def.static("table", "table").ShowExtraTip = function(itemBase, item)
  local itemType = itemBase.itemType
  local func = G_tblExtraItemTip[itemType]
  if func ~= nil then
    func(item)
  end
end
def.method("number").ItemAdd = function(self, key)
  for k, v in pairs(self.itemList) do
    if v.key == key then
      v.count = v.count + 1
      return
    end
  end
end
def.method().ReturnSelectToSrc = function(self)
  for k, v in pairs(self.selectList) do
    self:ItemAdd(v.key)
  end
end
def.method("number").OnSelectPresentClick = function(self, index)
  local selectInfo = self.selectList[index]
  if selectInfo == nil then
    return
  end
  self:ItemAdd(selectInfo.key)
  self:RemoveFromSelect(selectInfo)
  self:FillItemsList(true)
  self:FillSelectList()
  self:FillPresentTimesInfo()
end
def.method().OnPresentClick = function(self)
  local uuids = {}
  for k, v in pairs(self.selectList) do
    local tmpUUid = v.uuid[1]
    uuids[tmpUUid] = v.num
  end
  if #self.selectList > 0 then
    local p = require("netio.protocol.mzm.gsp.item.CGiveItem").new(PresentPanel.Instance().selectRoleId, uuids)
    gmodule.network.sendProtocol(p)
    self.selectList = {}
  else
    Toast(textRes.Present[7])
  end
end
def.method().OnTipsClick = function(self)
  local tipsId = PresentUtility.GetPresentConsts("FLOAT_TIP")
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method().OnBagInfoChanged = function(self)
  self.itemList = {}
  self:FillItemsList(false)
  self:InitItems()
  self:FillItemsList(false)
end
def.method("userdata").SucceedPresent = function(self, roleId)
  self.selectList = {}
  if roleId == PresentPanel.Instance().selectRoleId then
    self:FillSelectList()
  end
  self:FillPresentTimesInfo()
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Img_BgItem_") == "Img_BgItem_" then
    self:OnSelectItemClick(clickobj)
  elseif string.sub(id, 1, #"Img_Present_") == "Img_Present_" then
    local index = tonumber(string.sub(id, #"Img_Present_" + 1, -1))
    self:OnSelectPresentClick(index)
  elseif "Btn_Present" == id then
    self:OnPresentClick()
  elseif "Btn_Tips" == id then
    self:OnTipsClick()
  end
end
ItemNode.Commit()
return ItemNode

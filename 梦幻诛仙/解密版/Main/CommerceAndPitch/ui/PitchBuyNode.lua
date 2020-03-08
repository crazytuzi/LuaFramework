local Lplus = require("Lplus")
local TabSonNode = require("Main.CommerceAndPitch.ui.TabSonNode")
local PitchPanelNode = Lplus.ForwardDeclare("PitchPanelNode")
local PitchBuyNode = Lplus.Extend(TabSonNode, "PitchBuyNode")
local PitchData = require("Main.CommerceAndPitch.data.PitchData")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local ItemModule = require("Main.Item.ItemModule")
local CommercePitchModule = Lplus.ForwardDeclare("CommercePitchModule")
local CommercePitchProtocol = require("Main.CommerceAndPitch.CommercePitchProtocol")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local TaskInterface = require("Main.task.TaskInterface")
local CommercePitchPanel = Lplus.ForwardDeclare("CommercePitchPanel")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local SCommonResultRes = require("netio.protocol.mzm.gsp.baitan.SCommonResultRes")
local ItemUtils = require("Main.Item.ItemUtils")
local IdType = require("consts.mzm.gsp.baitan.confbean.IdType")
local def = PitchBuyNode.define
def.field(PitchData).data = nil
def.field("table").uiTbl = nil
def.field("number").lastGroupListNum = 0
def.field("number").lastItemListNum = 0
def.field("number").lastSelectGroup = 0
def.field("table").lastSelectSmallGroup = nil
def.field("string").groupInfo = ""
def.field("table").itemTbl = nil
def.field("number").itemIndexSelect = 0
def.field("table").itemBuyInfo = nil
def.field("boolean").bIsGroupInit = false
def.field("number").curPage = 1
def.field("number").nextPage = 1
def.field("boolean").bIsDisplaySmallGroup = false
def.field("table").filterCondistions = nil
def.field("number").filterParam = 0
def.const("number").PerPageItemNum = 8
local EQUIPMENT_BIG_GROUP = 3
def.field("table").selectItemTipsInfo = nil
def.override(CommercePitchPanel, "userdata").Init = function(self, base, node)
  TabSonNode.Init(self, base, node)
  self.data = PitchData.Instance()
  self.data:InitGroupList()
  self.uiTbl = CommercePitchUtils.FillPitchBuyNodeUI(self.uiTbl, self.m_node)
  self.lastSelectGroup = CommercePitchModule.Instance().lastPitchBigGroup
  self.lastSelectSmallGroup = CommercePitchModule.Instance().lastPitchSmallGroup
  self.groupInfo = CommercePitchModule.Instance().lastPitchGroupInfo
  self.filterCondistions = {}
  local groupList = self.data:GetGroupList()
  if CommercePitchModule.Instance().lastPitchBigGroup == 0 then
    self.lastSelectGroup = 1
    if CommercePitchModule.Instance().lastPitchSmallGroup == nil then
      self.lastSelectSmallGroup = {}
      self.lastSelectSmallGroup.big = self.lastSelectGroup
      self.lastSelectSmallGroup.small = 0
      CommercePitchModule.Instance().lastPitchSmallGroup = self.lastSelectSmallGroup
      self.groupInfo = self.lastSelectSmallGroup.big .. "_" .. self.lastSelectSmallGroup.small
      CommercePitchModule.Instance().lastPitchGroupInfo = self.groupInfo
    end
  end
  if CommercePitchModule.Instance().lastPitchSmallGroup == nil or CommercePitchModule.Instance().lastPitchSmallGroup.big == 0 then
    self.lastSelectSmallGroup = {}
    self.lastSelectSmallGroup.big = self.lastSelectGroup
    self.lastSelectSmallGroup.small = 0
    CommercePitchModule.Instance().lastPitchSmallGroup = self.lastSelectSmallGroup
    self.groupInfo = self.lastSelectSmallGroup.big .. "_" .. self.lastSelectSmallGroup.small
    CommercePitchModule.Instance().lastPitchGroupInfo = self.groupInfo
  end
  self.itemTbl = self:GetCurConditionShoppingList()
end
def.override().OnShow = function(self)
  if CommercePitchPanel.Instance().group ~= 0 and CommercePitchPanel.Instance().stateByTask == CommercePitchPanel.StateConst.Pitch then
    self.lastSelectGroup = CommercePitchPanel.Instance().group
    self.lastSelectSmallGroup.big = CommercePitchPanel.Instance().group
    self.lastSelectSmallGroup.small = CommercePitchPanel.Instance().groupS
    CommercePitchModule.Instance().lastPitchSmallGroup = self.lastSelectSmallGroup
    CommercePitchModule.Instance().lastPitchBigGroup = self.lastSelectGroup
    self.groupInfo = self.lastSelectSmallGroup.big .. "_" .. self.lastSelectSmallGroup.small
    CommercePitchModule.Instance().lastPitchGroupInfo = self.groupInfo
  end
  local DEFAULT_SUBTYPE = self:GetDefaultSelSubType()
  self:UpdateFilterOption()
  local param = self:GetSelFilterParam()
  if false == PitchData.Instance():GetIsSyncShoppingList() and PitchData.Instance():GetOnceFinished() then
    PitchData.Instance():SetOnceFinished(false)
    CommercePitchProtocol.CQueryShopingListReq(DEFAULT_SUBTYPE, param)
  elseif self.data:CanFreeRefresh() and self.data:CanAutoFreeRefresh() then
    self.data:SetIsAutoRefesh(true)
    CommercePitchProtocol.CFreeRefreshShopingListReq(DEFAULT_SUBTYPE, param)
  end
  self.data:SetAutoFreeRefresh(false)
  self:ShowShoppingList()
  Event.RegisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.QUERY_BAITAN_PAGE_ITEMS_RES, PitchBuyNode.OnQueryBaitanPageRes)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.QUERY_BAITAN_PAGE_ITEMS_RES, PitchBuyNode.OnQueryBaitanPageRes)
end
def.method().UpdateTimeLabel = function(self)
  local time = GetServerTime() - self.data:GetLastFreeRefeshTime()
  local remainTime = CommercePitchUtils.GetPitchFreeRefeshTime() - time
  local str = ""
  if self.data:GetIsFreeRefesh() then
    str = textRes.Pitch[53]
  elseif remainTime >= 60 then
    local a, b = math.modf(remainTime / 60)
    str = a .. textRes.Pitch[1]
    if a < CommercePitchUtils.GetPitchFreeRefeshTime() / 60 and b >= 0 then
      str = str .. b * 60 .. textRes.Pitch[2]
    end
  elseif remainTime > 0 then
    str = remainTime .. textRes.Pitch[2]
  end
  self.uiTbl.Label_Time:GetComponent("UILabel"):set_text(str)
end
def.method().UpdateSilverMoney = function(self)
  self.uiTbl.Label_MoneyNum:GetComponent("UILabel"):set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)))
end
def.method().UpdateRefeshLabel = function(self)
  if self.data:GetIsFreeRefesh() then
    self.uiTbl.Group_MoneyRefresh:SetActive(false)
    self.uiTbl.Label_Refresh:SetActive(true)
  else
    self.uiTbl.Label_Refresh:SetActive(false)
    self.uiTbl.Group_MoneyRefresh:SetActive(true)
    self.uiTbl.Group_MoneyRefresh:FindDirect("Label_MoneyNum"):GetComponent("UILabel"):set_text(CommercePitchUtils.GetPitchRefeshNeedGold())
  end
end
def.method().UpdateGroupObjects = function(self)
  local groupGridTemplate = self.uiTbl.Table_BugList
  local groupTemplate = self.uiTbl.Tab_1
  local groupList = self.data:GetGroupList()
  local groupDVal = #groupList - self.lastGroupListNum
  if #groupList == 0 then
    groupGridTemplate:GetChild(0):SetActive(false)
  else
    groupGridTemplate:GetChild(0):SetActive(true)
  end
  if groupDVal > 0 then
    for i = 1, groupDVal do
      self.lastGroupListNum = self.lastGroupListNum + 1
      CommercePitchUtils.AddLastGroup(self.lastGroupListNum, "Tab_%d", groupGridTemplate, groupTemplate)
    end
  elseif groupDVal < 0 then
    local num = math.abs(groupDVal)
    for i = 1, num do
      local group = groupGridTemplate:GetChild(self.lastGroupListNum - 1)
      self:DestroySmallGroup(#groupList[self.lastGroupListNum].subTypeIdList, group)
      CommercePitchUtils.DeleteLastGroup(self.lastGroupListNum, "Tab_1", groupGridTemplate)
      self.lastGroupListNum = self.lastGroupListNum - 1
    end
  end
  if groupDVal > 0 then
    for i = 1, #groupList do
      local group = groupGridTemplate:GetChild(i - 1)
      self:UpdateSmallGroup(0, group)
      i = i + 1
    end
  end
  local uiGrid = groupGridTemplate:GetComponent("UITable")
  uiGrid.repositionNow = true
  self.m_base.m_msgHandler:Touch(groupGridTemplate)
  self.bIsGroupInit = true
end
def.method("number", "userdata").DestroySmallGroup = function(self, subTypeListNum, group)
  local tween = group:FindDirect("tween")
  if subTypeListNum > 1 then
    local Btn_List1 = tween:FindDirect("Btn_List1")
    Object.Destroy(Btn_List1)
  end
  local uiGrid = tween:GetComponent("UITable")
  uiGrid.repositionNow = true
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("number", "userdata").UpdateSmallGroup = function(self, subTypeListNum, group)
  local tween = group:FindDirect("tween")
  local Btn_List1 = tween:FindDirect("Btn_List1")
  if subTypeListNum > 1 then
    Btn_List1:SetActive(true)
    for i = 1, subTypeListNum do
      CommercePitchUtils.AddLastGroup(i, "Btn_List%d", tween, Btn_List1)
      i = i + 1
    end
  else
    Object.Destroy(Btn_List1)
  end
  local uiGrid = tween:GetComponent("UITable")
  uiGrid.repositionNow = true
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method().UpdateItemObjects = function(self)
  local pageCount = self.uiTbl.Grid_Page:get_childCount()
  if pageCount > 1 then
    for i = pageCount, 2, -1 do
      local page = self.uiTbl.Grid_Page:GetChild(i - 1)
      GameObject.Destroy(page)
    end
  end
  self.uiTbl.Grid_Page:GetComponent("UIGrid"):Reposition()
  self.uiTbl.Grid_Page.transform.parent.gameObject:GetComponent("UIScrollView"):ResetPosition()
end
def.method().ShowShoppingList = function(self)
  if false == self.bIsGroupInit then
    self:UpdateGroupObjects()
  end
  self.itemIndexSelect = 0
  self:FillGroupList(false)
  if 0 ~= self.lastSelectGroup then
    local lastGroup = self.uiTbl.Table_BugList:GetChild(self.lastSelectGroup - 1)
    lastGroup:FindDirect("Img_BgBuyList"):GetComponent("UIToggle"):set_isChecked(true)
    self:SelectGroup(self.lastSelectGroup)
  end
  self:UpdateTimeLabel()
  self:UpdateRefeshLabel()
  self:UpdateSilverMoney()
end
def.method().UpdateShoppingList = function(self)
  self:ShowShoppingList()
end
def.method().UpdateRequirementsCondTbl = function(self)
  self:FillGroupList(true)
  if 0 ~= self.lastSelectGroup then
    local bIsChecked = self.uiTbl.Btn_Select:GetComponent("UIToggle"):get_isChecked()
    local bUpdateObjects = false
    if bIsChecked then
      bUpdateObjects = true
    end
    self:SelectSmallGroup(self.lastSelectSmallGroup.big, self.lastSelectSmallGroup.small, bUpdateObjects)
  end
end
def.method("boolean").FillGroupList = function(self, bOnlyUpdateSign)
  local groupList = self.data:GetGroupList()
  local gridTemplate = self.uiTbl.Table_BugList
  local groupTemplate = self.uiTbl.Tab_1
  for i = 1, #groupList do
    local groupNew = gridTemplate:GetChild(i - 1)
    self:FillGroupInfo(groupList, i, groupNew, bOnlyUpdateSign)
  end
  self.lastGroupListNum = #groupList
end
def.method("table", "number", "userdata", "boolean").FillGroupInfo = function(self, groupList, index, groupNew, bOnlyUpdateSign)
  local Img_BgBuyList = groupNew:FindDirect("Img_BgBuyList")
  local Img_SignCom = Img_BgBuyList:FindDirect("Img_SignCom")
  if nil ~= CommercePitchPanel.Instance().requirementsGroup[groupList[index].ItemGroupSeq] and true == CommercePitchPanel.Instance().requirementsGroup[groupList[index].ItemGroupSeq] then
    Img_SignCom:SetActive(true)
  else
    local subType = self:GetSelSubType()
    local pages = self.data:GetShoppingListByGroup(subType)
    if pages and pages.isNeed then
      local pages = {isNeed = true}
      self.data:SetShoppingListByGroup(subType, pages)
    end
    Img_SignCom:SetActive(false)
  end
  if bOnlyUpdateSign then
    return
  end
  local Img_BgIcon = Img_BgBuyList:FindDirect("Img_BgIcon")
  local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
  local iconId = groupList[index].iconId
  GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), iconId)
  Img_BgBuyList:GetComponent("UIToggle"):set_isChecked(false)
  local tween = groupNew:FindDirect("tween")
  local Btn_List1 = tween:FindDirect("Btn_List1")
  local smalGroupList = groupList[index].subTypeIdList
  if #smalGroupList > 1 then
    tween:SetActive(false)
  else
    tween:SetActive(false)
  end
end
def.method("number", "table").ShowSmallGroupList = function(self, bigGroup, smalGroupList)
  self:UpdateItemObjects()
  self:ActivateItemBuyUI(false)
  local pageGO = self:GetPageGO(1, true)
  local Grid_BuyItem = pageGO:FindDirect("Grid_BuyItem")
  Grid_BuyItem:SetActive(true)
  local childCount = Grid_BuyItem:get_childCount()
  local maxCount = math.max(childCount - 1, #smalGroupList)
  for numIndex = 1, maxCount do
    local itemObj = self:GetBuyItemGO(numIndex, Grid_BuyItem)
    if numIndex <= #smalGroupList then
      self:FillSmallGroupInfo(smalGroupList, numIndex, itemObj, bigGroup)
    else
      GameObject.Destroy(itemObj)
    end
  end
  Grid_BuyItem:GetComponent("UIGrid"):Reposition()
  self.uiTbl.Group_Empty:SetActive(false)
  self.uiTbl.Group_Empty1:SetActive(false)
end
def.method("table", "number", "userdata", "number").FillSmallGroupInfo = function(self, groupList, index, itemObj, bigGroup)
  local Img_Sign = itemObj:FindDirect("Img_Sign")
  local requirementsGroup = CommercePitchPanel.Instance().requirementsGroup
  if nil ~= requirementsGroup[bigGroup * 100 + index] and true == requirementsGroup[bigGroup * 100 + index] then
    Img_Sign:SetActive(true)
    CommercePitchUtils.FillIcon("Img_Need", Img_Sign:GetComponent("UISprite"), 0)
  else
    Img_Sign:SetActive(false)
  end
  GUIUtils.Toggle(itemObj, false)
  local SubTypeName = self.data:GetSubTypeName(groupList[index])
  itemObj:FindDirect("Group_DetailItemInfo"):SetActive(false)
  local Label_ItemClassName = itemObj:FindDirect("Label_ItemClassName")
  GUIUtils.SetActive(Label_ItemClassName, true)
  GUIUtils.SetText(Label_ItemClassName, SubTypeName)
  local Img_BgItem = itemObj:FindDirect("Img_BgItem")
  local icon = self.data:GetSubTypeIcon(groupList[index])
  local Texture_Icon = Img_BgItem:FindDirect("Texture_Icon")
  GUIUtils.SetTexture(Texture_Icon, icon)
  local uiTexture = Texture_Icon:GetComponent("UITexture")
  if uiTexture then
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
  end
  GUIUtils.SetText(Img_BgItem:FindDirect("Label_Num"))
end
def.method("number", "boolean").UpdateSubTypeData = function(self, subType, isReset)
  local selSubType = self:GetSelSubType()
  if selSubType ~= subType then
    return
  end
  self.itemTbl = self:GetCurConditionShoppingList()
  self:FillShoppingListByGroup(false, isReset, true)
end
def.method("boolean", "boolean", "varlist").FillShoppingListByGroup = function(self, bOnlyUpdateSign, bUpdateObjects, ignoreEmpty)
  ignoreEmpty = ignoreEmpty or false
  if bUpdateObjects then
    self.curPage = 1
    self.nextPage = self.curPage
    self:UpdateItemObjects()
  end
  if nil == self.itemTbl then
    return
  end
  local itemTbl = self.itemTbl[self.curPage] or {}
  local gridTemplate = self.uiTbl.Grid_BuyItem
  local itemTemplate = gridTemplate:FindDirect("Group_BuyItem")
  itemTemplate:SetActive(false)
  if #itemTbl > 0 then
    gridTemplate:SetActive(true)
    self.uiTbl.Group_Empty:SetActive(false)
    self.uiTbl.Group_Empty1:SetActive(false)
  else
    gridTemplate:SetActive(false)
    local bIsChecked = self.uiTbl.Btn_Select:GetComponent("UIToggle"):get_isChecked()
    if bIsChecked then
      self.uiTbl.Group_Empty:SetActive(true)
      self.uiTbl.Group_Empty1:SetActive(false)
    else
      self.uiTbl.Group_Empty:SetActive(false)
      self.uiTbl.Group_Empty1:SetActive(true)
    end
  end
  self:UpdatePageInfoEx(ignoreEmpty)
end
def.method("table", "number", "userdata", "boolean").FillItemInfo = function(self, itemList, index, itemNew, bOnlyUpdateSign)
  local Group_DetailItemInfo = itemNew:FindDirect("Group_DetailItemInfo")
  Group_DetailItemInfo:SetActive(true)
  itemNew:FindDirect("Label_ItemClassName"):SetActive(false)
  local Img_Sign = itemNew:FindDirect("Img_Sign")
  local itemInfo = itemList[index]
  local itemId = itemList[index].itemid
  local Img_BgItem = itemNew:FindDirect("Img_BgItem")
  local Texture_Icon = Img_BgItem:FindDirect("Texture_Icon"):GetComponent("UITexture")
  local name, iconId = CommercePitchUtils.GetItemInfo(itemId)
  GUIUtils.FillIcon(Texture_Icon, iconId)
  if itemInfo.isUnShelve then
    Img_Sign:SetActive(true)
    CommercePitchUtils.FillIcon("Img_Sell", Img_Sign:GetComponent("UISprite"), 0)
    GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Gray)
  elseif 0 >= itemInfo.num then
    Img_Sign:SetActive(true)
    CommercePitchUtils.FillIcon("Img_Sell", Img_Sign:GetComponent("UISprite"), 0)
    GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Gray)
  elseif nil ~= CommercePitchPanel.Instance().requirementsItemTbl[itemId] or nil ~= CommercePitchPanel.Instance().requirementsCondItemId[itemId] then
    Img_Sign:SetActive(true)
    CommercePitchUtils.FillIcon("Img_Need", Img_Sign:GetComponent("UISprite"), 0)
    GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Normal)
  else
    Img_Sign:SetActive(false)
    GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Normal)
  end
  local Label_Num = Img_BgItem:FindDirect("Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(itemList[index].num)
  if bOnlyUpdateSign then
    return
  end
  local Label_ItemName = Group_DetailItemInfo:FindDirect("Label_ItemName")
  local Label_ShoppingId = Group_DetailItemInfo:FindDirect("Label_ShoppingId")
  local Label_Price = Group_DetailItemInfo:FindDirect("Label_Price")
  Label_ItemName:GetComponent("UILabel"):set_text(name)
  local priceText = CommercePitchUtils.GetPitchColoredPriceText(itemList[index].price)
  Label_Price:GetComponent("UILabel"):set_text(priceText)
  Label_ShoppingId:SetActive(false)
  if index == self.itemIndexSelect then
    self.itemIndexSelect = index
    itemNew:GetComponent("UIToggle"):set_isChecked(true)
    if index > PitchBuyNode.PerPageItemNum then
      GameUtil.AddGlobalTimer(0.01, true, function()
        if self.uiTbl.ScrollView_BuyItem and self.m_base.m_panel and false == self.m_base.m_panel.isnil then
          self.uiTbl.ScrollView_BuyItem:GetComponent("UIScrollView"):DragToMakeVisible(itemNew.transform, 10)
        end
      end)
    end
  else
    itemNew:GetComponent("UIToggle"):set_isChecked(false)
  end
end
def.method().OnCurGroupRequirementsClick = function(self)
  local groupList = self.data:GetGroupList()
  local subType = groupList[self.lastSelectSmallGroup.big].subTypeIdList[1]
  if #groupList[self.lastSelectSmallGroup.big].subTypeIdList > 1 then
    subType = groupList[self.lastSelectSmallGroup.big].subTypeIdList[self.lastSelectSmallGroup.small]
  end
  local bIsChecked = self.uiTbl.Btn_Select:GetComponent("UIToggle"):get_isChecked()
  local pageIndex = 1
  local param = self:GetSelFilterParam()
  CommercePitchProtocol.CQueryBaitanItemReq(pageIndex, subType, param)
end
def.method("=>", "number").GetSelSubType = function(self)
  local groupList = self.data:GetGroupList()
  local subType = groupList[self.lastSelectSmallGroup.big].subTypeIdList[1]
  if #groupList[self.lastSelectSmallGroup.big].subTypeIdList > 1 then
    subType = groupList[self.lastSelectSmallGroup.big].subTypeIdList[self.lastSelectSmallGroup.small] or -1
    if subType == -1 then
    end
  end
  return subType
end
def.method("=>", "number").GetDefaultSelSubType = function(self)
  local groupList = self.data:GetGroupList()
  local subType = groupList[self.lastSelectSmallGroup.big].subTypeIdList[1]
  if #groupList[self.lastSelectSmallGroup.big].subTypeIdList > 1 then
    subType = groupList[self.lastSelectSmallGroup.big].subTypeIdList[self.lastSelectSmallGroup.small]
    if subType == nil then
      subType = groupList[self.lastSelectSmallGroup.big].subTypeIdList[1] or -1
    end
  end
  return subType
end
def.static().RequireRefeshPitch = function()
end
def.method().BuySilver = function(self)
  GoToBuySilver(false)
end
def.method().ButtonRequireRefeshPitch = function(self)
  local bGoldRefesh = true
  local f = CommercePitchProtocol.CGoldRefreshShopingListReq
  if PitchData.Instance():GetIsFreeRefesh() then
    f = CommercePitchProtocol.CFreeRefreshShopingListReq
    bGoldRefesh = false
  end
  local have = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local need = CommercePitchUtils.GetPitchRefeshNeedGold()
  if bGoldRefesh and Int64.lt(have, need) then
    Toast(textRes.Pitch[11])
    return
  end
  local groupList = self.data:GetGroupList()
  local bigIndex = self.lastSelectGroup
  local smallIndex = self.lastSelectSmallGroup.small
  if smallIndex == 0 then
    smallIndex = 1
  end
  local subType = groupList[bigIndex].subTypeIdList[smallIndex]
  local bIsChecked = self.uiTbl.Btn_Select:GetComponent("UIToggle"):get_isChecked()
  local param = self:GetSelFilterParam()
  f(subType, param)
  PitchData.Instance():SetOnceFinished(false)
end
def.static("number", "table").BuySilverCallback = function(i, tag)
  if 1 == i then
    local dlg = tag.id
    dlg:BuySilver()
  elseif 0 == i then
    return
  end
end
def.method("table").OnBuyItemRes = function(self, p)
  local buyRes = p.buy_res
  local shoppingid = p.shoppingid
  local SBuyItemRes = require("netio.protocol.mzm.gsp.baitan.SBuyItemRes")
  local itemInfo = self.data:GetShoppingInfoByIndexAndId(p.index, p.itemid)
  if itemInfo == nil then
    return
  end
  if SBuyItemRes.SUCCESS == buyRes then
    self:ShowSuccessBuyMessage(p.itemid, 1, p.useMoney)
    self:SyncPageItemStatus(p.index, p.itemid, itemInfo)
  elseif SBuyItemRes.ALL_SELLED == buyRes then
    Toast(textRes.Pitch[4])
    self:SyncPageItemStatus(p.index, p.itemid, itemInfo)
  elseif SBuyItemRes.NOT_ENOUGH_MONEY == buyRes then
  elseif SBuyItemRes.NOT_IN_SELL == buyRes then
    Toast(textRes.Pitch[6])
    self:SyncPageItemStatus(p.index, p.itemid, itemInfo)
  end
end
def.method("number", "number", "number").ShowSuccessBuyMessage = function(self, itemid, num, useMoney)
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemid)
  local namenum = string.format("%sx%d", itemBase.name, num)
  local money = useMoney
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.CommonMsg(PersonalHelper.Type.ColorText, textRes.Common[44], "ffffff", PersonalHelper.Type.ColorText, namenum, "ffff00", PersonalHelper.Type.ColorText, textRes.Common.comma .. textRes.Common[45], "ffffff", PersonalHelper.Type.Silver, money)
end
def.method("number", "number", "table").SyncPageItemStatus = function(self, index, itemId, itemInfo)
  local function getItemOffsetIndex(index, itemId)
    local pos = self.data:GetItemPosByIndexAndId(index, itemId)
    if pos == nil then
      return -1
    end
    local subType = self:GetSelSubType()
    if subType ~= pos.subType then
      return 0
    end
    local param = self:GetSelFilterParam()
    if param ~= pos.param then
      return 0
    end
    if self.curPage ~= pos.pageIndex then
      return 0
    end
    return pos.offIndex
  end
  local offIndex = getItemOffsetIndex(index, itemId)
  if offIndex <= 0 then
    return
  end
  local page = self:GetPageGO(1, false)
  local Grid_BuyItem = page:FindDirect("Grid_BuyItem")
  local numIndex = offIndex
  local groupCount = Grid_BuyItem:get_childCount()
  if numIndex < groupCount then
    local item = Grid_BuyItem:GetChild(numIndex)
    if nil ~= item and nil ~= itemInfo then
      local Img_BgItem = item:FindDirect("Img_BgItem")
      local Label_Num = Img_BgItem:FindDirect("Label_Num")
      Label_Num:GetComponent("UILabel"):set_text(itemInfo.num)
      if 0 == itemInfo.num then
        local Img_Sign = item:FindDirect("Img_Sign")
        Img_Sign:SetActive(true)
        CommercePitchUtils.FillIcon("Img_Sell", Img_Sign:GetComponent("UISprite"), 0)
        local Img_BgItem = item:FindDirect("Img_BgItem")
        local Texture_Icon = Img_BgItem:FindDirect("Texture_Icon"):GetComponent("UITexture")
        GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Gray)
      elseif itemInfo.isUnShelve then
        local Img_Sign = item:FindDirect("Img_Sign")
        Img_Sign:SetActive(true)
        CommercePitchUtils.FillIcon("Img_Sell", Img_Sign:GetComponent("UISprite"), 0)
        local Img_BgItem = item:FindDirect("Img_BgItem")
        local Texture_Icon = Img_BgItem:FindDirect("Texture_Icon"):GetComponent("UITexture")
        GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Gray)
      end
    end
  end
end
def.method("number").OnCommonResultRes = function(self, res)
end
def.method().OnBuyItemClick = function(self)
  if 0 ~= self.itemIndexSelect then
    local level = require("Main.Hero.Interface").GetHeroProp().level
    if level < CommercePitchUtils.GetPitchOpenLevel() then
      Toast(string.format(textRes.Commerce[17], CommercePitchUtils.GetPitchOpenLevel()))
      return
    end
    local itemList = self:GetCurConditionShoppingList()[self.curPage]
    local silver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
    if itemList[self.itemIndexSelect] then
      local _ = itemList[self.itemIndexSelect]
      if 0 >= _.num then
        Toast(textRes.Pitch[4])
        return
      end
      if Int64.lt(silver, itemList[self.itemIndexSelect].price) then
        local tag = {id = self}
        CommonConfirmDlg.ShowConfirm("", textRes.Pitch[5], PitchBuyNode.BuySilverCallback, tag)
        return
      end
      local _ = itemList[self.itemIndexSelect]
      CommercePitchProtocol.CBuyItemReq(_.index, _.itemid, _.num, _.price)
      self.itemBuyInfo = {}
      self.itemBuyInfo.index = _.index
      self.itemBuyInfo.info = itemList[self.itemIndexSelect]
    else
      warn("pitch buy node itemclick error itemIndexSelect = ", self.itemIndexSelect)
    end
    if CommercePitchModule.Instance().showByTask == true then
      CommercePitchPanel.Instance():DestroyPanel()
      CommercePitchModule.Instance().showByTask = false
    end
  else
    Toast(textRes.Commerce[15])
  end
end
def.method("userdata").OnSelectGroup = function(self, clickobj)
  CommercePitchModule.Instance().selectPitchItemId = 0
  CommercePitchModule.Instance().selectPitchItemIds = {}
  self.itemIndexSelect = 0
  local id = clickobj.parent.name
  local index = tonumber(string.sub(id, string.len("Tab_") + 1))
  self.lastSelectGroup = index
  CommercePitchModule.Instance().lastPitchBigGroup = self.lastSelectGroup
  self.lastSelectSmallGroup.big = index
  self.lastSelectSmallGroup.small = 0
  CommercePitchModule.Instance().lastPitchSmallGroup = self.lastSelectSmallGroup
  self:UpdateFilterOption()
  self:SelectGroup(index)
  if index > 4 then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if self.m_base.m_panel and false == self.m_base.m_panel.isnil then
        local groupItem = self.uiTbl.Table_BugList:GetChild(index - 1)
        if groupItem then
          self.uiTbl.ScrollView_BugList:GetComponent("UIScrollView"):DragToMakeVisible(groupItem.transform, 10)
        end
      end
    end)
  end
end
def.method("number").SelectGroup = function(self, index)
  local groupList = self.data:GetGroupList()
  if #groupList[index].subTypeIdList > 1 and self.lastSelectSmallGroup.small <= 0 then
    self:ShowSmallGroupList(index, groupList[index].subTypeIdList)
  elseif #groupList[index].subTypeIdList > 0 then
    self:SelectSmallGroup(self.lastSelectSmallGroup.big, self.lastSelectSmallGroup.small, true)
  else
    self.itemTbl = nil
    self:FillShoppingListByGroup(false, true)
  end
end
def.method().UpdateFilterOption = function(self)
  self.lastSelectSmallGroup.filterIndex = 0
  if self.lastSelectGroup == EQUIPMENT_BIG_GROUP then
    local selSubType = self:GetDefaultSelSubType()
    local targetLevel
    if next(CommercePitchModule.Instance().selectPitchItemIds) ~= nil then
      local itemId = next(CommercePitchModule.Instance().selectPitchItemIds)
      local itemBase = ItemUtils.GetItemBase(itemId)
      if itemBase then
        targetLevel = itemBase.useLevel
      end
    end
    if self.data.subTypeList[selSubType] and targetLevel == nil then
      local subInfo
      for i, v in ipairs(self.data.subTypeList[selSubType]) do
        if nil ~= CommercePitchPanel.Instance().requirementsItemTbl[v.idValue] or nil ~= CommercePitchPanel.Instance().requirementsCondItemId[v.idValue] then
          subInfo = v
          break
        end
      end
      if subInfo and subInfo.idType == IdType.ITEMID then
        local itemId = subInfo.idValue or 0
        local itemBase = ItemUtils.GetItemBase(itemId)
        if itemBase then
          targetLevel = itemBase.useLevel
        end
      elseif 0 < #self.data.subTypeList[selSubType] and self.data.subTypeList[selSubType][1].idType == IdType.EQUIPITEMSHIFTID then
        local equipSiftCondId = self.data.subTypeList[selSubType][1].idValue
        local siftCondCfg = ItemUtils.GetEquipSiftCondCfg(equipSiftCondId)
        if siftCondCfg then
          local isEqual = function(a, b)
            if a == 0 then
              return true
            end
            return a == b
          end
          for k, v in pairs(CommercePitchPanel.Instance().requirementsCondTbl) do
            local filterCfg = ItemUtils.GetItemFilterCfg(k)
            for kk, vv in pairs(filterCfg.siftCfgs) do
              if vv.idtype == 2 then
                local reqSiftCondCfg = ItemUtils.GetEquipSiftCondCfg(vv.idvalue)
                if reqSiftCondCfg and isEqual(reqSiftCondCfg.wearPos, siftCondCfg.wearPos) and isEqual(reqSiftCondCfg.menPai, siftCondCfg.menPai) and isEqual(reqSiftCondCfg.sex, siftCondCfg.sex) then
                  targetLevel = reqSiftCondCfg.minUseLevel
                  break
                end
              end
            end
            if targetLevel ~= nil then
              break
            end
          end
        end
      end
    end
    local conditions = PitchData.Instance():GetEquipFilterConditions()
    local items = {}
    local isSet = false
    for i, v in ipairs(conditions) do
      items[i] = v.name
      if v.default and not isSet then
        self.lastSelectSmallGroup.filterIndex = i
      end
      if targetLevel and v.param == targetLevel then
        self.lastSelectSmallGroup.filterIndex = i
        isSet = true
      end
    end
    self.filterCondistions = conditions
    self.uiTbl.Btn_Lv_Menu:SetActive(true)
    local popupList = self.uiTbl.Btn_Lv_Menu:GetComponent("UIPopupList")
    popupList.items = items
    popupList.selectIndex = self.lastSelectSmallGroup.filterIndex - 1
    popupList.value = items[self.lastSelectSmallGroup.filterIndex]
  else
    self.uiTbl.Btn_Lv_Menu:SetActive(false)
    self.filterCondistions = {}
  end
end
def.method("=>", "number").GetSelFilterParam = function(self)
  local filterIndex = self.lastSelectSmallGroup.filterIndex
  filterIndex = filterIndex or 0
  local condition = self.filterCondistions[filterIndex]
  if condition then
    return condition.param
  else
    return 0
  end
end
def.method("number").ClickSmallGroup = function(self, smallIndex)
  local bigIndex = self.lastSelectGroup
  self.lastSelectSmallGroup.big = bigIndex
  self.lastSelectSmallGroup.small = smallIndex
  CommercePitchModule.Instance().lastPitchSmallGroup = self.lastSelectSmallGroup
  self.groupInfo = self.lastSelectSmallGroup.big .. "_" .. self.lastSelectSmallGroup.small
  CommercePitchModule.Instance().lastPitchGroupInfo = self.groupInfo
  self:UpdateFilterOption()
  self:SelectSmallGroup(bigIndex, smallIndex, true)
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self.m_base.m_panel and false == self.m_base.m_panel.isnil then
      self.uiTbl.ScrollView_BuyItem:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method("number", "number", "boolean").SelectSmallGroup = function(self, bigIndex, smallIndex, bUpdateObjects)
  local itemList = self:GetCurConditionShoppingList()
  self.itemTbl = itemList
  self:FillShoppingListByGroup(false, bUpdateObjects)
end
def.method("number").OnSelectItem = function(self, index)
  self.itemIndexSelect = index
end
def.method("userdata").OnClickItemTips = function(self, clickobj)
  if self.bIsDisplaySmallGroup then
    self:OnGroupBuyItemClick(clickobj.parent)
    return
  end
  local obj = clickobj.parent
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  local index = tonumber(string.sub(clickobj.parent.name, string.len("Group_BuyItem0") + 1))
  local itemList = self:GetCurConditionShoppingList()[self.curPage]
  if itemList[index].item ~= nil then
    ItemTipsMgr.Instance():ShowTips(itemList[index].item, 0, 0, 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
    self.selectItemTipsInfo = nil
  else
    self.selectItemTipsInfo = {}
    self.selectItemTipsInfo.shoppingid = tostring(itemList[index].index) .. "_" .. tostring(itemList[index].itemid)
    self.selectItemTipsInfo.screenPosX = screenPos.x
    self.selectItemTipsInfo.screenPosY = screenPos.y
    self.selectItemTipsInfo.width = sprite:get_width()
    self.selectItemTipsInfo.height = sprite:get_height()
    CommercePitchProtocol.CQueryItemReq(itemList[index].index, itemList[index].itemid, itemList[index].num, itemList[index].price)
  end
end
def.method("number", "table").ShowPitchItemTips = function(self, index, itemInfo)
  if self.selectItemTipsInfo ~= nil then
    local shoppingid = tostring(index) .. "_" .. tostring(itemInfo.id)
    if self.selectItemTipsInfo.shoppingid == shoppingid then
      ItemTipsMgr.Instance():ShowTips(itemInfo, 0, 0, 0, self.selectItemTipsInfo.screenPosX, self.selectItemTipsInfo.screenPosY, self.selectItemTipsInfo.width, self.selectItemTipsInfo.height, -1)
      self.selectItemTipsInfo = nil
    end
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Img_BgBuyList") then
    self:OnSelectGroup(clickobj)
  elseif string.find(id, "Btn_List") then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      self:OnSmallGroupClick(clickobj)
    else
      clickobj:GetComponent("UIToggle"):set_isChecked(true)
    end
  elseif string.find(id, "Group_BuyItem0") then
    self:OnGroupBuyItemClick(clickobj)
  elseif "Btn_Select" == id then
    self:OnCurGroupRequirementsClick()
  elseif "Btn_Refresh" == id then
    self:ButtonRequireRefeshPitch()
  elseif "Btn_Buy" == id then
    self:OnBuyItemClick()
  elseif "Img_BgItem" == id then
    self:OnClickItemTips(clickobj)
  elseif "Btn_Back" == id then
    self:OnBackPageClick()
  elseif "Btn_Next" == id then
    self:OnNextPageClick()
  end
end
def.method().OnBackPageClick = function(self)
  if self.itemTbl == nil or self.itemTbl.totalPage == nil then
    Toast(textRes.Pitch[33])
    return
  end
  if self.curPage > 1 then
    self.nextPage = self.curPage - 1
    self:UpdatePageInfo()
  else
    Toast(textRes.Pitch[31])
  end
end
def.method().OnNextPageClick = function(self)
  if self.itemTbl == nil or self.itemTbl.totalPage == nil then
    Toast(textRes.Pitch[33])
    return
  end
  local pageCount = self.itemTbl.totalPage
  if pageCount >= self.curPage + 1 then
    self.nextPage = self.curPage + 1
    self:UpdatePageInfo()
  else
    Toast(textRes.Pitch[32])
  end
end
def.override("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
end
def.override("string", "string", "number").onSelect = function(self, id, selected, index)
  if id == "Btn_Lv_Menu" and index > -1 then
    self.lastSelectSmallGroup.filterIndex = index + 1
    if not self.bIsDisplaySmallGroup and self:GetSelSubType() ~= -1 then
      local bOnlyUpdateSign = false
      local isReset = true
      self.itemTbl = self:GetCurConditionShoppingList()
      self:FillShoppingListByGroup(bOnlyUpdateSign, isReset)
    end
  end
end
def.override("string").onDragStart = function(self, id)
end
def.override("string").onDragEnd = function(self, id)
  if not self.bIsDisplaySmallGroup and (string.find(id, "Group_BuyItem0") or string.find(id, "Img_BgItem")) then
    self:DragScrollView()
  end
end
def.method().DragScrollView = function(self)
  local dragAmount = self.uiTbl.ScrollView_BuyItem:GetComponent("UIScrollView"):GetDragAmount()
  if dragAmount.y > 1.1 then
    self:OnNextPageClick()
  elseif dragAmount.y < -0.1 then
    self:OnBackPageClick()
  end
end
def.method("userdata").OnGroupBuyItemClick = function(self, clickobj)
  local index = tonumber(string.sub(clickobj.name, string.len("Group_BuyItem0")))
  if self.bIsDisplaySmallGroup then
    clickobj:GetComponent("UIToggle").value = false
    self:ClickSmallGroup(index)
  elseif clickobj:GetComponent("UIToggle"):get_isChecked() then
    self:OnSelectItem(index)
  else
    self.itemIndexSelect = 0
  end
end
def.method().UpdatePageInfo = function(self, ignoreEmpty)
  local ignoreEmpty = false
  self:UpdatePageInfoEx(ignoreEmpty)
end
def.method("boolean").UpdatePageInfoEx = function(self, ignoreEmpty)
  local curPage = self.curPage
  local pageCount = self.itemTbl.totalPage
  if pageCount == nil or pageCount == 0 then
    curPage = 1
    pageCount = 1
  end
  self.uiTbl.Label_Page:GetComponent("UILabel"):set_text(string.format("%d/%d", curPage, pageCount))
  self:ActivateItemBuyUI(true)
  local itemTbl = self.itemTbl[self.nextPage]
  if itemTbl == nil then
    if ignoreEmpty then
      return
    end
    local subType = self:GetSelSubType()
    local param = self:GetSelFilterParam()
    CommercePitchProtocol.CQueryBaitanItemReq(self.nextPage, subType, param)
    return
  end
  if self.itemIndexSelect > #itemTbl then
    self.itemIndexSelect = 0
  end
  if self.itemIndexSelect == 0 and #itemTbl > 0 then
    local priceSortItems = {}
    for i, v in ipairs(itemTbl) do
      table.insert(priceSortItems, {index = i, v = v})
    end
    table.sort(priceSortItems, function(left, right)
      if left.v.price == right.v.price then
        return left.index < right.index
      else
        return left.v.price < right.v.price
      end
    end)
    self.itemIndexSelect = priceSortItems[1].index
    for i, v in ipairs(priceSortItems) do
      if CommercePitchModule.Instance().selectPitchItemIds[v.v.itemid] then
        self.itemIndexSelect = v.index
        break
      end
    end
  end
  local pageIndex = self.nextPage
  self.curPage = self.nextPage
  local page = self:GetPageGO(1, true)
  local Grid_BuyItem = page:FindDirect("Grid_BuyItem")
  Grid_BuyItem:SetActive(true)
  local childCount = Grid_BuyItem:get_childCount()
  local maxCount = math.max(childCount - 1, #itemTbl)
  local needResetPosition = false
  for numIndex = 1, maxCount do
    local itemObj = self:GetBuyItemGO(numIndex, Grid_BuyItem)
    if numIndex <= #itemTbl then
      local bOnlyUpdateSign = false
      self:FillItemInfo(itemTbl, numIndex, itemObj, bOnlyUpdateSign)
    else
      needResetPosition = true
      GameObject.Destroy(itemObj)
    end
  end
  self.uiTbl.Label_Page:GetComponent("UILabel"):set_text(string.format("%d/%d", pageIndex, pageCount))
  Grid_BuyItem:GetComponent("UIGrid"):Reposition()
  if needResetPosition then
    self.uiTbl.ScrollView_BuyItem:GetComponent("UIScrollView"):ResetPosition()
  end
end
def.method("boolean").ActivateItemBuyUI = function(self, isActive)
  self.uiTbl.Group_BtnBuy:SetActive(isActive)
  self.bIsDisplaySmallGroup = not isActive
end
def.method("number", "boolean", "=>", "userdata").GetPageGO = function(self, pageIndex, createWhenMissing)
  local itemPageName = string.format("Page%02d", pageIndex)
  local itemPage = self.uiTbl.Grid_Page:FindDirect(itemPageName)
  if itemPage == nil and createWhenMissing then
    local pageCount = self.uiTbl.Grid_Page:get_childCount()
    local itemPageTemplate = self.uiTbl.Page01
    itemPage = GameObject.Instantiate(itemPageTemplate)
    itemPage.name = itemPageName
    itemPage.parent = self.uiTbl.Grid_Page
    itemPage:set_localScale(Vector.Vector3.one)
    self.uiTbl.Grid_Page:GetComponent("UIGrid"):Reposition()
    for i = pageCount - 1, 0, -1 do
      local pageGO = self.uiTbl.Grid_Page:GetChild(i)
      local pi = tonumber(string.sub(pageGO.name, 5, 6))
      if pageIndex > pi then
        itemPage.transform:SetSiblingIndex(i + 1)
        break
      end
    end
    local Grid_BuyItem = itemPage:FindDirect("Grid_BuyItem")
    Grid_BuyItem:SetActive(false)
  end
  return itemPage
end
def.method("number", "userdata", "=>", "userdata").GetBuyItemGO = function(self, numIndex, parentGO)
  local itemName = string.format("Group_BuyItem0%d", numIndex)
  local item = parentGO:FindDirect(itemName)
  if item == nil then
    local itemTemplate = parentGO:FindDirect("Group_BuyItem")
    itemTemplate:SetActive(false)
    item = GameObject.Instantiate(itemTemplate)
    item.name = itemName
    item.parent = parentGO
    item:set_localScale(Vector.Vector3.one)
    item:SetActive(true)
  end
  self.m_base.m_msgHandler:Touch(item)
  return item
end
def.method("=>", "table").GetCurConditionShoppingList = function(self)
  local subType = self:GetSelSubType()
  local param = self:GetSelFilterParam()
  return self.data:GetShoppingListByGroupAndParam(subType, param)
end
def.static("table", "table").OnQueryBaitanPageRes = function(params, context)
  local CommercePitchPanel = require("Main.CommerceAndPitch.ui.CommercePitchPanel")
  local instance = CommercePitchPanel.Instance()
  if instance.m_panel == nil or instance.m_panel.isnil then
    return
  end
  if instance.curNode ~= CommercePitchPanel.NodeId.PITCH then
    return
  end
  local PitchPanelNode = require("Main.CommerceAndPitch.ui.PitchPanelNode")
  if instance.nodes[instance.curNode].curNode ~= PitchPanelNode.NodeId.BUY then
    return
  end
  local self = instance.nodes[instance.curNode].nodes[PitchPanelNode.NodeId.BUY]
  local subType, isReset = params[1], params[2]
  self:UpdateSubTypeData(subType, isReset)
end
PitchBuyNode.Commit()
return PitchBuyNode

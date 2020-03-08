local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local CommerceNode = Lplus.Extend(TabNode, "CommerceNode")
local def = CommerceNode.define
local CommerceData = require("Main.CommerceAndPitch.data.CommerceData")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local ItemModule = require("Main.Item.ItemModule")
local CommercePitchModule = Lplus.ForwardDeclare("CommercePitchModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local TaskInterface = require("Main.task.TaskInterface")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local ItemUtils = require("Main.Item.ItemUtils")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommercePitchPanel = Lplus.ForwardDeclare("CommercePitchPanel")
def.field(CommerceData).data = nil
def.field("table").uiTbl = nil
def.field("number").lastGroupListNum = 0
def.field("number").lastBagListNum = 0
def.field("number").lastSelectGroup = 0
def.field("table").lastSelectSmallGroup = nil
def.field("number").lastSelectItemIndex = 0
def.field("number").selectBuyItemId = 0
def.field("number").selectSellItemIndex = 0
def.field("string").groupInfo = ""
def.field("table").itemTbl = nil
def.field("number").curPage = 0
def.field("number").maxPage = 0
def.field("number").curSubTypeId = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.data = CommerceData.Instance()
  self.data:InitData()
  self.uiTbl = CommercePitchUtils.FillCommerceUI(self.uiTbl, self.m_node)
  self.lastSelectGroup = CommercePitchModule.Instance().lastCommerceBigGroup
  self.lastSelectSmallGroup = CommercePitchModule.Instance().lastCommerceSmallGroup
  self.groupInfo = CommercePitchModule.Instance().lastCommerceGroupInfo
  local groupList = self.data:GetGroupList()
  if CommercePitchModule.Instance().lastCommerceBigGroup == 0 then
    self.lastSelectGroup = 1
    if CommercePitchModule.Instance().lastCommerceSmallGroup == nil then
      self.lastSelectSmallGroup = {}
      if #groupList[self.lastSelectGroup].subTypeIdList == 1 then
        self.lastSelectSmallGroup.big = self.lastSelectGroup
        self.lastSelectSmallGroup.small = 0
      else
        self.lastSelectSmallGroup.big = self.lastSelectGroup
        self.lastSelectSmallGroup.small = 1
      end
      CommercePitchModule.Instance().lastCommerceSmallGroup = self.lastSelectSmallGroup
      self.groupInfo = self.lastSelectSmallGroup.big .. "_" .. self.lastSelectSmallGroup.small
      CommercePitchModule.Instance().lastCommerceGroupInfo = self.groupInfo
    end
  end
  local small = self.lastSelectSmallGroup.small
  if #groupList[self.lastSelectSmallGroup.big].subTypeIdList == 1 then
    small = 1
  end
  local page = 1
  local itemId = CommercePitchModule.Instance().selectCommerceItemId
  if itemId > 0 then
    page = self.data:GetItemPage(self.lastSelectSmallGroup.big, small, itemId)
  end
  self.itemTbl, self.curPage, self.maxPage, self.curSubTypeId = self.data:GetItemList(self.lastSelectSmallGroup.big, small, page)
end
def.override().OnShow = function(self)
  if CommercePitchPanel.Instance().bigGroup ~= 0 and CommercePitchPanel.Instance().stateByTask == CommercePitchPanel.StateConst.Commerce then
    self.lastSelectGroup = CommercePitchPanel.Instance().bigGroup
    self.lastSelectSmallGroup.big = CommercePitchPanel.Instance().bigGroup
    self.lastSelectSmallGroup.small = CommercePitchPanel.Instance().smallGroup
    CommercePitchModule.Instance().lastCommerceSmallGroup = self.lastSelectSmallGroup
    CommercePitchModule.Instance().lastCommerceBigGroup = self.lastSelectGroup
    self.groupInfo = self.lastSelectSmallGroup.big .. "_" .. self.lastSelectSmallGroup.small
    CommercePitchModule.Instance().lastCommerceGroupInfo = self.groupInfo
  end
  self:RefeshCommerce()
  self:ShowCommerceList()
  self:UpdateGoldMoney()
end
def.override().OnHide = function(self)
end
def.method().UpdateGoldMoney = function(self)
  self.uiTbl.Label_BagMoneyNum:GetComponent("UILabel"):set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)))
end
def.method().UpdateRequirementsCondTbl = function(self)
  self:FillGroupList()
  if 0 ~= self.lastSelectGroup then
    self:SelectGroup(self.lastSelectGroup)
    self:SelectSmallGroup(self.curPage)
  end
end
def.method().UpdateGroupObjects = function(self)
  local groupGridTemplate = self.uiTbl.Table_List
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
      self:UpdateSmallGroup(#groupList[i].subTypeIdList, group)
      i = i + 1
    end
  end
  warn("UpdateGroupObjects   " .. self.lastGroupListNum)
  local uiGrid = groupGridTemplate:GetComponent("UITable")
  uiGrid.repositionNow = true
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
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
  local subList = self.itemTbl
  local uiList = self.uiTbl.Grid_BgComItem:GetComponent("UIList")
  uiList:set_itemCount(#subList)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method().UpdateBagItemsObjects = function(self)
  local bagItemList = self.data:GetCommerceItems()
  local itemDVal = #bagItemList - self.lastBagListNum
  local itemGridTemplate = self.uiTbl.Grid_Bag
  local itemTemplate = self.uiTbl.Img_BgBagItem01
  if #bagItemList > 0 then
    self.uiTbl.Group_NoItem:SetActive(false)
  else
    self.uiTbl.Group_NoItem:SetActive(true)
  end
  if itemDVal > 0 then
    for i = 1, itemDVal do
      self.lastBagListNum = self.lastBagListNum + 1
      CommercePitchUtils.AddLastGroup(self.lastBagListNum, "Img_BgBagItem0%d", itemGridTemplate, itemTemplate)
    end
  elseif itemDVal < 0 then
    local num = math.abs(itemDVal)
    for i = 1, num do
      CommercePitchUtils.DeleteLastGroup(self.lastBagListNum, "Img_BgBagItem01", itemGridTemplate)
      self.lastBagListNum = self.lastBagListNum - 1
    end
  elseif itemDVal == 0 and #bagItemList == 0 then
    itemTemplate:SetActive(false)
  end
  local uiGrid = itemGridTemplate:GetComponent("UIGrid")
  uiGrid.repositionNow = true
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method().ShowCommerceList = function(self)
  self:UpdateGroupObjects()
  self:CommerceItemsUpdate()
  self:CommerceBagsUpdate()
end
def.method().FillBag = function(self)
  local itemKeys = self.data:GetCommerceItems()
  if 0 == #itemKeys then
    return
  end
  local grid = self.uiTbl.Grid_Bag
  for i = 1, #itemKeys do
    local item = grid:GetChild(i - 1)
    self:FillBagInfo(itemKeys, i, item)
  end
  self.lastBagListNum = #itemKeys
end
def.method("table", "number", "userdata").FillBagInfo = function(self, itemKeys, index, item)
  local key = itemKeys[index]
  local items = self.data:GetCommerceItemInfo(key)
  local Texture_BagIcon = item:FindDirect("Texture_BagIcon")
  local Label_Num = item:FindDirect("Label_Num")
  GUIUtils.FillIcon(Texture_BagIcon:GetComponent("UITexture"), items.itemBase.icon)
  Label_Num:GetComponent("UILabel"):set_text(items.count)
end
def.method().FillGroupList = function(self)
  local groupGridTemplate = self.uiTbl.Table_List
  local groupTemplate = self.uiTbl.Tab_1
  local groupList = self.data:GetGroupList()
  for i = 1, #groupList do
    local groupNew = groupGridTemplate:GetChild(i - 1)
    self:FillGroupInfo(groupList, i, groupNew)
  end
  self.lastGroupListNum = #groupList
end
def.method("table", "number", "userdata").FillGroupInfo = function(self, groupList, index, groupNew)
  local Img_BgComList = groupNew:FindDirect("Img_BgComList")
  local Img_SignCom = Img_BgComList:FindDirect("Img_SignCom")
  local requirementsCommerceGroup = CommercePitchPanel.Instance().requirementsCommerceGroup
  if nil ~= requirementsCommerceGroup[index] and true == requirementsCommerceGroup[index] then
    Img_SignCom:SetActive(true)
  else
    Img_SignCom:SetActive(false)
  end
  local Img_BgIcon = Img_BgComList:FindDirect("Img_BgIcon")
  local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
  local iconId = groupList[index].BigTypeIcon
  GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), iconId)
  Img_BgComList:GetComponent("UIToggle"):set_isChecked(false)
  local tween = groupNew:FindDirect("tween")
  local Btn_List1 = tween:FindDirect("Btn_List1")
  local smalGroupList = groupList[index].subTypeIdList
  if #smalGroupList > 1 then
    tween:SetActive(false)
    Btn_List1:SetActive(true)
    for i = 1, #smalGroupList do
      local groupNew = tween:GetChild(i - 1)
      self:FillSmallGroupInfo(smalGroupList, i, groupNew, index)
    end
  else
    tween:SetActive(false)
  end
end
def.method("table", "number", "userdata", "number").FillSmallGroupInfo = function(self, groupList, index, groupNew, bigGroup)
  local Label_BtnList = groupNew:FindDirect("Label_BtnList")
  local Img_Sign = groupNew:FindDirect("Img_Sign")
  local requirementsCommerceGroup = CommercePitchPanel.Instance().requirementsCommerceGroup
  if nil ~= requirementsCommerceGroup[bigGroup * 100 + index] and true == requirementsCommerceGroup[bigGroup * 100 + index] then
    Img_Sign:SetActive(true)
  else
    Img_Sign:SetActive(false)
  end
  local SubTypeName = self.data:GetSubTypeName(groupList[index])
  Label_BtnList:GetComponent("UILabel"):set_text(SubTypeName)
  groupNew:GetComponent("UIToggle"):set_isChecked(false)
end
def.method("table").FillItemList = function(self, itemList)
  self:UpdateItemObjects()
  local labelPage = self.uiTbl.Label_Page
  if nil == itemList then
    labelPage:GetComponent("UILabel"):set_text("0/0")
    return
  end
  labelPage:GetComponent("UILabel"):set_text(string.format("%d/%d", self.curPage, self.maxPage))
  local uiList = self.uiTbl.Grid_BgComItem:GetComponent("UIList")
  local itemsUI = uiList:get_children()
  for i = 1, #itemList do
    local item = itemsUI[i]
    self:FillItemInfo(itemList, i, item)
  end
end
def.method("table", "number", "userdata").FillItemInfo = function(self, itemList, index, item)
  local Img_ComSign = item:FindDirect(string.format("Img_ComSign_%d", index))
  local Img_BgComItem = item:FindDirect(string.format("Img_BgComItem_%d", index))
  local Texture_ComIcon = Img_BgComItem:FindDirect(string.format("Texture_ComIcon_%d", index))
  local Label_ComItemName = item:FindDirect(string.format("Label_ComItemName_%d", index))
  local Label_ComPrice = item:FindDirect(string.format("Label_ComPrice_%d", index))
  local Group_UpDown = item:FindDirect(string.format("Group_UpDown_%d", index))
  local Img_Arrow = Group_UpDown:FindDirect(string.format("Img_Arrow_%d", index))
  local Img_Equal = Group_UpDown:FindDirect(string.format("Img_Equal_%d", index))
  local Label_Percent = Group_UpDown:FindDirect(string.format("Label_Percent_%d", index))
  local itemId = itemList[index]
  if itemId == CommercePitchModule.Instance().selectCommerceItemId or itemId == self.selectBuyItemId then
    local commerceItem = CommercePitchUtils.GetCommerceItemInfo(itemId)
    local showGroupBtn = commerceItem and not commerceItem.isPriceFlow
    self.uiTbl.Btn_Buy:SetActive(not showGroupBtn)
    self.uiTbl.Group_Btn:SetActive(showGroupBtn)
    item:GetComponent("UIToggle"):set_isChecked(true)
    self.selectBuyItemId = itemId
    if index > 4 then
      GameUtil.AddGlobalTimer(0, true, function()
        if itemId == CommercePitchModule.Instance().selectCommerceItemId and self.m_base.m_panel and false == self.m_base.m_panel.isnil then
          self.uiTbl.ScrollView_BgComItem:GetComponent("UIScrollView"):DragToMakeVisible(item.transform, 10)
        end
        CommercePitchModule.Instance().selectCommerceItemId = 0
      end)
    else
      CommercePitchModule.Instance().selectCommerceItemId = 0
    end
  else
    item:GetComponent("UIToggle"):set_isChecked(false)
  end
  local requirementsCommerceCondItemId = CommercePitchPanel.Instance().requirementsCommerceCondItemId
  if nil ~= requirementsCommerceCondItemId[itemId] and true == requirementsCommerceCondItemId[itemId] then
    Img_ComSign:SetActive(true)
  else
    Img_ComSign:SetActive(false)
  end
  local itemBase = ItemUtils.GetItemBase(itemId)
  local eqpBase = require("Main.Equip.EquipUtils").GetEquipMakeMaterialInfo(itemId)
  GUIUtils.FillIcon(Texture_ComIcon:GetComponent("UITexture"), itemBase.icon)
  Label_ComItemName:GetComponent("UILabel"):set_text(itemBase.name)
  local prop = require("Main.Hero.Interface").GetHeroProp()
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  Label_ComItemName:GetComponent("UILabel"):set_textColor(Color.Color(0.56, 0.24, 0.13, 1))
  if eqpBase and (eqpBase.sex == prop.gender and eqpBase.menpai == prop.occupation or eqpBase.sex == gender.ALL and eqpBase.menpai == prop.occupation or eqpBase.sex == prop.gender and eqpBase.menpai == occupation.ALL or eqpBase.sex == gender.ALL and eqpBase.menpai == occupation.ALL) then
    Label_ComItemName:GetComponent("UILabel"):set_textColor(Color.Color(0.22, 0.54, 0.22, 1))
  end
  local itemInfo = self.data:GetItemInfo(itemId)
  if nil == itemInfo then
    warn("itemId have no price ", itemId)
    Label_ComPrice:GetComponent("UILabel"):set_text("--")
    Img_Equal:SetActive(true)
    Label_Percent:SetActive(false)
    Img_Arrow:SetActive(false)
    return
  end
  Label_ComPrice:GetComponent("UILabel"):set_text(itemInfo.price)
  local extent = itemInfo.rise / 10000 * 100
  extent = tonumber(string.format("%0.2f", extent))
  if extent > 0 then
    Img_Equal:SetActive(false)
    Label_Percent:SetActive(true)
    Img_Arrow:SetActive(true)
    Label_Percent:GetComponent("UILabel"):set_text(math.abs(extent) .. "%")
    CommercePitchUtils.FillIcon("Img_Up", Img_Arrow:GetComponent("UISprite"), 1)
  elseif extent < 0 then
    Img_Equal:SetActive(false)
    Label_Percent:SetActive(true)
    Img_Arrow:SetActive(true)
    Label_Percent:GetComponent("UILabel"):set_text(math.abs(extent) .. "%")
    CommercePitchUtils.FillIcon("Img_Down", Img_Arrow:GetComponent("UISprite"), 1)
  elseif extent == 0 then
    Img_Equal:SetActive(true)
    Label_Percent:SetActive(false)
    Img_Arrow:SetActive(false)
  end
end
def.method("userdata").OnGroupClick = function(self, clickobj)
  local parentName = clickobj.parent.name
  local index = tonumber(string.sub(parentName, string.len("Tab_") + 1))
  if self.lastSelectSmallGroup.small > 0 then
    local bigGroup = self.uiTbl.Table_List:GetChild(self.lastSelectSmallGroup.big - 1)
    local smallGroup = bigGroup:FindDirect("tween"):FindDirect(string.format("Btn_List%d", self.lastSelectSmallGroup.small))
    smallGroup:GetComponent("UIToggle"):set_isChecked(false)
  end
  if index == self.lastSelectGroup then
    return
  end
  if 0 < self.lastSelectGroup then
    local last = self.uiTbl.Table_List:GetChild(self.lastSelectGroup - 1)
    if last:FindDirect("tween"):get_activeInHierarchy() then
      last:FindDirect("Img_BgComList"):GetComponent("UIPlayTween"):Play(false)
    end
  end
  self.curPage = 1
  self.lastSelectGroup = index
  CommercePitchModule.Instance().lastCommerceBigGroup = self.lastSelectGroup
  self:SelectGroup(index)
  local groupList = self.data:GetGroupList()
  if #groupList[index].subTypeIdList == 1 then
    local subTypeId = groupList[index].subTypeIdList[1]
    local subList = self.data:GetSubItemList(subTypeId)
    if 0 ~= self.lastSelectItemIndex and #subList >= self.lastSelectItemIndex then
      local itemSelect = self.uiTbl.Grid_BgComItem:FindDirect(string.format("Group_ComItem01_%d", self.lastSelectItemIndex))
      itemSelect:GetComponent("UIToggle"):set_isChecked(false)
    end
    self:UnSelectLastBuyItem()
  end
  if 1 < #groupList[index].subTypeIdList then
    self.uiTbl.ScrollView_Commerce:GetComponent("UIScrollView"):ResetPosition()
  else
    self.uiTbl.ScrollView_BgComItem:GetComponent("UIScrollView"):ResetPosition()
  end
end
def.method("number").SelectGroup = function(self, index)
  local groupList = self.data:GetGroupList()
  if #groupList[index].subTypeIdList > 1 then
  elseif #groupList[index].subTypeIdList == 1 then
    self.lastSelectSmallGroup.big = index
    self.lastSelectSmallGroup.small = 0
    CommercePitchModule.Instance().lastCommerceSmallGroup = self.lastSelectSmallGroup
    self.groupInfo = self.lastSelectSmallGroup.big .. "_" .. self.lastSelectSmallGroup.small
    CommercePitchModule.Instance().lastCommerceGroupInfo = self.groupInfo
    local small = 1
    self.itemTbl, self.curPage, self.maxPage, self.curSubTypeId = self.data:GetItemList(self.lastSelectSmallGroup.big, small, self.curPage)
    self:FillItemList(self.itemTbl)
    self:RefeshCommerce()
  elseif #groupList[index].subTypeIdList == 0 then
    self:FillItemList(nil)
  end
end
def.method("userdata").OnSmallGroupClick = function(self, clickobj)
  local smallIndex = tonumber(string.sub(clickobj.name, string.len("Btn_List") + 1))
  local bigIndex = tonumber(string.sub(clickobj.parent.parent.name, string.len("Tab_") + 1))
  self.lastSelectSmallGroup.big = bigIndex
  self.lastSelectSmallGroup.small = smallIndex
  CommercePitchModule.Instance().lastCommerceSmallGroup = self.lastSelectSmallGroup
  self.groupInfo = self.lastSelectSmallGroup.big .. "_" .. self.lastSelectSmallGroup.small
  CommercePitchModule.Instance().lastCommerceGroupInfo = self.groupInfo
  self:SelectSmallGroup(1)
  self:RefeshCommerce()
  local bigGroupList = self.data:GetGroupList()
  local selectGroup = bigGroupList[self.lastSelectGroup]
  local subTypeList = selectGroup.subTypeIdList
  local subTypeId = subTypeList[smallIndex]
  local subList = self.data:GetSubItemList(subTypeId)
  self:UnSelectLastBuyItem()
  if 0 ~= self.lastSelectItemIndex and #subList >= self.lastSelectItemIndex then
    local itemSelect = self.uiTbl.Grid_BgComItem:FindDirect(string.format("Group_ComItem01_%d", self.lastSelectItemIndex))
    itemSelect:GetComponent("UIToggle"):set_isChecked(false)
  end
  self.uiTbl.ScrollView_BgComItem:GetComponent("UIScrollView"):ResetPosition()
end
def.method("number").SelectSmallGroup = function(self, page)
  local groupList = self.data:GetGroupList()
  local small = self.lastSelectSmallGroup.small
  if #groupList[self.lastSelectSmallGroup.big].subTypeIdList == 1 then
    small = 1
  end
  self.itemTbl, self.curPage, self.maxPage, self.curSubTypeId = self.data:GetItemList(self.lastSelectSmallGroup.big, small, page)
  self:FillItemList(self.itemTbl)
end
def.method("string").OnSelectBuyItem = function(self, id)
  local index = tonumber(string.sub(id, #"Group_ComItem01_" + 1, -1))
  local itemId = self.itemTbl[index]
  self.selectBuyItemId = itemId
  self.lastSelectItemIndex = index
  CommercePitchModule.Instance().selectCommerceItemId = self.selectBuyItemId
end
def.static("number", "number").DownStopRise = function(itemKey, itemId)
  local tag = {itemKey = itemKey, itemId = itemId}
  CommonConfirmDlg.ShowConfirm("", textRes.Commerce[7], CommerceNode.SellItemCallback, tag)
end
def.method("number").OnBuyItemClick = function(self, itemCount)
  if 0 == self.selectBuyItemId then
    Toast(textRes.Commerce[15])
    return
  end
  local itemInfo = self.data:GetItemInfo(self.selectBuyItemId)
  if not itemInfo then
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.Commerce[21], rate, need), nil, nil)
    return
  end
  if itemInfo.rise / 10000 < 0.5 and itemInfo.rise / 10000 >= 0.1 then
    self:RequireToBuyItem(itemCount)
    return
  end
  if itemCount > 1 then
    local tag = {id = self, cnt = itemCount}
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.Commerce[25], itemCount), CommerceNode.BuyItemCallback, tag)
  else
    self:RequireToBuyItem(itemCount)
  end
end
def.method().OnPageBackClick = function(self)
  if self.curPage ~= nil and self.curPage > 1 then
    self:SelectSmallGroup(self.curPage - 1)
    self:RefeshCommerce()
  end
end
def.method().OnPageNextClick = function(self)
  if self.curPage ~= nil then
    self:SelectSmallGroup(self.curPage + 1)
    self:RefeshCommerce()
  end
end
def.method().OnBtnTipsClick = function(self)
  if self.curPage ~= nil then
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701603002)
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
  end
end
def.method("number").RequireToBuyItem = function(self, itemCount)
  local level = require("Main.Hero.Interface").GetHeroProp().level
  if level < CommercePitchUtils.GetCommerceOpenLevel() then
    Toast(string.format(textRes.Commerce[17], CommercePitchUtils.GetCommerceOpenLevel()))
    return
  end
  local itemInfo = self.data:GetItemInfo(self.selectBuyItemId)
  local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local price = itemInfo.price
  if itemInfo.rise / 10000 < 0.5 and itemInfo.rise / 10000 >= 0.1 then
    local rate = CommercePitchUtils.GetCommerceUpStopBuyRate()
    price = itemInfo.price * rate
  end
  if Int64.lt(gold, price * itemCount) then
    CommonConfirmDlg.ShowConfirm("", textRes.Commerce.ErrorCode[3], CommerceNode.BuyGoldCallback, {
      unique = "commercebuy"
    })
    return
  end
  local p = require("netio.protocol.mzm.gsp.shanghui.CBuyItemReq").new(gold, self.selectBuyItemId, itemCount)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").RequireToSellItem = function(itemKey, itemId)
  local p = require("netio.protocol.mzm.gsp.shanghui.CSellItemReq").new(itemKey, itemId)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number").SellToCommerce = function(itemKey, itemId, shPrice)
  local level = require("Main.Hero.Interface").GetHeroProp().level
  if level < CommercePitchUtils.GetCommerceOpenLevel() then
    Toast(string.format(textRes.Commerce[18], CommercePitchUtils.GetCommerceOpenLevel()))
    return
  end
  if shPrice == -2 then
    local p = require("netio.protocol.mzm.gsp.shanghui.CGetSellItemPriceReq").new(itemKey, itemId)
    gmodule.network.sendProtocol(p)
    return
  end
  local price = 0
  if shPrice > 0 then
    price = shPrice * 0.8
  else
    price = CommercePitchUtils.GetCommerceItemOrginialPrice(itemId) * 0.9
  end
  local tag = {itemKey = itemKey, itemId = itemId}
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Commerce[22], math.floor(price)), CommerceNode.SellItemCallback, tag)
end
def.static("number", "number", "number").SellToCommerceEx = function(itemKey, itemId, price)
  local tag = {itemKey = itemKey, itemId = itemId}
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Commerce[23], price), CommerceNode.SellItemCallback, tag)
end
def.method().UnSelectLastSellItem = function(self)
  self:SelectSmallGroup(self.curPage)
  if self.selectSellItemIndex == 0 then
    return
  end
  local itemGridTemplate = self.uiTbl.Grid_Bag
  local itemTemplate = itemGridTemplate:FindDirect(string.format("Img_BgBagItem0%d", self.selectSellItemIndex))
  if nil == itemTemplate then
    return
  end
  itemTemplate:GetComponent("UIToggle"):set_isChecked(false)
  self.selectSellItemIndex = 0
end
def.method("userdata", "number", "number", "number").SucceedBuyItem = function(self, costGold, canBuyNum, itemId, itemCount)
  self:SelectSmallGroup(self.curPage)
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemId)
  local namenum = string.format("%sx%d", itemBase.name, itemCount)
  PersonalHelper.CommonMsg(PersonalHelper.Type.ColorText, textRes.Common[44], "ffffff", PersonalHelper.Type.ColorText, namenum, "ffff00", PersonalHelper.Type.ColorText, textRes.Common.comma .. textRes.Common[45], "ffffff", PersonalHelper.Type.Gold, costGold, PersonalHelper.Type.Text, textRes.Commerce[11], PersonalHelper.Type.ColorText, canBuyNum, "00ff00")
end
def.static("userdata", "number").SucceedSellItem = function(earnGold, canSellNum)
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Commerce[12], PersonalHelper.Type.Gold, earnGold, PersonalHelper.Type.Text, textRes.Commerce[14], PersonalHelper.Type.Text, tostring(canSellNum))
end
def.static("number", "table").BuyItemCallback = function(i, tag)
  if i == 1 then
    local dlg = tag.id
    dlg:RequireToBuyItem(tag.cnt)
  end
end
def.static("number", "table").SellItemCallback = function(i, tag)
  if i == 1 then
    CommerceNode.RequireToSellItem(tag.itemKey, tag.itemId)
  end
end
def.static("number", "table").BuyGoldCallback = function(i, tag)
  if i == 1 then
    GoToBuyGold(false)
  end
end
def.method("number").CommonResultRes = function(self, res)
  local SCommonResultRes = require("netio.protocol.mzm.gsp.shanghui.SCommonResultRes")
  if res == SCommonResultRes.NEED_MORE_GOLD then
    CommonConfirmDlg.ShowConfirm("", textRes.Commerce.ErrorCode[3], CommerceNode.BuyGoldCallback, {
      unique = "commercebuy"
    })
  elseif res == SCommonResultRes.NEED_1DOT5_GOLD then
    if 0 ~= self.selectBuyItemId then
      local itemInfo = self.data:GetItemInfo(self.selectBuyItemId)
      if itemInfo.rise / 10000 < 0.5 and itemInfo.rise / 10000 >= 0.1 then
        local tag = {id = self}
        local rate = CommercePitchUtils.GetCommerceUpStopBuyRate()
        local need = itemInfo.price * rate
        CommonConfirmDlg.ShowConfirm("", string.format(textRes.Commerce.ErrorCode[2], rate, need), CommerceNode.BuyItemCallback, tag)
      end
    end
  elseif textRes.Commerce.ErrorCode[res] then
    Toast(textRes.Commerce.ErrorCode[res])
  end
end
def.method("userdata").OnCommerceItemClick = function(self, clickobj)
  local index = tonumber(string.sub(clickobj.parent.name, #"Group_ComItem01_" + 1, -1))
  local itemId = self.itemTbl[index]
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
end
def.method("userdata").OnBagItemClick = function(self, clickobj)
  local index = tonumber(string.sub(clickobj.name, string.len("Img_BgBagItem0") + 1))
  local itemKeys = self.data:GetCommerceItems()
  local key = itemKeys[index]
  self.selectSellItemIndex = index
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, key)
  if item then
    ItemTipsMgr.Instance():ShowTips(item, ItemModule.BAG, key, ItemTipsMgr.Source.Commerce, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
  end
end
def.method().RefeshCommerce = function(self)
  if self.curPage and self.curSubTypeId then
    local p = require("netio.protocol.mzm.gsp.shanghui.CRefreshShopingListReq").new(self.curSubTypeId, self.curPage)
    gmodule.network.sendProtocol(p)
    CommerceData.Instance():SetOnceFinished(false)
  end
end
def.method().CommerceItemsUpdate = function(self)
  self:FillGroupList()
  if 0 ~= self.lastSelectGroup then
    local lastGroup = self.uiTbl.Table_List:GetChild(self.lastSelectGroup - 1)
    lastGroup:FindDirect("Img_BgComList"):GetComponent("UIToggle"):set_isChecked(true)
    self:SelectGroup(self.lastSelectGroup)
    if 0 < self.lastSelectSmallGroup.small and self.lastSelectSmallGroup.big == self.lastSelectGroup then
      lastGroup:FindDirect("tween"):FindDirect(string.format("Btn_List%d", self.lastSelectSmallGroup.small)):GetComponent("UIToggle"):set_isChecked(true)
    end
    self:SelectSmallGroup(self.curPage)
  end
end
def.method().RefreshCommerceItemsInfo = function(self)
  if 0 ~= self.lastSelectSmallGroup.big then
    local lastGroup = self.uiTbl.Table_List:GetChild(self.lastSelectGroup - 1)
    lastGroup:FindDirect("Img_BgComList"):GetComponent("UIToggle"):set_isChecked(true)
    local tmp = self.lastSelectSmallGroup.big .. "_" .. self.lastSelectSmallGroup.small
    if tmp == self.groupInfo then
      if 0 < self.lastSelectSmallGroup.small and self.lastSelectSmallGroup.big == self.lastSelectGroup then
        lastGroup:FindDirect("tween"):FindDirect(string.format("Btn_List%d", self.lastSelectSmallGroup.small)):GetComponent("UIToggle"):set_isChecked(true)
      end
      self:SelectSmallGroup(self.curPage)
    end
  end
end
def.method().CommerceBagsUpdate = function(self)
  self.data:InitCommerceBagItems()
  self:UpdateBagItemsObjects()
  self:FillBag()
  if 0 ~= self.lastSelectGroup then
    local UIPlayTween = self.uiTbl.Table_List:FindDirect(string.format("Tab_%d", self.lastSelectGroup)):FindDirect("Img_BgComList"):GetComponent("UIPlayTween")
    UIPlayTween:Play(false)
    UIPlayTween:Play(true)
  end
  if 0 < self.lastSelectSmallGroup.small and self.lastSelectSmallGroup.big == self.lastSelectGroup then
    local lastGroup = self.uiTbl.Table_List:GetChild(self.lastSelectGroup - 1)
    lastGroup:FindDirect("tween"):FindDirect(string.format("Btn_List%d", self.lastSelectSmallGroup.small)):GetComponent("UIToggle"):set_isChecked(true)
  end
end
def.method().UnSelectLastBuyItem = function(self)
  if self.lastSelectItemIndex == 0 then
    return
  end
  local itemGridTemplate = self.uiTbl.Grid_BgComItem
  local itemTemplate = itemGridTemplate:FindDirect(string.format("Group_ComItem01_%d", self.lastSelectItemIndex))
  if nil == itemTemplate then
    return
  end
  itemTemplate:GetComponent("UIToggle"):set_isChecked(false)
  self.lastSelectItemIndex = 0
  self.selectBuyItemId = 0
end
def.override("userdata").onClickObj = function(self, clickobj)
  if IsCrossingServer() then
    ToastCrossingServerForbiden()
    return
  end
  local id = clickobj.name
  if "Img_BgComList" == id then
    self:OnGroupClick(clickobj)
  elseif string.find(id, "Btn_List") then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      self:OnSmallGroupClick(clickobj)
    else
      clickobj:GetComponent("UIToggle"):set_isChecked(true)
    end
  elseif string.sub(id, 1, #"Img_BgComItem_") == "Img_BgComItem_" then
    self:OnCommerceItemClick(clickobj)
  elseif string.sub(id, 1, #"Group_ComItem01_") == "Group_ComItem01_" then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      self:OnSelectBuyItem(id)
      self:UnSelectLastSellItem()
    else
      self.selectBuyItemId = 0
      self.lastSelectItemIndex = 0
    end
  elseif "Btn_Buy" == id then
    self:OnBuyItemClick(1)
  elseif "Btn_Buy1" == id then
    self:OnBuyItemClick(1)
  elseif "Btn_Buy50" == id then
    self:OnBuyItemClick(10)
  elseif "Btn_Buy100" == id then
    self:OnBuyItemClick(50)
  elseif string.find(id, "Img_BgBagItem0") then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      self:OnBagItemClick(clickobj)
      self:UnSelectLastBuyItem()
    end
  elseif "Btn_Back" == id then
    self:OnPageBackClick()
  elseif "Btn_Next" == id then
    self:OnPageNextClick()
  elseif "Btn_Tips" == id then
    self:OnBtnTipsClick()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  end
end
CommerceNode.Commit()
return CommerceNode

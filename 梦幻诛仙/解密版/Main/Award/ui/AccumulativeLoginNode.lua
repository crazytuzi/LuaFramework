local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local AccumulativeLoginNode = Lplus.Extend(AwardPanelNodeBase, "AccumulativeLoginNode")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local AccumulativeLoginMgr = require("Main.Award.mgr.AccumulativeLoginMgr")
local Vector = require("Types.Vector")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local GUIUtils = require("GUI.GUIUtils")
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local def = AccumulativeLoginNode.define
def.field("table").catchedAwardList = nil
def.field(EasyBasicItemTip).itemTipHelper = nil
def.field("table").uiObjs = nil
def.field("boolean").useUIScrollList = false
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
  self.awardType = GiftType.LOGIN_GIFT
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ACCUMULATIVE_LOGIN_AWARD_UPDATE, AccumulativeLoginNode.OnLoginAwardUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ACCUMULATIVE_LOGIN_AWARD_UPDATE, AccumulativeLoginNode.OnLoginAwardUpdate)
  self:Clear()
end
def.override("=>", "boolean").IsOpen = function(self)
  return AccumulativeLoginMgr.Instance():IsOpen()
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Get" then
    local anchorId = obj.parent.parent.name
    local index = tonumber(string.sub(anchorId, #"item_" + 1, -1))
    if index then
      self:OnDrawAwardButtonClicked(index)
    end
  else
    self:onClick(id)
  end
end
def.override("string").onClick = function(self, id)
  if id == "Button_Tips" then
  elseif self.itemTipHelper:CheckItem2ShowTip(id, -1, false) then
  end
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return AccumulativeLoginMgr.Instance():IsHaveNotifyMessage()
end
def.override().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.List_LeiDeng = self.m_node:FindDirect("Scroll View_LeiDeng/List_LeiDeng")
  self.itemTipHelper = EasyBasicItemTip()
end
def.method().UpdateUI = function(self)
  self:UpdateAwardList()
end
def.method().UpdateAwardList = function(self)
  local awardList = AccumulativeLoginMgr.Instance():GetOverallAwardList()
  self.catchedAwardList = awardList
  local accumulativeLoginStates = AccumulativeLoginMgr.Instance():GetAccumulativeLoginState()
  self:SetAwardList(awardList, accumulativeLoginStates)
end
def.method("table", "table").SetAwardList = function(self, awardList, accumulativeLoginStates)
  local listObj = self.uiObjs.List_LeiDeng
  local scrollViewObj = listObj.parent
  local uiScrollList = listObj:GetComponent("UIScrollList")
  if uiScrollList then
    self.useUIScrollList = true
    local GUIScrollList = listObj:GetComponent("GUIScrollList")
    if not GUIScrollList then
      listObj:AddComponent("GUIScrollList")
    end
    ScrollList_setUpdateFunc(uiScrollList, function(item, i)
      local award = awardList[i]
      item.name = "item_" .. i
      self:SetAwardItems(i, item, award, accumulativeLoginStates)
    end)
    ScrollList_setCount(uiScrollList, #awardList)
    local firstIndex = self:CalcFocusIndex(awardList)
    ScrollList_setFirstIndex(uiScrollList, firstIndex)
    self.m_base.m_msgHandler:Touch(listObj)
    return
  end
  self.useUIScrollList = false
  local uiList = self.uiObjs.List_LeiDeng:GetComponent("UIList")
  uiList:set_itemCount(#awardList)
  uiList:Resize()
  uiList:Reposition()
  local itemObjs = uiList.children
  for i, award in ipairs(awardList) do
    local listItem = itemObjs[i]
    self:SetAwardItems(i, listItem, award, accumulativeLoginStates)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
  GameUtil.AddGlobalLateTimer(0, true, function()
    if uiList.isnil then
      return
    end
    uiList:Reposition()
  end)
end
def.method("number", "userdata", "table", "table").SetAwardItems = function(self, index, listItem, award, accumulativeLoginStates)
  listItem:FindDirect("Img_Ti/Label_Num"):GetComponent("UILabel"):set_text(award.days)
  GUIUtils.SetText(listItem:FindDirect("Label_Tip"), award.desc)
  local Group_Icon = listItem:FindDirect("Group_Icon")
  local MAX_ITEM_PER_ROW = 3
  for i = 1, MAX_ITEM_PER_ROW do
    local Img_BgIcon = Group_Icon:GetChild(i - 1)
    if Img_BgIcon == nil then
      break
    end
    Img_BgIcon.name = "Img_BgIcon_" .. index .. "_" .. i
    local item = award.items[i]
    if item then
      local itemId = item.itemId
      local itemBase = ItemUtils.GetItemBase(itemId)
      local iconId = itemBase.icon
      local uiTexture = Img_BgIcon:FindDirect("Texture_Icon"):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, iconId)
      local text = 1 < item.num and item.num or ""
      Img_BgIcon:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(text)
      local quality = itemBase.namecolor
      local uiSprite = Img_BgIcon:GetComponent("UISprite")
      uiSprite:set_spriteName(string.format("Cell_%02d", quality))
      self.itemTipHelper:RegisterItem2ShowTip(itemId, Img_BgIcon)
      if accumulativeLoginStates.drawedDays[award.days] then
        GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
        uiSprite:set_spriteName("Cell_07")
      else
        GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
      end
    else
      Img_BgIcon:SetActive(false)
    end
  end
  local Goup_Ling = listItem:FindDirect("Goup_Ling")
  Goup_Ling:FindDirect("Btn_Get"):SetActive(false)
  Goup_Ling:FindDirect("Img_YiLing"):SetActive(false)
  Goup_Ling:FindDirect("Group_Date"):SetActive(false)
  if AccumulativeLoginMgr.Instance():IsDrawed(award.days) then
    Goup_Ling:FindDirect("Img_YiLing"):SetActive(true)
  elseif AccumulativeLoginMgr.Instance():CanDrawed(award.days) then
    Goup_Ling:FindDirect("Btn_Get"):SetActive(true)
    local scrollObj = self.uiObjs.List_LeiDeng.transform.parent.gameObject
    if not self.useUIScrollList then
      self:DragToMakeVisible(scrollObj, listItem, 4000)
    end
  else
    Goup_Ling:FindDirect("Group_Date"):SetActive(true)
    local remainDays = AccumulativeLoginMgr.Instance():GetCanDrawedRemainDays(award.days)
    Goup_Ling:FindDirect("Group_Date/Label_Num"):GetComponent("UILabel"):set_text(remainDays)
  end
end
def.method("table", "=>", "number").CalcFocusIndex = function(self, awardList)
  local index = 1
  for i, award in ipairs(awardList) do
    if not AccumulativeLoginMgr.Instance():IsDrawed(award.days) and AccumulativeLoginMgr.Instance():CanDrawed(award.days) then
      index = i
      break
    end
  end
  return index
end
def.method("number").OnDrawAwardButtonClicked = function(self, index)
  print("OnDrawAwardButtonClicked", index)
  if self.catchedAwardList == nil then
    return
  end
  if index == 2 then
    require("Main.Award.ui.Login3DaysTip").ShowTip()
  end
  local award = self.catchedAwardList[index]
  local days = award.days
  AccumulativeLoginMgr.Instance():DrawLoginAward(days)
  AccumulativeLoginMgr.Instance():RegisterAwardNotice(days, award)
end
def.static("table", "table").OnLoginAwardUpdate = function(params)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  local instance = AwardPanel.Instance().nodes[AwardPanel.NodeId.AccumulativeLogin]
  instance:UpdateUI()
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.catchedAwardList = nil
end
return AccumulativeLoginNode.Commit()

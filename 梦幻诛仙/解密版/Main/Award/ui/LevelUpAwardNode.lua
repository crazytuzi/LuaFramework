local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local LevelUpAwardNode = Lplus.Extend(AwardPanelNodeBase, "LevelUpAwardNode")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local LevelUpAwardMgr = require("Main.Award.mgr.LevelUpAwardMgr")
local Vector = require("Types.Vector")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local GUIUtils = require("GUI.GUIUtils")
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local def = LevelUpAwardNode.define
def.field(EasyBasicItemTip).itemTipHelper = nil
def.field("table").catchedAwardList = nil
def.field("table").uiObjs = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
  self.awardType = GiftType.LEVELUP_GIFT
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LEVEL_UP_AWARD_UPDATE, LevelUpAwardNode.OnLevelUpAwardUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LEVEL_UP_AWARD_UPDATE, LevelUpAwardNode.OnLevelUpAwardUpdate)
  self:Clear()
end
def.override("=>", "boolean").IsOpen = function(self)
  return LevelUpAwardMgr.Instance():IsOpen()
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Get" then
    local anchorId = obj.transform.parent.parent.gameObject.name
    local index = tonumber(string.sub(anchorId, #"item_" + 1, -1))
    self:OnDrawAwardButtonClicked(index)
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
  return LevelUpAwardMgr.Instance():IsHaveNotifyMessage()
end
def.override().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.List_LvUp = self.m_node:FindDirect("Scroll View_LvUp/List_LvUp")
  self.itemTipHelper = EasyBasicItemTip()
end
def.method().UpdateUI = function(self)
  self:UpdateAwardList()
end
def.method().UpdateAwardList = function(self)
  local awardList = LevelUpAwardMgr.Instance():GetOverallAwardList()
  self.catchedAwardList = awardList
  local levelUpAwardStates = LevelUpAwardMgr.Instance():GetLevelUpAwardState()
  self:SetAwardList(awardList, levelUpAwardStates)
end
def.method("table", "table").SetAwardList = function(self, awardList, levelUpAwardStates)
  local uiList = self.uiObjs.List_LvUp:GetComponent("UIList")
  uiList:set_itemCount(#awardList)
  uiList:Resize()
  uiList:Reposition()
  for i, award in ipairs(awardList) do
    self:SetAwardItems(i, award, levelUpAwardStates)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
end
def.method("number", "table", "table").SetAwardItems = function(self, index, award, levelUpAwardStates)
  local listItem = self.uiObjs.List_LvUp:FindDirect("item_" .. index)
  listItem:FindDirect("Img_Ti/Label_Num"):GetComponent("UILabel"):set_text(award.level)
  local MAX_ITEM_PER_ROW = 10
  for i = 1, MAX_ITEM_PER_ROW do
    local Img_BgIcon = listItem:FindDirect(string.format("Group_Icon/Img_BgIcon%d", i))
    if Img_BgIcon then
      GUIUtils.SetActive(Img_BgIcon:FindDirect("Img_Select"), true)
      Img_BgIcon.name = "Img_BgIcon_" .. award.level .. "_" .. i
    else
      Img_BgIcon = listItem:FindDirect(string.format("Group_Icon/Img_BgIcon_%d_%d", award.level, i))
    end
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
      if levelUpAwardStates.drawedLevels[award.level] then
        GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
        uiSprite:set_spriteName("Cell_07")
      end
    else
      Img_BgIcon:SetActive(false)
    end
  end
  local Goup_Ling = listItem:FindDirect("Goup_Ling")
  Goup_Ling:FindDirect("Btn_Get"):SetActive(false)
  Goup_Ling:FindDirect("Img_YiLing"):SetActive(false)
  local Group_Lv = Goup_Ling:FindDirect("Group_Lv")
  if Group_Lv then
    Group_Lv:SetActive(false)
  end
  if LevelUpAwardMgr.Instance():IsDrawed(award.level) then
    Goup_Ling:FindDirect("Img_YiLing"):SetActive(true)
  elseif LevelUpAwardMgr.Instance():CanDrawed(award.level) then
    local Btn_Get = Goup_Ling:FindDirect("Btn_Get")
    Btn_Get:SetActive(true)
    local scrollObj = self.uiObjs.List_LvUp.transform.parent.gameObject
    self:DragToMakeVisible(scrollObj, listItem, 4000)
  else
    Group_Lv:SetActive(true)
    Group_Lv:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(award.level)
  end
end
def.method("number").OnDrawAwardButtonClicked = function(self, index)
  print("OnDrawAwardButtonClicked", index)
  if self.catchedAwardList == nil then
    return
  end
  local award = self.catchedAwardList[index]
  local level = award.level
  if LevelUpAwardMgr.Instance():CanDrawed(level) then
    LevelUpAwardMgr.Instance():DrawLevelUpAward(level)
    LevelUpAwardMgr.Instance():RegisterAwardNotice(level, award)
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.LEVELAWARD, {level})
  else
    Toast(textRes.Award[3])
  end
end
def.static("table", "table").OnLevelUpAwardUpdate = function(params)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  local instance = AwardPanel.Instance().nodes[AwardPanel.NodeId.LevelUpAward]
  instance:UpdateUI()
end
def.method().Clear = function(self)
  self.uiObjs = nil
end
return LevelUpAwardNode.Commit()

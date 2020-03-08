local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AchievementPrizePanel = Lplus.Extend(ECPanelBase, "AchievementPrizePanel")
local AchievementData = require("Main.achievement.AchievementData")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = AchievementPrizePanel.define
local instance
def.field("table").uiTbl = nil
def.field("table").infoList = nil
def.field("number").curScore = 0
def.field("table").itemTbl = nil
def.static("=>", AchievementPrizePanel).Instance = function()
  if not instance then
    instance = AchievementPrizePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_ACHEVEMENT_PRIZE_PANEL, GUILEVEL.MUTEX)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_INFO_UPDATE, AchievementPrizePanel.OnArchievementInfoUpdate)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GET_SCORE_AWARD, AchievementPrizePanel.OnArchievementInfoUpdate)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_INFO_UPDATE, AchievementPrizePanel.OnArchievementInfoUpdate)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GET_SCORE_AWARD, AchievementPrizePanel.OnArchievementInfoUpdate)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local ScrollView = Img_Bg:FindDirect("Content_Prize/Scroll_View")
  uiTbl.Img_Bg = Img_Bg
  uiTbl.ScrollView = ScrollView
end
def.method().UpdateUI = function(self)
  local infoList, curScore = AchievementData.Instance():GetAchievementScoreInfoList()
  self.infoList = infoList
  self.curScore = curScore
  GameUtil.AddGlobalLateTimer(0, true, function()
    if _G.IsNil(self.m_panel) then
      return
    end
    self:FillList(true)
  end)
end
def.method("boolean").FillList = function(self, bResetScrollView)
  local infoList = self.infoList
  local scrollViewObj = self.uiTbl.ScrollView
  local scrollListObj = scrollViewObj:FindDirect("List_Prize")
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  self.itemTbl = {}
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillListInfo(i, item, infoList[i])
  end)
  ScrollList_setCount(uiScrollList, #infoList)
end
def.method("number", "userdata", "table").FillListInfo = function(self, index, uiItem, scoreInfo)
  local Label_Num = uiItem:FindDirect("Label_Num"):GetComponent("UILabel")
  local Group_Item = uiItem:FindDirect("Group_Item")
  local Img_Item1 = Group_Item:FindDirect("Img_Item1")
  local Img_Item2 = Group_Item:FindDirect("Img_Item2")
  local Img_Item3 = Group_Item:FindDirect("Img_Item3")
  local Img_ItemNumLabel1 = Img_Item1:FindDirect("Label"):GetComponent("UILabel")
  local Img_ItemNumLabel2 = Img_Item2:FindDirect("Label"):GetComponent("UILabel")
  local Img_ItemNumLabel3 = Img_Item3:FindDirect("Label"):GetComponent("UILabel")
  local Img_ItemNumTexture1 = Img_Item1:FindDirect("Texture")
  local Img_ItemNumTexture2 = Img_Item2:FindDirect("Texture")
  local Img_ItemNumTexture3 = Img_Item3:FindDirect("Texture")
  local Btn_Get = uiItem:FindDirect("Btn_Get")
  local Img_Get = uiItem:FindDirect("Img_Get")
  local Img_BgSlider = uiItem:FindDirect("Img_BgSlider")
  local Img_BgSliderLabel = Img_BgSlider:FindDirect("Label"):GetComponent("UILabel")
  Label_Num:set_text(scoreInfo.score)
  local itemComponents = {
    {
      img = Img_Item1,
      label = Img_ItemNumLabel1,
      icon = Img_ItemNumTexture1
    },
    {
      img = Img_Item2,
      label = Img_ItemNumLabel2,
      icon = Img_ItemNumTexture2
    },
    {
      img = Img_Item3,
      label = Img_ItemNumLabel3,
      icon = Img_ItemNumTexture3
    }
  }
  local itemList
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(scoreInfo.awardId)
  if awardCfg then
    itemList = awardCfg.itemList
  end
  for i, itemCom in ipairs(itemComponents) do
    if itemList and itemList[i] then
      local itemInfo = itemList[i]
      local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
      if itemBase then
        itemCom.img:SetActive(true)
        itemCom.label:set_text(itemInfo.num)
        GUIUtils.SetTexture(itemCom.icon, itemBase.icon)
      else
        itemCom.img:SetActive(false)
      end
    else
      itemCom.img:SetActive(false)
    end
  end
  if scoreInfo.isGetAward == 1 then
    Img_Get:SetActive(true)
    Btn_Get:SetActive(false)
    Img_BgSlider:SetActive(false)
  elseif self.curScore >= scoreInfo.score then
    Img_Get:SetActive(false)
    Btn_Get:SetActive(true)
    Img_BgSlider:SetActive(false)
  else
    Img_Get:SetActive(false)
    Btn_Get:SetActive(false)
    Img_BgSlider:SetActive(true)
    Img_BgSlider:GetComponent("UISlider").value = self.curScore / scoreInfo.score
    Img_BgSliderLabel:set_text(string.format("%d/%d", self.curScore, scoreInfo.score))
  end
  local parentIdx = tonumber(uiItem.parent.name)
  self.itemTbl[parentIdx] = itemList
end
def.method().HidePanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Get" then
    if clickobj.parent and clickobj.parent.parent then
      local item, idx = ScrollList_getItem(clickobj)
      if item then
        self:OnBtnGetClick(idx)
      end
    end
  elseif (id == "Img_Item1" or id == "Img_Item2" or id == "Img_Item3") and clickobj.parent and clickobj.parent.parent and clickobj.parent.parent.parent then
    self:OnBtnItemClick(clickobj)
  else
    warn("--------------------onClickObj:", id)
  end
end
def.method("number").OnBtnGetClick = function(self, index)
  local scoreInfo = self.infoList[index]
  if scoreInfo then
    local activityId = constant.AchievementConsts.activityId
    local req = require("netio.protocol.mzm.gsp.achievement.CGetAchievementScoreAward").new(activityId, scoreInfo.scoreIndexId)
    gmodule.network.sendProtocol(req)
  end
end
def.method("userdata").OnBtnItemClick = function(self, obj)
  local itemIdx = tonumber(string.sub(obj.name, string.len("Img_Item") + 1))
  local listIdx = tonumber(obj.parent.parent.parent.name)
  local itemId
  if self.itemTbl and self.itemTbl[listIdx] then
    local itemList = self.itemTbl[listIdx]
    if itemList then
      local itemInfo = itemList[itemIdx]
      if itemInfo then
        itemId = itemInfo.itemId
      end
    end
  end
  if itemId and itemId > 0 then
    local position = obj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = obj:GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
  end
end
def.static("table", "table").OnArchievementInfoUpdate = function(p1, p2)
  local activityId = p1[1]
  if instance and activityId == constant.AchievementConsts.activityId and instance:IsShow() then
    instance:UpdateUI()
  end
end
return AchievementPrizePanel.Commit()

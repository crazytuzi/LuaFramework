local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPreviewPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local def = AwardPreviewPanel.define
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
local CrossBattlefieldUtils = require("Main.CrossBattlefield.CrossBattlefieldUtils")
local CrossBattlefieldModule = require("Main.CrossBattlefield.CrossBattlefieldModule")
local CrossBattlefieldSeasonMgr = require("Main.CrossBattlefield.CrossBattlefieldSeasonMgr")
def.field("table").m_UIGOs = nil
def.field("userdata").m_uiScrollListDuanwei = nil
def.field("userdata").m_uiScrollListSeason = nil
def.field("table").m_duanweiAwardGroups = nil
def.field("table").seasonAwardCfgs = nil
def.field("number").seasonType = ChartType.SINGLE_CROSS_FIELD_LOCAL
local instance
def.static("=>", AwardPreviewPanel).Instance = function()
  if instance == nil then
    instance = AwardPreviewPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    return
  end
  self.seasonType = ChartType.SINGLE_CROSS_FIELD_LOCAL
  self:CreatePanel(RESPATH.PREFAB_CROSS_BATTLEFIELD_SEASON_AWARD_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowDuanweiInfo()
  Event.RegisterEvent(ModuleId.CROSS_BATTLEFIELD, gmodule.notifyId.CrossBattlefield.SELF_RANK_UPDATE, AwardPreviewPanel.OnSelfRankUpdate)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLEFIELD, gmodule.notifyId.CrossBattlefield.SELF_RANK_UPDATE, AwardPreviewPanel.OnSelfRankUpdate)
  self.m_UIGOs = nil
  self.m_uiScrollListDuanwei = nil
  self.m_uiScrollListSeason = nil
  self.m_duanweiAwardGroups = nil
  self.seasonAwardCfgs = nil
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_DuanWei = self.m_UIGOs.Img_Bg:FindDirect("Group_DuanWei")
  self.m_UIGOs.ScrollView_DuanWei = self.m_UIGOs.Group_DuanWei:FindDirect("Scroll View_LeiDeng")
  self.m_UIGOs.List_DuanWei = self.m_UIGOs.ScrollView_DuanWei:FindDirect("List_LeiDeng")
  local listPanel = self.m_UIGOs.List_DuanWei
  self.m_uiScrollListDuanwei = listPanel:GetComponent("UIScrollList")
  local guiScrollList = listPanel:GetComponent("GUIScrollList")
  if guiScrollList == nil then
    listPanel:AddComponent("GUIScrollList")
    do
      local uiScrollView = self.m_UIGOs.ScrollView_DuanWei:GetComponent("UIScrollView")
      ScrollList_setUpdateFunc(self.m_uiScrollListDuanwei, function(item, i)
        self:SetDuanweiAwardInfo(item, i)
        if uiScrollView and not uiScrollView.isnil then
          uiScrollView:InvalidateBounds()
        end
      end)
    end
  end
  self.m_UIGOs.Group_Season = self.m_UIGOs.Img_Bg:FindDirect("Group_Season")
  self.m_UIGOs.ScrollView_Season = self.m_UIGOs.Group_Season:FindDirect("Scroll View_Season")
  self.m_UIGOs.List_Season = self.m_UIGOs.ScrollView_Season:FindDirect("List_Season")
  local listPanel2 = self.m_UIGOs.List_Season
  self.m_uiScrollListSeason = listPanel2:GetComponent("UIScrollList")
  local guiScrollList = listPanel2:GetComponent("GUIScrollList")
  if guiScrollList == nil then
    listPanel2:AddComponent("GUIScrollList")
    do
      local uiScrollView = self.m_UIGOs.ScrollView_Season:GetComponent("UIScrollView")
      ScrollList_setUpdateFunc(self.m_uiScrollListSeason, function(item, i)
        self:SetSeasonAwardInfo(item, i)
        if uiScrollView and not uiScrollView.isnil then
          uiScrollView:InvalidateBounds()
        end
      end)
    end
  end
end
def.method().ShowDuanweiInfo = function(self)
  local seasonMgr = CrossBattlefieldSeasonMgr.Instance()
  local starNum = seasonMgr:GetStarNum()
  local duanweiInfo = CrossBattlefieldModule.Instance():GetDuanweiInfoByStarNum(starNum)
  local Label_DuanweiName = self.m_UIGOs.Group_DuanWei:FindDirect("Label_MyDuanWei/Label")
  GUIUtils.SetText(Label_DuanweiName, duanweiInfo.name)
  ScrollList_clear(self.m_uiScrollListDuanwei)
  local awardGroups = CrossBattlefieldUtils.GetDuanweiAwardGroups()
  local count = #awardGroups
  self.m_duanweiAwardGroups = awardGroups
  ScrollList_setCount(self.m_uiScrollListDuanwei, count)
end
def.method().ShowSeasonAwardInfo = function(self)
  if self.m_panel == nil then
    return
  end
  ScrollList_clear(self.m_uiScrollListSeason)
  self.seasonAwardCfgs = CrossBattlefieldUtils.GetAllSeasonAwardDisplayCfgs()
  local count = self.seasonAwardCfgs[self.seasonType] and #self.seasonAwardCfgs[self.seasonType] or 0
  ScrollList_setCount(self.m_uiScrollListSeason, count)
  self:QuerySelfRankInfo()
end
def.method("userdata", "number").SetDuanweiAwardInfo = function(self, awardPanel, idx)
  if awardPanel == nil then
    return
  end
  local awardInfo = self.m_duanweiAwardGroups and self.m_duanweiAwardGroups[idx]
  if awardInfo == nil then
    return
  end
  local seasonMgr = CrossBattlefieldSeasonMgr.Instance()
  local myStarNum = seasonMgr:GetStarNum()
  local minDuanweiInfo = CrossBattlefieldModule.Instance():GetDuanweiInfoByStarNum(awardInfo.minStarNum)
  local maxDuanweiInfo = CrossBattlefieldModule.Instance():GetDuanweiInfoByStarNum(awardInfo.maxStarNum)
  local Label_Name = awardPanel:FindDirect("Label_Name")
  local duanweiRange
  if awardInfo.minStarNum ~= awardInfo.maxStarNum then
    duanweiRange = string.format("%s - %s", minDuanweiInfo.name, maxDuanweiInfo.name)
  else
    duanweiRange = minDuanweiInfo.name
  end
  GUIUtils.SetText(Label_Name, duanweiRange)
  local Img_DuanWei = awardPanel:FindDirect("Img_DuanWei")
  local uiSprite = Img_DuanWei:GetComponent("UISprite")
  if uiSprite then
    local width, height = uiSprite.width, uiSprite.height
    local depth = uiSprite.depth
    GameObject.DestroyImmediate(uiSprite)
    local uiTexture = Img_DuanWei:AddComponent("UITexture")
    uiTexture.width, uiTexture.height = width, height
    uiTexture.depth = depth
  end
  GUIUtils.SetTexture(Img_DuanWei, minDuanweiInfo.icon)
  local cfg = ItemUtils.GetGiftAwardCfgByAwardId(awardInfo.awardId)
  if cfg then
    awardInfo.itemList = cfg.itemList
    for j = 1, 3 do
      local item = cfg.itemList[j]
      if item then
        local item_panel = awardPanel:FindDirect("Group_Icon/Img_BgIcon" .. j)
        local itemBase = ItemUtils.GetItemBase(item.itemId)
        item_panel:FindDirect("Label_Num"):GetComponent("UILabel").text = tostring(item.num)
        local awardIcon = item_panel:FindDirect("Texture_Icon")
        GUIUtils.SetTexture(awardIcon, itemBase.icon)
      end
    end
  end
end
def.method("userdata", "number").SetSeasonAwardInfo = function(self, awardPanel, idx)
  if awardPanel == nil then
    return
  end
  local awardInfo = self.seasonAwardCfgs and self.seasonAwardCfgs[self.seasonType][idx]
  if awardInfo == nil then
    return
  end
  local pre_award = self.seasonAwardCfgs and self.seasonAwardCfgs[self.seasonType][idx - 1]
  local pre_rank = pre_award and pre_award.rank or 1
  if awardInfo.rank - pre_rank == 1 then
    local rank_label = awardPanel:FindDirect("Label_Dan")
    rank_label:SetActive(true)
    rank_label:GetComponent("UILabel").text = awardInfo.rank
    awardPanel:FindDirect("Group_Duan"):SetActive(false)
  else
    awardPanel:FindDirect("Label_Dan"):SetActive(false)
    awardPanel:FindDirect("Group_Duan"):SetActive(true)
    awardPanel:FindDirect("Group_Duan/Label_1"):GetComponent("UILabel").text = pre_award and pre_award.rank + 1 or pre_rank
    awardPanel:FindDirect("Group_Duan/Label_2"):GetComponent("UILabel").text = awardInfo.rank
  end
  for i = 1, 3 do
    local itemIcon = awardPanel:FindDirect("Group_Icon/Img_BgSeasonIcon" .. i)
    local itemInfo = awardInfo.items[i]
    if itemInfo then
      local itemId = itemInfo.itemId
      itemIcon:SetActive(itemId > 0)
      if itemId > 0 then
        local Texture_Icon = itemIcon:FindDirect("Texture_Icon")
        local itemBase = ItemUtils.GetItemBase(itemId)
        if itemBase then
          GUIUtils.SetTexture(Texture_Icon, itemBase.icon)
        end
        local Label_Num = itemIcon:FindDirect("Label_Num")
        GUIUtils.SetText(itemInfo, itemNum)
      end
    else
      itemIcon:SetActive(false)
    end
  end
  local str = ""
  local curSeasonInfo, nextSeasonInfo = CrossBattlefieldUtils.GetRecentlySeasonInfo()
  if curSeasonInfo then
    if nextSeasonInfo == nil then
      str = string.format("%d.%d.%d - ", curSeasonInfo.year, curSeasonInfo.month, curSeasonInfo.day)
    else
      str = string.format("%d.%d.%d - %d.%d.%d", curSeasonInfo.year, curSeasonInfo.month, curSeasonInfo.day, nextSeasonInfo.year, nextSeasonInfo.month, nextSeasonInfo.day)
    end
  elseif nextSeasonInfo then
    str = string.format("%d.%d.%d", nextSeasonInfo.year, nextSeasonInfo.month, nextSeasonInfo.day)
  end
  local Label_Num = self.m_UIGOs.Group_Season:FindDirect("Label_SessionTime/Label_Num")
  GUIUtils.SetText(Label_Num, str)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local name = clickobj.name
  if string.find(name, "Img_BgIcon") == 1 then
    local itemidx = tonumber(string.sub(name, #"Img_BgIcon" + 1))
    local item, idx = ScrollList_getItem(clickobj)
    if item then
      local awardInfo = self.m_duanweiAwardGroups[idx]
      if awardInfo and awardInfo.itemList[itemidx] then
        require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(awardInfo.itemList[itemidx].itemId, clickobj, 0, false)
      end
    end
  elseif string.find(name, "Img_BgSeasonIcon") == 1 then
    local itemidx = tonumber(string.sub(name, #"Img_BgSeasonIcon" + 1))
    local item, idx = ScrollList_getItem(clickobj)
    if item then
      local awardInfo = self.seasonAwardCfgs[self.seasonType][idx]
      local itemInfo = awardInfo and awardInfo.items[itemidx]
      local itemid = itemInfo and itemInfo.itemId
      if itemid and itemid > 0 then
        require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(itemid, clickobj, 0, false)
      end
    end
  elseif name == "Btn_Close" then
    self:Hide()
  elseif name == "Tap_Season" then
    self:ShowSeasonAwardInfo()
  elseif name == "Tab_Own" then
    if self.seasonType ~= ChartType.SINGLE_CROSS_FIELD_LOCAL then
      self.seasonType = ChartType.SINGLE_CROSS_FIELD_LOCAL
      self:ShowSeasonAwardInfo()
    end
  elseif name == "Tab_Cross" and self.seasonType ~= ChartType.SINGLE_CROSS_FIELD_ROMOTE then
    self.seasonType = ChartType.SINGLE_CROSS_FIELD_ROMOTE
    self:ShowSeasonAwardInfo()
  end
end
def.method().QuerySelfRankInfo = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crossfield.CGetRoleCrossFieldRankReq").new(self.seasonType))
end
def.static("table", "table").OnSelfRankUpdate = function(params, context)
  local self = instance
  if not self.m_UIGOs.Group_Season.activeSelf then
    return
  end
  if self.seasonType ~= params.rankType then
    return
  end
  local Label_MyMingCi = self.m_UIGOs.Group_Season:FindDirect("Label_MyMingCi")
  local Label_Num = Label_MyMingCi:FindDirect("Label_Num")
  local Label_NotOnList = Label_MyMingCi:FindDirect("Label_NotOnList")
  GUIUtils.SetActive(Label_Num, params.rank > 0)
  GUIUtils.SetActive(Label_NotOnList, not (params.rank > 0))
  if params.rank > 0 then
    GUIUtils.SetText(Label_Num, params.rank)
  end
end
return AwardPreviewPanel.Commit()

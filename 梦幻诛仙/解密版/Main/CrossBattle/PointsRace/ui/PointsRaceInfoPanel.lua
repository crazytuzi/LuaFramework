local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PointsRaceMgr = require("Main.CrossBattle.PointsRace.PointsRaceMgr")
local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
local PointsRaceData = require("Main.CrossBattle.PointsRace.data.PointsRaceData")
local RankListData = require("Main.CrossBattle.PointsRace.data.RankListData")
local MathHelper = require("Common.MathHelper")
local PointsRaceProtocols = require("Main.CrossBattle.PointsRace.PointsRaceProtocols")
local Vector = require("Types.Vector")
local PointsRaceInfoPanel = Lplus.Extend(ECPanelBase, "PointsRaceInfoPanel")
local def = PointsRaceInfoPanel.define
local instance
def.static("=>", PointsRaceInfoPanel).Instance = function()
  if instance == nil then
    instance = PointsRaceInfoPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.const("number").UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.const("table").Top3IconName = {
  "Img_Num1",
  "Img_Num2",
  "Img_Num3"
}
local LIST_ITEM_PER_PAGE = 6
def.field("number")._curRankType = 0
def.field("string")._dragObjId = ""
def.field("boolean")._bWaitToUpdate = false
def.field("table")._rankListData = nil
def.field("number")._reqFrom = 1
def.field("number")._reqTo = LIST_ITEM_PER_PAGE
def.field("boolean")._bNeedRepositionRankList = false
def.static().ShowPanel = function()
  if not PointsRaceMgr.Instance():IsRaceOpen(true) then
    if PointsRaceInfoPanel.Instance():IsShow() then
      PointsRaceInfoPanel.Instance():DestroyPanel()
    end
    return
  end
  if not PointsRaceUtils.IsCrossBattlePointsRaceStage() then
    if PointsRaceInfoPanel.Instance():IsShow() then
      PointsRaceInfoPanel.Instance():DestroyPanel()
    end
    return
  end
  if PointsRaceInfoPanel.Instance():IsShow() then
    PointsRaceInfoPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_POINTS_RACE_INFO_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Zone = self.m_panel:FindDirect("Img_Bg/Group_Zone/Label")
  self._uiObjs.Label_Round_WinCount = self.m_panel:FindDirect("Img_Bg/Group_Details/Group_01/Label_Num")
  self._uiObjs.Label_Round_LoseCount = self.m_panel:FindDirect("Img_Bg/Group_Details/Group_02/Label_Num")
  self._uiObjs.Label_Round_Score = self.m_panel:FindDirect("Img_Bg/Group_Details/Group_03/Label_Num")
  self._uiObjs.Label_Round_Rank = self.m_panel:FindDirect("Img_Bg/Group_Details/Group_04/Label_Num")
  self._uiObjs.Label_Total_WinCount = self.m_panel:FindDirect("Img_Bg/Group_Details/Group_05/Label_Num")
  self._uiObjs.Label_Total_LoseCount = self.m_panel:FindDirect("Img_Bg/Group_Details/Group_06/Label_Num")
  self._uiObjs.Label_Continuous_WinCount = self.m_panel:FindDirect("Img_Bg/Group_Details/Group_09/Label_Num")
  self._uiObjs.Label_Total_Score = self.m_panel:FindDirect("Img_Bg/Group_Details/Group_07/Label_Num")
  self._uiObjs.Label_Total_Rank = self.m_panel:FindDirect("Img_Bg/Group_Details/Group_08/Label_Num")
  self._uiObjs.Label_Time_Title = self.m_panel:FindDirect("Img_Bg/Group_Time/Label_Name")
  self._uiObjs.Label_Time_Title_Com = self._uiObjs.Label_Time_Title:GetComponent("UILabel")
  self._uiObjs.Label_Time_Rest = self.m_panel:FindDirect("Img_Bg/Group_Time/Label_Time")
  self._uiObjs.Label_Time_Rest_Com = self._uiObjs.Label_Time_Rest:GetComponent("UILabel")
  self._uiObjs.Toggle_Round = self.m_panel:FindDirect("Img_Bg/Group_Rank/Tab01")
  self._uiObjs.Toggle_Total = self.m_panel:FindDirect("Img_Bg/Group_Rank/Tab02")
  self._uiObjs.Rank_ScrollView = self.m_panel:FindDirect("Img_Bg/Group_Rank/Group_RankList/Group_List/Scrolllist")
  self._uiObjs.uiScrollView = self._uiObjs.Rank_ScrollView:GetComponent("UIScrollView")
  self._uiObjs.Rank_List = self._uiObjs.Rank_ScrollView:FindDirect("List")
  self._uiObjs.uiList = self._uiObjs.Rank_List:GetComponent("UIList")
  self._uiObjs.Rank_Empty = self.m_panel:FindDirect("Img_Bg/Group_Rank/Group_NoData")
  local uiPanel = self._uiObjs.Rank_ScrollView:GetComponent("UIPanel")
  local finalClipRegion = uiPanel:get_finalClipRegion()
  local padding = self._uiObjs.uiList:get_padding()
  self._uiObjs.listClipY = finalClipRegion.w
  self._uiObjs.listPaddingY = padding.y
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:_ClearTimer()
  self:UpdateTime()
  self._timerID = GameUtil.AddGlobalTimer(PointsRaceInfoPanel.UPDATE_INTERVAL, false, function()
    self:UpdateTime()
  end)
  self:UpdateDetail(nil)
  PointsRaceProtocols.SendCGetPointRaceData()
  GUIUtils.Toggle(self._uiObjs.Toggle_Round, true)
end
def.method().UpdateTime = function(self)
  local curStage = PointsRaceData.Instance():GetCurStage()
  if curStage == PointsRaceMgr.StageEnum.PREPARE then
    GUIUtils.SetActive(self._uiObjs.Label_Time_Title, true)
    GUIUtils.SetActive(self._uiObjs.Label_Time_Rest, true)
    if self._uiObjs.Label_Time_Title_Com.text ~= textRes.PointsRace.RACE_WAIT_TIME then
      self._uiObjs.Label_Time_Title_Com.text = textRes.PointsRace.RACE_WAIT_TIME
    end
    self._uiObjs.Label_Time_Rest_Com.text = PointsRaceUtils.GetFormatTime(PointsRaceData.Instance():GetStageCountdown())
  elseif curStage == PointsRaceMgr.StageEnum.MATCHING then
    GUIUtils.SetActive(self._uiObjs.Label_Time_Title, true)
    GUIUtils.SetActive(self._uiObjs.Label_Time_Rest, true)
    if self._uiObjs.Label_Time_Title_Com.text ~= textRes.PointsRace.RACE_REST_TIME then
      self._uiObjs.Label_Time_Title_Com.text = textRes.PointsRace.RACE_REST_TIME
    end
    self._uiObjs.Label_Time_Rest_Com.text = PointsRaceUtils.GetFormatTime(PointsRaceData.Instance():GetStageCountdown())
  elseif curStage == PointsRaceMgr.StageEnum.STOP_MATCH then
    GUIUtils.SetActive(self._uiObjs.Label_Time_Title, true)
    GUIUtils.SetActive(self._uiObjs.Label_Time_Rest, true)
    if self._uiObjs.Label_Time_Title_Com.text ~= textRes.PointsRace.RACE_RETURN_TIME then
      self._uiObjs.Label_Time_Title_Com.text = textRes.PointsRace.RACE_RETURN_TIME
    end
    self._uiObjs.Label_Time_Rest_Com.text = PointsRaceUtils.GetFormatTime(PointsRaceData.Instance():GetStageCountdown())
  else
    GUIUtils.SetActive(self._uiObjs.Label_Time_Title, false)
    GUIUtils.SetActive(self._uiObjs.Label_Time_Rest, false)
  end
end
def.method()._ClearTimer = function(self)
  if self._timerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.override().OnDestroy = function(self)
  self:_ClearTimer()
  self:ResetRankList()
  self._uiObjs = nil
end
def.method().ResetRankList = function(self)
  self._curRankType = 0
  self._dragObjId = ""
  self._bWaitToUpdate = false
  self:ClearRankList()
  self._reqFrom = 1
  self._reqTo = LIST_ITEM_PER_PAGE
  self._bNeedRepositionRankList = false
end
def.method().ClearRankList = function(self)
  if self._rankListData then
    self._rankListData:Release()
    self._rankListData = nil
  end
  self._uiObjs.uiList.itemCount = 0
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
end
def.method("table").OnSGetPointRaceDataSuccess = function(self, p)
  if self:IsShow() then
    self:UpdateDetail(p.point_race_data)
  end
end
def.method("table").UpdateDetail = function(self, detailInfo)
  local zoneId = PointsRaceData.Instance():GetZoneId()
  local chZone = zoneId and textRes.ChineseNumber[zoneId] or nil
  if chZone then
    GUIUtils.SetActive(self._uiObjs.Label_Zone, true)
    GUIUtils.SetText(self._uiObjs.Label_Zone, string.format(textRes.PointsRace.ZONE_INDEX, chZone))
  else
    GUIUtils.SetActive(self._uiObjs.Label_Zone, false)
  end
  if detailInfo then
    GUIUtils.SetText(self._uiObjs.Label_Round_WinCount, detailInfo.cur_win)
    GUIUtils.SetText(self._uiObjs.Label_Round_Score, detailInfo.cur_point)
    GUIUtils.SetText(self._uiObjs.Label_Total_WinCount, detailInfo.wins)
    GUIUtils.SetText(self._uiObjs.Label_Total_Score, detailInfo.points)
    GUIUtils.SetText(self._uiObjs.Label_Round_LoseCount, detailInfo.cur_lose)
    GUIUtils.SetText(self._uiObjs.Label_Round_Rank, detailInfo.cur_rank)
    GUIUtils.SetText(self._uiObjs.Label_Total_LoseCount, detailInfo.loses)
    GUIUtils.SetText(self._uiObjs.Label_Total_Rank, detailInfo.rank)
    GUIUtils.SetText(self._uiObjs.Label_Continuous_WinCount, detailInfo.victories)
  else
    GUIUtils.SetText(self._uiObjs.Label_Round_WinCount, "")
    GUIUtils.SetText(self._uiObjs.Label_Round_Score, "")
    GUIUtils.SetText(self._uiObjs.Label_Total_WinCount, "")
    GUIUtils.SetText(self._uiObjs.Label_Total_Score, "")
    GUIUtils.SetText(self._uiObjs.Label_Round_LoseCount, "")
    GUIUtils.SetText(self._uiObjs.Label_Round_Rank, "")
    GUIUtils.SetText(self._uiObjs.Label_Total_LoseCount, "")
    GUIUtils.SetText(self._uiObjs.Label_Total_Rank, "")
    GUIUtils.SetText(self._uiObjs.Label_Continuous_WinCount, "")
  end
end
def.method("number").OnRankTypeSelected = function(self, type)
  if self._curRankType ~= type then
    warn(string.format("[PointsRaceInfoPanel:OnRankTypeSelected] rankType [%d] checked.", type))
    self:ResetRankList()
    self._curRankType = type
    self._bNeedRepositionRankList = true
    self._rankListData = RankListData.New(self._curRankType)
    self:RequireRankList(self._reqFrom, self._reqTo)
  end
end
def.method("number", "number").RequireRankList = function(self, from, to)
  self._reqFrom = from
  self._reqTo = to
  self._bWaitToUpdate = true
  PointsRaceProtocols.SendCGetRankList(self._curRankType - 1, from, to)
end
def.method("table").OnSGetRankListFail = function(self, p)
  if self:IsShow() then
    self._bWaitToUpdate = false
  end
end
def.method("table").OnSGetRankList = function(self, p)
  if self:IsShow() then
    local rankType = p.rank_type + 1
    if rankType ~= self._curRankType then
      warn(string.format("[PointsRaceInfoPanel:OnSGetRankList] abort data, p.rankType[%d] ~= self._curRankType[%d].", rankType, self._curRankType))
      return
    end
    self._bWaitToUpdate = false
    self._rankListData:UnmarshalProtocol(p)
    self:UpdateRank()
  end
end
def.method().UpdateRank = function(self)
  local itemAmount = self._rankListData:GetCount()
  if itemAmount > self._reqTo then
    itemAmount = self._reqTo
  end
  if self._bNeedRepositionRankList then
    warn("[PointsRaceInfoPanel:UpdateRank] self._uiObjs.uiScrollView:ResetPosition().")
    self._uiObjs.uiScrollView:ResetPosition()
    self._uiObjs.Rank_ScrollView:set_localPosition(Vector.Vector3.zero)
    local uiPanel = self._uiObjs.uiScrollView:GetComponent("UIPanel")
    uiPanel:set_clipOffset(Vector.Vector2.zero)
    self._bNeedRepositionRankList = false
  end
  self._uiObjs.uiList.itemCount = itemAmount
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
  if itemAmount > 0 then
    GUIUtils.SetActive(self._uiObjs.Rank_Empty, false)
    for index = self._reqFrom, itemAmount do
      local displayInfo = self._rankListData:GetData(index)
      self:SetListItemInfo(index, displayInfo)
    end
    self:TouchGameObject(self.m_panel, self.m_parent)
  else
    GUIUtils.SetActive(self._uiObjs.Rank_Empty, true)
  end
end
local colourText = function(str)
  local color = textRes.RankList.RankColor[index]
  local text = tostring(str)
  if color then
    text = string.format("[%s]%s[-]", color, text)
  end
  return text
end
def.method("number", "table").SetListItemInfo = function(self, index, displayInfo)
  if nil == displayInfo then
    warn("[ERROR][PointsRaceInfoPanel:SetListItemInfo] displayInfo nil at index:", index)
    return
  end
  local listItem = self._uiObjs.Rank_List:FindDirect("item_" .. index)
  if nil == listItem then
    warn("[ERROR][PointsRaceInfoPanel:SetListItemInfo] listItem nil at index:", index)
    return
  end
  if index % 2 == 0 then
    GUIUtils.SetActive(listItem:FindDirect("Img_Bg1"), false)
    GUIUtils.SetActive(listItem:FindDirect("Img_Bg2"), true)
  else
    GUIUtils.SetActive(listItem:FindDirect("Img_Bg2"), false)
    GUIUtils.SetActive(listItem:FindDirect("Img_Bg1"), true)
  end
  local Label_Ranking = listItem:FindDirect("Label_Ranking")
  local Img_MingCi = listItem:FindDirect("Img_MingCi")
  if index <= 3 then
    GUIUtils.SetSprite(Img_MingCi, PointsRaceInfoPanel.Top3IconName[index])
    GUIUtils.SetActive(Label_Ranking, false)
  else
    GUIUtils.SetSprite(Img_MingCi, "nil")
    GUIUtils.SetActive(Label_Ranking, true)
    GUIUtils.SetText(Label_Ranking, colourText(index))
  end
  local Img_Badge = listItem:FindDirect("Img_Badge")
  local CorpsUtils = require("Main.Corps.CorpsUtils")
  local badgeCfg = CorpsUtils.GetCorpsBadgeCfg(displayInfo.icon)
  if badgeCfg then
    GUIUtils.FillIcon(Img_Badge:GetComponent("UITexture"), badgeCfg.iconId)
  else
    warn("[ERROR][PointsRaceInfoPanel:SetListItemInfo] badgeCfg nil for badgeId:", displayInfo.icon)
    GUIUtils.SetActive(Img_Badge, false)
  end
  local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(displayInfo.zoneid)
  local serverName = serverCfg and serverCfg.name or textRes.PointsRace.SERVER_UNKNOWN
  local corpsName = displayInfo.corps_name and _G.GetStringFromOcts(displayInfo.corps_name) or ""
  local Label_TeamName = listItem:FindDirect("Label_TeamName")
  GUIUtils.SetText(Label_TeamName, colourText(serverName .. "-" .. corpsName))
  local Label_Num = listItem:FindDirect("Label_Num")
  GUIUtils.SetText(Label_Num, colourText(displayInfo.point))
end
def.method("string", "boolean").onToggle = function(self, id, active)
  local togglePrefix = "Tab"
  if active and string.find(id, togglePrefix) then
    local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    self:OnRankTypeSelected(index)
  end
end
def.method("string").onDragStart = function(self, id)
  self._dragObjId = id
end
def.method("string").onDragEnd = function(self, id)
  self._dragObjId = ""
  if string.find(id, "item_") then
    self:DragScrollView()
  end
end
def.method().DragScrollView = function(self)
  local dragAmount = self._uiObjs.uiScrollView:GetDragAmount()
  local trans = self._uiObjs.Rank_List.transform
  local bounds = NGUIMath.CalculateRelativeWidgetBounds2t1b(trans, trans, false)
  local listBoundsY = bounds.size.y
  local listPageHeight = self:_GetPageHight()
  warn("[PointsRaceInfoPanel:DragScrollView] dragAmount.y:", dragAmount.y)
  if dragAmount.y > 1 and self._bWaitToUpdate == false then
    local startIdx = (MathHelper.Round(listBoundsY / listPageHeight) - 1) * LIST_ITEM_PER_PAGE + 1
    local endIdx = startIdx + 2 * LIST_ITEM_PER_PAGE - 1
    startIdx = math.max(1, startIdx)
    self:RequireRankList(startIdx, endIdx)
  else
    local dy = (listBoundsY - self._uiObjs.listClipY) * dragAmount.y
    local base = listPageHeight - self._uiObjs.listClipY
    local startIdx, endIdx
    if dy > base then
      startIdx = MathHelper.Floor((dy - base) / listPageHeight) * LIST_ITEM_PER_PAGE + 1
      endIdx = startIdx + 2 * LIST_ITEM_PER_PAGE - 1
      startIdx = math.max(1, startIdx)
    elseif dy < 0 then
      startIdx = 1
      endIdx = LIST_ITEM_PER_PAGE
    end
    if startIdx and startIdx ~= self._reqFrom and endIdx ~= self._reqTo then
      if startIdx <= self._reqFrom then
        startIdx = math.max(1, startIdx - LIST_ITEM_PER_PAGE)
      end
      self:RequireRankList(startIdx, endIdx)
    end
  end
end
def.method("=>", "number")._GetPageHight = function(self)
  if self._uiObjs.listTemplateY == nil or self._uiObjs.listTemplateY < 1.0E-5 then
    local template = self._uiObjs.uiList:get_template()
    local trans = template.transform
    template:SetActive(true)
    local bounds = NGUIMath.CalculateRelativeWidgetBounds2t1b(trans, trans, false)
    template:SetActive(false)
    self._uiObjs.listTemplateY = bounds.size.y
  end
  return self._uiObjs.listTemplateY * LIST_ITEM_PER_PAGE + self._uiObjs.listPaddingY * (LIST_ITEM_PER_PAGE - 1)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Rule" then
    self:OnBtn_Rule()
  end
end
def.method().OnBtn_Rule = function(self)
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(PointsRaceUtils.GetTipId())
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
  end
end
PointsRaceInfoPanel.Commit()
return PointsRaceInfoPanel

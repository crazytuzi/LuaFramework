local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PointsRaceMgr = require("Main.CrossBattle.PointsRace.PointsRaceMgr")
local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
local PointsRaceData = require("Main.CrossBattle.PointsRace.data.PointsRaceData")
local RankListData = require("Main.CrossBattle.PointsRace.data.RankListData")
local MathHelper = require("Common.MathHelper")
local PointsRaceProtocols = require("Main.CrossBattle.PointsRace.PointsRaceProtocols")
local CrossBattlePointsFightInfoPanel = Lplus.Extend(ECPanelBase, "CrossBattlePointsFightInfoPanel")
local def = CrossBattlePointsFightInfoPanel.define
local instance
def.static("=>", CrossBattlePointsFightInfoPanel).Instance = function()
  if instance == nil then
    instance = CrossBattlePointsFightInfoPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("number").selectZoneId = 0
def.field("number").selectRound = 0
def.field("table").fightTimePoint = nil
def.const("table").Top3IconName = {
  "Img_Num1",
  "Img_Num2",
  "Img_Num3"
}
local LIST_ITEM_PER_PAGE = 8
def.field("number")._curRankType = 0
def.field("string")._dragObjId = ""
def.field("boolean")._bWaitToUpdate = false
def.field("table")._rankListData = nil
def.field("number")._reqFrom = 1
def.field("number")._reqTo = LIST_ITEM_PER_PAGE
def.field("boolean")._bNeedRepositionRankList = false
def.method("table", "number").ShowPanel = function(self, timePoint, round)
  if self:IsShow() then
    return
  end
  self.selectZoneId = PointsRaceData.Instance():GetZoneId() > 0 and PointsRaceData.Instance():GetZoneId() or 1
  self.selectRound = round
  self.fightTimePoint = timePoint
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_POINTS_FIGHT_INFO, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateTitle()
  self:UpdateUI()
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Time = self.m_panel:FindDirect("Img_Bg/Group_Time/Label_Time")
  self._uiObjs.Label_Game = self.m_panel:FindDirect("Img_Bg/Group_Time/Label_Game")
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
  self._uiObjs.Group_Zone = self.m_panel:FindDirect("Img_Bg/Group_Zone")
  self._uiObjs.Btn_Rule = self.m_panel:FindDirect("Img_Bg/Group_Rank/Btn_Rule")
end
def.method().UpdateTitle = function(self)
  local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
  GUIUtils.SetText(self._uiObjs.Label_Time, string.format(textRes.CrossBattle[105], self.fightTimePoint.year, self.fightTimePoint.month, self.fightTimePoint.day))
  GUIUtils.SetText(self._uiObjs.Label_Game, string.format(textRes.CrossBattle[106], PointsRaceUtils.GetZoneName(self.selectZoneId), self.selectRound))
end
def.method().UpdateUI = function(self)
  GUIUtils.Toggle(self._uiObjs.Toggle_Round, true)
end
def.override().OnDestroy = function(self)
  self:ResetRankList()
  self._uiObjs = nil
  self.selectZoneId = 0
  self.selectRound = 0
  self.fightTimePoint = nil
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
def.method("number").OnRankTypeSelected = function(self, type)
  if self._curRankType ~= type then
    warn(string.format("[CrossBattlePointsFightInfoPanel:OnRankTypeSelected] rankType [%d] checked.", type))
    self:ResetRankList()
    self._curRankType = type
    self._bNeedRepositionRankList = true
    self._rankListData = RankListData.New(self._curRankType)
    self:RequireRankList(self._reqFrom, self._reqTo)
    self._uiObjs.uiScrollView:ResetPosition()
  end
end
def.method("number", "number").RequireRankList = function(self, from, to)
  self._reqFrom = from
  self._reqTo = to
  self._bWaitToUpdate = true
  PointsRaceProtocols.SendCGetZoneRankList(self.selectZoneId, self.selectRound, self._curRankType - 1, from, to)
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
      warn(string.format("[CrossBattlePointsFightInfoPanel:OnSGetRankList] abort data, p.rankType[%d] ~= self._curRankType[%d].", rankType, self._curRankType))
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
    self._uiObjs.uiScrollView:ResetPosition()
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
    warn("[ERROR][CrossBattlePointsFightInfoPanel:SetListItemInfo] displayInfo nil at index:", index)
    return
  end
  local listItem = self._uiObjs.Rank_List:FindDirect("item_" .. index)
  if nil == listItem then
    warn("[ERROR][CrossBattlePointsFightInfoPanel:SetListItemInfo] listItem nil at index:", index)
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
    GUIUtils.SetSprite(Img_MingCi, CrossBattlePointsFightInfoPanel.Top3IconName[index])
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
    warn("[ERROR][CrossBattlePointsFightInfoPanel:SetListItemInfo] badgeCfg nil for badgeId:", displayInfo.icon)
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
  warn("[CrossBattlePointsFightInfoPanel:DragScrollView] dragAmount.y:", dragAmount.y)
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
def.method().ShowZoneSelectGroup = function(self)
  GUIUtils.SetActive(self._uiObjs.Group_Zone, true)
  local Group_ChooseType = self._uiObjs.Group_Zone:FindDirect("Group_ChooseType")
  local List = Group_ChooseType:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = constant.CCrossBattlePointConst.ZONE_NUM
  uiList:Resize()
  local items = uiList.children
  for i = 1, #items do
    local item = items[i]
    local Label_Name = item:FindDirect("Label_Name_" .. i)
    local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
    GUIUtils.SetText(Label_Name, PointsRaceUtils.GetZoneName(i))
    local Img_Bg = item:FindDirect("Img_Bg_" .. i)
    local uiWidget = Img_Bg:GetComponent("UIWidget")
    if uiWidget then
      if i == self.selectZoneId then
        uiWidget:set_color(Color.Color(0.28627450980392155, 0.8156862745098039, 0.5137254901960784))
      else
        uiWidget:set_color(Color.white)
      end
    end
  end
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    Group_ChooseType:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method("number").ChooseZone = function(self, zoneId)
  self.selectZoneId = zoneId
  local showType = self._curRankType
  self._curRankType = 0
  self:UpdateTitle()
  self:OnRankTypeSelected(showType)
end
def.method().HideZoneSelectGroup = function(self)
  GUIUtils.SetActive(self._uiObjs.Group_Zone, false)
  self:UpdateBtnZoneSelectState()
end
def.method().UpdateBtnZoneSelectState = function(self)
  local uiToggle = self._uiObjs.Btn_Rule:GetComponent("UIToggleEx")
  uiToggle.value = self._uiObjs.Group_Zone.activeSelf
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Rule" then
    self:OnClickBtnChooseZone()
  elseif string.find(id, "Img_Bg_") then
    local zoneId = tonumber(string.sub(id, #"Img_Bg_" + 1))
    self:OnClickBtnZone(zoneId)
    self:HideZoneSelectGroup()
  else
    self:HideZoneSelectGroup()
  end
end
def.method().OnClickBtnChooseZone = function(self)
  local active = self._uiObjs.Group_Zone.activeSelf
  if active then
    self:HideZoneSelectGroup()
  else
    self:ShowZoneSelectGroup()
  end
end
def.method("number").OnClickBtnZone = function(self, zoneId)
  self:ChooseZone(zoneId)
end
CrossBattlePointsFightInfoPanel.Commit()
return CrossBattlePointsFightInfoPanel

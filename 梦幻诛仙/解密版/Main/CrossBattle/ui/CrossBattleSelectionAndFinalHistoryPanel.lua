local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleSelectionAndFinalHistoryPanel = Lplus.Extend(ECPanelBase, "CrossBattleSelectionAndFinalHistoryPanel")
local GUIUtils = require("GUI.GUIUtils")
local def = CrossBattleSelectionAndFinalHistoryPanel.define
def.field("table").uiObjs = nil
def.field("string").timeStr = ""
def.field("string").titleStr = ""
def.field("table").fightCorps = nil
def.field("table").fightList = nil
def.field("function").zoneChangeCb = nil
def.field("number").curZoneId = 0
local instance
def.static("=>", CrossBattleSelectionAndFinalHistoryPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleSelectionAndFinalHistoryPanel()
  end
  return instance
end
def.method("string", "string", "table", "table", "function").ShowPanel = function(self, timeStr, titleStr, fightCorps, fightList, zoneChangeCb)
  self.timeStr = timeStr
  self.titleStr = titleStr
  self.fightCorps = fightCorps
  self.fightList = fightList
  self.zoneChangeCb = zoneChangeCb
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_FIGHT_HISTORY, 1)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateInfo()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.timeStr = ""
  self.titleStr = ""
  self.fightCorps = nil
  self.fightList = nil
  self.zoneChangeCb = nil
  self.curZoneId = 0
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Type01 = self.uiObjs.Img_Bg0:FindDirect("Group_Type01")
  self.uiObjs.Label_Time = self.uiObjs.Group_Type01:FindDirect("Label_Time")
  self.uiObjs.Label_Game = self.uiObjs.Group_Type01:FindDirect("Label_Game")
  self.uiObjs.Group_List = self.uiObjs.Group_Type01:FindDirect("Group_List")
  self.uiObjs.Group_Zone = self.uiObjs.Img_Bg0:FindDirect("Group_Zone")
  self.uiObjs.Btn_Select = self.uiObjs.Img_Bg0:FindDirect("Btn_Select")
  if self.zoneChangeCb == nil then
    GUIUtils.SetActive(self.uiObjs.Btn_Select, false)
  end
end
def.method().UpdateInfo = function(self)
  self:ShowTitle()
  self:FillBattleListInfo()
end
def.method().ShowTitle = function(self)
  GUIUtils.SetText(self.uiObjs.Label_Time, self.timeStr)
  GUIUtils.SetText(self.uiObjs.Label_Game, self.titleStr)
end
def.method().FillBattleListInfo = function(self)
  local battleCount = self.fightList and #self.fightList or 0
  local ScrollView = self.uiObjs.Group_Type01:FindDirect("Group_List/Scroll View")
  local List = ScrollView:FindDirect("List_Member")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = battleCount
  uiList:Resize()
  local battles = uiList.children
  for i = 1, #battles do
    local battle = battles[i]
    self:FillBattleInfo(battle, self.fightList[i])
  end
  ScrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "table").FillBattleInfo = function(self, battle, data)
  local Group_Team1 = battle:FindDirect("Group_Team1")
  local Group_Team2 = battle:FindDirect("Group_Team2")
  self:FillCorpsInfo(Group_Team1, data:GetCorpsAId(), data:GetCorpsAState())
  self:FillCorpsInfo(Group_Team2, data:GetCorpsBId(), data:GetCorpsBState())
end
def.method("userdata", "userdata", "number").FillCorpsInfo = function(self, corps, corpsId, result)
  local Label_Team1_Name = corps:FindDirect("Label_Team1_Name")
  local Label_Server1_Name = corps:FindDirect("Label_Server1_Name")
  local Img_Badge = corps:FindDirect("Img_Badge")
  local Group_Result = corps:FindDirect("Group_Result")
  local Img_Win = Group_Result:FindDirect("Img_Win")
  local Img_Lose = Group_Result:FindDirect("Img_Lose")
  local Img_Fight = Group_Result:FindDirect("Img_Fight")
  local Img_Quit = Group_Result:FindDirect("Img_Quit")
  local Img_Prepare = Group_Result:FindDirect("Img_Prepare")
  local Img_Info = corps:FindDirect("Img_Info")
  local CorpsUtils = require("Main.Corps.CorpsUtils")
  local corpsInfo = self.fightCorps[corpsId:tostring()]
  if corpsInfo == nil then
    GUIUtils.SetText(Label_Team1_Name, textRes.CrossBattle.CrossBattleSelection[9])
    GUIUtils.SetText(Label_Server1_Name, "")
    GUIUtils.SetActive(Img_Badge, false)
    GUIUtils.SetActive(Img_Win, false)
    GUIUtils.SetActive(Img_Lose, false)
    GUIUtils.SetActive(Img_Fight, false)
    GUIUtils.SetActive(Img_Quit, false)
    GUIUtils.SetActive(Img_Prepare, false)
    GUIUtils.SetActive(Img_Info, false)
  else
    local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(corpsInfo:GetZoneId())
    GUIUtils.SetText(Label_Team1_Name, corpsInfo:GetCorpsName())
    GUIUtils.SetText(Label_Server1_Name, serverCfg and serverCfg.name or textRes.CrossBattle.CrossBattleSelection[8])
    local cfg = CorpsUtils.GetCorpsBadgeCfg(corpsInfo:GetCorpsIcon())
    if cfg ~= nil then
      GUIUtils.SetActive(Img_Badge, true)
      GUIUtils.FillIcon(Img_Badge:GetComponent("UITexture"), cfg.iconId)
    else
      GUIUtils.SetActive(Img_Badge, false)
    end
    local SingleFightResult = require("netio.protocol.mzm.gsp.crossbattle.SingleFightResult")
    if result == SingleFightResult.FIGHT_WIN or result == SingleFightResult.ABSTAIN_WIN or result == SingleFightResult.BYE_WIN then
      GUIUtils.SetActive(Img_Win, true)
      GUIUtils.SetActive(Img_Lose, false)
      GUIUtils.SetActive(Img_Fight, false)
      GUIUtils.SetActive(Img_Quit, false)
      GUIUtils.SetActive(Img_Prepare, false)
    elseif result == SingleFightResult.FIGHT_LOSE then
      GUIUtils.SetActive(Img_Win, false)
      GUIUtils.SetActive(Img_Lose, true)
      GUIUtils.SetActive(Img_Fight, false)
      GUIUtils.SetActive(Img_Quit, false)
      GUIUtils.SetActive(Img_Prepare, false)
    elseif result == SingleFightResult.ABSTAIN_LOSE then
      GUIUtils.SetActive(Img_Win, false)
      GUIUtils.SetActive(Img_Lose, true)
      GUIUtils.SetActive(Img_Fight, false)
      GUIUtils.SetActive(Img_Quit, true)
      GUIUtils.SetActive(Img_Prepare, false)
    elseif result == SingleFightResult.IN_FIGHTING then
      GUIUtils.SetActive(Img_Win, false)
      GUIUtils.SetActive(Img_Lose, false)
      GUIUtils.SetActive(Img_Fight, true)
      GUIUtils.SetActive(Img_Quit, false)
      GUIUtils.SetActive(Img_Prepare, false)
    elseif result == SingleFightResult.STATE_NOT_START then
      GUIUtils.SetActive(Img_Win, false)
      GUIUtils.SetActive(Img_Lose, false)
      GUIUtils.SetActive(Img_Fight, false)
      GUIUtils.SetActive(Img_Quit, false)
      GUIUtils.SetActive(Img_Prepare, true)
    else
      GUIUtils.SetActive(Img_Win, false)
      GUIUtils.SetActive(Img_Lose, false)
      GUIUtils.SetActive(Img_Fight, false)
      GUIUtils.SetActive(Img_Quit, false)
      GUIUtils.SetActive(Img_Prepare, false)
    end
    GUIUtils.SetActive(Img_Info, true)
  end
end
def.method("number").SetCurrentZoneId = function(self, zoneId)
  self.curZoneId = zoneId
end
def.method().ShowZoneSelectGroup = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_Zone, true)
  local Group_ChooseType = self.uiObjs.Group_Zone:FindDirect("Group_ChooseType")
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
      if i == self.curZoneId then
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
  self:UpdateBtnZoneSelectState()
end
def.method().HideZoneSelectGroup = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_Zone, false)
  self:UpdateBtnZoneSelectState()
end
def.method().UpdateBtnZoneSelectState = function(self)
  local uiToggle = self.uiObjs.Btn_Select:GetComponent("UIToggleEx")
  uiToggle.value = self.uiObjs.Group_Zone.activeSelf
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_Info" then
    self:OnCorpsDetailClick(obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Select" then
    self:OnBtnSelectClick()
  elseif string.find(id, "Img_Bg_") then
    local zoneId = tonumber(string.sub(id, #"Img_Bg_" + 1))
    self:OnBtnZoneClick(zoneId)
    self:HideZoneSelectGroup()
  else
    self:HideZoneSelectGroup()
  end
end
def.method("userdata").OnCorpsDetailClick = function(self, obj)
  if self.fightList == nil then
    return
  end
  local corpsItem = obj.parent
  if corpsItem == nil then
    return
  end
  local fightItem = corpsItem.parent
  if fightItem == nil then
    return
  end
  local fightIdx = tonumber(string.sub(fightItem.name, #"item_" + 1))
  local battle = self.fightList[fightIdx]
  if battle == nil then
    return
  end
  local corpsId
  local corpsIdx = tonumber(string.sub(corpsItem.name, #"Group_Team" + 1))
  if corpsIdx == 1 then
    corpsId = battle:GetCorpsAId()
  else
    corpsId = battle:GetCorpsBId()
  end
  if corpsId ~= nil then
    local CorpsInterface = require("Main.Corps.CorpsInterface")
    CorpsInterface.CheckCorpsInfo(corpsId)
  end
end
def.method().OnBtnSelectClick = function(self)
  local active = self.uiObjs.Group_Zone.activeSelf
  if active then
    self:HideZoneSelectGroup()
  else
    self:ShowZoneSelectGroup()
  end
end
def.method("number").OnBtnZoneClick = function(self, zoneId)
  if self.zoneChangeCb then
    self.zoneChangeCb(zoneId)
  end
end
CrossBattleSelectionAndFinalHistoryPanel.Commit()
return CrossBattleSelectionAndFinalHistoryPanel

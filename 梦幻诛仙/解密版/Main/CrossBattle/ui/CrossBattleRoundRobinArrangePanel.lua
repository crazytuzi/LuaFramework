local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleRoundRobinArrangePanel = Lplus.Extend(ECPanelBase, "CrossBattleRoundRobinArrangePanel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local GUIUtils = require("GUI.GUIUtils")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local def = CrossBattleRoundRobinArrangePanel.define
local instance
def.field("number").curIndex = 1
def.field("number").selectedIdx = 0
def.static("=>", CrossBattleRoundRobinArrangePanel).Instance = function()
  if instance == nil then
    instance = CrossBattleRoundRobinArrangePanel()
  end
  return instance
end
def.method("number").ShowPanelByIndex = function(self, idx)
  self.selectedIdx = idx
  self:ShowPanel()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_LOOP_GAME_PLAN, 1)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    local crossBattleInterface = CrossBattleInterface.Instance()
    local idx = crossBattleInterface:getCurRoundRobinIndex()
    if self.selectedIdx > 0 then
      idx = self.selectedIdx
    end
    self.curIndex = idx
    self:setTabList()
    self:setFightInfoList()
    local p = require("netio.protocol.mzm.gsp.crossbattle.CGetRoundRobinRoundInfoInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, self.curIndex)
    gmodule.network.sendProtocol(p)
  else
    self.curIndex = 1
    self.selectedIdx = 0
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Success, CrossBattleRoundRobinArrangePanel.OnRoundInfoChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Success, CrossBattleRoundRobinArrangePanel.OnRoundInfoChange)
end
def.static("table", "table").OnRoundInfoChange = function(p1, p2)
  if instance and instance:IsShow() and instance.curIndex == p1[1] then
    instance:setFightInfoList()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------CrossBattleRoundRobinArrangePanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Rank" then
    local CrossBattleRoundRobinPoint = require("Main.CrossBattle.ui.CrossBattleRoundRobinPointPanel")
    CrossBattleRoundRobinPoint.Instance():ShowPanel()
  elseif id == "Btn_Rule" then
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    local CommonDescDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(crossBattleCfg.round_robin_stage_tips_id)
    CommonDescDlg.ShowCommonTip(tipContent, {x = 0, y = 0})
  elseif id == "Img_Info" then
    local pName = clickObj.parent.name
    local itemName = clickObj.parent.parent.name
    local fightInfos = CrossBattleInterface.Instance():getRoundRobinFightInfo(self.curIndex)
    local curInfo, idx
    if fightInfos == nil then
      return
    else
      local itemStrs = string.split(itemName, "_")
      idx = tonumber(itemStrs[2])
      if idx then
        curInfo = fightInfos.fightInfos[idx]
      else
        return
      end
    end
    if curInfo == nil then
      warn("!!!!!!!!!CrossBattleRoundRobinArrangePanel info is nil:", idx)
      return
    end
    if pName == "Group_Team1" then
      local corpsId = curInfo.corps_a_brief_info.corpsId
      CorpsInterface.CheckCorpsInfo(corpsId)
    elseif pName == "Group_Team2" then
      local corpsId = curInfo.corps_b_brief_info.corpsId
      CorpsInterface.CheckCorpsInfo(corpsId)
    end
  elseif strs[1] == "Tab" then
    local idx = tonumber(strs[2])
    if idx then
      self.curIndex = idx
      local fightInfos = CrossBattleInterface.Instance():getRoundRobinFightInfo(idx)
      if fightInfos then
        self:setFightInfoList()
      else
        local p = require("netio.protocol.mzm.gsp.crossbattle.CGetRoundRobinRoundInfoInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, idx)
        gmodule.network.sendProtocol(p)
        warn("--------CrossBattleRoundRobinArrangePanel CGetRoundRobinRoundInfoInCrossBattleReq:", idx)
      end
    end
  end
end
def.method().setTabList = function(self)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local num = #crossBattleCfg.round_robin_time_points
  local List = self.m_panel:FindDirect("Img_Bg0/Group_Tab/Group_TabBtn/List")
  local uiList = List:GetComponent("UIList")
  uiList.columns = num
  uiList.itemCount = num
  uiList:Resize()
  for i = 1, num do
    local Tab = List:FindDirect(string.format("Tab_%d", i))
    local Label = Tab:FindDirect(string.format("Label_1_%d", i))
    Label:GetComponent("UILabel"):set_text(textRes.CrossBattle.roundRobinTabName[i])
    local toggle = Tab:GetComponent("UIToggle")
    if i == self.curIndex then
      toggle.value = true
    else
      toggle.value = false
    end
  end
end
def.method().setTimeStr = function(self)
  local Label = self.m_panel:FindDirect("Img_Bg0/Group_Type01/Label")
  local readyStartTime, raceTime = CrossBattleInterface.Instance():getRoundRobinTimeByIndex(self.curIndex)
  local nYear = tonumber(os.date("%Y", readyStartTime))
  local nMonth = tonumber(os.date("%m", readyStartTime))
  local nDay = tonumber(os.date("%d", readyStartTime))
  local nHour = tonumber(os.date("%H", readyStartTime))
  local nMin = tonumber(os.date("%M", readyStartTime))
  local raceHour = tonumber(os.date("%H", raceTime))
  local raceMin = tonumber(os.date("%M", raceTime))
  warn("-------setTimeStr\239\188\154", readyStartTime, raceTime, nYear, nMonth, nDay, nHour, nMin, raceHour, raceMin)
  Label:GetComponent("UILabel"):set_text(string.format(textRes.CrossBattle[38], nYear, nMonth, nDay, nHour, nMin, raceHour, raceMin))
end
def.method().setFightInfoList = function(self)
  self:setTimeStr()
  local fightInfos = CrossBattleInterface.Instance():getRoundRobinFightInfo(self.curIndex)
  if fightInfos == nil then
    fightInfos = {}
  else
    fightInfos = fightInfos.fightInfos
  end
  local List_Member = self.m_panel:FindDirect("Img_Bg0/Group_Type01/Group_List/Scroll View/List_Member")
  local uiList = List_Member:GetComponent("UIList")
  uiList.itemCount = #fightInfos
  uiList:Resize()
  local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
  for i, v in ipairs(fightInfos) do
    local item = List_Member:FindDirect("item_" .. i)
    local Group_Team1 = item:FindDirect("Group_Team1")
    local Label_Team1_Name = Group_Team1:FindDirect("Label_Team1_Name")
    local Img_Badge1 = Group_Team1:FindDirect("Img_Badge")
    local Group_Result1 = Group_Team1:FindDirect("Group_Result")
    local corps1 = v.corps_a_brief_info
    Label_Team1_Name:GetComponent("UILabel"):set_text(GetStringFromOcts(corps1.name))
    local badgeCfg1 = CorpsUtils.GetCorpsBadgeCfg(corps1.corpsBadgeId)
    if badgeCfg1 then
      local badge_texture1 = Img_Badge1:GetComponent("UITexture")
      GUIUtils.FillIcon(badge_texture1, badgeCfg1.iconId)
    end
    local Group_Team2 = item:FindDirect("Group_Team2")
    local Label_Team2_Name = Group_Team2:FindDirect("Label_Team1_Name")
    local Img_Badge2 = Group_Team2:FindDirect("Img_Badge")
    local Group_Result2 = Group_Team2:FindDirect("Group_Result")
    local corps2 = v.corps_b_brief_info
    Label_Team2_Name:GetComponent("UILabel"):set_text(GetStringFromOcts(corps2.name))
    local badgeCfg2 = CorpsUtils.GetCorpsBadgeCfg(corps2.corpsBadgeId)
    if badgeCfg2 then
      local badge_texture2 = Img_Badge2:GetComponent("UITexture")
      GUIUtils.FillIcon(badge_texture2, badgeCfg2.iconId)
    end
    local Img_Win1 = Group_Result1:FindDirect("Img_Win")
    local Img_Lose1 = Group_Result1:FindDirect("Img_Lose")
    local Img_Quit1 = Group_Result1:FindDirect("Img_Quit")
    local Img_Fight1 = Group_Result1:FindDirect("Img_Fight")
    local Img_Win2 = Group_Result2:FindDirect("Img_Win")
    local Img_Lose2 = Group_Result2:FindDirect("Img_Lose")
    local Img_Quit2 = Group_Result2:FindDirect("Img_Quit")
    local Img_Fight2 = Group_Result2:FindDirect("Img_Fight")
    local state = v.state
    if state == RoundRobinFightInfo.STATE_FIGHTING then
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(true)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(true)
    elseif state == RoundRobinFightInfo.STATE_A_WIN then
      Img_Win1:SetActive(true)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(false)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(true)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(false)
    elseif state == RoundRobinFightInfo.STATE_B_WIN then
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(true)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(false)
      Img_Win2:SetActive(true)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(false)
    elseif state == RoundRobinFightInfo.STATE_A_ABSTAIN then
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(true)
      Img_Fight1:SetActive(false)
      Img_Win2:SetActive(true)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(false)
    elseif state == RoundRobinFightInfo.STATE_B_ABSTAIN then
      Img_Win1:SetActive(true)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(false)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(true)
      Img_Fight2:SetActive(false)
    elseif state == RoundRobinFightInfo.STATE_ALL_ABSTAIN then
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(true)
      Img_Fight1:SetActive(false)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(true)
      Img_Fight2:SetActive(false)
    else
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(false)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(false)
    end
  end
end
CrossBattleRoundRobinArrangePanel.Commit()
return CrossBattleRoundRobinArrangePanel

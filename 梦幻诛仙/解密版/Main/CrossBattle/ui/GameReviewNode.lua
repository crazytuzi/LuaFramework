local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GameReviewNode = Lplus.Extend(TabNode, "GameReviewNode")
local GUIUtils = require("GUI.GUIUtils")
local RoundRobinRoundStage = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinRoundStage")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local WatchGameMgr = require("Main.CrossBattle.WatchGameMgr")
local watchGameMgr = WatchGameMgr.Instance()
local CorpsUtils = require("Main.Corps.CorpsUtils")
local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
local SingleFightResult = require("netio.protocol.mzm.gsp.crossbattle.SingleFightResult")
local CrossBattleFinalMgr = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local def = GameReviewNode.define
def.field("number").roundRobinIdx = 1
def.field("table").roundRobinFightList = nil
def.field("number").curSelectedStage = -1
def.field("number").selectionIdx = 1
def.field("number").selectionZone = 1
def.field("table").selectionFightList = nil
def.field("number").finalIdx = 1
def.field("table").finalFightList = nil
local stageNode = {
  [CrossBattleActivityStage.STAGE_ROUND_ROBIN] = {
    tabName = "Tab_01",
    groupName = "Group_XunHuan"
  },
  [CrossBattleActivityStage.STAGE_SELECTION] = {
    tabName = "Tab_02",
    groupName = "Group_XuanBa"
  },
  [CrossBattleActivityStage.STAGE_FINAL] = {
    tabName = "Tab_03",
    groupName = "Group_ZongJue"
  }
}
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:selectedStageTab(-1)
  local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
  warn("---------GameReviewNode:", curStage)
  self:setFightInfoByStage(curStage)
end
def.override().OnHide = function(self)
  self.roundRobinIdx = 1
  self.roundRobinFightList = nil
  self.curSelectedStage = -1
  self.selectionIdx = 1
  self.selectionZone = 1
  self.selectionFightList = nil
  self.finalIdx = 1
  self.finalFightList = nil
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("-------GameReviewNode click:", id)
  local strs = string.split(id, "_")
  if id == "Tab_01" then
    self:setFightInfoByStage(CrossBattleActivityStage.STAGE_ROUND_ROBIN)
  elseif id == "Tab_02" then
    self:setFightInfoByStage(CrossBattleActivityStage.STAGE_SELECTION)
  elseif id == "Tab_03" then
    self:setFightInfoByStage(CrossBattleActivityStage.STAGE_FINAL)
  elseif id == "Btn_Zone01" then
    local pName = clickObj.parent.name
    if pName == "Group_XunHuan" then
      local Group_Zone01 = self.m_node:FindDirect("Group_XunHuan/Btn_Zone01/Group_Zone01")
      if Group_Zone01.activeSelf then
        Group_Zone01:SetActive(false)
      else
        self:setRoundRobinIndexList()
      end
    elseif pName == "Group_XuanBa" then
      local Group_Zone01 = self.m_node:FindDirect("Group_XuanBa/Btn_Zone01/Group_Zone01")
      if Group_Zone01.activeSelf then
        Group_Zone01:SetActive(false)
      else
        self:setSelectionZoneList()
      end
    elseif pName == "Group_ZongJue" then
      local Group_Zone01 = self.m_node:FindDirect("Group_ZongJue/Btn_Zone01/Group_Zone01")
      if Group_Zone01.activeSelf then
        Group_Zone01:SetActive(false)
      else
        self:setFinalIdxList()
      end
    end
  elseif id == "Btn_Zone02" then
    local Group_Zone02 = self.m_node:FindDirect("Group_XuanBa/Btn_Zone02/Group_Zone02")
    if Group_Zone02.activeSelf then
      Group_Zone02:SetActive(false)
    else
      self:setSelectionIdxList()
    end
  elseif id == "Btn_Video" then
    local groupObj = clickObj.parent.parent.parent.parent
    local gNmae = groupObj.name
    local pname = clickObj.parent.name
    local pstrs = string.split(pname, "_")
    local idx = tonumber(pstrs[2])
    if gNmae == "Group_XunHuanList" then
      if idx then
        local fightInfo = self.roundRobinFightList[idx]
        local crops1 = fightInfo.corps1
        local crops2 = fightInfo.corps2
        gmodule.moduleMgr:GetModule(ModuleId.CROSS_BATTLE):watchRoundRobinFightRecord(self.roundRobinIdx, crops1.corpsId, crops2.corpsId)
      end
    elseif gNmae == "Group_XuanBaList" then
      if idx then
        local fightInfo = self.selectionFightList[idx]
        local state = fightInfo.state1
        local recordId = fightInfo.fightRecordId
        warn("-------selectionFightRecord:", idx, state, recordId)
        if recordId:eq(Int64.new(0)) then
          Toast(textRes.CrossBattle[67])
          return
        end
        if state == SingleFightResult.STATE_NOT_START then
          Toast(textRes.CrossBattle[64])
        else
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CGetRealtimeRecordReq").new(recordId))
        end
      end
    elseif gNmae == "Group_ZongJueList" and idx then
      local fightInfo = self.finalFightList[idx]
      local state = fightInfo.state1
      local recordId = fightInfo.fightRecordId
      warn("------FinalFightRecored:", idx, state, recordId)
      if recordId:eq(Int64.new(0)) then
        Toast(textRes.CrossBattle[67])
        return
      end
      if state == SingleFightResult.STATE_NOT_START then
        Toast(textRes.CrossBattle[64])
      else
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CGetRealtimeRecordReq").new(recordId))
      end
    end
  elseif strs[1] == "Img" and strs[2] == "XunHuan" then
    local idx = tonumber(strs[3])
    if idx then
      self.roundRobinIdx = idx
      local Group_Zone01 = self.m_node:FindDirect("Group_XunHuan/Btn_Zone01/Group_Zone01")
      Group_Zone01:SetActive(false)
      self:setRoundRobinFightInfo()
    end
  elseif strs[1] == "Img" and strs[2] == "XuanBa" then
    local idx = tonumber(strs[3])
    if idx then
      local parentObj = clickObj.parent.parent.parent.parent
      local pName = parentObj.name
      if pName == "Group_Zone01" then
        self.selectionZone = idx
        self:setSelectionFightInfo()
      elseif pName == "Group_Zone02" then
        self.selectionIdx = idx
        self:setSelectionFightInfo()
      end
      parentObj:SetActive(false)
    end
  elseif strs[1] == "Img" and strs[2] == "ZongJue" then
    local idx = tonumber(strs[3])
    if idx then
      self.finalIdx = idx
      self:setFinalFightInfo()
      local Group_Zone01 = self.m_node:FindDirect("Group_ZongJue/Btn_Zone01/Group_Zone01")
      Group_Zone01:SetActive(false)
    end
  else
    local Group_Zone01 = self.m_node:FindDirect("Group_XunHuan/Btn_Zone01/Group_Zone01")
    Group_Zone01:SetActive(false)
    local Group_Zone01 = self.m_node:FindDirect("Group_XuanBa/Btn_Zone01/Group_Zone01")
    Group_Zone01:SetActive(false)
    local Group_Zone02 = self.m_node:FindDirect("Group_XuanBa/Btn_Zone02/Group_Zone02")
    Group_Zone02:SetActive(false)
    local Group_Zone01 = self.m_node:FindDirect("Group_ZongJue/Btn_Zone01/Group_Zone01")
    Group_Zone01:SetActive(false)
  end
end
def.method("number").setFightInfoByStage = function(self, stage)
  local Group_NoData = self.m_node:FindDirect("Group_NoData")
  local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
  if curStage == CrossBattleActivityStage.STAGE_CLOSE then
    local startTime, endTime = CrossBattleInterface.Instance():getCrossBattleStageTime(CrossBattleActivityStage.STAGE_FINAL)
    if endTime <= _G.GetServerTime() then
      curStage = CrossBattleActivityStage.STAGE_FINAL + 1
    end
  end
  if stage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
    if stage <= curStage then
      local lastStage = self.curSelectedStage
      self.curSelectedStage = stage
      self:selectedStageTab(stage)
      self:setRoundRobinFightInfo()
    else
      self:noOpenToast(stage)
    end
  elseif stage == CrossBattleActivityStage.STAGE_SELECTION then
    if stage <= curStage then
      local lastStage = self.curSelectedStage
      self.curSelectedStage = stage
      self:selectedStageTab(stage)
      self:setSelectionFightInfo()
    else
      self:noOpenToast(stage)
    end
  elseif stage == CrossBattleActivityStage.STAGE_FINAL then
    if stage <= curStage then
      local lastStage = self.curSelectedStage
      self.curSelectedStage = stage
      self:selectedStageTab(stage)
      self:setFinalFightInfo()
    else
      self:noOpenToast(stage)
    end
  elseif curStage >= CrossBattleActivityStage.STAGE_ROUND_ROBIN then
    local lastStage = self.curSelectedStage
    self.curSelectedStage = CrossBattleActivityStage.STAGE_ROUND_ROBIN
    self:selectedStageTab(CrossBattleActivityStage.STAGE_ROUND_ROBIN)
    self:setRoundRobinFightInfo()
  end
end
def.method("number").selectedStageTab = function(self, stage)
  local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
  if curStage == CrossBattleActivityStage.STAGE_CLOSE then
    local startTime, endTime = CrossBattleInterface.Instance():getCrossBattleStageTime(CrossBattleActivityStage.STAGE_FINAL)
    if endTime <= _G.GetServerTime() then
      curStage = CrossBattleActivityStage.STAGE_FINAL + 1
    end
  end
  local Group_TabBtn = self.m_node:FindDirect("Group_TabBtn")
  for i, v in pairs(stageNode) do
    local group = self.m_node:FindDirect(v.groupName)
    local Tab = Group_TabBtn:FindDirect(v.tabName)
    if stage == i then
      if stage <= curStage then
        Tab:GetComponent("UIToggle"):set_isChecked(true)
        group:SetActive(true)
      else
        Tab:GetComponent("UIToggle"):set_isChecked(false)
        group:SetActive(false)
      end
    else
      Tab:GetComponent("UIToggle"):set_isChecked(false)
      group:SetActive(false)
    end
  end
end
def.method("number").noOpenToast = function(self, stage)
  local openTime, _ = CrossBattleInterface.Instance():getCrossBattleStageTime(stage)
  if openTime > 0 then
    local nYear = tonumber(os.date("%Y", openTime))
    local nMonth = tonumber(os.date("%m", openTime))
    local nDay = tonumber(os.date("%d", openTime))
    local nHour = tonumber(os.date("%H", openTime))
    local nMin = tonumber(os.date("%M", openTime))
    local nSec = tonumber(os.date("%S", openTime))
    Toast(string.format(textRes.CrossBattle[4], textRes.CrossBattle.stageStr[stage], nYear, nMonth, nDay, nHour, nMin))
  else
    warn("---------GameReviewNode time error:", stage, openTime)
  end
  local Group_TabBtn = self.m_node:FindDirect("Group_TabBtn")
  local curNode = stageNode[stage]
  if curNode then
    local curTab = Group_TabBtn:FindDirect(curNode.tabName)
    curTab:GetComponent("UIToggle"):set_isChecked(false)
    warn("---------noOpenToast cur:", curTab:GetComponent("UIToggle").value)
  end
  local lastStage = stageNode[self.curSelectedStage]
  if lastStage then
    local lastTab = Group_TabBtn:FindDirect(lastStage.tabName)
    lastTab:GetComponent("UIToggle"):set_isChecked(true)
  end
end
def.method().setRoundRobinFightInfo = function(self)
  local Group_XunHuan = self.m_node:FindDirect("Group_XunHuan")
  Group_XunHuan:SetActive(true)
  local Label_1 = Group_XunHuan:FindDirect("Btn_Zone01/Label_1")
  local idxStr = textRes.CrossBattle.roundRobinTabName[self.roundRobinIdx]
  Label_1:GetComponent("UILabel"):set_text(idxStr)
  self:setRoundRobinFightList({})
  watchGameMgr:getRoundRobinLiveFightInfo(self.roundRobinIdx, function(infos)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    if infos == nil or #infos == 0 then
      self:setRoundRobinFightList({})
      return
    end
    local fightInfoList = {}
    for i, v in ipairs(infos) do
      if v.state ~= RoundRobinFightInfo.STATE_NOT_START and v.state ~= RoundRobinFightInfo.STATE_FIGHTING then
        table.insert(fightInfoList, v)
      end
    end
    self:setRoundRobinFightList(fightInfoList)
  end)
end
def.method().setRoundRobinIndexList = function(self)
  local roundCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local timePoints = roundCfg.round_robin_time_points
  local Group_Zone01 = self.m_node:FindDirect("Group_XunHuan/Btn_Zone01/Group_Zone01")
  Group_Zone01:SetActive(true)
  local num = 0
  local curTime = _G.GetServerTime()
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  for i, v in ipairs(timePoints) do
    local timePointCfg = TimeCfgUtils.GetCommonTimePointCfg(v)
    local time = AbsoluteTimer.GetServerTimeByDate(timePointCfg.year, timePointCfg.month, timePointCfg.day, 0, 0, 0)
    if curTime >= time then
      num = num + 1
    end
  end
  local List = self.m_node:FindDirect("Group_XunHuan/Btn_Zone01/Group_Zone01/Group_ChooseType/List_XunHuan")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = num
  uiList:Resize()
  for i = 1, num do
    local Btn = List:FindDirect("Btn_XunHuan_" .. i)
    local Label_Name = Btn:FindDirect("Label_Name_" .. i)
    Label_Name:GetComponent("UILabel"):set_text(textRes.CrossBattle.roundRobinTabName[i])
  end
end
def.method("table").setRoundRobinFightList = function(self, fightInfos)
  local List_Member = self.m_node:FindDirect("Group_XunHuan/Group_XunHuanList/Scroll View/List_Member")
  local uiList = List_Member:GetComponent("UIList")
  self.roundRobinFightList = fightInfos
  uiList.itemCount = #fightInfos
  uiList:Resize()
  for i, v in ipairs(fightInfos) do
    local item = List_Member:FindDirect("item_" .. i)
    local Group_Team1 = item:FindDirect("Group_Team1")
    self:setCorpsInfo(Group_Team1, v.corps1)
    self:setRoundRobinResult(Group_Team1, v.state, 1)
    local Group_Team2 = item:FindDirect("Group_Team2")
    self:setCorpsInfo(Group_Team2, v.corps2)
    self:setRoundRobinResult(Group_Team2, v.state, 2)
    local Btn_Video = item:FindDirect("Btn_Video")
    if v.state == RoundRobinFightInfo.STATE_ALL_ABSTAIN or v.state == RoundRobinFightInfo.STATE_A_ABSTAIN or v.state == RoundRobinFightInfo.STATE_B_ABSTAIN then
      Btn_Video:SetActive(false)
    else
      Btn_Video:SetActive(true)
    end
  end
end
def.method("userdata", "number", "number").setRoundRobinResult = function(self, Group_Team, state, corpsIdx)
  local Group_Result = Group_Team:FindDirect("Group_Result")
  local Img_Win = Group_Result:FindDirect("Img_Win")
  local Img_Lose = Group_Result:FindDirect("Img_Lose")
  local Img_Quit = Group_Result:FindDirect("Img_Quit")
  local Img_Fight = Group_Result:FindDirect("Img_Fight")
  local isQuit = state == RoundRobinFightInfo.STATE_ALL_ABSTAIN or corpsIdx == 1 and state == RoundRobinFightInfo.STATE_A_ABSTAIN or corpsIdx == 2 and state == RoundRobinFightInfo.STATE_B_ABSTAIN
  local isWin = state ~= RoundRobinFightInfo.STATE_NOT_START and not isQuit and (corpsIdx == 1 and (state == RoundRobinFightInfo.STATE_A_WIN or state == RoundRobinFightInfo.STATE_B_ABSTAIN) or corpsIdx == 2 and (state == RoundRobinFightInfo.STATE_B_WIN or state == RoundRobinFightInfo.STATE_A_ABSTAIN))
  local isLose = state ~= RoundRobinFightInfo.STATE_NOT_START and not isWin and not isQuit
  Img_Win:SetActive(isWin)
  Img_Lose:SetActive(isLose)
  Img_Quit:SetActive(isQuit)
  Img_Fight:SetActive(state == RoundRobinFightInfo.STATE_FIGHTING)
end
def.method("userdata", "table").setCorpsInfo = function(self, Group_Team, corpsInfo)
  local Label_Team1_Name = Group_Team:FindDirect("Label_Team1_Name")
  local Label_Server1_Name = Group_Team:FindDirect("Label_Server1_Name")
  local Img_Badge = Group_Team:FindDirect("Img_Badge")
  if corpsInfo == nil then
    Label_Team1_Name:GetComponent("UILabel"):set_text(textRes.CrossBattle.CrossBattleSelection[9])
    if Label_Server1_Name then
      Label_Server1_Name:GetComponent("UILabel"):set_text("")
    end
    Img_Badge:SetActive(false)
    return
  end
  Img_Badge:SetActive(true)
  local name = corpsInfo.name
  local serverName = corpsInfo.serverName or ""
  if Label_Server1_Name then
    Label_Server1_Name:GetComponent("UILabel"):set_text(serverName)
  end
  Label_Team1_Name:GetComponent("UILabel"):set_text(name)
  local badgeCfg = CorpsUtils.GetCorpsBadgeCfg(corpsInfo.badgeId)
  if badgeCfg then
    GUIUtils.FillIcon(Img_Badge:GetComponent("UITexture"), badgeCfg.iconId)
  end
end
def.method().setSelectionFightInfo = function(self)
  self:setSelectionStageInfo()
  self:setSelectionFightInfoList({})
  watchGameMgr:getSelectionFightInfo(self.selectionIdx, self.selectionZone, function(fightInfos)
    warn("----------getSelectionFightInfo callback:", self.m_panel)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    local fightList = {}
    for i, v in ipairs(fightInfos) do
      if (v.corps1 or v.corps2) and v.state1 ~= SingleFightResult.STATE_NOT_START and v.state1 ~= SingleFightResult.IN_FIGHTING then
        table.insert(fightList, v)
      end
    end
    self:setSelectionFightInfoList(fightList)
  end)
end
def.method().setSelectionStageInfo = function(self)
  local Group_XuanBa = self.m_node:FindDirect("Group_XuanBa")
  local Btn_Zone01 = Group_XuanBa:FindDirect("Btn_Zone01")
  local Btn_Zone02 = Group_XuanBa:FindDirect("Btn_Zone02")
  local Label_1 = Btn_Zone01:FindDirect("Label_1")
  local Label_2 = Btn_Zone02:FindDirect("Label_2")
  Label_1:GetComponent("UILabel"):set_text(PointsRaceUtils.GetZoneName(self.selectionZone))
  Label_2:GetComponent("UILabel"):set_text(textRes.CrossBattle.CrossBattleSelection.BattleType[self.selectionIdx])
end
def.method().setSelectionZoneList = function(self)
  local Group_XuanBa = self.m_node:FindDirect("Group_XuanBa")
  local Btn_Zone01 = Group_XuanBa:FindDirect("Btn_Zone01")
  local Group_Zone01 = Btn_Zone01:FindDirect("Group_Zone01")
  Group_Zone01:SetActive(true)
  local List_XuanBa = Group_Zone01:FindDirect("Group_ChooseType/List_XuanBa")
  local uiList = List_XuanBa:GetComponent("UIList")
  local num = constant.CCrossBattlePointConst.ZONE_NUM
  uiList.itemCount = num
  uiList:Resize()
  for i = 1, num do
    local Btn = List_XuanBa:FindDirect("Btn_XuanBa_" .. i)
    local Label_Name = Btn:FindDirect("Label_Name_" .. i)
    Label_Name:GetComponent("UILabel"):set_text(PointsRaceUtils.GetZoneName(i))
  end
end
def.method().setSelectionIdxList = function(self)
  local Group_XuanBa = self.m_node:FindDirect("Group_XuanBa")
  local Btn_Zone02 = Group_XuanBa:FindDirect("Btn_Zone02")
  local Group_Zone02 = Btn_Zone02:FindDirect("Group_Zone02")
  Group_Zone02:SetActive(true)
  local selectionIdxList = CrossBattleInterface.GetReachedCrossBattleSelectionStage()
  local List_XuanBa = Group_Zone02:FindDirect("Group_ChooseType/List_XuanBa")
  local uiList = List_XuanBa:GetComponent("UIList")
  local num = #selectionIdxList
  uiList.itemCount = num
  uiList:Resize()
  for i = 1, num do
    local Btn = List_XuanBa:FindDirect("Btn_XuanBa_" .. i)
    local Label_Name = Btn:FindDirect("Label_Name_" .. i)
    Label_Name:GetComponent("UILabel"):set_text(textRes.CrossBattle.CrossBattleSelection.BattleType[i])
  end
end
def.method("table").setSelectionFightInfoList = function(self, fightInfos)
  local List_Member = self.m_node:FindDirect("Group_XuanBa/Group_XuanBaList/Scroll View/List_Member")
  local uiList = List_Member:GetComponent("UIList")
  self.selectionFightList = fightInfos
  uiList.itemCount = #fightInfos
  uiList:Resize()
  for i, v in ipairs(fightInfos) do
    local item = List_Member:FindDirect("item_" .. i)
    local Group_Team1 = item:FindDirect("Group_Team1")
    self:setCorpsInfo(Group_Team1, v.corps1)
    self:setSelectionResultState(Group_Team1, v.state1)
    local Group_Team2 = item:FindDirect("Group_Team2")
    self:setCorpsInfo(Group_Team2, v.corps2)
    self:setSelectionResultState(Group_Team2, v.state2)
    local Btn_Video = item:FindDirect("Btn_Video")
    if v.corps1 == nil or v.corps2 == nil or v.state1 == SingleFightResult.ABSTAIN_WIN or v.state1 == SingleFightResult.ABSTAIN_LOSE then
      Btn_Video:SetActive(false)
    else
      Btn_Video:SetActive(true)
    end
  end
end
def.method("userdata", "number").setSelectionResultState = function(self, Group_Team, state)
  local Group_Result = Group_Team:FindDirect("Group_Result")
  local Img_Win = Group_Result:FindDirect("Img_Win")
  local Img_Lose = Group_Result:FindDirect("Img_Lose")
  local Img_Quit = Group_Result:FindDirect("Img_Quit")
  local Img_Fight = Group_Result:FindDirect("Img_Fight")
  local isQuit = state == SingleFightResult.ABSTAIN_LOSE
  local isWin = state == SingleFightResult.FIGHT_WIN or state == SingleFightResult.ABSTAIN_WIN or state == SingleFightResult.BYE_WIN
  local isLose = state == SingleFightResult.FIGHT_LOSE
  Img_Win:SetActive(isWin)
  Img_Lose:SetActive(isLose)
  Img_Quit:SetActive(isQuit)
  Img_Fight:SetActive(state == SingleFightResult.IN_FIGHTING)
end
def.method().setFinalFightInfo = function(self)
  local Group_ZongJue = self.m_node:FindDirect("Group_ZongJue")
  local Btn_Zone02 = Group_ZongJue:FindDirect("Btn_Zone02")
  Btn_Zone02:SetActive(false)
  self:setFinalIdxInfo()
  self:setFinalFightInfoList({})
  watchGameMgr:getFinalFightInfo(self.finalIdx, function(fightInfos)
    warn("----------getFinalFightInfo callback:", self.m_panel)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    local fightList = {}
    for i, v in ipairs(fightInfos) do
      if (v.corps1 or v.corps2) and v.state1 ~= SingleFightResult.STATE_NOT_START and v.state1 ~= SingleFightResult.IN_FIGHTING then
        table.insert(fightList, v)
      end
    end
    self:setFinalFightInfoList(fightList)
  end)
end
def.method().setFinalIdxList = function(self)
  local Group_Zone01 = self.m_node:FindDirect("Group_ZongJue/Btn_Zone01/Group_Zone01")
  Group_Zone01:SetActive(true)
  local finalIdxList = CrossBattleInterface.GetReachedCrossBattleFinalStage()
  local List = Group_Zone01:FindDirect("Group_ChooseType/List_ZongJue")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #finalIdxList
  uiList:Resize()
  for i, v in ipairs(finalIdxList) do
    local Btn = List:FindDirect("Btn_ZongJue_" .. i)
    local Label_Name = Btn:FindDirect("Label_Name_" .. i)
    local finalType = math.floor((i - 1) / CrossBattleFinalMgr.STAGE_BATTLE_COUNT) + 1
    local typeRound = (i - 1) % CrossBattleFinalMgr.STAGE_BATTLE_COUNT + 1
    Label_Name:GetComponent("UILabel"):set_text(textRes.CrossBattle.CrossBattleFinal.BattleType[finalType] .. "(" .. typeRound .. ")")
  end
end
def.method().setFinalIdxInfo = function(self)
  local Group_ZongJue = self.m_node:FindDirect("Group_ZongJue")
  local Btn_Zone01 = Group_ZongJue:FindDirect("Btn_Zone01")
  local Label_1 = Btn_Zone01:FindDirect("Label_1")
  local finalType = math.floor((self.finalIdx - 1) / CrossBattleFinalMgr.STAGE_BATTLE_COUNT) + 1
  local typeRound = (self.finalIdx - 1) % CrossBattleFinalMgr.STAGE_BATTLE_COUNT + 1
  Label_1:GetComponent("UILabel"):set_text(textRes.CrossBattle.CrossBattleFinal.BattleType[finalType] .. "(" .. typeRound .. ")")
end
def.method("table").setFinalFightInfoList = function(self, fightInfos)
  local List_Member = self.m_node:FindDirect("Group_ZongJue/Group_ZongJueList/Scroll View/List_Member")
  local uiList = List_Member:GetComponent("UIList")
  self.finalFightList = fightInfos
  uiList.itemCount = #fightInfos
  uiList:Resize()
  for i, v in ipairs(fightInfos) do
    local item = List_Member:FindDirect("item_" .. i)
    local Group_Team1 = item:FindDirect("Group_Team1")
    self:setCorpsInfo(Group_Team1, v.corps1)
    self:setSelectionResultState(Group_Team1, v.state1)
    local Group_Team2 = item:FindDirect("Group_Team2")
    self:setCorpsInfo(Group_Team2, v.corps2)
    self:setSelectionResultState(Group_Team2, v.state2)
    local Btn_Video = item:FindDirect("Btn_Video")
    if v.corps1 == nil or v.corps2 == nil or v.state1 == SingleFightResult.ABSTAIN_WIN or v.state1 == SingleFightResult.ABSTAIN_LOSE then
      Btn_Video:SetActive(false)
    else
      Btn_Video:SetActive(true)
    end
  end
end
GameReviewNode.Commit()
return GameReviewNode

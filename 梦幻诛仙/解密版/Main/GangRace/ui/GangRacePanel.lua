local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GangRacePanel = Lplus.Extend(ECPanelBase, "GangRacePanel")
local ECUIModel = require("Model.ECUIModel")
local GangRaceModule = Lplus.ForwardDeclare("GangRaceModule")
local GangRaceProtocol = require("Main.GangRace.GangRaceProtocol")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local RaceConsts = require("netio.protocol.mzm.gsp.gangrace.RaceConsts")
local def = GangRacePanel.define
local instance
def.field("boolean").bWaitData = false
def.field("table").uiTbl = nil
def.field("table").sortInfo = nil
def.field("table").racePlayers = nil
def.field("table").actionInfos = nil
def.field("table").localPosition = nil
def.field("table").chatMsgTime = nil
def.field("table").chatMsgs = nil
def.field("number").actionTimerId = 0
def.field("number").allStep = 0
def.field("number").curStep = 0
def.field("number").curStepRunTime = 0
def.field("number").playerRefrashTime = 0
def.field("number").myVoteIndex = 0
def.field("number").raceStatus = 0
def.field("number").statusOverTime = 0
def.field("boolean").isPlayAction = false
def.field("number").curGameRound = 0
def.field("number").maxGameRound = 0
def.field("number").raceWinIndex = 0
def.const("table").GameRaceState = {
  NORMAL = 1,
  VOTE = 2,
  VOTEOVER = 3,
  RUNPREV = 4,
  RUNNING = 5,
  RACEOVER = 6,
  GAMEOVER = 7
}
local RACE_OBJ_COUNT = 5
local RACE_STEP_TIME = 2
local STEP_MOVE_DIST = 2
local RACE_MOVE_DIST = 634
local ACTIONREF_TIME = 0.1
local PLAYERREF_TIME = 1
local VOTE_INFO_TIME = 1
local CHAT_SHOW_TIME = 2
def.static("=>", GangRacePanel).Instance = function()
  if not instance then
    instance = GangRacePanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:Reset()
  self.bWaitData = true
  Event.RegisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_RaceStatus, GangRacePanel.OnGangRaceStatus)
  GangRaceProtocol.sendGetRaceStatus()
end
def.method().Init = function(self)
  local msgs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GANGRACE_ACTION_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local code = DynamicRecord.GetIntValue(entry, "ActCode")
    local msg = DynamicRecord.GetStringValue(entry, "msg")
    msgs[code] = msg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  self.chatMsgs = msgs
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_VoteStatus, GangRacePanel.OnVoteStatus)
  Event.RegisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_VoteSuccess, GangRacePanel.OnVoteSuccess)
  Event.RegisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_PlayerInfo, GangRacePanel.OnPlayerInfo)
  Event.RegisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_RunningInfo, GangRacePanel.OnRunningInfo)
  Event.RegisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_RaceStart, GangRacePanel.OnRaceStart)
  self:InitUI()
  GangRaceProtocol.sendGetPlayerInfoReq()
  self:updateRaceStatus()
  Timer:RegisterListener(self.UpdateTimer, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_RaceStatus, GangRacePanel.OnGangRaceStatus)
  Event.UnregisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_VoteStatus, GangRacePanel.OnVoteStatus)
  Event.UnregisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_VoteSuccess, GangRacePanel.OnVoteSuccess)
  Event.UnregisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_PlayerInfo, GangRacePanel.OnPlayerInfo)
  Event.UnregisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_RunningInfo, GangRacePanel.OnRunningInfo)
  Event.UnregisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_RaceStart, GangRacePanel.OnRaceStart)
  Timer:RemoveListener(self.UpdateTimer)
  if self.actionTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.actionTimerId)
    self.actionTimerId = 0
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
    self.localPosition = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_Bg1 = Img_Bg0:FindDirect("Img_Bg1")
  local Group_Right = Img_Bg1:FindDirect("Group_Right")
  uiTbl.Img_Bg1 = Img_Bg1
  local playerList = {}
  for i = 1, RACE_OBJ_COUNT do
    playerList[i] = Group_Right:FindDirect(("Group_Player%d"):format(i))
  end
  uiTbl.Group_Right = playerList
  local Label_MoneyNumber = Img_Bg1:FindDirect("Label_MoneyNumber")
  uiTbl.Label_OwnNumber = Label_MoneyNumber
  local Img_TitleBg = Img_Bg1:FindDirect("Img_TitleBg")
  local Label_Time = Img_TitleBg:FindDirect("Label_Time")
  local Label_Info = Img_TitleBg:FindDirect("Label_Info")
  local Label_Stop = Img_TitleBg:FindDirect("Label_Stop")
  local Label_NextRace = Img_TitleBg:FindDirect("Label_NextRace")
  local Label_NextRaceTime = Img_TitleBg:FindDirect("Label_NextRaceTime")
  local Label_RaceEnd = Img_TitleBg:FindDirect("Label_RaceEnd")
  uiTbl.Label_Time = Label_Time
  uiTbl.Label_Info = Label_Info
  uiTbl.Label_Stop = Label_Stop
  uiTbl.Label_NextRace = Label_NextRace
  uiTbl.Label_NextRaceTime = Label_NextRaceTime
  uiTbl.Label_RaceEnd = Label_RaceEnd
  uiTbl.Label_Time:GetComponent("UILabel"):set_text(textRes.GangRace[13])
  local Group_Chat = {}
  local playerDirects = {}
  local Img_Grass = Img_Bg0:FindDirect("Img_Grass")
  local Grass_TimeLeft = Img_Grass:FindDirect("Label_TimeLeft")
  local Grass_Time = Img_Grass:FindDirect("Label_Time")
  local Grass_ZhiChi = Img_Grass:FindDirect("Label_Number")
  local Group_Player = Img_Grass:FindDirect("Group_Player")
  local PlayerName = {}
  local Img_Gold = {}
  for i = 1, RACE_OBJ_COUNT do
    local groupPlayer = Group_Player:FindDirect(("Group_Player%d"):format(i))
    local player = groupPlayer:FindDirect("Img_TXkuang")
    Img_Gold[i] = groupPlayer:FindDirect("Img_Gold")
    PlayerName[i] = groupPlayer:FindDirect(("Label_PlayerName%d"):format(i))
    PlayerName[i]:GetComponent("UILabel"):set_text("--")
    playerDirects[i] = player
    self.localPosition[i] = player.localPosition.x
    Group_Chat[i] = player:FindDirect(("Group_Chat%d"):format(i))
    Group_Chat[i]:SetActive(false)
    Img_Gold[i]:SetActive(false)
  end
  uiTbl.Group_Player = playerDirects
  uiTbl.Group_Chat = Group_Chat
  uiTbl.Player_Name = PlayerName
  uiTbl.Img_Gold = Img_Gold
  uiTbl.Grass_TimeLeft = Grass_TimeLeft
  uiTbl.Grass_Time = Grass_Time
  local rateValue = constant.CGangRaceConsts.winnerGoldRate / 100
  Grass_ZhiChi:GetComponent("UILabel"):set_text(string.format("%d%%", rateValue))
  local Btn_1000 = Img_Bg1:FindDirect("Btn_1000")
  uiTbl.Btn_Select1000 = Btn_1000
  local Btn_10000 = Img_Bg1:FindDirect("Btn_10000")
  uiTbl.Btn_Select10000 = Btn_10000
  local Label_Number = Img_Bg1:FindDirect("Label_Number")
  uiTbl.Label_Number = Label_Number
  if not self.sortInfo then
    self.sortInfo = {}
    for i = 1, RACE_OBJ_COUNT do
      self.sortInfo[i] = {idx = i, pos = 0}
    end
  end
  if not self.chatMsgTime then
    self.chatMsgTime = {}
    for i = 1, RACE_OBJ_COUNT do
      self.chatMsgTime[i] = 0
    end
  end
  if not self.racePlayers then
    self.racePlayers = {}
  end
  local racePlayers = self.racePlayers
  for i = 1, RACE_OBJ_COUNT do
    racePlayers[i] = {
      idx = i,
      step = 0,
      act = 0,
      modelid = 0,
      name = "--",
      totleMoney = 0,
      myMoney = 0
    }
  end
  self:UpdateGoldMoney()
  self:UpdatePlayerList(false)
  self:ShowPlayerHeadIcon(self.raceStatus ~= GangRacePanel.GameRaceState.RUNPREV)
end
def.method().Reset = function(self)
  local sortInfo = self.sortInfo
  if sortInfo then
    for i = 1, RACE_OBJ_COUNT do
      sortInfo[i].idx = i
      sortInfo[i].pos = 0
    end
  end
  local chatMsgTime = self.chatMsgTime
  if chatMsgTime then
    for i = 1, RACE_OBJ_COUNT do
      chatMsgTime[i] = 0
    end
  end
  self.allStep = 0
  self.actionInfos = nil
  self.isPlayAction = false
  self.raceWinIndex = 0
  if self.m_panel and false == self.m_panel.isnil then
    for i = 1, RACE_OBJ_COUNT do
      self:updateRacePlayerPos(i, 0)
    end
    self:CloseAllChatMsg()
  end
end
def.method().PlayActionOver = function(self)
  self:UpdateGoldIcon()
  self:CloseAllChatMsg()
  if self.curGameRound + 1 >= self.maxGameRound then
    self:changeRaceStatus(GangRacePanel.GameRaceState.GAMEOVER)
  else
    self:changeRaceStatus(GangRacePanel.GameRaceState.RACEOVER)
  end
end
def.static("table", "table").OnGangRaceStatus = function(params, context)
  local self = GangRacePanel.Instance()
  local statusInfo = params
  local status = statusInfo.statuscode
  local raceStatus = 0
  if status == RaceConsts.RACE_VOTE_STAGE then
    raceStatus = GangRacePanel.GameRaceState.VOTE
    self.statusOverTime = statusInfo.beginTime + constant.CGangRaceConsts.voteTime * 60
  elseif status == RaceConsts.RACE_VOTE_SUCCESS then
    raceStatus = GangRacePanel.GameRaceState.VOTEOVER
    self.statusOverTime = statusInfo.beginTime + constant.CGangRaceConsts.voteTime * 60
  elseif status == RaceConsts.RACE_RUN_STAGE then
    raceStatus = GangRacePanel.GameRaceState.RUNPREV
    self.statusOverTime = statusInfo.beginTime + constant.CGangRaceConsts.runTime * 60
  else
    raceStatus = GangRacePanel.GameRaceState.GAMEOVER
    self.statusOverTime = statusInfo.beginTime
  end
  self.curGameRound = statusInfo.curCount
  self.maxGameRound = statusInfo.maxCount
  if self.bWaitData == true then
    if raceStatus >= 0 then
      self.raceStatus = raceStatus
      self:SetModal(true)
      self:CreatePanel(RESPATH.PREFAB_GANGRACE_PANEL, GUILEVEL.MUTEX)
    end
    self.bWaitData = false
  else
    if status == RaceConsts.RACE_VOTE_STAGE then
      self:Reset()
      GangRaceProtocol.sendGetPlayerInfoReq()
    end
    self:changeRaceStatus(raceStatus)
  end
end
def.static("table", "table").OnVoteStatus = function(params, context)
  GangRacePanel.Instance():onVotingStatus(params.idx2VoteMoney, params.myVoteInfo)
end
def.static("table", "table").OnVoteSuccess = function(params, context)
  GangRacePanel.Instance():onVoteSuccess(params)
end
def.static("table", "table").OnPlayerInfo = function(params, context)
  GangRacePanel.Instance():onPlayerInfo(params)
end
def.static("table", "table").OnRunningInfo = function(params, context)
  GangRacePanel.Instance():onRunningInfo(params.beginTime, params.winIdx or 0, params.playerAction)
end
def.static("table", "table").OnRaceStart = function(params, context)
  Toast(textRes.GangRace[8])
end
def.method("number").changeRaceStatus = function(self, status)
  if status ~= self.raceStatus then
    self.raceStatus = status
    self:updateRaceStatus()
  end
end
def.method("table").onPlayerInfo = function(self, playerInfo)
  local racePlayers = self.racePlayers
  for _, v in ipairs(playerInfo) do
    local idx = v.playerIdx
    local modelid = 0
    local player = racePlayers[idx]
    player.idx = idx
    if 0 > v.gender then
      modelid = v.menpai
    else
      modelid = _G.GetOccupationCfg(v.menpai, v.gender).modelId
    end
    player.modelid = modelid
    player.name = v.name
    player.avatarId = v.avatarId
    player.frameId = v.avatarFrameId
  end
  self:UpdatePlayerList(false)
  self:UpdatePlayerHeadIcon()
  self:UpdatePlayerName()
end
def.method("table").onVoteSuccess = function(self, voteInfo)
end
def.method("table", "table").onVotingStatus = function(self, playerVote, myVote)
  local racePlayers = self.racePlayers
  self.myVoteIndex = 0
  for k, v in ipairs(playerVote) do
    local player = racePlayers[k]
    player.totleMoney = v
    player.myMoney = 0
  end
  for i, m in pairs(myVote) do
    local player = racePlayers[i]
    player.myMoney = m
    self.myVoteIndex = i
  end
  self:UpdatePlayerList(false)
end
def.method("number", "number", "table").onRunningInfo = function(self, beginTime, winIdx, playerAction)
  self.raceWinIndex = winIdx
  local actionInfos = {}
  for k, v in ipairs(playerAction) do
    local idx = v.playerIdx
    local actions = {}
    for _, act in ipairs(v.actionInfos) do
      table.insert(actions, {
        actionCode = act.actionCode,
        moveStep = act.moveStep
      })
    end
    actionInfos[idx] = actions
  end
  local allStep = 0
  for i = 1, RACE_OBJ_COUNT do
    local count = #actionInfos[i]
    if allStep > count or allStep == 0 then
      allStep = count
    end
  end
  local raceStatus = GangRacePanel.GameRaceState.RUNNING
  if beginTime >= allStep * RACE_STEP_TIME then
    if self.curGameRound + 1 >= self.maxGameRound then
      raceStatus = GangRacePanel.GameRaceState.GAMEOVER
    else
      raceStatus = GangRacePanel.GameRaceState.RACEOVER
    end
  end
  self:changeRaceStatus(raceStatus)
  self.allStep = allStep
  self.actionInfos = actionInfos
  self:playAction(beginTime)
end
def.method("number").UpdateTimer = function(self, dt)
  local status = self.raceStatus
  if status == GangRacePanel.GameRaceState.VOTE or status == GangRacePanel.GameRaceState.VOTEOVER then
    local time = self.statusOverTime - GetServerTime()
    self:ShowVoteTimeInfo(time)
    GangRaceProtocol.sendGetVoteStatusReq()
  elseif status == GangRacePanel.GameRaceState.RACEOVER then
    local time = self.statusOverTime - GetServerTime()
    self:ShowNextRaceTimeInfo(time)
  end
end
def.method().resetPlayerInfo = function(self)
  if self.racePlayers then
    local racePlayers = self.racePlayers
    for i = 1, RACE_OBJ_COUNT do
      local playerInfo = racePlayers[i]
      playerInfo.step = 0
      playerInfo.act = 0
    end
  end
end
def.method("number").playAction = function(self, beginTime)
  self.isPlayAction = false
  self:initAction(beginTime)
  if self.actionTimerId == 0 then
    self.actionTimerId = GameUtil.AddGlobalTimer(ACTIONREF_TIME, false, function()
      self:updateAction()
    end)
  end
  self.isPlayAction = true
end
def.method("number").initAction = function(self, beginTime)
  if self.actionInfos == nil or self.actionInfos[1] == nil or #self.actionInfos[1] < 1 then
    return
  end
  self:resetPlayerInfo()
  self.curStep = 1
  self.curStepRunTime = 0
  self.playerRefrashTime = 0
  self:updateRaceAction(beginTime, false)
  self:UpdateSort()
  self:UpdatePlayerList(true)
  self:ShowPlayerHeadIcon(true)
end
def.method().updateAction = function(self)
  if not self.isPlayAction then
    if self.actionTimerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.actionTimerId)
      self.actionTimerId = 0
    end
  else
    self:updateRaceAction(ACTIONREF_TIME, true)
    if self.curStep > self.allStep then
      self.isPlayAction = false
      self:UpdateSortForFinish()
      self:UpdatePlayerList(true)
      self:PlayActionOver()
    else
      self.playerRefrashTime = self.playerRefrashTime + ACTIONREF_TIME
      if self.playerRefrashTime >= PLAYERREF_TIME then
        self:UpdateSort()
        self:UpdatePlayerList(true)
        self.playerRefrashTime = self.playerRefrashTime - PLAYERREF_TIME
      end
    end
  end
end
def.method("number", "boolean").updateRaceAction = function(self, time, runAct)
  local actionChange = false
  local runTime = self.curStepRunTime + time
  local actionInfos = self.actionInfos
  while runTime >= 0 and self.curStep <= self.allStep do
    if runTime > RACE_STEP_TIME then
      for i = 1, RACE_OBJ_COUNT do
        local actions = actionInfos[i]
        local racePlayer = self.racePlayers[i]
        racePlayer.step = racePlayer.step + actions[self.curStep].moveStep
      end
      self.curStep = self.curStep + 1
      runTime = runTime - RACE_STEP_TIME
      actionChange = true
    else
      self.curStepRunTime = runTime
      break
    end
  end
  if runAct and actionChange then
    for i = 1, RACE_OBJ_COUNT do
      local actions = actionInfos[i]
      if self.curStep <= self.allStep then
        local actCode = actions[self.curStep].actionCode
        local msg = self:GetChatMsg(actCode)
        self:ShowChatMsg(i, msg)
      end
    end
  end
  for i = 1, RACE_OBJ_COUNT do
    local leftTime = self.chatMsgTime[i]
    if leftTime > 0 then
      leftTime = leftTime - time
      self.chatMsgTime[i] = leftTime
      if leftTime <= 0 then
        local Group_Chat = self.uiTbl.Group_Chat
        Group_Chat[i]:SetActive(false)
      end
    end
  end
  local scale = self.curStepRunTime / RACE_STEP_TIME
  for i = 1, RACE_OBJ_COUNT do
    local actions = actionInfos[i]
    local racePlayer = self.racePlayers[i]
    if self.curStep <= self.allStep then
      racePlayer.pos = racePlayer.step * STEP_MOVE_DIST + scale * actions[self.curStep].moveStep * STEP_MOVE_DIST
    else
      racePlayer.pos = racePlayer.step * STEP_MOVE_DIST
    end
    self:updateRacePlayerPos(i, racePlayer.pos)
  end
end
local SortFunc = function(a, b)
  return a.pos > b.pos
end
def.method().UpdateSort = function(self)
  local sortInfo = self.sortInfo
  for i = 1, RACE_OBJ_COUNT do
    local racePlayer = self.racePlayers[i]
    sortInfo[i].idx = i
    sortInfo[i].pos = racePlayer.pos
  end
  table.sort(sortInfo, SortFunc)
end
def.method().UpdateSortForFinish = function(self)
  local sortInfo = self.sortInfo
  for i = 1, RACE_OBJ_COUNT do
    local racePlayer = self.racePlayers[i]
    sortInfo[i].idx = i
    if i == self.raceWinIndex then
      sortInfo[i].pos = racePlayer.pos + 1000
    else
      sortInfo[i].pos = racePlayer.pos
    end
  end
  table.sort(sortInfo, SortFunc)
end
def.method("boolean").UpdatePlayerList = function(self, flag)
  local playerList = self.uiTbl.Group_Right
  local moneyText = self.uiTbl.Label_Number
  moneyText:GetComponent("UILabel"):set_text(0)
  for i = 1, RACE_OBJ_COUNT do
    local playerDirect = playerList[i]
    local Label_PlayerName = playerDirect:FindDirect("Label_PlayerName")
    local Label_TotalMoney = playerDirect:FindDirect("Label_TotalMoney")
    local Label_MyMoney = playerDirect:FindDirect("Label_MyMoney")
    local Img_Select = playerDirect:FindDirect("Img_Select")
    local idx = self.sortInfo[i].idx
    local playerInfo = self.racePlayers[idx]
    Label_PlayerName:GetComponent("UILabel"):set_text(playerInfo.name)
    Label_TotalMoney:GetComponent("UILabel"):set_text(playerInfo.totleMoney)
    Label_MyMoney:GetComponent("UILabel"):set_text(playerInfo.myMoney)
    if self.raceStatus == GangRacePanel.GameRaceState.VOTE then
      Img_Select:SetActive(true)
    elseif self.myVoteIndex == idx then
      moneyText:GetComponent("UILabel"):set_text(playerInfo.myMoney)
      Img_Select:SetActive(true)
      GUIUtils.Toggle(Img_Select, true)
    else
      Img_Select:SetActive(false)
    end
  end
end
def.method().UpdatePlayerName = function(self)
  local PlayerName = self.uiTbl.Player_Name
  if PlayerName then
    for i = 1, RACE_OBJ_COUNT do
      local playerInfo = self.racePlayers[i]
      PlayerName[i]:GetComponent("UILabel"):set_text(playerInfo.name)
    end
  end
end
def.method().UpdatePlayerHeadIcon = function(self)
  local racePlayers = self.racePlayers
  local Group_Player = self.uiTbl.Group_Player
  for i = 1, RACE_OBJ_COUNT do
    local player = racePlayers[i]
    local iconGo = Group_Player[i]:FindDirect("Img_TouxiangIcon")
    if player.avatarId and player.avatarId > 0 then
      SetAvatarIcon(iconGo, player.avatarId, player.frameId or 0)
    elseif player.modelid and 0 < player.modelid then
      local iconid = self:GetIconByModel(player.modelid)
      local texture = iconGo:GetComponent("UITexture")
      GUIUtils.FillIcon(texture, iconid)
    end
  end
end
def.method("number", "number").updateRacePlayerPos = function(self, index, pos)
  local player = self.uiTbl.Group_Player[index]
  if player then
    local localPosition = player.localPosition
    if pos > RACE_MOVE_DIST then
      pos = RACE_MOVE_DIST
    end
    player.localPosition = Vector.Vector3.new(self.localPosition[index] + pos, localPosition.y, localPosition.z)
  end
end
def.method().UpdateGoldIcon = function(self)
  local Img_Gold = self.uiTbl.Img_Gold
  local raceWinIndex = self.raceWinIndex
  if raceWinIndex == nil or raceWinIndex <= 0 then
    raceWinIndex = sortInfo[1].idx
  end
  local sortInfo = self.sortInfo
  for i = 1, RACE_OBJ_COUNT do
    Img_Gold[i]:SetActive(i == raceWinIndex)
  end
end
def.method().HideGoldIcon = function(self)
  local Img_Gold = self.uiTbl.Img_Gold
  for i = 1, RACE_OBJ_COUNT do
    Img_Gold[i]:SetActive(false)
  end
end
def.method("boolean").ShowPlayerHeadIcon = function(self, show)
  if self.m_panel ~= nil then
    local Group_Player = self.uiTbl.Group_Player
    for i = 1, RACE_OBJ_COUNT do
      Group_Player[i]:SetActive(show)
    end
  end
end
def.method("number").ShowVoteTimeInfo = function(self, time)
  if self.m_panel ~= nil then
    local timeStr = ""
    if time <= 0 then
      timeStr = textRes.GangRace[13]
    else
      local m = math.floor(time / 60)
      local s = math.mod(time, 60)
      timeStr = string.format(textRes.GangRace[14], m, s)
    end
    self.uiTbl.Label_Time:GetComponent("UILabel"):set_text(timeStr)
    self.uiTbl.Grass_Time:GetComponent("UILabel"):set_text(timeStr)
  end
end
def.method("number").ShowNextRaceTimeInfo = function(self, time)
  if self.m_panel ~= nil then
    local timeStr
    if time <= 0 then
      timeStr = textRes.GangRace[13]
    else
      local m = math.floor(time / 60)
      local s = math.mod(time, 60)
      timeStr = string.format(textRes.GangRace[14], m, s)
    end
    self.uiTbl.Label_NextRaceTime:GetComponent("UILabel"):set_text(timeStr)
  end
end
def.method().updateRaceStatus = function(self)
  local status = self.raceStatus
  warn("----------------race status", status)
  if self.m_panel == nil or self.m_panel.isnil then
    warn("updateRaceStatus, dlg not exsit!")
    return
  end
  if status == GangRacePanel.GameRaceState.VOTE then
    self.uiTbl.Label_Time:SetActive(true)
    self.uiTbl.Label_Info:SetActive(true)
    self.uiTbl.Label_Stop:SetActive(false)
    self.uiTbl.Label_Number:SetActive(false)
    self.uiTbl.Btn_Select1000:SetActive(true)
    self.uiTbl.Btn_Select10000:SetActive(true)
    self.uiTbl.Label_NextRace:SetActive(false)
    self.uiTbl.Label_NextRaceTime:SetActive(false)
    self.uiTbl.Label_RaceEnd:SetActive(false)
    self.uiTbl.Grass_TimeLeft:SetActive(true)
    self.uiTbl.Grass_Time:SetActive(true)
    local time = self.statusOverTime - GetServerTime()
    self:ShowPlayerHeadIcon(true)
    self:ShowVoteTimeInfo(time)
    self:HideGoldIcon()
    GangRaceProtocol.sendGetVoteStatusReq()
  elseif status == GangRacePanel.GameRaceState.VOTEOVER then
    self.uiTbl.Label_Time:SetActive(true)
    self.uiTbl.Label_Info:SetActive(true)
    self.uiTbl.Label_Stop:SetActive(false)
    self.uiTbl.Label_Number:SetActive(true)
    self.uiTbl.Btn_Select1000:SetActive(false)
    self.uiTbl.Btn_Select10000:SetActive(false)
    self.uiTbl.Label_NextRace:SetActive(false)
    self.uiTbl.Label_NextRaceTime:SetActive(false)
    self.uiTbl.Label_RaceEnd:SetActive(false)
    self.uiTbl.Grass_TimeLeft:SetActive(true)
    self.uiTbl.Grass_Time:SetActive(true)
    GangRaceProtocol.sendGetVoteStatusReq()
  elseif status == GangRacePanel.GameRaceState.RUNPREV then
    self.uiTbl.Label_Time:SetActive(false)
    self.uiTbl.Label_Info:SetActive(false)
    self.uiTbl.Label_Stop:SetActive(true)
    self.uiTbl.Label_Number:SetActive(true)
    self.uiTbl.Btn_Select1000:SetActive(false)
    self.uiTbl.Btn_Select10000:SetActive(false)
    self.uiTbl.Label_NextRace:SetActive(false)
    self.uiTbl.Label_NextRaceTime:SetActive(false)
    self.uiTbl.Label_RaceEnd:SetActive(false)
    self.uiTbl.Grass_TimeLeft:SetActive(false)
    self.uiTbl.Grass_Time:SetActive(false)
    self:ShowVoteTimeInfo(0)
    GangRaceProtocol.sendGetVoteStatusReq()
    GangRaceProtocol.sendGetRunningInfoReq()
  elseif status == GangRacePanel.GameRaceState.RUNNING then
    self.uiTbl.Label_Time:SetActive(false)
    self.uiTbl.Label_Info:SetActive(false)
    self.uiTbl.Label_Stop:SetActive(true)
    self.uiTbl.Label_Number:SetActive(true)
    self.uiTbl.Btn_Select1000:SetActive(false)
    self.uiTbl.Btn_Select10000:SetActive(false)
    self.uiTbl.Label_NextRace:SetActive(false)
    self.uiTbl.Label_NextRaceTime:SetActive(false)
    self.uiTbl.Label_RaceEnd:SetActive(false)
    self.uiTbl.Grass_TimeLeft:SetActive(false)
    self.uiTbl.Grass_Time:SetActive(false)
  elseif status == GangRacePanel.GameRaceState.RACEOVER then
    self.uiTbl.Label_Time:SetActive(false)
    self.uiTbl.Label_Info:SetActive(false)
    self.uiTbl.Label_Stop:SetActive(false)
    self.uiTbl.Label_Number:SetActive(true)
    self.uiTbl.Btn_Select1000:SetActive(false)
    self.uiTbl.Btn_Select10000:SetActive(false)
    self.uiTbl.Label_NextRace:SetActive(true)
    self.uiTbl.Label_NextRaceTime:SetActive(true)
    self.uiTbl.Label_RaceEnd:SetActive(false)
    self.uiTbl.Grass_TimeLeft:SetActive(false)
    self.uiTbl.Grass_Time:SetActive(false)
    local time = self.statusOverTime - GetServerTime()
    self:ShowNextRaceTimeInfo(time)
  elseif status == GangRacePanel.GameRaceState.GAMEOVER then
    self.uiTbl.Label_Time:SetActive(false)
    self.uiTbl.Label_Info:SetActive(false)
    self.uiTbl.Label_Stop:SetActive(false)
    self.uiTbl.Label_Number:SetActive(true)
    self.uiTbl.Btn_Select1000:SetActive(false)
    self.uiTbl.Btn_Select10000:SetActive(false)
    self.uiTbl.Label_NextRace:SetActive(false)
    self.uiTbl.Label_NextRaceTime:SetActive(false)
    self.uiTbl.Label_RaceEnd:SetActive(true)
    self.uiTbl.Grass_TimeLeft:SetActive(false)
    self.uiTbl.Grass_Time:SetActive(false)
  end
end
def.method().UpdateGoldMoney = function(self)
  if self.m_panel and false == self.m_panel.isnil then
    self.uiTbl.Label_OwnNumber:GetComponent("UILabel"):set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)))
  end
end
def.method("number", "string").ShowChatMsg = function(self, idx, msg)
  if msg and msg ~= "" and self.m_panel and false == self.m_panel.isnil then
    local Group_Chat = self.uiTbl.Group_Chat
    local Chat_GO = Group_Chat[idx]
    if Chat_GO then
      self.chatMsgTime[idx] = CHAT_SHOW_TIME
      Chat_GO:FindDirect("Label_ChatContent"):GetComponent("UILabel"):set_text(msg)
      Chat_GO:SetActive(true)
    end
  end
end
def.method().CloseAllChatMsg = function(self)
  if self.m_panel and false == self.m_panel.isnil then
    local Group_Chat = self.uiTbl.Group_Chat
    for i = 1, RACE_OBJ_COUNT do
      Group_Chat[i]:SetActive(false)
    end
  end
end
def.method("number", "=>", "string").GetChatMsg = function(self, actionCode)
  if actionCode > 0 then
    local msg = self.chatMsgs[actionCode]
    if msg then
      return msg
    end
  end
  return ""
end
def.method("number", "=>", "number").GetIconByModel = function(self, modelId)
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  local iconId = modelRecord:GetIntValue("headerIconId")
  return iconId
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:onBtnConfirmClick()
  elseif id == "Btn_CloseInfo" then
    warn("------------ click Btn_CloseInfo")
  elseif id == "Btn_ShowInfo" then
    self:onBtnShowInfoClick()
  elseif id == "Sprite" then
    self:OnBtnTipsClick()
  elseif id == "Btn_AddGold" then
    GoToBuyGold(false)
  else
    warn("gangrace panel btn:", id)
  end
end
def.method().onBtnConfirmClick = function(self)
  if self.raceStatus == GangRacePanel.GameRaceState.VOTE then
    local idx = 0
    local playerList = self.uiTbl.Group_Right
    for i = 1, RACE_OBJ_COUNT do
      local playerDirect = playerList[i]
      if GUIUtils.IsToggle(playerDirect:FindDirect("Img_Select")) then
        idx = i
      end
    end
    if idx <= 0 then
      Toast(textRes.GangRace[2])
      return
    end
    local voteCount = 0
    if GUIUtils.IsToggle(self.uiTbl.Btn_Select1000) then
      voteCount = 1
    end
    if GUIUtils.IsToggle(self.uiTbl.Btn_Select10000) then
      voteCount = 10
    end
    if voteCount == 0 then
      Toast(textRes.GangRace[3])
      return
    end
    GangRaceProtocol.sendRaceVote(idx, voteCount)
  elseif self.raceStatus == GangRacePanel.GameRaceState.VOTEOVER then
    Toast(textRes.GangRace[9])
  else
    Toast(textRes.GangRace[4])
  end
end
def.method().onBtnShowInfoClick = function(self)
  if self.raceStatus == GangRacePanel.GameRaceState.GAMEOVER then
    Toast(textRes.GangRace[5])
  end
end
def.method().OnBtnTipsClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701609800)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
return GangRacePanel.Commit()

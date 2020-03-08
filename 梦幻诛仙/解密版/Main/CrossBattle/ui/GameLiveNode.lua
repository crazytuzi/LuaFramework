local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local WatchGameMgr = require("Main.CrossBattle.WatchGameMgr")
local watchGameMgr = WatchGameMgr.Instance()
local GameLiveNode = Lplus.Extend(TabNode, "GameLiveNode")
local GUIUtils = require("GUI.GUIUtils")
local RoundRobinRoundStage = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinRoundStage")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
local SingleFightResult = require("netio.protocol.mzm.gsp.crossbattle.SingleFightResult")
local CrossBattleFinalMgr = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr")
local Vector = require("Types.Vector")
local def = GameLiveNode.define
def.field("number").timerId = 0
def.field("table").curFightInfoList = nil
def.field("number").roundRobinIdx = 0
def.field("number").selectionZone = 1
def.field("boolean").isRefreshList = false
def.field("number").refreshTimerId = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:setGameLiveInfo()
end
def.override().OnHide = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
  if self.refreshTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.refreshTimerId)
    self.refreshTimerId = 0
  end
  self.isRefreshList = false
  self.curFightInfoList = nil
  self.roundRobinIdx = 0
  self.selectionZone = 1
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("-------GameLiveNode click:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Video" then
    local pname = clickObj.parent.name
    local pstrs = string.split(pname, "_")
    local idx = tonumber(pstrs[2])
    if idx then
      local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
      if curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
        local fightInfo = self.curFightInfoList[idx]
        local crops1 = fightInfo.corps1
        local crops2 = fightInfo.corps2
        gmodule.moduleMgr:GetModule(ModuleId.CROSS_BATTLE):watchRoundRobinFight(self.roundRobinIdx, crops1.corpsId, crops2.corpsId, crops2.corpsId)
      elseif curStage == CrossBattleActivityStage.STAGE_SELECTION then
        local fightInfo = self.curFightInfoList[idx]
        local recordId = fightInfo.fightRecordId
        warn("-------watchSelectionLive:", idx, recordId)
        if recordId:eq(Int64.new(0)) then
          Toast(textRes.CrossBattle[66])
          return
        end
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CGetRealtimeRecordReq").new(recordId))
      elseif curStage == CrossBattleActivityStage.STAGE_FINAL then
        local fightInfo = self.curFightInfoList[idx]
        local recordId = fightInfo.fightRecordId
        warn("-------watchFinalLive:", idx, recordId)
        if recordId:eq(Int64.new(0)) then
          Toast(textRes.CrossBattle[66])
          return
        end
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CGetRealtimeRecordReq").new(recordId))
      end
    end
  elseif id == "Btn_VideoOther" then
    local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
    if curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
      local pname = clickObj.parent.name
      local pstrs = string.split(pname, "_")
      local idx = tonumber(pstrs[2])
      local fightInfo = self.curFightInfoList[idx]
      local crops1 = fightInfo.corps1
      local crops2 = fightInfo.corps2
      gmodule.moduleMgr:GetModule(ModuleId.CROSS_BATTLE):watchRoundRobinFight(self.roundRobinIdx, crops1.corpsId, crops2.corpsId, crops1.corpsId)
    end
  elseif id == "Btn_Zone01" then
    self:getOwnServerSelectionFightInfo()
  elseif id == "Btn_Zone02" then
    self:setSelectionRoundList()
  elseif strs[1] == "Img" and strs[2] == "XuanBa" then
    local idx = tonumber(strs[3])
    if idx then
      self.selectionZone = idx
      local Group_Zone02 = self.m_node:FindDirect("Btn_Zone02/Group_Zone02")
      Group_Zone02:SetActive(false)
      self:setSelectionInfo()
    end
  else
    local Group_Zone02 = self.m_node:FindDirect("Btn_Zone02/Group_Zone02")
    Group_Zone02:SetActive(false)
  end
end
def.method().setSelectionRoundList = function(self)
  local Group_Zone02 = self.m_node:FindDirect("Btn_Zone02/Group_Zone02")
  Group_Zone02:SetActive(true)
  local List = self.m_node:FindDirect("Btn_Zone02/Group_Zone02/Group_ChooseType/List_XuanBa")
  local uiList = List:GetComponent("UIList")
  local num = constant.CCrossBattlePointConst.ZONE_NUM
  uiList.itemCount = num
  uiList:Resize()
  for i = 1, num do
    local Btn = List:FindDirect("Btn_XuanBa_" .. i)
    local Label_Name = Btn:FindDirect("Label_Name_" .. i)
    Label_Name:GetComponent("UILabel"):set_text(PointsRaceUtils.GetZoneName(i))
  end
end
def.method().setGameLiveInfo = function(self)
  local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
  warn("--------setGameLiveInfo:", curStage)
  local Btn_Zone01 = self.m_node:FindDirect("Btn_Zone01")
  local Btn_Zone02 = self.m_node:FindDirect("Btn_Zone02")
  self:setFightInfoList({})
  if curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
    Btn_Zone01:SetActive(false)
    Btn_Zone02:SetActive(false)
    self:setRoundRobinInfo()
  elseif curStage == CrossBattleActivityStage.STAGE_SELECTION then
    self:setSelectionInfo()
  elseif curStage == CrossBattleActivityStage.STAGE_FINAL then
    Btn_Zone01:SetActive(false)
    Btn_Zone02:SetActive(false)
    self:setFinalInfo()
  else
    Btn_Zone01:SetActive(false)
    Btn_Zone02:SetActive(false)
    self:setNoDataInfo()
    self:setFightInfoList({})
  end
end
def.method().setNoDataInfo = function(self)
  local Group_Type01 = self.m_panel:FindDirect("Img_Bg0/Group_Type01")
  local Label = Group_Type01:FindDirect("Label")
  local Group_NoData = Group_Type01:FindDirect("Group_NoData")
  Label:GetComponent("UILabel"):set_text("")
  Group_NoData:SetActive(true)
end
def.method().setRoundRobinInfo = function(self)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local indexList = crossBattleInterface:getTodayRoundRobinIndexList()
  local Group_Type01 = self.m_panel:FindDirect("Img_Bg0/Group_Type01")
  local Label = Group_Type01:FindDirect("Label")
  local Group_NoData = Group_Type01:FindDirect("Group_NoData")
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local fightDuration = 0
  if crossBattleCfg then
    fightDuration = crossBattleCfg.round_robin_stage_fight_max_duration_in_minute * 60
  end
  local curTime = _G.GetServerTime()
  if 0 < crossBattleInterface.restartIndex then
    local restartReadyTime, restartStartTime = crossBattleInterface:getRestartRoundRobindTime()
    local nYear = tonumber(os.date("%Y", curTime))
    local nMonth = tonumber(os.date("%m", curTime))
    local nDay = tonumber(os.date("%d", curTime))
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local date = AbsoluteTimer.GetServerTimeTable(restartStartTime)
    if date.year == nYear and date.month == nMonth and date.day == nDay then
      table.insert(indexList, crossBattleInterface.restartIndex)
    end
  end
  warn("-------indexList:", indexList[1])
  if #indexList == 0 then
    Label:GetComponent("UILabel"):set_text("")
    Group_NoData:SetActive(true)
    self:setFightInfoList({})
  else
    Group_NoData:SetActive(false)
    do
      local showIdx = 0
      local startGameTime = 0
      for i, v in ipairs(indexList) do
        local readyTime, startTime = crossBattleInterface:getRoundRobinTimeByIndex(v)
        if v == crossBattleInterface.restartIndex then
          readyTime, startTime = crossBattleInterface:getRestartRoundRobindTime()
        end
        if curTime <= startTime + fightDuration then
          showIdx = v
          startGameTime = startTime
          break
        end
      end
      local function setTimeCallback()
        local nowTime = _G.GetServerTime()
        local leftTime = startGameTime - nowTime
        if leftTime > 0 then
          local hours = math.floor(leftTime / 3600)
          local mins = math.floor((leftTime - hours * 3600) / 60)
          local secs = leftTime - hours * 3600 - mins * 60
          Label:GetComponent("UILabel"):set_text(string.format(textRes.CrossBattle[54], hours, mins, secs, showIdx, textRes.CrossBattle.stageStr[2]))
        else
          GameUtil.RemoveGlobalTimer(self.timerId)
          self.timerId = 0
          Label:GetComponent("UILabel"):set_text(textRes.CrossBattle[69])
        end
      end
      setTimeCallback()
      if self.timerId == 0 then
        self.timerId = GameUtil.AddGlobalTimer(1, false, setTimeCallback)
      end
      warn("----------showIdx:", showIdx)
      if showIdx > 0 then
        self.roundRobinIdx = showIdx
        watchGameMgr:getRoundRobinLiveFightInfo(showIdx, function(infos)
          if self.m_panel == nil or self.m_panel.isnil then
            return
          end
          warn("----------gameLive callback:", #infos)
          local fightInfoList = {}
          for i, v in ipairs(infos) do
            warn("---------infos:", i, v.state, RoundRobinFightInfo.STATE_NOT_START)
            if v.state == RoundRobinFightInfo.STATE_NOT_START or v.state == RoundRobinFightInfo.STATE_FIGHTING then
              table.insert(fightInfoList, v)
            end
          end
          if fightInfoList == nil or #fightInfoList == 0 then
            self:setNoDataInfo()
            self:setFightInfoList({})
            return
          end
          self:setFightInfoList(fightInfoList)
        end)
      else
        self:setNoDataInfo()
        self:setFightInfoList({})
      end
    end
  end
end
def.method("table").setFightInfoList = function(self, fightInfos)
  local List_Member = self.m_panel:FindDirect("Img_Bg0/Group_Type01/Group_List/Scroll View/List_Member")
  local uiList = List_Member:GetComponent("UIList")
  self.curFightInfoList = fightInfos
  uiList.itemCount = #fightInfos
  uiList:Resize()
  warn("-------setFightInfoList:", #fightInfos)
  if fightInfos == nil or #fightInfos == 0 then
    if self.timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.timerId)
      self.timerId = 0
    end
    self:setNoDataInfo()
  else
    local Group_Type01 = self.m_panel:FindDirect("Img_Bg0/Group_Type01")
    local Label = Group_Type01:FindDirect("Label")
    local Group_NoData = Group_Type01:FindDirect("Group_NoData")
    Group_NoData:SetActive(false)
    warn("--------setGroupNoData: false")
  end
  local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
  for i, v in ipairs(fightInfos) do
    local item = List_Member:FindDirect("item_" .. i)
    local Group_Team1 = item:FindDirect("Group_Team1")
    self:setCorpsInfo(Group_Team1, v.corps1)
    local Group_Team2 = item:FindDirect("Group_Team2")
    self:setCorpsInfo(Group_Team2, v.corps2)
    local Btn_Video = item:FindDirect("Btn_Video")
    local Btn_VideoOther = item:FindDirect("Btn_VideoOther")
    local Sprite = item:FindDirect("Sprite")
    if curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
      Group_Team1:set_localPosition(Vector.Vector3.new(-15.4, Group_Team1.transform.localPosition.y, 0))
      Sprite:set_localPosition(Vector.Vector3.new(177, Sprite.transform.localPosition.y, 0))
      Btn_VideoOther:SetActive(true)
      self:setRoundRobinVideoState(Btn_Video, v.state)
      self:setRoundRobinVideoState(Btn_VideoOther, v.state)
    elseif curStage == CrossBattleActivityStage.STAGE_SELECTION or curStage == CrossBattleActivityStage.STAGE_FINAL then
      Group_Team1:set_localPosition(Vector.Vector3.new(-66.6, Group_Team1.transform.localPosition.y, 0))
      Sprite:set_localPosition(Vector.Vector3.new(152.3, Sprite.transform.localPosition.y, 0))
      Btn_VideoOther:SetActive(false)
      self:setSelectionVideoState(Btn_Video, v.state1)
    end
  end
end
def.method("userdata", "number").setRoundRobinVideoState = function(self, Btn_Video, state)
  if state == RoundRobinFightInfo.STATE_FIGHTING then
    Btn_Video:GetComponent("UIButton").isEnabled = true
  else
    Btn_Video:GetComponent("UIButton").isEnabled = false
  end
end
def.method("userdata", "number").setSelectionVideoState = function(self, Btn_Video, state)
  warn("-------setSelectionBtn:", Btn_Video, state)
  if state == SingleFightResult.IN_FIGHTING then
    Btn_Video:GetComponent("UIButton").isEnabled = true
    if self.refreshTimerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.refreshTimerId)
      self.refreshTimerId = 0
    end
  else
    Btn_Video:GetComponent("UIButton").isEnabled = false
    if self.isRefreshList and self.refreshTimerId == 0 then
      self.refreshTimerId = GameUtil.AddGlobalTimer(5, false, function()
        local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
        if curStage == CrossBattleActivityStage.STAGE_SELECTION then
          local curSelectIdx = CrossBattleInterface.GetTodayCrossBattleSelectionStage()
          self:getSelectionFightInfo(curSelectIdx)
        elseif curStage == CrossBattleActivityStage.STAGE_FINAL then
          local curSelectIdx = CrossBattleInterface.GetTodayCrossBattleFinalStage()
          self:getFinalFightInfo(curSelectIdx)
        end
      end)
    end
  end
end
def.method("userdata", "table").setCorpsInfo = function(self, Group_Team, corpsInfo)
  local Label_Team1_Name = Group_Team:FindDirect("Label_Team1_Name")
  warn("----------setCorpsInfo:", corpsInfo.name)
  local name = corpsInfo.name
  local serverName = corpsInfo.serverName or ""
  local Label_Server1_Name = Group_Team:FindDirect("Label_Server1_Name")
  Label_Server1_Name:GetComponent("UILabel"):set_text(serverName)
  Label_Team1_Name:GetComponent("UILabel"):set_text(name)
  local Img_Badge = Group_Team:FindDirect("Img_Badge")
  local badgeCfg = CorpsUtils.GetCorpsBadgeCfg(corpsInfo.badgeId)
  if badgeCfg then
    GUIUtils.FillIcon(Img_Badge:GetComponent("UITexture"), badgeCfg.iconId)
  end
end
def.method().setSelectionInfo = function(self)
  local Group_Type01 = self.m_panel:FindDirect("Img_Bg0/Group_Type01")
  local Label = Group_Type01:FindDirect("Label")
  local Group_NoData = Group_Type01:FindDirect("Group_NoData")
  local curSelectIdx = CrossBattleInterface.GetTodayCrossBattleSelectionStage()
  local Btn_Zone01 = self.m_node:FindDirect("Btn_Zone01")
  local Btn_Zone02 = self.m_node:FindDirect("Btn_Zone02")
  warn("--------curSelectIdx:", curSelectIdx)
  if curSelectIdx > 0 then
    Btn_Zone01:SetActive(true)
    Btn_Zone02:SetActive(true)
    self:setSelectionZoneInfo()
    self:setSelectionCountDown()
    self:getSelectionFightInfo(curSelectIdx)
  else
    Btn_Zone01:SetActive(false)
    Btn_Zone02:SetActive(false)
    self:setNoDataInfo()
    self:setFightInfoList({})
  end
end
def.method().setSelectionCountDown = function(self)
  local Group_Type01 = self.m_panel:FindDirect("Img_Bg0/Group_Type01")
  local Label = Group_Type01:FindDirect("Label")
  local Group_NoData = Group_Type01:FindDirect("Group_NoData")
  local curSelectIdx = CrossBattleInterface.GetTodayCrossBattleSelectionStage()
  if curSelectIdx > 0 then
    do
      local curSelectionStartTime = CrossBattleInterface.GetCrossBattleSelectionTimeByStage(curSelectIdx)
      local function setTimeCallback()
        local nowTime = _G.GetServerTime()
        local leftTime = curSelectionStartTime - nowTime
        if leftTime > 0 then
          local hours = math.floor(leftTime / 3600)
          local mins = math.floor((leftTime - hours * 3600) / 60)
          local secs = leftTime - hours * 3600 - mins * 60
          Label:GetComponent("UILabel"):set_text(string.format(textRes.CrossBattle[57], hours, mins, secs, textRes.CrossBattle.CrossBattleSelection.BattleType[curSelectIdx]))
        else
          Label:GetComponent("UILabel"):set_text(textRes.CrossBattle[65])
          GameUtil.RemoveGlobalTimer(self.timerId)
          self.timerId = 0
          self.isRefreshList = true
          self:getSelectionFightInfo(curSelectIdx)
        end
      end
      setTimeCallback()
      if self.timerId == 0 then
        self.timerId = GameUtil.AddGlobalTimer(1, false, setTimeCallback)
      end
    end
  end
end
def.method().getOwnServerSelectionFightInfo = function(self)
  local curSelectIdx = CrossBattleInterface.GetTodayCrossBattleSelectionStage()
  local Group_Type01 = self.m_panel:FindDirect("Img_Bg0/Group_Type01")
  local Label = Group_Type01:FindDirect("Label")
  local Group_NoData = Group_Type01:FindDirect("Group_NoData")
  if curSelectIdx > 0 then
    self:setSelectionCountDown()
    watchGameMgr:getOwnServerSelectionFightInfo(curSelectIdx, function(fightInfos)
      warn("----------getOwnServerSelectionFightInfo callback:", self.m_panel)
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      local fightList = {}
      for i, v in ipairs(fightInfos) do
        if v.state1 == SingleFightResult.STATE_NOT_START or v.state1 == SingleFightResult.IN_FIGHTING then
          table.insert(fightList, v)
        end
      end
      self:setFightInfoList(fightList)
    end)
  end
end
def.method("number").getSelectionFightInfo = function(self, curSelectIdx)
  watchGameMgr:getSelectionFightInfo(curSelectIdx, self.selectionZone, function(fightInfos)
    warn("----------getSelectionFightInfo callback:", self.m_panel)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    local fightList = {}
    for i, v in ipairs(fightInfos) do
      if v.corps1 and v.corps2 and (v.state1 == SingleFightResult.STATE_NOT_START or v.state1 == SingleFightResult.IN_FIGHTING) then
        table.insert(fightList, v)
      end
    end
    self:setFightInfoList(fightList)
  end)
end
def.method().setSelectionZoneInfo = function(self)
  local Btn_Zone02 = self.m_node:FindDirect("Btn_Zone02")
  local Label_2 = Btn_Zone02:FindDirect("Label_2")
  Label_2:GetComponent("UILabel"):set_text(PointsRaceUtils.GetZoneName(self.selectionZone))
end
def.method().setFinalInfo = function(self)
  local Group_Type01 = self.m_panel:FindDirect("Img_Bg0/Group_Type01")
  local Label = Group_Type01:FindDirect("Label")
  local Group_NoData = Group_Type01:FindDirect("Group_NoData")
  local curSelectIdx = CrossBattleInterface.GetTodayCrossBattleFinalStage()
  if curSelectIdx > 0 then
    do
      local finalStartTime = CrossBattleInterface.GetCrossBattleFinalTimeByStage(curSelectIdx)
      local function setTimeCallback()
        local nowTime = _G.GetServerTime()
        local leftTime = finalStartTime - nowTime
        if leftTime > 0 then
          local hours = math.floor(leftTime / 3600)
          local mins = math.floor((leftTime - hours * 3600) / 60)
          local secs = leftTime - hours * 3600 - mins * 60
          local finalType = math.floor((curSelectIdx - 1) / CrossBattleFinalMgr.STAGE_BATTLE_COUNT) + 1
          local typeRound = (curSelectIdx - 1) % CrossBattleFinalMgr.STAGE_BATTLE_COUNT + 1
          Label:GetComponent("UILabel"):set_text(string.format(textRes.CrossBattle[58], hours, mins, secs, textRes.CrossBattle.CrossBattleFinal.BattleType[finalType], typeRound))
        else
          Label:GetComponent("UILabel"):set_text(textRes.CrossBattle[65])
          GameUtil.RemoveGlobalTimer(self.timerId)
          self.timerId = 0
          self.isRefreshList = true
          self:getFinalFightInfo(curSelectIdx)
        end
      end
      setTimeCallback()
      if self.timerId == 0 then
        self.timerId = GameUtil.AddGlobalTimer(1, false, setTimeCallback)
      end
      self:getFinalFightInfo(curSelectIdx)
    end
  else
    self:setNoDataInfo()
    self:setFightInfoList({})
  end
end
def.method("number").getFinalFightInfo = function(self, curSelectIdx)
  watchGameMgr:getFinalFightInfo(curSelectIdx, function(fightInfos)
    warn("----------getFinalFightInfo callback:", self.m_panel)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    local fightList = {}
    for i, v in ipairs(fightInfos) do
      if v.corps1 and v.corps2 and (v.state1 == SingleFightResult.STATE_NOT_START or v.state1 == SingleFightResult.IN_FIGHTING) then
        table.insert(fightList, v)
      end
    end
    self:setFightInfoList(fightList)
  end)
end
GameLiveNode.Commit()
return GameLiveNode

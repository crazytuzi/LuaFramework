local Lplus = require("Lplus")
local SoloDungeonMgr = Lplus.Class("SoloDungeonMgr")
local DungeonUtils = require("Main.Dungeon.DungeonUtils")
local DungeonModule = Lplus.ForwardDeclare("DungeonModule")
local MissionType = require("consts.mzm.gsp.instance.confbean.ProcessType")
local def = SoloDungeonMgr.define
def.const("string").SOLOKEY = "solodungeonkey"
def.field("number").requestingMonsterId = 0
def.field("boolean").autoThisTime = true
def.field("boolean").guide = false
def.field("table").bossAwardProtocolCache = nil
def.field("table").killMonsterParamsCache = nil
def.method().Init = function(self)
end
def.method().Reset = function(self)
  self.requestingMonsterId = 0
  self.autoThisTime = true
  self.guide = false
  self.bossAwardProtocolCache = nil
  self.killMonsterParamsCache = nil
  if DungeonModule.Instance().State == DungeonModule.DungeonState.SOLO then
    Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, SoloDungeonMgr.OnEnterFight)
    Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, SoloDungeonMgr.OnLeaveFight)
    Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_MONSTER, SoloDungeonMgr.onClickMonster)
  end
end
def.static("table", "table").onEndFight = function(p1, p2)
  local mgr = DungeonModule.Instance().soloMgr
  if mgr.bossAwardProtocolCache ~= nil then
    SoloDungeonMgr.onBossAward(mgr.bossAwardProtocolCache)
    mgr.bossAwardProtocolCache = nil
  end
  if mgr.killMonsterParamsCache ~= nil then
    mgr:OnKillOneMonster(mgr.killMonsterParamsCache.win, mgr.killMonsterParamsCache.oldProcess)
    mgr.killMonsterParamsCache = nil
  end
end
def.static("table").onBossAward = function(p)
  if PlayerIsInFight() then
    DungeonModule.Instance().soloMgr.bossAwardProtocolCache = p
    return
  end
  require("Main.Chat.PersonalHelper").Block(true)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local itemId = p.items[1].itemid
  local num = p.items[1].itemcount
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Dungeon[34], PersonalHelper.Type.ItemMap, {
    [itemId] = num
  })
  local RewardItem = require("netio.protocol.mzm.gsp.question.RewardItem")
  local awards = {}
  for k, v in ipairs(p.items) do
    local param = {}
    param[RewardItem.PARAM_ITEM_ID] = v.itemid
    param[RewardItem.PARAM_ITEM_NUM] = v.itemcount
    local BossAward = RewardItem.new(RewardItem.TYPE_ITEM, param)
    table.insert(awards, BossAward)
  end
  local QuestionAwardPanel = require("Main.Question.ui.QuestionAwardPanel")
  QuestionAwardPanel.ShowAward(awards, textRes.Dungeon[33], QuestionAwardPanel.Type.DUNGEON)
end
def.static("table", "table").onSoloDungeonService = function(p1, p2)
  local npcId = p1[2]
  local serviceId = p1[1]
  if require("Main.npc.NPCServiceConst").SoloDungeon == serviceId then
    local tarDungeonId = DungeonModule.Instance().CurDungeon
    if tarDungeonId == 0 then
      local SoloDungeons = DungeonUtils.GetSingleDungeons()
      local minLv = 999
      local minId = 0
      local diffLv = 999
      local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
      for k, v in ipairs(SoloDungeons) do
        if minLv > v.level then
          minLv = v.level
          minId = v.id
        end
        if myLv >= v.level and diffLv > myLv - v.level then
          diffLv = myLv - v.level
          tarDungeonId = v.id
        end
      end
      if tarDungeonId == 0 then
        Toast(textRes.Dungeon[22])
        return
      end
    end
    local SoloDungeonDlg = require("Main.Dungeon.ui.SoloDungeonDlg")
    SoloDungeonDlg.ShowSoloDungeon(tarDungeonId)
  end
end
def.method("number", "number").FightMonster = function(self, dungeonId, processId)
  local teamData = require("Main.Team.TeamData")
  if teamData.Instance():HasTeam() then
    Toast(textRes.Dungeon[16])
    return
  end
  if DungeonModule.Instance().State ~= DungeonModule.DungeonState.OUT then
    Toast(textRes.Dungeon[7])
    return
  end
  local lefttimes = DungeonUtils.GetDungeonConst().FailTimeAll - DungeonModule.Instance().singleFailTimes
  if lefttimes <= 0 then
    Toast(textRes.Dungeon[25])
    return
  end
  local challengeDungeo = require("netio.protocol.mzm.gsp.instance.CChallengeSingleReq").new(dungeonId, processId)
  gmodule.network.sendProtocol(challengeDungeo)
end
def.static("table", "table").onClickMonster = function(p1, p2)
  local monsterID = p1[1]
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local monster = pubroleModule:GetMonster(monsterID)
  if DungeonUtils.GetDungeonMonsterCfg(monster.m_cfgId) then
    DungeonModule.Instance().soloMgr:GotoMonster(monsterID, true)
  end
end
def.method("boolean").FindMonster = function(self, auto)
  if DungeonModule.Instance().State == DungeonModule.DungeonState.SOLO then
    local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    local curDungeonId = DungeonModule.Instance().CurDungeon
    if curDungeonId <= 0 then
      return
    end
    local soloInfo = DungeonModule.Instance():GetSoloDungeonInfo(curDungeonId)
    if soloInfo and 0 < soloInfo.finishTimes then
      return
    end
    local curProcess = soloInfo and soloInfo.curProcess or 1
    local highProcess = soloInfo and soloInfo.highProcess or 0
    local soloMission = DungeonUtils.GetOneSoloDungeonCfg(curDungeonId, curProcess)
    local monster = pubroleModule:SelectOneMonsterByCfgId(soloMission.monsterId)
    if monster == nil then
      warn("RequestMonsterPositionFromServer : ", soloMission.monsterId, soloMission.mapId)
      local PubroleInterface = require("Main.Pubrole.PubroleInterface")
      PubroleInterface.RequestMonsterPositionFromServer(soloMission.monsterId, soloMission.mapId)
      self.requestingMonsterId = soloMission.monsterId
      self.autoThisTime = auto
      Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.GET_MONSTER_POS, SoloDungeonMgr.GetMonsterPos)
      return
    end
    if auto then
      if soloMission.type == MissionType.BOSS and curProcess > highProcess then
        self:GotoMonster(monster:GetId(), true)
      else
        self:GotoMonster(monster:GetId(), false)
      end
    else
      self:GotoMonster(monster:GetId(), true)
    end
  end
end
def.static("table", "table").GetMonsterPos = function(p1, p2)
  local soloMgr = DungeonModule.Instance().soloMgr
  for k, v in ipairs(p1) do
    local cfgId = v.monsterCfgId
    if cfgId == soloMgr.requestingMonsterId then
      do
        local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
        local auto = soloMgr.autoThisTime
        heroModule:MoveTo(v.mapId, v.x, v.y, 0, 5, MoveType.RUN, function()
          soloMgr:FindMonster(auto)
        end)
        soloMgr.requestingMonsterId = 0
        soloMgr.autoThisTime = true
        Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.GET_MONSTER_POS, SoloDungeonMgr.GetMonsterPos)
        break
      end
    end
  end
end
def.method("number", "boolean").GotoMonster = function(self, monsterID, needDialog)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local heroPos = heroModule.myRole:GetPos()
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local monsterPos, isInAir = pubroleModule:GetMonsterPos(monsterID)
  local monster = pubroleModule:GetMonster(monsterID)
  local dx = (monsterPos.x - heroPos.x) * (monsterPos.x - heroPos.x)
  local dy = (monsterPos.y - heroPos.y) * (monsterPos.y - heroPos.y)
  local diff = math.sqrt(dx + dy)
  if diff < 160 then
    self:InteractMonster(monster, needDialog)
  else
    heroModule:MoveTo(0, monsterPos.x, monsterPos.y, 0, 5, MoveType.RUN, function()
      self:InteractMonster(monster, needDialog)
    end)
  end
end
def.method("table", "boolean").InteractMonster = function(self, monster, needDialog)
  if needDialog then
    do
      local monsterCfgId = monster.m_cfgId
      local monsterId = monster:GetId()
      local dlg = require("Main.npc.ui.NPCDlg").Instance()
      local soloMonsterCfg = DungeonUtils.GetDungeonMonsterCfg(monsterCfgId)
      if soloMonsterCfg == nil then
        return
      end
      dlg:Clear()
      dlg:AddItem(soloMonsterCfg.attackOptionTalk, {true}, false)
      dlg:AddItem(soloMonsterCfg.notAttackOptionTalk, {false}, false)
      dlg:SetCustomCallback(function(param)
        if param[1] then
          self:AttackMonster(monsterId)
        end
        return true
      end)
      if soloMonsterCfg.halfIcon then
        dlg:SetHeadID(soloMonsterCfg.halfIcon, soloMonsterCfg.name, soloMonsterCfg.talk)
      end
      dlg:ShowDlg()
    end
  else
    local monsterId = monster:GetId()
    self:AttackMonster(monsterId)
  end
end
def.method("number").AttackMonster = function(self, monsterID)
  local lefttimes = DungeonUtils.GetDungeonConst().FailTimeAll - DungeonModule.Instance().singleFailTimes
  if lefttimes <= 0 then
    Toast(textRes.Dungeon[25])
    return
  end
  local attack = require("netio.protocol.mzm.gsp.instance.CInstanceFightReq").new(monsterID)
  gmodule.network.sendProtocol(attack)
end
def.method().OnEnterSoloDungeon = function(self)
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  if PlayerPref.HasRoleKey(SoloDungeonMgr.SOLOKEY) then
    self.guide = false
  else
    self.guide = true
    PlayerPref.SetRoleInt(SoloDungeonMgr.SOLOKEY, 1)
    PlayerPref.Save()
  end
  local SoloDungeonTip = require("Main.Dungeon.ui.SoloDungeonTip")
  local dungeonId = DungeonModule.Instance().CurDungeon
  local soloInfo = DungeonModule.Instance():GetSoloDungeonInfo(dungeonId)
  local curProcess = soloInfo and soloInfo.curProcess or 1
  SoloDungeonTip.SetMissionTip(dungeonId, curProcess, self.guide)
  local SoloDungeonDlg = require("Main.Dungeon.ui.SoloDungeonDlg")
  SoloDungeonDlg.Instance():DestroyPanel()
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, SoloDungeonMgr.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, SoloDungeonMgr.OnLeaveFight)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_MONSTER, SoloDungeonMgr.onClickMonster)
  Event.DispatchEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.ENTER_SOLO_DUNGEON, nil)
end
def.method().OnLeaveSoloDungeon = function(self)
  local SoloDungeonTip = require("Main.Dungeon.ui.SoloDungeonTip")
  SoloDungeonTip.CloseMissionTip()
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, SoloDungeonMgr.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, SoloDungeonMgr.OnLeaveFight)
  Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_MONSTER, SoloDungeonMgr.onClickMonster)
  Event.DispatchEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.LEAVE_SOLO_DUNGEON, nil)
end
def.static("table", "table").OnEnterFight = function()
  if DungeonModule.Instance().State == DungeonModule.DungeonState.SOLO then
    local SoloDungeonTip = require("Main.Dungeon.ui.SoloDungeonTip")
    SoloDungeonTip.CloseMissionTip()
  end
end
def.static("table", "table").OnLeaveFight = function()
  if DungeonModule.Instance().State == DungeonModule.DungeonState.SOLO then
    local SoloDungeonTip = require("Main.Dungeon.ui.SoloDungeonTip")
    SoloDungeonTip.ShowMissionTip()
  end
end
def.method("boolean", "number").OnKillOneMonster = function(self, win, oldProcess)
  if PlayerIsInFight() then
    DungeonModule.Instance().soloMgr.killMonsterParamsCache = {win = win, oldProcess = oldProcess}
    return
  end
  if DungeonModule.Instance().State == DungeonModule.DungeonState.SOLO then
    local SoloDungeonTip = require("Main.Dungeon.ui.SoloDungeonTip")
    local dungeonId = DungeonModule.Instance().CurDungeon
    local soloInfo = DungeonModule.Instance():GetSoloDungeonInfo(dungeonId)
    local curProcess = soloInfo and soloInfo.curProcess or 1
    local finishTimes = soloInfo and soloInfo.finishTimes or 0
    SoloDungeonTip.SetMissionTip(dungeonId, finishTimes > 0 and -1 or curProcess, self.guide)
    local oldProcess = DungeonUtils.GetOneSoloDungeonCfg(dungeonId, oldProcess)
    if win and oldProcess.type ~= MissionType.BOSS then
      self:FindMonster(true)
    end
  end
  local SoloDungeonDlg = require("Main.Dungeon.ui.SoloDungeonDlg")
  if SoloDungeonDlg.Instance().m_panel then
    SoloDungeonDlg.Instance():SetIconState()
  end
end
def.method("number", "number").SaoDangDungeon = function(self, dungeonId, processId)
  local soloDungeonSaoDangCfg = DungeonUtils.GetSoloDungeonSaoDangCfg(dungeonId)
  local soloDungeonInfo = DungeonModule.Instance():GetSoloDungeonInfo(dungeonId)
  local soloDungeonCfg = DungeonUtils.GetSoloDungeonCfg(dungeonId)
  local dungeonCfg = DungeonUtils.GetDungeonCfg(dungeonId)
  local mylv = require("Main.Hero.Interface").GetBasicHeroProp().level
  local opened = mylv >= dungeonCfg.level and mylv < dungeonCfg.closeLevel
  if dungeonInfo then
    opened = soloDungeonInfo.open
  end
  if not opened then
    Toast(textRes.Dungeon[32])
    return
  end
  local teamData = require("Main.Team.TeamData")
  if teamData.Instance():HasTeam() then
    Toast(textRes.Dungeon[16])
    return
  end
  local farMission = 0
  if soloDungeonInfo then
    farMission = soloDungeonInfo.highProcess
  end
  if farMission < soloDungeonSaoDangCfg.sao_dang_open_process_id then
    Toast(string.format(textRes.Dungeon[56], soloDungeonSaoDangCfg.sao_dang_open_process_id))
    return
  end
  local lefttimes = DungeonUtils.GetDungeonConst().FailTimeAll - DungeonModule.Instance().singleFailTimes
  if lefttimes <= 0 then
    Toast(textRes.Dungeon[25])
    return
  end
  local costItemNum = 0
  local costYuanbao = 0
  local curMission = soloDungeonInfo.curProcess
  if processId <= curMission then
    Toast(textRes.Dungeon[54])
    return
  end
  for k, v in ipairs(soloDungeonCfg) do
    if curMission <= v.processId and processId >= v.processId then
      costItemNum = costItemNum + v.sao_dang_item_num
    end
  end
  local text = string.format(textRes.Dungeon[52], curMission, processId)
  local itemId = soloDungeonSaoDangCfg.cost_item_id
  require("Main.Item.ItemConsumeHelper").Instance():ShowItemConsume(textRes.Dungeon[53], text, itemId, costItemNum, function(result)
    if result >= 0 then
      local hasCount = require("Main.Item.ItemModule").Instance():GetItemCountById(itemId)
      if hasCount > costItemNum then
        hasCount = costItemNum or hasCount
      end
      local saodang = require("netio.protocol.mzm.gsp.instance.CSaoDangReq").new(dungeonId, processId, hasCount, result)
      gmodule.network.sendProtocol(saodang)
    end
  end)
end
SoloDungeonMgr.Commit()
return SoloDungeonMgr

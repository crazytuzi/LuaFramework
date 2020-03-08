local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DragonBoatRaceMainPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local TeamData = require("Main.Team.TeamData")
local DragonBoatRaceModule = require("Main.DragonBoatRace.DragonBoatRaceModule")
local DragonBoatRaceData = require("Main.DragonBoatRace.DragonBoatRaceData")
local DragonBoatRaceUtils = require("Main.DragonBoatRace.DragonBoatRaceUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local GUIFxMan = require("Fx.GUIFxMan")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local ECSoundMan = require("Sound.ECSoundMan")
local def = DragonBoatRaceMainPanel.define
local Command = DragonBoatRaceModule.Command
local SPEED_TO_SPRITE_FPS_RATIO = 1
local MIN_SPRITE_FPS = 2
local BG_TWEEN_DURATION_RATIO = 25
local OFFSET_X_SCALE = 10
local BG_WIDTH = 1280
def.field("table").m_UIGOs = nil
def.field("table").m_commandMapBtn = nil
def.field("table").m_btnMapCommand = nil
def.field("table").m_targetCommands = nil
def.field("table").m_answerCommands = nil
def.field("table").m_curRace = nil
def.field("number").m_stageCountTime = 0
def.field("number").m_raceCountTime = 0
def.field("table").m_teamMemberList = nil
def.field("number").m_centralInfoTimerId = 0
def.field("number").m_trackLength = 0
def.field("string").m_carrierName = ""
local instance
def.static("=>", DragonBoatRaceMainPanel).Instance = function()
  if instance == nil then
    instance = DragonBoatRaceMainPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  local respath = self:GetPanelResPath()
  self:CreatePanel(respath, 0)
end
def.method("=>", "string").GetPanelResPath = function(self)
  local curRace = DragonBoatRaceModule.Instance():GetCurRace()
  local raceCfgId = curRace:GetRaceCfgId()
  local raceCfg = DragonBoatRaceUtils.GetRaceCfg(raceCfgId)
  local resIconId = raceCfg.activityGUIId
  local respath = _G.GetIconPath(resIconId)
  if respath == "" then
    error(string.format("No respath found for raceCfgId=%d, resIconId=%d", raceCfgId, resIconId))
  end
  return respath
end
def.override().OnCreate = function(self)
  self:InitData()
  if self.m_curRace == nil or self.m_curRace:IsRaceEnd() then
    warn("DragonBoatRace: race has ended, auto close race ui!")
    self:DestroyPanel()
    return
  end
  self:InitUI()
  self:UpdateUI()
  self:OnUpdate(0)
  Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
  Event.RegisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncPrepareStage, DragonBoatRaceMainPanel.OnSyncPrepareStage)
  Event.RegisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncCommands, DragonBoatRaceMainPanel.OnSyncCommands)
  Event.RegisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncCommandResults, DragonBoatRaceMainPanel.OnSyncCommandResults)
  Event.RegisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncEvent, DragonBoatRaceMainPanel.OnSyncEvent)
  Event.RegisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.RaceEnd, DragonBoatRaceMainPanel.OnRaceEnd)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.RaceEnd, DragonBoatRaceMainPanel.OnRaceEnd)
  Event.UnregisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncEvent, DragonBoatRaceMainPanel.OnSyncEvent)
  Event.UnregisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncCommandResults, DragonBoatRaceMainPanel.OnSyncCommandResults)
  Event.UnregisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncCommands, DragonBoatRaceMainPanel.OnSyncCommands)
  Event.UnregisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncPrepareStage, DragonBoatRaceMainPanel.OnSyncPrepareStage)
  Timer:RemoveIrregularTimeListener(self.OnUpdate)
  self.m_UIGOs = nil
  self.m_commandMapBtn = nil
  self.m_btnMapCommand = nil
  self.m_answerCommands = nil
  self.m_targetCommands = nil
  self.m_curRace = nil
  self.m_stageCountTime = 0
  self.m_raceCountTime = 0
  self.m_trackLength = 0
  self.m_teamMemberList = nil
  self.m_carrierName = ""
  self:RemoveCentralInfoTimer()
  self:ResumeMapBackgroundMusic()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif obj.parent.name == "Group_Btn" then
    local commandValue = self.m_btnMapCommand[id]
    if commandValue then
      self:OnClickControlBtn(commandValue)
    end
  end
end
def.method().InitData = function(self)
  self.m_commandMapBtn = {
    [Command.Up] = "Btn_Up",
    [Command.Left] = "Btn_Left",
    [Command.Right] = "Btn_Right"
  }
  self.m_btnMapCommand = {}
  for k, v in pairs(self.m_commandMapBtn) do
    self.m_btnMapCommand[v] = k
  end
  self.m_answerCommands = {}
  self.m_targetCommands = {}
  self.m_curRace = DragonBoatRaceModule.Instance():GetCurRace()
  self:CheckAndPlayRaceBackgroundMusic()
  self.m_trackLength = self.m_curRace:GetTrackLength()
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Bg = self.m_panel:FindDirect("Bg_River")
  self.m_UIGOs.Group_Bottom = self.m_panel:FindDirect("Group_Bottom")
  self.m_UIGOs.Group_Top = self.m_panel:FindDirect("Group_Top")
  self.m_UIGOs.Panel_Info = self.m_panel:FindDirect("Panel_Info")
  self.m_UIGOs.Group__Boat = self.m_panel:FindDirect("Group__Boat")
  self.m_UIGOs.Model_Me = self.m_UIGOs.Group__Boat:FindDirect("Model_Me")
  self.m_UIGOs.Model_Enemy = self.m_UIGOs.Group__Boat:FindDirect("Model_Enemy")
  self.m_UIGOs.List_Member = self.m_UIGOs.Group_Top:FindDirect("List_Member")
  self.m_UIGOs.Img_MapMini = self.m_UIGOs.Group_Top:FindDirect("Img_MapMini")
  self.m_UIGOs.Label_Time = self.m_UIGOs.Group_Top:FindDirect("Bg_Time/Label_Time")
  self.m_UIGOs.Pool_Order = self.m_UIGOs.Group_Bottom:FindDirect("Pool_Order")
  self.m_UIGOs.Grid_Order = self.m_UIGOs.Group_Bottom:FindDirect("Grid_Order")
  self.m_UIGOs.UI_Effect = self.m_UIGOs.Group_Bottom:FindDirect("UI_Effect")
  self.m_UIGOs.Panel_Info = self.m_panel:FindDirect("Panel_Info")
  self.m_UIGOs.Label_Info = self.m_UIGOs.Panel_Info:FindDirect("Bg_Info/Label")
  self.m_UIGOs.Label_CountDown = self.m_UIGOs.Panel_Info:FindDirect("Label_CountDown")
  self.m_UIGOs.CompetitorObjs = {}
  local competitors = self.m_curRace:GetCompetitors()
  local myTeamId = self:GetPlayersTeamId()
  for competitorId, v in pairs(competitors) do
    if v:GetId() == myTeamId then
      self.m_UIGOs.CompetitorObjs[tostring(competitorId)] = {
        sprite = self.m_UIGOs.Model_Me,
        label_speed = self.m_UIGOs.Img_MapMini:FindDirect("Label_MySpeed"),
        sprite_minimap = self.m_UIGOs.Img_MapMini:FindDirect("Img_Me")
      }
    else
      self.m_UIGOs.CompetitorObjs[tostring(competitorId)] = {
        sprite = self.m_UIGOs.Model_Enemy,
        label_speed = self.m_UIGOs.Img_MapMini:FindDirect("Label_EnemySpeed"),
        sprite_minimap = self.m_UIGOs.Img_MapMini:FindDirect("Img_Enemy")
      }
    end
  end
  self.m_UIGOs.start_offset = math.abs(self.m_UIGOs.Model_Me.localPosition.x)
  self.m_UIGOs.minimap_width = self.m_UIGOs.Img_MapMini:GetComponent("UIWidget").width
  self.m_UIGOs.minimap_dest_offset = -20
  self.m_UIGOs.minimap_start_offset = 10
  local Img_Start = self.m_UIGOs.Bg:FindChild("Img_Start")
  Img_Start.localPosition = Vector.Vector3.new(0, Img_Start.localPosition.y, 0)
  self.m_UIGOs.Img_Start = Img_Start
  local Img_Final = self.m_UIGOs.Bg:FindChild("Img_Final")
  Img_Final.parent = self.m_panel
  Img_Final.localPosition = Vector.Vector3.new(0, Img_Final.localPosition.y, 0)
  self.m_UIGOs.Img_Final = Img_Final
  self:ClearCommands()
  self:SetCentralInfo("")
  self:ShowCommandGuideEffect(false)
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if self.m_UIGOs == nil then
        return
      end
      local Texture_Bg1 = self.m_UIGOs.Bg:GetChild(0)
      local uiWidget = Texture_Bg1:GetComponent("UIWidget")
      local BG_WIDTH = uiWidget.width
      local HALF_BG_WIDTH = BG_WIDTH / 2
      Texture_Bg1.localPosition = Vector.Vector3.new(HALF_BG_WIDTH, 0, 0)
      local Texture_Bg2 = self.m_UIGOs.Bg:GetChild(1)
      Texture_Bg2.localPosition = Vector.Vector3.new(-HALF_BG_WIDTH, 0, 0)
      local tweenPosition = self.m_UIGOs.Bg:GetComponent("TweenPosition")
      tweenPosition.from = Texture_Bg1.localPosition
      tweenPosition.to = Texture_Bg2.localPosition
    end)
  end)
end
def.method().UpdateUI = function(self)
  self:UpdateTeamMembers()
  self:UpdateCommandPrompt()
  self:UpdateCompetitorsSpeed()
  self:UpdateStageCountdown()
  self:UpdateRaceTime()
  self:UpdateStageInfo()
end
def.method().UpdateTeamMembers = function(self)
  local TeamData = require("Main.Team.TeamData")
  local members = TeamData.Instance():GetAllTeamMembers()
  local uiList = self.m_UIGOs.List_Member:GetComponent("UIList")
  uiList.itemCount = #members
  uiList:Resize()
  self.m_teamMemberList = {}
  for i, v in ipairs(uiList.children) do
    self:SetTeamMemberInfo(v, members[i])
    self.m_teamMemberList[i] = members[i]
  end
end
def.method("userdata", "table").SetTeamMemberInfo = function(self, go, member)
  if _G.SetAvatarIcon then
    _G.SetAvatarIcon(go, member.avatarId)
  else
    local sprtiteName = GUIUtils.GetHeadSpriteNameNoBound(member.menpai, member.gender)
    GUIUtils.SetSprite(go, sprtiteName)
  end
end
def.method("userdata", "string").SetTeamMemberEmotion = function(self, go, emotion)
  local Html_Text = go:FindDirect("Html_Text")
  if emotion ~= "" then
    Html_Text:SetActive(true)
    Html_Text.localPosition = Vector.Vector3.new(20, Html_Text.localPosition.y, 0)
    local nguiHtml = Html_Text:GetComponent("NGUIHTML")
    local htmlText = string.gsub(emotion, "{e:%w+}", function(str)
      local emojiName = string.sub(str, 4, -2)
      return string.format("<img src='%s:%s' width=48 height=48 fps=5>", RESPATH.EMOJIATLAS, emojiName)
    end)
    nguiHtml:ForceHtmlText(htmlText)
  else
    Html_Text:SetActive(false)
  end
end
def.method().UpdateCommandPrompt = function(self)
  self:SetCommandPrompt("")
end
def.method("string").SetCommandPrompt = function(self, prompt)
  local Bg_Tip = self.m_UIGOs.Group_Bottom:FindDirect("Bg_Tip")
  if prompt ~= "" then
    GUIUtils.SetActive(Bg_Tip, true)
    local Label_Tip = self.m_UIGOs.Group_Bottom:FindDirect("Bg_Tip/Label_Tip")
    GUIUtils.SetText(Label_Tip, prompt)
  else
    GUIUtils.SetActive(Bg_Tip, false)
  end
end
def.method("table").SetCommands = function(self, commands)
  self:ClearCommands()
  self.m_targetCommands = commands
  self.m_answerCommands = {}
  local Grid = self.m_UIGOs.Grid_Order
  for i, command in ipairs(commands) do
    local commandGO = self:AddCommandGO(Grid, command)
    commandGO.name = "Btn_Command_" .. command.value
  end
  Grid:GetComponent("UIGrid"):Reposition()
  local commandNum = #commands
  if commandNum == 0 then
    self:SetCommandPrompt("")
    return
  end
  local commandValue, formatText
  if commandNum == 1 then
    formatText = textRes.DragonBoatRace[2]
    commandValue = commands[1].value
  else
    formatText = textRes.DragonBoatRace[14]
    commandValue = DragonBoatRaceModule.Command.Up
  end
  local raceCfgId = self.m_curRace:GetRaceCfgId()
  local commands = DragonBoatRaceUtils.GetRaceCommands(raceCfgId)
  local command = commands[commandValue]
  local commandName = command and command.name or "commandName_" .. commandValue
  local phaseCfg = self:GetCurPhaseCfg()
  local limitSeconds = phaseCfg and phaseCfg.commandTime or -1
  local prompt = formatText:format(commandName, limitSeconds)
  self:SetCommandPrompt(prompt)
  self:SetCentralInfo("")
end
def.method("userdata", "table", "=>", "userdata").AddCommandGO = function(self, parentGO, command)
  local btnName = self.m_commandMapBtn[command.value]
  local template = self.m_UIGOs.Pool_Order:FindDirect(btnName)
  local go = GameObject.Instantiate(template)
  go.parent = parentGO
  go.localRotation = template.localRotation
  go.localScale = template.localScale
  go.localPosition = Vector.Vector3.zero
  go:SetActive(true)
  return go
end
def.method().ClearCommands = function(self)
  local Grid = self.m_UIGOs.Grid_Order
  local childCount = Grid.childCount
  for i = childCount - 1, 0, -1 do
    local child = Grid:GetChild(i)
    GameObject.DestroyImmediate(child)
  end
end
def.method("table").SetAnswers = function(self, answers)
  local Grid = self.m_UIGOs.Grid_Order
  local childCount = Grid.childCount
  for i = 1, childCount do
    local commandGO = Grid:GetChild(i - 1)
    self:SetCommandAnswer(commandGO, answers[i])
  end
end
def.method("userdata", "table").SetCommandAnswer = function(self, go, answer)
  if answer == nil then
    return
  end
  local strs = go.name:split("_")
  local commandVal = tonumber(strs[3])
  local isCorrect = commandVal == answer.value
  local Btn_Right = go:FindDirect("Btn_Right")
  local Btn_Wrong = go:FindDirect("Btn_Wrong")
  GUIUtils.SetActive(Btn_Right, isCorrect)
  GUIUtils.SetActive(Btn_Wrong, not isCorrect)
end
def.method("number").SetPlayerTeamSpeed = function(self, speed)
  self:SetCompetitorSpeed(self:GetPlayersTeamId(), speed)
  self:SetBackgroundSpeed(speed)
end
def.method("number").SetBackgroundSpeed = function(self, speed)
  local uiTweener = self.m_UIGOs.Bg:GetComponent("UITweener")
  local duration = self:GetBGTweenDurationBySpeed(speed)
  uiTweener:set_duration(duration)
end
def.method("userdata", "number").SetCompetitorSpeed = function(self, competitorId, speed)
  local objs = self.m_UIGOs.CompetitorObjs[competitorId:tostring()]
  local spriteGO = objs.sprite
  if spriteGO == nil then
    error("cannot find spriteGO for competitorId = " .. competitorId:tostring())
  end
  local spriteAni = spriteGO:GetComponent("UISpriteAnimation")
  local fps = self:GetSpriteFPSBySpeed(speed)
  warn("fps", fps, competitorId:tostring(), spriteGO.name)
  spriteAni:set_framesPerSecond(fps)
  local label_speed = objs.label_speed
  local text
  if competitorId == self:GetPlayersTeamId() then
    text = textRes.DragonBoatRace[3]:format(speed)
  else
    text = textRes.DragonBoatRace[4]:format(speed)
  end
  GUIUtils.SetText(label_speed, text)
end
def.method("number", "=>", "number").GetSpriteFPSBySpeed = function(self, speed)
  return math.max(MIN_SPRITE_FPS, speed * SPEED_TO_SPRITE_FPS_RATIO)
end
def.method("number", "=>", "number").GetBGTweenDurationBySpeed = function(self, speed)
  return BG_TWEEN_DURATION_RATIO / speed
end
def.method("=>", "userdata").GetPlayersTeamId = function(self)
  return self.m_curRace:GetMyTeamId()
end
def.method("=>", "table").GetPlayersTeam = function(self)
  local myTeamId = self:GetPlayersTeamId()
  return self.m_curRace:GetCompetitor(myTeamId)
end
def.method("=>", "table").GetCurPhaseCfg = function(self)
  local phaseId = self.m_curRace:GetPhaseId()
  return DragonBoatRaceUtils.GetRacePhaseCfg(phaseId)
end
def.method().UpdateCompetitorsSpeed = function(self)
  local playerTeam = self:GetPlayersTeam()
  self:SetPlayerTeamSpeed(playerTeam:GetStageSpeed())
  local competitors = self.m_curRace:GetCompetitors()
  for id, competitor in pairs(competitors) do
    if competitor ~= playerTeam then
      self:SetCompetitorSpeed(competitor:GetId(), competitor:GetStageSpeed())
    end
  end
end
def.method().UpdateCompetitorsPos = function(self)
  local competitors = self.m_curRace:GetCompetitors()
  for _, competitor in pairs(competitors) do
    local id = competitor:GetId()
    local pos = competitor:GetCurPos()
    if not competitor:IsArrived() then
      self:SetCompetitorPos(id, pos)
      if pos >= self.m_trackLength then
        competitor:MarkAsArrived()
        self:PlayCompetitorArriveEffects(competitor)
      end
    end
  end
end
def.method("userdata", "number").SetCompetitorPos = function(self, competitorId, pos)
  local objs = self.m_UIGOs.CompetitorObjs[competitorId:tostring()]
  local spriteGO = objs.sprite
  if spriteGO == nil then
    error("cannot find spriteGO for competitorId = " .. competitorId:tostring())
  end
  local offsetX = pos * OFFSET_X_SCALE - self:GetViewOffset().x
  local localPosition = spriteGO.localPosition
  local nextPosition = Vector.Vector3.new(offsetX, localPosition.y, localPosition.z)
  spriteGO.localPosition = nextPosition
  self:SetCompetitorMinimapPos(competitorId, pos)
end
def.method("userdata", "number").SetCompetitorMinimapPos = function(self, competitorId, pos)
  local objs = self.m_UIGOs.CompetitorObjs[competitorId:tostring()]
  local spriteGO = objs.sprite_minimap
  if spriteGO == nil then
    error("cannot find spriteGO for competitorId = " .. competitorId:tostring())
  end
  spriteGO:SetActive(true)
  local trackLength = self.m_trackLength
  local trackPixelLen = self.m_UIGOs.minimap_width - self.m_UIGOs.minimap_start_offset + self.m_UIGOs.minimap_dest_offset
  local offsetX = pos / trackLength * trackPixelLen + self.m_UIGOs.minimap_start_offset - self.m_UIGOs.minimap_width / 2
  local localPosition = spriteGO.localPosition
  local nextPosition = Vector.Vector3.new(offsetX, localPosition.y, localPosition.z)
  spriteGO.localPosition = nextPosition
end
def.method("number", "number").SyncBackgroundAttachesPos = function(self, speed, dt)
  local playerTeam = self:GetPlayersTeam()
  local curPos = playerTeam:GetTimelinePos()
  local offsetX = curPos * OFFSET_X_SCALE
  local inBeginning = curPos * OFFSET_X_SCALE < self.m_UIGOs.start_offset
  local bgSpeed = BG_WIDTH * speed / BG_TWEEN_DURATION_RATIO
  local HALF_BG_WIDTH = BG_WIDTH / 2
  local Img_Start = self.m_UIGOs.Img_Start
  if self.m_UIGOs.img_start_offset_x and HALF_BG_WIDTH < self.m_UIGOs.img_start_offset_x then
    Img_Start:SetActive(false)
  elseif inBeginning then
    Img_Start:SetActive(true)
    self.m_UIGOs.img_start_offset_x = self.m_UIGOs.img_start_offset_x or 0
    self.m_UIGOs.img_start_offset_x = self.m_UIGOs.img_start_offset_x + bgSpeed * dt
  else
    Img_Start:SetActive(false)
  end
  local leftDistance = self.m_trackLength - curPos
  local leftPixelLen = leftDistance * OFFSET_X_SCALE
  local Img_Final = self.m_UIGOs.Img_Final
  local scrollDistance = bgSpeed * (leftDistance / speed)
  if scrollDistance < 1024 and scrollDistance > -1024 then
    Img_Final:SetActive(true)
    Img_Final.localPosition = Vector.Vector3.new(scrollDistance, Img_Final.localPosition.y, 0)
  else
    Img_Final:SetActive(false)
  end
end
def.method("=>", "table").GetViewOffset = function(self)
  local playerTeam = self:GetPlayersTeam()
  local curPos = playerTeam:GetCurPos()
  local offsetX = curPos * OFFSET_X_SCALE
  if curPos * OFFSET_X_SCALE < self.m_UIGOs.start_offset then
    offsetX = offsetX + self.m_UIGOs.start_offset - curPos * OFFSET_X_SCALE
  end
  return Vector.Vector3.new(offsetX, 0, 0)
end
def.method("number").OnUpdate = function(self, dt)
  local playerTeam = self:GetPlayersTeam()
  local uiTweener = self.m_UIGOs.Bg:GetComponent("UITweener")
  local curPos = playerTeam:GetCurPos()
  local speed
  if curPos * OFFSET_X_SCALE < self.m_UIGOs.start_offset then
    speed = playerTeam:GetStageSpeed() * curPos * OFFSET_X_SCALE / self.m_UIGOs.start_offset
    self:SetBackgroundSpeed(speed)
  else
    speed = playerTeam:GetStageSpeed()
  end
  self:UpdateCompetitorsPos()
  self:SyncBackgroundAttachesPos(speed, dt)
  self.m_stageCountTime = self.m_stageCountTime + dt
  if self.m_stageCountTime > 0.1 then
    self.m_stageCountTime = 0
    self:UpdateStageCountdown()
  end
  self.m_raceCountTime = self.m_raceCountTime + dt
  if self.m_raceCountTime > 1 then
    self.m_raceCountTime = 0
    self:UpdateRaceTime()
  end
end
def.method().UpdateStageCountdown = function(self)
  local curStage = self.m_curRace:GetStage()
  if curStage == DragonBoatRaceData.Stage.None then
    GUIUtils.SetText(self.m_UIGOs.Label_CountDown, "")
    return
  end
  local stageEndTime = self.m_curRace:GetStageEndTime()
  local curTime = self:GetMilliServerTime()
  local leftTime = math.ceil(math.max(0, (stageEndTime - curTime):ToNumber() / 1000))
  GUIUtils.SetText(self.m_UIGOs.Label_CountDown, leftTime)
  if self.m_UIGOs.beginCountDownTime and curTime > self.m_UIGOs.beginCountDownTime then
    self.m_UIGOs.beginCountDownTime = nil
    self:PlayBeginCountDownSound()
  end
  if self.m_UIGOs.raceBGMusicBeginTime and curTime > self.m_UIGOs.raceBGMusicBeginTime then
    self.m_UIGOs.raceBGMusicBeginTime = nil
    self:PlayRaceBackgroundMusic()
  end
end
def.method().UpdateRaceTime = function(self)
  local startTime = self.m_curRace:GetStartTime()
  local curTime = self:GetMilliServerTime()
  local duration = math.max(0, (curTime - startTime) / 1000:ToNumber())
  local t = _G.Seconds2HMSTime(duration)
  local timeText = string.format("%02d:%02d", t.m, t.s)
  GUIUtils.SetText(self.m_UIGOs.Label_Time, timeText)
end
def.method("=>", "userdata").GetMilliServerTime = function(self)
  return gmodule.moduleMgr:GetModule(ModuleId.DRAGON_BOAT_RACE):GetMilliServerTime()
end
def.method().UpdatePrepareInfo = function(self)
  local phaseCfg = self.m_curRace:GetCurPhaseCfg()
  local text = phaseCfg.tip
  self:SetCentralInfo(text)
  self:SetCommands({})
  self:SetCommandPrompt("")
  self:ClearTeamMemberEmotions()
  self:UpdateSpeedFXs()
  if phaseCfg.phaseNo == 1 then
    local prepareTime = phaseCfg.prepareTime
    local prompt = textRes.DragonBoatRace[16]:format(prepareTime)
    self:SetCommandPrompt(prompt)
    self:SetUpBeginCountdownSound()
  end
end
def.method().SetUpBeginCountdownSound = function(self)
  local stageEndTime = self.m_curRace:GetStageEndTime()
  local COUNTDOWN_SECONDS = 3
  self.m_UIGOs.beginCountDownTime = stageEndTime - Int64.new(COUNTDOWN_SECONDS * 1000)
  local curTime = self:GetMilliServerTime()
  if curTime > self.m_UIGOs.beginCountDownTime then
    self.m_UIGOs.beginCountDownTime = nil
  end
  self.m_UIGOs.raceBGMusicBeginTime = stageEndTime
end
def.method().PlayBeginCountDownSound = function(self)
  local raceCfgId = self.m_curRace:GetRaceCfgId()
  local raceCfg = DragonBoatRaceUtils.GetRaceCfg(raceCfgId)
  ECSoundMan.Instance():Play2DSoundByID(raceCfg.beginCountDownMusicId)
end
def.method().CheckAndPlayRaceBackgroundMusic = function(self)
  local curStage = self.m_curRace:GetStage()
  if curStage == DragonBoatRaceData.Stage.None then
    return
  end
  local startTime = self.m_curRace:GetStartTime()
  local phaseCfg = self.m_curRace:GetCurPhaseCfg()
  local prepareSeconds = phaseCfg.prepareTime
  local curTime = self:GetMilliServerTime()
  if curTime < startTime + Int64.new(prepareSeconds * 1000) then
    return
  end
  self:PlayRaceBackgroundMusic()
end
def.method().PlayRaceBackgroundMusic = function(self)
  local raceCfgId = self.m_curRace:GetRaceCfgId()
  local raceCfg = DragonBoatRaceUtils.GetRaceCfg(raceCfgId)
  local musicPath = require("Sound.SoundData").Instance():GetSoundPath(raceCfg.backgroundMusicId)
  if musicPath and musicPath ~= "" then
    ECSoundMan.Instance():PlayBackgroundMusic(musicPath, true)
  end
end
def.method().ResumeMapBackgroundMusic = function(self)
  if _G.PlayerIsInFight() then
    return
  end
  Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.ENABLE_MUSIC, {true, false})
end
def.method("table").PlayCompetitorArriveEffects = function(self, competitor)
  local raceCfgId = self.m_curRace:GetRaceCfgId()
  local raceCfg = DragonBoatRaceUtils.GetRaceCfg(raceCfgId)
  ECSoundMan.Instance():Play2DSoundByID(raceCfg.endPointMusicId)
  self:PlayGUIFX(raceCfg.endPointFXId, "competitor_arrived", -1)
  if competitor:GetId():lt(0) then
    local carrierName = self:GetCarrierName()
    Toast(textRes.DragonBoatRace[15]:format(carrierName))
  end
end
def.method().UpdateCommands = function(self)
  local commandList = self.m_curRace:GetCommandList() or {}
  local commands = {}
  for i, v in ipairs(commandList) do
    local command = {value = v}
    table.insert(commands, command)
  end
  self:SetCommands(commands)
  self:UpdateCompetitorsSpeed()
  self:ClearTeamMemberEmotions()
  self:UpdateSpeedFXs()
end
def.method().UpdateCommandResults = function(self)
  local playerTeam = self:GetPlayersTeam()
  local commandResult = playerTeam:GetLastCommandResult()
  local text, speedText
  local phaseCfg = self.m_curRace:GetCurPhaseCfg()
  local actualChange = commandResult:GetActualChangeSpeed()
  local carrierName = self:GetCarrierName()
  if commandResult:GetIsAllRight() then
    text = textRes.DragonBoatRace[6]
    if playerTeam:IsReachMaxSpeed() and actualChange == 0 then
      speedText = textRes.DragonBoatRace[10]:format(carrierName)
    elseif actualChange > 0 then
      speedText = textRes.DragonBoatRace[8]:format(actualChange, carrierName)
    else
      speedText = textRes.DragonBoatRace[8]:format(phaseCfg.speedUpUnit, carrierName)
    end
  else
    text = textRes.DragonBoatRace[7]
    if playerTeam:IsReachMinSpeed() and actualChange == 0 then
      speedText = textRes.DragonBoatRace[11]:format(carrierName)
    elseif actualChange < 0 then
      speedText = textRes.DragonBoatRace[9]:format(math.abs(actualChange), carrierName)
    else
      speedText = textRes.DragonBoatRace[9]:format(phaseCfg.speedDownUnit, carrierName)
    end
  end
  text = text:format(speedText)
  self:SetCentralInfo(text)
  local teamMemberStates = commandResult:GetTeamMemberStates()
  if teamMemberStates then
    for i, v in ipairs(self.m_teamMemberList) do
      local itemGO = self.m_UIGOs.List_Member:FindDirect("item_" .. i)
      local state = teamMemberStates[v.roleid:tostring()]
      if state and state.right then
        self:SetTeamMemberEmotion(itemGO, textRes.DragonBoatRace.Emotion.Right)
      else
        self:SetTeamMemberEmotion(itemGO, textRes.DragonBoatRace.Emotion.Wrong)
      end
    end
  end
  self:SetCommandPrompt("")
  self:SetCommands({})
  self:UpdateCompetitorsSpeed()
  self:UpdateSpeedFXs()
end
def.method().UpdateEvent = function(self)
  local playerTeam = self:GetPlayersTeam()
  local raceEvent = playerTeam:GetLastEvent()
  local eventId = raceEvent:GetEventId()
  self:UpdateCompetitorsSpeed()
  self:SetCommandPrompt("")
  self:SetCommands({})
  self:UpdateSpeedFXs()
  self:ClearTeamMemberEmotions()
  if eventId == DragonBoatRaceModule.EVENT_ID_NONE then
    self:SetCentralInfo("")
    return
  end
  local actualChange = raceEvent:GetActualChangeSpeed()
  local raceEventCfg = DragonBoatRaceUtils.GetRaceEventCfg(eventId)
  local text = raceEventCfg.tip
  local carrierName = self:GetCarrierName()
  local speedText
  if raceEventCfg.speedChange > 0 then
    if playerTeam:IsReachMaxSpeed() and actualChange == 0 then
      speedText = textRes.DragonBoatRace[10]:format(carrierName)
    elseif actualChange > 0 then
      speedText = textRes.DragonBoatRace[8]:format(actualChange, carrierName)
    else
      speedText = textRes.DragonBoatRace[8]:format(raceEventCfg.speedChange, carrierName)
    end
  elseif playerTeam:IsReachMinSpeed() and actualChange == 0 then
    speedText = textRes.DragonBoatRace[11]:format(carrierName)
  elseif actualChange < 0 then
    speedText = textRes.DragonBoatRace[9]:format(math.abs(actualChange), carrierName)
  else
    speedText = textRes.DragonBoatRace[9]:format(math.abs(raceEventCfg.speedChange), carrierName)
  end
  text = string.format("%s%s", text, speedText)
  local eventTriggerId = self.m_curRace:GetEventTriggerId()
  local eventTriggerCfg = DragonBoatRaceUtils.GetRaceEventTriggerCfg(eventTriggerId)
  local displayDuration
  if eventTriggerCfg then
    displayDuration = eventTriggerCfg.tipTime
  end
  self:SetCentralInfo(text, displayDuration)
  local curTime = self:GetMilliServerTime()
  local lifetime = math.max(0, (self.m_curRace:GetStageEndTime() - curTime):ToNumber() / 1000)
  local SpecialEffectLocationType = require("consts.mzm.gsp.lonngboatrace.confbean.SpecialEffectLocationType")
  if raceEventCfg.FXAttachPos == SpecialEffectLocationType.ON_BOAT then
    local str_id = playerTeam:GetId():tostring()
    local CompetitorObj = self.m_UIGOs.CompetitorObjs[str_id].sprite
    self:PlayGUIFXAsChild(CompetitorObj, raceEventCfg.FXId, "RaceEvent" .. eventId, lifetime)
  else
    self:PlayGUIFX(raceEventCfg.FXId, "RaceEvent" .. eventId, lifetime)
  end
end
def.method().UpdateSpeedFXs = function(self)
  local race = self.m_curRace
  local stage = race:GetStage()
  local competitors = self.m_curRace:GetCompetitors()
  for k, competitor in pairs(competitors) do
    local accelerate, decelerate
    if stage == DragonBoatRaceData.Stage.CommandResult then
      local commandResult = competitor:GetLastCommandResult()
      if commandResult:GetIsAllRight() then
        accelerate = true
      else
        decelerate = true
      end
    elseif stage == DragonBoatRaceData.Stage.Event then
      local raceEvent = competitor:GetLastEvent()
      local eventId = raceEvent:GetEventId()
      if eventId ~= DragonBoatRaceModule.EVENT_ID_NONE then
        local raceEventCfg = DragonBoatRaceUtils.GetRaceEventCfg(eventId)
        if raceEventCfg and raceEventCfg.speedChange > 0 then
          accelerate = true
        elseif raceEventCfg and raceEventCfg.speedChange < 0 then
          decelerate = true
        end
      end
    end
    local phaseCfg = race:GetCurPhaseCfg()
    local CompetitorObj = self.m_UIGOs.CompetitorObjs[k].sprite
    if accelerate then
      local fxId = phaseCfg.accelerateFXId
      self:PlayGUIFXAsChild(CompetitorObj, fxId, "accelerate_fx", -1)
    elseif decelerate then
      local fxId = phaseCfg.decelerateFXId
      self:PlayGUIFXAsChild(CompetitorObj, fxId, "accelerate_fx", -1)
    else
      local accelerate_fx = CompetitorObj:FindDirect("accelerate_fx")
      if accelerate_fx then
        GameObject.DestroyImmediate(accelerate_fx)
      end
    end
  end
end
def.method("number", "string", "number").PlayGUIFX = function(self, fxId, name, duration)
  local effectCfg = GetEffectRes(fxId)
  if effectCfg then
    warn(effectCfg.path)
    GUIFxMan.Instance():Play(effectCfg.path, name, 0, 0, duration, false)
  end
end
def.method("userdata", "number", "string", "number").PlayGUIFXAsChild = function(self, parent, fxId, name, duration)
  local effectCfg = GetEffectRes(fxId)
  if effectCfg then
    GUIFxMan.Instance():PlayAsChildLayer(parent, effectCfg.path, name, 0, 0, 1, 1, duration, false)
  end
end
def.method().ClearTeamMemberEmotions = function(self)
  for i, v in ipairs(self.m_teamMemberList) do
    local itemGO = self.m_UIGOs.List_Member:FindDirect("item_" .. i)
    self:SetTeamMemberEmotion(itemGO, "")
  end
end
def.method().UpdateStageInfo = function(self)
  local curStage = self.m_curRace:GetStage()
  if curStage == DragonBoatRaceData.Stage.Prepare then
    self:UpdatePrepareInfo()
  elseif curStage == DragonBoatRaceData.Stage.CommandSend then
    self:UpdateCommands()
  elseif curStage == DragonBoatRaceData.Stage.CommandResult then
    self:UpdateCommandResults()
  elseif curStage == DragonBoatRaceData.Stage.Event then
    self:UpdateEvent()
  end
end
def.method("string", "varlist").SetCentralInfo = function(self, info, duration)
  GUIUtils.SetActive(self.m_UIGOs.Label_Info.parent, info ~= "")
  GUIUtils.SetText(self.m_UIGOs.Label_Info, info)
  self:RemoveCentralInfoTimer()
  if duration then
    self.m_centralInfoTimerId = GameUtil.AddGlobalTimer(duration, true, function()
      if self.m_UIGOs == nil then
        return
      end
      self:SetCentralInfo("")
    end)
  end
end
def.method("number").OnClickControlBtn = function(self, commandValue)
  if self.m_curRace:IsReady() == false then
    return
  end
  local targetCommandNum = #self.m_targetCommands
  if targetCommandNum == 0 then
    return
  end
  local command = {value = commandValue}
  if targetCommandNum > #self.m_answerCommands then
    table.insert(self.m_answerCommands, command)
    self:SetAnswers(self.m_answerCommands)
    local index = #self.m_answerCommands
    if commandValue == self.m_targetCommands[index].value then
      self:PlayAnswerRightFXs(index)
    end
  end
  if #self.m_answerCommands == targetCommandNum and not self.m_answerCommands.hasSend then
    DragonBoatRaceModule.Instance():SendControlCommands(self.m_answerCommands)
    self.m_answerCommands.hasSend = true
  end
end
def.method("number").PlayAnswerRightFXs = function(self, index)
  local childCount = self.m_UIGOs.Grid_Order.childCount
  if index > childCount then
    return
  end
  local go = self.m_UIGOs.Grid_Order:GetChild(index - 1)
  local raceCfgId = self.m_curRace:GetRaceCfgId()
  local raceCfg = DragonBoatRaceUtils.GetRaceCfg(raceCfgId)
  local fxId = raceCfg.correctFXId
  local effectCfg = GetEffectRes(fxId)
  if effectCfg then
    local objName = "answer_right"
    local duration = -1
    GUIFxMan.Instance():PlayAsChildLayer(go, effectCfg.path, objName, 0, 0, 1, 1, duration, false)
  end
end
def.method().RemoveCentralInfoTimer = function(self)
  if self.m_centralInfoTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_centralInfoTimerId)
    self.m_centralInfoTimerId = 0
  end
end
def.method("boolean").ShowCommandGuideEffect = function(self, isShow)
  GUIUtils.SetActive(self.m_UIGOs.UI_Effect, isShow)
end
def.method("=>", "string").GetCarrierName = function(self)
  if self.m_carrierName == "" then
    local raceCfgId = self.m_curRace:GetRaceCfgId()
    local raceCfg = DragonBoatRaceUtils.GetRaceCfg(raceCfgId)
    self.m_carrierName = raceCfg.carrierName or "unknow_carrier"
  end
  return self.m_carrierName
end
def.static("table", "table").OnSyncPrepareStage = function(params, context)
  instance:UpdatePrepareInfo()
end
def.static("table", "table").OnSyncCommands = function(params, context)
  instance:UpdateCommands()
end
def.static("table", "table").OnSyncCommandResults = function(params, context)
  instance:UpdateCommandResults()
end
def.static("table", "table").OnSyncEvent = function(params, context)
  instance:UpdateEvent()
end
def.static("table", "table").OnRaceEnd = function(params, context)
  instance:DestroyPanel()
end
return DragonBoatRaceMainPanel.Commit()

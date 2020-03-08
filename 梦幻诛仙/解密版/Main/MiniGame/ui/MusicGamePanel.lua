local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MusicGamePanel = Lplus.Extend(ECPanelBase, "MusicGamePanel")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local MusicGameMgr = require("Main.MiniGame.MusicGameMgr")
local musicGameMgr = MusicGameMgr.Instance()
local GameType = require("consts.mzm.gsp.musicgame.confbean.GameType")
local MusicalScale = require("consts.mzm.gsp.musicgame.confbean.MusicalScale")
local GUIUtils = require("GUI.GUIUtils")
local CReportMusicGameResult = require("netio.protocol.mzm.gsp.musicgame.CReportMusicGameResult")
local def = MusicGamePanel.define
local instance
def.field("number").startTimerId = 0
def.field("number").countDownTimerId = 0
def.field("number").opTimerId = 0
def.field("number").curActivityId = 0
def.field("table").curGameCfg = nil
def.field("number").curIndex = 0
def.field("boolean").canClick = false
def.field("boolean").selectedResult = false
def.const("table").musicalScale2Btn = {
  [MusicalScale.MS_1] = "Btn_Do",
  [MusicalScale.MS_2] = "Btn_Re",
  [MusicalScale.MS_3] = "Btn_Mi",
  [MusicalScale.MS_4] = "Btn_Fa",
  [MusicalScale.MS_5] = "Btn_So",
  [MusicalScale.MS_6] = "Btn_La",
  [MusicalScale.MS_7] = "Btn_Xi",
  [MusicalScale.MS_8] = "Btn_A"
}
def.static("=>", MusicGamePanel).Instance = function()
  if instance == nil then
    instance = MusicGamePanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, gameId)
  if self:IsShow() then
    return
  end
  self.curGameCfg = MusicGameMgr.GetMusicGameCfg(gameId)
  local uiPath = "Arts/Prefab/" .. self.curGameCfg.ui_id .. ".prefab.u3dext"
  self:CreatePanel(uiPath, 0)
  self:SetModal(true)
  self:SetDepth(GUIDEPTH.TOPMOST)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:initGameInfo()
    self:displayTips()
  else
    if self.startTimerId > 0 then
      GameUtil.RemoveGlobalTimer(self.startTimerId)
      self.startTimerId = 0
    end
    if 0 < self.countDownTimerId then
      GameUtil.RemoveGlobalTimer(self.countDownTimerId)
      self.countDownTimerId = 0
    end
    if 0 < self.opTimerId then
      GameUtil.RemoveGlobalTimer(self.opTimerId)
      self.opTimerId = 0
    end
    if musicGameMgr.curTurn < self.curGameCfg.turn_sum then
      local p = require("netio.protocol.mzm.gsp.musicgame.CPauseMusicGameReq").new(self.curGameCfg.game_id)
      gmodule.network.sendProtocol(p)
    end
  end
end
def.override().OnCreate = function(self)
  local Label_CountDown = self.m_panel:FindDirect("Img_Bg/Label_CountDown")
  Label_CountDown:GetComponent("UILabel"):set_text("")
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MUSIC_GAME_END, MusicGamePanel.OnStopMusicGame)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MUSIC_GAME_END, MusicGamePanel.OnStopMusicGame)
end
def.static("table", "table").OnStopMusicGame = function(p1, p2)
  if instance and instance.m_panel then
    instance:Hide()
    Toast(textRes.MiniGame[2])
  end
end
def.method().Hide = function(self)
  self.curIndex = 0
  self.canClick = false
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  warn("--------MusicGame onClick:", id)
  if id == "Btn_Close" then
    self:Hide()
    return
  end
  if self.canClick then
    for i, v in pairs(MusicGamePanel.musicalScale2Btn) do
      if v == id then
        self:clickMusicKey(i)
        return
      end
    end
  else
    warn("------can not click music")
  end
end
def.method("number").clickMusicKey = function(self, musicalScale)
  if self.canClick then
    local maxScore = self.curGameCfg.point_upper_limit
    local curScore = musicGameMgr.curScore
    if maxScore <= curScore then
      Toast(textRes.MiniGame[5])
    end
    local musicInfo = self.curGameCfg.musicInfoList[self.curIndex]
    local selectedBtnName = MusicGamePanel.musicalScale2Btn[musicalScale]
    local Group_BtnYin = self.m_panel:FindDirect("Img_Bg/Group_BtnYin")
    local selectedBtn = Group_BtnYin:FindDirect(selectedBtnName)
    local clickEffect = Group_BtnYin:FindDirect("Effect")
    local musicId = 0
    local effectId = 0
    if musicInfo.musical_scale == musicalScale then
      self.selectedResult = true
      musicId = musicInfo.music_id
      effectId = musicInfo.effect_id
      if clickEffect then
        clickEffect.localPosition = selectedBtn.localPosition
        clickEffect:SetActive(true)
      end
    else
      self.selectedResult = false
      do
        local Img_Wrong = selectedBtn:FindDirect("Img_Wrong")
        Img_Wrong:SetActive(true)
        musicId = self.curGameCfg.wrong_music_id
        effectId = self.curGameCfg.wrong_effect_id
        GameUtil.AddGlobalTimer(0.2, true, function()
          if self.m_panel then
            Img_Wrong:SetActive(false)
          end
        end)
      end
    end
    self:playMusic(musicId)
    self:playEffect(effectId)
    self.canClick = false
  else
    warn("------can not click music")
  end
end
def.method("number").playMusic = function(self, musicId)
  if musicId > 0 then
    local ECSoundMan = require("Sound.ECSoundMan")
    ECSoundMan.Instance():Play2DSoundByID(musicId)
  end
end
def.method("number").playEffect = function(self, effectId)
  if effectId > 0 then
    local effres = _G.GetEffectRes(effectId)
    if effres then
      local musicInfo = self.curGameCfg.musicInfoList[self.curIndex]
      local curCountDown = musicInfo.interval_ms / 1000
      local Texture_Bg = self.m_panel:FindDirect("Img_Bg/Texture_Bg")
      require("Fx.GUIFxMan").Instance():PlayAsChildLayerWithCallback(Texture_Bg, effres.path, "effect", 0, 0, 1, 1, curCountDown, false, function()
      end)
    else
      warn("!!!!!!!!!invalid effectId:", effectId)
    end
  end
end
def.method().initGameInfo = function(self)
  self:setScoreInfo()
  self:setGameTurnNum()
  local Label_Score = self.m_panel:FindDirect("Img_Bg/Label_Score")
  if self.curGameCfg.point_upper_limit > 0 then
    Label_Score:SetActive(true)
  else
    Label_Score:SetActive(false)
  end
  local Label_Title = self.m_panel:FindDirect("Img_Bg/Img_Title/Label_Title")
  Label_Title:GetComponent("UILabel"):set_text(self.curGameCfg.desc)
end
def.method().setScoreInfo = function(self)
  local maxScore = self.curGameCfg.point_upper_limit
  local curScore = musicGameMgr.curScore
  if maxScore < curScore then
    curScore = maxScore
  end
  local Cur_Label_Num = self.m_panel:FindDirect("Img_Bg/Label_Score/Slider_Thumb/Label_CurPoint/Label_Num")
  Cur_Label_Num:GetComponent("UILabel"):set_text(curScore)
  local All_Label_Num = self.m_panel:FindDirect("Img_Bg/Label_Score/Label_Num")
  All_Label_Num:GetComponent("UILabel"):set_text(string.format(textRes.MiniGame[1], maxScore))
  local Slider_SX_EXP = self.m_panel:FindDirect("Img_Bg/Label_Score/Slider_SX_EXP")
  local slider = Slider_SX_EXP:GetComponent("UISlider")
  slider.value = curScore / maxScore
end
def.method().setGameTurnNum = function(self)
  local Label_RestNum = self.m_panel:FindDirect("Img_Bg/Label_RestName/Label_RestNum")
  local leftNum = self.curGameCfg.turn_sum - musicGameMgr.curTurn
  if leftNum < 0 then
    leftNum = 0
  end
  Label_RestNum:GetComponent("UILabel"):set_text(leftNum)
end
def.method().displayTips = function(self)
  local tipsId = self.curGameCfg.tips_content_id
  if tipsId > 0 then
    local configPath = string.format("%s/%s", Application.persistentDataPath, "config/mini_game_tip.lua")
    local chunk, errorMsg = loadfile(configPath)
    local activityInfo = {}
    if chunk == nil then
      GameUtil.CreateDirectoryForFile(configPath)
    else
      activityInfo = chunk()
    end
    if activityInfo == nil then
      warn("!!!!!!!!!!!! miniGameTip loal file error:", errorMsg)
      self:musicStartCountDown()
      return
    end
    local myHero = require("Main.Hero.HeroModule").Instance()
    local myRoleId = myHero:GetMyRoleId()
    local roleId = Int64.tostring(myRoleId)
    local lastShowTime = activityInfo[roleId] or 0
    local curTime = GetServerTime()
    local lastTimeTable = AbsoluteTimer.GetServerTimeTable(lastShowTime)
    local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
    if lastShowTime == 0 or lastTimeTable.year ~= curTimeTable.year or lastTimeTable.month ~= curTimeTable.month or lastTimeTable.day ~= curTimeTable.day then
      activityInfo[roleId] = curTime
      local MiniGameTip = require("Main.MiniGame.ui.MiniGameTip")
      local function callback()
        self:musicStartCountDown()
      end
      local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipsId)
      MiniGameTip.Instance():ShowDlg(tipContent, callback)
      require("Main.Common.LuaTableWriter").SaveTable("ActivityTipInfo", configPath, activityInfo)
    else
      self:musicStartCountDown()
    end
  else
    self:musicStartCountDown()
  end
end
def.method().musicStartCountDown = function(self)
  local leftTime = self.curGameCfg.countdown_length
  local Label_CountDown = self.m_panel:FindDirect("Img_Bg/Label_CountDown")
  Label_CountDown:GetComponent("UILabel"):set_text(leftTime)
  self.startTimerId = GameUtil.AddGlobalTimer(1, false, function()
    leftTime = leftTime - 1
    if leftTime > 0 then
      Label_CountDown:GetComponent("UILabel"):set_text(leftTime)
    else
      Label_CountDown:GetComponent("UILabel"):set_text("")
      GameUtil.RemoveGlobalTimer(self.startTimerId)
      self.startTimerId = 0
      self:startCountDown(true)
    end
  end)
end
def.method("boolean").startCountDown = function(self, isNow)
  if musicGameMgr.curTurn >= self.curGameCfg.turn_sum then
    return
  end
  local len = #self.curGameCfg.musicInfoList
  if self.curGameCfg.game_type == GameType.RANDOM then
    self.curIndex = math.random(1, len)
  else
    self.curIndex = self.curIndex + 1
    if len < self.curIndex then
      self.curIndex = 1
    end
  end
  local musicInfo = self.curGameCfg.musicInfoList[self.curIndex]
  local curCountDown = 0
  if not isNow then
    curCountDown = musicInfo.interval_ms / 1000
  end
  self.countDownTimerId = GameUtil.AddGlobalTimer(curCountDown, true, function()
    self:endCountDown()
  end)
end
def.method().endCountDown = function(self)
  GameUtil.RemoveGlobalTimer(self.countDownTimerId)
  self.countDownTimerId = 0
  local Label_CountDown = self.m_panel:FindDirect("Img_Bg/Label_CountDown")
  Label_CountDown:GetComponent("UILabel"):set_text("")
  local musicInfo = self.curGameCfg.musicInfoList[self.curIndex]
  local Group_BtnYin = self.m_panel:FindDirect("Img_Bg/Group_BtnYin")
  local btnName = MusicGamePanel.musicalScale2Btn[musicInfo.musical_scale]
  local btn = Group_BtnYin:FindDirect(btnName)
  local clickBtn = btn:FindDirect(btnName)
  local Img_Right = btn:FindDirect("Img_Right")
  local clickEffect = Group_BtnYin:FindDirect("Effect")
  if clickBtn then
    clickBtn:SetActive(true)
  end
  Img_Right:SetActive(true)
  self.canClick = true
  self.opTimerId = GameUtil.AddGlobalTimer(self.curGameCfg.lighting_duration_ms / 1000, true, function()
    if self.m_panel == nil then
      return
    end
    if clickBtn then
      clickBtn:SetActive(false)
    end
    Img_Right:SetActive(false)
    local tween = Img_Right:GetComponent("TweenPosition")
    if tween then
      tween:PlayForward()
    end
    if clickEffect then
      clickEffect:SetActive(false)
    end
    local curTurnNum = musicGameMgr:addTurnNum(1)
    self:setGameTurnNum()
    local maxScore = self.curGameCfg.point_upper_limit
    local curScore = musicGameMgr.curScore
    if maxScore > curScore then
      if self.selectedResult then
        musicGameMgr:addScore(self.curGameCfg.right_point)
      else
        musicGameMgr:addScore(self.curGameCfg.wrong_point)
      end
      self:setScoreInfo()
    end
    self:reportMusicGameResult(curTurnNum)
    self:startCountDown(false)
    self.opTimerId = 0
    self.canClick = false
    self.selectedResult = false
  end)
end
def.method("number").reportMusicGameResult = function(self, turnNum)
  local result = CReportMusicGameResult.WRONG
  if self.selectedResult then
    result = CReportMusicGameResult.RIGHT
  end
  local p = CReportMusicGameResult.new(self.curGameCfg.game_id, turnNum, result)
  gmodule.network.sendProtocol(p)
end
MusicGamePanel.Commit()
return MusicGamePanel

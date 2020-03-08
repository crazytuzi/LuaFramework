local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ConstellationsMainPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local ConstellationUtils = import("..ConstellationUtils")
local ConstellationModule = import("..ConstellationModule")
local def = ConstellationsMainPanel.define
local OffsetIndexBound = {min = -4, max = 4}
local TWEEN_POSITION_DURATION = 0.5
local TWEEN_SCALE_DURATION = 0.5
local MAX_CARD = 5
local I_SEE_PREVIEW_BTN_GUIDE = 550110000
local instance
def.static("=>", ConstellationsMainPanel).Instance = function()
  if instance == nil then
    instance = ConstellationsMainPanel()
  end
  return instance
end
def.field("table").m_uiObjs = nil
def.field("table").m_uiParams = nil
def.field("number").m_timerId = 0
def.field("table").m_allConstellations = nil
def.field("table").m_constellationMapRound = nil
def.field("number").m_curConstellation = ConstellationModule.CONSTELLATION_NONE
def.field("boolean").m_flipCardRequiring = false
def.field("number").m_startRound = 1
def.field("number").m_endRound = 12
def.field("boolean").m_hasAutoShowChoosePanel = false
def.field("boolean").m_hasShowPreviewBtnGuide = false
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PERFAB_12CONSTELLATIONS_MAIN, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  if not ConstellationModule.Instance():IsOpen() then
    self:DestroyPanel()
    return
  end
  self:InitData()
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEventWithContext(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.NATAL_CONSTELLATION_UPDATE, ConstellationsMainPanel.OnNatalConstellationUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.FLIP_CARD_SUCCESS, ConstellationsMainPanel.OnFlipCardSuccess, self)
  Event.RegisterEventWithContext(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.CONSTELLATION_ROUND_UPDATE, ConstellationsMainPanel.OnConstellationRoundUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.STAGE_UPDATE, ConstellationsMainPanel.OnStageUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.ACCUMULATED_EXP_UPDATE, ConstellationsMainPanel.OnAccumulatedExpUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.FEATURE_CLOSE, ConstellationsMainPanel.OnFeatureClose, self)
  Event.RegisterEventWithContext(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, ConstellationsMainPanel.OnPanel_PostCreate, self)
  Event.RegisterEventWithContext(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostDestroy, ConstellationsMainPanel.OnPanel_PostDestroy, self)
  self.m_timerId = GameUtil.AddGlobalTimer(1, false, function(...)
    self:OnTimer()
  end)
  self:OnTimer()
  GameUtil.AddGlobalTimer(0, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    self:Check2ShowChooseConstellationPanel()
  end)
  GameUtil.AddGlobalTimer(2, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    self:CheckConstellationInfo()
  end)
end
def.override().OnDestroy = function(self)
  self.m_uiObjs = nil
  if self.m_timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_timerId)
    self.m_timerId = 0
  end
  self.m_uiParams = nil
  self.m_allConstellations = nil
  self.m_constellationMapRound = nil
  self.m_hasAutoShowChoosePanel = false
  self.m_hasShowPreviewBtnGuide = false
  Event.UnregisterEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.NATAL_CONSTELLATION_UPDATE, ConstellationsMainPanel.OnNatalConstellationUpdate)
  Event.UnregisterEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.FLIP_CARD_SUCCESS, ConstellationsMainPanel.OnFlipCardSuccess)
  Event.UnregisterEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.CONSTELLATION_ROUND_UPDATE, ConstellationsMainPanel.OnConstellationRoundUpdate)
  Event.UnregisterEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.STAGE_UPDATE, ConstellationsMainPanel.OnStageUpdate)
  Event.UnregisterEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.ACCUMULATED_EXP_UPDATE, ConstellationsMainPanel.OnAccumulatedExpUpdate)
  Event.UnregisterEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.FEATURE_CLOSE, ConstellationsMainPanel.OnFeatureClose)
  Event.UnregisterEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, ConstellationsMainPanel.OnPanel_PostCreate)
  Event.UnregisterEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostDestroy, ConstellationsMainPanel.OnPanel_PostDestroy)
end
def.override("boolean").OnShow = function(self, s)
end
def.method().InitData = function(self)
  self.m_curConstellation = ConstellationModule.Instance():GetCurRoundConstellation()
  self.m_allConstellations = ConstellationUtils.GetAllConstellations()
  self.m_constellationMapRound = {}
  for i, v in ipairs(self.m_allConstellations) do
    self.m_constellationMapRound[v] = i
  end
  self.m_endRound = #self.m_allConstellations
end
def.method().InitUI = function(self)
  self.m_uiObjs = {}
  self.m_uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_uiObjs.Btn_Close = self.m_uiObjs.Img_Bg:FindDirect("Btn_Close")
  self.m_uiObjs.Group_Up = self.m_uiObjs.Img_Bg:FindDirect("Group_Up")
  self.m_uiObjs.Group_Astrology = self.m_uiObjs.Group_Up:FindDirect("Group_Astrology")
  self.m_uiObjs.Grid_Stars = self.m_uiObjs.Group_Astrology:FindDirect("Grid_Stars")
  self.m_uiObjs.Label_TimeLeft = self.m_uiObjs.Group_Astrology:FindDirect("Label_TimeLeft")
  self.m_uiObjs.Label_TimeLeft1 = self.m_uiObjs.Group_Astrology:FindDirect("Label_TimeLeft1")
  self.m_uiObjs.Label_Infor = self.m_uiObjs.Group_Astrology:FindDirect("Label_Infor")
  self.m_uiObjs.Label_Tips = self.m_uiObjs.Group_Astrology:FindDirect("Label_Tips")
  self.m_uiObjs.Group_Grid = self.m_uiObjs.Group_Astrology:FindDirect("Group_Grid")
  self.m_uiObjs.Group_Time = self.m_uiObjs.Group_Up:FindDirect("Group_Time")
  self.m_uiObjs.Group_Btn = self.m_uiObjs.Group_Up:FindDirect("Group_Btn")
  self.m_uiObjs.Group_Down = self.m_uiObjs.Img_Bg:FindDirect("Group_Down")
  self.m_uiObjs.Img_IconHead = self.m_uiObjs.Group_Down:FindDirect("Img_IconHead")
  self.m_uiObjs.Item = self.m_uiObjs.Group_Down:FindDirect("Item")
  self.m_uiObjs.Img_Money = self.m_uiObjs.Group_Down:FindDirect("Img_Money")
  self.m_uiObjs.Img_Exp = self.m_uiObjs.Group_Down:FindDirect("Img_Exp")
  self.m_uiParams = {}
  self.m_uiParams.Img_Bg_OffsetY = self.m_uiObjs.Img_Bg.localPosition.y
  local Item0 = self.m_uiObjs.Grid_Stars:FindDirect("Item0")
  local Item1 = self.m_uiObjs.Grid_Stars:FindDirect("Item1")
  local Item2 = self.m_uiObjs.Grid_Stars:FindDirect("Item2")
  local Item3 = self.m_uiObjs.Grid_Stars:FindDirect("Item3")
  local uiWidget0 = Item0:GetComponent("UIWidget")
  local uiWidget1 = Item1:GetComponent("UIWidget")
  local scaleSize = uiWidget0.width / uiWidget1.width
  self.m_uiParams.scaleSize = scaleSize
  self.m_uiParams.halfExtend = 3
  self.m_uiParams.widget_width = uiWidget1.width
  self.m_uiParams.widget_height = uiWidget1.height
  self.m_uiParams.widget_gap = Item2.localPosition.x - Item1.localPosition.x
  self.m_uiParams.widget_startgap = (uiWidget0.width - uiWidget1.width) / 2
  self.m_uiParams.widget_center_pos = Item0.localPosition
  self.m_uiParams.widget_template = Item1
  self.m_uiParams.widget_template.name = "_tempalte"
  self.m_uiParams.widget_template:SetActive(false)
  self.m_uiParams.widget_parent = self.m_uiObjs.Grid_Stars
  local childCount = self.m_uiObjs.Grid_Stars.childCount
  for i = childCount - 1, 0, -1 do
    local childGO = self.m_uiObjs.Grid_Stars:GetChild(i)
    if not childGO:IsEq(self.m_uiParams.widget_template) then
      GameObject.Destroy(childGO)
    end
  end
  self:TraverseCardWidgets(function(i, childGO)
    GUIUtils.AddBoxCollider(childGO:FindDirect("Sprite"))
    local Img_BgPrize = childGO:FindDirect("Img_BgPrize")
    local uiPlayTween = Img_BgPrize:GetComponent("UIPlayTween")
    uiPlayTween.enabled = false
  end)
  GUIUtils.SetActive(self.m_uiObjs.Label_TimeLeft, true)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_BgPrize" or id == "Sprite" then
    local parentName = obj.parent.name
    if string.find(parentName, "Container") then
      local index = tonumber(string.sub(parentName, #"Container" + 1, -1))
      if index then
        self:OnClickCardObj(index, obj.parent)
      end
    end
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:MinimizePanel()
  elseif id == "Btn_Change" then
    self:OnChangeBtnClick()
  elseif id == "Btn_Talk" then
    self:OnClickChatBtn()
  elseif id == "Btn_CloseTalk" then
    self:OnClickCloseChatBtn()
  elseif id == "Btn_Preview" then
    self:OnPreviewBtnClick()
  end
end
def.method("string", "string").onTweenerFinish = function(self, id, tweenId)
end
def.method().OnTimer = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if self:IsCardStageBegin() then
    local endTime = self:GetCurRoundEndTime():ToNumber()
    local pauseSeconds = self:GetRoundPauseSeconds()
    local curTime = _G.GetServerTime()
    local leftTime = endTime - curTime - pauseSeconds
    leftTime = math.max(0, leftTime)
    GUIUtils.SetText(self.m_uiObjs.Label_TimeLeft1, "")
    GUIUtils.SetText(self.m_uiObjs.Label_TimeLeft, leftTime)
    if self:IsRoundPause() then
      self:RandomFlipCardReq()
      self:TraverseCardWidgets(function(i, go)
        if self:IsCardBackFace(go) then
          self:FlipCardToFront(go, false)
        end
      end)
      local pauseLeftTime = endTime - curTime + 1
      pauseLeftTime = math.max(0, pauseLeftTime)
      if pauseSeconds >= pauseLeftTime then
        GUIUtils.SetText(self.m_uiObjs.Label_TimeLeft, "")
        local Label_TimeLeft1 = self.m_uiObjs.Label_TimeLeft1
        if Label_TimeLeft1 then
          if not Label_TimeLeft1.activeSelf then
            Label_TimeLeft1:SetActive(true)
          end
          GUIUtils.SetText(self.m_uiObjs.Label_TimeLeft1, pauseLeftTime)
        end
      end
    end
    local curRound = self:GetCurRound()
    local endRound = self:GetEndRound()
    if curRound >= endRound and self:IsRoundEnd() then
      GUIUtils.SetText(self.m_uiObjs.Label_TimeLeft1, 0)
      ConstellationModule.Instance():StageFinish()
    end
    self:UpdatePreviewBtn()
  end
end
def.method().UpdateUI = function(self)
  self:UpdateStages()
  self:UpdateChatControlBtn()
  self:UpdateTotalGains()
  self:UpdateRoleInfo()
  self:UpdateNatalConstellation()
  self:UpdatePanelAlign()
  self:UpdatePreviewBtn()
end
def.method("=>", "boolean").IsChatPanelShow = function(self)
  if require("Main.Chat.ui.ChannelChatPanel").Instance():IsShow() then
    return true
  end
  if require("Main.friend.ui.SocialDlg").Instance():IsShow() then
    return true
  end
  return false
end
def.method("=>", "boolean").IsCardStageBegin = function(self)
  local stageInfo = ConstellationModule.Instance():GetStageInfo()
  return stageInfo.stage == ConstellationModule.Stage.STG_CARD
end
def.method("=>", "boolean").IsCardStageEnd = function(self)
  local stageInfo = ConstellationModule.Instance():GetStageInfo()
  return stageInfo.stage > ConstellationModule.Stage.STG_CARD
end
def.method("=>", "boolean").IsRoundPause = function(self)
  local stageInfo = ConstellationModule.Instance():GetStageInfo()
  if stageInfo.stage ~= ConstellationModule.Stage.STG_CARD then
    return true
  end
  local endTime = self:GetCurRoundEndTime():ToNumber()
  local pauseSeconds = self:GetRoundPauseSeconds()
  local curTime = _G.GetServerTime()
  local leftTime = endTime - curTime - pauseSeconds
  return leftTime <= 0
end
def.method("=>", "boolean").IsRoundEnd = function(self)
  local stageInfo = ConstellationModule.Instance():GetStageInfo()
  if stageInfo.stage ~= ConstellationModule.Stage.STG_CARD then
    return false
  end
  local endTime = self:GetCurRoundEndTime():ToNumber()
  local curTime = _G.GetServerTime()
  local leftTime = endTime - curTime
  return leftTime <= 0
end
def.method("=>", "number").GetPrepareLeftSeconds = function(self)
  local stageInfo = ConstellationModule.Instance():GetStageInfo()
  if stageInfo.stage < ConstellationModule.Stage.STG_START_COUNTDOWN then
    return -1
  end
  if stageInfo.stage > ConstellationModule.Stage.STG_START_COUNTDOWN then
    return 0
  end
  local curTime = GetServerTime()
  local endTime = stageInfo.stageEndTime:ToNumber()
  local leftTime = math.max(0, endTime - curTime)
  return leftTime
end
def.method("=>", "number").GetCloseLeftSeconds = function(self)
  local stageInfo = ConstellationModule.Instance():GetStageInfo()
  if stageInfo.stage ~= ConstellationModule.Stage.STG_FINISHED then
    return -1
  end
  local curTime = GetServerTime()
  local endTime = stageInfo.stageEndTime:ToNumber()
  local leftTime = math.max(0, endTime - curTime)
  return leftTime
end
def.method("=>", "number").GetCurRound = function(self)
  local constellation = self:GetCurRoundConstellation()
  return self:GetRoundByConstellation(constellation)
end
def.method("number", "=>", "number").GetRoundByConstellation = function(self, constellation)
  return self.m_constellationMapRound[constellation] or 0
end
def.method("=>", "userdata").GetCurRoundEndTime = function(self)
  local stageInfo = ConstellationModule.Instance():GetStageInfo()
  return stageInfo.stageEndTime
end
def.method("=>", "number").GetRoundPauseSeconds = function(self)
  return ConstellationUtils.GetConstant("PauseSeconds")
end
def.method("=>", "number").GetStartRound = function(self)
  return self.m_startRound
end
def.method("=>", "number").GetEndRound = function(self)
  return self.m_endRound
end
def.method("=>", "number").GetNatalConstellation = function(self)
  return ConstellationModule.Instance():GetNatalConstellation()
end
def.method("=>", "number").GetCurRoundConstellation = function(self)
  return self.m_curConstellation
end
def.method("=>", "table").GetCurRoundBound = function(self)
  local halfExtend = self.m_uiParams.halfExtend
  local curRound = self:GetCurRound()
  local leftBound = curRound - halfExtend
  local startRound = self:GetStartRound()
  leftBound = math.max(startRound, leftBound)
  local rightBound = curRound + halfExtend
  local endRound = self:GetEndRound()
  rightBound = math.min(endRound, rightBound)
  return {min = leftBound, max = rightBound}
end
def.method("=>", "boolean").HaveMoreRound = function(self)
  local halfExtend = self.m_uiParams.halfExtend
  local curRound = self:GetCurRound()
  local endRound = self:GetEndRound()
  return endRound > curRound + halfExtend
end
def.method("varlist").MoveForward = function(self, step)
  local step = step or 1
  local endRound = self:GetEndRound()
  local curRound = self:GetCurRound()
  if endRound <= curRound then
    print("This is the last round!")
    return
  end
  local nextRound = math.min(curRound + step, endRound)
  self:MoveWidgets(-step)
  if self:HaveMoreRound() then
    local halfExtend = self.m_uiParams.halfExtend
    local curRound = self:GetCurRound()
    for i = 1, step do
      local round = curRound + halfExtend + i
      if endRound < round then
        break
      end
      local constellation = self:GetConstellationByRound(round)
      local initIndex = OffsetIndexBound.max + i - 1
      local childGO = self:CreateConstellationWidgets(initIndex, constellation)
      self:MoveWidget(childGO, initIndex - step)
    end
  end
  self.m_curConstellation = self:GetConstellationByRound(nextRound)
  GameUtil.AddGlobalTimer(TWEEN_POSITION_DURATION, true, function(...)
    if self.m_panel and not self.m_panel.isnil then
      self:OnMoveEnd()
    end
  end)
  self:TraverseCardWidgets(function(i, go)
    self:FlipCardToBack(go, false)
  end)
end
def.method().OnMoveEnd = function(self)
  self:UpdateCurConstellationInfo()
  self:TraverseConstellationWidgets(function(i, childGO)
    local strs = string.split(childGO.name, "_")
    local offsetIndex = tonumber(strs[2])
    local Img_Icon = childGO:FindDirect("Img_Icon")
    local uiTexture = Img_Icon:GetComponent("UITexture")
    if offsetIndex ~= 0 then
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
    else
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
    end
  end)
  self:UpdateCards()
  self:UpdatePreviewBtn()
end
def.method("number").MoveWidgets = function(self, step)
  local removeTODOList = {}
  self:TraverseConstellationWidgets(function(i, childGO)
    local strs = string.split(childGO.name, "_")
    local offsetIndex = tonumber(strs[2])
    if offsetIndex >= OffsetIndexBound.min and offsetIndex <= OffsetIndexBound.max then
      local nextOffsetIndex = offsetIndex + step
      self:MoveWidget(childGO, nextOffsetIndex)
    else
      table.insert(removeTODOList, childGO)
    end
  end)
  for i, v in ipairs(removeTODOList) do
    if not v.isnil then
      GameObject.Destroy(v)
    end
  end
end
def.method("userdata", "number").MoveWidget = function(self, childGO, nextOffsetIndex)
  local strs = string.split(childGO.name, "_")
  childGO.name = string.format("%s_%d", strs[1], nextOffsetIndex)
  local transformInfo = self:GetWidgetTransformInfo(nextOffsetIndex)
  TweenPosition.Begin(childGO, TWEEN_POSITION_DURATION, transformInfo.localPosition)
  TweenScale.Begin(childGO, TWEEN_SCALE_DURATION, transformInfo.localScale)
end
def.method().UpdateStages = function(self)
  if self:IsCardStageBegin() then
    self:UpdateRounds()
  elseif self:IsCardStageEnd() then
    self:UpdateFinishCountDown()
  else
    self:UpdatePrepareCountDown()
  end
end
def.method().UpdatePrepareCountDown = function(self)
  GUIUtils.SetActive(self.m_uiObjs.Group_Astrology, false)
  GUIUtils.SetActive(self.m_uiObjs.Group_Time, true)
  local function countdown(seconds)
    local Label_Time = self.m_uiObjs.Group_Time:FindDirect("Label_Time")
    GUIUtils.SetText(Label_Time, seconds)
    if seconds <= 0 then
      return
    end
    GameUtil.AddGlobalTimer(1, true, function()
      if self.m_uiObjs == nil or Label_Time.isnil then
        return
      end
      local leftSeconds = self:GetPrepareLeftSeconds()
      if leftSeconds > 0 then
        countdown(leftSeconds)
      else
        countdown(0)
        self:OnPrepareCountDownEnd()
      end
    end)
  end
  local leftSeconds = self:GetPrepareLeftSeconds()
  countdown(leftSeconds)
end
def.method().OnPrepareCountDownEnd = function(self)
  local constellation = self:GetCurRoundConstellation()
  if constellation ~= ConstellationModule.CONSTELLATION_NONE then
    self:UpdateRounds()
  end
end
def.method().UpdateRounds = function(self)
  GUIUtils.SetActive(self.m_uiObjs.Group_Astrology, true)
  GUIUtils.SetActive(self.m_uiObjs.Group_Time, false)
  local childCount = self.m_uiObjs.Grid_Stars.childCount
  for i = childCount - 1, 0, -1 do
    local childGO = self.m_uiObjs.Grid_Stars:GetChild(i)
    if not childGO:IsEq(self.m_uiParams.widget_template) then
      GameObject.Destroy(childGO)
    end
  end
  local templateGO = self.m_uiParams.widget_template
  local parentGO = self.m_uiParams.widget_parent
  local function createWidget(round, offsetIndex)
    local constellation = self:GetConstellationByRound(round)
    self:CreateConstellationWidgets(offsetIndex, constellation)
  end
  local function createWidgets(startIndex, endIndex, offset)
    for i = startIndex, endIndex, offset do
      local offsetIndex = i - startIndex + offset
      createWidget(i, offsetIndex)
    end
  end
  self.m_curConstellation = ConstellationModule.Instance():GetCurRoundConstellation()
  local curRound = self:GetCurRound()
  local roundBound = self:GetCurRoundBound()
  createWidgets(curRound - 1, roundBound.min, -1)
  createWidget(curRound, 0)
  createWidgets(curRound + 1, roundBound.max, 1)
  self:UpdateCurConstellationInfo()
  self:UpdateCards()
  self:UpdateRoundCountDown()
  self:UpdatePreviewBtn()
end
def.method().UpdateCurConstellationInfo = function(self)
  local curRound = self:GetCurRound()
  local constellation = self:GetConstellationByRound(curRound)
  local info = self:GetConstellationInfo(constellation)
  local text = string.format(textRes.Constellation[6], info.name, info.todayFortune)
  GUIUtils.SetText(self.m_uiObjs.Label_Infor, text)
end
def.method().UpdateRoundCountDown = function(self)
end
def.method("number", "number", "=>", "userdata").CreateConstellationWidgets = function(self, offsetIndex, constellation)
  local templateGO = self.m_uiParams.widget_template
  local parentGO = self.m_uiParams.widget_parent
  local go = GameObject.Instantiate(templateGO)
  go:SetActive(true)
  go.parent = parentGO
  local transformInfo = self:GetWidgetTransformInfo(offsetIndex)
  go.localScale = transformInfo.localScale
  go.localPosition = transformInfo.localPosition
  go.name = "Constellation_" .. offsetIndex
  local info = self:GetConstellationInfo(constellation)
  local Img_Icon = go:FindDirect("Img_Icon")
  GUIUtils.SetTexture(Img_Icon, info.icon)
  if offsetIndex ~= 0 then
    GUIUtils.SetTextureEffect(Img_Icon:GetComponent("UITexture"), GUIUtils.Effect.Gray)
  end
  return go
end
def.method("number", "=>", "table").GetWidgetTransformInfo = function(self, offsetIndex)
  local widget_center_pos = self.m_uiParams.widget_center_pos
  local widget_gap = self.m_uiParams.widget_gap
  local widget_startgap = self.m_uiParams.widget_startgap
  local scaleSize = self.m_uiParams.scaleSize
  local dir = 0
  if offsetIndex ~= 0 then
    dir = offsetIndex > 0 and 1 or -1
    scaleSize = 1
  end
  local x = dir * widget_startgap + widget_center_pos.x + widget_gap * offsetIndex
  local y, z = widget_center_pos.y, widget_center_pos.z
  local transformInfo = {}
  transformInfo.localPosition = Vector.Vector3.new(x, y, z)
  transformInfo.localScale = Vector.Vector3.one * scaleSize
  return transformInfo
end
def.method("number", "=>", "table").GetConstellationInfo = function(self, constellation)
  local info = {constellation = constellation}
  local cfg = ConstellationUtils.GetConstellationCfg(constellation)
  info.icon = cfg.icon
  info.name = cfg.name
  local roundInfo = ConstellationModule.Instance():GetRoundInfo()
  local fortune = roundInfo and roundInfo.fortune or 1
  info.todayFortune = cfg.fortunes[fortune] or "nil"
  return info
end
def.method("number", "=>", "number").GetConstellationByRound = function(self, round)
  return self.m_allConstellations[round] or ConstellationModule.CONSTELLATION_NONE
end
def.method().UpdateFinishCountDown = function(self)
  GUIUtils.SetActive(self.m_uiObjs.Group_Astrology, true)
  GUIUtils.SetActive(self.m_uiObjs.Group_Time, false)
  GUIUtils.SetActive(self.m_uiObjs.Label_Tips, true)
  GUIUtils.SetActive(self.m_uiObjs.Label_Infor, false)
  local function countdown(seconds)
    local Label_Tips = self.m_uiObjs.Label_Tips
    local text = string.format(textRes.Constellation[12], seconds)
    GUIUtils.SetText(Label_Tips, text)
    if seconds <= 0 then
      return
    end
    GameUtil.AddGlobalTimer(1, true, function()
      if self.m_uiObjs == nil or Label_Tips.isnil then
        return
      end
      local leftSeconds = self:GetCloseLeftSeconds()
      if leftSeconds > 0 then
        countdown(leftSeconds)
      else
        countdown(0)
        self:OnCloseCountDownEnd()
      end
    end)
  end
  local leftSeconds = self:GetCloseLeftSeconds()
  countdown(leftSeconds)
end
def.method().OnCloseCountDownEnd = function(self)
  self:DestroyPanel()
end
def.method().UpdateChatControlBtn = function(self)
  local Btn_Talk = self.m_uiObjs.Group_Btn:FindDirect("Btn_Talk")
  local Btn_CloseTalk = self.m_uiObjs.Group_Btn:FindDirect("Btn_CloseTalk")
  local showTalkBtn = not self:IsChatPanelShow()
  GUIUtils.SetActive(Btn_Talk, showTalkBtn)
  GUIUtils.SetActive(Btn_CloseTalk, not showTalkBtn)
end
def.method().UpdateTotalGains = function(self)
  local Label_ExpNum = self.m_uiObjs.Img_Exp:FindDirect("Label_Num")
  local Label_MoneyNum = self.m_uiObjs.Img_Money:FindDirect("Label_Num")
  local expNum = ConstellationModule.Instance():GetAccumulatedExp()
  local MoneyNum = 0
  GUIUtils.SetText(Label_ExpNum, expNum)
  GUIUtils.SetText(Label_MoneyNum, MoneyNum)
end
def.method().UpdateRoleInfo = function(self)
  local heroProp = _G.GetHeroProp()
  if heroProp == nil then
    return
  end
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarId = AvatarInterface.Instance():getCurAvatarId()
  local avatarFrameId = AvatarInterface.Instance():getCurAvatarFrameId()
  _G.SetAvatarIcon(self.m_uiObjs.Img_IconHead, avatarId, avatarFrameId)
  local Label_LV = self.m_uiObjs.Img_IconHead:FindDirect("Label_LV")
  GUIUtils.SetText(Label_LV, heroProp.level)
end
def.method().UpdateNatalConstellation = function(self)
  local constellation = self:GetNatalConstellation()
  local icon, name
  if constellation > ConstellationModule.CONSTELLATION_NONE then
    local info = self:GetConstellationInfo(constellation)
    icon = info.icon
    name = string.format(textRes.Constellation[7], info.name)
  else
    icon = 0
    name = ""
  end
  local Img_Icon = self.m_uiObjs.Item:FindDirect("Img_Icon")
  GUIUtils.SetTexture(Img_Icon, icon)
  local Label_Star = self.m_uiObjs.Item:FindDirect("Label_Star")
  GUIUtils.SetText(Label_Star, name)
end
def.method().UpdateCards = function(self)
  local roundInfo = ConstellationModule.Instance():GetRoundInfo()
  local cards = roundInfo and roundInfo.cards or {}
  local choose_index = roundInfo and roundInfo.choose_index or 0
  self:TraverseCardWidgets(function(i, cardGO)
    local cardInfo = cards[i]
    local cardViewInfo = self:GetCardViewInfo(cardInfo)
    if i == choose_index then
      cardViewInfo.choose = true
    end
    self:SetCardViewInfo(cardGO, cardViewInfo)
    if self:IsRoundPause() or i == choose_index then
      self:FlipCardToFront(cardGO, true)
    end
  end)
end
def.method().OnChangeBtnClick = function(self)
  local constellation = self:GetNatalConstellation()
  if constellation == ConstellationModule.CONSTELLATION_UNKONW then
    Toast(textRes.Constellation[17])
    ConstellationModule.Instance():AttemptQueryConstellationInfo()
    return
  end
  require("Main.Constellation.ui.ChooseConstellationPanel").Instance():ShowPanel()
end
def.method().OnClickChatBtn = function(self)
  if self:IsChatPanelShow() then
    return
  end
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
end
def.method().OnClickCloseChatBtn = function(self)
  require("Main.Chat.ui.ChannelChatPanel").Instance():DestroyPanel()
  require("Main.friend.ui.SocialDlg").Instance():DestroyPanel()
end
def.method().OnPreviewBtnClick = function(self)
  local natalConstellation = self:GetNatalConstellation()
  local curRoundConstellation = self:GetCurRoundConstellation()
  if natalConstellation ~= curRoundConstellation then
    Toast(textRes.Constellation[9])
    return
  end
  local hasFlipAll = self:FlipAllCards()
  if hasFlipAll then
    Toast(textRes.Constellation[8])
  end
end
def.method("=>", "boolean").FlipAllCards = function(self)
  local hasFlipAll = true
  self:TraverseCardWidgets(function(i, go)
    if self:IsCardBackFace(go) then
      hasFlipAll = false
    end
    self:FlipCardToFront(go, false)
  end)
  return hasFlipAll
end
def.method("number", "userdata").OnClickCardObj = function(self, index, cardGO)
  print("OnClickCardObj", index, cardGO.name)
  if self:IsRoundPause() then
    Toast(textRes.Constellation[10])
    return
  end
  local roundInfo = ConstellationModule.Instance():GetRoundInfo()
  local choose_index = roundInfo and roundInfo.choose_index or 0
  if choose_index ~= 0 then
    Toast(textRes.Constellation[11])
    return
  end
  local constellation = self:GetCurRoundConstellation()
  ConstellationModule.Instance():ChooseCardReq(constellation, index)
end
def.method().RandomFlipCardReq = function(self)
  if self.m_flipCardRequiring then
    return
  end
  local roundInfo = ConstellationModule.Instance():GetRoundInfo()
  local choose_index = roundInfo and roundInfo.choose_index or 0
  if choose_index ~= 0 then
    return
  end
  local constellation = self:GetCurRoundConstellation()
  local index = math.random(MAX_CARD)
  ConstellationModule.Instance():ChooseCardReq(constellation, index)
  self.m_flipCardRequiring = true
end
def.method("function").TraverseConstellationWidgets = function(self, traveller)
  if traveller == nil then
    return
  end
  local parentGO = self.m_uiObjs.Grid_Stars
  local childCount = parentGO.childCount
  for i = 0, childCount - 1 do
    local childGO = parentGO:GetChild(i)
    local childName = childGO.name
    if childName ~= "_tempalte" then
      traveller(i, childGO)
    end
  end
end
def.method("function").TraverseCardWidgets = function(self, traveller)
  if traveller == nil then
    return
  end
  local parentGO = self.m_uiObjs.Group_Grid
  local childCount = parentGO.childCount
  for i = 0, childCount - 1 do
    local childGO = parentGO:GetChild(i)
    traveller(i + 1, childGO)
  end
end
def.method("userdata", "boolean").FlipCardToFront = function(self, cardGO, instant)
  self:FlipCard(cardGO, true, instant)
end
def.method("userdata", "boolean").FlipCardToBack = function(self, cardGO, instant)
  self:FlipCard(cardGO, false, instant)
end
def.method("userdata", "boolean", "boolean").FlipCard = function(self, cardGO, isForward, instant)
  local includeInactive = false
  if not cardGO.activeInHierarchy then
    instant = true
    includeInactive = true
  end
  if instant then
    local uiTweeners = cardGO:GetComponentsInChildren("UITweener", includeInactive)
    local factor = isForward and 1 or 0
    for i, v in ipairs(uiTweeners) do
      GUIUtils.SampleTweener(v, factor)
    end
  else
    local Img_BgPrize = cardGO:FindDirect("Img_BgPrize")
    local uiPlayTween = Img_BgPrize:GetComponent("UIPlayTween")
    uiPlayTween:Play(isForward)
  end
end
def.method("userdata", "=>", "boolean").IsCardBackFace = function(self, cardGO)
  local Img_BgPrize = cardGO:FindDirect("Img_BgPrize")
  local uiTweener = Img_BgPrize:GetComponent("UITweener")
  if uiTweener.tweenFactor == 0 then
    return true
  else
    return false
  end
end
def.method("userdata", "table").SetCardViewInfo = function(self, cardGO, cardViewInfo)
  cardViewInfo = cardViewInfo or {}
  local Sprite = cardGO:FindDirect("Sprite")
  local Img_Exp = Sprite:FindDirect("Img_Exp")
  local Img_Money = Sprite:FindDirect("Img_Money")
  local Img_Star = Sprite:FindDirect("Img_Star")
  local Img_Select = cardGO:FindDirect("Img_Select")
  if cardViewInfo.award then
    local award = cardViewInfo.award
    if award.exp then
      GUIUtils.SetActive(Img_Exp, true)
      local Label = Img_Exp:FindDirect("Label")
      GUIUtils.SetText(Label, award.exp)
    else
      GUIUtils.SetActive(Img_Exp, false)
    end
    if award.money then
      GUIUtils.SetActive(Img_Money, true)
      local moneySprite = award.money.sprite
      GUIUtils.SetSprite(Img_Money, moneySprite)
      local Label = Img_Money:FindDirect("Label")
      GUIUtils.SetText(Label, tostring(award.money.num))
    else
      GUIUtils.SetActive(Img_Money, false)
    end
  else
    GUIUtils.SetActive(Img_Exp, false)
    GUIUtils.SetActive(Img_Money, false)
  end
  local starSpriteName = string.format("%dx", cardViewInfo.star or 0)
  GUIUtils.SetSprite(Img_Star, starSpriteName)
  local isChoose = cardViewInfo.choose and true or false
  GUIUtils.SetActive(Img_Select, isChoose)
end
def.method("number", "=>", "userdata").FindCardGO = function(self, index)
  return self.m_uiObjs.Group_Grid:FindDirect("Container" .. index)
end
def.method().MinimizePanel = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local title = textRes.Common[8]
  local content = textRes.Constellation[16]
  CommonConfirmDlg.ShowConfirm(title, content, function(s)
    if s == 1 then
      self:DestroyPanel()
    end
  end, nil)
end
def.method("table", "=>", "table").GetCardViewInfo = function(self, cardInfo)
  if cardInfo == nil then
    return nil
  end
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local getOneValidMoneyFromAwardBean = function(awardBean)
    local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
    local moneyType, moneyNum
    if awardBean.goldIngot > 0 then
      moneyType = MoneyType.GOLD_INGOT
      moneyNum = awardBean.goldIngot
    elseif awardBean.gold:gt(0) then
      moneyType = MoneyType.GOLD
      moneyNum = awardBean.gold:ToNumber()
    elseif awardBean.silver:gt(0) then
      moneyType = MoneyType.SILVER
      moneyNum = awardBean.silver:ToNumber()
    end
    return moneyType, moneyNum
  end
  local cardViewInfo = {}
  cardViewInfo.star = cardInfo.star
  cardViewInfo.award = nil
  cardViewInfo.choose = false
  if cardInfo.award then
    local awardBean = cardInfo.award
    cardViewInfo.award = {}
    cardViewInfo.award.exp = awardBean.roleExp
    local moneyType, moneyNum = getOneValidMoneyFromAwardBean(awardBean)
    if moneyType then
      local currency = CurrencyFactory.GetInstance(moneyType)
      cardViewInfo.award.money = {}
      cardViewInfo.award.money.type = moneyType
      cardViewInfo.award.money.num = moneyNum
      cardViewInfo.award.money.sprite = currency:GetSpriteName()
    end
  end
  if cardInfo.extra_award then
    local extra_awardBean = cardInfo.extra_award
    local moneyType, moneyNum = getOneValidMoneyFromAwardBean(extra_awardBean)
    if moneyType then
      if cardViewInfo.award.money == nil then
        local currency = CurrencyFactory.GetInstance(moneyType)
        cardViewInfo.award.money = {}
        cardViewInfo.award.money.type = moneyType
        cardViewInfo.award.money.num = moneyNum
        cardViewInfo.award.money.sprite = currency:GetSpriteName()
      elseif cardViewInfo.award.money.type == moneyType then
        cardViewInfo.award.money.num = cardViewInfo.award.money.num + moneyNum
      end
    end
  end
  return cardViewInfo
end
def.method().Check2ShowChooseConstellationPanel = function(self)
  local constellation = self:GetNatalConstellation()
  if constellation == ConstellationModule.CONSTELLATION_NONE and not self.m_hasAutoShowChoosePanel then
    self.m_hasAutoShowChoosePanel = true
    require("Main.Constellation.ui.ChooseConstellationPanel").Instance():ShowPanel()
  end
end
def.method().CheckConstellationInfo = function(self)
  local constellation = self:GetNatalConstellation()
  if constellation == ConstellationModule.CONSTELLATION_UNKONW then
    warn("delay check constellation info!")
    ConstellationModule.Instance():QueryConstellationInfoReq()
  end
end
def.method().AlignRight = function(self)
  local GUIMan = require("GUI.ECGUIMan")
  local screenHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  local screenWidth = screenHeight / Screen.height * Screen.width
  local Btn_Close = self.m_uiObjs.Btn_Close
  local padding = 1
  local offsetY = self.m_uiParams.Img_Bg_OffsetY
  local uiWidget = self.m_uiObjs.Img_Bg:GetComponent("UIWidget")
  local btnWidget = Btn_Close:GetComponent("UIWidget")
  local rightPartWidth = math.max(Btn_Close.localPosition.x + btnWidget.width / 2, uiWidget.width / 2)
  local x = screenWidth / 2 - rightPartWidth - padding
  local y = offsetY
  local z = 0
  self.m_uiObjs.Img_Bg.localPosition = Vector.Vector3.new(x, y, z)
end
def.method().AlignCenter = function(self)
  local offsetY = self.m_uiParams.Img_Bg_OffsetY
  self.m_uiObjs.Img_Bg.localPosition = Vector.Vector3.new(0, offsetY, 0)
end
def.method().UpdatePanelAlign = function(self)
  if self:IsChatPanelShow() then
    self:AlignRight()
  else
    self:AlignCenter()
  end
end
def.method().UpdatePreviewBtn = function(self)
  if not self:IsCardStageBegin() and not self:IsCardStageEnd() then
    return
  end
  local Btn_Preview = self.m_uiObjs.Group_Down:FindDirect("Btn_Preview")
  local Label_Settle = Btn_Preview:FindDirect("Label_Settle")
  local Img_Select = Btn_Preview:FindDirect("Img_Select")
  local text = GUIUtils.GetUILabelTxt(Label_Settle) or ""
  local ISeeGuide = require("Main.Guide.ui.ISeeGuide")
  local curConstellation = self:GetCurRoundConstellation()
  local natalConstellation = self:GetNatalConstellation()
  if curConstellation == natalConstellation and not self:IsCardStageEnd() then
    GUIUtils.SetActive(Img_Select, true)
    if not text:find("%[%-%]$") then
      text = string.format("[ffffff]%s[-]", text)
    end
    do
      local hasFlipAll = true
      self:TraverseCardWidgets(function(i, go)
        if self:IsCardBackFace(go) then
          hasFlipAll = false
        end
      end)
      if hasFlipAll then
        ISeeGuide.Close()
      elseif not self.m_hasShowPreviewBtnGuide then
        self.m_hasShowPreviewBtnGuide = true
        ISeeGuide.ShowISee(I_SEE_PREVIEW_BTN_GUIDE, function(_, normal, selected)
          if not normal then
            return
          end
          if selected then
            self:FlipAllCards()
          else
            ISeeGuide.Close()
          end
        end)
      end
    end
  else
    ISeeGuide.Close()
  end
end
def.method("table").OnNatalConstellationUpdate = function(self)
  self.m_hasShowPreviewBtnGuide = false
  self:UpdateNatalConstellation()
  self:UpdatePreviewBtn()
  self:Check2ShowChooseConstellationPanel()
end
def.method("table").OnFlipCardSuccess = function(self, params)
  local cardInfo = params[1]
  local index = cardInfo.index
  print("OnFlipCardSuccess " .. index)
  self.m_flipCardRequiring = false
  local cardGO = self:FindCardGO(index)
  local cardViewInfo = self:GetCardViewInfo(cardInfo)
  cardViewInfo.choose = true
  self:SetCardViewInfo(cardGO, cardViewInfo)
  self:FlipCardToFront(cardGO, false)
end
def.method("table").OnConstellationRoundUpdate = function(self, params)
  self.m_flipCardRequiring = false
  local constellation = params[1]
  local nextRound = self:GetRoundByConstellation(constellation)
  local curRound = self:GetCurRound()
  local step = nextRound - curRound
  self:MoveForward(step)
end
def.method("table").OnStageUpdate = function(self, params)
  local stage = params[1]
  self:UpdateStages()
end
def.method("table").OnAccumulatedExpUpdate = function(self, params)
  local exp = params[1]
  self:UpdateTotalGains()
end
def.method("table").OnFeatureClose = function(self, params)
  self:DestroyPanel()
end
def.method("table").OnPanel_PostCreate = function(self, params)
  self:UpdatePanelAlign()
  self:UpdateChatControlBtn()
end
def.method("table").OnPanel_PostDestroy = function(self, params)
  self:UpdatePanelAlign()
  self:UpdateChatControlBtn()
end
return ConstellationsMainPanel.Commit()

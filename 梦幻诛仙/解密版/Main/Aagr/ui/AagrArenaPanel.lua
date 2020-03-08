local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AagrUtils = require("Main.Aagr.AagrUtils")
local AagrData = require("Main.Aagr.data.AagrData")
local MainUIChat = require("Main.MainUI.ui.MainUIChat")
local AagrProtocols = require("Main.Aagr.AagrProtocols")
local AagrArenaPanel = Lplus.Extend(ECPanelBase, "AagrArenaPanel")
local def = AagrArenaPanel.define
local instance
def.static("=>", AagrArenaPanel).Instance = function()
  if instance == nil then
    instance = AagrArenaPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._arenaInfo = nil
def.field("boolean")._bShowChat = false
def.field("table")._playerRankList = nil
def.field("boolean")._bShowRank = true
def.field("userdata")._onlineColor = nil
def.field("userdata")._offlineColor = nil
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
local EFFECT_DURATION = 3
def.field("number")._ballLevel = 0
def.field("boolean")._bShowUpgradeEffect = false
def.static().ShowPanel = function()
  if not AagrData.Instance():IsInArena() then
    warn("[ERROR][AagrArenaPanel:ShowPanel] show fail! not in arena.")
    if AagrArenaPanel.Instance():IsShow() then
      AagrArenaPanel.Instance():DestroyPanel()
    end
    return
  end
  AagrArenaPanel.Instance():_InitData()
  if AagrArenaPanel.Instance():IsShow() then
    AagrArenaPanel.Instance():UpdateUI()
    return
  end
  AagrArenaPanel.Instance():CreatePanel(RESPATH.PREFAB_AAGR_ARENA_PANEL, 0)
end
def.method()._InitData = function(self)
  self._arenaInfo = AagrData.Instance():GetArenaInfo()
  self._playerRankList = self._arenaInfo and self._arenaInfo:GetPlayerRankList()
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
  self:UpdateUI()
  self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:UpdateCountdown()
  end)
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Group_Top = self.m_panel:FindDirect("Group_Top")
  self._uiObjs.Group_Life = self._uiObjs.Group_Top:FindDirect("Group_Life")
  self._uiObjs.uiGrid = self._uiObjs.Group_Life:GetComponent("UIGrid")
  self._uiObjs.LabelRoundTime = self._uiObjs.Group_Top:FindDirect("Group_Time/Label_Time")
  self._uiObjs.LabelCircleTime = self._uiObjs.Group_Top:FindDirect("Group_CircleTime/Label_Time")
  self._uiObjs.Group_AllBtn = self.m_panel:FindDirect("Group_AllBtn")
  self._uiObjs.Btn_AllIn = self._uiObjs.Group_AllBtn:FindDirect("Btn_AllIn")
  self._uiObjs.Btn_AllOut = self._uiObjs.Group_AllBtn:FindDirect("Btn_AllOut")
  self._uiObjs.Group_PlayerInfo = self.m_panel:FindDirect("Group_PlayerInfo")
  self._uiObjs.Group_Info = self._uiObjs.Group_PlayerInfo:FindDirect("Group_Info")
  self._uiObjs.TweenPlayerInfo = self._uiObjs.Group_Info:GetComponent("TweenPosition")
  self._uiObjs.Scrollview_List = self._uiObjs.Group_Info:FindDirect("Group_List/Scrollview_List")
  self._uiObjs.uiScrollView = self._uiObjs.Scrollview_List:GetComponent("UIScrollView")
  self._uiObjs.List = self._uiObjs.Scrollview_List:FindDirect("List")
  self._uiObjs.uiList = self._uiObjs.List:GetComponent("UIList")
  self._uiObjs.Btn_Right = self._uiObjs.Group_PlayerInfo:FindDirect("Group_Btn/Btn_Right")
  self._uiObjs.Btn_Left = self._uiObjs.Group_PlayerInfo:FindDirect("Group_Btn/Btn_Left")
  self._uiObjs.TweenBtn_Right = self._uiObjs.Btn_Right:GetComponent("UIPlayTween")
  self._uiObjs.TweenBtn_Left = self._uiObjs.Btn_Left:GetComponent("UIPlayTween")
  self._uiObjs.Group_Evolve = self.m_panel:FindDirect("Group_Top/Group_Evolve")
  self._uiObjs.Label_Num = self._uiObjs.Group_Evolve:FindDirect("Label_Num")
  self._uiObjs.Img_ArrowGreen = self._uiObjs.Group_Evolve:FindDirect("Img_ArrowGreen")
  GUIUtils.SetActive(self._uiObjs.Img_ArrowGreen, false)
  self._onlineColor = Color.white
  self._offlineColor = Color.Color(0.5019607843137255, 0.5411764705882353, 0.5294117647058824)
end
def.method().UpdateUI = function(self)
  self:UpdateTopInfo()
  self:UpdateChat(self._bShowChat)
  self:UpdateRank(self._bShowRank)
  self:UpdateLevelProgress()
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show and nil == self._arenaInfo then
    self:_InitData()
    self:UpdateUI()
  else
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearTimer()
  self._uiObjs = nil
  self._arenaInfo = nil
  self._playerRankList = nil
  self._bShowChat = false
  self._bShowRank = true
  self._onlineColor = nil
  self._offlineColor = nil
  self._ballLevel = 0
  self._bShowUpgradeEffect = false
end
def.method().UpdateTopInfo = function(self)
  local lifeCount = self._arenaInfo and self._arenaInfo:GetPlayerLifeCount(_G.GetMyRoleID()) or 0
  warn("[AagrArenaPanel:UpdateTopInfo] curLifeCount, maxLife, self._arenaInfo:", lifeCount, AagrData.Instance():GetBallMaxLife(), self._arenaInfo)
  local maxCount = self._uiObjs.uiGrid:GetChildListCount()
  local gridChildList = self._uiObjs.uiGrid:GetChildList()
  for i = 1, maxCount do
    local item = self._uiObjs.Group_Life:FindDirect("Item_0" .. i)
    local Img_Star = item:FindDirect("Img_Star")
    GUIUtils.SetActive(Img_Star, i <= lifeCount)
  end
  self:UpdateCountdown()
end
def.method().UpdateCountdown = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.LabelRoundTime) and not _G.IsNil(self._uiObjs.LabelCircleTime) then
    local remainRoundTime = self._arenaInfo and self._arenaInfo:GetRoundRemainTime() or 0
    GUIUtils.SetText(self._uiObjs.LabelRoundTime, AagrUtils.GetCountdownText(textRes.Aagr.ARENA_ROUND_COUNTDOWN, remainRoundTime))
    local remainShrinkTime = self._arenaInfo and self._arenaInfo:GetShrinkRemainTime() or 0
    GUIUtils.SetText(self._uiObjs.LabelCircleTime, AagrUtils.GetCountdownText(textRes.Aagr.ARENA_CIRCLE_COUNTDOWN, remainShrinkTime))
  end
end
def.method("boolean").UpdateChat = function(self, bShow)
  self._bShowChat = bShow
  GUIUtils.SetActive(self._uiObjs.Btn_AllOut, not bShow)
  GUIUtils.SetActive(self._uiObjs.Btn_AllIn, bShow)
  if MainUIChat.Instance():IsShow() then
    if bShow then
      MainUIChat.Instance():Expand()
    else
      MainUIChat.Instance():Shrink()
    end
  end
end
def.method("=>", "number").GetPlayerCount = function(self)
  return self._playerRankList and #self._playerRankList or 0
end
def.method("boolean").UpdateRank = function(self, bShow)
  self._bShowRank = bShow
  if bShow then
    self:DoUpdateRank()
    self._uiObjs.TweenBtn_Right:Play(false)
    self._uiObjs.TweenBtn_Left:Play(false)
  else
    self._uiObjs.TweenBtn_Right:Play(true)
    self._uiObjs.TweenBtn_Left:Play(true)
  end
end
def.method().DoUpdateRank = function(self)
  self:_ClearList()
  local playerCount = self:GetPlayerCount()
  if playerCount > 0 then
    self._uiObjs.uiList.itemCount = playerCount
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for idx, playerInfo in ipairs(self._playerRankList) do
      self:ShowPlayerInfo(idx, playerInfo)
    end
  end
end
def.method("number", "table").ShowPlayerInfo = function(self, idx, playerInfo)
  local listItem = self._uiObjs.uiList.children[idx]
  if nil == listItem then
    warn("[ERROR][AagrArenaPanel:ShowPlayerInfo] listItem nil at idx:", idx)
    return
  end
  if nil == playerInfo then
    warn("[ERROR][AagrArenaPanel:ShowPlayerInfo] playerInfo nil at idx:", idx)
    return
  end
  local textColor = self._onlineColor
  if nil == playerInfo.in_game_scene or playerInfo.in_game_scene == 0 then
    textColor = self._offlineColor
  end
  local Img_MingCi = listItem:FindDirect("Img_MingCi")
  local Label_Rank = listItem:FindDirect("Label_Rank")
  if idx < 4 then
    GUIUtils.SetActive(Img_MingCi, true)
    GUIUtils.SetActive(Label_Rank, false)
    local spriteName = "Img_Num" .. idx
    GUIUtils.SetSprite(Img_MingCi, spriteName)
  else
    GUIUtils.SetActive(Img_MingCi, false)
    GUIUtils.SetActive(Label_Rank, true)
    GUIUtils.SetTextAndColor(Label_Rank, idx, textColor)
  end
  local Label_PlayerName = listItem:FindDirect("Label_PlayerName")
  GUIUtils.SetTextAndColor(Label_PlayerName, self._arenaInfo:GetPlayerName(playerInfo.roleId), textColor)
  local Label_Points = listItem:FindDirect("Label_Points")
  GUIUtils.SetTextAndColor(Label_Points, playerInfo.score, textColor)
end
def.method()._ClearList = function(self)
  self._uiObjs.uiList.itemCount = 0
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
end
def.method().UpdateLevelProgress = function(self)
  local ballInfo = require("Main.Aagr.mgr.ArenaBallMgr").Instance():GetBallInfo(_G.GetMyRoleID())
  if ballInfo then
    local curLevel = ballInfo:GetLevel()
    local curGene = ballInfo:GetGene()
    local maxLevel = AagrData.Instance():GetMaxBallLevel()
    if curLevel >= maxLevel then
      GUIUtils.SetProgress(self._uiObjs.Group_Evolve, GUIUtils.COTYPE.SLIDER, 1)
      GUIUtils.SetText(self._uiObjs.Label_Num, textRes.Aagr.ARENA_GENE_MAX)
    else
      local ballLevelCfg = AagrData.Instance():GetBallLevelCfg(curLevel)
      local levelUpGene = ballLevelCfg and ballLevelCfg.requiredGene or 0
      local progress = levelUpGene > 0 and curGene / levelUpGene or 0
      progress = math.min(1, progress)
      GUIUtils.SetProgress(self._uiObjs.Group_Evolve, GUIUtils.COTYPE.SLIDER, progress)
      GUIUtils.SetText(self._uiObjs.Label_Num, curGene .. "/" .. levelUpGene)
    end
    if curLevel > self._ballLevel and 0 < self._ballLevel and self._bShowUpgradeEffect == false then
      self._bShowUpgradeEffect = true
      GUIUtils.SetActive(self._uiObjs.Img_ArrowGreen, true)
      GameUtil.AddGlobalTimer(EFFECT_DURATION, true, function()
        self._bShowUpgradeEffect = false
        if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.Img_ArrowGreen) then
          GUIUtils.SetActive(self._uiObjs.Img_ArrowGreen, false)
        end
      end)
    end
    self._ballLevel = curLevel
  else
    warn("[ERROR][AagrArenaPanel:UpdateLevelProgress] self ballInfo nil.")
    GUIUtils.SetProgress(self._uiObjs.Group_Evolve, GUIUtils.COTYPE.SLIDER, 0)
    GUIUtils.SetText(self._uiObjs.Label_Num, "")
  end
end
def.method()._Update = function(self)
  self:UpdateCountdown()
end
def.method()._ClearTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Quit" then
    self:OnBtn_Quit()
  elseif id == "Btn_AllOut" then
    self:OnBtn_AllOut()
  elseif id == "Btn_AllIn" then
    self:OnBtn_AllIn()
  elseif id == "Btn_Right" then
    self:OnBtn_Right()
  elseif id == "Btn_Left" then
    self:OnBtn_Left()
  end
end
def.method().OnBtn_Quit = function(self)
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Aagr.ARENA_QUIT_TITLE, textRes.Aagr.ARENA_QUIT_CONTENT, function(id, tag)
    if id == 1 then
      AagrProtocols.SendCLeaveGameMapReq()
    end
  end, nil)
end
def.method().OnBtn_AllOut = function(self)
  self:UpdateChat(true)
end
def.method().OnBtn_AllIn = function(self)
  self:UpdateChat(false)
end
def.method().OnBtn_Right = function(self)
  self._bShowRank = true
  self:DoUpdateRank()
end
def.method().OnBtn_Left = function(self)
  self._bShowRank = false
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ARENA_INFO_CHANGE, AagrArenaPanel.OnArenaInfoChange)
    eventFunc(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ARENA_PLAYER_CHANGE, AagrArenaPanel.OnPlayerInfoChange)
    eventFunc(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ARENA_BALL_INFO_CHANGE, AagrArenaPanel.OnBallInfoChange)
    eventFunc(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, AagrArenaPanel.OnMainUIShow)
  end
end
def.static("table", "table").OnArenaInfoChange = function(params, context)
  local self = AagrArenaPanel.Instance()
  if self and self:IsShow() then
    self:_InitData()
    self:UpdateUI()
  end
end
def.static("table", "table").OnPlayerInfoChange = function(params, context)
  local self = AagrArenaPanel.Instance()
  if self and self:IsShow() then
    self:_InitData()
    self:UpdateTopInfo()
    self:UpdateRank(self._bShowRank)
  end
end
def.static("table", "table").OnBallInfoChange = function(params, context)
  local roleId = params.roleId
  local self = AagrArenaPanel.Instance()
  if roleId and self and self:IsShow() and Int64.eq(_G.GetMyRoleID(), roleId) then
    self:_InitData()
    self:UpdateLevelProgress()
  end
end
def.static("table", "table").OnMainUIShow = function(params, context)
  local self = AagrArenaPanel.Instance()
  if self and self:IsShow() then
    self:UpdateChat(self._bShowChat)
  end
end
AagrArenaPanel.Commit()
return AagrArenaPanel

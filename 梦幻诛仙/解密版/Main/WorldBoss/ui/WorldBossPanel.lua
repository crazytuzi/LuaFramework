local EC = require("Types.Vector3")
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECUIModel = require("Model.ECUIModel")
local WorldBossMgr = require("Main.WorldBoss.WorldBossMgr")
local WorldBossUtility = require("Main.WorldBoss.WorldBossUtility")
local GUIUtils = require("GUI.GUIUtils")
local RankListModule = require("Main.RankList.RankListModule")
local RankListUtils = require("Main.RankList.RankListUtils")
local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
local WorldBossPanel = Lplus.Extend(ECPanelBase, "WorldBossPanel")
local def = WorldBossPanel.define
local instance
def.static("=>", WorldBossPanel).Instance = function()
  if instance == nil then
    instance = WorldBossPanel()
  end
  return instance
end
def.field("table").uiNodes = nil
def.const("number").RANKNUM = 300
def.field("table").model = nil
def.field("boolean").isThisWeek = true
def.field("boolean").activityEnded = false
def.field("number").duration = 0
def.field("number")._CurOccupationIndex = 0
def.field("boolean")._IsChoosingOccup = false
def.field("boolean")._IsRemote = false
def.field("boolean")._IsChoosingRemote = false
def.field("table").rankListData = nil
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:UpdateUI(true)
  else
    self:CreatePanel(RESPATH.PREFAB_WORLDBOSS_MAIN_PANEL, 1)
    self:SetModal(true)
  end
end
def.method("boolean", "number", "function", "function").RequestData = function(self, isRemote, occupationId, callback1, callback2)
  if isRemote then
    self.rankListData = RankListModule.Instance():GetRankListData(RankListUtils.GetWroldBossRemoteChartTypeByOccup(occupationId))
    self.rankListData:ReqRankList(1, constant.CBigbossConsts.PAGE_SIZE_LITTLE, callback1)
    self.rankListData:ReqSelfRankInfo(callback2)
  else
    self.rankListData = RankListModule.Instance():GetRankListData(RankListUtils.GetWroldBossChartTypeByOccup(occupationId))
    self.rankListData:ReqRankList(1, constant.CBigbossConsts.PAGE_SIZE_LITTLE, callback1)
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.duration = WorldBossMgr.Instance():GetEndTime() - WorldBossMgr.Instance():GetStartTime()
  Timer:RegisterListener(self.UpdateTimeCD, self)
  Event.RegisterEvent(ModuleId.WORLDBOSS, gmodule.notifyId.WorldBoss.CHALLENGE_COUNT_BOUGHT, WorldBossPanel.OnBuyChallengeCount)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow == false then
    return
  end
  self:FillOccupList()
  self:UpdateUI(true)
end
def.method().FillOccupList = function(self)
  local occupCfgList = WorldBossMgr.Instance():GetOccupationList()
  local uiList = self.uiNodes.occupationList:GetComponent("UIList")
  local itemCount = #occupCfgList
  uiList.itemCount = itemCount
  uiList:Resize()
  uiList:Reposition()
  for i = 1, itemCount do
    local item = self.uiNodes.occupationList:FindDirect("Btn_Camp_" .. i)
    GUIUtils.SetText(item:FindDirect("Label_" .. i), occupCfgList[i].occupationName)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().DestroyModel = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.override().OnDestroy = function(self)
  Timer:RemoveListener(self.UpdateTimeCD)
  Event.UnregisterEvent(ModuleId.WORLDBOSS, gmodule.notifyId.WorldBoss.CHALLENGE_COUNT_BOUGHT, WorldBossPanel.OnBuyChallengeCount)
  self:ClearUp()
end
def.method().ClearUp = function(self)
  self:DestroyModel()
  self.isThisWeek = true
  self.activityEnded = false
  self.duration = 0
end
def.method().InitUI = function(self)
  self.uiNodes = {}
  self.uiNodes.imgBg = self.m_panel:FindDirect("Img_Bg0")
  self.uiNodes.grpLeft = self.uiNodes.imgBg:FindDirect("Group_Left")
  self.uiNodes.grpRight = self.uiNodes.imgBg:FindDirect("Group_Right")
  self.uiNodes.imgMyRes = self.uiNodes.grpLeft:FindDirect("Img_BgBottom")
  self.uiNodes.scrlViewRank = self.uiNodes.grpLeft:FindDirect("Group_Rank/Scroll View")
  self.uiNodes.listRank = self.uiNodes.scrlViewRank:FindDirect("List_Rank")
  self.uiNodes.imgTime = self.uiNodes.grpRight:FindDirect("Img_BgTime")
  self.uiNodes.model = self.uiNodes.grpRight:FindDirect("Model")
  self.uiNodes.imgModelName = self.uiNodes.grpRight:FindDirect("Img_BgName")
  self.uiNodes.sliderBlood = self.uiNodes.imgBg:FindDirect("Slider_BloodRole")
  self.uiNodes.sliderBlood:FindDirect("Label_BloodRole"):SetActive(false)
  self.uiNodes.occupationGroup = self.uiNodes.imgBg:FindDirect("Group_Choose")
  self.uiNodes.occupationLable = self.uiNodes.occupationGroup:FindDirect("Btn_CampChoose/Label_Btn")
  self.uiNodes.Group_Camp = self.uiNodes.occupationGroup:FindDirect("Group_Camp")
  self.uiNodes.ScrollView_Camp = self.uiNodes.Group_Camp:FindDirect("ScrollView_Camp")
  self.uiNodes.occupationList = self.uiNodes.Group_Camp:FindDirect("ScrollView_Camp/List_Camp")
  self.uiNodes.occupationImgUp = self.uiNodes.occupationGroup:FindDirect("Btn_CampChoose/Img_Up")
  self.uiNodes.occupationImgDown = self.uiNodes.occupationGroup:FindDirect("Btn_CampChoose/Img_Down")
  self.uiNodes.Group_Server = self.m_panel:FindDirect("Img_Bg0/Group_ChooseServer")
  self.uiNodes.Remote = self.uiNodes.Group_Server:FindDirect("Group_Server")
  self.uiNodes.RemoteUp = self.uiNodes.Group_Server:FindDirect("Btn_ChooseServer/Img_Up")
  self.uiNodes.RemoteDown = self.uiNodes.Group_Server:FindDirect("Btn_ChooseServer/Img_Down")
  self.uiNodes.RemoteName = self.uiNodes.Group_Server:FindDirect("Btn_ChooseServer/Label_Btn")
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_BIG_BOSS_REMOTE_CHART) then
    self.uiNodes.Group_Server:SetActive(true)
    self.uiNodes.grpLeft:FindDirect("Img_Rank"):SetActive(false)
  else
    self._IsRemote = false
    self._IsChoosingRemote = false
    self.uiNodes.Group_Server:SetActive(false)
    self.uiNodes.grpLeft:FindDirect("Img_Rank"):SetActive(true)
  end
end
def.method("boolean").UpdateUI = function(self, isThisWeek)
  self:ShowHideOccupationList(false)
  self:ShowHideRemoteList(false)
  self:UpdateOccupationRankList(WorldBossMgr.Instance():GetDefaultOccupationIndex(), self._IsRemote)
  self:ShowBoss(isThisWeek)
end
def.method("number", "boolean").UpdateOccupationRankList = function(self, occupationIndex, isRemote)
  self:ClearRankList()
  self._CurOccupationIndex = occupationIndex
  self._IsRemote = isRemote
  self:UpdateCurrentOccupation()
  self:UpdateCurrentRemote()
  self:RequestData(self._IsRemote, WorldBossMgr.Instance():GetOccupationIdByIndex(self._CurOccupationIndex), WorldBossPanel.OnRecievedData, WorldBossPanel.OnRecievedSelfData)
end
def.method().ClearRankList = function(self)
  local uiScrollView = self.uiNodes.scrlViewRank:GetComponent("UIScrollView")
  uiScrollView:ResetPosition()
  local uiList = self.uiNodes.listRank:GetComponent("UIList")
  uiList.itemCount = 0
  uiList:Resize()
  uiList:Reposition()
  local uiLabelRank = self.uiNodes.imgMyRes:FindDirect("Label_Content1"):GetComponent("UILabel")
  uiLabelRank.text = textRes.WorldBoss[7]
  local uiLabelScore = self.uiNodes.imgMyRes:FindDirect("Label_Content2"):GetComponent("UILabel")
  uiLabelScore.text = 0
end
def.method().UpdateCurrentOccupation = function(self)
  GUIUtils.SetText(self.uiNodes.occupationLable, WorldBossMgr.Instance():GetOccupationNameByIndex(self._CurOccupationIndex))
end
def.method().UpdateCurrentRemote = function(self)
  if self._IsRemote then
    GUIUtils.SetText(self.uiNodes.RemoteName, textRes.WorldBoss[13])
  else
    GUIUtils.SetText(self.uiNodes.RemoteName, textRes.WorldBoss[12])
  end
end
def.static("table").OnRecievedData = function(rankListData)
  local self = instance
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if rankListData.type ~= self:GetCurChartType() then
    return
  end
  self.rankListData = rankListData
  if self._IsRemote then
    self:UpdateRankList()
  else
    self:UpdateRankList()
    self:UpdateMyRank()
  end
end
def.static("table").OnRecievedSelfData = function(rankListData)
  local self = instance
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if rankListData.type ~= self:GetCurChartType() then
    return
  end
  self.rankListData = rankListData
  self:UpdateMyRank()
end
def.method("=>", "number").GetCurChartType = function(self)
  if self._IsRemote then
    return RankListUtils.GetWroldBossRemoteChartTypeByOccup(WorldBossMgr.Instance():GetOccupationIdByIndex(self._CurOccupationIndex))
  else
    return RankListUtils.GetWroldBossChartTypeByOccup(WorldBossMgr.Instance():GetOccupationIdByIndex(self._CurOccupationIndex))
  end
end
def.method().UpdateMyRank = function(self)
  local uiLabelRank = self.uiNodes.imgMyRes:FindDirect("Label_Content1"):GetComponent("UILabel")
  local uiLabelScore = self.uiNodes.imgMyRes:FindDirect("Label_Content2"):GetComponent("UILabel")
  local rank = self.rankListData:GetSelfRank()
  if rank <= WorldBossPanel.RANKNUM and rank > 0 then
    uiLabelRank.text = rank
  else
    uiLabelRank.text = textRes.WorldBoss[7]
  end
  uiLabelScore.text = tostring(self.rankListData:GetSelfValue())
end
def.method().UpdateRankList = function(self)
  local rankList = self.rankListData and self.rankListData:GetViewData(1, constant.CBigbossConsts.PAGE_SIZE_LITTLE) or nil
  if not rankList then
    warn(string.format("[WorldBossPanel:UpdateRankList] rankList nil at index [%d]!", self._CurOccupationIndex))
    self:ClearRankList()
    return
  end
  local uiScrollView = self.uiNodes.scrlViewRank:GetComponent("UIScrollView")
  uiScrollView:ResetPosition()
  local itemCount = #rankList
  local uiList = self.uiNodes.listRank:GetComponent("UIList")
  uiList.itemCount = itemCount
  uiList:Resize()
  uiList:Reposition()
  for i = 1, itemCount do
    local rank, name, occupationName, damagepoint = unpack(rankList[i])
    local item = self.uiNodes.listRank:FindDirect("item_" .. i)
    local uiLabelRank = item:FindDirect("Label_1"):GetComponent("UILabel")
    uiLabelRank.text = i
    local uiLabelName = item:FindDirect("Label_2"):GetComponent("UILabel")
    uiLabelName.text = name
    local uiLabelScore = item:FindDirect("Label_3"):GetComponent("UILabel")
    uiLabelScore.text = damagepoint
    item:FindDirect("Img_MingCi"):SetActive(false)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("boolean").ShowBoss = function(self, isThisWeek)
  self.isThisWeek = isThisWeek
  self:ToggleArrowButtons()
  self:UpdateBossInfo()
  self:UpdateTimeCD(0)
  self:UpdateCounts()
end
def.method().ToggleArrowButtons = function(self)
  local btnRight = self.uiNodes.grpRight:FindDirect("Btn_Right")
  local sprite = self.uiNodes.grpRight:FindDirect("Sprite")
  btnRight:SetActive(self.isThisWeek)
  sprite:SetActive(not self.isThisWeek)
end
def.method().UpdateBossInfo = function(self)
  local bossId = WorldBossMgr.Instance():GetBossID(self.isThisWeek)
  if bossId == 0 then
    warn("~~~~~~~~In world boss, no boss id!")
    return
  end
  local bossCfg = WorldBossUtility.GetMonsterCfg(bossId)
  if not bossCfg then
    warn("~~~~~~~~In world boss, no boss cfg!")
    return
  end
  local uiLabelBossName = self.uiNodes.imgModelName:FindDirect("Label_Name"):GetComponent("UILabel")
  uiLabelBossName.text = bossCfg.name
  self.uiNodes.sliderBlood:SetActive(self.isThisWeek)
  local uiModel = self.uiNodes.model:GetComponent("UIModel")
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
  if uiModel.mCanOverflow ~= nil then
    uiModel.mCanOverflow = true
  end
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, bossCfg.modelId)
  local modelPath
  if modelRecord then
    local iconId = modelRecord:GetIntValue("halfBodyIconId")
    local iconCfg = GetHalfBodyCfg(iconId)
    if iconCfg then
      modelPath = iconCfg.path
    end
  end
  if modelPath == nil then
    return
  end
  local function modelLoadCB()
    self.model:SetDir(180)
    self.model:Play("Stand_c")
    self.model:SetScale(1)
    self.model:SetPos(0, 0)
    self:UpdateModelExtra()
    uiModel.modelGameObject = self.model.m_model
  end
  if not self.model then
    self.model = ECUIModel.new(bossCfg.modelId)
    self.model.m_bUncache = true
    self.model:LoadUIModel(modelPath, function(ret)
      if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil or uiModel == nil or uiModel.isnil then
        return
      end
      modelLoadCB()
    end)
  else
    modelLoadCB()
  end
end
def.method().UpdateModelExtra = function(self)
end
def.method("number").UpdateTimeCD = function(self, dt)
  if not self.m_panel or self.m_panel.isnil or not self.m_panel:get_activeInHierarchy() then
    return
  end
  local uiLabelTimeTitle = self.uiNodes.imgTime:FindDirect("Label"):GetComponent("UILabel")
  local uiLabelTimeLeft = self.uiNodes.imgTime:FindDirect("Label_LeftTime"):GetComponent("UILabel")
  local uiSliderBloodLeft = self.uiNodes.sliderBlood:GetComponent("UISlider")
  local title, timeStr
  if self.isThisWeek then
    local time = WorldBossMgr.Instance():GetEndTime() - GetServerTime()
    title = textRes.WorldBoss[2]
    local sliderValue = 0
    if time > 0 then
      local hour = math.modf(time / 3600)
      local min = math.modf((time - hour * 3600) / 60)
      local sec = time - hour * 3600 - min * 60
      timeStr = string.format("%d:%02d:%02d", hour, min, sec)
      if 0 < self.duration then
        sliderValue = time / self.duration
      else
        sliderValue = 0
      end
    else
      self.activityEnded = true
      timeStr = string.format("%d:%02d:%02d", 0, 0, 0)
      sliderValue = 0
    end
    uiSliderBloodLeft.sliderValue = sliderValue
  else
    title = textRes.WorldBoss[3]
    local time = WorldBossMgr.Instance():GetNextStartTime()
    timeStr = require("Main.Common.AbsoluteTimer").GetFormatedServerDate(textRes.Common.Date[1], time)
  end
  uiLabelTimeTitle.text = title
  uiLabelTimeLeft.text = timeStr
end
def.method().UpdateCounts = function(self)
  local uiLabelCDTitle = self.uiNodes.grpRight:FindDirect("Label"):GetComponent("UILabel")
  local uiLabelCDNum = self.uiNodes.grpRight:FindDirect("Label_LeftNum"):GetComponent("UILabel")
  local title, counts
  if self.isThisWeek then
    title = textRes.WorldBoss[4]
    counts = WorldBossMgr.Instance():GetChallengeCountLeft()
  else
    title = textRes.WorldBoss[5]
    counts = ""
  end
  uiLabelCDTitle.text = title
  uiLabelCDNum.text = counts
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_RewardTips" then
    require("Main.WorldBoss.ui.WorldBossTipsPanel").Instance():ShowPanel()
  elseif id == "Btn_Partner" then
    Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_ShowLinupTab, nil)
  elseif id == "Btn_Buy" then
    self:TryBuyChallengeCount()
  elseif id == "Btn_Fight" then
    self:TrySendFightReq()
  elseif id == "Btn_Right" then
    self:ShowBoss(false)
  elseif id == "Sprite" then
    self:ShowBoss(true)
  elseif id == "Btn_CampChoose" then
    self:ShowHideOccupationList(not self._IsChoosingOccup)
  elseif id == "Btn_ChooseServer" then
    self:ShowHideRemoteList(not self._IsChoosingRemote)
  elseif string.sub(id, 1, #"Btn_Camp_") == "Btn_Camp_" then
    local index = tonumber(string.sub(id, #"Btn_Camp_" + 1, -1))
    self:ShowHideOccupationList(false)
    self:UpdateOccupationRankList(index, self._IsRemote)
  elseif id == "Btn_Server_1" then
    self:ShowHideRemoteList(false)
    self:UpdateOccupationRankList(self._CurOccupationIndex, false)
  elseif id == "Btn_Server_2" then
    self:ShowHideRemoteList(false)
    self:UpdateOccupationRankList(self._CurOccupationIndex, true)
  end
  if id ~= "Btn_CampChoose" then
    self:ShowHideOccupationList(false)
  end
  if id ~= "Btn_ChooseServer" then
    self:ShowHideRemoteList(false)
  end
end
def.method("boolean").ShowHideOccupationList = function(self, isshow)
  self._IsChoosingOccup = isshow
  self.uiNodes.Group_Camp:SetActive(isshow)
  self.uiNodes.occupationImgUp:SetActive(isshow)
  self.uiNodes.occupationImgDown:SetActive(not isshow)
  if isshow then
    local uiScrollView = self.uiNodes.ScrollView_Camp:GetComponent("UIScrollView")
    uiScrollView:ResetPosition()
    local uiList = self.uiNodes.occupationList:GetComponent("UIList")
    uiList:Reposition()
  end
end
def.method("boolean").ShowHideRemoteList = function(self, isshow)
  self._IsChoosingRemote = isshow
  self.uiNodes.Remote:SetActive(isshow)
  self.uiNodes.RemoteUp:SetActive(isshow)
  self.uiNodes.RemoteDown:SetActive(not isshow)
end
def.method().TryBuyChallengeCount = function(self)
  if self.activityEnded then
    Toast(textRes.WorldBoss.ErrorCode[7])
    return
  end
  local leftCount = WorldBossMgr.Instance():GetChallengeCountLeft()
  if leftCount > 0 then
    Toast(textRes.WorldBoss.ErrorCode[8])
    return
  end
  require("Main.WorldBoss.ui.WorldBossBuyPanel").Instance():ShowPanel()
end
def.method().TrySendFightReq = function(self)
  if not self.isThisWeek then
    Toast(textRes.WorldBoss[6])
    return
  end
  if self.activityEnded then
    Toast(textRes.WorldBoss.ErrorCode[7])
    return
  end
  if _G.PlayerIsInFight() then
    Toast(textRes.activity[379])
    return
  end
  local count = WorldBossMgr.Instance():GetChallengeCountLeft()
  if count < 1 then
    Toast(textRes.WorldBoss.ErrorCode[1])
    return
  end
  local roleRankInfo = WorldBossMgr.Instance():GetScoreRank()
  warn("[WorldBossMgr:TrySendFightReq] current occupationid and pre fightboss occupationid , rank, score:", GetHeroProp().occupation, roleRankInfo.occupationId, roleRankInfo.rank, roleRankInfo.score)
  if roleRankInfo.occupationId > 0 and roleRankInfo.rank > 0 and roleRankInfo.score > 0 and GetHeroProp().occupation ~= roleRankInfo.occupationId then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.WorldBoss[8], textRes.WorldBoss.CONFIRM_USE_NEW_OCCUP, function(id, tag)
      self:SendFightReq()
    end, nil)
    return
  end
  self:SendFightReq()
end
def.method().SendFightReq = function(self)
  local p = require("netio.protocol.mzm.gsp.bigboss.CStartFightReq").new()
  gmodule.network.sendProtocol(p)
  GameUtil.AddGlobalLateTimer(0.8, true, function()
    self:DestroyPanel()
  end)
end
def.static("table", "table").OnBuyChallengeCount = function(p1, p2)
  instance:UpdateCounts()
end
def.static("table", "table").OnRankListReceived = function(p1, p2)
end
return WorldBossPanel.Commit()

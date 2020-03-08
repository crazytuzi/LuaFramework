local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIDoudouGift = Lplus.Extend(ECPanelBase, "UIDoudouGift")
local def = UIDoudouGift.define
local instance
local DoudouGiftMgr = require("Main.WelcomeParty.DoudouGiftMgr")
local AchievementFinishInfo = require("Main.achievement.AchievementFinishInfo")
local AchievementGoalInfo = require("netio.protocol.mzm.gsp.achievement.AchievementGoalInfo")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local AchievementData = require("Main.achievement.AchievementData")
local GUIUtils = require("GUI.GUIUtils")
local const = constant.DouDouSongLiConsts
local txtConst = textRes.WelcomeParty
def.field("table")._uiGOs = nil
def.field("userdata").m_node = nil
def.field("table")._goalList = nil
def.field("table")._uiStatus = nil
def.static("=>", UIDoudouGift).Instance = function()
  if instance == nil then
    instance = UIDoudouGift()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiStatus = {}
  self._uiStatus.timer = 0
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, UIDoudouGift.OnAchievementGoaInfoChagnge)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GET_SCORE_AWARD, UIDoudouGift.OnAchievementScoreInfoChagnge)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, UIDoudouGift.OnAchievementGoaInfoChagnge)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GET_SCORE_AWARD, UIDoudouGift.OnAchievementScoreInfoChagnge)
  if self._uiStatus.timer ~= 0 then
    GameUtil.RemoveGlobalTimer(self._uiStatus.timerId)
    self._uiStatus.timer = 0
  end
  self.m_node = nil
  self._uiStatus = nil
  self._uiGOs = nil
  self._goalList = nil
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self.m_node = self.m_panel:FindDirect("Group_NewService")
    self:_updateUIGoldListInfo(0)
    self:_updateUIScoreAwardInfo()
    self:_updateUIActDate()
  else
    if self._uiStatus == nil then
      return
    end
    if self._uiStatus.timer ~= 0 then
      GameUtil.RemoveGlobalTimer(self._uiStatus.timerId)
      self._uiStatus.timer = 0
    end
  end
end
def.method().setLeftTime = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if self.m_node == nil then
    self.m_node = self.m_panel:FindDirect("Group_NewService")
  end
  local leftTiemStr = DoudouGiftMgr.Instance():getLeftTimeStr()
  local Label_Time = self.m_node:FindDirect("Label_Time")
  Label_Time:GetComponent("UILabel"):set_text(leftTiemStr)
end
def.method()._updateUIActDate = function(self)
  local lblTime = self.m_panel:FindDirect("Group_NewService/Label_Time")
  local startSrvTime = require("Main.Server.ServerModule").Instance():GetOpenServerStartDayTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local stblTime = AbsoluteTimer.GetServerTimeTable(startSrvTime)
  local etblTime = AbsoluteTimer.GetServerTimeTable(startSrvTime + (const.dayCount - 1) * 24 * 3600)
  GUIUtils.SetText(lblTime, txtConst[7]:format(stblTime.year, stblTime.month, stblTime.day, etblTime.year, etblTime.month, etblTime.day))
end
def.method("number")._updateUIGoldListInfo = function(self, idx)
  local doudouGiftMgr = DoudouGiftMgr.Instance()
  local goalList = doudouGiftMgr:GetGoalList()
  doudouGiftMgr:SortGoldList(goalList)
  self._goalList = goalList
  local Grid = self.m_node:FindDirect("Img_Bg/Scroll View/Grid")
  local uilist = Grid:GetComponent("UIList")
  uilist.itemCount = #goalList
  uilist:Resize()
  local awardObj
  for i, v in ipairs(goalList) do
    local curGoalInfo = doudouGiftMgr:GetGoalInfoByGoalId(v.id)
    local Img_ListBg = Grid:FindDirect("item_" .. i)
    local Label_TaskInfo = Img_ListBg:FindDirect("Label_TaskInfo")
    local Label_Title = Img_ListBg:FindDirect("Label_Title")
    local Btn_Get = Img_ListBg:FindDirect("Btn_Get")
    local Btn_Go = Img_ListBg:FindDirect("Btn_Go")
    local Img_GetIt = Img_ListBg:FindDirect("Img_GetIt")
    local Label_TaskNumber = Img_ListBg:FindDirect("Label_TaskNumber")
    local lblCredit = Img_ListBg:FindDirect("Label_Credit")
    lblCredit:GetComponent("UILabel"):set_text(v.point)
    Label_Title:GetComponent("UILabel"):set_text(v.title)
    Label_TaskInfo:GetComponent("UILabel"):set_text(v.goalDes)
    local finishStr = AchievementFinishInfo.getFinishInfoStr(v, curGoalInfo.parameters)
    Label_TaskNumber:GetComponent("UILabel"):set_text(finishStr)
    local UI_FX = Img_ListBg:FindDirect("UI_FX")
    if curGoalInfo.state == AchievementGoalInfo.ST_ON_GOING then
      Img_GetIt:SetActive(false)
      Btn_Get:SetActive(false)
      Btn_Go:SetActive(true)
      UI_FX:SetActive(false)
    elseif curGoalInfo.state == AchievementGoalInfo.ST_FINISHED then
      Img_GetIt:SetActive(false)
      Btn_Get:SetActive(true)
      Btn_Go:SetActive(false)
      UI_FX:SetActive(true)
    elseif curGoalInfo.state == AchievementGoalInfo.ST_HAND_UP then
      Img_GetIt:SetActive(true)
      Btn_Get:SetActive(false)
      Btn_Go:SetActive(false)
      UI_FX:SetActive(false)
    end
    local awardcfg = self:getAwardCfgByAwardId(v.fixAwardId)
    for k = 1, 3 do
      local itemInfo = awardcfg.itemList[k]
      local Img_Prize = Img_ListBg:FindDirect(string.format("Group_Icon/Img_BgIcon%d", k))
      if itemInfo then
        local Texture_Icon = Img_Prize:FindDirect("Texture_Icon"):GetComponent("UITexture")
        local Label_Num = Img_Prize:FindDirect("Label_Num")
        local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
        GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
        Label_Num:GetComponent("UILabel"):set_text(itemInfo.num)
      else
        Img_Prize:SetActive(false)
      end
    end
  end
end
def.method()._updateUIScoreAwardInfo = function(self)
  local Group_Slider = self.m_node:FindDirect("Group_Slider")
  local Group_Values = Group_Slider:FindDirect("Group_Values")
  local Group_Items = Group_Slider:FindDirect("Group_Items")
  local Img_BgSlider = Group_Slider:FindDirect("Img_BgSlider")
  local Label_Score = self.m_node:FindDirect("Label_Score")
  local doudouGiftMgr = DoudouGiftMgr.Instance()
  local curScore = doudouGiftMgr:GetCurScore()
  local showScore = curScore
  if showScore > const.maxScoreNum then
    showScore = const.maxScoreNum
  end
  Label_Score:GetComponent("UILabel"):set_text(showScore)
  local activityId = const.activityId
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  Img_BgSlider:GetComponent("UIProgressBar").value = curScore / const.maxScoreNum
  local activityScoreCfg = AchievementData.GetAchievementScoreActivityCfg(activityId)
  for i, v in ipairs(activityScoreCfg.scoreCfgIdList) do
    local scoreAwardCfg = AchievementData.GetAchievementScoreCfg(v)
    local key = string.format("%d_%d_%d", scoreAwardCfg.awardId, occupation.ALL, gender.ALL)
    local awardCfg = ItemUtils.GetGiftAwardCfg(key)
    local itemInfo = awardCfg.itemList[1]
    local Img_Item = Group_Items:FindDirect("item_score_" .. i)
    local lblNum = Img_Item:FindDirect("Label_Count")
    local icon = Img_Item:FindDirect("Texture_item_1")
    local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
    GUIUtils.SetTexture(icon, itemBase.icon)
    GUIUtils.SetText(lblNum, itemInfo.num)
    local score = scoreAwardCfg.score
    Group_Values:FindDirect("item_" .. i):GetComponent("UILabel"):set_text(score)
    local isGet = doudouGiftMgr:IsGetScoreAward(scoreAwardCfg.scoreIndexId)
    if isGet then
      GUIUtils.SetTextureEffect(icon:GetComponent("UITexture"), GUIUtils.Effect.Gray)
      GUIUtils.SetLightEffect(Img_Item, GUIUtils.Light.None)
    else
      Img_Item:SetActive(true)
      GUIUtils.SetTextureEffect(icon:GetComponent("UITexture"), GUIUtils.Effect.Normal)
      if curScore >= score then
        GUIUtils.SetLightEffect(Img_Item, GUIUtils.Light.Round)
      else
        GUIUtils.SetLightEffect(Img_Item, GUIUtils.Light.None)
      end
    end
  end
end
def.method("number", "=>", "table").getAwardCfgByAwardId = function(self, wardId)
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local key = string.format("%d_%d_%d", wardId, occupation.ALL, gender.ALL)
  return ItemUtils.GetGiftAwardCfg(key)
end
def.method().UpdateNotifyState = function(self)
  local doudouGiftMgr = DoudouGiftMgr.Instance()
  local tabId, index, isHaveAward = doudouGiftMgr:getCanGetAwardTabId()
  local isScoreAward = doudouGiftMgr:isOwnScoreAward()
  local isNotify = isHaveAward or isScoreAward
  local UIWelcomePartyBasic = require("Main.WelcomeParty.ui.UIWelcomePartyBasic")
  UIWelcomePartyBasic.Instance():SetTabNotify(UIWelcomePartyBasic.NodeId.DoudouGift, isNotify)
end
def.method("number").goOpertion = function(self, index)
  local goalCfg = self._goalList[index]
  local GrowUtils = require("Main.Grow.GrowUtils")
  local isEnter = GrowUtils.ApplyOperation(goalCfg.guideIndexId)
  if isEnter then
    local UIWelcomePartyBasic = require("Main.WelcomeParty.ui.UIWelcomePartyBasic")
    UIWelcomePartyBasic.Instance():DestroyPanel()
  end
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_CARVINAL_GIFT, 0)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("clickObj id", id)
  local strs = string.split(id, "_")
  if id == "Btn_Tip" then
    GUIUtils.ShowHoverTip(const.tipsId1, 0, 0)
  elseif id == "Btn_Go" then
    local parent = clickObj.parent
    local bstrs = string.split(parent.name, "_")
    self:goOpertion(tonumber(bstrs[2]))
  elseif id == "Btn_Get" then
    local parent = clickObj.parent
    local strs = string.split(parent.name, "_")
    self:getGoalAward(tonumber(strs[2]))
  elseif string.find(id, "Img_BgIcon") then
    local tstrs = string.split(clickObj.parent.parent.name, "_")
    local idx = tonumber(tstrs[2])
    local itemIdx = tonumber(string.sub(id, #"Img_BgIcon" + 1, #id))
    self:showGoalAwardItemTip(idx, itemIdx, clickObj)
  elseif string.find(id, "Texture_item_") then
    local strs = string.split(clickObj.parent.name, "_")
    if strs[1] == "item" and strs[2] == "score" and strs[3] == "Open" then
      self:getScoreAward(tonumber(strs[4]), clickObj)
    elseif strs[1] == "item" and strs[2] == "score" then
      self:getScoreAward(tonumber(strs[3]), clickObj)
    end
  end
end
def.method("number").getGoalAward = function(self, index)
  local goalCfg = self._goalList[index]
  local activityId = const.activityId
  local req = require("netio.protocol.mzm.gsp.achievement.CGetAchievementGoalAward").new(activityId, goalCfg.id)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number", "userdata").showGoalAwardItemTip = function(self, index, itemIdx, go)
  local goalCfg = self._goalList[index]
  local awardcfg = self:getAwardCfgByAwardId(goalCfg.fixAwardId)
  local itemInfo = awardcfg.itemList[itemIdx]
  local position = go:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  ItemTipsMgr.Instance():ShowBasicTips(itemInfo.itemId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, false)
end
def.method("number", "userdata").getScoreAward = function(self, index, obj)
  local activityId = const.activityId
  local activityScoreCfg = AchievementData.GetAchievementScoreActivityCfg(activityId)
  local v = activityScoreCfg.scoreCfgIdList[index]
  local scoreAwardCfg = AchievementData.GetAchievementScoreCfg(v)
  local score = scoreAwardCfg.score
  local isGet = DoudouGiftMgr.Instance():IsGetScoreAward(scoreAwardCfg.scoreIndexId)
  local curScore = DoudouGiftMgr.Instance():GetCurScore()
  if not isGet and score <= curScore then
    local req = require("netio.protocol.mzm.gsp.achievement.CGetAchievementScoreAward").new(activityId, scoreAwardCfg.scoreIndexId)
    gmodule.network.sendProtocol(req)
  else
    local ScoreAwardTips = require("Main.Award.ui.ScoreAwardTips")
    local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
    local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
    local key = string.format("%d_%d_%d", scoreAwardCfg.awardId, occupation.ALL, gender.ALL)
    local awardCfg = ItemUtils.GetGiftAwardCfg(key)
    local itemInfo = awardCfg.itemList[1]
    local position = obj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = obj:GetComponent("UIWidget")
    if itemInfo and itemInfo.itemId > 0 then
      ItemTipsMgr.Instance():ShowBasicTips(itemInfo.itemId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, false)
    end
  end
end
def.static("table", "table").OnAchievementGoaInfoChagnge = function(p1, p2)
  if instance and p1[1] == const.activityId then
    instance:_updateUIGoldListInfo(0)
    instance:_updateUIScoreAwardInfo()
    instance:UpdateNotifyState()
  end
end
def.static("table", "table").OnAchievementScoreInfoChagnge = function(p1, p2)
  if instance and p1[1] == const.activityId then
    instance:_updateUIScoreAwardInfo()
    instance:UpdateNotifyState()
  end
end
return UIDoudouGift.Commit()

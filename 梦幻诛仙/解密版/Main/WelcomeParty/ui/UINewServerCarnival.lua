local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UINewServerCarnival = Lplus.Extend(ECPanelBase, "UINewServerCarnival")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local AchievementData = require("Main.achievement.AchievementData")
local achievementData = AchievementData.Instance()
local NewServerAwardMgr = require("Main.Award.mgr.NewServerAwardMgr")
local newServerAwardMgr = NewServerAwardMgr.Instance()
local AchievementFinishInfo = require("Main.achievement.AchievementFinishInfo")
local AchievementGoalInfo = require("netio.protocol.mzm.gsp.achievement.AchievementGoalInfo")
local def = UINewServerCarnival.define
local instance
def.field("userdata").m_node = nil
def.field("table").curGoalList = nil
def.field("number").curTabIndex = 1
def.field("number").timerId = 0
def.static("=>", UINewServerCarnival).Instance = function()
  if instance == nil then
    instance = UINewServerCarnival()
  end
  return instance
end
def.override().OnCreate = function(self)
  warn("-------UINewServerCarnival OnCreate")
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, UINewServerCarnival.OnAchievementGoaInfoChagnge)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GET_SCORE_AWARD, UINewServerCarnival.OnAchievementScoreInfoChagnge)
end
def.override().OnDestroy = function(self)
  warn("-------UINewServerCarnival OnDestroy")
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, UINewServerCarnival.OnAchievementGoaInfoChagnge)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GET_SCORE_AWARD, UINewServerCarnival.OnAchievementScoreInfoChagnge)
end
def.static("table", "table").OnAchievementGoaInfoChagnge = function(p1, p2)
  warn("-------OnAchievementGoaInfoChagnge:", p1[1], p1[1] == constant.CCarnivalConsts.carnivalActivityId)
  if instance and p1[1] == constant.CCarnivalConsts.carnivalActivityId then
    instance:setGoalListInfo(instance.curTabIndex)
    instance:setScoreAwardInfo()
    instance:setTabInfo()
    instance:UpdateNotifyState()
  end
end
def.static("table", "table").OnAchievementScoreInfoChagnge = function(p1, p2)
  if instance and p1[1] == constant.CCarnivalConsts.carnivalActivityId then
    instance:setScoreAwardInfo()
    instance:UpdateNotifyState()
  end
end
def.method().UpdateNotifyState = function(self)
  local tabId, index, isHaveAward = newServerAwardMgr:getCanGetAwardTabId()
  local isScoreAward = newServerAwardMgr:isOwnScoreAward()
  local isNotify = isHaveAward or isScoreAward
  local UIWelcomePartyBasic = require("Main.WelcomeParty.ui.UIWelcomePartyBasic")
  UIWelcomePartyBasic.Instance():SetTabNotify(UIWelcomePartyBasic.NodeId.Carnival, isNotify)
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self.m_node = self.m_panel:FindDirect("Group_NewService")
    local tabId, index, isAward = newServerAwardMgr:getCanGetAwardTabId()
    if not isAward then
      tabId = newServerAwardMgr:getCanSelectedTabId()
    end
    self:selectedTab(tabId)
    self:setScoreAwardInfo()
    self:setTabInfo()
    if self.timerId == 0 then
      self.timerId = GameUtil.AddGlobalTimer(60, false, function()
        self:setLeftTime()
      end)
    end
  else
    self.curTabIndex = 1
    self.curGoalList = nil
    if self.timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.timerId)
      self.timerId = 0
    end
    self.m_node = nil
  end
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_NEW_CARVINAL_SERVICE_PANEL, 0)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  local strs = string.split(id, "_")
  if id == "Btn_Get" then
    local parent = obj.parent
    local strs = string.split(parent.name, "_")
    self:getGoalAward(tonumber(strs[2]))
  elseif id == "Btn_Go" then
    local parent = obj.parent
    local strs = string.split(parent.name, "_")
    self:goOpertion(tonumber(strs[2]))
  elseif id == "Btn_Tip" then
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(constant.CCarnivalConsts.tipsId1)
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
  elseif strs[1] == "Btn" then
    local openTabNum = newServerAwardMgr:getCreateRoleDayNum()
    local index = tonumber(strs[2])
    if openTabNum >= index then
      self:selectedTab(index)
    elseif openTabNum + 1 == index then
      Toast(textRes.activity[382])
    else
      Toast(textRes.activity[381])
    end
  elseif strs[1] == "Img" and strs[2] == "Prize" then
    local parent = obj.parent
    local itemStrs = string.split(parent.name, "_")
    self:showGoalAwardItemTip(tonumber(itemStrs[2]), tonumber(strs[3]), obj)
  elseif strs[1] == "item" and strs[2] == "score" and strs[3] == "Open" then
    self:getScoreAward(tonumber(strs[4]), obj)
  else
    if strs[1] == "item" and strs[2] == "score" then
      self:getScoreAward(tonumber(strs[3]), obj)
    else
    end
  end
end
def.method("number", "number", "userdata").showGoalAwardItemTip = function(self, index, itemIdx, go)
  local goalCfg = self.curGoalList[index]
  local awardcfg = self:getAwardCfgByAwardId(goalCfg.fixAwardId)
  local itemInfo = awardcfg.itemList[itemIdx]
  local position = go:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  ItemTipsMgr.Instance():ShowBasicTips(itemInfo.itemId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, false)
end
def.method("number").goOpertion = function(self, index)
  local goalCfg = self.curGoalList[index]
  local GrowUtils = require("Main.Grow.GrowUtils")
  local isEnter = GrowUtils.ApplyOperation(goalCfg.guideIndexId)
  if isEnter then
    local UIWelcomePartyBasic = require("Main.WelcomeParty.ui.UIWelcomePartyBasic")
    UIWelcomePartyBasic.Instance():DestroyPanel()
  end
end
def.method("number").getGoalAward = function(self, index)
  local goalCfg = self.curGoalList[index]
  local activityId = constant.CCarnivalConsts.carnivalActivityId
  local req = require("netio.protocol.mzm.gsp.achievement.CGetAchievementGoalAward").new(activityId, goalCfg.id)
  gmodule.network.sendProtocol(req)
end
def.method("number", "userdata").getScoreAward = function(self, index, obj)
  local activityId = constant.CCarnivalConsts.carnivalActivityId
  local activityScoreCfg = AchievementData.GetAchievementScoreActivityCfg(activityId)
  local v = activityScoreCfg.scoreCfgIdList[index]
  local scoreAwardCfg = AchievementData.GetAchievementScoreCfg(v)
  local score = scoreAwardCfg.score
  local isGet = newServerAwardMgr:isGetScoreAward(scoreAwardCfg.scoreIndexId)
  local curScore = newServerAwardMgr:getCurScore()
  if not isGet and score <= curScore then
    local activityId = constant.CCarnivalConsts.carnivalActivityId
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
def.method("number").selectedTab = function(self, index)
  if self.curTabIndex > 0 then
    local Btn = self.m_node:FindDirect("Btn_" .. self.curTabIndex)
    local Img_Selected = Btn:FindDirect("Img_Selected")
    Img_Selected:SetActive(false)
  end
  local Btn = self.m_node:FindDirect("Btn_" .. index)
  local Img_Selected = Btn:FindDirect("Img_Selected")
  Img_Selected:SetActive(true)
  self:setGoalListInfo(index)
  self.curTabIndex = index
end
def.method().setTabInfo = function(self)
  local const = constant.CCarnivalConsts
  local tabNames = {
    const.firstChapterName,
    const.secondChapterName,
    const.thirdChapterName,
    const.fourChapterName,
    const.fiveChapterName
  }
  local openTabNum = newServerAwardMgr:getCreateRoleDayNum()
  for i, v in ipairs(tabNames) do
    local Btn = self.m_node:FindDirect("Btn_" .. i)
    local Label = Btn:FindDirect("Label")
    Label:GetComponent("UILabel"):set_text(v)
    local Img_Selected = Btn:FindDirect("Img_Selected")
    Img_Selected:SetActive(i == self.curTabIndex)
    local isAward = newServerAwardMgr:isHaveAwardByTabId(i)
    local Img_Grey = Btn:FindDirect("Img_Grey")
    local Img_Red = Btn:FindDirect("Img_Red")
    Img_Red:SetActive(isAward)
    if i <= openTabNum then
      Img_Grey:SetActive(false)
    else
      Img_Grey:SetActive(true)
    end
  end
  self:setLeftTime()
end
def.method().setLeftTime = function(self)
  local leftTiemStr = newServerAwardMgr:getLeftTimeStr()
  local Label_Time = self.m_node:FindDirect("Label_Time")
  Label_Time:GetComponent("UILabel"):set_text(leftTiemStr)
end
def.method("number", "=>", "table").getAwardCfgByAwardId = function(self, wardId)
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local key = string.format("%d_%d_%d", wardId, occupation.ALL, gender.ALL)
  return ItemUtils.GetGiftAwardCfg(key)
end
def.method("number").setGoalListInfo = function(self, index)
  local goalList = newServerAwardMgr:getGoalListByTabId(index)
  newServerAwardMgr:sortGoalList(goalList)
  self.curGoalList = goalList
  local Grid = self.m_node:FindDirect("Img_Bg/Scroll View/Grid")
  local uilist = Grid:GetComponent("UIList")
  uilist.itemCount = #goalList
  uilist:Resize()
  local awardObj
  for i, v in ipairs(goalList) do
    local curGoalInfo = newServerAwardMgr:getGoalInfoByGoalId(v.id)
    local Img_ListBg = Grid:FindDirect("item_" .. i)
    local Label_TaskInfo = Img_ListBg:FindDirect("Label_TaskInfo")
    local Label_Title = Img_ListBg:FindDirect("Label_Title")
    local Btn_Get = Img_ListBg:FindDirect("Btn_Get")
    local Btn_Go = Img_ListBg:FindDirect("Btn_Go")
    local Img_GetIt = Img_ListBg:FindDirect("Img_GetIt")
    local Label_TaskNumber = Img_ListBg:FindDirect("Label_TaskNumber")
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
      local Img_Prize = Img_ListBg:FindDirect(string.format("Img_Prize_%d", k, i))
      if itemInfo then
        local Texture_Icon = Img_Prize:FindDirect("Img_PrizeIcon"):GetComponent("UITexture")
        local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
        GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
      else
        Img_Prize:SetActive(false)
      end
    end
  end
end
def.method().setScoreAwardInfo = function(self)
  local Group_Slider = self.m_node:FindDirect("Group_Slider")
  local Group_Values = Group_Slider:FindDirect("Group_Values")
  local Group_Items = Group_Slider:FindDirect("Group_Items")
  local Img_BgSlider = Group_Slider:FindDirect("Img_BgSlider")
  local Label_Score = self.m_node:FindDirect("Label_Score")
  local curScore = newServerAwardMgr:getCurScore()
  local showScore = curScore
  if showScore > constant.CCarnivalConsts.maxScoreNum then
    showScore = constant.CCarnivalConsts.maxScoreNum
  end
  Label_Score:GetComponent("UILabel"):set_text(showScore)
  local activityId = constant.CCarnivalConsts.carnivalActivityId
  Img_BgSlider:GetComponent("UIProgressBar").value = curScore / constant.CCarnivalConsts.maxScoreNum
  local activityScoreCfg = AchievementData.GetAchievementScoreActivityCfg(activityId)
  for i, v in ipairs(activityScoreCfg.scoreCfgIdList) do
    local scoreAwardCfg = AchievementData.GetAchievementScoreCfg(v)
    local Img_Item = Group_Items:FindDirect("item_score_" .. i)
    local item_score_Open = Group_Items:FindDirect("item_score_Open_" .. i)
    local score = scoreAwardCfg.score
    Group_Values:FindDirect("item_" .. i):GetComponent("UILabel"):set_text(score)
    local isGet = newServerAwardMgr:isGetScoreAward(scoreAwardCfg.scoreIndexId)
    local Img_Sprite = Img_Item:GetComponent("UITexture")
    if isGet then
      GUIUtils.SetLightEffect(Img_Item, GUIUtils.Light.None)
      Img_Sprite:set_color(Color.gray)
      Img_Item:SetActive(false)
      item_score_Open:SetActive(true)
    else
      Img_Item:SetActive(true)
      item_score_Open:SetActive(false)
      if curScore >= score then
        GUIUtils.SetLightEffect(Img_Item, GUIUtils.Light.Round)
      else
        GUIUtils.SetLightEffect(Img_Item, GUIUtils.Light.None)
      end
      Img_Sprite:set_color(Color.white)
    end
  end
end
return UINewServerCarnival.Commit()

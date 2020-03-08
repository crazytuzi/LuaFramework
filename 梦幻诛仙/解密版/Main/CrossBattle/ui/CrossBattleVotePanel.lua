local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleVotePanel = Lplus.Extend(ECPanelBase, "CrossBattleVotePanel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local CrossBattleVoteRankType = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleVoteRankType")
local GUIUtils = require("GUI.GUIUtils")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local def = CrossBattleVotePanel.define
def.const("number").ALL_STAGE_NUM = 6
def.field("number").curRankType = 0
def.field("number").curPage = 1
def.field("userdata").selectedCorpsId = nil
local instance
def.static("=>", CrossBattleVotePanel).Instance = function()
  if instance == nil then
    instance = CrossBattleVotePanel()
  end
  return instance
end
def.method("userdata").ShowPanelByCorpsId = function(self, corpsId)
  if self:IsShow() then
    self:getCrossBattleVoteRankByCorpsId(corpsId)
    return
  end
  self.selectedCorpsId = corpsId
  self:ShowPanel()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_VOTE, 1)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setCrossBattleStaus()
    self.curRankType = CrossBattleVoteRankType.TYPE_VOTE_NUM
    self:setCrossBattleRankInfo()
    if self.selectedCorpsId then
      self:getCrossBattleVoteRankByCorpsId(self.selectedCorpsId)
    else
      self:getCrossBattleVoteRank(1)
    end
  else
    self.selectedCorpsId = nil
  end
end
def.override().OnCreate = function(self)
  local Label_Tips02 = self.m_panel:FindDirect("Img_Bg0/Img_BgTitle/Label_Tips02")
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local param1 = crossBattleCfg.vote_stage_direct_promotion_corps_num + 1
  local param2 = crossBattleCfg.round_robin_max_corps_num + crossBattleCfg.vote_stage_direct_promotion_corps_num
  local param3 = crossBattleCfg.round_robin_stage_promotion_corps_num
  Label_Tips02:GetComponent("UILabel"):set_text(string.format(textRes.CrossBattle[42], param1, param2, param3))
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Rank_Info_Change, CrossBattleVotePanel.OnCrossBattleRankInfoChange)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Vote_Success, CrossBattleVotePanel.OnCrossBattleRankInfoChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Rank_Info_Change, CrossBattleVotePanel.OnCrossBattleRankInfoChange)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Vote_Success, CrossBattleVotePanel.OnCrossBattleRankInfoChange)
end
def.static("table", "table").OnCrossBattleRankInfoChange = function(p1, p2)
  if instance.m_panel then
    instance:setCrossBattleRankInfo()
    instance:setCrossBattleStaus()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------CrossBattleVotePanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Next" then
    local startPos = 1
    local rankList = CrossBattleInterface.Instance().crossBattleRankList
    if rankList then
      local rankInfo = rankList[#rankList]
      if rankInfo then
        startPos = rankInfo.rank + 1
      end
    end
    self:getCrossBattleVoteRank(startPos)
  elseif id == "Btn_Back" then
    local startPos = 1
    local rankList = CrossBattleInterface.Instance().crossBattleRankList
    if rankList then
      local rankInfo = rankList[1]
      if rankInfo then
        if rankInfo.rank == 1 then
          return
        end
        local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
        startPos = rankInfo.rank - crossBattleCfg.vote_stage_rank_page_num
        if startPos <= 0 then
          startPos = 1
        end
      end
    end
    self:getCrossBattleVoteRank(startPos)
  elseif id == "Btn_Tickets" then
    local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
    if curStage ~= CrossBattleActivityStage.STAGE_VOTE then
      Toast(textRes.CrossBattle[25])
      return
    end
    if not CrossBattleInterface.Instance():isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_VOTE) then
      Toast(textRes.CrossBattle[39])
      return
    end
    if not CorpsInterface.HasCorps() then
      Toast(textRes.CrossBattle[53])
      return
    end
    local time = _G.GetServerTime() - CrossBattleInterface.Instance().canvass_timestamp
    local constTime = constant.CrossBattleConsts.CANVASS_COOLDOWN_TIME_IN_SECOND
    if time >= constTime then
      self:canvassingClick()
    else
      local leftTime = constTime - time
      if leftTime > 0 then
        Toast(string.format(textRes.CrossBattle[48], leftTime))
      end
    end
  elseif id == "Group_Sort01" then
    self.curRankType = CrossBattleVoteRankType.TYPE_AVERAGE_FIGHT_VALUE
    self:getCrossBattleVoteRank(1)
  elseif id == "Group_Sort02" then
    self.curRankType = CrossBattleVoteRankType.TYPE_VOTE_NUM
    self:getCrossBattleVoteRank(1)
  elseif id == "Btn_MySite" then
    if not CorpsInterface.HasCorps() then
      Toast(textRes.CrossBattle[53])
      return
    end
    local crossBattleInterface = CrossBattleInterface.Instance()
    if crossBattleInterface:isApplyCrossBattle() then
      local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
      if myCorpsInfo == nil or myCorpsInfo.corpsId == nil then
        warn("-----Btn_MySite myCorpsId is nil")
        return
      end
      local myCorpsId = myCorpsInfo.corpsId
      self:getCrossBattleVoteRankByCorpsId(myCorpsId)
    else
      Toast(textRes.CrossBattle[9])
    end
  elseif id == "Btn_Tips" then
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    local CommonDescDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(crossBattleCfg.vote_stage_tips_id)
    CommonDescDlg.ShowCommonTip(tipContent, {x = 0, y = 0})
  elseif strs[1] == "Btn" and strs[2] == "Vote" then
    local idx = tonumber(strs[3])
    if idx then
      local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
      if curStage ~= CrossBattleActivityStage.STAGE_VOTE then
        Toast(textRes.CrossBattle[25])
        return
      end
      local leftTimes = CrossBattleInterface.Instance():getLeftVoteTimes()
      if leftTimes <= 0 then
        Toast(textRes.CrossBattle[7])
        return
      end
      local rankList = CrossBattleInterface.Instance().crossBattleRankList
      local rankInfo = rankList[idx]
      if rankInfo then
        if not CrossBattleInterface.Instance():isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_VOTE) then
          Toast(textRes.CrossBattle[39])
          return
        end
        local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
        local myHero = require("Main.Hero.HeroModule").Instance()
        local heroProp = myHero:GetHeroProp()
        if heroProp then
          local myLevel = heroProp.level
          if myLevel < crossBattleCfg.vote_level_limit then
            Toast(string.format(textRes.CrossBattle[43], crossBattleCfg.vote_level_limit))
            return
          end
        end
        local p = require("netio.protocol.mzm.gsp.crossbattle.CVoteInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, rankInfo.corps_brief_info.corpsId)
        gmodule.network.sendProtocol(p)
        warn("------vote:", idx, rankInfo.corps_brief_info.corpsId)
      end
    end
  elseif strs[1] == "Btn" and strs[2] == "Detail" then
    local idx = tonumber(strs[3])
    if idx then
      local rankList = CrossBattleInterface.Instance().crossBattleRankList
      local rankInfo = rankList[idx]
      if rankInfo then
        CorpsInterface.CheckCorpsInfo(rankInfo.corps_brief_info.corpsId)
      end
    end
  end
end
def.method().canvassingClick = function()
  local crossBattleInterface = CrossBattleInterface.Instance()
  if crossBattleInterface:isApplyCrossBattle() then
    do
      local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
      if myCorpsInfo == nil or myCorpsInfo.corpsId == nil then
        warn("-----myCorpsId is nil")
        return
      end
      local myCorpsId = myCorpsInfo.corpsId
      local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
      local trumpetCfg = require("Main.Chat.Trumpet.TrumpetMgr").Instance():GetTrumpetCfgById(crossBattleCfg.canvass_trumpet_cfg_id)
      if trumpetCfg == nil then
        return
      end
      local labaId = trumpetCfg.itemid
      local labaNum = 1
      local title = textRes.CrossBattle[11]
      local desc = textRes.CrossBattle[10]
      require("Main.Item.ItemConsumeHelper").Instance():ShowItemConsume(title, desc, labaId, labaNum, function(result)
        warn("---------------result:", result)
        if result >= 0 then
          local cname = string.format("{corpscheck:%s,%s}", myCorpsId:tostring(), myCorpsInfo.name)
          local link = string.format("{crossbattle:%s,%s}", myCorpsId:tostring(), textRes.CrossBattle[13])
          local content = string.format(textRes.CrossBattle[12], cname, link)
          local textOctets = require("netio.Octets").rawFromString(content)
          local p = require("netio.protocol.mzm.gsp.crossbattle.CCanvassInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, myCorpsId, textOctets)
          gmodule.network.sendProtocol(p)
          crossBattleInterface.canvass_timestamp = _G.GetServerTime()
          warn("-----------CCanvassInCrossBattleReq:", content, textOctets)
        end
      end)
    end
  else
    Toast(textRes.CrossBattle[9])
  end
end
def.method("number").getCrossBattleVoteRank = function(self, startPos)
  local CGetCrossBattleVoteRankReq = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleVoteRankReq")
  local access_type = CGetCrossBattleVoteRankReq.ACCESS_TYPE_POSITION
  local corpsId = Int64.new(0)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local p = CGetCrossBattleVoteRankReq.new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, self.curRankType, access_type, startPos, corpsId, crossBattleCfg.vote_stage_rank_page_num)
  gmodule.network.sendProtocol(p)
  warn("--------send crossBattleVoteRank:", startPos, crossBattleCfg.vote_stage_rank_page_num)
end
def.method("userdata").getCrossBattleVoteRankByCorpsId = function(self, corpsId)
  local CGetCrossBattleVoteRankReq = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleVoteRankReq")
  local access_type = CGetCrossBattleVoteRankReq.ACCESS_TYPE_CORPS_ID
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  self.selectedCorpsId = corpsId
  local p = CGetCrossBattleVoteRankReq.new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, self.curRankType, access_type, 0, corpsId, crossBattleCfg.vote_stage_rank_page_num)
  gmodule.network.sendProtocol(p)
  warn("--------send crossBattleVoteRank corpsId:", corpsId)
end
def.method().setCrossBattleStaus = function(self)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  local Group_Rank01 = self.m_panel:FindDirect("Img_Bg0/Group_Rank01")
  local Group_Rank02 = self.m_panel:FindDirect("Img_Bg0/Group_Rank02")
  if curStage == CrossBattleActivityStage.STAGE_VOTE then
    Group_Rank01:SetActive(true)
    Group_Rank02:SetActive(false)
    local _, endTime = crossBattleInterface:getCrossBattleStageTime(curStage)
    local leftTime = endTime - _G.GetServerTime()
    local days = 0
    local hours = 0
    if leftTime > 0 then
      days = math.floor(leftTime / 86400)
      hours = math.floor((leftTime - days * 86400) / 3600)
    end
    local Label_DateNum = Group_Rank01:FindDirect("Group_Date/Label_DateNum")
    Label_DateNum:GetComponent("UILabel"):set_text(string.format(textRes.CrossBattle[6], days, hours))
    local Label_VoteNum = Group_Rank01:FindDirect("Group_Vote/Label_VoteNum")
    Label_VoteNum:GetComponent("UILabel"):set_text(crossBattleInterface:getLeftVoteTimes())
  else
    Group_Rank01:SetActive(false)
    Group_Rank02:SetActive(true)
    local Label_VoteNum = Group_Rank02:FindDirect("Group_Vote/Label_VoteNum")
    local Label_VTNum = Group_Rank02:FindDirect("Group_VT/Label_VTNum")
    local myRankInfo = crossBattleInterface.myRankInfo
    if myRankInfo then
      Label_VoteNum:GetComponent("UILabel"):set_text(myRankInfo.rank)
      Label_VTNum:GetComponent("UILabel"):set_text(myRankInfo.vote_num)
    else
      Label_VoteNum:GetComponent("UILabel"):set_text(textRes.CrossBattle[16])
      Label_VTNum:GetComponent("UILabel"):set_text(0)
    end
  end
end
def.method().setCrossBattleRankInfo = function(self)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local rankList = crossBattleInterface.crossBattleRankList
  if rankList == nil then
    rankList = {}
  end
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  local isVoteStage = curStage == CrossBattleActivityStage.STAGE_VOTE
  local Group_List = self.m_panel:FindDirect("Img_Bg0/Group_RankList/Group_List")
  local uiList = Group_List:GetComponent("UIList")
  uiList.itemCount = #rankList
  uiList:Resize()
  local rankInfo = rankList[1]
  local page = 1
  if rankInfo then
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    page = math.floor(rankInfo.rank / crossBattleCfg.vote_stage_rank_page_num) + 1
  end
  local Label_Page = self.m_panel:FindDirect("Img_Bg0/Group_Page/Img_BgPage/Label_Page")
  Label_Page:GetComponent("UILabel"):set_text(page)
  local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
  local myCorpsId
  if myCorpsInfo and myCorpsInfo.corpsId then
    myCorpsId = myCorpsInfo.corpsId
  end
  for i, v in ipairs(rankList) do
    local RankBaby = Group_List:FindDirect("RankBaby_" .. i)
    local Img_MingCi = RankBaby:FindDirect("Img_MingCi_" .. i)
    local Label_Ranking = RankBaby:FindDirect("Label_Ranking_" .. i)
    local Label_TeamName = RankBaby:FindDirect("Label_TeamName_" .. i)
    local Label_FightPoint = RankBaby:FindDirect("Label_FightPoint_" .. i)
    local Label_Num = RankBaby:FindDirect("Label_Num_" .. i)
    local Group_Rank01 = RankBaby:FindDirect("Group_Rank01_" .. i)
    local Group_Rank02 = RankBaby:FindDirect("Group_Rank02_" .. i)
    local Img_Bg1 = RankBaby:FindDirect("Img_Bg1_" .. i)
    local Img_Bg2 = RankBaby:FindDirect("Img_Bg2_" .. i)
    local Img_BgMine = RankBaby:FindDirect("Img_BgMine_" .. i)
    local Img_Badge = RankBaby:FindDirect("Img_Badge_" .. i)
    Group_Rank01:SetActive(isVoteStage)
    Group_Rank02:SetActive(not isVoteStage)
    local cropsInfo = v.corps_brief_info
    if v.rank <= 3 then
      Img_MingCi:SetActive(true)
      Label_Ranking:GetComponent("UILabel"):set_text("")
      Img_MingCi:GetComponent("UISprite"):set_spriteName(string.format("Img_Num%d", v.rank))
    else
      Img_MingCi:SetActive(false)
      Label_Ranking:GetComponent("UILabel"):set_text(v.rank)
    end
    if self.selectedCorpsId and cropsInfo.corpsId:eq(self.selectedCorpsId) then
      Img_BgMine:SetActive(true)
      Img_Bg1:SetActive(false)
      Img_Bg2:SetActive(false)
    else
      Img_BgMine:SetActive(false)
      if i % 2 == 0 then
        Img_Bg1:SetActive(true)
        Img_Bg2:SetActive(false)
      else
        Img_Bg1:SetActive(false)
        Img_Bg2:SetActive(true)
      end
    end
    Label_TeamName:GetComponent("UILabel"):set_text(GetStringFromOcts(cropsInfo.name))
    local fightValue = v.average_fight_value
    if fightValue % 1 > 0 then
      fightValue = string.format("%.1f", fightValue)
    end
    Label_FightPoint:GetComponent("UILabel"):set_text(fightValue)
    Label_Num:GetComponent("UILabel"):set_text(v.vote_num)
    local Badge_Texture = Img_Badge:GetComponent("UITexture")
    local badgeCfg = CorpsUtils.GetCorpsBadgeCfg(cropsInfo.corpsBadgeId)
    if badgeCfg then
      GUIUtils.FillIcon(Badge_Texture, badgeCfg.iconId)
    end
  end
end
CrossBattleVotePanel.Commit()
return CrossBattleVotePanel

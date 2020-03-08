local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIPetsArenaMain = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = UIPetsArenaMain
local def = Cls.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local txtConst = textRes.Pet.PetsArena
local const = constant.CPetArenaConst
local PetsArenaMgr = require("Main.Pet.PetsArena.PetsArenaMgr")
local ItemModule = require("Main.Item.ItemModule")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local PetTeamUtils = require("Main.PetTeam.PetTeamUtils")
local PetsArenaUtils = require("Main.Pet.PetsArena.PetsArenaUtils")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._selfPetsTeamInfo = nil
def.field("table")._opponentsList = nil
def.field("table")._pet2ModelMap = nil
def.const("table").BTN_STATE = {
  STATE_NONE,
  STATE_BUY = 1,
  STATE_REFRESH = 2,
  STATE_CD = 3
}
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().initUI = function(self)
  local uiGOs = self._uiGOs
  uiGOs.lblTryTimes = self.m_panel:FindDirect("Img_Bg/Group_Times/Label_Times")
  uiGOs.groupBuy = self.m_panel:FindDirect("Img_Bg/Group_Times/Group_Buy")
  uiGOs.groupMoney = uiGOs.groupBuy:FindDirect("Img_Money")
  uiGOs.lblRankVal = self.m_panel:FindDirect("Img_Bg/Group_Rank/Label_RankNum")
  uiGOs.imgRankNull = self.m_panel:FindDirect("Img_Bg/Group_Rank/Img_RankNull")
  uiGOs.imgRankNull:SetActive(false)
  uiGOs.imgRankOff = self.m_panel:FindDirect("Img_Bg/Group_Rank/Img_RankOff")
  uiGOs.imgRankOff:SetActive(false)
  uiGOs.groupOwnScore = self.m_panel:FindDirect("Img_Bg/Group_Jing/Group_Own")
  uiGOs.groupTodayScore = self.m_panel:FindDirect("Img_Bg/Group_Jing/Group_Today")
  uiGOs.lblPetsTeamScore = self.m_panel:FindDirect("Img_Bg/Group_TeamPoint/Label_TeamPointNum")
  uiGOs.texTeamLaw = self.m_panel:FindDirect("Img_Bg/Group_FomationEdit/Texture_Fomation")
  uiGOs.lblBuyNum = uiGOs.groupBuy:FindDirect("Label")
  uiGOs.btnRankList = self.m_panel:FindDirect("Img_Bg/Group_Btn/Btn_Rank")
  uiGOs.btnRankList:SetActive(PetsArenaMgr.IsRanklistOpen())
  local groupFront = self.m_panel:FindDirect("Img_Bg/Group_Front")
  uiGOs.formation = {}
  for i = 1, PetsArenaMgr.MAX_MODEL do
    table.insert(uiGOs.formation, groupFront:FindDirect("Group_Site_" .. i))
  end
  self:updateUILeftTop()
  self:updateChallengerList()
end
def.method().updateUILeftTop = function(self)
  local uiGOs = self._uiGOs
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local currencyData = CurrencyFactory.Create(MoneyType.YUANBAO)
  local petsTeamInfo = self._selfPetsTeamInfo or {}
  local leftTryTimes = petsTeamInfo.buy_count and const.FREE_CHALLENGE_COUNT + petsTeamInfo.buy_count - petsTeamInfo.challenge_count or 0
  local maxTryTimes = petsTeamInfo.buy_count and petsTeamInfo.buy_count + const.FREE_CHALLENGE_COUNT or const.FREE_CHALLENGE_COUNT
  GUIUtils.SetText(uiGOs.lblTryTimes, txtConst[11]:format(leftTryTimes, maxTryTimes))
  local curPrice = petsTeamInfo.buy_count and const.FIRST_BUY_YUANBAO_PRICE + const.YUANBAO_PRICE_ADD_NUM * petsTeamInfo.buy_count or txtConst[1]
  GUIUtils.SetText(uiGOs.groupMoney:FindDirect("Label_Num"), curPrice)
  GUIUtils.SetSprite(uiGOs.groupMoney:FindDirect("Img_Icon"), currencyData:GetSpriteName())
  GUIUtils.SetText(uiGOs.lblRankVal, petsTeamInfo.rank or txtConst[1])
  local defenseTeamIdx = PetTeamData.Instance():GetDefTeamIdx()
  if petsTeamInfo.rank then
    uiGOs.imgRankOff:SetActive(defenseTeamIdx > 0 and 1 > petsTeamInfo.rank)
    uiGOs.imgRankNull:SetActive(defenseTeamIdx < 1)
    uiGOs.lblRankVal:SetActive(defenseTeamIdx > 0 and 0 < petsTeamInfo.rank)
  end
  local value = ItemModule.Instance():GetCredits(TokenType.PET_FIGHT_SCORE) or Int64.new(0)
  GUIUtils.SetText(uiGOs.groupOwnScore:FindDirect("Label_HaveNum"), value:tostring() or txtConst[1])
  GUIUtils.SetText(uiGOs.groupTodayScore:FindDirect("Label_TodayNum"), petsTeamInfo.today_point or txtConst[1])
  local bShow = petsTeamInfo.challenge_count and leftTryTimes < 1 or false
  uiGOs.lblBuyNum:SetActive(bShow)
  GUIUtils.SetText(uiGOs.lblBuyNum, txtConst[2]:format(petsTeamInfo.buy_count and const.MAX_BUY_COUNT - petsTeamInfo.buy_count or txtConst[1]))
  uiGOs.groupMoney:SetActive(bShow)
  local lblBuy = uiGOs.groupBuy:FindDirect("Btn_Buy/Label")
  if uiGOs.timer then
    _G.GameUtil.RemoveGlobalTimer(uiGOs.timer)
    uiGOs.timer = 0
  end
  if petsTeamInfo.refresh_time and 0 < petsTeamInfo.refresh_time then
    do
      local leftTime = const.REFRESH_CD - _G.GetServerTime() + petsTeamInfo.refresh_time
      if leftTime < 1 then
        if bShow then
          GUIUtils.SetText(lblBuy, txtConst[5])
          self._uiStatus.btnState = Cls.BTN_STATE.STATE_BUY
        else
          GUIUtils.SetText(lblBuy, txtConst[6])
          self._uiStatus.btnState = Cls.BTN_STATE.STATE_REFRESH
        end
        return
      end
      GUIUtils.SetText(lblBuy, txtConst[7]:format(math.floor(leftTime / 60), math.floor(leftTime % 60)))
      self._uiStatus.btnState = Cls.BTN_STATE.STATE_CD
      uiGOs.timer = _G.GameUtil.AddGlobalTimer(1, false, function()
        leftTime = leftTime - 1
        GUIUtils.SetText(lblBuy, txtConst[7]:format(math.floor(leftTime / 60), math.floor(leftTime % 60)))
        if leftTime <= 0 then
          _G.GameUtil.RemoveGlobalTimer(uiGOs.timer)
          uiGOs.timer = 0
          if bShow then
            GUIUtils.SetText(lblBuy, txtConst[5])
            self._uiStatus.btnState = Cls.BTN_STATE.STATE_BUY
          else
            GUIUtils.SetText(lblBuy, txtConst[6])
            self._uiStatus.btnState = Cls.BTN_STATE.STATE_REFRESH
          end
        end
      end)
    end
  elseif bShow then
    GUIUtils.SetText(lblBuy, txtConst[5])
    self._uiStatus.btnState = Cls.BTN_STATE.STATE_BUY
  elseif petsTeamInfo.refresh_time ~= nil then
    self._uiStatus.btnState = Cls.BTN_STATE.STATE_REFRESH
    GUIUtils.SetText(lblBuy, txtConst[6])
  end
end
def.method().updateUIRightTop = function(self)
  local uiGOs = self._uiGOs
  local defenseTeamIdx = PetTeamData.Instance():GetDefTeamIdx()
  local teamInfo = PetTeamData.Instance():GetTeamInfo(defenseTeamIdx)
  self:ShowTeam(teamInfo)
  local formationCfg
  if teamInfo == nil then
    formationCfg = PetTeamData.Instance():GetFormationCfg(constant.CPetFightConsts.DEFAULT_FORMATION_ID)
  end
  PetsArenaUtils.showFormationInfo(formationCfg, teamInfo, uiGOs.texTeamLaw, uiGOs.formation)
end
def.method("table").ShowTeam = function(self, petTeamInfo)
  self:ClearPetsModel()
  self._pet2ModelMap = {}
  PetsArenaUtils.ShowTeam(self, petTeamInfo, self._uiGOs.formation, self._uiGOs.lblPetsTeamScore, self._pet2ModelMap, 0, function(petId)
    return require("Main.Pet.mgr.PetMgr").Instance():GetPet(petId)
  end, {bIsMainPage = true})
end
def.method().updateChallengerList = function(self)
  local challengerInfos = self._opponentsList or {}
  local countChallenger = 5
  local uiList = self.m_panel:FindDirect("Img_Bg/Group_Player/Scrollview/List")
  local ctrlChlgerList = GUIUtils.InitUIList(uiList, countChallenger)
  for i = 1, countChallenger do
    self:fillChallengerInfo(ctrlChlgerList[i], challengerInfos[i], i)
  end
end
def.method("userdata", "table", "number").fillChallengerInfo = function(self, ctrl, info, idx)
  info = info or {}
  local headRoot = ctrl:FindDirect("Img_Head_" .. idx)
  local imgHead = headRoot
  local lblLv = headRoot:FindDirect("Label_Lv_" .. idx)
  local imgHeadFrame = headRoot:FindDirect("Img_BgHead01_" .. idx)
  local lblName = headRoot:FindDirect("Label_Name_" .. idx)
  local infoRoot = ctrl:FindDirect("Group_Info_" .. idx)
  local lblRank = infoRoot:FindDirect("Label_RankNum_" .. idx)
  local lblPetsTeamScore = infoRoot:FindDirect("Label_TeamNum_" .. idx)
  imgHead:SetActive(info.avatar ~= nil)
  _G.SetAvatarIcon(imgHead, info.avatar or 0)
  imgHeadFrame:SetActive(info.avatar_frame ~= nil)
  _G.SetAvatarFrameIcon(imgHeadFrame, info.avatar_frame or 0)
  GUIUtils.SetText(lblLv, info.level or txtConst[1])
  if info.name then
    if info.roleid:eq(0) then
      GUIUtils.SetText(lblName, const.ROBOT_NAME)
      GUIUtils.SetTexture(imgHead, const.ROBOT_ICON)
    else
      GUIUtils.SetText(lblName, _G.GetStringFromOcts(info.name))
    end
  else
    GUIUtils.SetText(lblName, info.name and _G.GetStringFromOcts(info.name) or txtConst[1])
  end
  if info.rank then
    if info.rank > const.TOP_NUM_HIDE_SCORE then
      GUIUtils.SetText(lblPetsTeamScore, info.score)
    else
      GUIUtils.SetText(lblPetsTeamScore, txtConst[22])
    end
    GUIUtils.SetText(lblRank, info.rank)
  else
    GUIUtils.SetText(lblRank, txtConst[1])
    GUIUtils.SetText(lblPetsTeamScore, txtConst[1])
  end
end
def.method().eventsRegister = function(self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.GET_OPPOENTSINFO_SUCCESS, Cls.OnGetOpponentsInfo, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.GET_SELF_PETSARENA_INFO, Cls.OnGetSelfInfo, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.REFRESH_OPPOENTSINFO_SUCCESS, Cls.OnRefreshOpponentsOK, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.BUY_CHALLENGE_COUNT_SUCCESS, Cls.OnBuyChallengeCountOK, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.START_PETS_FIGHT_SUCCESS, Cls.OnStartFightOK, self)
  Event.RegisterEventWithContext(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_DEF_TEAM_CHANGE, Cls.OnDefenseTeamChg, self)
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_PET_BATTLE, Cls.OnEnterPetFight, self)
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_PET_BATTLE, Cls.OnLeavePetFight, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.WATCH_VIDEO_END, Cls.OnWatchVideoEnd, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.GET_OPPOENTSINFO_FAILED, Cls.OnGetOpponentsInfoFailed, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.REPORT_FIGHT_END_OK, Cls.OnReportFightEndSuccess, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.PETARENA_RANK_CHANGE, Cls.OnPetArenaRankChg, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, Cls.OnPetArenaTokenChg, self)
end
def.method().eventsUnregister = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_OPPOENTSINFO_SUCCESS, Cls.OnGetOpponentsInfo)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_SELF_PETSARENA_INFO, Cls.OnGetSelfInfo)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.REFRESH_OPPOENTSINFO_SUCCESS, Cls.OnRefreshOpponentsOK)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.BUY_CHALLENGE_COUNT_SUCCESS, Cls.OnBuyChallengeCountOK)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.START_PETS_FIGHT_SUCCESS, Cls.OnStartFightOK)
  Event.UnregisterEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_DEF_TEAM_CHANGE, Cls.OnDefenseTeamChg)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_PET_BATTLE, Cls.OnEnterPetFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_PET_BATTLE, Cls.OnLeavePetFight)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.WATCH_VIDEO_END, Cls.OnWatchVideoEnd)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_OPPOENTSINFO_FAILED, Cls.OnGetOpponentsInfoFailed)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.REPORT_FIGHT_END_OK, Cls.OnReportFightEndSuccess)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PETARENA_RANK_CHANGE, Cls.OnPetArenaRankChg)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, Cls.OnPetArenaTokenChg)
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self._uiStatus.bTeamInfoDirty = false
  self._uiStatus.bEnterFight = false
  PetsArenaMgr.GetProtocol().CSengGetPetsArenaInfoReq()
  self:initUI()
  self:eventsRegister()
end
def.override().OnDestroy = function(self)
  self:eventsUnregister()
  self:ClearTimer()
  self._uiGOs = nil
  self._uiStatus = nil
  self._selfPetsTeamInfo = nil
  self:ClearPetsModel()
  self._opponentsList = nil
end
def.method().ClearTimer = function(self)
  if self._uiGOs.timer then
    _G.GameUtil.RemoveGlobalTimer(self._uiGOs.timer)
    self._uiGOs.timer = 0
  end
end
def.method().ClearPetsModel = function(self)
  if self._pet2ModelMap then
    for key, model in pairs(self._pet2ModelMap) do
      model:Destroy()
      model = nil
    end
    self._pet2ModelMap = nil
  end
end
def.override("boolean").OnShow = function(self, bShow)
  if not bShow then
    return
  end
  if self._uiStatus.bEnterFight then
    self:Show(false)
    return
  end
  if self._uiStatus.bTeamInfoDirty then
    self:updateChallengerList()
    self:updateUILeftTop()
  end
  if self._uiStatus.bJustLeaveFight then
    GameUtil.AddGlobalTimer(0.01, true, function()
      for _, model in pairs(self._pet2ModelMap or {}) do
        if not _G.IsNil(model) and not _G.IsNil(model.m_model) then
          model.m_model:SetActive(true)
          model:Play("Stand_c")
        else
          warn("[ERROR][PetsArenaMain:FillModel] _G.IsNil(model), _G.IsNil(model.m_model):", _G.IsNil(model), _G.IsNil(model.m_model))
        end
      end
    end)
  else
    self:updateUIRightTop()
  end
  self._uiStatus.bJustLeaveFight = false
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self._uiStatus = {}
  self._uiStatus.bJustLeaveFight = false
  self:CreatePanel(RESPATH.PREFAB_PETS_ARENA_MAIN, 1)
  self:SetModal(true)
end
def.method("=>", "number").getLeftTryTimes = function(self)
  local petsTeamInfo = self._selfPetsTeamInfo
  return const.FREE_CHALLENGE_COUNT + petsTeamInfo.buy_count - petsTeamInfo.challenge_count or 0
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Buy" == id then
    self:onClickBuyTryTimes()
  elseif "Btn_Record" == id then
    self:onClickFightHistory()
  elseif "Btn_Edit" == id then
    self:onClickEditPetTeam()
  elseif "Btn_Rule" == id then
    self:onClickCheckRules()
  elseif "Btn_Exchange" == id then
    self:onClickExchange()
  elseif "Btn_Reward" == id then
    self:onClickAward()
  elseif "Btn_Rank" == id then
    self:onClickRankBoard()
  elseif "Texture_Fomation" == id then
    self:onClickFormation(clickObj)
  elseif string.find(id, "Btn_Zhan1_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:onClickBtnChallenge(idx)
  elseif "Btn_Close" == id then
    self:DestroyPanel()
  elseif string.find(id, "Group_Site_") then
    local idx = tonumber(string.split(id, "_")[3])
    self:onClickUIModel(idx, clickObj)
  end
end
def.method().onClickBuyTryTimes = function(self)
  if self._uiStatus.btnState == nil then
    return
  end
  if self._uiStatus.btnState == Cls.BTN_STATE.STATE_BUY then
    if self._selfPetsTeamInfo.buy_count >= const.MAX_BUY_COUNT then
      Toast(txtConst[10])
      return
    end
    do
      local iNeedCurrency = const.FIRST_BUY_YUANBAO_PRICE + const.YUANBAO_PRICE_ADD_NUM * self._selfPetsTeamInfo.buy_count
      local currencyData = CurrencyFactory.Create(const.MONEY_TYPE)
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local content = txtConst[9]:format(iNeedCurrency, currencyData:GetName())
      CommonConfirmDlg.ShowConfirm(txtConst[8], content, function(select)
        if select == 1 then
          local owndCurrency = ItemModule.GetCurrencyNumByType(const.MONEY_TYPE)
          if owndCurrency:lt(iNeedCurrency) then
            ItemModule.GotoChargeByCurrencyType(const.MONEY_TYPE, true)
          else
            PetsArenaMgr.GetProtocol().CSendBuyTryTimes()
          end
        end
      end, nil)
    end
  elseif self._uiStatus.btnState == Cls.BTN_STATE.STATE_REFRESH then
    PetsArenaMgr.GetProtocol().CSendRefreshOppoent()
  elseif self._uiStatus.btnState == Cls.BTN_STATE.STATE_CD then
  end
end
def.method().onClickFightHistory = function(self)
  PetsArenaMgr.GetProtocol().CGetFightRecordReq()
end
def.method().onClickEditPetTeam = function(self)
  require("Main.PetTeam.ui.PetTeamPanel").ShowPanel()
end
def.method().onClickCheckRules = function(self)
  GUIUtils.ShowHoverTip(const.RULE_TIPS, 0, 0)
end
def.method().onClickExchange = function(self)
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
    TokenType.PET_FIGHT_SCORE
  })
end
def.method().onClickAward = function(self)
  require("Main.Pet.PetsArena.ui.UIAwardPreview").Instance():ShowPanel()
end
def.method().onClickRankBoard = function(self)
  local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
  require("Main.RankList.ui.RankListPanel").Instance():ShowChartView(ChartType.PET_ARENA_RANK)
end
def.method("userdata").onClickFormation = function(self, clickObj)
  local defenseTeamIdx = PetTeamData.Instance():GetDefTeamIdx()
  local teamInfo = PetTeamData.Instance():GetTeamInfo(defenseTeamIdx)
  if teamInfo == nil then
    return
  end
  require("Main.Pet.PetsArena.ui.PetsFomationTips").ShowPetsTipsWithGO(clickObj, 0, teamInfo, nil)
end
def.method("number").onClickBtnChallenge = function(self, idx)
  if self._selfPetsTeamInfo == nil then
    return
  end
  if self._uiStatus.bEnterFight then
    Toast(txtConst[37])
    return
  end
  local defenseTeamIdx = PetTeamData.Instance():GetDefTeamIdx()
  if defenseTeamIdx < 1 then
    Toast(txtConst[23])
    return
  end
  if 1 > self:getLeftTryTimes() then
    Toast(txtConst[19])
    return
  end
  if self._opponentsList == nil then
    return
  end
  local opponentsInfo = self._opponentsList[idx]
  require("Main.Pet.PetsArena.ui.UIPetsArenaReady").Instance():ShowPanel(opponentsInfo, {
    serial = self._uiStatus.serial
  })
end
def.method("number", "userdata").onClickUIModel = function(self, idx, clickObj)
  local defenseTeamIdx = PetTeamData.Instance():GetDefTeamIdx()
  local teamInfo = PetTeamData.Instance():GetTeamInfo(defenseTeamIdx)
  PetsArenaUtils.ShowNormalPetTips(teamInfo, idx, clickObj, nil)
end
def.method("table").OnGetOpponentsInfo = function(self, p)
  self._opponentsList = p.opponent_infos or {}
  self._uiStatus.serial = p.serial
  table.sort(self._opponentsList, function(a, b)
    if a.rank < b.rank then
      return true
    else
      return false
    end
  end)
  if self:IsShow() then
    self:updateChallengerList()
  else
    self._uiStatus.bTeamInfoDirty = true
  end
end
def.method("table").OnGetSelfInfo = function(self, p)
  self._selfPetsTeamInfo = p
  self:updateUILeftTop()
end
def.method("table").OnRefreshOpponentsOK = function(self, p)
  self._selfPetsTeamInfo.rank = p.rank
  self._selfPetsTeamInfo.refresh_time = p.refresh_time
  self:updateUILeftTop()
end
def.method("table").OnBuyChallengeCountOK = function(self, p)
  self._selfPetsTeamInfo.challenge_count = p.challenge_count
  self._selfPetsTeamInfo.buy_count = p.buy_count
  self:updateUILeftTop()
end
def.method("table").OnStartFightOK = function(self, p)
  self._selfPetsTeamInfo = p.pet_arena_info
  self:updateUILeftTop()
end
def.method("table").OnDefenseTeamChg = function(self, p)
  if self:IsShow() then
    self:updateUIRightTop()
  else
    self._uiStatus.bTeamInfoDirty = true
  end
end
def.method("table").OnEnterPetFight = function(self, p)
  self._uiStatus.bEnterFight = true
  self:Show(false)
end
def.method("table").OnLeavePetFight = function(self, p)
  self._uiStatus.bEnterFight = false
  self._uiStatus.bJustLeaveFight = true
  local guiManObj = require("GUI.ECGUIMan").Instance()
  local size = #guiManObj.m_uiLevelMap[self.m_level]
  local preUI = guiManObj.m_uiLevelMap[self.m_level][size - 1]
  if preUI == nil then
    self:Show(true)
  end
end
def.method("table").OnWatchVideoEnd = function(self, p)
end
def.method("table").OnGetOpponentsInfoFailed = function(self, p)
  self:DestroyPanel()
end
def.method("table").OnReportFightEndSuccess = function(self, p)
  self._selfPetsTeamInfo.point = p.point
  self._selfPetsTeamInfo.today_point = p.today_point
  self:updateUILeftTop()
end
def.method("table").OnPetArenaRankChg = function(self, p)
end
def.method("table").OnPetArenaTokenChg = function(self, p)
  self:updateUILeftTop()
end
return Cls.Commit()

local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgImagePvp = Lplus.Extend(ECPanelBase, "DlgImagePvp")
local def = DlgImagePvp.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
local PHASE = require("consts.mzm.gsp.activity.confbean.PhaseEnum")
local CommonDescDlg = require("GUI.CommonUITipsDlg")
local ItemUtils = require("Main.Item.ItemUtils")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local AllMoneyType = require("consts.mzm.gsp.item.confbean.AllMoneyType")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonTipWithTitle = require("GUI.CommonTipWithTitle")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
local ItemModule = require("Main.Item.ItemModule")
local EC = require("Types.Vector3")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
def.field("table").rivalList = nil
def.field("table").awardInfo = nil
def.field("number").refreshCd = 0
def.field("table").effect = nil
def.field("number").closeTime = 0
def.static("=>", DlgImagePvp).Instance = function()
  if dlg == nil then
    dlg = DlgImagePvp()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgImagePvp.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgImagePvp.OnLeaveFight)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, DlgImagePvp.OnCreditChange)
  Timer:RegisterListener(self.UpdateCountDown, self)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:SetData()
  else
    self:CreatePanel(RESPATH.DLG_IMAGE_PVP, 0)
    self:SetModal(true)
  end
end
def.override().OnDestroy = function(self)
  if self.effect then
    for _, v in pairs(self.effect) do
      v:Destroy()
    end
    self.effect = nil
  end
  self.closeTime = GetServerTime()
  gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP).data = nil
  self.rivalList = nil
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgImagePvp.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgImagePvp.OnLeaveFight)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, DlgImagePvp.OnCreditChange)
  Timer:RemoveListener(self.UpdateCountDown)
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if dlg.m_panel then
    dlg.m_panel:SetActive(false)
  end
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  if dlg.m_panel then
    dlg.m_panel:SetActive(true)
  end
end
def.static("table", "table").OnCreditChange = function(p1, p2)
  local jifen = p1[TokenType.JINGJICHANG_JIFEN]
  if jifen then
    dlg.m_panel:FindDirect("Img_Bg/Group_Info/Group_Jing/Label_HaveNum"):GetComponent("UILabel").text = tostring(jifen)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:SetData()
  if self.refreshCd > 0 then
    self.refreshCd = self.refreshCd - GetServerTime() + self.closeTime
  end
  self:SetCountDown()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Rank" then
    Event.DispatchEvent(ModuleId.RANK_LIST, gmodule.notifyId.RankList.REQ_OPEN_RANKLIST_PANEL, {
      ChartType.ROLE_JINGJI
    })
  elseif id == "Btn_JiFen" then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
      TokenType.JINGJICHANG_JIFEN
    })
  elseif id == "Btn_Tips" then
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701606100)
    CommonDescDlg.ShowCommonTip(tipContent, {x = 0, y = 0})
  elseif id == "Btn_Add" then
    require("Main.PVP.ui.DlgBuyChip").Instance():ShowDlg()
  elseif id == "Btn_Refresh" then
    self.refreshCd = constant.JingjiActivityCfgConsts.COMPETITOR_REFRESH_TIME
    self:SetCountDown()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.jingji.CRefreshOpponentReq").new())
  elseif id == "Btn_Buy" then
    local price = self.m_panel:FindDirect("Img_Bg/Group_Zhan/Group_Times/Group_Buy/Img_Money/Label_Num"):GetComponent("UILabel").text
    local yuanbao = ItemModule.Instance():GetAllYuanBao()
    if yuanbao:ToNumber() < tonumber(price) then
      Toast(textRes.ItemCommonError[498])
      return
    end
    require("GUI.CommonConfirmDlg").ShowConfirm("", string.format(textRes.PVP[18], price), function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.jingji.CBuyChallengeCount").new(1))
      end
    end, nil)
  elseif string.find(id, "Btn_Zhan") then
    if _G.PlayerIsInFight() then
      Toast(textRes.activity[379])
      return
    end
    if 0 >= gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP).data.challengeCount then
      Toast(textRes.PVP[1])
      return
    end
    local teamData = require("Main.Team.TeamData").Instance()
    local members = teamData:GetNormalMembers()
    local isCaptain = teamData:MeIsCaptain()
    if teamData:HasTeam() and (isCaptain and members and #members > 1 or not isCaptain and not teamData:MeIsAFK()) then
      Toast(textRes.PVP[42])
      return
    end
    local index = tonumber(string.sub(id, string.len("Btn_Zhan") + 1))
    local info = self.rivalList and self.rivalList[index]
    if info then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.jingji.CStartFightReq").new(info.roleid))
    end
  elseif id == "Texture_Prize1" then
    if self.awardInfo == nil or self.awardInfo.isFirstVictoty == -1 then
      Toast(textRes.PVP[6])
      return
    elseif self.awardInfo == nil or self.awardInfo.isFirstVictoty == 0 then
      Toast(textRes.PVP[7])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.jingji.CGetFirstVictoryRewardReq").new())
    self:RemoveUIEffect(id)
  elseif id == "Texture_Prize2" then
    if self.awardInfo == nil or self.awardInfo.isFiveFight == -1 then
      Toast(textRes.PVP[6])
      return
    elseif self.awardInfo == nil or self.awardInfo.isFiveFight == 0 then
      Toast(textRes.PVP[7])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.jingji.CGetFiveFightRewardReq").new())
    self:RemoveUIEffect(id)
    if not GameUtil.IsEvaluation() then
      require("GUI.GUIShare").Instance():ShowPanel({
        title = textRes.PVP[28],
        msg = textRes.PVP[29],
        confirmBtnStr = textRes.PVP[30],
        callback = function()
          local sdktype = ClientCfg.GetSDKType()
          if sdktype == ClientCfg.SDKTYPE.MSDK then
            RelationShipChainMgr.SendToFriend(3, 344300200)
          else
            local ECUniSDK = require("ProxySDK.ECUniSDK")
            if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
              ECUniSDK.Instance():Share({
                name = textRes.RelationShipChain[64],
                caption = textRes.RelationShipChain[65],
                shareDesc = textRes.RelationShipChain[67],
                type = ECUniSDK.SHARETYPE.FB
              })
            elseif ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
              ECUniSDK.Instance():Share({
                title = textRes.RelationShipChain[101],
                desc = textRes.RelationShipChain[103]
              })
            end
          end
        end
      })
    end
  elseif string.find(id, "Img_Box") then
    local phase = tonumber(string.sub(id, string.len("Img_Box") + 1)) + 1
    local chest = self.m_panel:FindDirect("Img_Bg/Group_Prize/Group_Box/" .. id)
    local claimIcon = chest:FindDirect("Img_Get")
    if claimIcon and claimIcon.activeSelf then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.jingji.CGetSeasonRewardReq").new())
      self:RemoveUIEffect("Img_Box")
      chest:FindDirect("Img_Light"):SetActive(false)
      chest:FindDirect("Img_Get"):SetActive(false)
    else
      local awardCfg = self:GetPhaseAward(phase)
      local phaseCfg = gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP):GetPhaseData(phase)
      local awardInfoStr = string.format(textRes.Award[5], phaseCfg.phaseName)
      local itemsStr = ItemTipsMgr.GetAwardDesc(awardCfg, true)
      local tipContent = string.gsub(itemsStr, "<br/>", "\n")
      local targetObj = dlg.m_panel:FindDirect("Img_Bg/Group_Prize/Group_Box/Img_Box" .. phase - 1)
      CommonTipWithTitle.Instance():ShowTargetTip(targetObj, awardInfoStr, tipContent)
    end
  end
end
def.method("number", "=>", "table").GetPhaseAward = function(self, phaseId)
  local awardid = 0
  if phaseId == PHASE.JINGTONG then
    awardid = 3101
  elseif phaseId == PHASE.DASHI then
    awardid = 3102
  elseif phaseId == PHASE.WANGZHE then
    awardid = 3103
  elseif phaseId == PHASE.CHUANSHUO then
    awardid = 3104
  end
  if awardid == 0 then
    return nil
  end
  local awardOcupSexKey = string.format("%d_%d_%d", awardid, 0, 0)
  return ItemUtils.GetGiftAwardCfg(awardOcupSexKey)
end
def.method().SetData = function(self)
  local p = gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP).data
  self:SetRankData(p)
  self:SetAwardInfo(p)
  self:SetRivals(p)
  self:SetEndTime()
end
def.static("table").OnSDataChanged = function(p)
  if dlg then
    dlg:SetRankData(p)
  end
end
def.static("table").OnSRewardChanged = function(p)
  if dlg then
    dlg:UpdateAwardInfo(p)
  end
end
def.static("table").OnSSyncTimes = function(p)
  if dlg == nil or dlg.m_panel == nil then
    return
  end
  dlg.m_panel:FindDirect("Img_Bg/Group_Zhan/Group_Times/Label_Times"):GetComponent("UILabel").text = tostring(p.challengeCount)
  local data = gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP).data
  if data then
    data.totalbuycount = p.totalbuycount
    data.challengeCount = p.challengeCount
    if data.challengeCount > 0 then
      dlg.m_panel:FindDirect("Img_Bg/Group_Zhan/Group_Times/Group_Buy"):SetActive(false)
      dlg.m_panel:FindDirect("Img_Bg/Group_Zhan/Group_Times/Btn_Refresh"):SetActive(true)
    else
      dlg:SetBuyInfo()
    end
  end
end
def.method().SetEndTime = function(self)
  if dlg.m_panel == nil then
    return
  end
  local endTime = gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP).endTime
  if endTime == 0 then
    return
  end
  dlg.m_panel:FindDirect("Img_Bg/Group_Prize/Label_Time"):GetComponent("UILabel").text = os.date("%m-%d %H:%M", endTime)
end
def.method("table").SetRankData = function(self, p)
  local data = gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP).data
  if data == nil then
    return
  end
  data.rank = p.rank
  data.challengeCount = p.challengeCount
  data.totalJifen = p.totalJifen
  data.dayJifen = p.dayJifen
  data.phase = p.phase
  data.winPoint = p.winPoint
  if self.m_panel == nil then
    return
  end
  local rankStr = textRes.RankList[1]
  local ranknum = self.m_panel:FindDirect("Img_Bg/Group_Info/Group_Rank/Label_RankNum")
  local bangwai = self.m_panel:FindDirect("Img_Bg/Group_Info/Group_Rank/Label_BangWai")
  if p.rank > 0 then
    rankStr = tostring(p.rank)
    ranknum:GetComponent("UILabel").text = rankStr
    bangwai:SetActive(false)
    ranknum:SetActive(true)
  else
    bangwai:SetActive(true)
    ranknum:SetActive(false)
  end
  local phasecfg
  if p.phase > 0 then
    phasecfg = gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP):GetPhaseData(p.phase)
  end
  self.m_panel:FindDirect("Img_Bg/Group_Zhan/Group_Times/Group_Buy"):SetActive(data.challengeCount <= 0)
  self.m_panel:FindDirect("Img_Bg/Group_Zhan/Group_Times/Btn_Refresh"):SetActive(data.challengeCount > 0)
  if data.challengeCount <= 0 then
    self:SetBuyInfo()
  end
  self.m_panel:FindDirect("Img_Bg/Group_Info/Group_DuanWei/Img_Badge"):GetComponent("UISprite").spriteName = self:GetPhaseIconName(data.phase)
  self.m_panel:FindDirect("Img_Bg/Group_Info/Group_Jing/Label_HaveNum"):GetComponent("UILabel").text = tostring(p.totalJifen)
  self.m_panel:FindDirect("Img_Bg/Group_Info/Group_Jing/Label_TodayNum"):GetComponent("UILabel").text = tostring(p.dayJifen)
  self.m_panel:FindDirect("Img_Bg/Group_Zhan/Group_Times/Label_Times"):GetComponent("UILabel").text = tostring(p.challengeCount)
  self.m_panel:FindDirect("Img_Bg/Group_Info/Group_ShengDian/Img_Bg1"):GetComponent("UISprite").spriteName = self:GetPhaseIconName(data.phase)
  local nextPhasecfg = gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP):GetPhaseData(p.phase + 1)
  local nextPhaseId = nextPhasecfg and nextPhasecfg.id or phasecfg and phasecfg.id or 0
  local nextPhasePoint = phasecfg and phasecfg.maxWinPoint or "--"
  local phaseTotal = phasecfg.maxWinPoint - phasecfg.minWinPoint
  local phaseGround = phasecfg and phasecfg.minWinPoint
  self.m_panel:FindDirect("Img_Bg/Group_Info/Group_ShengDian/Img_BgSlider"):GetComponent("UISlider").value = (p.winPoint - phaseGround) / phaseTotal
  self.m_panel:FindDirect("Img_Bg/Group_Info/Group_ShengDian/Img_BgSlider/Label_Num"):GetComponent("UILabel").text = tostring(p.winPoint .. "/" .. nextPhasePoint)
  self.m_panel:FindDirect("Img_Bg/Group_Info/Group_ShengDian/Img_Bg2"):GetComponent("UISprite").spriteName = self:GetPhaseIconName(nextPhaseId)
  for i = 1, 4 do
    local chest = self.m_panel:FindDirect("Img_Bg/Group_Prize/Group_Box/Img_Box" .. i)
    chest:FindDirect("Img_Light"):SetActive(self:GetPhaseBoxNum(data.phase) == i)
  end
  if p.lastSeasonPhase then
    local phasePrizeIdx = p.lastSeasonPhase - 1
    for i = 1, 4 do
      local chest = self.m_panel:FindDirect("Img_Bg/Group_Prize/Group_Box/Img_Box" .. i)
      chest:FindDirect("Img_Get"):SetActive(phasePrizeIdx == i)
      if phasePrizeIdx == i then
        self:ShowUIEffect("Img_Box", chest)
      end
    end
  end
  if p.winPointDelta == nil then
    return
  end
  local delta = math.abs(p.winPointDelta)
  if 0 < p.winPointDelta then
    if p.iswin == 0 then
      Toast(string.format(textRes.PVP[19], tostring(delta)))
    else
      Toast(string.format(textRes.PVP[8], tostring(delta)))
    end
  elseif 0 > p.winPointDelta then
    Toast(string.format(textRes.PVP[9], tostring(delta)))
  end
end
def.method().SetBuyInfo = function(self)
  local times = 1
  local data = gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP).data
  if data.totalbuycount and data.totalbuycount > 0 then
    times = data.totalbuycount + 1
  end
  local baseprice = constant.JingjiActivityCfgConsts.FIRST_BUY_YUANBAO_PRICE
  local delta = constant.JingjiActivityCfgConsts.YUANBAO_PRICE_ADD_NUM
  local price = baseprice + delta * times
  self.m_panel:FindDirect("Img_Bg/Group_Zhan/Group_Times/Group_Buy/Img_Money/Label_Num"):GetComponent("UILabel").text = tostring(price)
end
def.method("table").SetAwardInfo = function(self, awardInfo)
  self.awardInfo = awardInfo
  self:UpdateAwardPanelInfo()
end
def.method("table").UpdateAwardInfo = function(self, awardInfo)
  if self.awardInfo then
    self.awardInfo.isFirstVictoty = awardInfo.isFirstVictoty
    self.awardInfo.isFiveFight = awardInfo.isFiveFight
    self.awardInfo.lastSeasonPhase = awardInfo.lastSeasonPhase
    self:UpdateAwardPanelInfo()
  end
end
def.method().UpdateAwardPanelInfo = function(self)
  if self.awardInfo == nil or self.m_panel == nil then
    return
  end
  local hasAward = false
  local sp = self.m_panel:FindDirect("Img_Bg/Group_Prize/Group_DailyPrize/Texture_Prize1")
  local texture = sp:GetComponent("UITexture")
  if texture then
    if self.awardInfo.isFirstVictoty == 1 then
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Normal)
      self:ShowUIEffect("Texture_Prize1", sp)
      hasAward = true
    elseif self.awardInfo.isFirstVictoty == 0 then
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Gray)
    else
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Normal)
    end
  end
  sp = self.m_panel:FindDirect("Img_Bg/Group_Prize/Group_DailyPrize/Texture_Prize2")
  texture = sp:GetComponent("UITexture")
  if texture then
    if self.awardInfo.isFiveFight == 1 then
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Normal)
      self:ShowUIEffect("Texture_Prize2", sp)
      hasAward = true
    elseif self.awardInfo.isFiveFight == 0 then
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Gray)
    else
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Normal)
    end
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {
    activityId = constant.JingjiActivityCfgConsts.IMAGE_PVP,
    isShowRedPoint = hasAward
  })
end
def.method("table").SetRivals = function(self, p)
  if self.m_panel == nil or self.rivalList == nil then
    return
  end
  for i = 1, #self.rivalList do
    local info = self.rivalList[i]
    local panel = self.m_panel:FindDirect("Img_Bg/Group_Zhan/Group_" .. i)
    if panel then
      panel:FindDirect("Group_Info/Label_Lv"):GetComponent("UILabel").text = tostring(info.level)
      local phasecfg
      if info.phase > 0 then
        phasecfg = gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP):GetPhaseData(info.phase)
      end
      panel:FindDirect("Group_Info/Label_DuanWei"):GetComponent("UILabel").text = phasecfg and phasecfg.phaseName or ""
      local menpaiIcon = panel:FindDirect("Group_Info/Img_School")
      local headIcon = panel:FindDirect("Group_Head" .. i .. "/Img_Head")
      if 0 < info.occupation then
        menpaiIcon:SetActive(true)
        menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(info.occupation)
        headIcon:GetComponent("UISprite").spriteName = GUIUtils.GetHeadSpriteName(info.occupation, info.sex)
      else
        menpaiIcon:SetActive(false)
        headIcon:GetComponent("UISprite").spriteName = "ShenMi"
      end
      local rank_label = panel:FindDirect("Group_Head" .. i .. "/Img_MingCi")
      if info.rank and 0 < info.rank and info.rank <= constant.JingjiActivityCfgConsts.TOP_N_FOR_SHOW_RANK then
        rank_label:SetActive(true)
        rank_label:FindDirect("Label"):GetComponent("UILabel").text = tostring(info.rank)
      else
        rank_label:SetActive(false)
      end
    end
  end
end
def.method("number").UpdateCountDown = function(self, tk)
  if self.refreshCd <= 0 then
    return
  end
  self.refreshCd = self.refreshCd - tk
  self:SetCountDown()
end
def.method().SetCountDown = function(self)
  local btn = self.m_panel:FindDirect("Img_Bg/Group_Zhan/Group_Times/Btn_Refresh")
  btn:FindDirect("Label_RefreshTime"):GetComponent("UILabel").text = tostring(self.refreshCd)
  btn:GetComponent("UIButton"):set_isEnabled(self.refreshCd <= 0)
  btn:FindDirect("Label1"):SetActive(self.refreshCd <= 0)
  btn:FindDirect("Img_Clock"):SetActive(self.refreshCd > 0)
  btn:FindDirect("Label_RefreshTime"):SetActive(self.refreshCd > 0)
end
def.method("string", "userdata").ShowUIEffect = function(self, effname, effComtainer)
  local effid = 702020014
  if effComtainer == nil then
    return
  end
  if self.effect and self.effect[effname] then
    self.effect[effname].parent = effComtainer
    return
  end
  if self.effect == nil then
    self.effect = {}
  end
  local effres = GetEffectRes(effid)
  if effres == nil then
    return
  end
  local function OnLoadEffect(obj)
    if self.effect == nil then
      return
    end
    if obj == null then
      warn("[DlgImagePvp]asycload obj is nil: ", effres)
      return
    end
    local eff = Object.Instantiate(obj, "GameObject")
    eff:SetLayer(ClientDef_Layer.UI, true)
    eff.name = tostring(effid)
    local uiparticle = effComtainer:GetComponent("UIParticle")
    if uiparticle == nil then
      uiparticle = effComtainer:AddComponent("UIParticle")
    end
    uiparticle.modelGameObject = eff
    uiparticle.depth = 6
    eff.parent = effComtainer
    eff.localPosition = EC.Vector3.new(0, 0, 0)
    eff.localScale = EC.Vector3.one
    eff:SetActive(true)
    self.effect[effname] = eff
  end
  GameUtil.AsyncLoad(effres.path, OnLoadEffect)
end
def.method("string").RemoveUIEffect = function(self, effname)
  if self.effect == nil then
    return
  end
  local eff = self.effect[effname]
  if eff then
    eff:Destroy()
    self.effect[effname] = nil
  end
end
def.method("number", "=>", "string").GetPhaseIconName = function(self, phaseId)
  local iconName = ""
  if phaseId == PHASE.RUMEN then
    iconName = "Img_RM"
  elseif phaseId == PHASE.JINGTONG then
    iconName = "Img_JT"
  elseif phaseId == PHASE.DASHI then
    iconName = "Img_DS"
  elseif phaseId == PHASE.WANGZHE then
    iconName = "Img_WZ"
  elseif phaseId == PHASE.CHUANSHUO then
    iconName = "Img_CS"
  end
  return iconName
end
def.method("number", "=>", "number").GetPhaseBoxNum = function(self, phaseId)
  local iconNum = 0
  if phaseId == PHASE.RUMEN then
    iconNum = 0
  elseif phaseId == PHASE.JINGTONG then
    iconNum = 1
  elseif phaseId == PHASE.DASHI then
    iconNum = 2
  elseif phaseId == PHASE.WANGZHE then
    iconNum = 3
  elseif phaseId == PHASE.CHUANSHUO then
    iconNum = 4
  end
  return iconNum
end
DlgImagePvp.Commit()
return DlgImagePvp

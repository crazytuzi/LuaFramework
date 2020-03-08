local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QimaiMainDlg = Lplus.Extend(ECPanelBase, "QimaiMainDlg")
local MENPAI = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local def = QimaiMainDlg.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
local CommonUISmallTip = require("GUI.CommonUISmallTip")
local TipsHelper = require("Main.Common.TipsHelper")
local ItemModule = require("Main.Item.ItemModule")
local EC = require("Types.Vector3")
local PAGE_COUNT = 20
def.field("number").refreshCd = -1
def.field("table").effect = nil
def.static("=>", QimaiMainDlg).Instance = function()
  if dlg == nil then
    dlg = QimaiMainDlg()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Timer:RegisterListener(self.Update, self)
  Event.RegisterEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_UI, QimaiMainDlg.UpdateUI)
  Event.RegisterEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_RANK, QimaiMainDlg.UpdateRank)
  Event.RegisterEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_INFO, QimaiMainDlg.UpdateInfo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerRes, QimaiMainDlg.OnGetServerActivityTime)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, QimaiMainDlg.OnTeamMemberChanged)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_QIMAI_MAIN, 0)
  self:SetModal(true)
  gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU):RequireRankList(1, PAGE_COUNT)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.qmhw.CQMHWSelfRankReq").new())
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowInfo()
  self:SetAwardInfo()
  dlg:ShowRankList()
  self:SetMyRank()
  self:ShowTeamMembers()
  self:Update(0)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  if self.effect then
    for _, v in pairs(self.effect) do
      v:Destroy()
    end
    self.effect = nil
  end
  gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU):ClearRank()
  Timer:RemoveListener(self.Update)
  Event.UnregisterEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_UI, QimaiMainDlg.UpdateUI)
  Event.UnregisterEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_RANK, QimaiMainDlg.UpdateRank)
  Event.UnregisterEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_INFO, QimaiMainDlg.UpdateInfo)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerRes, QimaiMainDlg.OnGetServerActivityTime)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, QimaiMainDlg.OnTeamMemberChanged)
end
def.method("string").onDragEnd = function(self, id)
  if string.find(id, "Group_Info_") then
    if self.m_panel == nil then
      return
    end
    local dragAmount = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_Rank/Scroll View"):GetComponent("UIScrollView"):GetDragAmount()
    if dragAmount.y > 1 then
      local index = tonumber(string.sub(id, string.len("Group_Info_") + 1))
      if index <= 0 then
        return
      end
      gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU):RequireRankList(index, PAGE_COUNT)
    end
  end
end
def.method().ShowInfo = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local mgr = gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU)
  self.m_panel:FindDirect("Img_Bg/Group_Left/Group_Info/Label_SC/Label"):GetComponent("UILabel").text = mgr.win
  self.m_panel:FindDirect("Img_Bg/Group_Left/Group_Info/Label_FC/Label"):GetComponent("UILabel").text = mgr.lose
  self.m_panel:FindDirect("Img_Bg/Group_Left/Group_Info/Label_LS/Label"):GetComponent("UILabel").text = mgr.winningStreak
  self.m_panel:FindDirect("Img_Bg/Group_Left/Group_Info/Label_JF/Label"):GetComponent("UILabel").text = mgr.score
end
def.method().ShowRankList = function(self)
  if self.m_panel == nil then
    return
  end
  local rankData = gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU).rankData
  local listPanel = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_Rank/Scroll View/List_Rank")
  local uiList = listPanel:GetComponent("UIList")
  if rankData == nil then
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  uiList.itemCount = #rankData
  uiList:Resize()
  local info
  for i = 1, #rankData do
    info = rankData[i]
    local itemPanel = listPanel:FindDirect("Group_Info_" .. i)
    self:SetRankNumber(itemPanel, info.rank + 1)
    itemPanel:FindDirect("Label_MC_" .. i):GetComponent("UILabel").text = info.roleName
    itemPanel:FindDirect("Label_JF_" .. i):GetComponent("UILabel").text = tostring(info.score)
    itemPanel:FindDirect("Label_SC_" .. i):GetComponent("UILabel").text = _G.GetOccupationName(info.occupation)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().SetMyRank = function(self)
  local mgr = gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU)
  local myRankPanel = self.m_panel:FindDirect("Img_Bg/Group_Right/Img_BgBottom/Group_Own")
  self:SetRankNumber(myRankPanel, mgr.myrank)
  local myprop = require("Main.Hero.Interface").GetHeroProp()
  myRankPanel:FindDirect("Label_mMC"):GetComponent("UILabel").text = myprop.name
  myRankPanel:FindDirect("Label_mSC"):GetComponent("UILabel").text = _G.GetOccupationName(myprop.occupation)
  myRankPanel:FindDirect("Label_mJF"):GetComponent("UILabel").text = mgr.score
end
def.method("userdata", "number").SetRankNumber = function(self, rankpanel, rank)
  if rankpanel == nil then
    return
  end
  local rankLabel = rankpanel:FindDirect("Label_PM_" .. rank)
  if rankLabel == nil then
    rankLabel = rankpanel:FindDirect("Label_mPM")
  end
  local rankImage = rankpanel:FindDirect("Img_MingCi_" .. rank)
  if rankImage == nil then
    rankImage = rankpanel:FindDirect("Img_MingCi")
  end
  if rankLabel == nil or rankImage == nil then
    return
  end
  if rank <= 0 then
    rankLabel:GetComponent("UILabel").text = textRes.Common[1]
    rankImage:SetActive(false)
    return
  end
  if rank <= 3 and rank > 0 then
    local uiSprite = rankImage:GetComponent("UISprite")
    uiSprite.spriteName = "Img_Num" .. rank
    rankLabel:SetActive(false)
    rankImage:SetActive(true)
  else
    rankImage:SetActive(false)
    rankLabel:SetActive(true)
    local rankStr = tostring(rank)
    if rank == nil or rank <= 0 then
      rankStr = textRes.RankList[1]
    else
      rankStr = tostring(rank)
    end
    rankLabel:GetComponent("UILabel").text = rankStr
  end
end
def.method().SetAwardInfo = function(self)
  if self.m_panel == nil then
    return
  end
  local mgr = gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU)
  local sp = self.m_panel:FindDirect("Img_Bg/Group_Left/Group_DailyPrize/Texture_Prize1")
  local texture = sp:GetComponent("UITexture")
  if texture then
    if mgr.oneVictoryClaimed then
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Gray)
    elseif mgr.win > 0 then
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Normal)
      self:ShowUIEffect("Texture_Prize1", sp)
    else
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Normal)
    end
  end
  sp = self.m_panel:FindDirect("Img_Bg/Group_Left/Group_DailyPrize/Texture_Prize2")
  texture = sp:GetComponent("UITexture")
  if texture then
    if mgr.fiveBattleClaimed then
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Gray)
    elseif mgr.win + mgr.lose >= 5 then
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Normal)
      self:ShowUIEffect("Texture_Prize2", sp)
    else
      GUIUtils.SetTextureEffect(texture, GUIUtils.Effect.Normal)
    end
  end
end
def.method().ShowTeamMembers = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  local memberPanel
  for i = 1, 5 do
    memberPanel = self.m_panel:FindDirect("Img_Bg/Group_Down/Grid_Head/Group_Head" .. i)
    if teamData:HasTeam() then
      if i == 1 then
        memberPanel:FindDirect("Img_Leader"):SetActive(true)
      end
      if i <= #members then
        local member = members[i]
        local name = member.name
        local mengpai = member.menpai
        local lv = member.level
        local meipaiIconName = GUIUtils.GetOccupationSmallIcon(mengpai)
        _G.SetAvatarFrameIcon(memberPanel:FindDirect("Img_FgHead"), member.avatarFrameid)
        _G.SetAvatarIcon(memberPanel:FindDirect("Img_Head"), member.avatarId)
        memberPanel:FindDirect("Img_Head"):SetActive(true)
      else
        memberPanel:FindDirect("Img_Head"):SetActive(false)
      end
    elseif i == 1 then
      memberPanel:FindDirect("Img_Leader"):SetActive(false)
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      local meipaiIconName = GUIUtils.GetOccupationSmallIcon(heroProp.occupation)
      memberPanel:FindDirect("Img_Head"):SetActive(true)
      _G.SetAvatarFrameIcon(memberPanel:FindDirect("Img_FgHead"))
      _G.SetAvatarIcon(memberPanel:FindDirect("Img_Head"))
    else
      memberPanel:FindDirect("Img_Head"):SetActive(false)
    end
  end
end
def.static("table", "table").OnTeamMemberChanged = function(p1, p2)
  dlg:ShowTeamMembers()
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  dlg:Hide()
end
def.static("table", "table").UpdateUI = function(p1, p2)
end
def.static("table", "table").UpdateInfo = function(p1, p2)
  dlg:ShowInfo()
  dlg:SetAwardInfo()
end
def.static("table", "table").UpdateRank = function(p1, p2)
  dlg:ShowRankList()
  dlg:SetMyRank()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Team" then
    gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU):OpenActivityTeam()
  elseif id == "Btn_PlayTip" then
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701609700)
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
  elseif id == "Texture_Prize1" then
    local mgr = gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU)
    if mgr.oneVictoryClaimed then
      Toast(textRes.PVP[7])
      return
    elseif mgr.win < 1 then
      Toast(textRes.PVP[6])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.qmhw.CTaskWinCountAward").new(1))
    self:RemoveUIEffect(id)
  elseif id == "Texture_Prize2" then
    local mgr = gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU)
    if mgr.fiveBattleClaimed then
      Toast(textRes.PVP[7])
      return
    elseif mgr.win + mgr.lose < 5 then
      Toast(textRes.PVP[6])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.qmhw.CTaskJionCountAward").new(5))
    self:RemoveUIEffect(id)
  elseif string.find(id, "Group_Head") then
    local index = tonumber(string.sub(id, string.len("Group_Head") + 1))
    self:OnTouchTeamMember(index)
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.method("number").OnTouchTeamMember = function(self, idx)
end
def.method("string", "boolean").onPress = function(self, id, state)
end
def.static("table", "table").OnGetServerActivityTime = function(p1, p2)
  local activityId = p1[1]
  local ActivityID = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "Activityid"):GetIntValue("value")
  if activityId == ActivityID then
    dlg.mServerTime = p1[2]
    dlg:_FillTime()
  end
end
def.method().UpdateTime = function(self)
  local endTime = gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU).endTime
  if endTime == 0 then
    return
  end
  local nowSec = GetServerTime()
  local timestr
  if endTime >= nowSec then
    local left = Seconds2HMSTime(endTime - nowSec)
    if 0 < left.h then
      timestr = string.format("%02d:%02d:%02d", left.h, left.m, left.s)
    else
      timestr = string.format("%02d:%02d", left.m, left.s)
    end
  end
  self.m_panel:FindDirect("Img_Bg/Group_Left/Group_LeftTime/Label_Time"):GetComponent("UILabel").text = timestr or "00:00"
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
    eff:SetActive(false)
    eff:SetLayer(ClientDef_Layer.UI, true)
    eff.name = tostring(effid)
    local uiparticle = effComtainer:GetComponent("UIParticle")
    if uiparticle == nil then
      uiparticle = effComtainer:AddComponent("UIParticle")
    end
    uiparticle.modelGameObject = eff
    uiparticle.depth = 6
    eff.parent = effComtainer
    eff.localPosition = EC.Vector3.zero
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
def.method("number").Update = function(self, tick)
  local endTime = gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU).endTime
  if endTime == 0 then
    return
  end
  local nowSec = GetServerTime()
  local timestr
  if endTime >= nowSec then
    local left = Seconds2HMSTime(endTime - nowSec)
    if 0 < left.h then
      timestr = string.format("%02d:%02d:%02d", left.h, left.m, left.s)
    else
      timestr = string.format("%02d:%02d", left.m, left.s)
    end
  end
  self.m_panel:FindDirect("Img_Bg/Group_Left/Group_LeftTime/Label_Time"):GetComponent("UILabel").text = timestr or "00:00"
end
QimaiMainDlg.Commit()
return QimaiMainDlg

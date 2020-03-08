local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgLeaderBattleRank = Lplus.Extend(ECPanelBase, "DlgLeaderBattleRank")
local def = DlgLeaderBattleRank.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
local HeroInterface = require("Main.Hero.Interface")
local MENPAI = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
def.field("number").selectedMenpai = 1
def.field("number").refreshCd = 0
def.field("table").menpaiList = nil
def.const("table").Top3IconName = {
  "Img_Num1",
  "Img_Num2",
  "Img_Num3"
}
def.static("=>", DlgLeaderBattleRank).Instance = function()
  if dlg == nil then
    dlg = DlgLeaderBattleRank()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_LEADER_BATTTL_RANK, 1)
  self:SetModal(true)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaipvp.CSelfRankReq").new())
  self.selectedMenpai = HeroInterface.GetHeroProp().occupation
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaipvp.CChartReq").new(self.selectedMenpai, 0))
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.LEITAI, gmodule.notifyId.PVP.UPDATE_LEADER_BATTLE_MYRANK, DlgLeaderBattleRank.UpdateMyRank)
  Timer:RegisterListener(self.Update, self)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, DlgLeaderBattleRank.OnHeroStatusChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.LEITAI, gmodule.notifyId.PVP.UPDATE_LEADER_BATTLE_MYRANK, DlgLeaderBattleRank.UpdateMyRank)
  Timer:RemoveListener(self.Update)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, DlgLeaderBattleRank.OnHeroStatusChange)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:InitMenpaiBtns()
  self:SetRankData()
  self:SetMyRank()
  self:SetMenpaiBtn()
  self:SetButtonTime()
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self.refreshCd = 0
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Refresh" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaipvp.CChartReq").new(self.selectedMenpai, 0))
    self.refreshCd = 5
    self:SetButtonTime()
  elseif string.find(id, "Btn_Class_") then
    local idx = tonumber(string.sub(id, string.len("Btn_Class_") + 1))
    local menpai = self.menpaiList and self.menpaiList[idx]
    if self.selectedMenpai == menpai then
      return
    end
    self.selectedMenpai = menpai
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaipvp.CChartReq").new(self.selectedMenpai, 0))
  elseif id == "Btn_GameInfo" then
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701601100)
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
  end
end
def.method().InitMenpaiBtns = function(self)
  local btnList = self.m_panel:FindDirect("Img_Bg0/Img_BgLeft/Scorllview_Class/List_Class")
  local uiList = btnList:GetComponent("UIList")
  local occupations, num = _G.GetAllRealOpenedOccupations()
  uiList.itemCount = num
  uiList:Resize()
  self.menpaiList = {}
  if num == 0 then
    return
  end
  local menpai = next(occupations)
  local idx = 1
  while menpai do
    local btn = btnList:FindDirect("Btn_Class_" .. idx)
    if btn then
      btn:FindDirect("Label_" .. idx):GetComponent("UILabel").text = GetOccupationName(menpai)
      local sp = btn:FindDirect("Sprite_" .. idx):GetComponent("UISprite")
      sp.spriteName = GUIUtils.GetOccupationSmallIcon(menpai)
      table.insert(self.menpaiList, menpai)
    end
    idx = idx + 1
    menpai = next(occupations, menpai)
  end
end
def.static("table", "table").UpdateMyRank = function(self)
  instance:SetMyRank()
end
def.method().SetRankData = function(self)
  local rankInfo = gmodule.moduleMgr:GetModule(ModuleId.LEADER_BATTLE).rankInfo
  local listPanel = self.m_panel:FindDirect("Img_Bg0/Group_Detail/Scroll View/List_Detail")
  local uiList = listPanel:GetComponent("UIList")
  if rankInfo == nil then
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  self.selectedMenpai = rankInfo.menpai
  self:SetMenpaiBtn()
  uiList.itemCount = #rankInfo.data_list
  uiList:Resize()
  local info
  for i = 1, #rankInfo.data_list do
    info = rankInfo.data_list[i]
    local itemPanel = listPanel:FindDirect("Group_Detail1_" .. i)
    self:SetRankNumber(itemPanel, i)
    itemPanel:FindDirect("Label_Name_" .. i):GetComponent("UILabel").text = info.name
    itemPanel:FindDirect("Label_Score_" .. i):GetComponent("UILabel").text = tostring(info.score)
    itemPanel:FindDirect("Label_Num_" .. i):GetComponent("UILabel").text = tostring(info.win_times)
  end
end
def.method().SetMyRank = function(self)
  local myRankInfo = gmodule.moduleMgr:GetModule(ModuleId.LEADER_BATTLE).myRankInfo
  if myRankInfo == nil then
    return
  end
  local myRankPanel = self.m_panel:FindDirect("Img_Bg0/Img_BgBottom/Group_Player")
  if myRankInfo.rank then
    self:SetRankNumber(myRankPanel, myRankInfo.rank)
  else
    self:SetRankNumber(myRankPanel, -1)
  end
  myRankPanel:FindDirect("Label_FightNum"):GetComponent("UILabel").text = tostring(myRankInfo.win + myRankInfo.lose)
  myRankPanel:FindDirect("Label_Score"):GetComponent("UILabel").text = tostring(myRankInfo.score)
  myRankPanel:FindDirect("Label_Num"):GetComponent("UILabel").text = tostring(myRankInfo.lose)
end
def.method("userdata", "number").SetRankNumber = function(self, rankpanel, rank)
  if rankpanel == nil then
    return
  end
  local rankLabel = rankpanel:FindDirect("Label_Rank_" .. rank)
  if rankLabel == nil then
    rankLabel = rankpanel:FindDirect("Label_Rank")
  end
  local rankImage = rankpanel:FindDirect("Img_MingCi_" .. rank)
  if rankImage == nil then
    rankImage = rankpanel:FindDirect("Img_MingCi")
  end
  if rankLabel == nil or rankImage == nil then
    return
  end
  if rank <= 0 then
    rankImage:SetActive(false)
    rankLabel:GetComponent("UILabel").text = textRes.Common[1]
    return
  end
  if rank <= 3 and rank > 0 then
    local uiSprite = rankImage:GetComponent("UISprite")
    uiSprite.spriteName = DlgLeaderBattleRank.Top3IconName[rank]
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
def.method().SetMenpaiBtn = function(self)
  local idx = table.indexof(self.menpaiList, self.selectedMenpai)
  if not idx or idx <= 0 then
    return
  end
  local scroll_panel = self.m_panel:FindDirect("Img_Bg0/Img_BgLeft/Scorllview_Class")
  local selectedBtn = scroll_panel:FindDirect("List_Class/Btn_Class_" .. idx)
  if selectedBtn == nil then
    return
  end
  selectedBtn:GetComponent("UIToggle").value = true
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self.m_panel and not self.m_panel.isnil then
      scroll_panel:GetComponent("UIScrollView"):DragToMakeVisible(selectedBtn.transform, 10)
    end
  end)
end
def.method("number").Update = function(self, tick)
  self:UpdateTime(tick)
  local endTime = gmodule.moduleMgr:GetModule(ModuleId.LEADER_BATTLE).endTime
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
  self.m_panel:FindDirect("Img_Bg0/Img_BgBottom/Group_Message/Label_Time"):GetComponent("UILabel").text = timestr or "00:00"
end
def.method("number").UpdateTime = function(self, tk)
  if self.refreshCd <= 0 then
    return
  end
  self.refreshCd = self.refreshCd - tk
  self:SetButtonTime()
end
def.method().SetButtonTime = function(self)
  local btn = self.m_panel:FindDirect("Img_Bg0/Img_BgBottom/Btn_Refresh")
  btn:FindDirect("Label_RefreshTime"):GetComponent("UILabel").text = tostring(self.refreshCd)
  btn:GetComponent("UIButton"):set_isEnabled(self.refreshCd == 0)
  btn:FindDirect("Label1"):SetActive(self.refreshCd == 0)
  btn:FindDirect("Img_Clock"):SetActive(self.refreshCd > 0)
  btn:FindDirect("Label_RefreshTime"):SetActive(self.refreshCd > 0)
end
def.static("table", "table").OnHeroStatusChange = function()
  if not gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:IsInState(RoleState.SXZB) then
    dlg:Hide()
  end
end
DlgLeaderBattleRank.Commit()
return DlgLeaderBattleRank

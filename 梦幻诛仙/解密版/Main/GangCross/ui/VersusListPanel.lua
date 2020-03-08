local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local VersusListPanel = Lplus.Extend(ECPanelBase, "VersusListPanel")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local GangCrossData = require("Main.GangCross.data.GangCrossData")
local def = VersusListPanel.define
local instance
def.field("table").uiTbl = nil
def.field("number").actTime = 0
def.field("number").actIndex = 0
def.field("table").againstList = nil
local GANG_INFO_STATE = {
  NORMAL = 1,
  PREPARE = 2,
  WIN = 3,
  LOSE = 4,
  FIGHT = 5,
  QUIT = 6
}
def.static("=>", VersusListPanel).Instance = function()
  if not instance then
    instance = VersusListPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, againstList)
  self.againstList = againstList
  if self:IsShow() then
    self:UpdateUI()
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_CROSS_GANGINFO, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
    Timer:RegisterListener(self.UpdateTime, self)
  else
    Timer:RemoveListener(self.UpdateTime)
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Center = Img_Bg:FindDirect("Group_Center")
  local Group_List = Group_Center:FindDirect("Group_List")
  uiTbl.Group_List = Group_List
  local Group_Time = Img_Bg:FindDirect("Group_Bottom/Group_Label")
  local Label_Time = Group_Time:FindDirect("Label_Time")
  uiTbl.Group_Time = Group_Time
  uiTbl.Label_Time = Label_Time
end
def.method().Reset = function(self)
end
def.method().UpdateUI = function(self)
  do
    local IsSameGang = function(gangId1, gangId2)
      return Int64.eq(gangId1, gangId2)
    end
    local ownGangIndex = 0
    local againstList = self.againstList
    local zoneId = require("netio.Network").m_zoneid or 0
    local gangId = require("Main.Gang.data.GangData").Instance():GetGangId()
    if gangId then
      for k, v in ipairs(againstList) do
        if IsSameGang(v.faction1.factionid, gangId) or IsSameGang(v.faction2.factionid, gangId) then
          ownGangIndex = k
          break
        end
      end
    end
    self.actIndex = 0
    if ownGangIndex > 0 then
      local tmp = againstList[1]
      againstList[1] = againstList[ownGangIndex]
      againstList[ownGangIndex] = tmp
      local index = againstList[1].compete_index or 0
      if index >= constant.GangCrossConsts.MaxCompeteCountOfOneTime then
        self.actIndex = 1
      end
    end
    local function IsSameSvr(gangId1, myGangId)
      local svrId1 = GangCrossUtility.Instance():GetSvrIdForGangId(gangId1)
      local svrId2 = GangCrossUtility.Instance():GetSvrIdForGangId(myGangId)
      return svrId1 ~= 0 and (svrId1 == svrId2 or _G.IsMergedServer(svrId1))
    end
    if gangId then
      for k, v in ipairs(againstList) do
        if not IsSameSvr(v.faction1.factionid, gangId) and IsSameSvr(v.faction2.factionid, gangId) then
          local tmp = v.faction2
          v.faction2 = v.faction1
          v.faction1 = tmp
        end
      end
    end
  end
  self.actTime = GangCrossUtility.Instance():getActivityWeekBeginTime()
  self:UpdateTime(0)
  self:FillGangList()
end
def.method("=>", "number").GetActTime = function(self)
  local time = 0
  local actTime = self.actTime
  local nowTime = GetServerTime()
  if actTime > 0 and actTime < nowTime then
    local minutes = constant.GangCrossConsts.PrepareMinutes + constant.GangCrossConsts.FightMinutes + constant.GangCrossConsts.WaitForceEndMinutes + constant.GangCrossConsts.RestMinutes
    time = nowTime - actTime
    time = constant.GangCrossConsts.SignUpDays * 86400 + (constant.GangCrossConsts.MatchHours + constant.GangCrossConsts.MailRemindHours) * 3600 + constant.GangCrossConsts.WaitMinutes * 60 - time
    time = time + self.actIndex * minutes * 60
  end
  if time <= 0 then
    time = 0
  end
  return time
end
def.method("number").UpdateTime = function(self, dt)
  local time = self:GetActTime()
  local timeStr = GangCrossUtility.Instance():getTimeString(time)
  self.uiTbl.Group_Time:SetActive(time > 0)
  self.uiTbl.Label_Time:GetComponent("UILabel"):set_text(timeStr or "")
end
def.method().FillGangList = function(self)
  local againstList = self.againstList
  local scrollViewObj = self.uiTbl.Group_List:FindDirect("Scroll View")
  local scrollListObj = scrollViewObj:FindDirect("List_Member")
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillGangInfo(item, i, againstList[i])
  end)
  ScrollList_setCount(uiScrollList, #againstList)
  self.m_msgHandler:Touch(scrollListObj)
  if bResetScrollView then
    scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
  end
end
def.method("table", "=>", "string").GetSvrDisplayName = function(self, factionInfo)
  local svrName = GangCrossUtility.Instance():GetSvrNameForGangId(factionInfo.factionid)
  return svrName
end
def.method("userdata", "number", "table").FillGangInfo = function(self, memberUI, index, againstInfo)
  local Label_GangName01 = memberUI:FindDirect("Label_GangName01")
  local Label_GangName02 = memberUI:FindDirect("Label_GangName02")
  Label_GangName01:GetComponent("UILabel"):set_text(againstInfo.faction1.faction_name)
  Label_GangName02:GetComponent("UILabel"):set_text(againstInfo.faction2.faction_name)
  local Label_GangServer01 = memberUI:FindDirect("Label_GangServer01")
  local Label_GangServer02 = memberUI:FindDirect("Label_GangServer02")
  Label_GangServer01:GetComponent("UILabel"):set_text(self:GetSvrDisplayName(againstInfo.faction1))
  Label_GangServer02:GetComponent("UILabel"):set_text(self:GetSvrDisplayName(againstInfo.faction2))
  local winIndex = 0
  local winnerId = againstInfo.winner
  local Group_Result01 = memberUI:FindDirect("Group_Result01")
  local Group_Result02 = memberUI:FindDirect("Group_Result02")
  if 0 < winnerId:ToNumber() then
    if Int64.eq(winnerId, againstInfo.faction1.factionid) then
      winIndex = 1
    end
    if Int64.eq(winnerId, againstInfo.faction2.factionid) then
      winIndex = 2
    end
  end
  if winIndex == 1 then
    self:SetGangState(Group_Result01, GANG_INFO_STATE.WIN)
    self:SetGangState(Group_Result02, GANG_INFO_STATE.LOSE)
  elseif winIndex == 2 then
    self:SetGangState(Group_Result01, GANG_INFO_STATE.LOSE)
    self:SetGangState(Group_Result02, GANG_INFO_STATE.WIN)
  else
    local actTime = GangCrossUtility.Instance():getActivityWeekBeginTime()
    if actTime > 0 then
      local actIndex = againstInfo.compete_index
      local minutes = constant.GangCrossConsts.PrepareMinutes + constant.GangCrossConsts.FightMinutes + constant.GangCrossConsts.WaitForceEndMinutes + constant.GangCrossConsts.RestMinutes
      local timeDiff = constant.GangCrossConsts.SignUpDays * 86400 + (constant.GangCrossConsts.MatchHours + constant.GangCrossConsts.MailRemindHours) * 3600 + constant.GangCrossConsts.WaitMinutes * 60 + constant.GangCrossConsts.PrepareMinutes * 60
      if actIndex >= constant.GangCrossConsts.MaxCompeteCountOfOneTime then
        actIndex = 1
      else
        actIndex = 0
      end
      actTime = actTime + timeDiff + actIndex * minutes * 60
      local value = GetServerTime() - actTime
      if value < 0 then
        self:SetGangState(Group_Result01, GANG_INFO_STATE.PREPARE)
        self:SetGangState(Group_Result02, GANG_INFO_STATE.PREPARE)
      end
    end
  end
  local Img_Bg1 = memberUI:FindDirect("Img_Bg1")
  local Img_Bg2 = memberUI:FindDirect("Img_Bg2")
  if index % 2 == 0 then
    Img_Bg1:SetActive(false)
    Img_Bg2:SetActive(true)
  else
    Img_Bg1:SetActive(true)
    Img_Bg2:SetActive(false)
  end
end
def.method("userdata", "number").SetGangState = function(self, stateUI, state)
  local Img_Win = stateUI:FindDirect("Img_Win")
  local Img_Lose = stateUI:FindDirect("Img_Lose")
  local Img_Quit = stateUI:FindDirect("Img_Quit")
  local Img_Fight = stateUI:FindDirect("Img_Fight")
  local Img_Prepare = stateUI:FindDirect("Img_Prepare")
  Img_Win:SetActive(false)
  Img_Lose:SetActive(false)
  Img_Quit:SetActive(false)
  Img_Fight:SetActive(false)
  Img_Prepare:SetActive(false)
  if state == GANG_INFO_STATE.PREPARE then
    Img_Prepare:SetActive(true)
  end
  if state == GANG_INFO_STATE.WIN then
    Img_Win:SetActive(true)
  end
  if state == GANG_INFO_STATE.LOSE then
    Img_Lose:SetActive(true)
  end
  if state == GANG_INFO_STATE.FIGHT then
    Img_Fight:SetActive(true)
  end
  if state == GANG_INFO_STATE.QUIT then
    Img_Quit:SetActive(true)
  end
end
def.method().HidePanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Join" then
    self:onBtnJoinClick()
  elseif id == "Btn_Help" then
    self:onBtnHelpClick()
  else
    warn("-------------------- panel click btn:", id)
  end
end
def.static("number", "table").SendEnterCrossCompeteMapReq = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crosscompete.CEnterCrossCompeteMapReq").new())
  end
end
def.method().onBtnJoinClick = function(self)
  local time = self:GetActTime()
  if time > 0 then
    Toast(textRes.GangCross[28])
  else
    CommonConfirmDlg.ShowConfirm("", textRes.GangCross[19], VersusListPanel.SendEnterCrossCompeteMapReq, {})
  end
end
def.method().onBtnHelpClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701609958)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
return VersusListPanel.Commit()

local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GangMergeRequestsPanel = Lplus.Extend(ECPanelBase, "GangMergeRequestsPanel")
local def = GangMergeRequestsPanel.define
local instance
def.field(GangData).data = nil
def.field("boolean").bWaitData = false
def.field("table").gangList = nil
def.field("table").uiTbl = nil
def.field("table").selectedGang = nil
def.static("=>", GangMergeRequestsPanel).Instance = function(self)
  if nil == instance then
    instance = GangMergeRequestsPanel()
    instance.data = GangData.Instance()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self.bWaitData = true
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeReqListReceived, GangMergeRequestsPanel.OnGangMergeReqListRecv)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, GangMergeRequestsPanel.OnGangChange)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CCombineGangApplicantsReq").new())
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeReqListReceived, GangMergeRequestsPanel.OnGangMergeReqListRecv)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, GangMergeRequestsPanel.OnGangChange)
end
def.static("table", "table").OnGangMergeReqListRecv = function(params, context)
  local self = GangMergeRequestsPanel.Instance()
  self.gangList = params[1]
  if self.bWaitData == true then
    self.bWaitData = false
    self:SetModal(true)
    self:CreatePanel(RESPATH.PREFAB_GANG_MERGE_REQ_PANEL, 1)
  end
end
def.static("table", "table").OnGangChange = function(params, context)
  if params and params.isBaseInfo then
    GangMergeRequestsPanel.Instance():DestroyPanel()
  end
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow == false then
    return
  end
  self:UpdateUI()
end
def.method().InitUI = function(self)
  self.uiTbl = {}
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiTbl["Scroll View"] = Img_Bg:FindDirect("Group_List/Scroll View")
  self.uiTbl.List_Left = self.uiTbl["Scroll View"]:FindDirect("List_Left")
end
def.method().UpdateUI = function(self)
  self:FillGangList()
end
def.method("string").ShowEmptyListBg = function(self, content)
end
def.method().FillGangList = function(self)
  local gangAmount = #self.gangList
  local uiList = self.uiTbl.List_Left:GetComponent("UIList")
  uiList:set_itemCount(gangAmount)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local gangs = uiList:get_children()
  for i = 1, gangAmount do
    local gang = gangs[i]
    local gangInfo = self.gangList[i]
    self:FillGangInfo(gang, i, gangInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  self.uiTbl["Scroll View"]:GetComponent("UIScrollView"):ResetPosition()
  if 0 == gangAmount then
    self:ShowEmptyListBg(textRes.Gang[264])
  end
end
def.method("userdata", "number", "table").FillGangInfo = function(self, gang, index, gangInfo)
  local Label_ID = gang:FindDirect(string.format("Label_ID_%d", index))
  local Label_GangName = gang:FindDirect(string.format("Label_GangName_%d", index))
  local Label_RoleName = gang:FindDirect(string.format("Label_RoleName_%d", index))
  local Label_Level = gang:FindDirect(string.format("Label_Level_%d", index))
  local Label_Num = gang:FindDirect(string.format("Label_Num_%d", index))
  local gangDisplayId = GangUtility.GangIdToDisplayID(gangInfo.displayid, gangInfo.gangid)
  Label_ID:GetComponent("UILabel"):set_text(Int64.tostring(gangDisplayId))
  Label_GangName:GetComponent("UILabel"):set_text(gangInfo.name)
  Label_RoleName:GetComponent("UILabel"):set_text(gangInfo.leader_name)
  Label_Level:GetComponent("UILabel"):set_text(gangInfo.level)
  Label_Num:GetComponent("UILabel"):set_text(string.format("%d/%d", gangInfo.normal_num, gangInfo.normal_capacity))
  local Img_Bg1 = gang:FindDirect(string.format("Img_Bg1_%d", index))
  local Img_Bg2 = gang:FindDirect(string.format("Img_Bg2_%d", index))
  if index % 2 == 0 then
    Img_Bg1:SetActive(false)
    Img_Bg2:SetActive(true)
  else
    Img_Bg1:SetActive(true)
    Img_Bg2:SetActive(false)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Modal" == id then
    self:DestroyPanel()
  elseif string.find(id, "Btn_AgreeCombine") then
    local index = string.sub(id, #"Btn_AgreeCombine_" + 1, -1)
    self:AgreeCombine(tonumber(index))
  elseif string.find(id, "Btn_ConnectChief") then
    local index = string.sub(id, #"Btn_ConnectChief_" + 1, -1)
    self:ContactLeader(tonumber(index))
  elseif "Btn_RejectAll" == id then
    self:OnClickRejectAll()
  elseif "Btn_TipInfo" == id then
    self:OnBtnShowTip()
  else
    warn("------------------------clickobj:", id)
  end
end
def.static("number", "table").SendCombineGang = function(i, tag)
  if i == 1 then
    local CCombineGangApplyRep = require("netio.protocol.mzm.gsp.gang.CCombineGangApplyRep")
    local REPLY_AGREE = CCombineGangApplyRep.REPLY_AGREE
    gmodule.network.sendProtocol(CCombineGangApplyRep.new(tag.gangid, REPLY_AGREE))
    local self = GangMergeRequestsPanel.Instance()
    self.gangList = {}
    self:UpdateUI()
  end
end
def.method("number").AgreeCombine = function(self, index)
  local gangInfo = self.gangList[index]
  if not gangInfo then
    return
  end
  self.data:SaveGangName(gangInfo.gangid, gangInfo.name)
  local tag = {
    gangid = gangInfo.gangid
  }
  CommonConfirmDlg.ShowConfirm("", textRes.Gang[302], GangMergeRequestsPanel.SendCombineGang, tag)
end
def.method("number").ContactLeader = function(self, index)
  local gangInfo = self.gangList[index]
  if not gangInfo then
    return
  end
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  local ChatModule = require("Main.Chat.ChatModule")
  SocialDlg.ShowSocialDlg(1)
  ChatModule.Instance():ClearFriendNewCount(gangInfo.leader_id)
  ChatModule.Instance():StartPrivateChat3(gangInfo.leader_id, gangInfo.leader_name, gangInfo.leader_level, gangInfo.leader_menpai, gangInfo.leader_gender, gangInfo.leader_avatarid, gangInfo.leader_avatar_frame)
end
def.method().OnClickRejectAll = function(self)
  local CCombineGangApplyRep = require("netio.protocol.mzm.gsp.gang.CCombineGangApplyRep")
  local REPLY_REFUSE = CCombineGangApplyRep.REPLY_REFUSE
  local gangAmount = #self.gangList
  for i = 1, gangAmount do
    local gangInfo = self.gangList[i]
    if gangInfo then
      gmodule.network.sendProtocol(CCombineGangApplyRep.new(gangInfo.gangid, REPLY_REFUSE))
    end
  end
  self.gangList = {}
  self:UpdateUI()
end
def.method().OnBtnShowTip = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701602021)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
return GangMergeRequestsPanel.Commit()

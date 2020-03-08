local Lplus = require("Lplus")
local MembersTabSonNode = require("Main.Gang.ui.MembersTabSonNode")
local GangMembersNode = Lplus.ForwardDeclare("GangMembersNode")
local GangPurposeNode = Lplus.Extend(MembersTabSonNode, "GangPurposeNode")
local HaveGangPanel = Lplus.ForwardDeclare("HaveGangPanel")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local ChangeGangNamePanel = require("Main.Gang.ui.ChangeGangNamePanel")
local GangAnnouncementPanel = require("Main.Gang.ui.GangAnnouncementPanel")
local GangGroupMgr = require("Main.Gang.GangGroup.GangGroupMgr")
local GangGroupData = require("Main.Gang.GangGroup.GangGroupData")
local GangGroupUtility = require("Main.Gang.GangGroup.GangGroupUtility")
local def = GangPurposeNode.define
local instance
def.static("=>", GangPurposeNode).Instance = function()
  if instance == nil then
    instance = GangPurposeNode()
  end
  return instance
end
def.override(HaveGangPanel, "userdata").Init = function(self, base, node)
  MembersTabSonNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:UpdateInfo()
end
def.override().OnHide = function(self)
end
def.method().UpdateInfo = function(self)
  self:UpdateGangName()
  self:UpdateGangPurpose()
  self:UpdateButton()
  self:UpdateGangGroupInfo()
end
def.method().UpdateGangName = function(self)
  local Label_GangName = self.m_node:FindDirect("Label_GangName")
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  Label_GangName:GetComponent("UILabel"):set_text(gangInfo.name)
  local Label_Lv = Label_GangName:FindDirect("Label_Lv")
  Label_Lv:GetComponent("UILabel"):set_text(string.format(textRes.Gang[355], gangInfo.level))
  local Group_Member = self.m_node:FindDirect("Group_Member")
  local Label_MemNum = Group_Member:FindDirect("Label_MemNum"):GetComponent("UILabel")
  local bangzhongId = GangUtility.GetGangConsts("BANGZHONG_ID")
  local bangzhongMax = GangUtility.GetDutyMaxNum(bangzhongId, gangInfo.wingLevel)
  local onlineBangzhong, allBangzhong = GangData.Instance():GetOnlineAndAllBangzhongNum()
  Label_MemNum:set_text(string.format("%d/%d/%d", onlineBangzhong, allBangzhong, bangzhongMax))
  local Label_PreMemNum = Group_Member:FindDirect("Label_PreMemNum"):GetComponent("UILabel")
  local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
  local xuetuMax = GangUtility.GetDutyMaxNum(xuetuId, gangInfo.wingLevel)
  local onlineXuetu, allXuetu, promoteXuetu = GangData.Instance():GetXuetuNumOnlineAllPromote()
  Label_PreMemNum:set_text(string.format("%d/%d/%d", onlineXuetu, allXuetu, xuetuMax))
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  if nil == memberInfo then
    return
  end
  local tbl = GangUtility.GetAuthority(memberInfo.duty)
  local Img_Full = Group_Member:FindDirect("Img_Full")
  local isMemberFull = bangzhongMax <= allBangzhong
  Img_Full:SetActive(isMemberFull and tbl.isCanAssignDuty)
end
def.method().UpdateGangPurpose = function(self)
  local Label_Tenet = self.m_node:FindDirect("Label_Tenet"):GetComponent("UILabel")
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  Label_Tenet:set_text(gangInfo.purpose)
end
def.method().UpdateButton = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  if nil == memberInfo then
    return
  end
  self.m_node:FindDirect("Btn_ChangName"):SetActive(false)
  self.m_node:FindDirect("Btn_ChangTenet"):SetActive(false)
  local tbl = GangUtility.GetAuthority(memberInfo.duty)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local minLevel = GangUtility.GetGangConsts("MODIFY_NAME_MIN_GANG_LV")
  if tbl.isCanModifyName and minLevel <= gangInfo.level then
    self.m_node:FindDirect("Btn_ChangName"):SetActive(true)
  end
  if tbl.isCanModifyPurpose then
    self.m_node:FindDirect("Btn_ChangTenet"):SetActive(true)
  end
end
def.method().UpdateGangGroupInfo = function(self)
  local gangId = require("Main.Gang.GangModule").Instance().data:GetGangId()
  if not gangId then
    return
  end
  warn("<------Gang Id------>", gangId)
  local Group_QQ = self.m_node:FindDirect("Group_QQ")
  local Group_Weixin = self.m_node:FindDirect("Group_Weixin")
  Group_QQ:SetActive(false)
  Group_Weixin:SetActive(false)
  local groupUIRoot
  if _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.WX then
    Group_QQ:SetActive(false)
    Group_Weixin:SetActive(true)
    groupUIRoot = Group_Weixin
  elseif _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ then
    Group_Weixin:SetActive(false)
    if _G.platform == _G.Platform.android then
      Group_QQ:SetActive(true)
      groupUIRoot = Group_QQ
    elseif _G.platform == _G.Platform.ios then
      Group_QQ:SetActive(false)
    end
  end
  if not groupUIRoot then
    return
  end
  local isBangzhu = GangGroupUtility.IsBangzhu()
  local isGroupBound = GangGroupData.Instance():IsGroupBound()
  local isJoinedGroup = GangGroupData.Instance():IsInGroup()
  local gangGroupID = GangGroupUtility.GetGangGroupId()
  warn("\229\184\174\230\180\190\231\190\164ID:", gangGroupID)
  warn("\230\152\175\229\144\166\229\184\174\228\184\187:", isBangzhu)
  warn("\230\152\175\229\144\166\233\130\166\231\190\164:", isGroupBound)
  warn("\230\152\175\229\144\166\229\138\160\231\190\164:", isJoinedGroup)
  groupUIRoot:FindDirect("Label_Uncreated"):SetActive(not isGroupBound)
  groupUIRoot:FindDirect("Label_Created"):SetActive(isGroupBound and isBangzhu and isJoinedGroup)
  groupUIRoot:FindDirect("Label_Unjoined"):SetActive(isGroupBound and not isJoinedGroup)
  groupUIRoot:FindDirect("Label_Joined"):SetActive(isGroupBound and not isBangzhu and isJoinedGroup)
  groupUIRoot:FindDirect("Texture2"):SetActive(isGroupBound)
  groupUIRoot:FindDirect("Btn_Create"):SetActive(not isGroupBound and isBangzhu)
  groupUIRoot:FindDirect("Btn_Depart"):SetActive(_G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ and isGroupBound and isBangzhu and isJoinedGroup)
  local GroupOpenId = GangGroupData.Instance():GetQQGroupOpenID()
  groupUIRoot:FindDirect("Btn_Join"):SetActive(isGroupBound and not isJoinedGroup and (_G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.WX or GroupOpenId ~= ""))
end
def.method().OnChangeNameClick = function(self)
  ChangeGangNamePanel.ShowChangeGangNamePanel(nil, nil, true)
end
def.method().OnChangePurposeClick = function(self)
  ChangeGangNamePanel.ShowChangeGangNamePanel(nil, nil, false)
end
def.method().OnMemNumClick = function(self)
  local tipsId = 701602012
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 118, 148)
end
def.method().OnStuNumClick = function(self)
  local tipsId = 701602012
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 118, 148)
end
def.method().OnMemberFullClick = function(self)
  local tipsId = 701602010
  local GUIUtils = require("GUI.GUIUtils")
  local Img_Full = self.m_node:FindDirect("Group_Member/Img_Full")
  local y = Img_Full:get_localPosition().y
  GUIUtils.ShowHoverTip(tipsId, 0, y - 80)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_ChangName" == id then
    self:OnChangeNameClick()
  elseif "Btn_ChangTenet" == id then
    self:OnChangePurposeClick()
  elseif "Label_MemNum" == id or "Label_GangMember" == id then
    self:OnMemNumClick()
  elseif "Label_PreMemNum" == id or "Label_GangPreMem" == id then
    self:OnStuNumClick()
  elseif "Btn_Create" == id then
    GangGroupMgr.Instance():BindGangGroup()
  elseif "Btn_Join" == id then
    GangGroupMgr.Instance():JoinGangGroup()
  elseif "Btn_Depart" == id then
    self:RequestUnbindGangGroup()
  elseif "Img_Full" == id then
    self:OnMemberFullClick()
  end
end
def.method().RequestUnbindGangGroup = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Gang[287], textRes.Gang[288], function(id, tag)
    if id == 1 then
      GangGroupMgr.Instance():UnbindGangGroup()
    end
  end, nil)
end
GangPurposeNode.Commit()
return GangPurposeNode

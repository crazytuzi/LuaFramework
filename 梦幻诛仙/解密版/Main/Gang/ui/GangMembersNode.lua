local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local GangMemberInfoNode = require("Main.Gang.ui.GangMemberInfoNode")
local GangPurposeNode = require("Main.Gang.ui.GangPurposeNode")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangMembersNode = Lplus.Extend(TabNode, "GangMembersNode")
local def = GangMembersNode.define
local NodeId = {PURPOSE = 1, MEMBERINFO = 2}
local TitleSortType = {
  GangData.SortType.Name,
  GangData.SortType.Level,
  GangData.SortType.Occupation,
  GangData.SortType.Duty,
  GangData.SortType.Banggong,
  GangData.SortType.Offline
}
def.const("table").NodeId = NodeId
def.field("table").nodes = nil
def.field("table").tabToggles = nil
def.field("number").curNode = 0
def.field("userdata").Group_Left = nil
def.field("userdata").Group_Right = nil
def.field("userdata").Group_Title = nil
def.field("userdata").Notice_Img_Red = nil
def.field(GangData).data = nil
def.field("table").selectMember = nil
def.field("boolean").bWaitToMemberInfo = false
def.field("userdata").selectRoleId = nil
local instance
def.static("=>", GangMembersNode).Instance = function()
  if instance == nil then
    instance = GangMembersNode()
  end
  return instance
end
def.method("userdata").SetSelectMemberId = function(self, roleId)
  self.selectRoleId = roleId
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self:InitTabNodes()
  self.data = GangData.Instance()
  self.data:InitSortMemberList()
end
def.method().InitTabNodes = function(self)
  if not self.m_node or self.m_node.isnil then
    return
  end
  self.Group_Left = self.m_node:FindDirect("Group_Left")
  self.Group_Right = self.m_node:FindDirect("Group_Right")
  self.Group_Title = self.Group_Left:FindDirect("Group_Title")
  self.Notice_Img_Red = self.Group_Right:FindDirect("Btn_Notice/Img_Red")
  self.Notice_Img_Red:SetActive(GangData.Instance():IsHaveNewGangNotice())
  self.nodes = {}
  local purposeNode = self.Group_Right:FindDirect("Group_Tenet")
  self.nodes[GangMembersNode.NodeId.PURPOSE] = GangPurposeNode.Instance()
  self.nodes[GangMembersNode.NodeId.PURPOSE]:Init(self.m_base, purposeNode)
  local infoNode = self.Group_Right:FindDirect("Group_Info")
  self.nodes[GangMembersNode.NodeId.MEMBERINFO] = GangMemberInfoNode.Instance()
  self.nodes[GangMembersNode.NodeId.MEMBERINFO]:Init(self.m_base, infoNode)
  self.tabToggles = {}
  local purposeTabObj = self.Group_Right:FindDirect("Tab_Tenet")
  self.tabToggles[GangMembersNode.NodeId.PURPOSE] = purposeTabObj:GetComponent("UIToggle")
  local infoTabObj = self.Group_Right:FindDirect("Tab_Info")
  self.tabToggles[GangMembersNode.NodeId.MEMBERINFO] = infoTabObj:GetComponent("UIToggle")
  self.curNode = GangMembersNode.NodeId.PURPOSE
  self.tabToggles[self.curNode].value = true
end
def.override().OnShow = function(self)
  if self.selectRoleId then
    self.selectMember = GangData.Instance():GetMemberInfoByRoleId(self.selectRoleId)
    if self.selectMember then
      self.curNode = GangMembersNode.NodeId.MEMBERINFO
    end
  end
  if GangMembersNode.NodeId.PURPOSE == self.curNode then
    self.nodes[self.curNode]:Show()
  elseif GangMembersNode.NodeId.MEMBERINFO == self.curNode then
    self:RequireToSwitchToMemberInfo()
  end
  GameUtil.AddGlobalTimer(0.01, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self:FillMembersNewList(true)
    end
  end)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberModelInfo, GangMembersNode.OnMemberModelInfoChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberInfo, GangMembersNode.OnMemberInfoChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, GangMembersNode.OnNewMember)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_PurposeChanged, GangMembersNode.OnGangPurposeChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NameChanged, GangMembersNode.OnGangNameChange)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, GangMembersNode.OnFriendChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GroupStateChanged, GangMembersNode.OnGangGroupStateChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Offline, GangMembersNode.OnMemberUpdate)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NewAnno, GangMembersNode.OnGetNewAnno)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberModelInfo, GangMembersNode.OnMemberModelInfoChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberInfo, GangMembersNode.OnMemberInfoChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, GangMembersNode.OnNewMember)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_PurposeChanged, GangMembersNode.OnGangPurposeChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NameChanged, GangMembersNode.OnGangNameChange)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, GangMembersNode.OnFriendChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GroupStateChanged, GangMembersNode.OnGangGroupStateChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Offline, GangMembersNode.OnMemberUpdate)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NewAnno, GangMembersNode.OnGetNewAnno)
  self.nodes[self.curNode]:Hide()
  self.bWaitToMemberInfo = false
  self.selectRoleId = nil
end
def.method("number").SwitchTo = function(self, nodeId)
  if self.curNode == nodeId then
    return
  end
  self.nodes[self.curNode]:Hide()
  self.curNode = nodeId
  self.nodes[self.curNode]:Show()
end
def.method("boolean").FillMembersNewList = function(self, bResetScrollView)
  local memberList = self.data:GetMemberList()
  local scrollViewObj = self.Group_Left:FindDirect("Group_List/Scroll View")
  local scrollListObj = scrollViewObj:FindDirect("List_Left")
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillMemberInfo(item, i, memberList[i])
  end)
  ScrollList_setCount(uiScrollList, #memberList)
  self.m_base.m_msgHandler:Touch(scrollListObj)
  if bResetScrollView then
    scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
  end
end
def.method("userdata", "number", "table").FillMemberInfo = function(self, memberUI, index, memberInfo)
  local Label_GangName = memberUI:FindDirect("Label_GangName")
  local Label_ZhuangTai = memberUI:FindDirect("Label_ZhuangTai")
  local Label_School = memberUI:FindDirect("Label_School")
  local Label_Job = memberUI:FindDirect("Label_Job")
  local Label_Level = memberUI:FindDirect("Label_Level")
  local Label_GongNum = memberUI:FindDirect("Label_GongNum")
  Label_GangName:GetComponent("UILabel"):set_text(memberInfo.name)
  if -1 == memberInfo.offlineTime then
    Label_ZhuangTai:GetComponent("UILabel"):set_text(textRes.Gang[285])
  else
    local time = GangUtility.GetTime(memberInfo.offlineTime)
    Label_ZhuangTai:GetComponent("UILabel"):set_text(time)
  end
  local occupationName = _G.GetOccupationName(memberInfo.occupationId)
  Label_School:GetComponent("UILabel"):set_text(occupationName)
  local dutyName = self.data:GetDutyName(memberInfo.duty)
  Label_Job:GetComponent("UILabel"):set_text(dutyName)
  Label_Level:GetComponent("UILabel"):set_text(memberInfo.level)
  local historyBangGong = memberInfo.historyBangGong
  if historyBangGong < 0 then
    historyBangGong = 0
  end
  Label_GongNum:GetComponent("UILabel"):set_text(string.format("%d/%d", memberInfo.curBangGong, historyBangGong))
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local setColor = Color.Color(0.56, 0.24, 0.13, 1)
  if heroProp.id == memberInfo.roleId then
    setColor = Color.Color(0, 0.686, 0, 1)
  end
  Label_GangName:GetComponent("UILabel"):set_textColor(setColor)
  Label_ZhuangTai:GetComponent("UILabel"):set_textColor(setColor)
  Label_School:GetComponent("UILabel"):set_textColor(setColor)
  Label_Job:GetComponent("UILabel"):set_textColor(setColor)
  Label_Level:GetComponent("UILabel"):set_textColor(setColor)
  memberUI:FindDirect("Label_Ji"):GetComponent("UILabel"):set_textColor(setColor)
  Label_GongNum:GetComponent("UILabel"):set_textColor(setColor)
  if self.selectMember and self.selectMember.roleId == memberInfo.roleId and self.curNode == GangMembersNode.NodeId.MEMBERINFO then
    memberUI:GetComponent("UIToggle"):set_value(true)
  else
    memberUI:GetComponent("UIToggle"):set_value(false)
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
def.method("string").SelectMember = function(self, name)
  local memberInfo = self.data:GetMemberInfoByRoleName(name)
  self.selectMember = memberInfo
  self:RequireToSwitchToMemberInfo()
end
def.method("number").SetSelectMemberInfo = function(self, index)
  local memberList = self.data:GetMemberList()
  local memberInfo = memberList[index]
  self.selectMember = memberInfo
end
def.method().RequireToSwitchToMemberInfo = function(self)
  if self.selectMember == nil then
    self:SetSelectMemberInfo(1)
  end
  self.nodes[GangMembersNode.NodeId.MEMBERINFO]:SetMemberInfo(nil)
  self.nodes[GangMembersNode.NodeId.MEMBERINFO]:SetMemberModelInfo(nil)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGetRoleModelReq").new(self.selectMember.roleId))
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.role.CGetRoleInfoReq").new(self.selectMember.roleId))
  self.bWaitToMemberInfo = true
end
def.method().UpdateButtonList = function(self)
  if self.curNode == GangMembersNode.NodeId.MEMBERINFO then
    if self.data:GetMemberInfoByRoleId(self.selectMember.roleId) ~= nil then
      self.nodes[self.curNode]:FillMemberButtons()
    else
      self:SwitchTo(GangMembersNode.NodeId.PURPOSE)
      local toggle = self.Group_Right:FindDirect("Tab_Tenet"):GetComponent("UIToggle")
      toggle:set_value(true)
      self.bWaitToMemberInfo = false
      self.selectMember = nil
    end
  end
end
def.method().OnGangAnnouncementClick = function(self)
  local GangAnnouncementPanel = require("Main.Gang.ui.GangAnnouncementPanel")
  GangAnnouncementPanel.ShowGangAnnouncementPanel(nil, nil)
  GangData.Instance():SetNewGangNotice(false)
  self.Notice_Img_Red:SetActive(false)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {0})
end
def.method().OnBackToGangClick = function(self)
  local HaveGangPanel = Lplus.ForwardDeclare("HaveGangPanel")
  HaveGangPanel.Instance():DestroyPanel()
  require("Main.Gang.GangModule").Instance():GotoGangMap()
end
def.method().OnManageClick = function(self)
  local bCanMngApplierList = false
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local memberInfo = self.data:GetMemberInfoByRoleId(heroProp.id)
  if memberInfo then
    local tbl = GangUtility.GetAuthority(memberInfo.duty)
    bCanMngApplierList = tbl.isCanMgeApplyList
  end
  if bCanMngApplierList then
    require("Main.Gang.ui.GangMemberManagementPanel").Instance():ShowPanel()
  else
    Toast(textRes.Gang[360])
  end
end
def.method().OnShowTipsClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701602022)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method().OnBtn_Org = function(self)
  require("Main.Gang.ui.GangArchitecturePanel").ShowDlg()
end
def.method("string").SelectTitle = function(self, name)
  local idx = tonumber(string.sub(name, #"Label_" + 1, -1))
  local sortTbl = self.data:GetSortTimesTbl()
  for k, v in ipairs(TitleSortType) do
    local ImgSelect = self.Group_Title:FindDirect("Label_" .. k .. "/Img_Select")
    if k == idx then
      local sortNum = sortTbl[v]
      ImgSelect:SetActive(true)
      ImgSelect:FindDirect("Label_Up"):SetActive(sortNum % 2 == 0)
      ImgSelect:FindDirect("Label_Down"):SetActive(sortNum % 2 == 1)
    else
      ImgSelect:SetActive(false)
    end
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Tab_Tenet" == id then
    self:SwitchTo(GangMembersNode.NodeId.PURPOSE)
    self.bWaitToMemberInfo = false
  elseif "Tab_Info" == id then
    self:RequireToSwitchToMemberInfo()
  elseif "Label_1" == id then
    self.data:AddSortTimes(GangData.SortType.Name)
    local sortTbl = self.data:GetSortTimesTbl()
    local memberTbl = self.data:GetMemberList()
    self.data:MembersSortByName(sortTbl, memberTbl)
    self:FillMembersNewList(true)
    self:SelectTitle(id)
  elseif "Label_2" == id then
    self.data:AddSortTimes(GangData.SortType.Level)
    local sortTbl = self.data:GetSortTimesTbl()
    local memberTbl = self.data:GetMemberList()
    self.data:MembersSortByLevel(sortTbl, memberTbl)
    self:FillMembersNewList(true)
    self:SelectTitle(id)
  elseif "Label_3" == id then
    self.data:AddSortTimes(GangData.SortType.Occupation)
    local sortTbl = self.data:GetSortTimesTbl()
    local memberTbl = self.data:GetMemberList()
    self.data:MembersSortByOccupation(sortTbl, memberTbl)
    self:FillMembersNewList(true)
    self:SelectTitle(id)
  elseif "Label_4" == id then
    self.data:AddSortTimes(GangData.SortType.Duty)
    local sortTbl = self.data:GetSortTimesTbl()
    local memberTbl = self.data:GetMemberList()
    self.data:MembersSortByDuty(sortTbl, memberTbl)
    self:FillMembersNewList(true)
    self:SelectTitle(id)
  elseif "Label_5" == id then
    self.data:AddSortTimes(GangData.SortType.Banggong)
    local sortTbl = self.data:GetSortTimesTbl()
    local memberTbl = self.data:GetMemberList()
    self.data:MembersSortByBanggong(sortTbl, memberTbl)
    self:FillMembersNewList(true)
    self:SelectTitle(id)
  elseif "Label_6" == id then
    self.data:AddSortTimes(GangData.SortType.Offline)
    local sortTbl = self.data:GetSortTimesTbl()
    local memberTbl = self.data:GetMemberList()
    self.data:MembersSortByOfflineTime(sortTbl, memberTbl)
    self:FillMembersNewList(true)
    self:SelectTitle(id)
  elseif string.sub(id, 1, #"Group_List") == "Group_List" then
    local item, idx = ScrollList_getItem(clickobj)
    if not item then
      return
    end
    if item:GetComponent("UIToggle"):get_isChecked() then
      local name = item:FindDirect("Label_GangName"):GetComponent("UILabel"):get_text()
      self:SelectMember(name)
    end
  elseif "Btn_Notice" == id then
    self:OnGangAnnouncementClick()
  elseif "Btn_Back" == id then
    self:OnBackToGangClick()
  elseif "Btn_Manage" == id then
    self:OnManageClick()
  elseif "Btn_Tips" == id then
    self:OnShowTipsClick()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  elseif "Btn_Org" == id then
    self:OnBtn_Org()
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
  end
end
def.override("string").onDragStart = function(self, id)
  self.nodes[self.curNode]:onDragStart(id)
end
def.override("string").onDragEnd = function(self, id)
  self.nodes[self.curNode]:onDragEnd(id)
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.nodes[self.curNode]:onDrag(id, dx, dy)
end
def.method("table").OnMemberModelInfo = function(self, modelInfo)
  self.nodes[GangMembersNode.NodeId.MEMBERINFO]:SetMemberModelInfo(modelInfo)
  self.nodes[GangMembersNode.NodeId.MEMBERINFO]:SetSelectMemberRoleId(self.selectMember.roleId)
  if self.bWaitToMemberInfo and self.nodes[GangMembersNode.NodeId.MEMBERINFO]:GetMemberInfo() then
    if self.curNode == GangMembersNode.NodeId.MEMBERINFO then
      self.nodes[self.curNode]:Show()
    else
      self:SwitchTo(GangMembersNode.NodeId.MEMBERINFO)
    end
    local toggle = self.Group_Right:FindDirect("Tab_Info"):GetComponent("UIToggle")
    toggle:set_value(true)
  end
end
def.static("table", "table").OnMemberModelInfoChange = function(params, tbl)
  instance:OnMemberModelInfo(params[1])
end
def.method("table").OnMemberInfo = function(self, info)
  if not self.selectMember then
    return
  end
  self.nodes[GangMembersNode.NodeId.MEMBERINFO]:SetMemberInfo(info)
  self.nodes[GangMembersNode.NodeId.MEMBERINFO]:SetSelectMemberRoleId(self.selectMember.roleId)
  if self.bWaitToMemberInfo and self.nodes[GangMembersNode.NodeId.MEMBERINFO]:GetMemberModelInfo() then
    if self.curNode == GangMembersNode.NodeId.MEMBERINFO then
      self.nodes[self.curNode]:Show()
    else
      self:SwitchTo(GangMembersNode.NodeId.MEMBERINFO)
    end
    local toggle = self.Group_Right:FindDirect("Tab_Info"):GetComponent("UIToggle")
    toggle:set_value(true)
  end
end
def.static("table", "table").OnMemberInfoChange = function(params, tbl)
  instance:OnMemberInfo(params[1])
end
def.static("table", "table").OnNewMember = function(params, tbl)
  instance:FillMembersNewList(false)
  instance:UpdateButtonList()
end
def.static("table", "table").OnGangPurposeChange = function(params, tbl)
  instance.nodes[GangMembersNode.NodeId.PURPOSE]:UpdateGangPurpose()
end
def.static("table", "table").OnFriendChanged = function(params, tbl)
  instance:UpdateButtonList()
end
def.static("table", "table").OnGangNameChange = function(params, tbl)
  instance.nodes[GangMembersNode.NodeId.PURPOSE]:UpdateGangName()
end
def.static("table", "table").OnGangGroupStateChange = function(params, tbl)
  warn("***Group Test--->GangMemberNode--->OnGangGroupStateChanged")
  instance.nodes[GangMembersNode.NodeId.PURPOSE]:UpdateGangGroupInfo()
  local GangGroupUtility = require("Main.Gang.GangGroup.GangGroupUtility")
  GangGroupUtility.CheckShowBindGroupPrompt()
  GangGroupUtility.CheckShowJoinGroupPrompt()
end
def.static("table", "table").OnMemberUpdate = function(params, tbl)
  instance:FillMembersNewList(false)
end
def.static("table", "table").OnGetNewAnno = function(params, context)
  if instance and instance.Notice_Img_Red then
    instance.Notice_Img_Red:SetActive(true)
  end
end
GangMembersNode.Commit()
return GangMembersNode

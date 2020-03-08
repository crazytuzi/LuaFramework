local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local FriendUtils = Lplus.ForwardDeclare("FriendUtils")
local GangApplicantsPanel = Lplus.Extend(ECPanelBase, "GangApplicantsPanel")
local def = GangApplicantsPanel.define
local instance
local ApplicantState = {
  APPLY = 1,
  ADMITTED = 2,
  DELETED = 3
}
def.field("table").uiTbl = nil
def.field(GangData).data = nil
def.field("table").dataSnapshot = nil
def.static("=>", GangApplicantsPanel).Instance = function(self)
  if nil == instance then
    instance = GangApplicantsPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  self.data = GangData.Instance()
  self:GetDataSnapshot()
  self:CreatePanel(RESPATH.PREFAB_GANG_APPLIER_LIST, 2)
  self:SetModal(true)
end
def.method().GetDataSnapshot = function(self)
  local applierList = GangData.Instance():GetApplierList()
  self.dataSnapshot = {}
  if #applierList == 0 then
    return
  end
  for i = 1, #applierList do
    local data = {}
    data.applicant = applierList[i]
    data.state = ApplicantState.APPLY
    table.insert(self.dataSnapshot, data)
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ClearApplierList, GangApplicantsPanel.ClearApplierList)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_RemoveApplier, GangApplicantsPanel.RemoveApplier)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, GangApplicantsPanel.OnMemberChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, GangApplicantsPanel.OnNewMember)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ClearApplierList, GangApplicantsPanel.ClearApplierList)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_RemoveApplier, GangApplicantsPanel.RemoveApplier)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, GangApplicantsPanel.OnMemberChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, GangApplicantsPanel.OnNewMember)
  self.data = nil
  self.uiTbl = nil
  self.dataSnapshot = nil
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:UpdateList(true)
end
def.method().InitUI = function(self)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  self.uiTbl = {}
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Right = Img_Bg0:FindDirect("Group_Right")
  self.uiTbl.Group_Empty = Group_Right:FindDirect("Group_Empty")
  self.uiTbl.Group_List = Group_Right:FindDirect("Group_List")
  self.uiTbl["Scroll View"] = Group_Right:FindDirect("Group_List/Scroll View")
  self.uiTbl.Btn_Clear = Group_Right:FindDirect("Btn_Clear")
  self.uiTbl.Btn_Approve = Group_Right:FindDirect("Btn_Approve")
  self.uiTbl.Label_MemberNumber = Img_Bg0:FindDirect("Label_MemberNumber")
  self.uiTbl.Label_StudentNumber = Img_Bg0:FindDirect("Label_StudentNumber")
  self:ShowMemberInfo()
end
def.method().ShowMemberInfo = function(self)
  local gangInfo = self.data:GetGangBasicInfo()
  if gangInfo and self.uiTbl then
    local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
    local xuetuMax = GangUtility.GetDutyMaxNum(xuetuId, gangInfo.wingLevel)
    local onlineXuetu, allXuetu = self.data:GetXuetuNumOnlineAllPromote()
    local bangzhongId = GangUtility.GetGangConsts("BANGZHONG_ID")
    local bangzhongMax = GangUtility.GetDutyMaxNum(bangzhongId, gangInfo.wingLevel)
    local onlineBangzhong, allBangzhong = self.data:GetOnlineAndAllBangzhongNum()
    self.uiTbl.Label_MemberNumber:GetComponent("UILabel"):set_text(string.format("%d/%d", allBangzhong, bangzhongMax))
    self.uiTbl.Label_StudentNumber:GetComponent("UILabel"):set_text(string.format("%d/%d", allXuetu, xuetuMax))
  end
end
def.method("boolean").UpdateList = function(self, bRefresh)
  local applierAmount = #self.dataSnapshot
  if applierAmount == 0 then
    self.uiTbl.Group_List:SetActive(false)
    self.uiTbl.Group_Empty:SetActive(true)
    self.uiTbl.Btn_Clear:SetActive(false)
    self.uiTbl.Btn_Approve:SetActive(false)
    return
  else
    self.uiTbl.Group_List:SetActive(true)
    self.uiTbl.Group_Empty:SetActive(false)
    self.uiTbl.Btn_Clear:SetActive(true)
    self.uiTbl.Btn_Approve:SetActive(true)
  end
  local ScrollView = self.uiTbl.Group_List:FindDirect("Scroll View")
  local uiScrollView = ScrollView:GetComponent("UIScrollView")
  local Grid = ScrollView:FindDirect("Grid")
  local uiGrid = Grid:GetComponent("UIList")
  uiGrid:set_itemCount(applierAmount)
  uiGrid:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if uiGrid and not uiGrid.isnil then
      uiGrid:Reposition()
    end
  end)
  local appliers = uiGrid:get_children()
  for i = 1, applierAmount do
    local applierUI = appliers[i]
    local applierInfo = self.dataSnapshot[i].applicant
    self:FillApplierInfo(applierUI, i, applierInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  if bRefresh then
    GameUtil.AddGlobalLateTimer(0.01, true, function()
      if uiScrollView and not uiScrollView.isnil then
        uiScrollView:ResetPosition()
      end
    end)
  end
end
def.method("userdata", "number", "table").FillApplierInfo = function(self, applierUI, index, applierInfo)
  warn("[GangHelpPanel:FillApplierInfo] applierInfo.avatarId:", applierInfo.avatarId)
  local Img_IconHead = applierUI:FindDirect(string.format("Img_IconHead_%d", index))
  _G.SetAvatarIcon(Img_IconHead, applierInfo.avatarId, applierInfo.avatar_frame or 0)
  local Label_Name = applierUI:FindDirect(string.format("Label_Name_%d", index)):GetComponent("UILabel")
  Label_Name:set_text(applierInfo.name)
  local Label_Lv = applierUI:FindDirect(string.format("Label_Lv_%d", index)):GetComponent("UILabel")
  Label_Lv:set_text(applierInfo.level)
  local Img_School = applierUI:FindDirect(string.format("Img_School_%d", index))
  local occupationIconId = FriendUtils.GetOccupationIconId(applierInfo.occupationId)
  local occupationSprite = Img_School:GetComponent("UISprite")
  FriendUtils.FillIcon(occupationIconId, occupationSprite, 3)
  local GUIUtils = require("GUI.GUIUtils")
  local genderIcon = applierUI:FindDirect("Img_Sex_" .. index)
  GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(applierInfo.gender))
  local Label_NameJian = applierUI:FindDirect(string.format("Label_NameJian_%d", index)):GetComponent("UILabel")
  if applierInfo.inviterName ~= nil and applierInfo.inviterName ~= "" then
    Label_NameJian:set_text(applierInfo.inviterName)
    applierUI:FindDirect(string.format("Label_YinJian_%d", index)):SetActive(true)
  else
    Label_NameJian:set_text("")
    applierUI:FindDirect(string.format("Label_YinJian_%d", index)):SetActive(false)
  end
end
def.method("string").onClick = function(self, id)
  if "Modal" == id then
    self:DestroyPanel()
  elseif "Btn_Close" == id then
    self:DestroyPanel()
  elseif string.sub(id, 1, #"Btn_Agree_") == "Btn_Agree_" then
    local index = tonumber(string.sub(id, #"Btn_Agree_" + 1, -1))
    self:OnAgreeApplyClick(index)
  elseif "Btn_Clear" == id then
    self:OnClearAllAppliersClick()
  elseif "Btn_Approve" == id then
    self:OnApproveAllAppliersClick()
  end
end
def.method("number").OnAgreeApplyClick = function(self, index)
  local applicantInfo = self.dataSnapshot[index]
  if not applicantInfo then
    return
  end
  if applicantInfo.state == ApplicantState.DELETED then
    Toast(textRes.Gang[262])
    table.remove(self.dataSnapshot, index)
    instance:UpdateList(false)
    return
  else
    applicantInfo.state = ApplicantState.ADMITTED
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CConfirmApplyJoinGangReq").new(applicantInfo.applicant.roleId))
  end
end
def.method().OnClearAllAppliersClick = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CClearApplyListReq").new())
end
def.method().OnApproveAllAppliersClick = function(self)
  local bNeedToRefresh = false
  local IdToDelete = {}
  for i = 1, #self.dataSnapshot do
    if self.dataSnapshot[i].state == ApplicantState.DELETED then
      IdToDelete[i] = true
      bNeedToRefresh = true
    else
      self.dataSnapshot[i].state = ApplicantState.ADMITTED
    end
  end
  if bNeedToRefresh == true then
    local newList = {}
    for i = 1, #self.dataSnapshot do
      if IdToDelete[i] ~= true then
        table.insert(newList, self.dataSnapshot[i])
      end
    end
    self.dataSnapshot = newList
    self:UpdateList(false)
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CConfirmApplyJoinGangListReq").new())
end
def.static("table", "table").ClearApplierList = function(params, tbl)
  instance.dataSnapshot = {}
  instance:UpdateList(false)
end
def.static("table", "table").RemoveApplier = function(params, tbl)
  local roleId = params[1]
  instance:OnRemoveApplicant(roleId)
end
def.static("table", "table").OnMemberChange = function(params, tbl)
  instance:ShowMemberInfo()
end
def.static("table", "table").OnNewMember = function(params, tbl)
  instance:ShowMemberInfo()
end
def.method("userdata").OnRemoveApplicant = function(self, roleId)
  if not self.dataSnapshot or #self.dataSnapshot == 0 then
    return
  end
  for i = 1, #self.dataSnapshot do
    local applicantInfo = self.dataSnapshot[i]
    if applicantInfo.applicant.roleId == roleId then
      if applicantInfo.state == ApplicantState.ADMITTED then
        table.remove(self.dataSnapshot, i)
        instance:UpdateList(false)
      else
        applicantInfo.state = ApplicantState.DELETED
      end
      return
    end
  end
end
return GangApplicantsPanel.Commit()

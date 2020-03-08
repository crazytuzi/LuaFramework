local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local RelationInfoNode = Lplus.Extend(TabNode, "RelationInfoNode")
local swornData = require("Main.Sworn.data.SwornData")
local PersonalInfoModule = require("Main.PersonalInfo.PersonalInfoModule")
local SocialPlatformMgr = require("Main.PersonalInfo.mgr.SocialPlatformMgr")
local QingYuanModule = require("Main.QingYuan.QingYuanModule")
local QingYuanMgr = require("Main.QingYuan.QingYuanMgr")
local Vector3 = require("Types.Vector3").Vector3
local def = RelationInfoNode.define
local DISABLE_SNS_BTN = true
def.field("table").uiTbl = nil
def.field("table").parentPanel = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  self.parentPanel = base
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateInfo()
  self:UpdateSNSBtnStatus()
  self:UpdateMasterTaskBtnStatus()
  Event.RegisterEventWithContext(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SOCIAL_PLATFORM_OPEN_CHANGE, RelationInfoNode.OnSocialPlatformOpenChange, self)
  Event.RegisterEventWithContext(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.QINGYUAN_INFO_CHANGE, RelationInfoNode.OnQingYuanInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, RelationInfoNode.OnFeatureOpenChange, self)
  Event.RegisterEventWithContext(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, RelationInfoNode.OnMasterTaskInfoChange, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SOCIAL_PLATFORM_OPEN_CHANGE, RelationInfoNode.OnSocialPlatformOpenChange)
  Event.UnregisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.QINGYUAN_INFO_CHANGE, RelationInfoNode.OnQingYuanInfoChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, RelationInfoNode.OnFeatureOpenChange)
  Event.UnregisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, RelationInfoNode.OnMasterTaskInfoChange)
end
def.method().InitUI = function(self)
  if not self.m_node or self.m_node.isnil then
    return
  end
  self.uiTbl = {}
  self.uiTbl.Scroll_View = self.m_node:FindDirect("Scroll View")
  self.uiTbl.Label_ParnterName = self.m_node:FindDirect("Scroll View/Group_Marriage/Label_ParnterName")
  self.uiTbl.Label_MasterName = self.m_node:FindDirect("Scroll View/Group_Master/Label_MasterName")
  self.uiTbl.Label_ApprenticeNum = self.m_node:FindDirect("Scroll View/Group_Master/Label_ApprenticeNum")
  self.uiTbl.Brother_Grid = self.m_node:FindDirect("Scroll View/Group_Brother/List_Brother")
  self.uiTbl.Brother_Grid_TemplateItem = self.m_node:FindDirect("Scroll View/Group_Brother/List_Brother/Item01")
  self.uiTbl.Label_NoBrother = self.m_node:FindDirect("Scroll View/Group_Brother/Label_NoBrother")
  self.uiTbl.Btn_ManageInfo = self.m_node:FindDirect("Btn_ManageInfo")
  self.uiTbl.Btn_PublishInfo = self.m_node:FindDirect("Btn_PublishInfo")
  self.uiTbl.Btn_PublishInfo = self.m_node:FindDirect("Btn_PublishInfo")
  self.uiTbl.Group_Lover = self.m_node:FindDirect("Scroll View/Group_Lover")
  self.uiTbl.Btn_MasterTask = self.m_node:FindDirect("Scroll View/Group_Master/Btn_MasterTask")
  self.uiTbl.Btn_MasterTask_Reddot = self.m_node:FindDirect("Scroll View/Group_Master/Btn_MasterTask/Sprite")
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_MarriageInfo" == id then
    self:OnBtnClickMarriageInfo()
  elseif "Btn_MasterInfo" == id then
    self:OnBtnClickMasterInfo()
  elseif "Btn_BrotherInfo" == id then
    self:OnBtnClickBrotherInfo()
  elseif "Btn_MarriageGoto" == id then
    self:OnBtnClickGotoMarriageNpc()
  elseif "Btn_MasterGoto" == id then
    self:OnBtnClickGotoMasterNpc()
  elseif "Btn_BrotherGoto" == id then
    self:OnBtnClickGotoBrotherNpc()
  elseif "Btn_ManageInfo" == id then
    PersonalInfoModule.OpenSNSInfoManagePanel()
  elseif "Btn_PublishInfo" == id then
    PersonalInfoModule.OpenPublishSNSInfoPanel(constant.SNSConsts.ALL_SUB_TYPE_ID)
  elseif "Btn_LoverInfo" == id then
    QingYuanModule.OpenQingYuanInfoPanel()
  elseif "Btn_LoverGoto" == id then
    self:OnBtnClickGotoQingYuanNpc()
  elseif "Btn_MasterTask" == id then
    self:OnBtnClickMasterTask()
  end
end
def.method().OnBtnClickMarriageInfo = function(self)
  Toast(textRes.Personal[101])
end
def.method().OnBtnClickMasterInfo = function(self)
  local shituRelationPanel = require("Main.Shitu.ui.ShituRelationPanel").Instance()
  shituRelationPanel:ShowShituRelation()
end
def.method().OnBtnClickBrotherInfo = function(self)
  Toast(textRes.Personal[101])
end
def.method().OnBtnClickGotoMarriageNpc = function(self)
  if self.parentPanel and self.parentPanel:IsShow() then
    self.parentPanel:DestroyPanel()
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.CMarriageConsts.marriageNPC
  })
end
def.method().OnBtnClickGotoMasterNpc = function(self)
  if self.parentPanel and self.parentPanel:IsShow() then
    self.parentPanel:DestroyPanel()
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.ShiTuConsts.shiTuNPCId
  })
end
def.method().OnBtnClickGotoBrotherNpc = function(self)
  if self.parentPanel and self.parentPanel:IsShow() then
    self.parentPanel:DestroyPanel()
  end
  local npcId = swornData.GetSwornConst("SWORN_NPC_ID")
  if npcId then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
  end
end
def.method().OnBtnClickGotoQingYuanNpc = function(self)
  if self.parentPanel and self.parentPanel:IsShow() then
    self.parentPanel:DestroyPanel()
  end
  QingYuanModule.GotoQingYuanNPC()
end
def.method().OnBtnClickMasterTask = function(self)
  if self.parentPanel and self.parentPanel:IsShow() then
    self.parentPanel:DestroyPanel()
  end
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_BTN_CLICK, nil)
end
def.method().UpdateInfo = function(self)
  local MarriageInterface = require("Main.Marriage.MarriageInterface")
  local isMarried = MarriageInterface.IsMarried()
  if isMarried then
    local mateInfo = MarriageInterface.GetMateInfo()
    self:SetParnterName(mateInfo.mateName)
  else
    self:SetParnterName(textRes.Personal[102])
  end
  local shituData = require("Main.Shitu.ShituData").Instance()
  local hasMaster = shituData:HasMaster()
  local tudiInfo = string.format(textRes.Personal[103], shituData:GetNowApprenticeCount())
  if hasMaster then
    self:SetMasterInfo(shituData:GetMaster().roleName, tudiInfo)
  else
    self:SetMasterInfo(textRes.Personal[104], tudiInfo)
  end
  self:SetSwornMemberName()
  self:SetQingYuanInfo()
  self.uiTbl.Scroll_View:GetComponent("UIScrollView"):ResetPosition()
end
def.method().SetSwornMemberName = function(self)
  local members = swornData.Instance():GetSwornMember()
  local memberCount = #members
  local hasMember = memberCount > 0
  self.uiTbl.Label_NoBrother:SetActive(not hasMember)
  local gridObj = self.uiTbl.Brother_Grid
  gridObj:SetActive(hasMember)
  if hasMember then
    local uiGrid = gridObj:GetComponent("UIGrid")
    local childCount = uiGrid:GetChildListCount()
    local allCount = memberCount < childCount and childCount or memberCount
    local templateItem = self.uiTbl.Brother_Grid_TemplateItem
    if not templateItem then
      return
    end
    for i = 1, allCount do
      local itemObj = gridObj:FindDirect(string.format("Item%02d", i))
      if itemObj == nil then
        itemObj = GameObject.Instantiate(templateItem)
        itemObj.name = string.format("Item%02d", i)
        uiGrid:AddChild(itemObj.transform)
        itemObj.transform.localScale = Vector3.one
      end
      if i > memberCount then
        itemObj:SetActive(false)
      else
        itemObj:SetActive(true)
        itemObj:GetComponent("UILabel"):set_text(members[i].name)
      end
    end
    uiGrid:Reposition()
  end
end
def.method("string").SetParnterName = function(self, name)
  self.uiTbl.Label_ParnterName:GetComponent("UILabel"):set_text(name or "")
end
def.method("string", "string").SetMasterInfo = function(self, name, count)
  self.uiTbl.Label_MasterName:GetComponent("UILabel"):set_text(name or "")
  self.uiTbl.Label_ApprenticeNum:GetComponent("UILabel"):set_text(count)
end
def.method().SetQingYuanInfo = function(self)
  if not QingYuanMgr.Instance():IsQingYuanFunctionOpen() then
    GUIUtils.SetActive(self.uiTbl.Group_Lover, false)
    return
  else
    GUIUtils.SetActive(self.uiTbl.Group_Lover, true)
  end
  local Label_NoLover = self.uiTbl.Group_Lover:FindDirect("Label_NoLover")
  local List_Lover = self.uiTbl.Group_Lover:FindDirect("List_Brother")
  local roleList = QingYuanMgr.Instance():GetCurrentQingYuanRoleIdList()
  if roleList == nil or #roleList == 0 then
    GUIUtils.SetActive(Label_NoLover, true)
    GUIUtils.SetActive(List_Lover, false)
    return
  else
    GUIUtils.SetActive(Label_NoLover, false)
    GUIUtils.SetActive(List_Lover, true)
  end
  local templateItem = List_Lover:FindDirect(string.format("Item01"))
  local memberCount = #roleList
  local uiGrid = List_Lover:GetComponent("UIGrid")
  local childCount = uiGrid:GetChildListCount()
  local allCount = memberCount < childCount and childCount or memberCount
  local templateItem = self.uiTbl.Brother_Grid_TemplateItem
  if not templateItem then
    return
  end
  for i = 1, allCount do
    local itemObj = List_Lover:FindDirect(string.format("Item%02d", i))
    if itemObj == nil then
      itemObj = GameObject.Instantiate(templateItem)
      itemObj.name = string.format("Item%02d", i)
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
    end
    if i > memberCount then
      itemObj:SetActive(false)
    else
      itemObj:SetActive(true)
      local friendData = require("Main.friend.FriendData").Instance()
      local roleInfo = friendData:GetFriendInfo(roleList[i])
      if roleInfo ~= nil then
        itemObj:GetComponent("UILabel"):set_text(roleInfo.roleName)
      end
    end
  end
  uiGrid:Reposition()
end
def.method().UpdateSNSBtnStatus = function(self)
  if DISABLE_SNS_BTN then
    self.uiTbl.Btn_ManageInfo:SetActive(false)
    self.uiTbl.Btn_PublishInfo:SetActive(false)
  else
    self.uiTbl.Btn_ManageInfo:SetActive(SocialPlatformMgr.IsOpen())
    self.uiTbl.Btn_PublishInfo:SetActive(SocialPlatformMgr.IsOpen())
  end
end
def.static("table", "table").OnSocialPlatformOpenChange = function(context, params)
  local self = context
  self:UpdateSNSBtnStatus()
end
def.static("table", "table").OnQingYuanInfoChange = function(context, params)
  local self = context
  if self ~= nil then
    self:SetQingYuanInfo()
  end
end
def.static("table", "table").OnFeatureOpenChange = function(context, params)
  local self = context
  if self ~= nil then
    if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_QING_YUAN then
      self:SetQingYuanInfo()
    elseif params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SHITU_TASK then
      self:UpdateMasterTaskBtnStatus()
    end
  end
end
def.static("table", "table").OnMasterTaskInfoChange = function(context, params)
  local self = context
  if self ~= nil then
    self:UpdateMasterTaskBtnStatus()
  end
end
def.method().UpdateMasterTaskBtnStatus = function(self)
  local InteractMgr = require("Main.Shitu.interact.InteractMgr")
  if InteractMgr.Instance():IsFeatrueTaskOpen(false) then
    GUIUtils.SetActive(self.uiTbl.Btn_MasterTask, true)
    GUIUtils.SetActive(self.uiTbl.Btn_MasterTask_Reddot, InteractMgr.Instance():NeedReddot())
  else
    GUIUtils.SetActive(self.uiTbl.Btn_MasterTask, false)
  end
end
RelationInfoNode.Commit()
return RelationInfoNode

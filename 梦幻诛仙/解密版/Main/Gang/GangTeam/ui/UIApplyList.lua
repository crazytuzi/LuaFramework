local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local UIApplyList = Lplus.Extend(ECPanelBase, "UIApplyList")
local Cls = UIApplyList
local def = Cls.define
local instance
local GangTeamMgr = require("Main.Gang.GangTeamMgr")
local txtConst = textRes.Gang.GangTeam
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._applyList = nil
def.static("=>", UIApplyList).Instance = function()
  if instance == nil then
    instance = UIApplyList()
  end
  return instance
end
def.method().eventsRegister = function(self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.ApplicantsListChg, Cls.OnApplicantsChg, self)
end
def.method().eventsUnregister = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.ApplicantsListChg, Cls.OnApplicantsChg)
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  local uiGOs = self._uiGOs
  uiGOs.btnRefresh = self.m_panel:FindDirect("Img_Bg0/Btn_Fresh")
  GUIUtils.EnableButton(uiGOs.btnRefresh, true)
  self:eventsRegister()
  self:_initUI()
end
def.override().OnDestroy = function(self)
  self:eventsUnregister()
  self._uiGOs = nil
  self._uiStatus = nil
  self._applyList = nil
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    GUIUtils.EnableButton(self._uiGOs.btnRefresh, true)
  end
end
def.method()._initUI = function(self)
  self:_updateUIApplyList()
end
def.method("=>", "table").tryGetApplyList = function(self)
  local applyList = GangTeamMgr.GetData():GetApplyList()
  local retData = {}
  for i = 1, #applyList do
    local roleInfo = GangTeamMgr.GetGangRoleInfo(applyList[i])
    if roleInfo ~= nil then
      table.insert(retData, roleInfo)
    end
  end
  return retData
end
def.method()._updateUIApplyList = function(self)
  self._applyList = self:tryGetApplyList()
  local applyList = self._applyList or {}
  local itemCount = #applyList
  local ctrlScrollView = self.m_panel:FindDirect("Img_Bg0/Group_Player/Group_List/Scrollview")
  local ctrlUIList = ctrlScrollView:FindDirect("List")
  local ctrlApplyList = GUIUtils.InitUIList(ctrlUIList, itemCount)
  for i = 1, itemCount do
    local roleInfo = applyList[i]
    self:_fillApplyeeRoleInfo(ctrlApplyList[i], roleInfo, i)
  end
end
def.method("userdata", "table", "number")._fillApplyeeRoleInfo = function(self, ctrl, roleInfo, idx)
  local lblPower = ctrl:FindDirect(("Group_Player_%d/Img_BgPower_%d/Label_PowerNumber_%d"):format(idx, idx, idx))
  local ctrlInfoRoot = ctrl:FindDirect(("Group_Player_%d/Group_Head_%d"):format(idx, idx))
  local imgHeadFrame = ctrlInfoRoot:FindDirect("Img_BgIconGroup_" .. idx)
  local imgHead = imgHeadFrame:FindDirect("Texture_IconGroup_" .. idx)
  local lblLv = ctrlInfoRoot:FindDirect("Label_Lv_" .. idx)
  local lblName = ctrlInfoRoot:FindDirect("Label_Name_" .. idx)
  local imgSex = ctrlInfoRoot:FindDirect("Img_Sex_" .. idx)
  local imgOccup = ctrlInfoRoot:FindDirect("Img_SchoolIcon_" .. idx)
  _G.SetAvatarIcon(imgHead, roleInfo.avatarId)
  _G.SetAvatarFrameIcon(imgHeadFrame, roleInfo.avatar_frame)
  GUIUtils.SetText(lblName, roleInfo.name)
  GUIUtils.SetText(lblLv, txtConst[74]:format(roleInfo.level))
  GUIUtils.SetSprite(imgSex, GUIUtils.GetGenderSprite(roleInfo.gender))
  GUIUtils.SetSprite(imgOccup, GUIUtils.GetOccupationSmallIcon(roleInfo.occupationId))
  GUIUtils.SetText(lblPower, roleInfo.fight_value)
  local lblGangJob = ctrl:FindDirect(("Group_Player_%d/Label_GangJob_%d"):format(idx, idx))
  local dutyName = require("Main.Gang.data.GangData").Instance():GetDutyName(roleInfo.duty)
  GUIUtils.SetText(lblGangJob, dutyName)
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_GANG_APPLYLIST_PANEL, 2)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif string.find(id, "Btn_Agree_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:onClickBtnAgree(idx)
  elseif string.find(id, "Btn_DisAgree_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:onClickBtnDisagree(idx)
  elseif "Btn_Fresh" == id then
    self:onClickBtnRefresh()
  end
end
def.method("number").onClickBtnAgree = function(self, idx)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local roleId = self._applyList[idx].roleId
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  if not myTeam then
    Toast(txtConst[30])
    return
  end
  if #myTeam.members >= 5 then
    Toast(txtConst[24])
    return
  end
  local roleInfo = GangTeamMgr.GetGangRoleInfo(roleId)
  if roleInfo == nil then
    Toast(txtConst[31])
    return
  end
  GangTeamMgr.GetProtocol().sendJoinGangTeamRep(roleId, true)
end
def.method("number").onClickBtnDisagree = function(self, idx)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local roleId = self._applyList[idx].roleId
  GangTeamMgr.GetData():RmvApplyee(roleId)
  GangTeamMgr.GetProtocol().sendJoinGangTeamRep(roleId, false)
  self:_updateUIApplyList()
end
def.method().onClickBtnRefresh = function(self)
  self:_updateUIApplyList()
  GUIUtils.EnableButton(self._uiGOs.btnRefresh, false)
  _G.GameUtil.AddGlobalTimer(3, true, function()
    if self and self:IsShow() then
      GUIUtils.EnableButton(self._uiGOs.btnRefresh, true)
    end
  end)
end
def.method("table").OnApplicantsChg = function(self, p)
  self:_updateUIApplyList()
end
return Cls.Commit()

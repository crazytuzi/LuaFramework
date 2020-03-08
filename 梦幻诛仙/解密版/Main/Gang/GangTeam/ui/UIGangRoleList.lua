local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local UIGangRoleList = Lplus.Extend(ECPanelBase, "UIGangRoleList")
local Cls = UIGangRoleList
local def = Cls.define
local instance
local GangTeamMgr = require("Main.Gang.GangTeamMgr")
local txtConst = textRes.Gang.GangTeam
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._roleList = nil
def.field("table")._allRoleList = nil
def.field("table")._occupList = nil
def.field("table")._lvList = nil
def.static("=>", UIGangRoleList).Instance = function()
  if instance == nil then
    instance = UIGangRoleList()
  end
  return instance
end
def.method().eventsRegister = function(self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.TeamMemberChg, Cls.OnTeamMemberChg, self)
end
def.method().eventsUnregister = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.TeamMemberChg, Cls.OnTeamMemberChg)
end
def.override().OnCreate = function(self)
  self._uiStatus = {}
  self._uiStatus.selOccupIdx = 1
  self._uiStatus.selLvIdx = 1
  self._uiGOs = {}
  local uiGOs = self._uiGOs
  self:eventsRegister()
  self._allRoleList = GangTeamMgr.GetGangMemberList()
  uiGOs.groupNoData = self.m_panel:FindDirect("Img_Bg0/Group_NoData")
  local btnList = uiGOs.groupNoData:FindDirect("Btn_List")
  btnList:SetActive(false)
  local lblTalkContent = uiGOs.groupNoData:FindDirect("Img_Talk/Label")
  GUIUtils.SetText(lblTalkContent, txtConst[81])
  uiGOs.btnSelOccup = self.m_panel:FindDirect("Img_Bg0/Btn_Zone01")
  uiGOs.groupOccup = uiGOs.btnSelOccup:FindDirect("Group_Zone01")
  uiGOs.btnSelLv = self.m_panel:FindDirect("Img_Bg0/Btn_Zone02")
  uiGOs.groupLv = uiGOs.btnSelLv:FindDirect("Group_Zone02")
  uiGOs.lblSelOccup = uiGOs.btnSelOccup:FindDirect("Label_1")
  uiGOs.lblSelLv = uiGOs.btnSelLv:FindDirect("Label_2")
  uiGOs.imgBg = self.m_panel:FindDirect("Img_Bg0/Group_Player/Img_Bg1")
  self:_initUI()
end
def.override().OnDestroy = function(self)
  self:eventsUnregister()
  self._uiGOs = nil
  self._uiStatus = nil
  self._roleList = nil
  self._occupList = nil
  self._lvList = nil
  self._allRoleList = nil
end
def.method()._initUI = function(self)
  self:_initOccupDropdownList()
  self:_initLvDropdownList()
  self:_updateRoleList()
end
def.method("=>", "table").GetOccupationList = function(self)
  local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local occupList = {}
  local heroOccup = _G.GetHeroProp().occupation
  for k, occupId in pairs(OccupationEnum) do
    if occupId == 0 then
      table.insert(occupList, {
        occupId = occupId,
        name = txtConst[27]
      })
    else
      local occupName = _G.GetOccupationName(occupId)
      if occupName ~= nil and occupName ~= "" then
        table.insert(occupList, {occupId = occupId, name = occupName})
      end
    end
  end
  table.sort(occupList, function(a, b)
    if a.occupId < b.occupId then
      return true
    else
      return false
    end
  end)
  return occupList
end
def.method()._initOccupDropdownList = function(self)
  self._occupList = self:GetOccupationList()
  local occupList = self._occupList
  occupList = self._occupList
  local ctrlScrollView = self.m_panel:FindDirect("Img_Bg0/Btn_Zone01/Group_Zone01/Group_ChooseType")
  local ctrlUIList = ctrlScrollView:FindDirect("List")
  local occupCount = #occupList
  local ctrlOccupList = GUIUtils.InitUIList(ctrlUIList, occupCount)
  for i = 1, occupCount do
    local ctrl = ctrlOccupList[i]
    local lblName = ctrl:FindDirect("Label_Name_" .. i)
    if 1 > occupList[i].occupId then
      GUIUtils.SetText(lblName, txtConst[27])
    else
      GUIUtils.SetText(lblName, occupList[i].name)
    end
  end
  _G.GameUtil.AddGlobalTimer(0.1, true, function()
    if self and self:IsShow() then
      ctrlUIList:GetComponent("UIList"):DragToMakeVisible(self._uiStatus.selOccupIdx, 1000)
    end
  end)
end
def.method()._initLvDropdownList = function(self)
  local lvList = {-1}
  for i = 2, 10 do
    table.insert(lvList, i * 10)
  end
  self._lvList = lvList
  local ctrlScrollView = self.m_panel:FindDirect("Img_Bg0/Btn_Zone02/Group_Zone02/Group_ChooseType")
  local ctrlUIList = ctrlScrollView:FindDirect("List")
  local listCount = #lvList
  local ctrlLvList = GUIUtils.InitUIList(ctrlUIList, listCount)
  for i = 1, listCount do
    local ctrl = ctrlLvList[i]
    local lblName = ctrl:FindDirect("Label_Name_" .. i)
    if lvList[i] < 0 then
      GUIUtils.SetText(lblName, txtConst[28])
    else
      GUIUtils.SetText(lblName, txtConst[29]:format(lvList[i]))
    end
  end
  _G.GameUtil.AddGlobalTimer(0.1, true, function()
    if self and self:IsShow() then
      ctrlUIList:GetComponent("UIList"):DragToMakeVisible(self._uiStatus.selLvIdx, 1000)
    end
  end)
end
def.method()._updateRoleList = function(self)
  if self._roleList == nil then
    self:_filter()
  end
  self._roleList = self:_filterByOnline(self._roleList)
  local listCount = #(self._roleList or {})
  local bShowNoList = listCount < 1
  self._uiGOs.groupNoData:SetActive(bShowNoList)
  self._uiGOs.imgBg:SetActive(not bShowNoList)
  local ctrlScrollView = self.m_panel:FindDirect("Img_Bg0/Group_Player/Group_List/Scrollview")
  local ctrlUIList = ctrlScrollView:FindDirect("List")
  local ctrlRoleList = GUIUtils.InitUIList(ctrlUIList, listCount)
  for i = 1, listCount do
    local roleInfo = self._roleList[i]
    self:_fillRoleInfo(ctrlRoleList[i], roleInfo, i)
  end
end
def.method("userdata", "table", "number")._fillRoleInfo = function(self, ctrl, roleInfo, idx)
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
def.method("boolean").ToggleOccupList = function(self, bShow)
  self._uiGOs.groupOccup:SetActive(bShow)
  self._uiGOs.btnSelOccup:GetComponent("UIToggleEx").value = bShow
end
def.method("boolean").ToggleLevelList = function(self, bShow)
  self._uiGOs.groupLv:SetActive(bShow)
  self._uiGOs.btnSelLv:GetComponent("UIToggleEx").value = bShow
end
def.method()._filter = function(self)
  local selOccupId = self._occupList[self._uiStatus.selOccupIdx].occupId
  local selLv = self._lvList[self._uiStatus.selLvIdx]
  GUIUtils.SetText(self._uiGOs.lblSelOccup, self._occupList[self._uiStatus.selOccupIdx].name)
  if selLv < 1 then
    GUIUtils.SetText(self._uiGOs.lblSelLv, txtConst[28])
  else
    GUIUtils.SetText(self._uiGOs.lblSelLv, txtConst[29]:format(selLv))
  end
  warn("selOccupId", selOccupId, "selLv", selLv)
  if selOccupId < 1 and selLv < 1 then
    self._roleList = self._allRoleList
  elseif selOccupId > 0 and selLv > 1 then
    self:_filteByLvAndOccup(selOccupId, selLv)
  elseif selOccupId > 0 then
    self._roleList = self:_filteByOccupation(selOccupId, self._allRoleList)
  elseif selLv > 0 then
    self._roleList = self:_filteByLv(selLv, self._allRoleList)
  end
end
def.method("table", "=>", "table")._filterByOnline = function(self, roleList)
  if roleList == nil then
    return nil
  end
  local myRoleId = _G.GetHeroProp().id
  local newList = {}
  for i = 1, #roleList do
    local roleInfo = roleList[i]
    local gangTeam = GangTeamMgr.GetData():GetGangTeamByRoleId(roleInfo.roleId)
    if roleInfo.offlineTime == -1 and gangTeam == nil then
      table.insert(newList, roleInfo)
    end
  end
  return newList
end
def.method("number", "table", "=>", "table")._filteByOccupation = function(self, occupId, roleList)
  if roleList == nil then
    return nil
  end
  local retList = {}
  for i = 1, #roleList do
    local roleInfo = roleList[i]
    if roleInfo.occupationId == occupId then
      table.insert(retList, roleInfo)
    end
  end
  return retList
end
def.method("number", "table", "=>", "table")._filteByLv = function(self, lv, roleList)
  if roleList == nil then
    return nil
  end
  local retList = {}
  for i = 1, #roleList do
    local roleInfo = roleList[i]
    if lv <= roleInfo.level then
      table.insert(retList, roleInfo)
    end
  end
  return retList
end
def.method("number", "number")._filteByLvAndOccup = function(self, occupId, lv)
  self._roleList = {}
  for i = 1, #self._allRoleList do
    local roleInfo = self._allRoleList[i]
    if roleInfo.occupationId == occupId and lv <= roleInfo.level then
      table.insert(self._roleList, roleInfo)
    end
  end
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_GANGROLELIST_PANEL, 2)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("id", id)
  local bToggleOccup = false
  local bToggleLv = false
  if "Btn_Close" == id then
    self:DestroyPanel()
    return
  elseif "Btn_Fresh" == id then
    self:onClickBtnRefresh()
  elseif string.find(id, "Btn_Invite_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:onClickBtnInvite(idx)
  elseif id == "Btn_Zone01" then
    local UIToggleEx = self._uiGOs.btnSelOccup:GetComponent("UIToggleEx")
    bToggleOccup = UIToggleEx.value
  elseif id == "Btn_Zone02" then
    local UIToggleEx = self._uiGOs.btnSelLv:GetComponent("UIToggleEx")
    bToggleLv = UIToggleEx.value
  elseif string.find(id, "Img_BgZone01_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:onSelectOccup(idx)
  elseif string.find(id, "Img_BgZone02_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:onSelectLv(idx)
  end
  self:ToggleOccupList(bToggleOccup)
  self:ToggleLevelList(bToggleLv)
end
def.method().onClickBtnRefresh = function(self)
  self._allRoleList = GangTeamMgr.GetGangMemberList()
  self:_filter()
  self:_updateRoleList()
end
def.method("number").onClickBtnInvite = function(self, idx)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  if myTeam and #myTeam.members >= 5 then
    Toast(txtConst[24])
    return
  end
  local roleInfo = self._roleList[idx]
  if roleInfo then
    GangTeamMgr.GetProtocol().sendInviteGangTeamReq(roleInfo.roleId)
  end
end
def.method("number").onSelectOccup = function(self, idx)
  self._uiStatus.selOccupIdx = idx
  self:_filter()
  self:_updateRoleList()
end
def.method("number").onSelectLv = function(self, idx)
  self._uiStatus.selLvIdx = idx
  self:_filter()
  self:_updateRoleList()
end
def.method("table").OnTeamMemberChg = function(self, p)
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  if myTeam == nil then
    return
  end
  if p.teamId:eq(myTeam.teamid) then
    self:_filter()
    self:_updateRoleList()
  end
end
return Cls.Commit()

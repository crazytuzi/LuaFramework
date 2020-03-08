local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GangTeamListNode = Lplus.Extend(TabNode, CUR_CLASS_NAME)
local Cls = GangTeamListNode
local instance
local def = GangTeamListNode.define
local GangTeamMgr = require("Main.Gang.GangTeamMgr")
local GangModule = require("Main.Gang.GangModule")
local TeamData = require("Main.Team.TeamData")
local GUIUtils = require("GUI.GUIUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.Gang.GangTeam
def.field("number").nodeId = 0
def.field("table").uiGOs = nil
def.field("table")._teams = nil
def.field("table")._curTeams = nil
def.field("table")._uiStatus = nil
def.field("table")._teamTypeList = nil
def.static("=>", GangTeamListNode).Instance = function()
  if instance == nil then
    instance = GangTeamListNode()
  end
  return instance
end
def.method().eventsRegister = function(self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.NewTeamCreated, Cls.OnNewGangTeamBurn, self)
end
def.method().eventsUnregister = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.NewTeamCreated, Cls.OnNewGangTeamBurn)
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self._uiStatus = {}
  self.uiGOs = {}
  self._teamTypeList = {}
  self._curTeams = {}
  self._uiStatus.bTimeAscSort = true
  self._uiStatus.bPowerAscSort = true
  self._uiStatus.teamTypeCode = -1
  self._uiStatus.selIdx = 0
  self:eventsRegister()
  self.uiGOs.groupNoTeam = self.m_base.m_panel:FindDirect("Img_Bg0/Group_NoData")
  self._curTeams = self:GetTeamList()
  self:onSelectTeamType(-1)
  self:InitUI()
end
def.override().OnHide = function(self)
  self:eventsUnregister()
  local groupTeamList = self.m_node:FindDirect("Btn_Zone/Group_Zone")
  groupTeamList:SetActive(false)
  self._uiStatus = nil
  self.uiGOs = nil
  self._teamTypeList = nil
  self._teams = nil
  self._curTeams = nil
end
def.method().InitUI = function(self)
  local uiGOs = self.uiGOs
  local teams = GangTeamMgr.GetData():GetTeamsList() or {}
  local bHasTeams = #teams > 0
  local lblNoTeamContent = uiGOs.groupNoTeam:FindDirect("Img_Talk/Label")
  GUIUtils.SetText(lblNoTeamContent, txtConst[80])
  local btnList = uiGOs.groupNoTeam:FindDirect("Btn_List")
  uiGOs.imgBg = self.m_node:FindDirect("Img_Bg1")
  btnList:SetActive(false)
  self.uiGOs.groupNoTeam:SetActive(false)
  self:_updateUITeamList()
end
def.method()._initDropdownList = function(self)
  local teamTypeList = {-1}
  for i = 1, 2 do
    table.insert(teamTypeList, i)
  end
  self._teamTypeList = teamTypeList
  local ctrlScrollView = self.m_node:FindDirect("Btn_Zone/Group_Zone/Group_ChooseType")
  local ctrlUIList = ctrlScrollView:FindDirect("List")
  local listCount = #teamTypeList
  local ctrlTypeList = GUIUtils.InitUIList(ctrlUIList, listCount)
  for i = 1, listCount do
    local ctrl = ctrlTypeList[i]
    local lblName = ctrl:FindDirect("Label_Name_" .. i)
    ctrl.name = "Btn_" .. i .. "_" .. teamTypeList[i]
    local typeName = self:GetSelectTeamTypeName(teamTypeList[i])
    GUIUtils.SetText(lblName, typeName)
  end
end
def.method("number", "=>", "string").GetSelectTeamTypeName = function(self, typeCode)
  if typeCode < 0 then
    return txtConst[32]
  elseif typeCode == 1 then
    return txtConst[33]
  elseif typeCode == 2 then
    return txtConst[34]
  end
  return ""
end
def.method("boolean").ToggleTeamTypeList = function(self, bShow)
  local UIToggleEx = self.m_node:FindDirect("Btn_Zone"):GetComponent("UIToggleEx")
  local groupTeamList = self.m_node:FindDirect("Btn_Zone/Group_Zone")
  groupTeamList:SetActive(bShow)
  UIToggleEx.value = bShow
  if bShow then
    self:_initDropdownList()
  end
end
def.method()._updateUITeamList = function(self)
  local teams = self._curTeams
  local bShowNoTeam = #teams < 1
  self.uiGOs.groupNoTeam:SetActive(bShowNoTeam)
  self.m_node:FindDirect("Img_Bg1"):SetActive(not bShowNoTeam)
  local lblNoTeamContent = self.uiGOs.groupNoTeam:FindDirect("Img_Talk/Label")
  if self._uiStatus.teamTypeCode == 1 then
    GUIUtils.SetText(lblNoTeamContent, txtConst[82])
  elseif self._uiStatus.teamTypeCode == 2 then
    GUIUtils.SetText(lblNoTeamContent, txtConst[83])
  else
    GUIUtils.SetText(lblNoTeamContent, txtConst[80])
  end
  local ctrlScrollView = self.m_node:FindDirect("Group_List/Scrollview")
  local ctrlUIList = ctrlScrollView:FindDirect("List")
  local ctrlTeamList = GUIUtils.InitUIList(ctrlUIList, #teams)
  for i = 1, #teams do
    local team = teams[i]
    self:_fillTeamInfo(ctrlTeamList[i], team, i)
  end
end
def.method("userdata", "table", "number")._fillTeamInfo = function(self, ctrl, myTeam, idx)
  local lblAvgPower = ctrl:FindDirect(("Group_TeamInfo_%d/Group_Fight_%d/Label_FightNum_%d"):format(idx, idx, idx))
  local lblTeamName = ctrl:FindDirect(("Group_TeamInfo_%d/Group_Name_%d/Label_Name_%d"):format(idx, idx, idx))
  GUIUtils.SetText(lblAvgPower, math.floor(myTeam.avgPower or 0))
  GUIUtils.SetText(lblTeamName, myTeam.teamInfo.name)
  local members = {}
  for i = 1, #myTeam.teamInfo.members do
    table.insert(members, myTeam.teamInfo.members[i].roleid)
  end
  for i = 1, GangTeamMgr.MAX_MEMBER_COUNT do
    local roleId = members[i]
    local playInfo
    if roleId ~= nil then
      playInfo = myTeam.playInfoMap[roleId:tostring()]
    end
    local ctrlMem = ctrl:FindDirect("Group_Player_" .. idx)
    ctrlMem = ctrlMem:FindDirect(("Group_Head_%d_%d"):format(i, idx))
    if roleId == nil or playInfo == nil then
      ctrlMem:SetActive(false)
    else
      ctrlMem:SetActive(true)
      local imgFrame = ctrlMem:FindDirect(("Img_BgIconGroup_%d_%d"):format(i, idx))
      local imgHead = imgFrame:FindDirect(("Texture_IconGroup_%d_%d"):format(i, idx))
      local lblName = ctrlMem:FindDirect(("Label_Name_%d_%d"):format(i, idx))
      local imgOffline = imgFrame:FindDirect(("Img_Offline_%d_%d"):format(i, idx))
      local imgLeader = ctrlMem:FindDirect(("Img_Leader_%d_%d"):format(i, idx))
      imgLeader:SetActive(myTeam.teamInfo.leaderid:eq(playInfo.roleId))
      _G.SetAvatarIcon(imgHead, playInfo.avatarId)
      _G.SetAvatarFrameIcon(imgFrame, playInfo.avatar_frame)
      GUIUtils.SetText(lblName, playInfo.name)
      imgOffline:SetActive(playInfo.offlineTime ~= -1)
    end
  end
end
def.method("=>", "table").GetTeamList = function(self)
  local teams = GangTeamMgr.GetData():GetTeamsList() or {}
  self._teams = {}
  for i = 1, #teams do
    local team = teams[i]
    local roleInfoMap = {}
    local avgPower = 0
    local countNum = 0
    for j = 1, #team.members do
      local roleId = team.members[j].roleid
      local playInfo = self:GetMemGangInfoByRoleId(roleId)
      roleInfoMap[roleId:tostring()] = playInfo
      if playInfo ~= nil then
        avgPower = avgPower + playInfo.fight_value
        countNum = countNum + 1
      end
    end
    table.insert(self._teams, {
      teamInfo = team,
      playInfoMap = roleInfoMap,
      avgPower = avgPower / countNum
    })
  end
  return self._teams
end
def.method("userdata", "=>", "table").GetMemGangInfoByRoleId = function(self, roleId)
  return GangModule.Instance().data:GetMemberInfoByRoleId(roleId)
end
def.method("table", "=>", "table")._ascSortBytime = function(self, teams)
  if teams == nil then
    return nil
  end
  table.sort(teams, function(a, b)
    if not a.teamInfo.create_time:lt(b.teamInfo.create_time) then
      return true
    else
      return false
    end
  end)
  return teams
end
def.method("table", "=>", "table")._descSortBytime = function(self, teams)
  if teams == nil then
    return nil
  end
  table.sort(teams, function(a, b)
    if a.teamInfo.create_time:lt(b.teamInfo.create_time) then
      return true
    else
      return false
    end
  end)
  return teams
end
def.method("table", "=>", "table")._ascSortByPower = function(self, teams)
  if teams == nil then
    return nil
  end
  table.sort(teams, function(a, b)
    if a.avgPower > b.avgPower then
      return true
    else
      return false
    end
  end)
  return teams
end
def.method("table", "=>", "table")._descSortByPower = function(self, teams)
  if teams == nil then
    return nil
  end
  table.sort(teams, function(a, b)
    if a.avgPower < b.avgPower then
      return true
    else
      return false
    end
  end)
  return teams
end
def.method("table", "boolean", "=>", "table")._filterByTeamMember = function(self, teams, bFull)
  if teams == nil then
    return nil
  end
  local fullMemTeams = {}
  local unFullMemTeams = {}
  for i = 1, #teams do
    local teamInfo = teams[i].teamInfo
    if #teamInfo.members >= GangTeamMgr.MAX_MEMBER_COUNT then
      table.insert(fullMemTeams, teams[i])
    else
      table.insert(unFullMemTeams, teams[i])
    end
  end
  if bFull then
    return fullMemTeams
  else
    return unFullMemTeams
  end
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  warn("id", id)
  local bToggleTeamList = false
  if "Btn_Zone01" == id then
    self._uiStatus.bTimeAscSort = not self._uiStatus.bTimeAscSort
    self:onClickTimeSort()
  elseif "Btn_Zone02" == id then
    self._uiStatus.bPowerAscSort = not self._uiStatus.bPowerAscSort
    self:onClickPowerSort()
  elseif "Btn_Creat" == id then
    self:onClickBtnCreateGangTeam()
  elseif "Btn_Fresh" == id then
    self:GetTeamList()
    self:onSelectTeamType(self._uiStatus.teamTypeCode)
    self:_updateUITeamList()
  elseif "Btn_OneApply" == id then
    self:_onClickBtnEasyApply()
  elseif "Btn_Apply" == id then
    self:_onClickBtnApply()
  elseif "Btn_Zone" == id then
    local UIToggleEx = self.m_node:FindDirect("Btn_Zone"):GetComponent("UIToggleEx")
    bToggleTeamList = UIToggleEx.value
  elseif "Btn_TDHelp" == id then
    GUIUtils.ShowHoverTip(constant.CGangTeamConst.GangTeamTips, 0, 0)
  elseif string.find(id, "Img_Bg_") then
    local strs = string.split(obj.parent.name, "_")
    local teamTypeCode = tonumber(strs[3])
    self._uiStatus.teamTypeCode = teamTypeCode
    self:onSelectTeamType(teamTypeCode)
  elseif string.find(id, "Item_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[2])
    self._uiStatus.selIdx = idx
  elseif string.find(id, "Img_BgIconGroup_") then
    local strs = string.split(id, "_")
    local memIdx, teamIdx = tonumber(strs[3]), tonumber(strs[4])
    self:onClickTeamMember(teamIdx, memIdx, obj)
  end
  self:ToggleTeamTypeList(bToggleTeamList)
end
def.method().onClickTimeSort = function(self)
  if self._uiStatus.bTimeAscSort then
    self._curTeams = self:_ascSortBytime(self._curTeams)
  else
    self._curTeams = self:_descSortBytime(self._curTeams)
  end
  self:_updateUITeamList()
end
def.method().onClickPowerSort = function(self)
  if self._uiStatus.bPowerAscSort then
    self._curTeams = self:_ascSortByPower(self._curTeams)
  else
    self._curTeams = self:_descSortByPower(self._curTeams)
  end
  self:_updateUITeamList()
end
def.method().onClickBtnCreateGangTeam = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  if myTeam ~= nil then
    Toast(txtConst[22])
  else
    require("Main.Gang.GangTeam.ui.UIEditTeamName").Instance():ShowPanelWithCallback(function(str)
      if str == "" then
        str = _G.GetHeroProp().name
      end
      CommonConfirmDlg.ShowConfirm(txtConst[10], txtConst[77]:format(str), function(select)
        if select == 1 then
          GangTeamMgr.GetProtocol().sendCreateGangTeamReq(str)
        end
      end, nil)
    end)
  end
end
def.method()._onClickBtnEasyApply = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  if myTeam then
    Toast(txtConst[22])
  else
    GangTeamMgr.GetProtocol().sendAutoJoinGangTeamReq()
  end
end
def.method()._onClickBtnApply = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  if myTeam then
    Toast(txtConst[22])
    return
  end
  if self._uiStatus.selIdx < 1 then
    Toast(txtConst[23])
    return
  end
  local selTeam = self._curTeams[self._uiStatus.selIdx]
  if selTeam then
    selTeam = selTeam.teamInfo
    if #selTeam.members > 5 then
      Toast(txtConst[24])
    else
      GangTeamMgr.GetProtocol().sendJoinGangTeamReq(selTeam.teamid)
    end
  end
end
def.method("number").onSelectTeamType = function(self, teamTypeCode)
  local lblName = self.m_node:FindDirect("Btn_Zone/Label")
  local typeName = self:GetSelectTeamTypeName(teamTypeCode)
  GUIUtils.SetText(lblName, typeName)
  if teamTypeCode == 1 then
    self._curTeams = self:_filterByTeamMember(self._teams, true)
  elseif teamTypeCode == 2 then
    self._curTeams = self:_filterByTeamMember(self._teams, false)
  else
    self._curTeams = self._teams
  end
  if self._uiStatus.bTimeAscSort then
    self._curTeams = self:_ascSortBytime(self._curTeams)
  else
    self._curTeams = self:_descSortBytime(self._curTeams)
  end
  self:_updateUITeamList()
end
def.method("number", "number", "userdata").onClickTeamMember = function(self, teamIdx, memIdx, clickObj)
  local team = self._curTeams[teamIdx]
  if team == nil then
    return
  end
  local teamInfo = team.teamInfo
  local member = teamInfo.members[memIdx]
  if member then
    do
      local roleId = member.roleid
      if roleId:eq(_G.GetHeroProp().id) then
        return
      end
      local position = clickObj:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local widget = clickObj:GetComponent("UIWidget")
      gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(roleId, function(roleInfo)
        if self == nil or _G.IsNil(widget) then
          return
        end
        roleInfo.gangId = Int64.new(0)
        require("Main.Pubrole.PubroleTipsMgr").Instance():ShowTip(roleInfo, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1, {inMap = true})
      end)
    end
  end
end
def.method("table").OnNewGangTeamBurn = function(self, p)
  if p.leaderid:eq(_G.GetHeroProp().id) then
    self.m_base:SwitchToNode(require("Main.Gang.GangTeam.ui.GangTeamPanel").NodeId.SelfTeam)
  end
end
return GangTeamListNode.Commit()

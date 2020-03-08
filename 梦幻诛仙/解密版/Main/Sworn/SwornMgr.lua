local Lplus = require("Lplus")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local SwornData = require("Main.Sworn.data.SwornData")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local SwornPanel = Lplus.ForwardDeclare("SwornPanel")
local TeamData = require("Main.Team.TeamData").Instance()
local SwornMgr = Lplus.Class("SwornMgr")
local def = SwornMgr.define
def.const("table").SWORNERROR = {
  NON = 0,
  LOWLEVEL = 1,
  NOTEAM = 2,
  NOTENOUGHMEMBER = 3,
  NOTENOUGHMONEY = 4,
  NOTCAPTAIN = 5,
  NOSWORN = 6,
  INSWORN = 7,
  MAXCOUNT = 8
}
def.field("table").m_ConfirmDlgTable = function()
  return {}
end
local instance
local function OpenSwornPanel(subPage)
  local swornPanelInstance = SwornPanel.Instance()
  swornPanelInstance:SetPanelState(subPage)
  swornPanelInstance:ShowPanel()
end
def.static("=>", SwornMgr).Instance = function()
  if not instance then
    instance = SwornMgr()
  end
  return instance
end
def.static().CreateSworn = function()
  warn("CreateSworn")
  local p = require("netio.protocol.mzm.gsp.sworn.CCreateSwornReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").SetSwornName = function(p)
  warn("SetSwornName", p.name1, p.name2)
  local swornid = SwornData.Instance():GetFakeSwornID()
  local p = require("netio.protocol.mzm.gsp.sworn.CSetSwornNameReq").new(swornid, p.name1, p.name2)
  gmodule.network.sendProtocol(p)
end
def.static().AgreeSwornName = function()
  local swornid = SwornData.Instance():GetFakeSwornID()
  warn("AgreeSwornName", swornid)
  local p = require("netio.protocol.mzm.gsp.sworn.CAgreeSwornNameReq").new(swornid)
  gmodule.network.sendProtocol(p)
end
def.static().AgreeCreateSworn = function()
  local swornid = SwornData.Instance():GetFakeSwornID()
  warn("AgreeSwornName", swornid)
  local p = require("netio.protocol.mzm.gsp.sworn.CAgreeCreateSworn").new(swornid)
  gmodule.network.sendProtocol(p)
end
def.static().RejectSwornName = function()
  local swornid = SwornData.Instance():GetFakeSwornID()
  local p = require("netio.protocol.mzm.gsp.sworn.CRejectSwornNameReq").new(swornid)
  gmodule.network.sendProtocol(p)
end
def.static().RejectSworn = function()
  local swornid = SwornData.Instance():GetFakeSwornID()
  if swornid then
    local p = require("netio.protocol.mzm.gsp.sworn.CRejectSwornReq").new(swornid)
    gmodule.network.sendProtocol(p)
  end
end
def.static("table").SetSwornTitle = function(p)
  local swornid = SwornData.Instance():GetFakeSwornID()
  local p = require("netio.protocol.mzm.gsp.sworn.CSetSwornTitleReq").new(swornid, p.title)
  gmodule.network.sendProtocol(p)
end
def.static().ConfirmCreateSworn = function()
  local swornid = SwornData.Instance():GetFakeSwornID()
  local p = require("netio.protocol.mzm.gsp.sworn.CConfirmCreateSwornReq").new(swornid)
  gmodule.network.sendProtocol(p)
end
def.static().GetSwornInfo = function()
  local swornid = SwornData.Instance():GetSwornID()
  local p = require("netio.protocol.mzm.gsp.sworn.CGetSwornInfoReq").new(swornid)
  gmodule.network.sendProtocol(p)
end
def.static("table").ChangeSwornTitleReq = function(p)
  local p = require("netio.protocol.mzm.gsp.sworn.CChangeSwornTitleReq").new(p.title)
  gmodule.network.sendProtocol(p)
end
def.static("table").KickoutReq = function(p)
  warn("KickoutReq", p.kickoutid)
  local p = require("netio.protocol.mzm.gsp.sworn.CKickoutReq").new(p.kickoutid)
  gmodule.network.sendProtocol(p)
end
def.static().LeaveSwornReq = function()
  warn("CLeaveSwornReq")
  local p = require("netio.protocol.mzm.gsp.sworn.CLeaveSwornReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").ChangeSwornNameReq = function(p)
  warn("ChangeSwornNameReq", p.name1, p.name2)
  local p = require("netio.protocol.mzm.gsp.sworn.CChangeSwornNameReq").new(p.name1, p.name2)
  gmodule.network.sendProtocol(p)
end
def.static("table").ChangeSwornNameVoteReq = function(p)
  warn("ChangeSwornNameReq", p.votevalue)
  local p = require("netio.protocol.mzm.gsp.sworn.CChangeSwornNameVoteReq").new(p.votevalue)
  gmodule.network.sendProtocol(p)
end
def.static().AddNewMemberReq = function()
  warn("AddNewMemberReq")
  local p = require("netio.protocol.mzm.gsp.sworn.CAddNewMemberReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").NewMemberConfirmSwornReq = function(p)
  warn("NewMemberConfirmSwornReq", p.confirm, p.title)
  local p = require("netio.protocol.mzm.gsp.sworn.CNewMemberConfirmSwornReq").new(p.confirm, p.title)
  gmodule.network.sendProtocol(p)
  instance.m_ConfirmDlgTable.NewMemberConfirm = nil
end
def.static().GetNewMemberVoteInfoReq = function()
  warn("GetNewMemberVoteInfoReq")
  local p = require("netio.protocol.mzm.gsp.sworn.CGetNewMemberVoteInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").AddNewMemberVoteReq = function(p)
  warn("AddNewMemberVoteReq", p.votevalue)
  local p = require("netio.protocol.mzm.gsp.sworn.CAddNewMemberVoteReq").new(p.votevalue)
  gmodule.network.sendProtocol(p)
end
def.static().GetKickoutVoteInfoReq = function()
  warn("CGetKickoutVoteInfoReq")
  local p = require("netio.protocol.mzm.gsp.sworn.CGetKickoutVoteInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static().GetChangeNameVoteInfoReq = function()
  warn("GetChangeNameVoteInfoReq")
  local p = require("netio.protocol.mzm.gsp.sworn.CGetChangeNameVoteInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").KickoutVoteReq = function(p)
  warn("KickoutVoteReq", p.votevalue)
  local p = require("netio.protocol.mzm.gsp.sworn.CKickoutVoteReq").new(p.votevalue)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnNPCService = function(p1, p2)
  local serviceID = p1[1]
  local NPCID = p1[2]
  if serviceID == NPCServiceConst.Jie_Yi then
    local errCode = SwornMgr.CanSworn()
    if errCode == SwornMgr.SWORNERROR.NON then
      SwornMgr.CreateSworn()
    end
  elseif serviceID == NPCServiceConst.Add_Jie_Yi_Member then
    local errCode = SwornMgr.CanAddMember()
    if errCode == SwornMgr.SWORNERROR.NON then
      local members = TeamData:GetAllTeamMembers()
      local member = members[2]
      CommonConfirmDlg.ShowConfirmCoundDown(textRes.Sworn[7], textRes.Sworn[37]:format(member.name), "", "", 0, 0, function(selection, tag)
        if selection == 1 then
          SwornMgr.AddNewMemberReq()
        end
      end, nil)
    end
  elseif serviceID == NPCServiceConst.Delete_Jie_Yi_Member then
    do
      local member = SwornMgr.GetSwornMember()
      if #member < 2 then
        Toast(textRes.Sworn[28])
      elseif #member == 2 then
        CommonConfirmDlg.ShowConfirmCoundDown(textRes.Sworn[26], textRes.Sworn[27], "", "", 0, 0, function(selection, tag)
          if selection == 1 then
            local roleid = _G.GetMyRoleID()
            local params = {}
            for _, v in pairs(member) do
              if v.roleid ~= roleid then
                params.kickoutid = v.roleid
              end
            end
            SwornMgr.KickoutReq(params)
          end
        end, nil)
      elseif #member > 2 then
        local swornPanel = require("Main.Sworn.ui.SwornPanel")
        OpenSwornPanel(swornPanel.PANELSTATE.LEAVE)
      end
    end
  elseif serviceID == NPCServiceConst.Delete_Jie_Yi then
    local errCode = SwornMgr.CanDelete()
    if errCode == SwornMgr.SWORNERROR.NON then
      local leavePanel = require("Main.Sworn.ui.LeavePanel")
      leavePanel.Instance():ShowPanel()
    end
  elseif serviceID == NPCServiceConst.Modify_Jie_Yi_Name then
    local member = SwornMgr.GetSwornMember()
    if #member < 2 then
      Toast(textRes.Sworn[28])
    else
      local modifyNamePanel = require("Main.Sworn.ui.ModifyNamePanel")
      modifyNamePanel.Instance():ShowPanel()
    end
  elseif serviceID == NPCServiceConst.Modify_Title then
    local swornPanel = require("Main.Sworn.ui.SwornPanel")
    OpenSwornPanel(swornPanel.PANELSTATE.CHANGENAME)
  end
end
def.static("table").OnCreateSwornFailRes = function(p)
  warn("OnCreateSwornFailRes", p.resultcode, p.name1, " ", p.name2)
  local SCreateSwornFailRes = require("netio.protocol.mzm.gsp.sworn.SCreateSwornFailRes")
  if p.resultcode == SCreateSwornFailRes.ERROR_CREATE_TEAM then
  elseif p.resultcode == SCreateSwornFailRes.ERROR_PLAYERSWORN then
    Toast(textRes.Sworn[2]:format(p.name1))
  elseif p.resultcode == SCreateSwornFailRes.ERROR_CREATE_PLAYERCOUNT then
    Toast(textRes.Sworn[34])
  elseif p.resultcode == SCreateSwornFailRes.ERROR_CREATE_NOTFRIEND then
    Toast(textRes.Sworn[3]:format(p.name1, p.name2))
  elseif p.resultcode == SCreateSwornFailRes.ERROR_CREATE_FRIENDVALUE then
    local value = SwornData.GetSwornConst("MIN_FRIEND_VALUE")
    Toast(textRes.Sworn[56]:format(p.name1, p.name2, value))
  elseif p.resultcode == SCreateSwornFailRes.ERROR_CREATE_NOTAGREE then
    Toast(textRes.Sworn[10]:format(p.name1))
    local confirmDlg = instance.m_ConfirmDlgTable.CreateSwornConfirm
    if confirmDlg then
      confirmDlg:DestroyPanel()
    end
    local swornPanel = require("Main.Sworn.ui.SwornPanel")
    swornPanel.Instance():DestroyPanel()
  elseif p.resultcode == SCreateSwornFailRes.ERROR_CREATE_SILVER then
  elseif p.resultcode == SCreateSwornFailRes.ERROR_CREATE_TEAMCHANGE then
    Toast(textRes.Sworn[29])
    local swornPanel = require("Main.Sworn.ui.SwornPanel")
    swornPanel.Instance():DestroyPanel()
  elseif p.resultcode == SCreateSwornFailRes.ERROR_NAME_OVERLAP then
    Toast(textRes.Sworn[52])
  elseif p.resultcode == SCreateSwornFailRes.ERROR_CREATE_OVERTIME then
    Toast(textRes.Sworn[53])
  elseif p.resultcode == SCreateSwornFailRes.ERROR_CREATE_PLAYERLEVEL then
    local level = SwornData.GetSwornConst("MIN_PLAYER_LV")
    Toast(textRes.Sworn[60]:format(p.name1, level))
  elseif p.resultcode == SCreateSwornFailRes.ERROR_TEAM_MEMBER_STATUS then
    Toast(textRes.Sworn[64])
  elseif p.resultcode == SCreateSwornFailRes.ERROR_CREATE_OVERLAP then
    Toast(textRes.Sworn[66])
  end
end
def.static("table").OnBeginSetSwornName = function(p)
  warn("OnBeginSetSwornName", p.swornid, " ", p.roleid, TeamData:MeIsCaptain())
  if TeamData:MeIsCaptain() then
    local swornPanel = require("Main.Sworn.ui.SwornPanel")
    OpenSwornPanel(swornPanel.PANELSTATE.SETSWORNNAME)
  else
    Toast(textRes.Sworn[12])
  end
end
def.static("table").OnSetSwornNameError = function(p)
  warn("OnSetSwornNameError", p.resultcode)
  local SSetSwornNameError = require("netio.protocol.mzm.gsp.sworn.SSetSwornNameError")
  local swornPanel = require("Main.Sworn.ui.SwornPanel")
  if p.resultcode == SSetSwornNameError.ERROR_CREATE_TEAM then
  elseif p.resultcode == SSetSwornNameError.ERROR_NO_CAPTAIN then
  elseif p.resultcode == SSetSwornNameError.ERROR_PREF_NAME then
    Toast(textRes.Sworn[69])
    OpenSwornPanel(swornPanel.PANELSTATE.SETSWORNNAME)
  elseif p.resultcode == SSetSwornNameError.ERROR_SUFF_NAME then
    Toast(textRes.Sworn[70])
    OpenSwornPanel(swornPanel.PANELSTATE.SETSWORNNAME)
  elseif p.resultcode == SSetSwornNameError.ERROR_NAME_OVERLAP then
    Toast(textRes.Sworn[68])
    OpenSwornPanel(swornPanel.PANELSTATE.SETSWORNNAME)
  end
end
def.static("table").OnCreateSwornRes = function(p)
  warn("OnCreateSwornRes", p.swornid, type(p.swornid))
  SwornData.Instance():SetFakeSwornID(p.swornid)
  local members = TeamData:GetAllTeamMembers()
  local roleid = _G.GetMyRoleID()
  local desc = ""
  for k, v in pairs(members) do
    if v.roleid ~= roleid then
      desc = tostring(v.name) .. "," .. desc
    end
  end
  instance.m_ConfirmDlgTable.CreateSwornConfirm = CommonConfirmDlg.ShowConfirmCoundDown(textRes.Sworn[7], textRes.Sworn[8]:format(desc), "", "", 0, 30, function(selection, tag)
    if selection == 1 then
      SwornMgr.AgreeCreateSworn()
    elseif selection == 0 then
      SwornMgr.RejectSworn()
    end
  end, nil)
end
def.static("table").OnAgreeCreateSwornRes = function(p)
  warn("OnAgreeCreateSwornRes", p.swornid, p.roleid)
end
def.static("table").OnBeginConfirmSwornName = function(p)
  warn("OnBeginConfirmSwornName", p.roleid, p.name1, p.name2)
  SwornData.Instance():SetSwornName(p.name1, p.name2)
  if not TeamData:MeIsCaptain() then
    local swornPanel = require("Main.Sworn.ui.SwornPanel")
    OpenSwornPanel(swornPanel.PANELSTATE.CONFIRMNAME)
  else
    Toast(textRes.Sworn[14])
  end
end
def.static("table").OnAgreeSwornNameRes = function(p)
  warn("OnAgreeSwornNameRes", p.swornid, p.roleid)
  local roleid = _G.GetMyRoleID()
  if roleid ~= p.roleid and not TeamData:MeIsCaptain() then
    local swornPanelInstance = SwornPanel.Instance()
    local index = TeamData:GetMemberIndex(p.roleid)
    swornPanelInstance:UpdateSelectView(index, true)
  end
end
def.static("table").OnBeginSetSwornTitle = function(p)
  warn("OnBeginSetSwornTitle", p.swornid)
  local swornPanel = require("Main.Sworn.ui.SwornPanel")
  OpenSwornPanel(swornPanel.PANELSTATE.SETMEMBERNAME)
end
def.static("table").OnSetSwornTitleRes = function(p)
  warn("OnSetSwornTitleRes", p.resultcode)
  local SSetSwornTitleRes = require("netio.protocol.mzm.gsp.sworn.SSetSwornTitleRes")
  if p.resultcode == SSetSwornTitleRes.SUCCESS then
    Toast(textRes.Sworn[16])
  elseif p.resultcode == SSetSwornTitleRes.ERROR_NAME then
    Toast(textRes.Sworn[20])
    local swornPanel = require("Main.Sworn.ui.SwornPanel")
    OpenSwornPanel(swornPanel.PANELSTATE.SETMEMBERNAME)
  elseif p.resultcode == SSetSwornTitleRes.ERROR_UNKNOWN then
  end
end
def.static("table").OnAllSwornTitleOK = function(p)
  warn("OnAllSwornTitleOK", p.swornid)
  local swornMoney = SwornData.GetSwornConst("SWORN_NEED_SILVER")
  CommonConfirmDlg.ShowConfirmCoundDown(textRes.Sworn[17], textRes.Sworn[18]:format(swornMoney), "", "", 0, 0, function(selection, tag)
    if selection == 1 then
      SwornMgr.ConfirmCreateSworn()
    elseif selection == 0 then
      SwornMgr.RejectSworn()
    end
  end, nil)
end
def.static("table").OnCreateSwornSuccessRes = function(p)
  warn("OnCreateSwornSuccessRes", p.swornid)
  local fx = GameUtil.RequestFx(RESPATH.SWORN_SUCCESS, 1)
  if fx then
    local Vector = require("Types.Vector")
    local fxone = fx:GetComponent("FxOne")
    fx.parent = GUIRoot.GetUIRootObj()
    fx.localPosition = Vector.Vector3.new(0, 0, 0)
    fx.localScale = Vector.Vector3.one
    fxone:Play2(-1, false)
  end
  Toast(textRes.Sworn[19])
  SwornData.Instance():SetSwornID(p.swornid)
  SwornMgr.GetSwornInfo()
end
def.static("table").OnRoleSwornTitle = function(p)
  warn("OnRoleSwornTitle", p.swornid, p.roleid, p.title)
  local roleid = _G.GetMyRoleID()
  if roleid ~= p.roleid then
    local swornPanelInstance = SwornPanel.Instance()
    local index = TeamData:GetMemberIndex(p.roleid)
    swornPanelInstance:UpdateSelectView(index, true)
    swornPanelInstance:UpdateSelectNameView(index, p.title or "")
  end
end
def.static("table").OnRoleSwornId = function(p)
  warn("OnRoleSwornId", p.swornid)
  if p.swornid:eq(0) then
    Toast(textRes.Sworn[24])
    SwornData.ClearSwornData()
    return
  end
  SwornData.Instance():SetSwornID(p.swornid)
  SwornMgr.GetSwornInfo()
end
def.static("table").OnSwornInfoRes = function(p)
  warn("OnSwornInfoRes", p.info)
  SwornData.Instance():SetSWornData(p.info)
  SwornData.Instance():ClearFakeSwornMember()
end
def.static("table").OnChangeSwornTitleFailRes = function(p)
  warn("OnChangeSwornTitleFailRes", p.resultcode)
  local SSetSwornTitleRes = require("netio.protocol.mzm.gsp.sworn.SChangeSwornTitleFailRes")
  if p.resultcode == SSetSwornTitleRes.ERROR_NAME then
    Toast(textRes.Sworn[20])
  elseif p.resultcode == SSetSwornTitleRes.ERROR_SILVER_NOT_ENOUGH then
    local needMoney = SwornData.GetSwornConst("CHANGE_TITLE_NEED_GOLD")
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Sworn[59], PersonalHelper.Type.Gold, Int64.new(needMoney), PersonalHelper.Type.Text, textRes.Sworn[57])
  end
end
def.static("table").OnKickoutRes = function(p)
  warn("OnKickoutRes", p.resultcode)
  local SKickoutRes = require("netio.protocol.mzm.gsp.sworn.SKickoutRes")
  if p.resultcode == SKickoutRes.SUCCESS then
    local swornid = SwornData.Instance():GetSwornID()
    if swornid then
      Toast(textRes.Sworn[48])
    end
  elseif p.resultcode == SKickoutRes.ERROR_SILVER_NOT_ENOUGH then
    local needMoney = SwornData.GetSwornConst("KICK_OUT_NEED_SILVER")
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Sworn[62], PersonalHelper.Type.Silver, Int64.new(needMoney), PersonalHelper.Type.Text, textRes.Sworn[57])
  elseif p.resultcode == SKickoutRes.ERROR_NOT_AGREE then
    Toast(textRes.Sworn[63])
  elseif p.resultcode == SKickoutRes.ERROR_VOTEING then
    Toast(textRes.Sworn[41])
  end
end
def.static("table").OnRoleSwornTitleChange = function(p)
  warn("OnRoleSwornTitleChange", p.swornid, p.roleid, p.title)
  local roleid = _G.GetMyRoleID()
  if roleid == p.roleid then
    Toast(textRes.Sworn[47])
  end
  SwornData.Instance():ChangeMemberTitle(p.title, p.roleid)
end
def.static("table").OnKickoutVoteRes = function(p)
  warn("OnKickoutVoteRes", p.resultcode)
  local SKickoutVoteRes = require("netio.protocol.mzm.gsp.sworn.SKickoutVoteRes")
  if p.resultcode == SKickoutVoteRes.SUCCESS then
    Toast(textRes.Sworn[44])
  end
end
def.static("table").OnLeaveSwornRes = function(p)
  warn("OnLeaveSwornRes", p.resultcode)
  local SLeaveSwornRes = require("netio.protocol.mzm.gsp.sworn.SLeaveSwornRes")
  if p.resultcode == SLeaveSwornRes.SUCCESS then
    Toast(textRes.Sworn[38])
  elseif p.resultcode == SLeaveSwornRes.ERROR_NO_SWORN then
    Toast(textRes.Sworn[33])
  end
end
def.static("table").OnRoleLeave = function(p)
  warn("OnRoleLeave", p.swornid, p.roleid)
  SwornData.Instance():DeleteMember(p.roleid)
end
def.static("table").OnSwornDissolve = function(p)
  warn("OnSwornDissolve")
end
def.static("table").OnChangeSwornNameFailRes = function(p)
  warn("OnChangeSwornNameFailRes", p.resultcode)
  local SChangeSwornNameFailRes = require("netio.protocol.mzm.gsp.sworn.SChangeSwornNameFailRes")
  if p.resultcode == SChangeSwornNameFailRes.ERROR_NAME then
    Toast(textRes.Sworn[20])
  elseif p.resultcode == SChangeSwornNameFailRes.ERROR_SILVER_NOT_ENOUGH then
    Toast(textRes.Fabao[16])
  elseif p.resultcode == SChangeSwornNameFailRes.ERROR_NOT_AGREE then
    Toast(textRes.Sworn[30])
  end
end
def.static("table").OnSwornNameChange = function(p)
  warn("OnSwornNameChange", p.swornid, p.name1, p.name2)
  SwornData.Instance():SetSwornName(p.name1, p.name2)
end
def.static("table").OnNewMemberConfirmSwornRes = function(p)
  warn("OnNewMemberConfirmSwornRes", p.resultcode)
  local SNewMemberConfirmSwornRes = require("netio.protocol.mzm.gsp.sworn.SNewMemberConfirmSwornRes")
  if p.resultcode == SNewMemberConfirmSwornRes.SUCCESS then
    Toast(textRes.Sworn[51])
  elseif p.resultcode == SNewMemberConfirmSwornRes.ERROR_NOTAGREE then
    Toast(textRes.Sworn[39])
    if not TeamData:MeIsCaptain() then
      SwornData.ClearSwornData()
    end
  elseif p.resultcode == SNewMemberConfirmSwornRes.ERROR_TITLENAME then
    Toast(textRes.Sworn[20])
    if not TeamData:MeIsCaptain() then
      SwornData.ClearSwornData()
    end
  end
end
def.static("table").OnNewMemberConfirmSworn = function(p)
  warn("OnNewMemberConfirmSworn", p.rolename, p.info, instance.m_ConfirmDlgTable.NewMemberConfirm)
  if instance.m_ConfirmDlgTable.NewMemberConfirm then
    return
  end
  SwornData.Instance():SetFakeSwornMember(p.info.members)
  SwornData.Instance():SetSwornName(p.info.name1, p.info.name2)
  instance.m_ConfirmDlgTable.NewMemberConfirm = CommonConfirmDlg.ShowConfirmCoundDown(textRes.Sworn[71], textRes.Sworn[40]:format(p.rolename), "", "", 30, 0, function(selection, tag)
    if selection == 1 then
      local swornPanel = require("Main.Sworn.ui.SwornPanel")
      local swornPanelInstance = SwornPanel.Instance()
      if not swornPanelInstance.m_panel then
        OpenSwornPanel(swornPanel.PANELSTATE.INVITEMEMBER)
      end
    else
      local swornPanel = require("Main.Sworn.ui.SwornPanel")
      SwornPanel.Instance():RejectInvite()
    end
  end, nil)
end
def.static("table").OnAddNewMemberFailRes = function(p)
  warn("OnAddNewMemberFailRes", p.resultcode)
  local SAddNewMemberFailRes = require("netio.protocol.mzm.gsp.sworn.SAddNewMemberFailRes")
  if p.resultcode == SAddNewMemberFailRes.ERROR_MAX_MEMBER then
    Toast(textRes.Sworn[31])
  elseif p.resultcode == SAddNewMemberFailRes.ERROR_SILVER_NOT_ENOUGH then
    Toast(textRes.Fabao[16])
  elseif p.resultcode == SAddNewMemberFailRes.ERROR_NOT_AGREE then
    Toast(textRes.Sworn[32])
  end
end
def.static("table").OnChangeSwornNameRes = function(p)
  warn("OnChangeSwornNameRes", p.resultcode)
  local SChangeSwornNameRes = require("netio.protocol.mzm.gsp.sworn.SChangeSwornNameRes")
  if p.resultcode == SChangeSwornNameRes.SUCCESS then
    Toast(textRes.Sworn[51])
  elseif p.resultcode == SChangeSwornNameRes.ERROR_NAME then
    Toast(textRes.Sworn[20])
  elseif p.resultcode == SChangeSwornNameRes.ERROR_SILVER_NOT_ENOUGH then
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    local needMoney = SwornMgr.GetSwornConst("CHANGE_SWORNNAME_NEED_GOLD")
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Sworn[61], PersonalHelper.Type.Gold, Int64.new(needMoney), PersonalHelper.Type.Text, textRes.Sworn[57])
  elseif p.resultcode == SChangeSwornNameRes.ERROR_NOT_SWORN then
    Toast(textRes.Sworn[33])
  elseif p.resultcode == SChangeSwornNameRes.ERROR_VOTEING then
    Toast(textRes.Sworn[41])
  elseif p.resultcode == SChangeSwornNameRes.ERROR_NOT_AGREE then
    Toast(textRes.Sworn[30])
  end
end
def.static("table").OnAddNewMemberRes = function(p)
  warn("OnAddNewMemberRes", p.resultcode)
  local SAddNewMemberRes = require("netio.protocol.mzm.gsp.sworn.SAddNewMemberRes")
  if p.resultcode == SAddNewMemberRes.SUCCESS then
    Toast(textRes.Sworn[51])
  elseif p.resultcode == SAddNewMemberRes.ERROR_MAX_SWORN_MEMBER then
    Toast(textRes.Sworn[35])
  elseif p.resultcode == SAddNewMemberRes.ERROR_SILVER_NOT_ENOUGH then
    Toast(textRes.Fabao[16])
  elseif p.resultcode == SAddNewMemberRes.ERROR_NOT_TEAM then
    Toast(textRes.Sworn[1])
  elseif p.resultcode == SAddNewMemberRes.ERROR_NOT_TEAM_LEADER then
    Toast(textRes.Sworn[12])
  elseif p.resultcode == SAddNewMemberRes.ERROR_TEAM_COUNT then
    Toast(textRes.Sworn[1])
  elseif p.resultcode == SAddNewMemberRes.ERROR_LEADER_NO_SWORN then
    Toast(textRes.Sworn[33])
  elseif p.resultcode == SAddNewMemberRes.ERROR_MEMBER_SWORN then
    local members = TeamData:GetAllTeamMembers()
    local memberinfo = members[2]
    if memberinfo then
      Toast(textRes.Sworn[2]:format(memberinfo.name))
    end
  elseif p.resultcode == SAddNewMemberRes.ERROR_MEMBER_FRIEND then
    if p.args[1] and p.args[2] then
      Toast(textRes.Sworn[3]:format(p.args[1], p.args[2]))
    end
  elseif p.resultcode == SAddNewMemberRes.ERROR_MEMBER_FRIEND_VALUE then
    local swornValue = SwornData.GetSwornConst("MIN_FRIEND_VALUE")
    Toast(textRes.Sworn[4]:format(swornValue))
  elseif p.resultcode == SAddNewMemberRes.ERROR_MEMBER_LEVEL then
    local members = TeamData:GetAllTeamMembers()
    local memberinfo = members[2]
    if memberinfo then
      local level = SwornData.GetSwornConst("MIN_PLAYER_LV")
      Toast(textRes.Sworn[60]:format(memberinfo.name, level))
    end
  elseif p.resultcode == SAddNewMemberRes.ERROR_VOTE_NOT_AGREE then
    Toast(textRes.Sworn[32])
  elseif p.resultcode == SAddNewMemberRes.ERROR_VOTEING then
    Toast(textRes.Sworn[41])
  end
end
def.static("table").OnRoleJoin = function(p)
  warn("OnRoleJoin", p.swornid, p.newmemberinfo)
  SwornData.Instance():AddSwornMember(p.newmemberinfo)
end
def.static("table").OnGetNewMemberVoteInfoRes = function(p)
  warn("OnGetNewMemberVoteInfoRes", p.roleid, p.rolename, p.rolegender, p.rolemenpai, p.roletitle, p.invitename, p.verifytime, p.curvotecount)
  local votePanel = require("Main.Sworn.ui.VotePanel")
  local voteInstance = votePanel.Instance()
  local voteInfo = {}
  voteInfo.playerInfo = {}
  voteInfo.invitename = p.invitename
  voteInfo.playerInfo.name = p.rolename
  voteInfo.playerInfo.menpai = p.rolemenpai
  voteInfo.playerInfo.title = p.roletitle
  voteInfo.playerInfo.gender = p.rolegender
  voteInfo.deadLineTime = p.verifytime
  voteInfo.curvotecount = p.curvotecount
  voteInstance:SetVoteInfo(voteInfo)
  voteInstance:SetPanelState(votePanel.PANELSTATE.ADD)
  voteInstance:ShowPanel()
end
def.static("table").OnAddNewMemberVoteRes = function(p)
  warn("OnAddNewMemberVoteRes", p.resultcode)
  local SAddNewMemberVoteRes = require("netio.protocol.mzm.gsp.sworn.SAddNewMemberVoteRes")
  if p.resultcode == SAddNewMemberVoteRes.SUCCESS then
    Toast(textRes.Sworn[44])
  elseif p.resultcode == SAddNewMemberVoteRes.ERROR_OVERLAP_VOTE then
    Toast(textRes.Sworn[43])
  elseif p.resultcode == SAddNewMemberVoteRes.ERROR_VOTE_NOT_EXIST then
    Toast(textRes.Sworn[42])
  end
end
def.static("table").OnGetChangeNameVoteInfoRes = function(p)
  warn("OnGetChangeNameVoteInfoRes", p.name1, p.name2)
  local votePanel = require("Main.Sworn.ui.VotePanel")
  local voteInstance = votePanel.Instance()
  local voteInfo = {}
  voteInfo.name1 = p.name1
  voteInfo.name2 = p.name2
  voteInfo.rolename = p.rolename
  voteInfo.deadLineTime = p.verifytime
  voteInfo.curvotecount = p.curvotecount
  voteInfo.needvotecount = p.needvotecount
  voteInstance:SetVoteInfo(voteInfo)
  voteInstance:SetPanelState(votePanel.PANELSTATE.CHANGE)
  voteInstance:ShowPanel()
end
def.static("table").OnGetKickoutVoteInfoRes = function(p)
  warn("OnGetKickoutVoteInfoRes", p.rolename, p.kickrolename, p.kickrolemenpai, p.kickroletitle, p.kickrolegender)
  local votePanel = require("Main.Sworn.ui.VotePanel")
  local voteInstance = votePanel.Instance()
  local voteInfo = {}
  voteInfo.rolename = p.rolename
  voteInfo.playerInfo = {}
  voteInfo.playerInfo.name = p.kickrolename
  voteInfo.playerInfo.menpai = p.kickrolemenpai
  voteInfo.playerInfo.title = p.kickroletitle
  voteInfo.playerInfo.gender = p.kickrolegender
  voteInfo.deadLineTime = p.verifytime
  voteInfo.agreecount = p.agreecount
  voteInfo.notagreecount = p.notagreecount
  voteInfo.needvotecount = p.needvotecount
  voteInstance:SetVoteInfo(voteInfo)
  voteInstance:SetPanelState(votePanel.PANELSTATE.LEAVE)
  voteInstance:ShowPanel()
end
def.static("table").OnChangeSwornNameVoteRes = function(p)
  warn("OnChangeSwornNameVoteRes", p.resultcode)
  local SChangeSwornNameVoteRes = require("netio.protocol.mzm.gsp.sworn.SChangeSwornNameVoteRes")
  if p.resultcode == SChangeSwornNameVoteRes.SUCCESS then
    Toast(textRes.Sworn[44])
  elseif p.resultcode == SChangeSwornNameVoteRes.ERROR_OVERLAP_VOTE then
    Toast(textRes.Sworn[43])
  elseif p.resultcode == SChangeSwornNameVoteRes.ERROR_VOTE_NOT_EXIST then
    Toast(textRes.Sworn[42])
  end
end
def.static("table").OnSwornCreateNotify = function(p)
  warn("OnSwornCreateNotify Modify")
  local names = table.concat(p.names, "\239\188\140")
  local desc = textRes.Sworn[75]:format(names, p.name1 .. SwornMgr.GetNumberDesc(p.membercount) .. p.name2)
  local NoticeType = require("consts.mzm.gsp.function.confbean.NoticeType")
  require("GUI.InteractiveAnnouncementTip").AnnounceWithModuleId(desc, NoticeType.JIE_YI)
end
def.static("table").OnMemberLoginRes = function(p)
end
def.static("=>", "number").CanSworn = function()
  local HeroProp = require("Main.Hero.Interface").GetHeroProp()
  local roleLv = HeroProp.level
  local swornid = SwornData.Instance():GetSwornID()
  local level = SwornData.GetSwornConst("MIN_PLAYER_LV")
  local money = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local needMoney = SwornData.GetSwornConst("SWORN_NEED_SILVER")
  if roleLv < level then
    Toast(textRes.Sworn[5])
    return SwornMgr.SWORNERROR.LOWLEVEL
  elseif swornid then
    Toast(textRes.Sworn[23])
    return SwornMgr.SWORNERROR.INSWORN
  elseif not TeamData:HasTeam() then
    Toast(textRes.Sworn[1])
    return SwornMgr.SWORNERROR.NOTEAM
  elseif TeamData:GetMemberCount() < 2 then
    Toast(textRes.Sworn[1])
    return SwornMgr.SWORNERROR.NOTENOUGHMEMBER
  elseif not TeamData:MeIsCaptain() then
    Toast(textRes.Sworn[12])
    return SwornMgr.SWORNERROR.NOTCAPTAIN
  elseif money:lt(needMoney) then
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Sworn[55], PersonalHelper.Type.Silver, Int64.new(needMoney), PersonalHelper.Type.Text, textRes.Sworn[57])
    return SwornMgr.SWORNERROR.NOTENOUGHMONEY
  end
  return SwornMgr.SWORNERROR.NON
end
def.static("=>", "number").CanAddMember = function()
  local swornid = SwornData.Instance():GetSwornID()
  local member = SwornData.Instance():GetSwornMember()
  local maxCount = SwornData.GetSwornConst("MAX_MEMBER_COUNT")
  local members = TeamData:GetAllTeamMembers()
  local memberinfo = members[2]
  if not memberinfo then
    Toast(textRes.Sworn[34])
    return SwornMgr.SWORNERROR.NOTEAM
  elseif not swornid then
    Toast(textRes.Sworn[33])
    return SwornMgr.SWORNERROR.NOSWORN
  elseif maxCount <= #member then
    Toast(textRes.Sworn[35])
    return SwornMgr.SWORNERROR.MAXCOUNT
  elseif 2 > TeamData:GetMemberCount() then
    Toast(textRes.Sworn[34])
    return SwornMgr.SWORNERROR.NOTENOUGHMEMBER
  elseif 2 < TeamData:GetMemberCount() then
    Toast(textRes.Sworn[67])
    return SwornMgr.SWORNERROR.NOTENOUGHMEMBER
  elseif SwornData.Instance():IsSwornMember(memberinfo.roleid) then
    Toast(textRes.Sworn[36]:format(memberinfo.name))
    return SwornMgr.SWORNERROR.INSWORN
  elseif not TeamData:MeIsCaptain() then
    Toast(textRes.Sworn[12])
    return SwornMgr.SWORNERROR.NOTCAPTAIN
  end
  return SwornMgr.SWORNERROR.NON
end
def.static("=>", "number").CanDelete = function()
  local HeroProp = require("Main.Hero.Interface").GetHeroProp()
  local swornid = SwornData.Instance():GetSwornID()
  if not swornid then
    Toast(textRes.Sworn[33])
    return SwornMgr.SWORNERROR.NOSWORN
  end
  return SwornMgr.SWORNERROR.NON
end
def.static("=>", "table").GetFakeSwornMember = function(self)
  return SwornData.Instance():GetFakeSwornMember()
end
def.static("=>", "table").GetSwornName = function()
  return SwornData.Instance():GetSwornName()
end
def.static("=>", "string").GetSwornNameEx = function()
  local names = SwornData.Instance():GetSwornName()
  local count = #SwornMgr.GetSwornMember()
  return names.name1 .. SwornMgr.GetNumberDesc(count) .. names.name2
end
def.static("=>", "table").GetSwornMember = function()
  return SwornData.Instance():GetSwornMember()
end
def.static("string", "=>", "number").GetSwornConst = function(key)
  return SwornData.GetSwornConst(key)
end
def.static("userdata", "=>", "table").GetSwornMemberInfo = function(roleid)
  return SwornData.Instance():GetSwornMemberInfo(roleid)
end
def.static().ClearSwornData = function()
  SwornData.ClearSwornData()
end
def.static("number", "=>", "string").GetNumberDesc = function(count)
  return count == 2 and textRes.Sworn[58] or textRes.ChineseNumber[count]
end
def.static("userdata", "=>", "boolean").IsSwornMember = function(roleid)
  return SwornData.Instance():IsSwornMember(roleid)
end
def.static("number", "=>", "boolean").DelSwornVoteMail = function(id)
  if id == SwornData.GetSwornConst("NEW_MEMBER_VOTE_MAILID") then
    SwornMgr.AddNewMemberVoteReq({votevalue = 1})
    return true
  elseif id == SwornData.GetSwornConst("CHANGE_SWORNNAME_VOTE_MAILID") then
    SwornMgr.ChangeSwornNameVoteReq({votevalue = 1})
    return true
  elseif id == SwornData.GetSwornConst("KICK_OUT_VOTE_MAILID") then
    SwornMgr.KickoutVoteReq({votevalue = 2})
    return true
  end
  return false
end
def.static("number", "number", "=>", "boolean").GetSwornVoteMail = function(id, mailIndex)
  local votePanel = require("Main.Sworn.ui.VotePanel")
  votePanel.Instance():SetMailIndex(mailIndex)
  local swornid = SwornData.Instance():GetSwornID()
  if id == SwornData.GetSwornConst("NEW_MEMBER_VOTE_MAILID") then
    if not swornid then
      Toast(textRes.Sworn[38])
      return false
    else
      SwornMgr.GetNewMemberVoteInfoReq()
      return true
    end
  elseif id == SwornData.GetSwornConst("CHANGE_SWORNNAME_VOTE_MAILID") then
    if not swornid then
      Toast(textRes.Sworn[38])
      return false
    else
      SwornMgr.GetChangeNameVoteInfoReq()
      return true
    end
  elseif id == SwornData.GetSwornConst("KICK_OUT_VOTE_MAILID") then
    if not swornid then
      Toast(textRes.Sworn[38])
      return false
    else
      SwornMgr.GetKickoutVoteInfoReq()
      return true
    end
  end
  return false
end
def.method().Init = function(self)
  SwornData.Instance()
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, SwornMgr.OnNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SCreateSwornFailRes", SwornMgr.OnCreateSwornFailRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SBeginSetSwornName", SwornMgr.OnBeginSetSwornName)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SSetSwornNameError", SwornMgr.OnSetSwornNameError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SCreateSwornRes", SwornMgr.OnCreateSwornRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SAgreeCreateSwornRes", SwornMgr.OnAgreeCreateSwornRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SBeginConfirmSwornName", SwornMgr.OnBeginConfirmSwornName)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SAgreeSwornNameRes", SwornMgr.OnAgreeSwornNameRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SBeginSetSwornTitle", SwornMgr.OnBeginSetSwornTitle)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SSetSwornTitleRes", SwornMgr.OnSetSwornTitleRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SCreateSwornSuccessRes", SwornMgr.OnCreateSwornSuccessRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SRoleSwornTitle", SwornMgr.OnRoleSwornTitle)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SAllSwornTitleOK", SwornMgr.OnAllSwornTitleOK)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SRoleSwornId", SwornMgr.OnRoleSwornId)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SSwornInfoRes", SwornMgr.OnSwornInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SChangeSwornTitleFailRes", SwornMgr.OnChangeSwornTitleFailRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SRoleSwornTitleChange", SwornMgr.OnRoleSwornTitleChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SKickoutRes", SwornMgr.OnKickoutRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SKickoutVoteRes", SwornMgr.OnKickoutVoteRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SRoleLeave", SwornMgr.OnRoleLeave)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SSwornDissolve", SwornMgr.OnSwornDissolve)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SSwornNameChange", SwornMgr.OnSwornNameChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SNewMemberConfirmSworn", SwornMgr.OnNewMemberConfirmSworn)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SNewMemberConfirmSwornRes", SwornMgr.OnNewMemberConfirmSwornRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SRoleJoin", SwornMgr.OnRoleJoin)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SAddNewMemberRes", SwornMgr.OnAddNewMemberRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SChangeSwornNameRes", SwornMgr.OnChangeSwornNameRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SAddNewMemberVoteRes", SwornMgr.OnAddNewMemberVoteRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SGetNewMemberVoteInfoRes", SwornMgr.OnGetNewMemberVoteInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SGetChangeNameVoteInfoRes", SwornMgr.OnGetChangeNameVoteInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SGetKickoutVoteInfoRes", SwornMgr.OnGetKickoutVoteInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SChangeSwornNameVoteRes", SwornMgr.OnChangeSwornNameVoteRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SSwornCreateNotify", SwornMgr.OnSwornCreateNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.sworn.SMemberLoginRes", SwornMgr.OnMemberLoginRes)
end
def.method().Reset = function(self)
  self.m_ConfirmDlgTable = {}
  SwornData.ClearSwornData()
end
return SwornMgr.Commit()

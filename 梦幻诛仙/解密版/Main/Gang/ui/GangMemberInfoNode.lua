local Lplus = require("Lplus")
local MembersTabSonNode = require("Main.Gang.ui.MembersTabSonNode")
local GangMembersNode = Lplus.ForwardDeclare("GangMembersNode")
local GangMemberInfoNode = Lplus.Extend(MembersTabSonNode, "GangMemberInfoNode")
local HaveGangPanel = Lplus.ForwardDeclare("HaveGangPanel")
local ECUIModel = require("Model.ECUIModel")
local GangData = require("Main.Gang.data.GangData")
local GangAppointPanel = require("Main.Gang.ui.GangAppointPanel")
local GangUtility = require("Main.Gang.GangUtility")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local EC = {}
EC.Vector3 = require("Types.Vector3").Vector3
local def = GangMemberInfoNode.define
def.field("table").selectMemberModelInfo = nil
def.field("userdata").selectMemberRoleId = nil
def.field("table").model = nil
def.field("table").selectMemberInfo = nil
def.field("table").buttonList = nil
def.field("boolean").isDrag = false
local instance
def.static("=>", GangMemberInfoNode).Instance = function()
  if instance == nil then
    instance = GangMemberInfoNode()
  end
  return instance
end
def.override(HaveGangPanel, "userdata").Init = function(self, base, node)
  MembersTabSonNode.Init(self, base, node)
  self.selectMemberModelInfo = nil
  self.selectMemberRoleId = nil
  self.selectMemberInfo = nil
  self.model = nil
  self.isDrag = false
end
def.override().OnShow = function(self)
  self:FillMemberModel()
  self:FillMemberButtons()
end
def.override().OnHide = function(self)
  self.selectMemberModelInfo = nil
  self.selectMemberRoleId = nil
  self:DestoryDisplayMod()
  self.selectMemberInfo = nil
  self.isDrag = false
end
def.method("table").SetMemberModelInfo = function(self, modelInfo)
  self.selectMemberModelInfo = modelInfo
end
def.method("=>", "table").GetMemberModelInfo = function(self)
  return self.selectMemberModelInfo
end
def.method("table").SetMemberInfo = function(self, info)
  self.selectMemberInfo = info
end
def.method("=>", "table").GetMemberInfo = function(self)
  return self.selectMemberInfo
end
def.method("userdata").SetSelectMemberRoleId = function(self, roleId)
  self.selectMemberRoleId = roleId
end
def.method().FillMemberModel = function(self)
  self:DestoryDisplayMod()
  local uiModel = self.m_node:FindDirect("Img_BgModel/Model"):GetComponent("UIModel")
  local modId = self.selectMemberModelInfo.modelid
  self.model = ECUIModel.new(modId)
  _G.LoadModelWithCallBack(self.model, self.selectMemberModelInfo, false, false, function()
    if self.selectMemberModelInfo == nil then
      return
    end
    self.model:OnLoadGameObject()
    uiModel.modelGameObject = self.model.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      if camera then
        camera:set_orthographic(true)
      end
    end
  end)
end
def.method().DestoryDisplayMod = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.method().FillMemberButtons = function(self)
  local amount = 0
  self.buttonList = {}
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if self.selectMemberRoleId ~= heroProp.id then
    local bFriend = FriendModule.Instance():IsFriend(self.selectMemberRoleId)
    local strFriend = textRes.Friend[2]
    if false == bFriend then
      strFriend = textRes.Friend[1]
    end
    table.insert(self.buttonList, {name = strFriend, id = 1})
    local strChat = textRes.Gang[277]
    table.insert(self.buttonList, {name = strChat, id = 2})
    local bHaveTeam = require("Main.Team.TeamData").Instance():HasTeam()
    local bMyTeam = true
    local strTeam = textRes.Friend[22]
    if bHaveTeam then
      strTeam = textRes.Friend[22]
    elseif self.selectMemberInfo and Int64.lt(0, self.selectMemberInfo.teamId) then
      bMyTeam = false
      strTeam = textRes.Friend[21]
    else
      strTeam = textRes.Friend[22]
    end
    table.insert(self.buttonList, {name = strTeam, id = 3})
    local heroMember = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
    local bangzhuId = GangUtility.GetGangConsts("BANGZHU_ID")
    if heroMember.duty == bangzhuId then
      local str = textRes.Gang[278]
      table.insert(self.buttonList, {name = str, id = 4})
    end
    local memberInfo = GangData.Instance():GetMemberInfoByRoleId(self.selectMemberRoleId)
    local heroDutyLv = GangUtility.GetDutyLv(heroMember.duty)
    local memberDutyLv = GangUtility.GetDutyLv(memberInfo.duty)
    local fubangzhuId = GangUtility.GetGangConsts("FUBANGZHU_ID")
    local zhanglaoId = GangUtility.GetGangConsts("ZHANGLAO_ID")
    local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
    local tbl = GangUtility.GetAuthority(heroMember.duty)
    if tbl.isCanAssignDuty and heroDutyLv < memberDutyLv then
      local str = textRes.Gang[279]
      table.insert(self.buttonList, {name = str, id = 5})
    end
    if tbl.isCanForbidden and heroDutyLv < memberDutyLv and (heroMember.duty == fubangzhuId and memberInfo.duty ~= zhanglaoId or heroMember.duty ~= fubangzhuId) then
      local str = textRes.Gang[280]
      if memberInfo.forbiddenTalk ~= 0 and memberInfo.forbiddenTalk > GetServerTime() then
        str = textRes.Gang[281]
      end
      table.insert(self.buttonList, {name = str, id = 6})
    end
    if tbl.isCanKick and heroDutyLv < memberDutyLv and (heroMember.duty == fubangzhuId and memberInfo.duty ~= zhanglaoId or heroMember.duty ~= fubangzhuId) then
      local str = textRes.Gang[282]
      table.insert(self.buttonList, {name = str, id = 7})
    end
    local tag = {bMyTeam = bMyTeam}
    if heroMember.duty == bangzhuId and memberInfo.duty ~= xuetuId then
      local str = textRes.Gang[283]
      table.insert(self.buttonList, {name = str, id = 8})
    end
    local actCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(constant.CWatchmoonConsts.ACTIVITY_ID)
    if heroMember.level >= actCfg.levelMin and memberInfo.level >= actCfg.levelMin then
      local str = textRes.Gang[284]
      table.insert(self.buttonList, {name = str, id = 9})
    end
  end
  amount = #self.buttonList
  local ScrollView = self.m_node:FindDirect("Scroll View_Btn")
  local List_Btn = ScrollView:FindDirect("List_Btn"):GetComponent("UIList")
  List_Btn:set_itemCount(amount)
  List_Btn:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not List_Btn.isnil then
      List_Btn:Reposition()
    end
  end)
  local buttons = List_Btn:get_children()
  for i = 1, amount do
    local btnUI = buttons[i]
    local btnInfo = self.buttonList[i].name
    self:FillButtonInfo(btnUI, i, btnInfo)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
  ScrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "string").FillButtonInfo = function(self, btnUI, i, btnInfo)
  local Label_Btn = btnUI:FindDirect(string.format("Label_Btn_%d", i))
  Label_Btn:GetComponent("UILabel"):set_text(btnInfo)
end
def.static("number", "table").ChuanweiCallback = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CChangeDutyReq").new(tag.targetId, tag.duty))
  elseif i == 0 then
  end
end
def.method().RequireToChuanwei = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(self.selectMemberRoleId)
  local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
  if memberInfo.duty == xuetuId then
    Toast(textRes.Gang[101])
    return
  end
  local bangzhuId = GangUtility.GetGangConsts("BANGZHU_ID")
  local tag = {
    id = self,
    targetId = memberInfo.roleId,
    duty = bangzhuId
  }
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Gang[81], memberInfo.name), GangMemberInfoNode.ChuanweiCallback, tag)
end
def.method().RequireToAppoint = function(self)
  GangAppointPanel.ShowGangAppointPanel(nil, nil, self.selectMemberRoleId)
end
def.method().RequireToForbidTalk = function(self)
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(self.selectMemberRoleId)
  if memberInfo.forbiddenTalk ~= 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CUnForbiddenTalkReq").new(memberInfo.roleId))
  else
    local costVigor = GangUtility.GetGangConsts("FORBIDDEN_TALK_COST_VIGOR")
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    if costVigor > heroProp.energy then
      Toast(string.format(textRes.Gang[82], costVigor))
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CForbiddenTalkReq").new(memberInfo.roleId))
  end
end
def.method().RequireToLeaveGang = function(self)
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(self.selectMemberRoleId)
  if not memberInfo then
    return
  end
  local memberName = memberInfo.name
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Gang[237], memberName), function(id, tag)
    if id == 1 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CKickOutMemberReq").new(memberInfo.roleId))
    end
  end, nil)
end
def.method().RequireToAddFriend = function(self)
  if self.selectMemberInfo then
    FriendModule.AddFriendOrDeleteFriend(self.selectMemberRoleId, self.selectMemberInfo.name)
  end
end
def.method().RequireToChat = function(self)
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  SocialDlg.ShowSocialDlg(1)
  ChatModule.Instance():ClearFriendNewCount(self.selectMemberRoleId)
  ChatModule.Instance():StartPrivateChat3(self.selectMemberRoleId, self.selectMemberInfo.name, self.selectMemberInfo.level, self.selectMemberInfo.occupationId, self.selectMemberInfo.gender, self.selectMemberInfo.avatarId, self.selectMemberInfo.avatarFrameId)
end
def.method().RequireToInTeam = function(self)
  local bHaveTeam = require("Main.Team.TeamData").Instance():HasTeam()
  local bMyTeam = true
  if false == bHaveTeam and Int64.lt(0, self.selectMemberInfo.teamId) then
    bMyTeam = false
  end
  if bMyTeam then
    gmodule.moduleMgr:GetModule(ModuleId.TEAM):TeamInvite(self.selectMemberRoleId)
  else
    gmodule.moduleMgr:GetModule(ModuleId.TEAM):ApplyTeam(self.selectMemberInfo.teamId)
  end
end
def.method().RequireToGiftBox = function(self)
  local GangGiftBoxPanel = require("Main.Gang.ui.GangGiftBoxPanel")
  GangGiftBoxPanel.ShowGiftBoxPanelToMember(self.selectMemberRoleId)
end
def.method().RequireToWatchMoon = function(self)
  local roleId = self.selectMemberRoleId
  require("Main.activity.WatchMoon.WatchMoonMgr").Instance():SendWatchMoonRequest(roleId)
end
def.method("number").OnButtonClick = function(self, index)
  local id = self.buttonList[index].id
  if id == 1 then
    self:RequireToAddFriend()
  elseif id == 2 then
    self:RequireToChat()
  elseif id == 3 then
    self:RequireToInTeam()
  elseif id == 4 then
    self:RequireToChuanwei()
  elseif id == 5 then
    self:RequireToAppoint()
  elseif id == 6 then
    self:RequireToForbidTalk()
  elseif id == 7 then
    self:RequireToLeaveGang()
  elseif id == 8 then
    self:RequireToGiftBox()
  elseif id == 9 then
    self:RequireToWatchMoon()
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Btn_List_") == "Btn_List_" then
    local index = tonumber(string.sub(id, #"Btn_List_" + 1, -1))
    self:OnButtonClick(index)
  end
end
def.override("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and self.model then
    self.model:SetDir(self.model.m_ang - dx / 2)
  end
end
GangMemberInfoNode.Commit()
return GangMemberInfoNode

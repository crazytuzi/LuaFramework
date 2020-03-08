local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangMemberTipPanel = Lplus.Extend(ECPanelBase, "GangMemberTipPanel")
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local GangAppointPanel = require("Main.Gang.ui.GangAppointPanel")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local GUIUtils = require("GUI.GUIUtils")
local def = GangMemberTipPanel.define
local instance
def.field("table").uiTbl = nil
def.field("table").buttonList = nil
def.field("table").memberInfo = nil
def.static("=>", GangMemberTipPanel).Instance = function(self)
  if nil == instance then
    instance = GangMemberTipPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, memberInfo)
  self.memberInfo = memberInfo
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_GANG_MEMBER_TIPS_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateMemberInfo()
  self:FillMemberButtons()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberInfoChange, GangMemberTipPanel.OnGangMemberInfoChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberInfoChange, GangMemberTipPanel.OnGangMemberInfoChange)
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Container = Img_Bg0:FindDirect("Container")
  local Label_Data = Container:FindDirect("Label_Data")
  local Label_OnLine = Container:FindDirect("Label_OnLine")
  local Label_OffLine = Container:FindDirect("Label_OffLine")
  local Label_Lv = Container:FindDirect("Group_Icon/Label_Lv")
  local Img_Icon = Container:FindDirect("Group_Icon/Img_Icon")
  uiTbl.Label_Data = Label_Data
  uiTbl.Label_OnLine = Label_OnLine
  uiTbl.Label_OffLine = Label_OffLine
  uiTbl.Label_Lv = Label_Lv
  uiTbl.Img_Icon = Img_Icon
  uiTbl.Img_Bg0 = Img_Bg0
  local Group_Btn = Img_Bg0:FindDirect("Group_Btn")
  local btnTemplate = Group_Btn:FindDirect("Btn_5")
  uiTbl.Group_Btn = Group_Btn
  uiTbl.btnTemplate = btnTemplate
  btnTemplate.name = "Btn_0"
  btnTemplate:SetActive(false)
end
def.method("number", "=>", "number").GetIconByModel = function(self, modelId)
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  local iconId = modelRecord:GetIntValue("headerIconId")
  return iconId
end
def.method().UpdateMemberInfo = function(self)
  local uiTbl = self.uiTbl
  local memberInfo = self.memberInfo
  local onLine = memberInfo.offlineTime < 0
  uiTbl.Label_OnLine:SetActive(onLine)
  uiTbl.Label_OffLine:SetActive(not onLine)
  uiTbl.Label_Lv:GetComponent("UILabel"):set_text(memberInfo.level)
  local joinDate = os.date("*t", GangData.TimeToSecond(memberInfo.joinTime))
  local dateInfo = string.format(textRes.Gang[358], joinDate.year, joinDate.month, joinDate.day)
  uiTbl.Label_Data:GetComponent("UILabel"):set_text(dateInfo)
  local iconGo = uiTbl.Img_Icon
  if memberInfo.avatarId and 0 < memberInfo.avatarId then
    SetAvatarIcon(iconGo, memberInfo.avatarId, memberInfo.avatar_frame or 0)
  else
    local modelid = GetOccupationCfg(memberInfo.occupationId, memberInfo.gender).modelId
    local iconid = self:GetIconByModel(modelid)
    local texture = iconGo:GetComponent("UITexture")
    GUIUtils.FillIcon(texture, iconid)
  end
end
def.method().UpdateMemberButton = function(self)
  local Group_Btn = self.uiTbl.Group_Btn
  local uiGrid = Group_Btn:GetComponent("UIGrid")
  local template = self.uiTbl.btnTemplate
  local itemCount = #self.buttonList
  for i = 1, itemCount do
    local itemObj = Group_Btn:FindDirect("Btn_" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(template)
      itemObj:SetActive(true)
      itemObj.name = "Btn_" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
    end
    itemObj:FindDirect("Label"):GetComponent("UILabel"):set_text(self.buttonList[i].name)
  end
  local unuseIdx = itemCount + 1
  while true do
    local itemObj = Group_Btn:FindDirect("Btn_" .. unuseIdx)
    if itemObj == nil then
      break
    end
    GameObject.Destroy(itemObj)
    unuseIdx = unuseIdx + 1
  end
  GameUtil.AddGlobalLateTimer(0, true, function(...)
    Group_Btn:GetComponent("UIGrid"):Reposition()
  end)
end
def.method().FillMemberButtons = function(self)
  self.buttonList = {}
  local memberInfo = self.memberInfo
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local heroMember = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  local bangzhuId = GangUtility.GetGangConsts("BANGZHU_ID")
  local fubangzhuId = GangUtility.GetGangConsts("FUBANGZHU_ID")
  local zhanglaoId = GangUtility.GetGangConsts("ZHANGLAO_ID")
  local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
  if memberInfo.roleId ~= heroProp.id then
    if heroMember.duty == bangzhuId then
      local str = textRes.Gang[278]
      table.insert(self.buttonList, {name = str, id = 4})
    end
    local heroDutyLv = GangUtility.GetDutyLv(heroMember.duty)
    local memberDutyLv = GangUtility.GetDutyLv(memberInfo.duty)
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
  end
  if heroMember.duty == bangzhuId and memberInfo.duty ~= xuetuId then
    local str = textRes.Gang[283]
    table.insert(self.buttonList, {name = str, id = 8})
  end
  self:UpdateMemberButton()
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Modal" == id then
    self:Hide()
  else
    if string.find(id, "Btn_") then
      local index = tonumber(string.sub(id, 5))
      if index ~= nil then
        self:OnButtonClick(index)
      end
    else
    end
  end
end
def.method("number").OnButtonClick = function(self, index)
  local id = self.buttonList[index].id
  if id == 4 then
    self:RequireToChuanwei()
  elseif id == 5 then
    self:RequireToAppoint()
  elseif id == 6 then
    self:RequireToForbidTalk()
  elseif id == 7 then
    self:RequireToLeaveGang()
  elseif id == 8 then
    self:RequireToGiftBox()
  end
end
def.static("number", "table").ChuanweiCallback = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CChangeDutyReq").new(tag.targetId, tag.duty))
  elseif i == 0 then
  end
end
def.method().RequireToChuanwei = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local memberInfo = self.memberInfo
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
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Gang[81], memberInfo.name), GangMemberTipPanel.ChuanweiCallback, tag)
end
def.method().RequireToAppoint = function(self)
  GangAppointPanel.ShowGangAppointPanel(nil, nil, self.memberInfo.roleId)
end
def.method().RequireToForbidTalk = function(self)
  local memberInfo = self.memberInfo
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
  local memberInfo = self.memberInfo
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
def.method().RequireToGiftBox = function(self)
  local GangGiftBoxPanel = require("Main.Gang.ui.GangGiftBoxPanel")
  GangGiftBoxPanel.ShowGiftBoxPanelToMember(self.memberInfo.roleId)
end
def.static("table", "table").OnGangMemberInfoChange = function(params, context)
  local self = instance
  local memberInfo = self.memberInfo
  if memberInfo and memberInfo.roleId == params.roleid then
    self:UpdateMemberInfo()
    self:FillMemberButtons()
  end
end
return GangMemberTipPanel.Commit()

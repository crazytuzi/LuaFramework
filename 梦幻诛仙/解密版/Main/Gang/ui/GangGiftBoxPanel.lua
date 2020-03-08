local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangGiftBoxPanel = Lplus.Extend(ECPanelBase, "GangGiftBoxPanel")
local def = GangGiftBoxPanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
def.field("table").selectList = nil
def.field("table").memberList = nil
def.field("userdata").memberRoleId = nil
def.field("userdata").selectedItem = nil
def.static("=>", GangGiftBoxPanel).Instance = function(self)
  if nil == instance then
    instance = GangGiftBoxPanel()
  end
  return instance
end
def.static().ShowGiftBoxPanel = function()
  GangGiftBoxPanel.Instance():SetModal(true)
  GangGiftBoxPanel.Instance():CreatePanel(RESPATH.PREFAB_GANG_GIFT_BOX_PANEL, 2)
end
def.static("userdata").ShowGiftBoxPanelToMember = function(memberRoleId)
  GangGiftBoxPanel.Instance().memberRoleId = memberRoleId
  GangGiftBoxPanel.ShowGiftBoxPanel()
end
def.override().OnCreate = function(self)
  self:RequestGongXunData()
  self:InitMemberList()
  self:UpdateInfo()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemeberQuited, GangGiftBoxPanel.OnMemberQuit)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberLiheChanged, GangGiftBoxPanel.OnMemberLiheChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_LiheInfoChanged, GangGiftBoxPanel.OnLiheInfoChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberAdd, GangGiftBoxPanel.OnMemberAdd)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberGongXunChanged, GangGiftBoxPanel.OnMemberGongXunChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangLiHeReset, GangGiftBoxPanel.OnMemberLiheChanged)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemeberQuited, GangGiftBoxPanel.OnMemberQuit)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberLiheChanged, GangGiftBoxPanel.OnMemberLiheChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_LiheInfoChanged, GangGiftBoxPanel.OnLiheInfoChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberAdd, GangGiftBoxPanel.OnMemberAdd)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberGongXunChanged, GangGiftBoxPanel.OnMemberGongXunChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangLiHeReset, GangGiftBoxPanel.OnMemberLiheChanged)
  self.memberRoleId = nil
  self.selectedItem = nil
end
def.method().RequestGongXunData = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CRefreshGongXunReq").new())
end
def.method().InitMemberList = function(self)
  self.selectList = {}
  self.memberList = {}
  local list = GangData.Instance():GetMemberList()
  local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
  for k, v in pairs(list) do
    if v.duty ~= xuetuId then
      table.insert(self.memberList, v)
    end
  end
  GangData.Instance():InitGiftSortMemberList()
  local sortTbl = GangData.Instance():GetGiftSortTimesTbl()
  GangData.Instance():MembersSortByDuty(sortTbl, self.memberList)
end
def.method().UpdateInfo = function(self)
  self:UpdateMemberList(true)
  self:UpdateSendGiftInfo()
  self:SelectTargetMember()
end
def.method().UpdateSendGiftInfo = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_Num = Img_Bg0:FindDirect("Img_BgNum/Label_Num"):GetComponent("UILabel")
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local warehouseTbl = require("Main.Gang.GangUtility").GetWarehouseGangBasicCfg(gangInfo.warehouseLevel)
  local selectNum = 0
  for k, v in pairs(self.selectList) do
    if v == true then
      selectNum = selectNum + 1
    end
  end
  local remain = GangData.Instance():GetRemainLihe() - selectNum
  Label_Num:set_text(string.format("%d/%d", remain, warehouseTbl.gridSize))
end
def.method("boolean").UpdateMemberList = function(self, bRefresh)
  local memberAmount = #self.memberList
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Left = Img_Bg0:FindDirect("Group_Left")
  local ScrollView = Group_Left:FindDirect("Group_Rank/Scroll View")
  local List_Left = ScrollView:FindDirect("List_GangMember"):GetComponent("UIList")
  List_Left:set_itemCount(memberAmount)
  List_Left:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not List_Left.isnil then
      List_Left:Reposition()
    end
  end)
  local members = List_Left:get_children()
  for i = 1, memberAmount do
    local memberUI = members[i]
    local memberInfo = self.memberList[i]
    self:FillMemberInfo(memberUI, i, memberInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  if bRefresh then
    ScrollView:GetComponent("UIScrollView"):ResetPosition()
  end
end
def.method("userdata", "number", "table").FillMemberInfo = function(self, memberUI, index, memberInfo)
  local Label_GangName = memberUI:FindDirect(string.format("Label1_%d", index))
  local Label_Job = memberUI:FindDirect(string.format("Label3_%d", index))
  local Label_Level = memberUI:FindDirect(string.format("Label2_%d", index))
  local Label_GongNum = memberUI:FindDirect(string.format("Label4_%d", index))
  local Label_XunNum = memberUI:FindDirect(string.format("Label5_%d", index))
  local Label_RoleId = memberUI:FindDirect(string.format("Label_RoleId_%d", index))
  Label_GangName:GetComponent("UILabel"):set_text(memberInfo.name)
  local dutyName = GangData.Instance():GetDutyName(memberInfo.duty)
  Label_Job:GetComponent("UILabel"):set_text(dutyName)
  Label_Level:GetComponent("UILabel"):set_text(memberInfo.level)
  Label_GongNum:GetComponent("UILabel"):set_text(string.format("%d/%d", memberInfo.curBangGong, memberInfo.historyBangGong))
  Label_XunNum:GetComponent("UILabel"):set_text(memberInfo.gongXun)
  Label_RoleId:GetComponent("UILabel"):set_text(memberInfo.roleId:tostring())
  Label_RoleId:SetActive(false)
  local Group_Select = memberUI:FindDirect(string.format("Group_Select_%d", index))
  local Img_Sent = memberUI:FindDirect(string.format("Img_Sent_%d", index))
  local Img_NoWay = memberUI:FindDirect(string.format("Img_NoWay_%d", index))
  if memberInfo.isRewardLiHe == 1 then
    Group_Select:SetActive(false)
    Img_Sent:SetActive(true)
    Img_NoWay:SetActive(false)
  else
    local days = GangUtility.GetGangConsts("CAN_GET_LIHE_NEED_JOIN_DAY")
    if days > memberInfo.joinDays then
      Group_Select:SetActive(false)
      Img_Sent:SetActive(false)
      Img_NoWay:SetActive(true)
    else
      Group_Select:SetActive(true)
      if self.selectList[memberInfo.roleId:tostring()] == true then
        memberUI:GetComponent("UIToggle"):set_value(true)
      else
        memberUI:GetComponent("UIToggle"):set_value(false)
      end
      Img_Sent:SetActive(false)
      Img_NoWay:SetActive(false)
    end
  end
  if self.memberRoleId ~= nil and memberInfo.roleId == self.memberRoleId then
    self.selectedItem = memberUI
  end
end
def.method().SelectTargetMember = function(self)
  if not self.memberRoleId or not self.selectedItem then
    return
  end
  local roleId = Int64.tostring(self.memberRoleId)
  self:OnMemberClicked(roleId, true, self.selectedItem)
  self.memberRoleId = nil
  self.selectedItem = nil
end
def.method("string", "boolean", "userdata").OnMemberSelected = function(self, roleId, bSelect, clickobj)
  if bSelect then
    local selectNum = 0
    for k, v in pairs(self.selectList) do
      if v == true then
        selectNum = selectNum + 1
      end
    end
    local remain = GangData.Instance():GetRemainLihe() - selectNum
    if remain <= 0 then
      Toast(textRes.Gang[134])
      clickobj:GetComponent("UIToggle"):set_value(false)
    elseif self.selectList[roleId] == nil then
      self.selectList[roleId] = true
    end
  elseif self.selectList[roleId] ~= nil then
    self.selectList[roleId] = nil
  end
  self:UpdateSendGiftInfo()
end
def.method("string", "boolean", "userdata").OnMemberClicked = function(self, roleId, bSelect, clickobj)
  clickobj:GetComponent("UIToggle"):set_value(bSelect)
  local id = Int64.ParseString(roleId)
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(id)
  local days = GangUtility.GetGangConsts("CAN_GET_LIHE_NEED_JOIN_DAY")
  if memberInfo.isRewardLiHe == 1 then
    Toast(textRes.Gang[132])
  elseif days > memberInfo.joinDays then
    Toast(string.format(textRes.Gang[131], days))
  else
    self:OnMemberSelected(roleId, bSelect, clickobj)
  end
end
def.method().OnSendGiftClicked = function(self)
  local tbl = {}
  for k, v in pairs(self.selectList) do
    if v == true then
      local roleId = Int64.ParseString(k)
      table.insert(tbl, roleId)
    end
  end
  if #tbl > 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CDispatchLiHeReq").new(tbl))
    self.selectList = {}
  else
    Toast(textRes.Gang[133])
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif string.sub(id, 1, #"Group_Info_") == "Group_Info_" then
    local index = tonumber(string.sub(id, #"Group_Info_" + 1, -1))
    local roleId = clickobj:FindDirect(string.format("Label_RoleId_%d", index)):GetComponent("UILabel"):get_text()
    local bSelect = clickobj:GetComponent("UIToggle"):get_value()
    self:OnMemberClicked(roleId, bSelect, clickobj)
  elseif string.sub(id, 1, #"Toggle_Select_") == "Toggle_Select_" then
    local index = tonumber(string.sub(id, #"Toggle_Select_" + 1, -1))
    local roleId = clickobj.parent:FindDirect(string.format("Label_RoleId_%d", index)):GetComponent("UILabel"):get_text()
    local bSelect = clickobj:GetComponent("UIToggle"):get_value()
    self:OnMemberSelected(roleId, bSelect, clickobj)
  elseif "Btn_Send" == id then
    self:OnSendGiftClicked()
  elseif "Label1" == id then
    GangData.Instance():AddGiftSortTimes(GangData.SortType.Name)
    local sortTbl = GangData.Instance():GetGiftSortTimesTbl()
    local memberTbl = self.memberList
    GangData.Instance():MembersSortByName(sortTbl, memberTbl)
    self:UpdateMemberList(true)
  elseif "Label2" == id then
    GangData.Instance():AddGiftSortTimes(GangData.SortType.Level)
    local sortTbl = GangData.Instance():GetGiftSortTimesTbl()
    local memberTbl = self.memberList
    GangData.Instance():MembersSortByLevel(sortTbl, memberTbl)
    self:UpdateMemberList(true)
  elseif "Label3" == id then
    GangData.Instance():AddGiftSortTimes(GangData.SortType.Duty)
    local sortTbl = GangData.Instance():GetGiftSortTimesTbl()
    local memberTbl = self.memberList
    GangData.Instance():MembersSortByDuty(sortTbl, memberTbl)
    self:UpdateMemberList(true)
  elseif "Label4" == id then
    GangData.Instance():AddGiftSortTimes(GangData.SortType.Banggong)
    local sortTbl = GangData.Instance():GetGiftSortTimesTbl()
    local memberTbl = self.memberList
    GangData.Instance():MembersSortByBanggong(sortTbl, memberTbl)
    self:UpdateMemberList(true)
  elseif "Label5" == id then
  elseif "Modal" == id then
    self:DestroyPanel()
    self = nil
  end
end
def.static("table", "table").OnLiheInfoChanged = function(params, tbl)
  GangGiftBoxPanel.Instance():UpdateSendGiftInfo()
end
def.static("table", "table").OnMemberLiheChanged = function(params, tbl)
  GangGiftBoxPanel.Instance():UpdateMemberList(false)
end
def.static("table", "table").OnMemberQuit = function(params, tbl)
  local memberList = instance.memberList
  local selectList = instance.selectList
  local quitList = params
  for _, v in ipairs(quitList) do
    for i, info in ipairs(memberList) do
      if info.roleId == v then
        table.remove(memberList, i)
        break
      end
    end
    selectList[Int64.tostring(v)] = nil
  end
  instance:UpdateMemberList(false)
  instance:UpdateSendGiftInfo()
end
def.static("table", "table").OnMemberAdd = function(params, tbl)
  local memberList = instance.memberList
  local memberInfo = params[1]
  table.insert(memberList, memberInfo)
  instance:UpdateMemberList(false)
  instance:UpdateSendGiftInfo()
end
def.static("table", "table").OnMemberGongXunChanged = function(params, tbl)
  instance:UpdateMemberList(false)
end
return GangGiftBoxPanel.Commit()

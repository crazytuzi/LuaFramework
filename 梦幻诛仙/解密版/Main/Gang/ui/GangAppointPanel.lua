local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangAppointPanel = Lplus.Extend(ECPanelBase, "GangAppointPanel")
local def = GangAppointPanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
def.field("function").callback = nil
def.field("table").tag = nil
def.field("table").dutyTbl = nil
def.field("table").allDutyTbl = nil
def.field("number").selectDutyId = 0
def.field("userdata").selectRoleId = nil
def.field("number").xuetuNum = 0
def.static("=>", GangAppointPanel).Instance = function(self)
  if nil == instance then
    instance = GangAppointPanel()
  end
  return instance
end
def.static("function", "table", "userdata").ShowGangAppointPanel = function(callback, tag, selectRoleId)
  GangAppointPanel.Instance().callback = callback
  GangAppointPanel.Instance().tag = tag
  GangAppointPanel.Instance().selectRoleId = selectRoleId
  GangAppointPanel.Instance():SetModal(true)
  GangAppointPanel.Instance():CreatePanel(RESPATH.PREFAB_APPOINT_GANG_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.xuetuNum = 0
end
def.method().UpdateUI = function(self)
  self:UpdateData()
  self:UpdateDutyList()
end
def.method().UpdateData = function(self)
  self.dutyTbl = {}
  self.selectDutyId = 0
  self.allDutyTbl = {}
  local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
  local bangzhongId = GangUtility.GetGangConsts("BANGZHONG_ID")
  local memberList = GangData.Instance():GetMemberList()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local heroInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  if nil ~= heroInfo then
    local heroDutyLv = GangUtility.GetDutyLv(heroInfo.duty)
    for k, v in pairs(memberList) do
      if v.duty == xuetuId then
        self.xuetuNum = self.xuetuNum + 1
      end
      local GangUtility = require("Main.Gang.GangUtility")
      local dutyLv = GangUtility.GetDutyLv(v.duty)
      if heroDutyLv < dutyLv then
        if self.dutyTbl[dutyLv] == nil then
          self.dutyTbl[dutyLv] = {
            dutyId = v.duty,
            count = 1
          }
        else
          self.dutyTbl[dutyLv].count = self.dutyTbl[dutyLv].count + 1
        end
      end
    end
    local gangInfo = GangData.Instance():GetGangBasicInfo()
    local entries = DynamicData.GetTable(CFG_PATH.DATA_GANG_DUTY_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local dutyId = DynamicRecord.GetIntValue(entry, "id")
      local dutyLevel = DynamicRecord.GetIntValue(entry, "dutyLevel")
      if heroDutyLv < dutyLevel and xuetuId ~= dutyId then
        local max = GangUtility.GetDutyMaxNum(dutyId, gangInfo.wingLevel)
        local remain = max
        if dutyId == bangzhongId then
          remain = max - (#memberList - self.xuetuNum)
        elseif self.dutyTbl[dutyLevel] ~= nil then
          remain = max - self.dutyTbl[dutyLevel].count
        end
        table.insert(self.allDutyTbl, {dutyId = dutyId, remain = remain})
      end
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
end
def.method().UpdateDutyList = function(self)
  local Group_List = self.m_panel:FindDirect("Img_Bg0/Group_List")
  local ScrollView = Group_List:FindDirect("Scroll View")
  local List = ScrollView:FindDirect("List"):GetComponent("UIList")
  local amount = #self.allDutyTbl
  List:set_itemCount(amount)
  List:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not List.isnil then
      List:Reposition()
    end
  end)
  local dutys = List:get_children()
  for i = 1, amount do
    local dutyUI = dutys[i]
    local dutyInfo = self.allDutyTbl[i]
    self:FillDutyInfo(dutyUI, i, dutyInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  ScrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "table").FillDutyInfo = function(self, dutyUI, index, dutyInfo)
  local Label_Job = dutyUI:FindDirect(string.format("Label_Job_%d", index)):GetComponent("UILabel")
  local Label_JobRename = dutyUI:FindDirect(string.format("Label_JobRename_%d", index)):GetComponent("UILabel")
  local Label_Num = dutyUI:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel")
  local dutyId = dutyInfo.dutyId
  local name = GangUtility.GetDutyDefaultName(dutyId)
  Label_Job:set_text(name)
  local rename = GangData.Instance():GetDutyName(dutyId)
  Label_JobRename:set_text(rename)
  if dutyInfo.remain < 0 then
    Label_Num:set_text(0)
  else
    Label_Num:set_text(dutyInfo.remain)
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method("number", "userdata").SelectDuty = function(self, index, clickobj)
  local dutyInfo = self.allDutyTbl[index]
  if dutyInfo == nil then
    return
  end
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(self.selectRoleId)
  local xuetuId = GangUtility.GetGangConsts("XUETU_ID")
  if memberInfo.duty == xuetuId then
    local memberList = GangData.Instance():GetMemberList()
    local bangzhongId = GangUtility.GetGangConsts("BANGZHONG_ID")
    local gangInfo = GangData.Instance():GetGangBasicInfo()
    local bangzhongMax = GangUtility.GetDutyMaxNum(bangzhongId, gangInfo.wingLevel)
    if bangzhongMax <= #memberList - self.xuetuNum then
      Toast(textRes.Gang[252])
      clickobj:GetComponent("UIToggle"):set_isChecked(false)
      return
    end
  end
  if dutyInfo.remain == 0 then
    Toast(textRes.Gang[85])
    clickobj:GetComponent("UIToggle"):set_isChecked(false)
    return
  end
  self.selectDutyId = dutyInfo.dutyId
end
def.method().OnAppointDutyClick = function(self)
  if 0 == self.selectDutyId then
    Toast(textRes.Gang[86])
    return
  end
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(self.selectRoleId)
  if nil == memberInfo then
    return
  end
  if memberInfo.duty == self.selectDutyId then
    Toast(textRes.Gang[112])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CChangeDutyReq").new(self.selectRoleId, self.selectDutyId))
  self:Hide()
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Img_BgList_") == "Img_BgList_" then
    if clickobj:GetComponent("UIToggle"):get_isChecked() then
      local index = tonumber(string.sub(id, #"Img_BgList_" + 1, -1))
      self:SelectDuty(index, clickobj)
    else
      self.selectDutyId = 0
    end
  elseif "Btn_Yes" == id then
    self:OnAppointDutyClick()
  elseif "Btn_No" == id then
    self:Hide()
  elseif "Btn_Close" == id then
    self:Hide()
  elseif "Modal" == id then
    self:Hide()
  end
end
return GangAppointPanel.Commit()

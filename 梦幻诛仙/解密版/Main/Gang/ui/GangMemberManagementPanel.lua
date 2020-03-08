local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangMemberManagementPanel = Lplus.Extend(ECPanelBase, "GangMemberManagementPanel")
local def = GangMemberManagementPanel.define
local instance
def.field("table").data = nil
def.field("table").uiTbl = nil
def.field("table").listItems = nil
def.field("table").gangMembers = nil
def.field("table").sortFunction = nil
def.field("table").selectMember = nil
def.field("number").curPage = 1
def.field("number").sortType = 0
def.field("number").timeType = 0
def.field("boolean").sortTitleUp = false
def.field("boolean").selectAllBtnState = true
local MemberSortType = {
  NAME = 1,
  LEVEL = 2,
  MENPAI = 3,
  DUTY = 4,
  CURBANGGONG = 5,
  HISBANGGONG = 6,
  WEEKBANGGONG = 7,
  OFFLINE = 8,
  SHENZHAO = 9,
  GONGXUN = 10,
  LIHE = 11,
  JOINTIME = 12
}
local OfflineTimeConfig = {
  {time = 0, txt = "\231\169\186"},
  {time = 86400, txt = "1\229\164\169"},
  {time = 259200, txt = "3\229\164\169"},
  {time = 604800, txt = "7\229\164\169"},
  {time = 1209600, txt = "14\229\164\169"}
}
def.static("=>", GangMemberManagementPanel).Instance = function(self)
  if nil == instance then
    instance = GangMemberManagementPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_GANG_MEMBER_MANGEMENT_PANEL, 1)
end
def.override().OnCreate = function(self)
  self.data = require("Main.Gang.data.GangData").Instance()
  self.sortType = 0
  self.timeType = 0
  self.sortTitleUp = false
  self.selectMember = nil
  self:InitUI()
  self:InitSort()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberInfoChange, GangMemberManagementPanel.OnGangMemberInfoChange)
end
def.override().OnDestroy = function(self)
  self.selectMember = nil
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberInfoChange, GangMemberManagementPanel.OnGangMemberInfoChange)
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Top = Img_Bg:FindDirect("Group_Top")
  local Top_Level = Group_Top:FindDirect("Img_Level/Label_Num")
  local Top_ShenZhao = Group_Top:FindDirect("Img_ShenZhao/Label_Num")
  local Top_BangGong = Group_Top:FindDirect("Img_BangGong/Label_Num")
  local Top_Container = Group_Top:FindDirect("Container")
  local Img_Di_Label = Top_Container:FindDirect("Img_Di/Label")
  local Img_Di_Img_Up = Top_Container:FindDirect("Img_Di/Img_Up")
  local Img_Di_Img_Down = Top_Container:FindDirect("Img_Di/Img_Down")
  local Top_Panel = Top_Container:FindDirect("Panel")
  local PanelListGO = Top_Panel:FindDirect("Img_Bg2/Scroll View/List_Item2")
  uiTbl.Top_Level = Top_Level
  uiTbl.Top_ShenZhao = Top_ShenZhao
  uiTbl.Top_BangGong = Top_BangGong
  uiTbl.Top_Panel = Top_Panel
  uiTbl.Top_BtnUp = Img_Di_Img_Up
  uiTbl.Top_BtnDown = Img_Di_Img_Down
  uiTbl.Top_Container = Top_Container
  uiTbl.Top_ImgDi_Label = Img_Di_Label
  uiTbl.PanelListGO = PanelListGO
  local Group_Center = Img_Bg:FindDirect("Group_Center")
  local Group_Title = Group_Center:FindDirect("Group_Title")
  local Title_Group_1 = Group_Title:FindDirect("Group_1")
  local Title_Group_2 = Group_Title:FindDirect("Group_2")
  uiTbl.Group_Title = {}
  uiTbl.Group_Title[1] = Title_Group_1
  uiTbl.Group_Title[2] = Title_Group_2
  uiTbl.TitleSortButton = {
    [MemberSortType.NAME] = Group_Title:FindDirect("Label_2"),
    [MemberSortType.LEVEL] = Title_Group_1:FindDirect("Label_3"),
    [MemberSortType.MENPAI] = Title_Group_1:FindDirect("Label_4"),
    [MemberSortType.DUTY] = Title_Group_1:FindDirect("Label_5"),
    [MemberSortType.CURBANGGONG] = Title_Group_1:FindDirect("Label_6"),
    [MemberSortType.WEEKBANGGONG] = Title_Group_1:FindDirect("Label_7"),
    [MemberSortType.HISBANGGONG] = Title_Group_1:FindDirect("Label_8"),
    [MemberSortType.OFFLINE] = Title_Group_1:FindDirect("Label_9"),
    [MemberSortType.SHENZHAO] = Title_Group_2:FindDirect("Label_3"),
    [MemberSortType.GONGXUN] = Title_Group_2:FindDirect("Label_4"),
    [MemberSortType.LIHE] = Title_Group_2:FindDirect("Label_5"),
    [MemberSortType.JOINTIME] = Title_Group_2:FindDirect("Label_7")
  }
  local Group_List = Group_Center:FindDirect("Group_List")
  local Btn_SwitchLeft = Group_List:FindDirect("Panel/Btn_SwitchLeft")
  local Btn_SwitchRight = Group_List:FindDirect("Panel/Btn_SwitchRight")
  uiTbl.Group_List = Group_List
  uiTbl.Btn_SwitchLeft = Btn_SwitchLeft
  uiTbl.Btn_SwitchRight = Btn_SwitchRight
  local Group_Empty = Group_Center:FindDirect("Group_Empty")
  uiTbl.Group_Empty = Group_Empty
  local Group_Bottom = Img_Bg:FindDirect("Group_Bottom")
  local Btn_SelectAll = Group_Bottom:FindDirect("Btn_SelectAll")
  uiTbl.Btn_SelectAll = Btn_SelectAll
  Img_Di_Img_Up:SetActive(false)
  Btn_SwitchLeft:SetActive(false)
  Btn_SwitchRight:SetActive(true)
  self:ChangeSelctBtnState(true)
end
def.method().InitTopPanel = function(self)
  local PanelListGO = self.uiTbl.PanelListGO
  local itemCount = #OfflineTimeConfig
  local listItems = GUIUtils.InitUIList(PanelListGO, itemCount)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local labalGo = itemGO:FindDirect(string.format("Btn_Item2_%d/Label_Name2_%d", i, i))
    labalGo:GetComponent("UILabel"):set_text(OfflineTimeConfig[i].txt)
  end
  GUIUtils.Reposition(PanelListGO, GUIUtils.COTYPE.LIST, 0)
end
def.override("boolean").OnShow = function(self, s)
  GameUtil.AddGlobalTimer(0.01, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self:InitTopPanel()
      self:InitGangMembers()
      self:FillMembersNewList(true)
    end
  end)
end
def.method().InitGangMembers = function(self)
  local gangMembers = {}
  local memberList = self.data:GetMemberList()
  for _, memberInfo in ipairs(memberList) do
    table.insert(gangMembers, {info = memberInfo, state = false})
  end
  self.gangMembers = gangMembers
end
def.method("number").ChangePage = function(self, page)
  local listItems = self.listItems
  local Group_Title = self.uiTbl.Group_Title
  local Btn_SwitchLeft = self.uiTbl.Btn_SwitchLeft
  local Btn_SwitchRight = self.uiTbl.Btn_SwitchRight
  Group_Title[1]:SetActive(page == 1)
  Group_Title[2]:SetActive(page == 2)
  Btn_SwitchLeft:SetActive(page == 2)
  Btn_SwitchRight:SetActive(page == 1)
  for _, memberUI in pairs(listItems) do
    memberUI:FindDirect("Group_1"):SetActive(page == 1)
    memberUI:FindDirect("Group_2"):SetActive(page == 2)
  end
  self.curPage = page
end
def.method("boolean").ChangeSelctBtnState = function(self, selectAll)
  local label = self.uiTbl.Btn_SelectAll:FindDirect("Label")
  if selectAll then
    label:GetComponent("UILabel"):set_text(textRes.Gang[356])
  else
    label:GetComponent("UILabel"):set_text(textRes.Gang[357])
  end
  self.selectAllBtnState = selectAll
end
def.method("boolean").ShowTopPanel = function(self, show)
  self.uiTbl.Top_Panel:SetActive(show)
  self.uiTbl.Top_BtnUp:SetActive(show)
  self.uiTbl.Top_BtnDown:SetActive(not show)
end
def.method("boolean").FillMembersNewList = function(self, bResetScrollView)
  local memberList = self.gangMembers or {}
  local scrollViewObj = self.uiTbl.Group_List:FindDirect("Scroll View")
  local scrollListObj = scrollViewObj:FindDirect("List_Member")
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  self.listItems = {}
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillMemberInfo(item, i, memberList[i])
  end)
  ScrollList_setCount(uiScrollList, #memberList)
  self.m_msgHandler:Touch(scrollListObj)
  if bResetScrollView then
    scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
  end
end
def.method("userdata", "number", "table").FillMemberInfo = function(self, memberUI, index, member)
  local Img_Toggle = memberUI:FindDirect("Img_Toggle")
  Img_Toggle:GetComponent("UIToggle"):set_value(member.state)
  local Img_Bg1 = memberUI:FindDirect("Img_Bg1")
  local Img_Bg2 = memberUI:FindDirect("Img_Bg2")
  if index % 2 == 0 then
    Img_Bg1:SetActive(false)
    Img_Bg2:SetActive(true)
  else
    Img_Bg1:SetActive(true)
    Img_Bg2:SetActive(false)
  end
  self:UpdateMemberInfo(memberUI, member.info)
  self.listItems[index] = memberUI
end
def.method("userdata", "table").UpdateMemberInfo = function(self, memberUI, memberInfo)
  local Label_UserName = memberUI:FindDirect("Label_UserName")
  local Label_ZhuangTai = memberUI:FindDirect("Group_1/Label_State")
  local Label_School = memberUI:FindDirect("Group_1/Label_MenPai")
  local Label_Job = memberUI:FindDirect("Group_1/Label_ZhiWei")
  local Label_Level = memberUI:FindDirect("Group_1/Label_Level")
  local Label_GongNum1 = memberUI:FindDirect("Group_1/Label_BangGong")
  local Label_GongNum2 = memberUI:FindDirect("Group_1/Label_ShenZhao")
  local Label_GongNum3 = memberUI:FindDirect("Group_1/Label_GongXun")
  local Label_ShenZhao = memberUI:FindDirect("Group_2/Label_ShangJiao")
  local Label_GongXun = memberUI:FindDirect("Group_2/Label_GongXun")
  local Label_LiHe = memberUI:FindDirect("Group_2/Label_LiHe")
  local Label_RuBang = memberUI:FindDirect("Group_2/Label_RuBang")
  local Img_NoSpeak = memberUI:FindDirect("Img_NoSpeak")
  Label_UserName:GetComponent("UILabel"):set_text(memberInfo.name)
  if -1 == memberInfo.offlineTime then
    Label_ZhuangTai:GetComponent("UILabel"):set_text(textRes.Gang[285])
  else
    local time = GangUtility.GetTime(memberInfo.offlineTime)
    Label_ZhuangTai:GetComponent("UILabel"):set_text(time)
  end
  local occupationName = _G.GetOccupationName(memberInfo.occupationId)
  Label_School:GetComponent("UILabel"):set_text(occupationName)
  local dutyName = self.data:GetDutyName(memberInfo.duty)
  Label_Job:GetComponent("UILabel"):set_text(dutyName)
  Label_Level:GetComponent("UILabel"):set_text(memberInfo.level)
  local historyBangGong = memberInfo.historyBangGong
  if historyBangGong < 0 then
    historyBangGong = 0
  end
  Label_GongNum1:GetComponent("UILabel"):set_text(memberInfo.curBangGong)
  Label_GongNum2:GetComponent("UILabel"):set_text(memberInfo.weekBangGong)
  Label_GongNum3:GetComponent("UILabel"):set_text(historyBangGong)
  Label_ShenZhao:GetComponent("UILabel"):set_text(memberInfo.weekItem_banggong_count)
  Label_GongXun:GetComponent("UILabel"):set_text(memberInfo.gongXun)
  Label_LiHe:GetComponent("UILabel"):set_text(memberInfo.isRewardLiHe)
  Label_RuBang:GetComponent("UILabel"):set_text(GangUtility.GetTime(GangData.TimeToSecond(memberInfo.joinTime)))
  if self.selectMember and self.selectMember.roleId == memberInfo.roleId then
    memberUI:GetComponent("UIToggle"):set_value(true)
  else
    memberUI:GetComponent("UIToggle"):set_value(false)
  end
  Img_NoSpeak:SetActive(memberInfo.forbiddenTalk ~= 0)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local setColor = Color.Color(0.56, 0.24, 0.13, 1)
  if heroProp.id == memberInfo.roleId then
    setColor = Color.Color(0, 0.686, 0, 1)
  end
  Label_UserName:GetComponent("UILabel"):set_textColor(setColor)
  Label_ZhuangTai:GetComponent("UILabel"):set_textColor(setColor)
  Label_School:GetComponent("UILabel"):set_textColor(setColor)
  Label_Job:GetComponent("UILabel"):set_textColor(setColor)
  Label_Level:GetComponent("UILabel"):set_textColor(setColor)
  Label_GongNum1:GetComponent("UILabel"):set_textColor(setColor)
  Label_GongNum2:GetComponent("UILabel"):set_textColor(setColor)
  Label_GongNum3:GetComponent("UILabel"):set_textColor(setColor)
  Label_ShenZhao:GetComponent("UILabel"):set_textColor(setColor)
  Label_GongXun:GetComponent("UILabel"):set_textColor(setColor)
  Label_LiHe:GetComponent("UILabel"):set_textColor(setColor)
  Label_RuBang:GetComponent("UILabel"):set_textColor(setColor)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif "Btn_Clean" == id then
    self:OnBtnCleanClick()
  elseif "Btn_SelectAll" == id then
    self:OnBtnSelectAllClick()
  elseif "Btn_Tip" == id then
    self:OnBtnTipsClick()
  elseif "Img_Search" == id then
    self:OnBtnSearchClick()
  elseif "Btn_SwitchLeft" == id then
    self:OnBtnSwitchLeftClick()
  elseif "Btn_SwitchRight" == id then
    self:OnBtnSwitchRightClick()
  elseif "Img_Di" == id then
    self:OnBtnImgDiClick()
  elseif string.find(id, "Label_") then
    for sortType, labelGo in ipairs(self.uiTbl.TitleSortButton) do
      if clickobj.name == labelGo.name and clickobj.parent and clickobj.parent.name == labelGo.parent.name then
        self:ChangeMemberSort(sortType)
      end
    end
  elseif string.find(id, "Btn_Item2_") then
    local index = tonumber(string.sub(id, 11))
    if index ~= nil then
      self:OnBtnTopPanelClick(index)
    end
  elseif "Img_Toggle" == id then
    self:OnBtnListImgToggleClick(clickobj)
  else
    if "Group_List" == id then
      self:OnBtnListItemClick(clickobj)
    else
    end
  end
  if "Img_Di" ~= id and self then
    self:ShowTopPanel(false)
  end
end
def.method().OnBtnCleanClick = function(self)
  warn("OnBtnCleanClick")
  local selectList = {}
  local memberList = {}
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local heroMember = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  local heroDutyLv = GangUtility.GetDutyLv(heroMember.duty)
  for k, v in pairs(self.gangMembers) do
    if v.state then
      local memberDutyLv = GangUtility.GetDutyLv(v.info.duty)
      if v.info.roleId == heroProp.id then
        Toast(textRes.Gang[361])
        return
      end
      if heroDutyLv > memberDutyLv then
        Toast(textRes.Gang[362])
        return
      end
      table.insert(selectList, v)
    else
      table.insert(memberList, v)
    end
  end
  if #selectList > 0 then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.Gang[359], function(id, tag)
      if id == 1 then
        for k, v in pairs(selectList) do
          local memberInfo = v.info
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CKickOutMemberReq").new(memberInfo.roleId))
        end
        local curCount = 0
        local allCount = #self.gangMembers
        self.gangMembers = memberList
        self:ChangeSelctBtnState(true)
        self:FillMembersNewList(true)
        warn("----------\229\183\178\233\128\137\228\184\173: [", curCount, "|", allCount, "]")
      end
    end, nil)
  end
end
def.method().OnBtnSelectAllClick = function(self)
  for _, member in ipairs(self.gangMembers) do
    member.state = self.selectAllBtnState
  end
  for _, memberUI in pairs(self.listItems) do
    memberUI:FindDirect("Img_Toggle"):GetComponent("UIToggle"):set_value(self.selectAllBtnState)
  end
  local count = #self.gangMembers
  if self.selectAllBtnState and count > 0 then
    warn("----------\229\183\178\233\128\137\228\184\173: [", count, "|", count, "]")
  end
  self:ChangeSelctBtnState(count == 0 or not self.selectAllBtnState)
end
def.method().OnBtnTipsClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701602025)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method().OnBtnSearchClick = function(self)
  warn("OnBtnSearchClick")
  local Top_Level = self.uiTbl.Top_Level
  local Top_ShenZhao = self.uiTbl.Top_ShenZhao
  local Top_BangGong = self.uiTbl.Top_BangGong
  local level = tonumber(self.uiTbl.Top_Level:GetComponent("UILabel"):get_text())
  local shenzhao = tonumber(self.uiTbl.Top_ShenZhao:GetComponent("UILabel"):get_text())
  local banggong = tonumber(self.uiTbl.Top_BangGong:GetComponent("UILabel"):get_text())
  if not level then
    level = 0
    self.uiTbl.Top_Level:GetComponent("UILabel"):set_text("0")
  end
  if not shenzhao then
    shenzhao = 0
    self.uiTbl.Top_ShenZhao:GetComponent("UILabel"):set_text("0")
  end
  if not banggong then
    banggong = 0
    self.uiTbl.Top_BangGong:GetComponent("UILabel"):set_text("0")
  end
  local time = 0
  local timeCfg = OfflineTimeConfig[self.timeType]
  if timeCfg and 0 < timeCfg.time then
    time = GetServerTime() - timeCfg.time
  end
  warn("level =", level, "| shenzhao =", shenzhao, "| bangogng=", banggong, "| time=", time)
  local gangMembers = {}
  local memberList = self.data:GetMemberList()
  for _, memberInfo in ipairs(memberList) do
    if (time <= 0 or 0 < memberInfo.offlineTime and time > memberInfo.offlineTime) and (level <= 0 or level > memberInfo.level) and (shenzhao <= 0 or shenzhao > memberInfo.weekItem_banggong_count) and (banggong <= 0 or banggong > memberInfo.curBangGong) then
      table.insert(gangMembers, {info = memberInfo, state = false})
    end
  end
  self.gangMembers = gangMembers
  self:ShowTitleSortButton(false)
  self:FillMembersNewList(true)
  Toast(textRes.Gang[363])
end
def.method().OnBtnImgDiClick = function(self)
  self:ShowTopPanel(not self.uiTbl.Top_Panel.activeSelf)
end
def.method().OnBtnSwitchLeftClick = function(self)
  self:ChangePage(1)
end
def.method().OnBtnSwitchRightClick = function(self)
  self:ChangePage(2)
end
def.method("number").OnBtnTopPanelClick = function(self, index)
  local timeCfg = OfflineTimeConfig[index]
  if timeCfg then
    self.timeType = index
    self.uiTbl.Top_ImgDi_Label:GetComponent("UILabel"):set_text(timeCfg.txt)
  end
end
def.method("userdata").OnBtnListImgToggleClick = function(self, clickobj)
  local memberUI = clickobj.parent
  if memberUI and "Group_List" == memberUI.name then
    local item, idx = ScrollList_getItem(clickobj)
    if item and idx > 0 then
      local member = self.gangMembers[idx]
      member.state = item:FindDirect("Img_Toggle"):GetComponent("UIToggle").value
    end
  end
  local curCount = 0
  local allCount = #self.gangMembers
  for _, member in ipairs(self.gangMembers) do
    if member.state then
      curCount = curCount + 1
    end
  end
  if curCount > 0 then
    warn("----------\229\183\178\233\128\137\228\184\173: [", curCount, "|", allCount, "]")
  end
  self:ChangeSelctBtnState(allCount == 0 or curCount ~= allCount)
end
def.method("userdata").OnBtnListItemClick = function(self, uiItem)
  local item, idx = ScrollList_getItem(uiItem)
  if item then
    local memberInfo = self.gangMembers[idx].info
    self.selectMember = memberInfo
    item:GetComponent("UIToggle"):set_value(true)
    require("Main.Gang.ui.GangMemberTipPanel").Instance():ShowPanel(memberInfo)
  end
end
def.method().InitSort = function(self)
  if not self.sortFunction then
    self.sortFunction = {}
  end
  local function MembersSortByName()
    table.sort(self.gangMembers, function(a, b)
      return a.info.pinyinName < b.info.pinyinName
    end)
  end
  local function MembersSortByLevel()
    table.sort(self.gangMembers, function(a, b)
      return a.info.level > b.info.level
    end)
  end
  local function MembersSortByOccupation()
    table.sort(self.gangMembers, function(a, b)
      return a.info.occupationId < b.info.occupationId
    end)
  end
  local function MembersSortByDuty()
    local gangMembers = self.gangMembers
    local count = #gangMembers
    for i = 2, count do
      for j = count, i, -1 do
        local dutyLvA = GangUtility.GetDutyLv(gangMembers[j].info.duty)
        local dutyLvB = GangUtility.GetDutyLv(gangMembers[j - 1].info.duty)
        if dutyLvA < dutyLvB then
          local tmp = gangMembers[j]
          gangMembers[j] = gangMembers[j - 1]
          gangMembers[j - 1] = tmp
        end
      end
    end
  end
  local function MembersSortByCurBanggong()
    table.sort(self.gangMembers, function(a, b)
      return a.info.curBangGong > b.info.curBangGong
    end)
  end
  local function MembersSortByHisBanggong()
    table.sort(self.gangMembers, function(a, b)
      return a.info.historyBangGong > b.info.historyBangGong
    end)
  end
  local function MembersSortByWeekBanggong()
    table.sort(self.gangMembers, function(a, b)
      return a.info.weekBangGong > b.info.weekBangGong
    end)
  end
  local function MembersSortByOfflineTime()
    local offlineList = {}
    local onineList = {}
    local list = {}
    for k, v in pairs(self.gangMembers) do
      if v.info.offlineTime == -1 then
        table.insert(onineList, v)
      else
        table.insert(offlineList, v)
      end
    end
    local count = #offlineList
    table.sort(offlineList, function(a, b)
      return a.info.offlineTime > b.info.offlineTime
    end)
    for k, v in pairs(onineList) do
      table.insert(list, v)
    end
    for k, v in pairs(offlineList) do
      table.insert(list, v)
    end
    self.gangMembers = list
  end
  local function MembersSortByShenZhao()
    table.sort(self.gangMembers, function(a, b)
      return a.info.weekItem_banggong_count > b.info.weekItem_banggong_count
    end)
  end
  local function MembersSortByGongXun()
    table.sort(self.gangMembers, function(a, b)
      return a.info.gongXun > b.info.gongXun
    end)
  end
  local function MembersSortByLiHe()
    table.sort(self.gangMembers, function(a, b)
      return a.info.isRewardLiHe > b.info.isRewardLiHe
    end)
  end
  local function MembersSortByJoinTime()
    table.sort(self.gangMembers, function(a, b)
      return a.info.joinTime < b.info.joinTime
    end)
  end
  self.sortFunction[MemberSortType.NAME] = MembersSortByName
  self.sortFunction[MemberSortType.LEVEL] = MembersSortByLevel
  self.sortFunction[MemberSortType.MENPAI] = MembersSortByOccupation
  self.sortFunction[MemberSortType.DUTY] = MembersSortByDuty
  self.sortFunction[MemberSortType.CURBANGGONG] = MembersSortByCurBanggong
  self.sortFunction[MemberSortType.HISBANGGONG] = MembersSortByHisBanggong
  self.sortFunction[MemberSortType.WEEKBANGGONG] = MembersSortByWeekBanggong
  self.sortFunction[MemberSortType.OFFLINE] = MembersSortByOfflineTime
  self.sortFunction[MemberSortType.SHENZHAO] = MembersSortByShenZhao
  self.sortFunction[MemberSortType.GONGXUN] = MembersSortByGongXun
  self.sortFunction[MemberSortType.LIHE] = MembersSortByLiHe
  self.sortFunction[MemberSortType.JOINTIME] = MembersSortByJoinTime
end
def.method("boolean").ShowTitleSortButton = function(self, show)
  local title = self.uiTbl.TitleSortButton[self.sortType]
  if title then
    local ImgSelect = title:FindDirect("Img_Select")
    ImgSelect:SetActive(show)
    if show then
      ImgSelect:FindDirect("Label_Up"):SetActive(self.sortTitleUp)
      ImgSelect:FindDirect("Label_Down"):SetActive(not self.sortTitleUp)
    end
  end
end
def.method("number").ChangeMemberSort = function(self, sortType)
  local sortFunc = self.sortFunction[sortType]
  if sortFunc then
    if self.sortType == sortType then
      local memberList = {}
      local count = #self.gangMembers
      for i = 1, count do
        memberList[i] = self.gangMembers[count - i + 1]
      end
      self.gangMembers = memberList
      self.sortTitleUp = not self.sortTitleUp
    else
      self:ShowTitleSortButton(false)
      sortFunc()
      self.sortTitleUp = false
      self.sortType = sortType
    end
    self:ShowTitleSortButton(true)
    self:FillMembersNewList(true)
  end
end
def.static("table", "table").OnGangMemberInfoChange = function(params, context)
  local self = instance
  local target = require("Main.Gang.data.GangData").Instance():GetMemberInfoByRoleId(params.roleid)
  if target == nil then
    return
  end
  for _, memberUI in pairs(self.listItems) do
    local roleName = memberUI:FindDirect("Label_UserName"):GetComponent("UILabel"):get_text()
    if roleName == target.name then
      self:UpdateMemberInfo(memberUI, target)
      return
    end
  end
end
return GangMemberManagementPanel.Commit()

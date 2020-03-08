local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local ECLuaString = require("Utility.ECFilter")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local EquipModule = require("Main.Equip.EquipModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local SwornMgr = require("Main.Sworn.SwornMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local TeamData = require("Main.Team.TeamData").Instance()
local SwornPanel = Lplus.Extend(ECPanelBase, "SwornPanel")
local def = SwornPanel.define
def.const("table").PANELSTATE = {
  SETSWORNNAME = 1,
  CONFIRMNAME = 2,
  SETMEMBERNAME = 3,
  INVITEMEMBER = 4,
  CHANGENAME = 5,
  LEAVE = 6
}
def.const("table").TITELSPRITE = {
  "Label_JY_JHJY",
  "Label_JY_JHJY",
  "Label_JY_JHJY",
  "Label_JY_JNXR",
  "Label_JY_XGCW",
  "Label_JY_QLSQ"
}
def.field("number").m_CurState = 1
def.field("number").m_TimerID = 0
def.field("table").m_MemberList = nil
def.field("table").m_UIGO = nil
local LIMIT_WORD_NUM1 = 2
local LIMIT_WORD_NUM2 = 3
local instance
def.static("=>", SwornPanel).Instance = function()
  if not instance then
    instance = SwornPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_JIE_YI_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitMemberListData()
  self:Update()
end
def.override().OnDestroy = function(self)
  self.m_CurState = SwornPanel.PANELSTATE.SETSWORNNAME
  self.m_MemberList = nil
  self.m_UIGO = nil
  self:RemoveTimer()
end
def.method().RemoveTimer = function(self)
  if self.m_TimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_TimerID)
    self.m_TimerID = 0
  end
end
def.method("number").SetPanelState = function(self, state)
  self.m_CurState = state
end
def.method().SetSwornName = function(self)
  local name1 = GUIUtils.GetUIInputValue(self.m_UIGO.Input11)
  local name2 = GUIUtils.GetUIInputValue(self.m_UIGO.Input12)
  if not name1 or not name2 then
    return
  end
  if name1:len() == 0 or name2:len() == 0 then
    Toast(textRes.Sworn[13])
    return
  end
  if ECLuaString.Len(name1) > LIMIT_WORD_NUM1 or ECLuaString.Len(name2) > LIMIT_WORD_NUM1 then
    Toast(textRes.Sworn[74]:format(LIMIT_WORD_NUM1))
    return
  end
  local params = {}
  params.name1 = name1
  params.name2 = name2
  SwornMgr.SetSwornName(params)
  self:DestroyPanel()
end
def.method().RejectSworn = function(self)
  SwornMgr.RejectSworn()
  self:DestroyPanel()
end
def.method().ConfirmSwornName = function(self)
  SwornMgr.AgreeSwornName()
  self:DestroyPanel()
end
def.method().SetSwornTitle = function(self)
  local title = GUIUtils.GetUIInputValue(self.m_UIGO.Input3)
  if ECLuaString.Len(title) > LIMIT_WORD_NUM2 then
    Toast(textRes.Sworn[74]:format(LIMIT_WORD_NUM2))
    return
  end
  local params = {}
  params.title = title
  SwornMgr.SetSwornTitle(params)
  self:DestroyPanel()
end
def.method().ConfirmTitle = function(self)
  local title = GUIUtils.GetUIInputValue(self.m_UIGO.InputName2)
  if ECLuaString.Len(title) > LIMIT_WORD_NUM2 then
    Toast(textRes.Sworn[74]:format(LIMIT_WORD_NUM2))
    return
  end
  local params = {}
  params.title = title
  params.confirm = 1
  SwornMgr.NewMemberConfirmSwornReq(params)
  self:DestroyPanel()
end
def.method().LeaveConfirm = function(self)
  local count = #self.m_MemberList
  local index = 0
  for i = 1, count do
    local groupSelectGO = self.m_UIGO[("SelectGO%d"):format(i)]
    if groupSelectGO and GUIUtils.IsToggle(groupSelectGO) then
      index = i
      break
    end
  end
  if index == 0 then
    Toast(textRes.Sworn[22])
    return
  else
    do
      local member = self.m_MemberList[index]
      if not member then
        return
      end
      CommonConfirmDlg.ShowConfirmCoundDown(textRes.Sworn[26], textRes.Sworn[25]:format(member.name), "", "", 0, 0, function(selection, tag)
        if selection == 1 then
          local params = {}
          params.kickoutid = member.roleid
          SwornMgr.KickoutReq(params)
          self:DestroyPanel()
        end
      end, nil)
    end
  end
end
def.method().ChangeTitle = function(self)
  local title = GUIUtils.GetUIInputValue(self.m_UIGO.InputName1)
  if not title then
    return
  end
  if ECLuaString.Len(title) > LIMIT_WORD_NUM2 then
    Toast(textRes.Sworn[74]:format(LIMIT_WORD_NUM2))
    return
  end
  local params = {}
  params.title = title
  SwornMgr.ChangeSwornTitleReq(params)
  self:DestroyPanel()
end
def.method("number").ToggleControl = function(self, index)
  local count = #self.m_MemberList
  for i = 1, count do
    local groupSelectGO = self.m_UIGO[("SelectGO%d"):format(i)]
    if groupSelectGO and self.m_CurState == SwornPanel.PANELSTATE.LEAVE then
      GUIUtils.Toggle(groupSelectGO, i == index)
    end
  end
end
def.method().RejectInvite = function(self)
  local params = {}
  params.confirm = 2
  params.title = ""
  SwornMgr.NewMemberConfirmSwornReq(params)
  SwornMgr.ClearSwornData()
end
def.method("string", "userdata").onSubmit = function(self, id, uiInput)
  local inputStr = uiInput:get_value()
  local realLen = ECLuaString.Len(inputStr)
  if "Img_Input1" == id then
    if self.m_UIGO.Group1 and self.m_UIGO.Group1:get_activeInHierarchy() then
      if realLen > LIMIT_WORD_NUM1 then
        local realStr = ECLuaString.SubStr(inputStr, 1, LIMIT_WORD_NUM1)
        local input = self.m_UIGO.Group1:FindDirect("Group_Name/Img_Input1"):GetComponent("UIInput")
        if input then
          input:set_value(realStr)
        end
        Toast(textRes.Sworn[74]:format(LIMIT_WORD_NUM1))
      end
    elseif realLen > LIMIT_WORD_NUM2 then
      local realStr = ECLuaString.SubStr(inputStr, 1, LIMIT_WORD_NUM2)
      local input
      if self.m_UIGO.Group3 and self.m_UIGO.Group3:get_activeInHierarchy() then
        input = self.m_UIGO.Group3:FindDirect("Group_Name/Img_Input1"):GetComponent("UIInput")
      elseif self.m_UIGO.Group4 and self.m_UIGO.Group4:get_activeInHierarchy() then
        input = self.m_UIGO.Group4:FindDirect("Group_Name/Img_Input1"):GetComponent("UIInput")
      elseif self.m_UIGO.Group5 and self.m_UIGO.Group5:get_activeInHierarchy() then
        input = self.m_UIGO.Group5:FindDirect("Group_Name/Img_Input1"):GetComponent("UIInput")
      end
      if input then
        input:set_value(realStr)
      end
      Toast(textRes.Sworn[74]:format(LIMIT_WORD_NUM2))
    end
  elseif "Img_Input2" == id and self.m_UIGO.Group1 and self.m_UIGO.Group1:get_activeInHierarchy() and realLen > LIMIT_WORD_NUM1 then
    local realStr = ECLuaString.SubStr(inputStr, 1, LIMIT_WORD_NUM1)
    local input = self.m_UIGO.Group1:FindDirect("Group_Name/Img_Input2"):GetComponent("UIInput")
    if input then
      input:set_value(realStr)
    end
    Toast(textRes.Sworn[74]:format(LIMIT_WORD_NUM1))
  end
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    if self.m_CurState == SwornPanel.PANELSTATE.SETSWORNNAME or self.m_CurState == SwornPanel.PANELSTATE.CONFIRMNAME or self.m_CurState == SwornPanel.PANELSTATE.SETMEMBERNAME then
      self:RejectSworn()
    elseif self.m_CurState == SwornPanel.PANELSTATE.INVITEMEMBER then
      self:RejectInvite()
    end
    self:DestroyPanel()
  elseif id == "Btn_Step1Confirm" then
    self:SetSwornName()
  elseif id == "Btn_Step1Refuse" then
    self:RejectSworn()
  elseif id == "Btn_Step2Confirm" then
    self:ConfirmSwornName()
  elseif id == "Btn_Step2Refuse" then
    self:RejectSworn()
  elseif id == "Btn_Step3Confirm" then
    self:SetSwornTitle()
  elseif id == "Btn_NewConfirm" then
    self:ConfirmTitle()
  elseif id == "Btn_ChangeConfirm" then
    self:ChangeTitle()
  elseif id == "Btn_ChangeRefuse" then
    self:DestroyPanel()
  elseif id == "Btn_LeaveConfirm" then
    self:LeaveConfirm()
  elseif id == "Btn_LeaveRefuse" then
    self:DestroyPanel()
  elseif id:find("Group_Select_") == 1 then
    local _, lastIndex = id:find("Group_Select_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    self:ToggleControl(index)
  end
end
def.method().InitMemberListData = function(self)
  if self.m_CurState == SwornPanel.PANELSTATE.CHANGENAME or self.m_CurState == SwornPanel.PANELSTATE.LEAVE or self.m_CurState == SwornPanel.PANELSTATE.INVITEMEMBER then
    self.m_MemberList = SwornMgr.GetSwornMember()
  else
    self.m_MemberList = TeamData:GetAllTeamMembers()
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Title = self.m_panel:FindDirect("Img_Bg0/Img_BgTitle/Img_Label")
  self.m_UIGO.MemberList = self.m_panel:FindDirect("Group_Member/Group_Member/Scroll View/List_")
  self.m_UIGO.Group1 = self.m_panel:FindDirect("Group_Step1")
  self.m_UIGO.Group2 = self.m_panel:FindDirect("Group_Step2")
  self.m_UIGO.Group3 = self.m_panel:FindDirect("Group_Step3")
  self.m_UIGO.Group4 = self.m_panel:FindDirect("Group_New")
  self.m_UIGO.Group5 = self.m_panel:FindDirect("Group_Change")
  self.m_UIGO.Group6 = self.m_panel:FindDirect("Group_Leave")
  self.m_UIGO.Btn_Step1Confirm = self.m_panel:FindDirect("Group_Step1/Btn_Step1Confirm")
  self.m_UIGO.Btn_Step1Refuse = self.m_panel:FindDirect("Group_Step1/Btn_Step1Refuse")
  self.m_UIGO.Btn_Step2Confirm = self.m_panel:FindDirect("Group_Step2/Btn_Step2Confirm")
  self.m_UIGO.Btn_Step2Refuse = self.m_panel:FindDirect("Group_Step2/Btn_Step2Refuse")
  self.m_UIGO.Btn_Step3Confirm = self.m_panel:FindDirect("Group_Step3/Btn_Step3Confirm")
  self.m_UIGO.Btn_NewConfirm = self.m_panel:FindDirect("Group_New/Btn_NewConfirm")
  self.m_UIGO.Btn_ChangeConfirm = self.m_panel:FindDirect("Group_Change/Btn_ChangeConfirm")
  self.m_UIGO.Btn_ChangeRefuse = self.m_panel:FindDirect("Group_Change/Btn_ChangeRefuse")
  self.m_UIGO.Btn_LeaveConfirm = self.m_panel:FindDirect("Group_Leave/Btn_LeaveConfirm")
  self.m_UIGO.Btn_LeaveRefuse = self.m_panel:FindDirect("Group_Leave/Btn_LeaveRefuse")
  self.m_UIGO.Input11 = self.m_panel:FindDirect("Group_Step1/Group_Name/Img_Input1")
  self.m_UIGO.Input12 = self.m_panel:FindDirect("Group_Step1/Group_Name/Img_Input2")
  self.m_UIGO.Input21 = self.m_panel:FindDirect("Group_Step2/Group_Name/Img_Input1/Label")
  self.m_UIGO.Input22 = self.m_panel:FindDirect("Group_Step2/Group_Name/Img_Input2/Label")
  self.m_UIGO.Num1 = self.m_panel:FindDirect("Group_Step1/Group_Name/Img_Label/Label_Num")
  self.m_UIGO.Num2 = self.m_panel:FindDirect("Group_Step2/Group_Name/Img_Label/Label_Num")
  self.m_UIGO.SwornName = self.m_panel:FindDirect("Group_Step3/Group_Name/Label_Num")
  self.m_UIGO.Input3 = self.m_panel:FindDirect("Group_Step3/Group_Name/Img_Input1")
  self.m_UIGO.LeaveTime = self.m_panel:FindDirect("Group_Leave/Label3")
  self.m_UIGO.NeedMoney = self.m_panel:FindDirect("Group_Leave/Img_BgUseMoney/Label_Num")
  self.m_UIGO.Money = self.m_panel:FindDirect("Group_Leave/Img_BgHaveMoney/Label_Num")
  self.m_UIGO.SwornName1 = self.m_panel:FindDirect("Group_Change/Group_Name/Label_Num")
  self.m_UIGO.InputName1 = self.m_panel:FindDirect("Group_Change/Group_Name/Img_Input1")
  self.m_UIGO.NeedMoney1 = self.m_panel:FindDirect("Group_Change/Img_BgUseMoney/Label_Num")
  self.m_UIGO.Money1 = self.m_panel:FindDirect("Group_Change/Img_BgHaveMoney/Label_Num")
  self.m_UIGO.SwornName2 = self.m_panel:FindDirect("Group_New/Group_Name/Label_Num")
  self.m_UIGO.InputName2 = self.m_panel:FindDirect("Group_New/Group_Name/Img_Input1")
  self.m_UIGO.InviteName = self.m_panel:FindDirect("Group_New/Label1")
end
def.method("number", "boolean").UpdateSelectView = function(self, index, flag)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  local groupSelectGO = self.m_UIGO[("SelectGO%d"):format(index)]
  warn(index, "UpdateSelectView", groupSelectGO, " ", flag)
  GUIUtils.Toggle(groupSelectGO, flag)
end
def.method("number", "string").UpdateSelectNameView = function(self, index, desc)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  local jyNameGO = self.m_UIGO[("JYNameGO%d"):format(index)]
  warn(index, "UpdateSelectNameView", jyNameGO, " ", desc)
  GUIUtils.SetText(jyNameGO, desc)
end
def.method("number", "userdata", "function").CountDownBtn = function(self, time, btn, callback)
  if not btn or time == 0 then
    return
  end
  local txtGO = btn:FindDirect("Label")
  if not txtGO then
    return
  end
  local desc = GUIUtils.GetUILabelTxt(txtGO) or ""
  self:RemoveTimer()
  self.m_TimerID = GameUtil.AddGlobalTimer(1, false, function()
    if not btn or btn.isnil then
      return
    end
    GUIUtils.SetText(txtGO, desc .. "(" .. time .. ")")
    time = time - 1
    if time < 0 then
      callback()
      self:RemoveTimer()
    end
  end)
end
def.method().UpdateTitleView = function(self)
  local imgGO = self.m_UIGO.Title
  GUIUtils.SetSprite(imgGO, SwornPanel.TITELSPRITE[self.m_CurState])
end
def.method().UpdateLeftView = function(self)
  local roleid = _G.GetMyRoleID()
  local uiListGO = self.m_UIGO.MemberList
  local members = self.m_MemberList
  if self.m_CurState == SwornPanel.PANELSTATE.INVITEMEMBER then
    members = SwornMgr.GetFakeSwornMember()
  end
  local count = #members
  local listItems = GUIUtils.InitUIList(uiListGO, count)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, count do
    local itemGO = listItems[i]
    local member = members[i]
    local nameGO = itemGO:FindDirect(("Group_Member_%d/Label_Name_%d"):format(i, i))
    local jyNameGO = itemGO:FindDirect(("Group_Member_%d/Label_JieYiName_%d"):format(i, i))
    local iconGO = itemGO:FindDirect(("Group_Member_%d/Group_Icon_%d/Icon_Head_%d"):format(i, i, i))
    local groupSelectGO = itemGO:FindDirect(("Group_Select_%d"):format(i))
    local spriteName = GUIUtils.GetHeadSpriteNameNoBound(member.menpai, member.gender)
    local title = member.title or ""
    if self.m_CurState >= SwornPanel.PANELSTATE.INVITEMEMBER then
      local swornName = SwornMgr.GetSwornName()
      local num = #SwornMgr.GetSwornMember()
      if self.m_CurState == SwornPanel.PANELSTATE.INVITEMEMBER then
        num = #members
      end
      if swornName.name1 and swornName.name2 then
        local numDesc = SwornMgr.GetNumberDesc(num)
        title = swornName.name1 .. numDesc .. swornName.name2 .. "\194\183" .. title
      end
    end
    GUIUtils.SetActive(groupSelectGO, self.m_CurState ~= SwornPanel.PANELSTATE.SETSWORNNAME and self.m_CurState ~= SwornPanel.PANELSTATE.INVITEMEMBER and self.m_CurState ~= SwornPanel.PANELSTATE.CHANGENAME and member.roleid ~= roleid)
    GUIUtils.Toggle(groupSelectGO, TeamData:IsCaptain(member.roleid) and self.m_CurState == SwornPanel.PANELSTATE.CONFIRMNAME)
    GUIUtils.SetText(nameGO, member.name)
    GUIUtils.SetSprite(iconGO, spriteName)
    GUIUtils.SetText(jyNameGO, title)
    GUIUtils.SetCollider(groupSelectGO, self.m_CurState == SwornPanel.PANELSTATE.LEAVE)
    self.m_UIGO[("JYNameGO%d"):format(i)] = jyNameGO
    self.m_UIGO[("SelectGO%d"):format(i)] = groupSelectGO
  end
end
def.method().UpdateRightView = function(self)
  local count = #self.m_MemberList
  for i = 1, 6 do
    local groupGO = self.m_UIGO[("Group%d"):format(i)]
    local numGO = self.m_UIGO[("Num%d"):format(i)]
    GUIUtils.SetActive(groupGO, i == self.m_CurState)
    GUIUtils.SetText(numGO, SwornMgr.GetNumberDesc(count))
  end
  if self.m_CurState == SwornPanel.PANELSTATE.SETSWORNNAME then
    local swornNumGO = self.m_UIGO.Num1
    GUIUtils.SetText(swornNumGO, SwornMgr.GetNumberDesc(count))
  elseif self.m_CurState == SwornPanel.PANELSTATE.CONFIRMNAME then
    local swornName = SwornMgr.GetSwornName()
    local name1GO = self.m_UIGO.Input21
    local name2GO = self.m_UIGO.Input22
    local swornNumGO = self.m_UIGO.Num2
    GUIUtils.SetText(swornNumGO, SwornMgr.GetNumberDesc(count))
    GUIUtils.SetText(name1GO, swornName.name1)
    GUIUtils.SetText(name2GO, swornName.name2)
  elseif self.m_CurState == SwornPanel.PANELSTATE.SETMEMBERNAME then
    local swornName = SwornMgr.GetSwornName()
    local swornNameGO = self.m_UIGO.SwornName
    local desc = swornName.name1 .. SwornMgr.GetNumberDesc(count) .. swornName.name2
    GUIUtils.SetText(swornNameGO, desc)
  elseif self.m_CurState == SwornPanel.PANELSTATE.INVITEMEMBER then
    local swornName = SwornMgr.GetSwornName()
    local swornNameGO = self.m_UIGO.SwornName2
    local inviteNameGO = self.m_UIGO.InviteName
    local members = SwornMgr.GetSwornMember()
    local teamMembers = TeamData:GetAllTeamMembers()
    local invitorName = " "
    if teamMembers[1] and teamMembers[1].name then
      invitorName = teamMembers[1].name
    elseif members[1] and members[1].name then
      invitorName = members[1].name
    end
    local memNumber = 0
    local fakeSwornMember = SwornMgr.GetFakeSwornMember()
    if fakeSwornMember then
      memNumber = #fakeSwornMember
    end
    local desc = swornName.name1 .. SwornMgr.GetNumberDesc(memNumber) .. swornName.name2
    GUIUtils.SetText(swornNameGO, desc)
    GUIUtils.SetText(inviteNameGO, textRes.Sworn[40]:format(invitorName))
  elseif self.m_CurState == SwornPanel.PANELSTATE.CHANGENAME then
    local swornName = SwornMgr.GetSwornName()
    local nameGO = self.m_UIGO.SwornName1
    local needMoneyGO = self.m_UIGO.NeedMoney1
    local moneyGO = self.m_UIGO.Money1
    local desc = swornName.name1 .. SwornMgr.GetNumberDesc(count) .. swornName.name2
    local swornName = SwornMgr.GetSwornName()
    local needMoney = SwornMgr.GetSwornConst("CHANGE_TITLE_NEED_GOLD")
    local money = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    GUIUtils.SetText(nameGO, desc)
    GUIUtils.SetText(needMoneyGO, tostring(needMoney))
    GUIUtils.SetText(moneyGO, Int64.tostring(money))
  elseif self.m_CurState == SwornPanel.PANELSTATE.LEAVE then
    local timeGO = self.m_UIGO.LeaveTime
    local needMoneyGO = self.m_UIGO.NeedMoney
    local moneyGO = self.m_UIGO.Money
    local time = SwornMgr.GetSwornConst("KICK_OUT_WAIT_TIME")
    local needMoney = SwornMgr.GetSwornConst("KICK_OUT_NEED_SILVER")
    local money = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
    GUIUtils.SetText(timeGO, textRes.Sworn[21]:format(time))
    GUIUtils.SetText(needMoneyGO, tostring(needMoney))
    GUIUtils.SetText(moneyGO, Int64.tostring(money))
  end
end
def.method().UpdateButtonView = function(self)
  local btnGO
  local time = 0
  local callback = SwornMgr.RejectSwornName
  if self.m_CurState == SwornPanel.PANELSTATE.SETSWORNNAME then
    btnGO = self.m_UIGO.Btn_Step1Refuse
    time = 600
    function callback()
      self:RejectSworn()
    end
  elseif self.m_CurState == SwornPanel.PANELSTATE.CONFIRMNAME then
    btnGO = self.m_UIGO.Btn_Step2Confirm
    time = 600
    function callback()
      self:ConfirmSwornName()
    end
  elseif self.m_CurState == SwornPanel.PANELSTATE.SETMEMBERNAME then
    btnGO = self.m_UIGO.Btn_Step3Confirm
    time = 120
    function callback()
      self:SetSwornTitle()
    end
  elseif self.m_CurState == SwornPanel.PANELSTATE.INVITEMEMBER then
    btnGO = self.m_UIGO.Btn_NewConfirm
    time = 120
    function callback()
      self:ConfirmTitle()
    end
  end
  self:CountDownBtn(time, btnGO, callback)
end
def.method().Update = function(self)
  self:UpdateTitleView()
  self:UpdateLeftView()
  self:UpdateRightView()
  self:UpdateButtonView()
end
return SwornPanel.Commit()

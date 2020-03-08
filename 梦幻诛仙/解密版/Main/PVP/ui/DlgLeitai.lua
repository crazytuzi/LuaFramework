local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgLeitai = Lplus.Extend(ECPanelBase, "DlgLeitai")
local MENPAI = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local def = DlgLeitai.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
DlgLeitai.TAP_TYPE = {FIGHT = 1, WATCH = 2}
def.field("number").selectedMenpai = 0
def.field("table").listItems = nil
def.field("number").refreshCd = -1
def.field("number").tap = DlgLeitai.TAP_TYPE.FIGHT
def.field("table").menpaiList = nil
def.static("=>", DlgLeitai).Instance = function()
  if dlg == nil then
    dlg = DlgLeitai()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.LEITAI, gmodule.notifyId.PVP.UPDATE_LEITAI_INFO, DlgLeitai.UpdateInfo)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgLeitai.OnEnterFight)
  Timer:RegisterListener(DlgLeitai.UpdateTime, dlg)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.WATCH_FAILED, DlgLeitai.OnWatchFailed)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_LEITAI, 0)
  self:SetModal(true)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.LEITAI, gmodule.notifyId.PVP.UPDATE_LEITAI_INFO, DlgLeitai.UpdateInfo)
  Timer:RemoveListener(DlgLeitai.UpdateTime)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.WATCH_FAILED, DlgLeitai.OnWatchFailed)
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  dlg:Hide()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_OnePerson" then
    self:CheckMenpai()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CRefreshSingleListReq").new())
  elseif id == "Btn_Team" then
    self:CheckMenpai()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CRefreshTeamListReq").new())
  elseif string.find(id, "BtnMenpai_") then
    if self.menpaiList == nil then
      return
    end
    local idx = tonumber(string.sub(id, #"BtnMenpai_" + 1, -1))
    self.selectedMenpai = self.menpaiList[idx]
    self:CheckMenpai()
  elseif id == "Btn_All" then
    self.selectedMenpai = MENPAI.ALL
    self:CheckMenpai()
  elseif id == "Btn_Close" then
    self:Hide()
  elseif id == "Tap_Fight" then
    if self.tap == DlgLeitai.TAP_TYPE.FIGHT then
      return
    end
    local panel = self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Scroll View/List_Fight")
    local uiList = panel:GetComponent("UIList")
    uiList.itemCount = 0
    uiList:Resize()
    if self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Btn_OnePerson"):GetComponent("UIToggle").isChecked then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CRefreshSingleListReq").new())
    elseif self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Btn_Team"):GetComponent("UIToggle").isChecked then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CRefreshTeamListReq").new())
    end
    self.tap = DlgLeitai.TAP_TYPE.FIGHT
  elseif id == "Tap_WatchFight" then
    if self.tap == DlgLeitai.TAP_TYPE.WATCH then
      return
    end
    self:RequestFightInfo()
    self.tap = DlgLeitai.TAP_TYPE.WATCH
  elseif id == "Btn_Refresh" then
    if self.m_panel:FindDirect("Img_Bg0/Tap_WatchFight"):GetComponent("UIToggle").isChecked then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CRefreshFightListReq").new())
    elseif self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Btn_OnePerson"):GetComponent("UIToggle").isChecked then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CRefreshSingleListReq").new())
    elseif self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Btn_Team"):GetComponent("UIToggle").isChecked then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CRefreshTeamListReq").new())
    end
    local btn = self.m_panel:FindDirect("Img_Bg0/Btn_Refresh")
    btn:GetComponent("UIButton"):set_isEnabled(false)
    btn:FindDirect("Label1"):SetActive(false)
    btn:FindDirect("Img_Clock"):SetActive(true)
    btn:FindDirect("Label_RefreshTime"):SetActive(true)
    self.refreshCd = 5
    btn:FindDirect("Label_RefreshTime"):GetComponent("UILabel").text = tostring(self.refreshCd)
  elseif string.find(id, "Btn_Fight_") then
    local idx = tonumber(string.sub(id, string.len("Btn_Fight_") + 1))
    local roleinfo = self.listItems[idx]
    if roleinfo then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CPVPOtherReq").new(roleinfo.roleid))
    else
      warn("leitai pvp fight: target id is nil")
    end
  elseif string.find(id, "Btn_Watch_") then
    local idx = tonumber(string.sub(id, string.len("Btn_Watch_") + 1))
    local fightInfo = gmodule.moduleMgr:GetModule(ModuleId.LEITAI).fightList
    local roleinfo = fightInfo[idx]
    if roleinfo then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CObserveFightReq").new(roleinfo.activeRoleInfo.roleid))
    else
      warn("leitai pvp watch fight: target id is nil")
    end
  elseif string.find(id, "Img_RoleIcon_") then
    local idx = tonumber(string.sub(id, string.len("Img_RoleIcon_") + 1))
    local roleinfo = self.listItems[idx]
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(roleinfo.roleid, function(data)
      require("Main.Common.RoleOperateHelper").ShowRoleOPPanel(data)
    end)
  elseif string.find(id, "Btn_RoleIcon_") then
    local str = string.sub(id, string.len("Btn_RoleIcon_") + 1)
    local headIdx = tonumber(string.sub(str, 1, 1))
    local idx = tonumber(string.sub(id, string.len("Btn_RoleIcon_1_") + 1))
    local roleinfo
    if headIdx == 1 then
      roleinfo = self.listItems[idx].activeRoleInfo
    elseif headIdx == 2 then
      roleinfo = self.listItems[idx].passiveRoleInfo
    end
    if roleinfo == nil then
      return
    end
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(roleinfo.roleid, function(data)
      require("Main.Common.RoleOperateHelper").ShowRoleOPPanel(data)
    end)
  end
end
def.method().RequestFightInfo = function(self)
  local panel = self.m_panel:FindDirect("Img_Bg0/Group_WatchFightInfo/Scroll View/List_WatchFight")
  local uiList = panel:GetComponent("UIList")
  uiList.itemCount = 0
  uiList:Resize()
  panel:SetActive(false)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CRefreshFightListReq").new())
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowAllMenpai()
  local btn = self.m_panel:FindDirect("Img_Bg0/Btn_Refresh")
  btn:FindDirect("Img_Clock"):SetActive(false)
  btn:FindDirect("Label_RefreshTime"):SetActive(false)
  self.m_panel:FindDirect("Img_Bg0/Group_MenPaiBtn/Btn_All"):GetComponent("UIToggle"):set_value(true)
  self.selectedMenpai = MENPAI.ALL
  if require("Main.Team.TeamData").Instance():HasTeam() then
    self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Btn_Team"):GetComponent("UIToggle"):set_value(true)
  else
    self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Btn_OnePerson"):GetComponent("UIToggle"):set_value(true)
  end
  self.tap = DlgLeitai.TAP_TYPE.FIGHT
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CRefreshSingleListReq").new())
end
def.method().ShowAllMenpai = function(self)
  local panel = self.m_panel:FindDirect("Img_Bg0/Group_MenPaiBtn/Scrollview_MenPai/List")
  local uilist = panel:GetComponent("UIList")
  local allMenpai = require("Main.Children.ChildrenUtils").GetAllOpenedOccupationSkill()
  self.menpaiList = {}
  local count = table.nums(allMenpai)
  uilist.itemCount = count
  uilist:Resize()
  local menpai
  for i = 1, count do
    local btn = panel:FindDirect("BtnMenpai_" .. i)
    if btn then
      local sp = btn:FindDirect("Img_School_" .. i):GetComponent("UISprite")
      menpai = next(allMenpai, menpai)
      table.insert(self.menpaiList, menpai)
      if menpai == self.selectedMenpai then
        sp.spriteName = GUIUtils.GetOccupationSmallIcon(menpai)
      else
        sp.spriteName = GUIUtils.GetOccupationSmallIcon(menpai)
      end
      btn:FindDirect("Label_" .. i):GetComponent("UILabel").text = _G.GetOccupationName(menpai)
    end
  end
end
def.method().CheckMenpai = function(self)
  if self.m_panel:FindDirect("Img_Bg0/Tap_WatchFight"):GetComponent("UIToggle").isChecked then
    return
  elseif self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Btn_OnePerson"):GetComponent("UIToggle").isChecked then
    self:ShowSoloInfo()
  elseif self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Btn_Team"):GetComponent("UIToggle").isChecked then
    self:ShowTeamInfo()
  end
end
def.method().ShowFightInfo = function(self)
  local fightInfo = gmodule.moduleMgr:GetModule(ModuleId.LEITAI).fightList
  self.listItems = fightInfo
  local panel = self.m_panel:FindDirect("Img_Bg0/Group_WatchFightInfo/Scroll View/List_WatchFight")
  local uiList = panel:GetComponent("UIList")
  if fightInfo == nil then
    self.m_panel:FindDirect("Img_Bg0/Group_NoPersonInfo"):SetActive(true)
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  panel:SetActive(true)
  self.m_panel:FindDirect("Img_Bg0/Group_NoPersonInfo"):SetActive(#fightInfo == 0)
  uiList.itemCount = #fightInfo
  uiList:Resize()
  for i = 1, #fightInfo do
    local entryPanel = panel:FindDirect("Img_WatchFightInfo_" .. i)
    local g1 = entryPanel:FindDirect("Group_1_" .. i)
    local g2 = entryPanel:FindDirect("Group_2_" .. i)
    g1:FindDirect("Label_TeamNum_" .. i):SetActive(0 < fightInfo[i].activeTeamNum)
    g1:FindDirect("Label_Ren_" .. i):SetActive(0 < fightInfo[i].activeTeamNum)
    if 0 < fightInfo[i].activeTeamNum then
      g1:FindDirect("Label_TeamNum_" .. i):GetComponent("UILabel").text = fightInfo[i].activeTeamNum .. "/5"
    end
    g1:FindDirect("Label_UserName_" .. i):GetComponent("UILabel").text = fightInfo[i].activeRoleInfo.name
    g1:FindDirect("Label_MenPaiName_" .. i):GetComponent("UILabel").text = GetOccupationName(fightInfo[i].activeRoleInfo.menPai)
    local menpaiIcon = g1:FindDirect("Img_MenPai_" .. i):GetComponent("UISprite")
    menpaiIcon.spriteName = GUIUtils.GetOccupationSmallIcon(fightInfo[i].activeRoleInfo.menPai)
    local g1Head = g1:FindDirect("Btn_RoleIcon_1_" .. i)
    local spriteName = require("GUI.GUIUtils").GetHeadSpriteNameNoBound(fightInfo[i].activeRoleInfo.menPai, fightInfo[i].activeRoleInfo.gender)
    local head = g1Head:GetComponent("UISprite")
    head.spriteName = spriteName
    g1Head:FindDirect("Label_Grade_" .. i):GetComponent("UILabel").text = fightInfo[i].activeRoleInfo.level
    g1Head:FindDirect("Img_Team_" .. i):SetActive(0 < fightInfo[i].activeTeamNum)
    g2:FindDirect("Label_TeamNum_" .. i):SetActive(0 < fightInfo[i].passiveTeamNum)
    g2:FindDirect("Label_Ren_" .. i):SetActive(0 < fightInfo[i].passiveTeamNum)
    if 0 < fightInfo[i].passiveTeamNum then
      g2:FindDirect("Label_TeamNum_" .. i):GetComponent("UILabel").text = fightInfo[i].passiveTeamNum .. "/5"
    end
    g2:FindDirect("Label_UserName_" .. i):GetComponent("UILabel").text = fightInfo[i].passiveRoleInfo.name
    g2:FindDirect("Label_MenPaiName_" .. i):GetComponent("UILabel").text = GetOccupationName(fightInfo[i].passiveRoleInfo.menPai)
    local menpaiIcon = g2:FindDirect("Img_MenPai_" .. i):GetComponent("UISprite")
    menpaiIcon.spriteName = GUIUtils.GetOccupationSmallIcon(fightInfo[i].passiveRoleInfo.menPai)
    local g2Head = g2:FindDirect("Btn_RoleIcon_2_" .. i)
    local spriteName = require("GUI.GUIUtils").GetHeadSpriteNameNoBound(fightInfo[i].passiveRoleInfo.menPai, fightInfo[i].passiveRoleInfo.gender)
    local head = g2Head:GetComponent("UISprite")
    head.spriteName = spriteName
    g2Head:FindDirect("Label_Grade_" .. i):GetComponent("UILabel").text = fightInfo[i].passiveRoleInfo.level
    g2Head:FindDirect("Img_Team_" .. i):SetActive(0 < fightInfo[i].passiveTeamNum)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ShowSoloInfo = function(self)
  self.listItems = {}
  local soloList = gmodule.moduleMgr:GetModule(ModuleId.LEITAI).soloList
  local panel = self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Scroll View/List_Fight")
  local uiList = panel:GetComponent("UIList")
  if soloList == nil then
    uiList.itemCount = 0
    uiList:Resize()
    self.m_panel:FindDirect("Img_Bg0/Group_NoPersonInfo"):SetActive(true)
    return
  end
  for i = 1, #soloList do
    if self.selectedMenpai == MENPAI.ALL or soloList[i].menPai == self.selectedMenpai then
      table.insert(self.listItems, soloList[i])
    end
  end
  self.m_panel:FindDirect("Img_Bg0/Group_NoPersonInfo"):SetActive(#self.listItems == 0)
  uiList.itemCount = #self.listItems
  uiList:Resize()
  for i = 1, #self.listItems do
    local solo = self.listItems[i]
    local entryPanel = panel:FindDirect("Img_FightInfo_" .. i)
    entryPanel:FindDirect("Label_TeamNum_" .. i):SetActive(false)
    entryPanel:FindDirect("Label_Ren_" .. i):SetActive(false)
    entryPanel:FindDirect("Label_UserName_" .. i):GetComponent("UILabel").text = solo.name
    entryPanel:FindDirect("Label_MenPaiName_" .. i):GetComponent("UILabel").text = GetOccupationName(solo.menPai)
    local menpaiIcon = entryPanel:FindDirect("Img_MenPai_" .. i):GetComponent("UISprite")
    menpaiIcon.spriteName = GUIUtils.GetOccupationSmallIcon(solo.menPai)
    local headPanel = entryPanel:FindDirect("Img_RoleIcon_" .. i)
    local spriteName = require("GUI.GUIUtils").GetHeadSpriteNameNoBound(solo.menPai, solo.gender)
    local head = headPanel:GetComponent("UISprite")
    head.spriteName = spriteName
    headPanel:FindDirect("Label_Grade_" .. i):GetComponent("UILabel").text = solo.level
    headPanel:FindDirect("Img_Team_" .. i):SetActive(false)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ShowTeamInfo = function(self)
  self.listItems = {}
  local teamList = gmodule.moduleMgr:GetModule(ModuleId.LEITAI).teamList
  local panel = self.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Scroll View/List_Fight")
  local uiList = panel:GetComponent("UIList")
  if teamList == nil then
    uiList.itemCount = 0
    uiList:Resize()
    self.m_panel:FindDirect("Img_Bg0/Group_NoPersonInfo"):SetActive(true)
    return
  end
  for i = 1, #teamList do
    if self.selectedMenpai == MENPAI.ALL or teamList[i].roleInfo.menPai == self.selectedMenpai then
      teamList[i].roleInfo.num = teamList[i].num
      table.insert(self.listItems, teamList[i].roleInfo)
    end
  end
  self.m_panel:FindDirect("Img_Bg0/Group_NoPersonInfo"):SetActive(#self.listItems == 0)
  uiList.itemCount = #self.listItems
  uiList:Resize()
  for i = 1, #self.listItems do
    local leader = self.listItems[i]
    local entryPanel = panel:FindDirect("Img_FightInfo_" .. i)
    entryPanel:FindDirect("Label_TeamNum_" .. i):SetActive(true)
    entryPanel:FindDirect("Label_Ren_" .. i):SetActive(true)
    entryPanel:FindDirect("Label_TeamNum_" .. i):GetComponent("UILabel").text = leader.num .. "/5"
    entryPanel:FindDirect("Label_UserName_" .. i):GetComponent("UILabel").text = leader.name
    entryPanel:FindDirect("Label_MenPaiName_" .. i):GetComponent("UILabel").text = GetOccupationName(leader.menPai)
    local menpaiIcon = entryPanel:FindDirect("Img_MenPai_" .. i):GetComponent("UISprite")
    menpaiIcon.spriteName = GUIUtils.GetOccupationSmallIcon(leader.menPai)
    local g1Head = entryPanel:FindDirect("Img_RoleIcon_" .. i)
    local spriteName = require("GUI.GUIUtils").GetHeadSpriteNameNoBound(leader.menPai, leader.gender)
    local head = g1Head:GetComponent("UISprite")
    head.spriteName = spriteName
    g1Head:FindDirect("Label_Grade_" .. i):GetComponent("UILabel").text = teamList[i].roleInfo.level
    g1Head:FindDirect("Img_Team_" .. i):SetActive(true)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.static("table", "table").UpdateInfo = function(p1, p2)
  if dlg.m_panel:FindDirect("Img_Bg0/Tap_WatchFight"):GetComponent("UIToggle").isChecked then
    dlg:ShowFightInfo()
  elseif dlg.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Btn_OnePerson"):GetComponent("UIToggle").isChecked then
    dlg:ShowSoloInfo()
  elseif dlg.m_panel:FindDirect("Img_Bg0/Group_FightInfo/Btn_Team"):GetComponent("UIToggle").isChecked then
    dlg:ShowTeamInfo()
  end
end
def.method("number").UpdateTime = function(self, tk)
  if self.refreshCd < 0 then
    return
  end
  self.refreshCd = self.refreshCd - tk
  local btn = self.m_panel:FindDirect("Img_Bg0/Btn_Refresh")
  btn:FindDirect("Label_RefreshTime"):GetComponent("UILabel").text = tostring(self.refreshCd)
  if self.refreshCd == 0 then
    btn:GetComponent("UIButton"):set_isEnabled(true)
    btn:FindDirect("Label1"):SetActive(true)
    btn:FindDirect("Img_Clock"):SetActive(false)
    btn:FindDirect("Label_RefreshTime"):SetActive(false)
  end
end
def.static("table", "table").OnWatchFailed = function(p1, p2)
  dlg:RequestFightInfo()
end
DlgLeitai.Commit()
return DlgLeitai

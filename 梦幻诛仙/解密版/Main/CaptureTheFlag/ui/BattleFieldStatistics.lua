local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BattleFieldStatistics = Lplus.Extend(ECPanelBase, "BattleFieldStatistics")
local GUIUtils = require("GUI.GUIUtils")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local BattleFieldMgr = Lplus.ForwardDeclare("BattleFieldMgr")
local def = BattleFieldStatistics.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = BattleFieldStatistics()
  end
  return _instance
end
def.field("userdata").listCmp = nil
def.field("table").statisticsData = nil
def.field("number").selectTeam = 0
def.static("table").ShowBattleFieldStatistics = function(data)
  local dlg = BattleFieldStatistics.Instance()
  dlg.statisticsData = data
  dlg.selectTeam = data.myTeam
  if not dlg:IsShow() then
    dlg:CreatePanel(RESPATH.PREFAB_SINGLEBATTLE_RESULT, 1)
    dlg:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self:InitScrollList()
  self:UpdateWinOrLose()
  self:UpdateScore()
  self:UpdateTitle()
  self:UpdateTab()
  self:UpdateScrollList()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateTab = function(self)
  local tabGroup = self.m_panel:FindDirect("Img_Bg/Group_Tab")
  local tab1 = tabGroup:FindDirect("Tap_01")
  local tabLbl1 = tab1:FindDirect("Label_Tap01")
  local camp1Cfg = CaptureTheFlagUtils.GetCampCfg(self.statisticsData.team1)
  tabLbl1:GetComponent("UILabel"):set_text(camp1Cfg.campName)
  local tab2 = tabGroup:FindDirect("Tap_02")
  local tabLbl2 = tab2:FindDirect("Label_Tap02")
  local camp2Cfg = CaptureTheFlagUtils.GetCampCfg(self.statisticsData.team2)
  tabLbl2:GetComponent("UILabel"):set_text(camp2Cfg.campName)
  if self.statisticsData.team1 == self.selectTeam then
    tab1:GetComponent("UIToggle").value = true
  elseif self.statisticsData.team2 == self.selectTeam then
    tab2:GetComponent("UIToggle").value = true
  end
end
def.method().UpdateScrollList = function(self)
  local num = #self.statisticsData.roleInfos[self.selectTeam]
  ScrollList_setCount(self.listCmp, num)
  local scroll = self.m_panel:FindDirect("Img_Bg/Group_RankList/Group_List/Scrolllist")
  GameUtil.AddGlobalTimer(0.01, true, function()
    if not scroll.isnil then
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method().UpdateWinOrLose = function(self)
  local win = self.m_panel:FindDirect("Img_Bg/Img_Win")
  local lose = self.m_panel:FindDirect("Img_Bg/Img_Loss")
  local tie = self.m_panel:FindDirect("Img_Bg/Img_Draw")
  win:SetActive(false)
  lose:SetActive(false)
  tie:SetActive(false)
  if self.statisticsData.result > 0 then
    win:SetActive(true)
  elseif self.statisticsData.result < 0 then
    lose:SetActive(true)
  else
    tie:SetActive(true)
  end
end
def.method().UpdateTitle = function(self)
  local extraTitle = self.m_panel:FindDirect("Img_Bg/Group_RankList/Group_Title/Img_BgTitle/Group/Label4_5")
  extraTitle:GetComponent("UILabel"):set_text(self.statisticsData.extra)
end
def.method().UpdateScore = function(self)
  local name1 = self.m_panel:FindDirect("Img_Bg/Group_ResPVP/Group_Red/Label")
  local res1 = self.m_panel:FindDirect("Img_Bg/Group_ResPVP/Group_Red/Label_Res")
  local icon1 = self.m_panel:FindDirect("Img_Bg/Group_ResPVP/Group_Red/Texture")
  local name2 = self.m_panel:FindDirect("Img_Bg/Group_ResPVP/Group_Blue/Label")
  local res2 = self.m_panel:FindDirect("Img_Bg/Group_ResPVP/Group_Blue/Label_Res")
  local icon2 = self.m_panel:FindDirect("Img_Bg/Group_ResPVP/Group_Blue/Texture")
  local cfg1 = CaptureTheFlagUtils.GetCampCfg(self.statisticsData.team1)
  local cfg2 = CaptureTheFlagUtils.GetCampCfg(self.statisticsData.team2)
  name1:GetComponent("UISprite"):set_spriteName(cfg1.campNameIcon)
  name2:GetComponent("UISprite"):set_spriteName(cfg2.campNameIcon)
  res1:GetComponent("UILabel"):set_text(self.statisticsData.score1)
  res2:GetComponent("UILabel"):set_text(self.statisticsData.score2)
  icon1:GetComponent("UISprite"):set_spriteName(cfg1.icon)
  icon2:GetComponent("UISprite"):set_spriteName(cfg2.icon)
end
def.method().InitScrollList = function(self)
  local scroll = self.m_panel:FindDirect("Img_Bg/Group_RankList/Group_List/Scrolllist")
  local list = scroll:FindDirect("List")
  self.listCmp = list:GetComponent("UIScrollList")
  local GUIScrollList = list:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    list:AddComponent("GUIScrollList")
  end
  ScrollList_setUpdateFunc(self.listCmp, function(item, i)
    self:FillInfo(item, i)
  end)
  self.m_msgHandler:Touch(list)
end
def.method("userdata", "number").FillInfo = function(self, uiGo, index)
  local roleInfo = self.statisticsData.roleInfos[self.selectTeam][index]
  if roleInfo then
    local vip = uiGo:FindDirect("Img_Vip")
    vip:SetActive(roleInfo.vip == true)
    local head = uiGo:FindDirect("Group_Head/Img_Head")
    local lv = head:FindDirect("Label_Lv")
    local serverName = uiGo:FindDirect("Group_Head/Label_ServerName")
    local gender = uiGo:FindDirect("Group_Head/Group_Info/Img_Sex")
    local menpai = uiGo:FindDirect("Group_Head/Group_Info/Img_MenPai")
    local name = uiGo:FindDirect("Group_Head/Group_Info/Label_PlayerName")
    local bg = uiGo:FindDirect("Img_Bg1")
    local value1 = uiGo:FindDirect("Label_Kill")
    local value2 = uiGo:FindDirect("Label_Death")
    local value3 = uiGo:FindDirect("Label_Place_Resource")
    local value4 = uiGo:FindDirect("Label_Points")
    local colorStr = self.selectTeam == self.statisticsData.myTeam and "[00ff00]" or "[ff0000]"
    SetAvatarIcon(head, roleInfo.avatarId)
    lv:GetComponent("UILabel"):set_text(colorStr .. tostring(roleInfo.level))
    serverName:GetComponent("UILabel"):set_text(colorStr .. (roleInfo.zoneName or ""))
    gender:GetComponent("UISprite"):set_spriteName(GUIUtils.GetGenderSprite(roleInfo.gender))
    menpai:GetComponent("UISprite"):set_spriteName(GUIUtils.GetOccupationSmallIcon(roleInfo.occupation))
    name:GetComponent("UILabel"):set_text(colorStr .. roleInfo.name)
    value1:GetComponent("UILabel"):set_text(colorStr .. roleInfo.kill)
    value2:GetComponent("UILabel"):set_text(colorStr .. roleInfo.die)
    value3:GetComponent("UILabel"):set_text(colorStr .. roleInfo.extra or "")
    value4:GetComponent("UILabel"):set_text(colorStr .. roleInfo.point)
    if roleInfo.roleId == GetMyRoleID() then
      bg:SetActive(true)
    else
      bg:SetActive(false)
    end
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Conform" then
    self:DestroyPanel()
    BattleFieldMgr.Instance():LeaveSingleBattle()
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if id == "Tap_01" and active then
    self.selectTeam = self.statisticsData.team1
    self:UpdateScrollList()
  elseif id == "Tap_02" and active then
    self.selectTeam = self.statisticsData.team2
    self:UpdateScrollList()
  end
end
BattleFieldStatistics.Commit()
return BattleFieldStatistics

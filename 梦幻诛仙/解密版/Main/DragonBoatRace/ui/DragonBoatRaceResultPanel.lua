local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DragonBoatRaceResultPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local Statistic = "netio.protocol.mzm.gsp.lonngboatrace.Statistic"
local TeamData = require("Main.Team.TeamData")
local def = DragonBoatRaceResultPanel.define
def.field("table").m_UIGOs = nil
def.field("table").m_result = nil
def.field("number").m_timeId = 0
def.field("number").m_endTimestamp = 0
local instance
def.static("=>", DragonBoatRaceResultPanel).Instance = function()
  if instance == nil then
    instance = DragonBoatRaceResultPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("table").ShowPanel = function(self, result)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_result = result
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_DRAGON_BOAT_RESULT, 0)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  if self.m_result.displayTime and self.m_result.displayTime > 0 then
    self.m_endTimestamp = _G.GetServerTime() + self.m_result.displayTime
    self.m_timeId = GameUtil.AddGlobalTimer(1, false, function()
      if self.m_panel == nil then
        return
      end
      self:UpdateCountdown()
    end)
    self:UpdateCountdown()
  end
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_result = nil
  if self.m_timeId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_timeId)
    self.m_timeId = 0
  end
  Event.DispatchEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.RaceEnd, nil)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Confirm" then
    self:DestroyPanel()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Item_List = self.m_panel:FindDirect("Item_List")
  self.m_UIGOs.Group_HY = self.m_panel:FindDirect("Group_HY")
end
def.method().UpdateUI = function(self)
  self:UpdateWinnerInfo()
  self:UpdateRoleStatistics()
end
def.method().UpdateCountdown = function(self)
  local leftTime = self.m_endTimestamp - _G.GetServerTime()
  if leftTime <= 0 then
    self:DestroyPanel()
    return
  end
  local Btn_Confirm = self.m_panel:FindDirect("Btn_Confirm")
  local Label_Settle = Btn_Confirm:FindDirect("Label_Settle")
  local text = string.format("%s(%s)", textRes.Common[61], leftTime)
  GUIUtils.SetText(Label_Settle, text)
end
def.method().UpdateWinnerInfo = function(self)
  local winnerId = self.m_result.winnerId
  local Img_Loss = self.m_UIGOs.Group_HY:FindDirect("Img_Loss")
  local Img_Title = self.m_UIGOs.Group_HY:FindDirect("Img_Title")
  if winnerId:ge(0) then
    GUIUtils.SetActive(Img_Loss, false)
    GUIUtils.SetActive(Img_Title, true)
  else
    GUIUtils.SetActive(Img_Loss, true)
    GUIUtils.SetActive(Img_Title, false)
  end
end
def.method().UpdateRoleStatistics = function(self)
  local statistics = self:GetStatistics()
  local uiList = self.m_UIGOs.Item_List:GetComponent("UIList")
  uiList.itemCount = #statistics
  uiList:Resize()
  local children = uiList.children
  for i, v in ipairs(children) do
    self:SetRoleStatistic(v, statistics[i])
  end
end
def.method("userdata", "table").SetRoleStatistic = function(self, itemGO, statistic)
  local Label_Name = itemGO:FindChildByPrefix("Label_Name")
  local Img_BgHead = itemGO:FindChildByPrefix("Img_BgHead")
  local Img_Head = Img_BgHead:FindChildByPrefix("Img_Head")
  local Label_Correct = itemGO:FindChildByPrefix("Label_Correct")
  local Label_Wrong = itemGO:FindChildByPrefix("Label_Wrong")
  GUIUtils.SetText(Label_Name, statistic.member.name)
  GUIUtils.SetText(Label_Correct, statistic.right)
  GUIUtils.SetText(Label_Wrong, statistic.wrong)
  if _G.SetAvatarIcon then
    _G.SetAvatarIcon(Img_Head, statistic.member.avatarId)
  else
    local sprtiteName = GUIUtils.GetHeadSpriteNameNoBound(statistic.member.menpai, statistic.member.gender)
    GUIUtils.SetSprite(Img_Head, sprtiteName)
  end
end
def.method("=>", "table").GetStatistics = function(self)
  local teamData = TeamData.Instance()
  local statistics = {}
  for roleId, v in pairs(self.m_result.role2Statistic) do
    local statistic = v
    statistic.member = teamData:getMember(roleId)
    if statistic.member then
      table.insert(statistics, statistic)
    else
      warn(string.format("role(%s) not found in team", roleId:tostring()))
    end
  end
  table.sort(statistics, function(l, r)
    if l.right ~= r.right then
      return l.right > r.right
    else
      return l.member.roleid < r.member.roleid
    end
  end)
  return statistics
end
return DragonBoatRaceResultPanel.Commit()

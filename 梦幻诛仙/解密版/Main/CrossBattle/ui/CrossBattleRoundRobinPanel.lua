local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleRoundRobinPanel = Lplus.Extend(ECPanelBase, "CrossBattleRoundRobinPanel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local GUIUtils = require("GUI.GUIUtils")
local def = CrossBattleRoundRobinPanel.define
def.const("number").ALL_STAGE_NUM = 6
local instance
def.field("table").registerRoleList = nil
def.static("=>", CrossBattleRoundRobinPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleRoundRobinPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, registerRoleList)
  if self:IsShow() then
    return
  end
  self.registerRoleList = registerRoleList
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_LOOP_GAME_JOIN, 1)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setConditionList()
  else
    self.registerRoleList = nil
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------CrossBattleRoundRobinPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Quit" then
    self:Hide()
  elseif id == "Btn_Join" then
    local teamData = require("Main.Team.TeamData").Instance()
    if teamData:HasTeam() then
      local members = teamData:GetAllTeamMembers()
      local m1 = members[1]
      local HeroProp = require("Main.Hero.Interface").GetBasicHeroProp()
      if m1 and m1.roleid:eq(HeroProp.id) then
        if not CrossBattleInterface.Instance():isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_ROUND_ROBIN) then
          Toast(textRes.CrossBattle[39])
          return
        end
        self:Hide()
        local p = require("netio.protocol.mzm.gsp.crossbattle.CEnterRoundRobinMapReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
        gmodule.network.sendProtocol(p)
        warn("-----------CEnterRoundRobinMapReq:")
      else
        Toast(textRes.CrossBattle[31])
      end
    end
  end
end
def.method("userdata", "=>", "boolean").isRegisterRole = function(self, roleId)
  if self.registerRoleList == nil then
    return false
  end
  for i, v in ipairs(self.registerRoleList) do
    if v:eq(roleId) then
      return true
    end
  end
  return false
end
def.method("=>", "table").getConditionList = function(self)
  local condList = {}
  local teamData = require("Main.Team.TeamData").Instance()
  local memberCount = 0
  local members = teamData:GetAllTeamMembers()
  if teamData:HasTeam() then
    memberCount = #members
  end
  local teamMemberNum = constant.CrossBattleConsts.ENTER_ROUND_ROBIN_MAP_TEAM_MEMBER_NUM
  local cond1 = {
    content = textRes.CrossBattle[27],
    isAchieve = memberCount >= teamMemberNum
  }
  table.insert(condList, cond1)
  local isSelfCorps = true
  if members and memberCount >= teamMemberNum then
    for i, v in ipairs(members) do
      if CorpsInterface.GetCorpsMemberInfo(v.roleid) == nil then
        isSelfCorps = false
        break
      end
    end
  else
    isSelfCorps = false
  end
  local cond2 = {
    content = textRes.CrossBattle[28],
    isAchieve = isSelfCorps
  }
  table.insert(condList, cond2)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local canJoin = false
  local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
  local myCorpsId
  if myCorpsInfo and myCorpsInfo.corpsId then
    myCorpsId = myCorpsInfo.corpsId
  end
  if myCorpsId and not canJoin then
    for i, v in ipairs(crossBattleInterface.roundRobinPointRankList) do
      warn("------->>>>>>:", myCorpsId, v, v:eq(myCorpsId))
      if v:eq(myCorpsId) then
        canJoin = true
        break
      end
    end
  end
  local cond3 = {
    content = textRes.CrossBattle[29],
    isAchieve = canJoin
  }
  table.insert(condList, cond3)
  local isRegister = true
  if members and memberCount >= teamMemberNum then
    for i, v in ipairs(members) do
      if not self:isRegisterRole(v.roleid) then
        isRegister = false
        break
      end
    end
  else
    isRegister = false
  end
  local cond4 = {
    content = textRes.CrossBattle[30],
    isAchieve = isRegister
  }
  table.insert(condList, cond4)
  return condList
end
def.method().setConditionList = function(self)
  local condList = self:getConditionList()
  local List_Member = self.m_panel:FindDirect("Img_Bg/Group_Center/Group_List/Scroll View/List_Member")
  local uiList = List_Member:GetComponent("UIList")
  uiList.itemCount = #condList
  uiList:Resize()
  local canEnter = true
  for i, v in ipairs(condList) do
    local item = List_Member:FindDirect("item_" .. i)
    local Label_TermName = item:FindDirect("Label_TermName")
    local Img_Right = item:FindDirect("Group_Result/Img_Right")
    local Img_Wrong = item:FindDirect("Group_Result/Img_Wrong")
    Label_TermName:GetComponent("UILabel"):set_text(v.content)
    if v.isAchieve then
      Img_Right:SetActive(true)
      Img_Wrong:SetActive(false)
    else
      Img_Right:SetActive(false)
      Img_Wrong:SetActive(true)
      canEnter = canEnter and false
    end
  end
  local Btn_Join = self.m_panel:FindDirect("Img_Bg/Group_Bottom/Btn_Join")
  Btn_Join:GetComponent("UIButton").isEnabled = canEnter
end
CrossBattleRoundRobinPanel.Commit()
return CrossBattleRoundRobinPanel

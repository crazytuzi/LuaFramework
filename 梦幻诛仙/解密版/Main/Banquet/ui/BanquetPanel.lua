local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BanquetPanel = Lplus.Extend(ECPanelBase, "BanquetPanel")
local BanquetInterface = require("Main.Banquet.BanquetInterface")
local banquetInterface = BanquetInterface.Instance()
local GUIUtils = require("GUI.GUIUtils")
local def = BanquetPanel.define
def.field("number").timerId = 0
local instance
def.static("=>", BanquetPanel).Instance = function()
  if instance == nil then
    instance = BanquetPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PERFAB_JIAYAN_PANEL, 0)
  self:SetDepth(GUIDEPTH.BOTTOM)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setBanquetInfo()
    if self.timerId == 0 then
      self.timerId = GameUtil.AddGlobalTimer(1, false, function()
        self:setBanquetTime()
      end)
    end
  else
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.override().OnCreate = function(self)
  warn("-----OnCreate------")
  Event.RegisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_PALYER_NUM_CHANGE, BanquetPanel.OnBanquetPalyerNumChange)
  Event.RegisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_END, BanquetPanel.OnBanquetEnd)
  Event.RegisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_LEVEL_CHANGE, BanquetPanel.OnBanquetLevelChange)
  Event.RegisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_INFO_CHANGE, BanquetPanel.OnBanquetInfoChange)
  Event.RegisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_EXIT, BanquetPanel.OnBanquetExit)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, BanquetPanel.OnMapChange)
end
def.override().OnDestroy = function(self)
  warn("-----OnDestroy-------")
  Event.UnregisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_PALYER_NUM_CHANGE, BanquetPanel.OnBanquetPalyerNumChange)
  Event.UnregisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_END, BanquetPanel.OnBanquetEnd)
  Event.UnregisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_LEVEL_CHANGE, BanquetPanel.OnBanquetLevelChange)
  Event.UnregisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_INFO_CHANGE, BanquetPanel.OnBanquetInfoChange)
  Event.UnregisterEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_EXIT, BanquetPanel.OnBanquetExit)
  Event.UnregisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, BanquetPanel.OnMapChange)
end
def.static("table", "table").OnBanquetPalyerNumChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setBanquetInfo()
  end
end
def.static("table", "table").OnBanquetInfoChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setBanquetInfo()
  end
end
def.static("table", "table").OnBanquetExit = function(p1, p2)
  if instance and (instance:IsShow() or instance.m_panel) then
    instance:DestroyPanel()
    Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.LEAVE_BANQUET, nil)
  end
end
def.static("table", "table").OnMapChange = function(p1, p2)
  local mapId = p1[1]
  local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  if homelandModule:IsHomelandMap(mapId) then
    return
  end
  if instance and (instance:IsShow() or instance.m_panel) then
    instance:DestroyPanel()
    Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.LEAVE_BANQUET, nil)
  end
end
def.static("table", "table").OnBanquetEnd = function(p1, p2)
  warn("--------OnBanquetEnd---------")
  if instance and (instance:IsShow() or instance.m_panel) then
    instance:DestroyPanel()
    Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.LEAVE_BANQUET, nil)
  end
end
def.static("table", "table").OnMapInstanceChange = function(p1, p2)
  warn("--------OnMapInstanceChange-----")
  if instance and (instance:IsShow() or instance.m_panel) then
    instance:DestroyPanel()
    Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.LEAVE_BANQUET, nil)
  end
end
def.static("table", "table").OnBanquetLevelChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setBanquetInfo()
  end
end
def.method("string").onClick = function(self, id)
  warn("--------BanquetPanel onClick:", id)
  if id == "Btn_Close" then
    local teamData = require("Main.Team.TeamData").Instance()
    if teamData:HasTeam() == true then
      local members = teamData:GetAllTeamMembers()
      local heroProp = _G.GetHeroProp()
      if heroProp.id ~= members[1].roleid then
        local ST_NORMAL = require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL
        for k, v in pairs(members) do
          if v.status == ST_NORMAL and heroProp.id == v.roleid then
            Toast(textRes.NPC[25])
            return
          end
        end
      end
    end
    local function callback(id)
      if id == 1 then
        self:DestroyPanel()
        if banquetInterface.masterId then
          local p = require("netio.protocol.mzm.gsp.banquest.CLeaveBanquetReq").new(banquetInterface.masterId)
          gmodule.network.sendProtocol(p)
        end
        Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.LEAVE_BANQUET, nil)
      end
    end
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.Banquet[8], callback, {self})
  elseif id == "Btn_Tip" then
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701609914)
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
  end
end
def.method().setBanquetTime = function(self)
  local tipTime = constant.CBanquetConsts.DISHES_TIP_TIME
  local nextTime = banquetInterface:getNextAwardTime()
  if self.m_panel == nil then
    return
  end
  local Time_Num = self.m_panel:FindDirect("Time_Num/Label_Num")
  local curTime = GetServerTime()
  if nextTime < 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
    Time_Num:GetComponent("UILabel"):set_text(0)
    Toast(textRes.Banquet[3])
    local endTime = banquetInterface:getCurBanquetEndTime()
    local exitTime = endTime + constant.CBanquetConsts.BANQUEST_RESERVE_TIME
    local exitLeftTime = exitTime - curTime
    if curTime > 3 then
      self.timerId = GameUtil.AddGlobalTimer(exitLeftTime - 3, true, function()
        local banquetFinishPanel = require("Main.Banquet.ui.BanquetFinishPanel").Instance()
        banquetFinishPanel:ShowDlg(textRes.Banquet[4])
      end)
    end
    return
  end
  local leftTime = nextTime - curTime
  if leftTime == 1 then
    local rank = banquetInterface:getBanquetRank()
    local BanquestRankEnum = require("consts.mzm.gsp.homeland.confbean.BanquestRankEnum")
    if rank == BanquestRankEnum.KING then
      local fx = GameUtil.RequestFx(RESPATH.BANQUET_KING_EFFECT, 1)
      if fx then
        local Vector = require("Types.Vector")
        local fxone = fx:GetComponent("FxOne")
        fx.parent = GUIRoot.GetUIRootObj()
        fx.localPosition = Vector.Vector3.new(0, 0, 0)
        fx.localScale = Vector.Vector3.one
        fxone:Play2(-1, false)
      end
    end
  end
  if leftTime < 0 then
    leftTime = 0
  end
  if leftTime == tipTime then
    Toast(textRes.Banquet[1])
  end
  Time_Num:GetComponent("UILabel"):set_text(leftTime)
end
def.method().setBanquetInfo = function(self)
  local People_Num = self.m_panel:FindDirect("People_Num/Label_Num")
  People_Num:GetComponent("UILabel"):set_text(banquetInterface:getPlayerNum())
  local homeInfo = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GetCurHomelandInfo()
  local fengshuiValue = 0
  if homeInfo then
    fengshuiValue = homeInfo.geomancy
  end
  local FengShui_Num = self.m_panel:FindDirect("FengShui_Num/Label_Num")
  FengShui_Num:GetComponent("UILabel"):set_text(fengshuiValue)
  local Time_Num = self.m_panel:FindDirect("Time_Num/Label_Num")
  local curTime = GetServerTime()
  local nextTime = banquetInterface:getNextAwardTime()
  local leftTime = nextTime - curTime
  if leftTime < 0 then
    leftTime = 0
  end
  Time_Num:GetComponent("UILabel"):set_text(leftTime)
  local Level_Num = self.m_panel:FindDirect("Level_Num/Label_Num")
  Level_Num:GetComponent("UILabel"):set_text(textRes.Banquet.banquetRank[banquetInterface:getBanquetRank()])
end
BanquetPanel.Commit()
return BanquetPanel

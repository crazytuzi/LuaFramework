local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleRoundRobinPointPanel = Lplus.Extend(ECPanelBase, "CrossBattleRoundRobinPointPanel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local GUIUtils = require("GUI.GUIUtils")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local def = CrossBattleRoundRobinPointPanel.define
local instance
def.static("=>", CrossBattleRoundRobinPointPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleRoundRobinPointPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_LOOP_GAME_POINR, 0)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setPointList({})
    local p = require("netio.protocol.mzm.gsp.crossbattle.CGetRoundRobinPointInfoInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    gmodule.network.sendProtocol(p)
    warn("-----------CrossBattleRoundRobinPointPanel CGetRoundRobinPointInfoInCrossBattleReq:")
  else
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Point_Rank_Success, CrossBattleRoundRobinPointPanel.OnPointRankChange)
end
def.override().OnDestroy = function(self)
end
def.static("table", "table").OnPointRankChange = function(p1, p2)
  if instance and instance:IsShow() and p1[1] then
    instance:setPointList(p1[1])
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------CrossBattleRoundRobinPointPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Rule" then
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    local CommonDescDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(crossBattleCfg.round_robin_stage_tips_id)
    CommonDescDlg.ShowCommonTip(tipContent, {x = 0, y = 0})
  end
end
def.method("table").setPointList = function(self, ranList)
  local List = self.m_panel:FindDirect("Img_Bg0/Group_RankList/Group_List/Scrolllist/List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #ranList
  uiList:Resize()
  for i, v in ipairs(ranList) do
    local item = List:FindDirect("item_" .. i)
    local Img_Bg1 = item:FindDirect("Img_Bg1")
    local Img_Bg2 = item:FindDirect("Img_Bg2")
    local Img_MingCi = item:FindDirect("Img_MingCi")
    local Label_Ranking = item:FindDirect("Label_Ranking")
    local Label_TeamName = item:FindDirect("Label_TeamName")
    local Img_Badge = item:FindDirect("Img_Badge")
    local Label_Num = item:FindDirect("Label_Num")
    if i % 2 == 0 then
      Img_Bg1:SetActive(false)
      Img_Bg2:SetActive(true)
    else
      Img_Bg1:SetActive(true)
      Img_Bg2:SetActive(false)
    end
    if i <= 3 then
      Img_MingCi:SetActive(true)
      Label_Ranking:GetComponent("UILabel"):set_text("")
      Img_MingCi:GetComponent("UISprite"):set_spriteName(string.format("Img_Num%d", v.rank))
    else
      Img_MingCi:SetActive(false)
      Label_Ranking:GetComponent("UILabel"):set_text(v.rank)
    end
    local corpsInfo = v.corps_brief_info
    Label_TeamName:GetComponent("UILabel"):set_text(GetStringFromOcts(corpsInfo.name))
    Label_Num:GetComponent("UILabel"):set_text(v.point)
    local badgeCfg = CorpsUtils.GetCorpsBadgeCfg(corpsInfo.corpsBadgeId)
    if badgeCfg then
      local badge_texture = Img_Badge:GetComponent("UITexture")
      GUIUtils.FillIcon(badge_texture, badgeCfg.iconId)
    end
  end
end
CrossBattleRoundRobinPointPanel.Commit()
return CrossBattleRoundRobinPointPanel

local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local GangActivityNode = Lplus.Extend(TabNode, "GangActivityNode")
local GangHelpPanel = require("Main.Gang.ui.GangHelpPanel")
local BanggongExchangePanel = require("Main.Gang.ui.BanggongExchangePanel")
local GangDrugShopPanel = require("Main.Gang.ui.GangDrugShopPanel")
local GangModule = require("Main.Gang.GangModule")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local def = GangActivityNode.define
local gangName
local gangBattleIdx = 0
local tabnode
def.field("table").activityList = nil
def.field("table").activityListCache = nil
local instance
def.static("=>", GangActivityNode).Instance = function()
  if instance == nil then
    instance = GangActivityNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  tabnode = self
end
def.override().OnShow = function(self)
  self:InitActivityData()
  self:FilterCustomClosedActivity()
  local rivalGang = require("Main.Gang.GangBattleMgr").Instance().rivalGang
  if rivalGang then
    gangName = rivalGang.faction_name
  else
    gangName = nil
    Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Battle_Rival_Changed, GangActivityNode.OnRivalChanged)
    require("Main.Gang.GangBattleMgr").Instance().needGoToBattle = false
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.competition.CAgainstFactionReq").new())
  end
  self:FillGangActivityList()
end
def.method().InitActivityData = function(self)
  if self.activityListCache then
    return
  end
  self.activityListCache = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GANG_ACTIVITY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.activityId = DynamicRecord.GetIntValue(entry, "activityId")
    cfg.name = DynamicRecord.GetStringValue(entry, "name")
    cfg.iconId = DynamicRecord.GetIntValue(entry, "iconId")
    cfg.minLevel = DynamicRecord.GetIntValue(entry, "minLevel")
    cfg.desc = DynamicRecord.GetStringValue(entry, "desc")
    cfg.timeDesc = DynamicRecord.GetStringValue(entry, "timeDesc")
    cfg.tipId = DynamicRecord.GetIntValue(entry, "tips")
    table.insert(self.activityListCache, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method().FilterCustomClosedActivity = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local canSeeActivities = {}
  for i, v in ipairs(self.activityListCache) do
    if not ActivityInterface.Instance():IsCustomCloseActivity(v.activityId) then
      table.insert(canSeeActivities, v)
    end
  end
  self.activityList = canSeeActivities
end
def.method().FillGangActivityList = function(self)
  local count = #self.activityList
  local ScrollView = self.m_node:FindDirect("Scroll View")
  local list = ScrollView:FindDirect("List_HD"):GetComponent("UIList")
  list:set_itemCount(count)
  list:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not list.isnil then
      list:Reposition()
    end
  end)
  local items = list:get_children()
  for i = 1, count do
    local panel = items[i]
    local activityInfo = self.activityList[i]
    if panel and activityInfo then
      self:FillActivityInfo(panel, i, activityInfo)
    end
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
  ScrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "table").FillActivityInfo = function(self, panel, index, activityInfo)
  local Texture = panel:FindDirect(string.format("Icon_Frame_%d/Texture_%d", index, index)):GetComponent("UITexture")
  GUIUtils.FillIcon(Texture, activityInfo.iconId)
  panel:FindDirect("Labe_Name_" .. index):GetComponent("UILabel").text = activityInfo.name
  panel:FindDirect("Labe_Time_" .. index):GetComponent("UILabel").text = activityInfo.timeDesc
  panel:FindDirect("Labe_Level_" .. index):GetComponent("UILabel").text = string.format(textRes.Gang[200], activityInfo.minLevel)
  panel:FindDirect("Label_Info_" .. index):GetComponent("UILabel").text = activityInfo.desc
  local Img_Red = panel:FindDirect(string.format("Btn_Open_%d/Img_Red_%d", index, index))
  if Img_Red then
    local isShowRed = GangUtility.Instance():IsShowGangActivityRedPointByActivityId(activityInfo.activityId)
    if isShowRed then
      Img_Red:SetActive(true)
    else
      Img_Red:SetActive(false)
    end
  end
  if activityInfo.activityId == constant.CCompetitionConsts.GANG_BATTLE_ACTIVITYID then
    gangBattleIdx = index
  end
  if activityInfo.activityId == constant.CCompetitionConsts.GANG_BATTLE_ACTIVITYID and gangName and gangName ~= "" then
    local vstitle = panel:FindDirect("Label_VS_" .. index)
    vstitle:SetActive(true)
    local rivalName = panel:FindDirect("Label_Rival_" .. index)
    rivalName:SetActive(true)
    rivalName:GetComponent("UILabel").text = gangName
  else
    panel:FindDirect("Label_VS_" .. index):SetActive(false)
    panel:FindDirect("Label_Rival_" .. index):SetActive(false)
  end
end
def.override().OnHide = function(self)
  self.activityList = nil
  gangName = nil
  gangBattleIdx = 0
end
def.method().Clear = function(self)
  gangName = nil
  gangBattleIdx = 0
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Btn_Open_") == "Btn_Open_" then
    local index = tonumber(string.sub(id, #"Btn_tips_" + 1, -1))
    self:OnGangActivityJoinClick(index)
  elseif string.sub(id, 1, #"Btn_tips_") == "Btn_tips_" then
    local index = tonumber(string.sub(id, #"Btn_tips_" + 1, -1))
    self:OnGangActivityTipsClick(index)
  elseif string.sub(id, 1, #"Img_Activity_") == "Img_Activity_" then
    local index = tonumber(string.sub(id, #"Img_Activity_" + 1, -1))
    self:OnGangActivityInfosClick(index)
  end
end
def.method("number").OnGangActivityJoinClick = function(self, index)
  local activityCfg = self.activityList[index]
  local ActivityInterface = require("Main.activity.ActivityInterface")
  if activityCfg == nil then
    return
  end
  if not ActivityInterface.Instance():isAchieveActivityLevel(activityCfg.activityId) then
    Toast(textRes.Gang[365])
    return
  end
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.JOINGANGACTIVITY, {
    activityCfg.activityId
  })
  if activityCfg.activityId == constant.CCompetitionConsts.GANG_BATTLE_ACTIVITYID then
    local state = ActivityInterface.GetActivityState(constant.CCompetitionConsts.GANG_BATTLE_ACTIVITYID)
    if state < 0 then
      Toast(textRes.activity[51])
      return
    end
    require("Main.Gang.ui.HaveGangPanel").Instance():DestroyPanel()
    require("Main.Gang.GangBattleMgr").Instance():GotoGangBattle()
  elseif activityCfg.activityId == ActivityInterface.GangRobber_ACTIVITY_ID then
    self:OnJoinGangRobberyClick()
  elseif activityCfg.activityId == constant.CGangRaceConsts.activity then
    self:OnJoinGangRaceClick(activityCfg.activityId)
  elseif activityCfg.activityId == require("Main.RelationShipChain.RelationShipChainMgr").GetRedGiftActivityConstant("activityId") then
    Toast(textRes.Gang[257])
  elseif activityCfg.activityId == constant.GangCrossConsts.Activityid then
    self:OnJoinGangCrossClick(activityCfg.activityId)
  elseif require("Main.Gang.GodMedicine.GodMedicineMgr").IsGodMedicineAct(activityCfg.activityId) then
    self:OnClickGodMedicineAct(activityCfg.activityId)
  else
    require("Main.Gang.ui.HaveGangPanel").Instance():DestroyPanel()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {
      activityCfg.activityId
    })
  end
end
def.method().OnJoinGangRobberyClick = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityId = ActivityInterface.GangRobber_ACTIVITY_ID
  local actitivityInPeriod = ActivityInterface.Instance()._activityInPeriod
  if actitivityInPeriod[activityId] ~= nil then
    require("Main.Gang.GangModule").Instance():GotoGangMap()
    require("Main.Gang.ui.HaveGangPanel").Instance():DestroyPanel()
  else
    Toast(textRes.activity[51])
  end
end
def.method("number").OnJoinGangRaceClick = function(self, activityId)
  local FightMgr = require("Main.Fight.FightMgr")
  local isInFight = FightMgr.Instance().isInFight
  if isInFight then
    Toast(textRes.GangRace[12])
    return
  end
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local actitivityInPeriod = ActivityInterface.Instance()._activityInPeriod
  if actitivityInPeriod[activityId] ~= nil then
    require("Main.Gang.ui.HaveGangPanel").Instance():DestroyPanel()
    Event.DispatchEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_GangActOpen, nil)
  else
    Toast(textRes.activity[51])
  end
end
def.method("number").OnJoinGangCrossClick = function(self, activityId)
  local gangUtility = require("Main.Gang.GangUtility").Instance()
  gangUtility:RemoveGangActivityRedPoint(constant.GangCrossConsts.Activityid)
  local isOpen = gmodule.moduleMgr:GetModule(ModuleId.GANG_CROSS):IsFeatureOpen()
  if not isOpen then
    Toast(textRes.GangCross[27])
    return
  end
  require("Main.Gang.ui.HaveGangPanel").Instance():DestroyPanel()
  local ActivityInterface = require("Main.activity.ActivityInterface")
  if ActivityInterface.Instance():isActivityOpend2(activityId) then
    Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_GangActOpen, nil)
  else
    Toast(textRes.activity[51])
  end
end
def.method("number").OnClickGodMedicineAct = function(self, activityId)
  local GodMedicineMgr = require("Main.Gang.GodMedicine.GodMedicineMgr")
  if not GodMedicineMgr.IsInActivityPeriod(activityId) then
    Toast(textRes.activity[51])
    return
  end
  local iLeftTimes = GodMedicineMgr.GetLeftTimes(activityId)
  if iLeftTimes < 1 then
    Toast(textRes.Gang.GodMedicine[3])
    return
  end
  local GodMedicineUtils = require("Main.Gang.GodMedicine.GodMedicineUtils")
  local actCfg = GodMedicineUtils.GetActivityCfgById(activityId)
  local minLifeSkillLv = actCfg.openLifeSkillLevel
  local LivingSkillData = require("Main.Skill.data.LivingSkillData")
  local skillBag = LivingSkillData.Instance():GetSkillBagById(actCfg.lifeSkillId)
  local curLifeSkillLv = skillBag.level
  if minLifeSkillLv > curLifeSkillLv then
    Toast(textRes.Gang.GodMedicine[8]:format(minLifeSkillLv))
    return
  end
  if not GodMedicineMgr.IsSatifyAllRequirementsAndToast(actCfg, true) then
    return
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {
    actCfg.actId
  })
  require("Main.Gang.ui.HaveGangPanel").Instance():DestroyPanel()
end
def.method("number").OnGangActivityTipsClick = function(self, index)
  if gangBattleIdx == index then
    require("Main.Gang.ui.DlgGangBattleRules").Instance():ShowDlg()
  else
    local CommonDescDlg = require("GUI.CommonUITipsDlg")
    local tipId = self.activityList[index].tipId
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
    CommonDescDlg.ShowCommonTip(tipContent, {x = 0, y = 0})
  end
end
def.method("number").OnGangActivityInfosClick = function(self, index)
  local activityCfg = self.activityList[index]
  local activityId = activityCfg.activityId
  self:ShowActivityTip(activityId)
end
def.method("number").ShowActivityTip = function(self, activityId)
  local activityTip = require("Main.activity.ui.ActivityTip").Instance()
  if activityTip:IsShow() == false then
    if activityId and activityId > 0 then
      activityTip:SetActivityID(activityId)
      activityTip:ShowDlg()
    end
  else
    activityTip:HideDlg()
  end
end
def.static("table", "table").OnRivalChanged = function(p1, p2)
  local rivalGang = require("Main.Gang.GangBattleMgr").Instance().rivalGang
  if rivalGang == nil or rivalGang.faction_id:ToNumber() <= 0 then
    return
  end
  gangName = rivalGang.faction_name
  if gangName == nil or gangName == "" then
    gangName = textRes.Gang[268]
  end
  if gangBattleIdx == 0 then
    return
  end
  local ScrollView = tabnode.m_node:FindDirect("Scroll View")
  local list = ScrollView:FindDirect("List_HD"):GetComponent("UIList")
  local items = list:get_children()
  local panel = items[gangBattleIdx]
  local activityInfo = tabnode.activityList[gangBattleIdx]
  if panel and activityInfo then
    tabnode:FillActivityInfo(panel, gangBattleIdx, activityInfo)
  end
end
GangActivityNode.Commit()
return GangActivityNode

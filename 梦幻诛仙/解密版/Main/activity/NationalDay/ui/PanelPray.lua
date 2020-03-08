local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local NationalDayData = require("Main.activity.NationalDay.data.NationalDayData")
local NationalDayUtils = require("Main.activity.NationalDay.NationalDayUtils")
local PanelPray = Lplus.Extend(ECPanelBase, "PanelPray")
local def = PanelPray.define
local instance
def.static("=>", PanelPray).Instance = function()
  if instance == nil then
    instance = PanelPray()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table").cfg = nil
def.static().ShowPanel = function()
  if PanelPray.Instance():IsShow() then
    PanelPray.Instance():UpdateUI()
    return
  end
  instance.cfg = gmodule.moduleMgr:GetModule(ModuleId.NATIONAL_DAY).prayCfg or NationalDayUtils.GetBirthPrayRewardCfg()
  instance:CreatePanel(RESPATH.PREFAB_ACTIVITY_NATIONAL_DAY_PRAY, 1)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  local Group_Item = self.m_panel:FindDirect("Img_Bg0/Group_Item")
  self._uiObjs.items = {}
  for i = 1, 3 do
    self._uiObjs.items[i] = {}
    local item_panel = Group_Item:FindDirect("Item_0" .. i)
    self._uiObjs.items[i].Label_ServerNum = item_panel:FindDirect("Group_CurLabel/Label_CurNum")
    self._uiObjs.items[i].Label_Progress = item_panel:FindDirect("Group_ServerLabel/Label_ServerNum")
    self._uiObjs.items[i].Img_Finish = item_panel:FindDirect("Img_Finish")
    self._uiObjs.items[i].Btn_Accept = item_panel:FindDirect("Group_Btn/Img_Mission_" .. i)
    self._uiObjs.items[i].Btn_Claim = item_panel:FindDirect("Group_Btn/Img_Reward_" .. i)
    self._uiObjs.items[i].Btn_Reward = item_panel:FindDirect("Btn_Reward_" .. i)
  end
end
def.override("boolean").OnShow = function(self, show)
  if not show then
    return
  end
  local activityCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID)
  local time_label = self.m_panel:FindDirect("Img_Bg0/Group_Time/Label_Time")
  time_label:GetComponent("UILabel"):set_text(activityCfg.timeDes)
  self:UpdateUI()
end
def.method().UpdateUI = function(self)
  if self.m_panel == nil or self.cfg == nil then
    return
  end
  local label
  local prayTimes = NationalDayData.Instance():GetPrayTimes()
  for i = 1, #self.cfg do
    local cfg = self.cfg[i]
    label = self._uiObjs.items[i].Label_ServerNum
    local cur_num = prayTimes and prayTimes[cfg.id] or 0
    label:GetComponent("UILabel").text = tostring(cur_num)
    self:SetProgress(i, cur_num)
    local claimable = self:GetClaimableRewardIdx(i)
    self._uiObjs.items[i].Btn_Accept:SetActive(claimable <= 0)
    self._uiObjs.items[i].Btn_Claim:SetActive(claimable > 0)
    self._uiObjs.items[i].Btn_Claim:FindDirect("Img_Red"):SetActive(claimable > 0)
    local hasCount = require("Main.activity.ActivityInterface").CheckActivityConditionFinishCount(cfg.id)
    self._uiObjs.items[i].Img_Finish:SetActive(not hasCount)
  end
end
def.method("number", "=>", "number", "number").GetClaimableRewardIdx = function(self, idx)
  if self.cfg == nil then
    return 0
  end
  local cfg = self.cfg[idx]
  if cfg == nil then
    return 0
  end
  local claimable = 0
  local next_stage = 0
  local prayTimes = NationalDayData.Instance():GetPrayTimes()
  local cur_num = prayTimes and prayTimes[cfg.id] or 0
  local prayInfoMap = NationalDayData.Instance():GetPrayInfo()
  local prayInfo = prayInfoMap and prayInfoMap[cfg.id]
  local current_claimed = prayInfo and prayInfo.rewarded_stages
  local claimed_stage = current_claimed and current_claimed[#current_claimed] or 0
  for i = 1, #cfg.stages do
    next_stage = i
    if cur_num >= cfg.stages[i] then
      if claimed_stage < cfg.stages[i] then
        claimable = i
        break
      end
    else
      break
    end
  end
  return claimable, next_stage
end
def.method("number", "number").SetProgress = function(self, idx, cur_num)
  local label = self._uiObjs.items[idx]
  if label == nil then
    return
  end
  local progress = ""
  local marks = self.cfg[idx].stages
  for i = 1, #marks do
    local format = "%d"
    if cur_num >= marks[i] then
      format = "[00ff00]%d[-]"
    end
    if i == 1 then
      progress = string.format(format, marks[i])
    else
      format = "%s/" .. format
      progress = string.format(format, progress, marks[i])
    end
  end
  label.Label_Progress:GetComponent("UILabel").text = progress
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Img_Mission_") == 1 then
    local activityInfo = require("Main.activity.ActivityInterface").Instance():GetActivityInfo(constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID)
    if activityInfo and activityInfo.count > 0 then
      Toast(textRes.activity.NationalDay[14])
      return
    end
    local idx = tonumber(string.sub(id, -1, -1))
    local cfg = self.cfg[idx]
    if cfg == nil then
      return
    end
    local taskCfg = NationalDayUtils.GetBirthPrayCfg(constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID)
    local graphId = 0
    for k, v in pairs(taskCfg.taskIds) do
      if v == cfg.id then
        graphId = taskCfg.graphIds[k]
        break
      end
    end
    local taskInterface = require("Main.task.TaskInterface").Instance()
    local taskId = taskInterface:GetTaskIdByGraphId(graphId)
    if taskId > 0 then
      self:DestroyPanel()
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskId, graphId})
      return
    end
    local p = require("netio.protocol.mzm.gsp.birthdaypray.CAcceptTaskActivityReq").new(cfg.id)
    gmodule.network.sendProtocol(p)
  elseif string.find(id, "Img_Reward_") == 1 then
    local idx = tonumber(string.sub(id, -1, -1))
    local cfg = self.cfg[idx]
    if cfg == nil then
      return
    end
    local rewardIdx = self:GetClaimableRewardIdx(idx)
    if rewardIdx <= 0 then
      return
    end
    local pro = require("netio.protocol.mzm.gsp.birthdaypray.CReceiveRewardReq").new()
    pro.activity_cfg_id = constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID
    pro.task_activity_id = cfg.id
    pro.stage_id = cfg.stages[rewardIdx]
    gmodule.network.sendProtocol(pro)
  elseif string.find(id, "Btn_Reward_") == 1 then
    local idx = tonumber(string.sub(id, -1, -1))
    self:ShowAwardTip(idx)
  elseif id == "Bth_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Help" then
    local cfg = NationalDayUtils.GetBirthPrayCfg(constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID)
    _G.ShowCommonCenterTip(cfg.tipsId)
  end
end
def.method("number").ShowAwardTip = function(self, idx)
  if self.cfg == nil then
    return
  end
  local cfg = self.cfg[idx]
  if cfg == nil then
    return
  end
  local claimable, rewardIdx = self:GetClaimableRewardIdx(idx)
  if rewardIdx == 0 then
    Toast(textRes.activity.NationalDay[23])
    return
  end
  local awardOcupSexKey = string.format("%d_%d_%d", cfg.rewards[rewardIdx], 0, 0)
  local awardCfg = require("Main.Item.ItemUtils").GetGiftAwardCfg(awardOcupSexKey)
  local awardInfoStr = string.format(textRes.activity.NationalDay[22], cfg.stages[rewardIdx])
  local itemsStr = require("Main.Item.ItemTipsMgr").GetAwardDesc(awardCfg, true)
  local tipContent = string.gsub(itemsStr, "<br/>", "\n")
  local targetObj = self._uiObjs.items[idx].Btn_Reward
  local CommonTipWithTitle = require("GUI.CommonTipWithTitle")
  CommonTipWithTitle.Instance():ShowTargetTip(targetObj, awardInfoStr, tipContent)
end
PanelPray.Commit()
return PanelPray

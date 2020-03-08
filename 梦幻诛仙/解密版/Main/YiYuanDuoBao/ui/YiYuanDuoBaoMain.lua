local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local YiYuanDuoBaoMain = Lplus.Extend(ECPanelBase, "YiYuanDuoBaoMain")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local YiYuanDuoBaoUtils = require("Main.YiYuanDuoBao.YiYuanDuoBaoUtils")
local def = YiYuanDuoBaoMain.define
def.field("number").m_activityId = 0
def.field("number").m_turn = 0
def.field("number").m_timer = 0
def.field("table").m_nums = nil
def.field("table").m_joins = nil
local instance
def.static("=>", YiYuanDuoBaoMain).Instance = function()
  if instance == nil then
    instance = YiYuanDuoBaoMain()
  end
  return instance
end
def.static("number").ShowYiYuanDuoBaoMain = function(activityId)
  local self = YiYuanDuoBaoMain.Instance()
  self.m_activityId = activityId
  local type, turn = YiYuanDuoBaoUtils.GetTurn(self.m_activityId, GetServerTime())
  if type < 0 or type > 1 then
    self.m_activityId = 0
    self.m_turn = 0
    return
  end
  self.m_turn = turn
  if self:IsShow() then
    self:BringTop()
    self:OnCreate()
  else
    self:CreatePanel(RESPATH.PREFAB_YIYUANDUOBAO_MAIN_PANEL, 1)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.YIYUANDUOBAO, gmodule.notifyId.YiYuanDuoBao.ActivityChange, YiYuanDuoBaoMain.OnActivityChange, self)
  Event.RegisterEventWithContext(ModuleId.YIYUANDUOBAO, gmodule.notifyId.YiYuanDuoBao.NeedNumRefresh, YiYuanDuoBaoMain.OnNeedRefresh, self)
  self:UpdateTreasure()
  self:UpdateTime()
  self:UpdateCount()
  self:UpdateJoin()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.YIYUANDUOBAO, gmodule.notifyId.YiYuanDuoBao.ActivityChange, YiYuanDuoBaoMain.OnActivityChange)
  Event.UnregisterEvent(ModuleId.YIYUANDUOBAO, gmodule.notifyId.YiYuanDuoBao.NeedNumRefresh, YiYuanDuoBaoMain.OnNeedRefresh)
  self.m_activityId = 0
  self.m_turn = 0
  GameUtil.RemoveGlobalTimer(self.m_timer)
  self.m_timer = 0
end
def.override("boolean").OnShow = function(self, show)
end
def.method("table").OnActivityChange = function(self, params)
  local type, turn = YiYuanDuoBaoUtils.GetTurn(self.m_activityId, GetServerTime())
  if type < 0 or type > 1 then
    self:DestroyPanel()
    return
  end
  self.m_turn = turn
  self:UpdateTreasure()
  self:UpdateCount()
  self:UpdateJoin()
  self:UpdateTime()
end
def.method("table").OnNeedRefresh = function(self, params)
  self:UpdateCount()
  self:UpdateJoin()
end
def.method().UpdateTreasure = function(self)
  local turnCfg = YiYuanDuoBaoUtils.GetTurnCfg(self.m_activityId, self.m_turn)
  if turnCfg then
    local groupItem = self.m_panel:FindDirect("Img_Bg0/Group_Item")
    groupItem:SetActive(true)
    for i = 1, 3 do
      local item = groupItem:FindDirect(string.format("Item_%02d", i))
      local award = turnCfg.awards[i]
      if award then
        item:SetActive(true)
        local awardItems = ItemUtils.GetAwardItems(award.fix_award_id)
        if awardItems and awardItems[1] then
          local itemBase = ItemUtils.GetItemBase(awardItems[1].itemId)
          local nameLbl = item:FindDirect("Label_Name")
          nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
          local icon = item:FindDirect(string.format("Icon_Item%02d", i))
          GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
          local num = item:FindDirect("Group_Join/Label_JoinNum")
          num:GetComponent("UILabel"):set_text("-")
        end
      else
        item:SetActive(false)
      end
    end
  else
    self.m_panel:FindDirect("Img_Bg0/Group_Item"):SetActive(false)
  end
end
local minSec = 60
local hourSec = 60 * minSec
local function sec2str(sec)
  local hour = math.floor(sec / hourSec)
  local min = math.floor((sec - hour * hourSec) / minSec)
  local second = sec - hour * hourSec - min * minSec
  local retStr = string.format("%02d:%02d:%02d", hour, min, second)
  return retStr
end
def.method().UpdateTime = function(self)
  local group = self.m_panel:FindDirect("Img_Bg0/Group_OpenTime")
  local Label_Name = group:FindDirect("Label_Name")
  local Label_OpenTime = group:FindDirect("Label_OpenTime")
  local turnCfg = YiYuanDuoBaoUtils.GetTurnCfg(self.m_activityId, self.m_turn)
  local curTime = GetServerTime()
  local endTime = 0
  if curTime < turnCfg.begin_timestamp then
    Label_Name:GetComponent("UILabel"):set_text(textRes.YiYuanDuoBao[2])
    endTime = turnCfg.begin_timestamp
  elseif curTime >= turnCfg.begin_timestamp then
    Label_Name:GetComponent("UILabel"):set_text(textRes.YiYuanDuoBao[3])
    endTime = turnCfg.end_timestamp
  end
  local openTimeLbl = Label_OpenTime:GetComponent("UILabel")
  local diff = endTime - GetServerTime()
  if not (diff > 0) or not diff then
    diff = 0
  end
  openTimeLbl:set_text(sec2str(diff))
  self.m_timer = GameUtil.AddGlobalTimer(1, false, function()
    if openTimeLbl.isnil then
      GameUtil.RemoveGlobalTimer(self.m_timer)
      self.m_timer = 0
      return
    end
    local diff = endTime - GetServerTime()
    if not (diff > 0) or not diff then
      diff = 0
    end
    openTimeLbl:set_text(sec2str(diff))
    if diff <= 0 then
      GameUtil.RemoveGlobalTimer(self.m_timer)
      self.m_timer = 0
    end
  end)
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local startTime, endTime = YiYuanDuoBaoUtils.GetTurnToday(self.m_activityId, self.m_turn)
  if startTime > 0 and endTime > 0 then
    local Group_TreasureTime = self.m_panel:FindDirect("Img_Bg0/Group_TreasureTime")
    Group_TreasureTime:SetActive(true)
    local treasureTime = Group_TreasureTime:FindDirect("Label_TreasureTime")
    local startTimeTbl = AbsoluteTimer.GetServerTimeTable(startTime)
    local endTimeTbl = AbsoluteTimer.GetServerTimeTable(endTime)
    treasureTime:GetComponent("UILabel"):set_text(string.format("%02d:%02d~%02d:%02d", startTimeTbl.hour, startTimeTbl.min, endTimeTbl.hour, endTimeTbl.min))
  else
    self.m_panel:FindDirect("Img_Bg0/Group_TreasureTime"):SetActive(false)
  end
end
def.method().UpdateCount = function(self)
  self.m_nums = nil
  require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():RequestDuoBaoNum(self.m_activityId, self.m_turn, function(data)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    self.m_nums = data
    local groupItem = self.m_panel:FindDirect("Img_Bg0/Group_Item")
    for i = 1, 3 do
      local awardCfg = YiYuanDuoBaoUtils.GetAwardCfg(self.m_activityId, self.m_turn, i)
      local count = data[i] or 0
      if awardCfg then
        count = math.floor(count * awardCfg.ratio)
      end
      local item = groupItem:FindDirect(string.format("Item_%02d", i))
      local num = item:FindDirect("Group_Join/Label_JoinNum")
      num:GetComponent("UILabel"):set_text(tostring(count))
    end
    local YiYuanDuoBaoBuy = require("Main.YiYuanDuoBao.ui.YiYuanDuoBaoBuy")
    for k, v in pairs(self.m_nums) do
      YiYuanDuoBaoBuy.SetYiYuanDuoBaoBuyNum(self.m_activityId, self.m_turn, k, v)
    end
  end)
end
def.method().UpdateJoin = function(self)
  self.m_joins = nil
  require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():RequestDuoBaoJoin(self.m_activityId, self.m_turn, function(data)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    self.m_joins = data
    local groupItem = self.m_panel:FindDirect("Img_Bg0/Group_Item")
    for i = 1, 3 do
      local finish = groupItem:FindDirect(string.format("Item_%02d/Img_Finish", i))
      if data[i] then
        finish:SetActive(true)
      else
        finish:SetActive(false)
      end
    end
    local YiYuanDuoBaoBuy = require("Main.YiYuanDuoBao.ui.YiYuanDuoBaoBuy")
    for k, v in pairs(self.m_joins) do
      YiYuanDuoBaoBuy.SetYiYuanDuoBaoJoin(self.m_activityId, self.m_turn, k)
    end
  end)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_DailyReward" then
    require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():OpenDuoBaoHistory(self.m_activityId)
  elseif id == "Btn_Help" then
    GUIUtils.ShowHoverTip(constant.CIndianaConsts.INSTRUCTION_TIPS_ID, 0, 0)
  elseif string.sub(id, 1, 9) == "Icon_Item" then
    local index = tonumber(string.sub(id, 10))
    if index then
      local awardCfg = YiYuanDuoBaoUtils.GetAwardCfg(self.m_activityId, self.m_turn, index)
      if awardCfg then
        local awardItems = ItemUtils.GetAwardItems(awardCfg.fix_award_id)
        if awardItems and awardItems[1] then
          local icon = self.m_panel:FindDirect(string.format("Img_Bg0/Group_Item/Item_%02d/%s", index, id))
          require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(awardItems[1].itemId, icon, 0, false)
        end
      end
    end
  elseif string.sub(id, 1, 7) == "Img_Btn" then
    local index = tonumber(string.sub(id, 8))
    if index then
      local num = self.m_nums and self.m_nums[index] or 0
      local join = self.m_joins and self.m_joins[index] and true or false
      require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():OpenDuobaoBuy(self.m_activityId, self.m_turn, index, num, join)
    end
  end
end
YiYuanDuoBaoMain.Commit()
return YiYuanDuoBaoMain

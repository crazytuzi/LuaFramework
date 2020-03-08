local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local YiYuanDuoBaoBuy = Lplus.Extend(ECPanelBase, "YiYuanDuoBaoBuy")
local EC = require("Types.Vector3")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local YiYuanDuoBaoUtils = require("Main.YiYuanDuoBao.YiYuanDuoBaoUtils")
local def = YiYuanDuoBaoBuy.define
def.field("number").m_activityId = 0
def.field("number").m_turnId = 0
def.field("number").m_sortId = 0
def.field("number").m_curNum = 0
def.field("boolean").m_join = false
def.field("table").m_activityCfg = nil
def.field("table").m_turnCfg = nil
def.field("table").m_awardCfg = nil
def.field("number").m_timer = 0
def.field("number").m_scrollTimer = 0
local instance
def.static("=>", YiYuanDuoBaoBuy).Instance = function()
  if instance == nil then
    instance = YiYuanDuoBaoBuy()
  end
  return instance
end
def.static("number", "number", "number", "number", "boolean").ShowYiYuanDuoBaoBuy = function(activityId, turnId, sortId, num, join)
  local self = YiYuanDuoBaoBuy.Instance()
  self.m_activityId = activityId
  self.m_turnId = turnId
  self.m_sortId = sortId
  self.m_curNum = num
  self.m_join = join
  self.m_activityCfg = YiYuanDuoBaoUtils.GetActivityCfg(self.m_activityId)
  self.m_turnCfg = self.m_activityCfg and self.m_activityCfg.turns[turnId] or nil
  self.m_awardCfg = self.m_turnCfg and self.m_turnCfg.awards[sortId] or nil
  if self.m_activityCfg == nil or self.m_turnCfg == nil or self.m_awardCfg == nil then
    self.m_activityId = 0
    self.m_turnId = 0
    self.m_sortId = 0
    self.m_curNum = 0
    self.m_join = false
    self.m_activityCfg = nil
    self.m_turnCfg = nil
    self.m_awardCfg = nil
    return
  end
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_YIYUANDUOBAO_JOIN_PANEL, 2)
  self:SetModal(true)
end
def.static("number", "number", "number", "number").SetYiYuanDuoBaoBuyNum = function(activityId, turnId, sortId, num)
  local self = YiYuanDuoBaoBuy.Instance()
  if self.m_activityId == activityId and self.m_turnId == turnId and self.m_sortId == sortId then
    self.m_curNum = num
    if self:IsShow() then
      self:UpdateNum()
    end
  end
end
def.static("number", "number", "number").SetYiYuanDuoBaoJoin = function(activityId, turnId, sortId)
  local self = YiYuanDuoBaoBuy.Instance()
  if self.m_activityId == activityId and self.m_turnId == turnId and self.m_sortId == sortId then
    self.m_join = true
    if self:IsShow() then
      self:UpdateJoin()
    end
  end
end
def.override().OnCreate = function(self)
  self:UpdateItem()
  self:UpdateTime()
  self:UpdateSuperLuckyGuy()
  self:UpdateNum()
  self:UpdateJoin()
end
def.override().OnDestroy = function(self)
  self.m_activityId = 0
  self.m_turnId = 0
  self.m_sortId = 0
  self.m_curNum = 0
  self.m_join = false
  self.m_activityCfg = nil
  self.m_turnCfg = nil
  self.m_awardCfg = nil
  GameUtil.RemoveGlobalTimer(self.m_timer)
  self.m_timer = 0
  GameUtil.RemoveGlobalTimer(self.m_scrollTimer)
  self.m_scrollTimer = 0
end
def.override("boolean").OnShow = function(self, show)
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
def.method().UpdateNum = function(self)
  local joinNum = self.m_panel:FindDirect("Img_Bg0/Group_Info/Group_JoinNum/Label_JoinNum")
  local awardNum = self.m_panel:FindDirect("Img_Bg0/Group_Info/Group_LuckNum/Label_LuckNum")
  local count = math.floor(self.m_curNum * self.m_awardCfg.ratio)
  joinNum:GetComponent("UILabel"):set_text(string.format(textRes.YiYuanDuoBao[12], count))
  local add = (self.m_curNum - self.m_awardCfg.extra_award_need_num) / self.m_awardCfg.extra_award_need_num
  add = add > 0 and math.ceil(add) or 0
  local num = self.m_curNum > 0 and add + self.m_awardCfg.init_award_num or 0
  awardNum:GetComponent("UILabel"):set_text(string.format(string.format(textRes.YiYuanDuoBao[13], num)))
end
def.method().UpdateJoin = function(self)
  if self.m_join then
    local joinBtn = self.m_panel:FindDirect("Img_Bg0/Group_Cost/Btn_Join")
    local finishBtn = self.m_panel:FindDirect("Img_Bg0/Group_Cost/Img_Finish")
    joinBtn:SetActive(false)
    finishBtn:SetActive(true)
  else
    local joinBtn = self.m_panel:FindDirect("Img_Bg0/Group_Cost/Btn_Join")
    local finishBtn = self.m_panel:FindDirect("Img_Bg0/Group_Cost/Img_Finish")
    joinBtn:SetActive(true)
    finishBtn:SetActive(false)
  end
end
def.method().UpdateItem = function(self)
  local stepNumLbl = self.m_panel:FindDirect("Img_Bg0/Group_TitleLabel/Label_PeopleNum")
  stepNumLbl:GetComponent("UILabel"):set_text(math.ceil(self.m_awardCfg.extra_award_need_num * self.m_awardCfg.ratio))
  local groupReward = self.m_panel:FindDirect("Img_Bg0/Group_Reward")
  local icon = groupReward:FindDirect("Group_Item/Texture_Item")
  local nameLbl = groupReward:FindDirect("Group_ItemName/Label_ItemName")
  local items = ItemUtils.GetAwardItems(self.m_awardCfg.fix_award_id)
  if items and items[1] then
    local itemBase = ItemUtils.GetItemBase(items[1].itemId)
    if itemBase then
      groupReward:SetActive(true)
      nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
      GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
    else
      groupReward:SetActive(false)
    end
  else
    groupReward:SetActive(false)
  end
  local groupRewardItem = self.m_panel:FindDirect("Img_Bg0/Group_Info/Group_RewardItem")
  local rewardItem = groupRewardItem:FindDirect("Texture_RewardItem")
  local rewardNum = groupRewardItem:FindDirect("Label_RewardItem")
  local items = ItemUtils.GetAwardItems(self.m_awardCfg.attend_fix_award_id)
  if items and items[1] then
    local itemBase = ItemUtils.GetItemBase(items[1].itemId)
    if itemBase then
      groupRewardItem:SetActive(true)
      GUIUtils.FillIcon(rewardItem:GetComponent("UITexture"), itemBase.icon)
      rewardNum:GetComponent("UILabel"):set_text("x" .. tostring(items[1].num))
    else
      groupRewardItem:SetActive(false)
    end
  else
    groupRewardItem:SetActive(false)
  end
  local groupCost = self.m_panel:FindDirect("Img_Bg0/Group_Cost")
  local costName = groupCost:FindDirect("Label_UseMoneyTitle")
  local costIcon = groupCost:FindDirect("Img_BgUseMoney")
  local costNum = groupCost:FindDirect("Label_UseMoneyNum")
  costName:GetComponent("UILabel"):set_text(textRes.YiYuanDuoBao.CostName[self.m_awardCfg.cost_money_type] or "")
  costNum:GetComponent("UILabel"):set_text(self.m_awardCfg.cost_money_num)
  costIcon:GetComponent("UISprite"):set_spriteName(GUIUtils.GetMoneySprite(self.m_awardCfg.cost_money_type))
end
def.method().UpdateTime = function(self)
  local timeLbl = self.m_panel:FindDirect("Img_Bg0/Group_OpenTime/Label_OpenTime")
  local lbl = timeLbl:GetComponent("UILabel")
  local endTime = self.m_turnCfg.end_timestamp
  local leftTime = endTime - GetServerTime()
  if leftTime > 0 then
    lbl:set_text(sec2str(leftTime))
    self.m_timer = GameUtil.AddGlobalTimer(1, false, function()
      if lbl.isnil then
        GameUtil.RemoveGlobalTimer(self.m_timer)
        self.m_timer = 0
      end
      leftTime = endTime - GetServerTime()
      if leftTime < 0 then
        GameUtil.RemoveGlobalTimer(self.m_timer)
        self.m_timer = 0
      end
      lbl:set_text(sec2str(leftTime))
    end)
  else
    lbl:set_text("00:00:00")
  end
end
def.method().UpdateSuperLuckyGuy = function(self)
  local scroll = self.m_panel:FindDirect("Img_Bg0/Group_LuckLog/Group_Log/Scrollview")
  require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():RequestSuperLuckyGuy(self.m_activityId, function(data)
    if self.m_panel and not self.m_panel.isnil then
      do
        local uis = {}
        local poss = {
          [0] = EC.Vector3.new(-75, 150, 0)
        }
        for i = 1, 4 do
          local ui = scroll:FindDirect(string.format("Log_%d", i))
          table.insert(uis, ui)
          ui:SetActive(false)
          table.insert(poss, ui.localPosition)
        end
        local index = 1
        local all = 0
        local cur = 1
        self.m_scrollTimer = GameUtil.AddGlobalTimer(2, false, function()
          if self.m_panel == nil or self.m_panel.isnil then
            GameUtil.RemoveGlobalTimer(self.m_scrollTimer)
            self.m_scrollTimer = 0
            return
          end
          local info = data[index]
          if info == nil then
            if #data > 3 then
              index = 1
              info = data[index]
              index = index + 1
            else
              GameUtil.RemoveGlobalTimer(self.m_scrollTimer)
              self.m_scrollTimer = 0
              return
            end
          else
            index = index + 1
          end
          if all >= 3 then
            for i = 1, all do
              local move = cur - i > 0 and cur - i or 4 + (cur - i)
              local go = uis[move]
              TweenPosition.Begin(go, 1, poss[3 - i])
            end
          else
            all = all + 1
          end
          local startPos = poss[4]
          local endPos = poss[all]
          local curui = uis[cur]
          local timeLbl = curui:FindDirect(string.format("Label_Time_%d", cur))
          local nameLbl = curui:FindDirect(string.format("Label_Content_%d", cur))
          local turnCfg = YiYuanDuoBaoUtils.GetTurnCfg(self.m_activityId, info.turn)
          local awardCfg = turnCfg.awards[info.sortid]
          local timeTbl = AbsoluteTimer.GetServerTimeTable(turnCfg.end_timestamp)
          local timeStr = string.format("%04d-%02d-%02d %02d:%02d:%02d", timeTbl.year, timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min, timeTbl.sec)
          local serverName = textRes.YiYuanDuoBao[9]
          local roleId = info.roleid
          if roleId then
            local serverInfo = GetRoleServerInfo(roleId)
            if serverInfo then
              serverName = serverInfo.name
            end
          end
          local name = GetStringFromOcts(info.role_name) or textRes.YiYuanDuoBao[10]
          local itemName
          local items = ItemUtils.GetAwardItems(awardCfg.fix_award_id)
          if items and items[1] then
            local itemBase = ItemUtils.GetItemBase(items[1].itemId)
            if itemBase then
              itemName = itemBase.name
            end
          end
          local roleInfoStr = string.format(textRes.YiYuanDuoBao[11], serverName, name)
          roleInfoStr = roleInfoStr and roleInfoStr .. ":" .. itemName
          timeLbl:GetComponent("UILabel"):set_text(timeStr)
          nameLbl:GetComponent("UILabel"):set_text(roleInfoStr)
          curui:SetActive(true)
          curui.localPosition = startPos
          TweenPosition.Begin(curui, 1, endPos)
          cur = cur + 1 > 4 and 1 or cur + 1
        end)
      end
    end
  end)
end
def.method().UpdateTurn = function(self)
  local list = self.m_panel:FindDirect("Img_Bg0/Group_History/Scrollview/List_History")
  local listCmp = list:GetComponent("UIList")
  local count = self.m_data[self.m_day] and #self.m_data[self.m_day].turns or 0
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = self.m_data[self.m_day].turns[i]
    self:FillItem(uiGo, info, i)
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Texture_RewardItem" then
    local items = ItemUtils.GetAwardItems(self.m_awardCfg.attend_fix_award_id)
    if items and items[1] then
      local icon = self.m_panel:FindDirect("Img_Bg0/Group_Info/Group_RewardItem/Texture_RewardItem")
      require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(items[1].itemId, icon, 0, false)
    end
  elseif id == "Texture_Item" then
    local items = ItemUtils.GetAwardItems(self.m_awardCfg.fix_award_id)
    if items and items[1] then
      local icon = self.m_panel:FindDirect("Img_Bg0/Group_Reward/Group_Item/Texture_Item")
      require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(items[1].itemId, icon, 0, false)
    end
  elseif id == "Btn_Join" then
    require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():Buy(self.m_activityId, self.m_turnId, self.m_sortId)
  end
end
YiYuanDuoBaoBuy.Commit()
return YiYuanDuoBaoBuy

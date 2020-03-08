local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local YiYuanDuoBaoHistory = Lplus.Extend(ECPanelBase, "YiYuanDuoBaoHistory")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local YiYuanDuoBaoUtils = require("Main.YiYuanDuoBao.YiYuanDuoBaoUtils")
local def = YiYuanDuoBaoHistory.define
def.field("number").m_activityId = 0
def.field("table").m_data = nil
def.field("number").m_day = 1
local instance
def.static("=>", YiYuanDuoBaoHistory).Instance = function()
  if instance == nil then
    instance = YiYuanDuoBaoHistory()
  end
  return instance
end
def.static("number").ShowYiYuanDuoBaoHistory = function(activityId)
  local self = YiYuanDuoBaoHistory.Instance()
  self.m_activityId = activityId
  self.m_day = 1
  self.m_data = YiYuanDuoBaoUtils.GetActivityCfgByDay(self.m_activityId)
  if self.m_data == nil then
    self.m_activityId = 0
    self.m_day = 1
    return
  end
  if self:IsShow() then
    self:BringTop()
    self:OnCreate()
  else
    self:CreatePanel(RESPATH.PREFAB_YIYUANDUOBAO_HISTORY_PANEL, 2)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self:UpdateTab()
  self:UpdateTurn()
end
def.override().OnDestroy = function(self)
  self.m_activityId = 0
  self.m_day = 1
  self.m_data = nil
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
def.method().UpdateTab = function(self)
  local list = self.m_panel:FindDirect("Img_Bg0/Group_History/Group_Tab/List")
  local listCmp = list:GetComponent("UIList")
  local count = #self.m_data
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = self.m_data[i]
    local lbl = uiGo:FindDirect(string.format("Label_%d", i))
    lbl:GetComponent("UILabel"):set_text(string.format(textRes.YiYuanDuoBao[4], info.day))
    if i == self.m_day then
      uiGo:GetComponent("UIToggle").value = true
    end
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method().UpdateTurn = function(self)
  local list = self.m_panel:FindDirect("Img_Bg0/Group_History/Group_History/Scrollview/List_History")
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
def.method("userdata", "table", "number").FillItem = function(self, uiGo, turnInfo, index)
  local turnName = uiGo:FindDirect(string.format("Group_Time_%d/Label_Turn_%d", index, index))
  local turnTime = uiGo:FindDirect(string.format("Group_Time_%d/Label_TurnTime_%d", index, index))
  local turnState = uiGo:FindDirect(string.format("Group_State_%d/Img_State_%d", index, index))
  turnName:GetComponent("UILabel"):set_text(string.format(textRes.YiYuanDuoBao[5], turnInfo.diaplay_turn))
  local bTimeTbl = AbsoluteTimer.GetServerTimeTable(turnInfo.begin_timestamp)
  local eTimeTbl = AbsoluteTimer.GetServerTimeTable(turnInfo.end_timestamp)
  turnTime:GetComponent("UILabel"):set_text(string.format(textRes.YiYuanDuoBao[6], bTimeTbl.hour, bTimeTbl.min, eTimeTbl.hour, eTimeTbl.min))
  local state = "Img_Label03"
  local curTime = GetServerTime()
  if curTime < turnInfo.begin_timestamp then
    state = "Img_Label02"
  elseif curTime >= turnInfo.end_timestamp then
    state = "Img_Label04"
  end
  turnState:GetComponent("UISprite"):set_spriteName(state)
  for i = 1, 3 do
    local awardGo = uiGo:FindDirect(string.format("List_Item_%d/Group_Item_%d_%d", index, i, index))
    local award = turnInfo.awards[i]
    if award then
      local items = ItemUtils.GetAwardItems(award.fix_award_id)
      if items and items[1] then
        local itemBase = ItemUtils.GetItemBase(items[1].itemId)
        if itemBase then
          awardGo:SetActive(true)
          local iconBg = awardGo:FindDirect(string.format("Img_ItemBg_%d_%d", i, index))
          local icon = awardGo:FindDirect(string.format("Texture_Item_%d_%d", i, index))
          local nameLbl = awardGo:FindDirect(string.format("Label_ItemName_%d_%d", i, index))
          iconBg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
          GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
          nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
        else
          awardGo:SetActive(false)
        end
      else
        awardGo:SetActive(false)
      end
    else
      awardGo:SetActive(false)
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 8) == "Btn_Tab_" then
    local index = tonumber(string.sub(id, 9))
    if index then
      self.m_day = index
      self:UpdateTab()
      self:UpdateTurn()
    end
  elseif string.sub(id, 1, 15) == "Btn_RewardList_" then
    local indexStr = string.sub(id, 16)
    if indexStr then
      local indexs = string.split(indexStr, "_")
      if indexs and #indexs == 2 then
        local sortId = tonumber(indexs[1])
        local turnIndex = tonumber(indexs[2])
        if sortId and turnIndex then
          local turnId = self.m_data[self.m_day] and self.m_data[self.m_day].turns[turnIndex] and self.m_data[self.m_day].turns[turnIndex].turn
          if turnId then
            local finished = require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():IsFinished(self.m_activityId, turnId)
            if finished then
              require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():RequestLuckyGuy(self.m_activityId, turnId, sortId, function(data)
                require("Main.YiYuanDuoBao.ui.LuckGuyList").ShowLuckGuyList(data.award_infos, data.turn, data.sortid)
              end)
            else
              Toast(textRes.YiYuanDuoBao[20])
            end
          end
        end
      end
    end
  end
end
YiYuanDuoBaoHistory.Commit()
return YiYuanDuoBaoHistory

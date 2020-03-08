local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AllLottoMainPanel = Lplus.Extend(ECPanelBase, "AllLottoMainPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local AllLottoUtils = require("Main.AllLotto.AllLottoUtils")
local def = AllLottoMainPanel.define
local instance
def.static("=>", AllLottoMainPanel).Instance = function()
  if instance == nil then
    instance = AllLottoMainPanel()
  end
  return instance
end
def.field("number").m_activityId = 0
def.field("table").m_activityCfg = nil
def.field("number").m_timer = 0
def.field("table").m_infos = nil
def.static("number").ShowMainPanel = function(activityId)
  local dlg = AllLottoMainPanel.Instance()
  if dlg:IsShow() then
    if activityId ~= dlg.m_activityId then
      dlg:DestroyPanel()
      dlg.m_activityId = activityId
      dlg.m_activityCfg = require("Main.AllLotto.AllLottoUtils").GetAllLottoCfg(activityId)
      dlg:CreatePanel(RESPATH.PREFAB_ALLLOTTO_MAIN, 1)
      dlg:SetModal(true)
    end
  else
    dlg.m_activityId = activityId
    dlg.m_activityCfg = require("Main.AllLotto.AllLottoUtils").GetAllLottoCfg(activityId)
    dlg:CreatePanel(RESPATH.PREFAB_ALLLOTTO_MAIN, 1)
    dlg:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.ALLLOTTO, gmodule.notifyId.AllLotto.NewLuckyGuy, AllLottoMainPanel.OnNewLuckGuy, self)
  self:UpdateContent()
  self:UpdateTimer()
  self:UpdateReward()
  self:UpdateLuckyGuys()
end
def.method("table").OnNewLuckGuy = function(self, params)
  if self.m_infos == nil then
    self.m_infos = {}
  end
  table.insert(self.m_infos, 1, params)
  self:SetList(self.m_infos)
end
def.override("boolean").OnShow = function(self, show)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ALLLOTTO, gmodule.notifyId.AllLotto.NewLuckyGuy, AllLottoMainPanel.OnNewLuckGuy)
  GameUtil.RemoveGlobalTimer(self.m_timer)
  self.m_activityId = 0
  self.m_activityCfg = nil
  self.m_timer = 0
  self.m_infos = nil
end
def.method().UpdateContent = function(self)
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(self.m_activityCfg.tipId)
  local desc = self.m_panel:FindDirect("Img_Bg0/Group_Label/Label_TitleInfo")
  desc:GetComponent("UILabel"):set_text(tipContent)
end
local minSec = 60
local hourSec = 60 * minSec
local daySec = hourSec * 24
local function sec2str(sec)
  local day = math.floor(sec / daySec)
  local hour = math.floor((sec - day * daySec) / hourSec)
  local min = math.floor((sec - day * daySec - hour * hourSec) / minSec)
  local second = sec - day * daySec - hour * hourSec - min * minSec
  local tbl = {}
  if day > 0 then
    table.insert(tbl, string.format(textRes.Common[204], tostring(day)))
  elseif #tbl > 0 then
    table.insert(tbl, string.format(textRes.Common[204], tostring(day)))
  end
  if hour > 0 then
    table.insert(tbl, string.format(textRes.Common[203], tostring(hour)))
  elseif #tbl > 0 then
    table.insert(tbl, string.format(textRes.Common[203], tostring(hour)))
  end
  if min > 0 then
    table.insert(tbl, string.format(textRes.Common[202], tostring(min)))
  elseif #tbl > 0 then
    table.insert(tbl, string.format(textRes.Common[202], tostring(min)))
  end
  if second > 0 then
    table.insert(tbl, string.format(textRes.Common[201], tostring(second)))
  elseif #tbl > 0 then
    table.insert(tbl, string.format(textRes.Common[201], tostring(second)))
  end
  return table.concat(tbl)
end
def.method().UpdateTimer = function(self)
  local curTime = GetServerTime()
  for k, v in ipairs(self.m_activityCfg.turns) do
    if curTime < v.time then
      do
        local prefix = self.m_panel:FindDirect("Img_Bg0/Group_OpenTime/Label_Name"):GetComponent("UILabel")
        prefix:set_text(textRes.AllLotto[6])
        local timeLbl = self.m_panel:FindDirect("Img_Bg0/Group_OpenTime/Label_OpenTime"):GetComponent("UILabel")
        timeLbl:set_text(sec2str(v.time - curTime))
        self.m_timer = GameUtil.AddGlobalTimer(1, false, function()
          if not timeLbl.isnil then
            local leftTime = v.time - GetServerTime()
            if leftTime < 0 then
              GameUtil.RemoveGlobalTimer(self.m_timer)
              self.m_timer = 0
              self:UpdateTimer()
            else
              timeLbl:set_text(sec2str(leftTime))
            end
          else
            GameUtil.RemoveGlobalTimer(self.m_timer)
            self.m_timer = 0
          end
        end)
        return
      end
    end
  end
  local prefix = self.m_panel:FindDirect("Img_Bg0/Group_OpenTime/Label_Name"):GetComponent("UILabel")
  prefix:set_text(textRes.AllLotto[7])
  local timeLbl = self.m_panel:FindDirect("Img_Bg0/Group_OpenTime/Label_OpenTime"):GetComponent("UILabel")
  timeLbl:set_text("")
end
def.method().UpdateReward = function(self)
  local group = self.m_panel:FindDirect("Img_Bg0/Group_RewardList")
  for i = 1, 5 do
    local uiGo = group:FindDirect("Img_Item_" .. i)
    if uiGo then
      local itemId = self.m_activityCfg.items[i]
      if itemId then
        local itemBase = ItemUtils.GetItemBase(itemId)
        if itemBase then
          uiGo:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
          local icon = uiGo:FindDirect("Img_ItemIcon_" .. i)
          if icon then
            GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
          end
        else
          uiGo:SetActive(false)
        end
      else
        uiGo:SetActive(false)
      end
    end
  end
end
def.method("table").SetList = function(self, infos)
  local group = self.m_panel:FindDirect("Img_Bg0/Group_LuckLog/Group_Log/Scrollview/Group_Grid")
  group:SetActive(true)
  for i = 1, 4 do
    local log = group:FindDirect(string.format("Log_%d/Label_Content", i))
    if log then
      log:SetActive(true)
      local info = infos[i]
      local roleInfo = info and info.role_info
      local turn = info and info.turn
      if info and roleInfo and turn then
        local serverName = ""
        local serverInfo = GetRoleServerInfo(roleInfo.roleid)
        if serverInfo then
          serverName = serverInfo.name
        end
        local name = GetStringFromOcts(roleInfo.role_name) or ""
        local itemName = ""
        local turnCfg = AllLottoUtils.GetAllLottoTurnCfg(self.m_activityId, turn)
        if turnCfg then
          local items = ItemUtils.GetAwardItems(turnCfg.awardId)
          if items and items[1] then
            local itemBase = ItemUtils.GetItemBase(items[1].itemId)
            if itemBase then
              itemName = itemBase.name
            end
          end
        end
        local tipContent = string.format(textRes.AllLotto[3], serverName, name, itemName)
        log:GetComponent("UILabel"):set_text(tipContent)
      else
        log:SetActive(false)
      end
    end
  end
end
def.method().UpdateLuckyGuys = function(self)
  local group = self.m_panel:FindDirect("Img_Bg0/Group_LuckLog/Group_Log/Scrollview/Group_Grid")
  group:SetActive(false)
  require("Main.AllLotto.AllLottoModule").Instance():GetRecentLogs(self.m_activityId, 4, function(infos)
    if group.isnil then
      return
    end
    self.m_infos = infos
    self:SetList(self.m_infos)
  end)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_RewardList" then
    require("Main.AllLotto.AllLottoModule").Instance():ShowAllLogs(self.m_activityId)
  elseif string.sub(id, 1, 9) == "Img_Item_" then
    local index = tonumber(string.sub(id, 10))
    if index then
      local icon = self.m_panel:FindDirect("Img_Bg0/Group_RewardList/" .. id)
      require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(self.m_activityCfg.items[index], icon, 0, false)
    end
  end
end
AllLottoMainPanel.Commit()
return AllLottoMainPanel

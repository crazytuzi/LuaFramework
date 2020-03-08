local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local AllLottoModule = Lplus.Extend(ModuleBase, "AllLottoModule")
require("Main.module.ModuleId")
local AllLottoUtils = require("Main.AllLotto.AllLottoUtils")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local ItemUtils = require("Main.Item.ItemUtils")
local def = AllLottoModule.define
local instance
def.static("=>", AllLottoModule).Instance = function()
  if instance == nil then
    instance = AllLottoModule()
    instance.m_moduleId = ModuleId.ALLLOTTO
  end
  return instance
end
def.field("number").m_activityId = 0
def.field("number").m_timer = 0
def.field("table").m_logCallback = nil
def.field("table").m_rollInfo = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.alllotto.SGetAllLottoWarmUpAwardSuccess", AllLottoModule.OnSGetAllLottoWarmUpAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.alllotto.SGetAllLottoWarmUpAwardFail", AllLottoModule.OnSGetAllLottoWarmUpAwardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.alllotto.SBrdAllLottoResult", AllLottoModule.OnSBrdAllLottoResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.alllotto.SGetAllLottoLogsSuccess", AllLottoModule.OnSGetAllLottoLogsSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, AllLottoModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, AllLottoModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, AllLottoModule.OnFeatureChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Open, AllLottoModule.OnActivityOpen)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Close, AllLottoModule.OnActivityClose)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.SYNC_SERVER_LEVEL, AllLottoModule.OnServeLvChange)
  ModuleBase.Init(self)
end
def.static("table").OnSGetAllLottoWarmUpAwardSuccess = function(p)
  Toast(textRes.AllLotto[1])
end
def.static("table").OnSGetAllLottoWarmUpAwardFail = function(p)
  local tip = textRes.AllLotto.Error[p.res]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSBrdAllLottoResult = function(p)
  local self = AllLottoModule.Instance()
  if p.award_role_infos[1] then
    self:ShowLuckyGuy(p.activity_cfg_id, p.turn, p.award_role_infos[1])
  end
end
def.static("table").OnSGetAllLottoLogsSuccess = function(p)
  local self = AllLottoModule.Instance()
  if self.m_logCallback and self.m_logCallback[p.activity_cfg_id] then
    local num = p.num
    local toBeRemove = {}
    for k, v in ipairs(self.m_logCallback[p.activity_cfg_id]) do
      if v.num == num then
        if self.m_rollInfo and self.m_rollInfo.activityId == p.activity_cfg_id then
          local logs = {}
          for k, v in ipairs(p.logs) do
            if v.turn == self.m_rollInfo.turn then
              table.remove(p.logs, k)
              break
            end
          end
        end
        v.callback(p.logs)
        table.insert(toBeRemove, k)
      end
    end
    for i = #toBeRemove, 1, -1 do
      table.remove(self.m_logCallback[p.activity_cfg_id], i)
    end
  end
end
def.static("table", "table").OnActivityOpen = function(p1, p2)
  local activityId = p1[1]
  if activityId and AllLottoUtils.IsAllLottoActivity(activityId) then
    local self = AllLottoModule.Instance()
    self.m_activityId = activityId
    self:InitTimer(activityId)
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  end
end
def.static("table", "table").OnActivityClose = function(p1, p2)
  local self = AllLottoModule.Instance()
  if self.m_activityId > 0 then
    local activityId = p1[1]
    if activityId == self.m_activityId then
      self.m_activityId = 0
      self:ClearTimer()
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
    end
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local self = AllLottoModule.Instance()
  self:CheckActivity()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = AllLottoModule.Instance()
  self.m_activityId = 0
  self:ClearTimer()
  self.m_logCallback = nil
end
def.static("table", "table").OnServeLvChange = function(p1, p2)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
end
def.static("table", "table").OnFeatureChange = function(p1, p2)
  if p1.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ALL_LOTTO then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  end
end
def.method("number", "number").C2SGetWarmUp = function(self, activityId, turn)
  local req = require("netio.protocol.mzm.gsp.alllotto.CGetAllLottoWarmUpAwardReq").new(activityId, turn)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number").C2SGetLogs = function(self, activityId, num)
  local req = require("netio.protocol.mzm.gsp.alllotto.CGetAllLottoLogsReq").new(activityId, num)
  gmodule.network.sendProtocol(req)
end
def.method("number").InitTimer = function(self, activityId)
  local cfg = AllLottoUtils.GetAllLottoCfg(activityId)
  if cfg then
    local curTime = GetServerTime()
    for k, v in ipairs(cfg.warmUps) do
      if curTime < v.time then
        self.m_timer = AbsoluteTimer.AddListener(v.time - curTime, 0, AllLottoModule.OnWarmUpTimer, {
          activityId = activityId,
          turn = v.turn
        }, 0)
        return
      end
    end
  end
end
def.static("table").OnWarmUpTimer = function(context)
  local self = AllLottoModule.Instance()
  self.m_timer = 0
  self:InitTimer(self.m_activityId)
  if self:IsOpen() then
    self:ShowWarmUp(context.activityId, context.turn)
  end
end
def.method().ClearTimer = function(self)
  if self.m_timer > 0 then
    AbsoluteTimer.RemoveListener(self.m_timer)
    self.m_timer = 0
  end
end
def.method().CheckActivity = function(self)
  local activityId = AllLottoUtils.GetCurAllLottoId()
  if activityId > 0 then
    self.m_activityId = activityId
    self:InitTimer(activityId)
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ALL_LOTTO)
  local crossServer = IsCrossingServer()
  return open and not crossServer and self:IsActivityOpen(self.m_activityId)
end
def.method("number", "=>", "boolean").IsActivityOpen = function(self, actId)
  if actId > 0 then
    local actCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(actId)
    local serverInfo = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
    if actCfg and serverInfo then
      return serverInfo.level >= actCfg.serverLevelMin
    else
      return false
    end
  else
    return false
  end
end
def.method("=>", "boolean").IsRed = function(self)
  return false
end
def.method("number", "number", "function").GetRecentLogs = function(self, activityId, num, callback)
  if self.m_logCallback == nil then
    self.m_logCallback = {}
  end
  if self.m_logCallback[activityId] == nil then
    self.m_logCallback[activityId] = {}
  end
  table.insert(self.m_logCallback[activityId], {callback = callback, num = num})
  self:C2SGetLogs(activityId, num)
end
def.method("number", "function").GetAllLogs = function(self, activityId, callback)
  if self.m_logCallback == nil then
    self.m_logCallback = {}
  end
  if self.m_logCallback[activityId] == nil then
    self.m_logCallback[activityId] = {}
  end
  table.insert(self.m_logCallback[activityId], {callback = callback, num = 0})
  self:C2SGetLogs(activityId, 0)
end
def.method().ShowActivityPanel = function(self)
  require("Main.AllLotto.ui.AllLottoMainPanel").ShowMainPanel(self.m_activityId)
end
def.method("number").ShowAllLogs = function(self, activityId)
  self:GetAllLogs(activityId, function(infos)
    require("Main.AllLotto.ui.LuckList").ShowLuckList(activityId, infos)
  end)
end
def.method("number", "number").ShowWarmUp = function(self, activityId, turn)
  require("Main.AllLotto.ui.WarmUpPanel").ShowWarmUp(activityId, turn)
end
def.method("number", "number").GetWarmUp = function(self, activityId, turn)
  self:C2SGetWarmUp(activityId, turn)
end
def.method("number", "number", "table").ShowLuckyGuy = function(self, activityId, turn, roleInfo)
  local MAXSECOND = 16
  self.m_rollInfo = {activityId = activityId, turn = turn}
  GameUtil.AddGlobalTimer(MAXSECOND, true, function()
    self.m_rollInfo = nil
  end)
  local receiveTime = GetServerTime()
  self:ShowBandit(activityId, turn, roleInfo, function(finished)
    if finished then
      self.m_rollInfo = nil
      Event.DispatchEvent(ModuleId.ALLLOTTO, gmodule.notifyId.AllLotto.NewLuckyGuy, {role_info = roleInfo, turn = turn})
      self:ShowAnnouncement(activityId, turn, roleInfo)
      if roleInfo.roleid == GetMyRoleID() then
        self:ShowToMe(activityId, turn)
      end
    else
      local diff = GetServerTime() - receiveTime
      if diff >= MAXSECOND then
        self.m_rollInfo = nil
        Event.DispatchEvent(ModuleId.ALLLOTTO, gmodule.notifyId.AllLotto.NewLuckyGuy, {role_info = roleInfo, turn = turn})
        self:ShowAnnouncement(activityId, turn, roleInfo)
        if roleInfo.roleid == GetMyRoleID() then
          self:ShowToMe(activityId, turn)
        end
      else
        GameUtil.AddGlobalTimer(MAXSECOND - diff, true, function()
          if require("Main.Login.LoginModule").Instance():IsInWorld() then
            self.m_rollInfo = nil
            Event.DispatchEvent(ModuleId.ALLLOTTO, gmodule.notifyId.AllLotto.NewLuckyGuy, {role_info = roleInfo, turn = turn})
            self:ShowAnnouncement(activityId, turn, roleInfo)
            if roleInfo.roleid == GetMyRoleID() then
              self:ShowToMe(activityId, turn)
            end
          end
        end)
      end
    end
  end)
end
def.method("number", "number", "table").ShowAnnouncement = function(self, activityId, turn, roleInfo)
  local serverName = ""
  local serverInfo = GetRoleServerInfo(roleInfo.roleid)
  if serverInfo then
    serverName = serverInfo.name
  end
  local name = GetStringFromOcts(roleInfo.role_name) or ""
  local itemName = ""
  local turnCfg = AllLottoUtils.GetAllLottoTurnCfg(activityId, turn)
  if turnCfg then
    local items = ItemUtils.GetAwardItems(turnCfg.awardId)
    if items and items[1] then
      local itemBase = ItemUtils.GetItemBase(items[1].itemId)
      if itemBase then
        itemName = itemBase.name
      end
    end
  end
  local announceContent = string.format(textRes.AllLotto[5], serverName, name, itemName)
  require("GUI.RareItemAnnouncementTip").AnnounceRareItem(announceContent)
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = announceContent})
end
def.method("number", "number", "table", "function").ShowBandit = function(self, activityId, turn, roleInfo, callback)
  local result = require("Main.Hero.HeroUtility").Instance():RoleIDToDisplayID(roleInfo.roleid)
  require("Main.AllLotto.ui.Bandit").ShowResult(result, activityId, turn, roleInfo, callback)
end
def.method("number", "number").ShowToMe = function(self, activityId, turn)
  require("Main.AllLotto.ui.ShowToMe").ShowToMe(activityId, turn)
end
def.method().Share = function(self)
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendToFriendWithPhoto(1, ECMSDK.ShareURL[9])
end
AllLottoModule.Commit()
return AllLottoModule

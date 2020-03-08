local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local YiYuanDuoBaoModule = Lplus.Extend(ModuleBase, "YiYuanDuoBaoModule")
require("Main.module.ModuleId")
local YiYuanDuoBaoUtils = require("Main.YiYuanDuoBao.YiYuanDuoBaoUtils")
local def = YiYuanDuoBaoModule.define
local instance
def.static("=>", YiYuanDuoBaoModule).Instance = function()
  if instance == nil then
    instance = YiYuanDuoBaoModule()
    instance.m_moduleId = ModuleId.YIYUANDUOBAO
  end
  return instance
end
def.field("number").m_activityId = 0
def.field("table").m_cacheData = nil
def.field("table").m_numRequest = nil
def.field("table").m_joinRequest = nil
def.field("table").m_awardRequest = nil
def.field("table").m_historyRequest = nil
def.field("boolean").m_isRed = false
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.indiana.SAttendIndianaSuccess", YiYuanDuoBaoModule.OnSAttendIndianaSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.indiana.SAttendIndianaFail", YiYuanDuoBaoModule.OnSAttendIndianaFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.indiana.SGetAttendIndianaNumSuccess", YiYuanDuoBaoModule.OnSGetAttendIndianaNumSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.indiana.SGetIndianaAwardInfoSuccess", YiYuanDuoBaoModule.OnSGetIndianaAwardInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.indiana.SGetIndianaAwardInfoFail", YiYuanDuoBaoModule.OnSGetIndianaAwardInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.indiana.SGetIndianaLogsSuccess", YiYuanDuoBaoModule.OnSGetIndianaLogsSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.indiana.SRoleGetIndianaAwardBrd", YiYuanDuoBaoModule.OnSRoleGetIndianaAwardBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.indiana.SNotifyRoleGetIndianaAward", YiYuanDuoBaoModule.OnSNotifyRoleGetIndianaAward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.indiana.SGetRoleAttendIndianaInfoSuccess", YiYuanDuoBaoModule.OnSGetRoleAttendIndianaInfoSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, YiYuanDuoBaoModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, YiYuanDuoBaoModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, YiYuanDuoBaoModule.OnFeatureChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Open, YiYuanDuoBaoModule.OnActivityOpen)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, YiYuanDuoBaoModule.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, YiYuanDuoBaoModule.OnActivityEnd)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Close, YiYuanDuoBaoModule.OnActivityClose)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, YiYuanDuoBaoModule.OnChatBtnClick)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, YiYuanDuoBaoModule.OnActivityTodo)
  ModuleBase.Init(self)
end
def.static("table").OnSAttendIndianaSuccess = function(p)
  Toast(textRes.YiYuanDuoBao[1])
  local self = YiYuanDuoBaoModule.Instance()
  self:RemoveCache(string.format("%d_%d", p.activity_cfg_id, p.turn))
  Event.DispatchEvent(ModuleId.YIYUANDUOBAO, gmodule.notifyId.YiYuanDuoBao.NeedNumRefresh, nil)
end
def.static("table").OnSAttendIndianaFail = function(p)
  local tip = textRes.YiYuanDuoBao.Error[p.res]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSGetAttendIndianaNumSuccess = function(p)
  local self = YiYuanDuoBaoModule.Instance()
  if p.activity_cfg_id == self.m_activityId and self.m_numRequest and self.m_numRequest[p.turn] then
    for k, v in pairs(self.m_numRequest[p.turn]) do
      v(p.attend_nums)
    end
    self.m_numRequest[p.turn] = nil
  end
end
def.static("table").OnSGetRoleAttendIndianaInfoSuccess = function(p)
  local self = YiYuanDuoBaoModule.Instance()
  if p.activity_cfg_id == self.m_activityId and self.m_joinRequest and self.m_joinRequest[p.turn] then
    for k, v in pairs(self.m_joinRequest[p.turn]) do
      v(p.attend_sortids)
    end
    self.m_joinRequest[p.turn] = nil
    self:AddCache(string.format("%d_%d", p.activity_cfg_id, p.turn), p.attend_sortids, 0)
  end
end
def.static("table").OnSGetIndianaAwardInfoSuccess = function(p)
  local self = YiYuanDuoBaoModule.Instance()
  if p.activity_cfg_id == self.m_activityId and self.m_awardRequest and self.m_awardRequest[p.turn] and self.m_awardRequest[p.turn][p.sortid] then
    for k, v in pairs(self.m_awardRequest[p.turn][p.sortid]) do
      v(p)
    end
    self.m_awardRequest[p.turn][p.sortid] = nil
    local curTime = GetServerTime()
    local turnCfg = YiYuanDuoBaoUtils.GetTurnCfg(p.activity_cfg_id, p.turn)
    if turnCfg and curTime - turnCfg.end_timestamp > 60 then
      self:AddCache(string.format("%d_%d_%d", p.activity_cfg_id, p.turn, p.sortid), p, 0)
    end
  end
end
def.static("table").OnSGetIndianaAwardInfoFail = function(p)
  local tip = textRes.YiYuanDuoBao.Error[p.res]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSGetIndianaLogsSuccess = function(p)
  local self = YiYuanDuoBaoModule.Instance()
  if p.activity_cfg_id == self.m_activityId and self.m_historyRequest then
    for k, v in pairs(self.m_historyRequest) do
      v(p.logs)
    end
    self.m_historyRequest = nil
    local curTime = GetServerTime()
    local type, turn, time = YiYuanDuoBaoUtils.GetTurn(p.activity_cfg_id, curTime)
    local turnCfg1 = YiYuanDuoBaoUtils.GetTurnCfg(p.activity_cfg_id, turn - 1)
    local turnCfg2 = YiYuanDuoBaoUtils.GetTurnCfg(p.activity_cfg_id, turn)
    if turnCfg1 and turnCfg2 and curTime - turnCfg1.end_timestamp > 60 then
      self:AddCache(tostring(p.activity_cfg_id), p.logs, turnCfg2.end_timestamp)
    end
  end
end
def.static("table").OnSRoleGetIndianaAwardBrd = function(p)
  local serverName = textRes.YiYuanDuoBao[9]
  local roleId = p.roleid
  if roleId then
    local serverInfo = GetRoleServerInfo(roleId)
    if serverInfo then
      serverName = serverInfo.name
    end
  end
  local name = GetStringFromOcts(p.role_name) or textRes.YiYuanDuoBao[10]
  local awardCfg = YiYuanDuoBaoUtils.GetAwardCfg(p.activity_cfg_id, p.turn, p.sortid)
  if awardCfg then
    local ItemUtils = require("Main.Item.ItemUtils")
    local items = ItemUtils.GetAwardItems(awardCfg.fix_award_id)
    if items and items[1] then
      local itemBase = ItemUtils.GetItemBase(items[1].itemId)
      if itemBase then
        local tipContent = string.format(textRes.YiYuanDuoBao[14], serverName, name, itemBase.name)
        require("GUI.RareItemAnnouncementTip").AnnounceRareItem(tipContent)
        local ChatModule = require("Main.Chat.ChatModule")
        local ChatMsgData = require("Main.Chat.ChatMsgData")
        local HtmlHelper = require("Main.Chat.HtmlHelper")
        ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = tipContent})
      end
    end
  end
end
def.static("table").OnSNotifyRoleGetIndianaAward = function(p)
  Toast(textRes.YiYuanDuoBao[24])
  local effRes = GetEffectRes(constant.CIndianaConsts.GET_AWARD_EFFECT_ID)
  if effRes then
    require("Fx.GUIFxMan").Instance():Play(effRes.path, "YiYuanDuoBaoGetAward", 0, 0, -1, false)
  end
  local awardCfg = YiYuanDuoBaoUtils.GetAwardCfg(p.activity_cfg_id, p.turn, p.sortid)
  if awardCfg then
    local ItemUtils = require("Main.Item.ItemUtils")
    local items = ItemUtils.GetAwardItems(awardCfg.fix_award_id)
    if items and items[1] then
      require("Main.YiYuanDuoBao.ui.DuoBaoSharePanel").ShowDuoBaoSharePanel(items[1].itemId)
    end
  end
end
def.static("table", "table").OnActivityOpen = function(p1, p2)
  local activityId = p1[1]
  local self = YiYuanDuoBaoModule.Instance()
  local duobao = YiYuanDuoBaoUtils.IsYiYuanDuoBaoActivity(activityId)
  if duobao then
    self.m_activityId = activityId
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local activityId = p1[1]
  local self = YiYuanDuoBaoModule.Instance()
  if self.m_activityId == activityId then
    Event.DispatchEvent(ModuleId.YIYUANDUOBAO, gmodule.notifyId.YiYuanDuoBao.ActivityChange, nil)
    self:UpdateRed()
    Event.DispatchEvent(ModuleId.YIYUANDUOBAO, gmodule.notifyId.YiYuanDuoBao.RedChange, nil)
    require("GUI.InteractiveAnnouncementTip").InteractiveAnnounceWithPriorityAndSprite(textRes.YiYuanDuoBao[25], 0, "Group_4")
  end
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  local activityId = p1[1]
  local self = YiYuanDuoBaoModule.Instance()
  if activityId == self.m_activityId then
    Event.DispatchEvent(ModuleId.YIYUANDUOBAO, gmodule.notifyId.YiYuanDuoBao.ActivityChange, nil)
    do
      local activityId = self.m_activityId
      local inTurn, turn = YiYuanDuoBaoUtils.GetTurn(activityId, GetServerTime())
      turn = turn - 1
      GameUtil.AddGlobalTimer(30, true, function()
        if IsEnteredWorld() and self.m_activityId > 0 then
          self:RequestDuoBaoNum(activityId, turn, function(data)
            local ItemUtils = require("Main.Item.ItemUtils")
            local ChatModule = require("Main.Chat.ChatModule")
            local ChatMsgData = require("Main.Chat.ChatMsgData")
            local HtmlHelper = require("Main.Chat.HtmlHelper")
            local turnCfg = YiYuanDuoBaoUtils.GetTurnCfg(activityId, turn)
            for k, v in ipairs(data) do
              local awardCfg = turnCfg.awards[k]
              local count = v
              if awardCfg then
                count = math.floor(count * awardCfg.ratio)
              end
              local add = (v - awardCfg.extra_award_need_num) / awardCfg.extra_award_need_num
              add = add > 0 and math.ceil(add) or 0
              local num = v > 0 and add + awardCfg.init_award_num or 0
              local items = ItemUtils.GetAwardItems(awardCfg.fix_award_id)
              if items and items[1] then
                local itemBase = ItemUtils.GetItemBase(items[1].itemId)
                if itemBase then
                  local tipContent = string.format(textRes.YiYuanDuoBao[26], turnCfg.diaplay_turn, count, itemBase.name, num, activityId, turn, k)
                  require("GUI.AnnouncementTip").Announce(tipContent)
                  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = tipContent})
                end
              end
            end
            local effRes = GetEffectRes(constant.CIndianaConsts.OPEN_AWARD_EFFECT_ID)
            if effRes then
              require("Fx.GUIFxMan").Instance():Play(effRes.path, "YiYuanDuoBaoDrawAward", 0, 0, 5, false)
            end
          end)
        end
      end)
    end
  end
end
def.static("table", "table").OnChatBtnClick = function(p1, p2)
  local id = p1.id
  if id and string.sub(id, 1, 13) == "yiyuanduobao_" then
    local strs = string.split(id, "_")
    local activityId = tonumber(strs[2])
    local turnId = tonumber(strs[3])
    local sortId = tonumber(strs[4])
    if activityId and turnId and sortId then
      require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():RequestLuckyGuy(activityId, turnId, sortId, function(data)
        require("Main.YiYuanDuoBao.ui.LuckGuyList").ShowLuckGuyList(data.award_infos, data.turn, data.sortid)
      end)
    end
  end
end
def.static("table", "table").OnActivityClose = function(p1, p2)
  local activityId = p1[1]
  local self = YiYuanDuoBaoModule.Instance()
  if activityId == self.m_activityId then
    self.m_activityId = 0
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local self = YiYuanDuoBaoModule.Instance()
  self.m_activityId = YiYuanDuoBaoUtils.GetCurActivityId()
  self:UpdateRed()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = YiYuanDuoBaoModule.Instance()
  self.m_activityId = 0
  self.m_cacheData = nil
  self.m_numRequest = nil
  self.m_joinRequest = nil
  self.m_awardRequest = nil
  self.m_historyRequest = nil
  self.m_isRed = false
end
def.static("table", "table").OnFeatureChange = function(p1, p2)
  if p1.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_INDIANA_JONES then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  end
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  local self = YiYuanDuoBaoModule.Instance()
  if activityId == self.m_activityId then
    self:OpenDuoBaoPanel()
  end
end
def.method("number", "number", "number").C2SAttendDuoBao = function(self, activityId, turn, sortId)
  local req = require("netio.protocol.mzm.gsp.indiana.CAttendIndianaReq").new(activityId, turn, sortId)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number").C2SReqDuoBaoNum = function(self, activityId, turn)
  local req = require("netio.protocol.mzm.gsp.indiana.CGetAttendIndianaNumReq").new(activityId, turn)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number").C2SReqDuoBaoJoin = function(self, activityId, turn)
  local req = require("netio.protocol.mzm.gsp.indiana.CGetRoleAttendIndianaInfoReq").new(activityId, turn)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number", "number").C2SReqLuckyGuy = function(self, activityId, turn, sortId)
  local req = require("netio.protocol.mzm.gsp.indiana.CGetIndianaAwardInfoReq").new(activityId, turn, sortId)
  gmodule.network.sendProtocol(req)
end
def.method("number").C2SReqSpuerLuckyGuy = function(self, activityId)
  local req = require("netio.protocol.mzm.gsp.indiana.CGetIndianaLogsReq").new(activityId)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number", "=>", "number").IsInBuyTime = function(self, activityId, turn)
  local turnCfg = YiYuanDuoBaoUtils.GetTurnCfg(activityId, turn)
  if turnCfg then
    local curTime = GetServerTime()
    if curTime >= turnCfg.end_timestamp then
      return 1
    elseif curTime < turnCfg.begin_timestamp then
      return -1
    else
      return 0
    end
  else
    return -1
  end
end
def.method("number", "number", "=>", "boolean").IsFinished = function(self, activityId, turn)
  local turnCfg = YiYuanDuoBaoUtils.GetTurnCfg(activityId, turn)
  if turnCfg then
    local curTime = GetServerTime()
    if curTime >= turnCfg.end_timestamp then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_INDIANA_JONES)
  local crossServer = IsCrossingServer()
  return open and not crossServer and self.m_activityId > 0
end
def.method("=>", "boolean").IsRed = function(self)
  return self.m_isRed
end
def.method().UpdateRed = function(self)
  if self.m_activityId > 0 then
    local state = YiYuanDuoBaoUtils.GetTurn(self.m_activityId, GetServerTime())
    self.m_isRed = state == 1
  else
    self.m_isRed = false
  end
end
def.method().OpenDuoBaoPanel = function(self)
  if self.m_activityId > 0 then
    require("Main.YiYuanDuoBao.ui.YiYuanDuoBaoMain").ShowYiYuanDuoBaoMain(self.m_activityId)
    if self.m_isRed then
      self.m_isRed = false
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
      Event.DispatchEvent(ModuleId.YIYUANDUOBAO, gmodule.notifyId.YiYuanDuoBao.RedChange, nil)
    end
  end
end
def.method("number").OpenDuoBaoHistory = function(self, activityId)
  require("Main.YiYuanDuoBao.ui.YiYuanDuoBaoHistory").ShowYiYuanDuoBaoHistory(activityId)
end
def.method("number", "number", "number", "number", "boolean").OpenDuobaoBuy = function(self, activityId, turn, sortId, num, join)
  local inBuyTime = self:IsInBuyTime(activityId, turn)
  if inBuyTime == 0 then
    require("Main.YiYuanDuoBao.ui.YiYuanDuoBaoBuy").ShowYiYuanDuoBaoBuy(activityId, turn, sortId, num, join)
  elseif inBuyTime < 0 then
    Toast(textRes.YiYuanDuoBao[17])
  elseif inBuyTime > 0 then
    Toast(textRes.YiYuanDuoBao[18])
  end
end
def.method("number", "number", "number").Buy = function(self, activityId, turn, sortId)
  local activityCfg = YiYuanDuoBaoUtils.GetActivityCfg(activityId)
  local awardCfg = YiYuanDuoBaoUtils.GetAwardCfg(activityId, turn, sortId)
  if activityCfg and awardCfg and require("Main.Item.ItemModule").Instance():CheckMoneyEnough(awardCfg.cost_money_type, awardCfg.cost_money_num) then
    local moneyName = textRes.Item.MoneyName[awardCfg.cost_money_type]
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.YiYuanDuoBao[22], string.format(textRes.YiYuanDuoBao[23], awardCfg.cost_money_num, moneyName), function(sel)
      if sel == 1 then
        self:C2SAttendDuoBao(activityId, turn, sortId)
      end
    end, nil)
  end
end
def.method("number", "number", "function").RequestDuoBaoNum = function(self, activityId, turn, callback)
  if self.m_numRequest == nil then
    self.m_numRequest = {}
  end
  if self.m_numRequest[turn] == nil then
    self.m_numRequest[turn] = {}
  end
  table.insert(self.m_numRequest[turn], callback)
  self:C2SReqDuoBaoNum(activityId, turn)
end
def.method("number", "number", "function").RequestDuoBaoJoin = function(self, activityId, turn, callback)
  local cache = self:GetCache(string.format("%d_%d", activityId, turn))
  if cache then
    if callback then
      callback(cache)
    end
    return
  end
  if self.m_joinRequest == nil then
    self.m_joinRequest = {}
  end
  if self.m_joinRequest[turn] == nil then
    self.m_joinRequest[turn] = {}
  end
  table.insert(self.m_joinRequest[turn], callback)
  self:C2SReqDuoBaoJoin(activityId, turn)
end
def.method("number", "number", "number", "function").RequestLuckyGuy = function(self, activityId, turn, sortId, callback)
  local cache = self:GetCache(string.format("%d_%d_%d", activityId, turn, sortId))
  if cache then
    if callback then
      callback(cache)
    end
    return
  end
  if self.m_awardRequest == nil then
    self.m_awardRequest = {}
  end
  if self.m_awardRequest[turn] == nil then
    self.m_awardRequest[turn] = {}
  end
  if self.m_awardRequest[turn][sortId] == nil then
    self.m_awardRequest[turn][sortId] = {}
  end
  table.insert(self.m_awardRequest[turn][sortId], callback)
  self:C2SReqLuckyGuy(activityId, turn, sortId)
end
def.method("number", "function").RequestSuperLuckyGuy = function(self, activityId, callback)
  local cache = self:GetCache(tostring(activityId))
  if cache then
    if callback then
      callback(cache)
    end
    return
  end
  if self.m_historyRequest == nil then
    self.m_historyRequest = {}
  end
  table.insert(self.m_historyRequest, callback)
  self:C2SReqSpuerLuckyGuy(activityId)
end
def.method("string").RemoveCache = function(self, key)
  if self.m_cacheData then
    self.m_cacheData[key] = nil
  end
end
def.method("string", "table", "number").AddCache = function(self, key, data, expired)
  if self.m_cacheData == nil then
    self.m_cacheData = {}
  end
  self.m_cacheData[key] = {data = data, expired = expired}
end
def.method("string", "=>", "table").GetCache = function(self, key)
  if self.m_cacheData then
    if self.m_cacheData[key] then
      local info = self.m_cacheData[key]
      if info.expired > 0 and GetServerTime() >= info.expired then
        self.m_cacheData[key] = nil
        return nil
      else
        return info.data
      end
    else
      return nil
    end
  end
  return nil
end
YiYuanDuoBaoModule.Commit()
return YiYuanDuoBaoModule

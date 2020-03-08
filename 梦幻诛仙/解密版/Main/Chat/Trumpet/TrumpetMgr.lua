local Lplus = require("Lplus")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local TrumpetQueue = require("Main.Chat.Trumpet.data.TrumpetQueue")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local HeroInterface = require("Main.Hero.HeroModule")
local ItemModule = require("Main.Item.ItemModule")
local ChatUtils = require("Main.Chat.ChatUtils")
local SendTrumpetDlg, ChannelChatPanel, MainUIPanel, TrumpetPanel
local TrumpetMgr = Lplus.Class("TrumpetMgr")
local def = TrumpetMgr.define
local instance
def.static("=>", TrumpetMgr).Instance = function()
  if instance == nil then
    instance = TrumpetMgr()
  end
  return instance
end
def.field("table")._trumpetCfgList = nil
def.method().Init = function(self)
  TrumpetPanel = require("Main.Chat.Trumpet.ui.TrumpetPanel")
  MainUIPanel = require("Main.MainUI.ui.MainUIPanel")
  ChannelChatPanel = require("Main.Chat.ui.ChannelChatPanel")
  SendTrumpetDlg = require("Main.Chat.Trumpet.ui.SendTrumpetDlg")
  self:LoadCfg()
  TrumpetQueue.Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInTrumpet", TrumpetMgr.OnSChatInTrumpet)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chat.SChatInTrumpetFail", TrumpetMgr.OnSChatInTrumpetFail)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, TrumpetMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TrumpetMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.NEW_TRUMPET, TrumpetMgr.OnShowNextTrumpet)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, TrumpetMgr.OnMainUIShow)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_HIDE, TrumpetMgr.OnMainUIHide)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHANNEL_TRUMPET_CHANGE, TrumpetMgr.OnChannelTrumpetChange)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.TRUMPET_USE, TrumpetMgr.OnUseTrumpet)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CloseChatPanel, TrumpetMgr.OnChatHide)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, TrumpetMgr.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, TrumpetMgr.OnLeaveFight)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TrumpetMgr.OnFunctionOpenChange)
end
def.method().LoadCfg = function(self)
  self._trumpetCfgList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHAT_TRUMPET)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local cfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.itemid = DynamicRecord.GetIntValue(entry, "itemid")
    cfg.desc = DynamicRecord.GetStringValue(entry, "desc")
    cfg.costYB = DynamicRecord.GetIntValue(entry, "costYB")
    cfg.durationNormal = DynamicRecord.GetIntValue(entry, "durationNormal")
    cfg.durationIdle = DynamicRecord.GetIntValue(entry, "durationIdle")
    cfg.contentColorR = DynamicRecord.GetIntValue(entry, "content_color_r")
    cfg.contentColorG = DynamicRecord.GetIntValue(entry, "content_color_g")
    cfg.contentColorB = DynamicRecord.GetIntValue(entry, "content_color_b")
    cfg.spriteName = DynamicRecord.GetStringValue(entry, "spriteName")
    table.insert(self._trumpetCfgList, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(self._trumpetCfgList, function(a, b)
    return a.id < b.id
  end)
end
def.method("boolean", "=>", "boolean").IsFeatureOpen = function(self, needToast)
  local open = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_TRUMPET)
  if needToast and false == open then
    Toast(textRes.Chat.Trumpet.FEATRUE_NOT_OPEN)
  end
  return open
end
def.method("boolean", "=>", "boolean").IsConditionSatisfied = function(self, needToast)
  local result = true
  local rolelevel = 0
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp ~= nil then
    rolelevel = heroProp.level
  end
  result = rolelevel >= constant.CTrumpetConsts.RECEIVE_MIN_LEVEL
  if needToast and false == result then
    Toast(string.format(textRes.Chat.Trumpet.NOT_OPEN_LOW_LEVEL, constant.CTrumpetConsts.RECEIVE_MIN_LEVEL))
  end
  return result
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, needToast)
  local result = true
  if not self:IsFeatureOpen(needToast) then
    result = false
  elseif not self:IsConditionSatisfied(needToast) then
    result = false
  end
  return result
end
def.method("=>", "table").GetTrumpetCfgs = function(self)
  return self._trumpetCfgList
end
def.method("number", "=>", "table").GetTrumpetCfgByIndex = function(self, index)
  return self._trumpetCfgList[index]
end
def.method("number", "=>", "table").GetTrumpetCfgById = function(self, id)
  local result
  for i = 1, #self._trumpetCfgList do
    if self._trumpetCfgList[i].id == id then
      result = self._trumpetCfgList[i]
      break
    end
  end
  return result
end
def.method("number", "=>", "number").GetTrumpetIndexByItemId = function(self, id)
  local result = 0
  for i = 1, #self._trumpetCfgList do
    if self._trumpetCfgList[i].itemid == id then
      result = i
      break
    end
  end
  return result
end
def.method("function").Foreach = function(self, callback)
  if callback then
    for i = 1, #self._trumpetCfgList do
      callback(self._trumpetCfgList[i].itemid)
    end
  end
end
def.method("number").IsTrumpet = function(self, itemid)
  local result = false
  for i = 1, #self._trumpetCfgList do
    if self._trumpetCfgList[i].itemid == itemid then
      result = true
      break
    end
  end
  return result
end
def.method("number", "=>", "number").GetTrumpetCountById = function(self, id)
  local trumpetCfg = self:GetTrumpetCfgById(id)
  return trumpetCfg and ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, trumpetCfg.itemid) or 0
end
def.method("number", "string", "=>", "boolean").SendCChatInTrumpetReq = function(self, trumpetid, cntString)
  if self:IsOpen(true) then
    if "" == cntString then
      Toast(textRes.Chat.Trumpet.CONTENT_EMPTY)
      return false
    end
    do
      local unicodeName = GameUtil.Utf8ToUnicode(cntString)
      local chatlen = require("Main.Common.NameValidator").Instance():GetWordNum(unicodeName)
      if chatlen > constant.CTrumpetConsts.MAX_WORD_NUM then
        Toast(string.format(textRes.Chat.Trumpet.CONTENT_OVERLENGTH, constant.CTrumpetConsts.MAX_WORD_NUM))
        return false
      end
      if ChatUtils.GetChatLinkCount(cntString) > 1 then
        Toast(textRes.Chat.Trumpet.LINK_TOO_MUCK)
        warn("[SendTrumpetDlg:SendTrumpet] ERROR! ChatUtils.GetChatLinkCount(cntString)>1:", ChatUtils.GetChatLinkCount(cntString))
        return false
      end
      local trumpetCfg = self:GetTrumpetCfgById(trumpetid)
      if trumpetCfg == nil then
        Toast(textRes.Chat.Trumpet.TRUMPET_INVALID)
        return false
      end
      local trumpetCount = self:GetTrumpetCountById(trumpetid)
      local roleYB = ItemModule.Instance():GetAllYuanBao():ToNumber()
      if trumpetCount <= 0 then
        if roleYB >= trumpetCfg.costYB then
          require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Chat.Trumpet.COST_TITLE, string.format(textRes.Chat.Trumpet.COST_YUANBAO, trumpetCfg.costYB), function(id, tag)
            if id == 1 then
              local suc = self:DoSendCChatInTrumpetReq(trumpetid, roleYB, cntString)
              if suc then
                SendTrumpetDlg.Instance():ClearInput()
              end
            end
          end, nil)
          return false
        else
          Toast(textRes.Chat.Trumpet.LACK_OF_YUANBAO)
          local MallPanel = require("Main.Mall.ui.MallPanel")
          require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
          return false
        end
      end
      return self:DoSendCChatInTrumpetReq(trumpetid, roleYB, cntString)
    end
  else
    warn("[TrumpetMgr:SendCChatInTrumpetReq] send CChatInTrumpetReq fail, not open!")
    return false
  end
end
def.method("number", "number", "string", "=>", "boolean").DoSendCChatInTrumpetReq = function(self, trumpetid, currentYB, cntString)
  local contentType = ChatConsts.CONTENT_NORMAL
  local chatContent = require("netio.Octets").rawFromString(cntString)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatInTrumpetReq").new(trumpetid, currentYB, contentType, chatContent))
  if self:GetTrumpetCountById(trumpetid) > 0 then
    Toast(textRes.Chat.Trumpet.SEND_TRUMPET_WITH_ITEM)
  end
  return true
end
def.static("table").OnSChatInTrumpet = function(p)
  if p.chatContent.roleId == HeroInterface.Instance():GetMyRoleId() then
  end
end
def.static("table").OnSChatInTrumpetFail = function(p)
  warn("[TrumpetMgr:OnSChatInTrumpetFail] Received SChatInTrumpetFail, p.res:", p.res)
  local SChatInTrumpetFail = require("netio.protocol.mzm.gsp.chat.SChatInTrumpetFail")
  if SChatInTrumpetFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN == p.res then
    Toast(textRes.Chat.Trumpet.MODULE_CLOSE_OR_ROLE_FORBIDDEN)
  elseif SChatInTrumpetFail.ROLE_STATUS_ERROR == p.res then
    Toast(textRes.Chat.Trumpet.ROLE_STATUS_ERROR)
  elseif SChatInTrumpetFail.PARAM_ERROR == p.res then
    Toast(textRes.Chat.Trumpet.PARAM_ERROR)
  elseif SChatInTrumpetFail.YUANBAO_NOT_MATCH == p.res then
    Toast(textRes.Chat.Trumpet.LACK_OF_YUANBAO)
  elseif SChatInTrumpetFail.ITEM_AND_YUANBAO_NOT_ENOUGH == p.res then
    Toast(textRes.Chat.Trumpet.ITEM_AND_YUANBAO_NOT_ENOUGH)
  elseif SChatInTrumpetFail.CAN_NOT_SPEAK == p.res then
    Toast(textRes.Chat.Trumpet.CAN_NOT_SPEAK)
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  TrumpetQueue.Instance():Reset()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  TrumpetQueue.Instance():Reset()
end
def.static("table", "table").OnShowNextTrumpet = function(params, context)
  warn("[TrumpetMgr:OnShowNextTrumpet] On NEW_TRUMPET!")
  if params.next then
    if TrumpetPanel.Instance():IsShow() then
      TrumpetPanel.Instance():ShowTrumpet(params.next)
    else
      TrumpetPanel.ShowDlg(TrumpetMgr.GetAnchor(false))
    end
  elseif TrumpetPanel.Instance():IsShow() then
    TrumpetPanel.Instance():DestroyPanel()
  end
end
def.static("table", "table").OnMainUIShow = function(params, context)
  TrumpetMgr.UpdateAnchor(false)
end
def.static("table", "table").OnMainUIHide = function(params, context)
  TrumpetMgr.UpdateAnchor(false)
end
def.static("table", "table").OnChannelTrumpetChange = function(params, context)
  if params.show == false then
    if TrumpetPanel.Instance():IsShow() then
      TrumpetPanel.Instance():DestroyPanel()
    end
  else
    TrumpetMgr.UpdateAnchor(false)
  end
end
def.static("table", "table").OnUseTrumpet = function(params, context)
  warn("[TrumpetMgr:OnUseTrumpet] On TRUMPET_USE!")
  if TrumpetMgr.Instance():IsOpen(true) then
    SendTrumpetDlg.ShowDlg(params)
  end
end
def.static("table", "table").OnChatHide = function(params, context)
  TrumpetMgr.UpdateAnchor(true)
end
def.static("table", "table").OnEnterFight = function(params, context)
  TrumpetMgr.UpdateAnchor(false)
end
def.static("table", "table").OnLeaveFight = function(params, context)
  TrumpetMgr.UpdateAnchor(false)
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1.feature ~= ModuleFunSwitchInfo.TYPE_TRUMPET or p1.open then
  else
  end
end
def.static("boolean").UpdateAnchor = function(isHidingChat)
  if TrumpetQueue.Instance():IsEmpty() then
    if TrumpetPanel.Instance():IsShow() then
      TrumpetPanel.Instance():DestroyPanel()
    end
  else
    local anchor = TrumpetMgr.GetAnchor(isHidingChat)
    if TrumpetPanel.Instance():IsShow() then
      TrumpetPanel.Instance():SetAnchor(anchor)
    else
      TrumpetPanel.ShowDlg(anchor)
    end
  end
end
def.static("boolean", "=>", "table").GetAnchor = function(isHidingChat)
  local result
  if ChannelChatPanel.Instance():IsShow() and false == isHidingChat then
    result = {}
    result.anchor = ChannelChatPanel.Instance():GetTrumpetAnchor()
    result.isMainUI = false
  elseif MainUIPanel.Instance():IsShow() then
    result = {}
    result.anchor = MainUIPanel.Instance():GetTrumpetAnchor()
    result.isMainUI = true
  end
  return result
end
TrumpetMgr.Commit()
return TrumpetMgr

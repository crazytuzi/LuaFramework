require("Main.module.ModuleId")
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local FeatureOpenListModule = Lplus.Extend(ModuleBase, "FeatureOpenListModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = FeatureOpenListModule.define
local instance
def.static("=>", FeatureOpenListModule).Instance = function()
  if not instance then
    instance = FeatureOpenListModule()
    instance.m_moduleId = ModuleId.FEATURE
  end
  return instance
end
def.field("table").featureList = nil
def.override().Init = function(self)
  self.featureList = nil
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.open.SGetModuleFunSwitchesRep", FeatureOpenListModule.OnFeatureList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.open.SModuleFunSwitchInfoChanged", FeatureOpenListModule.OnFeatureChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.open.SModuleFunSwitchCloseTip", FeatureOpenListModule.OnFeatureChangeTip)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, FeatureOpenListModule.OnEnterWorld)
  ModuleBase.Init(self)
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local enterType = p1 and p1.enterType
  if enterType == _G.EnterWorldType.RECONNECT then
    instance.featureList = nil
    instance:RequestFeatureList()
  elseif instance.featureList then
    Event.DispatchEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, nil)
    instance:OnFeatureInit()
  end
end
def.override().OnReset = function(self)
  self.featureList = nil
end
def.static("table").OnFeatureList = function(p)
  instance.featureList = {}
  for k, v in pairs(p.funSwitches) do
    if v.moduleid >= Feature.MIN_TYPE_ID and v.moduleid <= Feature.MAX_TYPE_ID then
      if instance.featureList[v.moduleid] == nil then
        instance.featureList[v.moduleid] = {}
      end
      instance.featureList[v.moduleid][v.funid] = {
        open = v.isopen > 0 and true or false,
        param = v.params
      }
    end
  end
  if IsEnteredWorld() then
    Event.DispatchEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, nil)
    instance:OnFeatureInit()
  else
    Event.DispatchEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenPreInit, nil)
  end
end
def.static("table").OnFeatureChange = function(p)
  if instance.featureList == nil then
    instance.featureList = {}
  end
  local info = p.info
  if info.moduleid < Feature.MIN_TYPE_ID or info.moduleid > Feature.MAX_TYPE_ID then
    return
  end
  if instance.featureList[info.moduleid] == nil then
    instance.featureList[info.moduleid] = {}
  end
  instance.featureList[info.moduleid][info.funid] = {
    open = info.isopen > 0 and true or false,
    param = info.params
  }
  if info.funid == 0 then
    if IsEnteredWorld() then
      Event.DispatchEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, {
        feature = info.moduleid,
        open = info.isopen > 0 and true or false,
        param = info.params
      })
      instance:OnFeatrueChange(info.moduleid, info.isopen > 0, info.params)
    else
      Event.DispatchEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenPreChange, {
        feature = info.moduleid,
        open = info.isopen > 0 and true or false,
        param = info.params
      })
    end
  end
  if IsEnteredWorld() then
    Event.DispatchEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChangeFuncId, {
      feature = info.moduleid,
      open = info.isopen > 0 and true or false,
      param = info.params,
      funcid = info.funid
    })
  else
    Event.DispatchEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenPreChangeFuncId, {
      feature = info.moduleid,
      open = info.isopen > 0 and true or false,
      param = info.params,
      funcid = info.funid
    })
  end
end
def.static("table").OnFeatureChangeTip = function(p)
  local moduleId = p.moduleid
  local moduleName = textRes.IDIP.PlayTypeName[moduleId]
  if moduleName then
    local tip = string.format(textRes.IDIP[7], moduleName)
    Toast(tip)
  end
end
def.method().RequestFeatureList = function(self)
  local req = require("netio.protocol.mzm.gsp.open.CGetModuleFunSwitchesReq").new()
  gmodule.network.sendProtocol(req)
end
def.method("number", "=>", "boolean", "table").CheckFeatureOpen = function(self, featureType)
  return self:CheckFeatureOpenEx(featureType, 0)
end
def.method("number", "number", "=>", "boolean", "table").CheckFeatureOpenEx = function(self, featureType, funcId)
  if self.featureList == nil then
    return true, nil
  end
  local featureInfo = self.featureList[featureType]
  if featureInfo then
    if featureInfo[funcId] then
      return featureInfo[funcId].open, featureInfo[funcId].param
    else
      return true, nil
    end
  else
    return true, nil
  end
end
def.method().OnFeatureInit = function(self)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.OnToggle, {
    switch = self:CheckFeatureOpen(Feature.TYPE_APOLLO)
  })
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.InitApollo, {
    switch = self:CheckFeatureOpen(Feature.TYPE_APOLLO)
  })
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.InitQQEC, {
    switch = self:CheckFeatureOpen(Feature.TYPE_ESPORTS)
  })
  if not self:CheckFeatureOpen(Feature.TYPE_MASSWEDDING) then
    require("Main.activity.ActivityInterface").Instance():addCustomCloseActivity(constant.CMassWeddingConsts.activityid)
  end
  if not self:CheckFeatureOpen(Feature.TYPE_LUCKY_BAG) then
    require("Main.activity.ActivityInterface").Instance():addCustomCloseActivity(constant.CLuckyBagCfgConsts.ACTIVITY_CFG_ID)
  end
  if not self:CheckFeatureOpen(Feature.TYPE_MASS_EXP) then
    require("Main.activity.ActivityInterface").Instance():addCustomCloseActivity(constant.LingQiFengYinConsts.LINGQIFENGYIN_ACTIVITYID)
  end
end
def.method("number", "boolean", "table").OnFeatrueChange = function(self, featureId, switch, parms)
  if featureId == Feature.TYPE_APOLLO then
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.OnToggle, {switch = switch})
  elseif featureId == Feature.TYPE_MASSWEDDING then
    if switch then
      require("Main.activity.ActivityInterface").Instance():removeCustomCloseActivity(constant.CMassWeddingConsts.activityid)
    else
      require("Main.activity.ActivityInterface").Instance():addCustomCloseActivity(constant.CMassWeddingConsts.activityid)
    end
  elseif featureId == Feature.TYPE_LUCKY_BAG then
    if switch then
      require("Main.activity.ActivityInterface").Instance():removeCustomCloseActivity(constant.CLuckyBagCfgConsts.ACTIVITY_CFG_ID)
    else
      require("Main.activity.ActivityInterface").Instance():addCustomCloseActivity(constant.CLuckyBagCfgConsts.ACTIVITY_CFG_ID)
    end
  elseif featureId == Feature.TYPE_MASS_EXP then
    if switch then
      require("Main.activity.ActivityInterface").Instance():removeCustomCloseActivity(constant.LingQiFengYinConsts.LINGQIFENGYIN_ACTIVITYID)
    else
      require("Main.activity.ActivityInterface").Instance():addCustomCloseActivity(constant.LingQiFengYinConsts.LINGQIFENGYIN_ACTIVITYID)
    end
  end
end
def.method("=>", "boolean").IsFeatureListInited = function(self)
  return self.featureList ~= nil
end
local count = 0
def.method().Output = function(self)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local ChatModule = require("Main.Chat.ChatModule")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  if self.featureList then
    local sortedList = {}
    for k, v in pairs(self.featureList) do
      table.insert(sortedList, {k = k, v = v})
    end
    table.sort(sortedList, function(a, b)
      return a.k < b.k
    end)
    count = count + 1
    ChatModule.Instance():SendSystemMsgEx(ChatMsgData.System.SYS, HtmlHelper.Style.GM, {
      cmd = tostring(count) .. ":" .. textRes.IDIP[11]
    }, false)
    for _, cnt in pairs(sortedList) do
      for funcid, v in pairs(cnt.v) do
        if v.open == false then
          local k = cnt.k
          local switchName = textRes.IDIP.PlayTypeName[k] or "undefine"
          local str = string.format("%d.%d:%s is %s", k, funcid, switchName, v.open and "open" or "close")
          ChatModule.Instance():SendSystemMsgEx(ChatMsgData.System.SYS, HtmlHelper.Style.GM, {cmd = str}, false)
        end
      end
    end
    ChatModule.Instance():SendSystemMsgEx(ChatMsgData.System.SYS, HtmlHelper.Style.GM, {
      cmd = tostring(count) .. ":" .. textRes.IDIP[12]
    }, false)
  end
end
def.method("number", "number").OutputOne = function(self, id, funcId)
  local open, param = self:CheckFeatureOpenEx(id, funcId)
  local switchName = textRes.IDIP.PlayTypeName[id] or "undefine"
  local openStr = open and "open" or "close"
  local outputOne = "Funtion:" .. id .. "." .. funcId .. ":" .. switchName .. " is " .. openStr
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local ChatModule = require("Main.Chat.ChatModule")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  ChatModule.Instance():SendSystemMsgEx(ChatMsgData.System.SYS, HtmlHelper.Style.GM, {cmd = outputOne}, false)
end
FeatureOpenListModule.Commit()
return FeatureOpenListModule

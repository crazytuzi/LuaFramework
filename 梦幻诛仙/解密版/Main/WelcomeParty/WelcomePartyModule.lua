local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local WelcomePartyModule = Lplus.Extend(ModuleBase, MODULE_NAME)
local instance
local def = WelcomePartyModule.define
local Protocols = require("Main.WelcomeParty.Protocols")
local Utils = require("Main.WelcomeParty.WelcomePartyUtils")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local TescoMallMgr = require("Main.WelcomeParty.TescoMallMgr")
local DoudouGiftMgr = require("Main.WelcomeParty.DoudouGiftMgr")
local Cls = WelcomePartyModule
def.field("table")._nodeList = nil
def.static("=>", WelcomePartyModule).Instance = function()
  if instance == nil then
    instance = WelcomePartyModule()
  end
  return instance
end
def.override().Init = function(self)
  Protocols.Instance():Init()
  require("Main.WelcomeParty.ui.UIWelcomePartyBasic").Instance()
  require("Main.WelcomeParty.CarnivalSignMgr").Instance():Init()
  TescoMallMgr.Instance():Init()
  DoudouGiftMgr.Instance():Init()
  Event.RegisterEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, Cls.OnNodesOpenChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, Cls.OnNodesOpenChange)
end
def.static("=>", "table").GetProtocols = function()
  return Protocols
end
def.static("number", "=>", "boolean").IsFeatureOpen = function(openId)
  local featureInstance = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureInstance:CheckFeatureOpen(openId)
  return bFeatureOpen
end
def.method("=>", "boolean").IsOpen = function(self)
  for _, node in ipairs(instance._nodeList) do
    if node:IsOpen() then
      return true
    end
  end
  return false
end
def.static("table").RegistNode = function(node)
  instance._nodeList = instance._nodeList or {}
  if node == nil then
    return
  end
  table.insert(instance._nodeList, node)
end
def.static("=>", "boolean").IsShowRedDot = function()
  for _, node in ipairs(instance._nodeList) do
    if node:IsHaveNotifyMessage() then
      return true
    end
  end
  return false
end
def.static("table", "table").OnNodesOpenChange = function(p, c)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
end
return WelcomePartyModule.Commit()

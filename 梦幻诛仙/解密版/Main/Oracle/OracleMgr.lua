local Lplus = require("Lplus")
local OracleData = require("Main.Oracle.data.OracleData")
local LoginModule = require("Main.Login.LoginModule")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local DlgOracle
local OracleMgr = Lplus.Class("OracleMgr")
local def = OracleMgr.define
local instance
def.static("=>", OracleMgr).Instance = function()
  if instance == nil then
    instance = OracleMgr()
  end
  return instance
end
def.method().Init = function(self)
  DlgOracle = require("Main.Oracle.ui.DlgOracle")
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, OracleMgr._OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, OracleMgr._OnLeaveWorld)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, OracleMgr._OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.OPEN_ORACLE_DLG, OracleMgr._OnOpenOracleDlg)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, OracleMgr._OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Oracle, OracleMgr._OnUseOracleItem)
end
def.static("table", "table")._OnEnterWorld = function(self, params, context)
  OracleData.Instance():OnEnterWorld(params, context)
  if not params or params.enterType ~= LoginModule.EnterWorldType.RECONNECT then
  end
end
def.static("table", "table")._OnLeaveWorld = function(self, params, context)
  OracleData.Instance():OnLeaveWorld(params, context)
  if not params or params.reason == LoginModule.LeaveWorldReason.RECONNECT then
  end
end
def.static("table", "table")._OnHeroLevelUp = function(self, params, context)
  OracleData.Instance():OnHeroLevelUp(params, context)
end
def.static("table", "table")._OnOpenOracleDlg = function(self, params, context)
  if not _G.IsCrossingServer() then
    DlgOracle.ShowDlg()
  else
    ToastCrossingServerForbiden()
  end
end
def.static("table", "table")._OnFunctionOpenChange = function(param, context)
  if param.feature == ModuleFunSwitchInfo.TYPE_GENIUS and false == param.open and DlgOracle.Instance():IsShow() then
    DlgOracle.Instance():DestroyPanel()
  else
  end
end
def.static("table", "table")._OnUseOracleItem = function(param, context)
  local OracleModule = require("Main.Oracle.OracleModule")
  if not OracleModule.Instance():IsOpen(true) then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(param.bagId, param.itemKey)
  if item == nil then
    warn("[OracleMgr:_OnUseOracleItem] oracle itemInfo not found in bag!param.bagId, param.itemKey:", param.bagId, param.itemKey)
    return
  end
  local OracleProtocols = require("Main.Oracle.OracleProtocols")
  OracleProtocols.SendCUseGeniusStoneItem(item.uuid[1], param.bUseAll)
end
OracleMgr.Commit()
return OracleMgr

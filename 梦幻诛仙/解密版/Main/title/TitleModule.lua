local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local TitleModule = Lplus.Extend(ModuleBase, "TitleModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local def = TitleModule.define
local instance
def.static("=>", TitleModule).Instance = function()
  if instance == nil then
    instance = TitleModule()
    instance.m_moduleId = ModuleId.TITLE
  end
  return instance
end
local TitleInterface = require("Main.title.TitleInterface")
local titleInterface = TitleInterface.Instance()
def.override().Init = function(self)
  local protocols = require("Main.title.TitleProtocols")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.title.SChangePropertyReq", protocols.OnSChangePropertyReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.title.SChangeTitleOrAppellationReq", protocols.OnSChangeTitleOrAppellationReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.title.SChangeAppellationArgs", protocols.OnSChangeAppellationArgs)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.title.SGetNewTitleOrAppellation", protocols.OnSGetNewTitleOrAppellation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.title.SInitTitleOrAppellation", protocols.OnSInitTitleOrAppellation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.title.SRemoveTitleOrAppellation", protocols.OnSRemoveTitleOrAppellation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.title.STitleNormalInfo", protocols.OnSTitleNormalInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TITLE_CLICK, TitleModule.OnBtnTitleClick)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_APPELLATION_CLICK, TitleModule.OnBtnAppellationClick)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  titleInterface:Reset()
end
def.static("table", "table").OnBtnTitleClick = function(p1, p2)
  if #titleInterface._ownTitle == 0 then
    Toast(textRes.Title[32])
    return
  end
  require("Main.Hero.mgr.HeroPropMgr").Instance():SetNewTitle(0)
  local titleMain = require("Main.title.ui.TitleMain").Instance()
  titleMain._forceShowTab = 2
  titleMain:ShowDlg()
end
def.static("table", "table").OnBtnAppellationClick = function(p1, p2)
  if #titleInterface._ownAppellation == 0 then
    Toast(textRes.Title[31])
    return
  end
  require("Main.Hero.mgr.HeroPropMgr").Instance():SetNewAppellation(0)
  local titleMain = require("Main.title.ui.TitleMain").Instance()
  titleMain._forceShowTab = 1
  titleMain:ShowDlg()
end
TitleModule.Commit()
return TitleModule

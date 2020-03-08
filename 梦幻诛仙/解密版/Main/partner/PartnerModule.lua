local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local PartnerModule = Lplus.Extend(ModuleBase, "PartnerModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local PartnerInterface = require("Main.partner.PartnerInterface")
local def = PartnerModule.define
local instance
local GuideUtils = require("Main.Guide.GuideUtils")
def.static("=>", PartnerModule).Instance = function()
  if instance == nil then
    instance = PartnerModule()
    instance.m_moduleId = ModuleId.PARTNER
  end
  return instance
end
def.override().Init = function(self)
  local protocols = require("Main.partner.PartnerProtocols")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SPartnerLogginInfo", protocols.OnSPartnerLogginInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SActivePartnerRep", protocols.OnSActivePartnerRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SChangeDefaultLinupReq", protocols.OnSChangeDefaultLinupReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SChangeZhanWeiRep", protocols.OnSChangeZhanWeiRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SChangeZhenFaReq", protocols.OnSChangeZhenFaReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SPartnerNormalResult", protocols.OnSPartnerNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SReplaceLovesReq", protocols.OnSReplaceLovesReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SShuffleLovesReq", protocols.OnSShuffleLovesReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SSyncPartnerRep", protocols.OnSSyncPartnerRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SImproveYuanShenRep", protocols.OnSImproveYuanShenRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.partner.SSyncSinglePartnerPro", protocols.OnSSyncSinglePartnerPro)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_PARTNER_CLICK, PartnerModule.OnPartnerClick)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PartnerModule.OnLogin)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_OPEN_MY_PARTNER, PartnerModule.OnTeamOpenMyPartner)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Partner_Use, PartnerModule.OnItemPartnerUse)
  Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_ShowLinupTab, PartnerModule.OnPartnerShowLinupTab)
  require("Main.partner.PartnerYuanShenMgr").Instance()
end
def.static("table", "table").OnPartnerClick = function(param1, param2)
  require("Main.partner.ui.PartnerMain").Instance():ShowDlg()
end
def.static("table", "table").OnPartnerShowLinupTab = function(param1, param2)
  local PartnerMain = require("Main.partner.ui.PartnerMain")
  PartnerMain.Instance()._defaultTab = PartnerMain.TabType.Tab_BZ
  PartnerMain.Instance():ShowDlg()
end
def.static("table", "table").OnLogin = function(param1, param2)
  PartnerInterface.Instance():Reset()
  require("Main.partner.PartnerYuanShenMgr").Instance():Reset()
end
def.static("table", "table").OnTeamOpenMyPartner = function(param1, param2)
  require("Main.partner.ui.PartnerMain").Instance():ShowDlg()
  if param1 ~= nil then
    require("Main.partner.ui.PartnerMain").Instance():SetSelected(1)
  end
end
def.static("table", "table").OnItemPartnerUse = function(param1, param2)
  local prop = require("Main.Hero.Interface").GetHeroProp()
  if prop == nil then
    return
  end
  local mylevel = prop.level
  local tengfuchengid = 550200005
  local cfg = GuideUtils.GetFunctionOpenCfg(tengfuchengid)
  if cfg == nil then
    return
  end
  local limitLevel = cfg.level
  if mylevel < limitLevel then
    Toast(string.format(textRes.Partner[22], limitLevel))
    return
  end
  local itemId = param1.itemId
  if itemId then
    require("Main.partner.ui.PartnerMain").Instance():ShowDlgByCostItemId(itemId)
  else
    require("Main.partner.ui.PartnerMain").Instance():ShowDlg()
  end
end
PartnerModule.Commit()
return PartnerModule

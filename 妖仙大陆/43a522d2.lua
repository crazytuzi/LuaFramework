local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"
local GdDepotRq = require 'Zeus.Model.GuildDepot'

local self = {
    menu = nil,
}
local ret = GlobalHooks.DB.Find("WareHouseLevel", {})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function OnEnter()
  self.DepotInfo = GdDepotRq.GetDepotInfo()
  self.myGuildMsg = GDRQ.GetMyGuildInfo()
  local fundnum = self.myGuildMsg.fund
  local Depotlv = self.DepotInfo.level
  local lvstr = string.format(GetTextConfg("guild_DepotUp_lv"),Depotlv)
  self.lb_guildlv.Text = lvstr
  self.lb_costnum.Text = ret[Depotlv].Funds or 0
  if self.myGuildMsg.fund<(ret[Depotlv].Funds or 0) then
    self.lb_costnum.FontColor = GameUtil.RGBA2Color(0xff0000ff)
  else
    self.lb_costnum.FontColor = GameUtil.RGBA2Color(0xe7e5d1ff)
  end
  
  

  local fontColor = 
  {
    bai = 0xffe7e5d1,
    hong = 0xffff0000,
    nv = 0xff00d600,
  }
  local guildlv = self.myGuildMsg.baseInfo.level
  if Depotlv ~= #ret then
    self.lb_tishi1.Text = string.format(GetTextConfg("guild_DepotUp_upnum"),Depotlv,Depotlv+1)
    self.lb_tishi2.Text = string.format(GetTextConfg("guild_DepotUp_upnum2num"),ret[Depotlv].Spece,ret[Depotlv+1].Spece)
    local color1 = guildlv<ret[Depotlv].GLevel and fontColor.hong or fontColor.nv
    local strall = string.format(GetTextConfg("guild_DepotUp_needhalllv"),color1,ret[Depotlv].GLevel)
    self.tb_need.XmlText = strall
    self.tb_need.Visible = true
  else
    self.lb_tishi1.Text = GetTextConfg("guild_DepotUp_maxlv")
    self.lb_tishi2.Text = string.format(GetTextConfg("guild_DepotUp_maxlvnum"),ret[Depotlv].Spece)
    self.tb_need.Visible = false
  end
end

local function OnExit()
  
end

function _M.SetCall(callfunc)
  self.callfunc = callfunc
end

local function initUI()
  self.btn_levelup.TouchClick = function ()
    if self.myGuildMsg.baseInfo.level<ret[self.DepotInfo.level].GLevel then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_DepotUp_halllvshort"))
      return
    end
    GdDepotRq.upgradeDepotRequest(function ()
      OnEnter()
    end)
  end
end

local ui_names = 
{
  
  {name = 'lb_guildlv'},
  {name = 'lb_costnum'},
  
  {name = 'tb_need'},
  {name = 'btn_levelup'},
  {name = 'lb_tishi1'},
  {name = 'lb_tishi2'},
}

local function InitCompnent()
  local closebtn = self.menu:FindChildByEditName("btn_close",true)
  closebtn.TouchClick = function ()
    self.menu:Close()
  end
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_depotup.gui.xml", GlobalHooks.UITAG.GameUIGuildWareHouseUpLv)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  InitCompnent()
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
  self.menu:SubscribOnDestory(function ()
    self = nil
  end)
  return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

return {Create = Create}

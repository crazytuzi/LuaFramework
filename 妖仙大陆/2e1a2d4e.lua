local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"
local GdDepotRq = require 'Zeus.Model.GuildDepot'
local GdPray = require 'Zeus.Model.guildBless'

local self = {
    menu = nil,
}
local ret = GlobalHooks.DB.Find("BlessLevel", {})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function OnEnter()
  self.myPrayInfo = GdPray.GetMyPrayInfo()
  self.myGuildMsg = GDRQ.GetMyGuildInfo()
  local fundnum = self.myGuildMsg.fund
  local Praylv = self.myPrayInfo.guildInfo.level
  local lvstr = string.format(GetTextConfg("guild_PrayUp_praylv"),Praylv)
  self.lb_guildlv.Text = lvstr
  self.lb_costnum.Text = ret[Praylv].Funds or 0
  if self.myGuildMsg.fund<(ret[Praylv].Funds or 0) then
    self.lb_costnum.FontColor = GameUtil.RGBA2Color(0xf43a1cff)
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
  if Praylv ~= #ret then
    self.lb_tishi1.Text = string.format(GetTextConfg("guild_PrayUp_uplvtolv"),Praylv,Praylv+1)
    
      
    
      
    
    local color1 = guildlv<ret[Praylv].GLevel and fontColor.hong or fontColor.nv
    local strall = string.format(GetTextConfg("guild_PrayUp_otherCondition"),color1,ret[Praylv].GLevel)
    self.tb_need.XmlText = strall
    self.tb_need.Visible = true
  else
    self.lb_tishi1.Text = GetTextConfg("guild_PrayUp_maxlv")
    
    self.tb_need.Visible = false
  end
end

local function OnExit()
  
end

function _M.SetCall(callfunc)
  self.callfunc = callfunc
end

local function initUI()
  self.btn_up.TouchClick = function ()
    
    
    
    
    GdPray.upgradeBlessRequest(function (lvnum)
      OnEnter()
      self.callfunc(lvnum)
      EventManager.Fire('Guild.PushChangPray',{})
    end)
  end
end

local ui_names = 
{
  
  {name = 'lb_guildlv'},
  {name = 'lb_costnum'},
  
  {name = 'tb_need'},
  {name = 'btn_up'},
  {name = 'lb_tishi1'},
  
  {name = 'lb_tishi3'},
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
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_qifuup.gui.xml", GlobalHooks.UITAG.GameUIGuildPrayUpLv)
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

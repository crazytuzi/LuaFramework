local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"

local self = {
    menu = nil,
}
local ret = GlobalHooks.DB.Find("GuildLevel", {})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function rushUI()
  local filepath = 'static_n/guild/'..self.myGuildMsg.baseInfo.guildIcon..'.png'
  local layout = XmdsUISystem.CreateLayoutFromFile(filepath, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
  self.ib_icon.Layout = layout

  local guildlv = self.myGuildMsg.baseInfo.level
  local lvstr = string.format(GetTextConfg("guild_GDUP_gdlv"),guildlv)
  self.lb_guildlv.Text = lvstr
  self.lb_costnum.Text = ret[guildlv].exp or 0
  if self.myGuildMsg.exp<(ret[guildlv].exp or 0) then
    self.lb_costnum.FontColor = GameUtil.RGBA2Color(0xf43a1cff)
  else
    self.lb_costnum.FontColor = GameUtil.RGBA2Color(0xe7e5d1ff)
  end
  local expnum = self.myGuildMsg.exp
  self.gg_lv.Value = expnum/(ret[guildlv].exp or 1)*100 > 100 and 100 or (expnum/(ret[guildlv].exp or 1)*100)
  self.gg_lv.Text = expnum.."/"..(ret[guildlv].exp or 1)


  if not ret[guildlv] or not ret[guildlv].building1 then
    ret[guildlv].building1 = 1
    ret[guildlv].building2 = 1
    ret[guildlv].building3 = 1
    ret[guildlv].building4 = 1
  end
  local fontColor = 
  {
    bai = 0xffe7e5d1,
    hong = 0xffff0000,
    nv = 0xff00d600,
  }
  
  self.tb_need.Visible = guildlv ~= #ret
  if guildlv ~= #ret then
    local color1 = self.buildLevel.blessLevel>=ret[guildlv].building1 and fontColor.nv or fontColor.hong
    local str1 =  string.format(GetTextConfg("guild_GDUP_str1"),color1,ret[guildlv].building1)
    local color2 = self.buildLevel.techLevel>=ret[guildlv].building2 and fontColor.nv or fontColor.hong
    local str2 =  string.format(GetTextConfg("guild_GDUP_str2"),color2,ret[guildlv].building2)
    local color3 = self.buildLevel.depotLevel>=ret[guildlv].building3 and fontColor.nv or fontColor.hong
    local str3 =  string.format(GetTextConfg("guild_GDUP_str3"),color3,ret[guildlv].building3)
    local strall = string.format(GetTextConfg("guild_GDUP_strall"),str1,str2,str3,"")
    self.tb_need.XmlText = strall
  end
  
  if guildlv < 10 then
    local nextLvInfo = ret[guildlv+1]
    self.lb_tishi2.Visible = true
    self.lb_tishi3.Visible = true
    self.lb_tishi1.Text = string.format(GetTextConfg("guild_mumber_limit"),nextLvInfo.member)
    self.lb_tishi2.Text = string.format(GetTextConfg("guild_exp_limit"),nextLvInfo.MaxExpDay)
    self.lb_tishi3.Text = string.format(GetTextConfg("guild_funds_mumber"),nextLvInfo.MaxFundsDay)
  else
    self.lb_tishi1.Text = GetTextConfg("guild_lv_max")
    self.lb_tishi2.Visible = false
    self.lb_tishi3.Visible = false
  end
end

local function OnEnter()
  self.myGuildMsg = GDRQ.GetMyGuildInfo()
  GDRQ.getBuildingLevelRequest(function (levelinfo)
    self.buildLevel = levelinfo
    
    rushUI()
  end)
end

local function OnExit()
  
end

function _M.SetCall(callfunc)
  self.callfunc = callfunc
end

local function initUI()
  self.btn_up.TouchClick = function ( ... )
    GDRQ.upgradeGuildLevelRequest(function ( ... )
      self.myGuildMsg = GDRQ.GetMyGuildInfo()
      rushUI()
      self.callfunc()
    end)
  end
end

local ui_names = 
{
  
  {name = 'ib_icon'},
  {name = 'lb_guildlv'},
  {name = 'lb_costnum'},
  {name = 'gg_lv'},
  {name = 'tb_need'},
  {name = 'btn_up'},
  {name = 'tb_num'},
  {name = 'lb_tishi1'},
  {name = 'lb_tishi2'},
  {name = 'lb_tishi3'},
}

local function InitCompnent()
  local closebtn = self.menu:FindChildByEditName("btn_close",true)
  closebtn.TouchClick = function ()
    self.menu:Close()
  end
  
  self.menu.event_PointerClick = function (sender)
    if self and self.menu then
      self.menu:Close()
    end
  end

  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_up.gui.xml", GlobalHooks.UITAG.GameUIGuildUpLv)
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

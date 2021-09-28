local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local CDLabelExt = require "Zeus.Logic.CDLabelExt"

local self = {
    menu = nil,
}

local function Close()
  self.menu:Close()
end

function _M.SetEndInfo(params)
    self.tb_endTips.XmlText = params.info

    local function format(cd,label)
        self.btn_getout.Text = Util.GetText(TextConfig.Type.GUILD, "guild_close_seconds",math.floor(cd))
    end
    print(":  ", params.info)
    self.CDLabelExt = CDLabelExt.New(nil,params.sec,format,Close)
    self.CDLabelExt:start()
end

local function OnEnter()

end

local function OnExit()
    if self.CDLabelExt ~= nil then
        self.CDLabelExt:stop()
        self.CDLabelExt = nil
    end
end

local ui_names = 
{
  
  {name = 'tb_endTips'},
  {name = 'btn_getout'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.btn_getout.TouchClick = function ()
    self.menu:Close()
  end
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/hud/guildBOSS.gui.xml", GlobalHooks.UITAG.GameUIGuildBossEnd)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  self.menu.ShowType = UIShowType.HideBackHud

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

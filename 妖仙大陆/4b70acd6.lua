local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"


local self = {
    menu = nil,
}

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function OnEnter()
  self.myGuildInfo = GDRQ.GetMyGuildInfo()
  self.qqGroupStr = self.myGuildInfo.qqGroup or ""
  self.ti_name.Input.Text = self.qqGroupStr
end

local function OnExit()
  
end

function _M.SetCall(callfunc)
  self.callfunc = callfunc
end

local function initUI()
  
  self.ti_name.Input.contentType = UnityEngine.UI.InputField.ContentType.IntegerNumber
  self.ti_name.Input.Text = ""
  self.ti_name.event_endEdit = function (sender,txt)
    if txt == nil or string.len(txt)==0 then 
      return 
    end
    self.ti_name.Input.Text = tostring(txt)
    self.qqGroupStr = tostring(txt)
    if string.len(txt)>11 then
      local text = Util.GetText(TextConfig.Type.GUILD, "guild_words_toolong")
      GameAlertManager.Instance:ShowNotify(text)
    end
  end

  self.btn_modify.TouchClick = function ()
    local qqstr = self.qqGroupStr
    if string.len(qqstr)<=11 then
      GDRQ.setGuildQQGroupRequest(qqstr,
        function ()
          GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_SetQQ_changesucceed"))
          self.myGuildInfo.qqGroup = qqstr
          self.callfunc(qqstr)
          self.menu:Close()
        end
      )
    end
  end
end

local ui_names = 
{
  
  {name = 'ti_name'},
  {name = 'btn_modify'},
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
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_qun.gui.xml", GlobalHooks.UITAG.GameUIGuildSetQQ)
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

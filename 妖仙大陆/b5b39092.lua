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
  self.extParam = self.menu.ExtParam
  
  
  self.extParam = string.gsub(self.extParam,"<br/>","")
  self.extParam = string.gsub(self.extParam,"<b>","")
  self.extParam = string.gsub(self.extParam,"</b>","")
  self.ti_gonggao.Input.Text = self.extParam
end

local function OnExit()
  self.nottextIsChange = false
end

local function initUI()
  self.btn_up.TouchClick = function ()
    if not self.nottextIsChange then
      self.menu:Close()
      return
    end 
    GDRQ.changeGuildNoticeRequest(self.noticeStr or "",function (noticeStr)
      self.callfuc(noticeStr)
      self.menu:Close()
    end)
  end

  self.ti_gonggao.Input.lineType = UnityEngine.UI.InputField.LineType.MultiLineNewline
  self.ti_gonggao.event_ValueChanged = function (sender,txt)
    if string.utf8len(txt) < 100 then
      self.noticeStr = tostring(txt)
    else
      local text = Util.GetText(TextConfig.Type.GUILD, "guild_words_toolong")
      GameAlertManager.Instance:ShowNotify(text)
    end
    self.nottextIsChange = true
    self.ti_gonggao.Input.Text = self.noticeStr or ""
  end
end

function _M.setCall(callfuc)
   self.callfuc = callfuc
 end 

local ui_names = 
{
  
  {name = 'btn_up'},
  {name = 'ti_gonggao'},
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
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_notice.gui.xml", GlobalHooks.UITAG.GameUIGuildSetNotice)
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

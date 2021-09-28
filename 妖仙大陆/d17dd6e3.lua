local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local DaoyouModel   = require "Zeus.Model.Daoyou"

local self = {
    menu = nil,
}

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.DAOYOU, key)
end

local function OnEnter()
  self.ti_detail.Input.Text = ""
  self.daoqunName = ""
  self.btn_determine.TouchClick = function ()
    local namestr = self.daoqunName or ""
    GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,  
        string.format(GetTextConfg("daoqun_Change_Name"),namestr),
        GetTextConfg("daoqun_Change_NameYes"),
        GetTextConfg("daoqun_Change_NameNo"),
        nil,
        function()
          DaoyouModel.EditDaoqunNameRequest(
            namestr,
            function ()
              self.callfunc(namestr)
              self.menu:Close()
            end)
        end, nil)

  end
end

local function OnExit()

end

function _M.SetCall(callfunc)
  self.callfunc = callfunc
end

local function initUI()
  self.ti_detail.event_endEdit = function (sender,txt)
    if txt == nil then txt = "" end
    if string.utf8len(txt) < 9 then
      self.ti_detail.Input.Text = tostring(txt)
      self.daoqunName = tostring(txt)
    else
      self.ti_detail.Input.Text = self.daoqunName
    end
  end
end

local ui_names = 
{
  
  {name = 'ti_detail'},
  {name = 'btn_determine'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/social/dao_modify.gui.xml", GlobalHooks.UITAG.GameUISocialDaoqunSetName)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  self.menu.mRoot.EnableChildren = true
  self.menu.mRoot.IsInteractive = true
  LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function (sender)
      self.menu:Close()
  end})

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

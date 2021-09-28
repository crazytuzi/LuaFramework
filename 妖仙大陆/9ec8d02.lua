local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"

local function Close(self)
  self.menu:Close()  
end

local ui_names = 
{
  {name = 'btn_close',click = function (self)
    Close(self)
  end},

  {name = 'ti_nim'},
  {name = 'cvs_icon'},
  {name = 'lb_num1'},

  {name = 'bt_quit',click = function (self)
    Pomelo.RoleHandler.changePlayerNameRequest(self.name, self.pos, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ATTRIBUTE,143))
        EventManager.Fire('Event.RenameSuccess', {name = data.s2c_name})
        DataMgr.Instance.UserData.Name = data.s2c_name
        self.menu:Close()
    end)
  end},
}


local function OnEnter(self)
  self.name = ""
  self.ti_nim.Input.Text = ""

  local itemCode = "changename"
  local it = GlobalHooks.DB.Find("Items",itemCode)
  self.lb_num1.Text = it.Name
  local itshow = Util.ShowItemShow(self.cvs_icon,it.Icon,it.Qcolor)
  Util.NormalItemShowTouchClick(itshow,itemCode,false)
end

local function OnExit(self)

end

local function Set(self, param)
  self.pos = param.pos
end

local function InitComponent(self,tag)
  self.menu = LuaMenuU.Create('xmds_ui/common/changename.gui.xml',tag)

  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.ti_nim.Input.characterLimit = 30
  self.ti_nim.Input.contentType = UnityEngine.UI.InputField.ContentType.Standard
  self.ti_nim.event_endEdit = function (sender,txt)
    self.name = txt
  end

  
  
  

  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)

  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)

  self.menu:SubscribOnDestory(function ()

  end)

  local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
  self.menu:SetFullBackground(lrt)
  self.ti_nim.TextSprite.Anchor = TextAnchor.C_C 
end

local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

local function OnShowRoleRename(eventname, params)
  local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleRename,-1)
  obj:Set(params)
end

local function initial()
  EventManager.Subscribe("Event.ShowRoleRename", OnShowRoleRename)
end

_M.Close = Close
_M.Create = Create
_M.initial = initial
_M.Set = Set

return _M

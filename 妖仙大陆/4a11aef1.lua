local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local BloodSoulAPI = require "Zeus.Model.BloodSoul"

local self = {
    menu = nil,
}

local function OnEnter()

end

local function OnExit()

end

local ui_names = 
{
  
    {name = 'sp_content_bag'},
    {name = 'cvs_cell'},

    {name = 'lb_num'},
    {name = 'btn_arrange'},
    
}

local function InitCompnent()
    Util.CreateHZUICompsTable(self.menu,ui_names,self)
    
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/bloodsoul/bloodsmelt.gui.xml", GlobalHooks.UITAG.GameUIBloodSmelt)
    self.menu.Enable = false
    self.menu.mRoot.Enable = false
    self.menu.ShowType = UIShowType.Cover
  
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

local _M = {}
_M.__index = _M

local Util          = require "Zeus.Logic.Util"
local MountModel        = require "Zeus.Model.Mount"

local self = {
	menu = nil,
}

local function OnClickClose(displayNode)
	if self ~= nil and self.menu ~= nil then
		self.menu:Close()
	end
end

local function SwitchPage(sender)
	self.menu:RemoveAllSubMenu()

	local tag = GlobalHooks.UITAG.GameUIRideTrain
	if sender == self.tbt_skin then
		tag = GlobalHooks.UITAG.GameUIRideSkin
    end
    
    local node,lua_obj = GlobalHooks.CreateUI(tag,0)
    self.menu:AddSubMenu(node)
end

local function OnExit()
	self.menu:RemoveAllSubMenu()
end

local function OnEnter()	
	Util.InitMultiToggleButton(function (sender)
      SwitchPage(sender)
    end,self.tbt_culture,{self.tbt_culture,self.tbt_skin})
end

local function InitUI()
	local UIName = {
        "btn_close",
        "tbt_culture",
        "tbt_skin",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

local function InitCompnent(params)
	InitUI()

	self.btn_close.TouchClick = OnClickClose

	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
	self.menu = LuaMenuU.Create("xmds_ui/ride/frame.gui.xml", GlobalHooks.UITAG.GameUIRideMain)
	
    self.menu.ShowType = UIShowType.HideBackHud
	InitCompnent(params)
	return self.menu
end

local function Create(params)
	setmetatable(self, _M)
	local node = Init(params)
	return self
end


local function initial()
	EventManager.Subscribe("Event.Menu.CloseFuncEntryMenu", OnClickClose)
end

return {Create = Create, initial = initial}

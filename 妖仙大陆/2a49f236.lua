local _M = {}
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local Hangup           = require 'Zeus.UI.XmasterSet.SetUIHangup'
local System       = require 'Zeus.UI.XmasterSet.SetUISystem'
local self = {}

local function InitUI()
    local UIName = {
    	"btn_close",
        "tbt_hangup",
		"tbt_system",

        "cvs_content",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end


local function SwitchPage(sender)
	if sender == self.tbt_hangup then
		self.hangup:setVisible(true)
		self.system:setVisible(false)
	else
		self.hangup:setVisible(false)
		self.system:setVisible(true)
	end
end

local function OnEnter()
	self.hangup:OnEnter()
	self.system:OnEnter()
	Util.InitMultiToggleButton(function (sender)
      	SwitchPage(sender)
    end,self.tbt_hangup,{self.tbt_hangup,self.tbt_system})
end

local function OnExit()
	self.hangup:OnExit()
	self.system:OnExit()
end


local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/set/background.gui.xml',tag)
    self.menu.ShowType = UIShowType.HideBackHud
    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu:SubscribOnDestory(function()
        
    end)

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end

    self.hangup = Hangup.Create(GlobalHooks.UITAG.GameUISetHangup,self.cvs_content)
    self.hangup:setVisible(false)
    self.system = System.Create(GlobalHooks.UITAG.GameUISetSystem,self.cvs_content)
    self.system:setVisible(false)

    return self.menu
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}

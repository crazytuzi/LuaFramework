local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local Reward = require 'Zeus.UI.XmasterArena.ArenaUIReward'


local self = {}

local function InitUI()
    local UIName = {
    	"btn_close",
        "cvs_content",

        "tbt_reward",
        "tbt_ranking",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end


local function SwitchPage(sender)
    
        
        
        
        
        
        
        

    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
end

local function OnEnter()
	if self.reward == nil then
        self.reward = Reward.Create(GlobalHooks.UITAG.GameUIMultiPvp)
        self.cvs_content:AddChild(self.reward.menu)
        self.reward:OnEnter()
    else
        self.reward.menu.Visible = true
    end
end

local function OnExit()
    if self.reward~=nil then
        self.reward:OnExit()
        self.reward = nil
    end

    
    
    
    
    self.cvs_content:RemoveAllChildren(true)
end


local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/arena/jjc_main.gui.xml',tag)
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



    
    
    
    
    
    

    
    
    

    return self.menu
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}

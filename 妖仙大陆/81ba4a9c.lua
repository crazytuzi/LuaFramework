local _M = {}
_M.__index = _M


local Util          = require "Zeus.Logic.Util"

local self = {
    m_Root = nil,
}

local function OnEnter()

end

local function OnExit()

end

local function InitCompnent()
        local UIName = {
        "ib_explain",
        "btn_invite",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end

    
    self.btn_invite.TouchClick = function ()
      GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialDaoyouInvite,0)
    end

    self.m_Root:SubscribOnEnter(OnEnter)
    self.m_Root:SubscribOnExit(OnExit)
    self.m_Root:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
    self.m_Root = LuaMenuU.Create("xmds_ui/social/daoyou.gui.xml", GlobalHooks.UITAG.GameUISocialDaoqunBuild)
    self.menu = self.m_Root
    self.menu.Enable = false
    InitCompnent()
    return self.m_Root
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end


return {Create = Create}

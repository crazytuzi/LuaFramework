local _M = {}
_M.__index = _M

local Util              = require "Zeus.Logic.Util"
local Relive            = require "Zeus.Model.Relive"

local self = {
  menu = nil,
}

local function OnExit()

end

local function SetCallback(payConfirm)
    Relive.RequestRelive(1,payConfirm,function()
    end)
end

local function OnEnter()
    self.lb_proname2.Text = Relive.ReliveData.costStr

    self.tbn_gou.IsChecked = false

    self.bt_yes.TouchClick = function ()
        if self.tbn_gou.IsChecked == true then
            SetCallback(1)
        else
            SetCallback(0)
        end
        self.menu:Close()
    end

    self.bt_no.TouchClick = function ()
        self.menu:Close()
    end
end

local function InitCompnent()
    local UIName = {
        "lb_proname2",
        "tbn_gou",
        "bt_no",
        "bt_yes",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/common/common_tips.gui.xml", GlobalHooks.UITAG.GameUIDeadCommonTips)
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)

    InitCompnent()
    return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return node
end

local function OnActorRebirth(...)
    if self and self.menu then
        self.menu:Close()
    end
end

local function initial()
end

return {Create = Create, initial = initial}

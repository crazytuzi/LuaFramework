local _M = {}
_M.__index = _M


local Util          = require "Zeus.Logic.Util"
local FriendModel   = require 'Zeus.Model.Friend'
local DaoyouModel   = require "Zeus.Model.Daoyou"

local self = {
    menu = nil,
}

local function OnClickClose(displayNode)
    if self ~= nil and self.menu ~= nil then
        self.menu:Close()
    end
end

local function addNewMenu(node)
    if node then
        self.menu:AddSubMenu(node)
        if self.curMenu then
            self.menu:RemoveSubMenu(self.curMenu)
        end
        self.curMenu = node
    end
end

local function SwitchPage(sender)
    local node
    local lua_obj
    if sender == self.tbt_haoyou then
        node,lua_obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUISocialFriend,0)
        addNewMenu(node)
    elseif sender == self.tbt_jieyi then
        DaoyouModel.ReqDaoqunInfo(function (data)
            local tag = GlobalHooks.UITAG.GameUISocialDaoqunBuild
            if data and data.isHasDaoYou == 1 then
                tag = GlobalHooks.UITAG.GameUISocialDaoqun
            end
            node,lua_obj = GlobalHooks.CreateUI(tag,0)
            addNewMenu(node)
        end)
    elseif sender == self.tbt_jiehun then
        node,lua_obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUISocialLover,0)
        addNewMenu(node)
    end
end

local function OnExit()
    self.menu:RemoveAllSubMenu()
    self.curMenu = nil
end

local function OnEnter()
    Util.InitMultiToggleButton(function (sender)
      SwitchPage(sender)
    end,nil,{self.tbt_haoyou,self.tbt_jieyi,self.tbt_jiehun})

    if self.menu.ExtParam then
        local childTag = tonumber(self.menu.ExtParam)
        if childTag == GlobalHooks.UITAG.GameUISocialFriend then
            self.tbt_haoyou.IsChecked = true
        elseif childTag == GlobalHooks.UITAG.GameUISocialDaoqun then
            self.tbt_jieyi.IsChecked = true
        elseif childTag == GlobalHooks.UITAG.GameUISocialLover then
            self.tbt_jiehun.IsChecked = true
        else
            self.tbt_haoyou.IsChecked = true
        end
    else
        self.tbt_haoyou.IsChecked = true
    end

    self.tbt_jieyi.Visible = GlobalHooks.CheckFuncOpenByTag(GlobalHooks.UITAG.GameUISocialDaoqun, false)
end

local function InitUI()
    local UIName = {
        "btn_close",
        "tbt_haoyou",
        "tbt_jieyi",
        "tbt_jiehun",

        "lb_bj_haoyou",
        "lb_bj_jieyi",
        "lb_bj_jiehun",
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
    self.menu = LuaMenuU.Create("xmds_ui/social/main.gui.xml", GlobalHooks.UITAG.GameUISocialMain)
    
    self.menu.Enable = true
    self.menu.mRoot.Enable = true
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
    
end

return {Create = Create, initial = initial}

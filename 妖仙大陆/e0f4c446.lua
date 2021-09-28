local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local FubenAPI = require "Zeus.Model.Fuben"
local FubenUtil = require "Zeus.UI.XmasterFuben.FubenUtil"


local self = {
    menu = nil,
}

local function OpenSecondResUI(idx)
    local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIResFubenSecondUI, 0)
    lua_obj.SetResFubenInfo(self.FubelList[idx])
    self.menu:Close()
end

local function RefreshFubenItem(gx, gy, node)
    local idx = gy + 1
    node.UserTag = idx
    node:FindChildByEditName("btn_go", true).UserTag = idx
    local info = FubenAPI.getResFubenInfoById(self.FubelList[idx].dungeonId)
    node:FindChildByEditName("lb_name", true).Text = info.Name
    node:FindChildByEditName("lb_times", true).Text = self.FubelList[idx].lastTimes

    local ib_mappic = node:FindChildByEditName("ib_mappic",true)
    Util.HZSetImage(ib_mappic, "dynamic_n/dungeonsbanner/" .. info.MapPic .. ".png",false,LayoutStyle.IMAGE_STYLE_BACK_4)

    local ib_bosspic = node:FindChildByEditName("ib_bosspic",true)
    Util.HZSetImage(ib_bosspic, "dynamic_n/dungeonsbanner/" .. info.BossPic .. ".png",false,LayoutStyle.IMAGE_STYLE_BACK_4)
end

local function InitFubenCanAndData(node)
    node.Visible = true
    local btn_go = node:FindChildByEditName("btn_go", true)
    btn_go.TouchClick = function(sender)
        OpenSecondResUI(sender.UserTag)
    end
end

local function OnExit()

end

local function OnEnter()
    FubenAPI.reqResFubenInfo(function(data)
        self.FubelList = data
        local rows = #self.FubelList
        self.sp_detail:Initialize(self.cvs_single.Width, self.cvs_single.Height+10, rows, 1, self.cvs_single, 
        LuaUIBinding.HZScrollPanUpdateHandler(RefreshFubenItem), 
        LuaUIBinding.HZTrusteeshipChildInit(InitFubenCanAndData))
        if self.menu.ExtParam ~= nil then
            local index = tonumber(self.menu.ExtParam)
            if index and index > 0 then
                OpenSecondResUI(index)
            end
        end
    end)
end


local function InitUI()
    local UIName = {
        "btn_close",
        "sp_detail",
        "cvs_single",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.cvs_single.Visible = false

    self.btn_close.TouchClick = function(sender)
        self.menu:Close()
    end
end

local function InitCompnent(params)
    InitUI()

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/res/res_choice.gui.xml", GlobalHooks.UITAG.GameUIResFubenUI)
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

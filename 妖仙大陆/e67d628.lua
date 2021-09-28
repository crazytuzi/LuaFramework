local _M = {}
_M.__index = _M


local cjson             = require "cjson"
local Util              = require 'Zeus.Logic.Util'
local FriendModel       = require 'Zeus.Model.Friend'

local SocialUtil        = require "Zeus.UI.XmasterSocial.SocialUtil"
local ActivityUtil      = require "Zeus.UI.XmasterActivity.ActivityUtil"

local self = {
    menu = nil,
}

local function OnClickClose(displayNode)
    
    self.menu:Close()
end

local function OnClickDeleteFriend()
    FriendModel.friendRefuceApplyRequest(id, function(params)
        OnClickClose()
    end)
end

local function OnClickBlacklistFriend()
    FriendModel.friendRefuceApplyRequest(id, function(params)
        OnClickClose()
    end)
end

local function OnClickTeamInvitateFriend()
    FriendModel.friendRefuceApplyRequest(id, function(params)
        OnClickClose()
    end)
end

local function OnClickGuildInvitateFriend()
    FriendModel.friendRefuceApplyRequest(id, function(params)
        OnClickClose()
    end)
end

local function OnClickReportFriend()
    
end

local function  OnClickPresentFriend()
    
    OnClickClose()
end


function _M.FillFriendData(data)
    if (data ~= nil) then
        self.friendData = data
        
    end
end

local function OnEnter()
    self.friendData = nil
end

local function InitUI()
    
    local UIName = {
        "lb_name",
        "ib_head",
        "lb_level",
        "btn_accept_all",

        "lb_ID",
        "lb_xm_name",
        "lb_Glv",

        "btn_delete",
        "btn_blacklist",
        "btn_team",
        "btn_xm",
        "btn_report",
        "btn_present",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

local function InitCompnent()
    
    InitUI()

    self.refreshInterval = ActivityUtil.ParametersValue("Social.FriendRefresh")

    self.btn_delete.TouchClick = OnClickDeleteFriend
    self.btn_blacklist.TouchClick = OnClickBlacklistFriend
    self.btn_team.TouchClick = OnClickTeamInvitateFriend
    self.btn_xm.TouchClick = OnClickGuildInvitateFriend
    self.btn_report.TouchClick = OnClickReportFriend
    self.btn_present.TouchClick = OnClickPresentFriend


    local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    self.menu:SetFullBackground(lrt)

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
    self.menu = LuaMenuU.Create("xmds_ui/social/friend_interective.gui.xml", GlobalHooks.UITAG.GameUISocialFriendOprate)
    InitCompnent()
    
    return self.menu
end

function _M.Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end



return _M

local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local Dekaron = require 'Zeus.UI.XmasterSolo.SoloDekaron'
local Reward = require 'Zeus.UI.XmasterSolo.SoloReward'
local Rank = require 'Zeus.UI.XmasterSolo.SoloRank'
local News = require 'Zeus.UI.XmasterSolo.SoloNews'
local SoloAPI = require "Zeus.Model.Solo"

local self = {}

local function InitUI()
    local UIName = {
    	"btn_close",
        "cvs_main",

        "tbt_dekaron",
        "tbt_reward",
        "tbt_rank",
        "tbt_news",

        "ib_redpoint",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end


local function SwitchPage(sender)
    if self.showView ~= nil then
        self.showView.Visible = false
    end
    local  ui = self.uiList[sender.EditName]
    local node = self.nodeList[sender.EditName]

    if ui== nil or node == nil then
        return
    end

    if ui.isLoad then

    else
        ui:OnEnter()
        ui.isLoad = true
    end
    self.showView = node
    node.Visible = true
end

local function OnEnter()
    local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUISoloMatchOk)

    if obj ~= nil then
        self.menu:Close()
        obj:setVisible(true)
        return
    end

    self.uiList = {}
    self.nodeList = {}

    local dekaron,dekaronNode = Dekaron.Create()
    self.cvs_main:AddChild(dekaronNode)
    dekaron.isLoad = false
    dekaronNode.Visible = false
    self.uiList['tbt_dekaron'] = dekaron
    self.nodeList['tbt_dekaron'] = dekaronNode

    local reward,rewardNode = Reward.Create()
    self.cvs_main:AddChild(rewardNode)
    reward.isLoad = false
    rewardNode.Visible = false
    self.uiList['tbt_reward'] = reward
    self.nodeList['tbt_reward'] = rewardNode

    local rank,rankNode = Rank.Create()
    self.cvs_main:AddChild(rankNode)
    rank.isLoad = false
    rankNode.Visible = false
    self.uiList['tbt_rank'] = rank
    self.nodeList['tbt_rank'] = rankNode

    local news,newsNode = News.Create()
    self.cvs_main:AddChild(newsNode)
    news.isLoad = false
    newsNode.Visible = false
    self.uiList['tbt_news'] = news
    self.nodeList['tbt_news'] = newsNode
    
	Util.InitMultiToggleButton(function (sender)
      	SwitchPage(sender)
    end,self.tbt_dekaron,{self.tbt_dekaron,self.tbt_reward,self.tbt_rank,self.tbt_news})

    self.ib_redpoint.Visible = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_SOLO_REWARD) ~=0

    DataMgr.Instance.FlagPushData:AttachLuaObserver(GlobalHooks.UITAG.GameUISolo, {Notify = function(status, flagdate)
        if status == FlagPushData.FLAG_SOLO_REWARD then
            self.ib_redpoint.Visible = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_SOLO_REWARD) ~=0
        end      
    end})
end

local function OnExit()
    SoloAPI.clearCache()
    if self.uiList ~= nil then
        for _,v in pairs(self.uiList) do
            v:OnExit()
        end
        self.uiList = nil
        self.nodeList = nil
    end
    DataMgr.Instance.FlagPushData:DetachLuaObserver(GlobalHooks.UITAG.GameUISolo)
end


local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/solo/frame.gui.xml',tag)
    self.menu.ShowType = UIShowType.HideBackMenu
    
    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.uiList = {}
    self.nodeList = {}
    self.menu:SubscribOnDestory(function()
        self.uiList = nil
        self.nodeList = nil
    end)

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end

    return self.menu
end

function _M:getMyInfo()
    if self.uiList['tbt_dekaron'] == nil then
        return nil
    end
    return self.uiList['tbt_dekaron']:getMyInfo()
end

function _M:setWaitTime(avgMatchTime,startJoinTime)
    if self.uiList['tbt_dekaron'] == nil then
        return nil
    end
    return self.uiList['tbt_dekaron']:setWaitTime(avgMatchTime,startJoinTime)
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}

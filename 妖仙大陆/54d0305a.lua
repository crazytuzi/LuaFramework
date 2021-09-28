local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local _5V5Api = require 'Zeus.Model.5v5'
local SignUp = require 'Zeus.UI.Xmaster5V5.5V5UISignUp'
local Reward = require 'Zeus.UI.Xmaster5V5.5V5UIReward'

local self = {}

local function InitUI()
    local UIName = {
    	"btn_close",
        "cvs_main",

        "tbt_sign",
        "tbt_reward",
        "lb_bj_reward",

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
        ui:OnEnter(self.data)
        ui.isLoad = true
    end
    self.showView = node
    node.Visible = true
end

local function OnEnter()
    self.menu.Visible = false
    _5V5Api.request5v5Info(function(data)
        self.menu.Visible = true
        self.data = data

        self.uiList = {}
        self.nodeList = {}

        local signup,signupNode = SignUp.Create()
        self.cvs_main:AddChild(signupNode)
        signup.isLoad = false
        signupNode.Visible = false
        self.uiList['tbt_sign'] = signup
        self.nodeList['tbt_sign'] = signupNode

        local reward,rewardNode = Reward.Create()
        self.cvs_main:AddChild(rewardNode)
        reward.isLoad = false
        rewardNode.Visible = false
        self.uiList['tbt_reward'] = reward
        self.nodeList['tbt_reward'] = rewardNode

        Util.InitMultiToggleButton(function (sender)
            SwitchPage(sender)
        end,self.tbt_sign,{self.tbt_sign,self.tbt_reward})

        self.lb_bj_reward.Visible = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_5V5_REWARD) ~=0

        DataMgr.Instance.FlagPushData:AttachLuaObserver(GlobalHooks.UITAG.GameUI5V5Main, {Notify = function(status, flagdate)
            if status == FlagPushData.FLAG_5V5_REWARD then
                self.lb_bj_reward.Visible = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_5V5_REWARD) ~=0
            end      
        end})

    end)
end


local function OnExit()
    for _,v in pairs(self.uiList) do
        v:OnExit()
    end
    self.uiList = nil
    self.nodeList = nil
    DataMgr.Instance.FlagPushData:DetachLuaObserver(GlobalHooks.UITAG.GameUI5V5Main)
end

function _M:matchStop()
    if self.uiList['tbt_sign'] then
        self.uiList['tbt_sign']:matchStop()
    end
end

function _M:reMatch(matchTime, beginTime)
    if self.uiList['tbt_sign'] then
        self.uiList['tbt_sign']:reMatch(matchTime, beginTime)
    end
end

function _M:waitNum(num)
    if self.uiList['tbt_sign'] then
        self.uiList['tbt_sign']:waitNum(num)
    end
end

local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/5v5/5v5_main.gui.xml',tag)
    
    
    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

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


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}

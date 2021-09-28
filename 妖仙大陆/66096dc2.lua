local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local Fate  = require 'Zeus.UI.XmasterActivity.ActivityUIFate'
local Boss  = require 'Zeus.UI.XmasterActivity.ActivityUIBoss'
local Activity  = require 'Zeus.UI.XmasterActivity.ActivityUIActivity'
local self = {}

local function InitUI()
    local UIName = {
    	"btn_close",
        "cvs_main",
        "tbt_activity",
        "tbt_lords",
        "tbt_xianyuan",
        "tbt_fuben",
        "tbt_jixianfuben",
        "lb_title_1",
        "lb_title_2",
        "lb_title_3",
        "lb_title_4",
        "lb_title_5",
        "lb_bj_activity",
        "lb_bj_lords",
        "lb_bj_xianyuan",
        "lb_bj_fuben",
        "lb_bj_jixianfuben",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end


local function SwitchPage(sender)
    if self.showView ~= nil then
        self.showView.Visible = false
    end

    if sender == self.tbt_xianyuan then
        if self.fate.isLoad then

        else
            self.fate:OnEnter()
            self.fate.isLoad = true
        end
        
        self.showView = self.fateNode

    elseif sender == self.tbt_lords then     
        self.boss:OnEnter() 
        self.showView = self.bossNode

    elseif sender == self.tbt_activity then     
        self.activity:OnEnter() 
        self.showView = self.activityNode
    end

    if sender == self.tbt_fuben then     
        local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFuben, 0)
        obj.SetVisible(true)
        self.showView = nil
    else
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIFuben, 0)
    end

    if sender == self.tbt_jixianfuben then     
        local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFubenLimit, 0)
        obj.SetVisible(true)
        self.showView = nil
    else
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIFubenLimit, 0)
    end

    if self.showView ~= nil then
        self.showView.Visible = true
    end
     self.lb_title_1.Visible = (sender == self.tbt_activity)
     self.lb_title_2.Visible = (sender == self.tbt_lords)
     self.lb_title_3.Visible = (sender == self.tbt_xianyuan)
     self.lb_title_4.Visible = (sender == self.tbt_fuben)
     self.lb_title_5.Visible = (sender == self.tbt_jixianfuben)
end

local function InitRedPoint()
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_ACIVITY)
    self.lb_bj_activity.Visible = (num ~= nil and num > 0)

    num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_BOSS)
    self.lb_bj_lords.Visible = (num ~= nil and num > 0)

    num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_FATE)
    self.lb_bj_xianyuan.Visible = (num ~= nil and num > 0)

    num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_DUNGEON_SUPPER)
    self.lb_bj_fuben.Visible = (num ~= nil and num > 0)
end

local function SwitchChildMenu(param)
    if string.empty(param) then
        self.tbt_activity.IsChecked = true
    elseif param == "Activity" then
        self.tbt_activity.IsChecked = true
    elseif param == "Lingzhu" then
        self.tbt_lords.IsChecked = true
    elseif param == "Xianyuan" then
        self.tbt_xianyuan.IsChecked = true
    elseif param == "Dungeons" then
        self.tbt_fuben.IsChecked = true
    elseif param == "UltimateDungeons" then
        self.tbt_jixianfuben.IsChecked = true
    end
end

local function OnEnter()
	Util.InitMultiToggleButton(function (sender)
      	SwitchPage(sender)
    end,nil,{self.tbt_activity,self.tbt_lords,self.tbt_xianyuan,self.tbt_fuben,self.tbt_jixianfuben})
    DataMgr.Instance.FlagPushData:AttachLuaObserver(self.menu.Tag, self)

    SwitchChildMenu(self.menu.ExtParam)

    InitRedPoint()
end

local function OnExit()
	self.showView = nil

    self.fate:OnExit()
    self.boss:OnExit()
    self.activity:OnExit()
    DataMgr.Instance.FlagPushData:DetachLuaObserver(self.menu.Tag)
end

local function OnUpdateRedPoint(self,status)
    if status == FlagPushData.FLAG_ACTIVITY_ACIVITY then 
        local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_ACIVITY)
        self.lb_bj_activity.Visible = (num ~= nil and num > 0)
    elseif status == FlagPushData.FLAG_ACTIVITY_BOSS then  
        local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_BOSS)
        self.lb_bj_lords.Visible = (num ~= nil and num > 0)
    elseif status == FlagPushData.FLAG_ACTIVITY_FATE then  
        local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_FATE)
        self.lb_bj_xianyuan.Visible = (num ~= nil and num > 0)
    elseif status == FlagPushData.FLAG_DUNGEON_SUPPER then  
        local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_DUNGEON_SUPPER)
        self.lb_bj_fuben.Visible = (num ~= nil and num > 0)
    end

    
    
    
    
    
    
    

    
    
    
    
    
    
end

local function SetVisible(bool)
    if self ~= nil and self.menu ~= nil then
        self.menu.Visible = bool
    end
end

function _M.Notify(status, flagData)
    
    if self ~= nil and self.menu ~= nil then
        OnUpdateRedPoint(self,status)
    end
end

local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/activity/background.gui.xml',tag)
    self.menu.ShowType = UIShowType.HideBackHud
    
    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu:SubscribOnDestory(function()
        
    end)

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
            GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIFuben, 0)
            GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIFubenLimit, 0)
        	self.menu:Close()
    	end
    end

    self.fate,self.fateNode = Fate.Create()
    self.cvs_main:AddChild(self.fateNode)
    self.fate.isLoad = false
    self.fateNode.Visible = false

    self.boss,self.bossNode = Boss.Create()
    self.cvs_main:AddChild(self.bossNode)
    self.boss.isLoad = false
    self.bossNode.Visible = false

    self.activity,self.activityNode = Activity.Create()
    self.cvs_main:AddChild(self.activityNode)
    self.activity.isLoad = false
    self.activityNode.Visible = false

    return self.menu
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

_M.SetVisible = SetVisible
_M.SwitchChildMenu = SwitchChildMenu

return {Create = Create}

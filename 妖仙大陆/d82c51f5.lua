local _M = { }
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local _5V5Api = require 'Zeus.Model.5v5'
local ServerTime = require "Zeus.Logic.ServerTime"
local Leaderboard = require "Zeus.Model.Leaderboard"

local self = {}

local function onTimerUpdate(dt)
    local nowTime = ServerTime.GetServerUnixTime()
    local time = nowTime - self.beginTime
    if time < 0 then
        time = 0
    end
    self.lb_wait.Text = ServerTime.FormatCD(time)

end

local function setJoinTime(matchTime, beginTime)
    
    self.tbt_matching.Enable = true
    self.tbt_matching.IsChecked = true
    self:checkEnterEffect()
    self.tbt_matching.Text = Util.GetText(TextConfig.Type.SOLO,"cancelMatch")
    if matchTime == -1 then return end

    self.cvs_time.Visible = true
    if matchTime < 0 then
        matchTime = 30
    end
    self.lb_estimate.Text = ServerTime.FormatCD(matchTime)

    if beginTime <= 0 then
        beginTime = ServerTime.GetServerUnixTime()
    end
    self.beginTime = beginTime
    self.timer:Start()
    onTimerUpdate(0)
    EventManager.Fire("Event.Hud.showPvpWait",{startTime = beginTime})
end

function _M:reMatch(matchTime, beginTime)
    setJoinTime(matchTime, beginTime)
end

function _M:checkEnterEffect()
     local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_5V5_ENTER)
    if num ~= 0  and not self.tbt_matching.IsChecked then
        Util.showUIEffect(self.tbt_matching,55)
    else
        Util.clearUIEffect(self.tbt_matching,55)
    end
end

function _M:OnEnter(data)
    
    if data.firstRankInfo == nil then
        self.cvs_player.Visible = false
        self.lb_phantom.Visible = true
    else
        self.cvs_player.Visible = true
        self.lb_phantom.Visible = false

        Util.SetHeadImgByPro(self.ib_head,data.firstRankInfo.pro)
        self.lb_name.Text = data.firstRankInfo.playerName
        self.lb_point.Text = data.firstRankInfo.score
    end

    self.lb_mypoint.Text = data.score
    self.lb_rank.Text = data.rank
    self.lb_winnum.Text = data.win
    self.lb_losenum.Text = data.fail
    self.lb_flatnum.Text = data.tie
    local allnum = data.win + data.fail + data.tie
    local winRate = allnum == 0 and 0 or data.win / allnum
    self.lb_odds.Text =  string.format("%.2f", winRate*100) .. '%'
    self.lb_mvp.Text = data.mvp

    local joinTime = _5V5Api.getJoinTime()
    if joinTime~=nil then
        setJoinTime(joinTime.avgWaitTime,joinTime.matchTime)
    end
    if data.matchPeople then
        self.lb_waitNum.Text = data.matchPeople
    end

    self:checkEnterEffect()

    DataMgr.Instance.FlagPushData:AttachLuaObserver(GlobalHooks.UITAG.GameUI5V5Main+1, {Notify = function(status, flagdate)
        if status == FlagPushData.FLAG_5V5_ENTER then
            self:checkEnterEffect()
        end      
    end})
end

function _M:OnExit()
    DataMgr.Instance.FlagPushData:DetachLuaObserver(GlobalHooks.UITAG.GameUI5V5Main+1)
    self.timer:Stop()
end

function _M:matchStop()
    self.tbt_matching.Text = Util.GetText(TextConfig.Type.SOLO,"match")
    self.tbt_matching.Enable = true
    self.timer:Stop()
    self.cvs_time.Visible = false
    self.tbt_matching.IsChecked = false
    self:checkEnterEffect()
end

function _M:waitNum(num)
    self.lb_waitNum.Text = num
end

local ui_names = 
{
    {name = 'ib_bg'}, 
    {name = 'cvs_player'}, 
    {name = 'lb_phantom'}, 
    {name = 'ib_head'},    
    {name = 'lb_name'},    
    {name = 'lb_point'},   
    {name = 'tb_rule'},
    {name = 'lb_mypoint'},  
    {name = 'lb_rank'},     
    {name = 'lb_winnum'},   
    {name = 'lb_losenum'},   
    {name = 'lb_flatnum'},   
    {name = 'lb_odds'},     
    {name = 'lb_mvp'},      
    {name = 'cvs_time'},    
    {name = 'lb_estimate'},  
    {name = 'lb_wait'},      
    {name = 'lb_waitNum'},   
    {name = 'btn_look',click = function(self)
        local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUI5V5Record)   
        
        
    end},     
    {name = 'tbt_matching'}, 
    {name = 'btn_paihang',click = function(self)
        
        MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUILeaderboard,0,Leaderboard.LBType.ARENA_5V5)
    end}
}

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.event_PointerClick = function()
                ui.click(tbl)
            	end
        	end
    	end
	end
end

local function InitComponent(self)
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/5v5/5v5_signup.gui.xml')
    initControls(self.menu,ui_names,self)
    
    self.tbt_matching.IsChecked = false
    self.tbt_matching.Text = Util.GetText(TextConfig.Type.SOLO,"match")
    self.timer = Timer.New(onTimerUpdate, 1, -1)
    self.cvs_time.Visible = false
    self.tbt_matching.Enable = true

    self.tb_rule.XmlText = Util.GetText(TextConfig.Type.SOLO, "5v5Rule")
    self.tb_rule.Scrollable = true

    self.tbt_matching.TouchClick = function(send)
        if self.tbt_matching.IsChecked then
             local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5WaitEnter)
              if obj then
                self.tbt_matching.IsChecked = false
                menu.Visible = true
                return
              end

            _5V5Api.requestMatch(1,function (data)
                if data ~= nil then
                    setJoinTime(data.avgWaitTime,data.matchTime)
                else
                    
                    
                    
                end
                self:checkEnterEffect()
            end,
            function ()
                 
                self.tbt_matching.Enable = true
                self.tbt_matching.IsChecked = false
                self:checkEnterEffect()
                self.tbt_matching.Text = Util.GetText(TextConfig.Type.SOLO,"match")
            end)
        else
            self.tbt_matching.IsChecked = true
            self:checkEnterEffect()
            _5V5Api.requestCancleMatch(function() 
                self:matchStop()
                end)
        end
    end



    return self.menu
end

function _M.Create()
    setmetatable(self,_M)
    local node = InitComponent(self)
    return self,node
end

return _M

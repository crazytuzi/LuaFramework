local _M = { }
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local SoloAPI = require "Zeus.Model.Solo"
local Leaderboard = require "Zeus.Model.Leaderboard"
local ServerTime = require "Zeus.Logic.ServerTime"

local self = {}

local function ToCountDownSecond(endTime)
    if endTime == nil then
        return
    end
    local passTime = math.floor(endTime/1000-ServerTime.GetServerUnixTime())

    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    return Util.GetText(TextConfig.Type.SOLO,"endSeason",ServerTime.GetCDStrCut2(passTime))
end

local function onTimerUpdate(dt)
     local nowTime = ServerTime.GetServerUnixTime()
    
    
    

    
    
    
    
    

    
    local time = nowTime - self.beginTime
    if time < 0 then
        time = 0
    end
    self.lb_wait.Text = ServerTime.FormatCD(time)

end

local function setJoinTime(matchTime, beginTime)
    self.tbt_start.Enable = true
    self.tbt_start.Text = Util.GetText(TextConfig.Type.SOLO,"cancelMatch")
    if matchTime == -1 then return end

    self.cvs_tips.Visible = true
    EventManager.Fire("Event.Hud.show1v1Wait",{})
    
    self.lb_open.Visible = false
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
    self:checkEnterEffect()
end

function _M.Notify(status, userdata, self)
    if userdata:ContainsKey(status, UserData.NotiFyStatus.SOLOPOINT) then
        self.lb_nownum.Text = userdata:TryToGetLongAttribute(UserData.NotiFyStatus.SOLOPOINT,0)
    end
end

function _M:checkEnterEffect()
     local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_SOLO)
    if num ~= 0  and not self.tbt_start.IsChecked then
        Util.showUIEffect(self.tbt_start,55)
    else
        Util.clearUIEffect(self.tbt_start,55)
    end
end

function _M:OnEnter()
    self.tbt_start.IsChecked = false
    self.tbt_start.Text = Util.GetText(TextConfig.Type.SOLO,"match")
    self.tbt_start.Enable = true
    self.cvs_tips.Visible = false
    self.lb_open.Visible = true
    self.menu.Visible = false

    self.timeList = SoloAPI.getTimeList() or {}
    SoloAPI.requestSoloInfo(function(myInfo, soloMessages)
        self.menu.Visible = true
        self.myInfo = myInfo
        
        self.lb_nowrank.Text = myInfo.rank
        self.lb_now.Text = myInfo.score
        self.lb_times1.Text = myInfo.battleTimes
        self.lb_times2.Text = myInfo.winTotalTimes
        self.lb_times3.Text = myInfo.loseTotalTimes
        self.lb_times5.Text = myInfo.battleTimes - (myInfo.winTotalTimes + myInfo.loseTotalTimes)
        self.lb_times4.Text = myInfo.battleTimes ~=0 and (string.format("%.2f", myInfo.winTotalTimes*100 / myInfo.battleTimes) .. '%') or "0.00%"
        self.lb_nownum.Text = myInfo.myToken
        self.lb_todaynum.Text = myInfo.maxToken ~= 0 and (myInfo.todayToken .. '/' .. myInfo.maxToken) or 0
        self.tb_seasonCD.XmlText = ToCountDownSecond(myInfo.seasonEndTime)

        local eles = GlobalHooks.DB.Find('SoloRank',{})
        
        for _,v in ipairs(eles) do
            if v.RankScore <= myInfo.score then
                self.myScoreData = v
            else
                break
            end

        end
        Util.HZSetImage(self.cvs_grade, self.myScoreData.Icon)

        local str = ""
        for i,v in ipairs(self.timeList) do
            if v ~= nil then
                print(tostring(v.openTime) .. "  " .. tostring(v.closeTime))
                local openTime = ServerTime.FormatCD(v.openTime, "%H:%M")
                local closeTime = ServerTime.FormatCD(v.closeTime, "%H:%M")
                if i ~= 1 then
                    str = str .. ","
                end
                str = str .. string.format("%s-%s", openTime, closeTime)
            end
        end
        self.lb_open.Text = str

        
        if myInfo.startJoinTime ~=nil and myInfo.startJoinTime ~= 0 then
            
            self.tbt_start.IsChecked = true
            setJoinTime(myInfo.avgMatchTime, myInfo.startJoinTime)
        end
        
        
        
        
        
        
        
        
    end)
    
     DataMgr.Instance.UserData:AttachLuaObserver(GlobalHooks.UITAG.GameUISolo, self)

    self:checkEnterEffect()

    DataMgr.Instance.FlagPushData:AttachLuaObserver(GlobalHooks.UITAG.GameUISolo + 1, {Notify = function(status, flagdate)
        if status == FlagPushData.FLAG_SOLO then
            self:checkEnterEffect()
        end      
    end})

end

    
function _M:OnExit()
    DataMgr.Instance.UserData:DetachLuaObserver(GlobalHooks.UITAG.GameUISolo)
    DataMgr.Instance.FlagPushData:DetachLuaObserver(GlobalHooks.UITAG.GameUISolo + 1)

    
    
    
    

    self.timer:Stop()
end

function _M:getMyInfo()
    return self.myInfo
end

function _M:setWaitTime(avgMatchTime,startJoinTime)
    if startJoinTime ~=nil and startJoinTime ~= 0 then
            
        self.tbt_start.IsChecked = true
        setJoinTime(myInfo.avgMatchTime, myInfo.startJoinTime)
    else
        self.tbt_start.IsChecked = false
        self.tbt_start.Text = Util.GetText(TextConfig.Type.SOLO,"match")
        self.tbt_start.Enable = true
        self.cvs_tips.Visible = false
        self.lb_open.Visible = true
    end
end

local ui_names = 
{
    {name = 'lb_nowrank'}, 
    {name = 'lb_times1'},  
    {name = 'lb_times2'},  
    {name = 'lb_times3'},  
    {name = 'lb_times5'},  
    {name = 'lb_times4'},  
    {name = 'tb_seasonCD'},
    {name = 'ib_grade'},   
    {name = 'lb_now'},     
    {name = 'lb_nownum'},  
    {name = 'lb_todaynum'},
	{name = 'lb_open'},    
    {name = 'tbt_start'},  
    {name = 'cvs_tips'},   
    {name = 'lb_estimate'},
    {name = 'lb_wait'},    
    {name = 'cvs_grade',click = function( self )
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISoloGrade,-1,self.myScoreData.RankLevel)   
    end},
    {name = 'btn_shop',click = function (self)
         EventManager.Fire('Event.Goto', {id = "SoloShop"})
    end},
    {name = 'btn_1',click = function(self)
        local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISoloRecord)
        obj:setMyInfo(self.myInfo)
    end},
    {name = 'btn_2',click = function(self)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISoloRule)   
    end},
    {name = 'btn_3',click = function(self)
        MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUILeaderboard,0,Leaderboard.LBType.ARENA)
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
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/solo/solo_dekaron.gui.xml')
    initControls(self.menu,ui_names,self)
    self.menu.Visible = false

    self.timer = Timer.New(onTimerUpdate, 0.3, -1)

    self.tbt_start.TouchClick = function (sender)
        self.tbt_start.Enable = false
        if self.tbt_start.IsChecked then
            SoloAPI.requestJoinSolo(setJoinTime,function ()
                self.tbt_start.IsChecked = false
                self.tbt_start.Enable = true
                self.cvs_tips.Visible = false
                self.lb_open.Visible = true
                self:checkEnterEffect()
            end)
        else
            self.tbt_start.Text = Util.GetText(TextConfig.Type.SOLO,"match")
            SoloAPI.requestQuitSolo(function() 
                self.tbt_start.Enable = true
                self.timer:Stop()
                self.cvs_tips.Visible = false
                self.lb_open.Visible = true
                EventManager.Fire("Event.Hud.hide1v1Wait",{})
                end)
            self:checkEnterEffect()
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

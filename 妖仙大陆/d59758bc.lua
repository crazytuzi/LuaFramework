local _M = { }
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local Leaderboard = require "Zeus.Model.Leaderboard"
local ServerTime = require "Zeus.Logic.ServerTime"
local _5V5Api = require 'Zeus.Model.5v5'

local self = {}

local iconList = {
    "#dynamic_n/arena/arena.xml|arena|2",
    "#dynamic_n/arena/arena.xml|arena|1",
    "#dynamic_n/arena/arena.xml|arena|0",
    "#dynamic_n/arena/arena.xml|arena|3",
}

local function ToCountDownSecond(endTime)
    if endTime == nil then
        return
    end
    local passTime = math.floor(endTime/1000-ServerTime.GetServerUnixTime())
    return Util.GetText(TextConfig.Type.SOLO,"endSeason",ServerTime.GetCDStrCut2(passTime))
end

local function FillIcon(node,rerard)
    local tmp = string.split(rerard,':')
    local code = tmp[1]
    local num = tmp[2]
    node.Visible = true
    node:RemoveAllChildren(true)
    print("code = " .. code)
    local detail = ItemModel.GetItemDetailByCode(code)
    if detail== nil then
        return
    end
    local itshow = Util.ShowItemShow(node,detail.static.Icon,detail.static.Qcolor,num)
    itshow.EnableTouch = true
    itshow.TouchClick = function (sender)
        EventManager.Fire('Event.ShowItemDetail',{data=detail}) 
    end
end

local function initRewardList(self)
    local eles2 = GlobalHooks.DB.Find('PersonalRank',{})
    print("eles2 = ",#eles2)
    local ranktext = Util.GetText(TextConfig.Type.SOLO,'oneRank')
    local function UpdateRankRewardItem(gx,gy,node)
        node.Visible = true
        local data = eles2[gy+1]
        local items = string.split(data.RankReward,';')
        local ib_rank = node:FindChildByEditName('ib_rank',false)
        local lb_ranknum = node:FindChildByEditName('lb_ranknum',false)

        if ib_rank~= nil then
            local iconIndex = gy+1 > 4 and 4 or gy+1
            ib_rank.Layout = XmdsUISystem.CreateLayoutFroXml(iconList[iconIndex],LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
        end

        if data.StartRank == data.StopRank then
            lb_ranknum.Text = Util.CSharpStringformat(ranktext,data.StartRank)
        else
            local indexStr = data.StartRank..'-'..data.StopRank
            lb_ranknum.Text = Util.CSharpStringformat(ranktext,indexStr)
        end

        
        for i=1,3 do            
            local cvs_icon = node:FindChildByEditName('cvs_icon'..i,false)
            local item = items[i]
            cvs_icon.Visible = item ~= nil
            if item then
                FillIcon(cvs_icon,item)
            end
        end
    end

    local s = self.cvs_single.Size2D
    self.sp_show:Initialize(s.x,s.y,#eles2,1,self.cvs_single,UpdateRankRewardItem,function() end)
end

local function setTodayReward()
    local curTimes = self.data.hasRecivedCount + 1
    if curTimes > #self.todayReward then
        self.btn_receive.Enable = false
        self.btn_receive.IsGray = true
        self.ib_receive.Visible = false
        self.cvs_myreward1.Visible = false
        self.cvs_myreward2.Visible = false
        self.cvs_myreward3.Visible = false
        self.lb_nexttips.Visible = true
    else
        local reward = self.todayReward[curTimes].RankReward
        local items = string.split(reward,';')

        for i=1,3 do            
            local item = items[i]
            self["cvs_myreward" .. i].Visible = item ~= nil
            if item then
                FillIcon(self["cvs_myreward" .. i],item)
            end
        end

        if self.data.hasRecivedCount < self.data.totalCanReciveCount then
            self.btn_receive.Enable = true
            self.ib_receive.Visible = true
            self.btn_receive.IsGray = false
        else
            self.btn_receive.Enable = false
            self.ib_receive.Visible = false
            self.btn_receive.IsGray = true
        end
        self.lb_nexttips.Visible = false
    end
    
end

function _M:OnEnter(data)
    self.data = data
    initRewardList(self)
    
    self.lb_point.Text = data.score
    self.lb_rank.Text = data.rank
    self.lb_winnum.Text = data.win
    self.lb_losenum.Text = data.fail
    self.lb_flatnum.Text = data.tie
    local allnum = data.win + data.fail + data.tie
    local winRate = allnum == 0 and 0 or data.win / allnum
    self.lb_odds.Text =  string.format("%.2f", winRate*100) .. '%'
    self.lb_mvp.Text = data.mvp

    
    self.lb_receive_count.Text = data.hasRecivedCount
    self.lb_fight_count.Text = data.totalCanReciveCount
    setTodayReward()

    self.tbx_overtime.XmlText = ToCountDownSecond(self.data.seasonEndTime)
end

function _M:OnExit()

end


local ui_names = 
{
    {name = 'sp_show'},
    {name = 'cvs_single'},
    
    {name = 'lb_receive_count'},
    {name = 'lb_fight_count'},
    {name = 'cvs_myreward1'},
    {name = 'cvs_myreward2'},
    {name = 'cvs_myreward3'},
    {name = 'lb_point'},
    {name = 'lb_rank'},
    {name = 'lb_winnum'},   
    {name = 'lb_losenum'},   
    {name = 'lb_flatnum'},   
    {name = 'lb_odds'},
    {name = 'lb_mvp'},
    {name = 'btn_rank'},
    {name = 'btn_receive'}, 
    {name = 'ib_receive'},
    {name = 'lb_nexttips'},
    {name = 'tbx_overtime'},
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
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/5v5/5v5_reward.gui.xml')
    initControls(self.menu,ui_names,self)

    self.cvs_single.Visible = false
    self.btn_receive.Enable = false
    self.ib_receive.Visible = false
    self.lb_nexttips.Visible = false
    self.btn_rank.TouchClick = function (sender)
        MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUILeaderboard,0,Leaderboard.LBType.ARENA_5V5)
    end

    self.btn_receive.TouchClick = function(sender)
        _5V5Api.requestTodayReward(function ()
            
            local reward = self.todayReward[self.data.hasRecivedCount + 1].RankReward
            local items = string.split(reward,';')
            local  reward = {}
            for i=1,3 do 
                local tmp = string.split(items[i],':')
                local code = tmp[1]
                local num = tmp[2]
                local detail = ItemModel.GetItemDetailByCode(code)
                reward[detail.static.Name .. "(".. code .. ")"] = num
            end
            local dailyReward = Util.GetText(TextConfig.Type.GUILD, "dailyReward")
            Util.SendBIData("5v5Reward","",dailyReward,"","",reward,"")
            
            self.data.hasRecivedCount = self.data.hasRecivedCount + 1
            self.lb_receive_count.Text = self.data.hasRecivedCount
            setTodayReward()
        end)
    end

    self.todayReward = GlobalHooks.DB.Find('DayReward',{})
    return self.menu
end

function _M.Create()
    
    setmetatable(self,_M)
    local node = InitComponent(self)
    return self,node
end

return _M

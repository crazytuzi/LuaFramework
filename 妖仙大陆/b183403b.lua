local Util = require "Zeus.Logic.Util"
local SoloAPI = require "Zeus.Model.Solo"
local ServerTime = require "Zeus.Logic.ServerTime"
local StarNumExt = require "Zeus.Logic.StarNumExt"
local CDLabelExt = require "Zeus.Logic.CDLabelExt"
local Relive = require "Zeus.Model.Relive"

local FPS = 20

local SoloBattleOverUI = {
    menu = nil
}
Util.WrapOOPSelf(SoloBattleOverUI)

function SoloBattleOverUI:init(tag, params)
    if params ==nil or tonumber(params) == 0 then
        self.menu = LuaMenuU.Create("xmds_ui/solo/solo_result.gui.xml", tag)
    else
        self.menu = LuaMenuU.Create("xmds_ui/solo/solo_result2.gui.xml", tag)
        self.lb_times = self.menu:GetComponent("lb_times")
        self.battleTimes = tonumber(params)
        self.lb_times.Text = (self.battleTimes -1) .. "/5"
    end

    local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    self.menu:SetFullBackground(lrt)
    self.menu.ShowType = UIShowType.Cover

    self.closeBtn = self.menu:GetComponent("btn_out")
    self.closeBtn.TouchClick = self._self_onCloseBtnClick

    self.lb_rank = self.menu:GetComponent("lb_rank")
    self.ib_win = self.menu:GetComponent("ib_win")
    
    self.ib_lose = self.menu:GetComponent("ib_lose")
    self.ib_duang =self.menu:GetComponent("ib_duang")
    
    
    self.lb_qualifications = self.menu:GetComponent("lb_qualifications")
    self.lb_prop = self.menu:GetComponent("lb_prop")
    
    self.cdExt = CDLabelExt.New(self.closeBtn, 0, self._self_onTime,self._self_onCloseBtnClick)
    self.ib_box = self.menu:GetComponent("ib_box")


    
    
    
    
    

    self.backCanvas = self.menu:GetComponent("cvs_result")
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    

    

    
    
    
    

    self.menu:SubscribOnEnter(self._self_onEnter)
    self.menu:SubscribOnExit(self._self_onExit)
    self.menu:SubscribOnDestory(self._self_onDestroy)

    self.menu.Enable = true
    self.menu.event_PointerClick = function ()
        self:stopAnim()
    end
end

function SoloBattleOverUI:onCloseBtnClick(sender)
    self.menu:Close()
    SoloAPI.requestLeaveScene(function()
        
    end)
end

function SoloBattleOverUI:onTimerUpdate()

    if self.curRank ~= self.data.currentRank then
        self.curRank = self.curRank + self.addRank

        if math.abs(self.curRank) >= math.abs(self.data.currentRank) then
            self.curRank = self.data.currentRank
        end

        self.lb_rank.Text = self.curRank

        return
    end

    if self.wait1 > 0 then
        self.wait1 = self.wait1 -1
        return
    end

    if self.currScore ~= self.data.newScore then
        self.currScore = self.currScore + self.addScore
        if math.abs(self.currScore) >= math.abs(self.data.newScore) then
            self.currScore = self.data.newScore
        end

        if self.currScore < 0 then
            self.lb_qualifications.Text = self.currScore
        else
            self.lb_qualifications.Text = "+" .. self.currScore
        end

        return
    end

    if self.wait2 > 0 then
        self.wait2 = self.wait2 -1
        return
    end

    if self.curToken ~= self.data.tokenChange then
        self.curToken = self.curToken + self.addToken
        if math.abs(self.curToken) >= math.abs(self.data.tokenChange) then
            self.curToken = self.data.tokenChange
        end

        if self.curToken < 0 then
            self.lb_prop.Text = self.curToken
        else
            self.lb_prop.Text = "+" .. self.curToken
        end

        return
    end

    if self.battleTimes ~= nil then
        local action = ScaleAction.New()
        action.Duration = 0.15
        action.ScaleX = 1.2
        action.ScaleY = 1.2
        action.ActionEaseType = EaseType.easeOutBack
        action.ActionFinishCallBack = function ()
            self.lb_times.Text = self.battleTimes .. "/5"
            local action = ScaleAction.New()
            action.Duration = 0.15
            action.ScaleX = 1
            action.ScaleY = 1
            self.lb_times:AddAction(action)
        end
        self.lb_times:AddAction(action)
        
        if self.battleTimes == 5 then
            action = FadeAction.New()
            action.TargetAlpha = 0
            action.Duration = 0.3
            action.ActionFinishCallBack = function ( ... )
                Util.HZSetImage(self.ib_box, "dynamic_n/chest/baiyin.png", true, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
                local openef = self.menu:GetComponent("ib_box_openef")
                Util.showUIEffect(openef,49)
                
                local action = FadeAction.New()
                action.TargetAlpha = 1
                action.Duration = 0.3
                self.ib_box:AddAction(action)
            end
            self.ib_box:AddAction(action)
        end
    end
    
    self.timer:Stop()
end


function SoloBattleOverUI:stopAnim()
    if self.timer then
        self.timer:Stop()
        self.lb_rank.Text = self.data.currentRank
        self.lb_qualifications.Text = self.data.newScore
        self.lb_prop.Text = self.data.tokenChange
        self.lb_times.Text = self.battleTimes .. "/5"
        if self.battleTimes == 5 then
            Util.HZSetImage(self.ib_box, "dynamic_n/chest/baiyin.png", true, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
        end
    end
end
local win = Util.GetText(TextConfig.Type.SOLO, "win")
local lose = Util.GetText(TextConfig.Type.SOLO, "lose")
local tie = Util.GetText(TextConfig.Type.SOLO, "tie")
local resultText = {win,lose,tie}
function SoloBattleOverUI:setData(data, cd)
    
    self.cdExt:setCD(cd)
    self.cdExt:start()

    
    local rankdata = GlobalHooks.DB.Find('SoloRank',{})
    local scoreBefore = data.currScore - data.newScore
    if scoreBefore < 0 then
        scoreBefore = 0
    end
    local scoreAfter = data.currScore
    if scoreAfter < 0 then
        scoreAfter = 0
    end

    local duanBefore = nil
    local duanAfter = nil
    for _,v in ipairs(rankdata) do
        if scoreBefore >= v.RankScore then
            duanBefore = v
        end
        if scoreAfter >= v.RankScore then
            duanAfter = v
        end
    end
    local rankBefore = (data.currentRank - data.rankChange)
    if rankBefore < 0 then
        rankBefore = 0
    end
    local phylum = scoreBefore .. "_".. scoreAfter--"变化前资历="..scoreBefore .. ",变化前排名=".. (data.currentRank - data.rankChange) .. ",变化前段位=".. duanBefore.RankLevel
    local classfield = rankBefore .. "_".. data.currentRank--"变化后资历="..scoreAfter .. ",变化后排名=".. data.currentRank .. ",变化后段位=".. duanAfter.RankLevel
    local family = duanBefore.RankLevel .. "_".. duanAfter.RankLevel
    Util.SendBIData("soloResult","",resultText[data.result],phylum,classfield,family,"")
    
    self.data = data
    
    
    
    
    
    

  
  
    if data.result == 1 then
        Util.showUIEffect(self.ib_duang,44)
        Util.showUIEffect(self.ib_duang,26)
    elseif data.result == 2 then
        Util.showUIEffect(self.ib_duang,45) 
        Util.showUIEffect(self.ib_duang,27)
    elseif data.result == 3 then 
        Util.showUIEffect(self.ib_duang,47) 
        Util.showUIEffect(self.ib_duang,46)
    end

    if data.rankChange >0 then
        self.ib_win.Visible = true
        self.ib_lose.Visible = false
        
    elseif data.rankChange <0 then
        self.ib_win.Visible = false
        self.ib_lose.Visible = true
          
    else
        self.ib_win.Visible = false
        self.ib_lose.Visible = false
    end

    
    

    self.currScore = 0
    self.curRank = data.currentRank - data.rankChange
    self.curToken = 0

    self.addScore = 1
    self.addRank = 1
    self.addToken = 1
    
    if data.newScore < 0 then
        self.addScore = -self.addScore
        self.lb_qualifications.Text = "-0"
    else
        self.lb_qualifications.Text = "+0"
    end

    self.lb_rank.Text = data.currentRank
    if data.rankChange <0 then
        self.addRank = -self.addRank
    end

    if data.tokenChange <0 then
        self.addToken = -self.addToken
        self.lb_prop.Text = "-0"
    else
        self.lb_prop.Text = "+0"
    end

    self.wait1 = 20
    self.wait2 = 20
    self.timer = Timer.New(self._self_onTimerUpdate, 0.03, -1)
    self.timer:Start()
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end

function SoloBattleOverUI:onTime(cd)
    

    local str = Util.GetText(TextConfig.Type.SOLO,'arenaEndDesc')
    return string.format(str,math.floor(cd))
end













































































































function SoloBattleOverUI:onEnter()
end
function SoloBattleOverUI:onExit()
    
    self.cdExt:stop()
    self.timer:Stop()
    Relive.AutoOpenFeatureId ={id = GlobalHooks.UITAG.GameUISolo}
end

function SoloBattleOverUI:onDestroy()

    self.menu = nil
    
    setmetatable(self, nil)
    for k,v in pairs(self) do
        self[k] = nil
    end
end

local function Create(tag, params)
    local ui = {}
    setmetatable(ui, SoloBattleOverUI)
    ui:init(tag, params)
    return ui
end

return {Create = Create}

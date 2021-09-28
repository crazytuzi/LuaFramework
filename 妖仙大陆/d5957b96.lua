local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local ServerTime = require "Zeus.Logic.ServerTime"
local _5V5API = require "Zeus.Model.5v5"
local ChatModel     = require 'Zeus.Model.Chat'
local ChatUtil      = require "Zeus.UI.Chat.ChatUtil"
local Relive = require "Zeus.Model.Relive"

local self = {}


local Text = {
  exitDesc = Util.GetText(TextConfig.Type.SOLO,'arenaEndDesc'),
}

local function shareBattle()
    if self.instanceId then
        _5V5API.requestShardMatchResult(self.instanceId,function()
            local  text =Util.GetText(TextConfig.Type.SOLO,'sharestr') .. ChatUtil.Add5v5Battle(self.instanceId,Util.GetText(TextConfig.Type.SOLO,'clickstr')) --Util.GetText(TextConfig.Type.ITEM,'sharestr',ChatUtil.AddItemByData(nil,self.detail))
            print(text)
            ChatModel.chatMessageRequest(ChatModel.ChannelState.Channel_world,text, "", function (param)
                  GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.SOLO,'sendmessage'))
                  self.instanceId = nil
                  self.btn_fenxiang1.Enable = false
                  self.btn_fenxiang1.IsGray = true
                  self.btn_fenxiang.Enable = false
                  self.btn_fenxiang.IsGray = true
                end)
        end)
    end
end

local function InitUI()
    local UIName = {
        "btn_fenxiang1",
        "btn_tongji",
        "btn_continue",

        "cvs_xianshi",

        "ib_duang",
        "cvs_bg",
        "cvs_fra",
        "lb_point",
    }

    for i = 1, #UIName do
        self[UIName[i] ] = self.menu:GetComponent(UIName[i])
    end

    self.btn_fenxiang1.TouchClick = function ( sender )
        shareBattle()
    end

    self.btn_tongji.TouchClick = function ( sender )
        self.cvs_fra.Visible = true
        self.cvs_bg.Visible = false
    end

    self.btn_continue.TouchClick = function ( sender )
        if self ~= nil and self.menu ~= nil then
            self.menu:Close()
            _5V5API.requestLeaveArea(function()
                
            end)
        end
    end

    self.cvs_fra.TouchClick = function ( sender )
        self.cvs_fra.Visible = false
        self.cvs_bg.Visible = true
    end

    local btn_guanbi = self.cvs_fra:FindChildByEditName("btn_guanbi",true)
    self.btn_fenxiang = self.cvs_fra:FindChildByEditName("btn_fenxiang",true)

    btn_guanbi.TouchClick = function ( sender )
        self.cvs_fra.Visible = false
        self.cvs_bg.Visible = true
    end

    self.btn_fenxiang.TouchClick = function ( sender )
        shareBattle()
    end

    self.cvs_xianshi.Enable = false
end

local function InitUI1()
    local btn_close = self.menu:GetComponent("btn_close")
    self.cvs_frame1 = self.menu:GetComponent("cvs_frame1")
    btn_close.TouchClick = function ( sender )
        self.menu:Close()
    end
end

local function setPlayerData(node,data,showCount,playerType) 
    if data == nil then
        node.Visible = false
        return
    end
    local lb_icon = node:FindChildByEditName("lb_icon",true)
    local lb_level = node:FindChildByEditName("lb_level",true)
    local lb_name = node:FindChildByEditName("lb_name",true)
    local lb_jisha = node:FindChildByEditName("lb_jisha",true)
    local lb_die = node:FindChildByEditName("lb_die",true)
    local ib_mvp = node:FindChildByEditName("ib_mvp",true)

    Util.SetIconImagByPro(lb_icon,data.playerPro)
    lb_level.Text = "LV." .. data.playerLevel
    lb_name.Text = data.playerName


    lb_jisha.Text = data.killCount
    lb_die.Text = data.deadCount

    ib_mvp.Visible = false
    if data.isMvp ~=nil and tonumber(data.isMvp) ~= 0 then 
       ib_mvp.Visible = true
    end

    if playerType == 0 then
        lb_name.FontColorRGBA = 0xf7ffa3ff
        lb_level.FontColorRGBA = 0xf7ffa3ff
    elseif playerType == 1 then
        lb_name.FontColorRGBA = 0xddf2ffff
        lb_level.FontColorRGBA = 0xddf2ffff
    else
        lb_name.FontColorRGBA = 0xf86868ff
        lb_level.FontColorRGBA = 0xf86868ff
    end

    if self.maxkillCount == data.killCount and self.maxkillCount > 0 then
        lb_jisha.FontColorRGBA = 0xed2a0aff
    else
        lb_jisha.FontColorRGBA = 0xddf2ffff
    end

    if self.minDeadCount == data.deadCount then
        lb_die.FontColorRGBA = 0xfef8c3ff
    else
        lb_die.FontColorRGBA = 0x9aa9b5ff
    end

    if showCount then
        local lb_num1 = node:FindChildByEditName("lb_num1",true)
        local lb_num2 = node:FindChildByEditName("lb_num2",true)

        lb_num1.Text = Util.NumberToShow(data.hurt or 0)
        lb_num2.Text = Util.NumberToShow(data.treatMent or 0)

        if self.maxhurt == data.hurt and self.maxhurt > 0 then
            lb_num1.FontColorRGBA = 0xffae00ff
        else
            lb_num1.FontColorRGBA = 0xddf2ffff
        end

        if self.maxtreatMent == data.treatMent and self.maxtreatMent > 0 then
            lb_num2.FontColorRGBA = 0x00f012ff
        else
            lb_num2.FontColorRGBA = 0xddf2ffff
        end
    end
end



local function onTimerUpdate(dt)
    self.time = self.time -1
    if self.time <=0 then
        self.menu:Close()
        _5V5API.requestLeaveArea(function()
            
        end)
    else
        self.btn_continue.Text = string.format(Text.exitDesc,self.time)
    end
end

local function checkMaxMinData(data)
    self.maxkillCount = 0
    self.minDeadCount = 0
    self.maxhurt = 0
    self.maxtreatMent = 0

    self.myPos = 0
    local num = self.maxTeamNum * 2
    for i=1,num do
        local info = nil
        if i<self.maxTeamNum +1 then 
            info = data.resultInfoA[i]
        else
            info = data.resultInfoB[i-self.maxTeamNum]
        end
        if info ~= nil then
            if info.playerId == DataMgr.Instance.UserData.RoleID then
                self.myPos = i
            end

            if info.killCount > self.maxkillCount then
                self.maxkillCount = info.killCount
            end
            if info.deadCount < self.minDeadCount then
                self.minDeadCount = info.deadCount
            end

            if info.hurt > self.maxhurt then
                self.maxhurt = info.hurt
            end
            if info.treatMent > self.maxtreatMent then
                self.maxtreatMent = info.treatMent
            end
        end
    end
end

local function setUIdata(ui,data,showCount,nameColor)
    self.myPos = self.myPos or 0
    local playerType = 0
    for i=1,10 do
        local info = nil
        if self.myPos < self.maxTeamNum +1 then
            if i<6 then 
                info = data.resultInfoA[i]
                playerType  = 1
            else
                info = data.resultInfoB[i-5]
                playerType = 2
            end
        else
            if i<6 then 
                info = data.resultInfoB[i]
                playerType = 1
            else
                info = data.resultInfoA[i-5]
                playerType = 2
            end
        end

        if nameColor then
            playerType = 1
        else
            if info~= nil and info.playerId == DataMgr.Instance.UserData.RoleID then
                playerType = 0
            end
        end

        local cvs = ui:FindChildByEditName("cvs_head" .. i,true)
        setPlayerData(cvs,info,showCount,playerType)
    end
end

local function OnEnter()
    if self.lookBattleId ~= nil and self.lookBattleId ~=0 and self.lookBattleId ~= "" then
        
        
        
        self.cvs_frame1.Visible = false
        _5V5API.requestLookMatchResult(self.lookBattleId,function (data)
            print("requestLookMatchResult ===" .. PrintTable(data))
            self.maxTeamNum = #data.resultInfoA
            checkMaxMinData(data)

            local ib_win = self.cvs_frame1:FindChildByEditName("ib_win",true)
            local ib_pin = self.cvs_frame1:FindChildByEditName("ib_pin",true)
            local ib_pinpin = self.cvs_frame1:FindChildByEditName("ib_pinpin",true)
            local ib_lose = self.cvs_frame1:FindChildByEditName("ib_lose",true)
            ib_win.Visible = true
            ib_pin.Visible = false
            ib_pinpin.Visible = false
            ib_lose.Visible = true
            self.myPos = 0
            if data.resultA == 2 then
                self.myPos = self.maxTeamNum *2 + 1
            elseif data.resultA == 3 then
                ib_win.Visible = false
                ib_pin.Visible = true
                ib_pinpin.Visible = true
                ib_lose.Visible = false
            end


            setUIdata(self.cvs_frame1,data,true,true)
            self.cvs_frame1.Visible = true
        end)
    end
end

local function OnExit()
    if self.timer then
        self.timer:Stop()
    end

    if self.gameResult ~= nil then
        if self.gameResult.result == 1 then
            Util.clearUIEffect(self.ib_duang,44)
            Util.clearUIEffect(self.ib_duang,26)
        elseif self.gameResult.result == 2 then
            Util.clearUIEffect(self.ib_duang,45) 
            Util.clearUIEffect(self.ib_duang,27)
        elseif self.gameResult.result == 3 then 
            Util.clearUIEffect(self.ib_duang,47) 
            Util.clearUIEffect(self.ib_duang,46)
        end
    end
end

local guild_win = Util.GetText(TextConfig.Type.GUILD, "guild_win")
local guild_lose = Util.GetText(TextConfig.Type.GUILD, "guild_lose")
local guild_peace = Util.GetText(TextConfig.Type.GUILD, "guild_peace")

local resultText = {guild_win,guild_lose,guild_peace}
function _M:setBattleInfo(data)
    print("5v5Result ="..PrintTable(data))
    self.lookBattleId = nil
    if data.s2c_gameResult ~= nil then

        self.lb_point.FontColor = Util.FontColorOrange
        if data.s2c_gameResult.newScore > 0 then
            self.lb_point.Text = "+" .. data.s2c_gameResult.newScore
        elseif data.s2c_gameResult.newScore == 0 then
            if data.s2c_gameResult.result == 2 then
                self.lb_point.Text = "-" .. data.s2c_gameResult.newScore
                self.lb_point.FontColor = Util.FontColorRed
            else
                self.lb_point.Text = "+" .. data.s2c_gameResult.newScore
            end
        else
            self.lb_point.Text = data.s2c_gameResult.newScore
            self.lb_point.FontColor = Util.FontColorRed
        end

        self.time = data.s2c_gameOverTime
        self.btn_continue.Text = string.format(Text.exitDesc,self.time)
        self.timer:Start()
        self.instanceId = data.s2c_gameResult.instanceId

        if data.s2c_gameResult.result == 1 then
            Util.showUIEffect(self.ib_duang,44)
            Util.showUIEffect(self.ib_duang,26)
        elseif data.s2c_gameResult.result == 2 then
            Util.showUIEffect(self.ib_duang,45) 
            Util.showUIEffect(self.ib_duang,27)
        elseif data.s2c_gameResult.result == 3 then 
            Util.showUIEffect(self.ib_duang,47) 
            Util.showUIEffect(self.ib_duang,46)
        end

        self.btn_fenxiang1.Enable = true
        self.btn_fenxiang1.IsGray = false
        self.btn_fenxiang.Enable = true
        self.btn_fenxiang.IsGray = false
    else    
        self.instanceId = nil
    end
    self.gameResult = data.s2c_gameResult

    self.maxTeamNum = #data.resultInfoA
    checkMaxMinData(data)
    setUIdata(self.cvs_xianshi,data,false,false)
    setUIdata(self.cvs_fra,data,true,false)
    self.cvs_fra.Visible = false
    self.cvs_bg.Visible = true


    
    if data.s2c_gameResult then 
        local scoreBefore = data.s2c_gameResult.currScore - data.s2c_gameResult.newScore
        if scoreBefore < 0 then
            scoreBefore = 0
        end
        local currScore = data.s2c_gameResult.currScore
        local rankBefore = (data.s2c_gameResult.currRank - data.s2c_gameResult.rankChange)
        if rankBefore < 0 then
            rankBefore = 0
        end

        local phylum = scoreBefore .. "_" .. currScore--"变化前积分="..scoreBefore .. ",变化前排名=".. (data.s2c_gameResult.currRank - data.s2c_gameResult.rankChange)
        local classfield = rankBefore .. "_" .. data.s2c_gameResult.currRank--"变化后积分="..currScore .. ",变化后排名=".. data.s2c_gameResult.currRank
        Util.SendBIData("5v5Result","",resultText[data.s2c_gameResult.result],phylum,classfield,"","")

        Relive.AutoOpenFeatureId ={id = GlobalHooks.UITAG.GameUI5V5Main}
    end
    
end

local function InitComponent(self, tag,params)
    if params == nil or (params~=nil and params == "") then
        self.menu = LuaMenuU.Create('xmds_ui/5v5/5v5_settelment.gui.xml',tag)
        InitUI()
        self.timer = Timer.New(onTimerUpdate, 1, -1)
    else
        self.menu = LuaMenuU.Create('xmds_ui/5v5/5v5_share.gui.xml',tag)
        InitUI1()
        self.lookBattleId = params
        if params ~= nil then
            print("self.lookBattleId = ",params)
        end

        self.menu.mRoot.IsInteractive = true
        self.menu.mRoot.Enable = true
        self.menu.mRoot.EnableChildren = true
        LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function(displayNode)
            if self ~= nil and self.menu ~= nil then
                self.menu:Close()
            end
        end})

    end

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)


    return self.menu
end



local function Create(tag,params)
    setmetatable(self, _M)
    InitComponent(self,tag, params)
    return self
end

return {Create = Create}

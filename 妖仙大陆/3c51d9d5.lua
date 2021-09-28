local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local _5V5API = require "Zeus.Model.5v5"
local FubenUtil = require "Zeus.UI.XmasterFuben.FubenUtil"

local self = {
    menu = nil,
}

local useCvsList = {
    {3},
    {2,4},
    {2,3,4},
    {1,2,3,4},
    {1,2,3,4,5},
}

local function onTimerUpdate()
    self.cd = self.cd - 1
    if self.cd >= 0 then
        self.btn_doready.Text = Util.GetText(TextConfig.Type.SOLO, "readyTime", self.cd)
    else
        
        self.timer:Stop()
        self.menu:Close()
    end
end

function _M:setInfo(myDataList,enemyDataList,time,tempTeamId)
    self.teamNode = {}
    self.tempTeamId = tempTeamId
    self.cd = tonumber(time)
    self.timer:Start()

    self.btn_doready.Visible = true
    self.lb_haveready.Visible = false
    self.lb_wait.Visible = false
    self.btn_doready.Text = Util.GetText(TextConfig.Type.SOLO, "readyTime", self.cd)
    
    local cvsList = useCvsList[#myDataList]
    for i,v in ipairs(myDataList) do
        local cvs = self.teamHeads[cvsList[i]]
        cvs.Visible = true
        local ib_head = cvs:FindChildByEditName('ib_head',false)
        local lb_level = cvs:FindChildByEditName('lb_level',false)
        local lb_name = cvs:FindChildByEditName('lb_name',false)

        self.teamNode[v.playerId] = cvs
        Util.SetHeadImgByPro(ib_head,v.playerPro)
        lb_level.Text = v.playerLvl
        lb_name.Text = v.playerName
        local state = 1
        if v.readyStatus == 1 then
            state = 3
        elseif v.readyStatus == 2 then
            state = 2
        end
        self:setTeamerState(v.playerId,state)
    end

    cvsList = useCvsList[#enemyDataList]
    for i,v in ipairs(enemyDataList) do
        local cvs = self.teamHeads[cvsList[i]+5]
        cvs.Visible = true
        local ib_head = cvs:FindChildByEditName('ib_head',false)
        local lb_level = cvs:FindChildByEditName('lb_level',false)
        local lb_name = cvs:FindChildByEditName('lb_name',false)

        self.teamNode[v.playerId] = cvs
        Util.SetHeadImgByPro(ib_head,v.playerPro)
        lb_level.Text = v.playerLvl
        lb_name.Text = v.playerName
        local state = 1
        if v.readyStatus == 1 then
            state = 3
        elseif v.readyStatus == 2 then
            state = 2
        end
        self:setTeamerState(v.playerId,state)
    end

end

function _M:setTeamerState(palyerid,state)
    print("palyerid " .. palyerid .. "state " .. state)
    local cvs = self.teamNode[palyerid]
    if cvs then
        
        local ib_ok = cvs:FindChildByEditName('ib_ok',false)

        ib_ok.Visible = false
        if state == 1 then 

        elseif state == 2 then     
            ib_ok.Visible = true
        elseif state == 3 then     
        end
    end
end

local function OnEnter()

end

local function OnExit()
    
    self.timer:Stop()
    EventManager.Fire("Event.Hud.hidePvpWait",{})
end

local function InitUI()
    local UIName = {
        "btn_doready",
        "lb_haveready",
        "lb_wait",

        "btn_minsize",

        "lb_title",
        "lb_title_name",

        
        
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
    self.btn_doready.Visible = true
    self.lb_haveready.Visible = false
    self.lb_wait.Visible = false

    self.btn_doready.TouchClick = function(sender)
        _5V5API.requestReady(self.tempTeamId,function ()
            self.btn_doready.Visible = false
            self.lb_haveready.Visible = true
            self.lb_wait.Visible = false
        end)
    end
    self.btn_minsize.TouchClick = function(sender)
        self.menu.Visible = false
    end

    self.teamHeads = {}
    for i=1,10 do
        self.teamHeads[i] = self.menu:GetComponent("cvs_head" .. i) 
        
        self.teamHeads[i].Visible = false
        
    end
    

    self.cd = 0
    self.timer = Timer.New(onTimerUpdate, 1, -1)
end

local function InitCompnent(params)
    InitUI()
    self.teamNode = {}
    local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    self.menu:SetFullBackground(lrt)

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        
    end)
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/5v5/5v5_getready.gui.xml", GlobalHooks.UITAG.GameUIFubenWaitEnter)
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

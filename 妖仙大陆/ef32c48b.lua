local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local _5V5API = require "Zeus.Model.5v5"

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
        self.btn_giveup.Text = Util.GetText(TextConfig.Type.FUBEN, "giveUpTime", self.cd)
    else
        
        local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5Main)
        if obj then
            obj:matchStop()
        end
        if self.readyStatus[DataMgr.Instance.UserData.RoleID] == 1 then
            _5V5API.requestRefuseMatch(function ()end)
        end
        
        self.timer:Stop()
        self.menu:Close()
    end
end
    
function _M:setInfo(dataList,time)
    self.teamNode = {}
    self.cd = tonumber(time)

    local myReady = false

    self.btn_giveup.Enable = true
    self.btn_ready.Enable = true
    self.btn_giveup.IsGray = false
    self.btn_ready.IsGray = false
    self.btn_giveup.Text = Util.GetText(TextConfig.Type.FUBEN, "giveUpTime", self.cd)

    local cvsList = useCvsList[#dataList]
    for i,v in ipairs(dataList) do
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

            if v.playerId == DataMgr.Instance.UserData.RoleID then 
                myReady = true
            end
        end
        self:setTeamerState(v.playerId,state,false)
    end

    if myReady then
        self.cd = self.cd + 4
    end

    self.timer:Start()

    if self.tbn_gou.IsChecked and not self.sendReq then
        self.sendReq = true
        _5V5API.requestAgreeMatch(function ()
            self.timer:Stop()
        end)
    end
end

function _M:setTeamerState(palyerid,state,check)
    print("palyerid " .. palyerid .. "state " .. state)
    if check == nil then
        check = true
    end
    local cvs = self.teamNode[palyerid]
    if cvs then
        
        local ib_ok = cvs:FindChildByEditName('ib_ok',false)
        local ib_todo = cvs:FindChildByEditName('ib_todo',false)
        local ib_notok = cvs:FindChildByEditName('ib_notok',false)
        ib_ok.Visible = false
        ib_todo.Visible = false
        ib_notok.Visible = false
        if state == 1 then 
            ib_todo.Visible = true
        elseif state == 2 then     
            ib_ok.Visible = true
            if palyerid == DataMgr.Instance.UserData.RoleID then
                self.btn_giveup.Visible = false
                self.btn_ready.Visible = false
                self.lb_5v5_self_ready.Visible = true
            end
        elseif state == 3 then     
            ib_notok.Visible = true
        end
    end
    self.readyStatus[palyerid] = state

    local allReady = false
    if check then
        allReady = true
        for k,v in pairs(self.readyStatus) do
            if v ~= 2 then
                allReady = false
                break
            end
        end
    end

    if state == 3 or allReady then 
        self.lb_state.Visible = false
        if allReady then
            self.lb_5v5_ready.Visible =true
            self.lb_5v5_notready.Visible = false
        else
            self.lb_5v5_ready.Visible =false
            self.lb_5v5_notready.Visible = true
            local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5Main)
            if obj then
                obj:matchStop()
            end
        end
        self.timer1 = Timer.New(function ( )
            self.timer1:Stop()
            self.menu:Close()
        end, 2, 1)
        self.timer1:Start()
    end
end

local function OnEnter()
    self.readyStatus = {}
    self.lb_state.Visible = true
    self.lb_5v5_title.Visible = true
    self.lb_5v5_ready.Visible =false
    self.lb_5v5_notready.Visible = false

    self.sendReq = false
    self.tbn_gou.IsChecked = DataMgr.Instance.TeamData.AutoReady
end

local function OnExit()
    
    self.timer:Stop()
    if self.timer1 then
        self.timer1:Stop()
    end
end

local function InitUI()
    local UIName = {
        "btn_giveup",
        "btn_ready",
        "btn_cancle",

        "lb_state",
        "lb_title",
        "lb_title_name",
        "lb_5v5_title",
        "lb_5v5_notready",
        "lb_5v5_ready",
        "lb_5v5_self_ready",

        "cvs_desc",
        "cvs_head",

        "cvs_tip_repeat",
        "tbn_gou",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
    self.btn_giveup.Visible = true
    self.btn_ready.Visible = true
    self.btn_cancle.Visible = false

    self.lb_title.Visible = false
    self.lb_title_name.Visible = false
    self.lb_5v5_title.Visible = true
    self.lb_5v5_notready.Visible = false
    self.lb_5v5_ready.Visible = false
    self.lb_5v5_self_ready.Visible = false

    self.btn_giveup.TouchClick = function(sender)
        _5V5API.requestRefuseMatch(function ()
            self.timer:Stop()
            self.menu:Close()
        end)
        
        
        
        
        
        
        
    end
    self.btn_ready.TouchClick = function(sender)
        _5V5API.requestAgreeMatch(function ()
            self.timer:Stop()
        end)
        
        
        
        
        
        
    end

    self.tbn_gou.TouchClick = function(sender)
        DataMgr.Instance.TeamData.AutoReady = self.tbn_gou.IsChecked
        if self.tbn_gou.IsChecked and not self.sendReq then
            self.sendReq = true
            _5V5API.requestAgreeMatch(function ()
                self.timer:Stop()
            end)
        end
    end

    self.teamHeads = {}
    for i=1,5 do
        self.teamHeads[i] = self.cvs_head:Clone()
        self.teamHeads[i].Position2D = Vector2.New(self.cvs_head.Position2D.x+125*(i-1) ,self.cvs_head.Position2D.y)
        self.teamHeads[i].Visible = false
        self.cvs_desc:AddChild(self.teamHeads[i])
    end
    self.cvs_head.Visible = false

    self.teamList = nil
    self.teamMemberStateMap = nil
    self.fubenId = nil
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
    self.menu = LuaMenuU.Create("xmds_ui/dungeon/dungeon_teamEnter.gui.xml", GlobalHooks.UITAG.GameUI5V5Ready)
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

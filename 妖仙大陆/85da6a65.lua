local Util = require "Zeus.Logic.Util"
local SoloAPI = require "Zeus.Model.Solo"

local MaxRoundTimes = 3
local SoloHud = {}
Util.WrapOOPSelf(SoloHud)

GlobalHooks.soloroundover = function (win, winForce)
    winForce = tonumber(winForce)
    local roundTimes = GameUtil.GetEnvironmentVar("roundtime")
    local winTimes0 = GameUtil.GetEnvironmentVar("zhengying00")
    local winTimes1 = GameUtil.GetEnvironmentVar("zhengying01")
    
    
    if roundTimes < 2 or (winTimes0 < 2 and winTimes1 < 2) then
        local myForce = DataMgr.Instance.UserData.Force
        local myWinTimes = (myForce == 2 and winTimes0) or winTimes1
        local enemyWinTimes = (myForce == 2 and winTimes1) or winTimes0
        local winType = 2
        if winForce == myForce then
            winType = 1
        elseif winForce == 0 then
            winType = 3
        end

        
        
        
        
            local cd = GameUtil.GetEnvironmentVar("roundovertime")
            local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISoloRoundOver, -1)
            obj:setData(winType, myWinTimes, enemyWinTimes, cd)
        
    end
end

local self = nil

function SoloHud:init()
    self.node = DisplayNode.New("SoloHud")
    XmdsUISystem.SetNodeFullScreenSize(self.node)
    self.xmlNode = XmdsUISystem.CreateFromFile("xmds_ui/solo/solo_match.gui.xml");
    local r = GameUtil.OR(HudManagerU.HUD_TOP, HudManagerU.HUD_RIGHT)
    HudManagerU.Instance:InitAnchorWithNode(self.xmlNode, r);
    self.node:AddChild(self.xmlNode)
    HudManagerU.Instance:AddChild(self.node)

    self.winLabel = self.xmlNode:FindChildByEditName("lb_win", true)
    self.timeLabel = self.xmlNode:FindChildByEditName("lb_time", true)
    self.fightPointLabel0 = self.xmlNode:FindChildByEditName("lb_point", true)
    self.fightPointLabel1 = self.xmlNode:FindChildByEditName("lb_epoint", true)

    self.defaultTime = self.timeLabel.Text

    self.fightPoint0 = 0
    self.fightPoint1 = 0
    self.beginTime = os.time()
    self.timer = Timer.New(self._self_onTimerUpdate, 1, -1)

    self.myWinTimes = 0
    self.enemyWinTimes = 0

    self.isPlayer0 = nil
    
    self:reset()

    if SoloAPI.getVsPlayInfo() ~= nil and SoloAPI.getVsPlayInfo().s2c_isRobot then
        local mainHud = HudManagerU.Instance:GetHudUI("MainHud")
        local tb_autofight = mainHud:FindChildByEditName("tb_autofight", true)
        
        Util.showUIEffect(tb_autofight,52)
    end
end

function SoloHud:reset()
    self.myWinTimes = 0
    self.enemyWinTimes = 0
    self:updateFightPoint0(0)
    self:updateFightPoint1(0)
    self:updateWinTimes(0, 0)
    

    self.isPlayer0 = nil
    self.timeLabel.Text = self.defaultTime 
    

    EventManager.Subscribe("Event.EnvironmentVarChange", self._self_onEnvironmentChange)
    EventManager.Subscribe("Event.Scene.ChangeFinish", self._self_onZoneLayerInit)
end

function SoloHud:onZoneLayerInit(eventname,params)
    self.isPlayer0 = DataMgr.Instance.UserData.Force == 2
    local roundTimes = GameUtil.GetEnvironmentVar("roundtime")
    local playerPointKey0 = (self.isPlayer0 and "player0point") or "player1point"
    local fightPoint0 = GameUtil.GetEnvironmentVar(playerPointKey0)
    local playerPointKey1 = (self.isPlayer0 and "player1point") or "player0point"
    local fightPoint1 = GameUtil.GetEnvironmentVar(playerPointKey1)
    
    self:updateWinTimes(0, 0)
    self:updateFightPoint0(fightPoint0)
    self:updateFightPoint1(fightPoint1)
end

function SoloHud:onEnvironmentChange(eventname,params)
    self.isPlayer0 = DataMgr.Instance.UserData.Force == 2
    local key = params.key
    if key == "battle_start_time" then
        self.timeLabel.Text = tostring(params.value)
    elseif key == "player0point" then
        if self.isPlayer0 then
            self:updateFightPoint0(params.value)
        else
            self:updateFightPoint1(params.value)
        end
    elseif key == "player1point" then
        if self.isPlayer0 then
            self:updateFightPoint1(params.value)
        else
            self:updateFightPoint0(params.value)
        end
    elseif key == "zhengying00" then
        local myWinTimes = self.isPlayer0 and params.value or self.myWinTimes
        local enemyWinTimes = self.isPlayer0 and self.enemyWinTimes or params.value
        self:updateWinTimes(myWinTimes, enemyWinTimes)
    elseif key == "zhengying01" then
        local myWinTimes = not self.isPlayer0 and params.value or self.myWinTimes
        local enemyWinTimes = not self.isPlayer0 and self.enemyWinTimes or params.value
        self:updateWinTimes(myWinTimes, enemyWinTimes)
    
        
        
    end
    if SoloAPI.getVsPlayInfo() == nil then
        SoloAPI.requestRivalInfo()
    end
end

function SoloHud:updateWinTimes(myWinTimes, enemyWinTimes)
    self.myWinTimes = myWinTimes
    self.enemyWinTimes = enemyWinTimes
    self.winLabel.Text = string.format("%s:%s", myWinTimes, enemyWinTimes)
end

function SoloHud:updateRoundTimes(roundTimes)
    if roundTimes > MaxRoundTimes then
        roundTimes = MaxRoundTimes
    end
    self.winLabel.Text = string.format("%s/%s", roundTimes, MaxRoundTimes)
end

function SoloHud:resetTime()
    self.timeLabel.Text = "0"
end

function SoloHud:updateFightPoint0(fightPoint)
    self.fightPoint0 = fightPoint
    self.fightPointLabel0.Text = tostring(fightPoint)
end

function SoloHud:updateFightPoint1(fightPoint)
    self.fightPoint1 = fightPoint
    self.fightPointLabel1.Text = tostring(fightPoint)
end

function SoloHud:onTimerUpdate(dt)
    local time = math.floor(os.time() - self.beginTime)
    self.timeLabel.Text = tostring(time)
end

function SoloHud.get()
    return self, (self and self.node) or nil
end

function SoloHud.getOrCreate()
    if self then return self, self.node end
    self = {}
    setmetatable(self, SoloHud)
    self:init()
end

function SoloHud.destroy()
    if self and self.node then
        local mainHud = HudManagerU.Instance:GetHudUI("MainHud")
        local tb_autofight = mainHud:FindChildByEditName("tb_autofight", true)
        Util.clearUIEffect(tb_autofight,52)
        
        self.node:RemoveFromParent(true)
        self.node = nil
        self = nil
    end
end

return SoloHud

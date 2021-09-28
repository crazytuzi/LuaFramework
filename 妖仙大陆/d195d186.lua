local Util = require "Zeus.Logic.Util"
local SoloAPI = require "Zeus.Model.Solo"
local ServerTime = require "Zeus.Logic.ServerTime"

local SoloRoundOverUI = {
    menu = nil
}
Util.WrapOOPSelf(SoloRoundOverUI)

function SoloRoundOverUI:init(tag, params)
    self.menu = LuaMenuU.Create("xmds_ui/solo/solo_war.gui.xml", tag)
    local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    self.menu:SetFullBackground(lrt)
    self.menu.ShowType = UIShowType.Cover

    self.myScoreLabel = self.menu:GetComponent("lb_point1")
    self.enemyScoreLabel = self.menu:GetComponent("lb_point2")
    self.timeLabel = self.menu:GetComponent("tb_next")
    self.nextText = self.timeLabel.Text

    
    
    
    

    self.canvases = {
        self.menu:GetComponent("lb_win"),
        self.menu:GetComponent("lb_lose"),
        self.menu:GetComponent("lb_peace"),
    }

    self.menu:SubscribOnEnter(self._self_onEnter)
    self.menu:SubscribOnExit(self._self_onExit)
    self.menu:SubscribOnDestory(self._self_onDestroy)

    self.timer = Timer.New(self._self_onTimerUpdate, 1, -1)
    self.cd = 0
end

function SoloRoundOverUI:onTimerUpdate(dt)
    self.endTime = self.endTime - 1
    self.timeLabel.Text = tostring(self.endTime) .. self.nextText
    if self.endTime <= 0 then
        self.menu:Close()
    end
end

function SoloRoundOverUI:setData(winType, myWinTimes, enemyWinTimes, cd)
    self.myScoreLabel.Text = tostring(myWinTimes)
    self.enemyScoreLabel.Text = tostring(enemyWinTimes)
    for k,v in pairs(self.canvases) do
        v.Visible = winType == k
    end
    self.endTime = cd
    self.timeLabel.Text = tostring(self.endTime).. self.nextText
    self.timer:Start()

    local cvs_play1 = self.menu:GetComponent("cvs_play1")
    local cvs_play2 = self.menu:GetComponent("cvs_play2")
    local ib_head1 = cvs_play1:FindChildByEditName("ib_head", true)
    local lb_lv1 = cvs_play1:FindChildByEditName("lb_lv", true)
    local lb_playname1 = cvs_play1:FindChildByEditName("lb_playname",true)
    local ib_head2 = cvs_play2:FindChildByEditName("ib_head", true)
    local lb_lv2 = cvs_play2:FindChildByEditName("lb_lv", true)
    local lb_playname2 = cvs_play2:FindChildByEditName("lb_playname",true)

    lb_lv1.Text = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
    Util.SetHeadImgByPro(ib_head1,DataMgr.Instance.UserData.Pro)    
    lb_playname1.Text = DataMgr.Instance.UserData.Name

    local data = SoloAPI.getVsPlayInfo()
    if data then
        print("SoloRoundOverUI  vs pro == " .. data.s2c_vsPlayerPro)
        Util.SetHeadImgByPro(ib_head2,data.s2c_vsPlayerPro)
        lb_lv2.Text = data.s2c_vsPlayerLevel
        lb_playname2.Text = data.s2c_vsPlayerName
    end
end

function SoloRoundOverUI:onEnter()
end
function SoloRoundOverUI:onExit()
    self.timer:Stop()
end

function SoloRoundOverUI:onDestroy()

    self.menu = nil
    
    setmetatable(self, nil)
    for k,v in pairs(self) do
        self[k] = nil
    end
end

local function Create(tag, params)
    local ui = {}
    setmetatable(ui, SoloRoundOverUI)
    ui:init(tag, params)
    return ui
end

return {Create = Create}

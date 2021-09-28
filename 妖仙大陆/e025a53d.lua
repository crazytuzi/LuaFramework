local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local FubenAPI = require "Zeus.Model.Fuben"
local FubenUtil = require "Zeus.UI.XmasterFuben.FubenUtil"

local State = FubenUtil.EnterFubenState

local self = {
    menu = nil,
}

local function onMemberStateChange(evtName, data)
    if not self.menu then return end
    local i, v = table.indexOfKey(self.teamList, "id", data.playerId)
    if v then
        local state = (data.isReady and State.Accept) or State.Reject
        FubenUtil.setTeamMemberState(self.teamHeads[i], state)
        self.teamMemberStateMap[data.playerId] = state
    end
end

local function OnHandUpClose(evtName, data)
    if not string.empty(data.msg) then
        GameAlertManager.Instance:ShowNotify(data.msg)
    end
    self.menu:Close()
end

local function UpdateBtnStatus()
    if self.isLeader == true then
        self.btn_cancle.Text = Util.GetText(TextConfig.Type.FUBEN, "cancelTime", self.cd)
    else
        self.btn_giveup.Text = Util.GetText(TextConfig.Type.FUBEN, "giveUpTime", self.cd)
    end
end

local function onReadyCancelBtnClick(sender)
    self.sendReq = true

    if sender == self.btn_giveup then
        FubenAPI.requestReplyEnterFuben(false, self.fubenId)
        self.menu:Close()
    elseif sender == self.btn_ready then
        self.btn_ready.Enable = false
        self.btn_ready.IsGray = true
        self.btn_giveup.Enable = false
        self.btn_giveup.IsGray = true
        FubenAPI.requestReplyEnterFuben(true, self.fubenId)
    elseif sender == self.btn_cancle then
        FubenAPI.requestReplyEnterFuben(false, self.fubenId)
        self.menu:Close()
    end
end

local function onTimerUpdate()
    self.cd = self.cd - 1
    if self.cd >= 0 then
        UpdateBtnStatus()
    else
        GameAlertManager.Instance:ShowFloatingTips(Util.GetText(TextConfig.Type.FUBEN, "someOneGiveUp"))
        self.timer:Stop()
        self.menu:Close()
    end
    local cd = self.fullCd - self.cd
    if cd >= 3 and self.tbn_gou.IsChecked and not self.sendReq then
        onReadyCancelBtnClick(self.btn_ready)
    end
end

local function InitBtnStatus()
    local staticVo = FubenAPI.getStaticFubenVo(self.fubenId)
    self.lb_title_name.Text = staticVo.Name .. "-" .. FubenUtil.GetFubenHardText(staticVo.HardModel)

    self.btn_ready.Visible = not self.isLeader
    self.btn_ready.Enable = true
    self.btn_ready.IsGray = false
    self.btn_giveup.Visible = not self.isLeader
    self.btn_giveup.Enable = true
    self.btn_giveup.IsGray = false
    self.btn_cancle.Visible = self.isLeader
    self.btn_cancle.Enable = true
    self.btn_cancle.IsGray = false

    UpdateBtnStatus()
end

local function showHead(teamList, leaderId)
    self.teamList = teamList
    for i, v in ipairs(self.teamHeads) do
        FubenUtil.setTeamMemberHead(v, self.teamList[i])
        if self.teamList[i] and i <= 5 then
            local isLeader = self.teamList[i].id == leaderId
            if isLeader then
                self.teamMemberStateMap[self.teamList[i].id] = State.Accept
            end
            local state = (isLeader and State.Accept) or State.Wait
            FubenUtil.setTeamMemberState(v, state)
        end
    end
end

local function setInfo(param, fubenId, cd, leaderId, teamList)
    self.fubenId = fubenId
    self.cd = cd
    self.fullCd = cd
    self.teamMemberStateMap = {}
    self.isLeader = DataMgr.Instance.UserData.RoleID == leaderId
    InitBtnStatus()
    showHead(teamList, leaderId)

    EventManager.Subscribe("Event.Fuben.MemeberEnterStateChange", onMemberStateChange)
    EventManager.Subscribe("Event.Fuben.HandUpClose", OnHandUpClose)

    self.timer:Start()

    self.cvs_tip_repeat.Visible = not self.isLeader
end

local function OnEnter()
    self.sendReq = false
    self.tbn_gou.IsChecked = DataMgr.Instance.TeamData.AutoReady
end

local function OnExit()
    EventManager.Unsubscribe("Event.Fuben.MemeberEnterStateChange", onMemberStateChange)
    EventManager.Unsubscribe("Event.Fuben.HandUpClose", OnHandUpClose)
    if self.timer then
        self.timer:Stop()
    end
end

local function InitUI()
    local UIName = {
        "btn_giveup",
        "btn_ready",
        "btn_cancle",

        "lb_title",
        "lb_title_name",

        "cvs_desc",
        "cvs_head",

        "cvs_tip_repeat",
        "tbn_gou",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.btn_giveup.TouchClick = function(sender)
        onReadyCancelBtnClick(sender)
    end
    self.btn_ready.TouchClick = function(sender)
        onReadyCancelBtnClick(sender)
    end
    self.btn_cancle.TouchClick = function(sender)
        onReadyCancelBtnClick(sender)
    end

    self.tbn_gou.TouchClick = function(sender)
        DataMgr.Instance.TeamData.AutoReady = self.tbn_gou.IsChecked
        if self.tbn_gou.IsChecked and not self.sendReq then
            onReadyCancelBtnClick(self.btn_ready)
        end
    end

    self.teamHeads = {}
    for i=1,5 do
        self.teamHeads[i] = self.cvs_head:Clone()
        self.teamHeads[i].Position2D = Vector2.New(self.cvs_head.Position2D.x+125*(i-1) ,self.cvs_head.Position2D.y)
        self.cvs_desc:AddChild(self.teamHeads[i])
    end
    self.cvs_head.Visible = false

    self.teamList = nil
    self.teamMemberStateMap = nil
    self.fubenId = nil
    self.cd = 0
    self.fullCd = 0
    self.timer = Timer.New(onTimerUpdate, 1, -1)
end

local function InitCompnent(params)
    InitUI()

    local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    self.menu:SetFullBackground(lrt)

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = {}
    end)
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/dungeon/dungeon_teamEnter.gui.xml", GlobalHooks.UITAG.GameUIFubenWaitEnter)
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

_M.setInfo = setInfo

return {Create = Create, initial = initial}

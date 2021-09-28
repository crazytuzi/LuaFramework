local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local DemonTower = require "Zeus.Model.DemonTower"
local ServerTime = require "Zeus.Logic.ServerTime"
local FubenApi = require "Zeus.Model.Fuben"

local self = { }

local function onTimerUpdate(dt)
    self.time = self.time -1
    if self.time <=0 then
        self.time = nil
        self.menu:Close()
    else
        self.lb_num.Text = self.time
    end
end

local function OnExit()
    self.timer:Stop()
end

local function OnEnter()
    self.menu.Visible = false
    self.timer:Start()
end


function _M:setData(data)
    self.menu.Visible =true
    self.time = data.time
    self.lb_num.Text = self.time
    local towerData = data.demonTowerFloorInfo
    if data.type == 0 then
        self.lb_result.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/solo.xml|solo|9", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
        self.lb_time_now.Text = ServerTime.GetTimeStr(data.currentTime)        
        if data.newRecordFloor then
            self.lb_floor_now.FontColorRGBA = 0x009966ff  
        end
        if data.newRecordTime then
            self.lb_time_fastest.FontColorRGBA = 0x009966ff  
        end
        self.ib_floor_new.Visible = data.newRecordFloor
        self.ib_time_new.Visible = data.newRecordTime
        self.lb_time_fastest.Text = ServerTime.GetTimeStr(towerData.fastPlayerTime)
        self.lb_tips.Text = Util.GetText(TextConfig.Type.FUBEN, "secondsEnter")
    else
        self.lb_result.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/solo.xml|solo|8", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
        self.lb_time_now.Text = ""
        self.lb_time_fastest.Text = ""
        self.lb_tips.Text = Util.GetText(TextConfig.Type.FUBEN, "secondsExit")
    end
    self.lb_floor_now.Text = data.level
    self.lb_floor_highest.Text = data.myMaxFloorId

    if data.itemLine2 ~= nil then
        self.sp_reward:Initialize(self.cvs_icon.Width+10, self.cvs_icon.Height, 1, #data.itemLine2, self.cvs_icon,
           function(x, y, cell)
           local index = x + 1
           local code = data.itemLine2[index]
           cell.Enable = true
           cell.EnableChildren = true
           local detail = ItemModel.GetItemDetailByCode(code.itemCode)
           local itshow = Util.ShowItemShow(cell,detail.static.Icon,detail.static.Qcolor,code.itemNum,true)
           Util.NormalItemShowTouchClick(itshow,code.itemCode,false)
         end,
         function()
    
         end
        )
    end

    self.btn_restart.TouchClick = function()
         if DataMgr.Instance.TeamData.HasTeam and DataMgr.Instance.TeamData.MemberCount > 1 then
            local tips = Util.GetText(TextConfig.Type.FUBEN, 'cannotReqWithTeam')
            GameAlertManager.Instance:ShowNotify(tips)
            return
        else
            DemonTower.StartDemonTowerRequest(towerData.floorId)
        end
    end

    self.btn_away.TouchClick = function()
        self.menu:Close()
        FubenApi.requestLeaveFuben()
    end

end

local function InitUI()
    local UIName = {
        "btn_close",
        "lb_result",
        "lb_floor_now",
        "lb_time_fastest",
        "lb_floor_highest",
        "lb_time_now",
        "ib_floor_new",
        "ib_time_new",
        "cvs_icon",
        "sp_reward",
        "btn_restart",
        "btn_away",
        "lb_num",
        "lb_tips",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.btn_close.TouchClick = function(sender)
        self.menu:Close()
    end

    self.timer = Timer.New(onTimerUpdate, 1, -1)
end

local function InitCompnent(tag,params)
    self.menu = LuaMenuU.Create("xmds_ui/demontower/jiesuan3.gui.xml", tag)
    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end


local function Create(tag,params)
    setmetatable(self, _M)
    InitCompnent(tag,params)
    return self
end

return {Create = Create}

local _M = {}
_M.__index = _M



local DaoyouModel   = require "Zeus.Model.Daoyou"

local self = {
    menu = nil,
}

local function  RefreshCellDetail(cell, data, index)
    cell:FindChildByEditName("lb_player_name2", true).Text = data.playerName
    cell:FindChildByEditName("lb_now_all2", true).Text = data.reciveNumber
end

local function InitRebateDetail(detail)
    local count = 0
    if detail.memRebaeReciveInfo then
        count = #detail.memRebaeReciveInfo
    end
    self.lb_player_name1.Text = detail.playerName
    self.lb_now_all1.Text = detail.todaySendRebate
    self.sp_single2:Initialize(
            self.cvs_detail1.Width + 0, 
            self.cvs_detail1.Height + 0, 
            count,
            1,
            self.cvs_detail1, 
            function(x, y, cell)
                local index = y + 1
                local data = detail.memRebaeReciveInfo[index]
                RefreshCellDetail(cell, data, index)
            end,
            function() end
        )

    self.cvs_single2.Visible = true
end

local function RefreshCellData(cell, data, index)
    cell:FindChildByEditName("lb_player_name", true).Text = data.playerName
    cell:FindChildByEditName("lb_accumulation", true).Text = data.totalSendRebate
    cell:FindChildByEditName("lb_today_num", true).Text = data.todaySendRebate
    cell:FindChildByEditName("btn_detail", true).TouchClick = function()
        InitRebateDetail(data)
    end
end

local function OpenSetNameUI()
    local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialDaoqunSetName,0)
    obj.SetCall(function (str)
        self.lb_name.Text = str
    end)
end

local function RefreshUI(rebateList)
    local count = 0
    if rebateList.ri then
        count = #rebateList.ri
    end
    self.lb_all_num.Text = rebateList.selfTotalReciveRebate
    self.lb_now_all.Text = rebateList.selfTodayReciveRebate
    self.sp_see:Initialize(
            self.cvs_single.Width + 0, 
            self.cvs_single.Height + 0, 
            count,
            1,
            self.cvs_single, 
            function(x, y, cell)
                local index = y + 1
                local data = rebateList.ri[index]
                RefreshCellData(cell, data, index)
            end,
            function() end
        )
end

local function OnExit()
    self.cvs_single2.Visible = false
end

local function OnEnter()
    DaoyouModel.RebateRequest(function (data)
        RefreshUI(data)
    end)
end

local function InitUI()
    
    local UIName = {
        "btn_close",
        "cvs_main",
        "sp_see",
        "cvs_single",
        "lb_all_num",
        "lb_now_all",
        "btn_help",

        "cvs_single2",
        "lb_player_name1",
        "lb_now_all1",
        "sp_single2",
        "cvs_detail1",
        "cvs_intrduce",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

local function InitCompnent()
    InitUI()

    self.cvs_single.Visible = false
    self.cvs_single2.Visible = false
    self.cvs_detail1.Visible = false
    self.cvs_intrduce.Visible = false

    self.btn_close.TouchClick = function ()
        self.menu:Close()
    end

    self.cvs_single2.TouchClick = function ()
        self.cvs_single2.Visible = false
    end

    self.btn_help.event_PointerDown = function (sender)
        self.cvs_intrduce.Visible = true
    end
    self.btn_help.event_PointerUp = function (sender)
        self.cvs_intrduce.Visible = false
    end

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
    self.menu = LuaMenuU.Create("xmds_ui/social/dao_rebate.gui.xml", GlobalHooks.UITAG.GameUISocialDaoqunRebate)
    InitCompnent()

    self.menu.Enable = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    self.menu.mRoot.IsInteractive = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function (sender)
        if self then
            self.cvs_single2.Visible = false
        end
    end})
    return self.menu
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end


return {Create = Create}

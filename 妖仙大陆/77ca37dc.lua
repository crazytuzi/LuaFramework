local Player = require "Zeus.Model.Player"
local VipAPI = require "Zeus.Model.Vip"
local RechargeAPI = require "Zeus.Model.Recharge"
local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"
local Util      = require "Zeus.Logic.Util"

local _M = {}
_M.__index = _M
local self = {menu = nil,ResidueDay=nil,BuyMonthCard=nil,BuyExaltedCard=nil,
    Recharge=nil,OK=nil,Cancel=nil,}

local function GetPrizeHaveGet(vipType,VipGiftInfo)
    for i = 1,#VipGiftInfo do
        if VipGiftInfo[i].type == vipType then
            return VipGiftInfo[i].flag
        end
    end
    return 1
end

local function UpdateCardInfo(self,VipGiftInfo)
    
    local vip = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.VIP)
    self.btn_price.Visible = (vip ~= 1 and vip ~= 3) 
    self.btn_continue.Visible = (vip == 1 or vip == 3)
    self.btn_receive.Visible = (vip == 1 or vip == 3)
    if GetPrizeHaveGet(1,VipGiftInfo.datas) == 1 then 
        self.btn_receive.IsGray = true
        self.btn_receive.Enable = false
        self.lb_bj_receive.Visible = false 
    else
        self.btn_receive.IsGray = false
        self.btn_receive.Enable = true
        self.lb_bj_receive.Visible = self.btn_receive.Visible 
    end

    self.btn_price1.Visible = (vip ~= 2 and vip ~= 3) 
    self.btn_receive1.Visible = (vip == 2 or vip == 3)
    if GetPrizeHaveGet(2,VipGiftInfo.datas) == 1 then 
        self.btn_receive1.IsGray = true
        self.btn_receive1.Enable = false
        self.lb_bj_receive1.Visible = false 
    else
        self.btn_receive1.IsGray = false
        self.btn_receive1.Enable = true
        self.lb_bj_receive1.Visible = self.btn_receive1.Visible  
    end

    self.lb_validperiod.Text = string.format(self.ResidueDay,Mathf.Round(VipGiftInfo.s2c_remainTime/(60*60*24))) 
    self.lb_validperiod.Visible = (VipGiftInfo.s2c_remainTime > 0)

    
    Util.clearAllEffect(self.ib_crad_icon)
    Util.clearAllEffect(self.ib_crad_icon1)
    if vip == 1 or vip == 3 then
        Util.showUIEffect(self.ib_crad_icon,14)  
    else
        Util.showUIEffect(self.ib_crad_icon,13)  
    end
    if vip == 2 or vip == 3 then
        Util.showUIEffect(self.ib_crad_icon1,16) 
    else
        Util.showUIEffect(self.ib_crad_icon1,15) 
    end
end

local ui_names = {
    {name = "cvs_month"},
    {name = "lb_validperiod"},
    {name = "ib_received"},
    {name = "ib_recommend"},
    {name = "ib_new"},
    {name = "lb_bj_receive"},
    {name = "btn_continue",click = function(self)
        
        
        
        

        
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            self.BuyMonthCard,
            self.OK,
            self.Cancel,
            self.Recharge,
            nil,
            function()
                RechargeAPI.prepaidOrderIdRequest(1,1,function(orderId,app_notify_url) 
                    
                    local cardInfo = GlobalHooks.DB.Find('Card',1)
                    SDKWrapper.Instance:Pay(1,cardInfo.PayMoneyAmount,cardInfo.Name,orderId,app_notify_url)
                    print('orderId = ' ..orderId)
                end)
            end,
            nil)
        
    end},
    {name = "btn_receive",click = function(self)
        
        VipAPI.requestDailyReward(1,function () 
            self:Open()
        end)
    end},
    {name = "btn_price",click = function(self)
        
        
        
        

        
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            self.BuyMonthCard,
            self.OK,
            self.Cancel,
            self.Recharge,
            nil,
            function()
                RechargeAPI.prepaidOrderIdRequest(1,1,function(orderId,app_notify_url) 
                
                local cardInfo = GlobalHooks.DB.Find('Card',1)
                SDKWrapper.Instance:Pay(1,cardInfo.PayMoneyAmount,cardInfo.Name,orderId,app_notify_url)
                    print('orderId = ' ..orderId)
                end)
            end,
            nil)
        
    end},
    {name = "btn_look",click = function(self)
        self.cvs_tip123.Visible = true
        if self.cvs_tips1.Visible then
            self.cvs_tips1.Visible = false
        else
            self.cvs_tips1.Visible = true
        end
    end},
    {name = "cvs_year"},
    {name = "ib_received1"},
    {name = "ib_recommend1"},
    {name = "ib_new1"},
    {name = "lb_bj_receive1"},
    {name = "btn_receive1",click = function(self)
        
        VipAPI.requestDailyReward(2,function () 
            self:Open()
        end)
    end},
    {name = "btn_price1",click = function(self)
        
        
        
        
        

        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            self.BuyExaltedCard,
            self.OK,
            self.Cancel,
            self.Recharge,
            nil,
            function()
                RechargeAPI.prepaidOrderIdRequest(2,1,function(orderId,app_notify_url) 
                
                local cardInfo = GlobalHooks.DB.Find('Card',2)
                 SDKWrapper.Instance:Pay(2,cardInfo.PayMoneyAmount,cardInfo.Name,orderId,app_notify_url)
                    print('orderId = ' ..orderId)
                end)
            end,
            nil)
        
    end},
    {name = "btn_look1",click = function(self)
        self.cvs_tip123.Visible = true
        if self.cvs_tips2.Visible then
            self.cvs_tips2.Visible = false
        else
            self.cvs_tips2.Visible = true
        end
    end},
    {name = "cvs_tip123"},
    {name = "cvs_tips1"},
    {name = "cvs_tips2"},
    {name = "ib_crad_icon"},
    {name = "ib_crad_icon1"},

}

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.TouchClick = function()
                    ui.click(tbl)
                end
            end
        end
    end
end

local function Notify(status,userdata)
    if userdata:ContainsKey(status, UserData.NotiFyStatus.DIAMOND) then
        
        VipAPI.requestVipInfo(function (VipGiftInfo)
            UpdateCardInfo(self,VipGiftInfo)
        end)
    end
end

local function InitUI(self)
    self.OK = Util.GetText(TextConfig.Type.SHOP, "OK")
    self.Cancel = Util.GetText(TextConfig.Type.SHOP, "Cancel")
    self.ResidueDay = Util.GetText(TextConfig.Type.SHOP, "ResidueDay")
    self.BuyMonthCard = Util.GetText(TextConfig.Type.SHOP, "BuyMonthCard")
    self.BuyExaltedCard = Util.GetText(TextConfig.Type.SHOP, "BuyExaltedCard")
    self.Recharge = Util.GetText(TextConfig.Type.SHOP, "Recharge")
end

local function InitComponent(self,cvs)
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/mall/month_card.gui.xml')
    self.menu.Enable = false
    self.menu.Visible = false
    InitUI(self)
    initControls(self.menu, ui_names, self)
    cvs:AddChild(self.menu)
    self.cvs_tips1.Visible = false
    self.cvs_tips2.Visible = false
    self.cvs_tip123.Enable = true
    self.cvs_tip123.IsInteractive = true
    self.cvs_tip123.event_PointerClick = function()
        if self.cvs_tips1.Visible then
            self.cvs_tips1.Visible = false
        end
        if self.cvs_tips2.Visible then
            self.cvs_tips2.Visible = false
        end
        self.cvs_tip123.Visible = false
    end
end

function _M:Open()
    self.menu.Visible = true
    DataMgr.Instance.UserData:AttachLuaObserver(503, {Notify = Notify})
    VipAPI.requestVipInfo(function (VipGiftInfo)
        UpdateCardInfo(self,VipGiftInfo)
    end)
end

function _M:Close()
    self.menu.Visible = false
    DataMgr.Instance.UserData:DetachLuaObserver(503)
end

function _M.Create(parent,cvs)
    
    setmetatable(self,_M)
    self.parent = parent
    InitComponent(self,cvs)
    return self
end

return _M


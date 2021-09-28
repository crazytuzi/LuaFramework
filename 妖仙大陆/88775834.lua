


local Helper = require 'Zeus.Logic.Helper'
local Util = require 'Zeus.Logic.Util'
local PageMall = require "Zeus.UI.XmasterShop.PageMall"
local PageCard = require "Zeus.UI.XmasterShop.PageCard"
local PagePay = require "Zeus.UI.XmasterShop.PagePay"
local _M = {
    selectTbt = nil,funcPages = nil,WaitOrder=nil,FinishOrder=nil,
}
_M.__index = _M

local ui_names = {
    {name = "cvs_type"},
    {name = "tbt_mall"},
    {name = "tbt_card"},
    {name = "tbt_recharge"},
    {name = "lb_title1"},
    {name = "lb_title2"},
    {name = "lb_title3"},
    {name = "lb_bj_mall"},
    {name = "lb_bj_card"},
    {name = "btn_close",click = function(self)
        self:Close()
    end},
}

local function SetShopmallFlag(self)
    self.lb_bj_mall.Visible = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_SHOPMALL) ~= 0
end

local function SetVIPFlag(self)
    self.lb_bj_card.Visible = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_VIP) ~= 0
end

function _M:CloseAllFuncs()
    for k,v in pairs(self.funcPages) do
        v:Close()
    end
end
 
local function openPageMall(self)
    self.funcPages[self.tbt_mall]:Open()
end

local function openPageCard(self)
    self.funcPages[self.tbt_card]:Open()
end

local function openPageRecharge(self)
    self.funcPages[self.tbt_recharge]:Open()
end

local function OnCategoryChecked(self,sender)
    self.selectTbt = sender
    self:CloseAllFuncs()
    if sender == self.tbt_mall then
        openPageMall(self)
    elseif sender == self.tbt_card then
        openPageCard(self)
    elseif sender == self.tbt_recharge then
        openPageRecharge(self)
    end
    self.lb_title1.Visible = (sender == self.tbt_mall)
    self.lb_title2.Visible = (sender == self.tbt_card)
    self.lb_title3.Visible = (sender == self.tbt_recharge)
end

local function OnEnterMall(self,type)
    if type then
        local subs = string.split(type, '_')
        if subs[1] == "ticket" then
            self.funcPages[self.tbt_mall]:setParam("ticket",subs)
        else
            self.funcPages[self.tbt_mall]:setParam("diamond",subs)
        end
    else
        self.funcPages[self.tbt_mall]:setParam("diamond")
    end
    Util.ChangeMultiToggleButtonSelect(self.tbt_mall, self.tbt_operates)
end

local function OnEnterCard(self)
    Util.ChangeMultiToggleButtonSelect(self.tbt_card, self.tbt_operates)
end

local function OnEnterPay(self)
    Util.ChangeMultiToggleButtonSelect(self.tbt_recharge, self.tbt_operates)
end

local function OnPayCallback(evtName,params)
    if params.resultCode == 7 then 
        GameAlertManager.Instance:ShowNotify(self.WaitOrder)
    else
        GameAlertManager.Instance:ShowNotify(self.FinishOrder)
    end

    
end

function _M:Close()
    self.menu:Close()
    EventManager.Unsubscribe('Event.HuLaiSDK.payCallback',OnPayCallback)
end





function _M:OnEnter()
    if string.empty(self.menu.ExtParam) then
        self.menu.ExtParam = "mall"    
    end
    if not string.empty(self.menu.ExtParam) then
        self.args = string.split(self.menu.ExtParam, '|')
        if self.args[1] == "mall" then
            OnEnterMall(self,self.args[2])
        elseif self.args[1] == "card" then
            OnEnterCard(self)
        elseif self.args[1] == "pay" then
            OnEnterPay(self)
        end
    else
        Util.ChangeMultiToggleButtonSelect(self.tbt_mall, self.tbt_operates)
    end
    self.menu.ExtParam = "mall" 

    EventManager.Subscribe("Event.HuLaiSDK.payCallback", OnPayCallback)

    DataMgr.Instance.FlagPushData:AttachLuaObserver(GlobalHooks.UITAG.GameUIShop, {Notify = function(status, subject)
        if subject == DataMgr.Instance.FlagPushData then
            if self.menu ~= nil then
                if status == FlagPushData.FLAG_SHOPMALL then
                    SetShopmallFlag(self)
                end
                if status == FlagPushData.FLAG_VIP then
                    SetVIPFlag(self)
                end
            end
        end   
    end})

    SetShopmallFlag(self)
    SetVIPFlag(self)
end

function _M:OnExit()
    DataMgr.Instance.FlagPushData:DetachLuaObserver(GlobalHooks.UITAG.GameUIShop)
end

function _M:OnDispose()

end

function _M:OnDestory()

end

local function InitComponent(self,tag,param)
    self.menu = LuaMenuU.Create("xmds_ui/mall/main.gui.xml", tag)
    self.menu.Enable = false
    self.WaitOrder = Util.GetText(TextConfig.Type.SHOP, "WaitOrder")
    self.FinishOrder = Util.GetText(TextConfig.Type.SHOP, "FinishOrder")
    self.menu.ShowType = UIShowType.HideBackHud
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.menu:SubscribOnExit( function()
        self:OnExit()
    end )
    self.menu:SubscribOnEnter( function()
        self:OnEnter()
    end )
    self.menu:SubscribOnDestory( function()
        self:OnDestory()
    end )
    self.funcPages = {}
    self.funcPages[self.tbt_mall] = PageMall.Create(self,self.cvs_type)
    self.funcPages[self.tbt_card] = PageCard.Create(self,self.cvs_type)
    self.funcPages[self.tbt_recharge] = PagePay.Create(self,self.cvs_type)
    self.tbt_operates = {self.tbt_mall,self.tbt_card,self.tbt_recharge}
    Util.InitMultiToggleButton( function(sender)
        OnCategoryChecked(self, sender)
    end , nil, self.tbt_operates)
end

function _M.Create(tag,param)
    local self = {}
    setmetatable(self,_M)
    InitComponent(self,tag,param)
    return self
end

return _M


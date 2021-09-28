
local Helper = require 'Zeus.Logic.Helper'
local Util = require 'Zeus.Logic.Util'
local CurrencyTip = require "Zeus.UI.XmasterBag.CurrencyTip"
local _M = { 
    bag = nil,show_datas = nil,tag = nil
}
_M.__index = _M





function _M:CloseMenu()
    self.menu.Visible = false
    DataMgr.Instance.UserData:DetachLuaObserver(self.tag)
end

function _M:SetBag(bag)
    self.bag = bag
end

local ui_names =
{
    
    { name = 'cvs_rmby' },
    { name = 'cvs_rmby_tie' },
    { name = 'cvs_gold' },
    { name = 'cvs_silver' },
    { name = 'sp_money_function' },
    { name = "cvs_function_single"}
}


local Text = {
    TipsFormat = Util.GetText(TextConfig.Type.ITEM,'moneyTipsFormat')
}

local BASE_CURRENCY_CODE = {
    {code = "diamond",ctrl = "cvs_rmby"},
    {code = "ticket",ctrl = "cvs_rmby_tie"},
    {code = "gold",ctrl = "cvs_silver"},
}

local FUNC_CURRENCY_CODE = {
    "prestige"
}


local STATUS_LIST = {
    
    UserData.NotiFyStatus.DIAMOND,
    
    UserData.NotiFyStatus.TICKET,
    
    UserData.NotiFyStatus.GOLD,
    
    UserData.NotiFyStatus.GOLD,
    
    UserData.NotiFyStatus.GOLD,
    
    UserData.NotiFyStatus.PRESTIGE,
    
    UserData.NotiFyStatus.GOLD,
    
    UserData.NotiFyStatus.GOLD,
}

local function initBaseCurrencyNode(self,ctrl,data)
    ctrl.Enable = true
    ctrl.event_PointerClick = function()
        
        local currency = CurrencyTip.CreateCurrencyData(data)
        self.bag:OpenCurrencyTip(currency)
    end
    local btn_get = ctrl:FindChildByEditName("btn_get",false)
    if (btn_get) then
        btn_get.event_PointerClick = function()
            
            local jump = data.JumpTo
            if jump == 'Charge' then
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop, 0, "pay")
            end
        end
    end
end

local function bindBaseCurrency(self)
    self.show_datas = { }
    local datas = GlobalHooks.DB.Find('Money', {})
    for k,v in pairs(datas) do
        for i = 1,#BASE_CURRENCY_CODE,1 do
            if v.Code == BASE_CURRENCY_CODE[i].code then
                initBaseCurrencyNode(self,self[BASE_CURRENCY_CODE[i].ctrl],v)
                self.show_datas[v.Code] = { cvs = self[BASE_CURRENCY_CODE[i].ctrl], data = v }
            end
        end
    end
end

local function initFuncCurrencyNode(self,ctrl,data)
    local ib_single_icon = ctrl:FindChildByEditName("ib_single_icon",false)
    local lb_single_name = ctrl:FindChildByEditName("lb_single_name",false)
    local ib_single_get = ctrl:FindChildByEditName("ib_single_get",false)
    Util.HZSetImage(ib_single_icon,data.Icon)
    lb_single_name.Text = data.Name
    local cvs_single = ctrl:FindChildByEditName("cvs_single",false)
    cvs_single.event_PointerClick = function()
        
        local currency = CurrencyTip.CreateCurrencyData(data)
        self.bag:OpenCurrencyTip(currency)
    end
end

local function bindFuncCurrency(self)
    local datas = GlobalHooks.DB.Find('Money', {})
    local y = 0
    for k,v in pairs(datas) do
        for i = 1,#FUNC_CURRENCY_CODE,1 do
            if v.Code == FUNC_CURRENCY_CODE[i] then
                local ctrl = self.cvs_function_single:Clone()
                ctrl.X = 0
                ctrl.Y = y
                y = y + ctrl.Height
                initFuncCurrencyNode(self,ctrl,v)
                self.sp_money_function:AddNormalChild(ctrl)
                self.show_datas[v.Code] = { cvs = ctrl, data = v }
            end
        end
    end
end

function _M:Open()
    DataMgr.Instance.UserData:AttachLuaObserver(self.tag, self)
    self.Notify(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData, self)
    self.menu.Visible = true
end

local function setBaseCurrencyValue(cvs, v)
    local lb_number = cvs:FindChildByEditName("lb_number", false)
    if type(v) == 'number' then
        lb_number.Text = Util.NumFormat(v, 3, ',')
    else
        lb_number.Text = tostring(v or 0)
    end
end

local function setFuncCurrencyValue(cvs,v)
    cvs.Visible = true
    local lb_single_number = cvs:FindChildByEditName("lb_single_number",false)
    if type(v) == 'number' then
        lb_single_number.Text = Util.NumFormat(v, 3, ',')
    else
        lb_single_number.Text = tostring(v or 0)
    end
end

local function TryFillValue(self,userdata,cvs,code,status,check_status)
    if userdata:ContainsKey(status, check_status) then
        local v = userdata:GetAttribute(check_status)
        for i = 1,#BASE_CURRENCY_CODE,1 do
            if(BASE_CURRENCY_CODE[i].code == code) then
                setBaseCurrencyValue(cvs,v)
                return
            end
        end
        for i = 1,#FUNC_CURRENCY_CODE,1 do
            if(FUNC_CURRENCY_CODE[i] == code) then
                setFuncCurrencyValue(cvs,v)
                return
            end
        end
    end   
end

function _M.Notify(status, userdata, self)
    for k, v in pairs(self.show_datas) do
        local check_status = userdata:Key2Status(k)
        TryFillValue(self, userdata, v.cvs,v.data.Code ,status, check_status)
    end
end

local ELEMENT_SPACE = 16
local TITLE_SPACE = 20

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

local function InitComponent(self, tag,parent)
    
    self.tag = tag
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/bag/bag_currency.gui.xml')
    self.menu.Enable = false
    initControls(self.menu, ui_names, self)
    if(parent) then
        parent:AddChild(self.menu)
    end
    bindBaseCurrency(self)
    bindFuncCurrency(self)
    self.cvs_function_single.Visible = false
end


function _M.Create(tag,parent)
    local ret = { }
    setmetatable(ret, _M)
    InitComponent(ret, tag,parent)
    return ret
end

return _M

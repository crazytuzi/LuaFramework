


local Util = require "Zeus.Logic.Util"
local SdkPay = require "Zeus.Sdk.SdkPay"
local RechargeAPI = require "Zeus.Model.Recharge"
local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"

local _M = {}
_M.__index = _M
local self = {menu = nil,IsRecharge=nil,OK=nil,Cancel=nil,Recharge=nil,}

function _M:updateFeeItem()
    local item_counts = #self.FeeItem
    self.sp_payinfo.Scrollable:ClearGrid()
    if self.sp_payinfo.Rows <= 0 then
        self.sp_payinfo.Visible = true
        local cs = self.cvs_payinfo.Size2D
        self.sp_payinfo:Initialize(cs.x+15,cs.y,item_counts%4 == 0 and item_counts/4 or item_counts/3 +1,4,self.cvs_payinfo,
        function (gx,gy,node)
            local fItem = self.FeeItem[gy*4 + gx+1]
            if fItem == nil then
                node.Visible = false    
                return
            end
            node.Visible = true
            
            local ib_payinfo = node:FindChildByEditName('ib_payinfo',false)
            Util.HZSetImage(ib_payinfo, fItem.packageIcon)
            Util.showUIEffect(ib_payinfo,23) 

            local ib_cost = node:FindChildByEditName('ib_cost',true)
            local lb_cost_num = node:FindChildByEditName('lb_cost_num',true)
            lb_cost_num.Text = 'X '..fItem.payDiamond

            local ib_tj = node:FindChildByEditName('ib_tj',false)
            ib_tj.Visible = (fItem.payTag == 1)

            local ib_gift = node:FindChildByEditName('ib_gift',false)
            ib_gift.Visible = (fItem.virgin ~= 1)

            local ib_first = node:FindChildByEditName('ib_first',false)
            ib_first.Visible = (fItem.virgin == 1)

            local lb_get_num = node:FindChildByEditName('lb_get_num',false)
            lb_get_num.Text = fItem.nonFirstDiamond
            lb_get_num.Visible = (fItem.virgin ~= 1)

            local lb_first_num = node:FindChildByEditName('lb_first_num',false)
            lb_first_num.Text = fItem.firstDiamond
            lb_first_num.Visible = (fItem.virgin == 1)
            
            local ib_firstbox = node:FindChildByEditName('ib_firstbox',false)
            ib_firstbox.Visible = (fItem.virgin == 1)

            local lb_price = node:FindChildByEditName('lb_price',false)
            lb_price.Text = fItem.packageName

            node.TouchClick = function() 
            
                
                
            

                GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL, 
                string.format(self.IsRecharge,fItem.packageName),
                self.OK,
                self.Cancel,
                self.Recharge,
                nil,
                function()
                    RechargeAPI.prepaidOrderIdRequest(fItem.id,2,function(orderId,app_notify_url) 
                    
                    SDKWrapper.Instance:Pay(fItem.id,fItem.payMoneyAmount,fItem.packageName,orderId,app_notify_url)
                    print('orderId = ' ..orderId)
                    end)
                end,
                nil)
            end
        end,
        function () end)
    else
        self.sp_payinfo.Rows = item_counts
    end
end

local function RequestFeeItem(self)
    RechargeAPI.requestFeeItem(function(FeeItem)
        self.FeeItem = FeeItem or {}
        table.sort(self.FeeItem, function(item1,item2)
            return item1.payDiamond < item2.payDiamond
        end)
        
        self:updateFeeItem()
    end)
end

local function Notify(status,userdata)
    if userdata:ContainsKey(status, UserData.NotiFyStatus.DIAMOND) then
        
        RequestFeeItem(self)
    end
end

function _M:Open()
    self.menu.Visible = true
    RequestFeeItem(self)
    DataMgr.Instance.UserData:AttachLuaObserver(502, {Notify = Notify})
end

local ui_names = {
    {name = "cvs_type"},
    {name = "cvs_payinfo"},
    {name = "sp_payinfo"},
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

local function InItUI(self)
    self.OK = Util.GetText(TextConfig.Type.SHOP, "OK")
    self.Cancel = Util.GetText(TextConfig.Type.SHOP, "Cancel")
    self.IsRecharge = Util.GetText(TextConfig.Type.SHOP, "IsRecharge")
    self.Recharge = Util.GetText(TextConfig.Type.SHOP, "Recharge")
end

local function InitComponent(self,cvs)
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/mall/recharge.gui.xml')
    self.menu.Enable = false
    self.menu.Visible = false
    InItUI(self)
    initControls(self.menu, ui_names, self)
    cvs:AddChild(self.menu)
    self.cvs_payinfo.Visible = false
end

function _M:Close()
    self.menu.Visible = false
    DataMgr.Instance.UserData:DetachLuaObserver(502)
end

function _M.Create(parent,cvs)
    
    setmetatable(self,_M)
    InitComponent(self,cvs)
    return self
end

return _M


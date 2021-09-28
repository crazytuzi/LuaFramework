local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"

local self = {menu = nil}
local zhekouList = {54,52,56,50,48,49,57,53,51}

local function RefreshZheKouIcon(icon, id)
    icon.Visible = id > 0 and id < 10
    if icon.Visible == true then
        Util.HZSetImage2(icon, "#dynamic_n/mall/mall.xml|mall|"..zhekouList[id])
    end
end

local function UpdateItemList(datalist)
    local count = #datalist
    for i=1,3 do
        local node = self.ItemNodeList[i]
        if i <= count then
            local data = datalist[i]
            node.Visible = true
            local ib_zhekou = node:FindChildByEditName("ib_zhekou", true)
            local lb_name = node:FindChildByEditName("lb_name", true)
            local cvs_icon = node:FindChildByEditName("cvs_icon", true)
            local lb_num = node:FindChildByEditName("lb_num", true)
            local lb_price = node:FindChildByEditName("lb_price", true)
            local btn_buy = node:FindChildByEditName("btn_buy", true)
            local ib_buy_flag = node:FindChildByEditName("ib_buy_flag", true)
            local lb_diamond = node:FindChildByEditName("lb_diamond", true)

            RefreshZheKouIcon(ib_zhekou,data.packageScript)

            lb_name.Text = data.packageName
            lb_num.Text = data.packageNum
            lb_num.Visible = false
            local priceStr = "¥".. data.packagePrice/100
            lb_price.Text = priceStr
            btn_buy.Visible = data.packageState == 0
            ib_buy_flag.Visible = data.packageState == 1
            lb_diamond.Text = data.packagePrice/10

            local detail = ItemModel.GetItemDetailByCode(data.packageCode)
            local itshow = Util.ShowItemShow(cvs_icon,detail.static.Icon,detail.static.Qcolor,data.packageNum,true)
            Util.NormalItemShowTouchClick(itshow,data.packageCode,false)

            btn_buy.TouchClick = function (sender)
                GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL, 
                Util.GetText(TextConfig.Type.ACTIVITY, "confirmButGiftBag", priceStr, data.packageNum, data.packageName),
                nil,nil,nil,nil,
                function()
                    ActivityAPI.SuperPackageBuyRequest(data.packageId, function(orderInfo)
                        SDKWrapper.Instance:Pay(data.packageId, data.packagePrice,data.packageName,orderInfo.s2c_orderId,orderInfo.app_notify_url or "")
                    end)
                end,
                nil
                )
            end
        else
            self.ItemNodeList[i].Visible = false
        end
    end
end

local function updateTimeAndDesc(beginTime, endTime, desc)
    self.tb_rule.XmlText = ActivityUtil.GetConfigTimeXml(beginTime, endTime, desc)
end

local function RequestInfo()
    if self.menu then
        ActivityAPI.SuperPackageGetInfoRequest(function(data)
            if self.menu then
                updateTimeAndDesc(data.endTime,data.endTime,data.describe)
                UpdateItemList(data.superPackageAwardInfo or {})
            end
        end)
    end
end

function  _M.OnEnter()
    EventManager.Subscribe("Event.Activity.UpdateCZLB",RequestInfo)
    RequestInfo()
end
function _M.OnExit()
    EventManager.Unsubscribe("Event.Activity.UpdateCZLB",RequestInfo)
end

local ui_names = 
{
    {name = 'tb_rule'},
    {name = 'cvs_type1'},
    {name = 'cvs_type2'},
    {name = 'cvs_type3'},
}

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.event_PointerClick = function()
                ui.click(tbl)
                end
            end
        end
    end
end

local function InitComponent(self,xmlPath)
    self.menu = XmdsUISystem.CreateFromFile(xmlPath)
    initControls(self.menu,ui_names,self)

    self.ItemNodeList = {self.cvs_type1,self.cvs_type2,self.cvs_type3}

    return self.menu
end

local function Create(ActivityID,xmlPath)
    self = {}
    self.ActivityID = ActivityID
    setmetatable(self, _M)
    local node = InitComponent(self,xmlPath)
    return self,node
end

return {Create = Create}

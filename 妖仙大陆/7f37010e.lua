local _M = { }
_M.__index = _M

local Util = require 'Zeus.Logic.Util'

local SignRq = require "Zeus.Model.Sign"
local AllSginMsg = { }
local self = {
    menu = nil,
}

local ui_text =
{
    sign_sign = Util.GetText(TextConfig.Type.SIGN,'sign_sign'),
    sign_luxury = Util.GetText(TextConfig.Type.SIGN,'sign_luxury'),
    sign_vipcomp = Util.GetText(TextConfig.Type.SIGN,'sign_vipcomp'),
    sign_allsignday = Util.GetText(TextConfig.Type.SIGN,'sign_allsignday'),
    sign_pay = Util.GetText(TextConfig.Type.SIGN,'sign_pay'),
    sign_get = Util.GetText(TextConfig.Type.SIGN,'sign_get'),
    sign_isget = Util.GetText(TextConfig.Type.SIGN,'sign_isget'),
    sign_issign = Util.GetText(TextConfig.Type.SIGN,'sign_issign'),
    sign_alldays = Util.GetText(TextConfig.Type.SIGN,'sign_alldays'),
    sign_daysaward = Util.GetText(TextConfig.Type.SIGN,'sign_daysaward'),
    sign_Alreadydays = Util.GetText(TextConfig.Type.SIGN,'sign_Alreadydays'),
    sign_rule = Util.GetText(TextConfig.Type.SIGN,'sing_rule_ui'),
    sign_showtext = Util.GetText(TextConfig.Type.SIGN,'sign_rule'),
    sign_day = Util.GetText(TextConfig.Type.SIGN,'sign_day'),
}

local function getAccumulateRedPoint(self, cList)
    for _, v in pairs(cList) do
        if v.state == 1 then
            return true
        end
    end
    return false
end

local function initSignBtn(self)
    local Signbtn = self.btn_sign
    if AllSginMsg.todayState == 1 then
        Signbtn.Text = ui_text.sign_sign
        Signbtn.Enable = true
        Signbtn.IsGray = false
    else
        Signbtn.Text = ui_text.sign_issign
        Signbtn.Enable = false
        Signbtn.IsGray = true
    end
    self.lb_bj_accumulate.Visible = getAccumulateRedPoint(self, AllSginMsg.cumulativeList)
    self.lb_sign_accumulate.Visible =(AllSginMsg.todayState == 1)
end

local function SignNodeClick(node, index)
    local info = AllSginMsg.dailyList[index]
    local params = { }
    params.templateId = info.itemList.code
    local function closeCallback(d, eventname, param)
        if eventname == 'Event.OnExit' then
            if self.curchooseNode then
                self.curchooseNode:FindChildByEditName("ib_choose", true).Visible = false
                self.curchooseNode = nil
            end
        end
    end
    params.closeCallback = closeCallback
    if info.state == 3 then
        local customBtn = {
            title = ui_text.sign_vipcomp,
            eventName = "",
            clickFunc = function()
                SignRq.GetLeftVipRewardRequest(info.id, function()
                    node:FindChildByEditName("ib_gou", true).Visible = true
                    node:FindChildByEditName("ib_shadow", true).Visible = true
                    AllSginMsg.dailyList[index].state = 2
                end )
            end
        }
        local btns = { }
        table.insert(btns, customBtn)
        params.buttons = btns
    end
    self.curchooseNode = node
    EventManager.Fire("Event.ShowItemDetail", params)
end

local function update_pan_Right(x, y, node)
    local index = 6 * y + x + 1
    node.UserTag = index
    if index > #AllSginMsg.dailyList then
        node.Visible = false
        return
    end
    node.Visible = true
    local info = AllSginMsg.dailyList[index]
    node:FindChildByEditName("ib_choose", true).Visible = false
    local issign = node:FindChildByEditName("ib_gou", true)
    issign.Visible = info.state == 2
    node:FindChildByEditName("ib_shadow", true).Visible = info.state == 2
    local numtext = node:FindChildByEditName("lb_num", true)
    numtext.Text = info.itemList.groupCount
    local daySign = node:FindChildByEditName("lb_day", true)
    daySign.Text = string.format(ui_text.sign_day, index)

    local ib_discount1 = node:FindChildByEditName("ib_discount1", true) 
    ib_discount1.Visible = (info.script == 1)
    
    local ib_discount2 = node:FindChildByEditName("ib_discount2", true) 
    ib_discount1.Visible = (info.script == 2)

    node.TouchClick = function(node)
        node:FindChildByEditName("ib_choose", true).Visible = true
        SignNodeClick(node, index)
    end

    local kuang = node:FindChildByEditName("cvs_frame", true)
    local icon = info.itemList.icon
    local qColor = info.itemList.qColor
    
    local itemshow = HZItemShow.New(kuang.Width, kuang.Height)
    kuang:AddChild(itemshow)
    itemshow.IconID = icon
    itemshow.Quality = qColor

    local pathstr = "#dynamic_n/dynamic_new/sign/sign.xml|sign|" .. tostring(info.vipDoubleLevel + 7)
    local corner = node:FindChildByEditName("ib_corner", true)
    if info.vipDoubleLevel ~= 0 then
        local layout = XmdsUISystem.CreateLayoutFroXml(
        pathstr,
        LayoutStyle.IMAGE_STYLE_BACK_4,
        0
        )
        corner.Layout = layout
        corner.Visible = true
    else
        corner.Visible = false
    end

end


local function rushSign(self)
    initSignBtn(self)
    self.tbh_accumulate.XmlText = string.format(ui_text.sign_allsignday, AllSginMsg.signedCount)
    self.cvs_icon.Visible = false
    local count = #AllSginMsg.dailyList
    self.sp_list.Scrollable:Reset(6,(count - 1) / 6 + 1);
end

function _M:OnEnter()
    local nowDay = DataMgr.Instance.UserData:GetDateTimeToYYYY_MM_DD(XmdsNetManage.Instance.ServerTimeSync:GetServerUnixTime() / 1000)
    if self.reqTime == nil or self.reqTime ~= nowDay then
        SignRq.GetAttendanceInfoRequest( function()
            AllSginMsg = SignRq.GetAllSignMsg()
            rushSign(self)
            self.reqTime = nowDay
        end )
    end
end

function _M:OnExit()

end

local ui_names =
{
    { name = 'sp_list' },
    { name = 'cvs_icon' },
    { name = 'tbh_accumulate' },
    { name = 'btn_accumulate' },
    { name = 'btn_gantanhao' },
    { name = 'btn_sign' },
    { name = 'cvs_intrduce' },
    { name = 'lb_bj_accumulate' },
    { name = 'btn_intrduce' },
    { name = 'lb_sign_accumulate' },
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
    tbl.cvs_icon.Visible = false
end
 
local function InitComponent(self, xmlPath)
    
    self.menu = XmdsUISystem.CreateFromFile(xmlPath)
    initControls(self.menu, ui_names, self)

    self.sp_list:Initialize(
    self.cvs_icon.Width,
    self.cvs_icon.Height,
    0,
    
    0,
    
    self.cvs_icon,
    update_pan_Right,
    function() end
    )

    self.btn_accumulate.TouchClick = function()
        local node, lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISignAward, 0)
        lua_obj.SetCallback( function()
            AllSginMsg = SignRq.GetAllSignMsg()
            rushSign(self)
        end )
    end

    self.btn_sign.TouchClick = function()
        SignRq.GetDailyRewardRequest( function()
            AllSginMsg = SignRq.GetAllSignMsg()
            rushSign(self)
            local curSignIndex = 0
            for _, v in pairs(AllSginMsg.dailyList) do
                if v.state == 2 then
                    curSignIndex = curSignIndex + 1
                end
            end
            
            local info = AllSginMsg.dailyList[curSignIndex]
            local itemCode = info.itemList.code
            local itemName = GlobalHooks.DB.Find("Items", itemCode).Name
            local itemNum = info.itemList.groupCount
            local familyStr = itemName .. "(" .. itemCode .. ")" .. ":" .. itemNum
            Util.SendBIData("SignIn", "", "1", "", "", familyStr, "")
            
        end )
    end

    self.btn_gantanhao.TouchClick = function()
        self.cvs_intrduce.Visible = not self.cvs_intrduce.Visible
    end

    self.btn_intrduce.TouchClick = function()
        self.cvs_intrduce.Visible = false
    end

    return self.menu
end

function _M.Create(ActivityID, xmlPath)
    local ret = { }
    setmetatable(ret, _M)
    local node = InitComponent(ret, xmlPath)
    return ret, node
end

return _M

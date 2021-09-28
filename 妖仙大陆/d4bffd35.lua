local _M = { }
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local WFRq = require "Zeus.Model.Welfare"

local self = {
    menu = nil,
}

local fontcolor =
{
    hong = 0xf43a1cff,
    nv = 0x5bc61aff,
}

local function concatTimeStr(h, m, s)
    local th, tm, ts = ""
    local ttstr = ""
    local function strbuf(tt)
        if tt == 0 then
            ttstr = "00"
        else
            if tt > 0 and tt < 10 then
                ttstr = "0" .. tt
            else
                ttstr = tostring(tt)
            end
        end
        return ttstr
    end
    return strbuf(h) .. ":" .. strbuf(m) .. ":" .. strbuf(s)
end

local function changeGetBtn(btn, allgift, index)
    if allgift[index].state == 0 then
        btn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "notreached")
        btn.TouchClick = function()
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.SIGN, "notonlinelong"))
        end

    elseif allgift[index].state == 1 then
        btn.Text = Util.GetText(TextConfig.Type.SIGN, 'sign_get')
        local efc = self.cellCont[index]:FindChildByEditName("ib_effect", true)
        efc.Visible = true
        btn.TouchClick = function()
            WFRq.ReceiveGiftRequest(allgift[index].id, function()
                
                
                
                
                
                
                
                
                local activityData = GlobalHooks.DB.Find('Welfare', { btnText = Util.GetText(TextConfig.Type.SIGN, "onlinereward")})[1]
                
                

                local kingdomStr = activityData.ActivityID
                
                local phylumStr = activityData.btnText
                
                local classfieldStr = allgift[index].id
                

                local gainItem = { }
                for i = 1, #self.giftallmsg.giftList[index].item, 1 do
                    local code = self.giftallmsg.giftList[index].item[i].code
                    local num = self.giftallmsg.giftList[index].item[i].groupCount
                    local name = GlobalHooks.DB.Find("Items", code).Name
                    local nameStr = name .. "(" .. code .. ")"
                    gainItem[nameStr] = num
                end
                Util.SendBIData("ActivityReward", "", kingdomStr, phylumStr, classfieldStr, gainItem, "")
                
                allgift[index].state = 2
                
                OnlineGiftGetCallBack()

            end )
        end
    elseif allgift[index].state == 2 then
        btn.Text = Util.GetText(TextConfig.Type.SIGN, 'sign_isget')
        btn.Visible = false
    end
end

local function UpDataShowTimeTitle()
    local allgift = self.giftallmsg.giftList
    for i = 1, #allgift do
        local h, m, s = 0
        local needtiem = allgift[i].time * 60 - self.OnlineTime
        if needtiem > 0 then
            h = math.floor(needtiem / 3600)
            m = math.floor((needtiem - h * 3600) / 60)
            s = math.floor(needtiem - h * 3600 - m * 60)
            self.timeshow[i].Text = concatTimeStr(h, m, s)
            self.timeshow[i].FontColor = GameUtil.RGBA2Color(fontcolor.hong)
            self.timeshow[i].Visible = true
        else
            if self.timeshow[i].FontColorRGBA ~= fontcolor.nv then
                self.timeshow[i].Text = "00:00:00"
                self.timeshow[i].FontColor = GameUtil.RGBA2Color(fontcolor.nv)
                self.timeshow[i].Visible = false
                local GetBtn = self.cellCont[i]:FindChildByEditName("btn_get", true)
                if allgift[i].state == 0 then
                    allgift[i].state = 1
                end
                changeGetBtn(GetBtn, allgift, i)
            end
        end

    end
    if not self.cellCont[1]:FindChildByEditName("lb_countdown", true).Visible then
        for i = 1, #self.cellCont do
            if not self.AlreadyGet[i] then
                
            end
        end
    end
end

local function UpdateClick()
    local sh = XMUGUI_ScoreHelper.New(XMUGUI_ScoreHelper.Category_eTime, 0)
    sh:SetScore(
    self.timeshow[#self.timeshow],
    tostring(self.maxGiftTime),
    tostring(0),
    LuaHelper.Action(
    function()
        
        RemoveUpdateEvent("Event.OnlineGiftAll.Update")
    end
    ),
    LuaHelper.Action(
    function()
        
        self.OnlineTime = self.OnlineTime + 1
        UpDataShowTimeTitle()
    end
    )
    )
    UpDataShowTimeTitle()
    if self.maxGiftTime > self.OnlineTime then
        RemoveUpdateEvent("Event.OnlineGiftAll.Update", true)
        AddUpdateEvent(
        "Event.OnlineGiftAll.Update",
        function(dt)
            if nil ~= sh and true == sh:Update(dt) then
                sh = nil;
            end
        end
        )
    end
end

local function rushGiftCell()
    local allgift = self.giftallmsg.giftList
    table.sort(allgift, function(a, b)
        
        if a.state == 2 and b.state == 2 then
            return a.id < b.id
        elseif a.state == 2 then
            return false
        elseif b.state == 2 then
            return true
        end
        return a.id < b.id
    end )

    

    if allgift ~= nil then
        for i = 1, #allgift do
            local TimeTitle = self.cellCont[i]:FindChildByEditName("lb_need_time", true)
            TimeTitle.Text = allgift[i].name

            for j = 1, 4 do
                local icon = self.cellCont[i]:FindChildByEditName("cvs_icon" .. j, true)
                local item = nil
                if j <= #allgift[i].item then
                    item = allgift[i].item[j]
                end
                if item == nil then
                    icon.Visible = false
                else
                    icon.Visible = true
                    local m_it = Util.ShowItemShow(icon, item.icon, item.qColor, item.groupCount)
                    Util.NormalItemShowTouchClick(m_it, item.code, false)
                end
            end

            local isGet = self.cellCont[i]:FindChildByEditName("ib_have", true)
            isGet.Visible = allgift[i].state == 2
            self.AlreadyGet[i] = allgift.state == 2

            local efc = self.cellCont[i]:FindChildByEditName("ib_effect", true)
            efc.Visible = allgift.state == 1

            local showtimelb = self.cellCont[i]:FindChildByEditName("lb_countdown", true)
            self.timeshow[i] = showtimelb


            local lb_giftname = self.cellCont[i]:FindChildByEditName("lb_giftname", true)
            lb_giftname.Text = allgift[i].name

            local GetBtn = self.cellCont[i]:FindChildByEditName("btn_get", true)
            changeGetBtn(GetBtn, allgift, i)
        end
    end
end

local function findChildByTag(cvs,tag)
    for i = 0,cvs.NumChildren - 1 do
        local v = cvs:GetChildAt(i)
        if v.Tag == tag then
            return v
        end
    end
    return nil
end

local function InitAllCell()
    local cel = self.menu:FindChildByEditName("cvs_gift", true)
    local cvsp = self.menu:FindChildByEditName("cvs_parent", true)
    cvsp.Visible = true
    
    
    local nowDay = DataMgr.Instance.UserData:GetDateTimeToYYYY_MM_DD(XmdsNetManage.Instance.ServerTimeSync:GetServerUnixTime() / 1000)
    if self.day == nil or self.day ~= nowDay then
        cvsp:RemoveAllChildren(true)
        self.day = nowDay
        WFRq.SetRefresh(false)
    else
        local scrollpan = self.menu:FindChildByEditName("sp_sp", true)
        local ma = MoveAction.New()
            ma.TargetX = scrollpan.Scrollable.Container.X
            ma.TargetY = 0
            ma.ActionEaseType = EaseType.linear
            ma.Duration = 0.1
            scrollpan.Scrollable.Container:AddAction(ma)
    end
    
    local allgift = self.giftallmsg.giftList
    local num = #allgift
    if allgift then
        for i = cvsp.NumChildren - 1,0,-1 do
            local v = cvsp:GetChildAt(i)
            local tag = v.Tag
            local find = false
            for i = 1, num do
                if tag == self.giftallmsg.giftList[i].id then
                    find = true
                    break
                end
            end
            if not find then
                v.RemoveFromParent(true)
            end
        end
        for i = 1, num do
            local node = findChildByTag(cvsp,self.giftallmsg.giftList[i].id)
            if node == nil then
                node = cel:Clone()
                node.Tag = self.giftallmsg.giftList[i].id
                self.cellCont[i] = node
                cvsp:AddChild(node)
                node:FindChildByEditName("lb_countdown", true).Visible = false
            end
            node.X = 0
            node.Y =(i - 1) *(node.Height)
        end
        cvsp.Height = num * cel.Height
        self.maxGiftTime = allgift[num].time * 60
    else
        cvsp:RemoveAllChildren(true)
        cvsp.Height = 0
    end
end

function _M.OnEnter()
    self.menu.Visible = false
    self.timeshow = { }
    self.AlreadyGet = { }
    local refresh = WFRq.GetRefresh()
    if refresh then
        self.day = nil
    end
    WFRq.GetGiftInfoRequest( function()
        local willgift = WFRq.FindWillGiftMsg()
        if willgift == nil then
            
            
            
            
        end
        self.menu.Visible = true
        self.giftallmsg = WFRq.GetGiftMsg()
        if not self.giftallmsg.giftList then return end
        self.OnlineTime = self.giftallmsg.onlineTime
        InitAllCell()
        rushGiftCell()
        UpdateClick()
    end , function()
        self.menu:Close()
    end )
    local function handler_refresh()
        self.giftallmsg = WFRq.GetGiftMsg()
        local refresh = WFRq.GetRefresh()
        if refresh then
            self.day = nil
        end
        if not self.giftallmsg.giftList then return end
        self.OnlineTime = self.giftallmsg.onlineTime
        InitAllCell()
        rushGiftCell()
        UpdateClick()
    end
    self.handler_refresh = handler_refresh
    EventManager.Subscribe("Event.Hud.OnlineGiftPush",self.handler_refresh)
end

function OnlineGiftGetCallBack()
    rushGiftCell()
end

function _M.OnExit()
    RemoveUpdateEvent("Event.OnlineGiftAll.Update", true)





    
    EventManager.Unsubscribe("Event.Hud.OnlineGiftPush",self.handler_refresh)
end

function _M.SetCall(callback)
    self.callback = callback
end

local function initLiftRightBtn(...)
    local scrollpan = self.menu:FindChildByEditName("sp_sp", true)
    local liftbtn = self.menu:FindChildByEditName("btn_left", true)
    local rightbtn = self.menu:FindChildByEditName("btn_right", true)
    liftbtn.TouchClick = function()
        if scrollpan.Scrollable.Container.X > -230 then
            
            local ma = MoveAction.New()
            ma.TargetX = scrollpan.Scrollable.Container.X + 112
            ma.TargetY = 0
            ma.ActionEaseType = EaseType.linear
            ma.Duration = 0.1
            scrollpan.Scrollable.Container:AddAction(ma)
        end
    end
    rightbtn.TouchClick = function()
        if scrollpan.Scrollable.Container.X > -230 then
            
            local ma = MoveAction.New()
            ma.TargetX = scrollpan.Scrollable.Container.X - 112
            ma.TargetY = 0
            ma.ActionEaseType = EaseType.linear
            ma.Duration = 0.1
            scrollpan.Scrollable.Container:AddAction(ma)
        end
    end
end

local function InitUI()
    self.menu:FindChildByEditName("cvs_gift", true).Visible = false
end

local function InitComponent(self, xmlPath)
    self.menu = XmdsUISystem.CreateFromFile(xmlPath)
    InitUI()
    self.cellCont = { }
    return self.menu
end

local function Create(ActivityID, xmlPath)
    self = { }
    setmetatable(self, _M)
    local node = InitComponent(self, xmlPath)
    return self, node
end

return { Create = Create }

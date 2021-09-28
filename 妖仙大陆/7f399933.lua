local _M = {}
_M.__index = _M
local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local ServerTime = require "Zeus.Logic.ServerTime"
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"

local self = {menu = nil}

local TotalNodeNum = 18

local function GetStartDrawIndex(index)
    local count = index + 1
    if count > TotalNodeNum then
        count = count - TotalNodeNum
    end
    return count
end

local function GetNextDrawIndex(index)
    if index > TotalNodeNum then
        index = 1
    end
    if self.AwardEffectList[index].Visible == false then
        self.AwardEffectList[index].Visible = true
        return index
    else
        self.AwardEffectList[index].Visible = false
        return GetNextDrawIndex(index+1)
    end
end

local function RunDrawEffect(data)
    local count = #data
    if count == 0 then
        self.cvs_mask.Visible = false
        return
    end
    self.cvs_mask.Visible = true
    self.curIndex = GetStartDrawIndex(data[1].id)
    self.timer1 = Timer.New(function ()
        
        
        
        
        self.curIndex = GetNextDrawIndex(self.curIndex)
        if self.curIndex == data[1].id then
            self.timer1:Stop()
            self.timer2 = Timer.New(function ()
                
                
                
                
                self.curIndex = GetNextDrawIndex(self.curIndex)
                if self.curIndex == data[1].id then
                    self.timer2:Stop()
                    self.cvs_mask.Visible = false
                    local itemList = {}
                    for i,v in ipairs(data) do
                        table.insert(itemList,{id = v.id, code = v.code, groupCount = v.num})
                    end
                    EventManager.Fire('Event.OnShowNewItems',{items = itemList})
                end
            end, 0.3, -1)
            self.timer2:Start()
        end
    end, 0.1, -1)
    self.timer1:Start()
end

local function UpdateAwardList()
    local itemCount = #self.infoList.awards
    local canCount = #self.AwardNodeList
    for i=1,canCount do
        local node = self.AwardNodeList[i]
        local show = false
        if i <= itemCount then
            local data = self.infoList.awards[i]
            node.Visible = true
            local cvs_icon = node:FindChildByEditName("cvs_icon", true)
            local detail = ItemModel.GetItemDetailByCode(data.code)
            local itshow = Util.ShowItemShow(cvs_icon,detail.static.Icon,detail.static.Qcolor,data.num,true)
            Util.NormalItemShowTouchClick(itshow,data.code,false)
        else
            self.AwardNodeList[i].Visible = false
        end
        self.AwardEffectList[i].Visible = false
    end
end

local function UpdateTimeStamp()
    AddUpdateEvent("Event.XYCJ.updateTimeStamp", function(deltatime)
        local cd = self.infoList.freeCountUpdateTimeStamp - ServerTime.GetServerUnixTime()
        if not self.menu.Visible then
            RemoveUpdateEvent("Event.XYCJ.updateTimeStamp", true)
            return
        end
        if cd <= 0 then
            RemoveUpdateEvent("Event.XYCJ.updateTimeStamp", true)
            EventManager.Fire("Event.XYCJ.RequestInfo", {})
        else
            self.lb_mianfei.Text = ServerTime.GetTimeStr(cd)
        end
    end)
end

local function ResetDrawEffect()
    self.cvs_mask.Visible = false
    for i,v in ipairs(self.AwardEffectList) do
        v.Visible = false
    end
end

local function UpdateTimeAndDesc(data)
    local itemCode = "raffletickets"
    self.tb_rule.XmlText = ActivityUtil.GetConfigTimeXml(data.beginTime, data.endTime, data.describe)

    if self.filter then
        DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.filter)
        self.filter = nil
    end

    local bag_data = DataMgr.Instance.UserData.RoleBag
    self.lb_num_add.Text = data.exploredTicketCountLeft

    self.filter = ItemPack.FilterInfo.New()
    self.filter.CheckHandle = function (it)
      return it.TemplateId == itemCode
    end
    self.filter.NofityCB = function ()
        local vItem = bag_data:MergerTemplateItem(itemCode)
        local hasCount = (vItem and vItem.Num) or 0
        self.infoList.exploredTicketCountLeft = hasCount
        self.lb_num_add.Text = hasCount
    end
    bag_data:AddFilter(self.filter)

    self.cvs_money_1.Visible = data.freeCountLeft <= 0
    self.cvs_money_free.Visible = data.freeCountLeft > 0

    if data.freeCountLeft <= 0 then
        UpdateTimeStamp()
    end
end

local function DealDrawReasult(data)
    if self.menu then
        self.infoList.freeCountLeft = data.freeCountLeft
        self.infoList.exploredTicketCountLeft = data.exploredTicketCountLeft
        self.resultDraw = data
        UpdateTimeAndDesc(self.infoList)
        ResetDrawEffect()
        if self.tbt_gou.IsChecked == false then
            RunDrawEffect(data.awards or {})
        else
            local itemList = {}
            for i,v in ipairs(data.awards) do
                table.insert(itemList,{id = v.id, code = v.code, groupCount = v.num})
            end
            EventManager.Fire('Event.OnShowNewItems',{items = itemList})
        end
    end
end

local function RequestInfo()
    if self.menu then
        ActivityAPI.DailyDrawInfoRequest(0, function(data)
            if self.menu then
                self.infoList = data
                UpdateTimeAndDesc(data)
                UpdateAwardList()
            end
        end)
    end
end

function  _M.OnEnter()
    self.cvs_guize.Visible = false
    self.cvs_mask.Visible = false
    self.resultDraw = nil

    ResetDrawEffect()

    RequestInfo()

    EventManager.Subscribe("Event.XYCJ.RequestInfo",RequestInfo)
end

function _M.OnExit()
    RemoveUpdateEvent("Event.XYCJ.updateTimeStamp", true)
    EventManager.Unsubscribe("Event.XYCJ.RequestInfo",RequestInfo)
end

local ui_names = 
{
    {name = 'tb_rule'},
    {name = 'tbt_gou'},
    {name = 'btn_guize'},
    {name = 'cvs_guize'},
    {name = 'lb_num_add'},
    {name = 'btn_add'},
    {name = 'cvs_money_1'},
    {name = 'btn_one'},
    {name = 'lb_mianfei'},
    {name = 'cvs_money_10'},
    {name = 'btn_ten'},
    {name = 'cvs_money_free'},
    {name = 'btn_free'},
    {name = 'cvs_mask'},
}

local function InitControls(view, names, tbl)
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

    self.AwardNodeList = {}
    self.AwardEffectList = {}
    for i=1,TotalNodeNum do
        local ctrl = view:FindChildByEditName("cvs_"..i, true)
        if ctrl then
            self.AwardNodeList[i] = ctrl
            local effect = ctrl:FindChildByEditName("ib_choice", true)
            if effect then
                effect.Visible = false
                self.AwardEffectList[i] = effect
            end
        end
    end

    self.btn_free.TouchClick = function (sender)
        ActivityAPI.DailyDrawRequest(0,0,0,function(data)
            DealDrawReasult(data)
        end)
    end
    
    self.btn_one.TouchClick = function (sender)
        if self.infoList.exploredTicketCountLeft > 0 then
            ActivityAPI.DailyDrawRequest(0,1,0,function(data)
                DealDrawReasult(data)
            end)
        else
            GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            Util.GetText(TextConfig.Type.ACTIVITY, "confirmXYCJ", self.infoList.proportion),
            nil,nil,nil,nil,
            function()
                ActivityAPI.DailyDrawRequest(0,2,0,function(data)
                    DealDrawReasult(data)
                end)
            end,
            nil
            )
        end
    end

    self.btn_ten.TouchClick = function (sender)
        if self.infoList.exploredTicketCountLeft >= 10 then
            ActivityAPI.DailyDrawRequest(1,1,0,function(data)
                DealDrawReasult(data)
            end)
        else
            local diamond = (10-self.infoList.exploredTicketCountLeft)*self.infoList.proportion
            GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            Util.GetText(TextConfig.Type.ACTIVITY, "confirmXYCJ", diamond),
            nil,nil,nil,nil,
            function()
                ActivityAPI.DailyDrawRequest(1,2,0,function(data)
                    DealDrawReasult(data)
                end)
            end,
            nil
            )
        end
    end

    self.btn_guize.TouchClick = function (sender)
        self.cvs_guize.Visible = true
    end

    self.cvs_guize.TouchClick = function (sender)
        self.cvs_guize.Visible = false
    end

    self.btn_add.TouchClick = function (sender)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, "raffletickets")
    end

    self.cvs_mask.TouchClick = function (sender)
        
    end
end

local function InitComponent(self,xmlPath)
    self.menu = XmdsUISystem.CreateFromFile(xmlPath)
    InitControls(self.menu,ui_names,self)

    self.tbt_gou.IsChecked = false
    self.cvs_money_1.Visible = false

    self.infoList = nil

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

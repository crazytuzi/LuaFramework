local _M = {}
_M.__index = _M
local Util = require "Zeus.Logic.Util"
local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"

local self = {menu = nil}

local function FindEquipListItem(self,controlName)
    local child_list = self.sp_list.Scrollable.Container:GetAllChild()
    local children = Util.List2Luatable(child_list)
    for _,v in ipairs(children) do
        if v.Name == controlName then
            return v
        end
    end
    return nil
end

local function sortFunc(a, b)
    if a.state ~= b.state then
        if a.state == ActivityAPI.StateAlreadyGot then
            return false
        elseif b.state == ActivityAPI.StateAlreadyGot then
            return true
        end
    end
    return a.needNum < b.needNum
end

local function UpdateState(cell, state, idx)
    local ib_already = cell:FindChildByEditName("ib_already", true)
    ib_already.Visible = state == ActivityAPI.StateAlreadyGot

    local opBtn = cell:FindChildByEditName("btn_operation", true)
    opBtn.UserTag = idx
    opBtn.Visible = state ~= ActivityAPI.StateAlreadyGot
    opBtn.IsGray = state == ActivityAPI.StateAlreadyGot
    opBtn.TouchClick = OnOpCZTHBtnClick
    if state == ActivityAPI.StateCanGet then
        opBtn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "get")
    elseif state == ActivityAPI.StateCanNotGet then
        opBtn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "go")
    else
        opBtn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "alreadyGot")
    end

    local effect = cell:FindChildByEditName("ib_effect", true)
    effect.Visible = state == ActivityAPI.StateCanGet
end

local function UpdateCell(gx, gy, node)
    local idx = gy + 1
    local info = self.todayInfo[idx]
    ActivityUtil.fillItemsStatic(info.item)
    ActivityUtil.fillItems(node, info.item, 4)
    UpdateState(node, info.state, idx)
    node:FindChildByEditName("tb_condition", true).UnityRichText = info.currNum/100 .. "/" .. info.needNum .. Util.GetText(TextConfig.Type.SIGN, "yuan")
end

local function UpdateRewardScrollPan()
    table.sort(self.todayInfo, sortFunc)

    self.sp_see:Initialize(self.cvs_single.Width, self.cvs_single.Height,
        #self.todayInfo, 1, self.cvs_single, 
        function (x, y, node)
            UpdateCell(x, y, node)
        end, 
        LuaUIBinding.HZTrusteeshipChildInit(function (node)
          
        end)
    )
end

function OnOpCZTHBtnClick(sender)
    local info = self.todayInfo[sender.UserTag]
    if info.state == ActivityAPI.StateCanNotGet then
        EventManager.Fire('Event.Goto', {id = "Pay"})
    elseif info.state == ActivityAPI.StateCanGet then
        ActivityAPI.RevelryRechargeAwardRequest(info.id, function()
            if self.menu then
                info.state = ActivityAPI.StateAlreadyGot
                UpdateRewardScrollPan()
            end
        end)
    end
end

local function RequestDayInfo(index)
    ActivityAPI.RevelryRechargeGetInfoRequest(index, function(data)
        if self.menu then
            self.todayInfo = data
            UpdateRewardScrollPan()
        end
    end)

    if index ~= self.selectDay then
        local node = FindEquipListItem(self,"dayNode" .. self.selectDay)
        if node then
            local btn = node:FindChildByEditName("tbt_section",false)
            if btn then
                btn.IsChecked = false
                btn.Enable = true
            end
        end
    end
    self.selectDay = index
    local node = FindEquipListItem(self,"dayNode" .. self.selectDay)
    if node then
        local btn = node:FindChildByEditName("tbt_section",false)
        if btn then
            btn.IsChecked = true
            btn.Enable = false
        end
    end
end



local function UpdateDayScrollPan()
    local count = 0
    self.selectDay = self.daysInfo.today
    if self.daysInfo and self.daysInfo.column then
        count = #self.daysInfo.column
    end
    self.sp_list:Initialize(self.cvs_section.Width, self.cvs_section.Height, 1, count, self.cvs_section, 
        function (x, y, node)
            local index = x+1
            local data = self.daysInfo.column[index]
            local tbt_section = node:FindChildByEditName("tbt_section", true)
            tbt_section.Text = data.name
            node.UserTag = index
            node.Name = "dayNode" .. index
            tbt_section.TouchClick = function (sender)
                RequestDayInfo(index)
            end
            tbt_section.IsChecked = index == self.selectDay
            tbt_section.Enable = not tbt_section.IsChecked
        end, 
        LuaUIBinding.HZTrusteeshipChildInit(function (node)
            
        end)
    )

    RequestDayInfo(self.selectDay)
end

local function updateTimeAndDesc(beginTime, endTime, desc)
    self.tb_rule.XmlText = ActivityUtil.GetConfigTimeXml(beginTime, endTime, desc)
end

local function RequestInfo()
    if self.menu then
        ActivityAPI.RevelryRechargeGetColumnRequest(function ( data )
            if self.menu then
                self.daysInfo = data
                
                updateTimeAndDesc(data.beginTime, data.endTime, data.describe)
                UpdateDayScrollPan()
            end
        end)
    end
end

function  _M.OnEnter()
    self.selectDay = 1
    RequestInfo()
    self.rechargeExt:start()
end
function _M.OnExit()
    self.rechargeExt:stop()
end

local ui_names = 
{
    {name = 'tb_rule'},
    
    {name = 'cvs_section'},
    {name = 'sp_list'},

    {name = 'cvs_single'},
    {name = 'sp_see'},
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

    self.cvs_section.Visible = false
    self.cvs_single.Visible = false

    self.rechargeExt = UserDataValueExt.New(UserData.NotiFyStatus.DIAMOND,RequestDayInfo)
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

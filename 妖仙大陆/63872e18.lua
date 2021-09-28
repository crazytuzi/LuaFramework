local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local ActivityUtil = require 'Zeus.UI.XmasterActivity.ActivityUIUtil'
local ActivityModel = require 'Zeus.Model.DailyActivity'

local self = {}
local weekToday = 2
local calendarData = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
}

local weekIndex = {
    [1] = Util.GetText(TextConfig.Type.ACTIVITY, "ACT_Monday"),
    [2] = Util.GetText(TextConfig.Type.ACTIVITY, "ACT_Tuesday"),
    [3] = Util.GetText(TextConfig.Type.ACTIVITY, "ACT_Wednesday"),
    [4] = Util.GetText(TextConfig.Type.ACTIVITY, "ACT_Thursday"),
    [5] = Util.GetText(TextConfig.Type.ACTIVITY, "ACT_Friday"),
    [6] = Util.GetText(TextConfig.Type.ACTIVITY, "ACT_Saturday"),
    [7] = Util.GetText(TextConfig.Type.ACTIVITY, "ACT_Sunday"),
}

local function InitItemList(self,cvs_node,items,weekIndex)
    local item_counts = #items
    local sp_item_list = cvs_node:FindChildByEditName('sp_item_list',false)
    local cvs_item = cvs_node:FindChildByEditName('cvs_item',false)
    cvs_item.Visible = false

    sp_item_list.Scrollable:ClearGrid()
    if sp_item_list.Rows <= 0 then
        sp_item_list.Visible = true
        local cs = cvs_item.Size2D
        sp_item_list:Initialize(cs.x,cs.y,1,item_counts,cvs_item,
        function (gx,gy,node)
            local item = items[gx+1]
            local ib_choose = node:FindChildByEditName('ib_choose',false)
            ib_choose.Visible = (weekIndex == weekToday)
            local lb_name = node:FindChildByEditName('lb_name',false)
            lb_name.Text = item.SchName

            local lb_time = node:FindChildByEditName('lb_time',false)
            if item.PeriodInCalendar == "" then
                 lb_time.Text = item.TimeDesc
             else
                 lb_time.Text =  string.gsub(item.PeriodInCalendar,";","\n")
            end

            node.TouchClick = function()
                ActivityModel.DailyActivityRequest(function (params)
                    if params.s2c_dailyLs then
                        for i,v in ipairs(params.s2c_dailyLs) do
                            if v.id == item.SchID then
                                local node,menu = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIActivityDetail, 0) 
                                menu.SetActivityInfo(item, v)
                                return
                            end
                        end
                    end
                end)
            end

        end,function () end)
    else
        sp_item_list.Rows = item_counts
    end 
end

local function InitDayList(self)
    local item_counts = #calendarData
    self.sp_day_list.Scrollable:ClearGrid()
    if self.sp_day_list.Rows <= 0 then
        self.sp_day_list.Visible = true
        local cs = self.cvs_week_item.Size2D
        self.sp_day_list:Initialize(cs.x,cs.y,item_counts,1,self.cvs_week_item,
        function (gx,gy,node)
            local items = calendarData[gy+1]

            local lb_day = node:FindChildByEditName('lb_day',false)
            lb_day.Text = weekIndex[gy+1]

            local ib_zhezhao = node:FindChildByEditName('ib_zhezhao',false)
            ib_zhezhao.Visible = (gy+1 == weekToday)
            
            InitItemList(self,node,items,gy+1)

        end,function () end)
    else
        self.sp_day_list.Rows = item_counts
    end 
end

local function  UpdateCalendarInfo(self)
    
    weekToday = ActivityModel.TodayWeekIndex

    InitDayList(self)
end


local function InitUI()
    local UIName = {
    	"btn_close",
        "sp_day_list",
        "cvs_week_item",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
    self.cvs_week_item.Visible = false
end

local function OnEnter()

end

local function OnExit()
   
end

local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/activity/calendar.gui.xml',tag)
    self.menu.ShowType = UIShowType.HideBackHud
  
    
    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu:SubscribOnDestory(function()
        
    end)

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end
    
    local data = GlobalHooks.DB.Find('Schedule',{})
    for i = 1,#(data) do
        if data[i].IsValid == 1 and data[i].IsShowInCalendar == 1 then
            local opendays = data[i].Openday
            if opendays == "0" then
                opendays = "1;2;3;4;5;6;7"
            end
            local opendays = string.split(opendays,';')

            for _,v in pairs(opendays) do
                if v.Openday == data[i].Openday then
                    table.insert(data,data[i])
                end
                table.insert(calendarData[tonumber(v)],data[i])
            end
        end    
    end
    for k,v in pairs(calendarData) do
        if k < 7 then
            table.remove(v,#v-1)
        end
    end
    UpdateCalendarInfo(self)

    return self.menu
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}

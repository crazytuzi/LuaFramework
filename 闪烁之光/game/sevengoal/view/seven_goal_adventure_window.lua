--****************
--冒险笔记
--****************
SevenGoalAdventureWindow = SevenGoalAdventureWindow or BaseClass(BaseView)

local controller = SevenGoalController:getInstance()
local group_list = Config.DayGoalsNewData.data_group_list
local make_lev_list = Config.DayGoalsNewData.data_make_lev_list
local charge_totle_list = Config.DayGoalsNewData.data_charge_list
local table_sort = table.sort
local table_insert = table.insert
local string_format = string.format
function SevenGoalAdventureWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Big      
    self.view_tag = ViewMgrTag.DIALOGUE_TAG     
    self.layout_name = "seven_goal/seven_goal_adventure_windown"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("seven_goals", "seven_gold"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("seven_goals/banner","seven_goals_banner_1"), type = ResourcesType.single},
    }
end

function SevenGoalAdventureWindow:open_callback()
    local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 1)

    local title_banner = main_container:getChildByName("title_banner")
    local res = PathTool.getPlistImgForDownLoad("seven_goals/banner", "seven_goals_banner_1")
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(title_banner) then
                loadSpriteTexture(title_banner, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end
    
    main_container:getChildByName("Text_6"):setString(TI18N("下级奖励"))
    main_container:getChildByName("Text_10"):setString(TI18N("七日内完成每日任务升级日记，可获得对应等级奖励"))
    main_container:getChildByName("Text_7"):setString(TI18N("剩余时间："))
    self.time_text = main_container:getChildByName("time_text")
    self.time_text:setString("")

    local cur_lev_spr = main_container:getChildByName("Sprite_8")
    cur_lev_spr:getChildByName("Text_6_0"):setString(TI18N("等级"))
    self.btn_more = main_container:getChildByName("btn_more")
    self.btn_more:getChildByName("Text_5"):setString(TI18N("等级奖励"))
    self.btn_tips = main_container:getChildByName("btn_tips")
    self.bar = main_container:getChildByName("bar")
    self.bar:setScale9Enabled(true)
    self.bar_num = main_container:getChildByName("bar_num")
    self.bar_num:setString("")
    self.cur_lev_num = CommonNum.new(22, cur_lev_spr, 1, 1, cc.p(0.5, 0.5))
    self.cur_lev_num:setPosition(52, 72)
    
    local good_next = main_container:getChildByName("good_next")
    local scroll_next_size = good_next:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 30,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.60,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.60,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.60,                     -- 缩放
        need_dynamic = true,
    }
    self.next_scrollview = CommonScrollViewLayout.new(good_next, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_next_size, setting)
    self.next_scrollview:setSwallowTouches(false)

    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = SevenGoalAdventureItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                    -- y方向的间隔
        item_width = 616,               -- 单元的尺寸width
        item_height = 150,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)

    --累充
    local total_layer = main_container:getChildByName("total_layer")
    self.total_goto = total_layer:getChildByName("total_goto")
    self.total_goto:getChildByName("Text_1"):setString(TI18N("前往"))
    self.total_get = total_layer:getChildByName("total_get")
    self.total_get:getChildByName("Text_1"):setString(TI18N("领取"))
    self.total_get:setVisible(false)
    self.total_has = total_layer:getChildByName("total_has")
    self.total_has:setVisible(false)
    self.total_more = total_layer:getChildByName("total_more")
    self.total_more:getChildByName("Text_4"):setString(TI18N("查看更多"))
    self.total_name_charge = total_layer:getChildByName("total_name_charge")
    self.total_name_charge:setString("")
    local total_cons = total_layer:getChildByName("total_cons")
    local scroll_total_size = total_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.70,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.70,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.70,                     -- 缩放
        need_dynamic = true,
    }
    self.total_scrollview = CommonScrollViewLayout.new(total_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_total_size, setting)
    self.total_scrollview:setSwallowTouches(false)

    self.btn_close = main_container:getChildByName("btn_close")
end

--普通任务列表
function SevenGoalAdventureWindow:commonTeskList(data)
    local data_list = controller:getModel():getInitSevenGoalData()
    local common_list = {} --普通任务
    self.totleChargeData = {} --累充任务

    local period = controller:getModel():getSevenGoalPeriod()
    local cur_period = data.period or period

    if data_list and charge_totle_list[cur_period] then
        for i,v in pairs(data_list) do
            local status = false
            for m,val in pairs(charge_totle_list[cur_period]) do
                if v.id == val.goal_id then
                    status = true
                    break
                end
            end
            if status == true then
                table_insert(self.totleChargeData,v)
            else
                table_insert(common_list,v)
            end
        end
    end
    if self.item_scrollview then
        self.item_scrollview:setData(common_list,nil,nil,cur_period)
    end
end
function SevenGoalAdventureWindow:getTotalChargeData()
    return self.totleChargeData or {}
end
--累充数据
function SevenGoalAdventureWindow:setChangeTotleData()
    local period = controller:getModel():getSevenGoalPeriod()
    local totle_charge_data = self:getTotalChargeData()
    if totle_charge_data and next(totle_charge_data) and next(totle_charge_data[1]) and charge_totle_list[period] then
        local cur_tesk = charge_totle_list[period][totle_charge_data[1].id].desc or ""
        local cur_num = totle_charge_data[1].value or 0
        local cur_totle = totle_charge_data[1].target_val or 0
        local str = string_format("%s (%d/%d)",cur_tesk, cur_num, cur_totle)
        self.total_name_charge:setString(str)
        
        self.total_goto:setVisible(totle_charge_data[1].finish == 0)
        self.total_get:setVisible(totle_charge_data[1].finish == 1)
        self.total_has:setVisible(totle_charge_data[1].finish == 2)
    
        if self.total_scrollview then
            local list = {}
            for k, v in pairs(charge_totle_list[period][totle_charge_data[1].id].award) do
                local vo = {}
                vo.bid = v[1]
                vo.quantity = v[2]
                table.insert(list, vo)
            end
            if #list > 4 then
                self.total_scrollview:setClickEnabled(true)
            else
                self.total_scrollview:setClickEnabled(false)
            end
            self.total_scrollview:setData(list)
            self.total_scrollview:addEndCallBack(function()
                local list = self.total_scrollview:getItemList()
                for k,v in pairs(list) do
                    v:setDefaultTip()
                end
            end)
        end
    end
end
function SevenGoalAdventureWindow:register_event()
    self:addGlobalEvent(SevenGoalEvent.BaseMessage, function(data)
        if not data or next(data) == nil then return end
        self:setLessTime(data.end_time - GameNet:getInstance():getTime())
        self:setChargeLevData(data.exp,data.lev)

        self:setMoreResPoint()
        self:commonTeskList(data)
        self:setChangeTotleData()
    end)

    self:addGlobalEvent(SevenGoalEvent.Tesk_Updata, function(data)
        if not data or next(data) == nil then return end
        if self.item_scrollview then
            self:commonTeskList(data)
            self:setChangeTotleData()
        end
    end)
    self:addGlobalEvent(SevenGoalEvent.Reward_Lev, function(data)
        if not data or next(data) == nil then return end
        self:setMoreResPoint()
    end)

    self:addGlobalEvent(SevenGoalEvent.Updata_Lev, function(data)
        if not data or next(data) == nil then return end
        controller:getModel():setSevenGoalLev(data.lev)
        self:setMoreResPoint()
        self:setChargeLevData(data.exp,data.lev)
    end)

    registerButtonEventListener(self.btn_close, function()
        controller:openSevenGoalAdventureView(false)
    end,true, 2)
    registerButtonEventListener(self.btn_more, function()
        controller:openSevenGoalAdventureLevRewardView(true)
    end,true, 1)
    registerButtonEventListener(self.btn_tips, function(param,sender, event_type)
        local config = Config.DayGoalsNewData.data_constant.tips.desc
        TipsManager:getInstance():showCommonTips(config, sender:getTouchBeganPosition(),nil,nil,500)
    end,false, 1,nil,0.80)

    registerButtonEventListener(self.total_goto, function()
        StrongerController:getInstance():clickCallBack(131)
    end,true, 1)
    registerButtonEventListener(self.total_get, function()
        local totle_charge_data = self:getTotalChargeData()
        if next(totle_charge_data) ~= nil then
            local id = totle_charge_data[1].id
            if id then
                controller:sender13606(id)
            end
        end
    end,true, 1)
    registerButtonEventListener(self.total_more, function()
        controller:openSevenGoalTotleChargeView(true)
    end,true, 1)
end

function SevenGoalAdventureWindow:setMoreResPoint()
    local red_status = false
    red_status = controller:getModel():setMoreResPoint()
    addRedPointToNodeByStatus(self.btn_more, red_status, -10)
    controller:getModel():checkMainRedPoint()
end

function SevenGoalAdventureWindow:setChargeLevData(exp,lev)
    lev = lev or 1
    if self.cur_lev_num then
        self.cur_lev_num:setNum(lev)
    end
    local period = controller:getModel():getSevenGoalPeriod()
    if make_lev_list[period] == nil then return end
    lev = lev + 1
    if lev >= #make_lev_list[period] then
        lev = #make_lev_list[period]
    end
    exp = exp or 0
    local max_exp = make_lev_list[period][lev].exp or 100
    self.bar_num:setString(exp.."/"..max_exp)
    self.bar:setPercent(exp/max_exp * 100)

    local list = {}
    for k, v in pairs(make_lev_list[period][lev].reward) do
        local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
        if vo then
            vo.quantity = v[2]
            table.insert(list, vo)
        end
    end
    if self.next_scrollview then
        if #list > 3 then
            self.next_scrollview:setClickEnabled(true)
        else
            self.next_scrollview:setClickEnabled(false)
        end
        self.next_scrollview:setData(list)
        self.next_scrollview:addEndCallBack(function()
            local list = self.next_scrollview:getItemList()
            for k,v in pairs(list) do
                v:setDefaultTip()
            end
        end)
    end
end
--设置倒计时
function SevenGoalAdventureWindow:setLessTime(less_time)
    if tolua.isnull(self.time_text) then return end
    local less_time = less_time or 0
    doStopAllActions(self.time_text)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_text:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    doStopAllActions(self.time_text)
                    self.time_text:setString("00:00:00")
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(less_time)
    end
end
function SevenGoalAdventureWindow:setTimeFormatString(time)
    if time > 0 then
        self.time_text:setString(TimeTool.GetTimeFormatDayIIIIIIII(time))
    else
        self.time_text:setString("00:00:00")
    end
end
function SevenGoalAdventureWindow:openRootWnd()
    controller:sender13604()
end
function SevenGoalAdventureWindow:close_callback()
    doStopAllActions(self.time_text)
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    if self.next_scrollview then
        self.next_scrollview:DeleteMe()
    end
    self.next_scrollview = nil
    if self.cur_lev_num then
        self.cur_lev_num:DeleteMe()
        self.cur_lev_num = nil
    end
    controller:openSevenGoalAdventureView(false)
end

--******************
--子项
--******************
SevenGoalAdventureItem = class("SevenGoalAdventureItem", function()
    return ccui.Widget:create()
end)

function SevenGoalAdventureItem:ctor()
    self:configUI()
    self:register_event()
end

function SevenGoalAdventureItem:configUI()
    self.rootWnd = createCSBNote(PathTool.getTargetCSB("seven_goal/seven_goal_adventure_item"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.rootWnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(616,150))

    local main_container = self.rootWnd:getChildByName("main_container")
    self.title_name = main_container:getChildByName("title_name")
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get:getChildByName("Text_1"):setString(TI18N("领取"))
    self.btn_get:setVisible(false)
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("Text_1"):setString(TI18N("前往"))
    self.btn_goto:setVisible(false)
    self.has_spr = main_container:getChildByName("has_spr")
    self.has_spr:setVisible(false)
    self.cur_gold = main_container:getChildByName("cur_gold")
    self.cur_gold:setString("")
    
    local good_cons = main_container:getChildByName("good_cons")
    local scroll_next_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.80,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.80,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.80,                     -- 缩放
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_next_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end
function SevenGoalAdventureItem:setExtendData(period)
    self.cur_item_period = period
end

function SevenGoalAdventureItem:setData(data)
    if not data or next(data) == nil then return end
    self.data = data
    if group_list[self.cur_item_period] == nil then return end
    if group_list[self.cur_item_period][data.id] == nil then return end

    self.btn_goto:setVisible(data.finish == 0)
    self.btn_get:setVisible(data.finish == 1)
    self.has_spr:setVisible(data.finish == 2)
    self.cur_gold:setString(data.value.."/"..data.target_val)

    local title_name = group_list[self.cur_item_period][data.id]
    self.title_name:setString(title_name.desc or "")

    local list = {}
    local award = group_list[self.cur_item_period][data.id].award
    award = award or {}
    for k, v in pairs(award) do
        local vo = {}
        vo.bid = v[1]
        vo.quantity = v[2]
        table.insert(list, vo)
    end
    if #list > 4 then
        self.item_scrollview:setClickEnabled(true)
    else
        self.item_scrollview:setClickEnabled(false)
    end
    self.item_scrollview:setData(list)
    self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
        end
    end)
end
function SevenGoalAdventureItem:register_event()
    registerButtonEventListener(self.btn_goto, function()
        if not self.data and not self.cur_item_period then return end
        local id = nil
        if group_list[self.cur_item_period] and group_list[self.cur_item_period][self.data.id] then
            id = group_list[self.cur_item_period][self.data.id].show_icon
        end
        if id then
            StrongerController:getInstance():clickCallBack(id)
        end
    end,true, 1)
    registerButtonEventListener(self.btn_get, function()
        if self.data then
            controller:sender13606(self.data.id)
        end
    end,true, 1)
end
function SevenGoalAdventureItem:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    self:removeAllChildren()
    self:removeFromParent()
end
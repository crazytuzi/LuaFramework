--[[
    七天目标
]]
ActionSevenGoalWindow = ActionSevenGoalWindow or BaseClass(BaseView)

local data_constant = Config.DayGoalsData.data_constant

local table_insert = table.insert
local controller = ActionController:getInstance()
local model = controller:getModel()
function ActionSevenGoalWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.cur_index = nil
    self.cur_select = nil
    self.cur_grop_select = nil
    self.play_effect = {} --宝箱
    self.welfareList = nil
    self.growthTarget = nil
    self.priceList = nil
    self.item_scrollview_walfare = nil
    self.currentDay = 1 --当前天数
    self.initCurrentDay = 1 --初始化天数，保证天数回滚是不会改变
    
    --关于周期性的图片动态加载
    self.load_touch_day = {}
    self.layout_name = "action/action_seven_goal_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("actionlimitgroup", "actionlimitgroup"), type = ResourcesType.plist},
    }
end

function ActionSevenGoalWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")

    self.bg_sprite = self.root_wnd:getChildByName("Image_bg")
    if self.bg_sprite ~= nil then
        self.bg_sprite:setScale(display.getMaxScale())
    end

    self.main_container = self.background:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.layer_tab = self.main_container:getChildByName("layer_tab")

    --宝箱
    self.award_list = {108,108,108,110}
    local box_ave_x = 559 / 4
    self.box_list_layer = {}
    for i=1, 4 do
        local tab = self.background:getChildByName("box_"..i)
        tab:setPositionX(80+box_ave_x * i)
        tab.redpoint = tab:getChildByName("redpoint")
        tab.redpoint:setLocalZOrder(11)
        tab.redpoint:setVisible(false)
        tab.textNum = tab:getChildByName("textNum")
        tab.textNum:setLocalZOrder(11)
        tab.textNum:setString("")
        self.box_list_layer[i] = tab
    end

    self.goods_walfare = self.main_container:getChildByName("goods_walfare")
    self.close_btn = self.main_container:getChildByName("close_btn")
 
    self.btn_list = {}
    local btn_label_list = {TI18N("福利领取"),TI18N(""),TI18N(""),TI18N("福利礼包")}
    for i=1,4 do 
        local btn = self.layer_tab:getChildByName("btnSelect_"..i)
        btn.red_point = btn:getChildByName("redpoint")
        btn.red_point:setVisible(false)
        btn.normal = btn:getChildByName("normal")
        btn.select = btn:getChildByName("select")
        btn.select:setVisible(false)
        btn.title = btn:getChildByName("title")
        btn.title:setString(btn_label_list[i])
        btn.title:setTextColor(cc.c4b(0xEE, 0xD1, 0xAF, 0xff))
        btn.title:enableOutline(cc.c4b(0x53, 0x3D, 0x32, 0xff), 2)
        btn.index = i
        self.btn_list[i] = btn
    end

    local layerReward = self.background:getChildByName("layerReward")
    self.touchTotleDay = {}
    for i=1, 7 do
        local tab = {}
        tab.btn = layerReward:getChildByName("reward_"..i)
        tab.red_point = tab.btn:getChildByName("redpoint")
        tab.red_point:setVisible(false)

        local textDay = tab.btn:getChildByName("day")
        textDay:setString(TI18N("第")..i..TI18N("天"))

        tab.rewardImage = tab.btn:getChildByName("rewardImage")
        tab.show_day_icon = tab.btn:getChildByName("rewardItem")
        tab.show_day_icon:setScale(0.8)
        self.touchTotleDay[i] = tab
    end
    
    self.finish_round = self.background:getChildByName("finish_round")
    self.day_title = self.background:getChildByName("day_title")
    self.main_container:getChildByName("Text_19"):setString(TI18N("剩余时间: "))
    self.background:getChildByName("Text_1"):setString(TI18N("完成个数"))
  
    self.sevenGoalTime = self.main_container:getChildByName("sevenGoalTime")
    self.bar = self.background:getChildByName("bar")
    self.bar:setScale9Enabled(true)
    self.successNum = self.background:getChildByName("successNum")
    
    local bgSize = self.goods_walfare:getContentSize()
    local scroll_view_size_walfara = cc.size(bgSize.width, bgSize.height)
    local setting = {
        item_class = ActionSevenGoalItem,      -- 单元类
        start_x = 6,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 641,               -- 单元的尺寸width
        item_height = 156,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview_walfare = CommonScrollViewLayout.new(self.goods_walfare, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size_walfara, setting)
    self.item_scrollview_walfare:setSwallowTouches(false)
end


function ActionSevenGoalWindow:register_event()
    self:addGlobalEvent(ActionEvent.UPDATE_SEVENT_GOAL, function(data)
        self:seventGoal(data)
    end)

    self:addGlobalEvent(ActionEvent.UPDATE_SEVENT_GET, function(data)
        self:seventGet(data)
    end)

    for k,v in pairs(self.btn_list) do
        registerButtonEventListener(v, function()
            self:selectByBtn(k)
        end,false, 1)
    end
    
    for k,v in pairs(self.touchTotleDay) do
        registerButtonEventListener(v.btn, function()
            if k > self.initCurrentDay then
                message(TI18N("未达到开放天数")) 
                return
            end
            self:noArriveDayGray(k)
        end,false, 1)
    end

    for k,v in pairs(self.box_list_layer) do
        registerButtonEventListener(v, function()
            local all_target = model:getBoxRewardData()
            if all_target and all_target[k] and all_target[k].id then
                local function callback()
                    controller:cs13602(5, self.currentDay,all_target[k].id,0)
                end
                CommonAlert.showItemApply(TI18N("当前活跃度奖励"), all_target[k].award, callback,TI18N("确定"),
                    nil,nil,TI18N("奖励"),nil,nil,true,nil, nil,{off_y=50})
            end
        end,true, 1)
    end
    
    registerButtonEventListener(self.close_btn, function()
        controller:openSevenGoalView(false)
    end,true, 2)
end

function ActionSevenGoalWindow:openRootWnd()
    controller:cs13601()
end

function ActionSevenGoalWindow:seventGoal(data)
    if not data then return end
    if not data or data.cur_day > 7 or data.cur_day < 1 then
        controller:openSevenGoalView(false)
        return
    end
    doStopAllActions(self.layer_tab)
    data.period = data.period or 1
    if data.period == 7 then
        data.period = 4
    end
    local str_res = string.format("seven_goals/%d",data.period)
    if not self.item_load then
        local res1 = PathTool.getPlistImgForDownLoad(str_res,"action_seven_goal_bg1")
        self.item_load = loadSpriteTextureFromCDN(self.bg_sprite, res1, ResourcesType.single, self.item_load)
    end

    local all_target = model:getBoxRewardData()
    for i=1,4 do
        if self.box_list_layer[i] and all_target[i] then
            self.box_list_layer[i].textNum:setString(all_target[i].goal)
        end
    end

    local config = data_constant.day_item
    if data.period == 2 then
        config = data_constant.day_item1
    elseif data.period == 3 then
        config = data_constant.day_item2
    elseif data.period == 4 then
        config = data_constant.day_item3
    end
    for i=1,7 do
        local item_config = Config.ItemData.data_get_data(config.val[i])
        if item_config then
            local res = PathTool.getItemRes(item_config.icon)
            if self.touchTotleDay[i] then
                delayRun(self.layer_tab,i / display.DEFAULT_FPS,function () 
                    loadSpriteTexture(self.touchTotleDay[i].show_day_icon,res, LOADTEXT_TYPE)
                end)
            end
        end
    end

    delayRun(self.layer_tab,2 / display.DEFAULT_FPS,function () 
        if not self.load_round_finish then
            local res2 = PathTool.getPlistImgForDownLoad(str_res,"seven_goals_1_3")
            self.load_round_finish = loadSpriteTextureFromCDN(self.finish_round, res2, ResourcesType.single, self.load_round_finish)
        end
    end)

    delayRun(self.layer_tab,3 / display.DEFAULT_FPS,function () 
        if not self.load_day_title then
            local res3 = PathTool.getPlistImgForDownLoad(str_res,"seven_goals_1_4")
            self.load_day_title = loadSpriteTextureFromCDN(self.day_title, res3, ResourcesType.single, self.load_day_title)
            self.day_title:setScaleX(8.0)
        end
    end)

    local rove_ro = RoleController:getInstance():getRoleVo()
    self.goalEndTime = data.end_time or 0
    self.currentDay = data.cur_day or 1
    self.initCurrentDay = data.cur_day or 1
    self:noArriveDayGray(self.currentDay)

    self.success_num = data.num or 1
    self.successNum:setString(self.success_num)
    self.bar:setPercent(self:setSemgentPercent(self.success_num))

    self:udpateGoalEndTime()

    local box_list = model:getSevenGoalBoxList()
    self:updateTaskList(box_list)

    if self.cur_index == nil then
        self:selectByBtn(1)
    else
        self:selectByBtn(self.cur_index)
    end
    local initDayRed = self:initRedPointDay(self.currentDay)
    for i,v in ipairs(initDayRed) do
        if v and self.touchTotleDay[i] then
            self.touchTotleDay[i].red_point:setVisible(v)
        end
    end
    self:redPointTabDayList(self.currentDay)
end

function ActionSevenGoalWindow:udpateGoalEndTime()
    if not self.goalEndTime then return end
    if not self.sevenGoalTime then return end
    doStopAllActions(self.sevenGoalTime)
    if self.goalEndTime > 0 then
        self.sevenGoalTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
        cc.CallFunc:create(function()
            self.goalEndTime = self.goalEndTime - 1
            if self.goalEndTime <= 0 then
                doStopAllActions(self.sevenGoalTime)
                self.sevenGoalTime:setString("00:00:00")
            else
                self.sevenGoalTime:setString(TimeTool.GetTimeFormatDayIIIIIIII(self.goalEndTime))
            end
        end))))
        self:sevenGoalRemainTime()
    else
        doStopAllActions(self.sevenGoalTime)
        self.sevenGoalTime:setString("00:00:00")
    end
end

function ActionSevenGoalWindow:seventGet(data)
    if not data then return end
    self.success_num = data.num or 1
    self.successNum:setString(self.success_num)
    self.bar:setPercent(self:setSemgentPercent(self.success_num))
    local sort_list = {}
    local config_data = {}
    local serve_data = {}
    local sort_updata_data = {}

    if data.type == 1 or data.type == 2 or data.type == 3 then
        if data.type == 1 then
            config_data = model:getWalfareData(data.day_type)
            serve_data = model:getSevenGoalWelfareList(data.day_type)
        elseif data.type == 2 then
            config_data = model:getWalfareGrowUpData(data.day_type)
            serve_data = model:getServerGrowListData(data.day_type)
        elseif data.type == 3 then
            config_data = model:getWelfareGiftData(data.day_type)
            serve_data = model:getServerGiftListData(data.day_type)
        end
        local index = 1
        for i,v in ipairs(serve_data) do
            if v and v.goal_id and v.goal_id == data.id then
                index = i
                break
            end
        end
        if data.type == 1 then
            model:updataGoalWelfareList(data.day_type, index, data.status)
            sort_updata_data = model:getSevenGoalWelfareList(self.currentDay)
        elseif data.type == 2 then
            model:updataGrowListData(data.day_type, index, data.status)
            sort_updata_data = model:getServerGrowListData(data.day_type)
        elseif data.type == 3 then
            model:updataGiftListData(data.day_type, index, data.status)
            sort_updata_data = model:getServerGiftListData(data.day_type)
        end
        sort_updata_data = self:reverseTable(deepCopy(sort_updata_data))
        sort_updata_data = self:sortFunc(sort_updata_data)
        for i,v in ipairs(sort_updata_data) do
            for k,val in ipairs(config_data) do
                if v.goal_id == val.goal_id then
                    table_insert(sort_list, val)
                end
            end
        end
        config_data = sort_list
        local status = false
        for i, v in ipairs(sort_updata_data) do
            if v.status == 1 then
                status = true
                break
            end
        end
        if data.type == 1 then
            model:updataRedPointWelfareStatus(data.day_type, status)
        elseif data.type == 2 then
            model:updataRedPointGrowStatus(data.day_type, status)
        elseif data.type == 3 then
            model:updataRedPointGiftStatus(data.day_type, status)
        end
        local tab = {}
        tab.list = deepCopy(sort_updata_data)
        tab.type = self.cur_index
        tab.day = data.day_type
        tab.init_cur_day = self.initCurrentDay
        self.item_scrollview_walfare:setData(config_data, nil, nil, tab)

    elseif data.type == 4 then
        local half_data = model:getWelfareHalfData(data.day_type)
        local half_list = model:getHalfGiftList(data.day_type)

        local index = 1
        for i,v in ipairs(half_list) do
            if v.day == data.id then
                index = i
                break
            end
        end
        model:updataHalfListData(data.day_type, index, data.status)
        local half_updata_list = model:getHalfGiftList(data.day_type)

        table.sort( half_updata_list, function(a,b)
            if a.status < b.status then
                return a.status < b.status
            end
        end )

        for i,v in ipairs(half_updata_list) do
            for k,val in ipairs(half_data) do
                if v.day == val.id then
                    table_insert(sort_list, val)
                end
            end
        end
        half_data = sort_list

        local status = false
        for i, v in ipairs(half_updata_list) do
            if v.day <= 7 and v.status == 0 then
                status = true
                break
            end
        end
        model:updataRedPointHalfStatus(data.day_type, status)

        local tab = {}
        tab.list = deepCopy(half_updata_list)
        tab.type = self.cur_index
        tab.day = data.day_type
        tab.init_cur_day = self.initCurrentDay
        self.item_scrollview_walfare:setData(half_data, nil, nil, tab)

    elseif data.type == 5 then --宝箱
        local all_target = model:getBoxRewardData()
        local count_num = 1
        for i,v in ipairs(all_target) do
            if v.id == data.id then
                count_num = i
                break
            end
        end

        model:updataBoxListData(count_num, data.status)
        local box_list = model:getSevenGoalBoxList()
        self:updateTaskList(box_list)
        model:updataRedPointBoxStatus(count_num, box_list[count_num].status)
    end
    local all_target = model:getBoxRewardData()
    if self.success_num == all_target[1].goal or self.success_num == all_target[2].goal or self.success_num == all_target[3].goal or self.success_num == all_target[4].goal then                
        local box_list = model:getSevenGoalBoxList()
        for i=1,4 do
            if self.success_num == all_target[i].goal then
                if box_list[i].status == 0 then
                    box_list[i].status = 1
                end
            end
        end
        self:updateTaskList(box_list)
    end

    self:redPointTabDayList(data.day_type, true)
end

function ActionSevenGoalWindow:sevenGoalRemainTime()
    self.goalEndTime = self.goalEndTime - 1
    if self.goalEndTime <= 0 then
        doStopAllActions(self.sevenGoalTime)
        self.sevenGoalTime:setString("00:00:00")
    end
    self.sevenGoalTime:setString(TimeTool.GetTimeFormatDayIIIIIIII(self.goalEndTime))
end

--未开启的天数灰化      传入当前的天数
function ActionSevenGoalWindow:noArriveDayGray(day)
    day = day or 1
    if self.cur_index then
        self.currentDay = day
        self:selectByBtn( self.cur_index )
    end
    local number_period = model:getSevenGoldPeriod()
    if number_period == 7 then
        number_period = 4
    end
    local str_res = string.format("seven_goals/%d",number_period)
    for i=1, 7 do
        delayRun(self.layer_tab,i / display.DEFAULT_FPS,function () 
            if i <= self.initCurrentDay then
                if i == day then
                    local res = PathTool.getPlistImgForDownLoad(str_res,"seven_goals_1_2")
                    if not self.load_touch_day[day] then
                        if self.touchTotleDay[i].rewardImage then
                            self.load_touch_day[day] = loadSpriteTextureFromCDN(self.touchTotleDay[day].rewardImage, res, ResourcesType.single, self.load_touch_day[day])
                        end
                    end
                    if self.load_touch_day[day] then
                        if self.touchTotleDay[i].rewardImage then
                            loadSpriteTexture(self.touchTotleDay[day].rewardImage,res, LOADTEXT_TYPE)
                        end
                    end
                else
                    local res = PathTool.getPlistImgForDownLoad(str_res,"seven_goals_1_1")
                    if not self.load_touch_day[i] then
                        if self.touchTotleDay[i].rewardImage then
                            self.load_touch_day[i] = loadSpriteTextureFromCDN(self.touchTotleDay[i].rewardImage, res, ResourcesType.single, self.load_touch_day[i])
                        end
                    end
                    if self.load_touch_day[i] then
                        if self.touchTotleDay[i].rewardImage then
                            loadSpriteTexture(self.touchTotleDay[i].rewardImage,res, LOADTEXT_TYPE)
                        end
                    end
                end
            else
                if self.touchTotleDay[i] then
                    setChildUnEnabled(true, self.touchTotleDay[i].btn,cc.c4b(0xD3,0xD3,0xD3,0xff))
                end
                local res = PathTool.getPlistImgForDownLoad(str_res,"seven_goals_1_1")
                if not self.load_touch_day[i] then
                    if self.touchTotleDay[i].rewardImage then
                        self.load_touch_day[i] = loadSpriteTextureFromCDN(self.touchTotleDay[i].rewardImage, res, ResourcesType.single, self.load_touch_day[i])
                    end
                end
                if self.load_touch_day[i] then
                    if self.touchTotleDay[i].rewardImage then
                        loadSpriteTexture(self.touchTotleDay[i].rewardImage,res, LOADTEXT_TYPE)
                    end
                end
            end
        end)
    end
end

--逆向排序
function ActionSevenGoalWindow:reverseTable(tab)
    if tab == nil then return {} end
    local tmp = {}
    for i = 1, #tab do
        tmp[i] = table.remove(tab)
    end
    return tmp
end
function ActionSevenGoalWindow:sortFunc(data)
    local tempsort = {
        [0] = 2,  -- 0 未领取放中间
        [1] = 1,  -- 1 可领取放前面
        [2] = 3,  -- 2 已领取放最后
    }
    local function sortFunc( objA, objB )
        if objA.status ~= objB.status then
            if tempsort[objA.status] and tempsort[objB.status] then
                return tempsort[objA.status] < tempsort[objB.status]
            else
                return false
            end
        else
            return objA.goal_id < objB.goal_id
        end
    end
    table.sort(data, sortFunc)
    return data
end

--获取名字
function ActionSevenGoalWindow:getTabName(day)
    local grow = model:getWalfareGrowUpData(day)
    local gift = model:getWelfareGiftData(day)
    local name1,name2 = "",""
    if next(grow) ~= nil and grow[1].type_name then
        name1 = grow[1].type_name
    end
    if next(gift) ~= nil and gift[1].type_name then
        name2 = gift[1].type_name
    end
    return name1,name2
end

--主切换按钮
function ActionSevenGoalWindow:selectByBtn( index )
    index = index or 1
    if self.cur_select ~= nil then
        self.cur_select.select:setVisible(false)
        self.cur_select.title:setTextColor(cc.c4b(0xEE, 0xD1, 0xAF, 0xff))
        self.cur_select.title:enableOutline(cc.c4b(0x53, 0x3D, 0x32, 0xff), 2)
    end
    self.cur_index = index
    self.cur_select = self.btn_list[self.cur_index]
    if self.cur_select ~= nil then
        self.cur_select.select:setVisible(true)
        self.cur_select.title:disableEffect(cc.LabelEffect.OUTLINE)
        self.cur_select.title:setTextColor(cc.c4b(0x64, 0x32, 0x23, 0xff))
    end

    self:redPointTabDayList(self.currentDay)

    local walfare_data = {}
    local serve_list = {}
    local sort_list = {}

    if self.cur_index == 1 then
        walfare_data = model:getWalfareData(self.currentDay)
        serve_list = model:getSevenGoalWelfareList(self.currentDay)
    elseif self.cur_index == 2 then
        walfare_data = model:getWalfareGrowUpData(self.currentDay)
        serve_list = model:getServerGrowListData(self.currentDay)
    elseif self.cur_index == 3 then
        walfare_data = model:getWelfareGiftData(self.currentDay)
        serve_list = model:getServerGiftListData(self.currentDay)
    elseif self.cur_index == 4 then
        walfare_data = model:getWelfareHalfData(self.currentDay)
        serve_list = model:getHalfGiftList(self.currentDay)
    end  

    local name1,name2 = self:getTabName(self.currentDay)
    self.btn_list[2].title:setString(name1)
    self.btn_list[3].title:setString(name2)

    if self.cur_index == 4 then
        table.sort( serve_list, function(a,b)
            return a.status < b.status
        end )
        for i,v in ipairs(serve_list) do
            for k,val in ipairs(walfare_data) do
                if v.day == val.id then
                    table_insert(sort_list, val)
                end
            end
        end
    else
        serve_list = self:reverseTable(deepCopy(serve_list))
        serve_list = self:sortFunc(serve_list)
        for i,v in ipairs(serve_list) do
            for k,val in ipairs(walfare_data) do
                if v.goal_id == val.goal_id then
                    table_insert(sort_list, val)
                end
            end
        end
    end
    walfare_data = sort_list

    local tab = {}
    tab.list = serve_list
    tab.type = self.cur_index
    tab.day = self.currentDay
    tab.init_cur_day = self.initCurrentDay
    self.item_scrollview_walfare:setData(walfare_data, nil, nil, tab)
end

--初始化天数的红点
function ActionSevenGoalWindow:initRedPointDay(day)
    if day < 1 or day > 7 then
        return {}
    end
    local status = {}
    for i=1, day do
        status[i] = false
        local welfare_status = model:getRedPointWelfareStatus(i)
        local grow_status = model:getRedPointGrowStatus(i)
        local gift_status = model:getRedPointGiftStatus(i)
        local half_status = model:getRedPointHalfStatus(i)
        
        local total_status = false
        total_status = welfare_status or grow_status or gift_status or half_status
        status[i] = total_status
    end
    return status
end
--实时更新 天数 红点
function ActionSevenGoalWindow:redPointTabDayList(day, _type)
    if self.currentDay < 1 or self.currentDay > 7 then
        return
    end

    local welfare_status = model:getRedPointWelfareStatus(day)
    if self.btn_list[1].red_point then
        self.btn_list[1].red_point:setVisible(welfare_status)
    end

    local grow_status = model:getRedPointGrowStatus(day)
    if self.btn_list[2].red_point then
        self.btn_list[2].red_point:setVisible(grow_status)
    end

    local gift_status = model:getRedPointGiftStatus(day)
    if self.btn_list[3].red_point then
        self.btn_list[3].red_point:setVisible(gift_status)
    end

    local half_status = model:getRedPointHalfStatus(day)
    if self.btn_list[4].red_point then
        self.btn_list[4].red_point:setVisible(half_status)
    end

    if _type then
        local total_status = false
        total_status = welfare_status or grow_status or gift_status or half_status
        if self.touchTotleDay[day].red_point then
            self.touchTotleDay[day].red_point:setVisible(total_status)
        end

        --场景天数红点
        local initDayRed = self:initRedPointDay(self.currentDay)
        local red_point = false
        for i,v in ipairs(initDayRed) do
            if v and v == true then
                red_point = true
                break
            end
        end
        --宝箱
        local boxRed = false
        for i=1,3 do
            local status = model:getRedPointBoxStatus(i)
            if status == true then
                boxRed = true
                break
            end
        end

        local icon_id = MainuiConst.icon.seven_goal3
        if model:getSevenGoldPeriod() == 1 then
            icon_id = MainuiConst.icon.seven_goal
        elseif model:getSevenGoldPeriod() == 2 then
            icon_id = MainuiConst.icon.seven_goal1
        elseif model:getSevenGoldPeriod() == 3 then
            icon_id = MainuiConst.icon.seven_goal2
        elseif model:getSevenGoldPeriod() == 7 then
            icon_id = MainuiConst.icon.seven_goal4
        end
        MainuiController:getInstance():setFunctionTipsStatus(icon_id, red_point or boxRed)
    end
end

function ActionSevenGoalWindow:updateTaskList(data)
    for i=1, 4 do        
        local action = PlayerAction.action_1
        self.box_list_layer[i].redpoint:setVisible(false)

        if next(data) ~= nil and data[i] then
            if data[i] and data[i].status == 0 then
                action = PlayerAction.action_1
            elseif data[i] and data[i].status == 1 then
                action = PlayerAction.action_2
                self.box_list_layer[i].redpoint:setVisible(true)
            elseif data[i] and data[i].status == 2 then
                action = PlayerAction.action_3
            end
        end

        if self.play_effect[i] then
            self.play_effect[i]:clearTracks()
            self.play_effect[i]:removeFromParent()
            self.play_effect[i] = nil
        end
        if not tolua.isnull(self.box_list_layer[i]) and self.play_effect[i] == nil then
            local res_id = PathTool.getEffectRes(self.award_list[i])
            self.play_effect[i] = createEffectSpine(res_id, cc.p(self.box_list_layer[i]:getContentSize().width * 0.5, 0), cc.p(0, 0), true, action)
            self.box_list_layer[i]:addChild(self.play_effect[i])
        end
    end
end

function ActionSevenGoalWindow:setSemgentPercent(num)
    local segmeent = 25
    local percent = 1

    local all_target = model:getBoxRewardData()
    if all_target[1] == nil or all_target[2] == nil or all_target[3] == nil or all_target[4] == nil then return 0 end

    if num <= all_target[1].goal then
        return num / all_target[1].goal * segmeent
    elseif num > all_target[1].goal and num <= all_target[2].goal then
        percent = 2
    elseif num > all_target[2].goal and num <= all_target[3].goal then
        percent = 3
    elseif num > all_target[3].goal and num <= all_target[4].goal then
        percent = 4
    else
        return 100
    end
    local adv = all_target[percent].goal - all_target[percent-1].goal
    local count = num - all_target[percent-1].goal
    local percent_num = segmeent*(percent - 1) + ( count / adv ) * segmeent
    return percent_num
end


function ActionSevenGoalWindow:close_callback()
    doStopAllActions(self.layer_tab)
    self.cur_select = nil
    if self.play_effect and next(self.play_effect or {}) ~= nil then
        for i=1, 4 do
            if self.play_effect[i] then
                self.play_effect[i]:clearTracks()
                self.play_effect[i]:removeFromParent()
                self.play_effect[i] = nil
            end
        end
    end

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    if self.load_round_finish then
        self.load_round_finish:DeleteMe()
    end
    self.load_round_finish = nil
    if self.load_day_title then
        self.load_day_title:DeleteMe()
    end
    self.load_day_title = nil
    
    for i,v in pairs(self.load_touch_day) do
        if v then
            v:DeleteMe()
            v = nil
        end
    end

    self.play_effect = {}
    if self.item_scrollview_walfare then
        self.item_scrollview_walfare:DeleteMe()
        self.item_scrollview_walfare = nil
    end
    doStopAllActions(self.sevenGoalTime)
    controller:openSevenGoalView(false)
end

--子项
ActionSevenGoalItem = class("ActionSevenGoalItem", function()
    return ccui.Widget:create()
end)

function ActionSevenGoalItem:ctor()
    self.goods_list = {}
    self:configUI()
    self:register_event()
end

function ActionSevenGoalItem:configUI( )
    self.size = cc.size(641,156)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("action/action_seven_goal_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.goods_con = self.main_container:getChildByName("goods_con")
    self.has_bg = self.main_container:getChildByName("has_bg")
    self.has_bg:setVisible(false)

    self.textGet = self.main_container:getChildByName("textGet")
    self.btn_get = self.main_container:getChildByName("btn_get")
    self.btn_get:setTitleText(TI18N("领取"))
    local btn_get_label = self.btn_get:getTitleRenderer()
    if btn_get_label ~= nil then
        btn_get_label:enableOutline(Config.ColorData.data_color4[277], 2)
    end
    self.btn_get:setVisible(false)

    self.btn_goto = self.main_container:getChildByName("btn_goto")
    self.btn_goto:setTitleText(TI18N("前往"))
    self.btn_goto_label = self.btn_goto:getTitleRenderer()
    if self.btn_goto_label ~= nil then
        self.btn_goto_label:enableOutline(Config.ColorData.data_color4[278], 2)
    end
    self.btn_goto:setVisible(false)

    self.half_panel = self.main_container:getChildByName("half_panel")
    self.half_panel:getChildByName("Text_1"):setString(TI18N("原价:"))
    self.price_1 = self.half_panel:getChildByName("price_1")
    self.btn_buy = self.half_panel:getChildByName("btn_buy")
    self.price_2 = self.btn_buy:getChildByName("price_2")
    self.half_panel:setVisible(false)

    self.title_txt = self.main_container:getChildByName("title_txt")
end

function ActionSevenGoalItem:setExtendData(tab)
    self.serve_list = tab.list
    self.type = tab.type
    self.cur_day = tab.day
    self.init_cur_day = tab.init_cur_day
end

function ActionSevenGoalItem:setData( data )
    if not data or next(data) == nil then return end
    self.data = data
    if data.desc then
        self.title_txt:setString(data.desc)
    end

    for i,v in pairs(self.goods_list) do
        v:setVisible(false)
    end
    for i=1, #data.award1 do
        if not self.goods_list[i] then
            local item = BackPackItem.new(false, true, false, 0.7, false)
            item:setAnchorPoint(0, 0.5)
            item:setSwallowTouches(false)
            self.goods_con:addChild(item)
            self.goods_list[i] = item
        end
        item = self.goods_list[i]
        if item then
            item:setVisible(true)
            item:setPosition((i - 1)*(BackPackItem.Width*0.7+25), 45)
            item:setBaseData(data.award1[i][1], data.award1[i][2])
            item:setDefaultTip()
        end
    end

    if self.type == 1 then
        local val = self.serve_list[self.data._index]
        if val then
            local value = val.value or 0
            local target_val = val.target_val or 0
            local str = string.format("%d/%d",value,target_val)
            self.textGet:setString(str)
        end
    elseif self.type == 2 or self.type == 3 then
        if self.serve_list[self.data._index].progress and self.serve_list[self.data._index].progress[1] then
            local val = self.serve_list[self.data._index].progress[1]
            if val then
                local value = val.value or 0
                local target_val = val.target_val or 0
                local str = string.format("%d/%d",value,target_val)
                self.textGet:setString(str)
            end
        end
    elseif self.type == 4 then        
        self.btn_goto:setVisible(false)
        self.btn_get:setVisible(false)
        self.has_bg:setVisible(false)

        self.price_1:setString(data.price1)
        self.price_2:setString(data.price2)
        if self.serve_list[self.data._index].status == 0 then
            self.half_panel:setVisible(true)
            self.has_bg:setVisible(false)
            self.textGet:setString(TI18N("剩余: 1"))
        else
            self.half_panel:setVisible(false)
            self.has_bg:setVisible(true)
            self.textGet:setString(TI18N("剩余: 0"))
        end
    end

    if self.type ~= 4 then
        self.half_panel:setVisible(false)
        self.btn_goto:setVisible(self.serve_list[self.data._index].status == 0)
        self.btn_get:setVisible(self.serve_list[self.data._index].status == 1)
        self.has_bg:setVisible(self.serve_list[self.data._index].status == 2)
        if self.init_cur_day and self.cur_day > self.init_cur_day then
            self.btn_goto:setVisible(true)
            self.btn_goto:setTitleText(TI18N("未解锁"))
            setChildUnEnabled(true, self.btn_goto)
            self.btn_goto_label:disableEffect(cc.LabelEffect.OUTLINE)
            self.btn_goto:setTouchEnabled(false)
            self.btn_get:setVisible(false)
            self.has_bg:setVisible(false)
        else
            setChildUnEnabled(false, self.btn_goto)
            self.btn_goto_label:enableOutline(Config.ColorData.data_color4[278], 2)
            self.btn_goto:setTouchEnabled(true)
        end
    end
end

function ActionSevenGoalItem:register_event( )
    registerButtonEventListener(self.btn_get, function()
        ActionController:getInstance():cs13602(self.type, self.cur_day, self.serve_list[self.data._index].goal_id, self.data._index)
    end,true, 1)

    registerButtonEventListener(self.btn_goto, function()
        StrongerController:getInstance():clickCallBack(self.data.show_icon)
        ActionController:getInstance():openSevenGoalView(false)
    end,true, 1)

    registerButtonEventListener(self.btn_buy, function()
        ActionController:getInstance():cs13602(self.type, self.cur_day, self.data.id, self.data._index)
    end,true, 1)
end

function ActionSevenGoalItem:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end 
    if self.goods_list and next(self.goods_list or {}) ~= nil then
        for i, v in ipairs(self.goods_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self:removeAllChildren()
    self:removeFromParent()
end
--****************
--魔盒
--****************
local color_data = {
    [1] = cc.c4b(0xff,0xc9,0x89,0xff),
}
SevenGoalSecretWindow = SevenGoalSecretWindow or BaseClass(BaseView)

local controller = SevenGoalController:getInstance()
local make_lev_list = Config.DayGoalsNewData.data_make_lev_list
local cycle_item = Config.DayGoalsNewData.data_circle_exp_item
local charge_list = Config.DayGoalsNewData.data_charge_list
local group_list = Config.DayGoalsNewData.data_group_list
local table_insert = table.insert
local string_format = string.format
function SevenGoalSecretWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Big      
    self.view_tag = ViewMgrTag.DIALOGUE_TAG    	
    self.layout_name = "seven_goal/seven_goal_secret_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("seven_goals", "seven_gold"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("seven_goals/banner","seven_goals_banner_3"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("seven_goals/banner","seven_goals_banner_4"), type = ResourcesType.single},
    }
    self.tesk_list = {}
    self.totleChargeData = {}
    self.role_vo = RoleController:getInstance():getRoleVo()
end

function SevenGoalSecretWindow:open_callback()
    local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 1)

    self.time_text = main_container:getChildByName("time_text")
    self.time_text:setString("")

    local role_spr = main_container:getChildByName("role_spr")
    local res = PathTool.getPlistImgForDownLoad("seven_goals/banner", "seven_goals_banner_4")
    self.item_load_role = loadSpriteTextureFromCDN(role_spr, res, ResourcesType.single, self.item_load_role)
    local charge_spr = main_container:getChildByName("charge_spr")
    local res_1 = PathTool.getPlistImgForDownLoad("seven_goals/banner", "seven_goals_banner_3")
    self.item_load_charge = loadSpriteTextureFromCDN(charge_spr, res_1, ResourcesType.single, self.item_load_charge)

    local charge_image = main_container:getChildByName("charge_image")
    self.btn_more_charge = charge_image:getChildByName("btn_more_charge")
    self.btn_goto = charge_image:getChildByName("btn_goto")
    self.btn_goto:getChildByName("Text_17"):setString(TI18N("前往"))
    self.btn_get = charge_image:getChildByName("btn_get")
    self.btn_get:setVisible(false)
    self.btn_get:getChildByName("Text_17"):setString(TI18N("领取"))
    self.has_spr = charge_image:getChildByName("has_spr")
    self.has_spr:setVisible(false)
    self.charge_tesk = createRichLabel(22, color_data[1], cc.p(0,0.5), cc.p(19,118), nil, nil, nil)
    charge_image:addChild(self.charge_tesk)
    
    local good_cons = charge_image:getChildByName("good_cons")
    local scroll_next_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.70,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.70,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.70,                     -- 缩放
        need_dynamic = true,
    }
    self.charge_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_next_size, setting)
    self.charge_scrollview:setSwallowTouches(false)
    
    local tesk_finish_image = main_container:getChildByName("tesk_finish_image")
    self.btn_more = tesk_finish_image:getChildByName("btn_more")
    self.red_point = self.btn_more:getChildByName("red_point")
    self.red_point:setVisible(false)
    self.btn_more:getChildByName("Text_18"):setString(TI18N("查看魔盒秘密"))
    self.bar = tesk_finish_image:getChildByName("bar")
    self.bar:setScale9Enabled(true)
    self.bar:setPercent(0)
    self.bar_num = tesk_finish_image:getChildByName("bar_num")
    self.bar_num:setString("")
    self.icon_sprite = tesk_finish_image:getChildByName("icon_sprite")
    self.icon_num = tesk_finish_image:getChildByName("icon_num")
    self.icon_num:setString("")
    self.btn_tips = tesk_finish_image:getChildByName("btn_tips")
    tesk_finish_image:getChildByName("Text_19"):setString(TI18N("已积攒希望印记"))
    tesk_finish_image:getChildByName("Text_19_0"):setString(TI18N("今日进度"))
    tesk_finish_image:getChildByName("Text_19_1"):setString(TI18N("每日0点刷新任务"))

    self.tesk_panel = main_container:getChildByName("tesk_panel")
    self.tesk_panel:setScrollBarEnabled(false)
    self.btn_close = main_container:getChildByName("btn_close")
end
--进度数据
function SevenGoalSecretWindow:setChangeLev(lev,exp)
    local period = controller:getModel():getSevenGoalPeriod()
    if make_lev_list[period] == nil then return end
    local length = 0
    lev = lev or 1
    exp = exp or 1
    lev = lev + 1
    if make_lev_list[period] ~= nil then
        length = #make_lev_list[period]
    end
    local max_lex = length
    if lev >= max_lex then
        lev = max_lex
    end
    self.bar_num:setString(exp.."/"..make_lev_list[period][lev].exp)
    self.bar:setPercent(exp/make_lev_list[period][lev].exp * 100)

    local item_config = Config.ItemData.data_get_data(cycle_item[period].item_id)
    if item_config then
        local res = PathTool.getItemRes(item_config.icon)
        loadSpriteTexture(self.icon_sprite,res,LOADTEXT_TYPE)
    end

    local count = self.role_vo:getActionAssetsNumByBid(cycle_item[period].item_id)
    self.icon_num:setString(count or 0)
end
--累充
function SevenGoalSecretWindow:setChangeTotleData(period)
    local totle_charge_data = self:getTotalChargeData()
    if totle_charge_data and next(totle_charge_data) and totle_charge_data[1] and charge_list[period] then
        local cur_tesk = charge_list[period][totle_charge_data[1].id].desc or ""
        local cur_number = totle_charge_data[1].value or 0
        local cur_totle = totle_charge_data[1].target_val or 0
        local str = string_format("%s (%d/%d)",cur_tesk, cur_number, cur_totle)
        self.charge_tesk:setString(str)
        
        self.btn_goto:setVisible(totle_charge_data[1].finish == 0)
        self.btn_get:setVisible(totle_charge_data[1].finish == 1)
        self.has_spr:setVisible(totle_charge_data[1].finish == 2)

        if self.charge_scrollview then
            local list = {}
            for k, v in pairs(charge_list[period][totle_charge_data[1].id].award) do
                local vo = {}
                vo.bid = v[1]
                vo.quantity = v[2]
                table.insert(list, vo)
            end
            if #list > 4 then
                self.charge_scrollview:setClickEnabled(true)
            else
                self.charge_scrollview:setClickEnabled(false)
            end
            self.charge_scrollview:setData(list)
            self.charge_scrollview:addEndCallBack(function()
                local list = self.charge_scrollview:getItemList()
                for k,v in pairs(list) do
                    v:setDefaultTip()
                end
            end)
        end
    end
end
--查看更多红点
function SevenGoalSecretWindow:setMoreResPoint()
    local red_status = false
    red_status = controller:getModel():setMoreResPoint()
    if self.red_point then
        self.red_point:setVisible(red_status)
    end
    controller:getModel():checkMainRedPoint()
end

function SevenGoalSecretWindow:register_event()
    if not self.role_secret_event and self.role_vo then
        self.role_secret_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS, function(id, value)
            local period = controller:getModel():getSevenGoalPeriod()
            local item_num = cycle_item[period].item_id or 0
            if id and item_num and id == item_num and self.role_vo then 
                local count = self.role_vo:getActionAssetsNumByBid(item_num)
                self.icon_num:setString(count)
            end
        end)
    end
    self:addGlobalEvent(SevenGoalEvent.BaseMessage, function(data)
        if not data or next(data) == nil then return end
        self:setChangeLev(data.lev,data.exp)
        local time = (data.end_time - GameNet:getInstance():getTime()) or 0
        self:setLessTime(time)
        self:setMoreResPoint()

        local cur_period = data.period or 0
        local data_list = controller:getModel():getInitSevenGoalData()
        local tesk_data_list_common = {} --普通任务
        self.totleChargeData = {} --累充任务
        if data_list and charge_list[cur_period] then
            for i,v in pairs(data_list) do
                local status = false
                for m,val in pairs(charge_list[cur_period]) do
                    if v.id == val.goal_id then
                        status = true
                        break
                    end
                end
                if status == true then
                    table_insert(self.totleChargeData,v)
                else
                    table_insert(tesk_data_list_common,v)
                end
            end
        end
        self.tesk_panel:setInnerContainerSize(cc.size(624,543))
        local pos_y = self.tesk_panel:getInnerContainerSize().height - 118
        for i=1,6 do
            delayRun(self.tesk_panel, i*2/60, function()
                if not self.tesk_list[i] then
                    self.tesk_list[i] = SevenGoalSecretItem.new()
                    self.tesk_panel:addChild(self.tesk_list[i])
                end
                if self.tesk_list[i] then
                    self.tesk_list[i]:setExtendData(cur_period)
                    self.tesk_list[i]:setData(tesk_data_list_common[i] or {})
                    local val = (i-1)%3
                    self.tesk_list[i]:setPosition(103+(210*val),pos_y-(282*math.floor(i/4)))
                end
            end)
        end
        self:setChangeTotleData(cur_period)
    end)

    self:addGlobalEvent(SevenGoalEvent.Tesk_Updata, function(data)
        if not data or next(data) == nil then return end
        local data_list = controller:getModel():getInitSevenGoalData()
        local period = controller:getModel():getSevenGoalPeriod()
        local tesk_data_list_common = {} --普通任务
        self.totleChargeData = {} --累充任务
        if data_list and charge_list[period] then
            for i,v in pairs(data_list) do
                local status = false
                for m,val in pairs(charge_list[period]) do
                    if v.id == val.goal_id then
                        status = true
                        break
                    end
                end
                if status == true then
                    table_insert(self.totleChargeData,v)
                else
                    table_insert(tesk_data_list_common,v)
                end
            end
        end
        for i=1,6 do
            if self.tesk_list[i] then
                self.tesk_list[i]:setExtendData(period)
                self.tesk_list[i]:setData(tesk_data_list_common[i])
            end
        end
        self:setChangeTotleData(period)
    end)

    self:addGlobalEvent(SevenGoalEvent.Reward_Lev, function(data)
        if not data or next(data) == nil then return end
        self:setMoreResPoint()
    end)

    self:addGlobalEvent(SevenGoalEvent.Updata_Lev, function(data)
        if not data or next(data) == nil then return end
        controller:getModel():setSevenGoalLev(data.lev)
        self:setMoreResPoint()
        self:setChangeLev(data.lev,data.exp)
    end)
	registerButtonEventListener(self.btn_close, function()
        controller:openSevenGoalSecretView(false)
    end,true, 2)
    registerButtonEventListener(self.btn_more_charge, function()
        controller:openSevenGoalTotleChargeView(true)
    end,true, 1)
    registerButtonEventListener(self.btn_goto, function()
        StrongerController:getInstance():clickCallBack(131)
    end,true, 1)
    registerButtonEventListener(self.btn_get, function()
        local totle_charge_data = self:getTotalChargeData()
        local id = totle_charge_data[1].id
        if id then
            controller:sender13606(id)
        end
    end,true, 1)
    registerButtonEventListener(self.btn_tips, function(param,sender, event_type)
        local config = Config.DayGoalsNewData.data_constant.tips_1.desc
        TipsManager:getInstance():showCommonTips(config, sender:getTouchBeganPosition(),nil,nil,500)
    end,true, 1,nil,0.8)
    registerButtonEventListener(self.btn_more, function()
        controller:openSevenGoalAdventureLevRewardView(true)
    end,true, 1)
end
--设置倒计时
function SevenGoalSecretWindow:setLessTime(less_time)
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
function SevenGoalSecretWindow:setTimeFormatString(time)
    if time > 0 then
        self.time_text:setString(TimeTool.GetTimeFormatDayIIIIIIII(time))
    else
        self.time_text:setString("00:00:00")
    end
end
function SevenGoalSecretWindow:getTotalChargeData()
    return self.totleChargeData or {}
end
function SevenGoalSecretWindow:openRootWnd()
    controller:sender13604()
end
function SevenGoalSecretWindow:close_callback()
    doStopAllActions(self.tesk_panel)
    if self.item_load_role then 
        self.item_load_role:DeleteMe()
        self.item_load_role = nil
    end
	if self.item_load_charge then 
        self.item_load_charge:DeleteMe()
        self.item_load_charge = nil
    end
    if self.charge_scrollview then
        self.charge_scrollview:DeleteMe()
    end
    self.charge_scrollview = nil
    if self.tesk_list then
        for i,v in pairs(self.tesk_list) do
            v:DeleteMe()
        end
        self.tesk_list = nil
    end
    if self.role_secret_event then
        self.role_vo:UnBind(self.role_secret_event)
        self.role_secret_event = nil
    end
    controller:openSevenGoalSecretView(false)
end

--******************
--子项
SevenGoalSecretItem = class("SevenGoalSecretItem", function()
    return ccui.Widget:create()
end)

function SevenGoalSecretItem:ctor()
    self:configUI()
    self:register_event()
end

function SevenGoalSecretItem:configUI()
    self.rootWnd = createCSBNote(PathTool.getTargetCSB("seven_goal/seven_goal_secret_item"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.rootWnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(212,260))

    local main_container = self.rootWnd:getChildByName("main_container")
    self.finish_spr = main_container:getChildByName("finish_spr")
    self.finish_spr:setVisible(false)
    self.finish_spr:setLocalZOrder(10)
    self.name = main_container:getChildByName("name")
    self.name:setString("")
    self.tesk_num = main_container:getChildByName("tesk_num")
    self.tesk_num:setString("")
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("Text_2"):setString(TI18N("前往"))
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get:getChildByName("Text_2"):setString(TI18N("领取"))

    self.reward_item = BackPackItem.new(nil,true,nil,0.8)
    main_container:addChild(self.reward_item)
    self.reward_item:setPosition(cc.p(main_container:getContentSize().width/2, 131))
    self.reward_item:setDefaultTip()
end

function SevenGoalSecretItem:setExtendData(period)
    self.cur_secret_period = period
end

function SevenGoalSecretItem:setData(data)
    if not data or next(data) == nil then return end
    self.data = data
    local str = string_format("(%d/%d)",data.value,data.target_val)
    self.tesk_num:setString(str)

    if not group_list[self.cur_secret_period] then return end

    local desc = ""
    if group_list[self.cur_secret_period][data.id] then
        desc = group_list[self.cur_secret_period][data.id].desc
    end
    self.name:setString(desc)
    if group_list[self.cur_secret_period][data.id] then
        self.reward_item:setBaseData(group_list[self.cur_secret_period][data.id].award[1][1],group_list[self.cur_secret_period][data.id].award[1][2])
    end
    self.btn_goto:setVisible(data.finish == 0)
    self.btn_get:setVisible(data.finish == 1)
    self.finish_spr:setVisible(data.finish == 2)

end
function SevenGoalSecretItem:register_event()
    registerButtonEventListener(self.btn_get, function()
        if self.data and self.data.id then
            controller:sender13606(self.data.id)
        end
    end,true, 1)
    registerButtonEventListener(self.btn_goto, function()
        if self.cur_secret_period and self.data and self.data.id then
            local id = nil
            if group_list[self.cur_secret_period][self.data.id] then
                id = group_list[self.cur_secret_period][self.data.id].show_icon
                if id then
                    StrongerController:getInstance():clickCallBack(id)
                end
            end
        end
    end,true, 1)
end
function SevenGoalSecretItem:DeleteMe()
    if self.reward_item then 
       self.reward_item:DeleteMe()
       self.reward_item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
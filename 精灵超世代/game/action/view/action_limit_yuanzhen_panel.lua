-- --------------------------------------------------------------------
-- @author: lwc
--   限时活动通用模板(有倒计时时间的 和一个按钮的)
-- <br/>Create: 
-- --------------------------------------------------------------------
ActionLimitYuanZhenPanel = class("ActionLimitYuanZhenPanel", function()
    return ccui.Widget:create()
end)

ActionLimitYuanZhenPanel.action_yuanzhen_id = 13005
ActionLimitYuanZhenPanel.action_summer_id = 25013
ActionLimitYuanZhenPanel.action_wolf_id = 26002

local controller = ActionController:getInstance()
local string_format = string.format
local table_insert = table.insert
--@ bid 活动id 参照 holiday_role_data 表
--@ type 活动类型 参照 ActionType.Wonderful 定义
function ActionLimitYuanZhenPanel:ctor(bid, type)
    self.holiday_bid = bid
    self.type = type
    self:configUI()
    self:register_event()

    --scrollview列表
    self.limit_list = {}
    --self.dic_limit_list[id] = self.limit_list[n] 用于刷新数据用
    self.dic_limit_list = {}

    --根据任务id 保存的列表
    self.dic_task_list = {}
    --时间的label
    self.time_desc_list = {}
end

function ActionLimitYuanZhenPanel:configUI( )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_limit_yuanzhen_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container_size = self.main_container:getContentSize()

    local title_con = self.main_container:getChildByName("title_con")
    title_con:getChildByName("time_title"):setString(TI18N("剩余时间:"))
    self.time_val = title_con:getChildByName("time_val")
    self.goods_con = self.main_container:getChildByName("goods_con")

    -- 横幅图片
    local title_img = title_con:getChildByName("title_img")
    local title_desc= title_con:getChildByName("title_desc")
    local title_str = "txt_cn_welfare_banner17"
    if  self.holiday_bid == ActionRankCommonType.merge_task then
        title_str = "txt_cn_welfare_banner77"
        title_desc:setString(TI18N("一起来完成合服任务领取奖励吧！"))
        title_desc:setVisible(true)
    end
    self.activity_id = 0
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo then
        --网络传过来的优先拿网络的
        if tab_vo.reward_title ~= nil and tab_vo.reward_title ~= "" then
            title_str = tab_vo.reward_title
        end
        self.activity_id = tab_vo.camp_id
    end

    local res = PathTool.getWelfareBannerRes(title_str, false)
    self.item_load = loadSpriteTextureFromCDN(title_img, res, ResourcesType.single, self.item_load)

    -- 活动剩余时间
    local time = 0
    if tab_vo then
        time = tab_vo.remain_sec or 0
    end
    if time < 0 then
        time = 0
    end
    self:setLessTime(time)
    --左边按钮
    self.common_btn = title_con:getChildByName("common_btn")
    if self.holiday_bid == ActionRankCommonType.action_wolf or self.holiday_bid == ActionRankCommonType.exercise_1 or
       self.holiday_bid == ActionRankCommonType.exercise_2 or self.holiday_bid == ActionRankCommonType.exercise_3 or
       self.holiday_bid == ActionRankCommonType.merge_task  then
        self.common_btn:setVisible(false)
    else
        self.common_btn:setVisible(true)
    end
    
    if self.item_scrollview == nil then
        local scroll_view_size = self.goods_con:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 10,                     -- y方向的间隔
            item_width = 680,                -- 单元的尺寸width
            item_height = 136,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    if self.holiday_bid == ActionRankCommonType.yuanzhen_adventure then
        controller:sender24810()
    elseif self.holiday_bid == ActionRankCommonType.exercise_1 then
        controller:sender24813()
    elseif self.holiday_bid == ActionRankCommonType.exercise_2 then
        controller:sender24815()
    elseif self.holiday_bid == ActionRankCommonType.exercise_3 or self.holiday_bid == ActionRankCommonType.merge_task then
        controller:sender24817()
    else
        controller:cs16603(self.holiday_bid)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionLimitYuanZhenPanel:createNewCell(width, height)
   local cell = ActionLimitCommonItem2.new(self.action_id)
   cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ActionLimitYuanZhenPanel:numberOfCells()
    if not self.limit_list then return 0 end
    return #self.limit_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ActionLimitYuanZhenPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.limit_list[index]
    if not cell_data then return end
    local config = cell_data.config
    local time_desc = cell:setData(cell_data)
    self.time_desc_list[index] = time_desc
    self:updateTimeByIndex(index, time_desc)
end

--设置倒计时
function ActionLimitYuanZhenPanel:setLessTime(less_time)
    if tolua.isnull(self.time_val) then
        return
    end
    doStopAllActions(self.time_val)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    doStopAllActions(self.time_val)
                    self.time_val:setString("00:00:00")
                else
                    self:setTimeFormatString(less_time)
                end
                
            end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function ActionLimitYuanZhenPanel:setTimeFormatString(time)
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeFormatDayIIIIIIII(time))
    else
        self.time_val:setString("00:00:00")
    end
end

function ActionLimitYuanZhenPanel:updateTimeByIndex(index, time_desc)
    -- body 
    local cell_data = self.limit_list[index]
    if cell_data then
        if time_desc then
            local time = cell_data.end_time - GameNet:getInstance():getTime()
            if time < 0 then
                time = 0
            end
            time_desc:setString(string_format("%s%s", TI18N("剩余"), TimeTool.getDayOrHour(time)))
        end
    end
end

function ActionLimitYuanZhenPanel:register_event(  )
    registerButtonEventListener(self.common_btn, function() self:onCommonBtn() end,true, 2)

    --元宵冒险的  走的不是同一个协议..无奈
    if not self.limin_yuan_zhen_event  then
        self.limin_yuan_zhen_event = GlobalEvent:getInstance():Bind(ActionEvent.YUAN_ZHEN_DATA_EVENT,function (data)
            if not data then return end
            if data.camp_id == self.activity_id then
                local sort_func = SortTools.tableLowerSorter({"id"})
                table.sort(data.quest_list, sort_func)
                self.action_id = data.camp_id
                self:initUI()
                self:initYuanZhenData(data.quest_list, true)
            end
        end)
    end
    --元宵冒险的  走的不是同一个协议..无奈
    if not self.limin_yuan_zhen_update_event  then
        self.limin_yuan_zhen_update_event = GlobalEvent:getInstance():Bind(ActionEvent.YUAN_ZHEN_UPDATA_EVENT,function (data)
            if not data then return end
            self:initYuanZhenData({data})
        end)
    end
    --元宵冒险的  走的不是同一个协议..无奈
    if not self.limin_yuan_zhen_task_event  then
        self.limin_yuan_zhen_task_event = GlobalEvent:getInstance():Bind(ActionEvent.YUAN_ZHEN_TASK_EVENT,function (data)
            if not data then return end
            if not self.action_id then return end
            --后端要求我模拟完成条件
            local key = getNorKey(self.action_id, data.id)
            local config = Config.HolidayLantermAdventureData.data_lanterm_adventure_fun(key)
            if config and self.dic_limit_list[config.f_id] then
                self.dic_limit_list[config.f_id].status = TaskConst.task_status.completed
                self.dic_limit_list[config.f_id].sort = TaskConst.task_status.completed

                local config_list = Config.HolidayLantermAdventureData.data_lanterm_adventure_task_lis[self.action_id][config.f_id]
                --如果有下一个任务档次
                if config_list[config.s_id + 1] then
                    local key = getNorKey(self.action_id, config_list[config.s_id + 1].id)
                    local new_config = Config.HolidayLantermAdventureData.data_lanterm_adventure_fun(key)
                    if new_config and self.dic_task_list[new_config.id] then
                        self:initYuanZhenData({self.dic_task_list[new_config.id]})
                    else   
                        self:sortYuanZhenInfo()
                    end
                else
                    self:sortYuanZhenInfo()
                end
            end
        end)
    end
end

function ActionLimitYuanZhenPanel:onCommonBtn()
    if self.holiday_bid == ActionRankCommonType.yuanzhen_adventure then
        --元宵冒险
        MallController:getInstance():openMallActionWindow(true, self.holiday_bid)
    end
end

function ActionLimitYuanZhenPanel:initUI( )
    if self.action_id == ActionLimitYuanZhenPanel.action_yuanzhen_id then
       local icon = self.common_btn:getChildByName("icon")
        if icon then
            local res = PathTool.getTargetRes("welfare/action_icon","welfare_icon_99",false,false)
            self.item_load1 = loadSpriteTextureFromCDN(icon, res, ResourcesType.single, self.item_load1)
        end
        self.common_btn:getChildByName("label"):setString(TI18N("花灯集市"))

        title_desc = createRichLabel(18, cc.c4b(0xf7,0xe6,0xb0,0xff), cc.p(0,0.5), cc.p(50,76), nil, nil, 400)
        title_con:addChild(title_desc)
        title_desc:setString(TI18N("活动期间完成任务获取元宵花灯等限时奖励"))
    elseif self.action_id == ActionLimitYuanZhenPanel.action_summer_id then
        self.common_btn:setVisible(false)
    end
end


--元宵冒险数据
--@is_reset 是否重置
function ActionLimitYuanZhenPanel:initYuanZhenData(quest_list)
    if not self.action_id then return end
    if not quest_list then return end
    for i,v in ipairs(quest_list) do
        self.dic_task_list[v.id] = v
        local key = getNorKey(self.action_id, v.id)
        local config = Config.HolidayLantermAdventureData.data_lanterm_adventure_fun(key)
        if config and v.finish ~= TaskConst.task_status.over then
            local task = self.dic_limit_list[config.f_id] --父类id
            if task == nil then
                task = {}
                self.dic_limit_list[config.f_id] = task
                table_insert(self.limit_list, task)
            end
            local is_chang = true
            if task.config then
                if config.s_id > task.config.s_id then
                    --当前 序号比记录大 那么如果记录 未领取奖励 不能替换 
                    if task.status ~= TaskConst.task_status.completed then
                        is_chang = false
                    end
                elseif config.s_id < task.config.s_id then
                    --当前 序号比记录小  如果 当前已领取奖励 不能替换
                    if v.finish == TaskConst.task_status.completed  then
                        is_chang = false
                    end 
                end
            end
            if is_chang then
                -- task.id = config.id
                task.config = config
                task.f_id = config.f_id
                if v.finish == TaskConst.task_status.finish then
                    task.sort = 0
                elseif v.finish == TaskConst.task_status.un_finish then
                    task.sort = 1
                else
                    task.sort = v.finish
                end
                
                task.status = v.finish --总状态 (0:未完成 1:已完成 2:已奖励, 3:已过期)"}
                task.title = config.title
                task.desc = config.desc
                --目标值当前值(x/n)
                local target_val 
                local value
                if v.progress[1] then
                    target_val = v.progress[1].target_val
                    value = v.progress[1].value
                end
                task.goal = string_format("(%s/%s)",value, target_val)
                task.end_time = v.end_time 
                task.item_list = config.award
            end
        end 
    end

    self:sortYuanZhenInfo()
end

--元宵冒险排序
function ActionLimitYuanZhenPanel:sortYuanZhenInfo()
    local sort_func = SortTools.tableLowerSorter({"sort","f_id"})
    table.sort(self.limit_list, sort_func)
    self.item_scrollview:reloadData()
end

function ActionLimitYuanZhenPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function ActionLimitYuanZhenPanel:DeleteMe(  )
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.item_load1 then 
        self.item_load1:DeleteMe()
        self.item_load1 = nil
    end

    if self.limin_common_event then
        GlobalEvent:getInstance():UnBind(self.limin_common_event)
        self.limin_common_event = nil
    end

    if self.limin_yuan_zhen_event then
        GlobalEvent:getInstance():UnBind(self.limin_yuan_zhen_event)
        self.limin_yuan_zhen_event = nil
    end

    if self.limin_yuan_zhen_update_event then
        GlobalEvent:getInstance():UnBind(self.limin_yuan_zhen_update_event)
        self.limin_yuan_zhen_update_event = nil
    end

    if self.limin_yuan_zhen_task_event then
        GlobalEvent:getInstance():UnBind(self.limin_yuan_zhen_task_event)
        self.limin_yuan_zhen_task_event = nil
    end

    doStopAllActions(self.time_val)
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
end

------------------------------------------
-- 子项
ActionLimitCommonItem2 = class("ActionLimitCommonItem2", function()
    return ccui.Widget:create()
end)

function ActionLimitCommonItem2:ctor(action_id)
    self.action_id = action_id
    self:configUI()
    self:register_event()
end

function ActionLimitCommonItem2:configUI(  )
    self.size = cc.size(680,136)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("action/action_limit_yuanzhen_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("Text_6"):setString(TI18N("前往"))
    self.btn_goto:setVisible(false)
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get:getChildByName("Text_5"):setString(TI18N("领取"))
    self.btn_get:setVisible(false)
    self.btn_has = main_container:getChildByName("btn_has")
    self.btn_has:setVisible(false)

    self.goods_con = main_container:getChildByName("good_cons")

    if self.action_id == ActionLimitYuanZhenPanel.action_yuanzhen_id then
        self.title_desc = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,0.5), cc.p(14,129), nil, nil, 400)
        main_container:addChild(self.title_desc)

        self.goal_desc = createRichLabel(22, cc.c4b(0x93,0x53,0x22,0xff), cc.p(0.5,0.5), cc.p(596,127), nil, nil, 400)
        main_container:addChild(self.goal_desc)

        self.time_desc = createRichLabel(18, cc.c4b(0x93,0x53,0x22,0xff), cc.p(0.5,0.5), cc.p(594,24), nil, nil, 400)
        main_container:addChild(self.time_desc)

        local size = self.goods_con:getContentSize()
        self.item_scrollview = createScrollView(size.width, size.height, 0, 0, self.goods_con, ScrollViewDir.vertical )
    else--if self.action_id == ActionLimitYuanZhenPanel.action_summer_id then
        self.btn_goto:setPositionY(56)
        self.btn_get:setPositionY(56)
        self.btn_has:setPositionY(56)

        --标题
        self.title_desc = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0,0.5), cc.p(148,100), nil, nil, 400)
        main_container:addChild(self.title_desc)
        --小标题
        self.little_desc = createRichLabel(20, Config.ColorData.data_new_color4[10], cc.p(0,1), cc.p(148,72), nil, nil, 320)
        main_container:addChild(self.little_desc)

        self.time_desc = createRichLabel(18, Config.ColorData.data_new_color4[13], cc.p(0.5,0.5), cc.p(594,100), nil, nil, 400)
        main_container:addChild(self.time_desc)

        self.item = BackPackItem.new(false, true, false, 0.9, false, true)  
        self.item:setPosition(80, 66)
        main_container:addChild(self.item)
    end
end

function ActionLimitCommonItem2:register_event( )
    registerButtonEventListener(self.btn_get, function()
        if not self.data then return end
        if self.holiday_bid == ActionRankCommonType.yuanzhen_adventure then
            controller:sender24812(self.data.config.id)
        elseif self.holiday_bid == ActionRankCommonType.exercise_1 then
            controller:sender24814(self.data.config.id)
        elseif self.holiday_bid == ActionRankCommonType.exercise_2 then
            controller:sender24816(self.data.config.id)
        elseif self.holiday_bid == ActionRankCommonType.exercise_3 or self.holiday_bid == ActionRankCommonType.merge_task then
            controller:sender24818(self.data.config.id)
        else
            -- self.ctrl:cs16604(self.holiday_item_bid,self.data.aim)
        end
    end,true, 1)

    registerButtonEventListener(self.btn_goto, function() self:onGotoBtn() end,true, 1)
end

function ActionLimitCommonItem2:onGotoBtn()
    if not self.data then return end
    if not self.data.config then return end
    -- 特殊跳转 特殊处理
    if self.data.config.source_id == 130051 then
        --跳转到元宵厨房的
        local tab_vo = controller:getActionSubTabVo(AnimateActionCommonType.YuanZhen_Kitchen)
        if tab_vo and controller.action_operate and controller.action_operate.tab_list[tab_vo.bid] then
            controller.action_operate:handleSelectedTab(controller.action_operate.tab_list[tab_vo.bid])
        else
            message(TI18N("该活动已结束"))
        end
    elseif self.data.config.source_id == 250131 then
        --跳转到沙滩保卫战.
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.SandybeachBossFight)
    elseif self.data.config.source_id == 4401601 then
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.TermBegins)
    elseif self.data.config.source_id == 250132 then
        self:gotoActionByID(ActionRankCommonType.time_summon)
    elseif self.data.config.source_id == 250133 then
        self:gotoActionByID(ActionRankCommonType.action_skin_buy)
    elseif self.data.config.source_id == 250134 then
        self:gotoActionByID(ActionRankCommonType.limit_exercise)
    elseif self.data.config.source_id == 250135 then
        self:gotoActionByID(ActionRankCommonType.lottery_skin)
    elseif self.data.config.source_id == 460161 then --花火活动跳转
        if PetardActionController:getInstance():getModel():checkPetardIsOpen() then
            self:gotoActionByID(ActionRankCommonType.petard)
        else
            message(TI18N("活动未开启"))
        end
    elseif self.data.config.source_id == 460162 then --花火大会红包界面跳转
        if PetardActionController:getInstance():getModel():checkPetardIsOpen() then
            PetardActionController:getInstance():openRedbagWindow(true)
        else
            message(TI18N("活动未开启"))
        end
    elseif self.data.config.source_id == 460171 then
        self:gotoActionByID(ActionRankCommonType.elite_summon)
    elseif self.data.config.source_id == 460181 then --甜蜜大作战跳转
        self:gotoActionByID(ActionRankCommonType.sweet)
    elseif self.data.config.source_id == 480341 then --精灵召唤
        self:gotoActionByID(ActionRankCommonType.time_elfin_summon)
    elseif self.data.config.source_id == 930321 then --年兽跳转
        JumpController:getInstance():jumpViewByEvtData({70})
    else
        local config = Config.SourceData.data_source_data[self.data.config.source_id]
        if config then
            BackpackController:getInstance():gotoItemSources(config.evt_type, config.extend)
        else
            StrongerController:getInstance():clickCallBack(self.data.config.source_id)
        end
    end
end

function ActionLimitCommonItem2:gotoActionByID(jump_id)
    local tab_vo = controller:getActionSubTabVo(jump_id)
    if tab_vo and controller.action_operate and controller.action_operate.tab_list[tab_vo.bid] then
        controller.action_operate:handleSelectedTab(controller.action_operate.tab_list[tab_vo.bid])
    else
        message(TI18N("该活动已结束"))
    end
end
function ActionLimitCommonItem2:setActionRankCommonType(holiday_bid, type)
    self.holiday_bid = holiday_bid
    self.type = type
end

function ActionLimitCommonItem2:setData( data )
    self.data = data
    self.btn_goto:setVisible(data.status == TaskConst.task_status.un_finish)
    self.btn_get:setVisible(data.status == TaskConst.task_status.finish)
    self.btn_has:setVisible(data.status == TaskConst.task_status.completed)
    if self.time_desc then
        self.time_desc:setVisible(data.status ~= TaskConst.task_status.completed)
    end
    if self.action_id == ActionLimitYuanZhenPanel.action_yuanzhen_id then
        self.title_desc:setString(data.desc)
        if data.status == TaskConst.task_status.finish then
            self.goal_desc:setString(string_format("<div fontColor=#249003>%s</div>", data.goal))
        else
            self.goal_desc:setString(data.goal)
        end

        local data_list = data.item_list
        local setting = {}
        setting.scale = 0.8
        setting.max_count = 4
        -- setting.is_center = true
        self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)

       
    else--if self.action_id == ActionLimitYuanZhenPanel.action_summer_id or self.action_id == ActionLimitYuanZhenPanel.action_wolf_id then
        self.title_desc:setString(TI18N(data.title))
        local desc = TI18N(data.desc)..data.goal
        if data.status == TaskConst.task_status.finish then
            self.little_desc:setString(string_format("<div fontColor=#249003>%s</div>", desc))
        else
            self.little_desc:setString(desc)
        end
        if self.item and data.item_list ~= nil and next(data.item_list) ~= nil then
            self.item:setBaseData(data.item_list[1][1], data.item_list[1][2], true)         
        end
    end
    return self.time_desc
end

function ActionLimitCommonItem2:DeleteMe( )
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            v:DeleteMe()
        end
    end
    self.item_list = nil

    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
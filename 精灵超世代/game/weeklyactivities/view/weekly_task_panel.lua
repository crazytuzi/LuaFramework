----------------------------
-- @Author: pjl
-- @Date:   2022-01-20
-- @Description:   周活动任务
----------------------------
WeeklyTaskPanel =
    class(
    "WeeklyTaskPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = WeeklyActivitiesController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local task_config =
{
    [1] = Config.WeekExploreData.data_task_list,      -- 地宫
    [2] = Config.WaterBreedData.data_task_list,       -- 灵泉
    [3] = Config.WeekStoneRoomData.data_task_list,    -- 石室
}

--获取活动说明
function WeeklyTaskPanel:getActiviceDes(  )
    local config_rule = {
        Config.WeekActData.data_const["task_underground_tips"],
        Config.WeekActData.data_const["task_waterbreed_tips"],
        Config.WeekActData.data_const["task_bomb_bridge_tips"],
    }
    local activity_id = model:getWeeklyActivityId()
    return config_rule[activity_id].desc
end

function WeeklyTaskPanel:ctor(bid)
    self.info_list = {}
    self:loadResources()
end

function WeeklyTaskPanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_117"), type = ResourcesType.single},
    }
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(
        self.res_list,
        function()
            if self.configUI then
                self:configUI()
            end
            if self.register_event then
                self:register_event()
            end
        end
    )
end

function WeeklyTaskPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/weekly_task_panel"))
    self:addChild(self.root_wnd)
    -- self:setCascadeOpacityEnabled(true)
    -- self:setPosition(-40, -80)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    local bg = self.main_container:getChildByName("bg")
    local res_id = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_117")
    if not self.bg_load then
        self.bg_load = createResourcesLoad(res_id, ResourcesType.single, function()
            if not tolua.isnull(bg) then
                loadSpriteTexture(bg,res_id,LOADTEXT_TYPE)
            end
        end, self.bg_load)
    end

    self.time_text_0 = self.main_container:getChildByName("time_text_0")
    self.time_text_0:setString(TI18N("剩余时间"))
    self.time_text   = self.main_container:getChildByName("time_text")
    self.btn_rule = self.main_container:getChildByName("btn_rule")
    self.tab_container = self.main_container:getChildByName("tab_container")
    self.item_list = self.main_container:getChildByName("item_list")
    self.item = self.main_container:getChildByName("item")
    self.item:setVisible(false)

    self.task_type = model:getWeeklyActivityId()
    self.data_task_list = task_config[self.task_type]

    self:setLessTime(model:getWeeklyActivityData())
    local index = 1
    local task_data = model:getWeeklyTaskData()
    for k, v in ipairs(task_data.info_list or {}) do
        -- 找到可领
        if v.state == 1 then
            for j, w in ipairs(self.data_task_list or {}) do
                if w.id == v.id then
                    index = j
                    break
                end
            end
            break
        end
    end
    self:updateTabBtnList(index)
end

function WeeklyTaskPanel:setLessTime(data)
    local time = (data.end_time or 0 ) -GameNet:getInstance():getTime()
    if time < 0 then return end
    self.time_text:setString(TimeTool.GetTimeFormatDayIIIIII(time))

    if self.time_ticket == nil then
        local _callback = function() 
            local time = data.end_time-GameNet:getInstance():getTime()
            if  time >= 0 then
                self.time_text:setString(TimeTool.GetTimeFormatDayIIIIII(time))
            else
                if self.time_ticket then
                    GlobalTimeTicket:getInstance():remove(self.time_ticket)
                    self.time_ticket = nil
                end
            end
        end
        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback)
    end
end

function WeeklyTaskPanel:register_event()
    --获取下发任务信息数据
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.UPDATE_WEEK_TASK_DATA,function(data)
            if data then
                if self.tab_btn_list_view then
                    local task_data = model:getWeeklyTaskData()
                    local cell = self.tab_btn_list_view:getCellByIndex(task_data.round)
                    setChildUnEnabled(false, cell)
                    self.tab_btn_list_view:reloadData(nil, nil, true)
                end
                self:updateTabBtnList(self.select_type)
                self.scroll_view:reloadData()
            end
        end)
    end

    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        local des = self:getActiviceDes()
        TipsManager:getInstance():showCommonTips(des, sender:getTouchBeganPosition(),nil,nil,500)
    end ,false)

    self.update_week_data = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.UPDATE_WEEK_DATA, function(data)
    if data then
            self:setLessTime(data)
        end
    end)
end

function WeeklyTaskPanel:openRootWnd(type)
    -- self.select_type = type
    -- self:setSelecteTab(type, true)
    -- self:updateTabBtnList(self.select_type)
end

--页签滚动列表
function WeeklyTaskPanel:updateTabBtnList(index)
    if not self.data_task_list then return end

    if not self.tab_btn_list_view then
        local size = self.tab_container:getContentSize()
        local count = self:numberOfCellsTabBtn()
        -- local item_width = 153
        local item_width = 144
        local item_height = 64
        local position_data_list 
        -- if count <= 4  then
        --     position_data_list = {}
        --     local s_x = 5 --(size.width - count * item_width) * 0.5
        --     local y = item_height * 0.5
        --     for i=1,count do
        --         local x = s_x + item_width * 0.5 + (i -1) * item_width
        --         position_data_list[i] = cc.p(x, y)
        --     end
        -- end
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 10,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = item_width,               -- 单元的尺寸width
            item_height = item_height,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            -- col = 5,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true,
            position_data_list = position_data_list
        }


        self.tab_btn_list_view = CommonScrollViewSingleLayout.new(self.tab_container, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.horizontal, ScrollViewStartPos.top, size, setting, cc.p(0.5,0.5))

        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.createNewCellTabBtn), ScrollViewFuncType.CreateNewCell) --创建cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCellsTabBtn), ScrollViewFuncType.NumberOfCells) --获取数量
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndexTabBtn), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouchedTabBtn), ScrollViewFuncType.OnCellTouched) --更新cell

        -- if count <= 4  then
        --     self.tab_btn_list_view:setClickEnabled(false)
        -- end
    end
    local index = index or 1
    self.tab_btn_list_view:reloadData(index)
    self:changeTabIndex(index)
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function WeeklyTaskPanel:createNewCellTabBtn(width, height)
    local cell = ccui.Widget:create()
    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("common/common_tab_btn"))
    cell:addChild(cell.root_wnd)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(cc.p(0.5, 0.5))
    cell:setContentSize(cc.size(width, height))
    cell.container = cell.root_wnd:getChildByName("container")
    cell.normal_img = cell.container:getChildByName("unselect_bg")
    cell.select_img = cell.container:getChildByName("select_bg")
    cell.normal_img:setContentSize(cc.size(width, height))
    cell.select_img:setContentSize(cc.size(width, height))
    cell.select_img:setVisible(false)
    -- cell.setOntouch
    cell.container:setSwallowTouches(false)
    cell.label = cell.container:getChildByName("title")
    cell.label:setTextColor(Config.ColorData.data_new_color4[6])

    --红点. 暂时没有红点 先隐藏
    cell.red_point = cell.container:getChildByName("tab_tips")
    cell.red_num = cell.container:getChildByName("red_num")
    cell.red_point:setVisible(false)
    cell.red_num:setVisible(false)

    registerButtonEventListener(cell.container, function() self:onCellTouchedTabBtn(cell) end, false, 2, nil, nil, nil, true)
    -- --回收用
    -- cell.DeleteMe = function() 
    -- end
    return cell
end

--获取数据数量
function WeeklyTaskPanel:numberOfCellsTabBtn()
    if not self.data_task_list then return 0 end
    return #self.data_task_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function WeeklyTaskPanel:updateCellByIndexTabBtn(cell, index)
    cell.index = index
    local tab_data = self.data_task_list[index]
    if tab_data then
        local task_data = model:getWeeklyTaskData()
        cell.label:setString(string_format(TI18N("第%s轮"), index))
        setLabelAutoScale(cell.label, cell, 20)
        local tab_btn =  self.tab_btn_list_view:getCellByIndex(index)
        if task_data.round < index then
            setChildUnEnabled(true, tab_btn)
            tab_btn.label:setTextColor(Config.ColorData.data_new_color4[6])
            tab_btn.label:disableEffect(cc.LabelEffect.SHADOW)
            return
        end
        if self.select_type == index then
            cell.select_img:setVisible(true)
            cell.label:setTextColor(Config.ColorData.data_new_color4[1])
            cell.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        else
            cell.select_img:setVisible(false)
            cell.label:setTextColor(Config.ColorData.data_new_color4[6])
            cell.label:disableEffect(cc.LabelEffect.SHADOW)
        end

        -- self:changeTabIndex(index)

        --先不处理.都是1级开启的 省点
        -- if tab_data.can_touch then
        --     cell.label:enableOutline(cc.c4b(0x2a, 0x16, 0x0e, 0xff), 2)
        --     setChildUnEnabled(false, cell.tab_btn)
        -- else 
        --     cell.label:disableEffect(cc.LabelEffect.OUTLINE)
        --     setChildUnEnabled(true, cell.tab_btn)
        -- end
    end
end

--index :数据的索引
function WeeklyTaskPanel:onCellTouchedTabBtn(cell)
    local index = cell.index
    local tab_data = self.data_task_list[index]
    if tab_data then
        --点击需要判断
        -- if tab_data.can_touch then
            self:changeTabIndex(index)
        -- else
        --     message(TI18N(tab_data.notice))
        -- end
    end
end

function WeeklyTaskPanel:changeTabIndex(index)
    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[6])
            self.cur_tab.label:disableEffect(cc.LabelEffect.SHADOW)
        end
        self.cur_tab.select_img:setVisible(false)
    end

    self.select_type = index
    self.cur_tab =  self.tab_btn_list_view:getCellByIndex(self.select_type)

    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[1])
            self.cur_tab.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        end
        self.cur_tab.select_img:setVisible(true)
    end

    self:updateItemList(index)
end

function WeeklyTaskPanel:updateItemList(index)
    self.info_list = {}
    local task_data = model:getWeeklyTaskData()
    local config = self.data_task_list[index]
    for i = 1, #config do
        for k, v in ipairs(task_data.info_list or {}) do
            if config[i].task_id == v.id then
                table_insert(self.info_list, {id = v.id, state = v.state})
                break
            end
        end
    end

    table_sort(self.info_list,function(a,b)
        if a.id / 100 >= 1 and b.id /100 < 1 then
            return false
        elseif a.state ~= 2 and b.state == 2 then
            return true
        elseif a.state == 2 and b.state ~= 2 then
            return false
        else
            return a.id < b.id
        end
    end)

    if self.scroll_view == nil then
        local size = self.item_list:getContentSize()
        local setting = {
        start_x = 5,
        space_x = 0,
        start_y = 0,
        space_y = 5,
        item_width = 647,
        item_height = 114,
        row = 0,
        col = 1,
        need_dynamic = true
        }
        self.scroll_view = CommonScrollViewSingleLayout.new(self.item_list, nil , nil, nil, size, setting, cc.p(0, 0))

        self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewItemCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfItemCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateItemCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.scroll_view:setVisible(true)
    self.scroll_view:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function WeeklyTaskPanel:createNewItemCell()
    local cell = WeeklyTaskItem.new()
    if cell.setExtendData and self.item then
        cell:setExtendData(self.item)
    end
    
    return cell
end

--获取数据数量
function WeeklyTaskPanel:numberOfItemCells()
    if not self.data_task_list or not self.data_task_list[self.select_type] then return 0 end
    return #self.data_task_list[self.select_type]
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function WeeklyTaskPanel:updateItemCellByIndex(cell, index)
    cell.index = index
    local data = self.info_list[index]
    if not data then return end
    cell:setData(data, self.data_task_list, self.select_type)
end

function WeeklyTaskPanel:DeleteMe()
    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end

    if self.bg_load then 
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end

    if self.tab_btn_list_view then
        self.tab_btn_list_view:DeleteMe()
    end

    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end

    if self.update_week_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_week_data)
        self.update_week_data = nil
    end

    if self.update_action_even_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end    

    if self.time_ticket then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end

-- --------------------------------------------------------------------
-- @author: pjl(必填, 创建模块的人员)
-- @description:
--      周活动任务单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
WeeklyTaskItem = class("WeeklyTaskItem", function()
    return ccui.Layout:create()
end)

function WeeklyTaskItem:ctor()
    self.is_completed = false
end

--==============================--
--desc:设置扩展参数  {node = self.item, count = self.interaction_count} 
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function WeeklyTaskItem:setExtendData(node)
    if not tolua.isnull(node) and self.root_wnd == nil then
        self.is_completed = true
        local size = node:getContentSize()
        self:setAnchorPoint(cc.p(0.5, 0.5))
        self:setContentSize(size)
        
        self.root_wnd = node:clone()
        self.root_wnd:setVisible(true)
        self.root_wnd:setAnchorPoint(0.5, 0.5)
        self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
        self:addChild(self.root_wnd)
        
        self.name = self.root_wnd:getChildByName("name")
        self.item_container = self.root_wnd:getChildByName("item_container")

        self.unlocked_layout = self.root_wnd:getChildByName("unlocked_layout")
        self.value = self.unlocked_layout:getChildByName("value")
        self.progress = self.unlocked_layout:getChildByName("progress")
        self.get_btn = self.unlocked_layout:getChildByName("get_btn")
        local btn_size = self.get_btn:getContentSize()
        self.get_btn_label = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
        self.get_btn:addChild(self.get_btn_label)

        self.locked_layout = self.root_wnd:getChildByName("locked_layout")
        self.text = self.locked_layout:getChildByName("text")
        self.text:setString(TI18N("完成上一轮解锁"))

        self.unlocked_layout:setVisible(false)

        local goods_list = self.root_wnd:getChildByName("item_container")
        local bgSize = goods_list:getContentSize()
        local scroll_view_size = cc.size(bgSize.width, bgSize.height)
        local scale = 0.7
        local setting = {
            item_class = BackPackItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 5,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = BackPackItem.Width*scale,               -- 单元的尺寸width
            item_height = BackPackItem.Height*scale,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 0,                         -- 列数，作用于垂直滚动类型
            scale = scale
        }
        self.good_scrollview = CommonScrollViewLayout.new(goods_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
        self.good_scrollview:setSwallowTouches(false)
        
        self:registerEvent()
    end
end

function WeeklyTaskItem:registerEvent()
    registerButtonEventListener(self.get_btn, handler(self, self._onClickGetBtn), true)
end

function WeeklyTaskItem:_onClickGetBtn( param, sender, event_type )
    local status = self:getBtnStatus()
    -- 0是未完成，1是可以领，2是已经领取
    if status == 0 then
        controller:openMainWindow(true, 1)
    elseif status == 1 then
        controller:send_29202(self.select_type, self.task_id)
    end
end

function WeeklyTaskItem:setData(data, data_task_list, select_type)
    if data then
        self.data = data
        self.select_type = select_type
        self.task_id = data.id

        local select_config = data_task_list[select_type]
        local item_config = nil
        for k, v in ipairs(select_config or {}) do
            if data.id == v.task_id then
                item_config = v
                break
            end
        end
        self.name:setString(item_config.title_name)
        self.task_id = item_config.task_id

        local task_data = model:getWeeklyTaskData()

        -- 奖励
        local award_data = {}
        for i,v in ipairs(item_config.reward) do
            local bid = v[1]
            local num = v[2]
            local vo = deepCopy(Config.ItemData.data_get_data(bid))
            vo.quantity = num
            table_insert(award_data, vo)
        end
        self.good_scrollview:setData(award_data)
        self.good_scrollview:addEndCallBack(function ()
            local list = self.good_scrollview:getItemList()
            for k,v in pairs(list) do
                v:setDefaultTip()
            end
        end)

        if select_type > task_data.round then
            self.locked_layout:setVisible(true)
            self.unlocked_layout:setVisible(false)
        elseif select_type <= task_data.round then
            self.locked_layout:setVisible(false)
            self.unlocked_layout:setVisible(true)

            local value1, value2 = 0, 0
            if data.id == select_config[1].task_id then
                for i = 2, #select_config do
                    if task_data.process < select_config[i].exp then
                        break
                    end
                    value1 = value1 + 1
                end
                value2 = #select_config - 1
            else
                value1 = task_data.process
                value2 = item_config.exp
            end
            if value1 > value2 then
                value1 = value2
            end
            self.value:setString(string_format("%s/%s", value1, value2))

            local percent = (value1/value2)*100
            self.progress:setPercent(percent)

            setChildUnEnabled(false, self.get_btn)
            self.get_btn:setTouchEnabled(true)

            local status = data.state -- self:getBtnStatus()
            -- 0是未完成，1是可以领，2是已经领取
            if status == 0 then
                self.get_btn_label:setString(string_format("<div fontcolor=#ffffff shadow=0,-2,2,#0E73B3>%s</div>", TI18N("前往")))
                self.get_btn:loadTexture(PathTool.getResFrame("common", "common_1017"), LOADTEXT_TYPE_PLIST)
            elseif status == 1 then
                self.get_btn_label:setString(string_format("<div fontcolor=#ffffff shadow=0,-2,2,#854000>%s</div>", TI18N("领取")))
                self.get_btn:loadTexture(PathTool.getResFrame("common", "common_1018"), LOADTEXT_TYPE_PLIST)
            else
                self.get_btn_label:setString(string_format("<div fontcolor=#ffffff>%s</div>", TI18N("已领取")))
                self.get_btn:loadTexture(PathTool.getResFrame("common", "common_1018"), LOADTEXT_TYPE_PLIST)

                setChildUnEnabled(true, self.get_btn)
                self.get_btn:setTouchEnabled(false)
            end
        end
    end
end

function WeeklyTaskItem:getBtnStatus()
    if self.task_id == nil then return end
    local task_data = model:getWeeklyTaskData()
    for k, v in ipairs(task_data.info_list or {}) do
        if self.task_id == v.id then
            return v.state
        end
    end

    return 0
end

function WeeklyTaskItem:DeleteMe()
    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end

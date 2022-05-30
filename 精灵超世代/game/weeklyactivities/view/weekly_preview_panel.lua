----------------------------
-- @Author: pjl
-- @Date:   2022-02-10
-- @Description:   周活动预告
----------------------------
WeeklyPreviewPanel =
    class(
    "WeeklyPreviewPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = WeeklyActivitiesController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort

function WeeklyPreviewPanel:ctor(bid)
    self:loadResources()
end

function WeeklyPreviewPanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("weeklyactivity/weeklypreview", "weeklypreview_1"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("weeklyactivity/weeklypreview", "weeklypreview_2"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("weeklyactivity/weeklypreview", "weeklypreview_3"), type = ResourcesType.single},
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

function WeeklyPreviewPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/weekly_preview_panel"))
    self:addChild(self.root_wnd)
    -- self:setCascadeOpacityEnabled(true)
    -- self:setPosition(-40, -80)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    -- local bg = self.main_container:getChildByName("bg")
    -- local res_id = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_117")
    -- if not self.bg_load then
    --     self.bg_load = createResourcesLoad(res_id, ResourcesType.single, function()
    --         if not tolua.isnull(bg) then
    --             loadSpriteTexture(bg,res_id,LOADTEXT_TYPE)
    --         end
    --     end, self.bg_load)
    -- end

    self.item_list = self.main_container:getChildByName("item_list")
    self.item = self.main_container:getChildByName("item")
    self.item:setVisible(false)

    local size = self.item_list:getContentSize()
    local setting = {
        start_x = 10,
        space_x = 0,
        start_y = 9,
        space_y = 10,
        item_width = 676,
        item_height = 184,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewSingleLayout.new(self.item_list, nil , nil, nil, size, setting, cc.p(0, 0))

    self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewItemCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfItemCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateItemCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self.scroll_view:setVisible(true)
    self.scroll_view:reloadData()
end

function WeeklyPreviewPanel:register_event()
    -- self.update_week_data = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.UPDATE_WEEK_DATA, function(data)
    -- if data then
    --         self:setLessTime(data)
    --     end
    -- end)
end

function WeeklyPreviewPanel:openRootWnd(type)
    -- self.select_type = type
    -- self:setSelecteTab(type, true)
    -- self:updateTabBtnList(self.select_type)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function WeeklyPreviewPanel:createNewItemCell()
    local cell = WeeklyPreviewItem.new()
    if cell.setExtendData and self.item then
        cell:setExtendData(self.item)
    end
    
    return cell
end

--获取数据数量
function WeeklyPreviewPanel:numberOfItemCells()
    if not Config.WeekActData.data_weekly_act_preview then return 0 end
    return #Config.WeekActData.data_weekly_act_preview
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function WeeklyPreviewPanel:updateItemCellByIndex(cell, index)
    cell.index = index
    local data = model:getWeeklyTaskData()
    if not data then return end
    cell:setData(data)
end

function WeeklyPreviewPanel:DeleteMe()
    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end

    -- if self.bg_load then 
    --     self.bg_load:DeleteMe()
    --     self.bg_load = nil
    -- end

    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
end

-- --------------------------------------------------------------------
-- @author: pjl(必填, 创建模块的人员)
-- @description:
--      周活动任务单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
WeeklyPreviewItem = class("WeeklyPreviewItem", function()
    return ccui.Layout:create()
end)

function WeeklyPreviewItem:ctor()
    self.is_completed = false
end

--==============================--
--desc:设置扩展参数  {node = self.item, count = self.interaction_count} 
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function WeeklyPreviewItem:setExtendData(node)
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

        self.bg = self.root_wnd:getChildByName("bg")

        self.time_text_0 = self.root_wnd:getChildByName("time_text_0")
        self.time_text_0:setString(TI18N("倒计时："))
        self.time_text   = self.root_wnd:getChildByName("time_text")
        self.name = self.root_wnd:getChildByName("name")
        self.name:setString(TI18N("活动道具"))
        self.item_container = self.root_wnd:getChildByName("item_container")

        self.go_btn = self.root_wnd:getChildByName("go_btn")
        local btn_size = self.go_btn:getContentSize()
        self.go_btn_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
        self.go_btn_label:setString(string_format("<div fontcolor=#ffffff shadow=0,-2,2,#0E73B3>%s</div>", TI18N("前往")))
        self.go_btn:addChild(self.go_btn_label)

        self.go_btn:setVisible(false)

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

function WeeklyPreviewItem:registerEvent()
    registerButtonEventListener(self.go_btn, handler(self, self._onClickGoBtn), true)
end

function WeeklyPreviewItem:_onClickGoBtn( param, sender, event_type )
    controller:openMainWindow(true, 1)
end

function WeeklyPreviewItem:setLessTime(data, activity_id)
    local time = (data.end_time or 0 ) -GameNet:getInstance():getTime()
    if time < 0 then return end
    time = time + self.add_time
    self.time_text:setString(string_format(self.time_text_str, TimeTool.GetTimeFormatDayIIIIII(time)))

    if self.time_ticket == nil then
        local _callback = function()
            local time = data.end_time-GameNet:getInstance():getTime()
            if  time >= 0 then
                time = time + self.add_time
                self.time_text:setString(string_format(self.time_text_str, TimeTool.GetTimeFormatDayIIIIII(time)))
                -- self.time_text:setString(TimeTool.GetTimeFormatDayIIIIII(time))
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

function WeeklyPreviewItem:setData(data)
    if data then
        self.data = data

        local activity_id = model:getWeeklyActivityId()

        local res_id = PathTool.getPlistImgForDownLoad("weeklyactivity/weeklypreview", "weeklypreview_"..self.index)
        if not self.bg_load then
            self.bg_load = loadImageTextureFromCDN(self.bg, res_id, ResourcesType.single, self.bg_load)
        end

        self.time_text_str = ""
        self.add_time = 0
        local duration = 7 * 24 * 3600      -- 活动持续时间
        if self.index == activity_id then
            self.time_text_str = TI18N("%s后结束")
        else
            self.time_text_str = TI18N("%s后开始")

            local act_count = #Config.WeekActData.data_weekly_act_preview
            local num = math.fmod( (self.index+act_count-activity_id), act_count ) - 1
            self.add_time = num * duration
        end

        self:setLessTime(model:getWeeklyActivityData(), activity_id)

        local config = Config.WeekActData.data_weekly_act_preview[self.index]
        -- 奖励
        local award_data = {}
        local bid = config.cost_item
        local num = 1
        local vo = deepCopy(Config.ItemData.data_get_data(bid))
        vo.quantity = num
        table_insert(award_data, vo)
        if self.index == activity_id then
            local bid = config.reward_item
            local num = 1
            local vo = deepCopy(Config.ItemData.data_get_data(bid))
            vo.quantity = num
            table_insert(award_data, vo)

            self.go_btn:setVisible(true)
        else
            self.go_btn:setVisible(false)
        end

        self.good_scrollview:setData(award_data)
        self.good_scrollview:addEndCallBack(function ()
            local list = self.good_scrollview:getItemList()
            for k,v in pairs(list) do
                v:setDefaultTip()
            end
        end)
    end
end

function WeeklyPreviewItem:DeleteMe()
    if self.time_ticket then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end

    if self.bg_load then 
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end

    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end

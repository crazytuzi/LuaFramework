-- --------------------------------------------------------------------
--
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: yuanqi@shiyue.com(必填, 后续维护以及修改的人员)
-- @description:
--      奖励一览的总界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EndlessRewardWindow = EndlessRewardWindow or BaseClass(BaseView)

local controller = Endless_trailController:getInstance()
local model = Endless_trailController:getInstance():getModel()
-- local const_data = Config.EndlessData.data_const
local max_count = 10
local table_sort = table.sort

function EndlessRewardWindow:__init(type)
    self.type = type or Endless_trailEvent.endless_type.old
    self.touch_type = Endless_trailEvent.endless_type.old
    self.is_full_screen = false
    self.layout_name = "endlesstrail/endlesstrail_reward_window"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.partner_list = {}
end

function EndlessRewardWindow:open_callback(...)
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.win_title = self.main_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("奖励一览"))
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.scroll_list = self.main_panel:getChildByName("scroll_list")
    self.desc = self.main_panel:getChildByName("desc")
    self.desc:setString(TI18N("累计通关越多，获得奖励越多"))

    local scroll_view_size = self.scroll_list:getContentSize()
    local setting = {
        item_class = EndlessRewardItem, -- 单元类
        start_x = 10, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 5, -- y方向的间隔
        item_width = 586, -- 单元的尺寸width
        item_height = 170, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 1, -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview =
        CommonScrollViewLayout.new(self.scroll_list, cc.p(0, 10), ScrollViewDir.vertical, ScrollViewStartPos.top, cc.size(scroll_view_size.width, scroll_view_size.height - 20), setting)
    self.item_scrollview:setSwallowTouches(false)
    self.emptyTips = createImage(self.scroll_list, PathTool.getEmptyMark(), scroll_view_size.width / 2, 450, cc.p(0.5, 1))
    self.emptyTips:setVisible(false)
    self.empty_label = createLabel(26, Config.ColorData.data_color4[274], nil, self.emptyTips:getContentSize().width / 2, -35, TI18N("暂时没有奖励"), self.emptyTips, 0, cc.p(0.5, 0))
    self.btn_panel = self.main_panel:getChildByName("btn_panel")
    
    if controller:checkNewEndLessIsShow() == true  then
        self.sub_tab_array = {
            {title = TI18N("日常奖励"), index = 1},
            {title = TI18N("排行奖励"), index = 2},
            {title = TI18N("综合奖励"), index = 3},
            {title = TI18N("水系奖励"), index = 4},
            {title = TI18N("火系奖励"), index = 5},
            {title = TI18N("风系奖励"), index = 6},
            {title = TI18N("光暗奖励"), index = 7},
        }
    else
        self.sub_tab_array = {
            {title = TI18N("日常奖励"), index = 1},
            {title = TI18N("排行奖励"), index = 2},
            {title = TI18N("综合奖励"), index = 3},
        }
    end
    
    if not self.sub_tab_scrollview then
        local panel_size = self.btn_panel:getContentSize()
        self.sub_tab_scrollview = CommonSubBtnList.new(self.btn_panel, cc.p(0, 0.5), 
        cc.p(0, panel_size.height * 0.5), cc.size(142, 68), handler(self, self.changeSelectedTab))
    end
    self.sub_tab_scrollview:setData(self.sub_tab_array, 1)
    self.btn_panel:setScrollBarEnabled(false)
    local count = #self.sub_tab_array
    local btn_panel_width = 142*count+10
    self.btn_panel:setInnerContainerSize(cc.size(btn_panel_width,50))
    
    if btn_panel_width >600 then
        btn_panel_width = 600
    end
    self.btn_panel:setContentSize(cc.size(btn_panel_width,60))
    
    self:register_event()
end

function EndlessRewardWindow:register_event(...)
    if self.background then
        self.background:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    controller:openEndlessRewardWindow(false)
                end
            end
        )
    end

    if self.close_btn then
        self.close_btn:addTouchEventListener(
            function(sender, event_type)
                customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    controller:openEndlessRewardWindow(false)
                end
            end
        )
    end

    if not self.update_base_event then
        self.update_base_event =
            GlobalEvent:getInstance():Bind(
            Endless_trailEvent.UPDATA_BASE_DATA,
            function()
                self:updateItemData()
            end
        )
    end
    if not self.update_first_event then
        self.update_first_event =
            GlobalEvent:getInstance():Bind(
            Endless_trailEvent.UPDATA_FIRST_DATA,
            function()
                self:updateItemData()
            end
        )
    end
end

-- 切换标签页
function EndlessRewardWindow:changeSelectedTab(index)
    self.desc:setVisible(false)
    if index == 1 then
        self.desc:setVisible(true)
    end
    if index == 4 then
        self.touch_type = Endless_trailEvent.endless_type.water
        controller:send23903(self.touch_type)
    elseif index == 5 then
        self.touch_type = Endless_trailEvent.endless_type.fire
        controller:send23903(self.touch_type)
    elseif index == 6 then
        self.touch_type = Endless_trailEvent.endless_type.wind
        controller:send23903(self.touch_type)
    elseif index == 7 then
        self.touch_type = Endless_trailEvent.endless_type.light_dark
        controller:send23903(self.touch_type)
    elseif index == 3 then
        self.touch_type = Endless_trailEvent.endless_type.old
        controller:send23903(self.touch_type)
    end
    self.cur_selected = index
    self:updateItemData()
end

-- 设置列表内容
function EndlessRewardWindow:updateItemData()
    local list_data = {}
    local config = Config.EndlessData
    if config then
        local base_data = model:getEndlessData()
        if self.cur_selected == 3 or self.cur_selected == 4 or self.cur_selected == 5 or self.cur_selected == 6 or self.cur_selected == 7 then
            local first_data = model:getFirstData(self.touch_type)  
            if config.data_first_data and config.data_first_data[self.touch_type] and first_data then
                local temp_count = 1
                for k, v in ipairs(config.data_first_data[self.touch_type]) do
                    if v.id >= first_data.id then
                        local cur_is_receive = false
                        if first_data.rewarded then
                            for k1, v1 in pairs(first_data.rewarded) do
                                if v1.id == v.id then
                                    cur_is_receive = true
                                end
                            end
                        end
                        local temp_data = {
                            select_index = self.cur_selected,
                            id = v.id,
                            items = deepCopy(v.items),
                            limit_id = v.limit_id,
                            can_receive = first_data.max_id >= v.limit_id and first_data.status == 1,
                            is_receive = cur_is_receive,
                            type = self.touch_type,
                            max_id = first_data.max_id
                        }
                        
                        table.insert(list_data, temp_data)
                        temp_count = temp_count + 1
                        if temp_count > max_count then
                            break
                        end
                    end
                end
            end
        elseif self.cur_selected == 1 then
            if config.data_floor_data and config.data_floor_data[self.type] and base_data then
                local temp_count = 1
                local current_round = base_data.new_current_round
                if self.type == Endless_trailEvent.endless_type.old then
                    current_round = base_data.current_round
                end
                
                for k, v in ipairs(config.data_floor_data[self.type]) do
                    if k >= current_round then
                        local temp_data = {
                            select_index = self.cur_selected,
                            is_cur_round = k == current_round,
                            round = k,
                            items = deepCopy(v.items),
                            type = self.type
                        }
                        table.insert(list_data, temp_data)
                        temp_count = temp_count + 1
                        if temp_count > max_count then
                            break
                        end
                    end
                end
            end
        elseif self.cur_selected == 2 then
            -- local cur_rank_cfg
            -- if base_data then
            --     local my_idx = base_data.new_my_idx
            --     if self.type == Endless_trailEvent.endless_type.old then
            --         my_idx = base_data.my_idx
            --     end
            --     if config.data_rank_reward_data and config.data_rank_reward_data[self.type] then
            --         for i, v in ipairs(config.data_rank_reward_data[self.type]) do
            --             if my_idx >= v.min and my_idx <= v.max then
            --                 cur_rank_cfg = v
            --                 break
            --             end
            --         end
            --     end
            -- end
            
            local tmp_list = deepCopy(Config.EndlessData.data_rank_reward_data[self.type])
            table_sort(tmp_list, SortTools.KeyLowerSorter("min"))
            for i,v in ipairs(tmp_list) do
                v.index = i
            end
    
            for k, v in ipairs(tmp_list) do
                local title = string.format("%s~%s", v.min, v.max)
                if v.min == v.max then
                    title = string.format("%s", v.min)
                end
                local temp_data = {
                    select_index = self.cur_selected,
                    items = deepCopy(v.items),
                    type = self.type,
                    title = title
                }
                table.insert(list_data, temp_data)
            end

        end
    end
    if next(list_data) == nil then
        self.emptyTips:setVisible(true)
    else
        self.emptyTips:setVisible(false)
    end
    self.item_scrollview:setData(list_data)
end

function EndlessRewardWindow:openRootWnd(...)
end

function EndlessRewardWindow:close_callback(...)
    if self.update_first_event then
        GlobalEvent:getInstance():UnBind(self.update_first_event)
        self.update_first_event = nil
    end
    if self.update_base_event then
        GlobalEvent:getInstance():UnBind(self.update_base_event)
        self.update_base_event = nil
    end
    controller:openEndlessRewardWindow(false)
end

-- --------------------------------------------------------------------
-- @author: yuanqi(必填, 创建模块的人员)
-- @description:
--      无尽试炼奖励预览item
--
-- --------------------------------------------------------------------
EndlessRewardItem =
    class(
    "EndlessRewardItem",
    function()
        return ccui.Layout:create()
    end
)

function EndlessRewardItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_reward_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.title_label = self.main_panel:getChildByName("title_label")
    self.reward_container = self.main_panel:getChildByName("reward_container")
    self.first_btn_container = self.main_panel:getChildByName("first_btn_container")
    self.btn_receive = self.first_btn_container:getChildByName("btn_receive")
    self.btn_receive_label = self.btn_receive:getChildByName("label")
    self.btn_receive_label:setString(TI18N("领取"))
    self.receive_txt = self.first_btn_container:getChildByName("receive_txt")
    self.receive_txt:setString(TI18N("关后领取"))
    self.receive_level = self.first_btn_container:getChildByName("receive_level")

    local scroll_view_size = self.reward_container:getContentSize()
    local setting = {
        item_class = BackPackItem, -- 单元类
        start_x = 0, -- 第一个单元的X起点
        space_x = 10, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = BackPackItem.Width * 0.8, -- 单元的尺寸width
        item_height = BackPackItem.Height * 0.8, -- 单元的尺寸height
        row = 1, -- 行数，作用于水平滚动类型
        col = 0, -- 列数，作用于垂直滚动类型
        scale = 0.8
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.reward_container, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self:registerEvent()
end

function EndlessRewardItem:registerEvent()
    if self.btn_receive then
        self.btn_receive:addTouchEventListener(
            function(sender, event_type)
                customClickAction(sender, event_type)
                if ccui.TouchEventType.ended == event_type then
                    playButtonSound()
                    if self.data and self.data.id and self.type then
                        controller:send23904(self.data.id,self.type)
                    end
                end
            end
        )
    end
end

function EndlessRewardItem:setData(data)
    if not data then
        return
    end
    self.data = data
    self.type = data.type
    if self.data.select_index == 3 or self.data.select_index == 4 or self.data.select_index == 5 or self.data.select_index == 6 or self.data.select_index == 7 then
        self.first_btn_container:setVisible(true)
        self.btn_receive:setVisible(self.data.can_receive)
        if self.data.is_receive then
            self.btn_receive_label:setString(TI18N("已领取"))
            setChildUnEnabled(true, self.btn_receive)
            self.btn_receive:setEnabled(false)
            self.btn_receive_label:disableEffect(cc.LabelEffect.OUTLINE)
        else
            self.btn_receive_label:setString(TI18N("领取"))
            setChildUnEnabled(false, self.btn_receive)
            self.btn_receive:setEnabled(true)
            self.btn_receive_label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
            -- self.btn_receive:loadTextures(PathTool.getResFrame("common", "common_1017"), "", "", LOADTEXT_TYPE_PLIST)
        end
        self.receive_level:setVisible(not self.data.can_receive)
        self.receive_txt:setVisible(not self.data.can_receive)
        local title_text = string.format(TI18N("首通奖励(第%s关)"), self.data.limit_id) or ""
        if not self.data.can_receive then
            local max_round = data.max_id
       
            if self.data.limit_id >= max_round then
                self.receive_level:setString(self.data.limit_id - max_round)
            else
                self.receive_level:setString("0")
            end
        end
        self.title_label:setString(title_text)
    elseif self.data.select_index == 1 then
        self.first_btn_container:setVisible(false)
        local title_text = TI18N("当前关卡")
        if not self.data.is_cur_round then
            title_text = string.format(TI18N("通关第%s关"), self.data.round)
        end
        self.title_label:setString(title_text)
    elseif self.data.select_index == 2 then
        self.first_btn_container:setVisible(false)
        self.title_label:setString(string.format(TI18N("第%s名"), self.data.title))
    end
    -- 奖励数据
    local item_list = {}
    for k, v in pairs(data.items) do
        local vo = {}
        vo.id = v[1]
        vo.quantity = v[2]
        table.insert(item_list, vo)
    end
    self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k, v in pairs(list) do
            v.effect = false
            v:setDefaultTip()
            v:setSwallowTouches(true)
        end
    end)
    self.item_scrollview:setData(item_list)
end

function EndlessRewardItem:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end

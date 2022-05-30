-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      精英赛历史赛季
-- <br/> 2019年3月4日
--
-- --------------------------------------------------------------------
ElitematchHistoryRecordWindow = ElitematchHistoryRecordWindow or BaseClass(BaseView)

local controller = ElitematchController:getInstance()
local table_sort = table.sort
local string_format = string.format

function ElitematchHistoryRecordWindow:__init()
    self.win_type = WinType.Full
    self.layout_name = "elitematch/elitematch_history_record_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("elitematch_history", "elitematch_history"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_history_bg", true), type = ResourcesType.single}
    }
    --站台数据
    self.station_list = {}

    self.history_data_list = {}
    --标志有发送获取对应数据
    self.is_send_list = {}

    --称号id
    local config = Config.ArenaEliteData.data_elite_const.honor_shows
    if config then
        self.honor_shows = config.val
    else
        self.honor_shows = {}
    end
end

function ElitematchHistoryRecordWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_history_bg", true), LOADTEXT_TYPE)
    self.background:setScale( display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.main_panel_size = self.main_panel:getContentSize()
    -- self.main_panel:setLocalZOrder(2)

    self.top_panel = self.main_panel:getChildByName("top_panel")
    self.left_btn = self.top_panel:getChildByName("left_btn")
    self.right_btn = self.top_panel:getChildByName("right_btn")
    self.title_name = self.top_panel:getChildByName("title_name")
    self.title_name:setString(TI18N("历史赛季"))

    self.choose_btn = self.main_panel:getChildByName("choose_btn")
    self.choose_btn:getChildByName("label"):setString(TI18N("查看赛区"))
    self.choose_btn:setVisible(false)

    self.close_btn = self.main_panel:getChildByName("close_btn")
    -- self.rank_btn = self.main_panel:getChildByName("rank_btn")
    -- self.rank_btn:getChildByName("label"):setString(TI18N("排行"))
    
    --暂时写死显示 策划没填表.因为
    for i=1,6 do
        local station_lay = self.main_panel:getChildByName("station_lay_"..i)
        local point_good_btn = self.main_panel:getChildByName("point_good_btn_"..i)
        local station_item = {}
        station_item.station_lay = station_lay
        station_item.mode_node = station_lay:getChildByName("mode_node")
        station_item.name = station_lay:getChildByName("name")
        station_item.title_img = station_lay:getChildByName("title_img")
        local power_click = station_lay:getChildByName("power_click")
        station_item.power_click = power_click
        station_item.fight_label = CommonNum.new(20, power_click, 0, - 2, cc.p(0, 0.5))
        station_item.fight_label:setPosition(63, 30) 

        self.station_list[i] = station_item
    end

    -- self:addEffect()

    --设置适配
    self:adaptationScreen()
end
--设置适配屏幕
function ElitematchHistoryRecordWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    -- local left_x = display.getLeft(self.main_container)
    -- local right_x = display.getRight(self.main_container)

    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getBottomHeight()

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.main_panel_size.height - tab_y))

    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)
end

function ElitematchHistoryRecordWindow:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnLeft), true, 2)

    registerButtonEventListener(self.choose_btn, handler(self, self.onClickChooseBtn), true, 2)

    

     self.right_btn:addTouchEventListener(function(sender, event_type)
        customClickActionByXY(sender, event_type, -1, 1) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:onClickBtnRight()
        end
    end)

    for i,v in ipairs(self.station_list) do
        if v.point_good_btn then
            registerButtonEventListener(v.point_good_btn, function() self.onPointGoodByIndex(i) end ,true, 2)
        end
    end
    -- registerButtonEventListener(self.explain_btn, function(param,sender, event_type)
    --     local config = Config.PrimusData.data_const.game_rule
    --     TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    -- end ,false, 1)

    --战区信息
    self:addGlobalEvent(ElitematchEvent.Elite_History_Zone_Event, function(data)
        if not data then return end
        self.dic_max_zone_id = {}
        --和后端商量..做一个容错..默认只有1个赛区
        for i=1,self.max_period do
           self.dic_max_zone_id[i] = 1
        end
        for i,v in ipairs(data.zone_info) do
            self.dic_max_zone_id[v.period] = v.max_zone_id
        end
        self:initHeadInfo()
    end)

    --历史赛季
    self:addGlobalEvent(ElitematchEvent.Elite_History_Record_Event, function(data)
        if not data then return end
        table_sort(data.arena_elite_rank, function(a,b) return a.rank < b.rank end )
        if self.history_data_list[data.period] == nil then
            self.history_data_list[data.period] = {}
        end
        self.history_data_list[data.period][data.zone_id] = data
        if self.select_period == data.period then
            self:initData(data)
        end
    end)
end
function ElitematchHistoryRecordWindow:onClickBtnClose()
    controller:openElitematchHistoryRecordWindow(false)
end

function ElitematchHistoryRecordWindow:onClickBtnRank()
    controller:getModel():setElitePeriod(self.select_period or 1)
    RankController:getInstance():openRankView(true, RankConstant.RankType.elite)
end

function ElitematchHistoryRecordWindow:onClickChooseBtn( )
    if self.dic_max_zone_id and self.dic_max_zone_id[self.select_period] then
        local max_zone_id = self.dic_max_zone_id[self.select_period]

        controller:openElitematchZoneListPanel(true, max_zone_id, function(zone_id)
            if not zone_id then return end
            if self.station_list then
                self.cur_zone_id = zone_id
                self:setBtnShowStatus()
                self:updateData()
            end
        end)
    end
end
--左
function ElitematchHistoryRecordWindow:onClickBtnLeft()
    if not self.select_period then return end
    self.select_period = self.select_period - 1
    if self.select_period <= 1 then
        self.select_period = 1
    end
    
    self:setBtnShowStatus()
    self:updateData()
end
--右
function ElitematchHistoryRecordWindow:onClickBtnRight()
    if not self.select_period then return end
    self.select_period = self.select_period + 1
    if self.select_period >= self.max_period then
        self.select_period = self.max_period
    end
    self:setBtnShowStatus()
    self:updateData()
end

function ElitematchHistoryRecordWindow:updateData()
    if not self.dic_max_zone_id then return end
    if not self.cur_zone_id then return end
    if not self.dic_max_zone_id[self.select_period] then return end
    local zone_id = self.cur_zone_id --默认是当前选中的
    if zone_id > self.dic_max_zone_id[self.select_period] then
        --容错的
        zone_id = self.dic_max_zone_id[self.select_period]
    end

    if self.history_data_list[self.select_period] and self.history_data_list[self.select_period][zone_id] then
        self:initData(self.history_data_list[self.select_period][zone_id])
        return
    end

    if self.is_send_list[self.select_period] and self.is_send_list[self.select_period][zone_id] then
        return
    end
    if self.is_send_list[self.select_period] == nil then
        self.is_send_list[self.select_period] = {}
    end
    self.is_send_list[self.select_period][zone_id] = true

    --这里默认第一个
    controller:sender24911(self.select_period, 1, 6, zone_id)
end

--设置按钮状态
function ElitematchHistoryRecordWindow:setBtnShowStatus()
    if not self.select_period then return end
    if not self.max_period then return end
    if not self.dic_max_zone_id then return end

    if self.max_period == 1 then
        self.left_btn:setVisible(false)
        self.right_btn:setVisible(false) 
        return 
    end

    if self.select_period == 1 then
        self.left_btn:setVisible(false)
        local next_period = self.select_period + 1
        if self.dic_max_zone_id[next_period] and self.dic_max_zone_id[next_period] < self.cur_zone_id then
            self.right_btn:setVisible(false)
        else
            self.right_btn:setVisible(true)
        end
    elseif self.select_period == self.max_period then
        local pre_period = self.select_period - 1
        if self.dic_max_zone_id[pre_period] and self.dic_max_zone_id[pre_period] < self.cur_zone_id then
            self.left_btn:setVisible(false)    
        else
            self.left_btn:setVisible(true)    
        end 

        self.right_btn:setVisible(false) 
    else
        local pre_period = self.select_period - 1
        if self.dic_max_zone_id[pre_period] and self.dic_max_zone_id[pre_period] < self.cur_zone_id then
            self.left_btn:setVisible(false)    
        else
            self.left_btn:setVisible(true)    
        end 

        local next_period = self.select_period + 1
        if self.dic_max_zone_id[next_period] and self.dic_max_zone_id[next_period] < self.cur_zone_id then
            self.right_btn:setVisible(false)
        else
            self.right_btn:setVisible(true)
        end
    end

end
function ElitematchHistoryRecordWindow:onPointGoodByIndex(index)
    
end

-- function ElitematchHistoryRecordWindow:addEffect()
--     self.size = self.main_container:getSize()
--     --流星
--     if self.scene_effect_1 == nil then
--         self.scene_effect_1 = createEffectSpine(PathTool.getEffectRes(305), cc.p(self.size.width*0.5,self.size.height*0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
--         self.background:addChild(self.scene_effect_1, 1) 
--     end
-- end

--@ period 周期
function ElitematchHistoryRecordWindow:openRootWnd(period, max_period, zone_id)
    if not period then return end 
    self.max_period = max_period or period
    self.select_period = period
    self.cur_zone_id = zone_id or 1 --我的战区id

    controller:sender24910()
end

function ElitematchHistoryRecordWindow:initHeadInfo()
    if not self.dic_max_zone_id then return end
    if not self.dic_max_zone_id[self.select_period] then return end

    --当前选择的最大战区比我的战区小
    if self.dic_max_zone_id[self.select_period] < self.cur_zone_id then
        if self.dic_max_zone_id[self.max_period] and self.dic_max_zone_id[self.max_period] < self.cur_zone_id then
            --容错的
            self.cur_zone_id = self.dic_max_zone_id[self.max_period]
        end
        self.select_period = self.max_period
    end
    self:setTitle(self.select_period, self.cur_zone_id)
    self:setBtnShowStatus()
    self:updateData()
end

function ElitematchHistoryRecordWindow:setTitle(period, zone_id)
    local period = period or 1
    local zone_id = zone_id or 1
    local config = Config.ArenaEliteData.data_zone[zone_id]
    local str 
    if config then 
        str = string_format(TI18N("S%s赛季(%s赛区)"), period, config.name)
    else
        str = string_format(TI18N("S%s赛季"), period)
    end
    
    self.title_name:setString(str)
end

function ElitematchHistoryRecordWindow:initData(data)
    for i=1,6 do
        local server_data = nil 
        if data.arena_elite_rank then
            server_data = data.arena_elite_rank[i]
        end
        if self.max_period == self.select_period then
            server_data = nil 
        end
        self:updateStationInfoByPos(i, server_data)
    end
    
    self:setTitle(self.select_period, data.zone_id)
end

function ElitematchHistoryRecordWindow:updateStationInfoByPos(pos_index, sever_data)
    local station_item = self.station_list[pos_index]
    if not station_item then return end

    if sever_data == nil then
        if station_item.spine then
            station_item.spine:setVisible(false)
        end
        station_item.fight_label:setNum(0)
        station_item.power_click:setVisible(false)
        station_item.title_img:setVisible(false)
        station_item.name:setString(TI18N("虚以待位"))

    else
        -- station_item.point_good_btn:setVisible(true)
        local server_name = getServerName(sever_data.srv_id) or ""
        local name_str = string_format("[%s]%s",server_name, sever_data.name)
        station_item.name:setString(name_str)
        station_item.power_click:setVisible(true)
        station_item.title_img:setVisible(true)
        station_item.fight_label:setNum(sever_data.power)

        local honor_data = Config.HonorData.data_title[self.honor_shows[pos_index]] 
        if honor_data and station_item.title_img and station_item.item_load == nil then
            local res = PathTool.getPlistImgForDownLoad("honor","txt_cn_honor_"..honor_data.res_id,false)
            station_item.item_load = loadSpriteTextureFromCDN(station_item.title_img, res, ResourcesType.single, station_item.item_load)
        end 
        -- 模型
        self:updateSpine(sever_data.look_id, pos_index)
    end 
end

--更新模型,也是初始化模型
function ElitematchHistoryRecordWindow:updateSpine(look_id, pos_index)
    local station_item = self.station_list[pos_index]
    if not station_item then return end
    if station_item.record_look_id ~= nil and station_item.record_look_id == look_id then
        if station_item.spine then
            station_item.spine:setVisible(true)
        end
        return
    end 
    station_item.record_look_id = look_id
    local fun = function()
        if not station_item.spine then
            station_item.spine = BaseRole.new(BaseRole.type.role, look_id)
            station_item.spine:setAnimation(0,PlayerAction.show,true) 
            station_item.spine:setCascade(true)
            station_item.spine:setPosition(cc.p(0,45))
            station_item.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            station_item.spine:setScale(0.8)
            station_item.mode_node:addChild(station_item.spine) 
            station_item.spine:setCascade(true)
            station_item.spine:setOpacity(0)
            local action = cc.FadeIn:create(0.2)
            station_item.spine:runAction(action)
        end
    end
    if station_item.spine then
        station_item.spine:setCascade(true)
        local action = cc.FadeOut:create(0.2)
        station_item.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                doStopAllActions(station_item.spine)
                station_item.spine:removeFromParent()
                station_item.spine = nil
                fun()
        end)))
    else
        fun()
    end
end

function ElitematchHistoryRecordWindow:close_callback()
    if self.station_list then
        for k,item in pairs(self.station_list) do
            if item.spine then
                item.spine:DeleteMe()
                item.spine = nil
            end

            if item.item_load then
                item.item_load:DeleteMe()
                item.item_load = nil
            end

            if item.fight_label then
                item.fight_label:DeleteMe()
                item.fight_label = nil
            end
        end
        self.station_list = nil
    end

    controller:openElitematchHistoryRecordWindow(false)
end

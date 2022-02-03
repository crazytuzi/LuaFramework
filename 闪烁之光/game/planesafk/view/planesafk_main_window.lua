-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      位面改版主界面 参考afk的 后端 国辉 策划 中建
-- <br/>Create: 2020-02-05
-- --------------------------------------------------------------------

PlanesafkMainWindow = PlanesafkMainWindow or BaseClass(BaseView)

local controller = PlanesafkController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local math_ceil = math.ceil
local math_floor = math.floor

function PlanesafkMainWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.layout_name = "planesafk/planesafk_main_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("planes", "planes_map"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("planes","planes_bg", true), type = ResourcesType.single},
    }

    self.dic_map_list = {}
    --最大层数
    self.max_floor = 3
    local config = Config.PlanesData.data_const.max_floor
    if config then
        self.max_floor = config.val
    end

    self.difficult_limit_lev = 30
    local config = Config.PlanesData.data_const.planes_difficult_limit_lev
    if config then
        self.difficult_limit_lev = config.val
    end

    self.planes_difficult_max_power = 300000
    local config = Config.PlanesData.data_const.planes_difficult_max_power
    if config then
        self.planes_difficult_max_power = config.val
    end

    self.planes_first_time_tips = {}
    local config = Config.PlanesData.data_const.planes_first_time_tips
    if config then
        self.planes_first_time_tips = config.val
        if type(self.planes_first_time_tips) == "number" then
            self.planes_first_time_tips = {}
        end
    end

    self.door_item_list = {}
    self.door_item_load = {}
    -- self.door_res_id = {21, 22}
    self.door_res_id = {"E27531", "E27532"}
    self.show_item_id = {}
    self.show_item_id[Config.ItemData.data_assets_label2id.expedition_medal] = true
    self.show_item_id[Config.ItemData.data_assets_label2id.coin] = true
end

function PlanesafkMainWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("planes","planes_bg",true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    -- 触摸层
    self.map_container = self.root_wnd:getChildByName("map_container")

    -- ui层
    self.ui_container = self.root_wnd:getChildByName("ui_container")
    self.container_size = self.ui_container:getContentSize()
    self.close_btn = self.ui_container:getChildByName("close_btn")
    self.close_btn:getChildByName("label"):setString(TI18N("返回"))
    self.dun_btn = self.ui_container:getChildByName("dun_btn")
    self.dun_btn:getChildByName("label"):setString(TI18N("副本信息"))
    self.fight_btn = self.ui_container:getChildByName("fight_btn")
    self.fight_btn:getChildByName("label"):setString(TI18N("征战之证"))
    self.figure_btn = self.ui_container:getChildByName("figure_btn")
    self.figure_btn:getChildByName("label"):setString(TI18N("更换形象"))
    self.active_btn = self.ui_container:getChildByName("active_btn")
    if self.active_btn then
        self.active_btn:getChildByName("label"):setString(TI18N("位面迷踪"))
        self.active_btn:setVisible(false)
        self.active_time_val = self.active_btn:getChildByName("time_val_0")
    end
    
    self.btn_rule = self.ui_container:getChildByName("btn_rule")
    self.btn_hide = self.ui_container:getChildByName("btn_hide")

    self.bottom_panel = self.ui_container:getChildByName("bottom_panel")
    self.bag_btn = self.bottom_panel:getChildByName("bag_btn")
    self.hero_btn = self.bottom_panel:getChildByName("hero_btn")
    self.buff_btn = self.bottom_panel:getChildByName("buff_btn")
    self.shop_btn = self.bottom_panel:getChildByName("shop_btn")
    self.tip_btn = self.bottom_panel:getChildByName("tip_btn")
    self.tip_key_0 = self.bottom_panel:getChildByName("tip_key_0")
    self.Image_21 = self.bottom_panel:getChildByName("Image_21")
    self.tip_key_0:setString(TI18N("首次通关"))

    self.shadow_bg_1 = self.ui_container:getChildByName("shadow_bg_1")
    self.shadow_bg_2 = self.ui_container:getChildByName("shadow_bg_2")

    self.box_2017 = self.ui_container:getChildByName("box_2017")
    self.tip_key = self.box_2017:getChildByName("tip_key")
    self.tip_key:setString(TI18N("本轮已获:"))

    self.reward_list = {}
    self.reward_list[1] = createRichLabel(24, cc.c4b(0x6f,0xf2,0x81,0xff), cc.p(0, 0.5), cc.p(10,70),nil,nil,600)
    self.reward_list[2] = createRichLabel(24, cc.c4b(0x6f,0xf2,0x81,0xff), cc.p(0, 0.5), cc.p(10,30),nil,nil,600)
    self.box_2017:addChild(self.reward_list[1])
    self.box_2017:addChild(self.reward_list[2])
    
    local item_list = {{base_id = Config.ItemData.data_assets_label2id.expedition_medal, num = 0}, {base_id = Config.ItemData.data_assets_label2id.coin, num = 0}}
    for i,v in ipairs(item_list) do
        local item_config = Config.ItemData.data_get_data(v.base_id)
        if item_config and self.reward_list[i] then 
            local res = PathTool.getItemRes(item_config.icon)
            local str = string_format("<img src='%s' scale=0.3 />  %s", res, MoneyTool.GetMoneyString(v.num))                
            self.reward_list[i]:setString(str)
        end
    end

    self.top_title_bg = self.ui_container:getChildByName("top_title_bg")
    self.floor_txt = self.top_title_bg:getChildByName("floor_txt")
    self.time_val = self.top_title_bg:getChildByName("time_val")

    MainuiController:getInstance():setIsShowMainUIBottom(false) -- 隐藏底部UI
    self:adaptationScreen()
end

--设置适配屏幕
function PlanesafkMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.ui_container)
    local bottom_y = display.getBottom(self.ui_container)
    -- local left_x = display.getLeft(self.ui_container)
    -- local right_x = display.getRight(self.ui_container)

    self.shadow_bg_1:setPositionY(bottom_y)
    self.shadow_bg_2:setPositionY(top_y)
    --头部
    local tab_y = self.top_title_bg:getPositionY()
    self.top_title_bg:setPositionY(top_y - (self.container_size.height - tab_y))

    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(top_y - (self.container_size.height - close_btn_y))
    
    local close_btn_y = self.dun_btn:getPositionY()
    self.dun_btn:setPositionY(top_y - (self.container_size.height - close_btn_y))
    
    -- local close_btn_y = self.shop_btn:getPositionY()
    -- self.shop_btn:setPositionY(top_y - (self.container_size.height - close_btn_y))
    
    local close_btn_y = self.figure_btn:getPositionY()
    self.figure_btn:setPositionY(top_y - (self.container_size.height - close_btn_y))

    local close_btn_y = self.btn_rule:getPositionY()
    self.btn_rule:setPositionY(top_y - (self.container_size.height - close_btn_y))

    local close_btn_y = self.btn_hide:getPositionY()
    self.btn_hide:setPositionY(top_y - (self.container_size.height - close_btn_y))

    local close_btn_y = self.box_2017:getPositionY()
    self.box_2017:setPositionY(top_y - (self.container_size.height - close_btn_y))

    local close_btn_y = self.fight_btn:getPositionY()
    self.fight_btn:setPositionY(top_y - (self.container_size.height - close_btn_y))

    if self.active_btn then
        local close_btn_y = self.active_btn:getPositionY()
        self.active_btn:setPositionY(top_y - (self.container_size.height - close_btn_y))
    end


    --底部
    local bottom_panel_y = self.bottom_panel:getPositionY()
    self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)


    --多出的高度
    local height = (top_y - self.container_size.height) - bottom_y
    self.ext_height = height
    -- local size = self.panel_bg:getContentSize()
    -- self.panel_bg:setContentSize(cc.size(size.width, size.height + height))

    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end


function PlanesafkMainWindow:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.dun_btn, handler(self, self.onClickDunBtn), true)
    registerButtonEventListener(self.btn_hide, handler(self, self.onClickHideBtn), true)
    registerButtonEventListener(self.bag_btn, handler(self, self.onClickBagBtn), true)
    registerButtonEventListener(self.hero_btn, handler(self, self.onClickHeroBtn), true)
    registerButtonEventListener(self.buff_btn, handler(self, self.onClickBuffBtn), true)
    registerButtonEventListener(self.shop_btn, handler(self, self.onClickShopBtn), true)
    -- registerButtonEventListener(self.btn_rule, handler(self, self.onClickRuleBtn), true)
    registerButtonEventListener(self.figure_btn, handler(self, self.onClickFigureBtn), true)
    registerButtonEventListener(self.fight_btn, handler(self, self.onClickFightBtn), true)

    registerButtonEventListener(self.active_btn, handler(self, self.onActiveBtn), true)

    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        local config = Config.PlanesData.data_const.planes_rule
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end ,false, 1)


    registerButtonEventListener(self.tip_btn, function(param,sender, event_type)
        local config = Config.PlanesData.data_const.planes_first_time_tips
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end ,false, 1)

    --基础信息
    self:addGlobalEvent(PlanesafkEvent.Planesafk_Main_Base_Info_Event, function(data)
        --人物和 时间
        if not data then return end
        self.base_data = data
        self:setData()
    end)

    --地图数据
    self:addGlobalEvent(PlanesafkEvent.Planesafk_Main_Map_Info_Event, function(data)
        if not data then return end
        self.map_data = data 
        self:initMapData(data)
    end)
    --地图数据
    self:addGlobalEvent(PlanesafkEvent.Planesafk_Update_Map_Info_Event, function(data)
        if not data then return end
        self:initMapData(data, is_update)
    end)

    -- buff进背包的动画
    self:addGlobalEvent(PlanesafkEvent.Chose_Buff_Event, function ( buff_id, world_pos )
        self:showBuffItemMoveAni(buff_id, world_pos)
    end)
    -- 领取宝箱后
    self:addGlobalEvent(PlanesafkEvent.Planesafk_Pass_Reward_Info_Event, function ( data )
        if self.map_data then
            self.map_data.is_reward = 1
            self:updateBoxInfo()
        end
    end)
    -- 领取宝箱前
    self:addGlobalEvent(PlanesafkEvent.Planesafk_Last_Reward_Info_Event, function ( data )
        if self.map_data then
            self.map_data.is_can_reward = data.is_can_reward
            self.map_data.is_reward = data.is_reward
            self:updateBoxInfo()
        end
    end)
    -- 下一个地图
    self:addGlobalEvent(PlanesafkEvent.Planesafk_Next_Map_Info_Event, function ( data )
        controller:sender28603()
    end)
    -- 本日已获取
    self:addGlobalEvent(PlanesafkEvent.Planesafk_Update_Get_Reward_Event, function ( data )
        -- controller:sender28603()
        if not data then return end
        self:updateRewardInfo(data)
    end)

    -- 创建角色事件
    self:addGlobalEvent(PlanesafkEvent.Planesafk_Create_Role_Event, function ( data )
        if self.map_role == nil then
            self:showRoleInfo()
        end
    end)

    -- 更换形象
    self:addGlobalEvent(HomeworldEvent.Update_My_Home_Figure_Event, function (  )
        local look_id = HomeworldController:getInstance():getModel():getMyCurHomeFigureId()
        model:setPlanesRoleLookId(look_id)
        self:showRoleInfo(look_id)
    end)

    --战令信息
    self:addGlobalEvent(PlanesafkEvent.Planesafk_OrderAction_Init_Event, function(data)
        if not data then return end
        self:updateOrderactionRed()
    end)

    --战令红点刷新
    self:addGlobalEvent(PlanesafkEvent.Planesafk_OrderAction_First_Red_Event, function()
        self:updateOrderactionRed()
    end)
    --位免迷踪活动
    self:addGlobalEvent(ActionEvent.UPDATE_HOLIDAY_SIGNLE, function(data)
        if not data then return end
        if data.bid == ActionRankCommonType.planes_rank then
            self:setPanelData(data)
        end
    end)
end

function PlanesafkMainWindow:setPanelData( data )
    if self.active_btn then
        self.active_btn:setVisible(true)
        local time = data.remain_sec or 0
        time = time - 24*60*60
        if time <= 0 then
            time = 0
        end
        commonCountDownTime(self.active_time_val, time, {callback = function(time) self:setTimeFormatString(time) end})
    end
end

function PlanesafkMainWindow:setTimeFormatString( time )
    if time > 0 then
        self.active_time_val:setString(TimeTool.GetTimeForFunction(time))
    else
        self.active_time_val:setString(TI18N("已结束"))
    end
end
--活动
function PlanesafkMainWindow:onActiveBtn(  )
    MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.planes_rank)
end
--战令
function PlanesafkMainWindow:onClickFightBtn(  )
    controller:openPlanesafkOrderactionWindow(true)
end
-- 隐藏上栏
function PlanesafkMainWindow:onClickHideBtn(  )
    self.is_hide_top = not self.is_hide_top
    MainuiController:getInstance():setMainUIShowStatus(not self.is_hide_top)
    MainuiController:getInstance():setIsShowMainUIBottom(false)
    self.top_title_bg:setVisible(not self.is_hide_top)
    self.btn_rule:setVisible(not self.is_hide_top)
    self.btn_hide:setVisible(not self.is_hide_top)
    self.close_btn:setVisible(not self.is_hide_top)
    self.box_2017:setVisible(not self.is_hide_top)
    self.bottom_panel:setVisible(not self.is_hide_top)
    self.figure_btn:setVisible(not self.is_hide_top)
    if model:isHolidayOpen() then
        if self.active_btn then
            self.active_btn:setVisible(not self.is_hide_top)
        end
    end
    if self.is_hide_top == false then
        self.fight_btn:setVisible(model.getOrderIsShow())
    else
        self.fight_btn:setVisible(not self.is_hide_top)
    end

    if self.is_hide_top then
        if not self.hide_mask then
            self.hide_mask = ccui.Layout:create()
            self.hide_mask:setContentSize(SCREEN_WIDTH, SCREEN_HEIGHT)
            self.hide_mask:setScale(display.getMaxScale())
            self.hide_mask:setAnchorPoint(cc.p(0.5, 0.5))
            self.hide_mask:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
            self.hide_mask:setTouchEnabled(true)
            self.ui_container:addChild(self.hide_mask, 99)
            self.hide_mask:setSwallowTouches(false)
            self.hide_mask:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    self:onClickHideBtn()
                end
            end)
        end
        self.hide_mask:setVisible(true)
    elseif self.hide_mask then
        self.hide_mask:setVisible(false)
    end
end

-- 关闭
function PlanesafkMainWindow:onClickCloseBtn(  )
    controller:openPlanesafkMainWindow(false)
end

-- 打开振魂结晶
function PlanesafkMainWindow:onClickBagBtn(  )
    controller:openPlanesafkItemUsePanel(true)
end
-- 打开英雄列表
function PlanesafkMainWindow:onClickHeroBtn(  )
    controller:openPlanesafkHeroListPanel(true)
end

-- 打开buff列表
function PlanesafkMainWindow:onClickBuffBtn(  )
    controller:openPlanesafkBuffListPanel(true)
end

-- 打开buff列表
function PlanesafkMainWindow:onClickShopBtn(  )
    MallController:getInstance():openMallPanel(true, MallConst.MallType.FriendShop)
end

function PlanesafkMainWindow:onClickFigureBtn(  )
    if not self.base_data then return end
    local look_id = model:getPlanesRoleLookId()
    if not look_id or look_id == 0 then
        local limit_cfg = Config.HomeData.data_const["open_lev"]
        local open_lv = 70
        if limit_cfg then
            open_lv = limit_cfg.val or 70
        end
        message(string_format(TI18N("%s级开启家园系统，开启后才可更换Q版冒险形象哦~"), open_lv))
    else
        HomeworldController:getInstance():openHomeworldFigureWindow(true)
    end
end
--点击了宝箱
function PlanesafkMainWindow:onClickBoxBtn()
    if not self.map_data then return end
    if self.map_data.is_can_reward == 1 then
        controller:sender28605(self.map_data.floor)
        if self.box_effect then
            self.box_effect:setAnimation(0, PlayerAction.action_3, false)
        end
    end
end

--点击难度
function PlanesafkMainWindow:onClickHardBtn(index)
    if not self.map_data then return end

    local now_tower = StartowerController:getInstance():getModel():getNowTowerId()
    local role_vo = RoleController:getInstance():getRoleVo()

    if self.map_data.floor and self.map_data.floor > 1 and role_vo and role_vo.power >= self.planes_difficult_max_power and  now_tower >= self.difficult_limit_lev then
        controller:openPlanesafkChooseDifficultyPanel(true, {floor = self.map_data.floor + 1})
    else
        controller:sender28604(self.map_data.floor + 1, 1)
    end
end


function PlanesafkMainWindow:updateRewardInfo(data )
    if not self.show_item_id then return end
    if data.item_list and next(data.item_list) ~= nil then
        local item_list = {}
        for i,v in ipairs(data.item_list) do
            if self.show_item_id[v.base_id] then
                table_insert(item_list, v)
            end
        end
        table_sort(item_list, function(a,b) return a.base_id > b.base_id end)
        for i,v in ipairs(item_list) do
            local item_config = Config.ItemData.data_get_data(v.base_id)
            if item_config and self.reward_list[i] then 
                local res = PathTool.getItemRes(item_config.icon)
                local str = string_format("<img src='%s' scale=0.3 />  %s", res, MoneyTool.GetMoneyString(v.num))                
                self.reward_list[i]:setString(str)
            end
        end
    end
end

-- 锁屏
function PlanesafkMainWindow:isLockPlanesMapScreen( flag )
    if flag == true then
        if not self.lock_mask then
            local con_size = self.ui_container:getContentSize()
            self.lock_mask = ccui.Layout:create()
            self.lock_mask:setContentSize(SCREEN_WIDTH, SCREEN_HEIGHT)
            self.lock_mask:setAnchorPoint(cc.p(0.5, 0.5))
            self.lock_mask:setScale(display.getMaxScale())
            self.lock_mask:setPosition(con_size.width*0.5, con_size.height*0.5)
            self.lock_mask:setTouchEnabled(true)
            self.lock_mask:setSwallowTouches(true)
            self.ui_container:addChild(self.lock_mask, 10)
        end
        self.lock_mask:setVisible(true)
    elseif self.lock_mask then
        self.lock_mask:setVisible(false)
    end
end



function PlanesafkMainWindow:openRootWnd(setting)
    local setting = setting or {}
    controller:sender28602() -- 基本信息
    controller:sender28603() --地图信息

    controller:sender28613() --英雄列表
    controller:sender28625() --获取一下
    model:setPlanesafkLoginRedpointFalse()
end

function PlanesafkMainWindow:setVisible( bool )
    self.is_visible = bool
    if self.root_wnd == nil or tolua.isnull(self.root_wnd) then return end
    self.root_wnd:setVisible(bool)
    if bool == true then
        MainuiController:getInstance():setIsShowMainUIBottom(false) -- 隐藏底部UI
    else
        MainuiController:getInstance():setIsShowMainUIBottom(true) -- 隐藏底部UI
    end
end

function PlanesafkMainWindow:setData()
    local look_id = model:getPlanesRoleLookId()
    if not look_id or look_id == 0 then
        setChildUnEnabled(true, self.figure_btn)
    else
        setChildUnEnabled(false, self.figure_btn)
    end

    local time = self.base_data.update_time - GameNet:getInstance():getTime()
    --处理时间
    commonCountDownTime(self.time_val, time, {end_title=TI18N("后重置")})

    self.fight_btn:setVisible(model.getOrderIsShow())

    self:updateOrderactionRed()
    if model:isHolidayOpen() then
        --是否活动开启中 为了获取时间
        ActionController:getInstance():cs16603(ActionRankCommonType.planes_rank)
        if not model.getOrderIsShow()  then
            -- 如果战令不开 要放早战令的位置上
            if self.active_btn then
                self.active_btn:setPositionY(self.fight_btn:getPositionY())
            end
        end 
    end
end

function PlanesafkMainWindow:getMapEvtData(line, index)
    if line and index and self.dic_map_list then
        if self.dic_map_list[line] and self.dic_map_list[line].list  then
            return self.dic_map_list[line].list[index]
        end
    end
end


function PlanesafkMainWindow:initMapData(data, is_update)
    if data.map_id then
        self.map_data = data
        local config = Config.PlanesData.data_customs[self.map_data.map_id]
        if config then
            local str
            if config.difficulty ==2 then
                str = TI18N("困难")
            else
                str = TI18N("普通")
            end
            if self.floor_txt then
                self.floor_txt:setString(string_format(TI18N("第%s层位面探险(%s)"), self.map_data.floor,  str))
            end
        end
        
        local is_show = false
        for _,map_id in ipairs(self.planes_first_time_tips) do
            if map_id == self.map_data.map_id then
                is_show = true
                break
            end 
        end
        self.tip_btn:setVisible(is_show)
        self.tip_key_0:setVisible(is_show)
        self.Image_21:setVisible(is_show)
    end
    if not self.map_data then return end

    local dic_update_line = {}
    for i,v in ipairs(data.tile_list) do
        dic_update_line[v.line] = true
        if self.dic_map_list[v.line] == nil then
            self.dic_map_list[v.line] = {}
            self.dic_map_list[v.line].line = v.line
            self.dic_map_list[v.line].list = {}
        end
        if self.dic_map_list[v.line].list[v.index] == nil then
            if v.evt_id ~= 0 then
                v.evt_config = Config.PlanesData.data_evt_info[v.evt_id]
            end
            self.dic_map_list[v.line].list[v.index] = v
        else
            local data_val = self.dic_map_list[v.line].list[v.index]
            for k,val in pairs(v) do
                data_val[k] = val
            end
            if v.evt_id ~= 0 then
                data_val.evt_config = Config.PlanesData.data_evt_info[v.evt_id]
            else
                data_val.evt_config = nil
            end
        end
    end

    self.show_list = {}
    local line, index = model:getRolePos()
    for k,v in pairs(self.dic_map_list) do
        --计算变黑显示
        if v.line <= line then
            for _,map_data in pairs(v.list) do
                map_data.is_black = false
            end
        elseif v.line == line + 1 then
            --在主角的上方
            for _,map_data in pairs(v.list) do
                if map_data.index == (index - 1) or  map_data.index == (index + 1) then
                    --在主角的左右就显示白色
                    map_data.is_black = false
                else
                    map_data.is_black = true
                end
            end
        else
            for _,map_data in pairs(v.list) do
                map_data.is_black = true
            end
        end
        table_insert(self.show_list, v)
    end
    local sort_fun = SortTools.tableLowerSorter({"line"})
    table_sort(self.show_list, sort_fun)


    if self.map_role ~= nil and line > self.cur_line then
        --说明往上升了一行
        local x, y = self.map_role:getPosition()
        self.cur_line = line
        self.map_role:runAction(cc.FadeOut:create(0.2))
        self:showRoleShowEffect(true, PlayerAction.action_1, x, y)
        if self.scrollview_list then
            self.scrollview_list:resetItemByIndex(line)
        end
    else
        self.cur_line = line 
        self:updateItemlist(line)
        if self.map_role then
            local x, y = self:getRolePosition()
            self.map_role:setPosition(x,y)
        end
    end
    
    if data.map_id then
        self:updateBoxInfo()
    end
end

function PlanesafkMainWindow:updateScrollviewByIndex(line, index)
    if not self.scrollview_list then return end
    if not self.show_list then return end
    for i,v in ipairs(self.show_list) do
        if v.line == line then
            local is_hide = false
            for _index, val in pairs(v.list) do
                if _index ~= index then
                    val.is_hide = 1
                    is_hide = true
                end
            end
            self.scrollview_list:resetItemByIndex(line)
            return is_hide
        end
    end
end


function PlanesafkMainWindow:getBoxStatus(  )
    if not self.map_data then return end
    --显示宝箱状态 1 表示 未激活 2 表示可领取  3 表示已领取  0 表示不显示并且要显示门
    local is_show_box_staus = 0
    if self.map_data.is_can_reward == 1  then
        if self.map_data.is_reward == 1 then 
            --已领取
            if self.max_floor > self.map_data.floor then
                -- 不是最后一层 要显示门
                is_show_box_staus = 0
            else
                is_show_box_staus = 3
            end
        else 
            --可领取
            is_show_box_staus = 2
        end
    else
        --未激活
        is_show_box_staus = 1
    end 
    return is_show_box_staus
end

--更新宝箱逻辑
function PlanesafkMainWindow:updateBoxInfo()
    if not self.scrollview_list then return end

    local is_show_box_staus = self:getBoxStatus()
    if is_show_box_staus == nil then return end
    self.is_show_box_staus = is_show_box_staus
    if self.box_bg == nil then
        self.box_bg = ccui.Widget:create()
        self.box_bg:setContentSize(cc.size(PlanesafkConst.Grid_Width, PlanesafkConst.Grid_Height))
        self.box_bg:setAnchorPoint(cc.p(0.5,0.5))
        self.box_bg:setTouchEnabled(true)
        self.box_bg:setSwallowTouches(false)
        -- 
        registerButtonEventListener(self.box_bg, handler(self, self.onClickBoxBtn))
        -- self.box_bg:addTouchEventListener(function( sender, event_type) self:onClickBoxBtn(sender, event_type) end)
        self.box_bg:setName("box_bg")
        self.scrollview_list.container:addChild(self.box_bg)
        local max_len = #self.show_list
        local x,y = self.scrollview_list:getCellXYByIndex(max_len + 2)
        self.box_bg:setPosition(x,y)
    end

    if is_show_box_staus ~= 0 and is_show_box_staus ~= 3 and self.box_effect == nil then
        local res_id = PathTool.getEffectRes(110) --E27534
        self.box_effect = createEffectSpine("E27534", cc.p( PlanesafkConst.Grid_Width/2, PlanesafkConst.Grid_Height/2), cc.p(0.5, 0.5), true, PlayerAction.action_1, function()
            if self.is_show_box_staus == 3 or self.is_show_box_staus == 0 then
                self.box_effect:setVisible(false)
                self.box_bg:setTouchEnabled(false)
            end
        end)
        self.box_bg:addChild(self.box_effect)
    end

    if self.box_effect then
        if is_show_box_staus == 0 or is_show_box_staus == 3 then
            self.box_effect:setVisible(false)
        else
            self.box_effect:setVisible(true)
        end
        if is_show_box_staus == 1 then
            --未激活
            self.box_effect:setAnimation(0, PlayerAction.action_1, true)
        elseif is_show_box_staus == 2 then
            --可领取
            self.box_effect:setAnimation(0, PlayerAction.action_2, true)
        elseif is_show_box_staus == 3 then
            --已领取
            -- self.box_effect:setAnimation(0, PlayerAction.action_3, true)
        end
    end

    if is_show_box_staus == 0 then -- 显示门
        self.box_bg:setTouchEnabled(false)
        local count 
        --试练塔层数
        local now_tower = StartowerController:getInstance():getModel():getNowTowerId()
        local role_vo = RoleController:getInstance():getRoleVo()
        if self.map_data.floor and self.map_data.floor > 1 and role_vo and role_vo.power >= self.planes_difficult_max_power and  now_tower >= self.difficult_limit_lev then
            count = 2
        else
             count = 1
        end

        local size = cc.size(PlanesafkConst.Grid_Width, PlanesafkConst.Grid_Height)
        local center_x = PlanesafkConst.Grid_Width * 0.5
        local center_y = PlanesafkConst.Grid_Height * 0.5

        for i,v in pairs(self.door_item_list) do
            v:setVisible(false)
        end

        local x = center_x - (size.width/2 -  PlanesafkConst.Grid_Width/2)
        local index = 1
        if count == 1 or (count == 2 and self.map_data.floor == 1) then
            --第一层显示 
            index = 1
        else
            index = 2
        end

        if self.door_item_list[index] == nil then
            self.door_item_list[index] = self:createDooritem(index, size)
        else
            self.door_item_list[index]:setVisible(true)    
        end
        self.door_item_list[index]:setPosition(x, center_y)
        
    else
        for i,v in pairs(self.door_item_list) do
            v:setVisible(false)
        end
        self.box_bg:setTouchEnabled(true)
    end

    --判断弹窗逻辑
    if self.is_reward ~= nil and self.is_reward ~= self.map_data.is_reward and is_show_box_staus == 3 then
        model:setIsShowSearchFinish(true)
    end
    self.is_reward = self.map_data.is_reward
    -- if is_show_box_staus == 3 then
    --     --说明是最后关了 通关了并且领了奖励
    --     model:setIsShowSearchFinish(true)
    -- end
end

--创建门对象
function PlanesafkMainWindow:createDooritem(i, size)
    local res_id = self.door_res_id[i] or "E27531"
    local door_item = ccui.Widget:create()
    door_item:setContentSize(size)
    door_item:setAnchorPoint(cc.p(0.5,0.5))
    door_item:setTouchEnabled(true)
    door_item:setSwallowTouches(false)
    registerButtonEventListener(door_item, function() self:onClickHardBtn(i) end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY, nil, nil,nil, true)
    self.box_bg:addChild(door_item)

    -- local res_path = model:getBgPathByResId(res_id)
    -- local left_img = createSprite(nil, size.width*0.5, size.height*0.5, door_item, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    -- self.door_item_load[i] = loadSpriteTextureFromCDN(left_img, res_path, ResourcesType.single, self.door_item_load[i])

    self.door_item_load[i] = createEffectSpine(res_id, cc.p(size.width*0.5, size.height*0.5), cc.p(0.5, 0.5), false, PlayerAction.action_1, function()
        if self and self.door_item_load[i] and not self.door_item_load[i].is_update_ani  then
            self.door_item_load[i].is_update_ani = true
            self.door_item_load[i]:setAnimation(0, PlayerAction.action_2, true)
        end
    end)

    door_item:addChild(self.door_item_load[i])
    return door_item
end
-- 显示角色信息角色
function PlanesafkMainWindow:showRoleInfo( )
    if not self.scrollview_list then return end
    -- if not self.map_role then
    --     self:showRoleShowEffect(true, PlayerAction.action_2)
    -- end
    self:removeRoleInfo()
    local x, y = self:getRolePosition()
    local look_id = model:getPlanesRoleLookId()
    local figure_cfg = Config.HomeData.data_figure[look_id]
    local effect_id = "H60001"
    if figure_cfg then
        effect_id = figure_cfg.look_id
    end
    self.map_role = createEffectSpine( effect_id, cc.p(0, 0), cc.p(0.5, 0), true, PlayerAction.idle )
    self.map_role:setScale(0.4)
    -- self.map_role:setTimeScale(1.6)
    -- self.layer_bg:addChild(self.map_role)
    self.scrollview_list.container:addChild(self.map_role, 1000)
    self.map_role:setName("map_role")
    self.map_role:setPosition(x,y)
end

function PlanesafkMainWindow:showRoleShowEffect(status, action, pos_x, pos_y)
    if status then
        local pos_y = pos_y or 0
        local pos_x = pos_x or 0
        self.role_show_action = action or PlayerAction.action_1
        if self.role_show_effect == nil then
            self.role_show_effect = createEffectSpine("E27533", cc.p(pos_x, pos_y), cc.p(0.5, 0.5), true, self.role_show_action , function()
                if self and self.scrollview_list ~= nil then
                    if self.role_show_action == PlayerAction.action_1 then
                        local new_x, new_y = self:getRolePosition()
                        self.map_role:runAction(cc.FadeIn:create(0.2))
                        self.map_role:setPosition(new_x, new_y)
                        self.must_delay = true
                        self:showRoleShowEffect(true, PlayerAction.action_2, new_x, new_y)
                        self:updateItemlist(self.cur_line)
                        self.must_delay = false
                    else
                        self.role_show_effect:setVisible(false)
                    end
                end
            end)
            self.scrollview_list.container:addChild(self.role_show_effect, 1000)
        else
            self.role_show_effect:setPosition(pos_x, pos_y)
            self.role_show_effect:setVisible(true)
            self.role_show_effect:setAnimation(0, self.role_show_action, false)
        end
    else
        if self.role_show_effect then
            self.role_show_effect:clearTracks()
            self.role_show_effect:removeFromParent()
            self.role_show_effect = nil
        end
    end
end

--获取当前 角色应该在的位置
function PlanesafkMainWindow:getRolePosition( )
    local line, index = model:getRolePos()

    local x, y = self.scrollview_list:getCellXYByIndex(line)
    local start_x = x - self.scrollview_list.item_width * 0.5
    local start_y = y


    local item = self.scrollview_list:getActiveCellByIndex(line)
    if item then
        if item.item_list and item.item_list[index] then
            local item_x, item_y = item.item_list[index].root_wnd:getPosition()
            start_x = start_x + item_x
            start_y = start_y + item_y
        end
    end
    return start_x, start_y
end

function PlanesafkMainWindow:removeRoleInfo(not_show)
     if self.map_role then
        self.map_role:clearTracks()
        self.map_role:removeFromParent()
        self.map_role = nil
        self.cur_look_id = nil
        if not not_show then
            -- self:showRoleShowEffect(true)
        end
    end
end

--列表
function PlanesafkMainWindow:updateItemlist(line)
    if not self.show_list then return end
    if self.scrollview_list == nil then
        -- local scrollview_size = self.map_container:getContentSize()
        --高度要动态适配
        local ext_height = self.ext_height or 0
        local scrollview_size = cc.size(720, 1080 + ext_height )

        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 50,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 720,                -- 单元的尺寸width
            item_height = 140,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        local bottom_y = display.getBottom(self.ui_container)
        local y = bottom_y + 70
        self.scrollview_list = CommonScrollViewSingleLayout.new(self.map_container, cc.p(0,y) , ScrollViewDir.vertical, ScrollViewStartPos.bottom, scrollview_size, setting, cc.p(0, 0))
        self.scrollview_list.delay = 2
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    -- local select_index = line - 2
    -- if select_index < 1 then
    --     select_index = 1
    -- end
    if line == 1 then
        self.scrollview_list:reloadData()
    else
        self.scrollview_list:reloadData(nil, nil , true)
        self.scrollview_list:jumpToMoveByIndex(line)
    end
    -- self:showRoleInfo()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function PlanesafkMainWindow:createNewCell(width, height)
    local cell = PlanesafkMainItem.new(width, height, self)
    return cell
end

--获取数据数量
function PlanesafkMainWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list + 3
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function PlanesafkMainWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index] 
    if data then
        if self.must_delay and index == self.cur_line + 1 then
            delayRun(cell, 0.2, function() cell:setData(data, index)  end)
        else
            cell:setData(data, index)
        end
        
        cell:setVisible(true)
    else
        cell:setVisible(false)
    end
    
end

-- 播放buff进背包的效果
function PlanesafkMainWindow:showBuffItemMoveAni( buff_id, world_pos )
    if not buff_id or not world_pos then return end
    local buff_cfg = Config.PlanesData.data_buff[buff_id]
    if not buff_cfg then return end

    if self.move_buff_item then
        self.move_buff_item:DeleteMe()
        self.move_buff_item = nil
    end

    self.move_buff_item = PlanesBuffItem.new()
    self.move_buff_item:setAnchorPoint(cc.p(0.5, 0.5))
    self.move_buff_item:setData(buff_cfg)
    local local_pos = self.ui_container:convertToNodeSpace(world_pos)
    local item_size = self.move_buff_item:getContentSize()
    self.move_buff_item:setPosition(cc.p(local_pos.x+item_size.width*0.5, local_pos.y+item_size.height*0.5))
    self.ui_container:addChild(self.move_buff_item)

    local target_pos_x, target_pos_y = self.buff_btn:getPosition()
    local move_act = cc.MoveTo:create(0.7, cc.p(target_pos_x, target_pos_y))
    local rotate_act = cc.RotateTo:create(0.4, -30)
    local scale_act = cc.ScaleTo:create(0.7, 0.2)
    local function call_back(  )
        self.move_buff_item:DeleteMe()
        self.move_buff_item = nil
    end
    self.move_buff_item:runAction(cc.Sequence:create(cc.Spawn:create(move_act, rotate_act, scale_act), cc.CallFunc:create(call_back)))
end

function PlanesafkMainWindow:updateOrderactionRed()
    if tolua.isnull(self.fight_btn) then
        return
    end
    if model:getOrderactionRedpoint() == true then
        addRedPointToNodeByStatus(self.fight_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.fight_btn, false, 5, 5)
    end

end

function PlanesafkMainWindow:close_callback(  )
    if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end

     if self.box_effect then
        self.box_effect:clearTracks()
        self.box_effect:removeFromParent()
        self.box_effect = nil
    end

    if self.door_item_load then
        for k,v in pairs(self.door_item_load) do
            v:clearTracks()
            v:removeFromParent()
        end
        self.door_item_load =nil
    end
    self:removeRoleInfo()

    if self.scrollview_list then
        self.scrollview_list:DeleteMe()
    end
    self.scrollview_list = nil

    MainuiController:getInstance():setIsShowMainUIBottom(true) -- 隐藏底部UI

    --由于查看地方英雄需要额外加成数据 这里做特殊显示.关闭的时候需要清空
    LookController:getInstance():clearAttrData()

    -- 日记要求
    controller:sender28626()
    model:setIsShowSearchFinish(false)
    controller:openPlanesafkMainWindow(false)
end

-- 子项
PlanesafkMainItem = class("PlanesafkMainItem", function()
    return ccui.Widget:create()
end)

function PlanesafkMainItem:ctor(width, height, parent)
    self.parent = parent
    self.item_list = {}
    self:configUI(width, height)
    self:register_event()
end

function PlanesafkMainItem:configUI(width, height)
    self.size = cc.size(width,height)
    -- self:setTouchEnabled(true)
    self:setContentSize(self.size)
end

function PlanesafkMainItem:register_event( )
end

function PlanesafkMainItem:setData(data, index)
    self.data = data
    -- self.team_name:setString(data.team_name)
    for i,v in pairs( self.item_list) do
        v:setVisible(false)
    end
    local x = self.size.width * 0.5 - PlanesafkConst.Grid_Width
    local y = (self.size.height - PlanesafkConst.Grid_Height) * 0.5
    if self.data.list then
        for k,v in pairs(self.data.list) do
            local i = v.index
            if self.item_list[i] == nil then
                self.item_list[i] = PlanesafkEvtItem.New(self)
            else
                self.item_list[i]:setVisible(true)
            end
            self.item_list[i].root_wnd:setPosition(x + (i - 1) * PlanesafkConst.Grid_Width * 0.5, y)
            self.item_list[i]:setData(v)
        end
    end
    self:setZOrder(1000 - index)
    
end

function PlanesafkMainItem:DeleteMe()
    if self.item_list then
        for i,item in ipairs(self.item_list) do
            item:DeleteMe()
        end
        self.item_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end


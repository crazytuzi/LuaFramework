-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: lwc(必填, 创建模块的人员)
-- @editor: lwc(必填, 后续维护以及修改的人员)
-- @description:
--      年兽活动主界面
-- <br/>2020年1月3日
-- --------------------------------------------------------------------
local _controller = ActionyearmonsterController:getInstance()
local _model = _controller:getModel()

local _string_format = string.format
local _table_insert = table.insert
local _table_remove = table.remove
local _table_sort = table.sort
local _math_abs = math.abs

ActionyearmonsterMainWindow = ActionyearmonsterMainWindow or BaseClass(BaseView)

function ActionyearmonsterMainWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.view_tag = ViewMgrTag.WIN_TAG
    self.layout_name = "actionyearmonster/actionyearmonster_main_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("actionyearmonster", "actionyearmonster"), type = ResourcesType.plist},
    }

    self:initConfig()
end

-- 初始化数据
function ActionyearmonsterMainWindow:initConfig(  )
    self.cur_role_grid_index = 0 -- 角色当前所在的格子
    self.is_role_moving = false  -- 角色是否正在行走中
    self.grid_object_list = {}   -- 格子列表(key为格子下标)
    self.par_grid_object_list = {} -- 格子列表(用于排序设置层级)
    self.evt_item_list = {}      -- 事件图标列表
    self.role_move_grid_cache = {} -- 角色待移动的格子坐标列表
    self.is_hide_top = false  -- 当前是否隐藏了顶部UI
    self.route_effect_list = {}  -- 路线特效列表
    self.break_effect_list = {}  -- 地块裂开特效列表
    self.touchFive = false

    --其他玩家数据
    self.other_role_data = {}
    --其他玩家列表
    self.other_role_list = {}
    -- 地图场景大小
    self.cur_map_width = PlanesConst.Map_Width
    self.cur_map_height = PlanesConst.Map_Height

    self.role_vo = RoleController:getInstance():getRoleVo()
    --贡品id
    self.holiday_nian_tribute_id = 80351
    local config  = Config.HolidayNianData.data_const.holiday_nian_tribute_id
    if config then
        self.holiday_nian_tribute_id = config.val
    end
end

function ActionyearmonsterMainWindow:open_callback( )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    -- 触摸层
    self.touch_slayer = self.root_wnd:getChildByName("touch_slayer")
    self.touch_slayer:setScale(display.getMaxScale())
    self.touch_slayer:setSwallowTouches(false)

    self.map_container = self.root_wnd:getChildByName("map_container")
    -- 地图格子层
    self.grid_slayer = self.map_container:getChildByName("grid_slayer")
    -- 事件和角色层
    self.evt_slayer = self.map_container:getChildByName("evt_slayer")

    -- ui层
    self.ui_container = self.root_wnd:getChildByName("ui_container")
    self.close_btn = self.ui_container:getChildByName("close_btn")

    self.figure_btn = self.ui_container:getChildByName("figure_btn")
    self.figure_btn:getChildByName("label"):setString(TI18N("更换形象"))

    self.face_btn = self.ui_container:getChildByName("face_btn")
    self.face_btn:getChildByName("label"):setString(TI18N("表情设置"))

    
    self.five_btn = self.ui_container:getChildByName("five_btn")
    self.five_btn_num = self.five_btn:getChildByName("num")
    self.five_btn:getChildByName("label"):setString(TI18N("点击燃放"))
    

    self.redbag_btn = self.ui_container:getChildByName("redbag_btn")
    self.redbag_btn_num = self.redbag_btn:getChildByName("num")
    self.redbag_btn:getChildByName("label"):setString(TI18N("点击前往"))
    -- local look_id = _model:getPlanesRoleLookId()
    -- if not look_id or look_id == 0 then
    --     setChildUnEnabled(true, self.figure_btn)
    -- else
    --     setChildUnEnabled(false, self.figure_btn)
    -- end
    self.btn_rule = self.ui_container:getChildByName("btn_rule")
    self.btn_hide = self.ui_container:getChildByName("btn_hide")

    self.bottom_panel = self.ui_container:getChildByName("bottom_panel")
    self.bag_btn = self.bottom_panel:getChildByName("bag_btn")
    self.hero_btn = self.bottom_panel:getChildByName("hero_btn")
    self.buff_btn = self.bottom_panel:getChildByName("buff_btn")

    local shadow_bg_1 = self.ui_container:getChildByName("shadow_bg_1")
    local shadow_bg_2 = self.ui_container:getChildByName("shadow_bg_2")


    self.top_title_bg = self.ui_container:getChildByName("top_title_bg")
    self.act_time = self.top_title_bg:getChildByName("act_time")
    self.floor_txt = self.top_title_bg:getChildByName("floor_txt")
    self.floor_txt:setString(TI18N("新年瑞兽"))
    local config = Config.HolidayNianData.data_const.start_time
    if config then
        self.act_time:setString(TI18N("活动时间:")..config.desc)
    else
        self.act_time:setVisible(false)
    end

    --进度条
    self.progress_container = self.ui_container:getChildByName("progress_container")
    self.progress = self.progress_container:getChildByName("progress")
    self.progress_size = self.progress:getContentSize()
    self.hp_value = self.progress_container:getChildByName("hp_value")
    self.tips = self.progress_container:getChildByName("tips")
    self.status_tips = self.progress_container:getChildByName("status_tips")
    self.progress_icon = self.progress_container:getChildByName("icon")

    local box_reward_list = Config.HolidayNianData.data_redbag_progress
    if box_reward_list and next(box_reward_list) ~= nil then
        self.box_list = {}
        -- _table_sort( box_reward_list, function(a, b) return a < b end )
        local max_num = box_reward_list[#box_reward_list]
        self.max_num = max_num
        local len = self.progress_size.width/ max_num
        for i,num in ipairs(box_reward_list) do
            if i >= #box_reward_list then break end
            local box_item = {}
            local x = len * num + 80 
            box_item.sprite = createSprite(PathTool.getResFrame("actionyearmonster","actionyearmonster_20"), x, 24, self.progress_container, cc.p(0.5,0.5))
            box_item.lable = createLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.c4b(0x9f,0x30,0x1b,0xff), x, 52, num, self.progress_container, 2, cc.p(0.5,0.5))
            box_item.per = num * 100/max_num
            box_item.is_show_redbag = false
            self.box_list[i] = box_item
        end
    end

    --浮标
    self.buoy_1 = self.ui_container:getChildByName("buoy_1")
    self.buoy_1:setVisible(false)
    self.buoy_1_img = self.buoy_1:getChildByName("img") 
    self.buoy_2 = self.ui_container:getChildByName("buoy_2")
    self.buoy_2:setVisible(false)
    self.buoy_2_img = self.buoy_2:getChildByName("img") 

    self.five_effect_container = self.ui_container:getChildByName("five_effect_container")
    self.five_effect_container:setVisible(false)
    
    --适配
    local container_size = self.ui_container:getContentSize()
    local top_y = display.getTop(self.ui_container)
    local bottom_y = display.getBottom(self.ui_container)

    local _settopPos = function(obj)
        if tolua.isnull(obj) then return end
        local tab_y = obj:getPositionY()
        obj:setPositionY(top_y - (container_size.height - tab_y))
    end

    local _setbottomPos = function(obj)
        if tolua.isnull(obj) then return end
        local close_btn_y = obj:getPositionY()
        obj:setPositionY(bottom_y + close_btn_y)
    end 

    _settopPos(shadow_bg_2)
    _settopPos(self.top_title_bg)
    _settopPos(self.five_btn)
    _settopPos(self.redbag_btn)
    self.left_btn_pos_y = {}
    self.left_btn_pos_y[1] = self.five_btn:getPositionY()
    self.left_btn_pos_y[2] = self.redbag_btn:getPositionY()

    _settopPos(self.btn_rule)
    _settopPos(self.btn_hide)
    _settopPos(self.progress_container)

    _setbottomPos(shadow_bg_1)
    _setbottomPos(self.bottom_panel)
    _setbottomPos(self.figure_btn)
    _setbottomPos(self.face_btn)
    _setbottomPos(self.close_btn)

     --浮标做在线上
    self.buoy_line = {}

    self.center_pos_x = 360
    self.center_pos_y = 640
    self.center_r = 50 --浮标的半径

    local x1 = 0 + self.center_r
    local x2 = 720 - self.center_r
    local y1 = self.bottom_panel:getPositionY() + 212 + self.center_r
    local y2 = self.progress_container:getPositionY() - 67 - self.center_r

    self.y2 = y2 
    self.x1 = x1

    self.box_x1 = x1 - self.center_r
    self.box_x2 = x2 + self.center_r
    self.box_y1 = y1 - self.center_r
    self.box_y2 = y2 + self.center_r

    _table_insert(self.buoy_line, {pos_1 = cc.p(x1, y1), pos_2 = cc.p(x2 - 110, y1)})
    _table_insert(self.buoy_line, {pos_1 = cc.p(x1, y1), pos_2 = cc.p(x1, y2)})
    _table_insert(self.buoy_line, {pos_1 = cc.p(x1, y2), pos_2 = cc.p(x2, y2)})
    _table_insert(self.buoy_line, {pos_1 = cc.p(x2, y1 + 130), pos_2 = cc.p(x2, y2)})
    
    --右下角
    _table_insert(self.buoy_line, {pos_1 = cc.p(x2-110, y1), pos_2 = cc.p(x2-110, y1 + 130)})
    _table_insert(self.buoy_line, {pos_1 = cc.p(x2-110, y1 + 130), pos_2 = cc.p(x2, y1 + 130)})

    self:checkBuoyMoveTimer(true)
    MainuiController:getInstance():setIsShowMainUIBottom(false) -- 隐藏底部UI
end

function ActionyearmonsterMainWindow:register_event( )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.bag_btn, handler(self, self.onClickBagBtn), true)
    registerButtonEventListener(self.hero_btn, handler(self, self.onClickHeroBtn), true)
    registerButtonEventListener(self.buff_btn, handler(self, self.onClickBuffBtn), true)
    
    registerButtonEventListener(self.btn_hide, handler(self, self.onClickHideBtn), true)
    registerButtonEventListener(self.btn_rule, handler(self, self.onClickRuleBtn), true)

    registerButtonEventListener(self.figure_btn, handler(self, self.onClickFigureBtn), true)
    registerButtonEventListener(self.face_btn, handler(self, self.onClickFaceBtn), true)
    registerButtonEventListener(self.five_btn, handler(self, self.onClickFiveBtn), true)
    registerButtonEventListener(self.redbag_btn, handler(self, self.onClickRedbagBtn), true)

    -- 移动场景
    self.touch_slayer:addTouchEventListener(function ( sender, event_type )
        if not self.init_tile_end then return end

        if self.is_role_moving then
            self.stop_center_flag = true -- 移动过程中点击了则停止镜头跟随
        end
        if event_type == ccui.TouchEventType.began then
            self.touch_began_pos = sender:getTouchBeganPosition()
            self.last_pos = self.touch_began_pos  
        elseif event_type == ccui.TouchEventType.moved then
            local touch_move_pos = sender:getTouchMovePosition()
            if self.last_pos then
                local offset_x = touch_move_pos.x - self.last_pos.x
                local offset_y = touch_move_pos.y - self.last_pos.y
                self.last_pos = touch_move_pos
                self:onTouchMoveMap(offset_x, offset_y)
            end
        elseif event_type == ccui.TouchEventType.ended then
            local touch_end = sender:getTouchEndPosition()
            if self.touch_began_pos and touch_end and (_math_abs(touch_end.x - self.touch_began_pos.x) <= 20 and _math_abs(touch_end.y - self.touch_began_pos.y) <= 20) then 
                if self.is_role_moving then -- 移动过程中点击了，则走到下一个格子时停止移动
                    self.target_grid_index = nil -- 清掉待触发的事件格子
                    self.role_move_grid_cache = {} -- 清掉待行走的格子
                else
                    local grid_pos = self.grid_slayer:convertToNodeSpace(touch_end)
                    local grid_x, grid_y = PlanesTile.toTile(grid_pos.x, grid_pos.y)
                    local grid_index = PlanesTile.tileIndex(grid_x, grid_y)
                    self:onClickGridIconByIndex(grid_index)
                end
            end 
        end
    end)

    -- 地图层的数据
    self:addGlobalEvent(ActionyearmonsterEvent.YEAR_MONSTER_BASE_INFO, function ( data )
        self:setBaseData(data)
        self:updateRedBagCount()
        local cell_data = _model:getCellData()
        if cell_data ~= nil and not self.init_cell_data then
            self.init_cell_data = true
            self:setData(cell_data)
        end
    end)
    -- 地图层的数据
    self:addGlobalEvent(ActionyearmonsterEvent.YEAR_MONSTER_CEIL_INFO, function ( data )
        local base_data = _model:getBaseData()
        if base_data ~= nil and not self.init_cell_data then
            self.init_cell_data = true
            self:setBaseData(base_data)
            self:updateRedBagCount()
            self:setData(data)
        end
    end)


    -- -- 更新部分格子数据
    self:addGlobalEvent(ActionyearmonsterEvent.YEAR_UPDATE_GRID_EVENT, function ( data )
        if data then
            self:updateSomeGridData(data)
        end
    end)

    -- 新增事件显示
    self:addGlobalEvent(ActionyearmonsterEvent.YEAR_Add_Evt_Data_Event, function ( evt_vo_list )
        if self.init_evt_end and evt_vo_list then
            self:addEvtItemList(evt_vo_list)
        end
    end)

    -- 移动角色进入某一格子
    self:addGlobalEvent(ActionyearmonsterEvent.Year_Update_Role_Grid_Event, function ( data )
        if data then
            if data.code == 0 then -- 进入格子失败（正常情况下不会发生）
                self:doRoleStopMove()
            end
        end
    end)



    -- -- buff进背包的动画
    -- self:addGlobalEvent(PlanesEvent.Chose_Buff_Event, function ( buff_id, world_pos )
    --     self:showBuffItemMoveAni(buff_id, world_pos)
    -- end)

    -- -- 格子裂开特效
    -- self:addGlobalEvent(PlanesEvent.Show_Break_Effect_Event, function ( index_list )
    --     self:showBreakEffect(index_list)
    -- end)

    -- 更换形象
    self:addGlobalEvent(HomeworldEvent.Update_My_Home_Figure_Event, function (  )
        local look_id = HomeworldController:getInstance():getModel():getMyCurHomeFigureId()
        self:createRole(look_id)
    end)

    -- 播放烟花
    self:addGlobalEvent(ActionyearmonsterEvent.Year_Five_Effect_Event, function ( data )
        if data and data.code == 1 then
            self:showFiveEffect(true, data)
            self:setOtherRoleFace()
        else
            self.touchFive = false
        end
    end)
    -- 发送表情
    self:addGlobalEvent(ActionyearmonsterEvent.Year_Send_Face_Event, function ( data )
        if self.map_role then
            self:updateRoleFace(self.map_role, data)
            self:setOtherRoleFace(self.cur_role_grid_index)
        end
    end)
    
    -- 其他角色数据
    self:addGlobalEvent(ActionyearmonsterEvent.Year_Other_Role_Event, function ( data )
        if not data then return end
        self.other_role_data = data.player
        self:createOtherTimer()
    end)

    -- 自己的称号
    self:addGlobalEvent(RoleEvent.GetTitleList, function ( data )
        if not data then return end
        self.use_title_id = data.base_id
        if self.map_role then
            self:updateHonorInfo(self.map_role, self.use_title_id)
        end
    end)
    

    --背包信息
    -- self:addGlobalEvent(ActionyearmonsterEvent.Year_Iint_Bag_Data_Event, function(data)
    --     self:checkLeftShowInfo()
    -- end)

    -- self:addGlobalEvent(ActionyearmonsterEvent.Year_Update_Bag_Data_Event, function(data, is_add)
    --     self:checkLeftShowInfo()
    -- end)

    -- self:addGlobalEvent(ActionyearmonsterEvent.Year_Delete_Bag_Data_Event, function(data)
    --     self:checkLeftShowInfo()
    -- end)

    if self.role_assets_event == nil then
        if self.role_vo then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS,function(key ,value) 
                self:checkLeftShowInfo()
                self:updateSubmitRedInfo()
            end)
        end
    end   
end

-- 移动地图场景
function ActionyearmonsterMainWindow:onTouchMoveMap( offset_x, offset_y )
    if not self.map_container then return end

    local pos_x, pos_y = self.map_container:getPosition()
    local new_pos_x = pos_x + offset_x
    local new_pos_y = pos_y + offset_y
    new_pos_x, new_pos_y = self:checkMapSafePos(new_pos_x, new_pos_y)
    self.map_container:setPosition(cc.p(new_pos_x, new_pos_y))
end

-- 检测棋盘的坐标是否超出边界
function ActionyearmonsterMainWindow:checkMapSafePos( pos_x, pos_y )
    if pos_x > self.map_max_pos_x then
        pos_x = self.map_max_pos_x
    elseif pos_x < self.map_min_pos_x then
        pos_x = self.map_min_pos_x
    end
    if pos_y > self.map_max_pos_y then
        pos_y = self.map_max_pos_y
    elseif pos_y < self.map_min_pos_y then
        pos_y = self.map_min_pos_y
    end
    return pos_x, pos_y
end

function ActionyearmonsterMainWindow:onClickCloseBtn(  )
    _controller:openActionyearmonsterMainWindow(false)
end

--第一个 新春福袋
function ActionyearmonsterMainWindow:onClickBagBtn(  )
    _controller:openActionyearmonsterBagPanel(true)
end

--第二个 集字兑换
function ActionyearmonsterMainWindow:onClickHeroBtn(  )
    _controller:openActionyearmonsterExchangeWindow(true)
end

-- 第三个 提交贡品
function ActionyearmonsterMainWindow:onClickBuffBtn(  )
    if not self.base_data then return end
    _controller:openActionyearmonsterSubmitPanel(true, {base_data = self.base_data})
end

-- 表情设置
function ActionyearmonsterMainWindow:onClickFaceBtn(  )
    ElitematchController:getInstance():openElitematchDeclarationPanel(true,ElitematchConst.MsgType.eYearMonster)
end

-- 烟花
function ActionyearmonsterMainWindow:onClickFiveBtn(  )
    if self.touchFive == true then
        message(TI18N("烟花燃放中..."))
        return
    end
    self.touchFive = true
    _controller:sender28221()
end
-- 红包
function ActionyearmonsterMainWindow:onClickRedbagBtn(  )
    if self.redbag_list and next(self.redbag_list) ~= nil then
        local list = {}
        for i,v in ipairs(self.redbag_list) do
            local start_grid_x, start_grid_y = PlanesTile.indexTile(self.cur_role_grid_index) 
            local start_pos = cc.p(start_grid_x, start_grid_y)
            local end_grid_x, end_grid_y = PlanesTile.indexTile(v.index) 
            local end_pos = cc.p(end_grid_x, end_grid_y)
            local astar_result = PlanesTile.astar(start_pos, end_pos, self.cur_block_cfg)        
            if astar_result then
                _table_insert(list, v.index)
            end
        end
        if next(list) ~= nil then
            local len = #list
            local index = math.random(1,len)
            if list[index] then
                self:onClickGridIconByIndex(list[index])
            end
        else
            message(TI18N("前往路径上有障碍噢~"))
        end
    end
end

-- 隐藏上栏
function ActionyearmonsterMainWindow:onClickHideBtn(  )
    self.is_hide_top = not self.is_hide_top
    MainuiController:getInstance():setMainUIShowStatus(not self.is_hide_top)
    MainuiController:getInstance():setIsShowMainUIBottom(false)
    self.top_title_bg:setVisible(not self.is_hide_top)
    self.btn_rule:setVisible(not self.is_hide_top)
    self.btn_hide:setVisible(not self.is_hide_top)
    self.close_btn:setVisible(not self.is_hide_top)
    self.bottom_panel:setVisible(not self.is_hide_top)
    self.progress_container:setVisible(not self.is_hide_top)
    self.five_btn:setVisible(not self.is_hide_top)
    self.redbag_btn:setVisible(not self.is_hide_top)
    self.figure_btn:setVisible(not self.is_hide_top)
    self.face_btn:setVisible(not self.is_hide_top)
    if not self.is_hide_top then
        self:checkLeftShowInfo()
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



function ActionyearmonsterMainWindow:onClickRuleBtn( param, sender, event_type )
    local rule_cfg = Config.HolidayNianData.data_const["holiday_nian_desc"]
    if rule_cfg then
        TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
    end
end

function ActionyearmonsterMainWindow:onClickFigureBtn(  )
    if self.is_role_moving then
        message(TI18N("角色移动中, 无法更换形象"))
        return
    end
    local look_id = _model:getPlanesRoleLookId()
    if not look_id or look_id == 0 then
        local limit_cfg = Config.HomeData.data_const["open_lev"]
        local open_lv = 70
        if limit_cfg then
            open_lv = limit_cfg.val or 70
        end
        message(_string_format(TI18N("%s级开启家园系统，开启后才可更换Q版冒险形象哦~"), open_lv))
    else
        HomeworldController:getInstance():openHomeworldFigureWindow(true)
    end
end

function ActionyearmonsterMainWindow:updateSubmitRedInfo()
    if not self.base_data then return end
    if not self.role_vo then return end
    local count = self.role_vo:getActionAssetsNumByBid(self.holiday_nian_tribute_id)
    if self.base_data.val < self.base_data.max_val and count > 0  then
        addRedPointToNodeByStatus(self.buff_btn, true, 0, -15)
    else
        addRedPointToNodeByStatus(self.buff_btn, false, 0, -20)
    end
end

function ActionyearmonsterMainWindow:openRootWnd( setting )
    setting = setting or {}
    self.cur_dun_id = 1
    self.cur_floor = 1

    _controller:sender28200()
    _controller:sender28222()

    --获取称号
    RoleController:getInstance():sender23300()
end

function ActionyearmonsterMainWindow:checkLeftShowInfo()
    if not self.role_vo then return end
    local count = self.role_vo:getActionAssetsNumByBid(80352) 
    local index = 1
    if count > 0 then
        self.five_btn:setVisible(true)
        self.five_btn_num:setString("x"..count)
        index = index + 1
    else
        self.five_btn:setVisible(false)     
    end

    --红包逻辑
    if self.redbag_list and next(self.redbag_list) ~= nil then
        self.redbag_btn:setPositionY(self.left_btn_pos_y[index])
        self.redbag_btn:setVisible(true)
        self.redbag_btn_num:setString("x"..#self.redbag_list)
        index = index + 1
    else
        self.redbag_btn:setVisible(false)
    end

    --左上角适配
    if index == 1 then
        -- 两个都没
        self.buoy_line[7] = nil
        self.buoy_line[8] = nil
        if self.buoy_line[2] then
            self.buoy_line[2].pos_2.y = self.y2
        end
        if self.buoy_line[3] then
            self.buoy_line[3].pos_1.x = self.x1
        end
    elseif index == 2 then 
        --一个
        local effset_x = 100
        local effset_y = 120
        if self.buoy_line[2] then
            self.buoy_line[2].pos_2.y = self.y2 - effset_y
        end
        if self.buoy_line[3] then
            self.buoy_line[3].pos_1.x = self.x1 + effset_x
        end
        self.buoy_line[7] = {pos_1 = cc.p(self.x1, self.y2 - effset_y), pos_2 = cc.p(self.x1 + effset_x, self.y2 - effset_y)}
        self.buoy_line[8] = {pos_1 = cc.p(self.x1+effset_x, self.y2 - effset_y), pos_2 = cc.p(self.x1 + effset_x, self.y2)}
    else
        --两个
        local effset_x = 100
        local effset_y = 220
        if self.buoy_line[2] then
            self.buoy_line[2].pos_2.y = self.y2 - effset_y
        end
        if self.buoy_line[3] then
            self.buoy_line[3].pos_1.x = self.x1 + effset_x
        end
        self.buoy_line[7] = {pos_1 = cc.p(self.x1, self.y2 - effset_y), pos_2 = cc.p(self.x1 + effset_x, self.y2 - effset_y)}
        self.buoy_line[8] = {pos_1 = cc.p(self.x1 + effset_x, self.y2 - effset_y), pos_2 = cc.p(self.x1 + effset_x, self.y2)}
    end
end

function ActionyearmonsterMainWindow:setVisible( bool )
    self.is_visible = bool
    if self.root_wnd == nil or tolua.isnull(self.root_wnd) then return end
    self.root_wnd:setVisible(bool)
    if bool == true then
        MainuiController:getInstance():setIsShowMainUIBottom(false) -- 隐藏底部UI
    else
        MainuiController:getInstance():setIsShowMainUIBottom(true) -- 隐藏底部UI
    end
end

function ActionyearmonsterMainWindow:updateRedBagCount()
    if not self.base_data  then return end
    for k,v in pairs(self.evt_item_list) do
        if v.evt_cfg and v.evt_cfg.id == ActionyearmonsterConstants.evt_redbag then
            --红包事件
            v:updateRedbagCount()
        end
    end
end

function ActionyearmonsterMainWindow:setBaseData( data)
    if not data then return end
    if not self.progress then return end

    self.base_data = data
    local per =  data.val * 100/data.max_val
    self.progress:setPercent(per)
    if self.is_init_per == nil then
        self.is_init_per = true
        for i,v in ipairs(self.box_list) do
            local num = math.floor(data.max_val * v.per/100)
            v.lable:setString(num)    
            if per >= v.per then
                v.is_show_redbag = true
            else
                v.lable:disableEffect(cc.LabelEffect.OUTLINE)
                setChildUnEnabled(true, v.lable)    
                setChildUnEnabled(true, v.sprite)    
            end
        end    
    else
        for i,v in ipairs(self.box_list) do
            local num = math.floor(data.max_val * v.per/100)
            v.lable:setString(num) 
            if per >= v.per and not v.is_show_redbag  then
                self:showRedBagEffect()
                v.is_show_redbag = true
                v.lable:disableEffect(cc.LabelEffect.OUTLINE)
                v.lable:enableOutline(cc.c4b(0x9f,0x30,0x1b,0xff), 2)
                setChildUnEnabled(false, v.lable)    
                setChildUnEnabled(false, v.sprite)
            end
        end    
    end
    
    if self.record_val == nil then
        self.record_val = self.base_data.val
    else
        local temp_val = self.base_data.val - self.record_val
        if temp_val > 0 then
            self:crateLabelEffect(temp_val)
        end
        self.record_val = self.base_data.val
    end

    self.hp_value:setString(_string_format("%s/%s", data.val, data.max_val))
    if data.flag == 1 then
        self.tips:setString(TI18N("限时年兽已苏醒，前往挑战获取丰厚奖励！"))
        self.tips:setTextColor(cc.c4b(0xff, 0xef, 0xed, 0xff))
        self.tips:enableOutline(cc.c4b(0x4F, 0x01, 0x01, 0xff), 2)

        local time = data.end_time - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        
        setChildUnEnabled(false, self.progress_icon)
        self.status_tips:setPositionY(-26)
        self.status_tips:setTextColor(cc.c4b(0xff, 0x48, 0x30, 0xff))
        -- self.status_tips:enableOutline(cc.c4b(0x00, 0x00, 0x00, 0x00), 2)
        commonCountDownTime(self.status_tips, time, {callback = function(time) self:setTimeFormatString(time) end})

    else
        self.tips:setString(TI18N("全服收集祭品, 召唤限时年兽和红包雨"))
        self.tips:setTextColor(cc.c4b(0xff, 0xf2, 0xc7, 0xff))
        self.tips:enableOutline(cc.c4b(0x00, 0x00, 0x00, 0xff), 2)
        self.status_tips:setString(TI18N("未召唤"))
        self.status_tips:setPosition(584, 28)
        self.status_tips:setTextColor(cc.c4b(0xff, 0xf2, 0xc7, 0xff))
        -- self.status_tips:enableOutline(cc.c4b(0x00, 0x00, 0x00, 0x00), 2)
        doStopAllActions(self.status_tips)
        setChildUnEnabled(true, self.progress_icon)
    end
    self:updateSubmitRedInfo()
end

function ActionyearmonsterMainWindow:crateLabelEffect(num)
    if self.label_list == nil then
        self.label_list = {}
    end
    local label = nil
    if #self.label_list > 0 then
        label = _table_remove(self.label_list)
        label:setVisible(true)
        label:setString("+"..num)
    else
        label = createLabel(50, cc.c4b(0xff,0xcf,0x3c,0xff),cc.c4b(0xb0,0x35,0x0a,0xff),0, 0,"+"..num ,self.progress_container,2, cc.p(0.5,0.5), "fonts/title.ttf")
    end
    if label then
        label:setPosition(450, 0)
        label:setOpacity(0)
        local action1 = cc.FadeIn:create(0.2)
        local delay = cc.DelayTime:create(0.5)
        local action2 = cc.FadeOut:create(0.5)
        local sequence = cc.Sequence:create(action1,delay,action2, cc.CallFunc:create(function()
            label:setVisible(false)
            _table_insert(self.label_list, label)
        end))

        local moveto = cc.EaseSineOut:create(cc.MoveTo:create(0.8, cc.p(450, 40)))
        local spawn = cc.Spawn:create(moveto,sequence)

        label:runAction(spawn)
    end
end

function ActionyearmonsterMainWindow:setTimeFormatString(time)
    if time > 0 then 
        local str = _string_format(TI18N("%s后消失"),TimeTool.GetTimeForFunction(time))
        self.status_tips:setString(str)
    else
        self.status_tips:setString(TI18N("即将消失"))
    end
end

function ActionyearmonsterMainWindow:setData( data )
    if not data then return end
    self:playCloudEffect(true)

    local map_id = data.map_id
    self:initMapTileConfig(map_id)

    self.cur_role_grid_index = data.index -- 当前角色所在格子
    self.cur_grid_data = {} -- 格子数据
    self.redbag_list = {}
    for _,g_data in pairs(data.tile_list or {}) do -- 以格子下标为key来存储
        self.cur_grid_data[g_data.index] = g_data
        --红包事件
        if g_data.evtid == ActionyearmonsterConstants.evt_redbag then
            _table_insert(self.redbag_list, g_data)
        end
    end
    local all_evt_data = _model:getYearEvtVoList() -- 所有事件数据

    -- 当前层名称
    -- local cur_dun_id = PlanesController:getInstance():getModel():getCurDunId()
    -- local max_floor_num = Config.SecretDunData.data_max_dun_num[self.cur_floor]
    -- local dun_info = Config.SecretDunData.data_dun_info[cur_dun_id]
    -- if dun_info and max_floor_num then
    --     self.floor_txt:setString(TI18N(_string_format("%s 第%d/%d层", dun_info.name, self.cur_floor, max_floor_num)))
    -- end
    -- 创建地图背景
    self:updateMapBg()
    -- 创建地板
    self.init_grid_end = false
    self:updateGridList(self.cur_grid_data, true) 
    -- 创建事件
    self.init_evt_end = false
    self:updateEvtList(all_evt_data)
    -- 创建角色
    self:createRole()
    -- 角色移动到屏幕中间
    self:moveMapToRoleCenter()
    -- 播放背景音乐
    self:playBackgroundMusic()

    self:checkLeftShowInfo()
end

function ActionyearmonsterMainWindow:playBackgroundMusic(  )
    AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, "s_002", true)
end

-- 初始化地图格子数据
function ActionyearmonsterMainWindow:initMapTileConfig( map_id )
    if not map_id then return end
    self.cur_block_cfg = Config.MapBlock.data(map_id) or {} -- 当前地图的地编数据
    local map_cfg = Config.Map[map_id]
    if map_cfg then
        self.cur_map_width = map_cfg.width
        self.cur_map_height = map_cfg.height
    end
    -- 地图的最大、最小坐标
    self.map_min_pos_x = SCREEN_WIDTH - self.cur_map_width
    self.map_max_pos_x = 0
    self.map_min_pos_y = display.height - self.cur_map_height
    self.map_max_pos_y = 0

    PlanesTile.init(PlanesConst.Grid_Width*0.5, PlanesConst.Grid_Height*0.5, self.cur_map_width, self.cur_map_height, PlanesTile.year_monster_type)
    self.init_tile_end = true -- 初始化地图数据完成才可以进行一些操作
end

-- 更新地图背景
function ActionyearmonsterMainWindow:updateMapBg(  )
    if self.cur_map_res_id == true then return end
    self.cur_map_res_id = true
    local map_res_path = "resource/planes/map_bg/map_bg_100001.jpg"
    self.bg_img_load = loadImageTextureFromCDN(self.background, map_res_path, ResourcesType.single, self.bg_img_load)
end

-- 创建地板
function ActionyearmonsterMainWindow:updateGridList( grid_data_list, is_init )
    if not grid_data_list or next(grid_data_list) == nil then return end

    -- 先加载所有格子资源
    if self.grid_icon_load then
        self.grid_icon_load:DeleteMe()
        self.grid_icon_load = nil
    end
    local grid_res_list = {}
    local temp_res_list = {} -- 用于判断资源是否已经存在
    for k,v in pairs(grid_data_list) do
        if not temp_res_list[v.res_id] and v.res_id ~= 0 then
            local grid_res = self:getGridPathByResId(v.res_id)
            _table_insert(grid_res_list, {path = grid_res, type = ResourcesType.single})
            temp_res_list[v.res_id] = true
        end
    end
    self.grid_icon_load = ResourcesLoad.New()
    self.grid_icon_load:addAllList(grid_res_list, function (  )
        if is_init then -- 第一次创建格子时
            for _,grid_object in pairs(self.grid_object_list) do
                if grid_object.grid_icon then
                    grid_object.grid_icon:setVisible(false)
                    if grid_object.grid_data then
                        grid_object.grid_data.is_hide = 0
                    end
                end
            end
            local delay_index = 0
            local temp_index = 0
            for i,g_data in pairs(grid_data_list) do
                delay_index = delay_index + 1
                delayRun(self.grid_slayer, (delay_index/5) / display.DEFAULT_FPS, function (  )
                    self:createOneGridObject(g_data)
                    temp_index = temp_index + 1
                    if temp_index == tableLen(grid_data_list) then -- 格子初始化完成
                        self.init_grid_end = true
                    end
                end)
            end
        else
            for i,g_data in pairs(grid_data_list) do
                self:createOneGridObject(g_data)
            end
        end
    end)
end

-- 创建或刷新一个格子
function ActionyearmonsterMainWindow:createOneGridObject( g_data, is_hide )
    local index = g_data.index
    --结构 
    local object = self.grid_object_list[index] or {}
    local grid_icon = object.grid_icon
    if not grid_icon then
        grid_icon = createImage(self.grid_slayer, nil, 0, 0, cc.p(0.5, 0.5), false)
        grid_icon:ignoreContentAdaptWithSize(true)

        -- test 
        -- object.text_txt = createLabel(18, 2, nil,PlanesConst.Grid_Width*0.5, PlanesConst.Grid_Height*0.5, "", self.evt_slayer, nil, cc.p(0.5, 0.5))
        -- object.text_txt:setLocalZOrder(9999)

        object.grid_icon = grid_icon
        self.grid_object_list[index] = object
    _table_insert(self.par_grid_object_list, object)
    end
    if grid_icon then
        if g_data.is_hide == 1 then -- 后端告知要隐藏
            grid_icon:setVisible(false)
        else
            local grid_res = self:getGridPathByResId(g_data.res_id)
            if not object.grid_data or grid_icon.grid_res ~= grid_res then
                grid_icon.grid_res = grid_res
                grid_icon:loadTexture(grid_res, LOADTEXT_TYPE)
                local grid_size = grid_icon:getContentSize()
                grid_icon:setAnchorPoint(cc.p(0.5, 1-(PlanesConst.Grid_Height*0.5/grid_size.height)))
            end
            grid_icon:setVisible(not is_hide)
            local pos_x, pos_y = PlanesTile.indexPixel(g_data.index)
            object.pos_x = pos_x
            object.pos_y = pos_y
            grid_icon:setPosition(pos_x, pos_y)
            -- 设置层级，y越小层级越高，x越大层级越高
            local grid_x, grid_y = PlanesTile.indexTile(index)
            grid_icon:setLocalZOrder((100-grid_y)*100 + grid_x)

            -- test 
            -- object.text_txt:setPosition(pos_x, pos_y)
            -- object.text_txt:setString(_string_format("%s,evt:%s", g_data.is_walk, g_data.index))
        end
    end
    self.cur_grid_data[index] = g_data
    object.grid_data = g_data
end

-- 显示地板格子入场动画
function ActionyearmonsterMainWindow:showGridEnterAniByIndex( index_list )
    local cur_grid_x, cur_grid_y = PlanesTile.indexTile(self.cur_role_grid_index)
    for _,index in pairs(index_list) do
        local object = self.grid_object_list[index]
        if object and object.grid_icon and object.grid_data then
            object.grid_icon:setVisible(true)
            object.grid_icon:setOpacity(0)

            local grid_x, grid_y = PlanesTile.indexTile(index)
            local pos_x, pos_y = PlanesTile.indexPixel(index)
            local fade_in = cc.FadeIn:create(0.4)
            local move_to = cc.EaseBackOut:create(cc.MoveTo:create(0.4, cc.p(pos_x, pos_y)))

            local distance = PlanesTile.tileDistance(grid_x, grid_y, cur_grid_x, cur_grid_y)
            local random_val = math.random(5, 10)/10
            local delay_time = distance/4*random_val
            local delay_act = cc.DelayTime:create(delay_time)
            object.grid_icon:setPositionY(pos_y-200)
            object.grid_icon:runAction(cc.Sequence:create(delay_act, cc.Spawn:create(fade_in, move_to)))

            -- 事件
            if object.grid_data and object.grid_data.evtid > 0 then
                local evt_item = self.evt_item_list[index]
                if evt_item then
                    evt_item:showEvtEnterAni(delay_time)
                end
            end
        end
    end
end

-- 更新部分地板数据
function ActionyearmonsterMainWindow:updateSomeGridData( grid_data_list )
    if grid_data_list and next(grid_data_list) ~= nil and self.init_grid_end then -- 格子初始化完成才能更新
        for k,g_data in pairs(grid_data_list) do
            self.cur_grid_data[g_data.index] = g_data
        end
        self:updateGridList(grid_data_list)


        self.redbag_list = {}
        for _,g_data in pairs(self.cur_grid_data) do -- 以格子下标为key来存储
            --红包事件
            if g_data.evtid == ActionyearmonsterConstants.evt_redbag then
                _table_insert(self.redbag_list, g_data)
            end
        end
        self:checkLeftShowInfo()
    end
end

-- 检测周围需要显示的格子
function ActionyearmonsterMainWindow:checkShowRoundGrid( grid_index )
    if not grid_index then return end

    local grid_x, grid_y = PlanesTile.indexTile(grid_index)
    local add_grid_list = PlanesTile.tileRange(grid_x, grid_y, PlanesConst.Grid_Round, PlanesConst.Grid_Round)

    local show_ani_index_list = {}
    for k,v in pairs(add_grid_list) do
        if v[1] and v[2] then
            local grid_index = PlanesTile.tileIndex(v[1], v[2])
            local g_data = self.cur_grid_data[grid_index]
            local old_object = self.grid_object_list[grid_index]
            if g_data and g_data.is_hide == 0 and (not old_object or (old_object.grid_data and old_object.grid_data.is_hide == 1)) then
                -- 格子
                self:createOneGridObject(g_data, true)
                _table_insert(show_ani_index_list, grid_index)
                -- 事件
                local evt_vo = PlanesController:getInstance():getModel():getPlanesEvtVoByGridIndex(grid_index)
                self:createOneEvtItem(evt_vo, true)
            end
        end
    end
    if next(show_ani_index_list) ~= nil then
        self:showGridEnterAniByIndex(show_ani_index_list)
    end
end

-- 获取格子图标资源
function ActionyearmonsterMainWindow:getGridPathByResId(res_id)
    if res_id and res_id ~= "" and res_id ~= 0 then
        return _string_format("resource/planes/grid_icon/%s.png", res_id)
    end
end

-- 创建事件列表
function ActionyearmonsterMainWindow:updateEvtList( evt_vo_list )
    if not evt_vo_list or next(evt_vo_list) == nil then return end

    -- 先加载所有事件资源
    if self.evt_icon_load then
        self.evt_icon_load:DeleteMe()
        self.evt_icon_load = nil
    end
    local evt_res_list = self:getEvtResPathListByData(evt_vo_list)
    self.evt_icon_load = ResourcesLoad.New()
    self.evt_icon_load:addAllList(evt_res_list, function (  )
        for _,item in pairs(self.evt_item_list) do
            item:setVisible(false)
        end
        local index = 0
        local temp_index = 0
        for k,vo in pairs(evt_vo_list) do
            index = index + 1
            delayRun(self.evt_slayer, (index/5) / display.DEFAULT_FPS, function ( )
                self:createOneEvtItem(vo)
                temp_index = temp_index + 1
                if temp_index == tableLen(evt_vo_list) then -- 格子初始化完成
                    self.init_evt_end = true
                end
            end)
        end
    end)
end

-- 创建或更新一个事件item
function ActionyearmonsterMainWindow:createOneEvtItem( evt_vo, is_hide )
    if not evt_vo then return end
    local index = evt_vo.index
    local evt_item = self.evt_item_list[index]
    if not evt_item then
        evt_item = ActionyearmonsterEvtItem.New(self.evt_slayer)
        self.evt_item_list[index] = evt_item
    end
    evt_item:setData(evt_vo, is_hide)
    -- 格子
    local pos_x, pos_y = PlanesTile.indexPixel(index)
    evt_item:setPosition(pos_x, pos_y)
    -- 层级
    local grid_x, grid_y = PlanesTile.indexTile(index)
    evt_item:setLocalZOrder((100-grid_y)*100 + grid_x)
end

-- 获取事件的资源路径列表
function ActionyearmonsterMainWindow:getEvtResPathListByData( evt_vo_list )
    local evt_res_list = {}
    local temp_res_list = {} -- 用于判断资源是否已经存在
    for k,vo in pairs(evt_vo_list) do
        local res_cfg
        res_cfg = vo.config.res_1
        -- if vo.status == PlanesConst.Evt_State.Doing then -- 未完成
        --     res_cfg = vo.config.res_1
        -- else
        --     res_cfg = vo.config.res_2
        -- end
        if res_cfg and res_cfg[1] and res_cfg[1] == 1 then
            if not temp_res_list[res_cfg[2]] then
                local evt_res = self:getEvtPathByResId(res_cfg[2])
                _table_insert(evt_res_list, {path = evt_res, type = ResourcesType.single})
                temp_res_list[res_cfg[2]] = true
            end
        end
    end
    return evt_res_list
end

-- 新增事件
function ActionyearmonsterMainWindow:addEvtItemList( evt_vo_list )
    if not evt_vo_list or next(evt_vo_list) == nil then return end

    -- 先加载所有事件资源
    if self.evt_icon_load then
        self.evt_icon_load:DeleteMe()
        self.evt_icon_load = nil
    end
    local evt_res_list = self:getEvtResPathListByData(evt_vo_list)
    self.evt_icon_load = ResourcesLoad.New()
    self.evt_icon_load:addAllList(evt_res_list, function (  )
        for k,vo in pairs(evt_vo_list) do
            local evt_item = self.evt_item_list[vo.index]
            if not evt_item then
                evt_item = ActionyearmonsterEvtItem.New(self.evt_slayer)
                self.evt_item_list[vo.index] = evt_item
            end
            evt_item:setData(vo)
            -- 格子
            local pos_x, pos_y = PlanesTile.indexPixel(vo.index)
            evt_item:setPosition(pos_x, pos_y)
            -- 层级
            local grid_x, grid_y = PlanesTile.indexTile(vo.index)
            evt_item:setLocalZOrder((100-grid_y)*100 + grid_x)
        end
    end)
end

-- 获取事件图标资源
function ActionyearmonsterMainWindow:getEvtPathByResId( res_id )
    if res_id and res_id ~= "" then
        return _string_format("resource/planes/evt_icon/%s.png", res_id)
    end
end

-- 创建角色
function ActionyearmonsterMainWindow:createRole( look_id )
    look_id = look_id or _model:getPlanesRoleLookId()
    if not self.cur_look_id or self.cur_look_id ~= look_id then
        self.cur_look_id = look_id
        self:removeMapRole()
        self.map_role = self:createRoleById(look_id, nil, self.use_title_id,self.role_vo.name, true)
    end
    local pos_x, pos_y = PlanesTile.indexPixel(self.cur_role_grid_index)
    self.map_role:setPosition(pos_x, pos_y)
    self:updateRoleZOrder()
end

--启动创建其他玩家的定时器
function ActionyearmonsterMainWindow:createOtherTimer()
    if self.other_timer == nil then
        self.other_timer = GlobalTimeTicket:getInstance():add(function()
            local num = 0
            for k,v in pairs(self.other_role_list) do
                num = num +1
            end
            if num < #self.other_role_data then
                self:refreshOtherData()
            else

            end
        end, 5)
    end
end

--设置其他玩家表情
function ActionyearmonsterMainWindow:setOtherRoleFace(index)
    if index then
        local x0 , y0 = PlanesTile.indexTile(index)
        local list = self:getSudokuIndex(x0, y0)
        for k,v in pairs(self.other_role_list) do
            if v.data and self:isSudokuIndex(v.index, list) then
                for _,fd in ipairs(v.data.face) do
                    if fd.order == 2 then
                        self:updateRoleFace(v, fd.face_id)
                    end
                end
            end
        end
    else
        for k,v in pairs(self.other_role_list) do
            if v.data then
                for _,fd in ipairs(v.data.face) do
                    if fd.order == 3 then
                        self:updateRoleFace(v, fd.face_id)
                    end
                end
            end
        end
    end
end

function ActionyearmonsterMainWindow:checkOtherLookInfo()
    if not self.cur_role_grid_index then return end
    --移动中 不用检测
    if self.is_role_moving then
        return
    end
    local x0 , y0 = PlanesTile.indexTile(self.cur_role_grid_index)
    local list = self:getSudokuIndex(x0, y0)
    local dic_role = {}
    for k,v in pairs(self.other_role_list) do
        if v.data and self:isSudokuIndex(v.index, list) then
            dic_role[v.key] = true
            self:updateRoleLook(v, true)
        end
    end

    for _,v in pairs(self.other_role_list) do
        if not dic_role[v.key] then
            self:updateRoleLook(v, false)
        end
    end
end

function ActionyearmonsterMainWindow:isSudokuIndex(index, list)
    if not list then return true end
    local x , y = PlanesTile.indexTile(index)
    for i,v in ipairs(list) do
        if v.x == x and v.y == y then
            return true
        end
    end
    return false
end

--获取九宫格外的8个位置 5x5
--@is_sudoku 是否只需要九宫格位置
function ActionyearmonsterMainWindow:getSudokuIndex(x0, y0, is_sudoku)
    local list = {}
    --3x3内
    list[1] = {x = x0, y = y0-2} -- -1,-1
    list[2] = {x = x0 + y0 % 2, y = y0 - 1}
    list[3] = {x = x0 + 1, y = y0}
    list[4] = {x = x0 - 1 + y0 % 2, y = y0-1} -- -1 ,0
    list[5] = {x = x0 + y0 % 2, y = y0 + 1} -- 1, 0
    list[6] = {x = x0 - 1, y = y0}
    list[7] = {x = x0 - 1 + y0 % 2, y = y0 + 1}
    list[8] = {x = x0, y = y0 + 2}
    
    if is_sudoku then
        return list
    end

    --5x5 外
    list[9]  = {x = x0, y = y0 - 4} -- -2,2
    list[10] = {x = x0 + y0 % 2, y = y0 - 3}
    list[11] = {x = x0 + 1, y = y0 - 2}
    list[12] = {x = x0 + 1 + y0 % 2, y = y0 - 1}
    list[13] = {x = x0 + 2, y = y0} -- 2 -2

    list[14] = {x = x0 + 1 + y0 % 2, y = y0 + 1} -- 2 -1
    list[15] = {x = x0 + 1, y = y0 + 2} -- 2 0
    list[16] = {x = x0 + y0 % 2, y = y0 + 3} -- 2 1
    list[17] = {x = x0, y = y0 + 4} -- 2 2

    list[18] = {x = x0 - 1 + y0 % 2, y = y0 + 3} -- 1 2
    list[19] = {x = x0 - 1, y = y0 + 2} -- 0 2
    list[20] = {x = x0 - 2 + y0 % 2, y = y0 + 1} -- -1 2
    list[21] = {x = x0 - 2, y = y0} -- -2 2

    list[22] = {x = x0 - 2 + y0 % 2, y = y0 - 1} -- -2 1
    list[23] = {x = x0 - 1, y = y0 - 2} -- -2 0
    list[24] = {x = x0 - 1 + y0 % 2, y = y0 - 3} -- -2 -1


    return list
end

--刷新其他玩家数据
function ActionyearmonsterMainWindow:refreshOtherData()
    if not self.init_grid_end then return end
    if not self.other_role_data then return end
    if self.dic_pos_idnex == nil then
        self.dic_pos_idnex = {}
    end
    local count = 0
    local is_have = false
    for i,v in ipairs(self.other_role_data) do
        local row = math.random(1, 6)
        local col = math.random(1, 6)
        local index = self.cur_role_grid_index + (row - 3) * 1000 + (col - 3)
        if self:checkGridCanWalk(index) then
            local  key = _string_format("%s_%s", v.srv_id, v.rid)
            if self.other_role_list[key] == nil and self.dic_pos_idnex[index] == nil then
                self.other_role_list[key] =  self:createRoleById(v.look_id, index, v.honor_id, v.name)
                self.other_role_list[key].key = key
                self.other_role_list[key].data = v
                self.other_role_list[key].index = index
                self.dic_pos_idnex[index] = true
                local grid_x, grid_y = PlanesTile.indexTile(index)
                self.other_role_list[key]:setLocalZOrder((100-grid_y)*100 + grid_x + 1)
                is_have = true
                count = count + 1
                if count > 3 then --每次出现3个
                    return
                end
            end
        end
    end

    if is_have then
        self:checkOtherLookInfo()
    end
end

--检查格子是否能走人
function ActionyearmonsterMainWindow:checkGridCanWalk(index)
    if not self.init_grid_end then return false end
    local grid_object = self.grid_object_list[index]
    if not grid_object then return false end
    if not _model:checkIsHaveEvtByGridIndex(index) and grid_object.grid_data.is_walk == 0 then
        return false
    end

    if not _model:checkEvtCanWalkByGridIndex(index, true) then
        return false
    end
    if _model:checkIsHaveEvtByGridIndex(index) then
        return false
    end

    if _model:checkYearmonsterGrid(index) then
        return false
    end

    return true
end

function ActionyearmonsterMainWindow:createRoleById(look_id, index ,use_id, name, is_me)
    local figure_cfg = Config.HomeData.data_figure[look_id]
    local effect_id = "H60001"
    if figure_cfg then
        effect_id = figure_cfg.look_id
    end

    local new_role = ccui.Widget:create()

    new_role.role = createEffectSpine( effect_id, cc.p(0, 0), cc.p(0.5, 0), true, PlayerAction.idle )
    new_role:addChild(new_role.role)

    new_role.role:setScale(0.4)
    new_role.role:setTimeScale(2)
    self.evt_slayer:addChild(new_role)
    if index then
        local pos_x, pos_y = PlanesTile.indexPixel(index)
        new_role:setPosition(pos_x, pos_y)
    end

    if use_id then
        self:updateHonorInfo(new_role, use_id)
    end
    if name then
        local res = PathTool.getResFrame("common","common_90056")
        local sprite = createSprite(res, 0, -19, new_role, cc.p(0.5,0.5))
        sprite:setScale(0.5)
        new_role.name = createLabel(18, 1, nil, 0, -28, name, new_role, nil, cc.p(0.5, 0))
        if is_me then
            new_role.name:setTextColor(cc.c4b(0xff, 0xdb, 0x4c, 0xff))
            local res = PathTool.getResFrame("common","common_1099")
            local sprite = createSprite(res, 0, 130, new_role, cc.p(0.5,0.5))
            sprite:setScaleY(-1.5)

            local move_by_1 = cc.MoveTo:create(1, cc.p(0, 150))
            local move_by_2 = cc.MoveTo:create(0.8, cc.p(0, 130))

            sprite:runAction(cc.RepeatForever:create(cc.Sequence:create(move_by_1,move_by_2)))
        end
    end

    return new_role
end

function ActionyearmonsterMainWindow:updateHonorInfo(new_role, use_id)
    if not new_role then return end

    local vo = Config.HonorData.data_title[use_id]
    if vo and vo.res_id then 
        if new_role.record_honor_img == nil or new_role.record_honor_img ~= vo.res_id then
            new_role.record_honor_img = vo.res_id
            local res = PathTool.getPlistImgForDownLoad("honor","txt_cn_honor_"..vo.res_id,false,false)
            if new_role.honor_img == nil then
                new_role.honor_img = createSprite(nil, 0, 112, new_role, cc.p(0.5,0.5))
                new_role.honor_img:setScale(0.8)
                -- new_role.honor_img:setZOrder(2)
            end
            new_role.item_load_title = loadSpriteTextureFromCDN(new_role.honor_img, res, ResourcesType.single, new_role.item_load_title)
        end
    end
end

function ActionyearmonsterMainWindow:updateRoleFace(new_role, id)
    if not new_role then return end
    local config = Config.ArenaEliteData.data_face[id] 
    if config then
        if new_role.face_bg == nil then
            local y = 120
            new_role.face_bg = createImage(new_role, PathTool.getResFrame("actionyearmonster","txt_cn_actionyearmonster_23"), 0, y, cc.p(0.5, 0.5), true, nil, true)
            new_role.face_bg:setCapInsets(cc.rect(17, 18, 1, 4))
            new_role.face_bg:setContentSize(cc.size(143, 65))
            new_role.face_bg:setCascadeOpacityEnabled(true)
            new_role.face_spine = createEffectSpine(config.msg, cc.p(29, 39), cc.p(0.5, 0.5), false, PlayerAction.action)
            new_role.face_spine:setScale(0.5)
            new_role.face_bg:addChild(new_role.face_spine)

            local text = config.text or TI18N("恭喜发财")
            new_role.face_text = createLabel(20, cc.c4b(0x64,0x32,0x23,0xff),nil, 90, 37, text, new_role.face_bg, nil, cc.p(0.5,0.5))

            if new_role.honor_img ~= nil then
                new_role.honor_img:runAction(cc.FadeOut:create(0.3))
            end

            if new_role.look_img ~= nil and new_role.look_img:isVisible() then
                new_role.look_img:runAction(cc.FadeOut:create(0.3))
            end

            new_role.face_bg:setOpacity(0)

            local action1 = cc.FadeIn:create(0.5)
            local delay = cc.DelayTime:create(2)
            local action2 = cc.FadeOut:create(0.7)
            new_role.face_bg:runAction(cc.Sequence:create(action1,delay,action2, cc.CallFunc:create(function()
                new_role.face_spine:clearTracks()
                new_role.face_spine:removeFromParent()
                new_role.face_spine = nil

                new_role.face_bg:stopAllActions()
                new_role.face_bg:removeFromParent()
                new_role.face_bg = nil

                if new_role.honor_img ~= nil then
                    new_role.honor_img:runAction(cc.FadeIn:create(0.3))
                end

                if new_role.look_img ~= nil and new_role.look_img:isVisible() then
                    new_role.look_img:runAction(cc.FadeIn:create(0.3))
                end
            end)))
        end
    end
end

--更新角色查看
function ActionyearmonsterMainWindow:updateRoleLook(new_role, status)
    if status then
        if new_role.look_img == nil then
            local y = 152 
            new_role.look_img = createSprite(PathTool.getResFrame("actionyearmonster","actionyearmonster_17"), 0, y, new_role, cc.p(0.5,0.5))
            new_role.look_img:setCascadeOpacityEnabled(true)
            new_role.look_btn = ccui.Layout:create()
            new_role.look_btn:setCascadeOpacityEnabled(true)
            local size = cc.size(50,50)
            new_role.look_btn:setContentSize(size)
            new_role.look_btn:setTouchEnabled(true)
            new_role.look_btn:setSwallowTouches(true)
            new_role.look_btn:setPosition(4, 12)
            new_role.look_img:addChild(new_role.look_btn)

            local _img = createSprite(PathTool.getResFrame("common","common_1093"), size.width * 0.5, size.height * 0.5, new_role.look_btn, cc.p(0.5,0.5))
            registerButtonEventListener(new_role.look_btn, function()
                self:onLookPlayerInfo(new_role)
            end, true, 2)
        else
            -- 如果已经显示了就无视了
            if  new_role.look_img:isVisible() then
                return
            end
            new_role.look_img:setVisible(true)
        end
        new_role.look_img:setOpacity(0)
        new_role.look_img:runAction(cc.FadeIn:create(0.3))
    else
        if new_role.look_img then
            if not new_role.look_img:isVisible() then
                return
            end
            new_role.look_img:runAction(cc.Sequence:create(cc.FadeOut:create(0.3), cc.CallFunc:create(function()
                new_role.look_img:setVisible(false)
            end )))
        end
    end
end

function ActionyearmonsterMainWindow:onLookPlayerInfo(new_role)
    if new_role.data and new_role.data.rid and new_role.data.srv_id and  new_role.data.srv_id ~= "" and new_role.data.rid ~= "" then
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = new_role.data.srv_id, rid = new_role.data.rid})
    end
end


-- 更新角色的层级
function ActionyearmonsterMainWindow:updateRoleZOrder(  )
    if not self.cur_role_grid_index then return end

    local grid_x, grid_y = PlanesTile.indexTile(self.cur_role_grid_index)
    self.map_role:setLocalZOrder((100-grid_y)*100 + grid_x + 1)
end

-- 移除角色形象
function ActionyearmonsterMainWindow:removeMapRole(  )
    if self.map_role then
        self.map_role.role:clearTracks()
        if self.map_role.face_spine then
            self.map_role.face_spine:clearTracks()
            self.map_role.face_spine:removeFromParent()
            self.map_role.face_spine = nil
        end
        if self.map_role.item_load_title then
            self.map_role.item_load_title:DeleteMe()
            self.map_role.item_load_title = nil
        end
        self.map_role.role:removeFromParent()
        self.map_role:removeFromParent()
        self.map_role = nil
    end
end

--获取年兽旁边最好的格子
function ActionyearmonsterMainWindow:getYearMosterBestIndex(index)
    local start_grid_x, start_grid_y = PlanesTile.indexTile(self.cur_role_grid_index) 
    local start_pos = cc.p(start_grid_x, start_grid_y)

    local end_grid_x, end_grid_y = PlanesTile.indexTile(index) 
    local list = self:getSudokuIndex(end_grid_x, end_grid_y, true)

    local end_astar_result = false
    for i,v in ipairs(list) do
        local astar_result = PlanesTile.astar(start_pos, v, self.cur_block_cfg)
        if astar_result ~= nil and astar_result ~= false then
            if not end_astar_result then
                end_astar_result = astar_result
            elseif  end_astar_result.n > astar_result.n then
                end_astar_result = astar_result
            end
        end
    end
    return end_astar_result
end

-- 点击格子
function ActionyearmonsterMainWindow:onClickGridIconByIndex( index)
    local grid_object = self.grid_object_list[index]
    if not grid_object then return end

    if grid_object.grid_icon then
        if index ~= 9020 and index ~= 8019 and index ~= 9018 and index ~= 9019 and
          index ~= 14012 and index ~= 13011 and index ~= 14010 and index ~= 14011 then
            local pos_x = grid_object.pos_x or 0
            local pos_y = grid_object.pos_y or 0
            grid_object.grid_icon:stopAllActions()
            grid_object.grid_icon:setPosition(pos_x, pos_y)
            local move_by_1 = cc.EaseBackOut:create(cc.MoveTo:create(0.1, cc.p(pos_x, pos_y + 20)))
            local move_by_2 = cc.EaseBackOut:create(cc.MoveTo:create(0.1, cc.p(pos_x, pos_y)))
            local act_1 = cc.Spawn:create(move_by_1, cc.ScaleTo:create(0.1, 1.2))
            local act_2 = cc.Spawn:create(move_by_2, cc.ScaleTo:create(0.1, 0.9))
            grid_object.grid_icon:runAction(cc.Sequence:create(act_1, act_2, (cc.ScaleTo:create(0.05, 1.0))))
            local evt_item = self.evt_item_list[index]
            if evt_item then
                evt_item:showClickAni()
            end
        end
        playButtonSound2()
    end

    -- 格子初始化完成才能点击
    if not self.init_grid_end then return end
    -- 点击当前所在的格子
    if self.cur_role_grid_index == index then return end
    -- 不可行走的或隐藏的格子
    if not grid_object.grid_data or grid_object.grid_data.is_hide == 1 then return end
    -- 格子没有事件、且配置了不可行走
    if not _model:checkIsHaveEvtByGridIndex(index) and grid_object.grid_data.is_walk == 0 then
        message(TI18N("目标点为不可行走区域，请选择其他目标点"))
        return
    end

    local astar_result = nil
    --判断是不是年兽主格子 如果是转换成旁边副格子位置
    if not self.is_role_moving then
        --主年兽位置格子
        local year_list = _model:getYearMonsterList()
        if _model:checkLimitYearmonsterGrid(index) and year_list[1] then
            astar_result = self:getYearMosterBestIndex(year_list[1].index)
            local evt_item = self.evt_item_list[year_list[1].index]
            if evt_item then
                evt_item:showClickAni()
            end
        elseif _model:checkGoldYearmonsterGrid(index) and year_list[2] then
            astar_result = self:getYearMosterBestIndex(year_list[2].index)
            local evt_item = self.evt_item_list[year_list[2].index]
            if evt_item then
                evt_item:showClickAni()
            end
        end
    end
    -- if _model:checkYearmonsterCentreGrid(index) and not self.is_role_moving then
    --     astar_result = self:getYearMosterBestIndex(index)
        
    --     -- if self.cur_role_grid_index > index then
    --     --     index = index + 1000
    --     -- elseif self.cur_role_grid_index < index then
    --     --     index = index - 1
    --     -- end
    -- end
    -- 根据事件状态判断事件不可行走，则不给点击
    if not _model:checkEvtCanWalkByGridIndex(index, true) then
        message(TI18N("目标点为不可行走区域，请选择其他目标点"))
        return
    end

    -- 移动过程中点击了一个格子，则角色继续移动到下一个目标格子后，停止动作
    if self.is_role_moving then
        self.target_grid_index = nil -- 清掉待触发的事件格子
        self.role_move_grid_cache = {} -- 清掉待行走的格子
        return
    end
    if astar_result == nil then
        local start_grid_x, start_grid_y = PlanesTile.indexTile(self.cur_role_grid_index) 
        local start_pos = cc.p(start_grid_x, start_grid_y)
        local end_grid_x, end_grid_y = PlanesTile.indexTile(index) 
        local end_pos = cc.p(end_grid_x, end_grid_y)
        astar_result = PlanesTile.astar(start_pos, end_pos, self.cur_block_cfg)
    end
    if not astar_result then
        message(TI18N("前往路径上有障碍噢~"))
        return
    end
    self.role_move_grid_cache = {} -- 缓存待行走的格子列表
    while astar_result do
        local x = astar_result.x
        local y = astar_result.y
        local grid_index = PlanesTile.tileIndex(x, y)
        if grid_index ~= self.cur_role_grid_index then -- 当前所在的格子不用缓存
            _table_insert(self.role_move_grid_cache, 1, grid_index) -- A星计算出来的路线是终点排在第一位，于是这里逆序缓存
        end
        astar_result = astar_result.parent
    end

    -- 点击的格子有事件、且事件未完成，则需要走到事件前一格停下来（出生点除外，出生点一直是未完成）
    if _model:checkIsNeedStopPreGrid(index) then
        -- 这里缓存待触发的事件格子
        self.target_grid_index = _table_remove(self.role_move_grid_cache, #self.role_move_grid_cache)
    end

    -- 目标点特效
    if next(self.role_move_grid_cache) ~= nil then
        local target_index = self.role_move_grid_cache[#self.role_move_grid_cache]
        if target_index then
            local target_pos_x, target_pos_y = PlanesTile.indexPixel(target_index)
            self:handlerTargetEffect(true, target_pos_x, target_pos_y)
        end
    end
    self.stop_center_flag = false
    self:showMoveRoute()
    self:doNextRoleMove()
end

-- 创建路线特效显示
function ActionyearmonsterMainWindow:showMoveRoute(  )
    if not self.role_move_grid_cache or next(self.role_move_grid_cache) == nil then return end
    local route_info = {}
    for i,grid_index in ipairs(self.role_move_grid_cache) do
        local info = {}
        info.dir = 1
        local pos_x, pos_y = PlanesTile.indexPixel(grid_index)
        local next_grid_index = self.role_move_grid_cache[i+1]
        if next_grid_index then
            local next_pos_x, next_pos_y = PlanesTile.indexPixel(next_grid_index)
            if pos_x < next_pos_x and pos_y < next_pos_y then -- 右上
                info.dir = 1
            elseif pos_x < next_pos_x and pos_y > next_pos_y then --右下
                info.dir = 2
            elseif pos_x > next_pos_x and pos_y > next_pos_y then --左下
                info.dir = 3
            elseif pos_x > next_pos_x and pos_y < next_pos_y then --左上
                info.dir = 4
            end
            info.pos_x = pos_x
            info.pos_y = pos_y
            info.grid_index = grid_index
            _table_insert(route_info, info)
        end
    end
    for k, object in pairs(self.route_effect_list) do
        if object.effect then
            object.effect:setVisible(false)
        end
    end
    for i, r_data in ipairs(route_info) do
        local object = self.route_effect_list[i]
        if not object or next(object) == nil then
            object = {}
            object.effect = createEffectSpine(Config.EffectData.data_effect_info[1505], cc.p(r_data.pos_x, r_data.pos_y), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.evt_slayer:addChild(object.effect, 999)
            self.route_effect_list[i] = object
        else
            object.effect:setToSetupPose()
            object.effect:setPosition(r_data.pos_x, r_data.pos_y)
            object.effect:setAnimation(0, PlayerAction.action, true)
        end
        object.effect:setVisible(true)
        object.effect:setScale(1)
        if r_data.dir == 1 then
            object.effect:setScale(-1)
        elseif r_data.dir == 2 then
            object.effect:setScaleX(-1)
        elseif r_data.dir == 3 then
            object.effect:setScale(1)
        elseif r_data.dir == 4 then
            object.effect:setScaleY(-1)
        end
        object.grid_index = r_data.grid_index
    end
end

function ActionyearmonsterMainWindow:handlerTargetEffect(status, pos_x, pos_y)
    if status == true then
        if not tolua.isnull(self.evt_slayer) and self.target_effect == nil then
            self.target_effect = createEffectSpine(Config.EffectData.data_effect_info[1504], cc.p(pos_x, pos_y), cc.p(0.5, 0.5), true, PlayerAction.action_2)
            self.evt_slayer:addChild(self.target_effect, 99999)
        elseif self.target_effect then
            self.target_effect:setToSetupPose()
            self.target_effect:setPosition(pos_x, pos_y)
            self.target_effect:setAnimation(0, PlayerAction.action_2, true)
        end
    else
        if self.target_effect then
            self.target_effect:clearTracks()
            self.target_effect:removeFromParent()
            self.target_effect = nil
        end
    end
end

-- 显示地块裂开特效
function ActionyearmonsterMainWindow:showBreakEffect( data_list )
    if not data_list or next(data_list) == nil then return end

    for k,index in pairs(data_list) do
        -- 隐藏事件图标和格子
        local evt_item = self.evt_item_list[index]
        if evt_item then
            evt_item:setVisible(false)
        end
        local object = self.grid_object_list[index]
        if object and object.grid_icon then
            object.grid_icon:setVisible(false)
        end
        
        -- 播放裂开特效
        local break_effect = self.break_effect_list[k]
        if not break_effect then
            break_effect = createEffectSpine(Config.EffectData.data_effect_info[1705], cc.p(0, 0), cc.p(0.5, 0.75), false, PlayerAction.action, handler(self, self.onBreakAniEnd))
            self.grid_slayer:addChild(break_effect)
            self.break_effect_list[k] = break_effect
        else
            break_effect:setVisible(true)
            break_effect:setToSetupPose()
            break_effect:setAnimation(0, PlayerAction.action, false)
        end
        local pos_x, pos_y = PlanesTile.indexPixel(index)
        break_effect:setPosition(pos_x, pos_y)
        -- 设置层级，y越小层级越高，x越大层级越高
        local grid_x, grid_y = PlanesTile.indexTile(index)
        break_effect:setLocalZOrder((100-grid_y)*100 + grid_x)
    end
end

function ActionyearmonsterMainWindow:onBreakAniEnd(  )
    for k,break_effect in pairs(self.break_effect_list) do
        break_effect:setVisible(false)
    end
end

-- 锁屏
function ActionyearmonsterMainWindow:isLockPlanesMapScreen( flag )
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

-- 一格一格去移动角色
function ActionyearmonsterMainWindow:doNextRoleMove(  )
    local move_grid_index = _table_remove(self.role_move_grid_cache, 1)
    if not move_grid_index then -- 移动到最后一格了
        self:doRoleStopMove()
        return
    end

    if not self.stop_center_flag then
        self:moveMapToRoleCenter() -- 角色移动到屏幕中间
    end
    _controller:sender28202(move_grid_index) -- 通知服务端到达某一格子
    self:moveRoleByGrid(move_grid_index)
end

-- 移动角色
function ActionyearmonsterMainWindow:moveRoleByGrid( grid_index )
    if not self.map_role then return end

    local move_grid_x, move_grid_y = PlanesTile.indexTile(grid_index)

    self.cur_role_grid_index = grid_index
    self.is_role_moving = true

    self:openMapMoveTimer(false)
    
    local cur_pos_x, cur_pos_y = self.map_role:getPosition()
    local new_pos_x, new_pos_y = PlanesTile.indexPixel(grid_index)
    -- 记录一下角色移动的目标格子坐标
    self.move_target_pos_x = new_pos_x
    self.move_target_pos_y = new_pos_y

    -- 角色转向
    if new_pos_x > cur_pos_x then
        self.map_role.role:setScaleX(0.4)
    else
        self.map_role.role:setScaleX(-0.4)
    end

    -- 路线动态隐藏
    for k, object in pairs(self.route_effect_list) do
        if object.grid_index == grid_index then
            if object.effect then
                object.effect:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function (  )
                    object.effect:setVisible(false)
                end)))
            end
            break
        end
    end

    -- 角色移动
    local distance = math.sqrt(math.pow(new_pos_x-cur_pos_x, 2)+math.pow(new_pos_y-cur_pos_y, 2))
    local time = distance/ActionyearmonsterConstants.Move_Speed
    if not self.cur_role_action or self.cur_role_action ~= PlayerAction.move then
        self.cur_role_action = PlayerAction.move
        self.map_role.role:setToSetupPose()
        self.map_role.role:setAnimation(0, PlayerAction.move, true)
    end
    self.map_role:runAction(cc.Sequence:create(cc.MoveTo:create(time, cc.p(new_pos_x, new_pos_y)), cc.CallFunc:create(function (  )
        self:doNextRoleMove()
        -- self:checkShowRoundGrid(self.cur_role_grid_index)
    end)))
    self:updateRoleZOrder() -- 更新角色层级

    -- 地图移动
    if not self.stop_center_flag then
        local map_cur_pos_x, map_cur_pos_y = self.map_container:getPosition()
        local map_new_pos_x = map_cur_pos_x - (new_pos_x - cur_pos_x)
        local map_new_pos_y = map_cur_pos_y - (new_pos_y - cur_pos_y)

        self.map_move_state = self:checkMapIsCanMove()
        if self.map_move_state ~= 0 then -- 棋盘可以移动
            map_new_pos_x, map_new_pos_y = self:checkMapSafePos( map_new_pos_x, map_new_pos_y )
            if self.map_move_state == 1 then -- y轴不能移动
                map_new_pos_y = map_cur_pos_y
                self:openMapMoveTimer(true)
            elseif self.map_move_state == 2 then -- x轴不能移动
                map_new_pos_x = map_cur_pos_x
                self:openMapMoveTimer(true)
            end
            local map_dis = math.sqrt(math.pow(map_new_pos_x-map_cur_pos_x, 2)+math.pow(map_new_pos_y-map_cur_pos_y, 2))
            local map_time = map_dis/ActionyearmonsterConstants.Move_Speed
            self.map_container:runAction(cc.MoveTo:create(map_time, cc.p(map_new_pos_x, map_new_pos_y)))
        end

        -- 只要棋盘不是可以完全自由移动，就需要实时判断
        if self.map_move_state ~= 3 then
            self:openMapMoveTimer(true)
        end
    end
end

-- 移动地图使得角色居中
function ActionyearmonsterMainWindow:moveMapToRoleCenter(  )
    local map_pos_x, map_pos_y = self:getMapPosOfRoleCenter()
    self.map_container:runAction(cc.MoveTo:create(0.3, cc.p(map_pos_x, map_pos_y)))
end

-- 获取角色居中时地图的坐标
function ActionyearmonsterMainWindow:getMapPosOfRoleCenter(  )
    local pos_x = 0
    local pos_y = 0
    if self.map_role then
        local role_pos_x, role_pos_y = self.map_role:getPosition()
        if role_pos_x <= SCREEN_WIDTH*0.5 then
            pos_x = 0
        else
            pos_x = SCREEN_WIDTH*0.5 - role_pos_x
        end
        if role_pos_y <= display.height*0.5 then
            pos_y = 0
        else
            pos_y = display.height*0.5 - role_pos_y
        end
    end
    return self:checkMapSafePos(pos_x, pos_y)
end

-- 地图是否可以移动 0：不能移动 1：x轴可以移动 2：y轴可以移动 3：可以随意移动
function ActionyearmonsterMainWindow:checkMapIsCanMove(  )
    local move_state = 0
    if not self.map_role then return move_state end

    local cur_pos_x, cur_pos_y = self.map_role:getPosition()

    if cur_pos_x >= SCREEN_WIDTH*0.5 and cur_pos_x <= (self.cur_map_width-SCREEN_WIDTH*0.5)then
        move_state = 1
    end
    if cur_pos_y >= display.height*0.5 and cur_pos_y <= (self.cur_map_height-display.height*0.5) then
        if move_state > 0 then
            move_state = 3
        else
            move_state = 2
        end
    end
    return move_state
end

-- 检测地图移动的定时器
function ActionyearmonsterMainWindow:openMapMoveTimer( status )
    if status == true then
        if not self.map_move_timer then
            self.map_move_timer = GlobalTimeTicket:getInstance():add(function()
                local map_move_state = self:checkMapIsCanMove()
                if map_move_state ~= self.map_move_state then
                    self.map_move_state = map_move_state
                    if self.move_target_pos_x and self.move_target_pos_y then
                        local cur_pos_x, cur_pos_y = self.map_role:getPosition()

                        local map_cur_pos_x, map_cur_pos_y = self.map_container:getPosition()
                        local map_new_pos_x = map_cur_pos_x - (self.move_target_pos_x - cur_pos_x)
                        local map_new_pos_y = map_cur_pos_y - (self.move_target_pos_y - cur_pos_y)
                        -- 棋盘移动
                        map_new_pos_x, map_new_pos_y = self:checkMapSafePos( map_new_pos_x, map_new_pos_y )
                        if map_move_state == 1 then
                            map_new_pos_y = map_cur_pos_y
                        elseif map_move_state == 2 then
                            map_new_pos_x = map_cur_pos_x
                        end
                        local map_dis = math.sqrt(math.pow(map_new_pos_x-map_cur_pos_x, 2)+math.pow(map_new_pos_y-map_cur_pos_y, 2))
                        local map_time = map_dis/ActionyearmonsterConstants.Move_Speed
                        self.map_container:runAction(cc.MoveTo:create(map_time, cc.p(map_new_pos_x, map_new_pos_y)))
                    end
                end
            end, 0.1)
        end
    else
        if self.map_move_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.map_move_timer)
            self.map_move_timer = nil
        end
    end
end


--检查浮标移动
function ActionyearmonsterMainWindow:checkBuoyMoveTimer(status)
    if status then
        self.buoy_map_x, self.buoy_map_y = self.map_container:getPosition()
        local list = _model:getYearMonsterList()
        if list[1] then
            self.buoy_1:setVisible(true)
        end
        if list[2] then
            self.buoy_2:setVisible(true)    
        end
        
        if not self.buoy_move_timer then
            self.buoy_move_timer = GlobalTimeTicket:getInstance():add(function()
                if not tolua.isnull(self.map_container) then
                    local pos_x, pos_y = self.map_container:getPosition()
                    if _math_abs(self.buoy_map_x - pos_x) > 2 or _math_abs(self.buoy_map_y - pos_y) > 2 then
                        --说明需要检测移动了
                        self.buoy_map_x = pos_x
                        self.buoy_map_y = pos_y
                        local list = _model:getYearMonsterList()
                        if list[1] then --限时年兽
                            self:updateBuoyByIndex(list[1].index, self.buoy_1, self.buoy_1_img)
                        end
                        if list[2] then --金年兽
                            self:updateBuoyByIndex(list[2].index, self.buoy_2, self.buoy_2_img)
                        end
                    end  
                end
                
            end, 0.02)
        end
    else 
        if self.buoy_move_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.buoy_move_timer)
            self.buoy_move_timer = nil
        end
    end
end

function ActionyearmonsterMainWindow:updateBuoyByIndex(index, buoy, buoy_img)
    if not buoy then return end
    local x, y = PlanesTile.indexPixel(index)
    local ui_x = x + self.buoy_map_x 
    local ui_y = y + self.buoy_map_y
    if self:checkBoxPos(ui_x, ui_y) then
        buoy:setVisible(false)
    else
        buoy:setVisible(true)
        for i,line in ipairs(self.buoy_line) do
            local x0, y0 = self:getPosByPos12(line.pos_1.x, line.pos_1.y, line.pos_2.x, line.pos_2.y, self.center_pos_x, self.center_pos_y, ui_x, ui_y)    
            if x0 and y0 then
                local du = -math.deg(math.atan((ui_y - self.center_pos_y)/(ui_x - self.center_pos_x)))
                buoy:setPosition(x0, y0)

                if ui_x > self.center_pos_x then
                    buoy:setRotation(du)
                    buoy_img:setRotation(-du)
                else
                    buoy:setRotation(du + 180)
                    buoy_img:setRotation(-(du + 180))
                end
                break
            end
        end
    end
end

--获取相交位置根据 位置 1 位置 2(网上度娘来的)
function ActionyearmonsterMainWindow:getPosByPos12(x1, y1, x2, y2, x3, y3, x4, y4)
    local b1 = (y2-y1)*x1 + (x1-x2)*y1
    local b2 = (y4-y3)*x3 + (x3-x4)*y3
    local d = (x2-x1)*(y4-y3) - (x4-x3)*(y2-y1)
    local d1 = b2*(x2-x1) - b1*(x4-x3)
    local d2 = b2*(y2-y1) - b1*(y4-y3)
    --x0 y0就是相交点
    local x0 = d1/d 
    local y0 = d2/d

    --保证 x1 小于 x2
    if x1 > x2 then
        local temp = x1
        x1 = x2
        x2 = temp
    end
    --保证 y1 小于 y2
    if y1 > y2 then
        local temp = y1
        y1 = y2
        y2 = temp
    end

    if x0 >= x1 and x0 <= x2  and y0 >= y1 and y0 <= y2 then
        if x1 == x2 then 
            --说明线段竖的
            if y3 > y4 and y0 < y3 then
                --说明 在上方
                return x0, y0        
            elseif y3 < y4 and y0 > y3 then
                --说明 在下方
                return x0, y0        
            end
        elseif y1 == y2 then
            --说明线段横的
            if x3 > x4 and x0 < x3 then
                --说明在 左边
                return x0 , y0 
            elseif x3 < x4 and x0 > x3 then
                --说明在 右边
                return x0 , y0
            end
        end
    end
end


--检查是否在显示范围内才显示不在就不显示
function ActionyearmonsterMainWindow:checkBoxPos(x, y)
    if  x >= self.box_x1 and x <= self.box_x2 and y >= self.box_y1 and y <= self.box_y2 then
        return true
    end
    return false
end

-- 角色停止移动
function ActionyearmonsterMainWindow:doRoleStopMove(  )
    self:openMapMoveTimer(false)
    self:handlerTargetEffect(false)
    self.map_role:stopAllActions()
    self.map_role.role:setToSetupPose()
    self.map_role.role:setAnimation(0, PlayerAction.idle, true)
    self.cur_role_action = PlayerAction.idle
    self.is_role_moving = false
    self.role_move_grid_cache = {}
    for k, object in pairs(self.route_effect_list) do
        if object.effect then
            object.effect:stopAllActions()
            object.effect:setVisible(false)
        end
    end
    self:checkProceedGridEvt()
    self:checkOtherLookInfo()
end

-- 检测是否有事件需要触发
function ActionyearmonsterMainWindow:checkProceedGridEvt(  )
    if self.target_grid_index then
        local evt_vo = _model:getYearEvtVoByGridIndex(self.target_grid_index)
        if evt_vo and evt_vo.config  then
            _controller:onHandleYearEvtById(evt_vo.config.type, evt_vo.index)
        end
        self.target_grid_index = nil
    end
end

-- 播放云层特效
function ActionyearmonsterMainWindow:playCloudEffect( status )
    if status == true then
        if not tolua.isnull(self.ui_container) and self.cloud_effect == nil then
            self.cloud_effect = createEffectSpine(Config.EffectData.data_effect_info[157], cc.p(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.cloud_effect:setScale(display.getMaxScale())
            self.ui_container:addChild(self.cloud_effect, 99)
        elseif self.cloud_effect then
            self.cloud_effect:setToSetupPose()
            self.cloud_effect:setAnimation(0, PlayerAction.action_1, false)
        end
    else
        if self.cloud_effect then
            self.cloud_effect:clearTracks()
            self.cloud_effect:removeFromParent()
            self.cloud_effect = nil
        end
    end
end

-- 播放buff进背包的效果
function ActionyearmonsterMainWindow:showBuffItemMoveAni( buff_id, world_pos )
    if not buff_id or not world_pos then return end
    local buff_cfg = Config.SecretDunData.data_buff[buff_id]
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

--烟火特效
function ActionyearmonsterMainWindow:showFiveEffect(bool, data)
    self.five_effect_container:setVisible(bool)
    if bool then 
        playOtherSound("c_petard")
        local function func()
            self.touchFive = false
            if data then
                local list = {}
                for k,v in pairs(data.reward) do
                    _table_insert(list, {bid = v.base_id, num = v.num})
                end
                
                MainuiController:getInstance():openGetItemView(true, list, nil, {is_backpack = true})
            end
        end
        playEffectOnce(PathTool.getEffectRes(1752),0,0,self.five_effect_container,func, nil, nil, nil, PlayerAction.action, 1)
    end
end

function ActionyearmonsterMainWindow:showRedBagEffect()
    playEffectOnce("E27701",0,0,self.ui_container,nil, nil, nil, nil, PlayerAction.action, 1)
end

function ActionyearmonsterMainWindow:close_callback( )

    if self.role_assets_event and self.role_vo then
        self.role_vo:UnBind(self.role_assets_event)
        self.role_assets_event = nil
    end

    for k, object in pairs(self.route_effect_list) do
        if object.effect then
            object.effect:stopAllActions()
            object.effect:clearTracks()
            object.effect:removeFromParent()
            object.effect = nil
        end
    end
    for k,effect in pairs(self.break_effect_list) do
        effect:clearTracks()
        effect:removeFromParent()
        effect = nil
    end
    self:openMapMoveTimer(false)
    self:checkBuoyMoveTimer(false)
    self:playCloudEffect(false)
    self:handlerTargetEffect(false)
    self:showFiveEffect(false)
    if self.move_buff_item then
        self.move_buff_item:DeleteMe()
        self.move_buff_item = nil
    end
    if self.grid_icon_load then
        self.grid_icon_load:DeleteMe()
        self.grid_icon_load = nil
    end
    if self.evt_icon_load then
        self.evt_icon_load:DeleteMe()
        self.evt_icon_load = nil
    end
    if self.bg_img_load then
        self.bg_img_load:DeleteMe()
        self.bg_img_load = nil
    end
    for k,item in pairs(self.evt_item_list) do
        item:DeleteMe()
        item = nil
    end

    if self.other_role_list then
        for k,v in pairs(self.other_role_list) do
            v.role:clearTracks()
            if v.face_spine then
                v.face_spine:clearTracks()
                v.face_spine:removeFromParent()
                v.face_spine = nil
            end
            if v.item_load_title then
                v.item_load_title:DeleteMe()
                v.item_load_title = nil
            end
            v.role:removeFromParent()
            v:removeFromParent()
        end
        self.other_role_list = {}
    end
    if self.other_timer ~= nil then
        GlobalTimeTicket:getInstance():remove(self.other_timer)
        self.other_timer = nil
    end
    

    self:removeMapRole()
    AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, "s_002", true) -- 恢复主城背景音乐播放
    MainuiController:getInstance():setIsShowMainUIBottom(true) -- 隐藏底部UI
    _controller:openActionyearmonsterMainWindow(false)
end
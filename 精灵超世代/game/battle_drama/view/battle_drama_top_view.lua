-- --------------------------------------------------------------------
--
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--     战斗界面副本层
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
--BttleTopDramaView = BttleTopDramaView or BaseClass()
BttleTopDramaView = class("BttleTopDramaView", function()
    return ccui.Layout:create()
end)

local _b_controller = BattleController:getInstance()
local _render_mgr = RenderMgr:getInstance()
local _tolua_isnull = tolua.isnull
local _drama_model = BattleDramaController:getInstance():getModel()
local _controller = BattleDramaController:getInstance() 
local _game_net = GameNet:getInstance()
local _string_format = string.format
local _table_insert = table.insert
local _table_remove = table.remove

local _get_time_items = Config.MiscData.data_get_time_items
local _get_time_length = Config.MiscData.data_get_time_items_length

function BttleTopDramaView:ctor(battle_res_id,battle_type)
    self.battle_res_id = battle_res_id or 10001
    self.battle_type = battle_type or BattleConst.Fight_Type.Darma
    self.map_height = 820 --可滑行的高度
    self.is_init = false
    self.is_move_root_wnd = false
    self.cur_map_pos = nil
    self.is_has_max_item = false
    self.is_change_chapter = false
    self.btn_layout_status = false
    self.btn_count = 0
    self.fly_item_sum = 0
    self:initConfig()
    self:createRootWnd()
    self:loadResources()
end

function BttleTopDramaView:initConfig()
    self.root_size = cc.size(SCREEN_WIDTH, display.height - self.map_height)
    self.map_size = cc.size(1800,1500)          --地图的实际尺寸,这个是动态的值,后面可能要创建的时候传入
    self.main_point_list = {} --副本章节节点
    self.model = BattleDramaController:getInstance():getModel()
    self.ctrl = BattleDramaController:getInstance()
    self.cur_chapter_id = nil
    self.role_vo = RoleController:getInstance():getRoleVo()

    self.right_btn_list = {}        -- 右边的图标列表,包含了情报
    self.left_btn_list = {}         -- 左边的图标列表,包含了排行和通关奖励和通关录像、日常
end

function BttleTopDramaView:createRootWnd()
    self.main_size = cc.size(SCREEN_WIDTH, display.height)
    self:setContentSize(self.main_size)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)

    self.root = ccui.Layout:create()
    self.root:setAnchorPoint(cc.p(0.5,1))
    self.root:setContentSize(cc.size(self.main_size.width, self.root_size.height))
    self.root:setPosition(self.main_size.width * 0.5, display.height)
    self:addChild(self.root)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:setContentSize(self.map_size)
    self.root_wnd:setPosition(cc.p(0, 0))
    self.root:addChild(self.root_wnd)

    self.btn_layout = ccui.Layout:create()
    self.btn_layout:setVisible(false)
    self.btn_layout:setLocalZOrder(999)
    self.btn_layout:setPosition(self.main_size.width * 0.5, display.getBottom(self) + MainuiController:getInstance():getBottomHeight() + 32)
    self:addChild(self.btn_layout)

    ViewManager:getInstance():addToLayerByTag(self, ViewMgrTag.UI_TAG)
end

function BttleTopDramaView:loadResources(  )
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("battledrama", "battledrama"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/pattern", "pattern_3"), type = ResourcesType.single }
    }

    self.resources_load = ResourcesLoad.New(true)
    if self.resources_load then
        self.resources_load:addAllList(self.res_list, function (  )
            self:loadResListCompleted()
        end)
    end
end

function BttleTopDramaView:loadResListCompleted(  )
    if self.battle_type == BattleConst.Fight_Type.Darma then
        if self.top_info_container == nil then
            local top_view_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
            self.top_info_container = ccui.Layout:create()
            self.top_info_container:setContentSize(SCREEN_WIDTH, 255)
            self.top_info_container:setAnchorPoint(cc.p(0, 1))
            self.top_info_container:setPosition(display.getLeft(), display.getTop(self) - top_view_height + 25)
            self:addChild(self.top_info_container)
        end
        if self.right_open_widget == nil then
            self.right_open_widget = ccui.Layout:create()
            self.right_open_widget:setContentSize(108, 90)
            self.right_open_widget:setAnchorPoint(cc.p(1, 1))
            self.right_open_widget:setPosition(display.getRight()-20, 120)
            self.top_info_container:addChild(self.right_open_widget)
        end

        self:readyCreateFunIcon()           -- 准备创建的一波资源
        self:updateDramaChapterData()       -- 创建剧情节点
        self:createDramaButton()            -- 掉落信息
        --self:updateEncounter()              -- 创建冒险奇遇
        self:registerEvent()
    end
end

-- 显示界面
function BttleTopDramaView:openView(  )
    self:setVisible(true)
    self.is_showing = true
end

-- 隐藏界面
function BttleTopDramaView:hideView(  )
    self:clearFlyTimer()
    self:clearAllFlyItemList()
    self:setVisible(false)
    self:showWorldLevelTips(false)
    self.is_showing = false
end

--==============================--
--desc:队列创建的,需要显示的东西
--time:2018-11-19 06:36:48
--@return 
--==============================--
function BttleTopDramaView:readyCreateFunIcon()
    if _tolua_isnull(self.top_info_container) then return end
    local delay_fun_list = {"updatePassCahpterInfo", "updateTaskInfo", "updateQingbaoInfo", "updateDramaHallows", "updateOnlineGiftInfo", "updateWorldLevelIcon","updateWorldMapInfo"}
    for i,fun_name in ipairs(delay_fun_list) do
        delayRun(self.top_info_container , i*4/60, function()
            if self[fun_name] then
                self[fun_name](self)
            end
        end)
    end
    if self.time_ticket == nil then
        self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
            self:checkTimeTicket()
        end, 1)
    end
end

function BttleTopDramaView:isCreateOnlineGift()
    local status = false
    local data = OnlineGiftController:getInstance():getOnlineGiftData()
    if data then
        if #data ~= _get_time_length then
            status = true
        end
    end
    return status
end
--在线奖励
function BttleTopDramaView:updateOnlineGiftInfo()
    OnlineGiftController:getInstance():sender10926()
    if _tolua_isnull(self.top_info_container) then return end
    self:onlineCreate()
end
--创建图标
function BttleTopDramaView:onlineCreate()
    if self.online_gift_node == nil and self:isCreateOnlineGift() == true then
        self.online_gift_node = self:createReceiveIcon("领取")
        self.online_gift_node:setScale(0.8)
        self.online_gift_node:setPosition(self.top_info_container:getContentSize().width-60, -50)
        self.top_info_container:addChild(self.online_gift_node)
        

        registerButtonEventListener(self.online_gift_node, function()
            OnlineGiftController:getInstance():openOnlineGiftView(true)
        end,true, 1)
    end

    self:updateRightBtnPos(false)
end
--领取信息发生变化的时候
function BttleTopDramaView:receiveChangeData()
    local data = OnlineGiftController:getInstance():getOnlineGiftData()
    local num = 0
    if data then
        for i,v in ipairs(_get_time_items) do
            if data[1] then
                if data[1].time and data[1].time >= v.time then
                    num = i
                end
            end
        end
    end
    num = num + 1
    if num >= _get_time_length then
        num = _get_time_length
    end 

    local online_time = OnlineGiftController:getInstance():getOnlineTime() or 0
    if not self.online_show_item then
        if self.online_gift_node then
            self.online_show_item = BackPackItem.new(nil,true,nil,0.55,false)
            self.online_gift_node:addChild(self.online_show_item)
            self.online_show_item:setPosition(cc.p(39, 50))
        end
    end
    if self.online_show_item then
        self.online_show_item:setBaseData(_get_time_items[num].items[1][1], _get_time_items[num].items[1][2])
        self.online_show_item:showItemEffect(true,165,PlayerAction.action,true,1.2)

        self.online_show_item:addCallBack(function()
            OnlineGiftController:getInstance():openOnlineGiftView(true)
        end)

        if online_time >= _get_time_items[num].time then
            if self.online_gift_node then
                doStopAllActions(self.online_gift_node.label)
                self.online_gift_node.label:setString(TI18N"可领取")
            end
        else
            self.online_show_item:showItemEffect(false,165,PlayerAction.action,true)
            local time = _get_time_items[num].time - online_time
            self:setLessTime(time)
        end
    end
end
--避免网络时间延迟导致在线奖励领取完毕还在剧情副本中
function BttleTopDramaView:removeOnlineSprite(data)
    if data and data.list then
        local status = false
        local time = data.time or 0
        if next(data.list) ~= nil then
            --删除图标
            if #data.list >= _get_time_length then
                status = false
            else
                status = true
            end
        else
            status = true
        end
        if status == false then
            self:clearOnlineInfo()
        else
            --创建图标
            self:onlineCreate()
        end
    end
end

--设置倒计时
function BttleTopDramaView:setLessTime(less_time)
    if not less_time then return end
    if tolua.isnull(self.online_gift_node.label) then return end
    doStopAllActions(self.online_gift_node.label)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.online_gift_node.label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(self.online_gift_node.label)
            else
                self:setTimeFormatString(less_time)
            end
        end))))
    else
        self:setTimeFormatString(less_time)
    end
end
function BttleTopDramaView:setTimeFormatString(time)
    if time and time > 0 then
        self.online_gift_node.label:setString(TimeTool.GetTimeFormat(time))
    else
        self.online_gift_node.label:setString("")
    end
end
--删除
function BttleTopDramaView:removeOnlineGift(data)
    self:receiveChangeData()

    local status = false
    if _get_time_items[_get_time_length].time == data then --等于最后一个，就说明奖励已经全部领取完毕
        status = true
    end
    if status == true then
        if not tolua.isnull(self.online_gift_node) then 
            OnlineGiftController:getInstance():openOnlineGiftView(false) 
            self:clearOnlineInfo()
        end
    end
end

function BttleTopDramaView:clearOnlineInfo()
    if not tolua.isnull(self.online_gift_node) then 
        doStopAllActions(self.online_gift_node.label)
        if self.online_show_item then
            self.online_show_item:DeleteMe()
        end
        self.online_show_item  = nil
        self.online_gift_node:removeFromParent()
        self.online_gift_node = nil

        if self.update_online_get_event then
            GlobalEvent:getInstance():UnBind(self.update_online_get_event)
            self.update_online_get_event = nil
        end
    end
end

--==============================--
--desc:剧情里面需要用到的定时器
--time:2018-11-19 06:37:06
--@return 
--==============================--
function BttleTopDramaView:checkTimeTicket()
    -- if self.progress_aaa then
    --     if self.progress_aaa_111 == nil then
    --         self.progress_aaa_111 = 0
    --     end
    --     self.progress_aaa_111 = self.progress_aaa_111 + 1
    --     if self.progress_aaa_111 > 100 then
    --         self.progress_aaa_111 = 100
    --     end
    --     self.progress_aaa:setPercentage(self.progress_aaa_111)
    -- end
end

--==============================--
--desc:更新章节节点数据
--time:2018-11-19 06:37:28
--@return 
--==============================--
function BttleTopDramaView:updateDramaChapterData()
    self.drama_data = self.model:getDramaData()
    if not self.drama_data then return end
    if not self.cur_chapter_id then
        self.cur_chapter_id = self.drama_data.chapter_id
    end
    self.is_change_chapter = false
    if self.cur_chapter_id ~= self.drama_data.chapter_id then --如果是不等于则清楚
        --[[if self.main_point_list and next(self.main_point_list or {}) ~= nil then
            for i, item in pairs(self.main_point_list) do
                if item then
                    item:clearInfo()
                    item:DeleteMe()
                end
            end
        end
        self.main_point_list = {}--]]
        self.is_change_chapter = true
        self:updateImage() -- 更新假战斗界面地图
        --[[
        self:moveTag()--]]
        self.cur_chapter_id = self.drama_data.chapter_id
    end
    self.model:initDungeonList(self.drama_data.mode, self.drama_data.chapter_id)
    
    --[[local data = self.model:getInitDungeonList()
    if data then
        local item = nil
        for i, v in ipairs(data) do
            delayRun(self.root, 4 * i/display.DEFAULT_FPS,function()
                if not self.main_point_list[v.info_data.id] then
                    item = BattleDramaMainPointItem.new()
                    self.main_point_list[v.info_data.id] = item
                    if self.root_wnd then
                        self.root_wnd:addChild(item, 98)
                    end
                end
                item = self.main_point_list[v.info_data.id]
                if item then
                    v.v_data = self.model:getCurDunInfoByID(v.info_data.id)
                    item:setPosition(v.info_data.pos[1], v.info_data.pos[2])
                    item:setData(v)
                end
            end)
        end
    end

    if not self.cur_tag_container then
        self.cur_tag_container = ccui.Layout:create()
        self.cur_tag_container:setContentSize(cc.size(50, 50))
        self.cur_tag_container:setAnchorPoint(cc.p(0.5, 0.5))
        self.root_wnd:addChild(self.cur_tag_container, 99)
        self:createRole(PlayerAction.battle_stand)
    end
    self:updateMove()

    -- 设置章节节点的状态
    self:updateStatus()--]]
end

--- 设置章节节点的状态
function BttleTopDramaView:updateStatus(is_update)
    self.drama_data = self.model:getDramaData()
    if self.drama_data then
        local v_data = self.model:getCurDunInfoByID(self.drama_data.dun_id)
        local config = Config.DungeonData.E51147data_drama_dungeon_info(self.drama_data.dun_id)
        if config then
            if self.main_point_list and self.main_point_list[self.drama_data.dun_id] then
                local item = self.main_point_list[self.drama_data.dun_id]
                local is_big = config.is_big
                item:updateStatus(v_data.status, is_big)
            end
            self:updateMove(is_update)

            if not self.is_move_start then
                -- self:moveTag()
                self.is_move_start = true
            end
        end
    end
end

function BttleTopDramaView:updateMove(is_update)
    if self.drama_data then
        local config = Config.DungeonData.data_drama_dungeon_info(self.drama_data.dun_id)
        if config then
            local temp_pos = config.pos
            local item_pos = cc.p(temp_pos[1], temp_pos[2])
            local next_id = config.next_id
            local world_pos = self.root_wnd:convertToWorldSpace(cc.p(item_pos.x, item_pos.y))
            local node_pos = self.root_wnd:convertToNodeSpace(world_pos)
            local pos_y = item_pos.y / 2
            local offset_y = (self.root_size.height / 2 - pos_y)
            if pos_y >= offset_y then
                pos_y = -item_pos.y / 2
            end
            local distance_final_x = self.map_size.width - item_pos.x --当前距离地图终点距离
            local distance_mid_x = self.root_size.width / 2 - distance_final_x --距离屏幕中心点距离
            local pos_x = item_pos.x
            if pos_x >= self.root_size.width then
                if math.abs(distance_mid_x) >= self.root_size.width / 2 then
                    pos_x = -item_pos.x - distance_mid_x / 2
                else
                    pos_x = -item_pos.x - distance_mid_x
                end
            end
            local return_pos = self:scaleCheckPoint(math.ceil(pos_x), math.ceil(pos_y))
            if not self.is_move_root_wnd then
                if self.model:getRootWndPos() and not is_update and not self.is_change_chapter then
                    self.root_wnd:setPosition(self.model:getRootWndPos())
                else
                    self:rootWndMove(return_pos)
                end
            end
        end
    end
end

function BttleTopDramaView:moveTag(is_start)
end

function BttleTopDramaView:updateEffect(effect_res)
    if self.effect then
        self.effect:runAction(cc.RemoveSelf:create(true))
        self.effect = nil
    end
    if effect_res ~= "" then
        if not _tolua_isnull(self.root) and self.effect == nil then
            self.effect = createEffectSpine(effect_res, cc.p(0, self.root_size.height), cc.p(0, 1), true, PlayerAction.action)
            self.root:addChild(self.effect)
        end
    end
end 

function BttleTopDramaView:createRole(action_name)
    -- if not _tolua_isnull(self.spine_model) then
    --     self.spine_model:runAction(cc.RemoveSelf:create(true))
    --     self.spine_model = nil
    -- end
    -- if not self.spine_model then
    --     self.cur_action_name = action_name
    --     local look_id = RoleController:getInstance():getRoleVo().look_id
    --     local look_config = Config.LooksData.data_data[look_id]
    --     local res_id = "H30009" -- 默认显示该模型
    --     if look_config then
    --         res_id = look_config.ico_id or res_id
    --     end
    --     self.spine_model = createSpineByName(res_id, action_name)
    --     self.spine_model:setPosition(self.cur_tag_container:getContentSize().width / 2, -15)
    --     self.spine_model:setScaleX(0.7 * self:getDir())
    --     self.spine_model:setScaleY(0.7)
    --     self.cur_tag_container:addChild(self.spine_model)
    --     self.spine_model:setAnimation(0, action_name, true)
    --     self.spine_model:update(0)
    --     local height = self.spine_model:getBoundingBox().height or 85
    --     if not self.cur_effect then
    --         self.cur_effect = createEffectSpine(Config.EffectData.data_effect_info[105], cc.p(25, 130), cc.p(0.5, 0.5), true, PlayerAction.action, nil, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    --         self.cur_tag_container:addChild(self.cur_effect)
    --     end
    --     if self.cur_effect then
    --         self.cur_effect:setPosition(25,height)
    --     end
    -- end
end

function BttleTopDramaView:getDir()
    local scale = 1
    local item = self.main_point_list[self.drama_data.dun_id]
    if item then
        local max_item = self.main_point_list[self.drama_data.max_dun_id]
        local cur_x = item:getPositionX()
        local max_x = 0
        if max_item then
            max_x = max_item:getPositionX()
        end
        if cur_x > max_x then
            scale = 1
        else
            scale = -1
        end
    end
    return scale
end

--==============================--
--desc:章节变化时,显示收益提示
--time:2018-09-11 05:52:23
--@return 
--==============================--
function BttleTopDramaView:updateCurMapNameAction()

    if self.drama_data == nil then return end
    _b_controller:setDramaStatus(true)
    local is_init = false
    local last_dun_id = self.drama_data.last_dun_id or 0
    if self.drama_data.last_dun_id == 0 then
        last_dun_id = self.drama_data.max_dun_id
        is_init = true
    end
    local cur_id = self.drama_data.max_dun_id
    local info_config = Config.DungeonData.data_drama_dungeon_info
    local data = info_config(last_dun_id)
    local cur_data = info_config(cur_id)
    if data == nil or cur_data == nil then return end

    if not self.map_name_container then
        self.map_name_container = ccui.Layout:create()
        self.map_name_container:setContentSize(410, 217)
        self.map_name_container:setAnchorPoint(cc.p(0.5, 0))
        self.map_name_container:setOpacity(255)
        self.map_name_container:setCascadeOpacityEnabled(true)
        self.map_name_container:setPosition(cc.p(self.root_size.width / 2, display.height * 3 / 5))
        if not _tolua_isnull(self.map_name_container) then
            self:addChild(self.map_name_container, 99)
        end

        self.map_bg = createScale9Sprite(PathTool.getResFrame("common", "common_1034"), 0, self.map_name_container:getContentSize().height / 2, LOADTEXT_PLIST, self.map_name_container)
        --self.map_left_bg = createScale9Sprite(PathTool.getResFrame("battledrama", "battledrama_1038"), 0, self.map_name_container:getContentSize().height / 2, LOADTEXT_PLIST, self.map_name_container)
        self.map_bg:setAnchorPoint(cc.p(0, 0.5))
        self.map_bg:setContentSize(cc.size(self.map_name_container:getContentSize().width, self.map_name_container:getContentSize().height))

        --self.map_right_bg = createScale9Sprite(PathTool.getResFrame("battledrama", "battledrama_1038"), self.map_name_container:getContentSize().width - 0.5, self.map_name_container:getContentSize().height / 2, LOADTEXT_PLIST, self.map_name_container)
        --self.map_right_bg:setScaleX(- 1)
        --self.map_right_bg:setAnchorPoint(cc.p(0, 0.5))
        --self.map_right_bg:setContentSize(cc.size(self.map_right_bg:getContentSize().width, self.map_name_container:getContentSize().height))
        self.map_name_label = createLabel(28, Config.ColorData.data_new_color4[6], nil, self.map_name_container:getContentSize().width / 2, self.map_name_container:getContentSize().height - 20, "", self.map_name_container)
        self.map_name_label:setAnchorPoint(cc.p(0.5, 0.5))
        --self.before_rich_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(15, 85), 15, nil, 1000)
        self.before_rich_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(85, 85), 10, nil, 1000)
        self.map_name_container:addChild(self.before_rich_label)
        self.desc_cur_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(172, 93), 15, nil, 1000)
        self.map_name_container:addChild(self.desc_cur_label)
        self.after_rich_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(238, 85), 15, nil, 1000)
        self.map_name_container:addChild(self.after_rich_label)
        self.desc_cur_label_2 = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(278, 85), 15, nil, 1000)
        self.map_name_container:addChild(self.desc_cur_label_2)

    end
    if self.map_name_container and not _tolua_isnull(self.map_name_container) then
        -- 创建上一个关卡的产出数值
        local str = ""
        local num_str = ""
        if data and data.per_hook_items then
            local per_hook_items = self.model:calcHookItems(data)
            for i, v in ipairs(per_hook_items) do
                local config = Config.ItemData.data_get_data(v[1])
                --str = str .. _string_format(TI18N("<img src=%s visible=true scale=0.30 /><div>%s\n</div>"), PathTool.getItemRes(config.icon), config.name)
                str = str .. _string_format(TI18N("<img src=%s visible=true scale=0.30 /><div>%s\n</div>"), PathTool.getItemRes(config.icon), "")
                if is_init == true then
                    num_str = num_str .. "\n" ..0 
                else
                    num_str = num_str .. "\n" ..v[2]
                end
            end
        end
        self.before_rich_label:setString(str)
        self.desc_cur_label:setString(num_str)
        self.desc_cur_label:setPositionX(self.before_rich_label:getPositionX() + self.before_rich_label:getContentSize().width + 10)

        -- 创建当前关卡的产出数值
        local str = ""
        local num_str = ''
        if cur_data and cur_data.per_hook_items then
            local per_hook_items = self.model:calcHookItems(cur_data)
            for i, v in ipairs(per_hook_items) do
                local config = Config.ItemData.data_get_data(v[1])
                str = str .. _string_format(TI18N('<img src=%s visible=true scale=1 /><div>\n</div>'), PathTool.getResFrame("common", "common_90017"))
                num_str = num_str .. _string_format(TI18N("<div>%s/分钟\n</div>"), v[2])
            end
        end
        self.after_rich_label:setString(str)
        self.desc_cur_label_2:setString(num_str)
        self.after_rich_label:setPositionX(self.desc_cur_label:getPositionX() + self.desc_cur_label:getContentSize().width + 10)
        self.desc_cur_label_2:setPositionX(self.after_rich_label:getPositionX() + self.after_rich_label:getContentSize().width + 10)
        
        -- 设置名字
        -- local info_config = Config.DungeonData.data_drama_dungeon_info(cur_id)
        if cur_data and self.map_name_label then
            self.map_name_label:setString(cur_data.name)
        end

        -- 动作
        self.map_name_container:runAction(cc.Sequence:create(cc.FadeTo:create(0.8, 255), cc.DelayTime:create(3), cc.FadeOut:create(0.8), cc.CallFunc:create(function()
            if self.map_name_container and not _tolua_isnull(self.map_name_container) then
                self.map_name_container:removeAllChildren()
                self.map_name_container = nil
                _b_controller:setDramaStatus(false)
            end
        end)))
    end
end 

--==============================--
--desc:更具当前剧情id回头设置当前战斗地图 
--time:2018-09-11 05:52:23
--@return 
--==============================--
function BttleTopDramaView:updateImage()
    if _b_controller:getCtrlBattleScene() and self.drama_data then
        local _config = Config.DungeonData.data_drama_world_info[self.drama_data.mode]
        if _config and _config[self.drama_data.chapter_id] then
            local map_id =_config[self.drama_data.chapter_id].map_id
            if _b_controller:getCtrlBattleScene() then
                if self.map_resources_load then
                    self.map_resources_load:DeleteMe()
                    self.map_resources_load = nil
                end
                if not self.map_resources_load then
                    self.map_resources_load = ResourcesLoad.New(true)       -- 资源下载
                end
                if not self.res_list then
                    self.res_list = {}
                end
                local m_bg_res = PathTool.getBattleSceneRes(_string_format("%s/m_bg", map_id), false)
                local map_bg_res = PathTool.getBattleSceneRes(_string_format("%s/map_bg", map_id), false)
                table.insert(self.res_list, { path = m_bg_res, type = ResourcesType.single })
                table.insert(self.res_list, { path = map_bg_res, type = ResourcesType.single })
                self.map_resources_load:addAllList(self.res_list, function()
                    if _b_controller:getCtrlBattleScene() then
                        _b_controller:getCtrlBattleScene():updateBg(map_bg_res, m_bg_res)
                    end
                    --self:analysisMap(map_id)
                    self.res_list = {}
                end)
            end
        end
        self.is_init = true
    end
end

--==============================--
--desc:移动背景图
--time:2018-11-19 06:38:48
--@x:
--@y:
--@return 
--==============================--
function BttleTopDramaView:moveMainScene(x,y)
    x = self.root_wnd:getPositionX() + x
    y = self.root_wnd:getPositionY() + y
    local return_pos = self:scaleCheckPoint(x,y)
    self.root_wnd:setPosition(return_pos.x,return_pos.y)
end

--==============================--
--desc:判断位置的边界情况
--time:2018-11-19 06:39:05
--@_x:
--@_y:
--@return 
--==============================--
function BttleTopDramaView:scaleCheckPoint( _x, _y)
    local return_pos = cc.p(_x,_y)
    if return_pos.x > 0 then
        return_pos.x = 0
    elseif return_pos.x < (self.root_size.width-self.map_size.width) then
        return_pos.x = (self.root_size.width-self.map_size.width)
    end
    if return_pos.y < (self.root_size.height - self.map_size.height)  then
        return_pos.y = (self.root_size.height - self.map_size.height)
    elseif return_pos.y >= 0  then 
        return_pos.y = 0
    end
    return return_pos
end

--==============================--
--desc:注册监听事件
--time:2018-11-19 06:39:23
--@return 
--==============================--
function BttleTopDramaView:registerEvent()
    --[[local function onTouchBegin(touch, event)
        self.last_point = nil
        doStopAllActions(self.root_wnd)
        self.is_move_root_wnd = true

        -- 计算点
        if self.screen_size == nil then
            local pos = self.root:convertToWorldSpace(cc.p(0, 0))
            self.screenSize = cc.rect(pos.x, pos.y+100, self.root_size.width, self.root_size.height-100)
        end
        local pos = cc.p(touch:getLocation().x, touch:getLocation().y)
        if not cc.rectContainsPoint(self.screenSize, pos) then
            return false
        end

        return true
    end

    local function onTouchMoved(touch, event)
        self.last_point = touch:getDelta()
        self:moveMainScene(self.last_point.x,self.last_point.y)
    end

    local function onTouchEnded(touch, event)
        if self.last_point == nil then return end
        local interval_x = self.last_point.x * 3
        local interval_y = self.last_point.y * 3
        local temp_x = self.root_wnd:getPositionX() + interval_x
        local temp_y = self.root_wnd:getPositionY() + interval_y
        -- 修正之后的目标位置
        local return_pos = self:scaleCheckPoint(temp_x,temp_y)
        self.is_move_root_wnd = false
        self:rootWndMove(return_pos,true)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self.root:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.root)--]]

    if not self.update_drama_data_event then
        self.update_drama_data_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Update_Data,function (data)
            if data.chapter_id ~= self.cur_chapter_id then
                 if self.root_wnd and not _tolua_isnull(self.root_wnd) then
                    self:updateDramaChapterData()
                    self:updateCurMapInfo(true)
                end
            else
                if self.root_wnd and not _tolua_isnull(self.root_wnd) then
                    --self:updateStatus(true)
                    self:updateCurMapInfo()
                end
            end
            -- self:updateQingbaoInfo()
            self:updateNextBtnStatus(self.drama_data)
        end)
    end

    -- 最大关卡数更新，刷新掉落信息
    if not self.update_drama_max_id_event then
        self.update_drama_max_id_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Update_Max_Id, function (  )
            self:updateDramaDropInfo()
        end)    
    end

    if not self.update_drama_top_data_event then
        self.update_drama_top_data_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Top_Update_Data, function(data)
            if self.root_wnd and not _tolua_isnull(self.root_wnd) then
                self:updateDramaChapterData()
                self:updateCurMapInfo(true)
                self:updateNextBtnStatus(self.drama_data)
            end
        end)
    end
    
    if self.battle_exit_event == nil then
        self.battle_exit_event = GlobalEvent:getInstance():Bind(BattleEvent.MOVE_DRAMA_EVENT, function(combat_type,result)
            if combat_type == BattleConst.Fight_Type.Darma and self.drama_data and MainuiController:getInstance():checkIsInDramaUIFight() then
                self:updateCurMapNameAction()
                self.is_move_start = true
                --self:moveTag(true)
            end
        end)
    end

    if not self.update_drama_reward_event then
        self.update_drama_reward_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Drama_Reward_Data, function(data)
           self:updatePassCahpterInfo()
        end)
    end

    if not self.update_drama_quick_data_event then
        self.update_drama_quick_data_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Quick_Battle_Data, function(data)
            if data == nil then return end
            if _tolua_isnull(self.quick_battle_btn) then return end
            if data.fast_combat_num ~= 0 or not self.quick_battle_status then
                self.quick_battle_tips:setVisible(false)
            else
                self.quick_battle_tips:setVisible(true)
            end
            self:updateNextBtnStatus(self.model:getDramaData())
        end)
    end
        
    -- 图标添加或者移除的时候需要判断
    if self.update_function_status_event == nil then
        self.update_function_status_event = GlobalEvent:getInstance():Bind(MainuiEvent.UPDATE_FUNCTION_STATUS, function(id, status) 
            if id == MainuiConst.icon.daily then
                self:updateTaskInfo()
            elseif id == MainuiConst.icon.rank then
                -- self:updateRankInfo()
            end
        end)
    end
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "look_id" then
                
                elseif key == "energy" then
                    self:updateQingbaoInfo()
                elseif key == "lev" then
                    if self.next_battle_btn and self.next_battle_btn.lev_limit and self.next_battle_btn.lev_limit <= value then
                        self.next_battle_btn.lev_limit = 0
                        self.boss_btn_notice:setVisible(false)
                        self.boss_btn_challenge:setVisible(true)
                    end
                    self:updateWorldLevelIcon()
                    -- self:checkEncounterOpenStatus()
                    --self:updateEncounter()
                end
            end)
        end
    end
    -- 神器任务更新
    if self.update_hallows_task_event == nil then
        self.update_hallows_task_event = GlobalEvent:getInstance():Bind(HallowsEvent.UpdateHallowsTaskEvent, function() 
            self:updateDramaHallows()
        end) 
    end
    -- 激活神器
    if self.update_drama_hallows_event == nil then
        self.update_drama_hallows_event = GlobalEvent:getInstance():Bind(HallowsEvent.HallowsActivityEvent, function()
            self:updateDramaHallows()
        end)
    end
    -- 神器红点
    if self.update_hallows_red_status == nil then
        self.update_hallows_red_status = GlobalEvent:getInstance():Bind(HallowsEvent.HallowsRedStatus, function ()
            self:updateHallowsRedStatus()
        end)
    end

    if self.update_hookaccumulatetime_event == nil then
		self.update_hookaccumulatetime_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.UpdateHookAccumulateTime, function()
			self:updateResourceCollect()
		end)
	end

    if self.update_onlinegift_event == nil then
        self.update_onlinegift_event = GlobalEvent:getInstance():Bind(OnlineGiftEvent.Updata_Data, function(data)
            self:removeOnlineGift(data)
        end)
    end
    --在线等时间到达时
    if self.update_online_get_event == nil then
        self.update_online_get_event = GlobalEvent:getInstance():Bind(OnlineGiftEvent.Get_Data, function(data)
            self:removeOnlineSprite(data)
            self:receiveChangeData()
        end)
    end
    -- 远航红点
    if self.update_voyage_red_event == nil then
        self.update_voyage_red_event = GlobalEvent:getInstance():Bind(VoyageEvent.UpdateVoyageRedEvent, function(data)
            if self.qingbao_progress_tips and not _tolua_isnull(self.qingbao_progress_tips) then
                local red_status = VoyageController:getInstance():getModel():checkVoyageRedStatus()
                self.qingbao_progress_tips:setVisible(red_status)
            end
        end)
    end

     -- 冒险奇遇红点
     if self.update_encounter_red_event == nil then
        self.update_encounter_red_event = GlobalEvent:getInstance():Bind(EncounterEvent.UPDATA_RED_STATUS, function(data)
            -- self:checkEncounterRed()
        end)
    end
end

--==============================--
--desc:移动地图
--time:2018-11-19 03:05:53
--@return_pos:
--@is_move:
--@return 
--==============================--
function BttleTopDramaView:rootWndMove(return_pos,is_move)
    local move_to = cc.MoveTo:create(0.4, cc.p(return_pos.x, return_pos.y))
    if self.model:getRootWndPos() and not is_move then
        local distance_x = self.model:getRootWndPos().x - return_pos.x
        local distance_y = self.model:getRootWndPos().y - return_pos.y
        move_to = cc.MoveBy:create(0.4, cc.p(-distance_x, -distance_y))
    end
  
    doStopAllActions(self.root_wnd)
    local call_fun = cc.CallFunc:create(function()
        self.model:setRootWndPos(cc.p(return_pos.x, return_pos.y))
        self.in_touch_move = false
    end)
    self.root_wnd:runAction(cc.Sequence:create(move_to, call_fun))
end

--==============================--
--desc:解析待创建资源
--time:2018-09-11 05:54:23
--@map_id:
--@return 
--==============================--
--[[function BttleTopDramaView:analysisMap(map_id)

end--]]

--==============================--
--desc:创建左上角的图标,活动类的或者通关奖励类的
--time:2018-09-11 04:03:13
--@return 
--==============================--
function BttleTopDramaView:createSpecialIcon(res, content, load_type)
    local container = ccui.Layout:create()
    container:setAnchorPoint(0.5, 0.5)
    container:setContentSize(76,76)
    container:setTouchEnabled(true)

    --local bg = createSprite(PathTool.getResFrame("battledrama","battledrama_1020"),38,38,container,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)

    load_type = load_type or LOADTEXT_TYPE_PLIST
    local sp = createSprite(res, 38, 38, container, cc.p(0.5, 0.5), load_type) 

    content = content or ""
    local label = createLabel(18, Config.ColorData.data_new_color4[15], 2, 38, 2, content, container, 2, cc.p(0.5,0.5))
    label:enableOutline(Config.ColorData.data_new_color4[6])

    local tips = createSprite(PathTool.getResFrame("mainui", "mainui_1009"), 62, 62, container, cc.p(0.5, 0.5))
    tips:setVisible(false) 

    container.bg = bg
    container.sp = sp
    container.label = label
    container.tips = tips
    return container
end

--在线奖励创建的底图
function BttleTopDramaView:createReceiveIcon(content)
    local container = ccui.Layout:create()
    container:setAnchorPoint(0.5, 0.5)
    container:setContentSize(76,76)
    container:setTouchEnabled(true)

    local bg = createSprite(PathTool.getResFrame("battledrama","battledrama_1014"),38,38,container,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
    content = content or ""
    local label = createLabel(18, cc.c4b(0x00,0xff,0x00,0xff), 2, 36, -17, content, container, 2, cc.p(0.5,0.5))
    
    container.bg = bg
    container.label = label
    return container
end

--==============================--
--desc:资源状态更新
--time:2018-11-19 05:35:32
--@return 
--==============================--
function BttleTopDramaView:updateResourceCollect()
    if _tolua_isnull(self.resources_progress) then return end
    if _tolua_isnull(self.resources_box) then return end
    local cost_config = Config.DungeonData.data_drama_const.hangup_revenue
    local min_config = Config.DungeonData.data_drama_const.hangup_revenue_small
    local max_config = Config.DungeonData.data_drama_const.hangup_revenue_big
    if cost_config == nil or min_config == nil or max_config == nil then return end
    
    local hook_info = _drama_model:getHookAccumulateInfo()
    if hook_info == nil then return end
    local hook_time = hook_info.hook_time or 0      -- 挂机时间

    local action = PlayerAction.action
    if hook_time >= max_config.val then
        --action = PlayerAction.action_1
    --elseif hook_time >= min_config.val then
    --    action = PlayerAction.action_3
    --elseif hook_time >= cost_config.val then
    --    action = PlayerAction.action_1
    else
        action = PlayerAction.action
    end
    print("resources_box",hook_time,max_config.val,action,self.resources_action )
    if self.resources_action ~= action then
        self.resources_action = action
        self.resources_box:setToSetupPose()

        self.resources_box:setAnimation(0, action, true)
    end
    
    local time_max_config = Config.DungeonData.data_drama_const.profit_time_max
    if time_max_config then
        self.resources_progress:setPercent(100 * hook_time / time_max_config.val)
    end
    if not _tolua_isnull(self.resources_time_label) then
        self.resources_time_label:setString(TimeTool.GetTimeFormatIII(hook_time))
    end
end

--==============================--
--desc:世界地图按钮
--time:2018-11-19 07:28:23
--@return 
--==============================--
function BttleTopDramaView:updateWorldMapInfo()
    if _tolua_isnull(self.top_info_container) then return end
        
    if self.world_map_node == nil then
        -- self.world_map_node = self:createSpecialIcon(PathTool.getResFrame("battledrama", "battledrama_1017"), TI18N("查看地图"), LOADTEXT_TYPE_PLIST)
        self.world_map_node = self:createSpecialIcon(nil, nil, nil)
        if self.world_map_node.bg then
            self.world_map_node.bg:setVisible(false)
        end
        self.top_info_container:addChild(self.world_map_node)
        local node_size = cc.size(139,139)
        self.world_map_node = ccui.Layout:create()
        self.world_map_node:setAnchorPoint(0.5, 0.5)
        self.world_map_node:setContentSize(node_size)
        self.world_map_node:setTouchEnabled(true)

        local map_icon_k = createSprite(PathTool.getResFrame("battledrama","battledrama_1001"),node_size.width/2,node_size.height/2,self.world_map_node,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST, 2)
        local name_label = createLabel(20,1,cc.c3b(72,44,27),node_size.width/2,10,"",self.world_map_node,1,cc.p(0.5, 1))
        name_label:setDimensions(160, 50)
        name_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
        -- 小地图裁剪
        local draw = createSprite(PathTool.getResFrame("battledrama","battledrama_1010"),node_size.width/2,node_size.height/2,nil,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
        local map_cli_node = cc.ClippingNode:create(draw)
        map_cli_node:setAnchorPoint(cc.p(0.5,0.5))
        map_cli_node:setContentSize(node_size)
        map_cli_node:setCascadeOpacityEnabled(true)
        map_cli_node:setPosition(node_size.width/2, node_size.height/2)
        map_cli_node:setAlphaThreshold(0)

        self.world_map_node:addChild(map_cli_node)
        self.world_map_node.name_label = name_label
        self.world_map_node.map_cli_node = map_cli_node

        self:updateCurMapInfo(true)

        self.top_info_container:addChild(self.world_map_node)
        self.world_map_node:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                BattleDramaController:getInstance():openBattleDramaMapWindows(true)
            end
        end)
        local top_size = self.top_info_container:getContentSize() 
        self.world_map_node:setPosition(top_size.width-73, top_size.height-41)
    end
end

-- 刷新当前地图信息
function BttleTopDramaView:updateCurMapInfo( is_change_map )
    if self.world_map_node then
        self.drama_data = self.model:getDramaData()
        if self.drama_data then
            local drama_config = Config.DungeonData.data_drama_dungeon_info(self.drama_data.dun_id)
            -- 容错处理，配置表删减关卡数据了，有些老号会取不到旧的关卡数据
            if not drama_config or next(drama_config) == nil then
                return
            end
            if self.world_map_node.name_label then
                self.world_map_node.name_label:setString(drama_config.name)
            end

            if is_change_map then
                local node_size = self.world_map_node:getContentSize()
                local world_config = Config.DungeonData.data_drama_world_info[self.drama_data.mode]
                if world_config and world_config[self.drama_data.chapter_id] then
                    local map_id =world_config[self.drama_data.chapter_id].map_id
                    
                    if self.load_map_icon then
                        self.load_map_icon:DeleteMe()
                        self.load_map_icon = nil
                    end
                    local map_res = PathTool.getBattleSceneRes(_string_format("%s/blayer/small_map", map_id), true)
                    self.load_map_icon = createResourcesLoad(map_res, ResourcesType.single, function ()
                        if not self.map_icon_bg then
                            self.map_icon_bg = createSprite(map_res, 0, 0, self.world_map_node.map_cli_node, cc.p(0, 0), LOADTEXT_TYPE)
                        else
                            loadSpriteTexture(self.map_icon_bg, map_res, LOADTEXT_TYPE)
                        end
                        local node_pos = self:getCliNodePos()
                        self.map_icon_bg:setPosition(node_pos)
                    end, self.load_map_icon)
                end
            elseif self.map_icon_bg then
                local node_pos = self:getCliNodePos()
                self.map_icon_bg:setPosition(node_pos)
            end
        end
    end
end

-- 获取小地图裁剪的位置
function BttleTopDramaView:getCliNodePos(  )
    if self.drama_data then
        local info_config = Config.DungeonData.data_drama_dungeon_info(self.drama_data.dun_id)
        if info_config and info_config.pos then
            local pos_x = info_config.pos[1]
            local pos_y = info_config.pos[2]
            local node_size = self.world_map_node:getContentSize()
            local icon_size = self.map_icon_bg:getContentSize()
            pos_x = pos_x/(1024/icon_size.width)
            pos_y = pos_y/(1024/icon_size.height)
            if not self.map_icon_flag then
                local flag_res = PathTool.getResFrame("battledrama","battledrama_1013")
                self.map_icon_flag = createSprite(flag_res, pos_x, pos_y, self.map_icon_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            end
            self.map_icon_flag:setPosition(cc.p(pos_x, pos_y))
            pos_x = - pos_x + node_size.width/2
            pos_y = - pos_y + node_size.height/2
            if pos_x < -(icon_size.width-node_size.width) then
                pos_x = -(icon_size.width-node_size.width)
            elseif pos_x > 0 then
                pos_x = 0
            end
            if pos_y < -(icon_size.height-node_size.height) then
                pos_y = -(icon_size.height-node_size.height)
            elseif pos_y > 0 then
                pos_y = 0
            end
            return cc.p(pos_x, pos_y)
        end
    end
    return cc.p(0, 0)
end

--==============================--
--desc:右边日常任务,排在右边的第一个位置
--time:2018-09-11 05:56:09
--@return 
--==============================--
function BttleTopDramaView:updateTaskInfo(status)
    if status == false then return end
    local need_update_pos = false
    if self.task_icon_vo == nil then
        local task_icon_vo = MainuiController:getInstance():getFucntionIconVoById(MainuiConst.icon.daily) 
        if task_icon_vo == nil then return end

        self.task_icon_vo = task_icon_vo 
        self.task_icon = self:createSpecialIcon(PathTool.getResFrame("battledrama", "battledrama_1016"), TI18N("日常任务"), LOADTEXT_TYPE_PLIST)
        self.task_icon:setPosition(52, 52)
        self.top_info_container:addChild(self.task_icon)

        self.task_icon.index = 1
        self.left_btn_list[1] = self.task_icon
        
        self.task_icon:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                MainuiController:getInstance():iconClickHandle(self.task_icon_vo.config.id)
            end
        end)

        if self.task_icon_event == nil then
            self.task_icon_event = self.task_icon_vo:Bind(FunctionIconVo.UPDATE_SELF_EVENT, function(key)
                if key == "tips_status" then
                    self:checkTaskRed()
                end
            end)
        end
        self:checkTaskRed()
        need_update_pos = true
    end
    if need_update_pos then
        self:updateRightBtnPos()
    end
end

--==============================--
--desc:任务红点
--time:2018-09-11 05:42:16
--@return 
--==============================--
function BttleTopDramaView:checkTaskRed()
	local is_show = false
	if self.task_icon_vo and self.task_icon_vo.tips_status_list and next(self.task_icon_vo.tips_status_list or {}) ~= nil then
		for i, v in ipairs(self.task_icon_vo.tips_status_list) do
			if v.num > 0 then
				is_show = true
				break
			end
		end
	end
	if self.task_icon and not _tolua_isnull(self.task_icon.tips) then
		self.task_icon.tips:setVisible(is_show)
	end
end

--==============================--
--desc:创建冒险图标
--time:2018-09-11 05:55:16
--@return 
--==============================--
function BttleTopDramaView:updateQingbaoInfo()
    if _tolua_isnull(self.top_info_container) then return end
    if self.qingbao_node == nil then
        self.qingbao_node = createCSBNote(PathTool.getTargetCSB("battledrama/battle_drama_qingbao_node"))
        self.qingbao_node:setAnchorPoint(cc.p(0.5, 0.5))
        self.top_info_container:addChild(self.qingbao_node)

        self.qingbao_node.index = 1
        self.right_btn_list[1] = self.qingbao_node

        self.qingbao_container = self.qingbao_node:getChildByName("guidesign_tipsqingbao")
        self.qingbao_container:getChildByName("label"):setString(TI18N("远航"))        

        local qingbao_progress_container = self.qingbao_container:getChildByName("progress_container") 

        self.qingbao_progress = cc.ProgressTimer:create(createSprite(PathTool.getResFrame("battledrama", "battledrama_1021"), 40, 40, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST))
        self.qingbao_progress:setPosition(40, 40)
        self.qingbao_progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        qingbao_progress_container:addChild(self.qingbao_progress)

        self.qingbao_progress_value = self.qingbao_container:getChildByName("value")        -- 情报值
        self.qingbao_progress_tips = self.qingbao_container:getChildByName("tips")          -- 情报红点
        local red_status = VoyageController:getInstance():getModel():checkVoyageRedStatus()
        self.qingbao_progress_tips:setVisible(red_status)

        self.qingbao_container:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                local lev_config = Config.ShippingData.data_const["guild_lev"]
                if lev_config and self.role_vo and lev_config.val <= self.role_vo.lev then
                    VoyageController:getInstance():openVoyageMainWindow(true)
                elseif lev_config then
                    message(lev_config.desc)
                end
            end
        end)

        self:updateRightBtnPos(true)
    end
    if self.role_vo then
        local cur_energy = self.role_vo.energy
        local max_energy = self.role_vo.energy_max
        self.qingbao_progress:setPercentage(100*cur_energy/max_energy)
        self.qingbao_progress_value:setString(cur_energy)
    end
end

--==============================--
--desc:右边的图标列表,包含了日常和情报
--time:2018-11-19 07:42:45
--@return 
--==============================--
function BttleTopDramaView:updateRightBtnPos(is_right)
    if _tolua_isnull(self.top_info_container) then return end
    local btn_dict = {}
    if is_right == true then
        btn_dict = self.right_btn_list 
    else
        btn_dict = self.left_btn_list
    end
    if btn_dict == nil or next(btn_dict) == nil then return end
    local btn_list = {}
    for k,v in pairs(btn_dict) do
        if v.index ~= nil then
            _table_insert(btn_list, {index = v.index or 0, node = v})
        end
        
    end
    table.sort( btn_list, function(a, b) 
        return a.index < b.index
    end)

    local top_size = self.top_info_container:getContentSize()
    for i,v in ipairs(btn_list) do
        local _x, _y = 0, 0
        if is_right then
            _x = top_size.width - 73
            _y = top_size.height - 188 - (i - 1) * 94
        else
            _x = top_size.width - 200 -(i - 1) * 94 
            _y = top_size.height - 40
        end
        
        if v.node and not _tolua_isnull(v.node) then
            v.node:setPosition(cc.p(_x, _y))    
        end
    end
end

--==============================--
--desc:右边章节奖励
--time:2018-09-11 02:59:45
--@return 
--==============================--
function BttleTopDramaView:updatePassCahpterInfo()
    if _tolua_isnull(self.top_info_container) then return end
    local config = self.model:getNewDramaRewardID()
    local need_update_pos = false
    if config then
        if self.reward_btn == nil then
            self.reward_btn = self:createSpecialIcon(PathTool.getResFrame("battledrama","battledrama_1018"), TI18N("通关奖励"), LOADTEXT_TYPE_PLIST)
            self.top_info_container:addChild(self.reward_btn)
            
            self.reward_btn.index = 3
            self.left_btn_list[3] = self.reward_btn

            -- 引导需要
            self.reward_btn:setName("guidesign_battle_reward_btn")
            
            if not _tolua_isnull(self.reward_btn) then
                self.reward_btn:addTouchEventListener(function(sender, event_type)
                    customClickAction(sender, event_type)
                    if event_type == ccui.TouchEventType.ended then
                        BattleDramaController:getInstance():openDramRewardView(true)
                    end
                end)
            end
            need_update_pos = true
        end
        -- 设置显示红点
        if not _tolua_isnull(self.reward_btn.tips) then
            local status = self.model:getDramaRewardRedPointInfo()
            self.reward_btn.tips:setVisible(status)
        end
    else
        if not _tolua_isnull(self.reward_btn) then
            --全副本通关，所有通关奖励领取完毕后清除按钮
            _table_remove(self.left_btn_list, self.reward_btn.index)
            self.reward_btn:removeFromParent()
            self.reward_btn = nil
            need_update_pos = true
        end
    end
    if need_update_pos then
        self:updateRightBtnPos(false)
    end
end

--==============================--
--desc:更新排行榜数据
--time:2018-11-19 08:00:10
--@status:
--@return 
--==============================--
-- function BttleTopDramaView:updateRankInfo(status)
--     if status == false then return end
--     if self.rank_icon_vo == nil then
--         local rank_icon_vo = MainuiController:getInstance():getFucntionIconVoById(MainuiConst.icon.rank)
--         if rank_icon_vo == nil then return end
        
--         self.rank_icon_vo = rank_icon_vo
--         self.rank_icon = self:createSpecialIcon(PathTool.getResFrame("battledrama", "battledrama_1015"), TI18N("排行榜"), LOADTEXT_TYPE_PLIST)
--         self.top_info_container:addChild(self.rank_icon)
        
--         self.rank_icon.index = 4
--         self.left_btn_list[4] = self.rank_icon
        
--         self.rank_icon:addTouchEventListener(function(sender, event_type)
--             customClickAction(sender, event_type)
--             if event_type == ccui.TouchEventType.ended then
--                 RankController:getInstance():openRankView(true, RankConstant.RankType.drama)
--             end
--         end)

--         self:updateRightBtnPos(false)
--     end 
-- end

--==============================--
--desc:通关录像图标(现改为我要变强)
--time:2018-12-17 10:40:45
--@return 
--==============================--
function BttleTopDramaView:updatePassCahpterVideo( )
    if _tolua_isnull(self.top_info_container) then return end
    local need_update_pos = false
    if self.strong_btn == nil then
        self.strong_btn = self:createSpecialIcon(PathTool.getResFrame("battledrama","battledrama_1024"), TI18N("我要变强"), LOADTEXT_TYPE_PLIST)
        self.top_info_container:addChild(self.strong_btn)
        
        self.strong_btn.index = 2
        self.left_btn_list[2] = self.strong_btn

        -- 引导需要
        self.strong_btn:setName("hero_btn")
        
        if not _tolua_isnull(self.strong_btn) then
            self.strong_btn:addTouchEventListener(function(sender, event_type)
                customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playButtonSound2()
                    StrongerController:getInstance():openMainWin(true)
                end
            end)
        end

        need_update_pos = true
    end

    if need_update_pos then
        self:updateRightBtnPos()
    end
end

--==============================--
--desc:冒险奇遇图标
--time:2019-10-11 10:40:45
--@return 
--==============================--
--[[function BttleTopDramaView:updateEncounter( )
    local encounter_lev = Config.EncounterData.data_encounter_const.encounter_lev
    if self.role_vo and encounter_lev ~= nil and self.role_vo.lev < encounter_lev.val then return end
    if _tolua_isnull(self.top_info_container) then return end
    
    if self.encounter_btn == nil then
        self.encounter_btn = self:createSpecialIcon(PathTool.getResFrame("battledrama","battledrama_1024"), TI18N("冒险奇遇"), LOADTEXT_TYPE_PLIST)
        self.top_info_container:addChild(self.encounter_btn)
        
        if not _tolua_isnull(self.encounter_btn) then
            self.encounter_btn:addTouchEventListener(function(sender, event_type)
                customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playButtonSound2()
                    local encounterId = EncounterController:getInstance():getModel():getEncounterId()
                    EncounterController:getInstance():openEncounterWindow(true,encounterId)    
                end
            end)
        end
    end
    local top_size = self.top_info_container:getContentSize()
    self.encounter_btn:setPosition(top_size.width - 165, top_size.height - 200)
    self:checkEncounterRed()
end--]]

function BttleTopDramaView:checkEncounterRed( )
    local is_show_red = EncounterController:getInstance():getModel():getRedStatus()
    if self.encounter_btn then
        addRedPointToNodeByStatus(self.encounter_btn, is_show_red, 5, 5)
	end
end

function BttleTopDramaView:checkEncounterOpenStatus( )
    local is_open = true
    local encounter_lev = Config.EncounterData.data_encounter_const.encounter_lev
    if self.role_vo and encounter_lev ~= nil and self.role_vo.lev < encounter_lev.val then 
        is_open = false
    end
    if is_open then
        setChildUnEnabled(false, self.encounter_btn)
        self.encounter_btn_label:setTextColor(Config.ColorData.data_new_color4[15])
        self.encounter_btn_label:enableOutline(Config.ColorData.data_new_color4[6], 2)
    else
        setChildUnEnabled(true, self.encounter_btn)
        self.encounter_btn_label:setTextColor(Config.ColorData.data_new_color4[1])
        self.encounter_btn_label:enableOutline(Config.ColorData.data_new_color4[6], 2)
    end
end

-- 世界等级
function BttleTopDramaView:updateWorldLevelIcon(  )
    if self.role_vo and self.role_vo.lev < 60 then return end
    if _tolua_isnull(self.top_info_container) then return end
    local need_update_pos = false
    if not self.world_lv_btn then
        local top_size = self.top_info_container:getContentSize()
        local pos_x = top_size.width - 150
        local pos_y = top_size.height - 40
        self.world_lv_btn = createImage(self.top_info_container, PathTool.getResFrame("common","txt_cn_common_90022"), pos_x, pos_y, cc.p(0.5, 0.5), true)
        self.world_lv_btn:setTouchEnabled(true)

        self.world_lv_btn.index = 6
        self.left_btn_list[6] = self.world_lv_btn
        
        registerButtonEventListener(self.world_lv_btn, function (  )
            self:showWorldLevelTips(true)
        end, true)
        need_update_pos = true
    end
    if need_update_pos then
        self:updateRightBtnPos()
    end
end

-- 显示世界等级tips
function BttleTopDramaView:showWorldLevelTips( status )
    if status == true then
        if not self.world_lv_layout then
            self.world_lv_layout = ccui.Layout:create()
            self.world_lv_layout:setTouchEnabled(true)
            self.world_lv_layout:setSwallowTouches(false)
            self.world_lv_layout:setContentSize(self.main_size)
            self.world_lv_layout:setLocalZOrder(999)
            self.world_lv_layout:setAnchorPoint(cc.p(0.5, 0.5))
            self.world_lv_layout:setPosition(self.main_size.width * 0.5, self.main_size.height * 0.5)
            self:addChild(self.world_lv_layout)
            registerButtonEventListener(self.world_lv_layout, function (  )
                self:showWorldLevelTips(false)
            end)

            -- 背景
            local world_pos = self.world_lv_btn:convertToWorldSpace(cc.p(0, 0))
            local local_pos = self.world_lv_layout:convertToNodeSpace(world_pos) 
            local world_lv_bg = createImage(self.world_lv_layout, PathTool.getResFrame("common","common_1034"), local_pos.x-50, local_pos.y-20, cc.p(0.5, 1), true, nil, true)
            world_lv_bg:setTouchEnabled(true)
            local world_bg_size = cc.size(400, 150)

            -- 世界等级描述
            local world_lev_cfg = Config.WorldLevData.data_const["worldlev_des"]
            if world_lev_cfg then
                local world_lv_desc = createLabel(24,Config.ColorData.data_new_color4[6],nil,30,85,world_lev_cfg.desc,world_lv_bg,nil,cc.p(0, 1))
                world_lv_desc:setMaxLineWidth(350)
                local desc_size = world_lv_desc:getContentSize()
                world_bg_size.height = world_bg_size.height + desc_size.height
                world_lv_desc:setPosition(cc.p(30, world_bg_size.height-90))
            end
            world_lv_bg:setContentSize(world_bg_size)

            -- 图标
            local world_lv_icon = createSprite(PathTool.getResFrame("common","txt_cn_common_90022"), 50, world_bg_size.height-40, world_lv_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            local world_lv_title = createLabel(26,Config.ColorData.data_new_color4[6],nil,85,world_bg_size.height-40,TI18N("世界等级"),world_lv_bg,nil,cc.p(0, 0.5))
            local world_lv_line = createSprite(PathTool.getResFrame("common","common_1072"), 200, world_bg_size.height-75, world_lv_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            world_lv_line:setScaleY(3)
            world_lv_line:setRotation(90)
            
            -- 世界等级
            self.world_lv_txt = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(30, 35))
            world_lv_bg:addChild(self.world_lv_txt)
            local world_lev = RoleController:getInstance():getModel():getWorldLev()
            self.world_lv_txt:setString(string.format(TI18N("当前世界等级:<div fontcolor=#249003>%d级</div>"), world_lev))
        end
        self.world_lv_layout:setVisible(true)
    elseif self.world_lv_layout then
        self.world_lv_layout:setVisible(false)
    end
end

--==============================--
--desc:剧情副本创建下面的挑战BOSS,快速作战,宝可梦变强,以及资产收益组件
--time:2018-11-19 02:51:24
--@return 
--==============================--
function BttleTopDramaView:createDramaButton(  )
    if not _tolua_isnull(self.btn_layout) then
        if not self.battle_button_list then
            self.battle_button_list = createCSBNote(PathTool.getTargetCSB("battle/battle_button_list"))
            self.battle_button_list:setAnchorPoint(cc.p(0.5, 0))
            local target_pos_y = MainuiController:getInstance():getBottomHeight()
            self.battle_button_list:setPositionY(-target_pos_y-25)
            self.btn_layout:addChild(self.battle_button_list)

            local image_bg = self.battle_button_list:getChildByName("image_bg")
            

            self.drama_reward_layout = self.battle_button_list:getChildByName("reward_layout")
            self.drama_item_scrollview = self.battle_button_list:getChildByName("item_scrollview")
            self.drama_item_scrollview:setScrollBarEnabled(false)
            self.drama_item_scrollview:setSwallowTouches(false)

            -- 掉落详细按钮
            --self.detail_btn = self.battle_button_list:getChildByName("detail_btn")
            --self.detail_btn:addTouchEventListener(function(sender, event_type)
            --    customClickAction(sender, event_type)
            --    if event_type == ccui.TouchEventType.ended then
            --        BattleDramaController:getInstance():openDramDropWindows(true)
            --    end
            --end)
            self.detail_btn = createRichLabel(20, Config.ColorData.data_new_color4[12] , cc.p(0.5, 0.5), cc.p(638, 302))
            self.detail_btn:setString(string.format("<div href=xxx>%s</div>", TI18N("查看详情")))
            self.detail_btn:addTouchLinkListener(function(type, value, sender, pos)
                BattleDramaController:getInstance():openDramDropWindows(true)
            end, { "click", "href" })
            self.battle_button_list:addChild(self.detail_btn)

            -- 挑战bOSS
            self.next_battle_btn = self.battle_button_list:getChildByName("guildsign_battle_boss_btn")
            self.boss_btn_notice = self.next_battle_btn:getChildByName("notice_label")
            self.boss_btn_challenge = self.next_battle_btn:getChildByName("challenge_item")
            self.boss_btn_challenge:getChildByName("label"):setString(TI18N("挑战BOSS"))

            self.boss_btn_challenge_effect = createEffectSpine(Config.EffectData.data_effect_info[107], cc.p(95, 31), cc.p(0.5, 0.5), true, PlayerAction.action, nil, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
            self.boss_btn_challenge:addChild(self.boss_btn_challenge_effect, -1)

            self.next_battle_btn:addTouchEventListener(function(sender, event_type)
                customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    if not _b_controller:getIsNoramalBattle() then
                        message(TI18N("当前正在战斗中"))
                        return
                    end
                    if self.next_battle_btn.lev_limit > 0 then
                        message(TI18N("等级不足"))
                    elseif self.next_battle_btn.battle_status == 3 then
                        _controller:send13002()
                    else
                        HeroController:getInstance():openFormGoFightPanel(true)
                    end
                end
            end)
            
            -- 冷却时间
            self.next_battle_time = self.battle_button_list:getChildByName("next_battle_time")
            self.next_battle_time_label = self.next_battle_time:getChildByName("label")
            
            -- 冒险奇遇 --改为我要变强
            self.encounter_btn = self.battle_button_list:getChildByName("encounter_btn")
            self.encounter_btn_label = self.encounter_btn:getChildByName("label")
            self.encounter_btn_label:setString(TI18N("我要变强"))
            self.encounter_btn:addTouchEventListener(function(sender, event_type)
                customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playButtonSound2()
                    StrongerController:getInstance():openMainWin(true)
                    --宝可梦物语代码
                    -- local encounter_lev = Config.EncounterData.data_encounter_const.encounter_lev
                    -- if self.role_vo and encounter_lev ~= nil and self.role_vo.lev < encounter_lev.val then 
                    --     message(_string_format(TI18N("%d级解锁"),encounter_lev.val))
                    --     return
                    -- end

                    -- local encounterId = EncounterController:getInstance():getModel():getEncounterId()
                    -- EncounterController:getInstance():openEncounterWindow(true,encounterId)  
                end
            end)
            -- self:checkEncounterRed()
            -- self:checkEncounterOpenStatus()
            
            -- 引导需要
            self.encounter_btn:setName("hero_btn")

            -- 快速作战
            self.quick_battle_btn = self.battle_button_list:getChildByName("guidesign_battle_quick_btn")
            self.quick_battle_label = self.quick_battle_btn:getChildByName("label")
            self.quick_battle_label:setString(TI18N("快速作战"))
            self.quick_battle_tips = self.quick_battle_btn:getChildByName("tips")
            self.quick_battle_btn:addTouchEventListener(function(sender, event_type)
                customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.ended and self.quick_battle_status == true then
                    _controller:openDramBattleQuickView(true)
                    _drama_model:setOpenQuickBattleStatus(true)
                    _drama_model:checkRedPoint()
                    self.quick_battle_tips:setVisible(false)
                end
            end)
        end
        
        -- 当前资源宝箱
        if not self.resour_collect then
            self.resour_collect = createCSBNote(PathTool.getTargetCSB("battle/battle_resources_collect"))
            self.resour_collect:setPosition(- 326, 270)
            self.resour_collect:setLocalZOrder(999)
            self.btn_layout:addChild(self.resour_collect)
            
            self.is_in_collect = false
            
            local container = self.resour_collect:getChildByName("container")
            self.resources_progress = container:getChildByName("progress")              -- 宝箱进度
            local time_container = container:getChildByName("time_container")
            self.resources_time_label = time_container:getChildByName("time_label")
            local resources_model = self.resour_collect:getChildByName("resources_model")
            self.resources_box = createEffectSpine(PathTool.getEffectRes(282), cc.p(50, 5), cc.p(0.5, 0.5), true, PlayerAction.action)  -- 宝箱特效
            self.resources_box:setScale(0.5)
            resources_model:addChild(self.resources_box)
            resources_model:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playButtonSound2()
                    local hook_info = _drama_model:getHookAccumulateInfo()
                    if hook_info == nil then return end
                    local hook_time = hook_info.hook_time or 0
                    local cost_config = Config.DungeonData.data_drama_const.hangup_revenue

                    if hook_time < cost_config.val then
                        message(TI18N("需要累积一定收益才能领取噢~"))
                    else
                        if self.is_in_collect == true then return end
                        self.is_in_collect = true

                        local requestGetAwardFunc = function (  )
                            if not _tolua_isnull(self.resources_box) then
                                --local play_action = PlayerAction.action_2
                                --if self.resources_action == PlayerAction.action_3 then
                                --    play_action = PlayerAction.action_4
                                --elseif self.resources_action == PlayerAction.action_5 then
                                --    play_action = PlayerAction.action_6
                                --end
                                play_action = PlayerAction.action_1
                                self.resources_action = PlayerAction.action_1
                                self.resources_box:setToSetupPose()
                                self.resources_box:setAnimation(0, play_action, false)
                                delayRun(self.resour_collect, 1.5, function()
                                    self.is_in_collect = false
                                    BattleDramaController:getInstance():requestGetHookTimeAwards()
                                end)
                            end
                        end

                        local hook_info = _drama_model:getHookAccumulateInfo()
                        local cur_energy = self.role_vo.energy
                        local max_energy = self.role_vo.energy_max
                        local qingbao_val = 0 -- 可领取的情报值
                        if hook_info and hook_info.list then
                            for k,v in pairs(hook_info.list) do
                                if v.bid == Config.ItemData.data_assets_label2id.energy then
                                    qingbao_val = v.num
                                    break
                                end
                            end
                        end
                        if (cur_energy+qingbao_val) > max_energy then
                            if self.tips_alert then
                                self.tips_alert:close()
                                self.tips_alert = nil
                            end

                            local function call_back()
                                requestGetAwardFunc()
                                if self.tips_alert then
                                    self.tips_alert:close()
                                    self.tips_alert = nil
                                end
                            end
                            local function cancel_callback(  )
                                self.is_in_collect = false
                                if self.tips_alert then
                                    self.tips_alert:close()
                                    self.tips_alert = nil
                                end
                            end
                            local str = string.format(TI18N("当前已有<div fontcolor=#249003>%s/%s</div>远航情报，领取后超出上限部分将损失，是否确认领取？"), cur_energy, max_energy)
                            self.tips_alert = CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), cancel_callback, CommonAlert.type.rich,nil,nil,24)
                        else
                            requestGetAwardFunc()
                        end
                    end
                end
            end)
            
            self.resources_action = PlayerAction.action
            self:updateResourceCollect()
        end
        
        self:updateNextBtnStatus(self.model:getDramaData())
        self:updateDramaDropInfo()
        self:updateBtnLayerStatus(self.btn_layout_status)
    end
end

function BttleTopDramaView:playResourceCollect( x, y )
    if not self.resour_collect or _tolua_isnull(self.resour_collect) then return end
    if self.fly_item_sum and self.fly_item_sum >= 30 then return end  
    if self.fly_item_list and #self.fly_item_list >= 30 then return end

    local init_pos = self.btn_layout:convertToNodeSpace(cc.p(x, y))                        -- 起始位置
    local target_pos = self.resour_collect:convertToWorldSpace(cc.p(0, 0))
    target_pos = self.btn_layout:convertToNodeSpace(target_pos)                            -- 目标位置
    
    if self.fly_item_list == nil then
        self.fly_item_list = {}
    end
    if self.fly_cache_item_list == nil then
        self.fly_cache_item_list = {}
    end
    -- local wealth_list = {2, 5, 10008, 40204}
    local sum = math.random(10, 11)
    for i = 1, sum do
        local _x =(1 - math.random(0, 2)) * math.random(0, 40) + init_pos.x
        local _y =(1 - math.random(0, 2)) * math.random(0, 40) + init_pos.y
        -- local _index = math.random(1,#wealth_list)
        local _index = math.random(1, 4)
        local _item_res = PathTool.getResFrame("battledrama", "battledrama_resoure_" .. _index)
        
        local object = {}
        if #self.fly_cache_item_list == 0 then
            object.item = createSprite(_item_res, _x, _y, self.btn_layout, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 999)
            object.res_id = _item_res
        else
            object = _table_remove(self.fly_cache_item_list, 1)         -- 取出第一个
        end
        
        if object.item and object.res_id then
            object.item:setScale((1))
            object.item:setVisible(true)
            object.item:setPosition(_x, _y)
            if object.res_id ~= _item_res then
                object.res_id = _item_res
                loadSpriteTexture(object.item, _item_res, LOADTEXT_TYPE_PLIST)
            end
            _table_insert(self.fly_item_list, object)
        end
    end
    -- 定时飞
    if self.fly_timer == nil then
        self.fly_timer = GlobalTimeTicket:getInstance():add(function()
            if self.fly_item_list == nil or next(self.fly_item_list) == nil then
                self:clearFlyTimer()
                return
            end
            local object = table.remove(self.fly_item_list, 1)
            local _x, _y = object.item:getPosition()
            self.fly_item_sum = self.fly_item_sum + 1
            self:flyEnergyToWealth(object, cc.p(_x, _y), target_pos, #self.fly_item_list + 1)
        end, 0.01)
    end
end

function BttleTopDramaView:flyEnergyToWealth(object, init_pos, target_pos, index)
    if object == nil or _tolua_isnull(object.item) then return end
    
    local bezier = {}
    local begin_pos = cc.p(init_pos.x, init_pos.y)
    table.insert(bezier, begin_pos)
    
    local end_pos = cc.p(target_pos.x + 55, target_pos.y + 55)
    local min_pos = cc.pMidpoint(begin_pos, end_pos)
    
    local off_y = 10
    local off_x = - 30
    if index % 2 == 0 then
        off_y = math.random(100, 150)
        off_x = 30
    end
    
    local controll_pos = cc.p(min_pos.x + off_x, begin_pos.y - off_y)
    table.insert(bezier, controll_pos)
    table.insert(bezier, end_pos)
    
    local bezierTo = cc.BezierTo:create(1, bezier)
    local call_fun = cc.CallFunc:create(function()
        object.item:setVisible(false)
        self.fly_item_sum = self.fly_item_sum - 1
        _table_insert(self.fly_cache_item_list, object)
    end)
    
    local seq = cc.Sequence:create(bezierTo, call_fun)
    local scale_to = cc.ScaleTo:create(1, 0.2)
    local spawn = cc.Spawn:create(scale_to, seq)
    object.item:runAction(spawn)
end

-- 将fly_item_list中全部移到cache中
function BttleTopDramaView:clearAllFlyItemList(  )
    if self.fly_item_list and self.fly_cache_item_list then
        for i=#self.fly_item_list,1,-1 do
            local object = table.remove(self.fly_item_list, 1)
            object.item:setVisible(false)
            _table_insert(self.fly_cache_item_list, object)
        end
    end
end

function BttleTopDramaView:clearFlyTimer()
    if self.fly_timer then
        GlobalTimeTicket:getInstance():remove(self.fly_timer)
        self.fly_timer = nil
    end
end

--==============================--
--desc:设置挑战BOSS按钮状态以及快速作战的红点
--time:2017-08-15 09:55:18
--@time:倒计时时间
--@return
--==============================--
function BttleTopDramaView:updateNextBtnStatus(data)
    if data == nil then return end
    local status = 0
    self:checkQuickRed()
    if not _tolua_isnull(self.next_battle_btn) and not _tolua_isnull(self.next_battle_time) then
        self.next_battle_time:setVisible(false)
        self.next_battle_btn:setVisible(false)
        self.next_battle_btn.lev_limit = 0
        
        local cur_dungeon_config = Config.DungeonData.data_drama_dungeon_info(data.max_dun_id)
        if cur_dungeon_config then
            local next_id = cur_dungeon_config.next_id
            if next_id == 0 then
                self.next_battle_btn:setVisible(false)
                return
            end
        end
        
        if data.status == 2 and data.cool_time == 0 then            --可挑战
            local role_vo_lev = RoleController:getInstance():getRoleVo().lev or 0
            local config = Config.DungeonData.data_drama_dungeon_info(data.dun_id)
            self.next_battle_btn:setVisible(true)
            status = data.status
            if config and config.lev_limit and config.lev_limit > role_vo_lev then
                self.next_battle_btn.lev_limit = config.lev_limit
                self.boss_btn_notice:setVisible(true)
                self.boss_btn_challenge:setVisible(false)
                self.boss_btn_notice:setString(string.format(TI18N("%s级可挑战"), config.lev_limit))
            else
                self.boss_btn_notice:setVisible(false)
                self.boss_btn_challenge:setVisible(true)
            end
        elseif data.status == 1 and data.cool_time ~= 0 then        --冷却中
            status = data.status
            self.next_battle_time:setVisible(true)
            self.next_battle_btn:setVisible(false)
            self:updateCoolTimer(data.cool_time)
        elseif data.status == 3 then                                --已通过
            status = data.status
            self.next_battle_btn:setVisible(true)
            self.boss_btn_notice:setVisible(true)
            self.boss_btn_challenge:setVisible(false)
            self.boss_btn_notice:setString(TI18N("前往下一章"))
        end
        -- 保存一下挑战按钮的状态
        self.next_battle_btn.battle_status = status
    end
end

--==============================--
--desc:挑战BOSS倒计时
--time:2017-08-15 09:55:18
--@time:倒计时时间
--@return
--==============================--
function BttleTopDramaView:updateCoolTimer(time)
    if _tolua_isnull(self.next_battle_time_label) then return end
    if time ~= 0 and time then
        if not self.cool_timer then
            self.battl_cool_timer = 0
            self.next_battle_time_label:setString(TimeTool.GetMinSecTime(time - GameNet:getInstance():getTime()))
            
            local call_back = function()
                self.battl_cool_timer = time - GameNet:getInstance():getTime()
                local new_time = self.battl_cool_timer or 0
                if new_time >= 1 and new_time ~= nil then
                    if not _tolua_isnull(self.next_battle_time_label) then
                        self.next_battle_time_label:setString(TimeTool.GetMinSecTime(new_time))
                    end
                else
                    self:clearCoolTimer()
                end
            end
            self.cool_timer = GlobalTimeTicket:getInstance():add(call_back, 1, 0)
        end
    else
        self:clearCoolTimer()
    end
end

function BttleTopDramaView:clearCoolTimer()
    if self.cool_timer then
        GlobalTimeTicket:getInstance():remove(self.cool_timer)
        self.cool_timer = nil
    end
end

--==============================--
--desc:更新快速作战红点状态
--time:2018-11-19 02:21:09
--@return 
--==============================--
function BttleTopDramaView:checkQuickRed()
    local drama_data = _drama_model:getDramaData()
    if drama_data == nil then return end
    if not _tolua_isnull(self.quick_battle_btn) then
        local limit_dun = Config.DungeonData.data_drama_const["fast_combat_first"].val
        local is_open = false
        if drama_data.max_dun_id >= limit_dun then
            is_open = true
        end
        if self.quick_battle_status ~= is_open then
            self.quick_battle_status = is_open
            if is_open then
                setChildUnEnabled(false, self.quick_battle_btn)
                --self.quick_battle_label:setTextColor(cc.c4b(0xff,0xf4,0xc8,0xff))
                --self.quick_battle_label:enableOutline(cc.c4b(0x4f,0x16,0x00,0xff), 2)
            else
                setChildUnEnabled(true, self.quick_battle_btn)
                --self.quick_battle_label:setTextColor(Config.ColorData.data_color4[1])
                --self.quick_battle_label:enableOutline(cc.c4b(0x49,0x49,0x49,0xff), 2)
            end
        end
        
        if _drama_model:getOpenQuickBattleStatus() == false then --有免费次数
            local data = _drama_model:getQuickData()
            local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const["quick_swap_item"].val)
            if is_open == true then
                if data and data.fast_combat_num == 0 or num > 0 then
                    self.quick_battle_tips:setVisible(true)
                end
            end
        else
            self.quick_battle_tips:setVisible(false)
        end
    end
end

-- 刷新副本挂机收益、掉落信息
function BttleTopDramaView:updateDramaDropInfo(  )
    if self.drama_reward_layout and not _tolua_isnull(self.drama_reward_layout) then
        local drama_data = _drama_model:getDramaData()
        if drama_data == nil then return end
        local drama_config
        if not self.cur_drama_max_id and drama_data.max_dun_id == 0 then
            drama_config = Config.DungeonData.data_drama_dungeon_info(10010)
        else
            if self.cur_drama_max_id == drama_data.max_dun_id then return end
            drama_config = Config.DungeonData.data_drama_dungeon_info(drama_data.max_dun_id)
        end
        if drama_config == nil then return end
        self.cur_drama_max_id = drama_data.max_dun_id
        -- 挂机收益信息
        self.drama_item_labels = self.drama_item_labels or {}
        for i,v in ipairs(self.drama_item_labels) do
            v:setVisible(false)
        end
        local start_x = 0
        local offset_x = 30
        local label_len = 0
        for i, v in ipairs(drama_config.per_hook_items) do
            local label = self.drama_item_labels[i]
            if label == nil then
                label = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0,0.5), cc.p(_x, 22), nil, nil, 180)
                self.drama_item_labels[i] = label
                self.drama_reward_layout:addChild(label)
            end
            local config = Config.ItemData.data_get_data(v[1])
            local str = string.format(TI18N("<img src=%s visible=true scale=0.3 />%s/m"), PathTool.getItemRes(config.icon), v[2])
            label:setString(str)
            label:setVisible(true)
            local _x = start_x + label_len
            label:setPositionX(_x)
            label_len = label_len + label:getContentSize().width + offset_x
        end

        -- 关卡掉落信息
        self.drama_item_list = self.drama_item_list or {}
        for k,v in pairs(self.drama_item_list) do
            v:setVisible(false)
        end
        local item_datas = drama_config.hook_show_items
        local scale = 0.7
        local space_x = 18
        local start_x = 5
        local total_width = #item_datas * BackPackItem.Width * scale + (#item_datas-1) * space_x
        local max_width = math.max(self.drama_item_scrollview:getContentSize().width, total_width)
        self.drama_item_scrollview:setInnerContainerSize(cc.size(max_width, self.drama_item_scrollview:getContentSize().height))

        for i, v in ipairs(item_datas) do
            if self.init_drop_flag then
                self:createDramaDropItem( v, i, scale, space_x, start_x)
            else
                delayRun(self.drama_item_scrollview,i / display.DEFAULT_FPS,function ()
                    self:createDramaDropItem( v, i, scale, space_x, start_x)
                    self.init_drop_flag = true -- 创建的时候才分帧
                end)
            end
        end
    end
end

function BttleTopDramaView:createDramaDropItem( data, index, scale, space_x, start_x )
    local item = self.drama_item_list[index]
    if not item then
        item = BackPackItem.new(true, true)
        item:setDefaultTip()
        item:setAnchorPoint(0, 0.5)
        item:setScale(scale)
        self.drama_item_scrollview:addChild(item)
        self.drama_item_list[index] = item
    end
    item:setVisible(true)
    local _x = start_x + (index - 1) * (BackPackItem.Width * scale + space_x)
    item:setPosition(_x, self.drama_item_scrollview:getContentSize().height / 2)
    item:setBaseData(data[1], data[2], true)
end

function BttleTopDramaView:updateBtnLayerStatus( status )
    self.btn_layout_status = status -- 缓存一下显示状态
    if self.btn_layout and not _tolua_isnull(self.btn_layout) then
        self.btn_layout:setVisible(status)
        -- 剧情战斗
        if self.battle_type == BattleConst.Fight_Type.Darma then
            self.btn_layout:setVisible(true)
            if self.resour_collect then
                self.resour_collect:setVisible(status)
            end
            if self.hallows_layout then
                self.hallows_layout:setVisible(status)
            end
            if self.boss_btn_challenge_effect then
                self.boss_btn_challenge_effect:setVisible(status)
            end
        else
            self.btn_layout:setVisible(status)
        end
    end
end

-- 创建剧情副本的战法相关
function BttleTopDramaView:updataZhenfaInfo( status, data )
    if status == true then
        if data.formation == nil then return end
        local form_info = {}
        for i, v in pairs(data.formation) do
            form_info[v.group] = {v.formation_type or 1, v.formation_lev or 0}
        end
        -- 不满足任何一个条件,都直接不处理
        if form_info[1] == nil or form_info[2] == nil or form_info[1][1] == nil or form_info[1][2] == nil or form_info[2][1] == nil or form_info[2][2] == nil then return end
        if self.btn_layout and not _tolua_isnull(self.btn_layout) then
            if _tolua_isnull(self.form_view) then
                self.form_view = createCSBNote(PathTool.getTargetCSB("battle/battle_form_view"))
                self.form_view:setAnchorPoint(cc.p(0.5, 0))
                self.btn_layout:addChild(self.form_view, 999)
                self.form_view:setPosition(0, 258)
                
                self.left_btn = self.form_view:getChildByName("left_btn")
                self.left_form_icon = self.left_btn:getChildByName("icon")
                
                self.right_btn = self.form_view:getChildByName("right_btn")
                self.right_form_icon = self.right_btn:getChildByName("icon")

                self.buff_btn = self.form_view:getChildByName("buff_btn")
                self.buff_btn:setOpacity(0)
                self.buff_btn:runAction(cc.FadeIn:create(0.7)) -- 延迟一些显示，避免可能打开buff界面却还没有数据
                registerButtonEventListener(self.buff_btn, function (  )
                    local left_name = data.actor_role_name
                    local right_name = data.target_role_name
                    local group = _b_controller:getModel():getGroup()
                    if group == BattleGroupTypeConf.TYPE_GROUP_ENEMY and not _b_controller:getWatchReplayStatus() then
                        left_name = data.target_role_name
                        right_name = data.actor_role_name
                    end
                    _b_controller:openBattleBuffInfoView(true, left_name, right_name)
                end, false)

                local image_2 = self.form_view:getChildByName("image_2")
                self.round_label = image_2:getChildByName("round_label")

                self.left_name_panel = self.form_view:getChildByName("left_name_panel")
                self.right_name_panel = self.form_view:getChildByName("right_name_panel")
                self.left_name_label = self.left_name_panel:getChildByName("left_name_label")
                self.right_name_label = self.right_name_panel:getChildByName("right_name_label")

                self.left_camp_btn = self.form_view:getChildByName("left_camp_btn")
                self.right_camp_btn = self.form_view:getChildByName("right_camp_btn")
            end
            
            -- 阵法图标
            if not _tolua_isnull(self.form_view) then
                loadSpriteTexture(self.left_form_icon, PathTool.getResFrame("battle", "battle_form_icon_" .. form_info[1] [1]), LOADTEXT_TYPE_PLIST)
                loadSpriteTexture(self.right_form_icon, PathTool.getResFrame("battle", "battle_form_icon_" .. form_info[2] [1]), LOADTEXT_TYPE_PLIST)
            end

            -- 阵营图标
            local halo_list = data.halo_list or {}
            local left_halo_id = 0  -- 左侧光环id
            local right_halo_id = 0 -- 右侧光环id
            for k,v in pairs(halo_list) do
                if v.group == 1 then
                    left_halo_id = v.type
                elseif v.group == 2 then
                    right_halo_id = v.type
                end
            end
            local left_halo_id_list = {}
            local right_halo_id_list = {}
            -- 兼容旧的录像数据，可能发过来的阵营光环id还是旧的，需要转换为新的id
            if left_halo_id < 100 then
                left_halo_id_list = BattleConst.Old_Halo_Id_Change[left_halo_id] or {}
            else
                local left_id_1 = math.floor(left_halo_id/10000)
                local left_id_2 = math.floor((left_halo_id%10000)/100)
                local left_id_3 = left_halo_id%100
                if left_id_1 > 0 then
                    _table_insert(left_halo_id_list, left_id_1)
                end
                if left_id_2 > 0 then
                    _table_insert(left_halo_id_list, left_id_2)
                end

                if left_id_3 > 0 then
                    _table_insert(left_halo_id_list, left_id_3)
                end
            end
            -- 兼容旧的录像数据，可能发过来的阵营光环id还是旧的，需要转换为新的id
            if right_halo_id < 100 then
                right_halo_id_list = BattleConst.Old_Halo_Id_Change[right_halo_id] or {}
            else
                local right_id_1 = math.floor(right_halo_id/10000)
                local right_id_2 = math.floor((right_halo_id%10000)/100)
                local right_id_3 = right_halo_id%100
                if right_id_1 > 0 then
                    _table_insert(right_halo_id_list, right_id_1)
                end
                if right_id_2 > 0 then
                    _table_insert(right_halo_id_list, right_id_2)
                end
                if right_id_3 > 0 then
                    _table_insert(right_halo_id_list, right_id_3)
                end
            end
            if not _tolua_isnull(self.left_camp_btn) then
                local halo_res = PathTool.getCampGroupIcon( 1000 )
                local halo_icon_config = BattleController:getInstance():getModel():getCampIconConfigByIds(left_halo_id_list)
                if halo_icon_config and halo_icon_config.icon then
                    halo_res = PathTool.getCampGroupIcon(halo_icon_config.icon)
                    if not self.left_camp_effect then
                        local btn_size = self.left_camp_btn:getContentSize()
                        self.left_camp_effect = createImage(self.left_camp_btn, PathTool.getResFrame("common", "common_1101"), btn_size.width/2, btn_size.height/2, cc.p(0.5, 0.5), true)
                        self.left_camp_effect:setScale(0.8)
                    end
                    self:updateCampEffect(true, self.left_camp_effect)
                    addCountForCampIcon(self.left_camp_btn, halo_icon_config.nums)
                else
                    self:updateCampEffect(false, self.left_camp_effect)
                    addCountForCampIcon(self.left_camp_btn)
                end
                self.left_halo_load = loadImageTextureFromCDN(self.left_camp_btn, halo_res, ResourcesType.single, self.left_halo_load)
                local function onClickLeftCampBtn(  )
                    _b_controller:openBattleCampView(true, left_halo_id_list)
                end
                registerButtonEventListener(self.left_camp_btn, onClickLeftCampBtn, true,nil,nil,0.85)
            end
            if not _tolua_isnull(self.right_camp_btn) then
                local halo_res = PathTool.getCampGroupIcon( 1000 )
                local halo_icon_config = BattleController:getInstance():getModel():getCampIconConfigByIds(right_halo_id_list)
                if halo_icon_config and halo_icon_config.icon then
                    halo_res = PathTool.getCampGroupIcon(halo_icon_config.icon)
                    if not self.right_camp_effect then
                        local btn_size = self.right_camp_btn:getContentSize()
                        self.right_camp_effect = createImage(self.right_camp_btn, PathTool.getResFrame("common", "common_1101"), btn_size.width/2, btn_size.height/2, cc.p(0.5, 0.5), true)
                        self.right_camp_effect:setScale(0.8)
                    end
                    self:updateCampEffect(true, self.right_camp_effect)
                    addCountForCampIcon(self.right_camp_btn, halo_icon_config.nums)
                else
                    self:updateCampEffect(false, self.right_camp_effect)
                    addCountForCampIcon(self.right_camp_btn)
                end
                self.right_halo_load = loadImageTextureFromCDN(self.right_camp_btn, halo_res, ResourcesType.single, self.right_halo_load)
                local function onClickRightCampBtn(  )
                    _b_controller:openBattleCampView(true, right_halo_id_list)
                end
                registerButtonEventListener(self.right_camp_btn, onClickRightCampBtn, true,nil,nil,0.85)
            end

            -- 对阵双方名称
            local name1 = data.actor_role_name
            local name2 = data.target_role_name
            local group = _b_controller:getModel():getGroup()
            if group == BattleGroupTypeConf.TYPE_GROUP_ENEMY and not _b_controller:getWatchReplayStatus() then
                name1 = data.target_role_name
                name2 = data.actor_role_name
            end
            if name1 then
                self.left_name_label:setString(name1)
            end
            if name2 then
                self.right_name_label:setString(name2)
            end
        end
    else
        self:updateCampEffect(false, self.left_camp_effect)
        self:updateCampEffect(false, self.right_camp_effect)
        if self.form_view and not _tolua_isnull(self.form_view) then
            self.form_view:removeAllChildren()
            self.form_view:removeFromParent()
            self.form_view = nil
            self.left_camp_effect = nil
            self.right_camp_effect = nil
        end
    end
end

--更新回合
function BttleTopDramaView:updateRound(round)
    local fight_list_config = Config.CombatTypeData.data_fight_list
    if fight_list_config == nil or fight_list_config[self.battle_type] == nil then return end
    
    local total_round = fight_list_config[self.battle_type].max_action_count or 0
    if not _tolua_isnull(self.round_label) then
        self.round_label:setString(string.format(TI18N("第%d/%d回合"), round, total_round))
    end
end

-- 光环特效
function BttleTopDramaView:updateCampEffect( status, effect_node )
    if not effect_node or _tolua_isnull(effect_node) then return end
    if status == true then
        effect_node:setVisible(true)
        local fadein = cc.FadeIn:create(0.6)
        local fadeout = cc.FadeOut:create(0.6)
        effect_node:runAction(cc.RepeatForever:create(cc.Sequence:create(fadein, fadeout)))
    else
        doStopAllActions(effect_node)
        effect_node:setVisible(false)
    end
end

--==============================--
--desc:神器解锁的
--time:2018-09-28 10:40:45
--@return 
--==============================--
function BttleTopDramaView:updateDramaHallows()
    if not _tolua_isnull(self.btn_layout) then
        local hallows_model = HallowsController:getInstance():getModel()
        local is_open = HallowsController:getInstance():checkIsOpen()
        if is_open and not hallows_model:checkIsHaveAllHallows() then
            local layout_size = cc.size(160, 200)
            if not self.hallows_layout then
                self.hallows_layout = ccui.Layout:create()
                self.hallows_layout:setName("hallows_stage")
                self.hallows_layout:setContentSize(layout_size)
                self.hallows_layout:setPosition(cc.p(-self.main_size.width/2+layout_size.width/2, self.main_size.height/2+240))
                self.hallows_layout:setAnchorPoint(cc.p(0.5, 0.5))
                self.hallows_layout:setTouchEnabled(true)
                self.btn_layout:addChild(self.hallows_layout)
                self.hallows_layout:addTouchEventListener(function(sender, event_type)
                    if event_type == ccui.TouchEventType.ended then
                        playCloseSound()
                        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.hallows)
                    end
                end)
            end

            -- 显示当前正在解锁中的神器
            local hallows_id = hallows_model:getCurActivityHallowsId()
            if not self.cur_hallows_id or self.cur_hallows_id ~= hallows_id then
                self.cur_hallows_id = hallows_id
                --if self.drama_hallows_model then
                --    self.drama_hallows_model:clearTracks()
                --    self.drama_hallows_model:removeFromParent()
                --    self.drama_hallows_model = nil
                --end
                --local hallows_config = Config.HallowsData.data_base[hallows_id]
                --if hallows_config then
                --    self.drama_hallows_model = createEffectSpine(hallows_config.effect,cc.p(layout_size.width/2, 65), cc.p(0.5,0.5), true, hallows_config.effect_standby)
                --    self.drama_hallows_model:setScale(0.5)
                --    self.hallows_layout:addChild(self.drama_hallows_model, 2)
                if self.drama_hallows_sprite then
                    self.drama_hallows_sprite:removeFromParent()
                    self.drama_hallows_sprite = nil
                end
                    self.drama_hallows_sprite = createSprite("resource/hallows/trainer_"..hallows_id..".png", layout_size.width/2, 110, self.hallows_layout, cc.p(0.5,0.5), LOADTEXT_TYPE)
                    self.drama_hallows_sprite:setScale(0.5)
                --end
            end

            -- 进度条
            if not self.hallows_progress_bg then
                local progress_bg_2 = createImage(self.hallows_layout, PathTool.getResFrame("battledrama", "battledrama_1035"), layout_size.width/2, 40, cc.p(0.5, 0.5), true,0,true)
                progress_bg_2:setContentSize(cc.size(100,30))
                self.hallows_progress_bg = createImage(self.hallows_layout, PathTool.getResFrame("battledrama", "battledrama_1026"), layout_size.width/2, 40, cc.p(0.5, 0.5), true, nil, true)
                --self.hallows_progress_bg:setContentSize(cc.size(130, 22))
                self.hallows_progress = ccui.LoadingBar:create()
                self.hallows_progress:setAnchorPoint(cc.p(0.5, 0.5))
                self.hallows_progress:loadTexture(PathTool.getResFrame("battledrama", "battledrama_1027"), LOADTEXT_TYPE_PLIST)
                self.hallows_progress:setPosition(cc.p(layout_size.width/2, 41))
                self.hallows_layout:addChild(self.hallows_progress)

                self.hallows_progress_txt = createLabel(20,1,Config.ColorData.data_new_color4[6],layout_size.width/2, 65,"",self.hallows_layout,2,cc.p(0.5, 0.5))
            end
            local hallows_task_list = HallowsController:getInstance():getModel():getHallowsTaskList(self.cur_hallows_id)
            if hallows_task_list then
                local max_num = tableLen(hallows_task_list)
                local cur_num = 0
                for k,v in pairs(hallows_task_list) do
                    if v.finish == 2 then
                        cur_num = cur_num + 1
                    end
                end
                local percent = 100 * cur_num / max_num
                self.hallows_progress:setPercent(percent)
                self.hallows_progress_txt:setString(cur_num .. "/" .. max_num)
            end

            self:updateHallowsRedStatus()
        else
            if self.drama_hallows_model then
                self.drama_hallows_model:clearTracks()
                self.drama_hallows_model:removeFromParent()
                self.drama_hallows_model = nil
            end
            if self.hallows_layout then
                self.hallows_layout:removeAllChildren()
                self.hallows_layout:removeFromParent()
                self.hallows_layout = nil
            end
            if self.update_hallows_red_status then
                GlobalEvent:getInstance():UnBind(self.update_hallows_red_status)
                self.update_hallows_red_status = nil
            end
        end
    end
end 

--==============================--
--desc:神器红点
--time:2018-11-19 06:41:15
--@return 
--==============================--
function BttleTopDramaView:updateHallowsRedStatus()
    local red_status = HallowsController:getInstance():getModel():checkRedIsShowByRedType(HallowsConst.Red_Index.task_award)
    addRedPointToNodeByStatus( self.hallows_layout, red_status, 0, -135 )
end

function BttleTopDramaView:DeleteMe()
    self:clearCoolTimer()
    self:clearFlyTimer()
    self:updataZhenfaInfo(false)
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    if self.left_halo_load then
        self.left_halo_load:DeleteMe()
        self.left_halo_load = nil
    end
    if self.right_halo_load then
        self.right_halo_load:DeleteMe()
        self.right_halo_load = nil
    end
    if self.tips_alert then
        self.tips_alert:close()
        self.tips_alert = nil
    end
    if not _tolua_isnull(self.btn_layout) then
        if self.drama_hallows_model then
            self.drama_hallows_model:clearTracks()
            self.drama_hallows_model:removeFromParent()
            self.drama_hallows_model = nil
        end
        if self.drama_item_list then
            for k,v in pairs(self.drama_item_list) do
                v:DeleteMe()
                v = nil
            end
            self.drama_item_list = {}
        end
        self.btn_layout:removeAllChildren()
        self.btn_layout = nil
    end

    if not tolua.isnull(self.online_gift_node) then 
        doStopAllActions(self.online_gift_node.label)
    end
    if self.time_ticket then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
    if self.map_name_container and not _tolua_isnull(self.map_name_container) then
        doStopAllActions(self.map_name_container)
        self.map_name_container:removeAllChildren()
        self.map_name_container = nil
    end
    _b_controller:setDramaStatus(false)
    if self.update_drama_data_event then
        GlobalEvent:getInstance():UnBind(self.update_drama_data_event)
        self.update_drama_data_event = nil
    end
    if self.update_drama_top_data_event then
        GlobalEvent:getInstance():UnBind(self.update_drama_top_data_event)
        self.update_drama_top_data_event = nil
    end
    if self.update_drama_max_id_event then
        GlobalEvent:getInstance():UnBind(self.update_drama_max_id_event)
        self.update_drama_max_id_event = nil
    end
    if self.battle_exit_event then
        GlobalEvent:getInstance():UnBind(self.battle_exit_event)
        self.battle_exit_event = nil
    end
    if self.update_drama_reward_event then
        GlobalEvent:getInstance():UnBind(self.update_drama_reward_event)
        self.update_drama_reward_event = nil
    end
    if self.update_drama_quick_data_event then
        GlobalEvent:getInstance():UnBind(self.update_drama_quick_data_event)
        self.update_drama_quick_data_event = nil
    end
    if self.update_function_status_event then
        GlobalEvent:getInstance():UnBind(self.update_function_status_event)
        self.update_function_status_event = nil
    end
    self:clearOnlineInfo()

    -- 移除任务监听
    if self.task_icon_vo then
        if self.task_icon_event then
            self.task_icon_vo:UnBind(self.task_icon_event)
            self.task_icon_event = nil
        end
        self.task_icon_vo = nil
    end

    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end

    if self.update_hallows_task_event then
        GlobalEvent:getInstance():UnBind(self.update_hallows_task_event)
        self.update_hallows_task_event = nil
    end
    if self.update_drama_hallows_event then
        GlobalEvent:getInstance():UnBind(self.update_drama_hallows_event)
        self.update_drama_hallows_event = nil
    end
    if self.update_hallows_red_status then
        GlobalEvent:getInstance():UnBind(self.update_hallows_red_status)
        self.update_hallows_red_status = nil
    end
    if self.update_hookaccumulatetime_event then
        GlobalEvent:getInstance():UnBind(self.update_hookaccumulatetime_event)
        self.update_hookaccumulatetime_event = nil
    end
    if self.update_onlinegift_event then
        GlobalEvent:getInstance():UnBind(self.update_onlinegift_event)
        self.update_onlinegift_event = nil
    end
    if self.update_online_get_event then
        GlobalEvent:getInstance():UnBind(self.update_online_get_event)
        self.update_online_get_event = nil
    end

    if self.update_voyage_red_event then
        GlobalEvent:getInstance():UnBind(self.update_voyage_red_event)
        self.update_voyage_red_event = nil
    end

    if self.update_encounter_red_event then
        GlobalEvent:getInstance():UnBind(self.update_encounter_red_event)
        self.update_encounter_red_event = nil
    end

    if self.main_point_list then
        for k, v in pairs(self.main_point_list) do
            if v then
                v:DeleteMe() 
            end
        end
    end
    if self.effect then
        self.effect:runAction(cc.RemoveSelf:create(true))
        self.effect = nil
    end
    doStopAllActions(self.top_info_container)
    doStopAllActions(self.root_wnd)
    if self.map_resources_load then
        self.map_resources_load:DeleteMe()
        self.map_resources_load = nil
    end
    if self.btn_load_1 then
        self.btn_load_1:DeleteMe()
        self.btn_load_1 = nil
    end
    if self.load_map_icon then
        self.load_map_icon:DeleteMe()
        self.load_map_icon = nil
    end
    if not _tolua_isnull(self.root) then
        self.root:removeAllChildren()
        self.root:removeFromParent()
    end
    if self then
        self:removeAllChildren()
        self:removeFromParent()
    end
end

--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-04 14:29:25
-- @description    : 
		-- 家园主场景
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert
local _table_remove = table.remove

HomeWorldScene = HomeWorldScene or BaseClass(BaseView)

function HomeWorldScene:__init()
	self.is_full_screen = true
    self.win_type = WinType.Full
	self.layout_name = "homeworld/homeworld_main_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("homeworld","homeworld_big_bg_1"), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("homeworld","homeworld_big_bg_4"), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("homeworld", "homeworld"), type = ResourcesType.plist},
	}
    --此标志.标志是家园主界面 --by lwc
    self.is_homeWorldScene = false

    self:initConfig()
end

function HomeWorldScene:initConfig(  )
	self.cur_scale_val = 1 -- 建筑当前缩放值
	self.cur_hide_status = false -- 当前是否在隐藏ui状态
	self.cur_edit_status = false -- 当前是否为编辑模式
	--self.is_myself_home = true -- 是否为玩家自己的家园
    self.cur_home_type = HomeworldConst.Type.Myself -- 当前家园的状态
	self.pet_btn_status = false -- 萌宠按钮打开状态
    self.is_need_update_role = true
    self.can_click_next_btn = false
    self.cur_player_list_index = 1
    self.cur_storey_index = 1  -- 当前楼层

	-- 角色相关
    self.visitors_list = {}  -- 来访者角色列表
    self.visitors_pool_list = {} -- 来访者缓存池

	self.unit_list = {}  -- 显示中的家具
	self.unit_pools = {} -- 家具缓存池

	self.tile_w = HomeworldConst.Tile_Width
	self.tile_h = HomeworldConst.Tile_Height

	HomeTile.init(self.tile_w*0.5, self.tile_h*0.5, HomeworldConst.Map_Width, HomeworldConst.Map_Height)

    --萌宠对象
    self.homepet_vo = HomepetController:getInstance():getModel():getHomePetVo()
end

function HomeWorldScene:open_callback(  )
	-- 背景层
	self.bg_slayer = self.root_wnd:getChildByName("bg_slayer")
	self.bg_slayer:setScale(display.getMaxScale())

	-- 触摸层
	self.touch_slayer = self.root_wnd:getChildByName("touch_slayer")
	self.touch_slayer:setScale(display.getMaxScale())

	-- 建筑相关
	self.build_container = self.root_wnd:getChildByName("build_container")
	self.build_container:setContentSize(cc.size(HomeworldConst.Build_Width, HomeworldConst.Build_Height))
	-- 房子外层
	self.build_slayer = self.build_container:getChildByName("build_slayer")
	-- 地板层
	self.floor_slayer = self.build_container:getChildByName("floor_slayer")
	-- 墙壁层
	self.wall_slayer = self.build_container:getChildByName("wall_slayer")
	-- 家具层
	self.unit_slayer = self.build_container:getChildByName("unit_slayer")
	self.unit_slayer.pos_node = cc.Node:create()
	self.unit_slayer.pos_node:setVisible(false)
	self.unit_slayer:addChild(self.unit_slayer.pos_node)

	-- 功能ui相关
	self.ui_container = self.root_wnd:getChildByName("ui_container")
	-- 缩放的滑块
	self.slider_panel = self.ui_container:getChildByName("slider_panel")
	self.slider = self.slider_panel:getChildByName("slider")
	self.slider:setBarPercent(2, 98)
    self.slider:setScale9Enabled(true)

    -- 编辑按钮
    self.edit_btn = self.ui_container:getChildByName("edit_btn")
    if self.edit_btn then
        self.edit_btn_label = self.edit_btn:getChildByName("label")
        self.edit_btn_label:setString(TI18N("编辑模式"))
    end
    self.figure_btn = self.ui_container:getChildByName("figure_btn")
    self.figure_btn:getChildByName("label"):setString(TI18N("形象设置"))
    self.storey_btn = self.ui_container:getChildByName("storey_btn")
    self.storey_btn_label = self.storey_btn:getChildByName("label")
    self.storey_btn_label:setString(TI18N("换层"))
    self.shop_btn = self.ui_container:getChildByName("shop_btn")
    self.shop_btn:getChildByName("label"):setString(TI18N("宅室商店"))
    self.my_visit_btn = self.ui_container:getChildByName("my_visit_btn")
    self.my_visit_btn:getChildByName("label"):setString(TI18N("我的拜访"))
    self.add_friend_btn = self.ui_container:getChildByName("add_friend_btn")
    self.add_friend_btn:getChildByName("label"):setString(TI18N("留言板"))
    self.close_btn = self.ui_container:getChildByName("close_btn")
    self.close_btn_label = self.close_btn:getChildByName("label")
    self.close_btn_label:setString(TI18N("退出"))
    self.back_my_btn = self.ui_container:getChildByName("back_my_btn")
    self.back_my_btn:getChildByName("label"):setString(TI18N("返回我的"))
    self.hide_btn = self.ui_container:getChildByName("hide_btn")
    self.btn_rule = self.ui_container:getChildByName("btn_rule")

    -- 引导需要
    self.shop_btn:setName("guide_shop_btn")
    if self.edit_btn then
        self.edit_btn:setName("guide_edit_btn")
    end

    -- 宠物
    self.pet_panel = self.ui_container:getChildByName("pet_panel")
    self.pet_btn = self.pet_panel:getChildByName("pet_btn")
    self.pet_btn_label = self.pet_btn:getChildByName("label")
    self.pet_btn_label:setString(TI18N("萌兽"))
    self.pet_bag = self.pet_panel:getChildByName("pet_bag")
    self.pet_bag:setVisible(false)
    self.pet_bag:setPositionY(50)
    self.pet_bag:setOpacity(0)
    self.pet_bag_label = self.pet_bag:getChildByName("label")
    self.pet_bag_label:setString(TI18N("行囊"))
    self.pet_bag_tips = self.pet_bag:getChildByName("tips_icon")
    self.pet_item = self.pet_panel:getChildByName("pet_item")
    self.pet_item:setVisible(false)
    self.pet_item:setPositionY(50)
    self.pet_item:setOpacity(0)
    self.pet_item:getChildByName("label"):setString(TI18N("物品"))
    self.pet_collect = self.pet_panel:getChildByName("pet_collect")
    self.pet_collect:setVisible(false)
    self.pet_collect:setPositionY(50)
    self.pet_collect:setOpacity(0)
    self.pet_collect:getChildByName("label"):setString(TI18N("收藏"))

    -- 我的家园产出信息
    self.my_output_panel = self.ui_container:getChildByName("my_output_panel")
    self.my_output_panel:setContentSize(cc.size(306, 164))
    self.comfort_sp = self.my_output_panel:getChildByName("sp_icon_1")
    self.comfort_label = self.my_output_panel:getChildByName("comfort_label")
    self.like_sp = self.my_output_panel:getChildByName("sp_icon_3")
    self.like_label = self.my_output_panel:getChildByName("like_label")
    self.coin_sp = self.my_output_panel:getChildByName("sp_icon_2")
    self.coin_label = self.my_output_panel:getChildByName("coin_label")
    self.storey_sp = self.my_output_panel:getChildByName("sp_icon_4")
    self.storey_label = self.my_output_panel:getChildByName("storey_label")
    self.main_storey_label = self.my_output_panel:getChildByName("main_storey_label")
    self.main_storey_label:setString(TI18N("主楼层"))
    self.main_storey_btn = self.my_output_panel:getChildByName("mian_storey_btn")
    self.main_storey_btn:getChildByName("label"):setString(TI18N("设为主楼层"))
    self.detial_btn = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(254, 30))
    self.my_output_panel:addChild(self.detial_btn)
    self.detial_btn:setString(TI18N("<div fontcolor=53de28 href=detial>查看详情</div>"))
    local function clickLinkCallBack( type, value )
        if type == "href" and value == "detial" then
            self:_onClickDetialBtn()
        end
    end
    self.detial_btn:addTouchLinkListener(clickLinkCallBack,{"href"})

    -- 别人家园的点赞信息
    self.other_like_panel = self.ui_container:getChildByName("other_like_panel")
    self.like_btn = self.other_like_panel:getChildByName("like_btn")
    self.next_btn = self.other_like_panel:getChildByName("next_btn")
    self.next_btn:getChildByName("label"):setString(TI18N("访问下位"))
    self.can_like_tips = createRichLabel(18, cc.c4b(141,133,131,255), cc.p(0.5, 0.5), cc.p(105, 20))
    self.other_like_panel:addChild(self.can_like_tips)

    -- 家园名称
    self.title_panel = self.ui_container:getChildByName("title_panel")
    self.home_name = self.title_panel:getChildByName("home_name")
    self.edit_name_btn = self.title_panel:getChildByName("edit_name_btn")

	-- 适配
	local root_off = display.getBottom(self.root_wnd)
    self.root_off = root_off
	self.root_wnd:setPositionY(self.root_wnd:getPositionY() + root_off)
	local bottom_off = display.getBottom(self.ui_container)
	local top_off = display.getTop(self.ui_container)
    self.top_off = top_off
	self.title_panel:setPositionY(top_off-root_off-100)
	self.slider_panel:setPositionY(top_off-root_off-680)
    if self.edit_btn then
    	self.edit_btn:setPositionY(top_off-root_off-435)
    end
	self.figure_btn:setPositionY(top_off-root_off-545)
    self.storey_btn:setPositionY(top_off-root_off-655)
	self.shop_btn:setPositionY(top_off-root_off-325)
    self.btn_rule:setPositionY(top_off-root_off-145)
	self.my_visit_btn:setPositionY(top_off-root_off-215)
	self.add_friend_btn:setPositionY(top_off-root_off-330)
	self.close_btn:setPositionY(top_off-root_off-215)
	self.hide_btn:setPositionY(top_off-root_off-310)

	self.back_my_btn:setPositionY(bottom_off-root_off+200)
	self.pet_panel:setPositionY(bottom_off-root_off+205)
	self.my_output_panel:setPositionY(bottom_off-root_off+145)
	self.other_like_panel:setPositionY(bottom_off-root_off+160)

	self:updateBuildMinMaxPos()
    self._init_end_flag = true -- 初始化完成
end

function HomeWorldScene:register_event(  )
	self.slider:addEventListener(function ( sender,event_type )
        if event_type == ccui.SliderEventType.percentChanged then
            local slider_percent = self.slider:getPercent()
            self:onSliderScaleBuild(slider_percent)
        end
    end)

    self.touch_slayer:addTouchEventListener(function ( sender, event_type )
    	if self.cur_hide_status then return end -- 隐藏期间，不允许移动
    	if event_type == ccui.TouchEventType.began then
    		self.last_pos = sender:getTouchBeganPosition()
            for k,unit in pairs(self.unit_list) do
                unit:updateEditStatus(false)
            end
            self:showUnitTouchMask(false)        
    	elseif event_type == ccui.TouchEventType.moved then
    		local touch_move_pos = sender:getTouchMovePosition()
    		if self.last_pos then
    			local offset_x = touch_move_pos.x - self.last_pos.x
    			local offset_y = touch_move_pos.y - self.last_pos.y
    			self.last_pos = touch_move_pos
    			self:onTouchMoveBuild(offset_x, offset_y)
    		end
    	end
    end)

    -- 退出
    registerButtonEventListener(self.close_btn, function (  )
        self:onClickCloseBtn()
    end, true, 2)

    -- 改名
    registerButtonEventListener(self.edit_name_btn, function (  )
    	self:_onClickChangeName()
    end, true)

    -- 编辑
    registerButtonEventListener(self.edit_btn, function (  )
    	self:changeEditStatus(not self.cur_edit_status)
    end, true)

    -- 形象设置
    registerButtonEventListener(self.figure_btn, function (  )
    	_controller:openHomeworldFigureWindow(true)
    end, true)

    -- 换层
    registerButtonEventListener(self.storey_btn, function (  )
        self:_onClickStoreyBtn()
    end, true, 1, nil, nil, 0.5)

    -- 隐藏
    registerButtonEventListener(self.hide_btn, function (  )
    	self:changeHideStatus(true)
    end, true, nil, nil, nil, 0.3)

    -- 宅室商店
    registerButtonEventListener(self.shop_btn, function ( param, sender, event_type )
    	self:_onClickShopBtn()
    end, true)

    -- 我的拜访
    registerButtonEventListener(self.my_visit_btn, function (  )
    	self:_onClickVisitBtn()
    end, true)

    -- 添加好友
    registerButtonEventListener(self.add_friend_btn, function (  )
    	self:_onClickAddFriendBtn()
    end, true)

    -- 回到我的家园
    registerButtonEventListener(self.back_my_btn, function (  )
    	self:_onClickBackMyHomeBtn()
    end, true)

    -- 点赞按钮
    registerButtonEventListener(self.like_btn, function (  )
    	self:_onClickLikeBtn()
    end, true)

    -- 设置为主居室
    registerButtonEventListener(self.main_storey_btn, function (  )
        self:_onClickMainStoreyBtn()
    end, true)

    -- 下一位按钮
    registerButtonEventListener(self.next_btn, function (  )
        self:_onClickNextBtn()
    end, true, nil, nil, nil, 0.5)

    -- 规则说明
    registerButtonEventListener(self.btn_rule, function ( param,sender, event_type )
        local rule_cfg = Config.HomeData.data_const["home_rule"]
        if rule_cfg then
            TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
        end
    end, true)

    -- 萌兽出行
    registerButtonEventListener(self.pet_btn, function (  )
    	self:_onClickPetBtn()
    end, true, 1, nil, nil, 0.5)

    -- 萌宠行囊
    registerButtonEventListener(self.pet_bag, function (  )
    	self:_onClickPetBag()
    end, true)

    -- 萌宠物品
    registerButtonEventListener(self.pet_item, function (  )
    	self:_onClickPetItem()
    end, true)

    -- 萌宠行囊
    registerButtonEventListener(self.pet_collect, function (  )
    	self:_onClickPetCollect()
    end, true)

    ---------------------@ 事件监听
    -- 收到我的家园数据返回
    self:addGlobalEvent(HomeworldEvent.Get_My_Home_Data_Event, function (  )
    	if self.cur_home_type == HomeworldConst.Type.Myself then
            self.is_need_update_role = true
    		self:updateMyHome()
    	end
    end)

    -- 添加一个家具
    self:addGlobalEvent(HomeworldEvent.Add_One_Furniture_Event, function ( unit_bid )
    	local unit_cfg = Config.HomeData.data_home_unit(unit_bid)
    	if not unit_cfg then return end
    	if unit_cfg.type == HomeworldConst.Unit_Type.Floor then
    		self:updateHomeFloorById(unit_bid)
    	elseif unit_cfg.type == HomeworldConst.Unit_Type.Wall then
    		self:updateHomeWallById(unit_bid)
    	else
    		self:createOneUnit(unit_bid, true)
    	end
	end)

	-- 清空所有家具
	self:addGlobalEvent(HomeworldEvent.Clear_All_Furniture_Event, function (  )
		if self.cur_home_type == HomeworldConst.Type.Myself then
            self:deleteAllUnit()
        end
	end)

	-- 保存当前家园数据
	self:addGlobalEvent(HomeworldEvent.Save_My_Home_Data_Event, function (  )
		self:onSaveCurHomeData()
	end)
    
    -- 我的家园名称变化
    self:addGlobalEvent(HomeworldEvent.Update_My_Home_Name_Event, function ( name )
    	if self.cur_home_type == HomeworldConst.Type.Myself then
    		self:updateHomeName(name)
    	end
    end)

    -- 我的家园形象变化
    self:addGlobalEvent(HomeworldEvent.Update_My_Home_Figure_Event, function ( )
        if self.cur_home_type == HomeworldConst.Type.Myself then
            local figure_id = _model:getMyCurHomeFigureId()
            self:updateHomeRole(figure_id)
        end
    end)

    -- 萌宠状态事件
    if self.homepet_vo then
        if self.home_pet_vo_attt_event == nil then
            self.home_pet_vo_attt_event = self.homepet_vo:Bind(HomepetEvent.HOME_PET_VO_ATTR_EVENT, function(key, value)
                if key == "state" then
                    self:setHomepetStateInfo()
                elseif key == "set_item" then
                    self:updateHomepetRedPointInfo()
                end
            end)
        end
    end
    -- 萌宠物聊天
    self:addGlobalEvent(HomepetEvent.HOME_PET_TALK_EVENT, function (data)
        self:updateHomePetTalk(data)
    end)

    -- 我的家园一些数据变化（点赞数、舒适度）
    self:addGlobalEvent(HomeworldEvent.Update_Some_Data_Event, function ( )
    	self:updateMyHomeOutputInfo()
    end)

    -- 剩余点赞次数变化
    self:addGlobalEvent(HomeworldEvent.Update_Left_Worship_Num, function ( )
    	if self.cur_home_type == HomeworldConst.Type.Other then
    		self:updateWorshipInfo()
    	end
    end)

    -- 在线累计时长变化
    self:addGlobalEvent(HomeworldEvent.Update_Acc_Hook_Time_Data, function ( )
        if self.cur_home_type == HomeworldConst.Type.Myself then
            self:updateHookTimeInfo()
        end
    end)

    -- 点赞成功
    self:addGlobalEvent(RoleEvent.WorshipOtherRole, function ( rid, srv_id, idx, _type )
        if WorshipType.home == _type and self.other_rid and self.other_srv_id and self.other_rid == rid and self.other_srv_id == srv_id then
            self.other_worship = self.other_worship + 1
            self:updateWorshipInfo()
            _model:addPlayerToWorshipData(rid, srv_id)
        end
    end)

    -- 今日被点赞的玩家
    self:addGlobalEvent(HomeworldEvent.Get_Today_Worship_Data, function (  )
        self.can_click_next_btn = true
    end)

    -- 主居室变化
    self:addGlobalEvent(HomeworldEvent.Update_Main_Storey_Event, function (  )
        self:updateMyHomeOutputInfo()
    end)

    -- 红点
    self:addGlobalEvent(HomeworldEvent.Update_Red_Status_Data, function ( bid, status )
        self:updateRedBtnStatus(bid, status)
    end)
end

function HomeWorldScene:openRootWnd( other_home_data )
    
	if other_home_data then
		self.cur_home_type = HomeworldConst.Type.Other
		self:goToOtherPlayerHome(other_home_data)
	else
		self.cur_home_type = HomeworldConst.Type.Myself
        -- 入场动画
        self:playEnterEffect(true)
        ChatController:getInstance():closeChatUseAction()

		_controller:sender26001() -- 请求家园数据

        HomepetController:getInstance():sender26100() -- 申请一下萌宠的基本数据
	end

	local hour = tonumber(os.date("%H"))
	self:updateHomeBgByTime(hour)
	self:changeFuncUiShow()

	-- 默认缩小到 0.5
    if _model:getIsFirstTimeOpenHome() then
        self:showHomeSceneScaleAni(true)
    else
        self.slider:setPercent(50)
        self:onSliderScaleBuild(50)
    end
    -- 有家园币可领取时，建筑往右边移动一些距离
    if _model:getRedStatusById(HomeworldConst.Red_Index.Hook) then
        self.build_container:setPosition(cc.p(SCREEN_WIDTH/2+150, self.build_min_pos_y))
    else
        self.build_container:setPosition(cc.p(SCREEN_WIDTH/2, self.build_min_pos_y))
    end

    --设置萌宠状态
    self:setHomepetStateInfo()
    delayRun(self.root_wnd, 1.2, function() 
        --检测一下是否有萌宠事件
        GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_CHECK_TRIGGER_EVENT)
    end)

    self:updateRedBtnStatus()

    --测试音效 --"lwc"
    -- AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, "s_006", true) --
end

-- 从最小缩放到0.5
function HomeWorldScene:showHomeSceneScaleAni( status )
    if status == true then
        if self.build_ani_timer == nil then
            local percent = 100
            self.slider:setPercent(percent)
            self:onSliderScaleBuild(percent)

            if not self.build_ani_mask then
                self.build_ani_mask = ccui.Layout:create()
                self.build_ani_mask:setContentSize(SCREEN_WIDTH, SCREEN_HEIGHT)
                self.build_ani_mask:setScale(display.getMaxScale())
                self.build_ani_mask:setPositionY(display.getBottom(self.ui_container)-display.getBottom(self.root_wnd))
                self.build_ani_mask:setTouchEnabled(true)
                self.ui_container:addChild(self.build_ani_mask, 99)
                self.build_ani_mask:setSwallowTouches(false)
                self.build_ani_mask:addTouchEventListener(function(sender, event_type)
                    if event_type == ccui.TouchEventType.ended then
                        self.build_ani_mask:setVisible(false)
                    end
                end)
            end
            self.build_ani_mask:setVisible(true)

            self.build_ani_timer = GlobalTimeTicket:getInstance():add(function ()
                percent = percent - 0.6
                if percent <= 50 then
                    percent = 50
                    GlobalTimeTicket:getInstance():remove(self.build_ani_timer)
                    self.build_ani_timer = nil
                    self.build_ani_mask:setVisible(false)
                end
                self.slider:setPercent(percent)
                self:onSliderScaleBuild(percent)
            end, 0.01)
        end
    else
        if self.build_ani_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.build_ani_timer)
            self.build_ani_timer = nil
        end
    end
end

function HomeWorldScene:setHomepetStateInfo()
    if not self.homepet_vo then return end
    local state = self.homepet_vo:getPetState()
    if state == HomepetConst.state_type.eNotActive or 
        state == HomepetConst.state_type.eOnWay then --未激活  和 在旅行中
        local res = PathTool.getResFrame("homeworld","homeworld_1056")
        self.pet_bag:loadTexture(res, LOADTEXT_TYPE_PLIST)
        self.pet_bag_label:setString(TI18N("旅行中"))
        local res = PathTool.getResFrame("homeworld","homeworld_1058")
        self.pet_btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
        self.pet_btn_label:setString(TI18N("正在出行"))
    elseif state == HomepetConst.state_type.eHome then --在家
        local res = PathTool.getResFrame("homeworld","homeworld_1049")
        self.pet_bag:loadTexture(res, LOADTEXT_TYPE_PLIST)
        self.pet_bag_label:setString(TI18N("行囊"))

        local res = PathTool.getResFrame("homeworld","homeworld_1010")
        self.pet_btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
        self.pet_btn_label:setString(TI18N("萌宠"))
    end
    self:checkoutPetStatus()
    self:updateHomepetRedPointInfo()
end

--更新行囊背包红点信息
function HomeWorldScene:updateHomepetRedPointInfo()
    local dic_set_item_id = self.homepet_vo:getSetItemInfo()
    local state = self.homepet_vo:getPetState()
    if state == HomepetConst.state_type.eNotActive or 
        state == HomepetConst.state_type.eOnWay then --未激活  和 在旅行中
        self.pet_bag_tips:setVisible(false)
    else
        if dic_set_item_id[1] == nil and dic_set_item_id[3] == nil then
            self.pet_bag_tips:setVisible(true)
        else
            self.pet_bag_tips:setVisible(false)
        end
    end
end

-- 打开别人的家园
function HomeWorldScene:goToOtherPlayerHome( data )
	-- 入场动画
    if self._change_storey_flag then
        self._change_storey_flag = true
        self:playCloudEffect(true)
    else
        self:playEnterEffect(true)
    end
    ChatController:getInstance():closeChatUseAction()

    -- 进入别人家园时，请求今日点赞过的玩家数据
    if not _model:checkIsHaveTodayWorshipData() then
        _controller:sender26009()
        _controller:sender26019()
    else
        self.can_click_next_btn = true
    end

    self.is_need_update_role = true

	local figure_id = data.look_id
	local wall_bid = data.wall_bid
	local floor_id = data.land_bid
	local unit_list = {}
	for k,v in pairs(data.list) do
		local vo = FurnitureVo.New()
		vo:updateData(v)
		_table_insert(unit_list, vo)
	end
	local visitors = data.visitors
	local home_name = data.name
	self.other_rid = data.rid
	self.other_srv_id = data.srv_id
	self.other_worship = data.worship
    self.owner_name = data.tar_name or TI18N("房主")
    self.cur_storey_index = data.floor or 1

	self.cur_home_type = HomeworldConst.Type.Other
	self:changeFuncUiShow()
	-- 默认缩小到 0.75
	self.slider:setPercent(50)
	self:onSliderScaleBuild(50)
	self.build_container:setPosition(cc.p(SCREEN_WIDTH/2, self.build_min_pos_y))
	self:changeEditStatus(false, true)

	self:setData(figure_id, wall_bid, floor_id, unit_list, visitors, home_name)
end

function HomeWorldScene:getOtherHomeRidAndSrvId(  )
    return self.other_rid, self.other_srv_id
end

-- 从别人家园回到我的家园
function HomeWorldScene:backToMyHomeworld(  )
    self.is_need_update_role = true
    _controller:sender26001()
	-- 入场动画
	self:playEnterEffect(true)
    ChatController:getInstance():closeChatUseAction()

	self.cur_home_type = HomeworldConst.Type.Myself
	self:changeFuncUiShow()
	-- 默认缩小到 0.75
	self.slider:setPercent(50)
	self:onSliderScaleBuild(50)
	self.build_container:setPosition(cc.p(SCREEN_WIDTH/2, self.build_min_pos_y))
	self:changeEditStatus(false, true)
    
    delayRun(self.root_wnd, 1.2, function() 
        --检测一下是否有萌宠事件
        GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_CHECK_TRIGGER_EVENT)
    end)
end

-- 重载我的家园显示 is_clear:true则清空家具
function HomeWorldScene:updateMyHome( wall_bid, floor_id, unit_list )
    if self._change_storey_flag then
        self._change_storey_flag = false
        self:playCloudEffect(true)
    end
	local figure_id = _model:getMyCurHomeFigureId()
	local wall_bid = wall_bid or _model:getMyHomeWallId()
	local floor_id = floor_id or _model:getMyHomeFloorId()
	local unit_list = unit_list or _model:getMyHomeFurnitureData()
	local visitors = _model:getMyHomeVisitorsData()
	local home_name = _model:getMyHomeName()
	self.other_rid = nil
	self.other_srv_id = nil
	self.other_worship = 0
    self.can_click_next_btn = false
    self.cur_player_list_index = 1
    self.next_player_list = nil
	self:setData(figure_id, wall_bid, floor_id, unit_list, visitors, home_name)
end

-- 进入预览状态
function HomeWorldScene:enterPreviewState( data )
    if not data then return end

    self.cur_home_type = HomeworldConst.Type.Preview
    self:playEnterEffect(true)
    ChatController:getInstance():closeChatUseAction()

    -- 暂存一下当前家具数据
    self.preview_unit_data = {}
    self.preview_unit_data.wall_bid = self.cur_wall_id
    self.preview_unit_data.land_bid = self.cur_floor_id
    self.preview_unit_data.unit_list = {}
    for k,unit in pairs(self.unit_list) do
        local u_data = unit:getData()
        _table_insert(self.preview_unit_data.unit_list, u_data)
    end

    local wall_bid = data.wall_bid
    local floor_id = data.land_bid
    local unit_list = {}
    for k,v in pairs(data.unit_list) do
        local vo = FurnitureVo.New()
        vo:updateData(v)
        _table_insert(unit_list, vo)
    end
    local home_name = data.homename or _model:getMyHomeName()

    self:changeFuncUiShow()
    -- 默认缩小到 0.75
    self.slider:setPercent(50)
    self:onSliderScaleBuild(50)
    self.build_container:setPosition(cc.p(SCREEN_WIDTH/2, self.build_min_pos_y))
    self:changeEditStatus(false, true)

    self:setData(nil, wall_bid, floor_id, unit_list, nil, home_name)
end

-- 设置家园数据
--[[
	figure_id: 家园形象id
	wall_bid: 墙壁id
	floor_id: 地板id
	unit_list: 家具数据列表
	visitors: 访问者数据
]]
function HomeWorldScene:setData( figure_id, wall_bid, floor_id, unit_list, visitors, home_name )
    if not self._init_end_flag then return end
	-- 家园名
	if home_name then
		self:updateHomeName(home_name)
	end

	-- 1.显示墙面
	if wall_bid then
		self:updateHomeWallById(wall_bid)
	end

	-- 2.显示地板
	if floor_id then
		self:updateHomeFloorById(floor_id)
	end

	-- 3.显示家具
	if unit_list then
		self:updateHomeFurniture(unit_list)
	end

    -- 宠物、家园角色数据
    if self.is_need_update_role then
        for i = #self.visitors_list, 1, -1 do
            local role = _table_remove(self.visitors_list, i)
            role:setVisible(false)
            _table_insert(self.visitors_pool_list, role)
        end
        local delay_time = (#unit_list*2)/display.DEFAULT_FPS
        -- 等家具创建完之后再创建形象
        delayRun(self.root_wnd, delay_time, function ()
            -- 宠物形象
            self:showPetUnit(true, {})

            -- 4.本家园角色形象
            if figure_id then
                self:updateHomeRole(figure_id)
            elseif self.home_role then
                self.home_role:setVisible(false)
            end

            -- 5.来访者角色形象
            if visitors and next(visitors) ~= nil then
                self:updateVisitorsList(visitors)
            else
                self:updateAllFurnitureZOrder()
            end

            self.is_need_update_role = false
        end)
    else
        self:updateAllFurnitureZOrder()
    end

	self:updateMyHomeOutputInfo()
    self:updateHomeBgByTime()
	self:updateWorshipInfo()
    self:updateHookTimeInfo()
end

-- 更新家园名称
function HomeWorldScene:updateHomeName( name )
	if not name then return end
	self.home_name:setString(name)
end

-- 更新我的家园产出
function HomeWorldScene:updateMyHomeOutputInfo(  )
	if self.cur_home_type == HomeworldConst.Type.Myself then
        -- 楼层
        self.cur_storey_index, self.max_soft_storey = _model:getMyHomeCurStoreyIndex()
        self.storey_label:setString(self.cur_storey_index .. TI18N("楼"))

		-- 舒适度
		local cur_comfort_val = _model:getHomeComfortValue()
        local max_val_cfg = Config.HomeData.data_const["comfort_limit"]
        if max_val_cfg then
            self.comfort_label:setString(cur_comfort_val .. "/" .. max_val_cfg.val)
        else
            self.comfort_label:setString(cur_comfort_val)
        end

        -- 二层楼是否开放（暂时写死二层楼，后续开放多层楼时，就没有按钮置灰的需求了）
        if self.cur_storey_index == 1 then
            local max_soft_val = _model:getMaxAllSoftValue()
            local storet_cfg = Config.HomeData.data_home_storey[2]
            self.two_storey_open = false
            if storet_cfg.limit then
                self.two_storey_open = true
                for k,v in pairs(storet_cfg.limit) do
                    if v[1] == "lev" then
                        local role_vo = RoleController:getInstance():getRoleVo()
                        self.two_storey_open = (role_vo.lev >= v[2])
                    elseif v[1] == "soft" then
                        self.two_storey_open = (max_soft_val >= v[2])
                    end
                    if self.two_storey_open == false then
                        break
                    end
                end
            end
            setChildUnEnabled(not self.two_storey_open, self.storey_btn)
        else
            setChildUnEnabled(false, self.storey_btn)
        end

		-- 被点赞数
		local worship_num = _model:getHomeWorship()
		self.like_label:setString(worship_num)

		-- 家园币产出
        local output_val = _model:getHomeCoinOutput()
        if self.cur_storey_index == self.max_soft_storey then
            self.coin_label:setString(_string_format(TI18N("%d/时"), output_val))
        else
            self.coin_label:setString(_string_format(TI18N("%d/时(当前为%d层收入)"), output_val, self.max_soft_storey))
        end

        -- 根据是否为最高舒适度层和是否为主居室更新UI
        self:updateMyHomeOutputUI()
	end
end

-- 更新产出信息UI显示
function HomeWorldScene:updateMyHomeOutputUI(  )
    -- 是否为主居室
    local is_main_storey = (self.cur_storey_index == _model:getMyhomeMainStoreyIndex())
    self.main_storey_label:setVisible(is_main_storey)
    self.main_storey_btn:setVisible(not is_main_storey)
end

-- 更新别人家园点赞相关内容
function HomeWorldScene:updateWorshipInfo(  )
	if self.cur_home_type ~= HomeworldConst.Type.Other then return end

	if not self.other_worship_num then
		self.other_worship_num = createRichLabel(20, cc.c4b(213,174,143,255), cc.p(0.5, 0.5), cc.p(105, 50))
		self.other_like_panel:addChild(self.other_worship_num)
	end
	self.other_worship_num:setString(_string_format(TI18N("已被点赞<div fontcolor=84c152>%d</div>次"), self.other_worship or 0))

    local left_worship_num = _model:getLeftWorshipNum()
	self.can_like_tips:setString(_string_format(TI18N("今日还可点赞<div fontcolor=c1c1c1>%d</div>次"), left_worship_num))
end

-- 更新在线时长
function HomeWorldScene:updateHookTimeInfo(  )
    if self.cur_home_type ~= HomeworldConst.Type.Myself then return end

    if not self.hook_time_award then
        self.hook_time_award = HomeworldHookTimeAward.New(self.build_slayer)
    end
    self.hook_time_award:setData()
end

-- 点击关闭或退出预览模式
function HomeWorldScene:onClickCloseBtn(  )
    if self.cur_home_type == HomeworldConst.Type.Preview then
        _controller:showHomeworldSuitWindow(true)
        self.cur_home_type = HomeworldConst.Type.Myself
        self:changeFuncUiShow()

        -- 默认缩小到 0.75
        self.slider:setPercent(50)
        self:onSliderScaleBuild(50)
        self.build_container:setPosition(cc.p(SCREEN_WIDTH/2, self.build_min_pos_y))

        if self.preview_unit_data then
            local wall_bid = self.preview_unit_data.wall_bid
            local land_bid = self.preview_unit_data.land_bid
            local unit_list = self.preview_unit_data.unit_list
            self:updateMyHome(wall_bid, land_bid, unit_list)

            -- 进入编辑模式
            self:changeEditStatus(true)
        end
    else
        _controller:openHomeworldScene(false)
    end
end

-- 点击改名
function HomeWorldScene:_onClickChangeName(  )
    if isQingmingShield and isQingmingShield() then
        return
    end
    if self.cur_home_type ~= HomeworldConst.Type.Myself then return end

	if self.set_name_alert then
        self.set_name_alert:close()
        self.set_name_alert = nil
    end
    local function confirm_callback(str)
        if str == nil or str == "" then
            message(TI18N("名字不合法"))
            return
        end
        _controller:sender26011(str)
        if self.set_name_alert then
	        self.set_name_alert:close()
	        self.set_name_alert = nil
	    end
    end

    self.set_name_alert = CommonAlert.showInputApply("", TI18N("请输入名字(限制9字)"), TI18N("确 定"), 
        confirm_callback, TI18N("取 消"), nil, true, nil, 20, CommonAlert.type.rich, FALSE,
        cc.size(270,50), 9, {off_y=-15})
end

-- 点击切换楼层
function HomeWorldScene:_onClickStoreyBtn(  )
    if not self.cur_storey_index then return end

    if self.cur_home_type == HomeworldConst.Type.Myself and self.cur_storey_index == 1 and not self.two_storey_open then
        local storey_cfg = Config.HomeData.data_home_storey[2]
        local limit_soft_val = 0
        if storey_cfg then
            for k,v in pairs(storey_cfg.limit) do
                if v[1] == "soft" then
                    limit_soft_val = v[2] or 0
                    break
                end
            end
        end
        local max_soft_val = _model:getMaxAllSoftValue()
        message(_string_format(TI18N("总舒适度达到%d解锁（当前:%d）"), limit_soft_val, max_soft_val))
        return
    end

    local new_storey_index = self.cur_storey_index + 1
    if new_storey_index > Config.HomeData.data_home_storey_length then
        new_storey_index = 1
    end
    self._change_storey_flag = true
    if self.cur_home_type == HomeworldConst.Type.Myself then
        _controller:sender26001(new_storey_index)
    else
        _controller:sender26003(self.other_rid, self.other_srv_id, new_storey_index)
    end
end

-- 点击商店
function HomeWorldScene:_onClickShopBtn(  )
	_controller:openHomeworldShopWindow(true)
end

-- 点击我的拜访
function HomeWorldScene:_onClickVisitBtn(  )
	_controller:openHomeworldVisitWindow(true)
end

-- 点击添加好友
function HomeWorldScene:_onClickAddFriendBtn(  )
    if self.cur_home_type == HomeworldConst.Type.Other and self.other_rid and self.other_srv_id then
        local setting = {}
        setting.form_type = RoleConst.Other_Form_Type.eMessageBoardInfo
        RoleController:getInstance():requestRoleInfo(self.other_rid, self.other_srv_id, setting)
        --FriendController:getInstance():addOther(self.other_srv_id, self.other_rid)
    end
end

-- 回到我的家园
function HomeWorldScene:_onClickBackMyHomeBtn(  )
	--self:backToMyHomeworld()
    _controller:requestOpenMyHomeworld(true)
end

-- 点赞
function HomeWorldScene:_onClickLikeBtn(  )
    if self.cur_home_type ~= HomeworldConst.Type.Other then return end
    if self.other_rid and self.other_srv_id then
        RoleController:getInstance():requestWorshipRole(self.other_rid, self.other_srv_id, 1, WorshipType.home)
    end
end

-- 设置为主居室
function HomeWorldScene:_onClickMainStoreyBtn(  )
    if self.cur_home_type ~= HomeworldConst.Type.Myself then return end
    _controller:sender26021(self.cur_storey_index)
end

-- 拜访下一位
function HomeWorldScene:_onClickNextBtn(  )
    if self.cur_home_type ~= HomeworldConst.Type.Other or not self.can_click_next_btn then return end

    if not self.next_player_list then
        self.next_player_list = _model:getNextPlayerList(self.other_rid, self.other_srv_id)
    end
    self.cur_player_list_index = self.cur_player_list_index + 1
    if self.cur_player_list_index > #self.next_player_list then
        self.cur_player_list_index = 1
    end
    local next_player_data = self.next_player_list[self.cur_player_list_index]
    if next_player_data then
        _controller:sender26003(next_player_data.rid, next_player_data.srv_id)
    else
        message(TI18N("暂无下一位数据"))
    end
end

-- 详情
function HomeWorldScene:_onClickDetialBtn(  )
    if self.cur_home_type ~= HomeworldConst.Type.Myself then return end

    _controller:openHomeInfoWindow(true)
end

-- 点击萌兽出行
function HomeWorldScene:_onClickPetBtn(  )
	-- message("萌兽出行")
   

	self.pet_btn_status = not self.pet_btn_status

	if self.pet_btn_status then
		self.pet_bag:setVisible(true)
		self.pet_item:setVisible(true)
		self.pet_collect:setVisible(true)
        self.pet_btn:setTouchEnabled(false)
		self.pet_bag:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(45, 350)), cc.FadeIn:create(0.2)), cc.CallFunc:create(function ( )
            self.pet_btn:setTouchEnabled(true)
            self.pet_bag:setTouchEnabled(true)
            self.pet_item:setTouchEnabled(true)
            self.pet_collect:setTouchEnabled(true)
        end)))
		self.pet_item:runAction(cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(45, 250)), cc.FadeIn:create(0.2)))
		self.pet_collect:runAction(cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(45, 150)), cc.FadeIn:create(0.2)))
	else

        self.pet_bag:setTouchEnabled(false)
        self.pet_item:setTouchEnabled(false)
        self.pet_collect:setTouchEnabled(false)
            
        self.pet_btn:setTouchEnabled(false)
		self.pet_bag:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(45, 50)), cc.FadeOut:create(0.2)), cc.CallFunc:create(function (  )
			self.pet_bag:setVisible(false)
            self.pet_btn:setTouchEnabled(true)
		end)))
		self.pet_item:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(45, 50)), cc.FadeOut:create(0.2)), cc.CallFunc:create(function (  )
			self.pet_item:setVisible(false)
		end)))
		self.pet_collect:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(45, 50)), cc.FadeOut:create(0.2)), cc.CallFunc:create(function (  )
			self.pet_collect:setVisible(false)
		end)))
	end
end

-- 点击萌宠行囊
function HomeWorldScene:_onClickPetBag(  )
    if not self.homepet_vo then return end
    local state = self.homepet_vo:getPetState()
    if state == HomepetConst.state_type.eNotActive then --未未激活
        HomepetController:getInstance():openHomePetGooutProgressPanel(true)
    elseif state == HomepetConst.state_type.eHome then --在家
        HomepetController:getInstance():openHomePetTravellingBagPanel(true)
    elseif state == HomepetConst.state_type.eOnWay then --路上
        HomepetController:getInstance():openHomePetGooutProgressPanel(true)
    end
end

-- 点击萌宠物品
function HomeWorldScene:_onClickPetItem( )
	local setting = {}
    setting.show_type = HomepetConst.Item_bag_show_type.eBagItemType
    HomepetController:getInstance():openHomePetItemBagPanel(true, setting)
end

-- 点击萌宠收藏
function HomeWorldScene:_onClickPetCollect(  )
	HomepetController:getInstance():openHomePetCollectionPanel(true)
end

-- 根据是否是自己的家园切换UI显示
function HomeWorldScene:changeFuncUiShow(  )
    if not self._init_end_flag then return end
	self.shop_btn:setVisible(self.cur_home_type == HomeworldConst.Type.Myself)
    if self.edit_btn then
    	self.edit_btn:setVisible(self.cur_home_type == HomeworldConst.Type.Myself)
    end
	self.figure_btn:setVisible(self.cur_home_type == HomeworldConst.Type.Myself)
	self.my_output_panel:setVisible(self.cur_home_type == HomeworldConst.Type.Myself)
	self.pet_panel:setVisible(self.cur_home_type == HomeworldConst.Type.Myself)
	self.slider_panel:setVisible(self.cur_home_type == HomeworldConst.Type.Myself)
    self.edit_name_btn:setVisible(self.cur_home_type == HomeworldConst.Type.Myself)
	self.add_friend_btn:setVisible(self.cur_home_type == HomeworldConst.Type.Other)
	self.back_my_btn:setVisible(self.cur_home_type == HomeworldConst.Type.Other)
	self.other_like_panel:setVisible(self.cur_home_type == HomeworldConst.Type.Other)
    self.my_visit_btn:setVisible(self.cur_home_type ~= HomeworldConst.Type.Preview)
    self.btn_rule:setVisible(self.cur_home_type ~= HomeworldConst.Type.Preview)

    if self.cur_home_type ~= HomeworldConst.Type.Preview then
        self.close_btn_label:setString(TI18N("退出"))
        self.storey_btn:setVisible(true)
        if self.cur_home_type == HomeworldConst.Type.Myself then
            self.storey_btn:setPositionY(self.top_off-self.root_off-655)
        else
            self.storey_btn:setPositionY(self.top_off-self.root_off-435)
            setChildUnEnabled(false, self.storey_btn)
            --self.storey_btn_label:enableOutline(cc.c4b(76,38,26,255), 2)
        end
    else
        self.close_btn_label:setString(TI18N("返回"))
        self.storey_btn:setVisible(false)
    end

    if self.hook_time_award then
        self.hook_time_award:setVisible(self.cur_home_type == HomeworldConst.Type.Myself)
    end

    if self.home_role then
        self.home_role:setCanMoveRoleStatus(self.cur_home_type == HomeworldConst.Type.Myself)
    end
	if self.pet_unit then
		self.pet_unit:setCanMoveRoleStatus(self.cur_home_type == HomeworldConst.Type.Myself)
	end
end

-- 切换隐藏状态
function HomeWorldScene:changeHideStatus( status )
	self.cur_hide_status = status
	if status then
        self.btn_rule:setTouchEnabled(false)
        self.btn_rule:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeOut:create(0.2)))
        self.my_visit_btn:setTouchEnabled(false)
		self.my_visit_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeOut:create(0.2)))
		self.add_friend_btn:setTouchEnabled(false)
        self.add_friend_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeOut:create(0.2)))
		self.shop_btn:setTouchEnabled(false)
        self.shop_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeOut:create(0.2)))
        if self.edit_btn then
    		self.edit_btn:setTouchEnabled(false)
            self.edit_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeOut:create(0.2)))
        end
		self.figure_btn:setTouchEnabled(false)
        self.figure_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeOut:create(0.2)))
        self.storey_btn:setTouchEnabled(false)
        self.storey_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeOut:create(0.2)))
		self.back_my_btn:setTouchEnabled(false)
        self.back_my_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeOut:create(0.2)))
		self.my_output_panel:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, -300)), cc.FadeOut:create(0.2)))
		self.close_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeOut:create(0.2)))
		self.pet_panel:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeOut:create(0.2)))
		--self.hide_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeOut:create(0.2)))
		self.other_like_panel:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, -200)), cc.FadeOut:create(0.2)))
		self.title_panel:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, 200)), cc.FadeOut:create(0.2)))
		self.slider_panel:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeOut:create(0.2)))

        self.hide_btn:setVisible(false)
        MainuiController:getInstance():setMainUIChatBubbleStatus(false)
		-- 如果当前为编辑状态，则把仓库UI隐藏
		if self.cur_edit_status and self.my_unit_ui then
			self.my_unit_ui:setVisible(false)
		end
		MainuiController:getInstance():setMainUIShowStatus(false)

        if self.pet_unit then
            self.pet_unit:showPetArrow(false)
        end

		-- 延迟0.3秒创建一个全屏的触摸层
		delayRun(self.ui_container, 0.3, function (  )
			if not self.hide_mask then
				self.hide_mask = ccui.Layout:create()
	            self.hide_mask:setContentSize(SCREEN_WIDTH, SCREEN_HEIGHT)
	            self.hide_mask:setScale(display.getMaxScale())
	            self.hide_mask:setPositionY(display.getBottom(self.ui_container)-display.getBottom(self.root_wnd))
	            self.hide_mask:setTouchEnabled(true)
	            self.ui_container:addChild(self.hide_mask, 99)
	            self.hide_mask:setSwallowTouches(false)
	            self.hide_mask:addTouchEventListener(function(sender, event_type)
	                if event_type == ccui.TouchEventType.ended then
	                    self:changeHideStatus(false)
	                end
	            end)
			end
			self.hide_mask:setVisible(true)
		end)
	else
        self.btn_rule:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeIn:create(0.2)))
		self.my_visit_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeIn:create(0.2)))
		self.add_friend_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeIn:create(0.2)))
		self.shop_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeIn:create(0.2)))
        if self.edit_btn then
    		self.edit_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeIn:create(0.2)))
        end
		self.figure_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeIn:create(0.2)))
        self.storey_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeIn:create(0.2)))
		self.back_my_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.FadeIn:create(0.2)))
		self.my_output_panel:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, 300)), cc.FadeIn:create(0.2)))
		self.close_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeIn:create(0.2)))
		self.pet_panel:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeIn:create(0.2)))
		--self.hide_btn:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeIn:create(0.2)))
		self.other_like_panel:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, 200)), cc.FadeIn:create(0.2)))
		self.title_panel:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, -200)), cc.FadeIn:create(0.2)))
		self.slider_panel:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.FadeIn:create(0.2)))
        self.hide_btn:setVisible(true)
        MainuiController:getInstance():setMainUIChatBubbleStatus(true)

		-- 如果当前为编辑状态，则把仓库UI显示
		if self.cur_edit_status and self.my_unit_ui then
			self.my_unit_ui:setVisible(true)
		end
		MainuiController:getInstance():setMainUIShowStatus(true)

        if self.pet_unit then
            self.pet_unit:showPetArrow(true)
        end

        delayRun(self.ui_container, 0.3, function (  )
            self.btn_rule:setTouchEnabled(true)
            self.my_visit_btn:setTouchEnabled(true)
            self.add_friend_btn:setTouchEnabled(true)
            self.shop_btn:setTouchEnabled(true)
            if self.edit_btn then
                self.edit_btn:setTouchEnabled(true)
            end
            self.figure_btn:setTouchEnabled(true)
            self.storey_btn:setTouchEnabled(true)
            self.back_my_btn:setTouchEnabled(true)
        end)

		if self.hide_mask then
			self.hide_mask:setVisible(false)
		end
	end
end

-- 切换编辑模式状态
function HomeWorldScene:changeEditStatus( status, force )
	self.cur_edit_status = status

	if status then
		self:changeUIByEditStatus(true)
	else
		if force then
			self:changeUIByEditStatus(false)
            self:updateAllFurnitureZOrder()
            for k,unit in pairs(self.unit_list) do
                unit:setTranslucenceState(false)
            end
		else
			local str = TI18N("是否保存本次家园编辑？")
	        local confirm_callback = function()
	            self:changeUIByEditStatus(status)
				self:onSaveCurHomeData()
                self:updateAllFurnitureZOrder()
	        end
	        local cancel_callback = function (  )
	        	self:changeUIByEditStatus(status)
	        	self:updateMyHome()
	        end
	        self.save_alert = CommonAlert.show(str, TI18N("确定"), confirm_callback, TI18N("取消"), cancel_callback, CommonAlert.type.rich)
		end
	end
end

-- 获取当前的编辑状态
function HomeWorldScene:getHomeEditStatus(  )
	return self.cur_edit_status
end

function HomeWorldScene:changeUIByEditStatus( status )
	self.slider_panel:setVisible(not status)
	self:showMyUnitUi(status)

	if status == true then
        if self.edit_btn then
    		self.edit_btn_label:setString(TI18N("退出编辑"))
            addRedPointToNodeByStatus(self.edit_btn, false)
        end
	else
        if self.edit_btn then
    		self.edit_btn_label:setString(TI18N("编辑模式"))
            local suit_red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Suit)
            addRedPointToNodeByStatus(self.edit_btn, suit_red_status)
        end
	end

    if self.figure_btn then
        if self.cur_home_type == HomeworldConst.Type.Myself then
            self.figure_btn:setVisible(not status)
        else
            self.figure_btn:setVisible(false)
        end
    end

    if self.storey_btn then
        if self.cur_home_type == HomeworldConst.Type.Preview then
            self.storey_btn:setVisible(false)
        else
            self.storey_btn:setVisible(not status)
        end
    end

    if self.my_output_panel then
        if self.cur_home_type == HomeworldConst.Type.Myself then
            self.my_output_panel:setVisible(not status)
        else
            self.my_output_panel:setVisible(false)
        end
    end

	for k,unit in pairs(self.unit_list) do
		unit:changeCanEditStatus(status)
	end

	for k,role in pairs(self.visitors_list) do
		role:setVisible(not status)
	end

	if self.home_role then
        if self.cur_home_type == HomeworldConst.Type.Preview then
            self.home_role:setVisible(false)
        else
            self.home_role:setVisible(not status)
        end
	end
	if self.pet_unit then
        if status or self.cur_home_type == HomeworldConst.Type.Preview then
            self.pet_unit:setVisible(false)
        else
            self:checkoutPetStatus()
        end
	end
end

-- 保存我的当前家园数据
function HomeWorldScene:onSaveCurHomeData(  )
	if self.cur_home_type == HomeworldConst.Type.Myself then
		local wall_bid = self.cur_wall_id
		local land_bid = self.cur_floor_id
		local unit_datas = {}
		for k,unit in pairs(self.unit_list) do
			local u_data = unit:getFurnitureBaseData()
			_table_insert(unit_datas, u_data)
		end
		_controller:sender26002(wall_bid, land_bid, unit_datas, self.cur_storey_index)
	end
	self:changeEditStatus(false, true)	
end

-- 播放开门进入特效
function HomeWorldScene:playEnterEffect( status )
	if status == true then
		if not tolua.isnull(self.root_wnd) and self.enter_effect == nil then
            self.enter_effect = createEffectSpine(Config.EffectData.data_effect_info[902], cc.p(SCREEN_WIDTH*0.5, 0), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.enter_effect:setScale(display.getMaxScale())
            self.root_wnd:addChild(self.enter_effect, 99)
        elseif self.enter_effect then
            self.enter_effect:setToSetupPose()
            self.enter_effect:setAnimation(0, PlayerAction.action, false)
        end
	else
		if self.enter_effect then
            self.enter_effect:clearTracks()
            self.enter_effect:removeFromParent()
            self.enter_effect = nil
        end
	end
end

-- 播放云层特效
function HomeWorldScene:playCloudEffect( status )
    if status == true then
        if not tolua.isnull(self.root_wnd) and self.cloud_effect == nil then
            self.cloud_effect = createEffectSpine(Config.EffectData.data_effect_info[157], cc.p(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.cloud_effect:setScale(display.getMaxScale())
            self.root_wnd:addChild(self.cloud_effect, 99)
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

-- 移动建筑
function HomeWorldScene:onTouchMoveBuild( offset_x, offset_y )
	if not self.build_container then return end

	local pos_x, pos_y = self.build_container:getPosition()
	local new_pos_x = pos_x + offset_x
	local new_pos_y = pos_y + offset_y
	if new_pos_x > self.build_max_pos_x then
		new_pos_x = self.build_max_pos_x
	elseif new_pos_x < self.build_min_pos_x then
		new_pos_x = self.build_min_pos_x
	end
	if new_pos_y > self.build_max_pos_y then
		new_pos_y = self.build_max_pos_y
	elseif new_pos_y < self.build_min_pos_y then
		new_pos_y = self.build_min_pos_y
	end
	self.build_container:setPosition(cc.p(new_pos_x, new_pos_y))
end

-- 对建筑进行缩放
function HomeWorldScene:onSliderScaleBuild( percent )
	-- 最小只能缩到 SCREEN_WIDTH/HomeworldConst.Build_Width(屏幕宽度除以建筑宽度)
	self.cur_scale_val = 1 - percent/100*SCREEN_WIDTH/HomeworldConst.Build_Width
	self.build_container:setScale(self.cur_scale_val)
	self:updateBuildMinMaxPos()
	self:adjustBuildPos()
end

-- 对建筑坐标进行修正
function HomeWorldScene:adjustBuildPos(  )
	self:onTouchMoveBuild(0, 0)
end

-- 更新建筑坐标最大最小值
function HomeWorldScene:updateBuildMinMaxPos(  )
	self.build_min_pos_x = SCREEN_WIDTH - HomeworldConst.Build_Width*self.cur_scale_val*0.5
	self.build_max_pos_x = HomeworldConst.Build_Width*self.cur_scale_val*0.5
	if display.height > HomeworldConst.Build_Height*self.cur_scale_val then -- 当高度缩小到比屏幕高度还小时
		self.build_min_pos_y = HomeworldConst.Build_Height*self.cur_scale_val*0.5 - 500*self.cur_scale_val
		self.build_max_pos_y = HomeworldConst.Build_Height*self.cur_scale_val*0.5
	else
		self.build_min_pos_y = display.height - HomeworldConst.Build_Height*self.cur_scale_val*0.5 - 500*self.cur_scale_val
		self.build_max_pos_y = HomeworldConst.Build_Height*self.cur_scale_val*0.5
	end
end

-- 根据时间更新天空和建筑主体背景
function HomeWorldScene:updateHomeBgByTime( time )
	if time then
        if time >= 6 and time < 18 then
            self.cur_time_type = 1
        else
            self.cur_time_type = 2
        end
    end

    if not self.cur_time_type or not self.cur_storey_index then return end

	-- 天空
	local sky_res = _string_format("resource/homeworld/background/%d/sky.jpg", self.cur_time_type)
    if not self.cur_sky_res or self.cur_sky_res ~= sky_res then
        self.cur_sky_res = sky_res
        if not self.sky_bg then
            self.sky_bg = createSprite(nil, 0, 0, self.bg_slayer, cc.p(0, 0), LOADTEXT_TYPE)
        end
        self.sky_load = loadSpriteTextureFromCDN(self.sky_bg, sky_res, ResourcesType.single, self.sky_load)
    end

	-- 建筑主体
    local story_data = Config.HomeData.data_home_storey[self.cur_storey_index]
    if not story_data then return end
	local build_res = PathTool.getHomeBuildRes( self.cur_time_type, story_data.res_id )
    if not self.cur_build_res or self.cur_build_res ~= build_res then
        self.cur_build_res = build_res
        if not self.build_bg then
            self.build_bg = createSprite(nil, 0, 0, self.build_slayer, cc.p(0, 0), LOADTEXT_TYPE)
        end
        self.build_load = loadSpriteTextureFromCDN(self.build_bg, build_res, ResourcesType.single, self.build_load)
    end
end

-- 更新地板显示
function HomeWorldScene:updateHomeFloorById( floor_id )
	if self.cur_floor_id and self.cur_floor_id == floor_id then return end
	local floor_cfg = Config.HomeData.data_home_unit(floor_id)
	if not floor_cfg then return end
    GlobalEvent:getInstance():Fire(HomeworldEvent.Discharge_Furniture_Event, self.cur_floor_id)
	self.cur_floor_id = floor_id
	local left_floor_res = _string_format("resource/homeworld/floor/%s_1.png", floor_cfg.res)
	local right_floor_res = _string_format("resource/homeworld/floor/%s_2.png", floor_cfg.res)
	local res_list = {}
	_table_insert(res_list, {path=left_floor_res, type = ResourcesType.single})
	_table_insert(res_list, {path=right_floor_res, type = ResourcesType.single})

	if not self.left_floor_pic then
		self.left_floor_pic = createSprite(nil, HomeworldConst.Build_Width/2+16, 1094, self.floor_slayer, cc.p(1, 0), LOADTEXT_TYPE)
	end
	if not self.right_floor_pic then
		self.right_floor_pic = createSprite(nil, HomeworldConst.Build_Width/2+16, 1094, self.floor_slayer, cc.p(0, 0), LOADTEXT_TYPE)
	end

	if self.floor_load then
		self.floor_load:DeleteMe()
		self.floor_load = nil
	end
	self.floor_load = ResourcesLoad.New()
    self.floor_load:addAllList(res_list, function()
        loadSpriteTexture(self.left_floor_pic, left_floor_res, LOADTEXT_TYPE)
        loadSpriteTexture(self.right_floor_pic, right_floor_res, LOADTEXT_TYPE)
    end)
    GlobalEvent:getInstance():Fire(HomeworldEvent.Add_Furniture_Event, floor_id)
end

-- 更新墙面显示
function HomeWorldScene:updateHomeWallById( wall_id )
	if self.cur_wall_id and self.cur_wall_id == wall_id then return end
	local wall_cfg = Config.HomeData.data_home_unit(wall_id)
	if not wall_cfg then return end
    GlobalEvent:getInstance():Fire(HomeworldEvent.Discharge_Furniture_Event, self.cur_wall_id)
	self.cur_wall_id = wall_id
	local left_wall_res = _string_format("resource/homeworld/wall/%s_1.png", wall_cfg.res)
	local right_wall_res = _string_format("resource/homeworld/wall/%s_2.png", wall_cfg.res)
	local res_list = {}
	_table_insert(res_list, {path=left_wall_res, type = ResourcesType.single})
	_table_insert(res_list, {path=right_wall_res, type = ResourcesType.single})

	if not self.left_wall_pic then
		self.left_wall_pic = createSprite(nil, HomeworldConst.Build_Width/2+15, 1412, self.wall_slayer, cc.p(1, 0), LOADTEXT_TYPE)
	end
	if not self.right_wall_pic then
		self.right_wall_pic = createSprite(nil, HomeworldConst.Build_Width/2+15, 1412, self.wall_slayer, cc.p(0, 0), LOADTEXT_TYPE)
	end

	if self.wall_load then
		self.wall_load:DeleteMe()
		self.wall_load = nil
	end
	self.wall_load = ResourcesLoad.New()
    self.wall_load:addAllList(res_list, function()
        loadSpriteTexture(self.left_wall_pic, left_wall_res, LOADTEXT_TYPE)
        loadSpriteTexture(self.right_wall_pic, right_wall_res, LOADTEXT_TYPE)
    end)
    GlobalEvent:getInstance():Fire(HomeworldEvent.Add_Furniture_Event, wall_id)
end

-- 刷新家园家具显示
function HomeWorldScene:updateHomeFurniture( unit_vo_list )
	if not unit_vo_list then return end

	-- 先移除所有家具
	self:deleteAllUnit()

	for i,unit_vo in ipairs(unit_vo_list) do
		delayRun(self.unit_slayer, i / display.DEFAULT_FPS, function (  )
			self:createOneUnit(unit_vo)
		end)
	end
end

-- 创建一个家具单位(unit_data 可以是FurnitureVo，也可以是家具的配置表id)
function HomeWorldScene:createOneUnit( unit_data, is_add )
	if not unit_data then return end

	local unit_vo
	if type(unit_data) == "number" then
		local unit_id = unit_data
		local unit_cfg = Config.HomeData.data_home_unit(unit_id)
		local grid_x, grid_y, is_change_dir = self:getRandomPosByRange(unit_cfg.type, unit_cfg.dir, unit_cfg.tile_list_1, unit_cfg.tile_list_2)
		if grid_x and grid_y then
			unit_vo = FurnitureVo.New()
			unit_vo.bid = unit_id
			unit_vo.index = HomeTile.tileIndex(grid_x, grid_y)
            if is_change_dir then
                if unit_cfg.dir == 1 then
                    unit_vo.dir = 2
                else
                    unit_vo.dir = 1
                end
            else
                unit_vo.dir = unit_cfg.dir
            end
			unit_vo.config = unit_cfg
			unit_vo.id = unit_id*1000 + unit_vo.index
		end
	else
		unit_vo = deepCopy(unit_data)
	end

	if unit_vo then
		local unit_item = _table_remove(self.unit_pools, 1)
		if not unit_item then
			unit_item = HomeworldFurniture.New(self.unit_slayer, handler(self, self._onFurnitureCallback), self.cur_edit_status)
		end
		unit_item:setVisible(true)
		unit_item:setData(unit_vo, self.cur_edit_status, self.cur_scale_val)
		_table_insert(self.unit_list, unit_item)
		self:updateAllFurnitureZOrder()

        if is_add then
            for k,unit in pairs(self.unit_list) do
                unit:updateEditStatus(false)
            end
            self:showUnitTouchMask(false)
            unit_item:onClickFurniture()
        end

        GlobalEvent:getInstance():Fire(HomeworldEvent.Add_Furniture_Event, unit_vo.bid)
	end
end

-- 移除一个单位（移除到缓冲池）
function HomeWorldScene:deleteOneUnitById( id )
	for k,unit in pairs(self.unit_list) do
		if unit:getFurnitureId() == id then
			unit:setVisible(false)
			unit:suspendAllActions()
			_table_insert(self.unit_pools, unit)
			_table_remove(self.unit_list, k)
			break
		end
	end
end

-- 所有单位移除到缓冲池
function HomeWorldScene:deleteAllUnit(  )
	local num = #self.unit_list
	for i=num,1,-1 do
		local unit = self.unit_list[i]
		if unit then
			unit:setVisible(false)
			unit:suspendAllActions()
			_table_insert(self.unit_pools, unit)
			_table_remove(self.unit_list, i)
		end
	end
end

-- 家具单位回调
function HomeWorldScene:_onFurnitureCallback( call_type, param )
	if call_type == 1 then -- 所有家具变为未编辑状态
		for k,unit in pairs(self.unit_list) do
			unit:updateEditStatus(false)
		end
        self:showUnitTouchMask(false)
	elseif call_type == 2 then -- 所有家具刷新一遍层级关系
		self:updateAllFurnitureZOrder()
	elseif call_type == 3 and param then -- 删除一个家具
		local unit_id = param
		self:deleteOneUnitById(unit_id)
    elseif call_type == 4 then -- 有一个家具处于编辑状态，则显示一个触摸遮罩
        self:showUnitTouchMask(param)
	end
end

function HomeWorldScene:showUnitTouchMask( status )
    if status == true then
        if not self.unit_touch_mask then
            self.unit_touch_mask = ccui.Layout:create()
            self.unit_touch_mask:setAnchorPoint(cc.p(0, 0))
            self.unit_touch_mask:setSwallowTouches(true)
            self.unit_touch_mask:setPosition(cc.p(0, 0))
            self.unit_touch_mask:setContentSize(SCREEN_WIDTH*2, SCREEN_HEIGHT)
            self.unit_touch_mask:setTouchEnabled(true)
            self.unit_slayer:addChild(self.unit_touch_mask, 98)
            self.unit_touch_mask:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    for k,unit in pairs(self.unit_list) do
                        unit:updateEditStatus(false)
                    end
                    self:showUnitTouchMask(false)
                end
            end)
        end
        self.unit_touch_mask:setVisible(true)
        for k,unit in pairs(self.unit_list) do
            unit:setTranslucenceState(true)
        end
    elseif self.unit_touch_mask then
        self.unit_touch_mask:setVisible(false)
        for k,unit in pairs(self.unit_list) do
            unit:setTranslucenceState(false)
        end
    end
end

-- 根据bid获取当前场景中是否有该家具
function HomeWorldScene:checkCurHomeIsHaveUnitByBid( bid )
    local is_have = false
    for k,unit in pairs(self.unit_list) do
        if unit:getFurnitureBid() == bid then
            is_have = true
            break
        end
    end
    if not is_have and (bid == self.cur_wall_id or bid == self.cur_floor_id) then
        is_have = true
    end
    return is_have
end

-- 计算当前家具的舒适度
function HomeWorldScene:getCurHomeSoftVal(  )
    local soft_val = 0

    local all_unit_data = {}
    local all_suit_data = {}

    local function checkAddSuitData( unit_cfg )
        if unit_cfg.set_id and unit_cfg.set_id > 0 then
            local is_have = false
            for k,v in pairs(all_suit_data) do
                if unit_cfg.set_id == v.set_id then
                    is_have = true
                    local is_cal_num = true
                    for _,u_bid in pairs(v.item_list) do
                        if unit_cfg.bid == u_bid then
                            is_cal_num = false
                            break
                        end
                    end
                    if is_cal_num then
                        v.num = v.num + 1
                        _table_insert(v.item_list, unit_cfg.bid)
                    end
                    break
                end
            end
            if not is_have then
                local suit_data = {}
                suit_data.set_id = unit_cfg.set_id
                suit_data.num = 1
                suit_data.cfg = Config.HomeData.data_suit_soft[unit_cfg.set_id]
                suit_data.item_list = {}
                _table_insert(suit_data.item_list, unit_cfg.bid)
                _table_insert(all_suit_data, suit_data)
            end
        end
    end

    -- 墙壁
    local wall_cfg = Config.HomeData.data_home_unit(self.cur_wall_id)
    if wall_cfg then
        local s_data = {}
        s_data.bid = wall_cfg.bid
        s_data.num = 1
        s_data.cfg = wall_cfg
        _table_insert(all_unit_data, s_data)

        checkAddSuitData(wall_cfg)
    end
    -- 地板
    local floor_cfg = Config.HomeData.data_home_unit(self.cur_floor_id)
    if floor_cfg then
        local s_data = {}
        s_data.bid = floor_cfg.bid
        s_data.num = 1
        s_data.cfg = floor_cfg
        _table_insert(all_unit_data, s_data)

        checkAddSuitData(floor_cfg)
    end
    -- 家具
    for k,unit in pairs(self.unit_list) do
        local bid = unit:getFurnitureBid()
        local furniture_cfg = Config.HomeData.data_home_unit(bid)
        if furniture_cfg then
            local is_have = false
            for _,s_data in pairs(all_unit_data) do
                if s_data.bid == furniture_cfg.bid then
                    is_have = true
                    s_data.num = s_data.num + 1
                    break
                end
            end
            if not is_have then
                local s_data = {}
                s_data.bid = furniture_cfg.bid
                s_data.num = 1
                s_data.cfg = furniture_cfg
                _table_insert(all_unit_data, s_data)
            end

            checkAddSuitData(furniture_cfg)
        end
    end
    for k,s_data in pairs(all_unit_data) do
        local cal_num = math.min(s_data.cfg.effect_count, s_data.num)
        s_data.cal_soft = s_data.cfg.soft*cal_num
        soft_val = soft_val + s_data.cal_soft
    end

    for k,s_data in pairs(all_suit_data) do
        local diff_val
        local cur_num
        for num,cfg in pairs(s_data.cfg) do
            if s_data.num >= num and (not diff_val or diff_val > (s_data.num - num)) then
                diff_val = s_data.num - num
                cur_num = num
            end
        end
        if cur_num then
            s_data.cfg = s_data.cfg[cur_num]
            soft_val = soft_val + s_data.cfg.all_soft
        end
    end
    return soft_val
end

-- 获取当前家具所占格子数
function HomeWorldScene:getCurOccupyGridNum(  )
    local use_num = 0
    for k,unit in pairs(self.unit_list) do
        if unit:getFurnitureType() ~= HomeworldConst.Unit_Type.WallAcc and unit:getFurnitureType() ~= HomeworldConst.Unit_Type.Carpet then
            local num = unit:getOccupyGridNum()
            use_num = use_num + num
        end
    end
    return use_num
end

-- 调整家具的层级关系
function HomeWorldScene:updateAllFurnitureZOrder(  )
	local temp_list = {}
	for k,unit in pairs(self.unit_list) do
		_table_insert(temp_list, unit)
	end
	_table_insert(temp_list, self.home_role)
	for k,unit in pairs(self.visitors_list) do
		_table_insert(temp_list, unit)
	end
	_table_insert(temp_list, self.pet_unit)

	local sort_func = function ( objA, objB )
		local a_grid_x, a_grid_y = objA:getCurGridPos()
		local b_grid_x, b_grid_y = objB:getCurGridPos()
		if a_grid_y == b_grid_y then
			return a_grid_x < b_grid_x
		else
			return a_grid_y > b_grid_y
		end
	end
	table.sort(temp_list, sort_func)

	local zorder = 1
	for i,unit in ipairs(temp_list) do
		zorder = zorder + 1
        unit:setLocalZOrder(zorder)
	end
end

-- 根据家具的格子范围获取可以放置的位置
function HomeWorldScene:getRandomPosByRange( _type, dir, range, range_2 )
	if _type == HomeworldConst.Unit_Type.Carpet then
		_controller:updateOccupyGridList(nil, 2)
	else
		_controller:updateOccupyGridList(nil, 1)
	end
	local grid_x
	local grid_y
	local is_get = false
    local is_change_dir = false
	if _type == HomeworldConst.Unit_Type.Furniture or _type == HomeworldConst.Unit_Type.Carpet then  -- 地板家具
        if self:checkOccGridIsFull(_type, #range) then
            message(TI18N("地面格子数将超过可使用上限，无法新增家具"))
            return
        end
		grid_x = 11
		grid_y = 41
		grid_x, grid_y, is_get = self:checkLandUnitGrid(grid_x, grid_y, range)
        if not is_get then -- 找不到的话换一个方向找
            grid_x = 11
            grid_y = 41
            grid_x, grid_y, is_get = self:checkLandUnitGrid(grid_x, grid_y, range_2)
            is_change_dir = true
        end
	elseif _type == HomeworldConst.Unit_Type.WallAcc then -- 墙壁家具
		grid_x = 1
		grid_y = 57
		local tile_type = HOME_TILE_TYPE_L_WALL
		if dir == 2 then
			tile_type = HOME_TILE_TYPE_R_WALL
		end
        grid_x, grid_y, is_get = self:checkWallUnitGrid(grid_x, grid_y, range, tile_type)
        -- 如果默认方向找不到位置，换一面墙壁再找
		if not is_get then
            grid_x = 11
            grid_y = 57
            if tile_type == HOME_TILE_TYPE_L_WALL then
                tile_type = HOME_TILE_TYPE_R_WALL
            else
                tile_type = HOME_TILE_TYPE_L_WALL
            end
            grid_x, grid_y, is_get = self:checkWallUnitGrid(grid_x, grid_y, range_2, tile_type)
            is_change_dir = true
        end
	end

	if not is_get then
		message(TI18N("找不到合适的位置"))
		return
	end
	return grid_x, grid_y, is_change_dir
end

function HomeWorldScene:checkLandUnitGrid( grid_x, grid_y, range )
    local is_get = false
    for i=1,21 do
        for j=1,40 do
            if _model:checkGridWalkType(grid_x, grid_y) == HOME_TILE_TYPE_LAND then
                local grid_list = HomeTile.tilesOffset(grid_x, grid_y, range)
                local is_can_walk = self:checkRandomGridCanUse(grid_x, grid_y, range, HOME_TILE_TYPE_LAND)
                if is_can_walk == false then
                    grid_y = grid_y - 1
                else
                    is_get = true
                    break
                end
            else
                grid_y = grid_y - 1
            end
        end
        if is_get == false then
            grid_x = grid_x - 1
            if grid_x < 1 then
                grid_x = 21
            end
            grid_y = 41
        else
            break
        end
    end
    return grid_x, grid_y, is_get
end

function HomeWorldScene:checkWallUnitGrid( grid_x, grid_y, range, tile_type )
    local is_get = false
    for i=1,11 do
        for j=1,35 do
            if _model:checkGridWalkType(grid_x, grid_y) == tile_type then
                local grid_list = HomeTile.tilesOffset(grid_x, grid_y, range)
                local is_can_walk = self:checkRandomGridCanUse(grid_x, grid_y, range, tile_type)
                if is_can_walk == false then
                    grid_y = grid_y - 1
                else
                    is_get = true
                    break
                end
            else
                grid_y = grid_y - 1
            end
        end
        if is_get == false then
            grid_x = grid_x + 1
            grid_y = 57
        else
            break
        end
    end
    return grid_x, grid_y, is_get
end

-- 判断家具占用的格子是否达到了数量上限
function HomeWorldScene:checkOccGridIsFull( _type, need_num )
    local is_full = false
    need_num = need_num or 0
    local use_num = 0
    for k,unit in pairs(self.unit_list) do
        -- 只计算地板家具
        if unit:getFurnitureType() ~= HomeworldConst.Unit_Type.WallAcc then
            -- 判断一下是不是地毯
            if (_type == HomeworldConst.Unit_Type.Carpet and unit:checkIsCarpet()) or (_type ~= HomeworldConst.Unit_Type.Carpet and not unit:checkIsCarpet()) then
                local num = unit:getOccupyGridNum()
                use_num = use_num + num
            end
        end
    end

    local max_num_cfg = Config.HomeData.data_const["floor_effective_area_limit"]
    if max_num_cfg and max_num_cfg.val < (use_num+need_num) then
        is_full = true
    end
    return is_full
end

function HomeWorldScene:checkRandomGridCanUse( grid_x, grid_y, range, t_type )
	local grid_list = HomeTile.tilesOffset(grid_x, grid_y, range)
	local is_can = true
	for k,v in pairs(grid_list) do
		if not _model:checkGridIsCanWalk(v[1], v[2], t_type) then
			is_can = false
		end
		if is_can == false then
			break
		end
	end
	return is_can
end

----------------@ 角色相关 start
-- 创建本家园角色
function HomeWorldScene:updateHomeRole( figure_id )
	if not figure_id then return end

	if not self.home_role then
		self.home_role = HomeworldRole.New(self.unit_slayer)
	end
	local role_data = {}
	role_data.look_id = figure_id
	if self.cur_home_type == HomeworldConst.Type.Myself then
		local role_vo = RoleController:getInstance():getRoleVo()
		role_data.rid = role_vo.rid
		role_data.srv_id = role_vo.srv_id
        role_data.name = ""
	else
		role_data.rid = self.other_rid
		role_data.srv_id = self.other_srv_id
        role_data.name = self.owner_name
	end
    local is_my_home = (self.cur_home_type == HomeworldConst.Type.Myself)
    self.home_role:setVisible(true)
	self.home_role:setData(role_data, is_my_home, true)
end

-- 创建来访者角色列表
function HomeWorldScene:updateVisitorsList( visitors )
	for i = #self.visitors_list, 1, -1 do
        local role = _table_remove(self.visitors_list, i)
        role:setVisible(false)
        _table_insert(self.visitors_pool_list, role)
    end

    local is_my_home = (self.cur_home_type == HomeworldConst.Type.Myself)
    for i,v in ipairs(visitors) do
        delayRun(self.unit_slayer, i*2 / display.DEFAULT_FPS, function (  )
            local role = _table_remove(self.visitors_pool_list, 1)
            if not role then
                role = HomeworldRole.New(self.unit_slayer)
                role:setCanMoveRoleStatus(is_my_home)
            end
            _table_insert(self.visitors_list, role)
            role:setData(v, is_my_home)
            role:setVisible(true)
            if i == #visitors then -- 来访者创建完毕刷新一次层级
                self:updateAllFurnitureZOrder()
            end
        end)
    end
end

----------------@ 角色相关 end

----------------@ 宠物相关 start
-- 创建宠物
function HomeWorldScene:showPetUnit( status, data )
	if status == true and data then
		if not self.pet_unit then
			self.pet_unit = HomeworldPet.New(self.unit_slayer)
		end
		self.pet_unit:setData(data)
        self:checkoutPetStatus()
	elseif self.pet_unit then
		self.pet_unit:setVisible(false)
	end
end

function HomeWorldScene:checkoutPetStatus( )
    if not self.pet_unit then return end
    if self.cur_home_type == HomeworldConst.Type.Myself then
        --自己家
        if self.homepet_vo then
            local state = self.homepet_vo:getPetState()
            if state == HomepetConst.state_type.eNotActive or 
                state == HomepetConst.state_type.eOnWay then --未激活  和 在旅行中
                self.pet_unit:setVisible(false)
            elseif state == HomepetConst.state_type.eHome then --在家
                self.pet_unit:setVisible(true)
            end
        else
            self.pet_unit:setVisible(true)
        end
    else
        --别人家固定不显示
        self.pet_unit:setVisible(false)
    end
end

function HomeWorldScene:updateHomePetTalk(data)
    if not data then return end
    local config = Config.HomePetData.data_interaction_info[data.id]
    --类型1 表示聊天内容
    if config and config.type == 1 then
        if self.pet_unit then
            self.pet_unit:setPetTalkInfo(config.desc)
        end
    end
end

----------------@ 宠物相关 end

----------------@ 我的家具、方案、图鉴相关 start
-- 显示\隐藏
function HomeWorldScene:showMyUnitUi( status )
	if status == true then
		if not self.my_unit_ui then
			self.my_unit_ui = HomeworldMyUnit.New(self.ui_container)
		end
		self.my_unit_ui:setVisible(true)
		self.my_unit_ui:open()
	elseif self.my_unit_ui then
		self.my_unit_ui:setVisible(false)
	end
end

----------------@ 我的家具、方案、图鉴相关 end

-- 获取道具、人物、宠物所占据的格子列表 carpet_flag: 1:不计算地毯所占格子 2:家具中只计算地毯的格子
function HomeWorldScene:getOccupyGridList( unit_data, carpet_flag )
	local grid_list = {}

	unit_data = unit_data or {}
	local is_cal_furniture = true
	local is_cal_role = true
	local is_cal_pet = true
	for k,v in pairs(unit_data) do
		if v[1] == HomeworldConst.Scene_Unit_Type.Furniture and v[2] == nil then
			is_cal_furniture = false
		elseif v[1] == HomeworldConst.Scene_Unit_Type.Role and v[2] == nil then
			is_cal_role = false
		elseif v[1] == HomeworldConst.Scene_Unit_Type.Pet and v[2] == nil then
			is_cal_pet = false
		end
	end

	local function checkIsNeedCalById( unit_type, id )
		local is_cal = true
		for _,v in pairs(unit_data) do
			if v[1] == unit_type and v[2] == id then
				is_cal = false
				break
			end
		end
		return is_cal
	end

	-- 家具
	if is_cal_furniture then
		for k,unit in pairs(self.unit_list) do
			if not carpet_flag or (carpet_flag == 1 and not unit:checkIsCarpet()) or (carpet_flag == 2 and unit:checkIsCarpet()) then
				if checkIsNeedCalById(HomeworldConst.Scene_Unit_Type.Furniture, unit:getFurnitureId()) then
					local temp_list = unit:getOccupyGridList()
					for _,v in pairs(temp_list) do
						_table_insert(grid_list, v)
					end
				end
			end
		end
	end

	-- 角色和宠物
	if is_cal_role then
		if self.home_role then
			if checkIsNeedCalById(HomeworldConst.Scene_Unit_Type.Role, self.home_role:getSoleId()) then
				local temp_list = self.home_role:getOccupyGridList()
				for _,v in pairs(temp_list) do
					_table_insert(grid_list, v)
				end
			end
		end
		if self.pet_unit then
			local temp_list = self.pet_unit:getOccupyGridList()
			for _,v in pairs(temp_list) do
				_table_insert(grid_list, v)
			end
		end
		for k,role in pairs(self.visitors_list) do
			if role:isVisible() and checkIsNeedCalById(HomeworldConst.Scene_Unit_Type.Role, role:getSoleId()) then
				local temp_list = role:getOccupyGridList()
				for _,v in pairs(temp_list) do
					_table_insert(grid_list, v)
				end
			end
		end
	end

	return grid_list
end

-- 获取所有角色所占的格子
function HomeWorldScene:getAllRoleCurGridData(  )
    local grid_list = {}
    local grid_x, grid_y = self.home_role:getCurGridPos()
    _table_insert(grid_list, {grid_x, grid_y})
    for k,role in pairs(self.visitors_list) do
        if role:isVisible() then
            local r_grid_x, r_grid_y = role:getCurGridPos()
            _table_insert(grid_list, {r_grid_x, r_grid_y})
        end
    end
    return grid_list
end

-- 更新红点相关
function HomeWorldScene:updateRedBtnStatus( bid, status )
    if bid == HomeworldConst.Red_Index.Visit then
        local visit_red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Visit)
        addRedPointToNodeByStatus( self.my_visit_btn, visit_red_status )
    elseif bid == HomeworldConst.Red_Index.Suit then
        if self.edit_btn then
            local suit_red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Suit)
            addRedPointToNodeByStatus( self.edit_btn, suit_red_status )
        end
    elseif bid == HomeworldConst.Red_Index.Hook then
        local hook_red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Hook)
        if self.hook_time_award then
            self.hook_time_award:setRedStatus(hook_red_status)
        end
    --[[elseif bid == HomeworldConst.Red_Index.Figure then
        local figure_red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Figure)
        addRedPointToNodeByStatus( self.figure_btn, figure_red_status )--]]
    else
        -- 被访问红点
        local visit_red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Visit)
        addRedPointToNodeByStatus( self.my_visit_btn, visit_red_status )

        -- 套装红点
        if self.edit_btn then
            local suit_red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Suit)
            addRedPointToNodeByStatus( self.edit_btn, suit_red_status )
        end

        -- 挂机时间红点
        local hook_red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Hook)
        if self.hook_time_award then
            self.hook_time_award:setRedStatus(hook_red_status)
        end

        -- 形象解锁
        --[[local figure_red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Figure)
        addRedPointToNodeByStatus( self.figure_btn, figure_red_status )--]]
    end
end

--------------@ 测试代码
-- 画出网格
--[[function HomeWorldScene:showAllGrid( status )
	self.test_all_grid_list = self.test_all_grid_list or {}
	for k,v in pairs(self.test_all_grid_list) do
		v:setVisible(false)
	end
	if status == true then
		for i=1,22 do
			for j=1,62 do
				delayRun(self.unit_slayer, (i+j)/display.DEFAULT_FPS, function (  )
					local index = i*100 + j
					local grid = self.test_all_grid_list[index]
					if not grid then
						grid = createSprite(PathTool.getResFrame("homeworld", "homeworld_1023"), nil, nil, self.unit_slayer, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
						grid:setOpacity(120)
						self.test_all_grid_list[index] = grid
						grid.pos_txt = createLabel(14, 1, nil, 32, 16, nil, grid, nil, cc.p(0.5, 0.5))
					end
					grid:setVisible(true)
					local pos_x, pos_y = HomeTile.toPixel(nil, i, j)
					grid:setPosition(cc.p(pos_x, pos_y))
					grid.pos_txt:setString(_string_format("%d,%d", i, j))
				end)
			end
		end
	end
	self.cur_all_grid_status = status
end--]]

function HomeWorldScene:close_callback( )
    self:showHomeSceneScaleAni(false)
	self:playEnterEffect(false)
    self:playCloudEffect(false)
    self.root_wnd:stopAllActions()
    if self.homepet_vo then
        if self.home_pet_vo_attt_event ~= nil then 
            self.homepet_vo:UnBind(self.home_pet_vo_attt_event)
            self.home_pet_vo_attt_event = nil
        end
        self.homepet_vo = nil
    end

	if self.set_name_alert then
        self.set_name_alert:close()
        self.set_name_alert = nil
    end

	if self.sky_load then
		self.sky_load:DeleteMe()
		self.sky_load = nil
	end
	if self.build_load then
		self.build_load:DeleteMe()
		self.build_load = nil
	end
	if self.wall_load then
		self.wall_load:DeleteMe()
		self.wall_load = nil
	end
	if self.floor_load then
		self.floor_load:DeleteMe()
		self.floor_load = nil
    end
    for k,v in pairs(self.visitors_list) do
		v:DeleteMe()
		v = nil
    end
    for k,v in pairs(self.visitors_pool_list) do
		v:DeleteMe()
		v = nil
    end
	if self.pet_unit then
		self.pet_unit:DeleteMe()
		self.pet_unit = nil
	end
	if self.home_role then
		self.home_role:DeleteMe()
		self.home_role = nil
	end
    for k,v in pairs(self.unit_list) do
        v:DeleteMe()
        v = nil
    end
    for k,v in pairs(self.unit_pools) do
        v:DeleteMe()
        v = nil
    end
	if self.save_alert then
		self.save_alert:DeleteMe()
		self.save_alert = nil
	end
	if self.my_unit_ui then
		self.my_unit_ui:DeleteMe()
		self.my_unit_ui = nil
    end
    AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, "s_002", true) -- 恢复主城背景音乐播放
	MainuiController:getInstance():setMainUIShowStatus(true)
	_model:clearHomeCacheData() -- 清一下家园数据
	_controller:openHomeworldScene(false)
    _controller:openHomeworldSuitWindow(false)

    --检查萌宠对应家园的红点
    HomepetController:getInstance():getModel():checkHomeWorldRedpoint()
end
-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛我的精彩界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionMyGuessWindow = ArenaChampionMyGuessWindow or BaseClass(BaseView)

function ArenaChampionMyGuessWindow:__init(view_type)
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.is_full_screen = false
	self.layout_name = "arena/arena_champion_my_guess_window"
	self.res_list = {
	-- {path = PathTool.getPlistImgForDownLoad("arena", "arenaloop"), type = ResourcesType.plist},
	}

    self.view_type = view_type or ArenaConst.champion_type.normal
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl = ArenaController:getInstance()
        self.model = self.ctrl:getChampionModel()
    else
        self.ctrl = CrosschampionController:getInstance()
        self.model = self.ctrl:getModel()
    end
end 

function ArenaChampionMyGuessWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
    local main_panel = main_container:getChildByName("main_panel")
    main_panel:getChildByName("win_title"):setString(TI18N("我的竞猜"))

    self.close_btn = main_panel:getChildByName("close_btn")
    self.list_view = main_panel:getChildByName("list_view")

    self.empty_tips = main_panel:getChildByName("empty_tips")
    self.empty_tips:getChildByName("desc"):setString(TI18N("暂无任何竞猜"))

    self.item = main_panel:getChildByName("item")
end

function ArenaChampionMyGuessWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			ArenaController:getInstance():openArenaChampionMyGuessWindow(false)
		end
	end)
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			ArenaController:getInstance():openArenaChampionMyGuessWindow(false)
		end
    end)
    if self.update_my_guess_list_event == nil then
        self.update_my_guess_list_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateMyGuessListEvent, function(list) 
            self:updateMyGuessList(list)
        end)
    end
end

function ArenaChampionMyGuessWindow:openRootWnd()
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl:requestMyGuessInfo()
    else
        self.ctrl:sender26205()
    end
end

function ArenaChampionMyGuessWindow:updateMyGuessList(list)
    if list == nil or next(list) == nil then
        self.empty_tips:setVisible(true)
        if self.scroll_view then
            self.scroll_view:setVisible(false)
        end
    else
        self.empty_tips:setVisible(false)
        if self.scroll_view == nil then
            local size = self.list_view:getContentSize()
            local setting = {
                item_class = ArenaChampionMyGuessItem,
                start_x = 4,
                space_x = 4,
                start_y = 4,
                space_y = -2,
                item_width = 600,
                item_height = 136,
                row = 0,
                col = 1,
                need_dynamic = true
            }
            self.scroll_view = CommonScrollViewLayout.new(self.list_view, nil, nil, nil, size, setting)
        end
        self.scroll_view:setVisible(true)
        self.scroll_view:setData(list, nil, nil, {node=self.item, view_type=self.view_type}) 
    end
end

function ArenaChampionMyGuessWindow:close_callback()
    if self.update_my_guess_list_event then
        GlobalEvent:getInstance():UnBind(self.update_my_guess_list_event)
        self.update_my_guess_list_event = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    ArenaController:getInstance():openArenaChampionMyGuessWindow(false)
end




-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛我的竞猜单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionMyGuessItem = class("ArenaChampionMyGuessItem", function()
	return ccui.Layout:create()
end)

function ArenaChampionMyGuessItem:ctor()
	self.is_completed = false
end

--==============================--
--desc:设置扩展参数  {node = self.item, count = self.interaction_count} 
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function ArenaChampionMyGuessItem:setExtendData(data)
    if not data then return end
    local node = data.node
    self.view_type = data.view_type	
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
		
        local left_role = self.root_wnd:getChildByName("left_role")
		self.left_head = PlayerHead.new(PlayerHead.type.circle)
		self.left_head:setPosition(60, 60)
		left_role:addChild(self.left_head)

        local right_role = self.root_wnd:getChildByName("right_role")
		self.right_head = PlayerHead.new(PlayerHead.type.circle)
		self.right_head:setPosition(60, 60)
		right_role:addChild(self.right_head)

        self.success_img = self.root_wnd:getChildByName("success_img")  -- 胜利的标志,在该竞猜有结果才会显示
        self.result_label = self.root_wnd:getChildByName("result_label") -- 投注,得到或者失去
        self.match_step_label = self.root_wnd:getChildByName("match_step_label") -- 该竞猜的战斗阶段

        self.left_name = self.root_wnd:getChildByName("left_name")
        self.right_name = self.root_wnd:getChildByName("right_name")

        self.role_name = self.root_wnd:getChildByName("role_name")  -- 还没有出结果的时候,显示的竞猜对象名字
        self.info_btn = self.root_wnd:getChildByName("info_btn") -- 该竞猜已经出结果的时候的战斗按钮
        self.check_fight_btn = self.root_wnd:getChildByName("check_fight_btn") -- 该竞猜已经出结果的时候的观战按钮

        self.assets_container = self.root_wnd:getChildByName("assets_container") -- 竞猜的押注数量信息
        self.assets_value = self.assets_container:getChildByName("value")   -- 竞猜币的大小,颜色买得到是红色失去是蓝色,普通是175号色码

        if self.view_type == ArenaConst.champion_type.cross and Config.ItemData.data_get_data(33) then
            self.assets_container:getChildByName("Image_53"):loadTexture(PathTool.getItemRes(Config.ItemData.data_get_data(33).icon), LOADTEXT_TYPE)
        end

        -- 押注信息需要根据当前的押注结果显示位置,这边先写死吧
        self.role_name_y = 62 
        self.assets_y = self.assets_container:getPositionY() 

        self.left_success_x = 35
        self.right_success_x = 192

        self.success_img:setVisible(true)
		
		self:registerEvent()
	end
end

function ArenaChampionMyGuessItem:registerEvent()
	self.left_head:addCallBack(function()
		if self.data ~= nil then
            if self.data ~= nil and self.data.srv_id ~= "" then
			    FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.a_srv_id, rid = self.data.a_rid})
            end
		end
	end, false)
	self.right_head:addCallBack(function()
		if self.data ~= nil then
            if self.data ~= nil and self.data.srv_id ~= "" then
			    FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.b_srv_id, rid = self.data.b_rid})
            end
		end
	end, false)
	
	self.check_fight_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data and self.data.replay_id ~= 0 then
                if self.view_type == ArenaConst.champion_type.normal then
                    BattleController:getInstance():csRecordBattle(self.data.replay_id)
                else
                    local base_info = CrosschampionController:getInstance():getModel():getBaseInfo()
                    if base_info then
                        BattleController:getInstance():csRecordBattle(self.data.replay_id, base_info.srv_id)
                    else
                        BattleController:getInstance():csRecordBattle(self.data.replay_id)
                    end
                end 
            end
		end
	end)
	self.info_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            if self.data then
                ArenaController:getInstance():openArenaChampionReportWindow(true, self.data, self.view_type)
            end
		end
	end)
end

function ArenaChampionMyGuessItem:setData(data)
	if data then
        self.data = data
        if self.data.ret == 0 then         -- 正在进行中
            self.success_img:setVisible(fasle)
            self.info_btn:setVisible(false)
            self.check_fight_btn:setVisible(false)
            self.role_name:setVisible(true)
            self.assets_container:setPositionY(self.assets_y)
            self.result_label:setString(TI18N("投注:"))
            self.assets_value:setTextColor(Config.ColorData.data_color4[175])
            self.assets_value:setString(self.data.bet)
            if self.data.target == 1 then
                self.role_name:setString(transformNameByServ(self.data.a_name, self.data.a_srv_id))
            else
                self.role_name:setString(transformNameByServ(self.data.b_name, self.data.b_srv_id))
            end
        else
            self.success_img:setVisible(true)
            self.info_btn:setVisible(true)
            self.check_fight_btn:setVisible(true)
            self.role_name:setVisible(false)
            self.assets_container:setPositionY(self.role_name_y)
            if self.data.target == self.data.ret then   -- 这个时候是胜利的 
                self.result_label:setString(TI18N("得到:"))
                self.assets_value:setTextColor(Config.ColorData.data_color4[202])
                self.assets_value:setString(self.data.get_bet)
            else
                self.result_label:setString(TI18N("失去:"))
                self.assets_value:setTextColor(Config.ColorData.data_color4[183])
                self.assets_value:setString(self.data.bet)
            end

            if self.data.ret == 1 then      -- 左边赢了
                self.success_img:setPositionX(self.left_success_x)
            else
                self.success_img:setPositionX(self.right_success_x)
            end
        end
        self.left_head:setHeadRes(self.data.a_face, false, LOADTEXT_TYPE, self.data.a_face_file, self.data.a_face_update_time)
        self.right_head:setHeadRes(self.data.b_face, false, LOADTEXT_TYPE, self.data.b_face_file, self.data.b_face_update_time)

        self.left_name:setString(self.data.a_name)
        self.right_name:setString(self.data.b_name)

        self.match_step_label:setString(ArenaConst.getMatchStepDesc2(self.data.step, self.data.round))
	end
end

function ArenaChampionMyGuessItem:DeleteMe()
	if self.left_head then
		self.left_head:DeleteMe()
		self.left_head = nil
	end
	if self.right_head then
		self.right_head:DeleteMe()
		self.right_head = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end 
--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-22 16:32:50
-- @description    : 
		-- 跨服冠军赛入口主界面
---------------------------------
local _controller = CrosschampionController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

CrosschampionMainWindow = CrosschampionMainWindow or BaseClass(BaseView)

function CrosschampionMainWindow:__init()
    self.is_full_screen = true
    self.layout_name = "crosschampion/crosschampion_main_window"
    self.win_type = WinType.Full  
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("crosschampion","crosschampion"), type = ResourcesType.plist },
    }

    local res_id = BattleController:getInstance():curBattleResId(BattleConst.Fight_Type.CrossChampion)
    self.background_path = string.format("resource/bigbg/battle_bg/%s/b_bg.jpg", res_id)
    table.insert(self.res_list, {path = self.background_path, type = ResourcesType.single} )

    self.statue_list = {}
    self.cross_open_status = 0
end

function CrosschampionMainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(self.background_path, LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(main_container, 1)

    main_container:getChildByName("worship"):setString(TI18N("被膜拜次数:"))

    local tab_container = main_container:getChildByName("tab_container")

    local stage_panel = main_container:getChildByName("stage_panel")
    self.rank_btn = stage_panel:getChildByName("rank_btn")
    self.rank_btn:getChildByName("label"):setString(TI18N("排行榜"))
    self.shop_btn = stage_panel:getChildByName("shop_btn")
    self.shop_btn:getChildByName("label"):setString(TI18N("冠军商店"))
    self.guess_btn = stage_panel:getChildByName("guess_btn")
    self.guess_btn:getChildByName("label"):setString(TI18N("我的布阵"))

    for i=1,3 do
    	local statue = main_container:getChildByName("statue_" .. i)
    	if statue then
    		local object = {}
    		object.model = statue:getChildByName("model")
    		object.role_name = statue:getChildByName("role_name")
    		object.desc = statue:getChildByName("desc")
            object.desc:setString(TI18N("虚位以待"))
    		object.worship_btn = statue:getChildByName("worship_btn")
    		object.worship_label = object.worship_btn:getChildByName("label")
            object.size = object.model:getContentSize()
            object.index = i
    		_table_insert(self.statue_list, object)
    	end
    end

    self.my_worship_num = main_container:getChildByName("worship_num")
    local role_vo = RoleController:getInstance():getRoleVo()
    self.my_worship_num:setString(role_vo.cross_cham_worship or 0)

    local dec_container = main_container:getChildByName("dec_container")
    self.dec_container = dec_container
    self.tips_btn = dec_container:getChildByName("tips_btn")
    self.my_rank_lable = dec_container:getChildByName("my_rank_lable")
    self.my_total_rank = dec_container:getChildByName("my_total_rank")
    self.notice_label = dec_container:getChildByName("notice_label")
    self.notice_label:setString(TI18N("跨服天梯前256名可参与，奖励将通过邮件发放"))
    dec_container:getChildByName("label_1"):setString(TI18N("当前赛程:"))
    dec_container:getChildByName("label_2"):setString(TI18N("当前排名:"))
    dec_container:getChildByName("label_3"):setString(TI18N("历史最高排名:"))
    dec_container:getChildByName("label_4"):setString(TI18N("赛季时间:"))
    dec_container:getChildByName("label_5"):setString(TI18N("系统提示:"))

    -- 当前赛况
    self.match_step = createRichLabel(24, 1, cc.p(0, 0.5), cc.p(163, 175), nil, nil, 560) 
    dec_container:addChild(self.match_step)

    -- 赛季时间
    self.match_desc = createRichLabel(24, 1, cc.p(0, 0.5), cc.p(163, 66), nil, nil, 560)
    dec_container:addChild(self.match_desc)

    local btn_container = main_container:getChildByName("btn_container")
    self.close_btn = btn_container:getChildByName("close_btn")
    self.enter_btn = btn_container:getChildByName("enter_btn")
    self.enter_btn:getChildByName("label"):setString(TI18N("进入挑战"))

    -- 适配
    local top_off = display.getTop(main_container)
	local bottom_off = display.getBottom(main_container)
	tab_container:setPositionY(top_off - 174)
	btn_container:setPositionY(bottom_off + 138)
end

function CrosschampionMainWindow:register_event(  )
	registerButtonEventListener(self.rank_btn, handler(self, self._onClickRankBtn), true)
	registerButtonEventListener(self.shop_btn, handler(self, self._onClickShopBtn), true)
	registerButtonEventListener(self.tips_btn, handler(self, self._onClickTipsBtn), true)
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true)
	registerButtonEventListener(self.guess_btn, handler(self, self._onClickGuessBtn), true)
	registerButtonEventListener(self.enter_btn, handler(self, self._onClickEnterBtn), true)

    for k, object in pairs(self.statue_list) do
        object.worship_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if object.data ~= nil then
                    RoleController:getInstance():requestWorshipRole(object.data.rid, object.data.srv_id, k, WorshipType.crosschampion)
                end
            end
        end)
    end

    -- 个人信息
    self:addGlobalEvent(ArenaEvent.UpdateChampionRoleInfoEvent, function ( )
        self:setRoleInfo()
    end)

    -- 冠军赛信息
    self:addGlobalEvent(ArenaEvent.UpdateChampionBaseInfoEvent, function (  )
        self:setBaseInfo()
    end)

    -- 前三名数据
    self:addGlobalEvent(CrosschampionEvent.UpdateChampionTop3Event, function ( data )
        self:updateStatueInfo(data)
    end)

    -- 点赞
    self:addGlobalEvent(RoleEvent.WorshipOtherRole, function ( rid, srv_id, idx )
        if idx ~= nil then
            local object = self.statue_list[idx]
            if object ~= nil and object.worship_label ~= nil and object.worship_num ~= nil then
                object.worship_num = object.worship_num + 1
                object.worship_label:setString(object.worship_num)
                object.worship_btn:setTouchEnabled(false)
                setChildUnEnabled(true, object.worship_btn, Config.ColorData.data_color4[1])
                object.worship_label:enableOutline(cc.c3b(0x4b,0x4b,0x4b), 2)
            end
        end
    end)

    -- 被膜拜次数
    self:addGlobalEvent(RoleEvent.UpdateCrossChamWorshipEvent, function ( worship_num )
        self.my_worship_num:setString(worship_num or 0)
    end)
end

function CrosschampionMainWindow:_onClickRankBtn(  )
	ArenaController:getInstance():openArenaChampionRankWindow(true, ArenaConst.champion_type.cross)
end

function CrosschampionMainWindow:_onClickShopBtn(  )
	_controller:openCrosschampionShopWindow(true)
end

function CrosschampionMainWindow:_onClickTipsBtn(  )
    if Config.ArenaClusterChampionData.data_explain then
        MainuiController:getInstance():openCommonExplainView(true, Config.ArenaClusterChampionData.data_explain)
    end
end

function CrosschampionMainWindow:_onClickCloseBtn(  )
	_controller:openCrosschampionMainWindow(false)
end

function CrosschampionMainWindow:_onClickGuessBtn(  )
	HeroController:getInstance():openFormMainWindow(true, PartnerConst.Fun_Form.ArenaChampion)
end

function CrosschampionMainWindow:_onClickEnterBtn(  )
    if self.cross_open_status == 1 then
        message(TI18N("需等待跨服天梯开启"))
        return
    elseif self.cross_open_status == 2 then
        local limit_num = 64
        local limit_cfg = Config.ArenaClusterChampionData.data_const["open_number_limit"]
        if limit_cfg then
            limit_num = limit_cfg.val
        end
        message(_string_format(TI18N("参赛玩家不足%d名，本次周冠军赛无法开启"), limit_num))
        return
    end
	ArenaController:getInstance():openArenaChampionMatchWindow(true, 1, ArenaConst.champion_type.cross)
end

function CrosschampionMainWindow:openRootWnd(  )
    _controller:sender26200()
	_controller:sender26206()
    _controller:sender26201()
    _controller:sender26213()
    RoleController:getInstance():requestCrossChamWorshipNum()
    self:setBaseInfo()
    self:updateStatueInfo()
end

function CrosschampionMainWindow:setBaseInfo(  )
    local base_info = _model:getBaseInfo()
    if not base_info then return end

    if base_info.step == ArenaConst.champion_step.unopened then
        self.match_step:setString(_string_format("<div fontcolor=#ff5353 outline=1,#000000>%s</div>", TI18N("暂未开启"))) 
    elseif base_info.step == ArenaConst.champion_step.score then
        if base_info.step_status == ArenaConst.champion_step_status.unopened then
            self.match_step:setString(_string_format("<div outline=1,#000000>%s-</div><div fontcolor=#ff5353 outline=1,#000000>%s</div>", TI18N("选拔赛"), TI18N("暂未开启")))
        else
            self.match_step:setString(_string_format("<div outline=1,#000000>%s-</div><div fontcolor=#4af915 outline=1,#000000>%s</div>", TI18N("选拔赛"), TI18N("正式进行")))
        end
    elseif base_info.step == ArenaConst.champion_step.match_64 then
        if base_info.step_status == ArenaConst.champion_step_status.unopened then
            self.match_step:setString(_string_format("<div outline=1,#000000>%s-</div><div fontcolor=#ff5353 outline=1,#000000>%s</div>", TI18N("64强赛"), TI18N("暂未开启")))
        else
            self.match_step:setString(_string_format("<div outline=1,#000000>%s-</div><div fontcolor=#4af915 outline=1,#000000>%s</div>", TI18N("64强赛"), TI18N("正在进行")))
        end
    elseif base_info.step == ArenaConst.champion_step.match_8 then
        if base_info.step_status == ArenaConst.champion_step_status.over then
            self.match_step:setString(_string_format("<div outline=1,#000000>%s</div>", TI18N("周冠军赛已结束"))) 
        else
            self.match_step:setString(_string_format("<div outline=1,#000000>%s-</div><div fontcolor=#4af915 outline=1,#000000>%s</div>", TI18N("8强赛"), TI18N("正在进行")))
        end
    end

    doStopAllActions(self.match_desc)
    self.cross_open_status = base_info.is_open or 0
    if base_info.is_open == 1 then
        self.match_step:setString(_string_format("<div fontcolor=#ff5353 outline=1,#000000>%s</div>", TI18N("暂未开启")))
        self.match_desc:setString(_string_format("<div fontcolor=#ff5353 outline=1,#000000>%s</div>", TI18N("暂未开启")))
    elseif base_info.is_open == 2 then
        local limit_num = 64
        local limit_cfg = Config.ArenaClusterChampionData.data_const["open_number_limit"]
        if limit_cfg then
            limit_num = limit_cfg.val
        end
        self.match_step:setString(_string_format("<div outline=1,#000000>%s</div><div fontcolor=#4af915 outline=1,#000000>%d</div><div outline=1,#000000>%s</div>", TI18N("参赛玩家不足"), limit_num, TI18N("名，本次周冠军赛无法开启")))
        self.match_desc:setString(_string_format("<div fontcolor=#ff5353 outline=1,#000000>%s</div>", TI18N("暂未开启")))
    else
        local less_time = base_info.step_status_time - GameNet:getInstance():getTime()
        if less_time < 0 then
            less_time = 0
        end 
        self:setLessTime(base_info.start_time, base_info.end_time, less_time)
    end
end

function CrosschampionMainWindow:setLessTime( start_time, end_time, less_time )
    if tolua.isnull(self.match_desc) then return end
    doStopAllActions(self.match_desc)
    if less_time > 0 then
        self.match_desc:setString(_string_format("<div outline=1,#000000>%s-%s</div><div fontcolor=#4af915 outline=1,#000000>（剩余时间:%s）</div>",TimeTool.getMD(start_time),TimeTool.getMD(end_time),TimeTool.GetTimeFormatTwo(less_time))) 
        self.match_desc:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(self.match_desc)
            else
                self.match_desc:setString(_string_format("<div outline=1,#000000>%s-%s</div><div fontcolor=#4af915 outline=1,#000000>（剩余时间:%s）</div>",TimeTool.getMD(start_time),TimeTool.getMD(end_time),TimeTool.GetTimeFormatTwo(less_time))) 
            end
        end))))
    else
        self.match_desc:setString(_string_format("<div outline=1,#000000>%s-%s</div><div fontcolor=#4af915 outline=1,#000000>（剩余时间:%s）</div>",TimeTool.getMD(start_time),TimeTool.getMD(end_time),TimeTool.GetTimeFormatTwo(less_time))) 
    end
end

function CrosschampionMainWindow:setRoleInfo(  )
    local data = _model:getRoleInfo()
    if not data then return end

    local rank = data.rank or 0
    local best_rank = data.best_rank or 0
    if rank == 0 then
        self.my_rank_lable:setString(TI18N("未上榜"))
    else
        self.my_rank_lable:setString(rank)
    end
    if best_rank == 0 then
        self.my_total_rank:setString(TI18N("未上榜"))
    else
        self.my_total_rank:setString(best_rank)
    end
end

function CrosschampionMainWindow:updateStatueInfo( list )
    list = list or {}
    local role_vo = RoleController:getInstance():getRoleVo()
    for i, object in ipairs(self.statue_list) do
        local data = list[object.index]
        if data == nil then
            object.role_name:setVisible(false)
            object.desc:setVisible(true)
            object.worship_btn:setVisible(false)
        else
            object.role_name:setVisible(true)
            object.desc:setVisible(false)
            object.worship_btn:setVisible(true)
            object.role_name:setString(transformNameByServ(data.name, data.srv_id))
            object.worship_label:setString(data.worship)
            object.worship_num = data.worship               -- 缓存一下当前被赞的数量，这样用于点赞成功之后的数量更改
            
            if data.worship_status == TRUE or role_vo:isSameRole(data.srv_id, data.rid) then
                object.worship_btn:setTouchEnabled(false)
                setChildUnEnabled(true, object.worship_btn, Config.ColorData.data_color4[1])
                object.worship_label:enableOutline(cc.c3b(0x4b,0x4b,0x4b), 2)
            else
                object.worship_btn:setTouchEnabled(true)
                setChildUnEnabled(false, object.worship_btn, Config.ColorData.data_color4[175])
                object.worship_label:enableOutline(Config.ColorData.data_color4[277], 2)
            end
        end
        object.data = data
        -- 延迟创建模型，避免打开面板的时候卡
        delayRun(self.dec_container, 5 * i / display.DEFAULT_FPS, function()
            self:setStatueModel(object)
        end)
    end
end

function CrosschampionMainWindow:setStatueModel( object )
    if not object or tolua.isnull(object.model) then return end
    local data = object.data
    if data == nil then
        if object.spine ~= nil then
            if object.spine ~= nil then
                object.spine:DeleteMe()
                object.spine = nil
            end
            object.spine_id = nil
        end
        return
    end
    
    if object.spine_id == data.lookid then return end
    
    if object.spine ~= nil then
        object.spine:DeleteMe()
        object.spine = nil
    end
    object.spine_id = data.lookid
    object.spine = BaseRole.new(BaseRole.type.role, data.lookid)
    object.spine:setAnimation(0, PlayerAction.show, true)
    object.spine:setPosition(cc.p(object.size.width * 0.5, 145))
    object.spine:setAnchorPoint(cc.p(0.5, 0))
    object.model:addChild(object.spine)
end

function CrosschampionMainWindow:close_callback(  )
    doStopAllActions(self.dec_container)
    doStopAllActions(self.match_desc)
    for i, object in ipairs(self.statue_list) do
        if object.spine ~= nil then
            if object.spine ~= nil then
                object.spine:DeleteMe()
                object.spine = nil
            end
        end
    end
    self.status_list = nil
	_controller:openCrosschampionMainWindow(false)
end
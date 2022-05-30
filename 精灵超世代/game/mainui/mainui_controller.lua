-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      主UI控制器
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
MainuiController = MainuiController or BaseClass(BaseController)

local tolua_isnull = tolua.isnull  

function MainuiController:config()
    self.model = MainuiModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.function_list = {}                             -- 当前已经激活的图标,包含客户端自己的以及服务端的
    self.cur_index_status = 0                           --当前点击按钮
    self.ui_fight_type = MainuiConst.ui_fight_type.main_scene

    self.main_scene_btn_status = false

    self.cache_tips_list = {}                           -- 当前缓存的图标状态
    self.cache_wait_create_list = {}                    -- 缓存待创建的图标,可能是等级不足,可能是关卡数不对
end

function MainuiController:getModel()
    return self.model
end

function MainuiController:registerEvents()
    if self.init_main_event == nil then
        self.init_main_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_main_event)
            self.init_main_event = nil
            if self.role_change_event == nil then
                self.role_vo = RoleController:getInstance():getRoleVo()
                if self.role_vo ~= nil then
                    self.role_change_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function( key, value )
                        if key == "lev" then
                            self:checkFunctionByRoleLev(value)
                            sdkSubmitUserData(4) -- SDK采集数据
                        end
                    end)
                end
            end
        end)
    end
    if self.update_drama_max_event == nil then
        self.update_drama_max_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Update_Max_Id, function(max_id)
            self:updateMainBtnStatus(max_id)
        end)
    end 

    -- 请求进入竞技场之前，需要告诉服务器，我要进去了，有没有真是战斗，快点告诉我
    if self.combat_type_back_event == nil then
        self.combat_type_back_event = GlobalEvent:getInstance():Bind(BattleEvent.COMBAT_TYPE_BACK, function(combat_type, type)
            if type == 0 then -- 不存在战斗
                self:openRelevanceWindowAtOnce(combat_type)
            end
        end)
    end

    -- 如果是竞技场退出战斗的话，并且也是存在当前请求打开竞技场面板的情况下，则打开竞技场面板
    if self.battle_exit_event == nil then
        self.battle_exit_event = GlobalEvent:getInstance():Bind(SceneEvent.EXIT_FIGHT, function(combat_type)
            -- 判断一下是否还有未完成的战斗
            if not BattleController:getInstance():getModel():checkIsHaveUnfinishedWar(combat_type) then
                self:openRelevanceWindowAtOnce(combat_type)
            end
        end)
    end

    --代金券的检测(协议的推送)
    if self.isopen_perfer_event == nil then
        self.isopen_perfer_event = GlobalEvent:getInstance():Bind(ActionEvent.ACTION_PERFER_ISOPEN, function(status)
            --IOS不展示
            if not IS_IOS_PLATFORM then
                self:checkFunctionByPerfer(status)
            end
        end)
    end

end

--==============================--
--desc:获取主UI
--time:2017-06-06 04:13:26
--return 
--==============================--
function MainuiController:getMainUi()
    if self.mainui then
        return self.mainui
    end
end

--[[
    @desc: 引导需要
    author:{author}
    time:2018-08-09 11:14:49
    @return:
]]
function MainuiController:getMainUiRoot()
    if self.mainui then
        return self.mainui.node
    end
end

function MainuiController:registerProtocals()
    self:RegisterProtocal(12742, "handle12742")
    self:RegisterProtocal(16630, "handle16630")     -- 边玩边下领取奖励状态
    self:RegisterProtocal(16631, "handle16631")     -- 边玩边下领取奖励

    
    self:RegisterProtocal(10931, "handle10931")     -- 二维码扫一扫
end

function MainuiController:DeleteMe()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
    if self.mainui ~= nil then
        self.mainui:DeleteMe()
        self.mainui = nil
    end
    if self.notice_view then
        self.notice_view:DeleteMe()
        self.notice_view = nil
    end
    
    self.is_init = false
end

--==============================--
--desc:判断主ui下面6个按钮的状态
--time:2018-06-06 07:17:18
--@max_dun_id:
--@return 
--==============================--
function MainuiController:updateMainBtnStatus(max_dun_id)
    if self.mainui ~= nil then
        self.mainui:checkUnLockStatus(max_dun_id)
    else
        self.max_dun_id = max_dun_id
    end

    -- 判断是否有需要按照推图等级开启的功能图标
    self:checkFunctionByDrama(max_dun_id)
end

function MainuiController:setMergeServerContainerPositionY(is_offset)
    if self.mainui then
        self.mainui:setMergeServerContainerPositionY(is_offset)
    end
end

--==============================--
--desc:打开主界面,只有在主城,并且非战斗状态下,才显示
--time:2017-08-08 02:00:06
--@status:
--@is_hide: 是否是隐藏还是释放
--@return 
--==============================--
function MainuiController:openMainUI(status)
    local in_fight = BattleController:getInstance():isInFight()
    if status == true and in_fight == false then 
        if self.mainui == nil then
            self.mainui = MainUiView.New(self)
            self:checkFunctionByRoleLev()

            -- 打开主城之后再请求边玩边下吧
            delayOnce(function() 
                self:requestDownLoadStatus()
            end, 0.5) 
        end
        if self.mainui then
            self.mainui:open()
            self.mainui:checkShowNewPromptBubble()
            
            -- 这里做一下开启条件监测
            if self.max_dun_id ~= nil then
                self.mainui:checkUnLockStatus(self.max_dun_id)
                self.max_dun_id = nil
            end
        end   

        -- 挂接信息提示
        if self.notice_view == nil then 
            self.notice_view = MainUiNoticeView.new()   
        end
    else
        if self.mainui then
            self.mainui:close()
        end
    end
end

--==============================--
--desc:设置聊天气泡的状态
--time:2017-07-29 03:24:43
--@id:
--@return 
--==============================--
function MainuiController:setMainUIChatBubbleStatus(status)
    if self.mainui then
        self.mainui:setMainUIChatBubbleStatus(status)
    end
end

-- 设置主城上下部分UI的显示状态
function MainuiController:setMainUIShowStatus( status )
    if self.mainui then
        self.mainui:setIsShowMainUI(status)
    end
end

-- 设置主城底部UI显示状态
function MainuiController:setIsShowMainUIBottom( status )
    if self.mainui then
        self.mainui:setShowBottomUI(status)
    end
end

-- 设置主城顶部功能图标显示
function MainuiController:showFuncIconList( status )
    if self.mainui then
        self.mainui:showFuncIconList(status)
    end
end

-- 更新主城左右两侧图标红点
function MainuiController:updateIconRedStatus(  )
    if self.mainui then
        self.mainui:updateIconRedStatus()
    end
end

--==============================--
--desc:根据id获取指定的图标数据
--time:2017-07-29 03:24:43
--@id:
--@return 
--==============================--
function MainuiController:getFunctionIconById(id)
    return self.function_list[id]
end

--==============================--
--desc:设置功能图标的红点状态,主要是function_data_info的数据
--time:2018-07-22 02:54:58
--@id:
--@data:
--@return 
--==============================--
function MainuiController:setFunctionTipsStatus(id, data)
    if type(id) ~= "number" then return end
    local vo = self:getFunctionIconById(id)
    if vo then
        vo:setTipsStatus(data)
    else
        if self.cache_tips_list == nil then 
            self.cache_tips_list = {}
        end
        if type(data) == "table" then
            if data.bid == nil or type(data.bid) ~= "number" then return end
            if self.cache_tips_list[id] == nil then
                self.cache_tips_list[id] = {}
            end
            if data.bid ~= nil then
                self.cache_tips_list[id][data.bid] = data
            end
        else
            self.cache_tips_list[id] = data
        end
    end
    -- 检查红点状态
    self:checkMainSceneIconStatus()
end

--==============================--
--desc:初始化图标,找出是客户端创建并且达到等级的
--time:2017-09-21 05:00:03
--@return 
--==============================--
function MainuiController:checkFunctionByRoleLev(lev)
    if self.mainui == nil then return end -- 登录上线有升级的时候,这个时候会先于openui过来,所以没必要创建
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo == nil then return end
    lev = lev or role_vo.lev
	local add_list = {}
    for k,config in pairs(Config.FunctionData.data_info) do
        if self.function_list[config.id] == nil then
            if not MAKELIFEBETTER or (MAKELIFEBETTER == true and config.is_verifyios == TRUE) then
                if config.open_type == 1 and config.activate then
                    local activate = config.activate[1] -- 开启条件
                    if activate and activate[1] and activate[2] then
                        local activate_condition = activate[1]
                        local activate_value = activate[2]
                        if activate_condition == "lev" and lev >= activate_value then
                            local function_vo = self:createFunctionVo(config)
                            if function_vo ~= nil then
                                self.function_list[config.id] = function_vo
								table.insert(add_list, function_vo)
                                GlobalEvent:getInstance():Fire(MainuiEvent.UPDATE_FUNCTION_STATUS, config.id, true)
                            end
                        end
                    end
                end
            end
        end
    end
	if next(add_list) then
        if self.mainui then
            self.mainui:addIconList(add_list)
        end
    end
    -- 监测是否有带创建的图标
    self:checkCacheWaitFunction()
end

--代金券的创建图标
function MainuiController:checkFunctionByPerfer(status)
    if status and status == 1 then
        if self.function_list[MainuiConst.icon.perfer_icon] == nil then
            local config = Config.FunctionData.data_info[MainuiConst.icon.perfer_icon]
            local function_vo = self:createFunctionVo(config)
            self.function_list[MainuiConst.icon.perfer_icon] = function_vo
            if self.mainui then
                self.mainui:addIconList({function_vo})
            end
        end
    end
end
--==============================--
--desc:根据副本进度创建图标
--time:2018-07-22 02:04:31
--@max_dun_id:
--@return 
--==============================--
function MainuiController:checkFunctionByDrama(max_dun_id)
	local add_list = {}
	for k, config in pairs(Config.FunctionData.data_info) do
		if self.function_list[config.id] == nil then
			if not MAKELIFEBETTER or(MAKELIFEBETTER == true and config.is_verifyios == TRUE) then
				if config.open_type == 1 and config.activate then
					local activate = config.activate[1] -- 开启条件
					if activate and activate[1] and activate[2] then
						local activate_condition = activate[1]
						local activate_value = activate[2]
						if activate_condition == "dun" and max_dun_id >= activate_value then
							local function_vo = self:createFunctionVo(config)
                            if function_vo ~= nil then
								self.function_list[config.id] = function_vo
								table.insert(add_list, function_vo)
                                GlobalEvent:getInstance():Fire(MainuiEvent.UPDATE_FUNCTION_STATUS, config.id, true)
							end
						end
					end
				end
			end
		end
	end
	if next(add_list) then
		if self.mainui then
			self.mainui:addIconList(add_list)
		end
	end
    -- 监测是否有带创建的图标
    self:checkCacheWaitFunction()
end

--==============================--
--desc:监测是否有要求创建时候不满足情况的图标
--time:2018-07-22 02:31:40
--@return 
--==============================--
function MainuiController:checkCacheWaitFunction()
    if self.cache_wait_create_list == nil or tableLen(self.cache_wait_create_list) == 0 then return end
    local role_vo = RoleController:getInstance():getRoleVo()
    local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    for k,v in pairs(self.cache_wait_create_list) do
        local config = Config.FunctionData.data_info[k]
        if config == nil or config.activate == nil then
            self.cache_wait_create_list[k] = nil
        else
            local activate = config.activate[1]
            if activate[1] == nil or activate[2] == nil then
                self.cache_wait_create_list[k] = nil
            else
                local activate_condition = activate[1]
                local activate_value = activate[2]
                if (activate_condition == "lev" and role_vo and role_vo.lev >= activate_value ) or (activate_condition == "dun" and drama_data and drama_data.max_dun_id >= activate_value ) then
                    local function_vo = self:createFunctionVo(config)
                    if function_vo ~= nil then
                        local params = self.cache_wait_create_list[k]
                        function_vo:update(params)
                        self.function_list[k] = function_vo
                        if self.mainui then
                            self.mainui:addIcon(function_vo)
                        end
                        self.cache_wait_create_list[k] = nil

                        -- 缓存图标创建成功之后
                        GlobalEvent:getInstance():Fire(MainuiEvent.UPDATE_FUNCTION_STATUS, k, true)
                    end
                end
            end
        end
    end
end

function MainuiController:getFucntionIconVoById(id)
    if self.function_list and next(self.function_list or {}) ~= nil and self.function_list[id] then
        return self.function_list[id]
    end
end
--==============================--
--desc:创建一个图标数据
--time:2017-10-12 09:45:31
--@config:
--@params:
--@return 
--==============================--
function MainuiController:createFunctionVo(config)
    if config == nil then return end
    if config.id == MainuiConst.icon.oppo_gotocommunity then --oppo跳转社区的
        if not IS_OPPO_CHANNEL or BUILD_VERSION == 0 then    --oppo渠道的并且版号不为0的才添加图标
            return
        end
    end

    if config.id == MainuiConst.icon.scanning and (not canAddScannig()) then  -- 战盟扫一扫
        return
    end

    -- 这里根据icon判断是否可以创建
    if config.id == MainuiConst.icon.action or config.id == MainuiConst.icon.festival or config.id == MainuiConst.icon.combine then
        local can_add = ActionController:getInstance():checkCanAddWonderful(config.id)
        if can_add == false then return end
    end
    local function_vo = self.function_list[config.id]
    if function_vo == nil then
        function_vo = FunctionIconVo.New(config)
    end
    if self.cache_wait_create_list[config.id] ~= nil then
        function_vo:update(self.cache_wait_create_list[config.id])
        self.cache_wait_create_list[config.id] = nil
    end
    if self.cache_tips_list[config.id] ~= nil then
        function_vo:setTipsStatus(self.cache_tips_list[config.id])
        self.cache_tips_list[config.id] = nil
    end
    return function_vo
end

--==============================--
--desc:添加图标,
--time:2017-07-24 03:08:17
--@id:
--@args:如果非活动类的服务端的图标,即时开启的图标,至少包含状态:status,以及结束时间:end_time,活动类的图标,包含了活动id,状态status,以及扩展参数int_args
--@return 
--==============================---
function MainuiController:addFunctionIconById(id, ...)
    print("添加图标: ",id)
    if id == nil then return end
    if id == MainuiConst.icon.one_cent_gift and not IS_ONECENTGIFT then return end
    local params = {...}
    local function_vo = self.function_list[id]
    if function_vo then
        function_vo:update(params)
        return
    end
    local config = Config.FunctionData.data_info[id]
    if config == nil or config.activate == nil then return end
    if MAKELIFEBETTER == true and config.is_verifyios == FALSE then return end
    local activate = config.activate[1]
    if activate == nil or activate[1] == nil or activate[2] == nil then return end
    local activate_condition = activate[1]
    local activate_value = activate[2]
    local role_vo = RoleController:getInstance():getRoleVo()
    local drama_data = BattleDramaController:getInstance():getModel():getDramaData() 
    if (activate_condition == "lev" and role_vo and role_vo.lev >= activate_value ) or (activate_condition == "dun" and drama_data and drama_data.max_dun_id >= activate_value ) then
        function_vo = self:createFunctionVo(config)
        if function_vo ~= nil then
            function_vo:update(params)
            self.function_list[id] = function_vo
            if self.mainui then
                self.mainui:addIcon(function_vo)
            end
            GlobalEvent:getInstance():Fire(MainuiEvent.UPDATE_FUNCTION_STATUS, id, true)
        end
    else
        self.cache_wait_create_list[id] = params
    end
end

--==============================--
--desc:移除一个服务端图标
--time:2017-06-05 10:09:44
--@id:
--return 
--==============================--
function MainuiController:removeFunctionIconById(id)
    if id == nil then return end
    local function_vo = self.function_list[id]
    if function_vo == nil then return end
    if self.mainui then
        self.mainui:removeIcon(id)
    end
    self.function_list[id] = nil
    self.cache_wait_create_list[id] = nil
    GlobalEvent:getInstance():Fire(MainuiEvent.UPDATE_FUNCTION_STATUS, id, false)
end

--==============================--
--desc: 客户端物品获取提示
--time:2017-05-18 11:55:59
--@data:
--return 
--==============================--
function MainuiController:handle12742( data )
    if data == nil or next(data.asset_list) == nil then return end
    -- for i=1,10 do
    --     table.insert( data.asset_list, data.asset_list[1] )
    -- end
    self:openGetItemView(true, data.asset_list, data.source)
end

--==============================--
--desc:获得物品的通用接口
--time:2018-08-08 01:57:24
--@status:
--@list:
--@source:
--@extend:
--@return 
--==============================--
function MainuiController:openGetItemView(status, list, source, extend, open_type)
    if status == false then
        if self.exhibition_view then
            self.exhibition_view:close()
            self.exhibition_view = nil
        end
    else
        self.ref_class = ref_class or ItemExhibitionList

         --弹出面板播音效
        playOtherSound("c_get")
        if list == nil or next(list)  == nil then return end
        source = source or 0
        if self.exhibition_view == nil then
            self.exhibition_view = ItemExhibitionView.New(extend, open_type)
        end
        if self.exhibition_view:isOpen() == false then
            self.exhibition_view:open(list, source)
        end
    end
end

--==============================--
--desc:引导
--time:2018-01-24 05:01:02
--@return 
--==============================--
function MainuiController:getItemExhibtionRoot()
    if self.exhibition_view ~= nil then
        return self.exhibition_view.root_wnd
    elseif self.comp_view ~= nil then
        return self.comp_view.root_wnd
    end
end

--==============================--
--desc:打开or关闭边玩边下界面
--time:2017-08-09 03:04:02
--@status:
--@return 
--==============================--
function MainuiController:openDownloadView(status)
    if status == false then
        if self.download_view then
            self.download_view:close()
            self.download_view = nil
        end
    else
        if self.download_view == nil then
            self.download_view = DownloadPanel.New()
        end
        if self.download_view:isOpen() == false then
            self.download_view:open()
        end
    end
end

--==============================--
--desc:黑屏播放特效 播放一次消失
--time:2017-08-03 
--==============================--
function MainuiController:openPlayEffectView( status,effect_name,finish_call,isgore_playing, ignore_battle, delay_play,action_name )
   if status == false then
        if self.play_effect_view then
            self.play_effect_view:close()
            self.play_effect_view = nil
        end
    else
        if self.play_effect_view == nil then
            self.play_effect_view = PlayEffectView.New(self,effect_name, finish_call,isgore_playing, ignore_battle, delay_play,action_name )
        end
        if self.play_effect_view:isOpen() == false then
            self.play_effect_view:open()
        end
    end 
end


--==============================--
--desc:是否可以打开升级面板
--time:2017-07-26 06:33:34
--@return 
--==============================--
function MainuiController:itemExhibitionIsOpen()
    if self.exhibition_view ~= nil then
        return false
    end
    return true
end

--==============================--
--desc:点击不同的图标调用不同的面板
--time:2017-06-05 10:22:03
--@id:参照 MainuiController.icon
--return 
--==============================--
function MainuiController:iconClickHandle(id,item,action_id)
    print("iconClickHandle ",id,item,action_id)
    if id == nil then return end
    if id == MainuiConst.icon.friend then
        FriendController:getInstance():openFriendWindow(true)
    elseif id == MainuiConst.icon.mail then
        MailController:getInstance():openMailPanel(true)
    elseif id == MainuiConst.icon.daily then
        TaskController:getInstance():openTaskMainWindow(true)
    elseif id == MainuiConst.icon.welfare then
        WelfareController:getInstance():openMainWindow(true)
    elseif id == MainuiConst.icon.first_charge then
        ActionController:getInstance():openFirstChargeView(true)
    elseif id == MainuiConst.icon.first_charge_new or id == MainuiConst.icon.first_charge_new1 or id == MainuiConst.icon.first_charge_new2 or id == MainuiConst.icon.first_charge_new3 then
        NewFirstChargeController:getInstance():openNewFirstChargeView(true)
    elseif id == MainuiConst.icon.icon_charge1 then
        ActionController:getInstance():openFirstChargeView(true)
    elseif id == MainuiConst.icon.icon_charge2 then
        ActionController:getInstance():openFirstChargeView(true)
    elseif id == MainuiConst.icon.seven_login then
        ActionController:getInstance():openSevenLoginWin(true)
    elseif id == MainuiConst.icon.limit_recruit then
        RecruitHeroController:getInstance():openRecruitHeroWindow(true)
    elseif id == MainuiConst.icon.limit_gift_entry then
        ActionController:getInstance():openActionLimitGiftMainWindow(true)
    elseif id == MainuiConst.icon.seven_rank then
        ActionController:getInstance():sender22700(0)
    elseif id == MainuiConst.icon.crossserver_rank then
        ActionController:getInstance():sender22700(1)
    elseif id == MainuiConst.icon.festival or id == MainuiConst.icon.action then     -- 节日活动,竞猜活动
        ActionController:getInstance():openActionMainPanel(true, id)
    elseif id == MainuiConst.icon.combine then
        ActionController:getInstance():openActionMainPanel(true, id)
    elseif id == MainuiConst.icon.day_charge then
        ActionController:getInstance():openActionMainPanel(true, nil, 91005)
    elseif id == MainuiConst.icon.godpartner then
        ActionController:getInstance():openActionMainPanel(true, nil, 93006)
    elseif id == MainuiConst.icon.stronger then
        StrongerController:getInstance():openMainWin(true)
    elseif id == MainuiConst.icon.rank then
        RankController:getInstance():openMainView(true)
    elseif id == MainuiConst.icon.download then
        self:openDownloadView(true)
    elseif id == MainuiConst.icon.icon_firt1 then
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.VIP,5)
    elseif id == MainuiConst.icon.icon_firt2 then
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.VIP,8)
    elseif id == MainuiConst.icon.icon_firt3 then
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.VIP,12)
    elseif id == MainuiConst.icon.icon_firt4 then
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.VIP,13)
    elseif id == MainuiConst.icon.icon_firt5 then
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.VIP,14)
    elseif id == MainuiConst.icon.champion then
        MainSceneController:getInstance():openBuild(CenterSceneBuild.arena, ArenaConst.arena_type.rank)
    elseif id == MainuiConst.icon.escort then
        self:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Escort)
    elseif id == MainuiConst.icon.godbattle then
        GodbattleController:getInstance():requestEnterGodBattle()
    elseif id == MainuiConst.icon.dungeon_double_time then
        self:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildDun)
    elseif id == MainuiConst.icon.festval then
        -- ActionController:getInstance():openFestvalLoginWindow(true, ActionRankCommonType.common_day)
    elseif id == MainuiConst.icon.festval_spring then
        -- ActionController:getInstance():openFestvalLoginWindow(true, ActionRankCommonType.festval_day)
    elseif id == MainuiConst.icon.festval_lover then
        -- ActionController:getInstance():openFestvalLoginWindow(true, ActionRankCommonType.lover_day)
    elseif id == MainuiConst.icon.combine_login then
        -- ActionController:getInstance():openFestvalLoginWindow(true, 1011)
    elseif id == MainuiConst.icon.seven_goal or id == MainuiConst.icon.seven_goal1 or
            id == MainuiConst.icon.seven_goal2 or id == MainuiConst.icon.seven_goal3 or id == MainuiConst.icon.seven_goal4 then
        ActionController:getInstance():openSevenGoalView(true)
    elseif id == SevenGoalEntranceID.period_1 then
        SevenGoalController:getInstance():openSevenGoalAdventureView(true)
    elseif id == SevenGoalEntranceID.period_2 then
        SevenGoalController:getInstance():openSevenGoalSecretView(true)
    elseif id == MainuiConst.icon.guildwar then
        self:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildWar)
    elseif id == MainuiConst.icon.direct_gift then
        ActionController:getInstance():openDirectBuyGiftWin(true, 991016)
    elseif id == MainuiConst.icon.lucky_treasure then
        ActionController:getInstance():openLuckyTreasureWin(true)
    elseif id == MainuiConst.icon.preferential then
        -- ActionController:getInstance():openPreferentialWindow(true, 991014, id)
    elseif id == MainuiConst.icon.other_preferential then
        -- ActionController:getInstance():openPreferentialWindow(true, 91014, id)
    elseif id == MainuiConst.icon.ladder or id == MainuiConst.icon.ladder_2 then
        self:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.LadderWar)
    elseif id == MainuiConst.icon.certify then -- 实名认证
        RoleController:getInstance():openRoleAttestationWindow(true)
    elseif id == MainuiConst.icon.fund then -- 基金
        ActionController:getInstance():openActionFundWindow(true)
    elseif id == MainuiConst.icon.charge then -- 充值
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
        --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
    elseif id == MainuiConst.icon.day_first_charge then --每日首充
        DayChargeController:getInstance():openDayFirstChargeView(true)
    elseif id == MainuiConst.icon.vedio then --录像馆
        VedioController:getInstance():openVedioMainWindow(true)
    elseif id == MainuiConst.icon.open_server_recharge then --开服小额充值
        ActionController:getInstance():openActionOpenServerGiftWindow(true, ActionRankCommonType.open_server)
    elseif id == OrderActionEntranceID.entrance_id or id == OrderActionEntranceID.entrance_id1 or
            id == OrderActionEntranceID.entrance_id2 or id == OrderActionEntranceID.entrance_id3 or id == OrderActionEntranceID.entrance_id4 or
            id == OrderActionEntranceID.entrance_id5 or id == OrderActionEntranceID.entrance_id6 or id == OrderActionEntranceID.entrance_id7 or
            id == OrderActionEntranceID.entrance_id8 or id == OrderActionEntranceID.entrance_id9 then --战令活动
        OrderActionController:getInstance():openOrderActionMainView(true)
    elseif id == NewOrderActionEntranceID.entrance_id then
        NeworderactionController:getInstance():openOrderActionMainView(true)
    elseif id == MainuiConst.icon.return_action then
        ReturnActionController:getInstance():openReturnActionMainPanel(true)
    elseif id == MainuiConst.icon.oppo_gotocommunity then
        callFunc("gotoCommunity")
    elseif id == MainuiConst.icon.crosschampion then
        self:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossChampion)
    elseif id == MainuiConst.icon.personal_gift then --个人推送
        FestivalActionController:getInstance():openPersonalGiftView(true)
    elseif id == MainuiConst.icon.special_vip then
        ActionController:getInstance():openActionSpecialVIPWindow(true)
    elseif id == MainuiConst.icon.perfer_icon then
        ActionController:getInstance():openActionPerferPrizeWindow(true)
    elseif id == MainuiConst.icon.year_monster then
        ActionyearmonsterController:getInstance():sender28204()
        -- ActionyearmonsterController:getInstance():openActionyearmonsterMainWindow(true, setting)
    elseif id == MainuiConst.icon.monopoly then
        MonopolyController:getInstance():openHolynightMainWindow(true)
    elseif id == MainuiConst.icon.scanning then -- 战盟扫一扫
        local loginData = LoginController:getInstance():getModel():getLoginData()
        local output = string.format('{"ip":"%s", "port":"%s", "host":"%s", "rid":"%s", "srv_id":"%s", "usrName":"%s", "srv_name":"%s"}', loginData.ip, loginData.port, loginData.host, loginData.rid, loginData.srv_id, loginData.usrName, loginData.srv_name)
        callFunc("scanning", output)
    elseif id == MainuiConst.icon.limit_time_btn then -- 限时玩法
        local world_pos = item:convertToWorldSpace(cc.p(0.5, 0.5))
        local setting = {}
        setting.world_pos = world_pos
        self:openLimitTimePlayPanel(true, setting)
    elseif id == MainuiConst.icon.WeekAction then -- 周活动
        --ActionController:getInstance():openActionMainPanel(true, id)
        WeeklyActivitiesController:getInstance():openMainWindow(true)
    elseif id == MainuiConst.icon.peak_champion then --巅峰冠军赛
        ArenapeakchampionController:getInstance():openArenapeakchampionMainWindow(true)
    elseif id == MainuiConst.icon.limit_time_gift then --限时钜惠礼包
        print("----------------------在这打开的-------------------------->>",id)
        LimitTimeActionController:getInstance():openLimitTimeGiftWindow(true)
    elseif id == MainuiConst.icon.skin_direct_purchase then --皮肤直购
        ActionController:getInstance():openActionSkinDirectPurchasePanel(true)
    elseif id == MainuiConst.icon.eight_login then
        ActionController:getInstance():openEightLoginWin(true)
    elseif id == MainuiConst.icon.one_cent_gift or id == MainuiConst.icon.one_yuan_gift then
        OnecentgiftController:getInstance():openOnecentiftView(true)
    elseif id == MainuiConst.icon.rfm_personnal_gift then
        RfmPersonnalGiftController:getInstance():openRfmPersonalGiftView(true)
    elseif id == MainuiConst.icon.arena_many_people then --多人竞技场
        self:requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.AreanManyPeople)
    elseif id == MainuiConst.icon.free_capture then --免费捕捉
        FreeCaptureController:getInstance():openFreeCaptureWindow(true)
    end
end

---------------------------------------边玩边下
-- 当前边玩边下状态
function MainuiController:getDownLoadStatus()
    return self.down_load_status
end

-- 边玩边下的奖励物品列表
function MainuiController:getDownLoadItems()
    return self.down_load_items
end
function MainuiController:requestDownLoadStatus()
    self:SendProtocal(16630,{})
end

function MainuiController:handle16630(data)
    self.down_load_status = data.code       -- 是否领取了奖励
    self.down_load_items = data.items
    if self:checkDownLoadStatus() == true then
        self:removeFunctionIconById(MainuiConst.icon.download)
    else
        self:addFunctionIconById(MainuiConst.icon.download)
    end
end

--==============================--
--desc:检测边玩边下已经边玩边下领取状态
--time:2017-08-09 09:18:59
--@return:true表示已经下载完了,并且领过奖励
--==============================--
function MainuiController:checkDownLoadStatus()
    if IS_REQUIRE_RES_GY == false then return true end

    local percent_num = ResourcesLoadMgr:getInstance():getPercentage() or 0
    if self.down_load_status == TRUE and percent_num >= 100 then
        return true
    else
        return false
    end
    return true
end

function MainuiController:requestGetDownLoadAwards()
    self:SendProtocal(16631,{})
end

function MainuiController:handle16631(data)
    message(data.msg)
    if data.code == TRUE then
        self.down_load_status = TRUE
        if self:checkDownLoadStatus() == true then
            self:openDownloadView(false)
            self:removeFunctionIconById(MainuiConst.icon.download)
        else
            self:addFunctionIconById(MainuiConst.icon.download)
        end
    end
end

--==============================--
--desc:通用玩法规则面板
--time:2017-09-14 05:54:30
--@status:
--@config:
--@return 
--==============================--
function MainuiController:openCommonExplainView(status, config,title_str,summon)
    if status == false then
        if self.common_explain ~= nil then
            self.common_explain:close()
            self.common_explain = nil
        end
    else
        if config == nil or next(config) == nil then return end
        if self.common_explain == nil then
            self.common_explain = CommonExplainWindow.New(MainuiController:getInstance(),title_str,summon)
        end
        if self.common_explain and self.common_explain:isOpen() == false then
            self.common_explain:open(config)
        end
    end
end

--==============================--
--desc:主ui当前选中的下标
--time:2018-10-08 04:57:48
--@return 
--==============================--
function MainuiController:getMainUIIndex()
    if self.mainui then
        return self.mainui:getMainUiIndex()
    end
end

--==============================--
--desc:ui的战斗类型
--time:2018-10-08 05:03:10
--@index:
--@return 
--==============================--
function MainuiController:setUIFightType(index)
    self.ui_fight_type = index
end
function MainuiController:getUIFightType()
	return self.ui_fight_type
end 

--==============================--
--desc:是否处于剧情战斗的ui战斗下
--time:2018-10-08 05:14:08
--@return 
--==============================--
function MainuiController:checkIsInDramaUIFight()
    return  self.ui_fight_type == MainuiConst.ui_fight_type.drama_scene 
end

--==============================--
--desc:是否处于神界冒险战斗的ui战斗下
--time:2018-10-08 05:14:08
--@return 
--==============================--
function MainuiController:checkIsInSkySceneUIFight()
    return self.ui_fight_type == MainuiConst.ui_fight_type.sky_scene
end

--==============================--
--desc:是否处于无尽试炼战斗的ui战斗下
--time:2018-10-08 05:14:08
--@return 
--==============================--
function MainuiController:checkIsInEndlessUIFight()
    return self.ui_fight_type == MainuiConst.ui_fight_type.endless
end

function MainuiController:isInSkySceneOrDramaScene()
    return self:checkIsInDramaUIFight() or self:checkIsInSkySceneUIFight()
end

--==============================--
--desc:改表主城按钮状态,并且切换到具体的面板标签
--time:2018-07-20 10:09:25
--@index:
--@sub_type:
--@force:在观战或者查看战斗中,是否强制退出
--@return 
--==============================--
function MainuiController:changeMainUIStatus(index, sub_type, data, force)
    if self.mainui then
        -- 这里需要判断某一些是否开启了
        if sub_type == MainuiConst.sub_type.adventure then
            local config = Config.CityData.data_base[CenterSceneBuild.adventure]
            if config then
                if self:checkIsOpenByActivate(config.activate) == false then
                    message(config.desc)
                    return
                end
            end
        end
        self.mainui:changeMainUiStatus(index, sub_type, data, force)
    end
end

function MainuiController:getBottomHeight()
    if self.mainui then
        return self.mainui:getBottomHeight()
    end    
end

-- 处理主界面下面的5个红点, 如果data是nil则表示清空红点数据
function MainuiController:setBtnRedPoint(id,data)
    if type(id) ~= "number" then return end
    if self.mainui then
        self.mainui:updateBtnTipsPoint(id,data)
        
        -- 设置背包是否已满
        if id == MainuiConst.btn_index.backpack then
            BackpackController:getInstance():setEquipBackPackStatus(data)
        end
    end
end

function MainuiController:setBackPackBtnPos(pos)
    self.backpack_pos = pos
end

function MainuiController:getBackPackBtnPos()
    if self.backpack_pos then
        return self.backpack_pos
    end
end

--==============================--
--desc:请求打开战斗关联窗体的统一入口，因为一些窗体可能存在真实战斗
--time:2018-06-12 11:15:39
--@battle_type: 查看 BattleConst.Fight_Type 
--@btn_status: 查看 MainuiConst.ui_fight_type 
--@params: 自己额外附带参数
--@return 
--==============================--
function MainuiController:requestOpenBattleRelevanceWindow(battle_type, params)
    self.relevance_ui_last_type = self.ui_fight_type    -- 先把当前的战斗缓存起来
    self.relevance_battle_type = battle_type
    self.relevance_ui_fight_type = BattleConst.getUIFightByFightType(battle_type) 
    self.relevance_params = params
    self:setUIFightType(self.relevance_ui_fight_type)     -- 储存状态
    BattleController:getInstance():send20060(battle_type)
end 

--- 还原之前的ui战斗类型,因为可能几个带战斗类型的面板互相调用
function MainuiController:resetUIFightType()
    if self.relevance_ui_last_type then
        self.ui_fight_type = self.relevance_ui_last_type
        self.relevance_ui_last_type = MainuiConst.ui_fight_type.normal
    end
end

--==============================--
--desc:打开关联窗体,这里针对世界boss又需要重新判断调整
--time:2018-06-12 11:29:21
--@combat_type:当前战斗类型
--@return 
--==============================--
function MainuiController:openRelevanceWindowAtOnce(combat_type)
    if combat_type == BattleConst.Fight_Type.WorldBoss or combat_type == BattleConst.Fight_Type.SingleBoss then
        if self.relevance_battle_type ~= BattleConst.Fight_Type.WorldBoss and self.relevance_battle_type ~= BattleConst.Fight_Type.SingleBoss then return end
    else
        if self.relevance_battle_type ~= combat_type then return end
    end
    if self.relevance_ui_fight_type ~= self.ui_fight_type then return end
    if combat_type == BattleConst.Fight_Type.GuildDun then
        GuildbossController:getInstance():openMainWindow(true) 
    elseif combat_type == BattleConst.Fight_Type.Arena then
        ArenaController:getInstance():openArenaLoopMathWindow(true,self.relevance_params)
    elseif combat_type == BattleConst.Fight_Type.StarTower then 
        StartowerController:getInstance():openMainView(true)
    elseif combat_type == BattleConst.Fight_Type.Endless then
        Endless_trailController:getInstance():openEndlessMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.Escort then
		EscortController:getInstance():openEscortMainWindow(true, self.relevance_params)
    elseif combat_type == BattleConst.Fight_Type.Adventrue then --冒险
        AdventureController:getInstance():openAdventureMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.AdventrueMine then -- 秘矿冒险(取消了矿战)
        AdventureController:getInstance():openAdventureMainWindow(true)
        -- AdventureController:getInstance():openAdventureMineWindow(true, self.relevance_params)
    elseif combat_type == BattleConst.Fight_Type.DungeonStone then
        Stone_dungeonController:getInstance():openStoneDungeonView(true)
    elseif combat_type == BattleConst.Fight_Type.Godbattle then
        GodbattleController:getInstance():openGodBattleMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.GuildWar then
        GuildwarController:getInstance():openMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.PrimusWar then --荣耀神殿
        PrimusController:getInstance():openPrimusMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.LadderWar then
        LadderController:getInstance():openMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.ExpeditFight then
        --HeroExpeditController:getInstance():openHeroExpeditView(true)
        PlanesController:getInstance():openPlanesMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.YuanZhenFight then
        AnimateActionController:getInstance():openAnimateYuanzhenCollectWindow(true)
    elseif combat_type == BattleConst.Fight_Type.EliteMatchWar then --精英赛
        ElitematchController:getInstance():openElitematchMatchingWindow(true, self.relevance_params)
    elseif combat_type == BattleConst.Fight_Type.ElementWar then -- 元素圣殿
        ElementController:getInstance():openElementMainWindow(true, self.relevance_params)
    elseif combat_type == BattleConst.Fight_Type.HeavenWar then -- 天界副本
        HeavenController:getInstance():openHeavenMainWindow(true, self.relevance_params,HeavenConst.Tab_Index.Dungeon,nil,true)
    elseif combat_type == BattleConst.Fight_Type.SandybeachBossFight then -- 沙滩保卫战 沙滩争夺战
        ActionController:getInstance():openSandybeachBossFightMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.CrossArenaWar then -- 跨服竞技场
        CrossarenaController:getInstance():openCrossarenaMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.LimitExercise then -- 试炼之境
        LimitExerciseController:getInstance():openLimitExerciseChangeView(true)
    elseif combat_type == BattleConst.Fight_Type.CrossChampion then -- 跨服冠军赛
        CrosschampionController:getInstance():openCrosschampionMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.TermBegins or 
           combat_type == BattleConst.Fight_Type.TermBeginsBoss then -- 开学季战斗类型
        ActiontermbeginsController:getInstance():openActiontermbeginsMainWindow(true, self.relevance_params)
    elseif combat_type == BattleConst.Fight_Type.GuildSecretArea then -- 公会秘境
        GuildsecretareaController:getInstance():openGuildsecretareaMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.Arean_Team then -- 组队竞技场
        ArenateamController:getInstance():openArenateamMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.MonopolyWar_1 or 
        combat_type == BattleConst.Fight_Type.MonopolyWar_2 or 
        combat_type == BattleConst.Fight_Type.MonopolyWar_3 or 
        combat_type == BattleConst.Fight_Type.MonopolyWar_4 then -- 大富翁
        MonopolyController:getInstance():openMonopolyMianScene(true, self.relevance_params)
    elseif combat_type == BattleConst.Fight_Type.MonopolyBoss then -- 大富翁boss
        MonopolyController:getInstance():openHolynightBossWindow(true, self.relevance_params)
    elseif combat_type == BattleConst.Fight_Type.Training_Camp then -- 新手训练营
        TrainingcampController:getInstance():openTrainingcampWindow(true)
    elseif combat_type == BattleConst.Fight_Type.Arenapeakchampion then --巅峰冠军赛
        ArenapeakchampionController:getInstance():openArenapeakchampionGuessingWindow(true)
    elseif combat_type == BattleConst.Fight_Type.PlanesWar then -- 位面
        -- PlanesController:getInstance():openPlanesMapWindow(true, self.relevance_params)
        PlanesafkController:getInstance():openPlanesafkMainWindow(true, self.relevance_params)
    elseif combat_type == BattleConst.Fight_Type.YearMonsterWar then -- 年兽活动
        ActionyearmonsterController:getInstance():openActionyearmonsterMainWindow(true, self.relevance_params)
    elseif combat_type == BattleConst.Fight_Type.AreanManyPeople then -- 多人竞技场
        ArenaManyPeopleController:getInstance():openArenaManyPeopleMainWindow(true)
    elseif combat_type == BattleConst.Fight_Type.PractiseTower then -- 新人练武场
        PractisetowerController:getInstance():openMainView(true)
    end
    self.relevance_battle_type = nil
    self.relevance_ui_fight_type = nil 
    self.relevance_params = nil  
end

--==============================--
--desc:监测主UI的功能图标开启情况
--time:2018-07-22 10:27:57
--@id:
--@type:是主界面下面的6个+充值,还是其他比如排行榜之类的
--@return 
--==============================--
function MainuiController:checkMainFunctionOpenStatus(id, type, un_show_desc)
    type = type or MainuiConst.function_type.main
    id = id or 0
    local config = nil
    if type == MainuiConst.function_type.main then
        config = Config.FunctionData.data_base[id]
    else
        config = Config.FunctionData.data_info[id]
    end

    local str = ""
    local is_open = false
    if config == nil or config.activate == nil then
        str = TI18N("配置数据异常")
        is_open = false
    else
        str = config.desc
        is_open = self:checkIsOpenByActivate(config.activate)
    end

    if not un_show_desc and is_open == false then
        message(str)
    end
    return is_open
end

--==============================--
--desc:判断一个功能是否开启了,可能是等级,也可能是副本id
--time:2018-07-19 09:35:54
--@activate:必须包含2个值,类型和数值
--@return 
--==============================--
function MainuiController:checkIsOpenByActivate(activate)
    local role_vo = RoleController:getInstance():getRoleVo()
    local drama_data = BattleDramaController:getInstance():getModel():getDramaData()

    if activate == nil or type(activate) ~= "table" or next(activate) == nil then return false end
    if role_vo == nil or drama_data == nil or drama_data.max_dun_id == nil then return false end

    for i,v in ipairs(activate) do
        local condition_type = v[1]
        local condition_value = v[2] or 0
        local max_value = 0
        local lock_tips = ""
        if condition_type == "lev" then
            max_value = role_vo.lev
            lock_tips = string.format(TI18N("角色等级达到%s级解锁"), condition_value)
        elseif condition_type == "open_day" then
            max_value = role_vo.open_day
            lock_tips = string.format(TI18N("开服%s天解锁"), condition_value)
        elseif condition_type == "dun" then
            max_value = drama_data.max_dun_id
        elseif condition_type == "vip_lev" then
            max_value = role_vo.vip_lev
            lock_tips = string.format(TI18N("VIP等级达到%s级解锁"), condition_value)
        elseif condition_type == "world_lev" then
            max_value = RoleController:getInstance():getModel():getWorldLev()
            lock_tips = string.format(TI18N("世界等级达到%s级解锁"), condition_value)
        elseif condition_type == "charge_num" then -- 充值金额
            max_value = role_vo.vip_exp*0.1
        end
        if condition_value > max_value then
            return false, lock_tips
        end
    end
    return true
end

--==============================--
--desc:判断主城图标的红点状态,需要检查主城建筑以及功能红点
--time:2018-07-19 09:35:54
--@return 
--==============================--
function MainuiController:checkMainSceneIconStatus()
    -- 首先判断图标红点吧
    local main_scene_btn_status = false
    for k,v in pairs(self.function_list) do
        if v:getTipsStatus() == true then
            main_scene_btn_status = true
            break
        end
    end
    -- 如果有红点的话,直接跳过了
    if main_scene_btn_status == true then
        if self.main_scene_btn_status == false then
            self.main_scene_btn_status = true
            self:setBtnRedPoint(MainuiConst.btn_index.main_scene, self.main_scene_btn_status)
        end
        return
    end

    local build_list = MainSceneController:getInstance():getBuildVoList()
    if build_list then
        for k,v in pairs(build_list) do
            if v:getTipsStatus() == true then
                main_scene_btn_status = true
                break
            end
        end
    end
    if main_scene_btn_status ~= self.main_scene_btn_status then
        self.main_scene_btn_status = main_scene_btn_status
        self:setBtnRedPoint(MainuiConst.btn_index.main_scene, self.main_scene_btn_status)
    end
end

--设置时间
function MainuiController:setFuncionIconTime(id, time)
    local vo = self:getFunctionIconById(id)
    if vo then
        vo:changeTime(time)
    end
end

-- 获取主界面聊天框输入组件
function MainuiController:getMainChatInput(  )
    if self.mainui and self.mainui.chat_ui then
        return self.mainui.chat_ui.chat_input
    end
end

-- 打开主界面聊天的私聊界面
function MainuiController:openMianChatChannel( channel, data )
    if channel == ChatConst.Channel.Friend then
        local chatModel = ChatController:getInstance():getModel()
        if data then
            chatModel:addContactList(data.srv_id,data.rid)
            chatModel:writeContactList()
        else
            local vo = FriendController:getInstance():getModel():getArray():Get(0)
            if vo then
                chatModel:addContactList(vo.srv_id,vo.rid)
                chatModel:writeContactList()
            end
        end
        if data then
            self.mainui.chat_ui:openChannel(channel, data.srv_id, data.rid)
        else
            self.mainui.chat_ui:openChannel(channel)
        end
    else
        self.mainui.chat_ui:openChannel(channel)
    end
end

-- @人
function MainuiController:mainChatAtPeople( name, srv_id )
    local chatInput = self:getMainChatInput()
    if chatInput then
        chatInput:setInputText("@".. name .." ", srv_id)
    end
end

-- 设置当前主界面聊天框所在的界面类型
function MainuiController:setMainChatBoxCurViewType( viewType )
    self.cur_view_type = viewType
    if self.mainui and self.mainui.chat_ui then
        self.mainui.chat_ui:changeChatUIHeight(true)
    end
end

function MainuiController:getMainChatBoxCurViewType(  )
    return self.cur_view_type or ChatConst.ViewType.Normal
end

--- 打开限时活动的tips
function MainuiController:openLimitActionTips(status)
    if not status then
        if self.limit_action_window then
            self.limit_action_window:close()
            self.limit_action_window = nil
        end
    else
        if self.limit_action_window == nil then
            self.limit_action_window = LimitActionWindowTips.New()
        end
        self.limit_action_window:open()
    end
end
--- 打开限时玩法的列表面板
function MainuiController:openLimitTimePlayPanel(status, setting)

    if not status then
        if self.limit_time_play_panel then
            self.limit_time_play_panel:close()
            self.limit_time_play_panel = nil
        end
    else
        if self.limit_time_play_panel == nil then
            self.limit_time_play_panel = LimitTimePlayPanel.New()
        end
        self.limit_time_play_panel:open(setting)
    end
end

-- 主界面系统提示跳转
function MainuiController:onClickPromptTipsItem( data )
    if data.type == PromptTypeConst.Private_chat then --私聊
        local temp_data = {}
        for k,v in pairs(data.list[1].data.arg_uint32) do
            if v.key == 1 then
                temp_data.rid = v.value
            end
        end

        for k,v in pairs(data.list[1].data.arg_str) do
            if v.key == 1 then
                temp_data.srv_id = v.value
            end
        end
        if next(temp_data) ~= nil then
            ChatController:getInstance():openChatPanel(ChatConst.Channel.Friend,"friend",temp_data)
        end
    elseif data.type == PromptTypeConst.World_boss then --世界boss
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.world_boss)
    elseif data.type == PromptTypeConst.At_notice then
        ChatController:getInstance():openChatPanel()
    elseif data.type == PromptTypeConst.Endless_trail then  -- 无尽试炼
        Endless_trailController:getInstance():openEndlessBuffView(true)
        return
    elseif data.type == PromptTypeConst.Escort then
        EscortController:getInstance():openEscortMyInfoWindow(true) 
    elseif data.type == PromptTypeConst.GuileMuster then
        GuildbossController:getInstance():openMainWindow(true)
    elseif data.type == PromptTypeConst.Challenge then
        BattleController:getInstance():confirmBattlePk(data)
    elseif data.type == PromptTypeConst.Guild then --公会
        GuildController:getInstance():checkOpenGuildWindow()
    elseif data.type == PromptTypeConst.Guild_war then --公会战
        local is_open = GuildwarController:getInstance():checkIsCanOpenGuildWarWindow()
        if is_open == true then
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildWar)
        end
    elseif data.type == PromptTypeConst.Guild_voyage then --公会副本
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildDun)
    elseif data.type == PromptTypeConst.BBS_message or --自己留言板消息提醒
            data.type == PromptTypeConst.BBS_message_reply_self then  --自己留言板有新回复
        RoleController:getInstance():openRolePersonalSpacePanel(true, {index = RoleConst.Tab_type.eMessageBoard})
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo then
            RoleController:getInstance():send25840(role_vo.rid, role_vo.srv_id, 0)
        end
    elseif data.type == PromptTypeConst.BBS_message_reply then --他人留言板回复提醒
        local list = data.list
        if #list > 0 then
            local message_data = list[1].data
            local setting = {}
            setting.form_type = RoleConst.Other_Form_Type.eMessageBoardInfo
            local rid, srv_id, role_name,_,bbs_id = data:getSridByData(message_data)

            setting.bbs_id = bbs_id
            if rid and srv_id then
                RoleController:getInstance():requestRoleInfo(rid, srv_id, setting)
                RoleController:getInstance():send25840(rid, srv_id, bbs_id)
            end
        end
    elseif data.type == PromptTypeConst.Mine_defeat then --矿战被掠夺
        AdventureController:getInstance():openAdventureMineFightRecordPanel(true)
    elseif data.type == PromptTypeConst.Peak_champion_arena_tips then --巅峰冠军赛
        ArenapeakchampionController:getInstance():openArenapeakchampionMainWindow(true)
    elseif data.type == PromptTypeConst.Corss_arena_tips then --跨服竞技场
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossArenaWar)
        
    elseif data.type == PromptTypeConst.Artifact_Count_tips then --符文数量提示
        ForgeHouseController:getInstance():openForgeHouseView(true, ForgeHouseConst.Tab_Index.Artifact)
    elseif data.type == PromptTypeConst.Year_Monster_tips then --年兽挑战
        self.is_click_yearmoster = true
        JumpController:getInstance():jumpViewByEvtData({70})
    end

    if data.type == PromptTypeConst.BBS_message_reply then
        PromptController:getInstance():getModel():removePromptData(data.type, data.id)
    elseif data.type == PromptTypeConst.BBS_message or --自己留言板消息提醒
            data.type == PromptTypeConst.BBS_message_reply_self then  --自己留言板有新回复
        PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.BBS_message)
        PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.BBS_message_reply_self)
    elseif data.type == PromptTypeConst.AMP_tips then --多人竞技场可挑战提示
        JumpController:getInstance():jumpViewByEvtData({76})
    else
        PromptController:getInstance():getModel():removePromptDataByTpye(data.type)
    end
    --[[if self.mainui then
        self.mainui:showPromptTips(false)
    end--]]
end

--- 更新带上传的头像
function MainuiController:updateCustomHeadImg(path)
    if self.head_img_win then
        self.head_img_win:updateSelectHeadImg(path)
    end
end

--- 打关闭自定义头像
function MainuiController:openCustomHeadImgWin(status)
    if isQingmingShield and isQingmingShield() then
        return
    end
    if not CAN_USE_CAMERA then
        if IS_IOS_PLATFORM == true then
            message(TI18N("该功能需最新版本安装包才可使用，请耐心等待。"))
        else
            get_apk_url(function(data)
                if data and data.success == true and data.message then
                    if data.message.url and data.message.url ~= "" and PLATFORM_NAME == "symlf" then   -- 暂时只处理买量
                        CommonAlert.show(TI18N("是否前往下载最新版本，解锁自定义头像功能？"), TI18N("确定"), function()
                            sdkCallFunc("openUrl", data.message.url)
                        end, TI18N("取消"))
                    else
                        message(TI18N("请下载最新的安装包进行游戏体验，非常抱歉给你带来不好的游戏体验。"))
                    end
                else
                    message(TI18N("请下载最新的安装包进行游戏体验，非常抱歉给你带来不好的游戏体验。"))
                end
            end)
        end
        return
    end
    if status == true then
        if self.head_img_win == nil then
            self.head_img_win = CustomHeadImgWindow.New()
        end
        self.head_img_win:open()
    else
        if self.head_img_win then
            self.head_img_win:close()
            self.head_img_win = nil
        end
    end
end

-- 是否显示二维码扫一扫
function MainuiController:handle10931(data)
    if data.code == 0 then
        self:removeFunctionIconById(MainuiConst.icon.scanning)
    else
        self:addFunctionIconById(MainuiConst.icon.scanning)
    end
end
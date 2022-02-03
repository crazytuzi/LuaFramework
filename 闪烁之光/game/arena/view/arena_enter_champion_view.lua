-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      竞技场冠军赛入口
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaEnterChampionView = class("ArenaEnterChampionView", function()
	return ccui.Layout:create()
end)

local controller = ArenaController:getInstance()
local model = ArenaController:getInstance():getChampionModel()
local string_format = string.format

function ArenaEnterChampionView:ctor()
	self.statue_list = {}
	
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_enter_champion_view"))
	self.size = self.root_wnd:getContentSize()
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)
	
	local btn_container = self.root_wnd:getChildByName("btn_container")
	self.close_btn = btn_container:getChildByName("close_btn")
	
	local Panel_9 = self.root_wnd:getChildByName("Panel_9")
	self.rank_btn = Panel_9:getChildByName("rank_btn")
	
	self.guess_btn = btn_container:getChildByName("guess_btn")
	self.guess_btn:getChildByName("label"):setString(TI18N("我的布阵"))
	
	self.enter_btn = btn_container:getChildByName("enter_btn")
	local enter_btn_label = self.enter_btn:getChildByName("label")
	enter_btn_label:setString("进入挑战")
	
	local dec_container = self.root_wnd:getChildByName("dec_container")
	self.tips_btn = dec_container:getChildByName("tips_btn")            -- 规则说明
	
	local worship_title = self.root_wnd:getChildByName("worship")              -- 被膜拜次数
	worship_title:setString(TI18N("被膜拜次数："))
	self.worship = self.root_wnd:getChildByName("worship_num")
	self.worship:setString(1000)
	
	local label = nil
	for i = 1, 5 do
		local label = dec_container:getChildByName("label_" .. i)               -- 文字描述
		if label then
			label:setString(self:getTitleLabel(i))
        end
	end
    -- 当前赛程情况
    self.match_step = createRichLabel(24, 1, cc.p(0, 0.5), cc.p(163, 175), nil, nil, 560) 
	dec_container:addChild(self.match_step)

    self.my_rank_lable = dec_container:getChildByName("my_rank_lable")
    self.my_total_rank = dec_container:getChildByName("my_total_rank")

	self.match_desc = createRichLabel(24, 1, cc.p(0, 0.5), cc.p(163, 66), nil, nil, 560)
	dec_container:addChild(self.match_desc)

    self.notice_label = dec_container:getChildByName("notice_label")
    self.notice_label:setString(TI18N("赛季结束时将通过邮件发放排名奖励"))
    
	self.dec_container = dec_container
	self.btn_container = btn_container
	
	local statue = nil
	for i = 1, 3 do
		statue = self.root_wnd:getChildByName("statue_" .. i)
		statue.role_name = statue:getChildByName("role_name")                   -- 角色名字
		statue.desc = statue:getChildByName("desc")                             -- 虚位以待
		statue.desc:setString(TI18N("虚位以待"))
		statue.btn = statue:getChildByName("worship_btn")                       -- 点赞按钮
		statue.worship_label = statue.btn:getChildByName("label")               -- 点赞数量
		statue.worship_label:setString("")
		statue.model = statue:getChildByName("model")                           -- 存放模型的容器
		statue.model = statue:getChildByName("model")                           -- 存放模型的容器
		statue.size = statue.model:getContentSize()
		statue.honor = statue:getChildByName("honor")  
		statue.index = i
		statue.btn.index = i
		self.statue_list[i] = statue
	end
	self:registerEvent()
end

function ArenaEnterChampionView:registerEvent()
	self.close_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openArenaEnterWindow(false)
		end
	end)

	self.rank_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			controller:openArenaChampionRankWindow(true)
		end
	end)

	self.guess_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			HeroController:getInstance():openFormMainWindow(true, PartnerConst.Fun_Form.ArenaChampion)
		end
	end)

	self.enter_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			controller:openArenaChampionMatchWindow(true)
		end
	end)

	self.tips_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			MainuiController:getInstance():openCommonExplainView(true, Config.ArenaChampionData.data_explain)
		end
	end)

	for k, statue in pairs(self.statue_list) do
		statue.btn:addTouchEventListener(function(sender, event_type)
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if sender.data ~= nil then
					RoleController:getInstance():requestWorshipRole(sender.data.rid, sender.data.srv_id, sender.index)
				end
			end
		end)
	end
end

function ArenaEnterChampionView:getTitleLabel(i)
	if i == 1 then
		return TI18N("当前赛程:")
	elseif i == 2 then
		return TI18N("当前排名:")
	elseif i == 3 then
		return TI18N("历史最高排名:")
	elseif i == 4 then
		return TI18N("赛季时间:")
	else
		return TI18N("系统提示:")
	end
end

function ArenaEnterChampionView:addToParent(status)
	self:setVisible(status)
	self:handleEvent(status)

	-- 被膜拜的次数
	local role_vo = RoleController:getInstance():getRoleVo()
	if role_vo ~= nil then
		self.worship:setString(role_vo.worship)
	end

	if status == true then
		controller:requestSelfResultInfo()
		controller:requestRoleInfo()
		controller:requestChampionTop3()
		self:setBaseInfo()
	end
end

--==============================--
--desc:设置基础信息
--time:2018-08-03 06:27:12
--@return 
--==============================--
function ArenaEnterChampionView:setBaseInfo()
	local base_info = model:getBaseInfo()
	if base_info == nil then return end

	if base_info.step == ArenaConst.champion_step.unopened then
		self.match_step:setString(string_format("<div outline=1,#000000>%s</div>", TI18N("暂未开启"))) 
	elseif base_info.step == ArenaConst.champion_step.score then
		if base_info.step_status == ArenaConst.champion_step_status.unopened then
			self.match_step:setString(string_format("<div outline=1,#000000>%s-</div><div fontcolor=#4af915 outline=1,#000000>%s</div>", TI18N("选拔赛"), TI18N("暂未开启")))
		else
			self.match_step:setString(string_format("<div outline=1,#000000>%s-</div><div fontcolor=#4af915 outline=1,#000000>%s</div>", TI18N("选拔赛"), TI18N("正式进行")))
		end
	elseif base_info.step == ArenaConst.champion_step.match_32 then
		if base_info.step_status == ArenaConst.champion_step_status.unopened then
			self.match_step:setString(string_format("<div outline=1,#000000>%s-</div><div fontcolor=#4af915 outline=1,#000000>%s</div>", TI18N("32强赛"), TI18N("暂未开启")))
		else
			self.match_step:setString(string_format("<div outline=1,#000000>%s-</div><div fontcolor=#4af915 outline=1,#000000>%s</div>", TI18N("32强赛"), TI18N("正在进行")))
		end
	elseif base_info.step == ArenaConst.champion_step.match_4 then
		if base_info.step_status == ArenaConst.champion_step_status.over then
			self.match_step:setString(string_format("<div outline=1,#000000>%s</div>", TI18N("冠军赛已结束"))) 
		else
			self.match_step:setString(string_format("<div outline=1,#000000>%s-</div><div fontcolor=#4af915 outline=1,#000000>%s</div>", TI18N("4强赛"), TI18N("正在进行")))
		end
	end

	local less_time = base_info.step_status_time - GameNet:getInstance():getTime()
	if less_time < 0 then
		less_time = 0
	end 
	self.match_desc:setString(string_format("<div outline=1,#000000>%s-%s</div><div fontcolor=#4af915 outline=1,#000000>（剩余时间:%s）</div>",TimeTool.getMD(base_info.start_time),TimeTool.getMD(base_info.end_time),TimeTool.GetTimeFormatTwo(less_time))) 
end

--==============================--
--desc:设置个人信息
--time:2018-08-03 06:27:32
--@data:
--@return 
--==============================--
function ArenaEnterChampionView:setRoleInfo()
	local data = model:getRoleInfo()
	if data == nil then return end
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

function ArenaEnterChampionView:updateStatueInfo(list)
	list = list or {}
	local data = nil
	local role_vo = RoleController:getInstance():getRoleVo()
	local _honor_list = {"battle_champion", "battle_secondplace", "battle_thirdplace"}
	local _const_config = Config.ArenaChampionData.data_const
	for i, statue in ipairs(self.statue_list) do
		data = list[statue.index]
		if data == nil then
			statue.role_name:setVisible(false)
			statue.desc:setVisible(true)
			statue.btn:setVisible(false)
			statue.honor:setVisible(false)
		else
			statue.role_name:setVisible(true)
			statue.desc:setVisible(false)
			statue.btn:setVisible(true)
			statue.role_name:setString(data.name)
			statue.worship_label:setString(data.worship)
			statue.worship_num = data.worship               -- 缓存一下当前被赞的数量，这样用于点赞成功之后的数量更改
			local config = _const_config[_honor_list[i]]
			if config then
				local honor_config = Config.HonorData.data_title[config.val]
				if honor_config then
					local res_id = PathTool.getTargetRes("honor", string_format("txt_cn_honor_%s", honor_config.res_id), false, false)
					loadSpriteTexture(statue.honor,res_id,LOADTEXT_TYPE)
					statue.honor:setVisible(true)
				end
			end
			
			if data.worship_status == TRUE or role_vo:isSameRole(data.srv_id, data.rid) then
				statue.btn:setTouchEnabled(false)
				setChildUnEnabled(true, statue.btn, Config.ColorData.data_color4[1])
				statue.worship_label:enableOutline(Config.ColorData.data_color4[2], 2)
			else
				statue.btn:setTouchEnabled(true)
				setChildUnEnabled(false, statue.btn, Config.ColorData.data_color4[175])
				statue.worship_label:enableOutline(Config.ColorData.data_color4[277], 2)
			end
		end
		statue.btn.data = data
		-- 延迟创建模型，避免打开面板的时候卡
		delayRun(self.dec_container, 5 * i / display.DEFAULT_FPS, function()
			self:setStatueModel(statue)
		end)
	end
end

function ArenaEnterChampionView:setStatueModel(statue)
	if tolua.isnull(statue) then return end
	local data = statue.btn.data
	if data == nil then
		if statue.spine ~= nil then
			if statue.spine ~= nil then
				statue.spine:DeleteMe()
				statue.spine = nil
			end
			statue.spine_id = nil
		end
		return
	end
	
	if statue.spine_id == data.lookid then return end
	
	if statue.spine ~= nil then
		statue.spine:DeleteMe()
		statue.spine = nil
	end
	statue.spine_id = data.lookid
	statue.spine = BaseRole.new(BaseRole.type.role, data.lookid)
	statue.spine:setAnimation(0, PlayerAction.show, true)
	statue.spine:setPosition(cc.p(statue.size.width * 0.5, 145))
	statue.spine:setAnchorPoint(cc.p(0.5, 0))
    -- statue.spine:setScale(0.72)
	statue.model:addChild(statue.spine)
end

function ArenaEnterChampionView:handleEvent(status)
	if status == false then
		if self.update_base_info_event ~= nil then
			GlobalEvent:getInstance():UnBind(self.update_base_info_event)
			self.update_base_info_event = nil
		end
		if self.update_role_info_event ~= nil then
			GlobalEvent:getInstance():UnBind(self.update_role_info_event)
			self.update_role_info_event = nil
		end
		if self.update_statue_list_event ~= nil then
			GlobalEvent:getInstance():UnBind(self.update_statue_list_event)
			self.update_statue_list_event = nil
		end
        if self.update_worship_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_worship_event)
            self.update_worship_event = nil
        end
	else
		if self.update_base_info_event == nil then
			self.update_base_info_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateChampionBaseInfoEvent, function(data) 
				self:setBaseInfo()
			end)
		end

		if self.update_role_info_event == nil then
			self.update_role_info_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateChampionRoleInfoEvent, function() 
				self:setRoleInfo()
			end)
		end

		if self.update_statue_list_event == nil then
			self.update_statue_list_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateChampionTop3Event, function(list)
				self:updateStatueInfo(list)
			end)
		end 

		if self.update_worship_event == nil then
            self.update_worship_event = GlobalEvent:getInstance():Bind(RoleEvent.WorshipOtherRole, function(rid, srv_id, idx)
                if idx ~= nil then
                    local statue = self.statue_list[idx]
                    if statue ~= nil and statue.worship_label ~= nil and statue.worship_num ~= nil then
                        statue.worship_num = statue.worship_num + 1
                        statue.worship_label:setString(statue.worship_num)
                        statue.btn:setTouchEnabled(false)
                        setChildUnEnabled(true, statue.btn, Config.ColorData.data_color4[1])
                        statue.worship_label:enableOutline(Config.ColorData.data_color4[2], 2)
                    end
                end
            end)
        end
	end
end

function ArenaEnterChampionView:DeleteMe()
	doStopAllActions(self.dec_container)
	doStopAllActions(self.btn_container)
	self:handleEvent(false)
	for i, statue in ipairs(self.statue_list) do
		if statue.spine ~= nil then
			if statue.spine ~= nil then
				statue.spine:DeleteMe()
				statue.spine = nil
			end
		end
	end
	self.status_list = nil
	self:removeAllChildren()
	self:removeFromParent()
end 
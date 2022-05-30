-- --------------------------------------------------------------------
-- 剧情播报控制器,主要是战斗中的表现
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

StoryView = StoryView or BaseClass()
function StoryView:__init()
	self:config()
	self:initEvent()
end

-- 初始化配置
function StoryView:config()
	self.ticket = GlobalTimeTicket:getInstance()
	self.cur_drama = nil									-- 当前剧情的配置数据
	self.cur_act_list = {} 									-- 记录当前动作列表
	self.cur_step = 0 										-- 当前动作步数
	self.talk = nil 										-- 记录对话界面
    self.is_next_action = false								-- 是否可以点击跳过的剧情
	self.cur_bubble = nil									-- 当前显示的泡泡
end

-- 事件监听
function StoryView:initEvent()
	-- 读取剧情配置完成
	if self.read_config_complete == nil then
		self.read_config_complete = GlobalEvent:getInstance():Bind(StoryEvent.READ_CONFIG_COMPLETE,function()
			self:checkPlayStory()
		end)
	end

	-- 强制播放下一个动作
	if self.play_next_act == nil then
		self.play_next_act = GlobalEvent:getInstance():Bind(StoryEvent.PLAY_NEXT_ACT,function()
            self:playNextAct()
		end)
	end

	-- 跳过剧情
	if self.skip_story == nil then
		self.skip_story = GlobalEvent:getInstance():Bind(StoryEvent.SKIP_STORY,function()
        	self:storyOverHandler()
		end)
	end
end

function StoryView:checkPlayStory(  )
	local result_view = BattleController:getInstance():getFinishView(BattleConst.Fight_Type.Darma) 
	local star_result = StartowerController:getInstance():getResultWindow()
	local is_wait_levupgrade = LevupgradeController:getInstance():waitLevupgrade()
	local is_in_guide = GuideController:getInstance():isInGuide() -- 引导中不播放剧情
	if not is_in_guide and result_view == nil and star_result == nil and is_wait_levupgrade == false then
		self:playAct()
	else
		if is_in_guide then
			-- 引导结束
			if self.guide_over_event == nil then
				self.guide_over_event = GlobalEvent:getInstance():Bind(GuideEvent.Update_Guide_Status_Event,function(status)
					if status == false then
						GlobalEvent:getInstance():UnBind(self.guide_over_event)
						self.guide_over_event = nil
						self:checkPlayStory()
					end
				end)
			end
		else
			if self.can_play_drama_event == nil then
				self.can_play_drama_event = GlobalEvent:getInstance():Bind(StoryEvent.PREPARE_PLAY_PLOT, function() 
					GlobalEvent:getInstance():UnBind(self.can_play_drama_event)
					self.can_play_drama_event = nil
					self:playAct()
				end)
			end
		end
	end
end

--==============================--
--desc:引导触发的时候做的一些事情,比如关闭界面等
--time:2018-07-14 09:26:07
--@return 
--==============================--
function StoryView:doSomeThingForDrama()
	if self.cur_drama and (self.cur_drama.bid == GuideConst.special_id.guild or 
		                   self.cur_drama.bid == GuideConst.special_id.seerpalace or 
		                   self.cur_drama.bid == GuideConst.special_id.stronger or 
		                   self.cur_drama.bid == GuideConst.special_id.home_guide_1 or 
		                   self.cur_drama.bid == GuideConst.special_id.home_guide_2 or 
		                   self.cur_drama.bid == GuideConst.special_id.home_guide_3 or 
		                   self.cur_drama.bid == GuideConst.special_id.shop or 
		                   self.cur_drama.bid == GuideConst.special_id.planes or --位面引导
						   self.cur_drama.bid == GuideConst.special_id.elfin or
						   self.cur_drama.bid == GuideConst.special_id.holy_dial or
						   self.cur_drama.bid == GuideConst.special_id.heaven_tips or
						   self.cur_drama.bid == GuideConst.special_id.resonate)then
		-- 以上剧情特殊处理，不做关闭界面
		return
	end
	local btn_index = MainuiController:getInstance():getMainUIIndex()
	if btn_index ~= MainuiConst.btn_index.drama_scene and btn_index ~= MainuiConst.btn_index.main_scene then
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, nil, nil, true)
	else
		-- 公会引导结束之后,会跟一个剧情,这个时候这个剧情是不要关闭窗体的
		if self.cur_drama and self.cur_drama.bid ~= GuideConst.special_id.guild and self.cur_drama.bid ~= GuideConst.special_id.market and self.cur_drama.bid ~= GuideConst.special_id.seerpalace 
			and self.cur_drama.bid ~= GuideConst.special_id.stronger then
			-- 当前在主城且在战斗中，触发剧情引导时要切出战斗
			if btn_index == MainuiConst.btn_index.main_scene and BattleController:getInstance():isInFight() then
				MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, nil, nil, true)
			else
				BaseView.closeAllView()
				BaseView.closeSomeWin()
			end
		end
	end 
end

--==============================--
--desc:播放引导的主入口
--time:2018-07-14 09:26:30
--@return 
--==============================--
function StoryView:playAct()
	local model = StoryController:getInstance():getModel()
	self.cur_drama = model:getCurStory()
	self:doSomeThingForDrama()
    model:setStoryState(true)

	local list = model:getCurActList()
	self.cur_act_list = clone(list)
	if self.cur_act_list == nil or next(self.cur_act_list) == nil then 
		self:storyOverHandler()
		StoryController:getInstance():send_11100(model:getCurStoryBid(), 0)
		return
	end
	self.cur_step = 0
	self:playNextAct()
end

--==============================--
--desc:没播一步通知服务端的返回  要是最后一步关闭面板
--time:2018-07-12 07:41:01
--@return 
--==============================--
function StoryView:playStepOver()
	if #self.cur_act_list == 0 then
		self:storyOverHandler()
	end
end

--==============================--
--desc:播放下一个引导
--time:2018-07-12 07:42:36
--@return 
--==============================--
function StoryView:playNextAct()
	local model = StoryController:getInstance():getModel()
    if not model:isStoryState() then return end
    self.is_next_action = false

	if self.cur_bubble ~= nil and not tolua.isnull(self.cur_bubble:getRootWnd()) then
		doStopAllActions(self.cur_bubble:getRootWnd())
		self.cur_bubble:DeleteMe()
	end
	self.cur_bubble = nil

	local step = self.cur_step + 1
	self.cur_step = step
	if self.cur_act_list and #self.cur_act_list > 0 then
        if self.ticket:hasTicket("delayPlayStory") then
            self.ticket:remove("delayPlayStory")
        end
	    local obj = table.remove(self.cur_act_list, 1)
		StoryController:getInstance():send_11100(model:getCurStoryBid(), step)
		if type(obj[1]) == "table" then
			self:actTeamPlayer(obj)
		else
			self:actLonelyPlayer({obj},false)
		end
	else
		StoryController:getInstance():send_11100(model:getCurStoryBid(), step)
	end
end

-- 动作组的播放 obj 动作组对象
function StoryView:actTeamPlayer(obj)
	local time = 0
	for i = #obj, 1, -1 do
		local act = obj[i]
        time = math.max(time, act[2] + act[3])
		local async = function()
			self:actLonelyPlayer({act},true)
		end
		self.ticket:add(async,act[2],1)
	end
	local cb = function()
		self:playNextAct()
	end
	if time > 0 then
		self.ticket:add(cb, time, 0, "delayPlayStory")
    else
		self:playNextAct()
	end
end

-- 单个动作的播放 obj 动作对象 is_async 是否异步
function StoryView:actLonelyPlayer(obj, is_async)
	local copy_data
	for k,v in pairs(obj) do
		v = deepCopy(v)
		k = table.remove(v, 1)
		if k == "unit_dialog" then
    		self:showTalk(v[3],v[4],v[5],v[6],v[7])
    		self:playActSound(v[8])
		elseif k == "unit_opening" then
			self:playWelcom(true, v[3])
			self:playActSound(v[4])
		elseif k == "comic_begin" then
			self:playStartManga(true, v[3], v[4])
			self:playActSound(v[5])
		elseif k == "unit_black" then
			self:showBlackCurtain(true,v[3],v[5],v[6])
			self:playActSound(v[4])
		end
        if is_async then return end -- 动作组 由动作组决定超时时间

		local total_time = ( v[1] or 0 ) + ( v[ 2] or 0 )
    	local cb = function()
    		self:playNextAct()
    	end
    	if total_time == 0 then
    		self:playNextAct()
		elseif total_time > 0 and not is_async then
    		--self.ticket:add(cb, total_time, 0, "delayPlayStory")
    	end
    end
end

-- 播放音效
function StoryView:playActSound( sound_name )
	if sound_name then
		AudioManager:getInstance():stopAllSoundByType(AudioManager.AUDIO_TYPE.Drama)
		AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.Drama, sound_name, false)
	end
end

--==============================--
--desc:一段剧本播放结束,这个时候需要清除掉之前所有创建的单位数据
--time:2017-06-03 05:51:35
--return 
--==============================--
function StoryView:storyOverHandler()
	if self.ticket:hasTicket("delayPlayStory") then
		self.ticket:remove("delayPlayStory")
    end
	if self.cur_bubble ~= nil and not tolua.isnull(self.cur_bubble:getRootWnd()) then
		doStopAllActions(self.cur_bubble:getRootWnd())
		self.cur_bubble:DeleteMe()
	end
	self.cur_bubble = nil

	-- 对白
    self:hideTalk()
	self:clearDramaData()
	self:playStartManga(false)
	self:playWelcom(false)
	self:showBlackCurtain(false)
end

--==============================--
--desc:结束剧情,清除掉剧情相关的所有数据
--time:2017-08-16 10:56:17
--@return 
--==============================--
function StoryView:clearDramaData()
    self.cur_step = 0
    StoryController:getInstance():getModel():setStoryState(false) 	
	self.cur_drama = nil
    self.is_next_action = false
end

--==============================--
--desc:剧情对话面板
--time:2017-06-03 02:11:31
--@type:
--@bid:
--@msg:
--return 
--==============================--
function StoryView:showTalk(type, bid, actiontype, name, msg )
	name = Config.DramaData.data_guide_desc[name].desc
	msg = Config.DramaData.data_guide_desc[msg].desc
    self.is_next_action = true
    if self.talk == nil then
		self.talk = StoryTalk.New(self.cur_drama.is_skip)
		self.talk:open(type, bid, actiontype, name, msg)
	else
		self.talk:setData(type, bid, actiontype, name, msg)
	end
end

--==============================--
--desc:播放开场漫画
--time:2018-07-11 05:36:25
--@effect_id:
--@action_num:
--@return 
--==============================--
function StoryView:playStartManga(status, effect_id, action_num)
	if status == true then
		self.is_next_action = true
		if self.manga_view == nil then
			self.manga_view = StoryMangaView.New()
		end
		self.manga_view:open(effect_id, action_num) 
	else
		if self.manga_view then
			self.manga_view:close()
			self.manga_view = nil
		end
	end
end

--- 打开欢迎界面
function StoryView:playWelcom(status, msg)
	if status == true then
		self.is_next_action = true
		if self.welcom_window == nil then
			self.welcom_window = DramaWelcommeWindow.New()
		end
		self.welcom_window:open(msg)
	else
		if self.welcom_window then
			self.welcom_window:close()
			self.welcom_window = nil
		end
	end
end

-- 打开黑幕界面
function StoryView:showBlackCurtain( status, msg ,interval_time, end_time)
	if status == true then
		self.is_next_action = true
		if self.black_curtain_window == nil then
			self.black_curtain_window = DramaBlackCurtainWindow.New()
		end
		msg = Config.DramaData.data_guide_desc[msg].desc
		self.black_curtain_window:open(msg,interval_time, end_time)
	else
		if self.black_curtain_window then
			self.black_curtain_window:close()
			self.black_curtain_window = nil
		end
	end
end

--==============================--
--desc:剧情对话面板
--time:2017-06-03 02:11:14
--return 
--==============================--
function StoryView:hideTalk()
    if self.ticket:hasTicket("delayPlayStory") then
        self.ticket:remove("delayPlayStory")
    end
    if self.talk then
        self.talk:close()
        self.talk = nil
    end
end


--==============================--
--desc:剧情或者战斗中的泡泡,优先从剧情单位列表中查找对象
--time:2017-06-03 11:42:04
--@time:
--@id:
--@msg:
--@delay:
--@replay:
--@model_size
--return 
--desc:这个动作是要标志可以跳过的
--==============================--
function StoryView:showBubble(time,id,msg,delay,replay,model_size)
	if time == 0 then
		return
	end

	local battle_ctrl = BattleController:getInstance()
	local battle_model = battle_ctrl:getModel()
	if battle_ctrl:getIsNoramalBattle() then
		battle_model = battle_ctrl:getNormalModel()
	end
	if battle_model == nil then return end
	local spine = nil
	local screen_pos = nil
	local y_fix = nil
	local model_scale = model_size or  1
	msg = msg or ""
	local unit = nil
	if not battle_ctrl:getIsNoramalBattle() then
		unit = battle_model:getUnitById(id)
	end
	if unit ~= nil then
		spine = {root = unit.container,role_height = unit.boxHeight}
		screen_pos = unit.world_pos
	else
		local all_obj = battle_model:getAllObject()
		if all_obj ~= nil then
			for k,v in pairs(all_obj) do
				if v["pos"] == id then
                	if v["is_die"] then
                    	return
                	end
					spine = v["spine_renderer"]
                	y_fix = 0
					screen_pos = gridPosToScreenPos(v.grid_pos)
				end
			end
        	if spine == nil and not replay then
            	delayOnce(function() self:showBubble(time, id, msg, delay, true) end, 0.2)
        	end
		end
	end

	if spine and screen_pos then
		self:createBubble(spine, time, msg, screen_pos, y_fix,model_scale)
    end
end

--==============================--
--desc:创建一个泡泡,可能是剧情中的,也可能是普通战斗中的
--time:2017-06-13 10:21:50
--@time:
--@msg:
--return 
--==============================--
function StoryView:createBubble(spine, time, msg, screen_pos, y_fix,model_scale)
	if spine == nil or spine.root == nil or tolua.isnull(spine.root) then return end
    if spine.bubble_paopao then
        spine.bubble_paopao:DeleteMe()
        spine.bubble_paopao = nil
    end
	local bubble = StoryBubble.New(spine.root)
	bubble:getRootWnd():setScale(1/model_scale)
	bubble:getRootWnd():setCascadeOpacityEnabled(true)
	bubble:getRootWnd():setOpacity(255)
	bubble:getRootWnd():setLocalZOrder(spine.root:getGlobalZOrder()+99)
	local fade_in = cc.FadeIn:create(0.5)
	local fade_out = cc.FadeOut:create(0.5)
	if screen_pos.x > (display.width -100) then
		bubble:setData(msg)
		bubble:setPosition(0,(spine.role_height or 0) + (y_fix or 0))
	elseif screen_pos.x - bubble:getRootWnd():getContentSize().width < 0 then
		bubble:setData(msg, true)
		bubble:setPosition(bubble:getRootWnd():getContentSize().width, (spine.role_height or 0) + (y_fix or 0))
	else
		bubble:setData(msg)
		bubble:setPosition(spine.root:getContentSize().width/2, (spine.role_height or 0) + (y_fix or 0))
	end
	local delay1 = cc.DelayTime:create(time)
	local call_fun = cc.CallFunc:create(function()
		bubble:DeleteMe()
	end)
	local seq = cc.Sequence:create(fade_in,delay1,fade_out,call_fun)
	bubble:getRootWnd():runAction(seq)
	if StoryController:getInstance():getModel():isStoryState() then
    	self.is_next_action = true
		self.cur_bubble = bubble
    	bubble:addCloseCallBack(function()
        	self.cur_bubble = nil
    	end)
	else
        spine.bubble_paopao = bubble
    	bubble:addCloseCallBack(function()
        	spine.bubble_paopao = nil
    	end)
    end
end

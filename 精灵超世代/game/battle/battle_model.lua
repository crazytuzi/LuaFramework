-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      战斗核心逻辑模块
-- <br/>Create: 2015.01.01
--
-- --------------------------------------------------------------------

BattleModel = BattleModel or BaseClass()

--初始化单例
function BattleModel:__init()
	self.is_exit = true
	self.init_battle_role = false
	self.role_time_scale = 1
end

function BattleModel:initConfig()
	self.battle_controller = BattleController:getInstance()
	self.battle_normal_model = BattleController:getInstance():getNormalModel()
end

--==============================--
--desc:初始化部分数据
--time:2018-09-07 02:45:49
--@return 
--==============================--
function BattleModel:resetStartInfo()
	self.main_vo 				 = RoleController:getInstance():getRoleVo() or {} --宝可梦人物信息
	self.finish_data 			 = {} 		--战斗结束数据
	self.select_skill 			 = nil 		--选择技能
	self.res_num 				 = 0 		--资源数量
	self.is_exit 				 = false 	--是否已退出
	self.is_speed 				 = 1     	--是否加速 因为需求 有三倍速了 所以变成 对应 x1 x2 x3  --by lwc
	
	self.all_object 			 = {} 		--场景所有人物列表
	self.round_data 			 = {} 		--回合数据
	self.round_data_temp 		 = {} 		--临时保存过期的回合数据
	self.res_list 				 = {} 		--加载资源列表
	self.group 					 = 1 		--分组信息,默认是友方...要不然存在雇佣的时候,把自己的全部下掉了...这时候对比雇佣的就变成敌方了
	self.act_playing 			 = false 	--是否动作中
	self.one 					 = nil  	--每个效果数据
	self.show_finish_ui 		 = false 	--是否显示结算界面
	self.act_after_effect_list 	 = {} 		--保存buff动作后列表
	self.is_battle_type 		 = false 	--那种类型播放,ture为回合播报,false是正常播报
	self.is_next_mon 			 = false 	--是否存在下波怪物
	self.is_double_speed 		 = false 	--是否双倍加速
	self.sum 					 = 0 		--准备人员统计
	self.effect_bid_list 		 = {} 		--效果Bid列表
	self.effect_list 			 = {} 		--特效列表
	self.prepare_role_list		 = {} 		--预加载模型资源
	self.prepare_sound_list 	 = {}		--预加载音效
	self.is_right_target 		 = true 	--是否存在正确目标
	self.second_data 			 = nil 		--是否存在第二个播报
	self.is_black 				 = false 	--是否黑屏中
	-- self.die_num 				 = 0 		--记录怪物死亡人数
	self.next_mon_sum 			 = 0  		--下一波怪物总数
	self.total_distance 		 = 150000 	--初始化跑条总长度
	self.distance_list 			 = {} 		--跑条长度列表
	self.actor_sum 				 = 0 		--施法者总数
	self.actor_play_sum 		 = 0 		--施法者动作完成总数
	self.is_can_target 			 = false
	self.titan_data 			 = {}
	self.skill_cooldown_info 	 = {}
	self.star_sum_list 			 = {} 		--星星列表
	self.dragon_data 			 = {} 		--巨龙副本数据
	self.reconnect_num 			 = 0
	
	self.same_info_data	 = {}		-- 相同出手顺序下的不同回合播报处理

	self.scene_buff_effect_list  = {}		--场景buff的特效,已特效id储存,包含上层和下层特效,只要有就不需要创建
	
	self.skip_last_time = GameNet:getInstance():getTimeFloat()
	self.max_speed               = 2        -- 最大速度倍率 默认 2
	local config = Config.CombatTypeData.data_combat_speed[3]
	if config then
		if self.main_vo and self.main_vo.lev >= config.limit_lev then
			self.max_speed = config.speed		
		end
	end
	
end
----------------
--战斗基本逻辑--
----------------
--新建战斗逻辑
function BattleModel:battleStart(data)
	self:resetStartInfo()
	self.buffs 					 = data.buffs 						--重连buff
	self.fight_round 			 = data.current_wave or  1 			--当前战斗回合
	self.total_wave 			 = data.total_wave  or  1			--总回合
	self.action_count 			 = data.action_count or 0			--出手总次数
	self.fight_type 			 = data.combat_type

    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
        print("battleStart===>>", data.combat_type)
    end

	if not self.all_round_data then
		self.all_round_data 	 = {} --缓存所有波数怪物数据
	end
    self.hallows_list = {}
    for i, v in pairs(data.hallows_list or {}) do
        self.hallows_list[v.group] = v;
    end
	if data then
		--赋值战斗信息列表
		if next(data.objects or  {}) ~= nil then
			local sum_lev = 0
			local enmey_lev = 0
			local index = 0
			local enemy_index = 0
			for _, v in pairs(data.objects) do
				if not self.battle_controller:getWatchReplayStatus()  then
					v.fight_type = data.combat_type
					if v.owner_id == self.main_vo.rid and v.owner_srv_id == self.main_vo.srv_id then
						self.group = v.group
						self.battle_role_id = v.pos
					else
						local info = {rid = v.owner_id,srv_id = v.owner_srv_id}
						self:saveEnemyInfo(info)
					end
				else
					self.group = v.group
					self.battle_role_id = v.pos
				end
				-- 不计算神器和精灵的数量
				if v.hp > 0 and not self:checkIsHallowsOrElfin(v.object_type) then
					self.reconnect_num = self.reconnect_num + 1
				end
				if v.group == BattleGroupTypeConf.TYPE_GROUP_ROLE then
					index = index + 1
					sum_lev = sum_lev + v.lev
				elseif v.group == BattleGroupTypeConf.TYPE_GROUP_ENEMY then
					enemy_index = enemy_index + 1
					enmey_lev = enmey_lev + v.lev
				end
                if v.object_type == BattleObjectType.Hallows and self.hallows_list[v.group] then
                    v.hallows_val = self.hallows_list[v.group].val
                    v.hallows_max = self.hallows_list[v.group].max
                    self.hallows_list[v.group].pos = v.pos
                end
			end
			self.battle_controller:setSumLev(sum_lev/index)
			self.battle_controller:setEnemySumLev(enmey_lev/enemy_index)
		end
	end
	if not self.all_round_data[self.fight_round] then
		self.all_round_data[self.fight_round] = data.objects --缓存回合人物数据
	end
	if not tolua.isnull(self.battle_scene) then
		local call_back = function ()
			self:createBattleRole(data) --创建战斗人物
			if self.battle_scene and not tolua.isnull(self.battle_scene) then
				self.battle_scene:showUiViewAction()
			end
		end
		self.battle_scene:createUiLayer(data, self.main_vo, self.fight_type) --创建UI界面
		self:waitLoadBattleResources(data)
		if self.battle_controller:getInitStatus() == true then
			self.battle_scene:floorTips(call_back, data)
		else
			call_back()
		end
		--初始化战斗速率
		local play_speed = data.play_speed
		if self.battle_controller:getWatchReplayStatus() then -- 录像中默认给2倍数，且过程中可随意切换
			play_speed = 3
		end
		-- self:saveSpeed(self:changeSpeedState(play_speed), play_speed) 
		if play_speed ~= 1 and play_speed ~= 2 and play_speed ~= 3 then --过滤不是 这三个值的 判断
			play_speed = 1
		end

		self:saveSpeed(play_speed, play_speed) 
		GlobalEvent:getInstance():Fire(BattleEvent.BATTLE_DEBUG) --战斗调试
    else
        print("battleStart_battle_scene_null===>>", data.combat_type)
	end
end

--更新人物技能
function BattleModel:updataCurSkillData(data)
	if next(data.objects or {}) ~= nil then
		for i, role in ipairs(data.objects) do
			for _, v in ipairs(role.skills) do
				v.pos = role.pos
				v.cur_round = role.round
			end
		end
	end
end

--改变速度状态
function BattleModel:changeSpeedState(play_speed)
	if play_speed ~= nil then
		if play_speed >= self.battle_controller:getActTime("speed_scale") then
			return true
		else
			return false
		end
	end
end

--转换自动状态
function BattleModel:changeState(status)
	if status == TRUE then
		return true
	else
		return false
	end
end

--小回合处理
function BattleModel:round()
	if self.same_info_data and next(self.same_info_data) then
		local attacker = self.same_info_data.attacker
		local one = self.same_info_data.one
		local target_list = self.same_info_data.target_list
		one.target_list = {}
		for i, list in ipairs(target_list) do
			for _, n in ipairs(list) do
				table.insert( one.target_list, n )
			end
		end
		self.same_info_data = {}   -- 清空
		self:initOrder(attacker, one)
		return
	end

	if self.round_num and self.round_num > 0 then return end
	self.round_num = 0
	--清掉回合临时数据
	self.round_data_temp = {}
	self.second_data = nil
	self.actor_sum = 0
	self.actor_play_sum = 0
	--通知服务器播放完成
	if tableLen(self.order_list or {}) == 0 then
		--清除黑屏
		self:cancleBlackScreen()
		self.act_playing = false
		if self.all_object and next(self.all_object or {}) ~= nil then
			--回合结束后生效的buff特效
			if next(self.act_after_effect_list or {}) ~= nil then
				for _, buff in ipairs(self.act_after_effect_list) do
					local target = self.all_object[buff.target]
					self:playRoundBuff(target, buff, true)
				end
				self.act_after_effect_list = {}
			end
			for _, v in pairs(self.all_object or {}) do  --回合结束清掉缓存的buff_tips列表
				if v and v.spine_renderer and not v.spine_renderer.is_die then
					v.temp_skill_bid = 0
					if  v.spine_renderer:getActionName() ~= v.spine_renderer.stand  then
						SkillAct.setAnimation(v.spine_renderer, v.spine_renderer.stand, true)
					end
					if v.tips_list then
						v.tips_list = {}
					end
				end
			end
		end
		if self.is_battle_type == true then
			if self.play_round_start_data then
				self:handlePlayRoundStart(self.play_round_start_data)
				self.play_round_start_data = nil
			end
			self.battle_controller:csRoundFightEnd() --回合有播报数据通知服务器完成
			self:setUseSkillStatus(false)
		else
			self.battle_controller:csSkillPlayEnd() --通知服务器完成
		end
		return
	else
		self.one = table.remove(self.order_list, 1)
		local round_data = self.round_data[self.one.order]
		-- 这里的作用主要是做多段攻击判断
		if next(self.order_list or {} ) ~= nil then
			local second_order = self.order_list[1].order
			self.second_data = self.round_data[second_order]
		end
		self.round_num = tableLen(round_data)
		for _, round_one in pairs(round_data or {}) do
			self.round_num = self.round_num - 1
			for _, round_one_temp in pairs(round_one or {}) do
				--如果效果有,则执行动作
				if #round_one_temp.target_list > 0 then
					if self.all_object and next(self.all_object or {}) ~= nil and self.all_object[round_one_temp.actor] then
						local attacker = self.all_object[round_one_temp.actor]
						self.one.actor = round_one_temp.actor
						self.actor_sum = self.actor_sum + 1
						if attacker.spine_renderer then
							self:initOrder(attacker, round_one_temp)
						else
							self:round()
						end
					end
				else
					self:round()
				end
			end
		end
	end
end

--==============================--
--desc:初始化动作列表
--time:2019-01-07 08:27:44
--@attacker:施法者
--@one:回合数据
--@return 
--==============================--
function BattleModel:initOrder(attacker, one)
	if(not attacker.spine_renderer or attacker.spine_renderer.in_act) and self.battle_scene then
		attacker.error_time =(attacker.error_time or 0) + 1
		if attacker.error_time < 5 then
			delayRun(self.battle_scene, 0.5, function()
				self:initOrder(attacker, one)
			end)
		else
			attacker.in_act = false
		end
	end
	table.sort(one.target_list,function (a,b) --先根据index重新排序
		return a.priority < b.priority
	end)
	local list = deepCopy(one.target_list)
	table.sort(list, function(a, b) --先根据index重新排序
    	return a.target < b.target
	end)
	local col_target = list[1].target
	if col_target > 9 then
		col_target = col_target - GIRD_POS_OFFSET
	end
	if self.one and self.one_actor and self.one.actor == self.one_actor then

	else
		attacker:resetZOrder()
		attacker.targe_zorder = 999
	end
	local col = pos_to_col[col_target] 
	if self.all_object and next(self.all_object or {}) ~= nil and self.all_object[col_target] then
		if self.all_object[col_target].spine_renderer and self.all_object[col_target].spine_renderer.root then
			self.all_object[col_target]:resetZOrder()
			attacker.targe_zorder = self.all_object[col_target].spine_renderer.root:getLocalZOrder()
		end
	end
	attacker.col = col
	attacker.error_time = 0
	attacker.is_round = false  --没播放完成
	attacker.attacker_info = one --攻击者信息
	attacker.skill_data = Config.SkillData.data_get_skill(one.skill_bid) --技能信息
	attacker.target_pos = {x = attacker.grid_pos.x, y = attacker.grid_pos.y} --攻击者位置
	self:calcTargetPos(attacker)
	--重置播放受击
	for _, v in pairs(self.all_object or {}) do
		v.dmg_index = nil
		if v.dmg_aid_y_offset then
			v.dmg_aid_y_offset = 0
		end
		v.is_hurt_play = false
		v.is_big_play = false
		if v.tips_list then
			v.tips_list = {}
		end
	end

	-- 因为策划配置可能存在同一回合触发不同效果id播报
	local tmp_list = {}
	for i,v in ipairs(one.target_list) do
		if tmp_list[v.effect_bid] == nil then
			tmp_list[v.effect_bid] = {}
		end
	 	table.insert( tmp_list[v.effect_bid], v )
	end
	if tableLen(tmp_list) > 1 then  -- 这个时候就存在同一回合出现多个效果播报了,比较坑了
		-- print("WTF______more than one action in one round")
		local order_list = {}
		for k,v in pairs(tmp_list) do
			table.insert( order_list, v )
		end
		one.target_list = table.remove(order_list, 1)
		self.same_info_data = {attacker=attacker, one=one, target_list = order_list}
	end
	self:beginPlayEffectAction(attacker, one)
end

--[[
    @desc: 
    author:{author}
    time:2020-02-20 01:52:43
    --@attacker:
	--@one: 
    @return:
]]
function BattleModel:beginPlayEffectAction(attacker, one)
	if attacker == nil or one == nil then return end

	-- 这里需要根据皮肤去转换效果id
	local battle_effect_bid = one.target_list[1].effect_bid --效果ID
	local attacker_fashion_id = attacker:getFashionId()
	if attacker_fashion_id and attacker_fashion_id ~= 0 and battle_effect_bid ~= 0 then
		local skin_effect_id = Config.PartnerSkinData.data_skilltoeffect[getNorKey(attacker_fashion_id, battle_effect_bid)]
		if skin_effect_id then
			battle_effect_bid = skin_effect_id
		end
	end
	attacker.play_order_index = battle_effect_bid 
	-- print("WTF__skill____",one.skill_bid, battle_effect_bid)

	if attacker.play_order_index == nil or attacker.play_order_index == 0 then --如果效果ID为0或者空值返回
		self.actor_play_sum = self.actor_play_sum + 1
		-- 这里是新增加的..有一些时候的效果不报是0,但是却包含了子效果播报,这里需要重点观察
		local effect_play = one.target_list[1]
		if effect_play then
			if effect_play.sub_effect_play_list and next(effect_play.sub_effect_play_list) then
				self:handleSubEffectPlaylist(effect_play,attacker)
			end
        	self:dealRoundBuff(effect_play.buff_list, attacker)
		end
		self:round()
		return
	end
	
	local data_get_effect = Config.SkillData.data_get_effect 
	local effect_config = data_get_effect(attacker.play_order_index)
	if effect_config then
		attacker.play_order = deepCopy(effect_config.action_list)											--动作列表
		attacker.shake_id = effect_config.shake_id or 0 													--震屏ID
		attacker.effect_type = effect_config.effect_type or 1 												--效果类型
		attacker.act_hurt_type = effect_config.act_hurt_type or 0 											--受击表现
		attacker.play_stand = effect_config.play_stand or 1													--群攻时候是否收招
		attacker.anime_res = effect_config.anime_res or ""													--模型id,模型文件名
		attacker.split_hurt = effect_config.split_hurt or 1													--多段攻击次数
		attacker.hit_action = effect_config.hit_action or ""												--受击回调函数
		attacker.effect_desc = effect_config.effect_desc or ""												--效果描述
		attacker.is_must_die = effect_config.is_must_die or 0												--死亡移除
		attacker.is_move_map = effect_config.is_move_map or 0												--是否移动地图
		attacker.anime_user_atk = effect_config.anime_user_atk or ""										--攻击动作
		attacker.attack_sound = effect_config.attack_sound or ""											--攻击音效
		attacker.ready_sound = effect_config.ready_sound or ""												--起手音效
		attacker.shout_trick = effect_config.shout_trick or ""												--喊招音效
		attacker.hit_sound = effect_config.hit_sound or "" 													--受击音效


		-- attacker.bact_effect_list = deepCopy(self:getCurEffectList(effect_config.bact_effect_list )) 		--记录施法特效
		-- attacker.act_effect_list = deepCopy(self:getCurEffectList(effect_config.act_effect_list)) 			--记录出手点特效
		-- attacker.area_effect_list = deepCopy(self:getCurEffectList(effect_config.area_effect_list)) 		--记录范围人物特效
		-- attacker.hit_effect_list = deepCopy(self:getCurEffectList(effect_config.hit_effect_list)) 			--记录打击特效列表
		-- attacker.trc_effect_list = deepCopy(self:getCurEffectList(effect_config.trc_effect_list )) 			--记录弹道特效

		--modified by chenbin
		attacker.bact_effect_list = {}
		attacker.act_effect_list = {}
		attacker.area_effect_list = {}
		attacker.hit_effect_list = {}
		attacker.trc_effect_list = {}

	end

	--判断是否存在群攻魔法
	if next(attacker.area_effect_list or {}) ~= nil then
		print("WTF____area____effect")
	-- 	attacker.attacker_info.is_calc = false
	-- 	attacker.in_area_effect = true
	-- 	attacker.area_hit_num = 1
	-- 	attacker.area_hit_time = 0
	else
	-- 	attacker.in_area_effect = false
	end

	--modified by chenbin
	attacker.in_area_effect = false

	--播放动作函数
	local start_attack = function()
		self:playOrder(attacker)
	end
	local show_skill_name = function()
		if attacker.skill_data then
			if attacker.skill_data.type == BattleSkillTypeConf.PASSIVE_SKILL and attacker.skill_data.passive_skill_show == TRUE then -- 被动技能喊招方式
				if self.battle_scene and not tolua.isnull(self.battle_scene) then
					self.battle_scene:showPassiveSkillName(attacker, function()
						start_attack()
					end)
				end
			elseif attacker.skill_data.type == BattleSkillTypeConf.ACTIVE_SKILL then
				if self.battle_scene and not tolua.isnull(self.battle_scene) then
					self.battle_scene:showSkillName(attacker, function()
						start_attack()
					end, self.act_playing)
				end
			else
				start_attack()
			end
		end
	end
	-- 精灵的技能效果
	local show_elfin_ani = function ()
		if self.battle_scene and not tolua.isnull(self.battle_scene) then
			self.battle_scene:showElfinSkillAni(attacker, function()
				start_attack()
			end, self.act_playing)
		end
	end
	if attacker.object_type == BattleObjectType.Elfin then -- 精灵单独处理
		self:talk(attacker, show_elfin_ani)
		-- self:talk(attacker, show_skill_name)
	elseif one.skill_bid == 0 then --不需要喊招表现
		self:talk(attacker, start_attack)
	else
		self:talk(attacker, show_skill_name)
	end
	self.act_playing = true
end


--==============================--
--desc:从执行动作播报顺序列表中取出一个,用于播报
--time:2019-05-07 11:00:29
--@attacker:
--@return 
--==============================--
function BattleModel:playOrder(attacker)
	if attacker == nil or (attacker.wait_act and attacker.wait_act ~= 0) then return end
	attacker.wait_act = 0
	if self.show_finish_ui == true or attacker.spine_renderer == nil then
		return 
	end
	if self.fight_type ~= self.battle_controller:getCurFightType() then
		return
	end
	if attacker.play_order_index == nil or attacker.play_order_index == 0 then
		return
	end
	if attacker.play_order == nil or next(attacker.play_order) == nil then --判断是否还有动作进行
		self.actor_play_sum = self.actor_play_sum + 1
		if not attacker.is_die then
			local second_actor = 0 										-- 下一个播报的发起者
			self.one_actor = self.one and self.one.actor or 0			-- 当前播报的发起者
			if self.second_data then
				for _, round_one in pairs(self.second_data or {}) do
					for _, round_one_temp in pairs(round_one or {}) do
						second_actor = round_one_temp.actor
						break
					end
					if second_actor ~= 0 then
						break
					end
				end
			end
			--主要判断多连情况下什么时候转换为站立动作
			if second_actor == 0 or (self.one and self.one.actor ~= second_actor) then
				if attacker.spine_renderer:getActionName() ~= attacker.spine_renderer.stand then 
					SkillAct.setAnimation(attacker.spine_renderer, attacker.spine_renderer.stand, true)
				end
				--清除黑屏
				self:cancleBlackScreen()
				attacker:resetZOrder()
			end
		end
		if not attacker.is_round then --播放完动作后结束界面	
			self.act_playing = false
			if self.actor_play_sum >= self.actor_sum then --判断该播报的所有施法者都播放完成
				self:round() --播放完,执行下一轮动作
			end
		end
	else --逐个动作播放
		local index = attacker.play_order[1]
		table.remove(attacker.play_order, 1)
		local act = self:singleAct(index, attacker)
		if not tolua.isnull(attacker.spine_renderer.root) then
			attacker.spine_renderer:runAction(act)
		end
	end
end

--==============================--
--desc:AI气泡处理
--time:2019-05-07 11:25:21
--@attacker:
--@callback:
--@return 
--==============================--
function BattleModel:talk(attacker, callback)
	local msg = attacker.attacker_info.talk_content
	local actor = attacker.attacker_info.talk_pos
	if msg == "" or self.act_playing == true then
		if callback then
			callback()
		end
		return
	end
	msg = string.gsub(msg, "#name#", attacker.target_name or "")
	local data = WordCensor:getInstance():relapceFaceIconTag(msg)             -- 处理表情符转换
	local msg_time = 2
	if self.fight_type and self.fight_type == BattleConst.Fight_Type.Training_Camp then -- 新手训练营时间特殊处理
		msg_time = 0
	end
	StoryController:getInstance():getView():showBubble(msg_time, actor, data[2],0,nil,attacker.model_scale)
	if callback then
		callback()
	end
end

function BattleModel:resetBgPos()
	if self.battle_scene and not tolua.isnull(self.battle_scene) then
		if self.battle_scene:getSmapLayer() and not tolua.isnull(self.battle_scene:getSmapLayer()) then
			if  self.battle_scene:getSmapLayer():getPositionX() ~= 0 then
				self.battle_scene:getSmapLayer():setPositionX(0)
			end
		end
		if self.battle_scene:getMidmapLayer() and not tolua.isnull(self.battle_scene:getMidmapLayer()) then
			if  self.battle_scene:getMidmapLayer():getPositionX() ~= 0 then
				self.battle_scene:getMidmapLayer():setPositionX(0)
			end
		end
		if self.battle_scene:getFmapLayer() and not tolua.isnull(self.battle_scene:getFmapLayer()) then
			if  self.battle_scene:getFmapLayer():getPositionX() ~= 0 then
				self.battle_scene:getFmapLayer():setPositionX(0)
			end
		end
	end
end
--添加回合
--[[	@data:回合开始数据 --协议20002
]]
function BattleModel:playRoundStart(data,is_rec)
	if self.all_object == nil or next(self.all_object) == nil then return end	-- 这个做了容错
	if data == nil then return end

	-- 回合开始之前先移除掉已经死亡的
	if data.all_alive then
		local temp_list = {}
		for i,v in ipairs(data.all_alive) do
			temp_list[v.pos] = v.pos
		end
		for k,v in pairs(self.all_object) do
			if temp_list[k] == nil then			-- 死亡的
				if v.is_die == false and v.object_type ~= BattleObjectType.Hallows and v.object_type ~= BattleObjectType.Elfin then
					v:doDied()
				end
			end
		end
	end
	
	self.res_num = 0
	self.round_data = {}
	self.distance_list = {}
	self.order_list = {}
	self.act_playing = false
	self.total_distance = data.total_distance
	self.order_pos = data.pos
	self.play_round_start_data = data
	self.action_count  = data.action_count
	--如果回合开始有回合播报,则执行动作
	
	if data.hallows_list and self.all_object then
		for i, v in pairs(data.hallows_list) do
			local hallows = self.hallows_list[v.group]
			if hallows and hallows.pos then
				local obj = self.all_object[hallows.pos]
				if obj and obj.spine_renderer then
					obj.spine_renderer:setHallowsRound(v.val)
				end
			end
		end
	end

	-- 更新精灵的技能cd状态
	if data.sprite_cd_info and self.all_object then
		for _,v in pairs(data.sprite_cd_info) do
			local obj = self.all_object[v.pos]
			if obj and obj.spine_renderer then
				obj.spine_renderer:updateElfinSkillState(v.cd_info)
			end
		end
	end

	if next(data.skill_plays) == nil then
		self.battle_controller:csRoundFightEnd()
		self:setUseSkillStatus(false)
	else
		self:setUseSkillStatus(true)
		self:addRoundData(data, true) --true主要标记20002有roundbuff就不在处理了。
	end
	if self.battle_controller:getCtrlBattleScene() then
		self.battle_controller:getCtrlBattleScene():updateRound(data.action_count)
	end
	if next(data.skill_plays) == nil then  --如果回合没有播报,就直接执行是否可出手,如果存在就在播报完成后再去判断出手
		self:handlePlayRoundStart(data)
	end
	if not self.act_after_effect_list then --回合播放完成之后才播放buff列表
		self.act_after_effect_list = {}
	end
end

function BattleModel:handlePlayRoundStart(data,is_rec)
	if data == nil then return end
	if data.combat_type ~= self.battle_controller:getCurFightType() then return end
	
	self.is_role = self:getCurRoleType(self.order_pos)

	if next(self.all_object or {}) ~= nil and self.all_object then
		for _, v in pairs(self.all_object) do
			if v.spine_renderer and v then
				if not v.spine_renderer.is_die then --没死的伙伴在回合结束停止所有动作和重设位置
					v:resetZOrder()
					v.spine_renderer:setPosByGrid(v.grid_pos_back)
				else
					v:died()
				end
			end
		end
	end

	if next(data.round_buff) ~= nil then
        self:dealRoundBuff(data.round_buff)
	end
end

function BattleModel:getIsRoleRound()
	return self.is_role
end

--战斗播报
--[[	@data:战斗播报数据 协议20004
]]
function BattleModel:addRoundData(data, is_round)
	if data.combat_type ~= self.battle_controller:getCurFightType() then return end
	if not is_round then
		self.action_count  = data.action_count
	end

	-- 更新精灵的技能cd状态
	if data.sprite_cd_info and self.all_object and next(self.all_object or {}) ~= nil then
		for _,v in pairs(data.sprite_cd_info) do
			local obj = self.all_object[v.pos]
			if obj and obj.spine_renderer then
				obj.spine_renderer:updateElfinSkillState(v.cd_info)
			end
		end
	end

	self.star_sum_list = data.star_list
	self.round_data = {}
	self.order_list = {}
	--重组技能播报数据
	self.skill_plays_order_list = {}
	self.act_playing = false
	if self.battle_controller:getCtrlBattleScene() then
		self.battle_controller:getCtrlBattleScene():updateRound(self.action_count)
		self.battle_controller:getCtrlBattleScene():updateHeavenStarInfo(self.star_sum_list)
	end
	if next(self.all_object or {}) ~= nil and self.all_object then
		for _, v in pairs(self.all_object) do
			if v.is_round then
				v.is_round = false
			end
		end
	end

	if (data.skill_plays or {}) ~= nil  then
		for j, v in ipairs(data.skill_plays) do
			if next(v.effect_play or {}) ~= nil then
				for i, v1 in ipairs(v.effect_play) do
					if self.round_data_temp then
						if self.round_data_temp[v.order] == nil then
							self.round_data_temp[v.order] = {}
							table.insert(self.skill_plays_order_list, { skill_order = v.order, priority = v.order * 1000 + j})
						end
					end
					v1.skill_bid = v1.skill_bid_of_effect
					v1.talk_pos = v.talk_pos
					v1.talk_content = v.talk_content
					v1.index = i
					v1.skill_order = v.order
                    v1.priority = v1.order * 10000 + j * 100 + i
					if self.round_data_temp then
						table.insert(self.round_data_temp[v.order], v1)
					end
				end
			end
		end
		table.sort(self.skill_plays_order_list, function(a, b)
				return a.priority < b.priority
		end)
	end

	if next(self.round_data_temp or {}) ~= nil then --判断是否存在播报
		if next(self.skill_plays_order_list) ~= nil then
			for _, one in ipairs(self.skill_plays_order_list) do
				local temp = self.round_data_temp[one.skill_order]
				if temp then
					for _, one_temp in pairs(temp) do
						if self.round_data[one_temp.order] == nil then
							self.round_data[one_temp.order] = {}
							table.insert(self.order_list, {order = one_temp.order, priority = one_temp.priority})
						end
						if self.round_data[one_temp.order][one_temp.actor] == nil then
							self.round_data[one_temp.order][one_temp.actor] = {}
						end
						local object = {}
						object = self.round_data[one_temp.order][one_temp.actor][1]
						if object == nil then
							object = {}
							object.actor = one_temp.actor
							object.order = one_temp.order
							object.skill_bid = one_temp.skill_bid
							object.talk_content = one_temp.talk_content
							object.talk_pos = one_temp.talk_pos
							object.index = one.index
							table.insert(self.round_data[one_temp.order][one_temp.actor], object)
						end
						if object.target_list == nil then
							object.target_list = {}
						end
						table.insert(object.target_list, one_temp)
					end
				end
			end
			table.sort(self.order_list, function(a, b)
				return a.priority < b.priority
			end)
			self.round_data_temp = {}
		end
		self:round()

		if not self.act_after_effect_list then
			self.act_after_effect_list = {}
		end
		if not is_round then
			if next(data.round_buff) ~= nil then
				for _, buff in pairs(data.round_buff) do
					local buff_data = nil
					if Config.SkillData.data_get_buff[buff.buff_bid] then
						buff_data = Config.SkillData.data_get_buff[buff.buff_bid]
					end
					if buff_data ~= nil then
						table.insert(self.act_after_effect_list, buff)
					end
				end
			else
				self.act_after_effect_list = {}
			end
		end
	else
		if not is_round then
            self:dealRoundBuff(data.round_buff)
		end
		self:round()
	end
end

-- 处理回合buff
function BattleModel:dealRoundBuff(buff_list, attacker)
    for _, buff in pairs(buff_list or {}) do
        local buff_data = nil
        if Config.SkillData.data_get_buff[buff.buff_bid] then
            buff_data = Config.SkillData.data_get_buff[buff.buff_bid]
        end
        if buff_data ~= nil then
            if next(self.all_object or {}) ~= nil and self.all_object then
                local target = self.all_object[buff.target]
                self:playRoundBuff(target, buff, attacker)
            end
        end
    end
end

--进入战斗可能需要处理一些函数.
function BattleModel:enterFightFunc()
	GlobalEvent:getInstance():Fire(SceneEvent.ENTER_FIGHT, self.fight_type,self.battle_controller:getIsNoramalBattle())
end

--战斗地图赋值
function BattleModel:createBattleScence(data)
    if self.finish_data and self.finish_data.combat_type == data.combat_type then
        self.finish_data = nil
    end
	self.battle_controller:setCircleData(nil)
	if BattleConst.canDoBattle(data.combat_type) then
		if BattleConst.isNoRequest(data.combat_type) == true then
			self.battle_controller:setCurFightType(data.combat_type)
		end
		self.battle_controller:setExtendFightType(data.combat_type)
		self.battle_controller:setPkStatus(false)
		self.battle_controller:setIsHeroTestWar(false)
	    if data.combat_type == BattleConst.Fight_Type.PK then
			self.battle_controller:setPkStatus(true)
		elseif data.combat_type == BattleConst.Fight_Type.HeroTestWar then
			self.battle_controller:setIsHeroTestWar(true)
		end
		self.battle_controller:createMap(data)
	end
end

function BattleModel:enterBattle(data)
	self.battle_scene = self.battle_controller:getCtrlBattleScene()
	if self.battle_scene then
		self.battle_scene:setbattleModel(self.battle_controller:getModel())
		self.battle_scene:updateBtnLayerStatus(false)
		self.battle_scene:handleLayerShowHide(true)
	end
	self:playEnterEffect(data)
end
function BattleModel:createBattle(data)
	if not self.start_battle_timestamp then
		self.start_battle_timestamp = data.begin_time or GameNet:getInstance():getTime()
	end
	self:createBattleScene(data)
end
-- 创建战场，实际上就是创建战斗
function BattleModel:createBattleScene(data)
	if self:getReconnectStatus() then
		self:reconnectClear(data)
	else
		self:clearAllObject()
		self:battleStart(data)
	end
	self:enterFightFunc()
end

-- 播放进入战斗动画
function BattleModel:playEnterEffect(data)
	self.battle_controller:setIsNormaBattle(false)
	self.battle_controller:setBattleStartStatus(true)
	if self.show_finish_ui then --用于清理结束界面没关的时候清理
		self.battle_controller:openFinishView(false,self.fight_type)
	end
	self:createBattle(data)
end

-- 黑幕,加深友方.黑掉地图所有层
function BattleModel:blackScreen(attacker, delay_time, time, alpha, particle_id, effect_delay_time,is_loop)
	-- print("WTF_____BattleModel:blackScreen")
	time = time or display.DEFAULT_FPS / 4
	effect_delay_time = effect_delay_time or 0
	local begin_fun = function()
	end
	local end_fun = function()
	end
	return SkillAct.blackScreen(attacker, delay_time, time, begin_fun, end_fun)
end

--黑幕,除掉自己和目标之外黑屏
function BattleModel:blackScreen2(attacker, delay_time, time, alpha, particle_id, effect_delay_time,is_loop)
	-- print("WTF_____BattleModel:blackScreen2")
	time = time or display.DEFAULT_FPS / 4
	effect_delay_time = effect_delay_time or 0
	particle_id = particle_id or ""
	local is_loop = is_loop or TRUE
	local begin_fun = function()
		self.is_black = true
		if next(self.all_object or {}) ~= nil and self.all_object then
			for _, v in pairs(self.all_object or {}) do
				if v and v.spine_renderer then                          
					if v.pos ~= attacker.pos then
						if keyfind("target", v.pos, attacker.attacker_info.target_list) then
							v:setBlack(true)
						else
							v:setBlack2(true)
						end
					end
				end
			end
		end
		self.battle_scene:setBlack(true, alpha)
	end
	local end_fun = function()
	end
	return SkillAct.blackScreen(attacker, delay_time, time, begin_fun, end_fun)
end

--第四种黑幕,自己和目标以外的人都变黑
function BattleModel:blackScreen4(attacker, delay_time, time, alpha, particle_id, effect_delay_time, is_loop)
	-- print("WTF_____BattleModel:blackScreen4")
	time = time or display.DEFAULT_FPS / 4
	effect_delay_time = effect_delay_time or 0
	particle_id = particle_id or ""
	local is_loop = is_loop or TRUE
	local begin_fun = function()
		self.is_black = true
		if next(self.all_object or {}) ~= nil and self.all_object then
			for _, v in pairs(self.all_object or {}) do
				if v and v.spine_renderer then                          
					if v.pos ~= attacker.pos then
						if not keyfind("target", v.pos, attacker.attacker_info.target_list) then
							v:setBlack(true)
						end
					end
				end
			end
		end
		self.battle_scene:setBlack(true, alpha)
	end
	local end_fun = function()
	end
	return SkillAct.blackScreen(attacker, delay_time, time, begin_fun, end_fun)
end

-- 第三种黑幕，不加深任何人
function BattleModel:blackScreen3( attacker, delay_time, time, alpha )
	return cc.CallFunc:create(function() end)
	--[[
	print("WTF_____BattleModel:blackScreen3")
	print(debug.traceback())
	time = time or display.DEFAULT_FPS / 4
	local begin_fun = function()
		self.is_black = true
		self.battle_scene:setBlack(true, alpha)
	end
	local end_fun = function()
	end
	return SkillAct.blackScreen(attacker, delay_time, time, begin_fun, end_fun)
	]]
end

--清除黑屏
function BattleModel:cancleBlackScreen()
	if not tolua.isnull(self.battle_scene) then
		self.battle_scene:setBlack(false)
	end
	for _, v in pairs(self.all_object or {}) do
		if v and v.spine_renderer then                          
			v:setBlack2(false)
			v:setBlack(false)
		end
	end
	self.is_black = false
end

--生成残影
function BattleModel:shadow2(attacker, time,play_order_anime_res,anima_name)
	-- print("WTF_____BattleModel:shadow2")
	-- 开始打上标记
	local shadow_num = 5      -- 影子个数
	local start_fun = function()
		local shadow_num = 5      -- 影子个数
		local speed_cut = 0.07
		local is_fix = {60,140,250,370,490}
		local alpha = {210,170,130,80,50}     -- 影子透明度递减
		local is_stand = FALSE
		attacker.spine_renderer.role_shadow_data = {num = shadow_num, speed = speed_cut, is_fix = is_fix, alpha = alpha, is_stand = is_stand}
		--分身处理
		SkillAct.createShadow(attacker.spine_renderer,(play_order_anime_res or anima_name),anima_name)
	end
	local end_fun = function()
		if attacker.spine_renderer.role_shadow_list then
			for i, v in pairs(attacker.spine_renderer.role_shadow_list or {}) do
				v:runAction(cc.Sequence:create(cc.DelayTime:create((shadow_num-i) * 0.03),cc.CallFunc:create(function()
					v:setVisible(false)
				end)))
			end
			attacker.spine_renderer.role_shadow_data = nil
		end
	end
	local act = cc.Sequence:create(cc.CallFunc:create(start_fun), cc.DelayTime:create(time / display.DEFAULT_FPS), cc.CallFunc:create(end_fun))
	attacker.spine_renderer:runAction(act)
end


--生成残影和位移
function BattleModel:shadow(attacker, delay_time, time, shadow_num, speed_cut, is_stand, is_fix, alpha)
	-- print("WTF_____BattleModel:shadow")
	-- if true then return end
	local delay_time = delay_time or 0
	local time = time or dispaly.DEFAULT_FPS / 4

	-- 开始打上标记
	local start_fun = function()
		local shadow_num = shadow_num or 4      -- 影子个数
		local speed_cut = speed_cut or 0.07     -- 影子速度削减
		local is_fix = is_fix or 40    -- 影子位置偏移
		local alpha = alpha or 80     -- 影子透明度递减
		local is_stand = is_stand or FALSE
		attacker.spine_renderer.role_shadow_data = {num = shadow_num, speed = speed_cut, is_fix = is_fix, alpha = alpha, is_stand = is_stand}
	end
	-- 结束删除残影
	local end_fun = function()
		if attacker.spine_renderer.role_shadow_list then
			for _, v in pairs(attacker.spine_renderer.role_shadow_list or {}) do
				v:setVisible(false)
			end
			attacker.spine_renderer.role_shadow_data = nil
		end
	end
	end_fun()
	return SkillAct.shadow(attacker, delay_time, time, start_fun, end_fun)
end

--创建战斗人物
--@param data:战斗人物列表
function BattleModel:createBattleRole(data)
	if not data then return end
	if data.combat_type ~= self.fight_type then return end
	if tolua.isnull(self.battle_scene) then return end

	--创建角色
	data.objects = self:checkNeddAddElfinData(data.objects)
	local _render = RenderMgr:getInstance()
	for i, v in ipairs(data.objects or {}) do
		_render:doNextFrame(function() 
			self:addBattleRole(v, self.fight_type, data.current_wave, data.total_wave)
		end)
	end
end

-- 判断是否要添加精灵的单位数据(如果携带了神器，但是没携带精灵，也要显示精灵的UI)
function BattleModel:checkNeddAddElfinData( objects )
	if not objects then return {} end
	local a_is_have_hallows = false
	local a_is_have_elfin = false
	local b_is_have_hallows = false
	local b_is_have_elfin = false
	for k,v in pairs(objects) do
		if v.group == 1 and v.object_type == BattleObjectType.Hallows then
			a_is_have_hallows = true
		elseif v.group == 1 and v.object_type == BattleObjectType.Elfin then
			a_is_have_elfin = true
		elseif v.group == 2 and v.object_type == BattleObjectType.Hallows then
			b_is_have_hallows = true
		elseif v.group == 2 and v.object_type == BattleObjectType.Elfin then
			b_is_have_elfin = true
		end
	end
	if a_is_have_hallows and not a_is_have_elfin then
		local a_elfin_data = {
			object_type = 5,
			pos = 41,
			group = 1,
			fight_type = self.fight_type,
			hp = 1,
			hp_max = 1,
		}
		table.insert(objects, 1, a_elfin_data)
	end
	if b_is_have_hallows and not b_is_have_elfin then
		local b_elfin_data = {
			object_type = 5,
			pos = 42,
			group = 2,
			fight_type = self.fight_type,
			hp = 1,
			hp_max = 1,
		}
		table.insert(objects, 1, b_elfin_data)
	end
	return objects
end

-- 加载资源
function BattleModel:waitLoadBattleResources(data)
	if not data then return end
	if data.combat_type ~= self.fight_type then return end
	if tolua.isnull(self.battle_scene) then return end
	--modified by chenbin:不再需要根据技能加载特效
	-- for i, v in pairs(data.objects or {}) do
	-- 	self:addSpineBySkill(v.skills, v.object_bid, v.object_type, v.star)
	-- end
	self:addSpineRes()
end

--添加/复活角色
--param data:角色信息数据
function BattleModel:addBattleRole(data, combat_type, current_wave, total_wave,is_next,is_spec_add)
	if BattleConst.canDoBattle(data.fight_type) then
		local role = BattleRole.New(data, combat_type, current_wave, total_wave,is_next)
		if not is_next and not is_spec_add and next(self.all_object or {}) ~= nil and self.all_object and self.all_object[role.pos]  then
			local delete_role  = self.all_object[role.pos]
			if delete_role then
				if delete_role.tips_list then
					delete_role.tips_list = {}
				end
				if delete_role.spine_renderer and not tolua.isnull(delete_role.spine_renderer.root) then
					-- delete_role.spine_renderer:realrelease(true)
					delete_role.spine_renderer:cleanAllBuffIcon(delete_role.buff_list)
					SkillAct.clearAllEffect(role.spine_renderer)
				end
				self.all_object[role.pos] = nil
			end
		end
		-- if next(self.all_object or {}) ~= nil and self.all_object then
		if self.all_object then
			self.all_object[role.pos] = role
		end
	end
end

--角色出场准备好了
function BattleModel:roleReady(role)
	if self.all_object and not self.all_object[role.pos] then
		self.all_object[role.pos] = role
	end
end

--更新重连buff添加
function BattleModel:reconnectBuff(force)
	if not force and self.is_first == true then
		return
	end
	if self.buffs ~= nil then
		for _, buff in pairs(self.buffs or {}) do
			local buff_data = nil
			if Config.SkillData.data_get_buff[buff.buff_bid] then
				buff_data = Config.SkillData.data_get_buff[buff.buff_bid]
			end
			if buff_data ~= nil then
				if next(self.all_object or {}) ~= nil and self.all_object then
					local target = self.all_object[buff.target]
					self:playRoundBuff(target, buff)
					self.is_first = true
				end
			end
		end
	else
		self.act_after_effect_list = {}
	end
end


local TIME_OUT_DUR = 20
--动作开始
function BattleModel:actStart(attacker)
	if self:isFinish() then return end
	if self.battle_controller:getExtendFightType() == self.battle_controller:getCurFightType() or  self.battle_controller:getExtendFightType() == 0 then
		attacker.wait_act = attacker.wait_act + 1
		GlobalTimeTicket:getInstance():remove("attackerActTimeout" .. attacker.pos)
		GlobalTimeTicket:getInstance():add(function()
			self:actTimeout(attacker)
		end, TIME_OUT_DUR, 1, "attackerActTimeout".. attacker.pos)
	end
end

--动作超时
function BattleModel:actTimeout(attacker)
	print("WTF___timeout______", attacker.object_name)
	dump(attacker)
	attacker.wait_act = 1
	self:actFinish(attacker)
end

--动作结束
function BattleModel:actFinish(attacker)
	-- if attacker.object_type == 2 then
	-- 	print("WTF__actFinish_____",attacker.object_name)
	-- 	print(debug.traceback())
	-- end
	if  self.battle_controller:getExtendFightType() == self.battle_controller:getCurFightType() or self.battle_controller:getExtendFightType() == 0 then
		if attacker.wait_act > 0 then
			attacker.wait_act = attacker.wait_act - 1
			if attacker.wait_act == 0 then
				if not self.battle_controller:getIsNoramalBattle() then
					self:playOrder(attacker)
				else
					if self.battle_controller:getNormalModel() then
						self.battle_controller:getNormalModel():playOrder(attacker)
					end
				end
				GlobalTimeTicket:getInstance():remove("attackerActTimeout" .. attacker.pos)
			end
		end
	end
end
--用于添加其他副本新增UI在战斗界面的接口
--@param view:需要添加额外的view
function BattleModel:addExternView(view, x, y)
	x = x or SCREEN_WIDTH / 2
	y = y or SCREEN_HEIGHT / 2
	if self.battle_controller:getBattleStatus() and not tolua.isnull(self.battle_scene) then
		self.battle_scene:addExternView(view, x, y)
	end
end

--构建单个action,兼容muti
function BattleModel:singleAct(index, attacker)
	local act
	local acts = {}
	if type(index) == "table" then
		return self:mutiAct(index, attacker)
	else
		local args = Config.SkillData.data_get_act_data[index].act_args
		local funname = args[1]

		if funname == nil or self[funname] == nil then return end
		if type(self[funname]) == "function" then
			args[2] = args[2] or {0}

			----add by chenbin: test
			-- local anima_name = attacker.anime_user_atk
			-- if anima_name == nil or anima_name == "" then
			-- 	print("Error:Wrong Anim Name:", anima_name)
			-- 	print("Check data_get_effect -> ", attacker.play_order_index)
			-- 	print(debug.traceback())
			-- end
			-----------------

			return self[funname](self, attacker, unpack(args[2]))
		else
			error(string.format("动作错误,动作bid:%s"), index)
		end
	end
end

--构建并行act
function BattleModel:mutiAct(args, attacker)
	local act
	local acts = {}
	for _, arg in ipairs(args or {}) do
		act = self:singleAct(arg, attacker)
		table.insert(acts, act)
	end
	return cc.Spawn:create(unpack(acts))
end
---------------------------------------------
--对目标位置、中心点、子弹移动时间
---------------------------------------------
--计算目标位置,拿第一个目标作为目标
function BattleModel:calcTargetPos(attacker,object)
	local target
	local all_object = object or self.all_object
	if next(all_object or {}) ~= nil and all_object then
		--遍历查找目标
		for _, v in ipairs(attacker.attacker_info.target_list or {}) do
			target = all_object[v.target] --寻找目标位置
			if target and target.obj_type ~= attacker.obj_type then
				break;
			end
		end
		if target then
			attacker.target_pos = {x = target.grid_pos.x, y = target.grid_pos.y}
			attacker.target_pos_base = {x = target.grid_pos.x, y = target.grid_pos.y}
			attacker.target_name = target.object_name or ""
			attacker.target_type = target.obj_type
		end
	end
end

--计算中间点位置
-- 计算中心点
function BattleModel:center_pos(attacker, height_fix, just_grid)
	height_fix = height_fix or 0
	local xsum, ysum, num, xsum2, ysum2, num2,xsum3,ysum3,num3
	xsum, ysum, num, xsum2, ysum2, num2, xsum3, ysum3, num3 = 0, 0, 0, 0, 0, 0, 0, 0, 0
	local target_height = 0
	local target_width = 0

	if next(self.all_object or {}) ~= nil and self.all_object then
		for _, v in ipairs(attacker.attacker_info.target_list or {}) do
			local target = self.all_object[v.target]
			if target then
				target_height = target.height or 0
				target_width = target.width or 0
			end
			if target then
				if target.group ~= attacker.group then                              -- 敌方
					num2 = num2 + 1
					xsum2 = xsum2 + target.grid_pos.x
					ysum2 = ysum2 + target.grid_pos.y + height_fix * target_height / 100 / gridSizeY()
				else                                                                -- 友方
					num3 = num3 + 1
					xsum3 = xsum3 + target.grid_pos.x
					ysum3 = ysum3 + target.grid_pos.y + height_fix * target_height / 100 / gridSizeY()
				end
			end
		end
	end
	local pos
	if xsum == 0 and ysum == 0 or just_grid then
		if num2 == 0 then       -- 没有敌人的时候，例如加血
			pos = {x = xsum3 / num3, y = ysum3 / num3}
		else                    -- 敌方
			pos = {x = xsum2 / num2, y = ysum2 / num2}
		end
	else                        -- 扣血或者加血，可能包含了友方 -- 15-5-11 扣血的时候去掉友方
		if num2 == 0 then
			pos = {x = xsum / num, y = ysum / num}
		else
			pos = {x = xsum2 / num2, y = ysum2 / num2}
		end
	end
	if just_grid then
		return pos
	else
		return gridPosToScreenPos(pos)
	end
end

-- 计算移动时间
function BattleModel:calcMoveTime(attacker, list, is_back)
	if #list == 1 then
		if is_back then
			return {1, 0.5, 0.55}
		else
			return {1, 1}
		end
	end
	local time_list = {}
	local sum = 0
	local start_pos = cc.p(attacker.spine_renderer.root:getPosition())
	for i = 1, #list do
		time_list[i + 1] = math.pow(math.pow(math.abs(list[i].x - start_pos.x), 2) + math.pow(math.abs(list[i].y - start_pos.y), 2), 0.5)
		sum = sum + time_list[i + 1]
		start_pos = list[i]
	end
	if is_back then
		local back_pos = cc.p(attacker.spine_renderer.root:getPosition())
		time_list[#list + 2] = math.pow(math.pow(math.abs(start_pos.x - back_pos.x), 2) + math.pow(math.abs(start_pos.y - back_pos.y), 2), 0.5)
		sum = sum + time_list[#list + 2]
	end
	time_list[1] = sum
	return time_list
end

---------------------------------------------
--战斗动作,具体实现在skiil_act,这里只计算一些参数
---------------------------------------------
function BattleModel:moveTo(attacker, delay_time, move_time, grid_pos_x, grid_pos_y, action_name, is_jump, is_jump_delay, is_get_point, is_move, is_reverse, is_col_act)
	-- print("WTF_____BattleModel:moveTo")
	if not attacker then
		return
	end

	--add by chenbin:如果目标是友军，在原地释放
	if attacker.obj_type == attacker.target_type then
		return cc.CallFunc:create(function() end)
	end


	move_time = move_time or display.DEFAULT_FPS / 2
	grid_pos_x = grid_pos_x or 0
	grid_pos_y = grid_pos_y or 0
	action_name = action_name
	local is_jump_delay = is_jump_delay or 0
	local anime_res = attacker.anime_res
	is_reverse = is_reverse == TRUE
	local direct = is_reverse and - 1 or 1
	local is_move = is_move or 1

	local is_get_point = is_get_point or 0
	local target_pos
	if is_col_act == TRUE then -- 列动作特殊处理
        local is_left = (self:changeGroup(attacker.group) == BattleGroupTypeConf.TYPE_GROUP_ROLE) --
		local pos = {x = 0,y = 0}
		if is_left == true then
			local temp_list = {{x=34,y=15},{x=34,y=21},{x=34,y=27}}
			pos = temp_list[attacker.col]		
		else
			local temp_list = {{x=44,y=15},{x=44,y=21},{x=44,y=27}}
			pos = temp_list[attacker.col]
		end
		if pos then
			grid_pos_y = 0
            local screen_pos = gridPosToScreenPos(pos)
			target_pos = {x = screen_pos.x + grid_pos_x * attacker.obj_type * direct, y = screen_pos.y + grid_pos_y}
		end
	elseif grid_pos_x > 0 then
		target_pos = gridPosToScreenPos({x = attacker.grid_pos.x + grid_pos_x * attacker.obj_type * direct, y = attacker.grid_pos.y + grid_pos_y * attacker.obj_type * direct})
	else
		if is_reverse and attacker.target_pos_base then      -- 反转的用角色身后的来计算
			target_pos = gridPosToScreenPos({x = attacker.target_pos_base.x + grid_pos_x * attacker.obj_type * direct, y = attacker.target_pos_base.y + grid_pos_y * attacker.obj_type * direct})
		else
			target_pos = gridPosToScreenPos({x = attacker.target_pos.x + grid_pos_x * attacker.obj_type * direct, y = attacker.target_pos.y + grid_pos_y })
			local is_left = (self:changeGroup(attacker.group) == BattleGroupTypeConf.TYPE_GROUP_ROLE)
			if is_left then
				target_pos.x = target_pos.x - 200
			else
				target_pos.x = target_pos.x + 200
			end
		end
	end
	if is_get_point == 0 then --这个用于move点的时候应用
		local skill_act = SkillAct.MoveTo(attacker, attacker.spine_renderer, action_name, - attacker.obj_type, target_pos, delay_time, move_time, is_reverse, is_jump, is_jump_delay)
		attacker.spine_renderer:runAction(skill_act)
	else
		return SkillAct.MoveTo(attacker, attacker.spine_renderer, action_name, - attacker.obj_type, target_pos, delay_time, move_time, is_reverse, is_jump, is_jump_delay)
	end

end

--移动回来
function BattleModel:moveBack(attacker, delay_time, move_time, grid_pos_x, action_name, is_jump, is_jump_delay, is_get_point, is_move, is_reverse)
	-- print("WTF_____BattleModel:moveBack")
	action_name = action_name
	local anime_res = attacker.anime_res
	if is_reverse == nil then
		is_reverse = TRUE
	end
	grid_pos_x = grid_pos_x or 0
	move_time = move_time or display.DEFAULT_FPS / 2
	local is_jump_delay = is_jump_delay or 0
	local is_move = is_move or 1
	local is_get_point = is_get_point or 0
	local target_pos
	if grid_pos_x > 0 then
		target_pos = gridPosToScreenPos({x = attacker.target_pos.x - grid_pos_x * attacker.obj_type, y = attacker.target_pos.y})
	else
		target_pos = gridPosToScreenPos({x = attacker.grid_pos.x + grid_pos_x * attacker.obj_type, y = attacker.grid_pos.y})
	end
	if is_get_point == 0 then --这个用于move点的时候应用
		local skill_act = SkillAct.moveBack(attacker, attacker.spine_renderer, action_name, attacker.obj_type, target_pos, delay_time, move_time, is_reverse, is_jump, is_jump_delay)
		if attacker.spine_renderer.root and not tolua.isnull(attacker.spine_renderer.root) then
			attacker.spine_renderer:runAction(skill_act)
		end
	else
		return SkillAct.moveBack(attacker, attacker.spine_renderer, action_name, attacker.obj_type, target_pos, delay_time, move_time, is_reverse, is_jump, is_jump_delay)
	end
end

--渐出
function BattleModel:fadeOut(attacker, delay_time, time)
	-- print("WTF_____BattleModel:fadeOut")
	time = time or dispaly.DEFAULT_FPS / 2
	return SkillAct.fadeOut(attacker, attacker.spine_renderer, delay_time, time)
end

--渐入
function BattleModel:fadeIn(attacker, delay_time, time)
	-- print("WTF_____BattleModel:fadeIn")
	time = time or display.DEFAULT_FPS / 2
	return SkillAct.fadeIn(attacker, attacker.spine_renderer, delay_time, time)
end

--震动屏幕
function BattleModel:shakeScreen(attacker, delay_time, shake_bid)
	-- print("WTF_____BattleModel:shakeScreen")
	return SkillAct.shakeScreen(attacker, delay_time, shake_bid)
end

--单次attack
function BattleModel:attack(attacker, delay_time, hit_fun, start_fun, is_reverse)
	local anima_name = attacker.anime_user_atk
	local anime_res = attacker.anime_res

	local delay_time = delay_time or 0
	local start_callback = function()
		self:callfun(attacker, start_fun)
	end
	local hit_callback = function()
		self:callfun(attacker, hit_fun)
	end
	is_reverse = is_reverse == TRUE
	-- print("WTF____hehe_______",anima_name, anime_res)
	-- dump(attacker)
	--add by chenbin
	if anima_name == "" then
		--modified by chenbin
		anima_name = "attack"
	end
	----------
	return SkillAct.attack(attacker, delay_time, anima_name, hit_callback, start_callback, is_reverse, nil, anime_res)
end

--无动作攻击
function BattleModel:noActAttack(attacker, delay_time, hit_fun, start_fun, next_delay_time)
	print("WTF_____noActAttack____")
	local start_callback = function()
		self:callfun(attacker, start_fun)
	end
	local hit_callback = function()
		self:callfun(attacker, hit_fun)
	end
	return SkillAct.noActAttack(attacker, delay_time, hit_callback, start_callback, next_delay_time)
end

--准备动作
function BattleModel:ready(attacker, action_name, is_reverse)
end

-- 隐身
function BattleModel:hide(attacker, delay_time)
	-- print("WTF_____BattleModel:hide")
	return SkillAct.hide(attacker, delay_time)
end

-- 显示
function BattleModel:show(attacker, delay_time)
	-- print("WTF_____BattleModel:show")
	return SkillAct.show(attacker, delay_time)
end

--显示UI接口
function BattleModel:showUI(attacker, delay_time)
	-- print("WTF_____BattleModel:showUI")
	return SkillAct.showUI(attacker, delay_time)
end

--隐藏UI接口
function BattleModel:hideUI(attacker, delay_time)
	-- print("WTF_____BattleModel:hideUI")
	return SkillAct.hideUI(attacker, delay_time)
end

--跳跃接口
function BattleModel:jump(attacker, delay_time, height, jump_time, target_pos, times)
	local height = height or 200
	jump_time = jump_time or DEFAULT_FPS / 2
	times = times or 1
	target_pos = target_pos or cc.p(attacker.spine_renderer.root:getPosition())
	return SkillAct.jump(attacker, delay_time, jump_time, target_pos, height, times)
end

--远程子弹
function BattleModel:item(attacker, delay_time, effect_name, move_time, is_back, funname, start_height, target_pos, scale, is_offset_angle, bid, x_fix, height, is_shadow, shadow_data)
	local start_height =(start_height or 0) * attacker.height / 100
	move_time = move_time or display.DEFAULT_FPS / 2
	local hit_callback = function()
		self:callfun(attacker, funname)
		if #attacker.attacker_info.target_list > 1 then
			table.remove(attacker.attacker_info.target_list, 1)
		end
	end
	-- 假战斗不需要远程子弹.只需要播放动作就好了
	if self.battle_controller:getIsNoramalBattle() then
		hit_callback()
	else
		local time_arg = {}
		time_arg.time_list = self:calcMoveTime(attacker, target_pos, is_back)
		time_arg.time_all = move_time
		time_arg.delay_time = delay_time
		attacker.spine_renderer:runAction(SkillAct.flyItem(attacker, attacker.spine_renderer, attacker.obj_type, target_pos, time_arg, effect_name, is_back, hit_callback, start_height, tail_effect, scale, is_offset_angle, bid, x_fix, height, is_shadow, shadow_data))
	end
end

--远程攻击
function BattleModel:flyItem(attacker, delay_time, move_time, is_bcak, funname, start_height, pos, is_shadow, shadow_opacity, shadow_offset, shadow_num, is_reverse)
	if not attacker or attacker.play_order_index == nil then return end
	local effect_list = attacker.trc_effect_list
	local anime_res_up, anime_res_down, scale, x_fix, y_fix, alpha, h_scale, bid = "", "", 1, 0, 0, 255, 1, 0
	local height = 50
	local group = self:checkGroup(attacker.group)
	if next(effect_list or {}) ~= nil then
		for _, v in pairs(effect_list or {}) do
			if v.spec_res_up ~= "" then
				if group == BattleGroupTypeConf.TYPE_GROUP_ROLE then
					anime_res_up = v.spec_res_up or nil
				elseif group == BattleGroupTypeConf.TYPE_GROUP_ENEMY then
					anime_res_up = v.res_up or nil
				end
			else
				anime_res_up = v.res_up or nil
			end
			anime_res_down = v.res_down or nil
			scale = v.scale * 0.001
			x_fix =(v.x_fix or 0) * attacker.obj_type
			alpha = 255
			h_scale = v.h_scale or 1
			bid = v.bid
			if v.y_fix == 0 then
				height = 50
			else
				height = v.y_fix or 50
			end
		end
	end
	is_shadow = is_shadow or TRUE
	local shadow_data = {}
	shadow_data.shadow_num = shadow_num
	shadow_data.shadow_offset = shadow_offset
	shadow_data.shadow_opacity = shadow_opacity
	local is_back = nil
	local is_reverse = is_reverse == TRUE
	local is_offset_angle =  0
	local anima_name = attacker.anime_user_atk --攻击动作资源
	local anima_res = attacker.anime_res --攻击动作资源
	if anima_name == "" then
		--modified by chenbin
		-- anima_name = "action2"
		anima_name = "attack"
	end
	local target_pos 
	local attack_func = function()
		target_pos = {self:center_pos(attacker, height)}
		if #attacker.attacker_info.target_list <= 1 then
			return self:item(attacker, delay_time, anime_res_up, move_time, is_back, funname, start_height, target_pos, scale, is_offset_angle, bid, x_fix, height, is_shadow, shadow_data)
		else
			local is_first = true
			local act_start = SkillAct.normalStart(attacker)
			local act_list = {}
			self:playSelfEffect(attacker)
			for _, target_list in pairs(attacker.attacker_info.target_list or {}) do
				if next(self.all_object or {}) ~= nil and self.all_object then
					local target = self.all_object[target_list.target]
					if target then
						target_pos = cc.p(target.screen_pos.x, target.screen_pos.y)
						target_pos.y = target_pos.y + height
						if target.group ~= attacker.group then
							local func = self:item(attacker, delay_time, anime_res_up, move_time, is_back, "hurtOne", start_height, {target_pos}, scale, is_offset_angle, bid, x_fix, height, is_shadow, shadow_data)
							table.insert(act_list, func)
						end
					end
				end
			end
			local finish_func = cc.CallFunc:create(function()
				for _, target_list in pairs(attacker.attacker_info.last_effect or {}) do
					if not self.battle_controller:getIsNoramalBattle() then
						self:playMagic(attacker, target_list)
					else
						self.battle_controller:getNormalModel():playMagic(attacker, target_list)
					end
					
				end
			end)
			if #act_list > 0 then
				attacker.spine_renderer:runAction(cc.Sequence:reate(act_start, cc.Spawn:create(unpack(act_list)), finish_func, SkillAct.normalFinish(attacker)))
			else
				attacker.spine_renderer:runAction(cc.Sequence:create(act_start, finish_func, SkillAct.normalFinish(attacker)))
			end
		end
	end
	--add by chenbin : 现在远程技能不会飞出子弹，回调后直接造成伤害
	local hit_callback = function()
		self:callfun(attacker, funname)
		if #attacker.attacker_info.target_list > 1 then
			table.remove(attacker.attacker_info.target_list, 1)
		end
	end
	-- print("WTF___flyItem____")
	return SkillAct.attack(attacker, 0, anima_name, hit_callback, nil, is_reverse, attack_func, anima_res)
end

--- BattleModel:attackPoint 播放攻击特效
-- @param attacker Describe the parameter
function BattleModel:attackPoint(attacker)
	-- 播放音效
	if attacker.attack_sound and attacker.attack_sound ~= "" then
		if not self.battle_controller:getIsNoramalBattle() then
			AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.BATTLE, attacker.attack_sound, false)
		end
	end

	--TODO:modified by chenbin
	if true then return end

	-- 播放攻击点特效
	if attacker.act_effect_list and next(attacker.act_effect_list) ~= nil then
		local group = self:checkGroup(attacker.group)
		for _, v in pairs(attacker.act_effect_list) do
			local anime_res_up = ""
			local anime_res_down = ""
			if v.play_type == BattleEffectPlayType.ROLE then
				if v.spec_res_up ~= "" then
					if group == BattleGroupTypeConf.TYPE_GROUP_ROLE then
						anime_res_up = v.spec_res_up
					elseif group == BattleGroupTypeConf.TYPE_GROUP_ENEMY then
						anime_res_up = v.res_up
					end
				else
					anime_res_up = v.res_up
				end
				anime_res_down = v.res_down
				if anime_res_up ~= "" or anime_res_down ~= "" then
					self:effectSpineUser(attacker, 0, TRUE, v.x_fix * attacker.obj_type, v.y_fix, {anime_res_up, anime_res_down}, nil, v.scale * 0.001, 255, v.h_scale, nil, v.bid, nil, true)
				end
			end
		end
	end
end

--攻击准备动作
function BattleModel:attackReady(attacker)
    attacker.spine_renderer:showHallowsState(false)
	-- 播放发起点音效
	if attacker.ready_sound and attacker.ready_sound ~= "" then
		if not self.battle_controller:getIsNoramalBattle() then 
			AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.BATTLE, attacker.ready_sound, false)
		end
	end


	-- --TODO:modified by chenbin
	if true then return end

	-- 播放特效
	if attacker.bact_effect_list and next(attacker.bact_effect_list) ~= nil then
		for _, v in pairs(attacker.bact_effect_list) do
			if v.res_up ~= "" or v.res_down ~= "" then
				if v.play_type == BattleEffectPlayType.ROLE then
					self:effectSpineUser(attacker, 0, TRUE, v.x_fix * attacker.obj_type, v.y_fix, {v.res_up, v.res_down}, nil, v.scale * 0.001, 255, v.h_scale, nil, v.bid)
				elseif v.play_type == BattleEffectPlayType.ENEMY_SCENE or v.play_type == BattleEffectPlayType.ROLE_SCENE then
					self:effectArea(attacker, {v.res_up, v.res_down}, 0, TRUE, nil, v.play_type, v.x_fix, v.y_fix, v.bid, v.is_col_effect, false)
				end
			end
		end
	end
end

--处理友方效果
function BattleModel:playSelfEffect(attacker)
	local last_effect, target = {}
	for _, effect_play in ipairs(attacker.attacker_info.target_list or {}) do
		if next(self.all_object or {}) ~= nil and self.all_object then
			target = self.all_object[effect_play.target]
			if target and attacker.group == target.group then
				table.insert(last_effect, effect_play)
			end
		end
	end
	attacker.attacker_info.effect_play = last_effect
	attacker.attacker_info.last_effect = last_effect
end

--跟随人物特效
function BattleModel:effectSpineUser(attacker, delay_time, is_release, x_fix, height, effect_name, spine_renderer, scale, alpha, h_scale, callback, buff_bid, effect_bid, is_attack, object_type)	
	local is_release = is_release or TRUE
	spine_renderer = spine_renderer or attacker.spine_renderer
	if is_attack == true then
		if height == 0 then
			height = 50
		end
		height = height * 0.01 * spine_renderer.role_height
	else
		if height == 0 then
			height = spine_renderer.role_height - 15 or 0
		end
	end
	local effect_name = effect_name
	local obj_type = BattleTypeConf.TYPE_ROLE
	if attacker ~= nil then
		obj_type = attacker.obj_type
	end
	if object_type ~= nil then --这个主要是用于buff的目标
		obj_type = object_type
	end

	-- 这个要特殊处理.如果是0,则地方在反转一次
	if scale == 0 then
		scale = 1
		obj_type = 1
	end
	SkillAct.effectSpineUser(attacker, delay_time, spine_renderer, effect_name, obj_type, is_release, height, x_fix, scale, alpha, h_scale, nil, buff_bid, effect_bid)
end

-- 范围特效
function BattleModel:effectArea(attacker, effect_name, height, is_release, hit_callback, play_type, x_fix, y_fix, bid, is_col_effect, is_effect_play, group)
	local delay_time = 0
	effect_name = effect_name
	height = height or 0
	local reverse = attacker.obj_type
	local grid_pos
	local is_left = (self:changeGroup(attacker.group) == BattleGroupTypeConf.TYPE_GROUP_ROLE) --
	if is_col_effect == TRUE then
		local pos = {x = 0,y = 0}
		if is_left == true then
			local temp_list = {{x=34,y=17},{x=34,y=23},{x=34,y=29}}
			pos = temp_list[attacker.col]		
		else
			local temp_list = {{x=44,y=17},{x=44,y=23},{x=44,y=29}}
			pos = temp_list[attacker.col]
		end
		if pos then
            local screen_pos = gridPosToScreenPos(pos)
			grid_pos = {x = screen_pos.x + x_fix,y = screen_pos.y + y_fix}
		end
	else
		if play_type == BattleEffectPlayType.SCENE then
			grid_pos = {x = SCREEN_WIDTH / 2, y = SCREEN_HEIGHT / 2}
		elseif play_type == BattleEffectPlayType.ROLE_SCENE or play_type == BattleEffectPlayType.ENEMY_SCENE then  --在己方或者对方5号位置播放特效
			if self.battle_controller:getIsNoramalBattle() then
				is_left = (attacker.group == BattleGroupTypeConf.TYPE_GROUP_ROLE)
			end
			x_fix = attacker.obj_type * x_fix
			if is_left == true then --施法者位于左边的时候
				if play_type == BattleEffectPlayType.ROLE_SCENE then --友方阵型
					grid_pos = {x = SCREEN_WIDTH * 22 / 100 + x_fix, y = SCREEN_HEIGHT * 1 / 4 + y_fix}
				else --地方阵营
					grid_pos = {x = SCREEN_WIDTH * 78 / 100 + x_fix, y = SCREEN_HEIGHT * 1 / 4 + y_fix}
				end
			else
				if play_type == BattleEffectPlayType.ENEMY_SCENE then
					grid_pos = {x = SCREEN_WIDTH * 22 / 100 + x_fix, y = SCREEN_HEIGHT * 1 / 4 + y_fix}
				else
					grid_pos = {x = SCREEN_WIDTH * 78 / 100 + x_fix, y = SCREEN_HEIGHT * 1 / 4 + y_fix}
				end
			end
		else
			grid_pos = self:center_pos(attacker)
		end
	end
	grid_pos.y = grid_pos.y + height
	SkillAct.effectArea(attacker, effect_name, reverse, is_release, grid_pos, hit_callback, bid, is_effect_play, group)
end

--移动到敌方一个区域
function BattleModel:moveToArea(attacker, delay_time, move_time, grid_pos_x, grid_pos_y, action_name, is_jump, is_jump_delay, is_get_point, is_move, is_reverse)
	if not attacker then
		return
	end
	move_time = move_time or display.DEFAULT_FPS / 2
	action_name = action_name
	local anime_res = attacker.anime_res
	is_reverse = is_reverse == TRUE
	local direct = is_reverse and - 1 or 1
	local is_move = is_move or 1
	local is_get_point = is_get_point or 0
	local target_pos
	grid_pos_x = grid_pos_x * gridSizeX() or 0
	grid_pos_y = grid_pos_y * gridSizeY() or 0
	local is_left = (self:changeGroup(attacker.group) == BattleGroupTypeConf.TYPE_GROUP_ROLE) --
	if self.battle_controller:getIsNoramalBattle() then
		is_left = (attacker.group == BattleGroupTypeConf.TYPE_GROUP_ROLE)
	end
	if is_left == true then --施法者位于左边的时候
		target_pos = {x = SCREEN_WIDTH * 32 / 64 + grid_pos_x * attacker.obj_type, y = SCREEN_HEIGHT * 11 / 36 + grid_pos_y}
	else
		target_pos = {x = SCREEN_WIDTH * 32 / 64 + grid_pos_x * attacker.obj_type, y = SCREEN_HEIGHT * 11 / 36 + grid_pos_y}
	end
	if is_get_point == 0 then --这个用于move点的时候应用
		local skill_act = SkillAct.MoveTo(attacker, attacker.spine_renderer, action_name, - attacker.obj_type, target_pos, delay_time, move_time, is_reverse, is_jump, is_jump_delay)
		attacker.spine_renderer:runAction(skill_act)
	else
		return SkillAct.MoveTo(attacker, attacker.spine_renderer, action_name, - attacker.obj_type, target_pos, delay_time, move_time, is_reverse, is_jump, is_jump_delay)
	end
end

--==============================--
--desc:批次处理攻击,
--time:2018-07-25 07:49:51
--@return 
--==============================--
function BattleModel:batchPlayHurt(attacker, can_die)
	if attacker == nil or attacker.attacker_info == nil or attacker.attacker_info.target_list == nil then return end
	local target_list = attacker.attacker_info.target_list
	if next(target_list) == nil then return end
	local battle_controller = BattleController:getInstance()
	local battle_normal_model = battle_controller:getNormalModel()
	local had_play = false
	for i, effect_list in ipairs(target_list or {}) do
		if not battle_controller:getIsNoramalBattle() then
			local play_effect = false
			if effect_list.hp_changed and effect_list.hp_changed < 0 and had_play == false then
				had_play = true
				play_effect = true
			end
			-- if attacker.play_order_index == 5261003 or attacker.play_order_index == 5261002 or attacker.play_order_index == 5261001 then  -- 特殊处理,这类的群攻要一个一个播受击
			-- 	local delay_time = battle_controller:getActTime("machine_speed") or 0.2
			-- 	delayOnce(function() 
			-- 		self:playMagic(attacker, effect_list, can_die, true) 
			-- 	end, (i-1)*delay_time)
			-- else
				-- print("self:playMagic")
				self:playMagic(attacker, effect_list, can_die, play_effect) 
			-- end
		else
			battle_normal_model:playMagic(attacker, effect_list, can_die) 
		end
	end
end

--专门用来播放攻击动作
function BattleModel:actHurt(attacker, is_big)
	local had_play = false
	for i, effect_list in ipairs(attacker.attacker_info.target_list or {}) do
		local play_effect = false
		if effect_list.hp_changed and effect_list.hp_changed < 0 and had_play == false then
			had_play = true
			play_effect = true
		end
		self:playMagic2(attacker, effect_list, is_big, play_effect)
	end
end

--提前播放受击特效或者只播放受击动作
function BattleModel:playMagic2(attacker, effect_play, is_big, play_effect)
	if next(self.all_object or {}) ~= nil and self.all_object then
		local target = self.all_object[effect_play.target]
		if target and target.spine_renderer then
			if is_big == true then
				if not target.is_big_play then
					target.is_big_play = true
					self:playHurtEffect(attacker, target)
				end
			else
				if attacker.pos ~= target.pos and attacker.group ~= target.group then
					SkillAct.hurt(attacker, target.spine_renderer, target, "hurt", play_effect)
				end
			end
		end
	end
end

--==============================--
--desc:播放群攻
--time:2018-07-25 03:01:59
--@attacker:
--@return 
--==============================--
function BattleModel:areaHurt(attacker)
	local hurt_fun = function()
		self.is_shake = false
		local hit_num = not attacker.in_area_effect and attacker.spine_renderer.hit_num or attacker.area_hit_num or 1
		local hit_time = not attacker.in_area_effect and attacker.spine_renderer.hit_time or attacker.area_hit_time or 0
		local can_die = (hit_num > hit_time + 1)
		if next(self.all_object or {}) ~= nil and self.all_object then
			for _, v in pairs(self.all_object or {}) do
				v.is_hurt_play = false
				v.is_big_play = false
			end
		end
		self:batchPlayHurt(attacker, can_die)
	end
	self:playSceneAreaEffect(attacker, hurt_fun)
end

--伤害
function BattleModel:hurt(attacker,object)
	local all_object = object or self.all_object
	local time =  1
	local hurt_fun = function()
		self.is_shake = false
		local hit_num = not attacker.in_area_effect and attacker.spine_renderer.hit_num or attacker.area_hit_num or 1
		local hit_time = not attacker.in_area_effect and attacker.spine_renderer.hit_time or attacker.area_hit_time or 0
        local split_hurt = attacker.spine_renderer.split_hurt or 1 -- 单次伤害拆分出来的多次伤害
		if hit_num == 1 or split_hurt > 1 then
			self:batchPlayHurt(attacker, false) 
		else --多段攻击
			local can_die = (hit_num > hit_time + 1) 
			for _, v in pairs(all_object or {}) do
				v.is_hurt_play = false
				v.is_big_play = false
			end
			self:batchPlayHurt(attacker, can_die)
		end
	end
	if next(attacker.area_effect_list) ~= nil then --为了防止群攻特效动作有hit点的时候返回
	else
		attacker.in_area_effect = false
		hurt_fun()
	end
end

--伤害一个人
function BattleModel:hurtOne(attacker)
	self.is_shake = false
	local effect_play_num = #attacker.attacker_info.target_list
	if effect_play_num > 0 then
		if not self.battle_controller:getIsNoramalBattle() then
			self:playMagic(attacker, attacker.attacker_info.target_list[1], nil, nil, false)
		else
			self.battle_controller:getNormalModel():playMagic(attacker, attacker.attacker_info.target_list[1], nil, nil, false)
		end
		
	end
end

--==============================--
--desc:播放魔法效果,这个时候到时候里面的所有的都分帧处理掉
--time:2018-07-25 03:13:08
--@attacker:施法者
--@effect_play:播报
--@no_die:是否死亡
--@play_effect:是否播放受击音效
--@return 
--==============================--
function BattleModel:playMagic(attacker, effect_play, no_die, play_effect)
	if self.battle_scene == nil or tolua.isnull(self.battle_scene) then return end	-- 主战斗场景都没有了就不需要做下面判断了
    if effect_play.play_num and effect_play.play_num <= 0 then return end -- 该播报已处理完成

    if effect_play.play_num == nil then
        effect_play.play_num = attacker.split_hurt or 1
    end

	if attacker.split_hurt > 1 then -- 需要拆分伤害效果
		local index = attacker.split_hurt - effect_play.play_num + 1
		local percent = attacker.damageSeg[index]
		-- effect_play.one_hp_change = math.ceil((effect_play.hp_changed or 0) / effect_play.play_num)
		effect_play.one_hp_change = math.ceil( (effect_play.hp_changed or 0) * percent )
		-- print("one_hp_change", effect_play.hp_changed, effect_play.play_num, effect_play.one_hp_change)
	end

    effect_play.play_num = effect_play.play_num or 1
    effect_play.play_num = effect_play.play_num - 1
	local effect_hit = 1
	local magic_hurt = false

	if  next(self.all_object or {}) ~= nil and self.all_object then
		if self.all_object == nil or effect_play.target == nil then return end
		if self.all_object and effect_play.target ~= nil and self.all_object[effect_play.target] then
			local target = self.all_object[effect_play.target]
			if target and target.spine_renderer and not tolua.isnull(target.spine_renderer.root) then
				if effect_play.is_hit == 0 or effect_play.is_blind == 1 then  --如果是躲闪
					local str = ""
					if effect_play.is_hit == 0 then
						effect_hit = 0
						str = TI18N("躲闪")
					end
					if effect_play.is_blind == 1 then
						str = TI18N("未命中")
					end
					if effect_play.is_dead == FALSE then
						if not tolua.isnull(self.battle_scene) then
							target.spine_renderer:playFontMessage(str, nil, false, self.battle_scene.effect_layer_1)
						end
					end
				end
				local hp_changed = effect_play.one_hp_change or effect_play.hp_changed or 0
				local dmg = math.floor(hp_changed)
				if effect_play.is_crit == 1 then --暴击的时候
					effect_hit = 2
				end
                local is_dead = effect_play.is_dead
                if effect_play.play_num > 0 then
                    is_dead = 0
                end
				self:updateTargetHp(attacker, target, dmg, is_dead, effect_hit, effect_play)

				--处理buff列表
				if effect_play.play_num <= 0 and next(effect_play.buff_list or {}) ~= nil then
					self:handleBufflist(attacker, effect_play.buff_list, 1)
				end

				--处理召唤列表
				if next(effect_play.summon_list or {}) ~= nil then
					self:addRoleList(effect_play.summon_list, attacker)
				end
				--处理子效果列表
				if effect_play.play_num <= 0 and next(effect_play.sub_effect_play_list or {}) ~= nil then
					self:handleSubEffectPlaylist(effect_play,attacker)
				end

				-- 特殊战斗类型判断
				self:handleExtendDungeon(effect_play)

				--如果存在援护
				if effect_play.aid_actor ~= 0 then
					self:handleAidActor(effect_play,attacker,effect_hit,target)
				end

				--播放受击动作
				self:playBattleRoleHurt(attacker, target, dmg, play_effect)
				
				-- 效果飘字
				local effect_play_effect_desc = attacker.effect_desc
				if effect_play_effect_desc ~= "" and effect_play.is_hit ~= 0 and effect_play.play_num <= 0 then
					self:showbuffName(target, effect_play_effect_desc, 229, attacker.play_order_index, true, 230)
				end
			end
		end
	end
end

--==============================--
--desc:播放受击动作
--time:2019-03-14 07:01:34
--@attacker:
--@target:
--@dmg:
--@play_effect:
--@return 
--==============================--
function BattleModel:playBattleRoleHurt(attacker, target, dmg, play_effect)
	if attacker == nil or target == nil then return end
	if target.is_hurt_play == true then return end -- 正在受击就不处理了
	target.is_hurt_play = true 
	-- 播放伤害魔法效果
	if not target.is_big_play then
		self:playHurtEffect(attacker, target)                        
	end	
	if(attacker.pos ~= target.pos and dmg <= 0) and attacker.group ~= target.group then
		local hit_action = attacker.hit_action
		if hit_action ~= "no-hurt" then
			RenderMgr:getInstance():doNextFrame(function()
				if attacker and target and target.spine_renderer and(not tolua.isnull(target.spine_renderer.root)) then
					SkillAct.hurt(attacker, target.spine_renderer, target, hit_action, play_effect)
				end
			end)
		end
	end
end

--==============================--
--desc:用于更新其他副本战斗中的数据
--time:2017-10-12 09:24:51
--@data:
--@return
--==============================--
function BattleModel:handleExtendDungeon(effect_play)
	--用于更新泰坦类型副本战斗数据
	--用于更新公会副本总伤害的
	if self.fight_type == BattleConst.Fight_Type.GuildDun or self.fight_type == BattleConst.Fight_Type.MonopolyBoss then
		self.battle_scene:addGuildBossUI(self.fight_type,effect_play.total_hurt)
	elseif self.fight_type == BattleConst.Fight_Type.YearMonsterWar or self.fight_type == BattleConst.Fight_Type.WhiteDayWar then
		self.battle_scene:updateYearUIInfo(effect_play.total_hurt)
	end
end

--==============================--
--desc:处理援助
--time:2017-10-12 09:21:55
--@effect_play:
--@attacker:
--@effect_hit:
--@return
--==============================--
function BattleModel:handleAidActor(effect_play,attacker,effect_hit,target)
	if  next(self.all_object or {}) ~= nil and self.all_object then
		if self.all_object == nil or effect_play.aid_actor == nil then return end
		local aid_target = self.all_object[effect_play.aid_actor]
		if aid_target and aid_target.spine_renderer then
			local aid_dmg = effect_play.actor_hp_changed
			local camp_restrain = effect_play.camp_restrain
			local friend_pos = cc.p(target.spine_renderer.root:getPosition())
			local role_width = target.width * target.obj_type
			aid_target.spine_renderer.root:setLocalZOrder(target.spine_renderer.root:getLocalZOrder() + 1)
			aid_target.spine_renderer:setPosByGrid(screenPosToGridPos(cc.p(friend_pos.x + role_width, friend_pos.y)))
			self:actStart(attacker);
			SkillAct.aid_hurt(attacker, aid_target.spine_renderer, aid_target, "hurt")
			if aid_dmg <= 0 then
				aid_target.hp = math.max(0, aid_target.hp + aid_dmg)
			else
				aid_target.hp = math.min(aid_target.hp_max, aid_target.hp + aid_dmg)
			end

			local per = math.min(math.max(100 * aid_target.hp / aid_target.hp_max, 0), 100)
			aid_target.spine_renderer:setHpPercent(per)
			
			if effect_play.actor_is_dead == TRUE then --and aid_target.spine_renderer.is_die == false
				aid_target:died()
			end
			target.dmg_aid_y_offset = - 40
			self:mutiHurtNum(aid_target, aid_dmg, effect_hit, false, camp_restrain)
			self:playHurtEffect(attacker, aid_target)
		end
	end
end

--==============================--
--desc:处理子效果列表
--time:2017-10-11 09:04:24
--@list:
--@return
--==============================--
function BattleModel:handleSubEffectPlaylist(effect_play,attacker)
	if  next(self.all_object or {}) ~= nil and self.all_object then
		local camp_restrain = effect_play.camp_restrain
		for i, sub_effect_play in ipairs(effect_play.sub_effect_play_list) do
			if self.all_object[sub_effect_play.sub_target]  then
				local sub_target = self.all_object[sub_effect_play.sub_target]
				if sub_target.spine_renderer and sub_target then
					local sub_dmg = sub_effect_play.sub_hp_changed
					if sub_dmg <= 0 then
						sub_target.hp = math.max(0, sub_target.hp + sub_dmg)
					else
						sub_target.hp = math.min(sub_target.hp_max, sub_target.hp + sub_dmg)
					end
					self:mutiHurtNum(sub_target, sub_dmg, nil, false, camp_restrain)
					local per = math.min(math.max(100 * sub_target.hp / sub_target.hp_max, 0), 100)
					sub_target.spine_renderer:setHpPercent(per)

					if sub_effect_play.extra_effect and next(sub_effect_play.extra_effect or {}) ~= nil then
						for i,v in pairs(sub_effect_play.extra_effect) do
							if v.extra_key == 2 then -- 护盾吸收伤害
                                SkillAct.playBuffAbsorbHurt(sub_target, v.extra_param)
							end
						end
					end

					-- 技能效果是否飘字
					local effect_config = Config.SkillData.data_get_effect(sub_effect_play.sub_effect_id);
					if effect_config then
						local effect_desc = effect_config.effect_desc
						if effect_desc ~= "" and sub_effect_play.sub_is_hit ~= 0 then
							self:showbuffName(sub_target, effect_desc, 229, sub_effect_play.sub_effect_id, true, 230)
						end
					end

					-- 被动技能是否飘字
					local skill_config = Config.SkillData.data_get_skill(sub_effect_play.sub_skill_id)
					if skill_config then
						local passive_skill_show = skill_config.passive_skill_show
						local name = skill_config.name
						if passive_skill_show == TRUE then
							self:showbuffName(sub_target, name, 217, sub_effect_play.sub_effect_id, true, 218)
						end
					end

					if sub_effect_play.sub_is_hit == 0 and effect_play.is_dead == FALSE then
						local str = TI18N("躲闪")
						if not tolua.isnull(self.battle_scene) then
							sub_target.spine_renderer:playFontMessage(str, nil, false, self.battle_scene.effect_layer_1)
						end
					end
				end
			end
		end
	end
end

--==============================--
--desc:处理bufflist函数
--time:2017-10-11 09:01:30
--@list:bufff列表
--@return
--==============================--
function BattleModel:handleBufflist(attacker,list,effect_hit)
	--处理buff列表
	if  next(self.all_object or {}) ~= nil and self.all_object then
		local is_injury = false
		local count = 0
		for i, buff in pairs(list or {}) do
			local buff_target = self.all_object[buff.target]
			if buff_target and buff_target.spine_renderer then
				self:addBuff(attacker, buff_target, buff)

				if buff.change_type == 1 then --伤害buff造成处理
					local buff_dmg = buff.change_value
					if buff_dmg <= 0 then
						buff_target.hp = math.max(0, buff_target.hp + buff_dmg)
					else
						buff_target.hp = math.min(buff_target.hp_max, buff_target.hp + buff_dmg)
					end
					local per = math.min(math.max(100 * buff_target.hp / buff_target.hp_max, 0), 100)
					buff_target.spine_renderer:setHpPercent(per)
					if buff.is_dead == TRUE then
						buff_target:died()
					end
					self:mutiHurtNum(buff_target, buff_dmg, effect_hit, true)
				end
			end
		end
	end
end

--==============================--
--desc:-- 添加召唤角色
--time:2017-09-20 11:34:05
--@list: 召唤列表
--@attacker:
--@return
--==============================--
function BattleModel:addRoleList(list, attacker)
    if nil == list or #list == 0 then return end
    if attacker then
	end
    for index, v in ipairs(list or {}) do
		v.special_born = true
		v.fight_type = self.fight_type
        local have_same = false
        for i = index + 1, #list do
            if list[i].pos == v.pos then
                have_same = true
            end
        end
        if not have_same then
			self:addBattleRole(v, self.fight_type,self.fight_round,self.total_wave,false,false)
        end
    end
    list = {}       -- 列表置空，可能和多次剧情创建有关
end

--更新目标血量统一接口
function BattleModel:updateTargetHp(attacker, target, dmg, is_die, effect_hit, effect_play)
	if target then
		local is_must_die = attacker.is_must_die or 0
		effect_hit = effect_hit or 1
		local camp_restrain = effect_play.camp_restrain
		self:mutiHurtNum(target, dmg, effect_hit, false, camp_restrain)
		if dmg <= 0 then
			target.hp = math.max(0, target.hp + dmg)
		else
			target.hp = math.min(target.hp_max, target.hp + dmg)
		end
		target.hp_max = target.hp_max
		local per = math.min(math.max(100 * target.hp / target.hp_max, 0), 100)
		target.spine_renderer:setHpPercent(per)
		if is_die == TRUE then
			if is_must_die == 0 then --is_must_die表示是否需要移除尸体 -- and  target.spine_renderer.is_die == false
				target:died()
			end
		else
			if target.is_die == true and not self.battle_controller:getIsNoramalBattle() then
				target:relive()
			end
		end
	end
end

--播放回合buff
function BattleModel:playRoundBuff(target, buff, attacker)
	if buff == nil or target == nil or target.spine_renderer == nil then return end
	self:addBuff(attacker, target, buff)

	if buff.change_type == 1 then	-- 血量变化的时候
		local dmg = buff.change_value
		if dmg <= 0 then
			target.hp = math.max(0, target.hp + dmg)
		else
			target.hp = math.min(target.hp_max, target.hp + dmg)
		end
		local per = math.min(math.max(100 * target.hp / target.hp_max, 0), 100)
		target.spine_renderer:setHpPercent(per)
		self:mutiHurtNum(target, dmg, nil, true)
		if buff.is_dead == TRUE then
			target:died()
		end
	end
end

-- 多次飘血
function BattleModel:mutiHurtNum(target, dmg, hit_type, is_buff, camp_restrain)
	-- print("BattleModel:mutiHurtNum",dmg)
	-- print(debug.traceback())
	if dmg == 0 then return end
	if target.type == BattleObjectType.Elfin then return end -- 精灵不处理飘血
	-- 飘血的高度
	if target.dmg_index == nil then
		target.dmg_index = 0
	end
	target.dmg_index = target.dmg_index + 1
	SkillAct.playDmgMessage(target, dmg, hit_type, is_buff, camp_restrain) 
end

--播放分析伤害特效
--[[	@attacker:施法者
	@target:目标者
]]
function BattleModel:playHurtEffect(attacker, target)
	-- --TODO:add by chenbin
	if true then return end


	if not attacker or attacker.play_order_index == nil or next(attacker.hit_effect_list) == nil then return end
	local anime_res_down, anime_res_up, x_fix, y_fix, scale, alpha, h_scale, bid
	for _, v in ipairs(attacker.hit_effect_list) do
		anime_res_down = v.res_down or ""
		anime_res_up = v.res_up or ""
		x_fix = (v.x_fix or 0) * attacker.obj_type
		y_fix = v.y_fix
		scale = v.scale * 0.001
		alpha = 255
		h_scale = v.h_scale or 1
		bid = v.bid
		if anime_res_up == nil and anime_res_down == nil then return end
		self:playHitEffect(attacker, target, anime_res_up, anime_res_down, y_fix, x_fix, scale, alpha, h_scale, bid)
	end
end

--播放震屏效果
--[[	@shake_id:震屏id
]]
function BattleModel:playShakeScreen(shake_id)
	if shake_id == 0 or shake_id == nil then
		return
	end
	if not tolua.isnull(self.battle_scene) then
		self.battle_scene:shakeScreen(shake_id)
	end
end

--播放目标受击特效
--[[	@attacker:施法者
	@target:目标
	@res_up:上层特效
	@res_down:下层特效
	@y_fix,x_fix：x,y偏移
	@bid:特效Bid
]]
function BattleModel:playHitEffect(attacker, target, res_up, res_down, y_fix, x_fix, scale, alpha, h_scale, bid)
	local height
	if y_fix ~= 0 then
		height = y_fix
	end
	if res_up == "" and res_down == "" then return end
	local effect_name = {res_up, res_down}
	local spine_renderer = target.spine_renderer or attacker.spine_renderer
	height =(height or 50) / 100 *(spine_renderer.role_height or 0)
	local effect_name = effect_name
	local obj_type = nil
	if attacker ~= nil then
		obj_type = attacker.obj_type
	end
	if obj_type then
		SkillAct.effectHitUser(attacker, 0, spine_renderer, effect_name, obj_type, TRUE, height, x_fix, scale, alpha, h_scale, nil, bid, false)
	end
end

--播放场景特效,只处理场景类型的特效播放
--[[	@attacker:施法者
	@hurt_fun：伤害函数
]]
function BattleModel:playSceneAreaEffect(attacker, hurt_fun)
	if not attacker or attacker.play_order_index == nil or (next(attacker.area_effect_list) == nil) then return end

	-- --TODO:modified by chenbin
	if true then return end
	for _, v in ipairs(attacker.area_effect_list) do
		if v.play_type == BattleEffectPlayType.SCENE or v.play_type == BattleEffectPlayType.ROLE_SCENE or v.play_type == BattleEffectPlayType.ENEMY_SCENE then
			if v.res_down ~= "" or v.res_up ~= "" then
				self:effectArea(attacker, {v.res_up, v.res_down}, 0, TRUE, hurt_fun, v.play_type, v.x_fix, v.y_fix, v.bid, v.is_col_effect)
			end
		end
	end
end

--计算魔法伤害,判断是多次攻击还是攻击一次
--[[	@attacker:施法者
]]
function BattleModel:calcMagicHurt(attacker)
	local hit_num = not attacker.in_area_effect and attacker.spine_renderer.hit_num or attacker.area_hit_num or 1
	if attacker.attacker_info.is_calc or hit_num <= 1 then return end
	attacker.hurt_sum = 0
	attacker.hit_time = 0
	for _, mp in ipairs(attacker.attacker_info.target_list or {}) do
		mp.dmg_sum = 0
		mp.hurt_sum = 0
		local dmg = mp.hp_changed or 0
		if dmg < 0 then
			mp.hurt_sum = mp.hurt_sum + dmg
		end
		attacker.hit_time = attacker.hit_time + 1
		attacker.hurt_sum = attacker.hurt_sum - mp.hurt_sum
	end
	attacker.attacker_info.is_calc = true
	attacker.hit_time = attacker.hit_time * hit_num
end

--增加Buff
--[
--    attacker:s释放者
--    target:目标
--    buff:数据
--]
function BattleModel:addBuff(attacker, target, buff)
	local buff_data = Config.SkillData.data_get_buff[buff.buff_bid]
	if not buff_data then return end
	if buff.action_type == 7 then return end -- 这类buff不做任何处理,直接跳出去
	if buff_data.is_passive == 1 then
		self:playBuffEffect(attacker, target, buff, buff_data)       -- 播放魔法效果
	end
    if buff.action_type == 4 then return end
	-- 这种情况下是移除buff
	if buff.action_type == 2 or buff.action_type == 6 then
		self:removeBuff(target, buff)
	end
	if target == nil or target.spine_renderer == nil then return end

	if buff_data.is_passive == 1 or buff_data.group == 3211 then --不可复活Buff组额外处理
		if buff.action_type == 1 or buff.action_type == 3 or buff.action_type == 5 then
			if buff_data.group == 195 and buff.action_type == 1 then
				target:changeToGuiHun(true)
			else
				if buff_data.group ~= 3211 then
					if not keyfind("type", buff_data.positive_or_negative, target.buff_list) then
						target.buff_icon[buff_data.positive_or_negative] = 1
					end
					if buff_data.buff_spine ~= nil and buff_data.buff_spine ~= "" then
						if not target.spine_renderer.is_change_status then
							-- 这里需要判断是否要转换变身id,根据当前皮肤id来做转换
							local fashion_id = target:getFashionId()
							local change_spine = buff_data.buff_spine

							if fashion_id ~= 0 then
								local buff_skin_config = Config.PartnerSkinData.data_bufftospine[getNorKey(fashion_id, buff_data.bid)]
								if buff_skin_config and buff_skin_config.spine_res and buff_skin_config.spine_res ~= "" then
									change_spine = buff_skin_config.spine_res
								end
							end
							target:changeSpine(true, change_spine, PlayerAction.battle_stand)
						end
					end
				end
				if buff.remain_round ~= 0 and buff.action_type ~= 3 then
					table.insert(target.buff_list, {id = buff.id, bid = buff.buff_bid, duration = buff_data.duration
						, action_type = buff.action_type, remain_round = buff.remain_round, buff_res = buff_data.res, can_select = buff_data.can_select
						, type = buff_data.positive_or_negative, end_round = buff.end_round,is_release = buff_data.is_release})
					target.spine_renderer:updataBuffList(target.buff_list, target.object_name)
				end
			end
		end
	end
end

--移除buff`
--[[
	@target:目标
	@buff:buff列表状态
]]
function BattleModel:removeBuff(target, buff)
	if self.battle_scene == nil or tolua.isnull(self.battle_scene) then return end	-- 主战斗场景都没有了就不需要做下面判断了
	-- 如果这个移除buff对象是死亡单位,这边就比较特殊处理了
	if target == nil or target.spine_renderer == nil then return end

	-- 只处理变身的单位
	if target.is_die == true then
		local buff_data = Config.SkillData.data_get_buff[buff.buff_bid]
		if buff_data then
			if target.spine_renderer.is_change_status == true and target.spine_renderer.buff_spine and buff_data.buff_spine ~= "" then
				target:changeSpine(false)
			end
		end
	else
		if target.buff_list then
			local tmp_buff = keyfind("id", buff.id, target.buff_list)
			if tmp_buff then
				if buff.action_type == 2 or buff.action_type == 6 or buff.remain_round == 0 then --移除buff )
					keydelete("id", buff.id, target.buff_list)
					if not target.spine_renderer.is_die then
						target.spine_renderer:removeBuffIcon(buff.id)
						target.spine_renderer:updataBuffList(target.buff_list, target.object_name)
					end
					if tmp_buff.buff_res ~= "" then
						SkillAct.clearEffect(target, tmp_buff.bid)
					end
					local buff_data = Config.SkillData.data_get_buff[buff.buff_bid]
					if buff_data then
						-- 这里是新增的,移除场景buff
						local effect_config = Config.SkillData.data_get_effect_data[buff_data.res]
						if effect_config and (effect_config.play_type == BattleEffectPlayType.ROLE_SCENE or effect_config.play_type == BattleEffectPlayType.ENEMY_SCENE) then
							self:removeSceneBuffEffect(target.group, effect_config.bid)
						end

						if target.spine_renderer.is_change_status == true and target.spine_renderer.buff_spine and buff_data.buff_spine ~= "" then
							target:changeSpine(false)
						end
					end
				end
				if not keyfind("type", tmp_buff.type, target.buff_list) then
					if target.buff_icon[tmp_buff.type] ~= nil then
						target.buff_icon[tmp_buff.type] = nil
					end
				end
			end
		end
	end
end

-- 储存场景buff的特效,暂时不太可能存在唯一的,根据group去储存的
function BattleModel:addSceneBuffEffect(group, bid, effect_res, effect, action_name)
	if group == nil or bid == nil or effect_res == nil or effect == nil or action_name == nil then return end
	local key = getNorKey(group, bid)
	if self.scene_buff_effect_list[key] == nil then
		self.scene_buff_effect_list[key] = {}
	end
	local second_key = getNorKey(effect_res, action_name)
	if self.scene_buff_effect_list[key][second_key] then
		self.scene_buff_effect_list[key][second_key]:release(true, 0)
	end
	self.scene_buff_effect_list[key][second_key] = effect
end

-- 移除场景特效,如果没有参数,则移除全部
function BattleModel:removeSceneBuffEffect(group, bid)
	if group == nil or bid == nil then
		if self.scene_buff_effect_list then
			for k,v in pairs(self.scene_buff_effect_list) do
				for _, effect in pairs(v) do
					effect:release(true, 0)
				end
			end
			self.scene_buff_effect_list = {}
		end
	else
		local key = getNorKey(group, bid)
		local effect_list = self.scene_buff_effect_list[key]
		if effect_list then
			for k, effect in pairs(effect_list) do
				effect:release(true, 0)
			end
			self.scene_buff_effect_list[key] = nil
		end
	end
end

--- 处理buff飘字
function BattleModel:playBuffEffect(attacker, target, buff, buff_data)
	-- 处理buff飘字
	if buff.action_type == 1 or buff.action_type == 4 or buff.action_type == 6 then
		local text_color = 235
		local outline_color = 236
		local client_desc = buff_data.client_desc
		if buff.action_type == 6 then
			client_desc = TI18N("增益被窃取")
		else
			if buff_data.positive_or_negative == 1 then -- 增益
				text_color = 221
				outline_color = 222
			elseif buff_data.positive_or_negative == 2 then --减益 
				text_color = 223
				outline_color = 224
			elseif buff_data.positive_or_negative == 3 then --控制
				text_color = 225
				outline_color = 226
			end
		end
		if client_desc ~= "" then
			self:showbuffName(target, client_desc, text_color, buff, nil, outline_color)
		end
	end

	local bid = 0
	-- 后面部分没有发起者就不做处理,类似回合之前buff.也不要播放了
	if not attacker then return end
	if not keyfind("id", buff.id, target.buff_list) then
		if (buff.action_type == 1 or buff.action_type == 5) and buff_data.res ~= 0 then  --策划要求只有增加类型下播放特效
			local config = Config.SkillData.data_get_effect_data[buff_data.res]
			if config then
				if config.play_type == BattleEffectPlayType.ROLE_SCENE or config.play_type == BattleEffectPlayType.ENEMY_SCENE then
					-- 这里判断一下,如果存在,就不要播了,如果是己方,就是按照attacker.group去储存,否则是按照target.group 去储存
					local group = attacker.group
					local fashion_id = attacker:getFashionId()
					if config.play_type == BattleEffectPlayType.ENEMY_SCENE then
						group = target.group
						fashion_id = target:getFashionId()
					end
					local key = getNorKey(group, buff_data.res)
					if self.scene_buff_effect_list[key] == nil or next(self.scene_buff_effect_list[key]) == nil then
						local effect_list = {config.res_up,config.res_down}
						if fashion_id ~= 0 then
							local buff_skin_config = Config.PartnerSkinData.data_bufftospine[getNorKey(fashion_id, buff_data.bid)]
							if buff_skin_config and buff_skin_config.effect_bid and buff_skin_config.effect_bid ~= 0 then
								local tmp_config = Config.SkillData.data_get_effect_data[buff_skin_config.effect_bid]
								if tmp_config then
									effect_list = {tmp_config.res_up,tmp_config.res_down}
								end
							end
						end
						self:effectArea(attacker, effect_list, 0, FALSE, nil, config.play_type, config.x_fix, config.y_fix, buff_data.res, config.is_col_effect, false, group)
					end
				else
					-- 这里转换一下 跟当前皮肤绑定,只替换资源,不干别的
					local fashion_id = target:getFashionId()
					local effect_list = {config.res_up,config.res_down}
					if fashion_id ~= 0 then
						local buff_skin_config = Config.PartnerSkinData.data_bufftospine[getNorKey(fashion_id, buff_data.bid)]
						if buff_skin_config and buff_skin_config.effect_bid and buff_skin_config.effect_bid ~= 0 then
							local tmp_config = Config.SkillData.data_get_effect_data[buff_skin_config.effect_bid]
							if tmp_config then
								effect_list = {tmp_config.res_up,tmp_config.res_down}
							end
						end
					end
					self:effectSpineUser(attacker, 0, buff_data.is_release, config.x_fix * target.obj_type, config.y_fix, effect_list, target.spine_renderer, config.scale * 0.001, 255, 1, nil, buff_data.bid, buff_data.res, nil, target.obj_type)
				end
			end
		end
	end
	if buff.action_type == 3 and buff_data.efftive_effect ~= 0 then --这类型判断为生效Buff触发一次特效
		local config = Config.SkillData.data_get_effect_data[buff_data.efftive_effect]
		if config then
			self:effectSpineUser(attacker, 0, TRUE, config.x_fix * target.obj_type, config.y_fix, {config.res_up,config.res_down}, target.spine_renderer, config.scale * 0.001, 255, 1, nil, buff_data.bid, buff_data.res, nil, target.obj_type)
			self.act_after_effect_list = {}
		end
	end
end

-- 显示buff名字
function BattleModel:showbuffName(target, msg, text_color, buff, is_effect, outline)
	if not target then return end
	if target.spine_renderer and not tolua.isnull(target.spine_renderer.spine) then
		local r = target.spine_renderer.spine:getBoundingBox()
		local height = target.height or math.max(r.height, 100)
		local tips, _x = nil, 88
		if not target.tips_list then
			target.tips_list = {}
		end
		local id, bid = 0, 0
		if is_effect then
			id = buff
			bid = buff
		else
			id = buff.id
			bid = buff.buff_bid
		end
		text_color = text_color or 1
		outline = outline or 1

		if target.tips_list[id] == nil then
			local sp = createSprite(PathTool.getResFrame("battle", "battle_buff_name_bg"), 0, 0, tips, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, - 1)
			sp:setCascadeOpacityEnabled(true)
			tips = createLabel(20, text_color, outline, sp:getContentSize().width / 2, sp:getContentSize().height / 2, msg, sp, nil, cc.p(0.5, 0.5))
			sp:setOpacity(100)
			sp:setScale(0.6)
			sp:setVisible(false)
			sp:setPosition(0, height / 2)
			target.spine_renderer.root:addChild(sp, 99)
			table.insert(target.tips_list, {id = id, bid = bid, sp = sp})
		end
		for i, v in pairs(target.tips_list) do
			if v.sp ~= nil then
				v.sp:stopAllActions()
				v.sp:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.3 * i),
				cc.CallFunc:create(function()
					v.sp:setVisible(true)
				end),
				cc.Spawn:create(cc.ScaleTo:create(0.4, 1.2), cc.MoveTo:create(0.4, cc.p(0, v.sp:getPositionY() + 50)), cc.FadeIn:create(0.4)),
				cc.Spawn:create(cc.ScaleTo:create(0.6, 0.9), cc.FadeTo:create(0.6, 100), cc.MoveTo:create(0.6, cc.p(0, v.sp:getPositionY() + 75))),
				cc.CallFunc:create(function()
					if v.sp:getPositionY() >=(v.sp:getPositionY() + 75) then
						v.sp:setPositionY(v.sp:getPositionY() + 75)
					end
				end),
				cc.FadeOut:create(0.1), cc.CallFunc:create(function()
					v.sp:setVisible(false)
				end)))
			end
		end
	end
end

--------------------------
-- 技能动作附带回调函数 --
--------------------------
-- 受伤 有群攻特效用群攻特效的hit点
function BattleModel:callfun(attacker, args)
	if args == nil then return end
	
	local funname
	local arg = {}
	if type(args) == "table" then
		funname = args[1]
		arg = {args[2], args[3], args[4]}
	else
		funname = args
	end
	if type(self[funname]) == "function" then
		self[funname](self, attacker, unpack(arg))
	elseif type(funname) == "number" then       -- 如果是个数字，直接调用某个动作
		local act = self:singleAct(funname, attacker)
		if act then
			attacker.spine_renderer:runAction(act)
		end
	end
end
--战斗结果
function BattleModel:result(data, is_self_exit)
	if self.finish_data == nil then return end
    if self.battle_controller:getCurFightInfo() == true then return end
	if data.combat_type == self.fight_type and data.combat_type == self.battle_controller:getCurFightType() then
		self.finish_data.result = data
		self.is_exit_self = is_self_exit
		if self.finish_data.result then
			self:clear()
		end
	end
end
--判断是否结束
function BattleModel:isFinish()
	if self.finish_data ~= nil then
		return self.finish_data.result ~= nil
	end
end
-----------------------清场-------------------
--清场
function BattleModel:clear(is_enter)
    if self.battle_controller:getCurFightInfo() == true then return end
	if next(self.all_object or {}) ~= nil and self.all_object then
		for _, v in pairs(self.all_object or {}) do
			GlobalTimeTicket:getInstance():remove("attackerActTimeout" .. v.pos)
		end
	end
	GlobalTimeTicket:getInstance():remove("next_wait_timer")
	if self.screen_over_timer ~= nil then
		GlobalTimeTicket:getInstance():remove(self.screen_over_timer)
		self.screen_over_timer = nil
	end
	self.is_exit = true
	self.particle = nil
	self.is_first = nil
	self.all_round_data = {}
	self.start_battle_timestamp = nil
	self.dragon_data = {}
	self:setSpecialEnemyData(false)
	self.battle_controller:setBattleStartStatus(false)
	self:exitBattleFight(is_enter)
end

--退出战斗可能也要处理一些函数
function BattleModel:exitFightFunc()
	GlobalEvent:getInstance():Fire(SceneEvent.EXIT_FIGHT, self.fight_type, self.result)
end

--退出战斗
--@param no_event:是否退出
function BattleModel:exitBattleFight(is_enter)
	if not self.battle_scene or tolua.isnull(self.battle_scene) then return end
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
        print("退出战斗",self.fight_type)
    end
	GlobalTimeTicket:getInstance():remove("exit_fight_timer")
	QueueManager:getInstance():remove("SkillAct")
	GlobalMessageMgr:getInstance():showPermanentMsg(false)
	self:scFightEndClear()
	self:clearAllObject()
	self.all_object = {}
	self.buffs = {}
	self.act_after_effect_list = {}
	self.effect_bid_list = {}
	self.effect_list = {}
	self.prepare_role_list = {}
	self.prepare_sound_list = {}
	self.res_list = {}
	self.battle_speed = 1
	if self.battle_scene:getMapLayer() and not tolua.isnull(self.battle_scene:getMapLayer()) then
		self.battle_scene:clearRoleLayer()
	end
	if not is_enter then
		self.battle_controller:setPkStatus(false)
		self.battle_controller:setIsHeroTestWar(false)
		self.battle_controller:setWatchWitnessBattleStatus(false)
		self:exitFightFunc()
		self.is_reconect = nil
		self:clearView()
	end

	SkillAct.clearSpine()
end

function BattleModel:clearView()
	if self.battle_controller:getCurFightType() == BattleConst.Fight_Type.Darma and MainuiController:getInstance():checkIsInDramaUIFight() then --如果是剧情副本且在剧情副本里面
		self.show_finish_ui = false
		self:setBattleTimeScale(self.battle_controller:getActTime("base_speed_scale"))
		self.battle_scene:clearUiLayer()
		self.battle_controller:send20060(BattleConst.Fight_Type.Darma)
		-- end
	else --如果不在剧情副本
		self.show_finish_ui = false
		if self.fight_type == self.battle_controller:getCurFightType() or self.battle_controller:getIsClickStatus() then --战斗类型相同情况下
			if MainuiController:getInstance():checkIsInDramaUIFight() then
				if self.battle_controller:getWatchReplayStatus() or self.fight_type == BattleConst.Fight_Type.PK or self.fight_type == BattleConst.Fight_Type.HeroTestWar then
					self.battle_scene:clearUiLayer()
					self.battle_controller:send20060(BattleConst.Fight_Type.Darma)
				end
			else
				self:setBattleTimeScale(self.battle_controller:getActTime("base_speed_scale"))
				self:removeBattleScene()

				-- 这个时候直接移除掉场景
				self.battle_controller:clear(true)
			end
		elseif self.battle_controller:getCurFightType() == 0 then
			self:setBattleTimeScale(self.battle_controller:getActTime("base_speed_scale"))
			self:removeBattleScene()
			-- 这个时候直接移除掉场景
			self.battle_controller:clear(true)
		end
	end
	self.finish_data = {}
	self.battle_controller:setWatchReplayStatus(false)
end

function BattleModel:removeBattleScene()
	if self.battle_scene and not tolua.isnull(self.battle_scene) then
		self.battle_scene:cleanFightView()
		self.battle_scene:removeAllChildren()
		self.battle_scene = nil
	end
end

--重连不在战斗强制退出
function BattleModel:battleclear()
	self:clear()
end
-------------------------------------------------------
---------获取一些战斗场景变量、选择状态----------------
-------------------------------------------------------
--获取战斗场景
function BattleModel:getBattleScene()
	if not tolua.isnull(self.battle_scene) then
		return self.battle_scene
	end
end
--获取人物层
function BattleModel:getMapLayer()
	if not tolua.isnull(self.battle_scene) then
		return self.battle_scene:getMapLayer()
	end
end

--获取特效层
function BattleModel:getEffectLayer(effect_type)
	if not tolua.isnull(self.battle_scene) then
	return self.battle_scene:getEffectLayer(effect_type)
	end
end

--获取是否自动
function BattleModel:getIsAuto()
	return self.is_auto
end

--获取group
function BattleModel:getGroup()
	return self.group
end

--是否在战斗
function BattleModel:isInFight()
	return (self.battle_controller:getBattleStatus() or (not self.battle_controller:getBattleStatus() and not self.is_exit)) and not self.battle_controller:getIsNoramalBattle()
end

--获取人物所有列表
function BattleModel:getAllObject()
	return self.all_object
end

--用来检测目标是否选择准确
function BattleModel:checkTagetPos(pos)
	if self.all_object == nil or pos == nil then return end
	local vo = self.all_object[pos]
	if self.all_object[pos] and self.all_object then
		if vo.spine_renderer then
			if self.is_right_target == true then
				return true
			else
				return false
			end
		end
	end
end

--加速按钮设置
function BattleModel:changeSpeed()
	self.is_speed = self.is_speed + 1
	if self.is_speed > self.max_speed then
		self.is_speed = 1
	end
	self:saveSpeed(self.is_speed, self.is_speed)
	if not self.battle_controller:getWatchReplayStatus() then -- 录像中倍数默认2倍，且可以随意切换，无需通知后端
		self.battle_controller:csFightSpeed(self.is_speed)
	end
end

--用于剧情副本改变速率
function BattleModel:storySpeed(bool)
	if bool == true then
		self:setBattleTimeScale(1)
	else
		if self.battle_speed == nil then
			self.battle_speed = self.battle_controller:getActTime("base_speed_scale")
		end
		self:setBattleTimeScale(self.battle_speed)
	end
end

--统一设置全局速度
function BattleModel:setBattleTimeScale(battle_speed)
	local speed = self.battle_controller:getActTime("base_speed_scale")

	if battle_speed >= self.battle_controller:getActTime("speed_scale_2") then
		speed = self.battle_controller:getActTime("speed_scale_2")
	elseif battle_speed >= self.battle_controller:getActTime("speed_scale") then
		speed = self.battle_controller:getActTime("speed_scale")
	else
		speed = self.battle_controller:getActTime("base_speed_scale")
	end
	self.role_time_scale = speed
	self:setRoleTimeScale(speed)
end


function BattleModel:getTimeScale()
    return self.role_time_scale
end


function BattleModel:setRoleTimeScale(battle_speed)
	if self.all_object and next(self.all_object or {}) ~= nil then
		for k, v in pairs(self.all_object) do
			if v.spine_renderer and v.spine_renderer.spine then
				v.spine_renderer.spine:setTimeScale(battle_speed)
			end
		end
	end
end

--保存当前战斗速率
function BattleModel:saveSpeed(bool, speed)
	self.is_speed = bool
	self.battle_speed = speed
	if self.battle_scene then
		self.battle_scene:setSpeed(bool, speed)
	end
end

--获取当前效果列表所拥有特效列表
--[[		@list:配置特效列表转换
]]
function BattleModel:getCurEffectList(list)
	local effect_list = {}
	for i, v in ipairs(list) do
		local effect_data = Config.SkillData.data_get_effect_data[v]
		table.insert(effect_list, effect_data)
	end
	return effect_list
end

--是否动作状态
function BattleModel:getActState()
	return self.act_playing
end

--根据当前出手位置判断是否为友方
function BattleModel:getCurRoleType(pos)
	if next(self.all_object or {}) ~= nil and self.all_object then
		if self.all_object and pos ~= nil then
			local vo = self.all_object[pos]
			local group
			if vo then
				group = self:checkGroup(vo.group)
			end
			if group == BattleGroupTypeConf.TYPE_GROUP_ROLE then
				return true
			else
				return false
			end
		end
	end
end

--获取不能行动状态bid
function BattleModel:getCurParterBuffListBID(pos)
	if next(self.all_object or {}) ~= nil and self.all_object then
		local pos = pos or self.order_pos
		local vo = self.all_object[pos]
		if vo ~= nil then
			for _, v in pairs(vo.buff_list) do
				if v.can_select == 0 then
					return v.bid
				end
			end
		end
	end
end

--判断目标身上Buff能否出手
function BattleModel:getCurParterBuffList(pos)
	if next(self.all_object or {}) ~= nil and self.all_object then
		local pos = pos or self.order_pos
		local vo = self.all_object[pos]
		if vo then
			if vo.buff_list and next(vo.buff_list or {}) ~= nil then
				for _, v in pairs(vo.buff_list) do
					if v.can_select == 0 then
						return false
					end
				end
				return true
			else
				return true
			end
		end
	end
end

--判断目标身上是否存在反击Buff
function BattleModel:getBuffTag(pos)
	if next(self.all_object or {}) ~= nil and self.all_object then
		local pos = pos or self.order_pos
		local vo = self.all_object[pos]
		if vo then
			for _, v in pairs(vo.buff_list) do
				local config = Config.SkillData.data_get_buff[v.bid]
				if config.group == 3108 then
					return true
				end
			end
			return false
		end
	end
end

--判断目标身上是否存在洞察buff
function BattleModel:getCurParterShowBuff(pos)
	if next(self.all_object or {}) ~= nil and self.all_object then
		local pos = pos or self.order_pos
		local vo = self.all_object[pos]
		if vo then
			local is_silent = false
			for _, v in pairs(vo.buff_list) do
				local config = Config.SkillData.data_get_buff[v.bid]
				if config and config.group == 3704 then
					is_silent = true
					break
				end
			end
			return is_silent
		end
	end
end

--判断目标身上是否存在沉默buff
function BattleModel:getCurParterSilentBuff(pos)
	if next(self.all_object or {}) ~= nil and self.all_object then
		local pos = pos or self.order_pos
		local vo = self.all_object[pos]
		if vo then
			local is_silent = false
			for _, v in pairs(vo.buff_list) do
				local config = Config.SkillData.data_get_buff[v.bid]
				if config and config.group == 3303 then
					is_silent = true
					break
				end
			end
			return is_silent
		end
	end
end

--显示结算界面 is_replay:是否为录像
function BattleModel:showWin(data, is_replay)
	if data.show_panel_type == nil or data.combat_type == nil then return end
	if data.show_panel_type == 1  then
		-- 战斗类型相同且当前不在录像战斗中、或者当前为结束录像战斗（为录像时后端传过来的combat_type会大于1000）,则退出战斗场景
		if (self.battle_controller:getCurFightType() == data.combat_type and not self.battle_controller:getWatchReplayStatus()) or is_replay then
			self:setFinishData(data)
			self.battle_controller:setBattleStartStatus(false)
			self.show_finish_ui = true
			if  not tolua.isnull(self.battle_controller:getCtrlBattleScene())  then
				self.battle_controller:getCtrlBattleScene():handleLayerShowHide(false)
			end
			if self.is_speed and self.is_speed > 1 then
				self:setBattleTimeScale(self.battle_controller:getActTime("base_speed_scale"))
			end
			if not tolua.isnull(self.battle_scene) then
				self.battle_scene:setWait(false)
			end
			if not self.battle_controller:getWatchReplayStatus() then
				delayOnce(function()
					self:scFightEndClear(data.result)
				end,0.5)
			else
				if not self.finish_data then
					self.finish_data = {}
				end
				self.finish_data.result = data.result
				self:clear()
			end
		end
		self:showWinView(data)
	elseif data.show_panel_type == 2 then
		self:clear(true)
	else
		local call_delay_func = function()
			self:setFinishData(data)
			self.battle_controller:setBattleStartStatus(false)
			self.show_finish_ui = true
			if not tolua.isnull(self.battle_controller:getCtrlBattleScene()) then
				self.battle_controller:getCtrlBattleScene():handleLayerShowHide(false)
			end
			if not self.finish_data then
				self.finish_data = {}
			end
			self.finish_data.result = data.result
			self:clear()
		end

		if (self.battle_controller:getCurFightType() == data.combat_type and not self.battle_controller:getWatchReplayStatus()) or is_replay or data.combat_type == 0 then
			if data.combat_type == BattleConst.Fight_Type.EliteMatchWar or data.combat_type == BattleConst.Fight_Type.EliteKingMatchWar then	-- 如果是精英赛可能存在播放表情,要延迟关闭界面
				if not tolua.isnull(self.battle_scene) then
					self.battle_scene:addEliteDeclarationUI(data.combat_type, 2, data)
					delayOnce(function()
						call_delay_func()
						ElitematchController:getInstance():sender24950()
					end, 1.5)
				else
					call_delay_func()
				end
			else
				call_delay_func()
			end
		end
	end
end

--游戏退出结算
function BattleModel:showWinView(data)
	if data == nil then return end
	self.battle_controller:openFinishView(true,data.combat_type,data, self.fight_round, self.total_wave)
end


--用于结束协议过来清掉人物,预防有尸体遗留
function BattleModel:scFightEndClear(result)
	if next(self.all_object or {}) ~= nil and self.all_object then
		for i, role in pairs(self.all_object) do
			if role.spine_renderer and not tolua.isnull(role.spine_renderer.root) then
				role.spine_renderer:showSpineModel(false)
			end
		end
	end
end

--判断目标身上是否存在不可以复活buff
function BattleModel:getCurParterIsDisableReliveBuff(pos)
	if next(self.all_object or {}) ~= nil and self.all_object then
		local vo = self.all_object[pos]
		if vo then
			local is_disable_relive = false
			for _, v in pairs(vo.buff_list) do
				if Config.SkillData.data_get_buff[v.bid] then
					local config = Config.SkillData.data_get_buff[v.bid]
					if config and config.group == 3211 then
						is_disable_relive = true
						break
					end
				end
			end
			return is_disable_relive
		end
	end
end


--判断目标类型是否正确
function BattleModel:isRight(target)
	if target ~= BattleTargetTypeConf.DEAD_ALLY
	and target ~= BattleTargetTypeConf.ALIVE_SELF
	and target ~= BattleTargetTypeConf.ALIVE_EXEPT_SELF
	and target ~= BattleTargetTypeConf.ALIVE_ALLY_EXCEPT_SELF then
		return true
	end
	return false
end

--获取位置所有信息
--[[	@pos:目标位置
]]
function BattleModel:getObjectDataFromPos(pos)
	if self.all_object == nil then return end
	for _, v in pairs(self.all_object) do
		if v.pos == pos then
			return v
		end
	end
end
--设置结束数据
function BattleModel:setFinishData(data)
	self.finish_data = {}
	if data then
		self.finish_data = data
	end
end

--用于策划特殊要求层级设置
function BattleModel:updateSpineZorder(zoder,group)
	if self.all_object == nil then return end
	for _, role in pairs(self.all_object) do
		if role.spine_renderer then
			if role.group ~= group then
				role.spine_renderer.root:setLocalZOrder(zoder)
			end
		end
	end
end


--停止跑动
function BattleModel:updateStop()
	if self.all_object then
		for k, role in pairs(self.all_object or {}) do
			if role ~= nil and role.spine_renderer ~= nil and role.spine_renderer.is_die == false then
				role.spine_renderer:doStand()
                if role.group == 2 then
                    role.spine_renderer:reverse()
                end
			end
		end
	end
end

--更新下一波跑动
function BattleModel:updateRun(is_move_half)
	if self.all_object then
		for k, role in pairs(self.all_object or {}) do
			if role ~= nil and role.spine_renderer ~= nil and role.spine_renderer.is_die == false then
				role.spine_renderer:doRun()
                if role.group == 2 then
                    role.spine_renderer:reverse()
                end
                if is_move_half then
                    role:showEnterAction()
                end
			end
		end
	end
end

--设置重连状态
function BattleModel:setReconnectStatus(bool)
	self.is_reconect = bool
end

function BattleModel:getReconnectStatus()
	return self.is_reconect
end


--选中目标位置特效
--[[	@pos:位置
]]
function BattleModel:setSelectTargetTag(pos)
	if self.all_object == nil then return end
	for _, role in pairs(self.all_object or {}) do
		if role.pos == pos then
			if role.spine_renderer then
				role.spine_renderer:showTargetEffect(true)
			end
		else
			if role.spine_renderer then
				role.spine_renderer:showTargetEffect(false)
			end
		end
	end
end

--更新多波怪物数据接口
--[[	@data:多波怪物数据 协议20020
]]
function BattleModel:upDateNextMon(data)
	if self.all_object == nil or data == nil then
		return
	end
	self.fight_round = data.current_wave
	self.total_wave = data.total_wave
	self.fight_type = data.combat_type

	if not self.all_round_data[self.fight_round] then
		self.all_round_data[self.fight_round] = data.objects
	end
	--清掉上一回合地方死亡对象
	for _, v in pairs(self.all_object or {}) do
		SkillAct.clearAllEffect(v.spine_renderer)
		if v.spine_renderer then
			v.spine_renderer:cleanAllBuffIcon(v.buff_list)
		end
		if v.group == BattleGroupTypeConf.TYPE_GROUP_ENEMY and v.spine_renderer then
			v.spine_renderer:setVisible(false)
			v.spine_renderer:realrelease(true)
			self.all_object[v.pos] = nil
		end
	end
	self:setBuffsList(data.buffs) --更新buff

	if self.battle_scene and not tolua.isnull(self.battle_scene) then
		for _, v in pairs(data.objects or {}) do
			local role = self.all_object[v.pos]

			if v.pos ~= 31 and v.pos ~= 32 and v.pos ~= 41 and v.pos ~= 42 then
				if v.group == 1 and role ~= nil and role.spine_renderer then
					if role.spine_renderer.is_die == false then
						self.sum = self.sum + 1
						role:updataNextBattleRole(v, data)
					end
				elseif v.group == 2 then
					v.fight_type = data.combat_type
					self:addBattleRole(v, data.combat_type, data.current_wave, data.total_wave,true)
				end
			end
		end
		self.battle_scene:updataZhenfaInfo(data)
		self:reconnectBuff(true)
	end
end

--==============================--
--desc:移除掉场景上面所有的单位
--time:2019-02-18 06:30:57
--@return 
--==============================--
function BattleModel:clearAllObject()
	for _, v in pairs(self.all_object or {} ) do
		v:removeBuffTipsList()
		if v.spine_renderer and not tolua.isnull(v.spine_renderer.root) then
			v.spine_renderer.root:stopAllActions()
			v.spine_renderer:setVisible(false)
			v.spine_renderer:realrelease(true)
			v.spine_renderer:cleanAllBuffIcon(v.buff_list)
			SkillAct.clearAllEffect(v.spine_renderer)
		end
		v:exitdeleteRole()
		self.all_object[v.pos] = nil
	end
	-- 新增,移除场景特效
	self:removeSceneBuffEffect()
end

--重连先清除人物再创建,没刷新接口
function BattleModel:reconnectClear(data)
	if not tolua.isnull(self.battle_scene)  then
		self.battle_scene:clearUiLayer(true)
	end
	self:clearAllObject()
	self:battleStart(data)
end

--正常开始准备协议,每创建一个正常的战斗单位之后,都判断是否创建完成
function BattleModel:addReadySum()
	self.sum = self.sum + 1
	if next(self.all_object or {}) ~= nil then
		local alive_num = self.reconnect_num or 1
		if self.sum >= alive_num then
			if self.battle_controller:getModel():getNextMonStatus() then
				self.battle_controller:getModel():setNextMonStatus(false)
			end
			if not self.is_show_special and not self.special_enemy_data then
				self:addReadayFunc()
			end
		end
	end
end

function BattleModel:addReadayFunc()
	self.battle_controller:csReadyFightStart()
	if self.battle_controller:getCtrlBattleScene() then
		self.battle_controller:getCtrlBattleScene():updateRound(self.action_count)
	end
	if not tolua.isnull(self.battle_scene) then
		self.battle_scene:setMoveMapStatus(false)
		self.sum = 0
	end
end

--重连准备
function BattleModel:addReConnectReadySum(object_type)
	-- 不计算神器和精灵的数量
	if self:checkIsHallowsOrElfin(object_type) then return end
	if not self.rec_sum then
		self.rec_sum = 0
	end
	self.rec_sum = self.rec_sum + 1
	if self.rec_sum >= self.reconnect_num then
		if self.battle_controller:getModel():getNextMonStatus() then
			self.battle_controller:getModel():setNextMonStatus(false)
		end
		self.battle_controller:csReBattleFightReady()
		if not self.is_first then
			self:reconnectBuff()
		end
		self:setReconnectStatus(false)
		if not tolua.isnull(self.battle_scene) then
			self.battle_scene:setMoveMapStatus(false)
		end
		self.rec_sum = 0
	end
end

--检查重连生存人数
function BattleModel:findRecAliveNum()
	-- local count = 0
	-- if next(self.all_object) ~= nil then
	-- 	for _, role in pairs(self.all_object) do
	-- 		if role.spine_renderer and role then
	-- 			if role.spine_renderer.is_die == false then
	-- 				count = count + 1
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- return count
	return self.reconnect_num
end

--检查友方生存人数
function BattleModel:findAliveNum()
	-- local count = 0
	-- if next(self.all_object or {}) ~= nil and self.all_object then
	-- 	for _, role in pairs(self.all_object) do
	-- 		if role and role.spine_renderer then
	-- 			if role.spine_renderer.is_die == false and self:changeGroup(role.group) == 1 then
	-- 				count = count + 1
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- return count
	return self.reconnect_num
end

--用于检查敌方死亡人数
function BattleModel:checkEnemyDie(group, pos)
end

--获取当前回合人物数量
function BattleModel:findRoleSum(round)
	if next(self.all_round_data) ~= nil then
		local count = 0
		local list = self.all_round_data[round]
		if list then
			for i, v in pairs(list) do
				local data = list[i]
				count = count + 1
			end
		end
		return count
	end
end

--剧情副本重置位置
function BattleModel:resetMap()
	if not tolua.isnull(self.battle_scene) then
		self.battle_scene:resetMap()
	end
end

--获取加速状态
function BattleModel:getDoubleSpeedStatus()
	return self.is_double_speed
end

--获取黑屏状态
function BattleModel:getBlackStatus()
	return self.is_black
end

--转换组别
function BattleModel:changeGroup(group)
	local group_temp = self:checkGroup(group)
	if self.battle_controller:getWatchReplayStatus() then
		group_temp = group
	elseif BattleConst.isNeedChangeGroup(self.fight_type) then
		group_temp = group
	end
	return group_temp
end

--- 是否是左边
function BattleModel:isLeft(group)
	return self:changeGroup(group) == BattleGroupTypeConf.TYPE_GROUP_ROLE
end

--转换组别
function BattleModel:checkGroup(group)
	local temp_group = BattleGroupTypeConf.TYPE_GROUP_ENEMY
	if group == self:getGroup() then
		temp_group = BattleGroupTypeConf.TYPE_GROUP_ROLE
	end
	return temp_group
end

--==============================--
--desc:预加载技能特效
--time:2019-01-07 05:37:39
--@skill_id:
--@return 
--==============================--
function BattleModel:addSpineBySkill(skills, object_bid, object_type, object_star)
	if skills == nil or next(skills) == nil then return end
	if object_bid == nil or object_type == nil then return end
	if object_type == BattleObjectType.Hallows then return end	-- 神器不做预加载
	local model_id = nil
	object_star = object_star or 0
	if object_type == BattleObjectType.Pet then
		local base_data = Config.PartnerData.data_partner_star(getNorKey(object_bid, object_star)) 
		if base_data then
			model_id = base_data.res_id
		end
	elseif object_type == BattleObjectType.Unit then
		local base_data = Config.UnitData.data_unit(object_bid)
		if base_data then
			model_id = base_data.body_id
		end
	end
	if model_id == nil then return end

	-- 设置该伙伴相关的技能特效资源
	for i, skill in ipairs(skills) do
		self:addToWaitLoadRes(skill.skill_bid, model_id)
	end 
end

--==============================--
--desc:添加待预加载的资源
--time:2019-01-07 06:28:25
--@skill_id:
--@model_res:
--@return 
--==============================--
function BattleModel:addToWaitLoadRes(skill_id, model_res)
	if skill_id == nil or skill_id == 0 then return end

	if not self.effect_bid_list then
		self.effect_bid_list = {}
	end
	if not self.effect_list then
		self.effect_list = {}
	end
	if self.prepare_role_list == nil then
		self.prepare_role_list = {}
	end
	if self.prepare_sound_list == nil then
		self.prepare_sound_list  = {}
	end

	if self.effect_bid_list[skill_id] then return end
	
	local skill_data = Config.SkillData.data_get_skill(skill_id)
	if skill_data == nil then return end
	self.effect_bid_list[skill_id] = skill_data

	if skill_data.effect_list and next(skill_data.effect_list) then
		for i,v in ipairs(skill_data.effect_list) do
			local effect_data = Config.SkillData.data_get_effect(v)
			if effect_data then
				if effect_data.attack_sound and effect_data.attack_sound ~= "" and self.prepare_sound_list[effect_data.attack_sound] == nil then
					self.prepare_sound_list[effect_data.attack_sound] = effect_data.attack_sound
				end
				if effect_data.ready_sound and effect_data.ready_sound ~= "" and self.prepare_sound_list[effect_data.ready_sound] == nil then
					self.prepare_sound_list[effect_data.ready_sound] = effect_data.ready_sound
				end
				if effect_data.shout_trick and effect_data.shout_trick ~= "" and self.prepare_sound_list[effect_data.shout_trick] == nil then
					self.prepare_sound_list[effect_data.shout_trick] = effect_data.shout_trick
				end
				if effect_data.hit_sound and effect_data.hit_sound ~= "" and self.prepare_sound_list[effect_data.hit_sound] == nil then
					self.prepare_sound_list[effect_data.hit_sound] = effect_data.hit_sound
				end
				for i, bid in ipairs(effect_data.bact_effect_list) do
					self.effect_list[bid] = bid
				end
				for i, bid in ipairs(effect_data.act_effect_list) do
					self.effect_list[bid] = bid
				end
				for i, bid in ipairs(effect_data.area_effect_list) do
					self.effect_list[bid] = bid
				end
				for i, bid in ipairs(effect_data.hit_effect_list) do
					self.effect_list[bid] = bid
				end
				-- 添加将要播放的模型动作到预加载列表
				if effect_data.anime_res ~= "" then
					local model_res_key = getNorKey(model_res, effect_data.anime_res)
					if self.prepare_role_list[model_res_key] == nil then
						self.prepare_role_list[model_res_key] = {model_res, effect_data.anime_res}
					end
					local hurt_res_key = getNorKey(model_res, "hurt")  -- 受击动作直接写进去
					if self.prepare_role_list[hurt_res_key] == nil then
						self.prepare_role_list[hurt_res_key] = {model_res, "hurt"}
					end
				end
			end
		end
	end
end

function BattleModel:addSpineRes()
	if next(self.prepare_role_list or {}) ~= nil then
		for k,v in pairs(self.prepare_role_list) do
			SkillAct.addSpine(v[1], v[2])
		end
	end

	if next(self.prepare_sound_list or {}) ~= nil then
		for k,v in pairs(self.prepare_sound_list) do
			AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.BATTLE, v) 
		end
	end

--modified by chenbin:不再加载原特效
--[[
	if next(self.effect_list or {}) ~= nil then
		for _, v in pairs(self.effect_list) do
			local effect_res_data = Config.SkillData.data_get_effect_data[v]
			if effect_res_data ~= nil then
				SkillAct.addSpine(effect_res_data.res_up)
				SkillAct.addSpine(effect_res_data.spec_res_up)
				SkillAct.addSpine(effect_res_data.res_down)
			end
		end
	end
]]
end

-- --设置spine资源
function BattleModel:setRes(img_path)
	self.res_list[img_path] = true
end

-- 资源加载开始
function BattleModel:resLoadStart(img_path)
	if self.res_list[img_path] then
		return false
	end
	self.res_num = self.res_num + 1
	self.res_list[img_path] = true
	return true
end

-- 资源加载结束
function BattleModel:resLoadFinish(img_path)
end

--获取是否挂机状态
function BattleModel:getHookStatus()
	return self.is_onHook
end

--是否存在可用目标
function BattleModel:setTargetStatus(status)
	self.is_right_target = status
end

--获取目标状态
function BattleModel:getTargetStatus()
	return self.is_right_target
end

--获取战斗回合
function BattleModel:getFightRound()
	return self.fight_round
end

-- 获取当前出手次数
function BattleModel:getFightActionCount()
	return self.action_count
end

--用于设置buff列表
--[[	@data:buff数据
]]
function BattleModel:setBuffsList(data)
	self.buffs = data
end
--用于标记多波怪物的状态
function BattleModel:setNextMonStatus(bool)
	self.is_next_mon = bool
end
--获取多波怪物状态标记
function BattleModel:getNextMonStatus()
	return self.is_next_mon
end

--设置是否加速状态下
function BattleModel:setDoubleSpeedStatus(bool)
	self.is_double_speed = bool
end

--获取当前战斗类型
function BattleModel:getBattleType()
	return self.fight_type
end

function BattleModel:setBattleType(fight_type)
	self.fight_type = fight_type
end

--正常回合播报过来设置变量
--[[		@bool:ture为回合播报,false是正常播报
]]
function BattleModel:setUseSkillStatus(bool)
	self.is_battle_type = bool
end

--获取播报类型
function BattleModel:getUseSkillStatus()
	return self.is_battle_type
end

--获取总回合数
function BattleModel:getTotalWave()
	return self.total_wave
end


--获取战斗开始时间戳
function  BattleModel:getBattleTimeStamp()
	return self.start_battle_timestamp or 0
end

--保存战斗中敌方id,srv_id
function BattleModel:saveEnemyInfo(info)
	self.enemy_info = info
end

function BattleModel:getEnemyInfo()
	if self.enemy_info then
		return self.enemy_info
	end
end


function BattleModel:setSpecialEnemyData(bool,data)
	self.is_show_special = bool
	self.special_enemy_data = data
end

-- 根据战斗类型获取是否可以改变战斗速度
function BattleModel:checkIsCanChangeBattleSpeed( battle_type, show_tips )
	-- 录像可以随意切换倍速
	if self.battle_controller:getWatchReplayStatus() then
		return true
	end
	-- 优先判断变速条件
	local next_speed = 1
	if self.battle_speed == 1 then
		next_speed = 2
	end
	local speed_config = Config.CombatTypeData.data_combat_speed[next_speed]
	local role_vo = RoleController:getInstance():getRoleVo()
	if speed_config and role_vo.lev < speed_config.limit_lev and role_vo.vip_lev < speed_config.limit_vip_lev then
		if show_tips then
			message(string.format(TI18N("等级达到%d级或VIP%d开启"), speed_config.limit_lev, speed_config.limit_vip_lev))
		end
		return false
	end

	-- 再判断是否为某些不能开启变速的战斗  加了三倍速后 就去掉此功能判断了 --by lwc
	-- local fight_config = Config.CombatTypeData.data_fight_list[battle_type]
	-- if fight_config and fight_config.is_pvp == 1 then
	-- 	if show_tips then
	-- 		message(string.format(TI18N("%s不能更改速度"), fight_config.des))
	-- 	end
	-- 	return false
	-- end
	return true
end

--根据阵营数据返回阵营数据对应的阵营buff奖励
function BattleModel:getFormIdListByCamp(dic_camp)
	if dic_camp and next(dic_camp) ~= nil then
		local dic_form_id = {}
		local table_insert = table.insert
	    local configs = Config.CombatHaloData.data_halo
	    local dic_filter = {}
	    for i,config in ipairs(configs) do
	        local is_match = true
	        for i,v in ipairs(config.pos_info) do
	            local camp_type = v[1]
	            local camp_num = v[2]
	            if not dic_camp[camp_type] or dic_camp[camp_type] ~= camp_num then
	                is_match = false
	            end 
	        end
	        if is_match then
	            dic_form_id[config.id] = config.id
	            if config.condition ~= 0 then
		            dic_filter[config.id] = config.condition --过滤条件
		        end
	        end
	    end
	    --过滤
	    for id,condition in pairs(dic_filter) do
	    	if dic_form_id[condition] then
	    		dic_form_id[id] = nil
	    	end
	    end
	    local form_id_list = {}
	    for _,id in pairs(dic_form_id) do
	    	table_insert(form_id_list, id)
	    end
	    table.sort(form_id_list, function(a, b) return a < b end)
	    return form_id_list
	end
	return {}
end

-- 根据激活的阵营id获取对应光环数据
function BattleModel:getCampIconConfigByIds( id_list )
	if not id_list or next(id_list) == nil then return end
	local len = #id_list
	if len == 1 then
		local id = id_list[1]
		return Config.CombatHaloData.data_halo_icon[id]
	else
		table.sort(id_list, function(a, b) return a < b end)
		local id
		if len == 2 then
			id = id_list[1]*100 + id_list[2]
		else
			id = id_list[1]*10000 + id_list[2]*100 + id_list[3]
		end
		return Config.CombatHaloData.data_halo_icon[id]
	end
end

-- 是否为精灵或者神器
function BattleModel:checkIsHallowsOrElfin(object_type)
	if object_type == BattleObjectType.Hallows or object_type == BattleObjectType.Elfin then
		return true
	end
	return false
end

------------------------------------剧情相关
--==============================--
--desc:剧情控制移除一个剧情单位
--time:2017-06-03 11:32:51
--@id:
--return
--==============================---
function BattleModel:removeUnit(id)
	if self.story_unit_list == nil or self.battle_scene == nil then return end
	local vo = self.story_unit_list[id]
	if vo == nil then return end
	self.story_unit_list[id] = nil
	self.battle_scene:removeUnit(id)
end

--==============================--
--desc:创建一个剧情单位
--time:2017-06-03 11:33:34
--@vo: {id, x, y, dir, name}
--return
--==============================--
function BattleModel:addUnit(data)
	if self.battle_scene == nil then return end

	if self.story_unit_list == nil then
		self.story_unit_list = {}
	end
	if self.story_unit_list[data.id] ~= nil then return end

	local vo = UnitVo.New()
	vo.type = UnitVo.type.NPC
	vo:initAttributeData(data)
	self.story_unit_list[data.id] = vo
	self.battle_scene:addUnit(vo)
end

--==============================--
--desc:获取剧情创建的单位
--time:2017-06-03 11:45:21
--@id:
--return
--==============================--
function BattleModel:getUnitById(id)
	if self.story_unit_list == nil or self.battle_scene == nil then return end
	local vo = self.story_unit_list[id]
	if vo == nil then return end
	if tolua.isnull(self.battle_scene) then return  end
	return self.battle_scene:getUnitById(id)
end

-- 获取配置表中配置的战斗模型缩放比例
function BattleModel:getBattleSpineScale(  )
	if self.battle_spine_scale == nil then
		self.battle_spine_scale = self.battle_controller:getActTime("spine_scale")
	end
	return self.battle_spine_scale or 1
end

-----------------多战斗相关
-- 设置是否还有未完成的战斗
function BattleModel:setUnfinishedWarStatus( combat_type, status )
	self.unfinished_war_list = self.unfinished_war_list or {}
	self.unfinished_war_list[combat_type] = status
end

-- 根据战斗类型判断是否还有未完成的战斗
function BattleModel:checkIsHaveUnfinishedWar( combat_type )
	local is_have = false
	if self.unfinished_war_list and self.unfinished_war_list[combat_type] == 1 then
		is_have = true
	end
	return is_have
end
-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      新版挂机战斗主逻辑
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleHookModel = BattleHookModel or BaseClass()

function BattleHookModel:__init()
    self.act_playing = false
    self.is_init = false
    self.actor_plays_list = {} 
    self.is_set_battle_type = false
    self.all_object = {}
end

function BattleHookModel:initConfig()
    self.ctrl = BattleController:getInstance()
    self.battle_model = BattleController:getInstance():getModel()
end

--创建人物
function BattleHookModel:battleNormalStart(data)
    self.all_object             = {} --所有人物
    self.group                  = 0
    self.act_playing            = false
    self.one                    = nil  --每个效果数据
    self.round_data             = {} --回合数据
    self.round_data_temp        = {} --临时保存过期的回合数据
    self.sum                    = 0 --准备人员统计
    self.actor_sum              = 0 --施法者总数
    self.actor_play_sum         = 0 --施法者动作完成总数
    self.our_num                = 0 --自己总数
    self.is_real_battle_ready   = false
    self.res_num                = 0
    self.res_list               = {}
    if data then
        self:createBattleRole(data)
    end
end

function BattleHookModel:playEnd(die_pos)
    if self.all_object and next(self.all_object or {}) ~= nil then
        BattleLoop2.playEnd(die_pos)
        if self.all_object[die_pos] ~= nil then
            self.all_object[die_pos]:exitdeleteRole()
        end
        self.all_object[die_pos] = nil
        for k, v in pairs(self.all_object) do
            if self.actor_plays_list[v.pos] and next(self.actor_plays_list[v.pos]) ~= nil then
                table.remove(self.actor_plays_list[v.pos], 1)
                local temp_data = self.actor_plays_list[v.pos][1]
                if temp_data then
                    self:handleSkillPlayData(temp_data)
                end
            end
        end
    end
end

--回合播报
function BattleHookModel:round()
    --清掉回合临时数据
    self.round_data_temp = {}
    self.second_data = nil
    self.actor_sum = 0
    self.actor_play_sum = 0
    --通知服务器播放完成
    if tableLen(self.order_list or {}) == 0 then
        --清除黑屏
        self.battle_model:cancleBlackScreen()
        if not self.is_real_battle_ready then
            self.act_playing = false
        end
    else
        if not self.is_set_battle_type and BattleController:getInstance():getIsNoramalBattle() then
            self.ctrl:setExtendFightType(self.ctrl:getCurFightType())
            self.is_set_battle_type = true
        end
        self.one = table.remove(self.order_list, 1)
        local round_data = self.round_data[self.one.order]
        if next(self.order_list or {}) ~= nil then
            local second_order = self.order_list[1].order
            self.second_data = self.round_data[second_order]
        end
        for _, round_one in pairs(round_data or {}) do
            for _, round_one_temp in pairs(round_one or {}) do
                --如果效果有,则执行动作
                if #round_one_temp.target_list > 0 then
                    local attacker
                    if next(self.all_object or {}) ~= nil and self.all_object[round_one_temp.actor] then
                        self.one.actor = round_one_temp.actor
                        self.actor_sum = self.actor_sum + 1
                        attacker = self.all_object[round_one_temp.actor]
                        if attacker and attacker.spine_renderer then
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

--协议返回数据
function BattleHookModel:openNormalBattle(data, is_again)
    self.battle_model:clearAllObject()
    self:clearRole()
    self.is_set_battle_type = false
    if next(self.all_object or {}) == nil then
        self:startBattle(data, is_again)
    else
        self.battle_model:clearAllObject()
        self:clearAllObject(false, data)
    end
end

function BattleHookModel:startBattle(data, is_again)
    self.res_num = 0
    if data then
        if self.battle_scene and not tolua.isnull(self.battle_scene) then
            self.ctrl:setIsNormaBattle(true)
            if not is_again then
               GlobalEvent:getInstance():Fire(
                SceneEvent.ENTER_FIGHT,
                BattleConst.Fight_Type.Nil,
                BattleController:getInstance():getIsNoramalBattle()
                )
            end

            self.battle_scene:setbattleModel(self.ctrl:getNormalModel())
            self.battle_scene:setMoveMapStatus(true)
            self.ctrl:getCtrlBattleScene():MapMovescheduleUpdate()
          
            self.ctrl:setBattleStartStatus(true)
            self.ctrl:getCtrlBattleScene():handleLayerShowHide(true)
            self:battleNormalStart(data)
            self.is_init = true
        end
    end
end

function BattleHookModel:handleSkillPlayData(data)
    self.round_data = {}
    self.skill_plays_order_list = {}
    self.order_list = {}
    self.act_playing = false
    if data then
        self:playSkillPlayData(data)
    end
end


function BattleHookModel:getSkillPlayData(target)
    if self.actor_plays_list[target] then
        return self.actor_plays_list[target]
    end
end

function BattleHookModel:updateActorPlaysList(data)
    if data then
        if not self.actor_plays_list[data.actor] then
            self.actor_plays_list[data.actor] = {}
        end
        table.insert(self.actor_plays_list[data.actor], data)
    end
end

function BattleHookModel:playSkillPlayData(data)
    if data and (data.skill_plays or {}) ~= nil then
        for _, v in ipairs(data.skill_plays) do
            if next(v.effect_play or {}) ~= nil then
                for i, v1 in ipairs(v.effect_play) do
                    if self.round_data_temp then
                        if self.round_data_temp[v.order] == nil then
                            self.round_data_temp[v.order] = {}
                            table.insert(self.skill_plays_order_list, { skill_order = v.order })
                        end
                    end
                    v1.skill_bid = v.skill_bid
                    v1.index = i
                    v1.skill_order = v.order
                    v1.talk_content = v.talk_content
                    v1.talk_pos = v.talk_pos
                    if self.round_data_temp then
                        table.insert(self.round_data_temp[v.order], v1)
                    end
                end
            end
        end
        table.sort(self.skill_plays_order_list, function(a, b)
            return a.skill_order < b.skill_order
        end)
    end
    if next(self.round_data_temp or {}) ~= nil then --判断是否存在播报
        if next(self.skill_plays_order_list) ~= nil then
            for _, one in pairs(self.skill_plays_order_list) do
                local temp = self.round_data_temp[one.skill_order]
                if temp then
                    for _, one_temp in pairs(temp) do
                        if self.round_data[one_temp.order] == nil then
                            self.round_data[one_temp.order] = {}
                            table.insert(self.order_list, { order = one_temp.order,target = one_temp.target })
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
                            object.target = one_temp.target
                            object.skill_bid = one_temp.skill_bid
                            object.index = one_temp.index
                            object.talk_content = one_temp.talk_content
                            object.talk_pos = one_temp.talk_pos
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
                return a.order < b.order
            end)
            self.round_data_temp = {}
        end
    end
    if self.round_data then
        self:round()
    end
end

--战斗地图赋值
function BattleHookModel:createBattleScence(data)
    if not self.start then
        self.battle_scene = self.ctrl:getCtrlBattleScene()

        if not self.battle_scene then
            self.ctrl:createMap(data, BattleConst.Fight_Type.Darma)
        end
        if self.battle_scene then
            self:openNormalBattle(data)
            self.battle_scene:updateBtnLayerStatus(true)
        end
    end
end

function BattleHookModel:createBattleRole(data)
    print("创建战斗人物")
    if self.battle_scene and not tolua.isnull(self.battle_scene) then
        if not data then return end
        --创建己方角色
        self.sum = 0
        self.our_num = tableLen(data.objects or {})
        for i, v in pairs(data.objects or {}) do
            self.group = v.group
            self:addBattleRole(v, data.comabt_type)
        end
        for i, v in pairs(data.target_list or {}) do
            self:addBattleRole(v, data.combat_type)
        end
    end
end


function BattleHookModel:addBattleRole(data, combat_type,is_next_offset)
    if not BattleController:getInstance():getIsNoramalBattle() then
        return
    end
    local time_scale = self:getTimeScale()
    local role = BattleHookRole.New(data, combat_type, time_scale, is_next_offset)
    if next(self.all_object or {}) ~= nil and self.all_object then
        self.all_object[role.pos] = role
    end
end


--获取group
function BattleHookModel:getGroup()
    return self.group
end

--角色出场准备好了
function BattleHookModel:roleReady(role)
    if self.all_object == nil then return end
    if not self.all_object[role.pos] then
        self.all_object[role.pos] = role
    end
end

--初始化动作列表
--[[	@attacker:施法者
	@one:回合数据
]]
function BattleHookModel:initOrder(attacker, one)
    if (not attacker.spine_renderer or attacker.spine_renderer.in_act) and self.battle_scene then
        attacker.error_time = (attacker.error_time or 0) + 1
        if attacker.error_time < 5 then
            delayRun(self.battle_scene, 0.5, function()
                self:initOrder(attacker, one)
            end)
        else
            attacker.in_act = false
        end
    end
    table.sort(one.target_list, function(a, b) --先根据index重新排序
        return a.index < b.index
    end)
    local list = deepCopy(one.target_list)
    table.sort(list, function(a, b) --先根据index重新排序
        return a.target < b.target
    end)
    local col_target = list[1].target

    if col_target > 9 then
        col_target = col_target - GIRD_POS_OFFSET
    end
    local col = pos_to_col[col_target]
    attacker.col = col
    attacker.error_time = 0
    attacker.is_round = false  --没播放完成
    attacker.attacker_info = one --攻击者信息
    attacker.skill_data = Config.SkillData.data_get_skill(one.skill_bid) --技能信息
    --攻击者位置
    attacker.target_pos = { x = attacker.grid_pos.x, y = attacker.grid_pos.y }
    --计算目标中点位置
    self.battle_model:calcTargetPos(attacker, self.all_object)

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
    if attacker.play_order_index == nil or attacker.play_order_index == 0 then --如果效果ID为0或者空值返回
        self:round()
        return
    end

    local effect_config = Config.SkillData.data_get_effect(attacker.play_order_index) 
    if effect_config then
        attacker.play_order = deepCopy(effect_config.action_list)											            --动作列表

        attacker.shake_id = effect_config.shake_id or 0 													            --震屏ID
        attacker.effect_type = effect_config.effect_type or 1 												            --效果类型
        attacker.act_hurt_type = effect_config.act_hurt_type or 0 											            --受击表现
        attacker.play_stand = effect_config.play_stand or 1													            --群攻时候是否收招
        attacker.attack_sound = effect_config.attack_sound or ""											            --攻击音效
        attacker.ready_sound = effect_config.ready_sound or ""												            --起手音效
        attacker.anime_res = effect_config.anime_res or ""													            --模型id,模型文件名
        attacker.split_hurt = effect_config.split_hurt or 1													            --多段攻击次数
        attacker.hit_action = effect_config.hit_action or ""												            --受击回调函数
        attacker.effect_desc = effect_config.effect_desc or ""												            --效果描述
        attacker.is_must_die = effect_config.is_must_die or 0												            --死亡移除
        attacker.shout_trick = effect_config.shout_trick or ""												            --喊招音效
        attacker.hit_sound = effect_config.hit_sound or "" 													            --受击音效
        attacker.is_move_map = effect_config.is_move_map or 0												            --是否移动地图
        attacker.anime_user_atk = effect_config.anime_user_atk or ""										            --攻击动作

        attacker.hit_effect_list = deepCopy(self.battle_model:getCurEffectList(effect_config.hit_effect_list)) 			--记录打击特效列表
        attacker.area_effect_list = deepCopy(self.battle_model:getCurEffectList(effect_config.area_effect_list)) 		--记录范围人物特效
        attacker.act_effect_list = deepCopy(self.battle_model:getCurEffectList(effect_config.act_effect_list)) 			--记录出手点特效
        attacker.bact_effect_list = deepCopy(self.battle_model:getCurEffectList(effect_config.bact_effect_list)) 		--记录施法特效
        attacker.trc_effect_list = deepCopy(self.battle_model:getCurEffectList(effect_config.trc_effect_list)) 		    --记录弹道特效
    end
    --判断是否存在群攻魔法
    if next(attacker.area_effect_list or {}) ~= nil then
        attacker.attacker_info.is_calc = false
        attacker.in_area_effect = true
        attacker.area_hit_num = 1
        attacker.area_hit_time = 0
    else
        attacker.in_area_effect = false
    end
    --播放动作函数
    local start_attack = function()
        self:playOrder(attacker)
    end
    local show_skill_name = function()
        if attacker.skill_data then
            start_attack()
        end
    end
    if one.skill_bid == 0 then --不需要喊招表现
        self:talk(attacker, start_attack)
    else
        self:talk(attacker, show_skill_name)
    end
    self.act_playing = true
end

--按动作顺序执行动作
--[[	@attacker:动作施法者
]]
function BattleHookModel:playOrder(attacker)
    attacker.wait_act = 0
    if self.is_real_battle_ready == true or self.is_init == false then
        return
    end
    if attacker.play_order_index == nil or attacker.play_order_index == 0 then
        return
    end
    local act
    if attacker and (nil == attacker.play_order or #(attacker.play_order) == 0) or not attacker.spine_renderer then --判断是否还有动作进行
        self.actor_play_sum = self.actor_play_sum + 1
        if attacker.play_order_index == 0 then
            attacker.play_order_index = nil
            self:hurt(attacker, self.all_object) --攻击
        end
        if not attacker.is_die then
            attacker:resetZOrder()
            
            if self.second_data then
            else
                self.end_round_black = true
                if attacker.spine_renderer:getActionName() ~= PlayerAction.run then
                    SkillAct.setAnimation(attacker.spine_renderer, PlayerAction.run, true)
                end
            end
        end
        if not attacker.is_round then --播放完动作后结束界面
            if self.actor_play_sum >= self.actor_sum then --判断该播报的所有施法者都播放完成
                self:round() --播放完,执行下一轮动作
            end
        end
    else --逐个动作播放
        local index = attacker.play_order[1]
        table.remove(attacker.play_order, 1)
        act = self.battle_model:singleAct(index, attacker, true)
        if not tolua.isnull(attacker.spine_renderer.root) then
            attacker.spine_renderer:runAction(act)
        end
    end
end

--播放魔法效果
function BattleHookModel:playMagic(attacker, effect_play, no_die)
    if self.battle_scene == nil or tolua.isnull(self.battle_scene) then return end	-- 主战斗场景都没有了就不需要做下面判断了
    local effect_hit = 1
    local magic_hurt = false
    if next(self.all_object or {}) ~= nil and self.all_object then
        if self.all_object == nil or effect_play.target == nil then return end
        if self.all_object and effect_play.target ~= nil and self.all_object[effect_play.target] then
            local target = self.all_object[effect_play.target]
            local hurt = effect_play.hurt or 0
            if target and target.spine_renderer and not tolua.isnull(target.spine_renderer.root) then

                local dmg = effect_play.hurt

                if effect_play.play_num == nil then
                    effect_play.play_num = attacker.split_hurt or 1
                end
                if attacker.split_hurt > 1 then -- 需要拆分伤害效果
                    local index = attacker.split_hurt - effect_play.play_num + 1
                    local percent = attacker.damageSeg[index]
                    dmg = math.ceil( (effect_play.hurt or 0) * percent )
                    -- print("hook_one_hp_change", effect_play.hurt, effect_play.play_num, dmg)
                end
                effect_play.play_num = effect_play.play_num or 1
                effect_play.play_num = effect_play.play_num - 1

                local is_die = 0
                if effect_play.hp <= 0 then
                    is_die = 1
                end
                -- if effect_play.is_crit == 1 then --暴击的时候
                --     effect_hit = 2
                -- end
                self.battle_model:updateTargetHp(attacker, target, dmg, is_die, effect_hit, effect_play)
                local hurt_do_fun = function()
                    if not target.is_hurt_play then
                        target.is_hurt_play = true
                        if not target.is_big_play then
                            self.battle_model:playHurtEffect(attacker, target)                         -- 播放伤害魔法效果
                        end
                        if (attacker.pos ~= target.pos and dmg <= 0) and attacker.group ~= target.group then
                            local hit_action = attacker.hit_action
                            if hit_action ~= "no-hurt" then
                                SkillAct.hurt(attacker, target.spine_renderer, target, hit_action)
                            end
                        end
                    end
                end
                if attacker then  -- 扣血
                    hurt_do_fun()
                end
            end
        end
    end
end

--说话内容处理
--[[	@attakcer:施法者
	@callback:回调
	@act_playing:是否动作中
]]
function BattleHookModel:talk(attacker, callback)
    local msg = attacker.attacker_info.talk_content or ""
    local actor = attacker.attacker_info.talk_pos
    if msg == "" or self.act_playing == true then
        if callback then
            callback()
        end
        return
    end
    msg = string.gsub(msg, "#name#", "")
    local data = WordCensor:getInstance():relapceFaceIconTag(msg)             -- 处理表情符转换
    StoryController:getInstance():getView():showBubble(2, actor, data[2], 0, nil, 1)
    if callback then
        callback()
    end
end

function BattleHookModel:updateNextRoundData(next_type)
    if BattleController:getInstance():getIsNoramalBattle() then
        local target_list = {}
        local next_data = BattleLoop2.nextTarget(next_type)
        if next_data then
            local move_time = self:getMoveTime(next_data.actor,next_data.effect_bid)
            table.insert(target_list,next_data)
            if self.all_object == nil or target_list == nil then
                return
            end
            ---delayOnce(function ()
                --下一帧创建人物
                if self.battle_scene and not tolua.isnull(self.battle_scene) then
                    for _, v in pairs(target_list or {}) do
                        local next_col = pos_to_col[v.pos - GIRD_POS_OFFSET]
                        if v.group == 2 then
                            self:addBattleRole(v,BattleConst.Fight_Type.Nil,self:checkColObjet(next_col))
                        end
                    end
                end
            --end,0.1)
        end
    end
end

function BattleHookModel:setAckMoveTime(time)
    self.move_time = time
end

function BattleHookModel:getFinalMoveTime()
    return self.move_time or 12 / display.DEFAULT_FPS
end

function BattleHookModel:getMoveTime(actor,play_order_index)
    local move_time = 12
    if Config.SkillData.data_get_effect(play_order_index) then
        local skill_config = Config.SkillData.data_get_effect(play_order_index)
        local is_move_map = skill_config.is_move_map or FALSE --是否触碰back点
        local play_order_anime_res = skill_config.anime_res
        local res = 0
        if self.all_object and next(self.all_object or {}) ~= nil then
            self.cur_role = self.all_object[actor]
            if self.cur_role then
                res = self.cur_role.res
            end
        end
        if is_move_map == FALSE then
            local config = Config.BattleActData.data_info[res] or Config.BattleActData.data_info[0]
            if config then
                local anima_res_config = config[play_order_anime_res] or Config.BattleActData.data_info[0]["action1"]
                if anima_res_config then
                    local temp_config = anima_res_config[skill_config.anime_user_atk] or anima_res_config["action1"]
                    if temp_config == nil then
                        temp_config = Config.BattleActData.data_info[0]["action1"]["action1"]
                    end
                    if temp_config then
                        move_time = temp_config.move_delay_time + temp_config.move_time
                    end
                end
            end
        end
    end
    self:setAckMoveTime(move_time / display.DEFAULT_FPS)
end

--判断当前pos的行上是否已经有单位
function BattleHookModel:checkColObjet(col)
    if self.all_object then
        local is_has = false
        for k, role in pairs(self.all_object or {}) do
            if role ~= nil and role.group == 2 then
                local cur_col = pos_to_col[role.pos - GIRD_POS_OFFSET]
                if cur_col == col then
                    is_has = true
                end
            end
        end
        return is_has
    end
end

--停止跑动
function BattleHookModel:updateStop()
    if self.all_object then
        for k, role in pairs(self.all_object or {}) do
            if role ~= nil and role.spine_renderer ~= nil and role.spine_renderer.is_die == false then
                --if role.group == 1 then
                role.spine_renderer:doStand(true)
                if role.group == 2 then
                    role.spine_renderer:reverse()
                end
            end
        end
    end
end

--==============================--
--desc:战斗的主入口,切换真假战斗或者直接进战斗
--time:2018-09-07 12:06:39
--@data:
--@return 
--==============================--
function BattleHookModel:chanegBattle(data)
    if data then
        self.is_real_battle_ready = true
        self:handleChangeBattle(data)
    end
end

function BattleHookModel:handleChangeBattle(data)
    if not BattleController:getInstance():getModel():getReconnectStatus() then
        if self.battle_scene and not tolua.isnull(self.battle_scene) then
            self.battle_scene:setMoveMapStatus(false)
        end
        if self.ctrl:getCtrlBattleScene() and not tolua.isnull(self.ctrl:getCtrlBattleScene()) then
            self.ctrl:getCtrlBattleScene():unMapMovescheduleUpdate()
            self.ctrl:getCtrlBattleScene():handleLayerShowHide(false)
        end
        self:clearAllObject(true, data)
    else
        self.ctrl:openBattleScene(data)
    end
end

function BattleHookModel:setRes(json_path)
    if not self.res_list then
        self.res_list = {}
    end
    self.res_list[json_path] = true
end

-- 资源加载开始
function BattleHookModel:resLoadStart(json_path)
    if not self.res_list then
        self.res_list = {}
    end
    if self.res_list[json_path] then
        return false
    end
    self.res_num = self.res_num + 1
    self.res_list[json_path] = true
    return true
end

function BattleHookModel:clearAllObject(is_change_battle, data)
    local delete_num = 0
    if next(self.all_object or {}) == nil then
        if is_change_battle then
            self:clearRole()
            self.ctrl:openBattleScene(data)
        end
    else
        local sum = tableLen(self.all_object or {})
        for i, v in pairs(self.all_object or {}) do
            SkillAct.clearAllEffect(v.spine_renderer)
            if v.spine_renderer and v.spine_renderer.root and not tolua.isnull(v.spine_renderer.root) then
                v.spine_renderer:setVisible(false)
                v.spine_renderer:realrelease(true)
                self.all_object[v.pos] = nil
            end
        end
        self:clearRole()
        if not is_change_battle then
            self.battle_scene:setMoveMapStatus(false)
            self:startBattle(data)
        else
            self.ctrl:openBattleScene(data)
        end
    end
end


function BattleHookModel:getInitNormalStatus()
    return self.is_init
end


function BattleHookModel:isInFight()
    return BattleController:getInstance():getBattleStatus()
end

--获取人物所有列表
function BattleHookModel:getAllObject()
    return self.all_object
end

function BattleHookModel:clearRole()
    for _, v in pairs(self.all_object or {}) do
        if v.spine_renderer and not tolua.isnull(v.spine_renderer.root) then
            v.spine_renderer.root:stopAllActions()
            v.spine_renderer:setVisible(false)
            v.spine_renderer:realrelease(true)
            self.all_object[v.pos] = nil
        end
    end
    self.all_object = {}
    self.actor_plays_list = {}
    self.actor_target_list = {}
    self.sum = 0
    self.is_init = false
    if BattleController:getInstance():getCtrlBattleScene() then
        BattleController:getInstance():getCtrlBattleScene():unMapMovescheduleUpdate()
    end
end

function BattleHookModel:battleclear()
    self.act_playing = false
    self.start = false
    self.skill_plays_order_list = {}
    self.round_data = {}
    if next(self.all_object or {}) ~= nil and self.all_object then
        for _, v in pairs(self.all_object or {}) do
            v:exitdeleteRole()
        end
    end
    self.ctrl:setBattleStartStatus(false)
    self.ctrl:setIsNormaBattle(false)
    self:clearRole()
    self.is_init = false
    GlobalEvent:getInstance():Fire(SceneEvent.EXIT_FIGHT, BattleConst.Fight_Type.Nil)
    if BattleController:getInstance():getCtrlBattleScene() then
        BattleController:getInstance():getCtrlBattleScene():unMapMovescheduleUpdate()
    end
end

function BattleHookModel:getTimeScale()
    if self.time_scale == nil then
        self.time_scale = BattleController:getInstance():getActTime("base_speed_scale")
    end
    return self.time_scale or 1.1
end

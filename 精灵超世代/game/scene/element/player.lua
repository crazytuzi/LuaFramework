-- --------------------------------------------------------------------
-- 角色数据,暂时考虑到只作用于众神战场上吧
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

Player = Player or BaseClass(SceneObj)

function Player:__init(is_hero)
	is_hero = is_hero or false
	self.is_hero = is_hero
    self.isRuning = false
    self.isNeedRun = false	

    self.move_start_pos = cc.p(0,0)
    self.move_end_pos = cc.p(0,0)
    self.move_total_distance = 0 
    self.move_pass_distance = 0
    self.move_dir = cc.p(0,0)
    self.move_speed = 0

    self.dir_number = 0
end

function Player:setVo(value)
	SceneObj.setVo(self, value)
    self.dir_number = self.vo.dir

	self:setBattleStatus(self.vo.status)
	self:setEffectStatus(self.vo.effect)
	self:setSkillStatus(self.vo.skill_effect)
	-- self:setSelfEffectStatus(self.is_hero)

	if self.update_self_event == nil then
		if self.vo ~= nil then
			self.update_self_event = self.vo:Bind(SceneEvent.UPDATE_UNIT_ATTRIBUTE, function(key, value)
				if key == "status" then  -- 255 加速 256 护盾
					self:setBattleStatus(self.vo.status)
				elseif key == "effect" then
					self:setEffectStatus(self.vo.effect)
				elseif key == "skill_effect" then
					self:setSkillStatus(self.vo.skill_effect)
				end
			end)
		end
	end
end

--==============================--
--desc:移动
--time:2017-09-11 05:40:51
--@start_pos:
--@end_pos:
--@return 
--==============================--
function Player:doMove(start_pos, end_pos)
	if start_pos == nil then
		start_pos = self.world_pos
	end
	if start_pos.x == end_pos.x and  start_pos.y == end_pos.y then return end
	self:setWorldPos(start_pos)
	local vo = self.vo
	if vo then
        local speed_add = (1- (1-FPS_RATE)*0.5)
		self.move_speed = math.min(20, (self.mechine_speed + vo.speed / speed_add))
	end
	
	self.move_pass_distance = 0
	self.move_total_distance = 0
	self.move_start_pos = start_pos
	self.move_end_pos = end_pos
	self.dir_number, self.move_total_distance, self.move_dir = self:computeMoveInfo(end_pos)
	self.isNeedRun = true
	self:doRun()
end

--==============================--
--desc:停止移动
--time:2017-09-11 05:41:20
--@return 
--==============================--
function Player:stopMove()
    if not self.isRuning then return end
	self.isRuning = false
	self.isNeedRun  = false
	self:doStand()
end

--==============================--
--desc:计算朝向,其实只有2个方向
--time:2017-09-11 05:41:32
--@end_pos:
--@return 
--==============================--
function Player:computeMoveInfo(end_pos)
    local cur_start_pos = cc.p(self.world_pos.x, self.world_pos.y)
    local cur_end_pos = end_pos
	local state_move_dir = cc.pSub(cur_end_pos, cur_start_pos)
	local distance = cc.pGetLength(state_move_dir)
	state_move_dir = cc.pNormalize(state_move_dir)
 	local dir_number = GameMath.GetDirectionNumberHV(state_move_dir)
 	return dir_number, distance, state_move_dir
end

--==============================--
--desc:检测状态
--time:2017-09-11 05:42:12
--@dt:
--@step:
--@return 
--==============================--
function Player:update(dt, step)
	if self.isNeedRun then
		self:step(dt)
    end
	SceneObj.update(self,dt)
	self:updateNamePos()
end

function Player:step( dt )
	local vo = self.vo
	if self.move_pass_distance >= self.move_total_distance then
		self.move_pass_distance = 0
		local pos = cc.p(self.move_end_pos.x, self.move_end_pos.y)
		self.isRuning = false
		self.isNeedRun  = false
		if self.vo.is_speed_up == false then
			self:doStand()
		end
	else
		self.move_pass_distance = math.min(self.move_pass_distance + self.move_speed, self.move_total_distance)
		local mov_dir = cc.pMul(self.move_dir, self.move_pass_distance) 
		local now_pos = cc.p(self.move_start_pos.x, self.move_start_pos.y)
		now_pos = cc.pAdd(now_pos, mov_dir)
        now_pos.x = now_pos.x
        now_pos.y = now_pos.y
		self:setWorldPos(now_pos)
		self.isRuning = true
		local vo = self.vo
		if vo then
	        local speed_add = (1- (1-FPS_RATE)*0.5)
			self.move_speed = math.min(20, (self.mechine_speed + vo.speed / speed_add))
		end
	end
end

--==============================--
--desc:设置战斗状态
--time:2017-09-13 10:50:10
--@status:
--@return 
--==============================--
function Player:setBattleStatus(status)
	if status == GodBattleConstants.role_status.fight then
		local effect_id = PathTool.getEffectRes(186)
		if self.fightEffect == nil then
			self.fightEffect = createEffectSpine(effect_id, cc.p(0, 0), cc.p(0.5, 0), true)
			self.topContainer:addChild(self.fightEffect)

			self.fightEffect:update(0)
		end
	else
		if self.fightEffect ~= nil then
            self.fightEffect:runAction(cc.RemoveSelf:create())
			self.fightEffect = nil
		end
	end
	self:updateEffectPos()
end

--==============================--
--desc:众神之战的觉得战斗buff效果
--time:2017-09-13 04:47:25
--@status:
--@return 
--==============================--
function Player:setBattleBuff(status)
	if status == GodBattleConstants.buff.normal then
		if self.buffEffect ~= nil then
            self.buffEffect:runAction(cc.RemoveSelf:create())
			self.buffEffect = nil
		end
	else
		local config = nil
        if self.vo and self.vo.camp == GodBattleConstants.camp.god then
            if status == GodBattleConstants.buff.legendary then
                config = Config.ZsWarData.data_const["god_legendary"]
            end
        elseif self.vo and self.vo.camp == GodBattleConstants.camp.devil then
            if status == GodBattleConstants.buff.legendary then
                config = Config.ZsWarData.data_const["imp_legendary"]
            end
        end
		if config ~= nil then
			-- 如果是不同的特效,先移除掉,然后再添加吧
			if self.buffEffect ~= nil and self.buffEffect.name ~= config.val then
				if self.buffEffect ~= nil then
					self.buffEffect:runAction(cc.RemoveSelf:create())
					self.buffEffect = nil
				end
			end
			if self.buffEffect == nil then
                self.buffEffect = createEffectSpine(config.val, cc.p(0, 0), cc.p(0.5, 0), true)
                self.topContainer:addChild(self.buffEffect)
                self.buffEffect:update(0)
			end
		end
	end
    self:setBattleContLoseBuff(status)
	self:updateEffectPos()
end

--==============================--
--desc:众神之战的连败buff效果
--time:2017-09-13 04:47:25
--@status:
--@return 
--==============================--
function Player:setBattleContLoseBuff(status) 
	if status == GodBattleConstants.buff.cont_lose then
        if self.contLoseBuffEffect ~= nil then return end
		local config = nil
        if self.vo and self.vo.camp == GodBattleConstants.camp.god then
            if status == GodBattleConstants.buff.cont_lose then
                config = Config.ZsWarData.data_const["god_defeat"]
            end
        elseif self.vo and self.vo.camp == GodBattleConstants.camp.devil then
            if status == GodBattleConstants.buff.cont_lose then
                config = Config.ZsWarData.data_const["imp_defeat"]
            end
        end
		if config ~= nil then
            self.contLoseBuffEffect = createEffectSpine(config.val, cc.p(0, 10), cc.p(0.5, 1), true)
            self.bottom:addChild(self.contLoseBuffEffect, -99)
        end
    else
		if self.contLoseBuffEffect ~= nil then
            self.contLoseBuffEffect:runAction(cc.RemoveSelf:create())
			self.contLoseBuffEffect = nil
		end
    end
end

--==============================--
--desc:众神之战里面可能是变身效果,可能是特效
--time:2017-09-13 03:36:51
--@status:
--@return 
--==============================--
function Player:setEffectStatus(status)
	local role = RoleController:getInstance():getRoleVo()
	status = status or GodBattleConstants.buff.normal
	if status == GodBattleConstants.buff.normal then
		self:setBattleBuff(status)
		self:changePlayerBody(status)
	else
		if status == GodBattleConstants.buff.cont_win then -- 如果是连败,那么必然是要清除掉buff的
			self:setBattleBuff(GodBattleConstants.buff.normal)
			self:changePlayerBody(status)
		elseif status == GodBattleConstants.buff.camp_change then -- 如果是连败,那么必然是要清除掉buff的
			self:setBattleBuff(GodBattleConstants.buff.normal)
			self:changePlayerBody(status)
		else	-- 如果是连杀,必然需要清除掉变身
			self:setBattleBuff(status)
			self:changePlayerBody(GodBattleConstants.buff.normal)
		end
	end
end

--==============================--
--desc:根据众神之战里面的状态切换模型
--time:2017-09-13 04:43:41
--@return 
--==============================--
function Player:changePlayerBody(status)
	local role = RoleController:getInstance():getRoleVo()
	local config = nil
	if self.vo and self.vo.camp then
		if self.vo.camp == GodBattleConstants.camp.god then
			if status == GodBattleConstants.buff.normal then
				config = Config.ZsWarData.data_const["god_born"]
			elseif status == GodBattleConstants.buff.cont_win then
				config = Config.ZsWarData.data_const["god_change"]
			elseif status == GodBattleConstants.buff.camp_change then
				config = Config.ZsWarData.data_const["god_god"]
			end
		elseif self.vo.camp == GodBattleConstants.camp.devil then
			if status == GodBattleConstants.buff.normal then
				config = Config.ZsWarData.data_const["imp_born"]
			elseif status == GodBattleConstants.buff.cont_win then
				config = Config.ZsWarData.data_const["imp_change"]
			elseif status == GodBattleConstants.buff.camp_change then
				config = Config.ZsWarData.data_const["imp_god"]
			end
		end
	end
	if config ~= nil then
		if config ~= nil then
			if self.vo.body_res ~= config.val then
				self.vo.body_res = config.val
				if self.isNeedRun == true then
					self:playActionOnce(PlayerAction.run, self.vo.body_res)
				else
					self:playActionOnce(PlayerAction.battle_stand, self.vo.body_res)
				end
			end
		end
	end
end

--==============================--
--desc:自己的头顶指示
--time:2017-09-15 07:39:10
--@is_hero:
--@return 
--==============================--
function Player:setSelfEffectStatus(is_hero)
	if self.vo == nil or is_hero == false then 
		if self.own_mark_effect ~= nil then
			self.own_mark_effect:runAction(cc.RemoveSelf:create())
			self.own_mark_effect = nil
		end
	else
		if self.own_mark_effect == nil then
			local effect_id = PathTool.getEffectRes(122)
			if self.own_mark_effect == nil then
				self.own_mark_effect = createEffectSpine(effect_id, cc.p(0, 0), cc.p(0.5, 0), true)
				self.topContainer:addChild(self.own_mark_effect)
				self.own_mark_effect:update(0)
			end
		end
	end
	self:updateEffectPos()
end

--==============================--
--desc:技能效果
--time:2017-09-13 10:14:59
--@list:
--@return 
--==============================--
function Player:setSkillStatus(list)
	local is_speed_up = false
	local immune = false
    local dizzy = false
	
	for k,v in pairs(list) do
		if v.id == 1 then
			is_speed_up = true
		elseif v.id == 2 then
			immune = 2
		elseif v.id == 3 then
			dizzy = 3
		end
	end

	self:setSpeedUpStatus(is_speed_up)
	self:setImmuneStatus(immune)
	self:setDizzyStatus(dizzy)
end

--==============================--
--desc:设置加速状态
--time:2017-09-14 03:04:29
--@status:
--@return 
--==============================--
function Player:setSpeedUpStatus(status)
	if self.vo == nil then  return end
	if status == false then
		self.vo.speed = 1
		self.vo.is_speed_up = false
		if self.speed_up_effect ~= nil then
			self.speed_up_effect:runAction(cc.RemoveSelf:create())
			self.speed_up_effect = nil
		end
	else
		self.vo.speed = 1.2
		self.vo.is_speed_up = true
		local config = Config.ZsWarData.data_const["speed_up"]
		if self.speed_up_effect == nil and config ~= nil then
			self.speed_up_effect = createEffectSpine(config.val, cc.p(0, 30), cc.p(0.5, 0), true)
			self.spineContainer:addChild(self.speed_up_effect, 2)
		end
	end
end

--==============================--
--desc:设置免疫状态
--time:2017-09-14 03:08:01
--@status:
--@return 
--==============================--
function Player:setImmuneStatus(status)
	if self.vo == nil then  return end
	if status == false then
		if self.immune_effect ~= nil then
			self.immune_effect:runAction(cc.RemoveSelf:create())
			self.immune_effect = nil
		end
	else
		local config = Config.ZsWarData.data_const["shield"]
		if self.immune_effect == nil and config ~= nil then
			self.immune_effect = createEffectSpine(config.val, cc.p(0, 0), cc.p(0.5, 0), true)
			self.spineContainer:addChild(self.immune_effect, 3)
		end
	end
end

--==============================--
--desc:设置眩晕状态
--time:2017-09-14 03:08:01
--@status:
--@return 
--==============================--
function Player:setDizzyStatus(status)
	if self.vo == nil then  return end
	if status == false then
		if self.dizzy_effect ~= nil then
			self.dizzy_effect:runAction(cc.RemoveSelf:create())
			self.dizzy_effect = nil
		end
	else
		local config = Config.ZsWarData.data_const["attack_effect"]
		if self.dizzy_effect == nil and config ~= nil then
			self.dizzy_effect = createEffectSpine(config.val, cc.p(0, 0), cc.p(0.5, 0), true)
			self.topContainer:addChild(self.dizzy_effect, 0)
		end
	end
end

--==============================--
--desc:注册事件
--time:2017-09-11 05:43:48
--@return 
--==============================--
function Player:registEvent()
end

function Player:clickHandler()
end

function Player:__delete()
	self.dir_number = 0
	if self.vo ~= nil then
		if self.update_self_event ~= nil then
			self.vo:UnBind(self.update_self_event)
			self.update_self_event = nil
		end
		self.vo = nil
	end
end

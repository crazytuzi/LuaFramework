TestRole = TestRole or BaseClass(Role)

function TestRole:__init(vo)
	Role.__init(self, vo)

	-- 0 为战力，1 为行走，2 为战斗
	self.role_type = 0
	self.next_can_attack_time = 0
	self.atk_target = nil
	self.skill_id_list = {}
end

function TestRole:__delete()
	Role.__delete(self)

	self.role_type = 0
	self.next_can_attack_time = 0
	self.atk_target = nil
	self.skill_id_list = {}
end

function TestRole:Update(now_time, elapse_time)
	Role.Update(self, now_time, elapse_time)
	
	self:DoAttackObj()
end

function TestRole:SetTestMove()
	local main_role = Scene.Instance:GetMainRole()
 	if not main_role then return end
 	local role_pos_x, role_pos_y = main_role:GetLogicPos()
 	local random_x = math.floor(math.random(-30, 30)) + role_pos_x
 	local random_y = math.floor(math.random(-30, 30)) + role_pos_y
 	self.role_type = 1
 	self:DoMove(random_x, random_y)
end

function TestRole:QuitStateMove()
	self.draw_obj:StopMove()
	if self.has_craft then
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:RemoveModel(SceneObjPart.FightMount)
		self:RemoveModel(SceneObjPart.Mount) self.has_craft = false end, 0.2)
	end
	self.is_jump = false
	if self.role_type == 1 then
		self:SetTestMove()
	end
end

function TestRole:SetAttckerRole()
 	self.role_type = 2

 	local skill_all_list = {
 		{121, 131, 141, 151},
 		{221, 231, 241, 251},
 		{321, 331, 341, 351},
 		{421, 431, 441, 451},
 	}

 	self.skill_id_list = skill_all_list[self.vo.prof]
end

function TestRole:SetAtkTarget(target_robert)
	self.atk_target = target_robert
end

function TestRole:DoAttackObj()
	if self.role_type ~= 2 or self.atk_target == nil then
		return 
	end

	if Status.NowTime >= self.next_can_attack_time then
		self.next_can_attack_time = Status.NowTime + 1
		-- 停止采集
		self.last_skill_id = tonumber(self.skill_id_list[GameMath.Rand(1, #self.skill_id_list)]) or 0
		self:ReqFight(self, self.atk_target, self.last_skill_id, 0)
	end
end


-- 请求战斗，通过模防协议实现
function TestRole:ReqFight(attacker_robert, hiter_robert, skill_id, skill_index)
	if attacker_robert == hiter_robert or nil == attacker_robert or nil == hiter_robert then
		return
	end

	local protocol = SCPerformSkill.New()
	protocol.deliverer = attacker_robert:GetObjId()
	protocol.target = hiter_robert:GetObjId()
	protocol.skill = skill_id
	protocol.skill_data = skill_index or 0
	FightCtrl.Instance:OnPerformSkill(protocol)

	-- 部分技能要造成多次伤害(真实情况下是服务器发多次伤害，这里进行模拟)
	local hit_count = 1
	local hit_interval = 0.3

	function changeblood(attacker, hiter, skill_id, hit_count)
		if not self.is_playing 
			or nil == RobertManager.Instance:GetRobert(attacker:GetObjId())
		 	or nil == RobertManager.Instance:GetRobert(hiter:GetObjId())
		 	or attacker:IsDead()
		 	or hiter:IsDead() then
			return
		end

		local hurt = 10
		hurt = -1 * math.min(hurt, hiter:GetObj():GetVo().hp)
		local protocol = SCObjChangeBlood.New()
		protocol.obj_id = hiter:GetObjId()
		protocol.deliverer = attacker:GetObjId()
		protocol.skill = skill_id
		protocol.fighttype = FIGHT_TYPE.NORMAL
		protocol.product_method = 0
		protocol.real_blood = hurt
		protocol.blood = hurt
		protocol.passive_flag = 0
		FightCtrl.Instance:OnObjChangeBlood(protocol)

		hiter:OnBeHited()
	end

	GlobalTimerQuest:AddDelayTimer(function ()
		changeblood(attacker_robert, hiter_robert, skill_id, hit_count)
	end, hit_interval)
end

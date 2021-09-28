require("game/story/robert")
require("game/story/robert_ai/base_robert_ai")
require("game/story/robert_ai/active_attack_robert_ai")

RobertManager = RobertManager or BaseClass()

--普通技能(多段伤害)
local normal_skill_list = {
	[141] = 3,
	[221] = 3,
	[341] = 3,
	[441] = 3,
	[121] = 4,
	[231] = 4,
	[331] = 4,
	[431] = 4,
	[131] = 5,
	[241] = 5,
	[321] = 5,
	[421] = 5,
	[5] = 10,
}

function RobertManager:__init()
	if RobertManager.Instance ~= nil then
		ErrorLog("[RobertManager] attempt to create singleton twice!")
		return
	end
	RobertManager.Instance = self

	self.robert_role_cfg = ConfigManager.Instance:GetAutoConfig("story_auto")["robert_role"]
	self.robert_monster_cfg = ConfigManager.Instance:GetAutoConfig("story_auto")["robert_monster"]

	self.obj_id_inc = 100000
	self.robert_dic = {}
	self.is_playing = false

	self.end_die_robert_list = {}	-- 一场战斗结束需哪些机器人死亡
	self.fight_end_callback = nil	-- 一场战斗结束的回调
	self.fight_id_inc = 0			-- 发生的第几场战斗
	self.is_fighting = false 		-- 战斗是否在进行中
end

function RobertManager:__delete()
	for _, v in pairs(self.robert_dic) do
		v:DeleteMe()
	end
	self.robert_dic = {}

	Runner.Instance:RemoveRunObj(self)
	RobertManager.Instance = nil
end

function RobertManager:Clear()
	print_log("RobertManager:Clear")
	self.end_die_robert_list = {}
	self.fight_end_callback = nil
	self.is_fighting = false
	self.fight_id_inc = 0
	self:DelAllRobert()
end

function RobertManager:Start()
	if not self.is_playing then
		self.is_playing = true
		self:Clear()
		self:CreateMainRoleRobert(self.robert_role_cfg[0])
		Runner.Instance:AddRunObj(self, 8)
	end
end

function RobertManager:Stop()
	if self.is_playing then
		self.is_playing = false
		self:Clear()
		Runner.Instance:RemoveRunObj(self)
	end
end

function RobertManager:IsPlaying()
	return self.is_playing
end

function RobertManager:Update(now_time, elapse_time)
	for _, v in pairs(self.robert_dic) do
		v:Update(now_time, elapse_time)
	end
end

function RobertManager:IsFighting()
	return self.is_fighting
end

-- 主角是否正在使用机器人属性，如果正在使用中，则只保存服务器发过来的属性值，在退出机器人状态时再更到最新
function RobertManager:IsMainRoleUseingRobertAttr(attr_key, attr_value)
	if not self.is_playing then
		return false
	end

	local robert = self.robert_dic[Scene.Instance:GetMainRole():GetObjId()]
	if nil == robert then
		return false
	end

	return robert:RefrehOldAttrValue(attr_key, attr_value)
end

function RobertManager:OnMainRoleCreate()
	if self.is_playing then
		self:CreateMainRoleRobert(self.robert_role_cfg[0])
	end
end

function RobertManager:CreateRobert(robert_id)
	if nil ~= self:GetRobertByRobertId(robert_id) then
		return
	end

	local robert_cfg = self.robert_role_cfg[robert_id]
	if nil ~= robert_cfg then
		self:CreateRoleRobert(robert_cfg)
	end

	robert_cfg = self.robert_monster_cfg[robert_id]
	if nil ~= robert_cfg then
		self:CreateMonsterRobert(robert_cfg)
	end
end

function RobertManager:CreateMainRoleRobert(robert_cfg)
	self:DelRobertByRobertId(0)

	if nil ~= robert_cfg and Scene.Instance:GetMainRole() then
		local obj_id = Scene.Instance:GetMainRole():GetObjId()
		self.robert_dic[obj_id] = Robert.New(Scene.Instance:GetMainRole(), robert_cfg)
	end
end

function RobertManager:CreateRoleRobert(robert_cfg)
	self.obj_id_inc = self.obj_id_inc + 1

	local role_vo = RoleVo.New()
	role_vo.role_id = self.obj_id_inc
	role_vo.obj_id = self.obj_id_inc
	role_vo.name = robert_cfg.name or ""
	role_vo.level = 500
	role_vo.sex = robert_cfg.sex
	role_vo.prof = robert_cfg.prof
	role_vo.pos_x = robert_cfg.born_x
	role_vo.pos_y = robert_cfg.born_y
	role_vo.move_speed = robert_cfg.move_speed
	role_vo.max_hp = robert_cfg.max_hp
	role_vo.hp = role_vo.max_hp
	role_vo.appearance = TableCopy(PlayerData.Instance:GetRoleVo().appearance)
	role_vo.appearance.wuqi_id = robert_cfg.wuqi_id
	role_vo.appearance.mount_used_imageid = robert_cfg.mount_imageid
	role_vo.appearance.wing_used_imageid = robert_cfg.wing_imageid
	role_vo.name_color = 0 ~= robert_cfg.side and EvilColorList.NAME_COLOR_RED_1 or 0

	-- 说以下属性要跟人物一样，扯淡啊
	role_vo.sex = PlayerData.Instance:GetRoleVo().sex
	role_vo.prof = PlayerData.Instance:GetRoleVo().prof
	role_vo.wing_used_imageid = PlayerData.Instance:GetRoleVo().appearance.wing_used_imageid

	local role = Scene.Instance:CreateRole(role_vo)
	self.robert_dic[role_vo.obj_id] = Robert.New(role, robert_cfg)
end

function RobertManager:CreateMonsterRobert(robert_cfg)
	self.obj_id_inc = self.obj_id_inc + 1

	local monster_vo = MonsterVo.New()
	monster_vo.obj_id = self.obj_id_inc
	monster_vo.monster_id = robert_cfg.monster_id
	monster_vo.level = 500
	monster_vo.pos_x = robert_cfg.born_x
	monster_vo.pos_y = robert_cfg.born_y
	monster_vo.move_speed = robert_cfg.move_speed
	monster_vo.max_hp = robert_cfg.max_hp
	monster_vo.hp = monster_vo.max_hp

	local monster = Scene.Instance:CreateMonster(monster_vo)
	self.robert_dic[monster_vo.obj_id] = Robert.New(monster, robert_cfg)
end

function RobertManager:DelAllRobert()
	for k, v in pairs(self.robert_dic) do
		v:DeleteMe()
	end

	self.robert_dic = {}
end

function RobertManager:DelRobert(obj_id)
	if nil ~= self.robert_dic[obj_id] then
		self.robert_dic[obj_id]:DeleteMe()
		self.robert_dic[obj_id] = nil
	end
end

function RobertManager:DelRobertByRobertId(robert_id)
	for k, v in pairs(self.robert_dic) do
		if v:GetRobertId() == robert_id then
			v:DeleteMe()
			self.robert_dic[k] = nil
			break
		end
	end
end

function RobertManager:GetRobert(obj_id)
	return self.robert_dic[obj_id]
end

function RobertManager:GetRobertByRobertId(robert_id)
	for _, v in pairs(self.robert_dic) do
		if v:GetRobertId() == robert_id then
			return v
		end
	end

	return nil
end

-- 开始一场战斗，提供战斗结束需死亡哪个robert
function RobertManager:StartFight(end_die_robert_list, fight_end_callback)
	self.is_fighting = true
	self.fight_id_inc = self.fight_id_inc + 1
	self.end_die_robert_list = end_die_robert_list
	self.fight_end_callback = fight_end_callback

	print("RobertManager, StartFight", self.fight_id_inc)
end

-- 直接结束一场战斗
function RobertManager:StopFight()
	self.end_die_robert_list = {}
	self:CheckFightEnd()
end

-- 检查战斗是否应该结束
function RobertManager:CheckFightEnd()
	if #self.end_die_robert_list > 0 then
		return
	end

	print("RobertManager, FightEnd", self.fight_id_inc)
	self.is_fighting = false
	GuajiCtrl.Instance:StopGuaji()

	if nil ~= self.fight_end_callback then
		self.fight_end_callback(self.fight_id_inc)
	end
end

-- 机器人移动到位置
function RobertManager:RobertMoveTo(robert_id, pos_x, pos_y)
	local robert = self:GetRobertByRobertId(robert_id)
	if nil ~= robert then
		robert:DoMove(pos_x, pos_y)
	end
end

-- 机器人攻击目标
function RobertManager:RobertAtkTarget(attacker_robert_id, target_robert_id)
	local target_robert = self:GetRobertByRobertId(target_robert_id)
	local attacker_robert = self:GetRobertByRobertId(attacker_robert_id)

	if nil ~= attacker_robert and nil ~= target_robert then
		attacker_robert:SetAtkTarget(target_robert)
	end
end

-- 机器人说话
function RobertManager:RobertSay(robert_id, content, say_time)
	local robert = self:GetRobertByRobertId(robert_id)
	if nil ~= robert then
		robert:Say(content, say_time)
	end
end

-- 改变机器人外观
function RobertManager:RobertChangeAppearance(robert_id, appearance_type, appearance_value)
	local robert = self:GetRobertByRobertId(robert_id)
	if nil ~= robert then
		robert:ChangeAppearance(appearance_type, appearance_value)
	end
end

-- 改变机器人称号
function RobertManager:RobertChangeTitle(robert_id, title_id)
	local robert = self:GetRobertByRobertId(robert_id)
	if nil ~= robert then
		robert:ChangeTitle(title_id)
	end
end

-- 机器人改变属性值
function RobertManager:RobertChangeAttrValue(robert_id, attr_key, attr_value)
	local robert = self:GetRobertByRobertId(robert_id)
	if nil ~= robert then
		robert:ChangeAttrValue(attr_key, attr_value)
	end
end

-- 机器人改变aoe范围
function RobertManager:RobertChangeAoeRange(robert_id, aoe_range)
	local robert = self:GetRobertByRobertId(robert_id)
	if nil ~= robert then
		robert:ChangeAoeRange(aoe_range)
	end
end

-- 机器人改变攻击力
function RobertManager:RobertChangeGongJi(robert_id, min_gongji, max_gongji)
	local robert = self:GetRobertByRobertId(robert_id)
	if nil ~= robert then
		robert:ChangeMinGongji(min_gongji)
		robert:ChangeMaxGongji(max_gongji)
	end
end

-- 机器人开始采集
function RobertManager:RobertStartGather(robert_id, gather_id)
	local robert = self:GetRobertByRobertId(robert_id)
	if nil ~= robert then
		robert:StartGather(Scene.Instance:GetSceneId(), gather_id)
	end
end

-- 机器人转向
function RobertManager:RobertRotateTo(robert_id, angle)
	local robert = self:GetRobertByRobertId(robert_id)
	if nil ~= robert then
		robert:SetLocalRotationY(angle)
	end
end

-- 机器人寻找机器人打
function RobertManager:FindEnemy(attacker_robert)
	if nil == attacker_robert or attacker_robert:IsDead() then
		return
	end

	local target_x, target_y, distance = 0, 0, 100000
	local finder_x, finder_y = attacker_robert:GetLogicPos()
	local target_robert = nil

	for _, v in pairs(self.robert_dic) do
		if v ~= attacker_robert and self:IsEnemy(attacker_robert, v) then
			target_x, target_y = v:GetLogicPos()
			local temp_distance = GameMath.GetDistance(finder_x, finder_y, target_x, target_y, false)
			if temp_distance < distance then
				target_robert = v
				distance = temp_distance
			end
		end
	end

	return target_robert
end

-- 寻找某个范围内的敌人列表
function RobertManager:FindEnemyList(attacker_robert, center_x, center_y, range)
	local enemy_list = {}

	if nil == attacker_robert or attacker_robert:IsDead() then
		return enemy_list
	end

	local target_x, target_y = 0, 0
	for _, v in pairs(self.robert_dic) do
		if v ~= attacker_robert and self:IsEnemy(attacker_robert, v) then
			target_x, target_y = v:GetLogicPos()
			local temp_distance = GameMath.GetDistance(center_x, center_y, target_x, target_y, true)
			if temp_distance <= range then
				table.insert(enemy_list, v)
			end
		end
	end

	return enemy_list
end

-- 是否是敌人
function RobertManager:IsEnemy(attacker_robert, target_robert)
	if attacker_robert == target_robert
		or nil == attacker_robert or attacker_robert:IsDead()
		or nil == target_robert or target_robert:IsDead() then

		return false
	end

	return attacker_robert:GetSide() ~= target_robert:GetSide()
end

-- 请求战斗，通过模防协议实现
function RobertManager:ReqFight(attacker_robert, hiter_robert, skill_id, skill_index)
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
	if normal_skill_list[skill_id] then
		hit_count = normal_skill_list[skill_id]
	end

	local aoe_range = attacker_robert:GetAoeRange()
	local hiter_robert_list = {hiter_robert}
	if aoe_range > 0 then
		local center_x, center_y = hiter_robert:GetLogicPos()
		hiter_robert_list = self:FindEnemyList(attacker_robert, center_x, center_y, aoe_range)
	end

	function changeblood(attacker, hiter, skill_id, hit_count)
		if not self.is_playing 
			or nil == self:GetRobert(attacker:GetObjId())
		 	or nil == self:GetRobert(hiter:GetObjId())
		 	or attacker:IsDead()
		 	or hiter:IsDead() then
			return
		end

		local min_gongji = attacker:GetMinGongji() * hit_count
		local max_gongji = attacker:GetMaxGongji() * hit_count
		local hurt = GameMath.Rand(min_gongji, max_gongji)
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
		GlobalEventSystem:Fire(OtherEventType.ROBERT_ATTACK_ROBERT, attacker:GetRobertId(), hiter:GetRobertId())
	end

	for _, v in ipairs(hiter_robert_list) do
		changeblood(attacker_robert, v, skill_id, hit_count)
	end
end

function RobertManager:OnRobertDie(robert)
	if nil == robert then
		return
	end

	local len = #self.end_die_robert_list
	for i = len, 1, -1 do
		if self.end_die_robert_list[i] == robert:GetRobertId() then
			table.remove(self.end_die_robert_list, i)
		end
	end

	GlobalEventSystem:Fire(OtherEventType.ROBERT_DIE, robert:GetRobertId())
	
	self:CheckFightEnd()
end
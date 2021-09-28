KfHotSpringSceneLogic = KfHotSpringSceneLogic or BaseClass(CrossServerSceneLogic)

local target = {
	scene = scene_id,
	x = min_x,
	y = min_y,
	id = id
}

function KfHotSpringSceneLogic:__init()
	self.point_a = {x = 0, y = 0}
	self.point_b = {x = 0, y = 0}
	self.range = 0
	local config = HotStringChatData.Instance:GetQuestionConfig()
	if config then
		local other_config = config.other[1]
		if other_config then
			self.point_a = {x = other_config.Apoint_pos_x, y = other_config.Apoint_pos_y}
			self.point_b = {x = other_config.Bpoint_pos_x, y = other_config.Bpoint_pos_y}
			self.range = other_config.range * other_config.range
		end
	end
	-- 最后站立的答题区域
	self.last_pos = -2
	self.hot_spring_gather_list = {}
end

function KfHotSpringSceneLogic:__delete()
	if nil ~= self.pos_change then
		GlobalEventSystem:UnBind(self.pos_change)
		self.pos_change = nil
	end
end

function KfHotSpringSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)

	if not self.pos_change then
		self.pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind(self.CheckPosition, self))
	end

	MainUICtrl.Instance:SetViewState(false)

	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetAutoVisible(false)		--隐藏挂机按钮
		GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, true)
	end

	HotStringChatCtrl.Instance:ShowRankView()
end

function KfHotSpringSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	GlobalEventSystem:Fire(OtherEventType.REPAIR_STATE_CHANGE, false)

	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetAutoVisible(true)		--显示挂机按钮
	end

	HotStringChatCtrl.Instance:CloseRankView()
	HotStringChatCtrl.Instance:CloseQuestionView()
	HotStringChatData.Instance:ClearpartnerId()

	self.last_pos = -2
	if nil ~= self.pos_change then
		GlobalEventSystem:UnBind(self.pos_change)
		self.pos_change = nil
	end
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function KfHotSpringSceneLogic:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

function KfHotSpringSceneLogic:CheckPosition(logic_pos_x, logic_pos_y)
	if not logic_pos_x or not logic_pos_y or self.last_pos == -2 then return end

	local delta_pos_a = u3d.vec2(logic_pos_x - self.point_a.x, logic_pos_y - self.point_a.y)
	local distance_a = u3d.v2Length(delta_pos_a, false)

	local delta_pos_b = u3d.vec2(logic_pos_x - self.point_b.x, logic_pos_y - self.point_b.y)
	local distance_b = u3d.v2Length(delta_pos_b, false)

	if distance_a <= self.range then
		if self.last_pos == 0 then return end
		self.last_pos = 0
		HotStringChatCtrl.Instance:SendAnswerQuestionReq(0, 0)
	elseif distance_b <= self.range then
		if self.last_pos == 1 then return end
		self.last_pos = 1
		HotStringChatCtrl.Instance:SendAnswerQuestionReq(0, 1)
	else
		if self.last_pos == 2 then return end
		self.last_pos = 2
		HotStringChatCtrl.Instance:SendAnswerQuestionReq(0, 2)
	end
end

function KfHotSpringSceneLogic:ClearPos()
	self.last_pos = -1
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		local x, y = main_role:GetLogicPos()
		self:CheckPosition(x, y)
	end
end

function KfHotSpringSceneLogic:GetPosA()
	return self.point_a
end

function KfHotSpringSceneLogic:GetPosB()
	return self.point_b
end

-- 是否是挂机打怪的敌人
function KfHotSpringSceneLogic:IsGuiJiMonsterEnemy()
	return false
end

-- 是否可攻击的怪
function KfHotSpringSceneLogic.IsAttackMonster()
	return false
end

-- 角色是否是敌人
function KfHotSpringSceneLogic:IsRoleEnemy()
	return false
end

function KfHotSpringSceneLogic:IsCanCheckWaterArea()
	return true
end

function KfHotSpringSceneLogic:GotoGather()
	self:GetDuckCatch()
	self:ToGather()
end

function KfHotSpringSceneLogic:GetDuckCatch()
	self.hot_spring_gather_list = {}
	if Scene.Instance:GetSceneType() ~= SceneType.HotSpring then
		return
	end
	for i, j in pairs(Scene.Instance:GetObjListByType(SceneObjType.GatherObj)) do
		if HotStringChatData.Instance:IsHotSpringDuck(j:GetGatherId()) then
			local pos_x, pos_y = j:GetLogicPos()
			self.hot_spring_gather_list[#self.hot_spring_gather_list + 1] = {x = pos_x, y = pos_y, id = j:GetGatherId(), obj_id = j:GetObjKey()}
		end
	end
end

function KfHotSpringSceneLogic:ToGather()
	local scene_id = Scene.Instance:GetSceneId()
	local target_distance = 1000 * 1000
	local main_role = Scene.Instance:GetMainRole()
	local p_x, p_y = main_role:GetLogicPos()
	local min_x, min_y, id = 0, 0, 0
	local can_gather = false
	if not can_gather and HotStringChatData.Instance:GetRestGatherTimesByType() ~= 0 then
		for k, v in pairs(self.hot_spring_gather_list) do
			if not AStarFindWay:IsBlock(v.x, v.y) then
				local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
				if distance < target_distance then
					min_x = v.x
					min_y = v.y
					target_distance = distance
					id = v.id
				end
				can_gather = true
			end
		end
	end

	if not can_gather then
		TipsCtrl.Instance:ShowSystemMsg(Language.HotString.GatherNoDuck)
		return
	end

	target = {scene = scene_id, x = min_x, y = min_y, id = id}
	MoveCache.end_type = MoveEndType.GatherById
	MoveCache.param1 = target.id
	GuajiCache.target_obj_id = target.id
	GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 4, 0)
end

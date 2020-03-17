_G.PrepState = {}

function PrepState:new(entity, skillId)
	local state = BaseState:new(entity)
	state.name = "prep"
	state.skillId = skillId
	state.prepTime = 0
	state.prepState = 0
	state.entity = entity
	state.avatar = entity:GetAvatar()
	setmetatable(state, {__index = PrepState})
	return state
end

function PrepState:enter()
	local skillId = self.skillId
	local skillConfig = t_skill[skillId]
	self.prepTime = GetCurTime() + skillConfig.prep_time
	self.entity:PlaySkill(skillId)
end

function PrepState:update(e)
	if GetCurTime() > self.prepTime then
		self.entity.stateMachine:changeState(IdleState:new(self.entity))
	end
end

function PrepState:exit()
	self.avatar:SetPrepState(0)
	self.avatar:StopCurrSkillAction()
	SkillController:SetStiffTime(self.skillId)
end

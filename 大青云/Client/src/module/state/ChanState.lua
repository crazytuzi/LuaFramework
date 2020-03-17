_G.ChanState = {}

function ChanState:new(entity, skillId)
	local state = BaseState:new(entity)
	state.name = "chan"
	state.skillId = skillId
	state.chanTime = 0
	state.ChanState = 0
	state.entity = entity
	state.avatar = entity:GetAvatar()
	setmetatable(state, {__index = ChanState})
	return state
end

function ChanState:enter()
	local skillId = self.skillId
	local skillConfig = t_skill[skillId]
	self.chanTime = GetCurTime() + skillConfig.chant_time
	self.entity:PlaySkill(skillId)
end

function ChanState:update(e)
	if GetCurTime() > self.chanTime then
		self.entity.stateMachine:changeState(IdleState:new(self.entity))
	end
end

function ChanState:exit()
	self.avatar:StopCurrSkillAction()
end

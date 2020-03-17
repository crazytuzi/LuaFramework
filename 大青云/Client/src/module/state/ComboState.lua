_G.ComboState = {}

function ComboState:new(entity, skillId)
	local state = BaseState:new(entity)
	state.name = "combo"
	state.skillId = skillId
	state.comboTime = 0
	state.entity = entity
	state.avatar = entity:GetAvatar()
	setmetatable(state, {__index = ComboState})
	return state
end

function ComboState:enter()
	local skillId = self.skillId
	local skillConfig = t_skill[skillId]
	if SkillController.comboing == false then
		SkillController.comboing = true
		self.comboTime = GetCurTime() + skillConfig.combo_time
	end
end

function ComboState:update(e)
	local timeNow = GetCurTime()
	if timeNow > self.comboTime then
		self.entity.stateMachine:changeState(IdleState:new(self.entity))
	end
end

function ComboState:exit()
	SkillController.comboing = false
	AutoBattleController:SetSkillCD(self.skillId)
	SkillController:SetComboSkillCD(self.skillId)
end

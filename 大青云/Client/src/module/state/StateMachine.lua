_G.StateMachine = {}

function StateMachine.new(entity)
	if entity.stateMachine then
		return entity.stateMachine
	end
	local stateMachine = {}
	stateMachine.entity = entity 
	stateMachine.currState = nil
	stateMachine.prevState = nil
	setmetatable(stateMachine, {__index = StateMachine})
	return stateMachine
end

function StateMachine:update(e)
	if self.currState then
		self.currState:update(e)
	end
end

function StateMachine:changeState(newState)
	self.prevState = self.currState
	self.currState:exit( )
	self.currState = newState
	self.currState:enter( )
end
_G.IdleState = {}

function IdleState:new(entity)
	local state = BaseState:new(entity)
	state.name = "idle"
	setmetatable(state, {__index = IdleState})
	return state
end

function IdleState:enter()

end

function IdleState:update(e)

end

function IdleState:exit()
	
end
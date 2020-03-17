_G.BaseState = { }

function BaseState.new(entity)
	local state = {}
	state.entity = entity
	setmetatable(state, {__index = BaseState})
	return state
end

function BaseState:enter()

end

function BaseState:update(e)

end

function BaseState:exit()

end


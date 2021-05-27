
StateMachine = StateMachine or BaseClass()

function StateMachine:__init(obj)
	self.obj = obj
	self.state_list = {}
	self.is_changeing = false
	self.state_now = nil
	self.next_state_name = nil
end

function StateMachine:__delete()
	self.state_list = {}
	self.state_now = nil
end

function StateMachine:SetStateFunc(state_name, enter_func, update_func, quit_func)
	self.state_list[state_name] = {}
	self.state_list[state_name].name = state_name
	self.state_list[state_name].enter = enter_func
	self.state_list[state_name].update = update_func
	self.state_list[state_name].quit = quit_func
end

local temp_state = nil
function StateMachine:ChangeState(state_name, ...)
	if self.is_changeing then
		self.next_state_name = state_name
		return
	end

	self.is_changeing = true
	self.next_state_name = nil

	if nil ~= self.state_now then
		temp_state = self.state_now
		self.state_now = self.state_list[state_name]
		temp_state.quit(self.obj)
	else
		self.state_now = self.state_list[state_name]
	end

	if nil ~= self.state_now then
		self.state_now.enter(self.obj, ...)
	end

	self.is_changeing = false
end

function StateMachine:UpdateState(elapse_time)
	if nil ~= self.next_state_name then
		self:ChangeState(self.next_state_name)
	end

	if nil ~= self.state_now then
		self.state_now.update(self.obj, elapse_time)
	end
end

function StateMachine:IsInState(state_name)
	if nil == self.state_now then
		return false
	end

	if self.state_now.name == state_name then
		return true
	end

	return false
end

function StateMachine:GetStateName()
	return self.state_now and self.state_now.name or ""
end

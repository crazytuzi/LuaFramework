----------------------------------------------------------------
local require = require


require("i3k_state_base");


-----------------------------------------------------------------
i3k_state_machine = i3k_class("i3k_state_machine");
function i3k_state_machine:ctor(state)
	self._state 		= state;
	self._cur_state_obj = nil;
	self._transitions	= { };
	self._events		= { };
	self._curr_event_id	= 0;
	self._next_event_id	= 0;
end

function i3k_state_machine:AddTransition(from, evt, to, state_obj)
	local transition = self._transitions[from];

	local tr = { _to = to, _obj = state_obj };
	if transition then
		transition[evt] = tr;
	else
		transition = { };
		transition[evt] = tr;

		self._transitions[from] = transition;
	end
end

function i3k_state_machine:Transition(evt)
	local row = self._transitions[self._state];
	if not row then
		return false;
	end

	local transition = row[evt];
	if not transition then
		return false;
	end

	local cur_obj = transition._obj;
	if not cur_obj then
		return;
	end

	local pre_state = self._state;

	local pre_obj = self._cur_state_obj;
	if cur_obj:Entry(self, self._state, evt, transition._to) then
		cur_obj._isEntry = true;

		if pre_obj and pre_obj._isEntry then
			pre_obj._isEntry = false;

			pre_obj:Leave(self, self._state, evt, transition._to);
		end

		local needChange	= true;
		local firstChange	= true;

		while pre_state ~= self._state do
			if pre_state ~= transition._to then
				needChange = true;
			else
				needChange = false;
			end
			pre_state = self._state;

			if firstChange then
				firstChange = false;
			else
				if pre_obj and pre_obj._isEntry then
					pre_obj._isEntry = false;

					pre_obj:Leave(self, self._state, evt, transition._to);
				end
			end

			pre_obj = self._cur_state_obj;
		end

		if needChange then
			if pre_obj and pre_obj._isEntry then
				pre_obj._isEntry = false;

				pre_obj:Leave(self, self._state, evt, transition._to);
			end

			cur_obj:Do(self, evt);

			self._state 		= transition._to;
			self._cur_state_obj = cur_obj;
		end
	else
		return false;
	end 

	return true;
end

function i3k_state_machine:PostEvent(evt)
	self:Transition(evt);

	self._next_event_id = self._next_state_id + 1;
	self._events[self._next_event_id] = evt;
end

function i3k_state_machine:ProcessEvent(evt)
	local ret = self:Transition(evt) 

	while self._curr_event_id < self._next_event_id do
		local event = self._events[self._curr_event_id];
		self._events[self._curr_event_id] = nil;
		self._curr_event_id = self._curr_event_id + 1;

		self:Transition(event);
	end

	return ret;
end


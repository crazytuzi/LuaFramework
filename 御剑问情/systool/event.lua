Event = Event or BaseClass()

function Event:__init(event_id)
	self.event_id = event_id
	self.bind_id_count = 0
	self.bind_num = 0
	self.event_func_list = {}
	self.event_queue = {}
	self.arg_table = {}
end

function Event:Fire(arg_table)
	for _, func in pairs(self.event_func_list) do
		func(unpack(arg_table))
	end
end

function Event:UnBind(obj)
	if obj.event_id == self.event_id then
		self.bind_num = self.bind_num - 1
		self.event_func_list[obj.bind_id] = nil
	end
end

function Event:Bind(event_func)
	self.bind_num = self.bind_num + 1
	self.bind_id_count = self.bind_id_count + 1
	local obj = {event_id = self.event_id, bind_id = self.bind_id_count}
	self.event_func_list[obj.bind_id] = event_func
	return obj
end

function Event:GetBindNum()
	return self.bind_num
end

function Event:FireByQueue(arg_table)
	self.arg_table = arg_table
	self.event_queue = {}
	for _, func in pairs(self.event_func_list) do
		table.insert(self.event_queue, func)
	end
	self.cur_index = 0
	Runner.Instance:AddRunObj(self, 3)
end

function Event:Update()
	local total_count = #self.event_queue
	if self.cur_index < total_count then
		self.cur_index = self.cur_index + 1
		func = self.event_queue[self.cur_index]
		func(unpack(self.arg_table))
	end

	if self.cur_index >= total_count then
		Runner.Instance:RemoveRunObj(self)
		self.event_queue = {}
	end
end
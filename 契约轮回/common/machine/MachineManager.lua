--
-- Author: LaoY
-- Date: 2018-06-30 14:59:05
--

MachineManager = MachineManager or class("MachineManager")

function MachineManager:ctor()
	MachineManager.Instance = self
	self.machine_count = 0
	self.machine_list = {}
	self.machine_index_list = {}
	setmetatable(self.machine_list, {__mode = "v"})
	setmetatable(self.machine_index_list, {__mode = "k"})
	-- FixedUpdateBeat:Add(self.Update,self,2,1)
	LateUpdateBeat:Add(self.Update,self,2,1)

	
end

function MachineManager:dctor()
	-- FixedUpdateBeat:Remove(self.Update)
	LateUpdateBeat:Remove(self.Update)
end

function MachineManager:GetInstance()
	if not MachineManager.Instance then
		MachineManager()
	end
	return MachineManager.Instance
end

function MachineManager:CreateMachine(machine)
	self.machine_count = self.machine_count + 1
	self.machine_index_list[machine] = self.machine_count
	self.machine_list[self.machine_count] = machine
end

function MachineManager:RemoveMachine(machine)
	local machine_count = self.machine_index_list[machine]
	self.machine_list[machine_count] = nil
	self.machine_index_list[machine] = nil
end

function MachineManager:Update(deltaTime)
	for count,machine in pairs(self.machine_list) do
		if not machine.is_dctored then
			machine:Update(deltaTime)
		end
	end
end
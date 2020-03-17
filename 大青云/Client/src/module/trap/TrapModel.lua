_G.TrapModel = TrapModel or {
	list = {}
}

function TrapModel:DeleteAllTrap()
	self.list = {}
end

function TrapModel:GetTrapList()
	return self.list
end

function TrapModel:AddTrap(trap)
	self.list[trap.cid] = trap
end

function TrapModel:GetTrap(cid)
	return self.list[cid]
end

function TrapModel:DeleteTrap(trap)
	self.list[trap.cid] = nil
end

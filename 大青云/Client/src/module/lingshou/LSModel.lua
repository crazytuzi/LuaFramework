_G.LSModel = LSModel or {
	lingShouList = {}
}

function LSModel:DeleteAllLingShou()
	self.lingShouList = {}
end

function LSModel:GetLingShouList()
	return self.lingShouList
end

function LSModel:AddLingShou(lingShou)
	self.lingShouList[lingShou.cid] = lingShou
end

function LSModel:GetLingShou(cid)
	return self.lingShouList[cid]
end

function LSModel:DeleteLingShou(lingShou)
	self.lingShouList[lingShou.cid] = nil
end
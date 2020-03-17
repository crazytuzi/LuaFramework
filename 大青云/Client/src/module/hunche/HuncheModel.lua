_G.HuncheModel = HuncheModel or {
	list = {}
}

function HuncheModel:DeleteAllHunche()
	self.list = {}
end

function HuncheModel:GetHuncheList()
	return self.list
end

function HuncheModel:AddHunche(hunche)
	self.list[hunche.cid] = hunche
end

function HuncheModel:GetHunche(cid)
	return self.list[cid]
end

function HuncheModel:DeleteHunche(hunche)
	self.list[hunche.cid] = nil
end
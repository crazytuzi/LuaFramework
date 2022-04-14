CasthouseModel = CasthouseModel or class("CasthouseModel",BaseModel)
local CasthouseModel = CasthouseModel

function CasthouseModel:ctor()
	CasthouseModel.Instance = self
	self:Reset()
end

function CasthouseModel:Reset()
	
end

function CasthouseModel.GetInstance()
	if CasthouseModel.Instance == nil then
		CasthouseModel()
	end
	return CasthouseModel.Instance
end



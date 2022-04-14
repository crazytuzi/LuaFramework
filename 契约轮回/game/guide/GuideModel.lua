GuideModel = GuideModel or class("GuideModel",BaseModel)
local GuideModel = GuideModel
local tableInsert = table.insert

function GuideModel:ctor()
	GuideModel.Instance = self
	self:Reset()
end

function GuideModel:Reset()
	self.has_guide = false
	self.advertise_name = ""
	self.guides = {}
	self.items = {}
	self.cur_guide = nil
end

function GuideModel.GetInstance()
	if GuideModel.Instance == nil then
		GuideModel()
	end
	return GuideModel.Instance
end

--是否有引导
function GuideModel:HasGuide()
	return #self.items > 0 
end



GuideModel =BaseClass(LuaModel)

function GuideModel:GetInstance()
	if GuideModel.inst == nil then
		GuideModel.inst = GuideModel.New()
	end
	return GuideModel.inst
end

function GuideModel:__init()
end

function GuideModel:__delete()
	GuideModel.inst = nil
end
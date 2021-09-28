CommonModel = BaseClass(LuaModel)

--单例
function CommonModel:GetInstance()
	if CommonModel.inst == nil then
		CommonModel.inst = CommonModel.New()
	end
	return CommonModel.inst
end

function CommonModel:__init()
	
end

function CommonModel:__delete()
	CommonModel.inst = nil
end
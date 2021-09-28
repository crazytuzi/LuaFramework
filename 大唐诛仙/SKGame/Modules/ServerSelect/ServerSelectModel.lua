ServerSelectModel =BaseClass(LuaModel)

function ServerSelectModel:__init()

end

function ServerSelectModel:__delete()
	ServerSelectModel.inst = nil
end

function ServerSelectModel:GetInstance()
	if ServerSelectModel.inst == nil then
		ServerSelectModel.inst = ServerSelectModel.New()
	end
	return ServerSelectModel.inst
end

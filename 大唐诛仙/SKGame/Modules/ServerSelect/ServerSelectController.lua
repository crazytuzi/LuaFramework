RegistModules("ServerSelect/View/ServerContentItem")
RegistModules("ServerSelect/View/ServerTabItem")
RegistModules("ServerSelect/View/ServerSelectPanel")
RegistModules("ServerSelect/View/ServerState")

RegistModules("ServerSelect/Vo/ServerVo")
RegistModules("ServerSelect/ServerSelectView")
RegistModules("ServerSelect/ServerSelectModel")
RegistModules("ServerSelect/ServerSelectConst")

ServerSelectController =BaseClass(LuaController)

function ServerSelectController:__init()
	self:Config()
end

function ServerSelectController:__delete()
	ServerSelectController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	if self.view then
		self.view:Destroy()
	end
	self.view = nil
end

function ServerSelectController:Config()
	self.model = ServerSelectModel:GetInstance()
	self.view = ServerSelectView.New()
end

function ServerSelectController:GetInstance()
	if ServerSelectController.inst == nil then
		ServerSelectController.inst = ServerSelectController.New()
	end
	return ServerSelectController.inst
end

function ServerSelectController:OpenServerSelectPanel(accountData)
	if self.view then
		self.view = ServerSelectView.New()
	end
	self.view:OpenServerSelectPanel(accountData)
end
RegistModules("Composition/View/CompositionItemInfo")
RegistModules("Composition/View/CompositionUI")
RegistModules("Composition/View/CompositionUILeft")
RegistModules("Composition/View/CompositionUIRight")

RegistModules("Composition/CompositionModel")
RegistModules("Composition/CompositionView")
RegistModules("Composition/CompositionConst")


CompositionController =BaseClass(LuaController)

function CompositionController:__init()

	self:Config()
	self:RegistProto()
	self:InitEvent()
end

function CompositionController:__delete()
	self:CleanEvent()
	CompositionController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	if self.view then
		self.view:Destroy()
	end
	self.view = nil
end

function CompositionController:GetInstance()
	if CompositionController.inst == nil then
		CompositionController.inst = CompositionController.New()
	end
	return CompositionController.inst
end

function CompositionController:Config()
	self.model = CompositionModel:GetInstance()
	self.view = CompositionView.New()
end


function CompositionController:RegistProto()
	self:RegistProtocal("S_Compose", "HandleComposeSucc")
end

function CompositionController:HandleComposeSucc(msgParam)
	local msg = self:ParseMsg(bag_pb.S_Compose(), msgParam)
	if msg then
		self.model:DispatchEvent(CompositionConst.ComposeSucc)
	end
end

function CompositionController:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end
	end)
end

function CompositionController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function CompositionController:GetCompositionUI()
	local rtnCompositionUI = {}
	if self.view then
		rtnCompositionUI = self.view:GetCompositionUI()
	end
	return rtnCompositionUI
end

function CompositionController:CompositionReq(itemId)
	if itemId then
		local msg = bag_pb.C_Compose()
		msg.itemId = itemId
		self:SendMsg("C_Compose", msg)
	end
end
RegistModules("Decomposition/DecompositionConst")
RegistModules("Decomposition/DecompositionModel")
RegistModules("Decomposition/RefinedModel")
RegistModules("Decomposition/View/DecompositionUI")
RegistModules("Decomposition/View/DecompositionUILeft")
RegistModules("Decomposition/View/DecompositionUIRight")
RegistModules("Decomposition/View/ButtonDecompositionTick")

DecompositionController =BaseClass(LuaController)

function DecompositionController:__init()
	self.decompositionModel = DecompositionModel:GetInstance()
	self.refinedModel = RefinedModel:GetInstance()
	self:RegistProto()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.decompositionModel then self.decompositionModel:Reset() end
		if self.refinedModel then self.refinedModel:Reset() end
	end)
end
function DecompositionController:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	if self.decompositionModel then
		self.decompositionModel:Destroy()
	end
	self.decompositionModel = nil
	if self.refinedModel then
		self.refinedModel:Destroy()
	end
	self.refinedModel = nil
	DecompositionController.inst = nil
end
function DecompositionController:GetInstance()
	if DecompositionController.inst == nil then
		DecompositionController.inst = DecompositionController.New()
	end
	return DecompositionController.inst
end

function DecompositionController:RegistProto()
	self:RegistProtocal("S_AutoDecompose")
	self:RegistProtocal("S_Decompose")

	self:RegistProtocal("S_AutoRefine")
	self:RegistProtocal("S_Refine")
end

function DecompositionController:S_AutoDecompose(bf)
	local msg = self:ParseMsg(bag_pb.S_AutoDecompose(), bf)
	if #msg.playerBagId ~= 0 then
		for i = 1 , #msg.playerBagId do
			local id = msg.playerBagId[i]
			self.decompositionModel:DispatchEvent(DecompositionConst.Succ, id)
		end
	end
end
function DecompositionController:S_Decompose(bf)
	local msg = self:ParseMsg(bag_pb.S_Decompose(), bf)
	if #msg.playerBagId ~= 0 then
		for i = 1 , #msg.playerBagId do
			local id = msg.playerBagId[i]
			self.decompositionModel:DispatchEvent(DecompositionConst.Succ, id)
		end
	end
end

function DecompositionController:S_AutoRefine(bf)
	local msg = self:ParseMsg(bag_pb.S_AutoRefine(), bf)
	if #msg.playerBagId ~= 0 then
		for i = 1 , #msg.playerBagId do
			local id = msg.playerBagId[i]
			self.refinedModel:DispatchEvent(DecompositionConst.Succ, id)
		end
	end
end
function DecompositionController:S_Refine(bf)
	local msg = self:ParseMsg(bag_pb.S_Refine(), bf)
	if #msg.playerBagId ~= 0 then
		for i = 1 , #msg.playerBagId do
			local id = msg.playerBagId[i]
			self.refinedModel:DispatchEvent(DecompositionConst.Succ, id)
		end
	end
end

--发送分解请求
function DecompositionController:C_Decompose(list)
	if list then
		local msg = bag_pb.C_Decompose()
		for i = 1 , #list do
			msg.playerBagId:append(list[i])
		end
		self:SendMsg("C_Decompose", msg)
	end
end
--一键分解请求
function DecompositionController:C_AutoDecompose(list)
	if list  then
		local msg = bag_pb.C_AutoDecompose()
		for i = 1, #list do
			msg.rareId:append(list[i])
		end
		self:SendMsg("C_AutoDecompose", msg)
	end
end

--提炼
function DecompositionController:C_Refine(list)
	if list then
		local msg = bag_pb.C_Refine()
		for i = 1 , #list do
			msg.playerBagId:append(list[i])
		end
		self:SendMsg("C_Refine", msg)
	end
end
--一键提炼
function DecompositionController:C_AutoRefine(list)
	if list  then
		local msg = bag_pb.C_AutoRefine()
		for i = 1, #list do
			msg.rareId:append(list[i])
		end
		self:SendMsg("C_AutoRefine", msg)
	end
end
RegistModules("Style/StyleConst")
RegistModules("Style/StyleModel")
RegistModules("Style/StyleView")

RegistModules("Style/Vo/StyleDynamicVo")

RegistModules("Style/View/StyleActivePanel")
RegistModules("Style/View/StyleItem")
RegistModules("Style/View/StyleProp")
RegistModules("Style/View/StylePanel")


StyleController =BaseClass(LuaController)

function StyleController:GetInstance()
	if StyleController.inst == nil then
		StyleController.inst = StyleController.New()
	end
	return StyleController.inst
end

function StyleController:__init()
	self.model = StyleModel:GetInstance()
	self.view = nil

	self:InitEvent()
	self:RegistProto()

	self.getRankDataSuccess = false
end

function StyleController:InitEvent()
	if not self.reloginHandle then
		self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE,function ()
			self.model:Reset()
		end)
	end
end

-- 协议注册
function StyleController:RegistProto()
	self:RegistProtocal("S_SynFashionList") --时装列表
	self:RegistProtocal("S_PutonFashion") --装备时装返回
	self:RegistProtocal("S_PutdownFashion") --卸下时装
	self:RegistProtocal("S_AddFashion") --激活新的时装
end

function StyleController:S_AddFashion(buff)
	local msg = self:ParseMsg(fashion_pb.S_AddFashion(), buff)
	self.model:AddStyle(msg)
end

function StyleController:S_SynFashionList(buff)
	local msg = self:ParseMsg(fashion_pb.S_SynFashionList(), buff)
	self.model:ParseSynStyleData(msg)
end

function StyleController:S_PutonFashion(buff)
	local msg = self:ParseMsg(fashion_pb.S_PutonFashion(), buff)
	self.model:PutOnStyle(msg)
end

function StyleController:S_PutdownFashion(buff)
	local msg = self:ParseMsg(fashion_pb.S_PutdownFashion(), buff)
	self.model:PutDownStyle(msg)
end

function StyleController:C_GetFashionList()
	local msg = fashion_pb.C_GetFashionList()
	self:SendMsg("C_GetFashionList", msg)
end

function StyleController:C_PutonFashion(fashionId)
	local msg = fashion_pb.C_PutonFashion()
	msg.fashionId = fashionId
	self:SendMsg("C_PutonFashion", msg)
end

function StyleController:C_PutdownFashion(fashionId)
	local msg = fashion_pb.C_PutdownFashion()
	msg.fashionId = fashionId
	self:SendMsg("C_PutdownFashion", msg)
end

function StyleController:GetStylePanel()
	if self.view == nil then
		self.view = StyleView.New()
	end
	self:C_GetFashionList()
	return self.view:GetStylePanel()
end

function StyleController:DestroyStylePanel()
	if self.view ~= nil then
		self.view:Destroy()
	end
	self.view = nil
end

function StyleController:Close()
	if self.view then 
		self.view:Close()
	end
end

function StyleController:__delete()
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	if self.view then
		self.view:Destroy()
		self.view = nil
	end

	if self.model then
		self.model:Destroy()
		self.model = nil
	end

	StyleController.inst = nil
end
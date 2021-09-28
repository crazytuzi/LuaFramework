RegistModules("Wakan/WakanConst")
RegistModules("Wakan/WakanModel")
RegistModules("Wakan/WakanView")

RegistModules("Wakan/View/AwakePanelItem")
RegistModules("Wakan/View/AwakePanel")

RegistModules("Wakan/View/WakanProperty")
RegistModules("Wakan/View/WakanCostItem")
RegistModules("Wakan/View/WakanCostItemSelectPanel")
RegistModules("Wakan/View/WakanSelectItem")
RegistModules("Wakan/View/WakanSelectItems")
RegistModules("Wakan/View/WakanPanel")

WakanController =BaseClass(LuaController)

function WakanController:GetInstance()
	if WakanController.inst == nil then
		WakanController.inst = WakanController.New()
	end
	return WakanController.inst
end

function WakanController:__init()
	self.model = WakanModel:GetInstance()
	self.view = WakanView.New()

	self:AddEvent()
	self:RegistProto()
	self:ReqWakanListHandler()
end

function WakanController:AddEvent()
	self.handler1 = self.model:AddEventListener(WakanConst.ReqWakanList, function ( data ) self:ReqWakanListHandler(data) end)
	self.handler2 = self.model:AddEventListener(WakanConst.ReqTakeWakan, function ( data ) self:ReqTakeWakanHandler(data) end)
	self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
		-- if self.model then
		-- 	self.model:Reset()
		-- end
		if self.inst then
			self.inst:Destroy()
		end
	end)
end

function WakanController:RemoveEvent()
	if self.model then
		self.model:RemoveEventListener(self.handler1)
		self.model:RemoveEventListener(self.handler2)
	end
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
end

-- 协议注册
function WakanController:RegistProto()
	self:RegistProtocal("S_WakanList", "RespondWakanListHandler")
	self:RegistProtocal("S_TakeWakan", "RespondTakeWakanHandler")
end

--请求注灵信息
function WakanController:ReqWakanListHandler(data)
	local msg = wakan_pb.C_WakanList()
	self:SendMsg("C_WakanList", msg)
end

--注灵信息反馈
function WakanController:RespondWakanListHandler(buffer)
	local msg = self:ParseMsg(wakan_pb.S_WakanList(), buffer)
	SerialiseProtobufList(msg.wakanList, function(item)
		if self.model then
			self.model:UpdateWakanPartInfo(item)
		end
	end)
	WakanModel:GetInstance():DispatchEvent(WakanConst.WakanDataSync)
end

--请求注灵
function WakanController:ReqTakeWakanHandler(data)
	local msg = wakan_pb.C_TakeWakan()
	msg.posId = data.posId
	for i=1, #data.itemIds do
		msg.listItems:append(data.itemIds[i])
	end
	self:SendMsg("C_TakeWakan", msg)
end

--注灵反馈
function WakanController:RespondTakeWakanHandler(buffer)
	local msg = self:ParseMsg(wakan_pb.S_TakeWakan(), buffer)
	local isCrit = msg.isCrit
	if self.model then
		self.model:UpdateWakanPartInfo(msg.wakanMsg)
	end
	WakanModel:GetInstance():DispatchEvent(WakanConst.WakanDataUpdate, {true, isCrit == 1})
end

function WakanController:OpenWakanPanel()
	if self.view and self.model then 
		self.model:FillPlayerEquipList()
		self.view:Open()
	end
end

function WakanController:GetWakanPanel()
	if self.view == nil then
		self.view = WakanView.New()
	end
	self:ReqWakanListHandler(data)
	return self.view:GetWakanPanel()
end

function WakanController:DestroyWakanPanel()
	if self.view ~= nil then
		self.view:Destroy()
	end
	self.view = nil
end

function WakanController:Close()
	if self.view then 
		self.view:Close()
	end
end

function WakanController:__delete()
	self:RemoveEvent()
	if self.view then
		self.view:Destroy()
		self.view = nil
	end
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
	WakanController.inst = nil
end
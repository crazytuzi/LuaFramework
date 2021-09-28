RegistModules("Wing/WingConst")
RegistModules("Wing/WingModel")
RegistModules("Wing/WingView")

RegistModules("Wing/Vo/WingDynamicVo")

RegistModules("Wing/View/WingActivePanel")
RegistModules("Wing/View/WingCostPropItem")
RegistModules("Wing/View/prop")
RegistModules("Wing/View/Start")
RegistModules("Wing/View/Starts")
RegistModules("Wing/View/UpProp")
RegistModules("Wing/View/WingItem")
RegistModules("Wing/View/WingItemGroup")
RegistModules("Wing/View/WingPanel_Left")
RegistModules("Wing/View/WingPanel_Right")
RegistModules("Wing/View/WingUpPanel")
RegistModules("Wing/View/WingPanel")

WingController =BaseClass(LuaController)

function WingController:GetInstance()
	if WingController.inst == nil then
		WingController.inst = WingController.New()
	end
	return WingController.inst
end

function WingController:__init()
	self.model = WingModel:GetInstance()
	resMgr:AddUIAB("Wing")
	self.view = nil

	self:InitEvent()
	self:RegistProto()

	self.getRankDataSuccess = false
end

function WingController:InitEvent()
	
end

-- 协议注册
function WingController:RegistProto()
	self:RegistProtocal("S_SynWingList") --羽翼数据改变
	self:RegistProtocal("S_PutonWing") --装备翅膀
	self:RegistProtocal("S_PutdownWing") --卸下翅膀
	self:RegistProtocal("S_Evolve") --羽化
	self:RegistProtocal("S_AddWing") --激活新的羽翼
	self:RegistProtocal("S_UnEvolve") --羽翼降解--
end

function WingController:S_AddWing(buff)
	local msg = self:ParseMsg(wing_pb.S_AddWing(), buff)
	self.model:ActiveWing(msg)
end

function WingController:S_SynWingList(buff)
	local msg = self:ParseMsg(wing_pb.S_SynWingList(), buff)
	self.model:ParseSynWingData(msg)
end

function WingController:S_PutonWing(buff)
	local msg = self:ParseMsg(wing_pb.S_PutonWing(), buff)
	self.model:PutOnWing(msg)
end

function WingController:S_PutdownWing(buff)
	local msg = self:ParseMsg(wing_pb.S_PutdownWing(), buff)
	self.model:PutDownWing(msg)
end

function WingController:S_Evolve(buff)
	local msg = self:ParseMsg(wing_pb.S_Evolve(), buff)
	self.model:ParseEvolveData(msg)
end

function WingController:S_UnEvolve(buff)
	local msg = self:ParseMsg(wing_pb.S_UnEvolve(), buff)
	self.model:ParseEvolveData(msg)
end

function WingController:C_GetWingList()
	local msg = wing_pb.C_GetWingList()
	self:SendMsg("C_GetWingList", msg)
end

function WingController:C_PutonWing(wingId)
	local msg = wing_pb.C_PutonWing()
	msg.wingId = wingId
	self:SendMsg("C_PutonWing", msg)
end

function WingController:C_PutdownWing(wingId)
	local msg = wing_pb.C_PutdownWing()
	msg.wingId = wingId
	self:SendMsg("C_PutdownWing", msg)
end

function WingController:C_Evolve(type, wingId, itemId)
	local msg = wing_pb.C_Evolve()
	msg.type = type
	msg.wingId = wingId
	msg.itemId = itemId
	self:SendMsg("C_Evolve", msg)
end

function WingController:C_UnEvolve(wingId)
	local msg = wing_pb.C_UnEvolve()
	msg.wingId = wingId
	self:SendMsg("C_UnEvolve", msg)
end

function WingController:GetWingPanel(activeIds)
	if self.view == nil then
		self.view = WingView.New()
	end
	self:C_GetWingList()
	return self.view:GetWingPanel(activeIds)
end

function WingController:DestroyWingPanel()
	if self.view ~= nil then
		self.view:Destroy()
	end
	self.view = nil
	WingModel.NewActive = nil
end

function WingController:Close()
	if self.view then 
		self.view:Close()
	end
end

function WingController:__delete()
	self:DestroyWingPanel()

	if self.view then
		self.view:Destroy()
		self.view = nil
	end

	if self.model then
		self.model:Destroy()
		self.model = nil
	end

	WingController.inst = nil
end
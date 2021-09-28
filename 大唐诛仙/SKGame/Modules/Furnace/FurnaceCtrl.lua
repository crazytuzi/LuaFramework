RegistModules("Furnace/FurnaceConst")
RegistModules("Furnace/FurnaceModel")
RegistModules("Furnace/FurnaceVo")
RegistModules("Furnace/View/StarComp")
RegistModules("Furnace/View/GotFromComp")
RegistModules("Furnace/View/AttrLabel")
RegistModules("Furnace/View/FurnaceItemI")
RegistModules("Furnace/View/FurnaceItemII")
RegistModules("Furnace/View/FurnacePanel")
RegistModules("Furnace/FurnaceMainPanel")

-- 队伍控制器
FurnaceCtrl = BaseClass(LuaController)
function FurnaceCtrl:GetInstance()
	if FurnaceCtrl.inst == nil then
		FurnaceCtrl.inst = FurnaceCtrl.New()
	end
	return FurnaceCtrl.inst
end

function FurnaceCtrl:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()
end
function FurnaceCtrl:Config()
	self.view = nil
	self.model = FurnaceModel:GetInstance()
end
function FurnaceCtrl:Open(t)
	self:GetMainPanel():Open(tabIndex)
end
-- 获取主面板
function FurnaceCtrl:GetMainPanel()
	if not self:IsExistView() then
		self.view = FurnaceMainPanel.New()
	end
	return self.view
end
-- 判断主面板是否存在
function FurnaceCtrl:IsExistView()
	return self.view and self.view.isInited
end
function FurnaceCtrl:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED , function ()
		GlobalDispatcher:RemoveEventListener(self.handler0)
		self:UpdateData(LoginModel:GetInstance():GetFurnaceList())
	end)
end
function FurnaceCtrl:RegistProto()
	self:RegistProtocal("S_GetPlayerFurnaceList")
	self:RegistProtocal("S_UpgradeFurnace")
end
-- 玩家已激活列表
function FurnaceCtrl:S_GetPlayerFurnaceList(buff)
	local msg = self:ParseMsg(furnace_pb.S_GetPlayerFurnaceList(),buff)
	self:UpdateData(msg.furnaceList)
	self.model:DispatchEvent(FurnaceConst.FurnaceListChange)
end
function FurnaceCtrl:UpdateData(list)
	SerialiseProtobufList( list, function ( item ) -- 玩家熔炉信息
		-- print(">>>>>>>>>>>>>>",item.stage, item.star, item.furnaceId)
		self.model:UpdateItem(item)
	end )
end
-- 升级熔炉
function FurnaceCtrl:S_UpgradeFurnace(buff)
	local msg = self:ParseMsg(furnace_pb.S_UpgradeFurnace(),buff)
	self.model:DispatchEvent(FurnaceConst.FurnaceUplevelChange, msg.playerFurnace)
end

-- 玩家已激活熔炉列表
function FurnaceCtrl:C_GetPlayerFurnaceList()
	self:SendEmptyMsg(furnace_pb, "C_GetPlayerFurnaceList")
end
-- 升级熔炉
function FurnaceCtrl:C_UpgradeFurnace(furnaceId)
	local msg = furnace_pb.C_UpgradeFurnace()
	msg.furnaceId = furnaceId
	self:SendMsg("C_UpgradeFurnace",msg)
end

-- 销毁
function FurnaceCtrl:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	FurnaceCtrl.inst = nil
	if self:IsExistView() then
		self.view:Destroy()
	end
	self.view = nil
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
end
RegistModules("GodFightRune/GodFightRuneView")
RegistModules("GodFightRune/GodFightRuneModel")

RegistModules("GodFightRune/View/GodFightRuneContent")
RegistModules("GodFightRune/View/GodFightRuneEffect")
RegistModules("GodFightRune/View/GodFightRuneItem")
RegistModules("GodFightRune/View/GodFightRunePanel")
RegistModules("GodFightRune/View/TabGodFightRune")
RegistModules("GodFightRune/View/GodFightRuneTips")

RegistModules("GodFightRune/Vo/RuneVo")
RegistModules("GodFightRune/Vo/InscriptionEffectVo")

RegistModules("GodFightRune/GodFightRuneConst")

GodFightRuneController =BaseClass(LuaController)

function GodFightRuneController:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()
end

function GodFightRuneController:__delete()
	self:CleanEvent()
	GodFightRuneController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	if self.view then
		self.view:Destroy()
	end
	self.view = nil
end


function GodFightRuneController:Config()
	self.model = GodFightRuneModel:GetInstance()
	self.view = GodFightRuneView.New()
end

function GodFightRuneController:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED , function ()
		GlobalDispatcher:RemoveEventListener(self.handler0)
		self:InitData()
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end
	end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_DIE , function ()
		if self.model then
			self.model:ShowRedTips()
		end
	end)
end

function GodFightRuneController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
end

--初始化玩家身上的装备铭文效果列表
function GodFightRuneController:InitData()
	local listPlayerWeaponEffect = LoginModel:GetInstance():GetListPlayerWeaponEffect()
	self.model:SetData(listPlayerWeaponEffect or {})
	--zy("====== 初始化玩家身上的装备铭文效果列表")
	self.model:ShowRedTips()
end

function GodFightRuneController:RegistProto()
	self:RegistProtocal("S_Epigraph", "RepUseGodFightRune")
	self:RegistProtocal("S_FuseItem", "RepCompoundRune")
	self:RegistProtocal("S_SynPlayerWeaponEffect", "HandleSyncWeaponInscriptionEffect")
end

function GodFightRuneController:GetInstance()
	if GodFightRuneController.inst == nil then
		GodFightRuneController.inst = GodFightRuneController.New()
	end
	return GodFightRuneController.inst
end

function GodFightRuneController:OpenGodFightRunePanel()
	if self.view then
		self.view:OpenGodFightRunePanel()
	end
end

--使用斗神印请求
--使用斗神印请求
function GodFightRuneController:ReqUseGodFightRune(equipmentId, playerBagId, holeId)
	if equipmentId ~= -1 and holeId ~= -1 and itemId ~= 0 then
		local msg = equipment_pb:C_Epigraph()
		msg.playerEquipmentId = equipmentId
		msg.playerBagId = playerBagId
		msg.holeId = holeId
		self:SendMsg("C_Epigraph", msg)
	end
end

function GodFightRuneController:ReqCompoundRune(itemId)
	if itemId ~= -1 then
		local msg = bag_pb:C_FuseItem()
		msg.itemId = itemId
		self:SendMsg("C_FuseItem", msg)
	end
end

function GodFightRuneController:RepCompoundRune(msgParam)
	local msg = self:ParseMsg(bag_pb:S_FuseItem(), msgParam)
	if msg then
		UIMgr.Win_FloatTip("合成成功")
		GlobalDispatcher:DispatchEvent(EventName.CompoundRuneSucc)
	end
end

--使用斗神印回包处理
function GodFightRuneController:RepUseGodFightRune(msgParam)
	local msg = self:ParseMsg(equipment_pb:S_Epigraph(), msgParam)
	if msg then
		self.model:DispatchEvent(GodFightRuneConst.EpigraphSucc , msg.holeId)
		UIMgr.Win_FloatTip("使用斗神印成功")
	end
end 

function GodFightRuneController:HandleSyncWeaponInscriptionEffect(msgParam)
	local msg = self:ParseMsg(equipment_pb:S_SynPlayerWeaponEffect(), msgParam)
	if msg.effectMsg then
		self.model:SyncInscriptionData(msg.effectMsg)
		GlobalDispatcher:DispatchEvent(EventName.RefershWeaponInscription)
		self.model:ShowRedTips()
	end
end


require("game/cross_server_supremacy/supremacy_data")
require("game/cross_server_supremacy/supremacy_view")
SupremacyCtrl = SupremacyCtrl or BaseClass(BaseController)

function SupremacyCtrl:__init()
	if SupremacyCtrl.Instance ~= nil then
		print_error("[ElementBattleCtrl] attempt to create singleton twice!")
		return
	end
	SupremacyCtrl.Instance = self

	self.data = SupremacyData.New()
	self.view = SupremacyView.New(ViewName.SupremacyView)

	self:RegisterAllProtocols()
end

function SupremacyCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	SupremacyCtrl.Instance = nil
end

function SupremacyCtrl:RegisterAllProtocols()
	--跨服信息
	self:RegisterProtocol(SCFBInfo, "OnSCFBInfo")							--各国纪念碑数量	
	self:RegisterProtocol(SCRoleDakuafuParam, "OnSCRoleDakuafuParam")		--单个场景玩家信息	
	self:RegisterProtocol(SCFBAllMessage, "OnSCFBAllMessage")				--所有场景玩家信息
	self:RegisterProtocol(SCGiftinfo, "OnSCGiftinfo")						--跨服天降好礼信息

	--跨服boss
	self:RegisterProtocol(SCBossInfo, "OnSCBossInfo")
	self:RegisterProtocol(BossTaskInfo, "OnBossTaskInfo")
end

function SupremacyCtrl:OnSCFBInfo(protocol)
	self.data:SetMountment(protocol)
	if self.view then
		self.view:Flush("Mountment")
	end
end

function SupremacyCtrl:OnSCRoleDakuafuParam(protocol)
	self.data:SetSingleInfo(protocol)
	if self.view then
		self.view:Flush("SingleInfo")
	end
	self:ShowAddHonour(protocol)
end

function SupremacyCtrl:ShowAddHonour(protocol)
	local seq = protocol.seq or 0
	local list = protocol.item_list[seq] or {}
	if self.honour_exp == nil and list.cross_rongyao then
		self.honour_exp = list.cross_rongyao
		return
	end
	if list.cross_rongyao and list.cross_rongyao > self.honour_exp then
		TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.Honour.AddHonour,list.cross_rongyao - self.honour_exp))
		self.honour_exp = list.cross_rongyao
	end
end

function SupremacyCtrl:OnSCFBAllMessage(protocol)
	
end

function SupremacyCtrl:OnSCGiftinfo(protocol)
	self.data:SetHaoLiInfo(protocol)
	if self.view then
		self.view:Flush("hao_li")
	end
end

function SupremacyCtrl:OnSCBossInfo(protocol)
	self.data:SetBossInfoData(protocol)
	GlobalEventSystem:Fire(ObjectEventType.OBJ_MONSTER_CHANGE)
	if self.view then
		self.view:Flush("boss")
	end
	if MainUICtrl.Instance.view.target_view then
		MainUICtrl.Instance.view.target_view:OnFirstHurtChange(protocol.exist, protocol.first_hurt)
	else
		self.scene_loaded = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnSceneLoaded, self, protocol.exist, protocol.first_hurt))
	end
end

function SupremacyCtrl:OnBossTaskInfo(protocol)
	self.data:SetBossTaskData(protocol)
	if self.view then
		self.view:Flush("boss")
	end
end


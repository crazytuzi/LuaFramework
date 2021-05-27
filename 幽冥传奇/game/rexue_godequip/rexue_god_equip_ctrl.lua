require("scripts/game/rexue_godequip/rexue_god_equip_data")
require("scripts/game/rexue_godequip/rexue_god_equip_view")
require("scripts/game/rexue_godequip/rexue_god_suit_tip")
require("scripts/game/rexue_godequip/rexue_shenge_view")

ReXueGodEquipCtrl = ReXueGodEquipCtrl or BaseClass(BaseController)
function ReXueGodEquipCtrl:__init( ... )
	if ReXueGodEquipCtrl.Instance then
		ErrorLog("[ReXueGodEquipCtrl] Attemp to create a singleton twice !")
	end
	ReXueGodEquipCtrl.Instance = self

	self.data = ReXueGodEquipData.New()

	self.view = ReXueGodEquipView.New(ViewDef.MainGodEquipView)
	self.tip_view = ReXueGodEquipSuitView.New(ViewDef.ReXueSuitTip)
	self.rexue_shenge_view = RexueShengeView.New(ViewDef.RexueShenge)

	self:RegisterAllProtocols()

	self.login_info_event = self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
	self.pass_data_event = self:BindGlobalEvent(OtherEventType.PASS_DAY, BindTool.Bind(self.OnPassDay, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.RexueShenBinDuiHuan)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.RexueShenBinUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ReXueZhanShenUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ReXueShaShenUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.WingCompose)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ZhanChongCompose)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.RexueShenzhu)

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
end


function ReXueGodEquipCtrl:__delete( ... )
	ReXueGodEquipCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	
	
	if self.login_info_event then
		self:UnBindGlobalEvent(self.login_info_event)
		self.login_info_event = nil
	end

	if self.pass_data_event then
		self:UnBindGlobalEvent(self.pass_data_event)
		self.pass_data_event = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	if self.tip_view then
		self.tip_view:DeleteMe()
		self.tip_view = nil
	end
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	if self.rexue_shenge_view then
		self.rexue_shenge_view:DeleteMe()
		self.rexue_shenge_view = nil
	end
end

function ReXueGodEquipCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCAllShenzhuData, "OnAllShenzhuData")
	self:RegisterProtocol(SCAllShengeData, "OnAllShengeData")
	self:RegisterProtocol(SCShenzhuResult, "OnShenzhuResult")
	self:RegisterProtocol(SCShengeResult, "OnShengeResult")
end

function ReXueGodEquipCtrl:RecvMainInfoCallBack( ... )
	if self.timer == nil then
		self.timer = GlobalTimerQuest:AddDelayTimer(function ( ... )
				if self.timer then
					GlobalTimerQuest:CancelQuest(self.timer)
					self.timer = nil
				end
				self:FlushDuiHuan()
				self:FlushReXueUp()
		end, 2)
	end
	
	RemindManager.Instance:DoRemindDelayTime( RemindName.ReXueZhanShenUp, 0.2)
	RemindManager.Instance:DoRemindDelayTime( RemindName.ReXueShaShenUp, 0.2)
	RemindManager.Instance:DoRemindDelayTime( RemindName.WingCompose, 0.2)
	RemindManager.Instance:DoRemindDelayTime( RemindName.ZhanChongCompose, 0.2)
	RemindManager.Instance:DoRemindDelayTime( RemindName.RexueShenzhu)
end

function ReXueGodEquipCtrl:OnPassDay( ... )
	self:FlushDuiHuan()
	self:FlushReXueUp()
	RemindManager.Instance:DoRemindDelayTime( RemindName.ReXueZhanShenUp, 0.2)
	RemindManager.Instance:DoRemindDelayTime( RemindName.ReXueShaShenUp, 0.2)
	RemindManager.Instance:DoRemindDelayTime( RemindName.WingCompose, 0.2)
	RemindManager.Instance:DoRemindDelayTime( RemindName.ZhanChongCompose, 0.2)
end

function ReXueGodEquipCtrl:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_VIP_GRADE then
		self:FlushDuiHuan()
	 elseif vo.key == OBJ_ATTR.CREATURE_LEVEL then
	 	self:FlushDuiHuan()
	 	self:FlushReXueUp()
	 	RemindManager.Instance:DoRemindDelayTime( RemindName.ReXueZhanShenUp, 0.2)
		RemindManager.Instance:DoRemindDelayTime( RemindName.ReXueShaShenUp, 0.2)
		RemindManager.Instance:DoRemindDelayTime( RemindName.WingCompose, 0.2)
		RemindManager.Instance:DoRemindDelayTime( RemindName.ZhanChongCompose, 0.2)
	 elseif vo.key == OBJ_ATTR.ACTOR_CIRCLE then
		self:FlushDuiHuan()
		self:FlushReXueUp()
		RemindManager.Instance:DoRemindDelayTime( RemindName.WingCompose, 0.2)
		RemindManager.Instance:DoRemindDelayTime( RemindName.ZhanChongCompose, 0.2)
	elseif vo.key == OBJ_ATTR.ACTOR_COIN then
		RemindManager.Instance:DoRemindDelayTime( RemindName.RexueShenBinDuiHuan, 0.2)
		RemindManager.Instance:DoRemindDelayTime( RemindName.RexueShenBinUp, 0.2)
		RemindManager.Instance:DoRemindDelayTime( RemindName.ReXueZhanShenUp, 0.2)
		RemindManager.Instance:DoRemindDelayTime( RemindName.ReXueShaShenUp, 0.2)
		RemindManager.Instance:DoRemindDelayTime( RemindName.WingCompose, 0.2)
		RemindManager.Instance:DoRemindDelayTime( RemindName.ZhanChongCompose, 0.2)
	end
end

function ReXueGodEquipCtrl:FlushDuiHuan( ... )
	self.data:InitData()
	RemindManager.Instance:DoRemindDelayTime( RemindName.RexueShenBinDuiHuan, 0.2)
end

function ReXueGodEquipCtrl:FlushReXueUp( ... )
	self.data:SetRewardComspoe()
	RemindManager.Instance:DoRemindDelayTime( RemindName.RexueShenBinUp, 0.2)
end

function ReXueGodEquipCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.RexueShenBinDuiHuan then
		return self.data:GetIsRemindData()
	elseif remind_name == RemindName.RexueShenBinUp then
		return self.data:GetReXueUpPoint()
	elseif remind_name == RemindName.ReXueZhanShenUp then
		return self.data:GetZhanShenCanCompose()
	elseif remind_name == RemindName.ReXueShaShenUp then
		return self.data:GetShaShenCanCompose()
	elseif remind_name == RemindName.WingCompose then
		return self.data:SingleCanPoint(15) and 1 or 0   --翅膀合成类型
	elseif remind_name == RemindName.ZhanChongCompose then
		return self.data:SingleCanPoint(16) and 1 or 0  --战宠合成类型
	elseif remind_name == RemindName.RexueShenzhu then
		return self.data:GetShenzhuRemindNum()
	end
end

function ReXueGodEquipCtrl:ItemDataListChangeCallback(event)
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ()
			RemindManager.Instance:DoRemindDelayTime(RemindName.RexueShenBinDuiHuan)
			RemindManager.Instance:DoRemindDelayTime( RemindName.RexueShenBinUp, 0.2)
			RemindManager.Instance:DoRemindDelayTime( RemindName.ReXueZhanShenUp, 0.2)
			RemindManager.Instance:DoRemindDelayTime( RemindName.ReXueShaShenUp, 0.2)
			RemindManager.Instance:DoRemindDelayTime( RemindName.WingCompose, 0.2)
			RemindManager.Instance:DoRemindDelayTime( RemindName.ZhanChongCompose, 0.2)
			if self.delay_timer then
				GlobalTimerQuest:CancelQuest(self.delay_timer)
				self.delay_timer = nil
			end
	end, 0.5)

	local shenzhu_consume_id = ReXueGodEquipData.Instance:GetShenzhuLevelConsumeId()
	local bool = false
	for i, v in pairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			bool = true
			break
		else
			local item_id = v.data.item_id
			if shenzhu_consume_id[item_id] then
				bool = true
				break
			end
		end
	end
	
	if bool then
		RemindManager.Instance:DoRemindDelayTime(RemindName.RexueShenzhu)
	end
end

function ReXueGodEquipCtrl:OnChangeOneEquip(param_t)
	-- 覆盖了常用槽位,不做判断.
	RemindManager.Instance:DoRemindDelayTime(RemindName.RexueShenzhu)
end

function ReXueGodEquipCtrl:ReqComspoeEquip(compose_type, equip_pos)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqComposeAtBodtEquip)
	protocol.compose_type = compose_type
	protocol.equip_pos = equip_pos
	protocol:EncodeAndSend()
end


function ReXueGodEquipCtrl:OpenTipView(SuitType)
	ViewManager.Instance:OpenViewByDef(ViewDef.ReXueSuitTip)
	self.tip_view:SetData(SuitType)
end

--------------------------------------------------------------------------------
-- 热血装备-神格
--------------------------------------------------------------------------------

-- 接收所有神铸数据(7, 52)
function ReXueGodEquipCtrl:OnAllShenzhuData(protocol)
	self.data:SetAllShenzhuData(protocol)
end

-- 接收所有神格数据(7, 53)
function ReXueGodEquipCtrl:OnAllShengeData(protocol)
	self.data:SetAllShengeData(protocol)
end

-- 接收神铸结果(7, 54)
function ReXueGodEquipCtrl:OnShenzhuResult(protocol)
	self.data:SetShenzhuResult(protocol)
end

-- 接收神格结果(7, 55)
function ReXueGodEquipCtrl:OnShengeResult(protocol)
	self.data:SetShengeResult(protocol)
end

-- 神铸(7, 56)
function ReXueGodEquipCtrl.ReqRexueShenzhu(slot, index_1, index_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRexueShenzhu)
	protocol.slot = slot
	protocol.index_1 = index_1
	protocol.index_2 = index_2
	protocol:EncodeAndSend()
end

-- 神格(7, 57)
function ReXueGodEquipCtrl.ReqRexueShenge(slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRexueShenge)
	protocol.slot = slot
	protocol:EncodeAndSend()
end

--------------------------------------------------------------------------------
-- 热血装备-神格
--------------------------------------------------------------------------------
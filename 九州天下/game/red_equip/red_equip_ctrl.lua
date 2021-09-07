require("game/red_equip/red_equip_data")
require("game/red_equip/red_equip_view")

RedEquipCtrl = RedEquipCtrl or BaseClass(BaseController)
function RedEquipCtrl:__init( )
	if nil ~= RedEquipCtrl.Instance then
		print_error("[RedEquipCtrl] Attemp to create a singleton twice !")
		return
	end
	RedEquipCtrl.Instance = self

	self.red_equip_view = RedEquipView.New(ViewName.RedEquipView)
	self.red_equip_data = RedEquipData.New()

	if not self.item_change then
		self.item_change = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
	end
	self:RegisterAllProtocols()
end

function RedEquipCtrl:__delete( )
	if self.red_equip_view ~= nil then
		self.red_equip_view:DeleteMe()
		self.red_equip_view = nil
	end

	if self.red_equip_data ~= nil then
		self.red_equip_data:DeleteMe()
		self.red_equip_data = nil
	end
	if self.item_change ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end
	RemindManager.Instance:UnRegister(RemindName.RedEquip)
	RedEquipCtrl.Instance = nil
end

function RedEquipCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRedEquipCollect, "OnSCRedEquipCollect")
	self:RegisterProtocol(SCRedEquipCollectOther, "OnSCRedEquipCollectOther")

	RemindManager.Instance:Register(RemindName.RedEquip, BindTool.Bind(self.RedEquipRemind, self))
end

function RedEquipCtrl:OnSCRedEquipCollect(protocol)
	self.red_equip_data:RedEquipCollect(protocol)
	self.red_equip_view:Flush()
	RemindManager.Instance:Fire(RemindName.RedEquip)
end

function RedEquipCtrl:OnSCRedEquipCollectOther(protocol)
	local index = self.red_equip_data:GetActiveMax()
	self.red_equip_data:RedEquipCollectOther(protocol)
	self.red_equip_view:Flush()
	local next_index = self.red_equip_data:GetActiveMax()
	if OpenFunData.Instance:CheckIsHide("redequip") and index ~= -1 and next_index > index then
		local cfg = OpenFunData.Instance:GetSingleCfg("redequip")
		TipsCtrl.Instance:ShowOpenFunFlyView(cfg)
	end
	KaiFuChargeCtrl.Instance:Flush("red_equip_activity_flush")

	local kaifu_time = TimeCtrl.Instance:GetCurOpenServerDay()				--当前开服天数
	if kaifu_time <= 6 then
		RemindManager.Instance:Fire(RemindName.KaiFuRedEquip)
	end
end

-- COMMON_OPERATE_TYPE.COT_REQ_RED_EQUIP_COLLECT_TAKEON 
-- 红装收集，请求穿上，param1是红装seq，param2是红装槽index， param3是背包index，
function RedEquipCtrl:SendRedEquipInfo(operate_type, param1, param2, param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSReqCommonOpreate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end

function RedEquipCtrl:RedEquipRemind()
	local num = #self.red_equip_data:GetOtherInfo() + 1
	for i=0,num do
		if RedEquipData.Instance:GetEquipList(i) and self.red_equip_data:GetActiveFlag(i) == 1 then
			return 1 
		end
	end
	return 0
end

function RedEquipCtrl:ItemDataChangeCallback(item_id)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
		RemindManager.Instance:Fire(RemindName.RedEquip)
		self.red_equip_view:Flush()
	end
end
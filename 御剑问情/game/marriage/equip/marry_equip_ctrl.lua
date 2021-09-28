require("game/marriage/equip/marry_equip_data")
require("game/marriage/equip/marry_equip_guaji_view")
require("game/marriage/equip/marry_equip_recyle_view")
require("game/marriage/equip/marry_equip_recyle_info_view")
require("game/marriage/equip/marry_equip_suit_view")
--------------------------------------------------------------
--情缘装备
--------------------------------------------------------------
MarryEquipCtrl = MarryEquipCtrl or BaseClass(BaseController)

function MarryEquipCtrl:__init()
	if MarryEquipCtrl.Instance then
		print_error("[MarryEquipCtrl] Attemp to create a singleton twice !")
	end
	MarryEquipCtrl.Instance = self
	self.data = MarryEquipData.New()
	self.guaji_view = MarryEquipGuajiView.New()
	self.recyle_view = MarryEquipRecyleView.New()
	self.recyle_info_view = MarryEquipReclyeInfoView.New(ViewName.ReclyeInfoView)
	self.suit_view = MarryEquipSuitView.New(ViewName.MarryEquipSuitView)

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event, true)
	self:RegisterAllProtocols()
end

function MarryEquipCtrl:__delete()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	self.item_data_event = nil

	self.data:DeleteMe()
	self.data = nil

	self.guaji_view:DeleteMe()
	self.guaji_view = nil

	self.recyle_view:DeleteMe()
	self.recyle_view = nil

	if self.recyle_info_view then
		self.recyle_info_view:DeleteMe()
		self.recyle_info_view = nil
	end

	if self.suit_view then
		self.suit_view:DeleteMe()
		self.suit_view = nil
	end
	
	MarryEquipCtrl.Instance = nil
end

function MarryEquipCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCQingyuanEquipInfo, "OnQingyuanEquipInfo")						-- 情缘装备信息
end

function MarryEquipCtrl:OpenGuajiView()
	self.guaji_view:Open()
end

function MarryEquipCtrl:OpenRecyleView(call_back)
	self.recyle_view:SetCallBack(call_back)
	self.recyle_view:Open()
end

function MarryEquipCtrl:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local item_cfg = nil
	if item_id then
		item_cfg = ItemData.Instance:GetItemConfig(item_id)
	end
	if nil == item_id or (item_cfg and EquipData.IsMarryEqType(item_cfg.sub_type)) then
		self.data:ClearCacheQingYuanEquipList()
		ViewManager.Instance:FlushView(ViewName.Marriage, "equip")
		if not self.data:IsMaxMarryLevel() and (PUT_REASON_TYPE.PUT_REASON_PICK == put_reason or PUT_REASON_TYPE.PUT_REASON_GM == put_reason)
			and item_cfg and item_cfg.color <= SettingData.Instance:GetMarryEquipIndex() and not self.data:IsBetterMarryEquip(item_id) then
			PackageCtrl.Instance:SendDiscardItem(index, new_num, item_id, new_num, 1)
		end
	end
end

-- 请求爱人装备信息
function MarryEquipCtrl.SendActiveLoverEquipInfo()
	if GameVoManager.Instance:GetMainRoleVo().lover_uid <= 0 then return end
	MarryEquipCtrl.SendQingyuanEquipOperate(QINGYUAN_EQUIP_REQ_TYPE.OTHER_EQUIP_INFO)
end

-- 请求激活套装
function MarryEquipCtrl.SendActiveQingyuanSuit(suit_type, slot, bag_index)
	MarryEquipCtrl.SendQingyuanEquipOperate(QINGYUAN_EQUIP_REQ_TYPE.ACTIVE_SUIT, suit_type, slot, bag_index)
end

-- 卸下情缘装备
function MarryEquipCtrl.SendTakeOffQingyuanEquip(index)
	MarryEquipCtrl.SendQingyuanEquipOperate(QINGYUAN_EQUIP_REQ_TYPE.TAKE_OFF, index)
end

-- 情缘装备操作
function MarryEquipCtrl.SendQingyuanEquipOperate(operate_type, param_1, param_2, param_3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanEquipOperate)
	protocol.operate_type = operate_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end

--情缘装备信息
function MarryEquipCtrl:OnQingyuanEquipInfo(protocol)
	self.data:SetMarryEquipInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.Marriage, "equip")
	RemindManager.Instance:Fire(RemindName.MarryEquip)
	RemindManager.Instance:Fire(RemindName.MarrySuit)
	RemindManager.Instance:Fire(RemindName.MarryEquipRecyle)
end

--刷新回收装备面板
function MarryEquipCtrl:FlushMarryEquipReclyeInfoView()
	if self.recyle_info_view:IsOpen() then
		self.recyle_info_view:Flush()
	end
end

--刷新珍藏面板
function MarryEquipCtrl:FlushMarryEquipSuitView()
	if self.suit_view:IsOpen() then
		self.suit_view:Flush()
	end
end

--装备和珍藏面板是否开启
function MarryEquipCtrl:IsOpenView()
	local  is_open = not self.suit_view:IsOpen() and not self.recyle_info_view:IsOpen()
	return is_open
end
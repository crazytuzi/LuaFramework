require("scripts/game/wing/wing_data")
require("scripts/game/wing/wing_view")
require("scripts/game/wing/wing_adjust_cfg")
require("scripts/game/wing/wing_dialog")
require("scripts/game/wing/wing_buy_gift")
require("scripts/game/wing/wing_wing")
require("scripts/game/wing/wing_compound_view")
require("scripts/game/wing/wing_preview_view")

WingCtrl = WingCtrl or BaseClass(BaseController)

function WingCtrl:__init()
	if WingCtrl.Instance then
		ErrorLog("[WingCtrl]:Attempt to create singleton twice!")
	end
	WingCtrl.Instance = self

	--获取神羽数据到本地
	self.data = WingData.New()
	--wing主界面
	self.view = WingView.New(ViewDef.Wing)

	--通过调用夫类的方法注册协议
	self:RegisterAllProtocols()
	
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.WingUpgrade, true)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.ShenYu, true)
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function WingCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	-- self.WingShenyuView:DeleteMe()
	-- self.WingShenyuView = nil

	-- self.shenyuData:DeleteMe()
	-- self.shenyuData = nil

    WingCtrl.Instance = nil
end

function WingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCWingInfo, "OnWingInfo")
	self:RegisterProtocol(SCAddEquipment, "OnAddEquipment")	
	self:RegisterProtocol(SCUpdataDieResult, "OnUpdataDieResult")
	self:RegisterProtocol(SCTakeoffEquipIndex, "OnTakeoffEquipIndex")
end

--所有装备信息
function WingCtrl:OnWingInfo(protocol)
	
	self.data:SetNewWingEquipData(protocol.equip_list)
	-- self.shenyuData:SetEquipList(protocol.equip_list)
	
	self.data:SetEquipInfoData(protocol)
	self.view:Flush(self.view:GetShowIndex())
end

--添加装备信息
function WingCtrl:OnAddEquipment(protocol)
	self.data:SetAddWingment(protocol.item)

	self.view:Flush(self.view:GetShowIndex())
end

function WingCtrl:OnRecvMainRoleInfo()
	self.view:Flush(self.view:GetShowIndex())
end

--激活、进阶翅膀
function WingCtrl.SendWingUpGradeReq(auto_upgrade,use_gold)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWingUpGradeReq)
	protocol.auto_upgrade = auto_upgrade
	protocol.use_gold = use_gold
	protocol:EncodeAndSend()
end

--装备神羽
function WingCtrl.SendEquipmentShenyu(guid)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipmentShenyu)
	protocol.guid = guid
	protocol:EncodeAndSend()
end

--装备幻化
function WingCtrl.SendEquipDie(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWingEquipHhReq)
	protocol.hh_equip_index = index
	protocol:EncodeAndSend()
end

--脱下神羽
function WingCtrl.SendTakeOfftShenyu(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipTakeoff)
	protocol.equ_index = index
	protocol:EncodeAndSend()
end

--取消幻化
function WingCtrl.SendCancelDie()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCanCelDieReq)
	protocol:EncodeAndSend()
end

--转换神羽
function WingCtrl.SendChangeShenyu(guid,id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSChangeShenyu)
	protocol.guid = guid
	protocol.id = id
	protocol:EncodeAndSend()
end

function WingCtrl:GetRemindSign(remind_name)
	if remind_name == RemindName.WingStone then
		return 0
	elseif remind_name == RemindName.ShenYu then
		return 0--self.data:WingCanUpRemind()
	elseif remind_name == RemindName.WingUpgrade then
		local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local cond_lv = GameCond[ViewDef.Wing.v_open_cond].RoleLevel or 0
		if role_lv < cond_lv then return 0 end
		return self.data:SetUpgradeData() + self.data:WingCanUpRemind()
	end
end

--神翼背包投入合成物品
function WingCtrl:MoveItemToWingFromBag(item)
	self.data:SetWingCompoundData(item)
	self.view:Flush(TabIndex.wing_compound)
end

function WingCtrl:MoveDataToWing()
	self.view:Flush(TabIndex.wing_compound, "move_cell")
end

-- 幻化结果
function WingCtrl:OnUpdataDieResult(protocol)
	self.data:SetDieResult(protocol)

	self.view:Flush(self.view:GetShowIndex())
end

-- 下发脱下装备槽位
function WingCtrl:OnTakeoffEquipIndex(protocol)
	self.data:GetTakeOffIndex(protocol.take_index)

	self.view:Flush(self.view:GetShowIndex())
end
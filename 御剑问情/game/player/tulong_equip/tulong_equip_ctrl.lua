require("game/player/tulong_equip/tulong_equip_data")
-- 屠龙装备
TulongEquipCtrl = TulongEquipCtrl or BaseClass(BaseController)

function TulongEquipCtrl:__init()
	if TulongEquipCtrl.Instance then
		print_error("[TulongEquipCtrl] 尝试生成第二个单例模式")
	end
	TulongEquipCtrl.Instance = self

	self.tulong_data = TulongEquipData.New()

	self:RegisterShenProtocols()
end

function TulongEquipCtrl:__delete()
	if nil ~= self.tulong_data then
		self.tulong_data:DeleteMe()
		self.tulong_data = nil
	end

	TulongEquipCtrl.Instance = nil
end

-- 注册协议
function TulongEquipCtrl:RegisterShenProtocols()
	self:RegisterProtocol(SCCSAEquipInfo, "OnCSAEquipInfo")
	self:RegisterProtocol(SCCSAActivePower, "OnSCCSAActivePower")
end

--场景上有角色屠龙装备特效变化
function TulongEquipCtrl:OnSCCSAActivePower(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj and obj.SetAttr then
		obj:SetAttr("combine_server_equip_active_special", protocol.combine_server_equip_active_special)
	end
end

------------------------神装
-- 神装升级 index装备下标
function TulongEquipCtrl:SendTulongUpLevel(index)
	TulongEquipCtrl.ReqShenzhaungOpreate(TulongEquipData.OPERATE_TYPE.UP_COMMON_LEVEL, index)
end
-- 神装升级 index装备下标
function TulongEquipCtrl:SendChuanshiUpLevel(index)
	TulongEquipCtrl.ReqShenzhaungOpreate(TulongEquipData.OPERATE_TYPE.UP_GREAT_LEVEL, index)
end

function TulongEquipCtrl.ReqShenzhaungOpreate(operate_type, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCSAEquipOpera)
	protocol.operate_type = operate_type
	protocol.index = index or 0
	protocol:EncodeAndSend()
end

function TulongEquipCtrl:OnCSAEquipInfo(protocol)
	self.tulong_data:SetPartList(protocol.part_list)
	self.tulong_data:SetCSPartList(protocol.cs_part_list)

	PlayerCtrl.Instance:FlushPlayerView("tulong_equip")
	Scene.Instance:GetMainRole():SetAttr("combine_server_equip_active_special", protocol.combine_server_equip_active_special)
	RemindManager.Instance:Fire(RemindName.TulongEquip)
	RemindManager.Instance:Fire(RemindName.CSTulongEquip)
end

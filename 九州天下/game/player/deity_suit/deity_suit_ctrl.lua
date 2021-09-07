require("game/player/deity_suit/deity_suit_data")
-- 神装
DeitySuitCtrl = DeitySuitCtrl or BaseClass(BaseController)

function DeitySuitCtrl:__init()
	if DeitySuitCtrl.Instance then
		print_error("[DeitySuitCtrl] 尝试生成第二个单例模式")
	end
	DeitySuitCtrl.Instance = self

	self.deity_suit_data = DeitySuitData.New()

	self:RegisterProtocols()
end

function DeitySuitCtrl:__delete()
	if nil ~= self.deity_suit_data then
		self.deity_suit_data:DeleteMe()
		self.deity_suit_data = nil
	end

	DeitySuitCtrl.Instance = nil
end

-- 注册协议
function DeitySuitCtrl:RegisterProtocols()
	self:RegisterProtocol(CSShenzhaungOper)
	self:RegisterProtocol(SCShenzhaungInfo, "OnShenzhaungInfo")
end

function DeitySuitCtrl:MainuiOpenShenCreate()
	DeitySuitCtrl.ReqShenzhaungOpreate(SHENZHUANG_OPERATE_TYPE.REQ)
end

------------------------神装
-- 神装升级 index装备下标
function DeitySuitCtrl:SendShenzhuangUpLevel(index)
	DeitySuitCtrl.ReqShenzhaungOpreate(SHENZHUANG_OPERATE_TYPE.UPLEVEL, index)
end

function DeitySuitCtrl.ReqShenzhaungOpreate(operate_type, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShenzhaungOper)
	protocol.operate_type = operate_type
	protocol.index = index or 0
	protocol:EncodeAndSend()
end

function DeitySuitCtrl:OnShenzhaungInfo(protocol)
	self.deity_suit_data:SetActSuitId(protocol.act_suit_id)
	self.deity_suit_data:SetPartList(protocol.part_list)

	PlayerCtrl.Instance:FlushPlayerView("deity_suit_change")
	RemindManager.Instance:Fire(RemindName.ShenEquip)
end

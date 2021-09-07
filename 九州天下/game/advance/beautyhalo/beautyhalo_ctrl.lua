require("game/advance/beautyhalo/beautyhalo_data")

BeautyHaloCtrl = BeautyHaloCtrl or BaseClass(BaseController)
local PLAYER_MOUNT_FLAG = nil
function BeautyHaloCtrl:__init()
	if BeautyHaloCtrl.Instance then
		print_error("[BeautyHaloCtrl] Attemp to create a singleton twice !")
		return
	end
	BeautyHaloCtrl.Instance = self

	self:RegisterAllProtocols()
	self.data = BeautyHaloData.New()
end

function BeautyHaloCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	BeautyHaloCtrl.Instance = nil
end

function BeautyHaloCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCJinglingGuanghuanInfo, "OnBeautyHaloInfoReq")
end

-- 美人光环信息
function BeautyHaloCtrl:OnBeautyHaloInfoReq(protocol)
	self.data:SetBeautyHaloInfo(protocol)
	AdvanceCtrl.Instance:FlushView("meiren_guanghuan")
	BeautyHaloHuanHuaCtrl.Instance:FlushView("halohuanhua")
	-- MountHuanHuaCtrl.Instance:FlushView("mounthuanhua")
	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 美人光环升星请求
function BeautyHaloCtrl:SendBeautyHaloUpStar(is_auto_buy,is_one_key)
	-- local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingGuanghuanUpStarLevel)
	-- send_protocol.is_auto_buy = is_auto_buy or 0
	-- send_protocol:EncodeAndSend()

	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingGuanghuanUpStarLevel)
	send_protocol.is_auto_buy = is_auto_buy or 0
	if 1 == send_protocol.is_auto_buy and is_one_key then
		local  beautyhalo_info = self.data:GetBeautyHaloInfo()
		local grade_info_list = self.data:GetCurBeautyHaloCfg(beautyhalo_info.grade)
		if nil ~= grade_info_list then
			send_protocol.repeat_times = grade_info_list.pack_num
		else
			send_protocol.repeat_times = 1
		end
	else
		send_protocol.repeat_times = 1
	end
	send_protocol:EncodeAndSend()
end

-- 美人光环使用形象请求
function BeautyHaloCtrl:SendBeautyHaloUseImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseJinglingGuanghuanImage)
	send_protocol.image_id = image_id or 0
	send_protocol:EncodeAndSend()
end

-- 美人光环信息请求
function BeautyHaloCtrl:SendGetBeautyHaloInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingGuanghuanGetInfo)
	send_protocol:EncodeAndSend()
end

-- 光环进阶结果返回 --
function BeautyHaloCtrl:OnHaloUpGradeOptResult(result)
	AdvanceCtrl.Instance:OnBeautyHaloUppGradeOptResult(result)
end

function BeautyHaloCtrl:SendShengongUpLevelReq(equip_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShengongUplevelEquip)
	send_protocol.equip_index = equip_index or 0
	send_protocol:EncodeAndSend()
end
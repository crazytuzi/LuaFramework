require("game/advance/halidom/halidom_data")

HalidomCtrl = HalidomCtrl or BaseClass(BaseController)
function HalidomCtrl:__init()
	if HalidomCtrl.Instance then
		print_error("[HalidomCtrl] Attemp to create a singleton twice !")
		return
	end
	HalidomCtrl.Instance = self

	self.halidom_data = HalidomData.New()
	
	self:RegisterAllProtocols()
end

function HalidomCtrl:__delete()
	if self.halidom_data ~= nil then
		self.halidom_data:DeleteMe()
		self.halidom_data = nil
	end

	HalidomCtrl.Instance = nil
end

function HalidomCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCJinglingFazhenInfo, "OnSpiritFazhenInfoReq")
end

-- 圣物信息
function HalidomCtrl:OnSpiritFazhenInfoReq(protocol)
	self.halidom_data:SetHalidomInfo(protocol)
	AdvanceCtrl.Instance:FlushView("halidom")
	-- RemindManager.Instance:Fire(RemindName.Spirit)
	HalidomHuanHuaCtrl.Instance:FlushView("halidomhuanhua")
	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 圣物升星请求
function HalidomCtrl:SendSpiritFazhenUpStar(is_auto_buy,is_one_key)
	-- local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingFazhenUpStarLevel)
	-- send_protocol.is_auto_buy = is_auto_buy or 0
	-- send_protocol:EncodeAndSend()

	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingFazhenUpStarLevel)
	send_protocol.is_auto_buy = is_auto_buy or 0
	if 1 == send_protocol.is_auto_buy and is_one_key then
		local halidom_info = self.halidom_data:GetHalidomInfo()
		local grade_info_list = self.halidom_data:GetCurHalidomCfg(halidom_info.grade)
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

-- 圣物使用形象请求
function HalidomCtrl:SendSpiritFazhenUseImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseJinglingFazhenImage)
	send_protocol.image_id = image_id or 0
	send_protocol:EncodeAndSend()
end

-- 圣物信息请求
function HalidomCtrl:SendGetSpiritFazhenInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingFazhenGetInfo)
	send_protocol:EncodeAndSend()
end

-- 圣物进阶结果返回
function HalidomCtrl:OnFazhenUppGradeOptResult(result)
	AdvanceCtrl.Instance:OnHalidomUppGradeOptResult(result)
end

require("game/dress_up/mask/mask_data")

MaskCtrl = MaskCtrl or BaseClass(BaseController)

function MaskCtrl:__init()
	if MaskCtrl.Instance then
		print_error("[MaskCtrl] Attemp to create a singleton twice !")
		return
	end
	MaskCtrl.Instance = self

	self:RegisterAllProtocols()
	self.mask_data = MaskData.New()
end

function MaskCtrl:__delete()
	if self.mask_data ~= nil then
		self.mask_data:DeleteMe()
		self.mask_data = nil
	end

	MaskCtrl.Instance = nil
end

function MaskCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMaskInfo, "OnMaskInfo");
end

function MaskCtrl:OnMaskInfo(protocol)
	if self.mask_data.mask_info and next(self.mask_data.mask_info) then
		if self.mask_data.mask_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		end
	end
	self.mask_data:SetMaskInfo(protocol)
	DressUpCtrl.Instance:FlushView("mask")
	MaskHuanHuaCtrl.Instance:FlushView("maskhuanhua")
	--PlayerCtrl.Instance:FlushPlayerView("cur_fashion")
	if protocol.temp_img_id_has_select == 0 and protocol.temp_img_id == 0 and protocol.temp_img_time ~= 0 then
		MainUICtrl.Instance:FlushView()
	end

	RemindManager.Instance:Fire(RemindName.DressUpMask)

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function MaskCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local repeat_times = 1
	if 1 == auto_buy and is_one_key then
		local mask_info = self.mask_data:GetMaskInfo()
		local grade_info_list = self.mask_data:GetMaskGradeCfg(mask_info.grade)
		
		if nil ~= grade_info_list then
			repeat_times = grade_info_list.pack_num
		end
	end
	self:SendMaskReq(UGS_REQ.REQ_TYPE_UP_GRADE,repeat_times,auto_buy)
end

-- 进阶结果返回
function MaskCtrl:OnUpgradeOptResult(result)
	DressUpCtrl.Instance:MaskUpgradeResult(result)
end

--发送使用形象请求
function MaskCtrl:SendUseMaskImage(image_id, is_temp_image)
	self:SendMaskReq(UGS_REQ.REQ_TYPE_USE_IMG,image_id,is_temp_image)
end

--发送取消使用形象请求
function MaskCtrl:SendUnuseMaskImage(image_id, is_temp_image)
	self:SendMaskReq(UGS_REQ.REQ_TYPE_UP_UNUSE_IMG,image_id,is_temp_image)
end

-- 发送技能升级请求
function MaskCtrl:MaskSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMaskSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function MaskCtrl:SendGetMaskInfo()
	self:SendMaskReq(UGS_REQ.REQ_TYPE_ALL_INFO)
end

function MaskCtrl:SendMaskUpLevelReq(equip_index)
	self:SendMaskReq(UGS_REQ.REQ_TYPE_UP_GRADE_EQUIP,equip_index)
end

function MaskCtrl:SendMaskReUseReq()
	self:SendMaskReq(UGS_REQ.REQ_TYPE_UP_REUSE_IMG)
end

function MaskCtrl:SendMaskReq(req_type,param1,param2,param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUgsMaskReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end
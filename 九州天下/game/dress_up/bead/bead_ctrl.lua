require("game/dress_up/bead/bead_data")

BeadCtrl = BeadCtrl or BaseClass(BaseController)

function BeadCtrl:__init()
	if BeadCtrl.Instance then
		print_error("[BeadCtrl] Attemp to create a singleton twice !")
		return
	end
	BeadCtrl.Instance = self

	self:RegisterAllProtocols()
	self.bead_data = BeadData.New()
end

function BeadCtrl:__delete()
	if self.bead_data ~= nil then
		self.bead_data:DeleteMe()
		self.bead_data = nil
	end

	BeadCtrl.Instance = nil
end

function BeadCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBeadInfo, "OnBeadInfo");
end

function BeadCtrl:OnBeadInfo(protocol)
	if self.bead_data.bead_info and next(self.bead_data.bead_info) then
		if self.bead_data.bead_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		end
	end
	self.bead_data:SetBeadInfo(protocol)
	DressUpCtrl.Instance:FlushView("bead")
	BeadHuanHuaCtrl.Instance:FlushView("beadhuanhua")
	--PlayerCtrl.Instance:FlushPlayerView("cur_fashion")
	if protocol.temp_img_id_has_select == 0 and protocol.temp_img_id == 0 and protocol.temp_img_time ~= 0 then
		MainUICtrl.Instance:FlushView()
	end

	RemindManager.Instance:Fire(RemindName.DressUpBead)

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function BeadCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local repeat_times = 1
	if 1 == auto_buy and is_one_key then
		local bead_info = self.bead_data:GetBeadInfo()
		local grade_info_list = self.bead_data:GetBeadGradeCfg(bead_info.grade)
		
		if nil ~= grade_info_list then
			repeat_times = grade_info_list.pack_num
		end
	end
	self:SendBeadReq(UGS_REQ.REQ_TYPE_UP_GRADE,repeat_times,auto_buy)
end

-- 进阶结果返回
function BeadCtrl:OnUpgradeOptResult(result)
	DressUpCtrl.Instance:BeadUpgradeResult(result)
end

--发送使用形象请求
function BeadCtrl:SendUseBeadImage(image_id, is_temp_image)
	self:SendBeadReq(UGS_REQ.REQ_TYPE_USE_IMG,image_id,is_temp_image)
end

--发送取消使用形象请求
function BeadCtrl:SendUnuseBeadImage(image_id, is_temp_image)
	self:SendBeadReq(UGS_REQ.REQ_TYPE_UP_UNUSE_IMG,image_id,is_temp_image)
end

-- 发送技能升级请求
function BeadCtrl:BeadSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSBeadSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function BeadCtrl:SendGetBeadInfo()
	self:SendBeadReq(UGS_REQ.REQ_TYPE_ALL_INFO)
end

function BeadCtrl:SendBeadUpLevelReq(equip_index)
	self:SendBeadReq(UGS_REQ.REQ_TYPE_UP_GRADE_EQUIP,equip_index)
end

function BeadCtrl:SendBeadReUseReq()
	self:SendBeadReq(UGS_REQ.REQ_TYPE_UP_REUSE_IMG)
end

function BeadCtrl:SendBeadReq(req_type,param1,param2,param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUgsBeadReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end
require("game/dress_up/kirin_arm/kirin_arm_data")

KirinArmCtrl = KirinArmCtrl or BaseClass(BaseController)

function KirinArmCtrl:__init()
	if KirinArmCtrl.Instance then
		print_error("[KirinArmCtrl] Attemp to create a singleton twice !")
		return
	end
	KirinArmCtrl.Instance = self

	self:RegisterAllProtocols()
	self.kirin_arm_data = KirinArmData.New()
end

function KirinArmCtrl:__delete()
	if self.kirin_arm_data ~= nil then
		self.kirin_arm_data:DeleteMe()
		self.kirin_arm_data = nil
	end

	KirinArmCtrl.Instance = nil
end

function KirinArmCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCKirinArmInfo, "OnKirinArmInfo");
end

function KirinArmCtrl:OnKirinArmInfo(protocol)
	if self.kirin_arm_data.kirin_arm_info and next(self.kirin_arm_data.kirin_arm_info) then
		if self.kirin_arm_data.kirin_arm_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		end
	end
	self.kirin_arm_data:SetKirinArmInfo(protocol)
	DressUpCtrl.Instance:FlushView("kirin_arm")
	KirinArmHuanHuaCtrl.Instance:FlushView("kirin_armhuanhua")
	--PlayerCtrl.Instance:FlushPlayerView("cur_fashion")
	if protocol.temp_img_id_has_select == 0 and protocol.temp_img_id == 0 and protocol.temp_img_time ~= 0 then
		MainUICtrl.Instance:FlushView()
	end

	RemindManager.Instance:Fire(RemindName.DressUpKirinArm)

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function KirinArmCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local repeat_times = 1
	if 1 == auto_buy and is_one_key then
		local kirin_arm_info = self.kirin_arm_data:GetKirinArmInfo()
		local grade_info_list = self.kirin_arm_data:GetKirinArmGradeCfg(kirin_arm_info.grade)
		
		if nil ~= grade_info_list then
			repeat_times = grade_info_list.pack_num
		end
	end
	self:SendKirinArmReq(UGS_REQ.REQ_TYPE_UP_GRADE,repeat_times,auto_buy)
end

-- 进阶结果返回
function KirinArmCtrl:OnUpgradeOptResult(result)
	DressUpCtrl.Instance:KirinArmUpgradeResult(result)
end

--发送使用形象请求
function KirinArmCtrl:SendUseKirinArmImage(image_id, is_temp_image)
	self:SendKirinArmReq(UGS_REQ.REQ_TYPE_USE_IMG,image_id,is_temp_image)
end

--发送取消使用形象请求
function KirinArmCtrl:SendUnuseKirinArmImage(image_id, is_temp_image)
	self:SendKirinArmReq(UGS_REQ.REQ_TYPE_UP_UNUSE_IMG,image_id,is_temp_image)
end

-- 发送技能升级请求
function KirinArmCtrl:KirinArmSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSKirinArmSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function KirinArmCtrl:SendGetKirinArmInfo()
	self:SendKirinArmReq(UGS_REQ.REQ_TYPE_ALL_INFO)
end

function KirinArmCtrl:SendKirinArmUpLevelReq(equip_index)
	self:SendKirinArmReq(UGS_REQ.REQ_TYPE_UP_GRADE_EQUIP,equip_index)
end

function KirinArmCtrl:SendKirinArmReUseReq()
	self:SendKirinArmReq(UGS_REQ.REQ_TYPE_UP_REUSE_IMG)
end

function KirinArmCtrl:SendKirinArmReq(req_type,param1,param2,param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUgsKirinArmReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end
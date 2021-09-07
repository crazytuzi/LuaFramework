require("game/dress_up/headwear/headwear_data")

HeadwearCtrl = HeadwearCtrl or BaseClass(BaseController)

function HeadwearCtrl:__init()
	if HeadwearCtrl.Instance then
		print_error("[HeadwearCtrl] Attemp to create a singleton twice !")
		return
	end
	HeadwearCtrl.Instance = self

	self:RegisterAllProtocols()
	self.headwear_data = HeadwearData.New()
end

function HeadwearCtrl:__delete()
	if self.headwear_data ~= nil then
		self.headwear_data:DeleteMe()
		self.headwear_data = nil
	end

	HeadwearCtrl.Instance = nil
end

function HeadwearCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHeadwearInfo, "OnHeadwearInfo");
end

function HeadwearCtrl:OnHeadwearInfo(protocol)
	if self.headwear_data.headwear_info and next(self.headwear_data.headwear_info) then
		if self.headwear_data.headwear_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		end
	end
	self.headwear_data:SetHeadwearInfo(protocol)
	DressUpCtrl.Instance:FlushView("headwear")
	HeadwearHuanHuaCtrl.Instance:FlushView("headwearhuanhua")
	--PlayerCtrl.Instance:FlushPlayerView("cur_fashion")
	if protocol.temp_img_id_has_select == 0 and protocol.temp_img_id == 0 and protocol.temp_img_time ~= 0 then
		MainUICtrl.Instance:FlushView()
	end

	RemindManager.Instance:Fire(RemindName.DressUpHeadwear)

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function HeadwearCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local repeat_times = 1
	if 1 == auto_buy and is_one_key then
		local headwear_info = self.headwear_data:GetHeadwearInfo()
		local grade_info_list = self.headwear_data:GetHeadwearGradeCfg(headwear_info.grade)
		
		if nil ~= grade_info_list then
			repeat_times = grade_info_list.pack_num
		end
	end
	self:SendHeadwearReq(UGS_REQ.REQ_TYPE_UP_GRADE,repeat_times,auto_buy)
end

-- 进阶结果返回
function HeadwearCtrl:OnUpgradeOptResult(result)
	DressUpCtrl.Instance:HeadwearUpgradeResult(result)
end

--发送使用形象请求
function HeadwearCtrl:SendUseHeadwearImage(image_id, is_temp_image)
	self:SendHeadwearReq(UGS_REQ.REQ_TYPE_USE_IMG,image_id,is_temp_image)
end

--发送取消使用形象请求
function HeadwearCtrl:SendUnuseHeadwearImage(image_id)
	self:SendHeadwearReq(UGS_REQ.REQ_TYPE_UP_UNUSE_IMG,image_id,is_temp_image)
end

-- 发送技能升级请求
function HeadwearCtrl:HeadwearSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHeadwearSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function HeadwearCtrl:SendGetHeadwearInfo()
	self:SendHeadwearReq(UGS_REQ.REQ_TYPE_ALL_INFO)
end

function HeadwearCtrl:SendHeadwearUpLevelReq(equip_index)
	self:SendHeadwearReq(UGS_REQ.REQ_TYPE_UP_GRADE_EQUIP,equip_index)
end

function HeadwearCtrl:SendHeadwearReUseReq()
	self:SendHeadwearReq(UGS_REQ.REQ_TYPE_UP_REUSE_IMG)
end

function HeadwearCtrl:SendHeadwearReq(req_type,param1,param2,param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUgsHeadwearReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end
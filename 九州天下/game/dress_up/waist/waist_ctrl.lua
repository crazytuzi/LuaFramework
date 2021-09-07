require("game/dress_up/waist/waist_data")

WaistCtrl = WaistCtrl or BaseClass(BaseController)

function WaistCtrl:__init()
	if WaistCtrl.Instance then
		print_error("[WaistCtrl] Attemp to create a singleton twice !")
		return
	end
	WaistCtrl.Instance = self

	self:RegisterAllProtocols()
	self.waist_data = WaistData.New()
end

function WaistCtrl:__delete()
	if self.waist_data ~= nil then
		self.waist_data:DeleteMe()
		self.waist_data = nil
	end

	WaistCtrl.Instance = nil
end

function WaistCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCWaistInfo, "OnWaistInfo");
end

function WaistCtrl:OnWaistInfo(protocol)
	if self.waist_data.waist_info and next(self.waist_data.waist_info) then
		if self.waist_data.waist_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		end
	end
	self.waist_data:SetWaistInfo(protocol)
	DressUpCtrl.Instance:FlushView("waist")
	WaistHuanHuaCtrl.Instance:FlushView("waisthuanhua")
	--PlayerCtrl.Instance:FlushPlayerView("cur_fashion")
	if protocol.temp_img_id_has_select == 0 and protocol.temp_img_id == 0 and protocol.temp_img_time ~= 0 then
		MainUICtrl.Instance:FlushView()
	end

	RemindManager.Instance:Fire(RemindName.DressUpWaist)

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function WaistCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local repeat_times = 1
	if 1 == auto_buy and is_one_key then
		local waist_info = self.waist_data:GetWaistInfo()
		local grade_info_list = self.waist_data:GetWaistGradeCfg(waist_info.grade)
		
		if nil ~= grade_info_list then
			repeat_times = grade_info_list.pack_num
		end
	end
	self:SendWaistReq(UGS_REQ.REQ_TYPE_UP_GRADE,repeat_times,auto_buy)
end

-- 进阶结果返回
function WaistCtrl:OnUpgradeOptResult(result)
	DressUpCtrl.Instance:WaistUpgradeResult(result)
end

--发送使用形象请求
function WaistCtrl:SendUseWaistImage(image_id, is_temp_image)
	self:SendWaistReq(UGS_REQ.REQ_TYPE_USE_IMG,image_id,is_temp_image)
end

--发送取消使用形象请求
function WaistCtrl:SendUnuseWaistImage(image_id, is_temp_image)
	self:SendWaistReq(UGS_REQ.REQ_TYPE_UP_UNUSE_IMG,image_id,is_temp_image)
end

-- 发送技能升级请求
function WaistCtrl:WaistSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWaistSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function WaistCtrl:SendGetWaistInfo()
	self:SendWaistReq(UGS_REQ.REQ_TYPE_ALL_INFO)
end

function WaistCtrl:SendWaistUpLevelReq(equip_index)
	self:SendWaistReq(UGS_REQ.REQ_TYPE_UP_GRADE_EQUIP,equip_index)
end

function WaistCtrl:SendWaistReUseReq()
	self:SendWaistReq(UGS_REQ.REQ_TYPE_UP_REUSE_IMG)
end

function WaistCtrl:SendWaistReq(req_type,param1,param2,param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUgsWaistReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end
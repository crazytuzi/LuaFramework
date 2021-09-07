require("game/dress_up/fabao/fabao_data")

FaBaoCtrl = FaBaoCtrl or BaseClass(BaseController)

function FaBaoCtrl:__init()
	if FaBaoCtrl.Instance then
		print_error("[FaBaoCtrl] Attemp to create a singleton twice !")
		return
	end
	FaBaoCtrl.Instance = self

	self:RegisterAllProtocols()
	self.fabao_data = FaBaoData.New()
end

function FaBaoCtrl:__delete()
	if self.fabao_data ~= nil then
		self.fabao_data:DeleteMe()
		self.fabao_data = nil
	end

	FaBaoCtrl.Instance = nil
end

function FaBaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFaBaoInfo, "OnFaBaoInfo");
end

function FaBaoCtrl:OnFaBaoInfo(protocol)
	if self.fabao_data.fabao_info and next(self.fabao_data.fabao_info) then
		if self.fabao_data.fabao_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		end
	end
	self.fabao_data:SetFaBaoInfo(protocol)
	DressUpCtrl.Instance:FlushView("fabao")
	FaBaoHuanHuaCtrl.Instance:FlushView("fabaohuanhua")
	--PlayerCtrl.Instance:FlushPlayerView("cur_fashion")
	if protocol.temp_img_id_has_select == 0 and protocol.temp_img_id == 0 and protocol.temp_img_time ~= 0 then
		MainUICtrl.Instance:FlushView()
	end

	RemindManager.Instance:Fire(RemindName.DressUpFaBao)

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function FaBaoCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local repeat_times = 1
	if 1 == auto_buy and is_one_key then
		local fabao_info = self.fabao_data:GetFaBaoInfo()
		local grade_info_list = self.fabao_data:GetFaBaoGradeCfg(fabao_info.grade)
		
		if nil ~= grade_info_list then
			repeat_times = grade_info_list.pack_num
		end
	end
	self:SendFaBaoReq(UGS_REQ.REQ_TYPE_UP_GRADE,repeat_times,auto_buy)
end

-- 进阶结果返回
function FaBaoCtrl:OnUpgradeOptResult(result)
	DressUpCtrl.Instance:FaBaoUpgradeResult(result)
end

--发送使用形象请求
function FaBaoCtrl:SendUseFaBaoImage(image_id, is_temp_image)
	self:SendFaBaoReq(UGS_REQ.REQ_TYPE_USE_IMG,image_id,is_temp_image)
end

--发送取消使用形象请求
function FaBaoCtrl:SendUnuseFaBaoImage(image_id, is_temp_image)
	self:SendFaBaoReq(UGS_REQ.REQ_TYPE_UP_UNUSE_IMG,image_id,is_temp_image)
end

-- 发送技能升级请求
function FaBaoCtrl:FaBaoSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFaBaoSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function FaBaoCtrl:SendGetFaBaoInfo()
	self:SendFaBaoReq(UGS_REQ.REQ_TYPE_ALL_INFO)
end

function FaBaoCtrl:SendFaBaoUpLevelReq(equip_index)
	self:SendFaBaoReq(UGS_REQ.REQ_TYPE_UP_GRADE_EQUIP,equip_index)
end

function FaBaoCtrl:SendFaBaoReUseReq()
	self:SendFaBaoReq(UGS_REQ.REQ_TYPE_UP_REUSE_IMG)
end

function FaBaoCtrl:SendFaBaoReq(req_type,param1,param2,param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUgsFaBaoReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end
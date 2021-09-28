require("game/advance/foot/foot_data")

FootCtrl = FootCtrl or BaseClass(BaseController)

function FootCtrl:__init()
	if FootCtrl.Instance then
		return
	end
	FootCtrl.Instance = self

	self:RegisterAllProtocols()
	self.foot_data = FootData.New()
end

function FootCtrl:__delete()
	if self.foot_data ~= nil then
		self.foot_data:DeleteMe()
		self.foot_data = nil
	end

	FootCtrl.Instance = nil
end

function FootCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFootPrintInfo, "OnFootprintInfo")
	self:RegisterProtocol(CSFootprintOperate)
end

function FootCtrl:OnFootprintInfo(protocol)
	if self.foot_data.foot_info and next(self.foot_data.foot_info) then
		if self.foot_data.foot_info.grade < protocol.grade then
			-- -- 请求开服活动信息
			-- if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING) then
			-- 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			-- end
			-- CompetitionActivityCtrl.Instance:SendGetBipinInfo()
			--因为阶数变化下发再物品变化下发之前所以延时一秒
			GlobalTimerQuest:AddDelayTimer(function ()
            TipsCtrl.Instance:OpenZhiShengDanTips(TabIndex.foot_jinjie, protocol.grade)
       		end, 1)
		end
	end
	self.foot_data:SetFootInfo(protocol)

	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.foot_jinjie)
	local is_act_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK)
	if protocol.star_level >= GameEnum.BIPIN_LEVEL_COND and is_act_open and not is_get_reward then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK,
			RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	AdvanceCtrl.Instance:FlushView("foot")
	JinJieRewardCtrl.Instance:FlushJinJieAwardView()
	FootHuanHuaCtrl.Instance:FlushView("foothuanhua")
	-- TempMountCtrl.Instance:FlushFootView()
	-- if protocol.temp_img_id_has_select == 0 and protocol.temp_img_id == 0 and protocol.temp_img_time ~= 0 then
	-- 	MainUICtrl.Instance:FlushView()
	-- end

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

function FootCtrl.SendFootOperate(operate_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFootprintOperate)
	send_protocol.operate_type = operate_type
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

----------- 下面要删除的

function FootCtrl:SendUseFootImage(image_id, is_temp_image)
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_USE_IMAGE, image_id, is_temp_image)
end


-- 发送进阶请求
function FootCtrl:SendUpGradeReq(auto_buy, is_one_key, has_repeat_times)
	local is_auto_buy = auto_buy
	local repeat_times = 1
	if is_one_key then
		local foot_info = self.foot_data:GetFootInfo()
		local grade_info_list = self.foot_data:GetFootGradeCfg(foot_info.grade)
		if nil ~= grade_info_list then
			if auto_buy == 1 then
				repeat_times = grade_info_list.pack_num
			else
				repeat_times = math.min(has_repeat_times, grade_info_list.pack_num)
			end
		end
	end
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_UP_GRADE, repeat_times, is_auto_buy)
end

-- 发送技能升级请求
function FootCtrl:FootSkillUplevelReq(skill_idx, auto_buy)
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_UP_LEVEL_SKILL, skill_idx, auto_buy)
end

function FootCtrl:SendGetFootInfo()
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_INFO_REQ)
end

-- 请求升星
function FootCtrl:SendFootUpStarLevel(is_auto_buy, stuff_index, loop_times)
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_UP_STAR, stuff_index, is_auto_buy, loop_times or 1)
end

function FootCtrl:SendFootUpLevelReq(equip_index)
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_UP_LEVEL_EQUIP, equip_index)
end
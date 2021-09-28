require("game/advance/wing/wing_data")

WingCtrl = WingCtrl or BaseClass(BaseController)

function WingCtrl:__init()
	if WingCtrl.Instance then
		return
	end
	WingCtrl.Instance = self

	self:RegisterAllProtocols()
	self.wing_data = WingData.New()
end

function WingCtrl:__delete()
	if self.wing_data ~= nil then
		self.wing_data:DeleteMe()
		self.wing_data = nil
	end

	WingCtrl.Instance = nil
end

function WingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCWingInfo, "WingInfo");
	self:RegisterProtocol(CSWingSkillUplevelReq)
	self:RegisterProtocol(CSUpgradeWing)
	self:RegisterProtocol(CSUseWingImage)			--请求使用形象
	self:RegisterProtocol(CSWingGetInfo)
end

function WingCtrl:WingInfo(protocol)
	if self.wing_data.wing_info and next(self.wing_data.wing_info) then
		if self.wing_data.wing_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
			--因为阶数变化下发再物品变化下发之前所以延时一秒
			GlobalTimerQuest:AddDelayTimer(function ()
            TipsCtrl.Instance:OpenZhiShengDanTips(TabIndex.wing_jinjie, protocol.grade)
       		end, 1)
		end
	end
	self.wing_data:SetWingInfo(protocol)
	AdvanceCtrl.Instance:FlushView("wing")
	WingHuanHuaCtrl.Instance:FlushView("winghuanhua")
	JinJieRewardCtrl.Instance:FlushJinJieAwardView()
	TempMountCtrl.Instance:FlushWingView()
	if protocol.temp_img_id_has_select == 0 and protocol.temp_img_id == 0 and protocol.temp_img_time ~= 0 then
		MainUICtrl.Instance:FlushView()
	end

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function WingCtrl:SendUpGradeReq(auto_buy, is_one_key, has_repeat_times)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeWing)
	send_protocol.is_auto_buy = auto_buy
	if is_one_key then
		local wing_info = self.wing_data:GetWingInfo()
		local grade_info_list = self.wing_data:GetWingGradeCfg(wing_info.grade)
		if nil ~= grade_info_list then
			if auto_buy == 1 then
				send_protocol.repeat_times = grade_info_list.pack_num
			else
				send_protocol.repeat_times = math.min(has_repeat_times, grade_info_list.pack_num)
			end
		else
			send_protocol.repeat_times = 1
		end
	else
		send_protocol.repeat_times = 1
	end
	send_protocol:EncodeAndSend()
end

--发送使用形象请求
function WingCtrl:SendUseWingImage(image_id, is_temp_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseWingImage)
	send_protocol.image_id = image_id
	send_protocol.is_temp_image = is_temp_image or 0
	send_protocol:EncodeAndSend()
end

-- 发送技能升级请求
function WingCtrl:WingSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWingSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function WingCtrl:SendGetWingInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWingGetInfo)
	send_protocol:EncodeAndSend()
end

-- 请求升星
function WingCtrl:SendWingUpStarLevel(is_auto_buy, stuff_index, loop_times)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWingUpStarLevel)
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol.stuff_index = stuff_index or 0
	send_protocol.loop_times = loop_times or 1
	send_protocol:EncodeAndSend()
end

function WingCtrl:SendWingUpLevelReq(equip_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWingUplevelEquip)
	send_protocol.equip_index = equip_index or 0
	send_protocol:EncodeAndSend()
end
require("game/advance/halo/halo_data")

HaloCtrl = HaloCtrl or BaseClass(BaseController)

function HaloCtrl:__init()
	if HaloCtrl.Instance then
		return
	end
	HaloCtrl.Instance = self

	self:RegisterAllProtocols()
	self.halo_data = HaloData.New()
end

function HaloCtrl:__delete()
	if self.halo_data ~= nil then
		self.halo_data:DeleteMe()
		self.halo_data = nil
	end

	HaloCtrl.Instance = nil
end

function HaloCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHaloInfo, "HaloInfo")
	self:RegisterProtocol(CSHaloSkillUplevelReq)
	self:RegisterProtocol(CSUpgradeHalo)
	self:RegisterProtocol(CSUseHaloImage)			--请求使用形象
	self:RegisterProtocol(CSHaloGetInfo)
end

function HaloCtrl:HaloInfo(protocol)
	if self.halo_data.halo_info and next(self.halo_data.halo_info) then
		if self.halo_data.halo_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
			--因为阶数变化下发再物品变化下发之前所以延时一秒
			GlobalTimerQuest:AddDelayTimer(function ()
            TipsCtrl.Instance:OpenZhiShengDanTips(TabIndex.halo_jinjie, protocol.grade)
       		end, 1)
		end
	end
	self.halo_data:SetHaloInfo(protocol)
	AdvanceCtrl.Instance:FlushView("halo")
	HaloHuanHuaCtrl.Instance:FlushView("halohuanhua")
	JinJieRewardCtrl.Instance:FlushJinJieAwardView()
	local show_halo_grade_cfg = GoddessData.Instance:GetShowHaloGradeList()
	if next(show_halo_grade_cfg) and protocol.grade <= show_halo_grade_cfg[3] then
		RemindManager.Instance:Fire(RemindName.Goddess_Camp)
	end

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function HaloCtrl:SendUpGradeReq(auto_buy, is_one_key, has_repeat_times)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeHalo)
	send_protocol.auto_buy = auto_buy
	if is_one_key then
		local halo_info = self.halo_data:GetHaloInfo()
		local grade_info_list = self.halo_data:GetHaloGradeCfg(halo_info.grade)
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
function HaloCtrl:SendUseHaloImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseHaloImage)
	send_protocol.image_id = image_id
	send_protocol:EncodeAndSend()
end

-- 发送技能升级请求
function HaloCtrl:HaloSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHaloSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function HaloCtrl:SendGetHaloInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHaloGetInfo)
	send_protocol:EncodeAndSend()
end

-- 发送升星请求
function HaloCtrl:HaloUpStarlevelReq(is_auto_buy, stuff_index, loop_times)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHaloUpStarLevel)
	send_protocol.stuff_index = stuff_index or 0
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol.loop_times = loop_times or 1
	send_protocol:EncodeAndSend()
end

function HaloCtrl:SendHaloUpLevelReq(equip_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHaloUplevelEquip)
	send_protocol.equip_index = equip_index or 0
	send_protocol:EncodeAndSend()
end
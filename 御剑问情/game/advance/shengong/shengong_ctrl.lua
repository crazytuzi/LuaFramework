require("game/advance/shengong/shengong_data")

ShengongCtrl = ShengongCtrl or BaseClass(BaseController)

function ShengongCtrl:__init()
	if ShengongCtrl.Instance then
		return
	end
	ShengongCtrl.Instance = self

	self:RegisterAllProtocols()
	self.shengong_data = ShengongData.New()
end

function ShengongCtrl:__delete()
	if self.shengong_data ~= nil then
		self.shengong_data:DeleteMe()
		self.shengong_data = nil
	end

	ShengongCtrl.Instance = nil
end

function ShengongCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShengongInfo, "ShengongInfo");
	self:RegisterProtocol(CSShengongSkillUplevelReq)
	self:RegisterProtocol(CSUpgradeShengong)
	self:RegisterProtocol(CSUseShengongImage)			--请求使用形象
	self:RegisterProtocol(CSShengongGetInfo)
end

function ShengongCtrl:ShengongInfo(protocol)
	-- AdvanceShengongView:SetModle(is_show)
	local grade_change_flag = false
	if self.shengong_data.shengong_info and next(self.shengong_data.shengong_info) then
		if self.shengong_data.shengong_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
			grade_change_flag = true
			--因为阶数变化下发再物品变化下发之前所以延时一秒
			GlobalTimerQuest:AddDelayTimer(function ()
            TipsCtrl.Instance:OpenZhiShengDanTips(TabIndex.goddess_shengong, protocol.grade)
       		end, 1)
		end
	end

	if self.shengong_data.shengong_info and self.shengong_data.shengong_info.star_level and self.shengong_data.shengong_info.star_level < protocol.star_level then
		GoddessCtrl.Instance:PlayUpStarEffect()
	end

	local flush_flag = self.shengong_data.shengong_info.used_imageid ~= protocol.used_imageid
	self.shengong_data:SetShengongInfo(protocol)
	if flush_flag then
		GoddessCtrl.Instance:FlushShengongModel()
	end

	AdvanceCtrl.Instance:FlushView("shengong")
	ShengongHuanHuaCtrl.Instance:FlushView("shengonghuanhua")
	GoddessCtrl.Instance:FlushView("shengong")
	JinJieRewardCtrl.Instance:FlushJinJieAwardView()
	if grade_change_flag == true then
		GoddessCtrl.Instance:GetView():Flush("sg")
	end
	local main_role = Scene.Instance:GetMainRole()
	if not main_role then return end
	local main_role_appearance_vo = GameVoManager.Instance:GetMainRoleVo().appearance
	if nil == main_role_appearance_vo then
		main_role_appearance_vo = {}
	end
	main_role_appearance_vo.shengong_used_imageid = protocol.used_imageid
	main_role:SetAttr("appearance", main_role_appearance_vo)
	RemindManager.Instance:Fire(RemindName.Goddess_Shengong)

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function ShengongCtrl:SendUpGradeReq(auto_buy, is_one_key, has_repeat_times)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeShengong)
	send_protocol.auto_buy = auto_buy
	if is_one_key then
		local shengong_info = self.shengong_data:GetShengongInfo()
		local grade_info_list = self.shengong_data:GetShengongGradeCfg(shengong_info.grade)
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

-- 进阶结果返回
function ShengongCtrl:OnUppGradeOptResult(result)
	GoddessCtrl.Instance:ShengongUpGradeResult(result)
end

--发送使用形象请求
function ShengongCtrl:SendUseShengongImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseShengongImage)
	send_protocol.image_id = image_id
	send_protocol:EncodeAndSend()
end

-- 发送技能升级请求
function ShengongCtrl:ShengongSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShengongSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function ShengongCtrl:SendGetShengongInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShengongGetInfo)
	send_protocol:EncodeAndSend()
end

-- 神弓升星请求
function ShengongCtrl:SendShengongUpStarReq(stuff_index, is_auto_buy, loop_times)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShengongUpStarLevel)
	send_protocol.stuff_index = stuff_index or 0
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol.loop_times = loop_times or 1
	send_protocol:EncodeAndSend()
end

--取消神弓形象
function ShengongCtrl.SendUnUseShengongImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUnUseShengongImage)
	send_protocol.image_id = image_id or 0
	send_protocol.reserve_sh = 0
	send_protocol:EncodeAndSend()
end

function ShengongCtrl:SendShengongUpLevelReq(equip_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShengongUplevelEquip)
	send_protocol.equip_index = equip_index or 0
	send_protocol:EncodeAndSend()
end
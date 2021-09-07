require("game/advance/shenyi/shenyi_data")

ShenyiCtrl = ShenyiCtrl or BaseClass(BaseController)

function ShenyiCtrl:__init()
	if ShenyiCtrl.Instance then
		print_error("[ShenyiCtrl] Attemp to create a singleton twice !")
		return
	end
	ShenyiCtrl.Instance = self

	self:RegisterAllProtocols()
	self.shenyi_data = ShenyiData.New()
end

function ShenyiCtrl:__delete()
	if self.shenyi_data ~= nil then
		self.shenyi_data:DeleteMe()
		self.shenyi_data = nil
	end

	ShenyiCtrl.Instance = nil
end

function ShenyiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShenyiInfo, "ShenyiInfo");
	self:RegisterProtocol(CSShenyiSkillUplevelReq)
	self:RegisterProtocol(CSUpgradeShenyi)
	self:RegisterProtocol(CSUseShenyiImage)			--请求使用形象
	self:RegisterProtocol(CSShenyiGetInfo)
	self:RegisterProtocol(CSShenyiUplevelEquip)
end

function ShenyiCtrl:ShenyiInfo(protocol)
	if self.shenyi_data.shenyi_info and next(self.shenyi_data.shenyi_info) then
		if self.shenyi_data.shenyi_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		end
	end

	-- if self.shenyi_data.shenyi_info and self.shenyi_data.shenyi_info.star_level ~= nil and self.shenyi_data.shenyi_info.star_level < protocol.star_level then
	-- 	GoddessCtrl.Instance:GetView():PlayUpStarEffect()
	-- end

	local flush_flag = self.shenyi_data.shenyi_info.used_imageid ~= protocol.used_imageid
	self.shenyi_data:SetShenyiInfo(protocol)
	-- if flush_flag then
	-- 	GoddessCtrl.Instance:FlushShenyiModel()
	-- end
	AdvanceCtrl.Instance:FlushView("mantle")
	ShenyiHuanHuaCtrl.Instance:FlushView("shenyihuanhua")
	-- ShenyiHuanHuaCtrl.Instance:FlushView("shenyihuanhua")
	-- GoddessCtrl.Instance:FlushView("shenyi")
	local main_role = Scene.Instance:GetMainRole()
	if not main_role then return end
	local main_role_appearance_vo = GameVoManager.Instance:GetMainRoleVo().appearance
	main_role_appearance_vo.shenyi_used_imageid = protocol.used_imageid
	main_role:SetAttr("appearance", main_role_appearance_vo)
	--RemindManager.Instance:Fire(RemindName.Goddess_Shenyi)
	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

-- 发送进阶请求
function ShenyiCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeShenyi)
	send_protocol.auto_buy = auto_buy
	if 1 == send_protocol.auto_buy and is_one_key then
		local shenyi_info = self.shenyi_data:GetShenyiInfo()
		local grade_info_list = self.shenyi_data:GetShenyiGradeCfg(shenyi_info.grade)
		if nil ~= grade_info_list then
			send_protocol.repeat_times = grade_info_list.pack_num
		else
			send_protocol.repeat_times = 1
		end
	else
		send_protocol.repeat_times = 1
	end
	send_protocol:EncodeAndSend()
end

-- 进阶结果返回
function ShenyiCtrl:OnUppGradeOptResult(result)
	AdvanceCtrl.Instance:OnShengongUpGradeResult(result)
end

--发送使用形象请求
function ShenyiCtrl:SendUseShenyiImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseShenyiImage)
	send_protocol.image_id = image_id
	send_protocol:EncodeAndSend()
end

-- 发送技能升级请求
function ShenyiCtrl:ShenyiSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenyiSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function ShenyiCtrl:SendGetShenyiInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenyiGetInfo)
	send_protocol:EncodeAndSend()
end

-- 神弓升星请求
function ShenyiCtrl:SendShenyiUpStarReq(stuff_index, is_auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenyiUpStarLevel)
	send_protocol.stuff_index = stuff_index or 0
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol:EncodeAndSend()
end

--取消神翼形象
function ShenyiCtrl.SendUnUseShenyiImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUnUseShenyiImage)
	send_protocol.image_id = image_id or 0
	send_protocol.reserve_sh = 0
	send_protocol:EncodeAndSend()
end


function ShenyiCtrl:SendShenyiUpLevelReq(equip_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenyiUplevelEquip)
	send_protocol.equip_index = equip_index or 0
	send_protocol:EncodeAndSend()
end
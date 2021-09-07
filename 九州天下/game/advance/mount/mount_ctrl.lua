require("game/advance/mount/mount_data")

MountCtrl = MountCtrl or BaseClass(BaseController)
local PLAYER_MOUNT_FLAG = nil
function MountCtrl:__init()
	if MountCtrl.Instance then
		print_error("[MountCtrl] Attemp to create a singleton twice !")
		return
	end
	MountCtrl.Instance = self

	self:RegisterAllProtocols()
	self.mount_data = MountData.New()
	self.mount_downed_in_cg = false
end

function MountCtrl:__delete()
	if self.mount_data ~= nil then
		self.mount_data:DeleteMe()
		self.mount_data = nil
	end

	MountCtrl.Instance = nil
end

function MountCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMountInfo, "MountInfo");
	self:RegisterProtocol(SCMountAppeChange, "MountAppeChange");
	self:RegisterProtocol(CSMountSkillUplevelReq)
	self:RegisterProtocol(CSUpgradeMount)
	self:RegisterProtocol(CSUseMountImage)			--请求使用形象
	self:RegisterProtocol(CSMountGetInfo)
end

function MountCtrl:MountInfo(protocol)
	if self.mount_data.mount_info and next(self.mount_data.mount_info) then
		if self.mount_data.mount_info.grade < protocol.grade then
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		end
	end
	self.mount_data:SetMountInfo(protocol)
	AdvanceCtrl.Instance:FlushView("mount")
	MountHuanHuaCtrl.Instance:FlushView("mounthuanhua")
	TempMountCtrl.Instance:FlushView()
	if protocol.temp_img_id_has_select == 0 and protocol.temp_img_id == 0 and protocol.temp_img_time ~= 0 then
		MainUICtrl.Instance:FlushView()
	end
	--PlayerCtrl.Instance:FlushPlayerView()

	RemindManager.Instance:Fire(RemindName.AdvanceMount)

	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

function MountCtrl:MountAppeChange(protocol)
	local role = Scene.Instance:GetObj(protocol.objid)
	if nil == role then
		return
	end

	role:SetAttr("mount_appeid", protocol.mount_appeid)

	if role:IsMainRole() then
		PLAYER_MOUNT_FLAG = protocol.mount_appeid > 0 and 1 or 0

		self:CheckMountUpOrDownInCg()
	end

	RemindManager.Instance:Fire(RemindName.AdvanceMount)
end

-- 发送进阶请求
function MountCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeMount)
	send_protocol.auto_buy = auto_buy
	if 1 == send_protocol.auto_buy and is_one_key then
		local mount_info = self.mount_data:GetMountInfo()
		local grade_info_list = self.mount_data:GetMountGradeCfg(mount_info.grade)
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
function MountCtrl:OnUppGradeOptResult(result)
	AdvanceCtrl.Instance:MountUpgradeResult(result)
end

--发送使用形象请求
function MountCtrl:SendUseMountImage(image_id, is_temp_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseMountImage)
	send_protocol.image_id = image_id
	send_protocol.is_temp_image = is_temp_image or 0
	send_protocol:EncodeAndSend()
end

-- 发送技能升级请求
function MountCtrl:MountSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMountSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function MountCtrl:SendGetMountInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMountGetInfo)
	send_protocol:EncodeAndSend()
end

function MountCtrl:CheckMountUpOrDownInCg()
	if PLAYER_MOUNT_FLAG == nil then
		PLAYER_MOUNT_FLAG = GameVoManager.Instance:GetMainRoleVo().mount_appeid > 0 and 1 or 0
	end

	if CgManager.Instance:IsCgIng() then
		if 1 == PLAYER_MOUNT_FLAG then
			self:SendGoonMountReq(0)
			self.mount_downed_in_cg = true
		end
	else
		if self.mount_downed_in_cg then
			self.mount_downed_in_cg = false
			self:SendGoonMountReq(1)
		end
	end
end

function MountCtrl:SendGoonMountReq(mount_flag)
	-- 放CG过程中不给上坐骑
	if mount_flag == 1 and CgManager.Instance:IsCgIng() then
		return
	end


	local use_multi_mount = MultiMountData.Instance:GetCurUseMountId() or -1
	if use_multi_mount > -1 then
		if mount_flag == 0 then
			MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_UNRIDE)
		else
			MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_RIDE)
		end
	else
		if PLAYER_MOUNT_FLAG == nil or mount_flag ~= PLAYER_MOUNT_FLAG then
			if PLAYER_MOUNT_FLAG == nil then
				PLAYER_MOUNT_FLAG = GameVoManager.Instance:GetMainRoleVo().mount_appeid > 0 and 1 or 0
			end

			-- 是否是变身形象
			if mount_flag and mount_flag == 1 then
				local bianshen_param = GameVoManager.Instance:GetMainRoleVo().bianshen_param
				if bianshen_param ~= "" and bianshen_param ~= 0 then
					return
				end

				local role = Scene.Instance:GetMainRole()
				if role ~= nil and role:IsWarSceneState() then
					return
				end
			end

			local send_protocol = ProtocolPool.Instance:GetProtocol(CSGoonMount)
			send_protocol.mount_flag = mount_flag or 0
			send_protocol:EncodeAndSend()
		end
	end
end

function MountCtrl:SendMountUpLevelReq(equip_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMountUplevelEquip)
	send_protocol.equip_index = equip_index or 0
	send_protocol:EncodeAndSend()
end
require("game/advance/fightmount/fight_mount_data")

FightMountCtrl = FightMountCtrl or BaseClass(BaseController)

function FightMountCtrl:__init()
	if FightMountCtrl.Instance then
		print_error("[FightMountCtrl] Attemp to create a singleton twice !")
		return
	end
	FightMountCtrl.Instance = self

	self:RegisterAllProtocols()
	self.data = FightMountData.New()
end

function FightMountCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	FightMountCtrl.Instance = nil
end

function FightMountCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFightMountInfo, "FightMountInfo");
	self:RegisterProtocol(SCFightMountAppeChange, "FightMountAppeChange");
	self:RegisterProtocol(CSFightMountSkillUplevelReq)
	self:RegisterProtocol(CSUpgradeFightMount)
	self:RegisterProtocol(CSUseFightMountImage)			--请求使用形象
	self:RegisterProtocol(CSFightMountGetInfo)
end

function FightMountCtrl:FightMountInfo(protocol)
	self.data:SetFightMountInfo(protocol)
	AdvanceCtrl.Instance:FlushView("fightmount")
	FightMountHuanHuaCtrl.Instance:FlushView("fightmounthuanhua")

	RemindManager.Instance:Fire(RemindName.AdvanceFightMount)
end

function FightMountCtrl:FightMountAppeChange(protocol)
	local role = Scene.Instance:GetObj(protocol.objid)
	if role then
		role:SetAttr("fight_mount_appeid", protocol.mount_appeid)
	end

	RemindManager.Instance:Fire(RemindName.AdvanceFightMount)
end

-- 发送进阶请求
function FightMountCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeFightMount)
	send_protocol.auto_buy = auto_buy
	if 1 == send_protocol.auto_buy and is_one_key then
		local mount_info = self.data:GetFightMountInfo()
		local grade_info_list = self.data:GetMountGradeCfg(mount_info.grade)
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
function FightMountCtrl:OnUppGradeOptResult(result)
	AdvanceCtrl.Instance:OnFightMountUpgradeResult(result)
end

--发送使用形象请求
function FightMountCtrl:SendUseFightMountImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseFightMountImage)
	send_protocol.image_id = image_id
	send_protocol:EncodeAndSend()
end

-- 发送技能升级请求
function FightMountCtrl:FightMountSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function FightMountCtrl:SendGetFightMountInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountGetInfo)
	send_protocol:EncodeAndSend()
end

function FightMountCtrl:SendGoonFightMountReq(mount_flag)
	if mount_flag == 0 then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.fight_mount_appeid <= 0 then
			return
		end
	end

	-- 是否是变身形象
	if mount_flag and mount_flag == 1 then
		local bianshen_param = GameVoManager.Instance:GetMainRoleVo().bianshen_param
		if bianshen_param ~= "" and bianshen_param ~= 0 then
			return
		end
		local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if scene_cfg.pb_fightmount and 1 == scene_cfg.pb_fightmount then
			return
		end
	end

	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGoonFightMount)
	send_protocol.goon_mount = mount_flag or 0
	send_protocol:EncodeAndSend()
end
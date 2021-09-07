require("game/advance/fazhen/fazhen_data")

FaZhenCtrl = FaZhenCtrl or BaseClass(BaseController)

function FaZhenCtrl:__init()
	if FaZhenCtrl.Instance then
		print_error("[FaZhenCtrl] Attemp to create a singleton twice !")
		return
	end
	FaZhenCtrl.Instance = self

	self:RegisterAllProtocols()
	self.data = FaZhenData.New()
end

function FaZhenCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	FaZhenCtrl.Instance = nil
end

function FaZhenCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFazhenInfo, "FazhenInfo")
	-- self:RegisterProtocol(SCFightMountAppeChange, "FightMountAppeChange")
	-- self:RegisterProtocol(CSFightMountSkillUplevelReq)
	-- self:RegisterProtocol(CSUpgradeFightMount)
	-- self:RegisterProtocol(CSUseFightMountImage)			--请求使用形象
	-- self:RegisterProtocol(CSFightMountGetInfo)

	self:RegisterProtocol(CSFazhenOpera)
end

function FaZhenCtrl:FazhenInfo(protocol)
	self.data:SetFazhenInfo(protocol)
	AdvanceCtrl.Instance:FlushView("fazhen")
	FaZhenHuanHuaCtrl.Instance:FlushView("fazhenhuanhua")
	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
end

function FaZhenCtrl:FightMountAppeChange(protocol)
	local role = Scene.Instance:GetObj(protocol.objid)
	if role then
		role:SetAttr("fight_mount_appeid", protocol.mount_appeid)
	end
end

-- 发送进阶请求
function FaZhenCtrl:SendUpGradeReq(auto_buy, is_one_key)
	local pack_num = 1
	if 1 == auto_buy and is_one_key then
		local mount_info = self.data:GetFightMountInfo()
		local grade_info_list = self.data:GetMountGradeCfg(mount_info.grade)
		if nil ~= grade_info_list then
			pack_num = grade_info_list.pack_num
		end
	end
	self:SendFaZhenOpera(FAZHEN_OPERA_REQ_TYPE.FAZHEN_OPERA_REQ_TYPE_UPGRADE, auto_buy, pack_num)
end

-- 进阶结果返回
function FaZhenCtrl:OnUppGradeOptResult(result)
	AdvanceCtrl.Instance:OnFightMountUpgradeResult(result)
end

--发送使用形象请求
function FaZhenCtrl:SendUseFaZhenImage(image_id)
	self:SendFaZhenOpera(FAZHEN_OPERA_REQ_TYPE.FAZHEN_OPERA_REQ_TYPE_USE_IMG, image_id)
end

-- 发送技能升级请求
function FaZhenCtrl:FightMountSkillUplevelReq(skill_idx, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountSkillUplevelReq)
	send_protocol.skill_idx = skill_idx
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function FaZhenCtrl:SendGetFightMountInfo()
	self:SendFaZhenOpera(FAZHEN_OPERA_REQ_TYPE.FAZHEN_OPERA_REQ_TYPE_INFO)
end

function FaZhenCtrl:SendFaZhenOpera(opera_type, param_1, param_2, param_3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFazhenOpera)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end


function FaZhenCtrl:SendFightMountUpLevelReq(equip_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountUplevelEquip)
	send_protocol.equip_index = equip_index or 0
	send_protocol:EncodeAndSend()
end
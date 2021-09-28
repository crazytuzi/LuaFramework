require("game/lianhun/lianhun_view")
require("game/lianhun/lianhun_data")
require("game/lianhun/lianhun_skill_tips")
require("game/lianhun/fu_ben_suoyaotower_data")
require("game/lianhun/fu_ben_suoyaotower_fight_view")
require("game/lianhun/lianhun_equip_tips")
LianhunCtrl = LianhunCtrl or  BaseClass(BaseController)


function LianhunCtrl:__init()
	if LianhunCtrl.Instance ~= nil then
		ErrorLog("[LianhunCtrl] attempt to create singleton twice!")
		return
	end

	LianhunCtrl.Instance = self

	self:RegisterAllProtocols()

	self.suoyaotower_data = SuoYaoTowerData.New()
	self.suoyao_fightview = SuoYaoTowerFightView.New(ViewName.SuoYaoTowerFightView)
	self.data = LianhunData.New()
	self.view = LianhunView.New(ViewName.LianhunView)
	self.lianhun_skill_tips = LianhunSkillTipsView.New()
	self.lianhun_equip_tips = LianhunEquipTips.New()
end

function LianhunCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.lianhun_skill_tips ~= nil then
		self.lianhun_skill_tips:DeleteMe()
		self.lianhun_skill_tips = nil
	end
	if self.lianhun_equip_tips ~= nil then
		self.lianhun_equip_tips:DeleteMe()
		self.lianhun_equip_tips = nil
	end

	if self.suoyaotower_data ~= nil then
		self.suoyaotower_data:DeleteMe()
		self.suoyaotower_data = nil
	end

	LianhunCtrl.Instance = nil
end

-- 协议注册
function LianhunCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCLianhunAllInfo, "OnLianhunAllInfo")
	--锁妖塔
	self:RegisterProtocol(SCSuoyaotaFbAllInfo, "OnSCSuoyaotaFbAllInfo")
	self:RegisterProtocol(SCSuoyaotaFbResultInfo, "OnSCSuoyaotaFbResultInfo")
	self:RegisterProtocol(SCSuoyaotaFbSingleInfo, "OnSCSuoyaotaFbSingleInfo")
	self:RegisterProtocol(SCSuoyaotaFbFetchResultInfo, "OnSCSuoyaotaFbFetchResultInfo")
	self:RegisterProtocol(SCSuoyaotaFbPowerInfo, "OnSCSuoyaotaFbPowerInfo")
	self:RegisterProtocol(SCSuoyaotaFbTitle, "OnSCSuoyaotaFbTitle")
end

function LianhunCtrl:FlushView()
	self.view:Flush()
end

--锁妖塔
function LianhunCtrl:SendSuoYaoTowerReq(opera_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSuoyaotaFbOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

function LianhunCtrl:OnSCSuoyaotaFbAllInfo(protocol)
	self.suoyaotower_data:SetFbTowerInfo(protocol)
	self.view:Flush({})
	RemindManager.Instance:Fire(RemindName.SuoYaoTower)
end

function LianhunCtrl:OnSCSuoyaotaFbResultInfo(protocol)
	self.suoyaotower_data:SetFbTowerResultInfo(protocol)
end

function LianhunCtrl:OnSCSuoyaotaFbSingleInfo(protocol)
	self.suoyaotower_data:SetFbTowerSingleInfo(protocol)

	LianhunCtrl.Instance:SendSuoYaoTowerReq(SUOYAOTA_FB_OPERA_REQ_TYPE.SUOYAOTA_FB_OPERA_REQ_TYPE_ALL_INFO)
	self.view:Flush({})
end

function LianhunCtrl:OnSCSuoyaotaFbFetchResultInfo(protocol)

end

function LianhunCtrl:OnSCSuoyaotaFbTitle(protocol)
	self.suoyaotower_data:SetTitle(protocol)
end

function LianhunCtrl:OnSCSuoyaotaFbPowerInfo(protocol)
	self.suoyaotower_data:SetPower(protocol)
	self.view:Flush({})
	RemindManager.Instance:Fire(RemindName.SuoYaoTower)
end

function LianhunCtrl:FlushVector(data)
	ViewManager.Instance:Open(ViewName.FuBenFinishStarNextView, nil, "finish", data)
end

function LianhunCtrl:OnResultInfo(protocol)
	self.suoyaotower_data:SetFBResultInfo(protocol)

	if 0 == protocol.is_pass and 1 == protocol.is_finish then

		local ok_fun = function()
			ViewManager.Instance:Open(ViewName.LianhunView, TabIndex.suoyao_tower)
		end

		FuBenCtrl.Instance:SetFailOkCallBack(ok_fun)
		ViewManager.Instance:Open(ViewName.FBFailFinishView)
	end
end

function LianhunCtrl:SendEquipmentLianhunUplevel(equip_index, is_auto_buy)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipmentLianhunUplevel)
	protocol.equip_index = equip_index
	protocol.is_auto_buy = is_auto_buy
	protocol:EncodeAndSend()
end

function LianhunCtrl:CloseView()
	self.view:Close()
end

-- 请求进入副本下一关
function LianhunCtrl:SendEnterNextFBReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFBReqNextLevel)
	send_protocol:EncodeAndSend()
end

--展示技能描述
function LianhunCtrl:ShowSkillTips(skill_name, skill_level, now_des, next_des, levelup_des, asset, bunble, eff_asset, eff_bunble)
	self.lianhun_skill_tips:SetSkillName(skill_name)
	self.lianhun_skill_tips:SetSkillLevel(skill_level)
	self.lianhun_skill_tips:SetNowDes(now_des)
	self.lianhun_skill_tips:SetNextDes(next_des)
	self.lianhun_skill_tips:SetLevelUpDes(levelup_des)
	self.lianhun_skill_tips:SetSkillRes(asset, bunble)
	self.lianhun_skill_tips:SetSkillEffRes(eff_asset, eff_bunble)
	self.lianhun_skill_tips:Open()
end


--展示技能描述
function LianhunCtrl:ShowEquipTips(data)
	self.lianhun_equip_tips:SetData(data)
end


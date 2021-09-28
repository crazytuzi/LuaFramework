KaiFuDegreeRewardsData = KaiFuDegreeRewardsData or BaseClass()

local BiPingList = {
		[TabIndex.mount_jinjie] = {activity_type = 2062},
		[TabIndex.wing_jinjie] = {activity_type = 2065},
		[TabIndex.halo_jinjie] = {activity_type = 2191},
		[TabIndex.foot_jinjie] = {activity_type = 2192},
		[TabIndex.fight_mount] = {activity_type = 2193},
		[TabIndex.goddess_shengong] = {activity_type = 2194},
		[TabIndex.goddess_shenyi] = {activity_type = 2195},

}

function KaiFuDegreeRewardsData:__init()
    if KaiFuDegreeRewardsData.Instance ~= nil then
		print_error("[KaiFuDegreeRewardsData] Attemp to create a singleton twice !")
		return
	end

	KaiFuDegreeRewardsData.Instance = self

	self.mount_can_reward = {}
    self.mount_fetch_reward = {}
    self.mount_rare_reward_fetch = {}

    self.wing_can_reward = {}
    self.wing_fetch_reward = {}
    self.wing_rare_reward_fetch = {}

    self.halo_can_reward = {}
    self.halo_fetch_reward = {}
    self.halo_rare_reward_fetch = {}

    self.foot_can_reward = {}
    self.foot_fetch_reward = {}
    self.foot_rare_reward_fetch = {}

    self.fightmount_can_reward = {}
    self.fightmount_fetch_reward = {}
    self.fightmount_rare_reward_fetch = {}

    self.shengong_can_reward = {}
    self.shengong_fetch_reward = {}
    self.shengong_rare_reward_fetch = {}

    self.shenyi_can_reward = {}
    self.shenyi_fetch_reward = {}
    self.shenyi_rare_reward_fetch = {}

    self.yaoshi_can_reward = {}
	self.yaoshi_fetch_reward = {}
	self.yaoshi_rare_reward_fetch = {}

	self.toushi_can_reward = {}
	self.toushi_fetch_reward = {}
	self.toushi_rare_reward_fetch = {}

	self.qilinbi_can_reward = {}
	self.qilinbi_fetch_reward = {}
	self.qilinbi_rare_reward_fetch = {}

	self.mask_can_reward = {}
	self.mask_fetch_reward = {}
	self.mask_rare_reward_fetch = {}

	self.xianbao_can_reward = {}
	self.xianbao_fetch_reward = {}
	self.xianbao_rare_reward_fetch = {}

	self.lingzhu_can_reward = {}
	self.lingzhu_fetch_reward = {}
	self.lingzhu_rare_reward_fetch = {}

	self.lingchong_can_reward = {}
	self.lingchong_fetch_reward = {}
	self.lingchong_rare_reward_fetch = {}

	self.linggong_can_reward = {}
	self.linggong_fetch_reward = {}
	self.linggong_rare_reward_fetch = {}

	self.lingqi_can_reward = {}
	self.lingqi_fetch_reward = {}
	self.lingqi_rare_reward_fetch = {}

	self.buy_grade = {}

    self.ac_type = 0
    self.ac_type1 = 0

    local buy_cfg = ConfigManager.Instance:GetAutoConfig("upgrade_card_buy_cfg_auto").buy_cfg
    self.buy_cfg_open_day_list = GetDataRange(buy_cfg, "open_game_day")
    self.buy_cfg = ListToMap(buy_cfg, "open_game_day", "related_activity_c", "grade")

    RemindManager.Instance:Register(RemindName.MountDegree, BindTool.Bind(self.GetMountDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.WingDegree, BindTool.Bind(self.GetWingDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.HaloDegree, BindTool.Bind(self.GetHaloDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.FootDegree, BindTool.Bind(self.GetFootDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.FightMountDegree, BindTool.Bind(self.GetFightMountDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.ShenGongDegree, BindTool.Bind(self.GetShenGongDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.ShenYiDegree, BindTool.Bind(self.GetShenYiDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.YaoShiDegree, BindTool.Bind(self.GetYaoShiDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.TouShiDegree, BindTool.Bind(self.GetTouShiDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.QiLinBiDegree, BindTool.Bind(self.GetQiLinBiDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.MaskDegree, BindTool.Bind(self.GetMaskDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.XianBaoDegree, BindTool.Bind(self.GetXianBaoDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.LingZhuDegree, BindTool.Bind(self.GetLingZhuDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.LingChongDegree, BindTool.Bind(self.GetLingChongDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.LingGongDegree, BindTool.Bind(self.GetLingGongDegreeRemind, self))
    RemindManager.Instance:Register(RemindName.LingQiDegree, BindTool.Bind(self.GetLingQiDegreeRemind, self))
end

function KaiFuDegreeRewardsData:__delete()
	RemindManager.Instance:UnRegister(RemindName.MountDegree)
	RemindManager.Instance:UnRegister(RemindName.WingDegree)
	RemindManager.Instance:UnRegister(RemindName.HaloDegree)
	RemindManager.Instance:UnRegister(RemindName.FootDegree)
	RemindManager.Instance:UnRegister(RemindName.FightMountDegree)
	RemindManager.Instance:UnRegister(RemindName.ShenGongDegree)
	RemindManager.Instance:UnRegister(RemindName.ShenYiDegree)
	RemindManager.Instance:UnRegister(RemindName.YaoShiDegree)
	RemindManager.Instance:UnRegister(RemindName.TouShiDegree)
	RemindManager.Instance:UnRegister(RemindName.QiLinBiDegree)
	RemindManager.Instance:UnRegister(RemindName.MaskDegree)
	RemindManager.Instance:UnRegister(RemindName.XianBaoDegree)
	RemindManager.Instance:UnRegister(RemindName.LingZhuDegree)
	RemindManager.Instance:UnRegister(RemindName.LingChongDegree)
	RemindManager.Instance:UnRegister(RemindName.LingGongDegree)
	RemindManager.Instance:UnRegister(RemindName.LingQiDegree)

	self.mount_can_reward = {}
    self.mount_fetch_reward = {}
    self.mount_rare_reward_fetch = {}

    self.wing_can_reward = {}
    self.wing_fetch_reward = {}
    self.wing_rare_reward_fetch = {}

    self.halo_can_reward = {}
    self.halo_fetch_reward = {}
    self.halo_rare_reward_fetch = {}

    self.foot_can_reward = {}
    self.foot_fetch_reward = {}
    self.foot_rare_reward_fetch = {}

    self.fightmount_can_reward = {}
    self.fightmount_fetch_reward = {}
    self.fightmount_rare_reward_fetch = {}

    self.shengong_can_reward = {}
    self.shengong_fetch_reward = {}
    self.shengong_rare_reward_fetch = {}

    self.shenyi_can_reward = {}
    self.shenyi_fetch_reward = {}
    self.shenyi_rare_reward_fetch = {}

    self.yaoshi_can_reward = {}
	self.yaoshi_fetch_reward = {}
	self.yaoshi_rare_reward_fetch = {}

	self.toushi_can_reward = {}
	self.toushi_fetch_reward = {}
	self.toushi_rare_reward_fetch = {}

	self.qilinbi_can_reward = {}
	self.qilinbi_fetch_reward = {}
	self.qilinbi_rare_reward_fetch = {}

	self.lingchong_can_reward = {}
	self.lingchong_fetch_reward = {}
	self.lingchong_rare_reward_fetch = {}

	self.linggong_can_reward = {}
	self.linggong_fetch_reward = {}
	self.linggong_rare_reward_fetch = {}

	self.lingqi_can_reward = {}
	self.lingqi_fetch_reward = {}
	self.lingqi_rare_reward_fetch = {}

    KaiFuDegreeRewardsData.Instance = nil
end

function KaiFuDegreeRewardsData:SetDegreeMountInfo(protocol)
	self.mount_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.mount_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.mount_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeWingInfo(protocol)
	self.wing_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.wing_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.wing_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeHaloInfo(protocol)
	self.halo_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.halo_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.halo_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeFootInfo(protocol)
	self.foot_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.foot_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.foot_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeFightMountInfo(protocol)
	self.fightmount_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.fightmount_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.fightmount_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeShenGongInfo(protocol)
	self.shengong_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.shengong_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.shengong_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeShenYiInfo(protocol)
	self.shenyi_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.shenyi_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.shenyi_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeYaoShiInfo(protocol)
	self.yaoshi_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.yaoshi_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.yaoshi_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeTouShiInfo(protocol)
	self.toushi_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.toushi_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.toushi_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeQiLinBiInfo(protocol)
	self.qilinbi_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.qilinbi_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.qilinbi_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeMaskInfo(protocol)
	self.mask_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.mask_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.mask_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeXianBaoInfo(protocol)
	self.xianbao_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.xianbao_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.xianbao_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeLingZhuInfo(protocol)
	self.lingzhu_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.lingzhu_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.lingzhu_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeLingChongInfo(protocol)
	self.lingchong_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.lingchong_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.lingchong_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeLingGongInfo(protocol)
	self.linggong_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.linggong_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.linggong_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:SetDegreeLingQiInfo(protocol)
	self.lingqi_can_reward = bit:d2b(protocol.can_fetch_reward_flag)
	self.lingqi_fetch_reward = bit:d2b(protocol.fetch_reward_flag)
	self.lingqi_rare_reward_fetch = bit:d2b(protocol.rare_reward_fetch_flag)
end

function KaiFuDegreeRewardsData:GetMountDegreeCfg()
	local mount_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().mount_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().mount_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE)
end

function KaiFuDegreeRewardsData:GetWingDegreeCfg()
	local wing_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().wing_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().wing_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE)
end

function KaiFuDegreeRewardsData:GetHaloDegreeCfg()
	local halo_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().halo_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().halo_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW)
end

function KaiFuDegreeRewardsData:GetFootDegreeCfg()
	local foot_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().footprint_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().footprint_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW)
end

function KaiFuDegreeRewardsData:GetFinghtMountDegreeCfg()
	local fightmount_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().fightmount_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().fightmount_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW)
end

function KaiFuDegreeRewardsData:GetShenGongDegreeCfg()
	local shengong_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().shengong_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().shengong_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW)
end

function KaiFuDegreeRewardsData:GetShenYiDegreeCfg()
	local shenyi_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().shenyi_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().shenyi_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW)
end

function KaiFuDegreeRewardsData:GetYaoShiDegreeCfg()
	local yaoshi_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().yaoshi_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().yaoshi_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE)
end

function KaiFuDegreeRewardsData:GetTouShiDegreeCfg()
	local toushi_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().toushi_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().toushi_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE)
end

function KaiFuDegreeRewardsData:GetQiLinBiDegreeCfg()
	local qilinbi_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().qilinbi_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().qilinbi_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE)
end

function KaiFuDegreeRewardsData:GetMaskDegreeCfg()
	local mask_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().mask_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().mask_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE)
end

function KaiFuDegreeRewardsData:GetXianBaoDegreeCfg()
	local xianbao_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().xianbao_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().xianbao_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE)
end

function KaiFuDegreeRewardsData:GetLingZhuDegreeCfg()
	local lingzhu_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().lingzhu_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().lingzhu_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE)
end

function KaiFuDegreeRewardsData:GetLingChongDegreeCfg()
	local lingchong_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().lingchong_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().lingchong_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE)
end

function KaiFuDegreeRewardsData:GetLingGongDegreeCfg()
	local linggong_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().linggong_upgrade
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().linggong_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE)
end

function KaiFuDegreeRewardsData:GetLingQiDegreeCfg()
	return self:GetRandActivityConfig(ServerActivityData.Instance:GetCurrentRandActivityConfig().lingqi_upgrade, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE)
end

function KaiFuDegreeRewardsData:GetRandActivityConfig(cfg, type)
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local pass_day = ActivityData.Instance:GetActDayPassFromStart(type)
	local rand_t = {}
	local day = nil
	if cfg == nil then
		return rand_t
	end
	if cfg[0] and (nil == day or cfg[0].opengame_day == day) and (open_day - pass_day) <= cfg[0].opengame_day then
		day = cfg[0].opengame_day
		rand_t[cfg[0].seq] = cfg[0]
	end

	for k,v in ipairs(cfg) do
		if v and (nil == day or v.opengame_day == day) and (open_day - pass_day) <= v.opengame_day then
			day = v.opengame_day
			rand_t[v.seq] = v
		end
	end
	return rand_t
end

function KaiFuDegreeRewardsData:GetIsOpenBiPing(index)
	if index == nil then return end
	for k,v in pairs(BiPingList) do
		if k == index then
			if ActivityData.Instance:GetActivityIsOpen(v.activity_type) then
				return true
			end
		end
	end
	return false
end

function KaiFuDegreeRewardsData:GetBiPingActivity(index)
	for k,v in pairs(BiPingList) do
		if k == index then
			return v.activity_type
		end
	end
end

--是否可领取
function KaiFuDegreeRewardsData:GetCanReward(activity_type, index)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE then
		return self.mount_can_reward[32 - index] or 0

    elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE then
		return self.wing_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW then
		return self.halo_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW then
		return self.foot_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW then
		return self.fightmount_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW then
		return self.shengong_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW then
		return self.shenyi_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE then
		return self.yaoshi_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE then
		return self.toushi_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE then
		return self.qilinbi_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE then
		return self.mask_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE then
		return self.xianbao_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE then
		return self.lingzhu_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE then
		return self.lingchong_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE then
		return self.linggong_can_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE then
		return self.lingqi_can_reward[32 - index] or 0
	end
	return 0
end

--是否已领取
function KaiFuDegreeRewardsData:GetFetchReward(activity_type, index)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE then
		return self.mount_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE then
		return self.wing_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW then
		return self.halo_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW then
		return self.foot_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW then
		return self.fightmount_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW then
		return self.shengong_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW then
		return self.shenyi_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE then
		return self.yaoshi_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE then
		return self.toushi_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE then
		return self.qilinbi_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE then
		return self.mask_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE then
		return self.xianbao_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE then
		return self.lingzhu_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE then
		return self.lingchong_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE then
		return self.linggong_fetch_reward[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE then
		return self.lingqi_fetch_reward[32 - index] or 0
	end

	return 0
end

--特殊物品是否已领取
function KaiFuDegreeRewardsData:GetRareReward(activity_type, index)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE then
		return self.mount_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE then
		return self.wing_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW then
		return self.halo_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW then
		return self.foot_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW then
		return self.fightmount_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW then
		return self.shengong_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW then
		return self.shenyi_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE then
		return self.yaoshi_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE then
		return self.toushi_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE then
		return self.qilinbi_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE then
		return self.mask_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE then
		return self.xianbao_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE then
		return self.lingzhu_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE then
		return self.lingchong_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE then
		return self.linggong_rare_reward_fetch[32 - index] or 0

	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE then
		return self.lingqi_rare_reward_fetch[32 - index] or 0
	end

	return 0
end

--获取当前面板对应的活动类型(这个值是点击面板的时候传进来的)
function KaiFuDegreeRewardsData:SetDegreeActivityType(activity_type)
    self.ac_type = activity_type or 0
end

--红点
function KaiFuDegreeRewardsData:GetMountDegreeRemind()
	local data = self:GetMountDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetWingDegreeRemind()
	local data = self:GetWingDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetHaloDegreeRemind()
	local data = self:GetHaloDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetFootDegreeRemind()
	local data = self:GetFootDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetFightMountDegreeRemind()
	local data = self:GetFinghtMountDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetShenGongDegreeRemind()
	local data = self:GetShenGongDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetShenYiDegreeRemind()
	local data = self:GetShenYiDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetYaoShiDegreeRemind()
	local data = self:GetYaoShiDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetTouShiDegreeRemind()
	local data = self:GetTouShiDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetQiLinBiDegreeRemind()
	local data = self:GetQiLinBiDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetMaskDegreeRemind()
	local data = self:GetMaskDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetXianBaoDegreeRemind()
	local data = self:GetXianBaoDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetLingZhuDegreeRemind()
	local data = self:GetLingZhuDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetLingChongDegreeRemind()
	local data = self:GetLingChongDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetLingGongDegreeRemind()
	local data = self:GetLingGongDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetLingQiDegreeRemind()
	local data = self:GetLingQiDegreeCfg()
	if data then
		for k,v in pairs(data) do
			local can_rewards = self:GetCanReward(
				ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE, v.seq)

	    	local fetch_reward = self:GetFetchReward(
	    		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE, v.seq)

	    	if can_rewards == 1 and fetch_reward == 0 then
	    		return 1
	    	end
		end
	end
	return 0
end

function KaiFuDegreeRewardsData:GetDegreeName()
    if Language.Common.DegreeCellName[self.ac_type] then
   		 return Language.Common.DegreeCellName[self.ac_type]
	end
	return ""
end

function KaiFuDegreeRewardsData:GetDegreeRewardsCfg()
	if self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE then
		self.degree_rewards_cfg = self:GetMountDegreeCfg()

    elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE then
    	self.degree_rewards_cfg = self:GetWingDegreeCfg()

    elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW then
    	self.degree_rewards_cfg = self:GetHaloDegreeCfg()

    elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW then
    	self.degree_rewards_cfg = self:GetFootDegreeCfg()

    elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW then
    	self.degree_rewards_cfg = self:GetFinghtMountDegreeCfg()

    elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW  then
    	self.degree_rewards_cfg = self:GetShenGongDegreeCfg()

    elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW then
    	self.degree_rewards_cfg = self:GetShenYiDegreeCfg()

	elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE then
		self.degree_rewards_cfg = self:GetYaoShiDegreeCfg()

	elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE then
		self.degree_rewards_cfg = self:GetTouShiDegreeCfg()

	elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE then
		self.degree_rewards_cfg = self:GetQiLinBiDegreeCfg()

	elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE then
		self.degree_rewards_cfg = self:GetMaskDegreeCfg()

	elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE then
		self.degree_rewards_cfg = self:GetXianBaoDegreeCfg()

	elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE then
		self.degree_rewards_cfg = self:GetLingZhuDegreeCfg()

	elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE then
		self.degree_rewards_cfg = self:GetLingChongDegreeCfg()

	elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE then
		self.degree_rewards_cfg = self:GetLingGongDegreeCfg()

	elseif self.ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE then
		self.degree_rewards_cfg = self:GetLingQiDegreeCfg()
    end

	return self.degree_rewards_cfg
end

function KaiFuDegreeRewardsData:GetDegreeActivityReward()
	local cfg = self:GetDegreeRewardsCfg()
	local spec_cfg = nil
	local super_reward = nil
	local list = {}
	for k, v in pairs(cfg) do
		local fetch_reward_flag = (self:GetFetchReward(self.ac_type, v.seq) and 1 == self:GetFetchReward(self.ac_type, v.seq)) and 1 or 0
		local rare_reward = self:GetRareReward(self.ac_type, v.seq) or 0
		local data = {}
		data.cfg = v
		data.fetch_reward_flag = fetch_reward_flag
		data.seq = v.seq
		if v.super_reward and v.super_reward.item_id > 0 then
			super_reward = data
		elseif v.rare_reward_item and v.rare_reward_item.item_id > 0 and rare_reward == 0 then
			spec_cfg = data
		else
			table.insert(list, data)
		end
	end

	table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "seq"))
	list[0] = table.remove(list, 1)
	return list, spec_cfg or super_reward
end

function KaiFuDegreeRewardsData:GetDegreeRewardsGrade(data_index)
	if self.degree_rewards_cfg == nil or self.degree_rewards_cfg[data_index] == nil then return 0 end

	return self.degree_rewards_cfg[data_index].need_value
	       or self.degree_rewards_cfg[data_index].need_jie or 0
end

--判断是否是循环进阶活动
function KaiFuDegreeRewardsData.IsDegreeRewardsType(activity_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE
		or activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE

		then return true

    end
	return false
end

--按钮显示限制
function KaiFuDegreeRewardsData.IsCanOpenDegreeRewards(ac_type)
	if ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE and not OpenFunData.Instance:CheckIsHide("mount_jinjie") then
		return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE and not OpenFunData.Instance:CheckIsHide("wing_jinjie") then
		return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW and not OpenFunData.Instance:CheckIsHide("halo_jinjie") then
		return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW and not OpenFunData.Instance:CheckIsHide("foot_jinjie") then
		return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW and not OpenFunData.Instance:CheckIsHide("fight_mount") then
		return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW and not OpenFunData.Instance:CheckIsHide("goddess_shengong") then
		return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW and not OpenFunData.Instance:CheckIsHide("goddess_shenyi") then
		return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE and not OpenFunData.Instance:CheckIsHide("appearance_waist") then
		return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE and not OpenFunData.Instance:CheckIsHide("appearance_toushi") then
		return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE and not OpenFunData.Instance:CheckIsHide("appearance_qilinbi") then
		return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE and not OpenFunData.Instance:CheckIsHide("appearance_mask") then
	return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE and not OpenFunData.Instance:CheckIsHide("appearance_xianbao") then
	return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE and not OpenFunData.Instance:CheckIsHide("appearance_lingzhu") then
	return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE and not OpenFunData.Instance:CheckIsHide("lingchong_jinjie") then
	return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE and not OpenFunData.Instance:CheckIsHide("appearance_linggong") then
	return false

	elseif ac_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE and not OpenFunData.Instance:CheckIsHide("appearance_lingqi") then
	return false
	end

	return true
end

--判断循环进阶活动是否开启
function KaiFuDegreeRewardsData.IsDegreeRewardsOpen()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE)
		or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE)

		then return true
    end
	return false
end

function KaiFuDegreeRewardsData:SetBuyInfo(protocol)
	if self.buy_info then
		self.buy_info[protocol.activity_id] = protocol.is_already_buy
		self.buy_grade[protocol.activity_id] = protocol.grade
	else
		self.buy_info = {}
		for k,v in pairs(RAND_ACTIVITY_TYPE_UPGRADE) do
			self.buy_info[k] = 0
		end
		self.buy_info[protocol.activity_id] = protocol.is_already_buy
		self.buy_grade[protocol.activity_id] = protocol.grade
	end
end

function KaiFuDegreeRewardsData:GetBuyDataByType(activity_type)
	local activity_seq = RAND_ACTIVITY_TYPE_UPGRADE[activity_type]
	if not activity_seq then
		print_error("没有活动索引")
		return nil
	end
	local open_game_day = TimeCtrl.Instance:GetCurOpenServerDay()
	open_game_day = GetRangeRank(self.buy_cfg_open_day_list, open_game_day)
	local grade = self.buy_grade[activity_type]
	-- if not self.upgrade_data_class_list then
	-- 	self.upgrade_data_class_list = self:GetUpgradeData()
	-- end
	-- local grade = self.upgrade_data_class_list[activity_type].Instance:GetGrade()
	-- grade = grade
	local info_list = CheckList(self.buy_cfg, open_game_day, activity_seq)
	if not info_list then return end
	local range = {}
	for k,v in pairs(info_list) do
		table.insert(range, k)
	end
	table.sort(range)
	local flag = true
	if grade > range[#range] then
		flag = false
	end
	grade = GetRangeRank(range, grade)

	info_list = info_list[grade]
	return info_list, flag
end

function KaiFuDegreeRewardsData:GetUpgradeData()
	return {
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE] = MountData,             --坐骑
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE] = WingData,			  --羽翼
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW] = HaloData,		  --光环
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW] = FootData,     --足迹
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW] = FightMountData,	  --战骑
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW] = ShengongData,	  --神弓
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW] = ShenyiData,	      --神翼
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE] = WaistData,			  --腰饰
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE] = TouShiData,			  --头饰
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE] = QilinBiData,			  --麒麟臂
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE] = MaskData,			  --面饰
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE] = XianBaoData,			  --仙宝
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE] = LingZhuData,			  --灵珠
	}
end

function KaiFuDegreeRewardsData:CanBuy(activity_type)
	local flag = CheckList(self.buy_info, activity_type)
	if not flag then
		return false
	end
	return self.buy_info[activity_type] == 1
end

function KaiFuDegreeRewardsData:CanShowBuyItem()
	local show_day = ConfigManager.Instance:GetAutoConfig("upgrade_card_buy_cfg_auto").other[1].limit_opengame_day
	local open_game_day = TimeCtrl.Instance:GetCurOpenServerDay()
	return open_game_day > show_day
end
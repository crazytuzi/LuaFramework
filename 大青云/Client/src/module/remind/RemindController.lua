--[[
下方提醒
lizhuangzhuang
2014年10月21日15:56:53
]]

_G.RemindController = setmetatable({},{__index=IController});

RemindController.name = "RemindController";

RemindController.QueueMap = {
	[RemindConsts.Type_FriendApply] = RemindFriendApplyQueue,
	[RemindConsts.Type_TeamApply]   = RemindTeamApplyQueue,
	[RemindConsts.Type_TeamInvite]  = RemindTeamInviteQueue,
	[RemindConsts.Type_GuildInvite] = RemindGuildInviteQueue,
	[RemindConsts.Type_NewMail]     = RemindNewMailQueue,
	[RemindConsts.Type_HANG]        = RemindHangQueue,
	[RemindConsts.Type_EaLeftPoint] = RemindEaLeftPointQueue,
	[RemindConsts.Type_FengYao]		= RemindFengYaoQueue,
	[RemindConsts.Type_DropItem]	= RemindDropItemQueue,
	[RemindConsts.Type_LevelReward]	= RemindLevelRewardQueue,
	[RemindConsts.Type_FRecommend]	= RemindFRecommendQueue,
	[RemindConsts.Type_LvlUp]		= RemindLvlUpQueue,
	[RemindConsts.Type_CaveBoss]	= RemindCaveBossQueue,
	[RemindConsts.Type_LingLu]		= RemindLingLuQueue,
	[RemindConsts.Type_HuiZhang]	= RemindLingLiHuiZhangQueue,
	[RemindConsts.Type_Skill]		= RemindSkillQueue,
	[RemindConsts.Type_FReward]		= RemindFRewardQueue,
	[RemindConsts.Type_LovelyPet]	= RemindLovelyPetPassQueue,
	[RemindConsts.Type_DominateRoute]	= 	RemindDominateRouteQueue,
	[RemindConsts.Type_GuildZhaoji] = RemindGuildZhaojiQueue,
	[RemindConsts.Type_SWYJ]        = RemindSWYJQueue,
	[RemindConsts.Type_GuildDGBid]  = RemindGuildDiGongBidQueue,
	[RemindConsts.Type_UnionWar]  = RemindUnionWarQueue,
	[RemindConsts.Type_UnionDGWar]  = RemindUnionDiGongWarQueue,
	[RemindConsts.Type_UnionCityWar]= RemindUnionCityWarQueue,
	[RemindConsts.Type_InterBoss]= RemindInierServiceBossQueue,
	[RemindConsts.Type_InterContest]= RemindInierServiceContestQueue,
	[RemindConsts.Type_InterContestPreZige]= RemindContestZigeQueue,
	[RemindConsts.Type_SmithingStar] = RemindSmithingStarQueue,
	[RemindConsts.Type_SmithingInlay] = RemindSmithingInlayQueue,
	[RemindConsts.Type_SmithingWash] = RemindSmithingWashQueue,
	[RemindConsts.Type_SmithingGroup] = RemindSmithingGroupQueue,
	[RemindConsts.Type_LovelyPetFight] = RemindLovelyPetFightQueue,
	[RemindConsts.Type_HuoYueDuUp] = RemindHuoYueDuUpQueue,
	[RemindConsts.Type_MountUp] = RemindMountUpQueue,
	[RemindConsts.Type_FuMo] = RemindFuMoQueue,
	[RemindConsts.Type_XingTu] = RemindXingTuQueue,
	[RemindConsts.Type_ZhuanZhi] = RemindZhuanZhiQueue,
	[RemindConsts.Type_SmithingCollection] = RemindSmithingCollectionQueue,
	[RemindConsts.Type_SkillJueXue] = RemindSkillJueXueQueue,

};

function RemindController:Create()

end

--添加提醒
function RemindController:AddRemind(type,data)
	local remindQueue = RemindModel:GetQueue(type);
	if not remindQueue then
		local clz = self.QueueMap[type];
		if not clz then print('没有找到注册提醒类型'..type) return; end
		remindQueue = clz:new();
		RemindModel:AddQueue(remindQueue);
	end
	remindQueue:AddData(data);
	remindQueue:RefreshData();
end

--清空提醒
function RemindController:ClearRemind(type)
	local remindQueue = RemindModel:GetQueue(type);
	if not remindQueue then return; end
	remindQueue:ClearData();
	remindQueue:RefreshData();
end

function RemindController:ExecuteRemind(type)
	local remindQueue = RemindModel:GetQueue(type);
	if not remindQueue then
		local clz = self.QueueMap[type];
		if not clz then print('没有找到注册提醒类型可以执行'..type) return; end
		remindQueue = clz:new();
		RemindModel:AddQueue(remindQueue);
	end
	remindQueue:Execute();
end

--检查是否有提醒，目前在登录和升级的时候调用这个函数
function RemindController:CheckShow()
	--装备升星
	self:ExecuteRemind(RemindConsts.Type_SmithingStar);
	--宝石镶嵌 宝石升级
	self:ExecuteRemind(RemindConsts.Type_SmithingInlay);
	--装备洗练
	self:ExecuteRemind(RemindConsts.Type_SmithingWash);
	--装备套装
	self:ExecuteRemind(RemindConsts.Type_SmithingGroup);
	--宠物到期
	LovelyPetUtil:RemindCurrentPetOverdue();
	--宠物没一个是出战的
	self:ExecuteRemind(RemindConsts.Type_LovelyPetFight);
	--技能可以升级
	self:ExecuteRemind(RemindConsts.Type_Skill);
	--绝学可以升级
	self:ExecuteRemind(RemindConsts.Type_SkillJueXue);
	--仙阶活跃度
	self:ExecuteRemind(RemindConsts.Type_HuoYueDuUp);
	--坐骑
	self:ExecuteRemind(RemindConsts.Type_MountUp);
	--潜力点未加
	self:ExecuteRemind(RemindConsts.Type_EaLeftPoint);
	--伏魔
	self:ExecuteRemind(RemindConsts.Type_FuMo);
	--星图
	self:ExecuteRemind(RemindConsts.Type_XingTu);
	--转职
	self:ExecuteRemind(RemindConsts.Type_ZhuanZhi);
	--封妖 悬赏
	self:ExecuteRemind(RemindConsts.Type_FengYao);
	--神装收集
	self:ExecuteRemind(RemindConsts.Type_SmithingCollection);
end

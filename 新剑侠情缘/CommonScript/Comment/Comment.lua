
GameSetting.Comment = GameSetting.Comment or {};

local Comment = GameSetting.Comment;

Comment.Type_CardPick_SS = 1;				--抽卡SS级同伴
Comment.Type_RandomFuben_SSS = 2;			--随机秘境SSS评分
Comment.Type_TeamFuben_SSS = 3;				--组队秘境SSS评价
Comment.Type_HeroChallenge_10 = 4;			--英雄挑战10关通过
Comment.Type_HonorLevelChange = 5;			--头衔晋升（具体哪些头衔在下面配置）
Comment.Type_WhiteTiger_BOSS = 6;			--白虎堂击杀四层boss
Comment.Type_WuLinMengZhu_First = 7;		--武林盟主第一
Comment.Type_RankBattle_First = 8;			--武神殿第一
Comment.Type_Battle_First = 9;				--战场第一
Comment.Type_HuaShanLunJian_First = 10		--华山论剑第一
Comment.Type_TeamBattle_7 = 11;				--通天塔第一
Comment.Type_FactionBattle_BigBrother = 12;	--门派竞技大湿胸
Comment.Type_FactionBattle_NewbieKing = 13;	--门派竞技新人王

-- 配置每个类型属于哪个组
Comment.tbTypeGroup =
{
--仅触发一次（1年触发一次）
	[Comment.Type_RandomFuben_SSS]			= 1,		--随机秘境SSS评分
	[Comment.Type_TeamFuben_SSS]			= 1,		--组队秘境SSS评价
	[Comment.Type_HeroChallenge_10]			= 1,		--英雄挑战10关通过
--每月触发一次
	[Comment.Type_RankBattle_First]			= 2,		--武神殿第一
	[Comment.Type_WuLinMengZhu_First]		= 2,		--武林盟主第一
	[Comment.Type_TeamBattle_7]				= 2,		--通天塔第一
	[Comment.Type_CardPick_SS]				= 2,		--抽卡SS级同伴
	[Comment.Type_Battle_First]				= 2,		--战场第一
	[Comment.Type_WhiteTiger_BOSS]			= 2,		--白虎堂击杀四层boss
	[Comment.Type_HuaShanLunJian_First]		= 3,		--华山论剑第一
	[Comment.Type_FactionBattle_BigBrother]	= 4,		--门派竞技大湿胸
	[Comment.Type_FactionBattle_NewbieKing]	= 5,		--门派竞技新人王
	[Comment.Type_HonorLevelChange]			= 6,		--头衔晋升
}

-- 配置每个组每月显示几次
Comment.tbGroupMonthSetting =
{
	[2] = 1,
	[3] = 1,
	[4] = 1,
	[5] = 1,
	[6] = 1,
}

-- 每月最多显示多少次
Comment.nMonthTotalTimes = 3;

-- 配置每个组每年显示几次
Comment.tbGroupYearSetting =
{
	[1] = 1,
}

-- 这些头衔才提示
Comment.tbHonorTips = {
	[6] = 1,
	[7] = 1,
	[8] = 1,
	[9] = 1,
	[10] = 1,
	[11] = 1,
	[12] = 1,
}

function Comment:OnEvent(nEventType, ...)
	local nGroupId = self.tbTypeGroup[nEventType];
	if not nGroupId then
		return;
	end

	local tbParam = {...};
	if nEventType == self.Type_HonorLevelChange then
		local nHonorLevel = tbParam[1];
		if not self.tbHonorTips[nHonorLevel] then
			return;
		end
	end

	local tbSetting = Client:GetUserInfo("Comment");
	tbSetting.tbMonth = tbSetting.tbMonth or {};

	local bShowComment = false;
	if self.tbGroupMonthSetting[nGroupId] then
		local nCurMonth = Lib:GetLocalMonth();
		tbSetting.tbMonth = tbSetting.tbMonth or {nMonth = 0};
		if tbSetting.tbMonth.nMonth ~= nCurMonth then
			tbSetting.tbMonth = {nMonth = nCurMonth, nTotalTimes = 0};
		end

		tbSetting.tbMonth[nGroupId] = tbSetting.tbMonth[nGroupId] or 0;
		tbSetting.tbMonth[nGroupId] = tbSetting.tbMonth[nGroupId] + 1;
		tbSetting.tbMonth.nTotalTimes = tbSetting.tbMonth.nTotalTimes + 1;
		bShowComment = (tbSetting.tbMonth[nGroupId] <= self.tbGroupMonthSetting[nGroupId] and tbSetting.tbMonth.nTotalTimes <= self.nMonthTotalTimes);
	elseif self.tbGroupYearSetting[nGroupId] then
		local tbTime = os.date("*t", GetTime());
		tbSetting.tbYear = tbSetting.tbYear or {nYear = 0};
		if tbSetting.tbYear.nYear ~= tbTime.year then
			tbSetting.tbYear = {nYear = tbTime.year};
		end

		tbSetting.tbYear[nGroupId] = tbSetting.tbYear[nGroupId] or 0;
		tbSetting.tbYear[nGroupId] = tbSetting.tbYear[nGroupId] + 1;
		bShowComment = tbSetting.tbYear[nGroupId] <= self.tbGroupYearSetting[nGroupId];
	end

	if not bShowComment then
		return;
	end

	-- 需要的时候才保存
	Client:SaveUserInfo();

	Ui:OpenWindow("Comment");
end


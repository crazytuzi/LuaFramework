Require("CommonScript/Activity/BeautyPageant.lua");

local tbAct = Activity.BeautyPageant
local tbActUiSetting = Activity:GetUiSetting("BeautyPageant")
tbActUiSetting.szUiName = "BeautySelection"
tbActUiSetting.szTitle  = "武林第一美女评选"
tbActUiSetting.nShowLevel = tbAct.LEVEL_LIMIT
tbActUiSetting.nShowPriority = 2

tbAct.REFRESH_SIGNUP_FRIEND_INTERVAL = 30

--这里的奖励只用来做界面显示
local tbSignUpTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.SIGN_UP]
local tbLocalTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.LOCAL]
local tbFinalTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.FINAL]

tbAct.tbShowAward = 
{
	{
		szContent = string.format([[
[FFFE0D]「武林第一美女评选」[-]活动开始了！各阶段规则请看以下介绍：

[FFFE0D]【报名阶段】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]等级要求：[-]等级达到[FFFE0D]%d级[-]
[FFFE0D]报名条件：[-]女性玩家[FFFE0D]（游戏中男女性角色均可报名）[-]
    前往襄阳城[00ff00] [url=npc:「选美大会司仪」紫轩, 622, 10][-]处报名参赛，报名需要上传[FFFE0D]本人真实的照片及其他信息[-]，报名成功后资料会进入待审核状态，如果提交的资料涉及违规，将不会通过审核，需要重新提交资料再次报名。若资料审核通过则表示成功报名参赛，并且会通过邮件发放[ff8f06][url=openwnd:选美宣传单, ItemTips, "Item", nil, 4691][-]，可以通过它在任意聊天频道宣传本人的选美信息，或打开自己的参赛页面。

[FFFE0D]【海选赛（本服评选）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]票选对象：[-]本服成功报名参赛的佳人
    此阶段，玩家可以通过消耗[FF69B4][url=openwnd:红粉佳人, ItemTips, "Item", nil, 4692][-]道具给心目中的女神进行投票。[FFFE0D]每消耗1朵，被投佳人票数+1[-]。通过该道具可以打开投票页面，或者点击主屏幕的“美女评选”图标进入投票页面。
    [FFFE0D]%s[-]将按票数排名评选出海选赛十强佳人，其中票数排名第一名的佳人评为[FF69B4]「本服第一美女」[-]，票数排名前十名的佳人评为[FF69B4]「本服十大美女」[-]，且每个服务器最终排名[FFFE0D]前3名[-]的佳人自动入围[FFFE0D]决赛（跨服评选）[-]。
    [00FF00][url=openwnd:查看【红粉佳人】获得途径, AttributeDescription, '', false, 'BeautyPageantVoteItem'][-]

[FFFE0D]海选赛奖励[-] ]], Lib:TimeDesc10(tbSignUpTime[1]), Lib:TimeDesc10(tbLocalTime[2]+1), tbAct.LEVEL_LIMIT, Lib:TimeDesc10(tbLocalTime[1]), Lib:TimeDesc10(tbLocalTime[2]+1), Lib:TimeDesc10(tbLocalTime[2]+1));
		tbAllAward = {
			{
				szTitle = "海选赛冠军";
				tbAward = {
					{"Item", 4872, 1},  --雕像
					{"Item", 4838, 2},  --5级家具摆设
					{"Item", 4863, 1},  --坐骑外装（紫色）
					{"Item", 4822, 1},  --头像
					{"Item", 4830, 1},  --聊天前缀
					{"Item", 4846, 1},  --称号
					{"Item", 4842, 1},  --称号特效
					{"Item", 4832, 1},  --头像框
					{"Item", 4856, 1},  --世界红包
					{"Item", 4852, 1},  --家族红包
				};
			};
			{
				szTitle = "海选赛十强";
				tbAward = {
					{"Item", 4838, 1},  --5级家具摆设
					{"Item", 4823, 1},  --头像
					{"Item", 4847, 1},  --称号
					{"Item", 4843, 1},  --称号特效
					{"Item", 4832, 1},  --头像框
					{"Item", 4853, 1},  --家族红包
				};
			};
			{
				szTitle = "获投199票";
				tbAward = {
					{"Item", 4848, 1},  --称号
					{"Item", 4824, 1},  --头像
					{"Item", 4854, 1},  --家族红包
					{"Energy", 15000},
				};
			};
		};
	};

	{
		szContent = string.format([[
[FFFE0D]【决赛（跨服评选）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]票选对象：[-]入围决赛的佳人
    每个服务器海选赛[FFFE0D]前3名[-]的佳人自动入围决赛阶段，决赛阶段的投票方式与海选赛相同[FFFE0D]（可以给跨服的佳人投票）[-]。[FFFE0D]%s[-]将按票数排名评选出决赛十强佳人，其中票数排名第一名的佳人评为[FF69B4]「武林第一美女」[-]，票数排名前十名的佳人评为[FF69B4]「武林十大美女」[-]。

[FFFE0D]决赛奖励[-] ]], Lib:TimeDesc10(tbFinalTime[1]), Lib:TimeDesc10(tbFinalTime[2]+1), Lib:TimeDesc10(tbFinalTime[2]+1));
		tbAllAward = {
			{
				szTitle = "决赛冠军";
				tbAward = {
					{"Item", 4839, 1},  --雕像
					{"Item", 4837, 2},  --6级家具摆设
					{"Item", 4869, 1},  --坐骑外装（粉色带特效）
					{"Item", 4821, 1},  --头像
					{"Item", 4828, 1},  --聊天前缀
					{"Item", 4844, 1},  --称号
					{"Item", 4840, 1},  --称号特效
					{"Item", 4831, 1},  --头像框
					{"Item", 4858, 1},  --世界红包
					{"Item", 4855, 1},  --家族红包
				};
			};
			{
				szTitle = "决赛十强";
				tbAward = {
					{"Item", 4837, 1},  --6级家具摆设
					{"Item", 4864, 1},  --坐骑外装（粉色）
					{"Item", 4821, 1},  --头像
					{"Item", 4829, 1},  --聊天前缀
					{"Item", 4845, 1},  --称号
					{"Item", 4841, 1},  --称号特效
					{"Item", 4831, 1},  --头像框
					{"Item", 4857, 1},  --世界红包
					{"Item", 4870, 1},  --家族红包
				};
			};
			{
				szTitle = "获投8000票";
				tbAward = {
					{"Item", 4838, 1},  --地毯
					{"Item", 4820, 1},  --头像
					{"Item", 5252, 1},  --前缀
					{"Item", 5253, 1},  --称号
					{"Energy", 30000},
					{"Item", 5255, 1},  --世界红包
					{"Item", 5254, 1},  --家族红包
				};
			};
		};
	};
}

if version_vn then
	local tbSemiFinalTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.SEMIFINAL]
	tbAct.tbShowAward = 
	{
		{
			szContent = string.format([[
	[FFFE0D]「武林第一美女评选」[-]活动开始了！各阶段规则请看以下介绍：
	
	[FFFE0D]【报名阶段】[-]
	[FFFE0D]阶段时间：[-]%s ~ %s
	[FFFE0D]等级要求：[-]等级达到[FFFE0D]%d级[-]
	[FFFE0D]报名条件：[-]女性玩家[FFFE0D]（游戏中男女性角色均可报名）[-]
	    前往襄阳城[00ff00] [url=npc:「选美大会司仪」紫轩, 622, 10][-]处报名参赛，报名需要上传[FFFE0D]本人真实的照片及其他信息[-]，报名成功后资料会进入待审核状态，如果提交的资料涉及违规，将不会通过审核，需要重新提交资料再次报名。若资料审核通过则表示成功报名参赛，并且会通过邮件发放[ff8f06][url=openwnd:选美宣传单, ItemTips, "Item", nil, 4691][-]，可以通过它在任意聊天频道宣传本人的选美信息，或打开自己的参赛页面。
	
	[FFFE0D]【海选赛（本服评选）】[-]
	[FFFE0D]阶段时间：[-]%s ~ %s
	[FFFE0D]票选对象：[-]本服成功报名参赛的佳人
	    此阶段，玩家可以通过消耗[FF69B4][url=openwnd:红粉佳人, ItemTips, "Item", nil, 4692][-]道具给心目中的女神进行投票。[FFFE0D]每消耗1朵，被投佳人票数+1[-]。通过该道具可以打开投票页面，或者点击主屏幕的“美女评选”图标进入投票页面。
	    [FFFE0D]%s[-]将按票数排名评选出海选赛十强佳人，其中票数排名第一名的佳人评为[FF69B4]「本服第一美女」[-]，票数排名前十名的佳人评为[FF69B4]「本服十大美女」[-]，且每个服务器最终排名[FFFE0D]前3名[-]的佳人自动入围[FFFE0D]全服评选[-]。
	    [00FF00][url=openwnd:查看【红粉佳人】获得途径, AttributeDescription, '', false, 'BeautyPageantVoteItem'][-]
	
	[FFFE0D]海选赛奖励[-] ]], Lib:TimeDesc10(tbSignUpTime[1]), Lib:TimeDesc10(tbLocalTime[2]+1), tbAct.LEVEL_LIMIT, Lib:TimeDesc10(tbLocalTime[1]), Lib:TimeDesc10(tbLocalTime[2]+1), Lib:TimeDesc10(tbLocalTime[2]+1));
			tbAllAward = {
				{
					szTitle = "海选赛冠军";
					tbAward = {
						{"Item", 4872, 1},  --雕像
						{"Item", 4838, 2},  --5级家具摆设
						{"Item", 4863, 1},  --坐骑外装（紫色）
						{"Item", 4822, 1},  --头像
						{"Item", 4830, 1},  --聊天前缀
						{"Item", 4846, 1},  --称号
						{"Item", 4842, 1},  --称号特效
						{"Item", 4832, 1},  --头像框
						{"Item", 4856, 1},  --世界红包
						{"Item", 4852, 1},  --家族红包
					};
				};
				{
					szTitle = "海选赛十强";
					tbAward = {
						{"Item", 4838, 1},  --5级家具摆设
						{"Item", 4823, 1},  --头像
						{"Item", 4847, 1},  --称号
						{"Item", 4843, 1},  --称号特效
						{"Item", 4832, 1},  --头像框
						{"Item", 4853, 1},  --家族红包
					};
				};
				{
					szTitle = "获投199票";
					tbAward = {
						{"Item", 4848, 1},  --称号
						{"Item", 4824, 1},  --头像
						{"Item", 4854, 1},  --家族红包
						{"Energy", 15000},
					};
				};
			};
		};

		{
			szContent = string.format([[
	[FFFE0D]【全服评选阶段】[-]
	[FFFE0D]阶段时间：[-]%s ~ %s
	[FFFE0D]票选对象：[-]入围全服评选的佳人
	    此阶段，玩家可以通过消耗[FF69B4][url=openwnd:红粉佳人, ItemTips, "Item", nil, 4692][-]道具给心目中的女神进行投票。[FFFE0D]每消耗1朵，被投佳人票数+1[-]。通过该道具可以打开投票页面，或者点击主屏幕的“美女评选”图标进入投票页面。
	    [FFFE0D]%s[-]将按票数排名评选全服十强佳人，另外评委会会在排名前11~50名的玩家中选出10名美女与前十强一同进入决赛角逐武林第一美女桂冠。
	    [00FF00][url=openwnd:查看【红粉佳人】获得途径, AttributeDescription, '', false, 'BeautyPageantVoteItem'][-]
	
	[FFFE0D]全服评选奖励[-] ]], Lib:TimeDesc10(tbSemiFinalTime[1]), Lib:TimeDesc10(tbSemiFinalTime[2]+1), Lib:TimeDesc10(tbSemiFinalTime[2]+1));
			tbAllAward = {
				{
					szTitle = "获投8000票";
					tbAward = {
						{"Item", 4838, 1},  --地毯
						{"Item", 4820, 1},  --头像
						{"Item", 5252, 1},  --前缀
						{"Item", 5253, 1},  --称号
						{"Energy", 30000},
						{"Item", 7947, 1},  --世界红包
						{"Item", 7944, 1},  --家族红包
					};
				};
			};
		};

		{
			szContent = string.format([[

	[FFFE0D]【决赛（跨服评选）】[-]
	[FFFE0D]阶段时间：[-]%s ~ %s
	[FFFE0D]票选对象：[-]入围决赛的佳人
	    每个服务器海选赛[FFFE0D]前3名[-]的佳人自动入围决赛阶段，决赛阶段的投票方式与海选赛相同[FFFE0D]（可以给跨服的佳人投票）[-]。[FFFE0D]%s[-]将按票数排名评选出决赛20强佳人，其中票数排名第一名的佳人评为[FF69B4]「武林第一美女」[-]，票数排名第二名的佳人评为[FF69B4]「武林第二美女」[-]，票数排名第三名的佳人评为[FF69B4]「武林第三美女」[-]，票数排名第4~20名的佳人评为[FF69B4]「武林绝色佳人」[-]。

	[FFFE0D]决赛奖励[-] ]], Lib:TimeDesc10(tbFinalTime[1]), Lib:TimeDesc10(tbFinalTime[2]+1), Lib:TimeDesc10(tbFinalTime[2]+1));
			tbAllAward = {
				{
					szTitle = "决赛冠军";
					tbAward = {
						{"Item", 4839, 1},  --雕像
						{"Item", 4837, 2},  --6级家具摆设
						{"Item", 4869, 1},  --坐骑外装（粉色带特效）
						{"Item", 4821, 1},  --头像
						{"Item", 4828, 1},  --聊天前缀
						{"Item", 4844, 1},  --称号
						{"Item", 4840, 1},  --称号特效
						{"Item", 4831, 1},  --头像框
						{"Item", 4858, 1},  --世界红包
						{"Item", 4855, 1},  --家族红包
					};
				};
				{
					szTitle = "决赛亚军";
					tbAward = {
						{"Item", 4837, 2},  --6级家具摆设
						{"Item", 4869, 1},  --坐骑外装（粉色带特效）
						{"Item", 4821, 1},  --头像
						{"Item", 7940, 1},  --聊天前缀
						{"Item", 7942, 1},  --称号
						{"Item", 4840, 1},  --称号特效
						{"Item", 4831, 1},  --头像框
						{"Item", 7948, 1},  --世界红包
						{"Item", 7945, 1},  --家族红包
					};
				};
				{
					szTitle = "决赛季军";
					tbAward = {
						{"Item", 4837, 2},  --6级家具摆设
						{"Item", 4869, 1},  --坐骑外装（粉色带特效）
						{"Item", 4821, 1},  --头像
						{"Item", 7941, 1},  --聊天前缀
						{"Item", 7943, 1},  --称号
						{"Item", 4840, 1},  --称号特效
						{"Item", 4831, 1},  --头像框
						{"Item", 7949, 1},  --世界红包
						{"Item", 7946, 1},  --家族红包
					};
				};
				{
					szTitle = "决赛20强";
					tbAward = {
						{"Item", 4837, 1},  --6级家具摆设
						{"Item", 4864, 1},  --坐骑外装（粉色）
						{"Item", 4821, 1},  --头像
						{"Item", 4829, 1},  --聊天前缀
						{"Item", 4845, 1},  --称号
						{"Item", 4841, 1},  --称号特效
						{"Item", 4831, 1},  --头像框
						{"Item", 7951, 1},  --世界红包
						{"Item", 7950, 1},  --家族红包
					};
				};
			};
		};
	}
end

function tbAct:OnLogout()
	self.nSignUpTimeOut = 0
	self.nLastSyncSignUpFriend = 0;
	self.tbSignUpFriendList = {}
end

function tbAct:IsShowMainButton()
	if not self:IsInProcess() then
		return false
	end

	if not me or me.nLevel < self.LEVEL_LIMIT then
		return false
	end

	return true
end

function tbAct:RequestSignUpFriend()
	local nNow = GetTime();
	self.nLastSyncSignUpFriend = self.nLastSyncSignUpFriend or 0;
	if (nNow - self.nLastSyncSignUpFriend) >= self.REFRESH_SIGNUP_FRIEND_INTERVAL then
		self.nLastSyncSignUpFriend = nNow;
		RemoteServer.BeautyPageantSignUpFriendReq();
	end
end

function tbAct:SyncIsSignUp(nSignUpTimeOut)
	self.nSignUpTimeOut = nSignUpTimeOut
end

function tbAct:SyncSignUpFriendList(tbList)
	self.tbSignUpFriendList = {}
	for _,nPlayerId in ipairs(tbList) do
		self.tbSignUpFriendList[nPlayerId] = 1
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_BEAUTY_FRIEND_LIST)
end

function tbAct:GetSignUpFriendList()
	return self.tbSignUpFriendList or {}
end

function tbAct:IsSignUp()
	return self.nSignUpTimeOut and GetTime() < self.nSignUpTimeOut
end

function tbAct:SendMsg(nType, nParam)
	local nChannelType = nParam
	if nType == tbAct.MSG_CHANNEL_TYPE.PRIVATE then
		nChannelType = ChatMgr.ChannelType.Private
		if FriendShip:IsHeInMyBlack(nParam) then
			me.CenterMsg("对方在您的黑名单中")
			return
		end
	end

	if not ChatMgr:CheckSendMsg(nChannelType, "1", false) then
		return false;
	end

	if nType == tbAct.MSG_CHANNEL_TYPE.PRIVATE then
		local szMsg, tbLinkData = self:GetSendMsg(me)
		ChatMgr:CachePrivateMsg(nParam, szMsg, tbLinkData)

	end

	RemoteServer.SendBeautyPageantChannelMsg(nType, nParam);
end

function tbAct:CheckPlayerData(pPlayer)
end

function tbAct:SyncFurnitureAwardFrame(szFrame)
	self.szFurnitureAwardFrame = szFrame
end

function tbAct:GetFurnitureAwardFrame()
	return self.szFurnitureAwardFrame
end

function tbAct:OnRefreshVotedAward()
	local bHaveAward = NewInformation.tbCustomCheckRP.fnBeautyRewardCheckRp()
	if bHaveAward then
		Activity:CheckRedPoint();
		NewInformation:CheckRedPoint();
	end
	--最新消息的次级界面需要带上EventId做参数
	UiNotify.OnNotify(UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD, UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD, bHaveAward)
end

function tbAct:OpenSignUpPage()
	Ui.HyperTextHandle:Handle(string.format("[url=openBeautyUrl:SignUp, %s][-]", self:GetSignUpUrl()));
end

function tbAct:OpenMainPage()
	Ui.HyperTextHandle:Handle(string.format("[url=openBeautyUrl:MainPage, %s][-]", self:GetMainEntryUrl()));
end

function tbAct:OnSynMiniMainMapInfo()
	local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
	for i,v in ipairs(tbMapTextPosInfo) do
		if v.Index == "BeautyPageant_diaoxiang" then
			v.Text = "选美冠军" ;
		end
	end
end

function tbAct:DoOpenBeautyUrl(szUrl)
	local nCurCount = me.GetItemCountInAllPos(Activity.BeautyPageant.VOTE_ITEM)
	local szMyKinName = ""
	if Kin:HasKin() then
		local tbKinBaseInfo = Kin:GetBaseInfo() or {}
		szMyKinName = tbKinBaseInfo.szName or szMyKinName
	end
	local szRoleName = Lib:UrlEncode(me.szName)
	szRoleName = string.gsub(szRoleName, "%%", "%%%%");
	szMyKinName = Lib:UrlEncode(szMyKinName)
	szMyKinName = string.gsub(szMyKinName, "%%", "%%%%");

	szUrl = string.gsub(szUrl, "%$PlatId%$", Sdk:GetLoginPlatId());
	szUrl = string.gsub(szUrl, "%$Area%$", Sdk:GetAreaId());
	szUrl = string.gsub(szUrl, "%$ServerId%$", Sdk:GetServerId());
	szUrl = string.gsub(szUrl, "%$RoleId%$", me.dwID);
	szUrl = string.gsub(szUrl, "%$RoleName%$", szRoleName);
	szUrl = string.gsub(szUrl, "%$KinName%$", szMyKinName);
	szUrl = string.gsub(szUrl, "%$VoteItem%$", nCurCount);
	szUrl = string.gsub(szUrl, "%$openid%$", Sdk:GetUid());
	szUrl = string.gsub(szUrl, "%$job%$", me.nFaction);
	szUrl = string.format("%s&isLoginPC=%d", szUrl, (Sdk:IsPCVersion() and 1) or 0)
	Sdk:OpenUrl(szUrl);
end
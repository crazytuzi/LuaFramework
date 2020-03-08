Require("CommonScript/Activity/KinElect.lua");

local tbAct = Activity.KinElect
local tbActUiSetting = Activity:GetUiSetting("KinElect")
tbActUiSetting.szUiName = "BeautySelection2"
tbActUiSetting.szTitle  = "家族评选"
tbActUiSetting.nShowLevel = tbAct.LEVEL_LIMIT
tbActUiSetting.nShowPriority = 2

tbAct.REFRESH_SIGNUP_FRIEND_INTERVAL = 30

--这里的奖励只用来做界面显示
local tbFirstTime1 = tbAct.STATE_TIME[tbAct.STATE_TYPE.FIRST_1]
local tbFirstTime2 = tbAct.STATE_TIME[tbAct.STATE_TYPE.FIRST_2]
local tbSecondTime1 = tbAct.STATE_TIME[tbAct.STATE_TYPE.SECOND_1]
local tbSecondTime2 = tbAct.STATE_TIME[tbAct.STATE_TYPE.SECOND_2]
local tbThirdTime1 = tbAct.STATE_TIME[tbAct.STATE_TYPE.THIRD_1]
local tbThirdTime2 = tbAct.STATE_TIME[tbAct.STATE_TYPE.THIRD_2]

tbAct.tbShowAward =
{
	{
		szContent = string.format([[
[FFFE0D]「家族评选」[-]活动开始了！各阶段规则请看以下介绍：

[FFFE0D]【报名阶段（初赛）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]等级要求：[-]等级达到[FFFE0D]%d级[-]
[FFFE0D]报名条件：[-]家族族长，且家族等达2级以上[-]
    点击主界面[00ff00]家族评选[-]按钮报名参赛，报名需要上传[FFFE0D]本家族的照片（最多5张）[-]，报名成功后资料会进入待审核状态，如果提交的资料涉及违规，将不会通过审核，需要重新提交资料再次报名。若资料审核通过则表示成功报名参赛，并且会通过邮件给全体家族成员发放[ff8f06][url=openwnd:家族评选宣传单, ItemTips, "Item", nil, 11191][-]，可以通过它打开应援页面。
    [FFFE0D]只有初赛报名时在本家族且发奖时也在本家族的成员，才能在以后的比赛中获得家族相关奖励，建议少侠不要中途更换家族！[-]

[FFFE0D]【比赛阶段（初赛）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]票选对象：[-]本服成功报名参赛的家族
    此阶段，玩家可以通过消耗[FF69B4][url=openwnd:风云徽, ItemTips, "Item", nil, 11120][-]或者[FF69B4][url=openwnd:水月徽, ItemTips, "Item", nil, 11235][-]道具进行投票。[FF69B4][url=openwnd:水月徽, ItemTips, "Item", nil, 11235][-]道具只能投票给本家族且离开家族后将扣除背包内所有该道具。[FFFE0D]每消耗1张，被投家族票数+1[-]。通过该道具可以打开投票页面，或者点击主屏幕的“家族评选”图标进入投票页面。
    [FFFE0D]%s[-]将按票数排名评选出初赛冠军，冠军家族和每个服务器最终获得一定票数以上的家族自动入围[FFFE0D]复赛（跨服评选）[-]。
    [FFFE0D]部分奖励只有领袖和族长才能获得，可点击图标查看详情！[-]

[FFFE0D]初赛奖励[-] ]], Lib:TimeDesc10(tbFirstTime1[1]), Lib:TimeDesc10(tbFirstTime1[2]+1), tbAct.LEVEL_LIMIT, Lib:TimeDesc10(tbFirstTime1[1]), Lib:TimeDesc10(tbFirstTime1[2]+1), Lib:TimeDesc10(tbFirstTime2[2]+1));
		tbAllAward = {
			{
				szTitle = "初赛冠军";
				tbAward = {
					{"Item", 11122, 1},  --雕像
					{"Item", 11029, 1},  --称号
					{"Item", 11139, 1},  --家族红包
					{"Item", 11193, 10},  --家族评选宝箱
					{"Item", 11216, 1},  --称号
				};
			};
			{
				szTitle = "获得复赛资格";
				tbAward = {
					{"Item", 11140, 1},  --家族红包
					{"Item", 11193, 6},  --家族评选宝箱
					{"Item", 11217, 1},  --称号
				};
			};
			{
				szTitle = "获投N票";
				tbAward = {
					{"Item", 11141, 1},  --家族红包
					{"Item", 11193, 5},  --家族评选宝箱
				};
			};
		};
	};

	{
		szContent = string.format([[
[FFFE0D]【报名阶段（复赛）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]等级要求：[-]等级达到[FFFE0D]%d级[-]
[FFFE0D]报名条件：[-]家族族长，且本家族有复赛资格[-]
    点击主界面[00ff00]家族评选[-]按钮报名参赛，报名需要选择一个主题并上传符合该主题的[FFFE0D]家族故事[-]，报名成功后资料会进入待审核状态，如果提交的资料涉及违规，将不会通过审核，需要重新提交资料再次报名。若资料审核通过则表示成功报名参赛，并且会通过邮件给全体成员发送通知。

[FFFE0D]【比赛阶段（复赛）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]票选对象：[-]入围复赛且成功上传作品的家族
    复赛阶段的投票方式与初赛相同[FFFE0D]（可以给跨服的家族投票）[-]。复赛将根据票数选出总冠军和各个主题的前三名，所有获得一定票数以上的家族，都将获得奖励。
    [FFFE0D]雕像、坐骑和世界红包奖励只有领袖可以获得，特殊称号、聊天前缀和头像框领袖和族长可以获得，其余奖励全员均可获得。[-]
    [FFFE0D]复赛各主题的称号和前缀奖励，根据主题不同而不同。这里只展示一类。[-]

[FFFE0D]复赛奖励[-] ]], Lib:TimeDesc10(tbSecondTime1[1]), Lib:TimeDesc10(tbSecondTime1[2]+1), tbAct.LEVEL_LIMIT, Lib:TimeDesc10(tbSecondTime1[1]), Lib:TimeDesc10(tbSecondTime1[2]+1));
		tbAllAward = {
			{
				szTitle = "复赛总冠军";
				tbAward = {
					{"Item", 11123, 1},  --雕像
					{"Item", 10951, 1},  --坐骑
					{"Item", 11132, 1},  --世界红包
					{"Item", 11030, 1},  --称号
					{"Item", 11157, 1},  --前缀
					{"Item", 11019, 1},  --头像框
					{"Item", 11193, 20},  --家族评选宝箱
					{"Item", 11218, 1},  --称号
					{"Item", 11229, 1},  --头像
					{"Item", 9565, 1},  --糖葫芦玩具
				};
			};
			{
				szTitle = "复赛主题冠军";
				tbAward = {
					{"Item", 11124, 1},  --雕像
					{"Item", 11133, 1},  --世界红包
					{"Item", 11031, 1},  --称号
					{"Item", 11158, 1},  --前缀
					{"Item", 11143, 1},  --家族红包
					{"Item", 11019, 1},  --头像框
					{"Item", 11193, 10},  --家族评选宝箱
					{"Item", 11219, 1},  --称号
					{"Item", 11229, 1},  --头像
					{"Item", 9565, 1},  --糖葫芦玩具
				};
			};
			{
				szTitle = "复赛主题三甲";
				tbAward = {
					{"Item", 11134, 1},  --世界红包
					{"Item", 11168, 1},  --前缀
					{"Item", 11144, 1},  --家族红包
					{"Item", 11019, 1},  --头像框
					{"Item", 11193, 6},  --家族评选宝箱
					{"Item", 11220, 1},  --称号
					{"Item", 11229, 1},  --头像
				};
			};
			{
				szTitle = "获投N票";
				tbAward = {
					{"Item", 11145, 1},  --家族红包
					{"Item", 11193, 3},  --家族评选宝箱
					{"Item", 11221, 1},  --称号
				};
			};
		};
	};

	{
		szContent = string.format([[
[FFFE0D]【报名阶段（决赛）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]等级要求：[-]等级达到[FFFE0D]%d级[-]
[FFFE0D]报名条件：[-]家族族长或家族宝贝，且本家族有决赛资格[-]
    点击主界面[00ff00]家族评选[-]按钮报名参赛，报名需要选择嗨歌系统内已上传的作品进行提交，报名成功后资料会进入待审核状态，如果提交的资料涉及违规，将不会通过审核，需要重新提交资料再次报名。若资料审核通过则表示成功报名参赛，并且会通过邮件给全体成员发送通知。

[FFFE0D]【比赛阶段（决赛）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]票选对象：[-]入围决赛且成功上传作品的家族
    决赛阶段的投票方式与初赛相同[FFFE0D]（可以给跨服的家族投票）[-]。决赛将根据票数选出冠军，亚军，季军，十强，所有成功报名决赛的家族，都将获得奖励。
    [FFFE0D]雕像、坐骑和世界红包奖励只有领袖可以获得，特殊称号、聊天前缀和头像框领袖和族长可以获得，其余奖励全员均可获得。[-]

[FFFE0D]决赛奖励[-] ]], Lib:TimeDesc10(tbThirdTime1[1]), Lib:TimeDesc10(tbThirdTime1[2]+1), tbAct.LEVEL_LIMIT, Lib:TimeDesc10(tbThirdTime1[1]), Lib:TimeDesc10(tbThirdTime1[2]+1));
		tbAllAward = {
			{
				szTitle = "决赛冠军";
				tbAward = {
					{"Item", 11125, 1},  --雕像
					{"Item", 10953, 1},  --坐骑
					{"Item", 11135, 1},  --世界红包
					{"Item", 11041, 1},  --称号
					{"Item", 11151, 1},  --前缀
					{"Item", 11146, 1},  --家族红包
					{"Item", 11020, 1},  --头像框
					{"Item", 11193, 30},  --家族评选宝箱
					{"Item", 11222, 1},  --称号
					{"Item", 11230, 1},  --头像
					{"Item", 11231, 1},  --军旗玩具
					{"Item", 11043, 1},  --浮光衣服偏色
					{"Item", 11044, 1},  --浮光头饰偏色
					{"Item", 11045, 1},  --苍澜衣服偏色
					{"Item", 11046, 1},  --苍澜头饰偏色
					{"Item", 11047, 1},  --秋叶流歌衣服偏色
					{"Item", 11048, 1},  --秋叶流歌头饰偏色
					{"Item", 11049, 1},  --翩燕流云衣服偏色
					{"Item", 11050, 1},  --翩燕流云头饰偏色
					{"Item", 11128, 1},  --家族底图
				};
			};
			{
				szTitle = "决赛亚军";
				tbAward = {
					{"Item", 11126, 1},  --雕像
					{"Item", 11136, 1},  --世界红包
					{"Item", 11042, 1},  --称号
					{"Item", 11152, 1},  --前缀
					{"Item", 11147, 1},  --家族红包
					{"Item", 11020, 1},  --头像框
					{"Item", 11193, 20},  --家族评选宝箱
					{"Item", 11223, 1},  --称号
					{"Item", 11230, 1},  --头像
					{"Item", 11231, 1},  --军旗玩具
					{"Item", 11045, 1},  --苍澜衣服偏色
					{"Item", 11046, 1},  --苍澜头饰偏色
					{"Item", 11047, 1},  --秋叶流歌衣服偏色
					{"Item", 11048, 1},  --秋叶流歌头饰偏色
					{"Item", 11049, 1},  --翩燕流云衣服偏色
					{"Item", 11050, 1},  --翩燕流云头饰偏色
					{"Item", 11129, 1},  --家族底图
				};
			};
			{
				szTitle = "决赛季军";
				tbAward = {
					{"Item", 11127, 1},  --雕像
					{"Item", 11137, 1},  --世界红包
					{"Item", 11212, 1},  --称号
					{"Item", 11153, 1},  --前缀
					{"Item", 11148, 1},  --家族红包
					{"Item", 11020, 1},  --头像框
					{"Item", 11193, 10},  --家族评选宝箱
					{"Item", 11224, 1},  --称号
					{"Item", 11230, 1},  --头像
					{"Item", 11231, 1},  --军旗玩具
					{"Item", 11047, 1},  --秋叶流歌衣服偏色
					{"Item", 11048, 1},  --秋叶流歌头饰偏色
					{"Item", 11049, 1},  --翩燕流云衣服偏色
					{"Item", 11050, 1},  --翩燕流云头饰偏色
					{"Item", 11130, 1},  --家族底图
				};
			};
			{
				szTitle = "决赛十强";
				tbAward = {
					{"Item", 11138, 1},  --世界红包
					{"Item", 11213, 1},  --称号
					{"Item", 11154, 1},  --前缀
					{"Item", 11020, 1},  --头像框
					{"Item", 11193, 6},  --家族评选宝箱
					{"Item", 11225, 1},  --称号
					{"Item", 11230, 1},  --头像
					{"Item", 11049, 1},  --翩燕流云衣服偏色
					{"Item", 11050, 1},  --翩燕流云头饰偏色
					{"Item", 11131, 1},  --家族底图
				};
			};
			{
				szTitle = "保底奖励";
				tbAward = {
					{"Item", 11150, 1},  --家族红包
					{"Item", 11193, 3},  --家族评选宝箱
					{"Item", 11226, 1},  --称号
				};
			};
		};
	};
}

function tbAct:OnLogout()
	self.nSignUpTimeOut = 0
end

function tbAct:IsShowMainButton()
	if not self.bShowBtn then
		return false
	end
	if not me or me.nLevel < self.LEVEL_LIMIT then
		return false
	end

	return true
end

function tbAct:SyncIsSignUp(nSignUpTimeOut)
	self.nSignUpTimeOut = nSignUpTimeOut
end

function tbAct:IsSignUp()
	return self.nSignUpTimeOut and GetTime() < self.nSignUpTimeOut
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
	local bHaveAward = NewInformation.tbCustomCheckRP.fnKinElectCheckRp()
	if bHaveAward then
		Activity:CheckRedPoint();
		NewInformation:CheckRedPoint();
	end
	--最新消息的次级界面需要带上EventId做参数
	UiNotify.OnNotify(UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD, UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD, bHaveAward)
end

function tbAct:OnSynMiniMainMapInfo()
	local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
	for i,v in ipairs(tbMapTextPosInfo) do
		if v.Index == "KinElect_diaoxiang" then
			v.Text = "家族评选冠军" ;
		end
	end
end

function tbAct:DoOpenKinElectPaperUrl(szUrl)
	local nCurCount = me.GetItemCountInAllPos(Activity.KinElect.VOTE_ITEM)
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
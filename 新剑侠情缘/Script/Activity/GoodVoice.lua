local tbAct = Activity.GoodVoice

local tbActUiSetting = Activity:GetUiSetting("GoodVoice")
tbActUiSetting.szUiName = "GoodVoiceSelection"
tbActUiSetting.szTitle  = "剑侠好声音评选"
tbActUiSetting.nShowLevel = tbAct.LEVEL_LIMIT
tbActUiSetting.nShowPriority = 2

tbAct.REFRESH_SIGNUP_FRIEND_INTERVAL = 30
tbAct.REFRESH_UNSIGNUP_FRIEND_INTERVAL = 30
-- 展示奖励
-- 海选阶段
tbAct.szLocalContent =[[
[FFFE0D]「剑侠好声音」[-]海选活动开始了！各阶段规则请看以下介绍：

[FFFE0D]【报名阶段】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]等级要求：[-]等级达到[FFFE0D]%d级[-]
    前往襄阳或临安城[00ff00] [url=npc:「好声音使者」纳兰真, 90, 15][-]处报名参赛，少侠也可推荐自己的好友参赛。报名需要上传[FFFE0D]本人录制的声音作品[-]，报名成功后会进入待审核状态，如果提交的资料涉及违规，将不会通过审核，需要重新提交资料再次报名。若资料审核通过则表示成功报名参赛，并且会通过邮件发放[ff8f06][url=openwnd:好声音宣传册·海选赛, ItemTips, "Item", nil, 7707][-]，可以通过它在任意聊天频道宣传本人的参赛信息，或打开自己的参赛页面。

[FFFE0D]【海选赛（本服评选）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]票选对象：[-]本服成功报名参赛的选手
    玩家可以通过消耗[FF69B4][url=openwnd:桃花笺, ItemTips, "Item", nil, 7537][-]道具给心目中的好声音进行投票。[FFFE0D]每消耗1个，被投作品票数+1[-]。通过该道具可以打开投票页面，或者点击主屏幕的“剑侠好声音”图标进入投票页面。
    [FFFE0D]5月5日23点59分[-]投票通道将关闭，进入海选结果复核阶段，[FFFE0D]5月7日12点[-]前将公布海选结果并按票数排名评选出海选赛[FFFE0D]10[-]强，奖励将在3个工作日内发放。票数排名[FFFE0D]前5[-]或得票数超过[FFFE0D]10000[-]的玩家将晋级全服[FFFE0D]复赛[-]，并且海选赛阶段票数[FFFE0D]清零[-]，票数从复赛开始重新计算。
    [00FF00][url=openwnd:查看【桃花笺】获得途径, AttributeDescription, '', false, 'GoodVoiceVote'][-]

[FFFE0D]海选赛奖励[-] ]]
tbAct.tbLocalShowAward = {
	[1] =  --海选第一
	{
		szTitle = "海选第一";
		tbAward = 
		{
			{"Item", 7733, 1},  --雕像
			{"Item", 7721, 1},  --特殊称号&特效
			{"Item", 7726, 1},  --聊天前缀
			{"Item", 7728, 1},  --聊天泡泡1
			{"Item", 7729, 1},  --聊天泡泡2
			{"Item", 7730, 1},  --坐骑外装
			{"Item", 7736, 1},  --头像
			{"Item", 4856, 1},  --世界红包
			{"Item", 4852, 1},  --家族红包
		};
		
	},

	[2] =  --海选前十
	{
		szTitle = "海选前十";
		tbAward = 
		{
			{"Item", 7720, 1},  --特殊称号&特效
			{"Item", 7725, 1},  --聊天前缀
			{"Item", 7736, 1},  --头像
			{"Item", 7728, 1},  --聊天泡泡1
			{"Item", 4853, 1},  --家族紅包
		};
	},

	[3] =  --获投199票
	{
		szTitle = "获投199票";
		tbAward = 
		{
			{"Item", 7719, 1},  --特殊称号&特效
			{"Item", 7724, 1},  --聊天前缀
			{"Item", 7735, 1},  --头像
			{"Item", 6535, 3},  --5000元气真气贡献任选
			{"Item", 4854, 1},  --家族紅包
		};
	},
}

-- 复赛阶段
tbAct.szSemiFinalContent = [[
[FFFE0D]「剑侠好声音」[-]复赛即将开始！详细规则请看以下介绍：

[FFFE0D]【复赛（全服评选）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]票选对象：[-]成功晋级全服复赛的选手
    玩家可以通过消耗[FF69B4][url=openwnd:桃花笺, ItemTips, "Item", nil, 7537][-]道具给心目中的好声音进行投票。[FFFE0D]每消耗1个，被投作品票数+1[-]。通过该道具可以打开投票页面，或者点击主屏幕的“剑侠好声音”图标进入投票页面。参赛玩家获投520票、1600票与2800票时，其所在区服的所有家族属地在19：18会下起浪漫桃花雨，拾取桃花瓣后能获得额外奖励哦！让我们继续为好声音选手加油呐喊吧！
    复赛为全服票选阶段，选手晋级复赛后，海选得票数清零，作品重新展开投票。除主赛场外，复赛增设地域分赛场与门派分赛场为君助威，各位少侠的参赛作品可同时竞艺主赛场与分赛场。分赛场与主赛场票数互通，采用同个投票通道，分赛场名次只与分赛场特别奖项有关，与晋级无关。（玩家可以同时获得总榜、区域与门派奖励哦。）
    
    地域分赛场：
    地域分赛场将以玩家报名时填写的省份归属地域进行划分，与各位同乡展开激烈的地域好声音之战，最终根据票数排名角出区域前三名。地域划分范围如下：
    1、华东地区（包括山东、江苏、安徽、浙江、福建、上海、江西）；
    2、华南地区（包括广东、广西、海南）； 
    3、华中地区（包括湖北、湖南、河南）； 
    4、华北地区（包括北京、天津、河北、山西、内蒙古）； 
    5、西北地区（包括宁夏、新疆、青海、陕西、甘肃）； 
    6、西南地区（包括四川、云南、贵州、西藏、重庆）；
    7、东北地区（包括辽宁、吉林、黑龙江）； 
    8、港澳台地区（包括台湾、香港、澳门）。 

    门派分赛场：
    门派分赛场将以少侠报名时的门派为准进行划分，与同门派的师兄妹同台献声竞艺，最终根据票数排名角出本门派的前三名。

    [FFFE0D]%s[-]投票通道将关闭，进入复赛结果复核阶段，[FFFE0D]%s[-]前将公布复赛结果并按票数排名评选[FFFE0D]总榜冠军、区域前三、门派前三[-]，奖励将在3个工作日内发放。总榜排行前[FFFE0D]100名[-]选手进入全服决赛，并且复赛阶段票数[FFFE0D]清零[-]，票数从决赛开始重新计算。
    [00FF00][url=openwnd:查看【桃花笺】获得途径, AttributeDescription, '', false, 'GoodVoiceVote'][-]

[FFFE0D]好声音复赛奖励[-] ]]
tbAct.tbSemiFinalShowAward = {
	[1] =  --复赛第一
	{
		szTitle = "复赛冠军";
		tbAward = 
		{
			{"Item", 7892, 1},  --雕像
			{"Item", 7750, 1},  --称号·声动四海
			{"Item", 7807, 1},  --聊天前缀
			{"Item", 7740, 1},  --<幽炎·螭魅雪狐>坐骑时装·1年
			{"Item", 7868, 1},  --家族红包·复赛冠军
			{"Item", 7874, 1},  --世界红包·复赛冠军
		};
	},

	[2] =  --复赛区域冠军
	{
		szTitle = "复赛区域冠军";
		tbAward = 
		{
			{"Item", 7892, 1},  --雕像
			{"Item", 7884, 1},  --称号·(区域)最强声
			{"Item", 7888, 1},  --前缀·(区域)最强声
			{"Item", 7877, 1},  --头像框·全服三大声音
			{"Item", 7737, 1},  --好声音复赛前三人物绘卷
			{"Item", 7858, 1},  --家具·音乐盒
			{"Item", 7866, 1},  --家族红包·复赛区域冠军
			{"Item", 7872, 1},  --世界红包·复赛区域冠军
		};
	},
	[3] =  --复赛门派冠军
	{
		szTitle = "复赛门派冠军";
		tbAward = 
		{
			{"Item", 7892, 1},  --雕像
			{"Item", 7886, 1},  --称号·(门派)最强声
			{"Item", 7890, 1},  --前缀·(门派)最强声
			{"Item", 7877, 1},  --头像框·全服三大声音
			{"Item", 7737, 1},  --好声音复赛前三人物绘卷
			{"Item", 7858, 1},  --家具·音乐盒
			{"Item", 7867, 1},  --家族红包·复赛门派冠军
			{"Item", 7873, 1},  --世界红包·复赛门派冠军
		};
	},

	[4] =  --复赛区域前三
	{
		szTitle = "复赛区域亚军季军";
		tbAward = 
		{
			{"Item", 7885, 1},  --称号·(区域)好声音
			{"Item", 7889, 1},  --前缀·(区域)好声音
			{"Item", 7737, 1},  --好声音复赛前三人物绘卷
			{"Item", 7858, 1},  --家具·音乐盒
			{"Item", 7864, 1},  --家族红包·复赛区域前三
			{"Item", 7870, 1},  --世界红包·复赛区域前三
			{"Item", 6535, 2},  --5000元气真气贡献任选
		};
	},
	[5] =  --复赛门派前三
	{
		szTitle = "复赛门派亚军季军";
		tbAward = 
		{
			{"Item", 7887, 1},  --称号·(门派)好声音
			{"Item", 7891, 1},  --前缀·(门派)好声音
			{"Item", 7737, 1},  --好声音复赛前三人物绘卷
			{"Item", 7858, 1},  --家具·音乐盒
			{"Item", 7865, 1},  --家族红包·复赛门派前三
			{"Item", 7871, 1},  --世界红包·复赛门派前三
			{"Item", 6535, 2},  --5000元气真气贡献任选
		};
	},

	[6] =  --复赛8000票
	{
		szTitle = "复赛8000票";
		tbAward = 
		{
			{"Item", 7744, 1},  --称号·金声玉色
			{"Item", 7801, 1},  --前缀·金声玉色
			{"Item", 7858, 1},  --家具·音乐盒
			{"Item", 7863, 1},  --家族红包·复赛获投8000票
			{"Item", 7869, 1},  --世界红包·复赛获投8000票
			{"Item", 6535, 4},  --5000元气真气贡献任选
		};
	},
}

-- 决赛阶段
tbAct.szFinalContent = [[
[FFFE0D]「剑侠好声音」[-]决赛即将开始！详细规则请看以下介绍：

[FFFE0D]【决赛（全服评选）】[-]
[FFFE0D]阶段时间：[-]%s ~ %s
[FFFE0D]票选对象：[-]成功晋级决赛的选手
    玩家可以通过消耗[FF69B4][url=openwnd:桃花笺, ItemTips, "Item", nil, 7537][-]道具给心目中的好声音进行投票。[FFFE0D]每消耗1个，被投作品票数+1[-]。通过该道具可以打开投票页面，或者点击主屏幕的“剑侠好声音”图标进入投票页面。
    选手晋级决赛后，投票通道重新开启，复赛得票数清零。此阶段开启各位声音大咖的终极对决，选手也将代表各自导师战队争夺第一，获胜选手所在的战队将获得丰富奖励。同时决赛更新短视频上传功能，决赛选手可以在参赛页视频上传入口上传本地短视频，展示更多风采。
    [FFFE0D]%s[-]投票通道将关闭，进入决赛结果复核阶段，[FFFE0D]%s[-]前将公布决赛结果并按票数排名评选[FFFE0D]决赛十强[-]。进入决赛的所有玩家均会获得好声音大会送上的[aa62fc][url=openwnd:5000真气元气贡献任选礼盒, ItemTips, "Item", nil, 6535]10份[-]，冠军所属战队的所有玩家会获得对应的[aa62fc][url=openwnd:称号·新星之声, ItemTips, "Item", nil, 7752][-][aa62fc][url=openwnd:称号·声之丽颖, ItemTips, "Item", nil, 7751][-]与[aa62fc][url=openwnd:5000真气元气贡献任选礼盒, ItemTips, "Item", nil, 6535]4份[-]，并且决赛前三甲所在服务器的所有玩家均会获得奖励一份，所有奖励将在3个工作日内发放。
    [00FF00][url=openwnd:查看【桃花笺】获得途径, AttributeDescription, '', false, 'GoodVoiceVote'][-]

[FFFE0D]决赛奖励[-] ]]
tbAct.tbFinalShowAward = {
	[1] =  --决赛第一
	{
		szTitle = "决赛冠军";
		tbAward = 
		{
			{"Item", 7894, 1},  --雕像
			{"Item", 7749, 2},  --称号·仙籁之音
			{"Item", 7806, 1},  --前缀·仙籁之音
			{"Item", 7897, 1},  --冠军宝箱
			{"Item", 7738, 1},  --好声音决赛十强人物绘卷
			{"Item", 7739, 1},  --好声音冠军人物绘卷
			{"Item", 7861, 1},  --古琴
			{"Item", 7862, 1},  --小波斯
			{"Item", 7896, 1},  --大宋专辑制作资格
			{"Item", 7895, 1},  --签名照
		};
	},

	[2] =  --决赛第二
	{
		szTitle = "决赛亚军";
		tbAward = 
		{
			{"Item", 7894, 1},  --雕像
			{"Item", 7748, 2},  --称号·凤凰之鸣
			{"Item", 7805, 1},  --前缀·凤凰之鸣
			{"Item", 7898, 1},  --亚军宝箱
			{"Item", 7738, 1},  --好声音决赛十强人物绘卷
			{"Item", 7861, 1},  --古琴
			{"Item", 7456, 1},  --小黑猫
			{"Item", 7896, 1},  --大宋专辑制作资格
			{"Item", 7895, 1},  --签名照
		};
	},

	[3] =  --决赛季军
	{
		szTitle = "决赛季军";
		tbAward = 
		{
			{"Item", 7894, 1},  --雕像
			{"Item", 7747, 2},  --称号·珠玉之声
			{"Item", 7804, 1},  --前缀·珠玉之声
			{"Item", 7899, 1},  --季军宝箱
			{"Item", 7738, 1},  --好声音决赛十强人物绘卷
			{"Item", 7861, 1},  --古琴
			{"Item", 7456, 1},  --小黑猫
			{"Item", 7896, 1},  --大宋专辑制作资格
			{"Item", 7895, 1},  --签名照
		};
	},

	[4] =  --决赛4-10名
	{
		szTitle = "决赛4-10名";
		tbAward = 
		{
			{"Item", 7746, 2},  --称号·曼声清扬
			{"Item", 7803, 1},  --前缀·曼声清扬
			{"Item", 7877, 1},  --头像框·全服十大声音
			{"Item", 7738, 1},  --好声音决赛十强人物绘卷
			{"Item", 7456, 1},  --小黑猫
			{"Item", 4857, 1},  --世界红包·决赛十强
			{"Item", 4870, 1},  --家族红包·决赛十强
		};
	},
}

-- 粉丝榜奖励最新消息
tbAct.szFansContent = [[
[FFFE0D]「剑侠好声音」[-]评选期间（%s~%s），全阶段累计赠送[FF69B4][url=openwnd:桃花笺, ItemTips, "Item", nil, 7537][-]总数在[FFFE0D]粉丝榜前十[-]所获得的奖励。

[FFFE0D]好声音粉丝榜奖励[-] ]]
tbAct.tbFansShowAward = {
	[1] =  --粉丝榜第一
	{
		szTitle = "粉丝榜第1名";
		tbAward = 
		{
			{"Item", 7860, 1},  --家具·鼓
			{"Item", 7937, 1},  --定制称号
			{"Item", 7938, 1},  --定制前缀
			{"Item", 7727, 1},  --头像框·七彩音符
		};
		
	},

	[2] =  --粉丝榜前十
	{
		szTitle = "粉丝榜第2~10名";
		tbAward = 
		{
			{"Item", 7860, 1},  --家具·鼓
			{"Item", 7723, 1},  --称号·人间难得是知音
			{"Item", 7732, 1},  --前缀·头号知音
			{"Item", 7727, 1},  --头像框·七彩音符
		};
	},
}


function tbAct:GetNewInfoShowData(tbData)
	local nNowTime = GetTime()
	local tbSignUpTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.SIGN_UP]
	local tbLocalTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.LOCAL]
	local tbSemiFinalTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.SEMI_FINAL]
	local tbSemiFinalRestTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.SEMI_FINAL_REST]
	local tbFinalTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.FINAL]
	local tbFinalRestTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.FINAL_REST]
	tbData = tbData or {}
	local szKey = tbData.szKey or ""
	if szKey == self.szNewInfoFansKey then
		return string.format(self.szFansContent, Lib:TimeDesc17(tbLocalTime[1]), Lib:TimeDesc17(tbFinalTime[2])), self.tbFansShowAward
	end
	
	local szContent = string.format(self.szLocalContent, Lib:TimeDesc17(tbSignUpTime[1]), Lib:TimeDesc17(tbSignUpTime[2]), tbAct.LEVEL_LIMIT, Lib:TimeDesc17(tbLocalTime[1]), Lib:TimeDesc17(tbLocalTime[2]), Lib:TimeDesc17(tbLocalTime[2]+1))
	local nCurState = self:GetCurState();
	local tbAward = self.tbLocalShowAward
	if nCurState == self.STATE_TYPE.SEMI_FINAL or 
		nCurState == self.STATE_TYPE.SEMI_FINAL_REST then

		szContent = string.format(self.szSemiFinalContent, Lib:TimeDesc17(tbSemiFinalTime[1]), Lib:TimeDesc17(tbSemiFinalTime[2]), Lib:TimeDesc17(tbSemiFinalTime[2]), Lib:TimeDesc17(tbSemiFinalRestTime[2]))
		tbAward = self.tbSemiFinalShowAward
	elseif nCurState == self.STATE_TYPE.FINAL or 
		nCurState == self.STATE_TYPE.FINAL_REST or
		nNowTime >= self.STATE_TIME[self.STATE_TYPE.FINAL_REST][2] then
		
		szContent = string.format(self.szFinalContent, Lib:TimeDesc17(tbFinalTime[1]), Lib:TimeDesc17(tbFinalTime[2]), Lib:TimeDesc17(tbFinalTime[2]), Lib:TimeDesc17(tbFinalRestTime[2]))
		tbAward = self.tbFinalShowAward
	end
	return szContent, tbAward
end

function tbAct:MainEnter()
	Pandora:OpenGoodVoiceMain()
end

function tbAct:SingUpEnter()
	Pandora:OpenGoodVoiceSignUp()
end

function tbAct:PlayerPageEnter(tbParams)
	Pandora:OpenGoodVoicePlayerPage(tbParams)
end

function tbAct:IsSignUp()
	return self.nSignUpTimeOut and GetTime() < self.nSignUpTimeOut
end

function tbAct:SyncIsSignUp(nSignUpTimeOut)
	self.nSignUpTimeOut = nSignUpTimeOut
end

function tbAct:SyncSignUpFriendList(tbList)
	self.tbSignUpFriendList = {}
	for _,v in ipairs(tbList) do
		self.tbSignUpFriendList[v[1]] = v[2]
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_BEAUTY_FRIEND_LIST)
end

function tbAct:SyncUnSignUpFriendList(tbList)
	self.tbUnSignUpFriendList = {}
	for _,nPlayerId in ipairs(tbList) do
		self.tbUnSignUpFriendList[nPlayerId] = 1
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_BEAUTY_FRIEND_LIST)
end

function tbAct:GetSignUpFriendList()
	return self.tbSignUpFriendList or {}
end

function tbAct:GetUnSignUpFriendList()
	return self.tbUnSignUpFriendList or {}
end

function tbAct:RequestRecommend(nPlayerId)
	RemoteServer.GoodVoiceRecommondReq(nPlayerId);
end

function tbAct:DoRecommend()
	Ui:OpenWindow("BeautyCompetitionPanel", Ui:GetClass("BeautyCompetitionPanel").TYPE_GOODVOICE_RECOMMOND)
end

function tbAct:CheckPlayerData(pPlayer)
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

	RemoteServer.SendGoodVoiceChannelMsg(nType, nParam);
end

function tbAct:OnRefreshVotedAward()
	local bHaveAward = NewInformation.tbCustomCheckRP.fnGoodVoiceRewardCheckRp()
	if bHaveAward then
		Activity:CheckRedPoint();
		NewInformation:CheckRedPoint();
	end
	--最新消息的次级界面需要带上EventId做参数
	UiNotify.OnNotify(UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD, UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD, bHaveAward)
end

function tbAct:RequestSignUpFriend()
	local nNow = GetTime();
	self.nLastSyncSignUpFriend = self.nLastSyncSignUpFriend or 0;
	if (nNow - self.nLastSyncSignUpFriend) >= self.REFRESH_SIGNUP_FRIEND_INTERVAL then
		self.nLastSyncSignUpFriend = nNow;
		RemoteServer.GoodVoiceSignUpFriendReq();
	end
end

function tbAct:RequestUnSignUpFriend()
	local nNow = GetTime();
	self.nLastSyncUnSignUpFriend = self.nLastSyncUnSignUpFriend or 0;
	if (nNow - self.nLastSyncUnSignUpFriend) >= self.REFRESH_UNSIGNUP_FRIEND_INTERVAL then
		self.nLastSyncUnSignUpFriend = nNow;
		RemoteServer.GoodVoiceUnSignUpFriendReq();
	end
end

function tbAct:SyncFurnitureAwardFrame(szFrame)
	self.szFurnitureAwardFrame = szFrame
end

function tbAct:GetFurnitureAwardFrame()
	return self.szFurnitureAwardFrame
end

function tbAct:OnSynMiniMainMapInfo(bRankStatue, bAreaStatue, bFactionStatue)
	local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
	for i,v in ipairs(tbMapTextPosInfo) do
		if bRankStatue and v.Index == "GoodVoice_Normal" then
			v.Text = "好声音正赛冠军" ;
		end
		if bAreaStatue and v.Index == "GoodVoice_Area" then
			v.Text = "好声音区域冠军" ;
		end
		if bFactionStatue and v.Index == "GoodVoice_Faction" then
			v.Text = "好声音门派冠军" ;
		end
	end
end

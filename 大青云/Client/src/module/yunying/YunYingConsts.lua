--[[
运营活动常量
lizhuangzhuang
2015年5月14日14:25:44
]]

_G.YunYingConsts = {};

--运营活动
YunYingConsts.BT_Phone = 1;--手机绑定
YunYingConsts.BT_MClient = 2;--微端奖励
YunYingConsts.BT_VPlan = 3;--V计划
YunYingConsts.BT_MClientD = 4;--微端下载
YunYingConsts.BT_QQReward = 5;--QQ群礼包
YunYingConsts.BT_WeekSign = 6;--七日登录
YunYingConsts.BT_DoubleWeekSign = 7;--双周登录
YunYingConsts.BT_QiHooQuick = 8;--360加速球
YunYingConsts.BT_Wishi360 = 9;--360卫士
YunYingConsts.BT_Youxi360 = 10;--360游戏大厅

YunYingConsts.BT_operActivity1 = 11;--首冲
YunYingConsts.BT_operActivity2 = 12;--每日首冲
YunYingConsts.BT_operActivity3 = 13;--活动1
YunYingConsts.BT_operActivity4 = 14;--活动2
YunYingConsts.BT_VIP = 15;--VIP
YunYingConsts.BT_operActivity5 = 16;--活动2
YunYingConsts.BT_operActivity6 = 17;--活动2
YunYingConsts.BT_WishiQuick360 = 18;--360卫士特权加速礼包
YunYingConsts.BT_ShunwangVip = 19;--顺网vip接口
YunYingConsts.BT_ShunwangReward = 20;--顺网vip奖励接口
YunYingConsts.BT_FeihuoVip = 21;--顺网vip奖励接口
YunYingConsts.BT_XunleiVip = 22; --迅雷vip
YunYingConsts.BT_XunleiPhone = 23; -- 迅雷手机
YunYingConsts.BT_DuowanBaifuAct = 24; -- 多玩百服盛典
YunYingConsts.BT_SougouVip = 25; -- 搜狗vip
YunYingConsts.BT_SougouYouxi = 26; -- 搜狗游戏大厅
YunYingConsts.BT_SougouSkin = 27; -- 搜狗皮肤
YunYingConsts.BT_37wan = 28; -- 37Wan
YunYingConsts.BT_FeihuoPhone = 29; -- 飞火手机绑定
YunYingConsts.BT_KugouVip = 30; -- 酷狗vip会员
YunYingConsts.BT_YXLaXin = 31; -- 老拉新
YunYingConsts.BT_Christmas = 32; -- 圣诞
YunYingConsts.BT_GirlTV = 33;--美女直播
YunYingConsts.BT_PhoneHelp = 34;--手机助手
YunYingConsts.BT_YXTianjiang = 35 --天降惊喜。wan
YunYingConsts.BT_operActivity7 = 36 --活动2
YunYingConsts.BT_operActivity8 = 37 --等级投资
YunYingConsts.BT_operActivity9 = 38 --战力投资
YunYingConsts.BT_DominateRoute = 39 -- 紫装副本
YunYingConsts.BT_WanChannelReward = 40 -- wan平台指定渠道领取特定奖励


--按钮位置(相对位置,从左向右排列)
YunYingConsts.BtnPosMap = {
	[1] = {
		--联运的特权图标都放在左边
		YunYingConsts.BT_Christmas,
		YunYingConsts.BT_ShunwangVip,
		YunYingConsts.BT_ShunwangReward,
		YunYingConsts.BT_FeihuoVip,
		YunYingConsts.BT_XunleiVip,
		YunYingConsts.BT_XunleiPhone,
		YunYingConsts.BT_DuowanBaifuAct,
		YunYingConsts.BT_SougouVip,
		YunYingConsts.BT_SougouYouxi,
		YunYingConsts.BT_SougouSkin,
		YunYingConsts.BT_37wan,
		YunYingConsts.BT_FeihuoPhone,
		YunYingConsts.BT_KugouVip,
	
		---------------------
		YunYingConsts.BT_PhoneHelp,
		YunYingConsts.BT_GirlTV,
		YunYingConsts.BT_YXLaXin,
		YunYingConsts.BT_VPlan,
		YunYingConsts.BT_MClientD,
		YunYingConsts.BT_Phone,
		YunYingConsts.BT_WeekSign,
		YunYingConsts.BT_DoubleWeekSign,
		YunYingConsts.BT_QiHooQuick,
		YunYingConsts.BT_Wishi360,
		YunYingConsts.BT_Youxi360,
		YunYingConsts.BT_WanChannelReward,   --wan
		YunYingConsts.BT_WishiQuick360,
		YunYingConsts.BT_operActivity2,
		YunYingConsts.BT_operActivity3,
		YunYingConsts.BT_operActivity4,
		YunYingConsts.BT_operActivity6,
		YunYingConsts.BT_operActivity7,
		YunYingConsts.BT_operActivity5,
		YunYingConsts.BT_operActivity8,
		YunYingConsts.BT_operActivity9,
		YunYingConsts.BT_operActivity1,
		YunYingConsts.BT_YXTianjiang,
		YunYingConsts.BT_MClient,
		YunYingConsts.BT_VIP,
		YunYingConsts.BT_DominateRoute,
		YunYingConsts.BT_QQReward,
	},
	[2] = {}
};




--运营活动奖励类型
--处理通用奖励是否领取协议用
YunYingConsts.RT_Phone = 1;--手机绑定
YunYingConsts.RT_MClient = 2;--微端奖励
YunYingConsts.RT_360Speed = 3;--360加速球
YunYingConsts.RT_MCIsFirstCharge = 4;--是否充值
YunYingConsts.RT_TitleZiTao = 5;--黄子韬称号
YunYingConsts.RT_TitleYangMi = 6;--杨幂称号
YunYingConsts.RT_602 = 7;--602特权
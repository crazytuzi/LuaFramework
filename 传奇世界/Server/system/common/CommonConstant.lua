
--下载有礼
DOWNLOAD_ALREADY = -3 --该奖励已领取
DOWNLOAD_NOSLOT	 = -1 --背包空间不足

--支付记录
MAX_PAY_RECORD = 20

CURRENCY_INGOT = 1
CURRENCY_BINDINGOT = 2

--镖车数据
local dart_record = require "data.DartDB"

DART_NEED_LEVEL 			= 	dart_record[1].q_need_level		-- 镖车参与等级
DART_MAX_TIMES 				=	dart_record[1].q_times			-- 镖车最大次数

SYSTEM_DART_SWITCH = true


TEAMTYPE = {
	SINGLE = 1,
	TEAM = 2
}
--镖车发车间隔时间
SINGLETIME = 5
--TEAMTIME = 3* 60
TEAM_RELEASE_TIME = 10 *60 --队伍在一定时候后自动解散
DART_MOVE_SPEED = 40	--镖车最大移动速度
DART_CHECK_AROUND = 9   --镖车周边检测范围
DART_SURVIVE_TIME = 30 * 60 --镖车最大存活时间

TEAM_DART_INVITE_TIME = 30			-- 镖车邀请时间限制


-- 镖车移动坐标

DART_RUNING_POSITION = {
			{ x = 193 , y = 32 }, { x = 189 , y = 36 }, { x = 185 , y = 40 }, { x = 181 , y = 44 }, { x = 177 , y = 48 }, { x = 173 , y = 44 }, { x = 169 , y = 40 }, 
			{ x = 165 , y = 40 }, { x = 161 , y = 40 }, { x = 157 , y = 36 }, { x = 153 , y = 32 }, { x = 149 , y = 32 }, { x = 145 , y = 32 }, { x = 141 , y = 28 }, 
			{ x = 137 , y = 28 }, { x = 133 , y = 32 }, { x = 129 , y = 36 }, { x = 125 , y = 36 }, { x = 121 , y = 36 }, { x = 117 , y = 36 }, { x = 113 , y = 36 }, 
			{ x = 109 , y = 40 }, { x = 105 , y = 44 }, { x = 101 , y = 48 }, { x = 97 , y = 52 }, { x = 93 , y = 56 }, { x = 89 , y = 60 }, { x = 85 , y = 64 },
			{ x = 81 , y = 68 }, { x = 77 , y = 72 }, { x = 73 , y = 76 }, { x = 69 , y = 80 }, { x = 65 , y = 84 }, { x = 61 , y = 84 }, { x = 57 , y = 84 }, 
			{ x = 53 , y = 88 }, { x = 49 , y = 92 }, { x = 45 , y = 96 }, { x = 41 , y = 100}, { x = 37 , y = 104 }, { x = 33 , y = 108 }, { x = 29 , y = 112 }, 
			{ x = 25 , y = 112 }, { x = 21 , y = 112 }, { x = 17 , y = 116 }, { x = 13 , y = 120 }, { x = 13 , y = 124 }, { x = 13 , y = 128 }, { x = 13 , y = 132 }, 
			{ x = 17 , y = 136 }, { x = 21 , y = 140 }, { x = 25 , y = 144 }, { x = 29 , y = 148 }, { x = 33 , y = 152 }, { x = 37 , y = 156 }, { x = 41 , y = 160 }, 
			{ x = 45 , y = 164 }, { x = 49 , y = 168 }, { x = 53 , y = 172 }, { x = 57 , y = 176 }, { x = 61 , y = 180 }, { x = 65 , y = 184 }, { x = 69 , y = 188 }, 
            { x = 73 , y = 192 }, { x = 77 , y = 192 }, { x = 81 , y = 192 }, { x = 85 , y = 192 }, { x = 89 , y = 192 }, { x = 93 , y = 192 }, { x = 97 , y = 189 },
}

--[[
DART_RUNING_POSITION = {
	{x = 193, y = 32}, {x = 179, y = 46}, {x = 155, y = 32}, {x = 138, y = 36}, {x = 118, y = 40},  {x = 103, y = 50}, {x = 76, y = 76}, {x = 54, y = 89}, {x = 33, y = 99}, {x = 13, y = 128}, {x = 89, y = 207}, {x = 97, y = 189}
}
]]

-- 镖车移动方向
DART_RUNING_STEP = {5, 5, 5, 5, 5, 5, 4, 3, 3, 3, 3, 4, 4, 3, 4, 4, 3, 4, 5, 4, 4, 
					4, 5, 5, 5, 
					4, 5, 5, 4,
					5, 5, 5, 5, 5, 4, 5, 
					5, 5, 5, 4, 5, 5, 4, 6, 6, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, }

DART_RUNING_LEN = 4	-- 镖车每次运行长度



DART_ERR_TRAILER = 42	-- 镖车预告

--天山雪莲
TIANSHAN_XUELIAN_LEVEL=25
TIANSHAN_XUELIAN_BUFF=404

--客户端提示表信息
-------------------------------------------------------------------
DART_ITEMS_NOT_ENOUGTH_1 =-3--您的青铜行镖令数量不足，无法进行发起青铜镖车！
DART_ITEMS_NOT_ENOUGTH_2 =-4--您的白银行镖令数量不足，无法进行发起白银镖车！
DART_ITEMS_NOT_ENOUGTH_3 =-5--您的黄金行镖令数量不足，无法进行发起黄金镖车！
	
DART_TIMES_VALID 	= -6	-- 您的镖车护送次数已用完，明天再来吧！	
DART_NOT_TIME 		= -7	-- 当前不在镖车护送时间，无法进行护送！	
DART_TEAM_TIME		= -8	-- 您已成功加入集体镖车的护送，镖车%d秒后开始发车！	
DART_SUCCESS		= -9	-- 您的镖车已护送至目的地，请到镖师处领取奖励！	
DART_FAILD			= -10	-- 	您的镖车已破碎，请至镖车处领取补偿奖励！	
DART_PICK_REWARD	= -11	-- 	请领取护镖奖励后，再来发起新的镖车护送！

DART_TEAM_FULLY	    = -12	--该队护镖队伍已满，请选择加入其他队伍！
DART_TEAM_ALREADY_SEND = -13	--您参与集体护镖已经开始护送，请前往加入护送！
DART_GET_REWARD		= -14		--您成功领取了镖车护送的奖励，获得%d点经验！
DART_NOT_REWARD	    = -15		--您当前没有可以领取的奖励！
DART_RELEASE_TEAM   = -16		--您参加的镖车已被解散，请至邮箱领取镖车令牌！
--DART_TEAM_FULLY-17		--您参加的镖车人数已满，即将开始护送，请前往护送．
DART_LEAVE_TEAM	    = -18		--您已经成功退出镖车队伍！
DART_ROLE_LEAVE_TEAM     = -19	  --%s退出镖车队伍！
DART_NOT_QUIT 			= -20     --您的镖车即将发车，不能退出！
DART_SINGLE_ALREADY_SEND = -21    -- 您的镖车即将发车，请前往护送．
DART_ROLE_JOIN_TEAM		= -22	  -- %s加入镖车队伍，当前镖车人数%s．

DART_TEAM_MEMBER_CAN_NOT_DART = -24	  -- 队员不能发起组队运镖
DART_TEAM_MEMBER_LEVEL_CAN_NOT_DART = -25	  -- 队伍成员%s等级不足，不能发起组队运镖
DART_TEAM_MEMBER_TIMES_CAN_NOT_DART = -26	  -- 队伍成员%s今日次数已用完，不能发起组队运镖
DART_TEAM_MEMBER_REWARD_CAN_NOT_DART = -27	  -- 队伍成员%s还未领取镖车奖励，不能发起组队运镖
DART_TEAM_MEMBER_DART_CAN_NOT_DART = -28	  -- 队伍成员%s已经发起了运镖，不能发起组队运镖
DART_TEAM_MEMBER_MAX_CAN_NOT_DART = -29	  -- 队伍成员超过了运镖人数，不能发起组队运镖
DART_TEAM_MEMBER_FAR_CAN_NOT_DART = -30	  -- 队伍成员%s距离你太远了，不能发起组队运镖

DART_INVITE_ERR_TEAM_DART_FULL = -31	  -- 护镖队伍已满，不能邀请加入护镖队伍！
DART_INVITE_ERR_OFFLINE = -32	  -- 对方不在线，不能邀请加入护镖队伍！
DART_INVITE_ERR_LEVEL = -33	  -- 对方等级不足，不能邀请加入护镖队伍！
DART_INVITE_ERR_DART_COUNT = -34	  -- 对方今日次数已用完，不能邀请加入护镖队伍！
DART_INVITE_ERR_REWARD = -35	  -- 对方还未领取镖车奖励，不能邀请加入护镖队伍！
DART_INVITE_ERR_DART = -36	  -- 对方已经发起了运镖，不能邀请加入护镖队伍！
DART_INVITE_ERR_OFTEN = -37	  -- 对方被邀请得太频繁，不能邀请加入护镖队伍！

DART_TEAM_NULL = -38		-- 该镖车队伍已发车或者已解散
DART_TEAM_ERR_DART = -39		-- 已经参与了运镖
DART_TEAM_MEMBER_INVITE = -40	  -- 队伍成员%s正在处理镖车邀请，不能发起组队运镖
DART_TEAM_REFUSE_JOIN = -41	  -- 玩家%s拒绝了你的组队运镖邀请
DART_RELEASE_TEAM2 = -42	  -- 您参加的镖车已被解散



COMMON_ERR_TAKE_OBJECT_REWARD_OBJECT_NOT_DONE = -1			-- 目标没有完成,不能领取奖励
COMMON_ERR_TAKE_OBJECT_REWARD_LEVEL = -2			-- 等级不足,不能领取奖励
COMMON_ERR_TAKE_OBJECT_REWARD_TAKED = -3			-- 已经领取过奖励
COMMON_ERR_TAKE_OBJECT_BAG = -4			-- 背包空间不足，不能领取奖励



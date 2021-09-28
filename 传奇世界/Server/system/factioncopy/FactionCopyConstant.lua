--FactionCopyConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  FactionCopyConstant.lua
 --* Author:  seezon
 --* Modified: 2015年11月11日
 --* Purpose: 帮会副本常量定义
 -------------------------------------------------------------------*/

FACTIONCOPY_RANK_NUM = 10	--显示的排名数量
FACTIONCOPY_BOSS_TIME = 10 * 60		--BOSS刷新时间
FACTIONCOPY_TOTAL_TIME = 20 * 60	--活动总时间
FACTIONCOPY_OUT_TIME = 1 * 60	--活动结束后强制传送出去的时间

FACTIONCOPY_REWARD_EMAIL_COFIG1 = 44	--参与奖励邮件ID
FACTIONCOPY_REWARD_EMAIL_COFIG2 = 45	--排名奖励邮件ID
FACTIONCOPY_REWARD_EMAIL_COFIG3 = 46	--最后一击奖励邮件ID
FACTIONCOPY_REWARD_EMAIL_COFIG4 = 47	--击杀奖励邮件ID

--定义行会副本相关提示
FACTIONCOPY_ERR_NOT_SEND_FAIL = -1	    --传送失败，请重试
FACTIONCOPY_ERR_ONT_OPEN = -2	    --活动没有开启
FACTIONCOPY_ERR_LEVEL_NOT_ENOUGH = -3	    --您的等级不足XX，无法参加活动！
FACTIONCOPY_ERR_NO_FACTION = -4				--没有帮会
FACTIONCOPY_ERR_IN_OPEN = -5				--行会副本正中，无法重新召唤
FACTIONCOPY_ERR_POS_LOW = -6		--召唤失败，只有会长或副会长可以进行召唤
FACTIONCOPY_ERR_FACTION_LEVEL_LOW = -7		--行会等级不足XX，不可召唤该BOSS
FACTIONCOPY_ERR_FACTION_MONEY_LOW = -8		--行会资源不足XX，召唤失败
FACTIONCOPY_HAS_CALL = -9		--今天你的行会已经召唤过BOSS了
FACTIONCOPY_ERR_CAN_NOT_TRANS = -10  --当前地图无法传送
FACTIONCOPY_ERR_BOSS_ONT_CALL = -11	    --你的帮会没有召唤BOSS
FACTIONCOPY_ERR_IN_COPYTEAM = -12	--在副本队伍中，无法参加
FACTIONCOPY_ERR_CALL_BOSS_FAIL = -13	    --召唤失败
FACTIONCOPY_ERR_COPY_OVER_TIP = -14	    --行会副本活动结束，1分钟后将传送出去
FACTIONCOPY_ERR_PRE_OPEN = -15	    --行会副本BOSS%s将在十分钟后召唤完成，请所有成员准时参与战斗
FACTIONCOPY_ERR_BOSS_DIE_NOT_JOIN = -16	    --BOSS已经死亡，无法进入
FACTIONCOPY_ERR_BOSS_HAS_FRESH = -17	    --您的行会BOSS%s已经召唤成功，参与活动将获得巨额奖励，请前往参加
FACTIONCOPY_ERR_LAST_HIT = -18	    --玩家%s完成了对BOSS的最后一击
FACTIONCOPY_ERR_PLAYER_RELIVE = -19      --玩家复活发送自动寻路坐标点
FACTIONCOPY_ERR_COPY_OVER_ALL = -20	 --通知所有行会成员副本活动结束

--行会副本定时设置
FACTIONCOPY_SETTIMEERR_POS_LOW = -21			--设置失败，只有会长或副会长可以进行副本定时开启设置
FACTIONCOPY_SETTIMEERR_IN_OPEN = -22			--设置失败, 行会副本开启中
FACTIONCOPY_SETTIMEHAS_SET = -23			--设置失败, 今天该行会已经设置过一次副本定时开启
FACTIONCOPY_SETTIMEERR_FACTION_LEVEL_LOW = -24		--行会等级不足XX，不可设置该副本定时开启时间
FACTIONCOPY_SETTIMEERR_FACTION_MONEY_LOW = -25		--行会资源不足XX，不可设置该副本定时开启时间
FACTIONCOPY_SETTIMEERR_FACTION_TIMEOUT = -26		--设定时间不能早于或者等于当前时间
FACTIONCOPY_SETTIMEERR_FACTION_OPENED = -27		--今天已经成功开启过副本 无法设置时间
FACTIONCOPY_ERR_BOSS_KILLED = -28			--今天已经成功击杀 无法进入

--BOSS刷新定时系统提示
FACTIONCOPY_NOTIFY_TIME = {60,30,10}  --秒

FACTIONCOPY_OPEN_NEXTDAY = 24*60*60
FACTIONCOPY_CLOSE_HOUR = 0				--行会副本每日关闭时间 (小时)
--系统频道行会副本开启推送消息
NOTIFY_FACTIONCOPY_OPEN_MSG = 82

--行会副本可开启时间配置
FactionCopyCanOpenTime = { "10:00", "10:30", "13:00", "13:30", "16:00", "16:30", "19:00", "19:30", "22:00", "22:30" }

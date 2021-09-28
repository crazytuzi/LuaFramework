--ShaWarConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  ShaWarConstant.lua
 --* Author:  seezon
 --* Modified: 2015年7月29日
 --* Purpose: 沙巴克常量定义
 -------------------------------------------------------------------*/
SHAWAR_MAP_ID = 4100					--沙城地图ID
SHAWAR_PALACE_MAP_ID = 4101			--皇宫地图ID
SHAWAR_LAST_TIME = 60*60			--活动持续时间
SHAWAR_PALACE_HOLD_POS = {[1]={x=10,y=26},[2]={x=19,y=29},[3]={x=22,y=23},[4]={x=29,y=21}}	--由城墙进入皇宫的皇宫坐标
SHAWAR_HOLD_POS = {[1]={x=97,y=82},[2]={x=105,y=82},[3]={x=109,y=79},[4]={x=113,y=76}}			--城墙驻守的坐标
SHAWAR_CANCLE_HOLD_POS = {[1]={x=94,y=85},[2]={x=108,y=86},[3]={x=112,y=83},[4]={x=116,y=80}}	--取消城墙驻守时的坐标
SHAWAR_OPEN_WEEK = 4			--沙城开战周数
SHAWAR_COUNT_DOWN_NUM = 30			--沙城开战前倒计时秒数
SHAWAR_DEFEND_NPCID	= "384"				--守城NPCID
SHAWAR_DEFENDNPC_FRESHID = 2192		--守城NPC刷新ID
SHAWAR_RELIVE_TIME = 10		--沙巴克战争复活时间
SHAWAR_LEADER_BUFF = 340		--沙巴克城主BUFF


--定义错误号
SHAWAR_ERR_ID_NOT_OPEN = -1			--沙城战没有开启
SHAWAR_ERR_HAS_IN_SHA = -2			--已经在沙城地图了
SHAWAR_ERR_FAIL = -3				--没人占领沙巴克
SHAWAR_ERR_SUCCESS = -4				--有帮派占领沙巴克成功
SHAWAR_ERR_KILL_NOTIFY1 = -5			--%s浴血奋战，达成5连杀 
SHAWAR_ERR_KILL_NOTIFY2 = -6			--%s完成妖怪般的杀戮，达成10连杀
SHAWAR_ERR_KILL_NOTIFY3 = -7			--%s达成15连杀，他已经无敌了
SHAWAR_ERR_KILL_NOTIFY4 = -8			--%s手起刀落，终结了%s的5连胜
SHAWAR_ERR_KILL_NOTIFY5 = -9			--%s乘其不备，终结了%s的10连胜
SHAWAR_ERR_KILL_NOTIFY6 = -10			--%s战神附体，终结了%s的15连胜
SHAWAR_ERR_HOLD_PALACE_SUCCESS = -11	--%s帮会占领皇宫成功，开始读秒
SHAWAR_ERR_NO_FACTION = -12				--没有帮会
SHAWAR_ERR_REWARD_HAS_GIVE = -13		--已经领过奖励
SHAWAR_ERR_NOT_SAME_FAC_HOLD = -14		--与驻守人不是同一个帮派，不能进入
SHAWAR_ERR_HAS_PEOPLE_HOLD = -15		--已经有人驻守了，驻守失败
SHAWAR_NOT_SHA_NO_IN = -16		--非沙城人员不能进入皇宫
SHAWAR_NOT_INGOT_ENOUGH = -17		--您的元宝不足，无法操作
SHAWAR_CANNOT_IN_PALACE = -18		--没资格进入皇宫

SHAWAR_READYOPEN_NOTICE = 83	--开启前广播提示
SHAWAR_READYOPEN_NOTICE2 = 107	--开启前广播提示
SHAWAR_REMAIN_TIME_NOTICE2 = 84	--剩余时间提醒
SHAWAR_OPEN_NOTICE = 85 		--正式开启广播提示
SHAWAR_CLOSE_NOTICE1 = 86 		--活动结束，无行会占领
SHAWAR_CLOSE_NOTICE2 = 87 		--活动结束，有行会占领
SHAWAR_REWARD = 108 			--活动结束，城主领取奖励提示
SHAWAR_LEADER_LOAD = 91 		--沙巴克城主上线提示

--杀人数量提示
KILLNOTIFYNUM = {
	NUM5			= 5,	--杀人达到5
	NUM10			= 10,	--杀人达到10
	NUM15			= 15,	--杀人达到15
}

--处理驻守事件
DEALHOLDTYPE = {
	ENTER			= 1,	--进入皇宫
	HOLD			= 2,	--驻守
	CANCLEHOLD		= 3,	--退出驻守
}


--沙巴克城皇宫入口索引
SHAWARHOLDINDEX = {
	SIDEDOOR1		= 1,	--侧门1
	SIDEDOOR2		= 2,	--侧门2
	DOOR			= 3,	--皇宫大门
	SIDEDOOR3		= 4,	--侧门3
}

--沙巴克战斗日志类型
SHAWARRECORDTYPE = {
	TYPE1		= 1,	--xx行会成功占领了沙城
	TYPE2		= 2,	--xx行会成功守卫了沙城
	TYPE3		= 3,	--xx行会击败了xx行会，成功占领了沙城
}
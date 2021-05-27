--#include "..\..\..\language\LangCode.txt"
activityTips =
{
	{
		id = 1,
		level = 70,
		delay = 60,
		moveLimit = 60,
		iconid=1,
		isDelete = true,
        link = "",--活动传送位置，如："m沙漠土城:86:124:月老"
		name = Lang.ActivityName.name00072,
		award = {{type=3,count=1,id=0},
		         {type=2,count=1,id=0},
			 {type=4,count=1,id=0},
			 {type=6,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;10:30-10:50}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动开启后,土城}{color;FFFF0000;(173:129)}{color;FFFFFFFFF;处刷出BOSS}{color;FFFF0000;(麒麟富贵兽)}{color;FFFFFFFFF;,每次击杀富贵兽可获得大量经验和绑金,根据玩家自身攻击,获得不同数量的经验和绑金,富贵兽死亡有几率爆出高级装备和材料.}",
		ensure = "",
		awardDesc = "绑金、经验",
		time = "10:30-10:50",
		isShowCdIcon = true,
		iconid = 1,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"10:30-10:50",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
    },
	{
		id = 2,
		level = 60,
		delay = 60,
		moveLimit = 60,
		isDelete = false,
        link = "",
		name =Lang.ActivityName.name00073,
		award = {{type=3,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动NPC:}{color;FFFF0000;卧龙城-城主雕像}\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;11:30-12:30}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动开启后,去卧龙城找城主雕像点击膜拜城主,在卧龙城安全区内可获得}{color;FFFF0000;大量经验}{color;FFFFFFFFF;,城主可获得双倍奖励.}",
		ensure = "城主雕像,2,城主雕像",
		awardDesc = "绑金、经验",
		time = "11:30-12:30",
		isShowCdIcon = true,
		iconid = 6,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"11:30-12:30",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 3,
		level = 60,
		delay = 60,
	    moveLimit = 60,
		isDelete = false,
        link = "",
		name =Lang.ActivityName.name00074,
		award = {{type=1,count=1,id=0},
		         {type=2,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动NPC:}{color;FFFF0000;土城-武林争霸}\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;12:40-13:20}\n{color;FFFFFFFF;活动介绍:}{color;FFFF0000;12:40-12:49}{color;FFFFFFFFF;为报名时间(找土城NPC-武林争霸报名即可,)}{color;FFFF0000;12:50-13:20}{color;FFFFFFFFF;为争霸时间(已报名玩家可进入场地自由PK,地图内不增加PK值,活动时间结束时,争霸场地内)}{color;FFFF0000;只剩下一名玩家}{color;FFFFFFFFF;则,该玩家为胜利者,可获得丰厚的元宝和绑金奖励,有报名参赛未获胜的玩家也可在NPC-武林争霸处领取绑金的安慰奖.}",
		ensure = "武林争霸,3,武林争霸",
		awardDesc = "元宝、绑金",
		time = "12:50-13:20",
		isShowCdIcon = true,
		iconid = 9,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"12:50-13:20",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 4,
		level = 0,
		delay = 0,
		moveLimit = 0,
        link = "",
		isDelete = true,
		name =Lang.ActivityName.name00075,
		award = {{type=3,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;13:30-16:30}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动期间,杀任意怪均可享受}{color;FFFF0000;双倍经验}{color;FFFFFFFFF;奖励,使用}{color;FFFF0000;多倍经验材料}{color;FFFFFFFFF;可叠加经验奖励.}",
		ensure = "",
		awardDesc = "经验",
		time = "13:30-16:30",
		isShowCdIcon = false,
		iconid = 7,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"13:30-16:30",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 5,
		level = 60,
		delay = 60,
		moveLimit = 60,
		isDelete = true,
        link = "",
		name = Lang.ActivityName.name00072,
        award = {{type=3,count=1,id=0},
		         {type=2,count=1,id=0},
			 {type=4,count=1,id=0},
			 {type=6,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;14:00-14:20}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动开启后,土城}{color;FFFF0000;(173:129)}{color;FFFFFFFFF;处刷出BOSS}{color;FFFF0000;(麒麟富贵兽)}{color;FFFFFFFFF;,每次击杀富贵兽可获得大量经验和绑金,根据玩家自身攻击,获得不同数量的经验和绑金,富贵兽死亡有几率爆出高级装备和材料.}",
		ensure = "",
		awardDesc = "绑金、经验",
		time = "14:00-14:20",
		isShowCdIcon = true,
		iconid = 1,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"14:00-14:20",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 6,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = true,
		name =Lang.ActivityName.name00076,
		award = {{type=2,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;15:30-16:00}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动期间,黄金满屋地图内刷新150只}{color;FFFF0000;真假黄金战神}{color;FFFFFFFFF;,其中有一部分为真黄金战神,可直接爆出}{color;FFFF0000;金条}{color;FFFFFFFFF;,一部分为假黄金战神,只爆小堆绑定绑金.}",
		ensure = "黄金满屋,3,黄金满屋",
		awardDesc = "绑定绑金",
		time = "15:30-16:00",
		isShowCdIcon = true,
		iconid = 4,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"15:30-16:00",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 7,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = true,
		name =Lang.ActivityName.name00077,
		award = {{type=4,count=1,id=0},
		         {type=6,count=1,id=0},
		         {type=3,count=1,id=0},
		         {type=2,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;16:30-17:00}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动期间,土城黑龙神殿}{color;FFFF0000;(150:127)}{color;FFFFFFFFF;处涌现出黑龙大军,疯狂侵袭土城安全区附近的}{color;FFFF0000;(109:91)}{color;FFFFFFFFF;处,消灭黑龙大军,有机会获得高级装备和材料.}",
		ensure = "",
	    awardDesc = "装备、材料",
		time = "16:30-17:00",
		isShowCdIcon = true,
		iconid = 2,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"16:30-17:00",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 8,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = false,
		name =Lang.ActivityName.name00073,
		award = {{type=3,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动NPC:}{color;FFFF0000;卧龙城-城主雕像}\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;11:30-12:30}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动开启后,去卧龙城找城主雕像点击膜拜城主,在卧龙城安全区内可获得}{color;FFFF0000;大量经验}{color;FFFFFFFFF;,城主可获得双倍奖励.}",
		ensure = "城主雕像,2,城主雕像",
	    awardDesc = "经验",
		time = "17:30-18:30",
		isShowCdIcon = true,
		iconid = 6,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"17:30-18:30",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 9,
		level = 0,
		delay = 0,
		moveLimit = 0,
        link = "",
		isDelete = true,
		name =Lang.ActivityName.name00075,
		award = {{type=3,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;19:00-21:00}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动期间,杀任意怪均可享受}{color;FFFF0000;双倍经验}{color;FFFFFFFFF;奖励,使用}{color;FFFF0000;多倍经验材料}{color;FFFFFFFFF;可叠加经验奖励.}",
		ensure = "",
		awardDesc = "经验",
		time = "19:00-21:00",
		isShowCdIcon = false,
		iconid = 7,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"19:00-21:00",
				}
				},
			levelLimit ={
				minLevel = 0,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 10,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = false,
		name =Lang.ActivityName.name00078,
		award = {{type=1,count=1,id=0},
		         {type=4,count=1,id=0},
		         {type=6,count=1,id=0},
		         {type=3,count=1,id=0},
		         {type=2,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;19:10-19:40}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动期间,黑龙神殿内刷新一BOSS}{color;FFFF0000;黑龙魔君}{color;FFFFFFFFF;,BOSS的存活时间为25分钟,玩家必须在25分钟内击败黑龙,否则黑龙消失,当黑龙被击败后,地图内自动降落}{color;FFFF0000;满地财宝}{color;FFFFFFFFF;各种高级装备和材料应有尽有,拾取模式为:}{color;FFFF0000;自由拾取模式}{color;FFFFFFFFF;地图内PK不增加PK值,但死亡会掉落装备.}",
		ensure = "黑龙神殿,3,黑龙神殿",
		awardDesc = "元宝、装备、材料",
		time = "19:10-19:40",
		isShowCdIcon = true,
		iconid = 3,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"19:10-19:40",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 11,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = true,
		name =Lang.ActivityName.name00079,
		award = {{type=4,count=1,id=0},
		         {type=6,count=1,id=0},
		         {type=3,count=1,id=0},
		         {type=2,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;21:00-21:30}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动期间,王城将受到}{color;FFFF0000;神威魔王}{color;FFFFFFFFF;侵袭,消灭神威魔王,有机会获得高级装备和各种材料.}",
		ensure = "",
		awardDesc = "装备、材料",
		time = "21:00-21:30",
		isShowCdIcon = true,
		iconid = 8,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"21:00-21:30",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 12,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = true,
		name = Lang.ActivityName.name00072,
		award = {{type=3,count=1,id=0},
		         {type=2,count=1,id=0},
			 {type=4,count=1,id=0},
			 {type=6,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;22:10-22:30}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动开启后,土城}{color;FFFF0000;(173:129)}{color;FFFFFFFFF;处刷出BOSS}{color;FFFF0000;(麒麟富贵兽)}{color;FFFFFFFFF;,每次击杀富贵兽可获得大量经验和绑金,根据玩家自身攻击,获得不同数量的经验和绑金,富贵兽死亡有几率爆出高级装备和材料.}",
		ensure = "",
		awardDesc = "绑金、经验",
		time = "22:10-22:30",
		isShowCdIcon = true,
		iconid = 1,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"22:10-22:30",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 13,
		level = 60,
		delay = 60,
		moveLimit = 60,
		isDelete = false,
        link = "",
		name = Lang.ActivityName.name00080,
		award = {{type=3,count=1,id=0},
		         {type=2,count=1,id=0}},
		tips = "{color;FFFFFFFF;报名时间:}{color;FFFF0000;12:40-12:49}\n{color;FFFFFFFF;报名详解:}{color;FFFFFFFFF;参与武林争霸活动需要事先报名,报名时间系统会自动弹出窗口供给报名,也可直接到土城NPC}{color;FFFF0000;(武林争霸)}{color;FFFFFFFFF;处点击报名.}",
		ensure = "",
		awardDesc = "元宝、绑金",
		time = "12:40-12:49",
		isShowCdIcon = true,
		iconid = 9,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"12:40-12:49",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	 {
	 	id = 14,
	 	level = 60,
	 	delay = 60,
	 	moveLimit = 60,
         link = "",
	 	isDelete = true,
	 	name = Lang.ActivityName.name00081,
	 	award = {{type=4,count=1,id=0},
	 	         {type=6,count=1,id=0},
	 	         {type=3,count=1,id=0},
	          {type=2,count=1,id=0}},
	 	tips = "\n{color;FFFFFFFF;活动NPC:}{color;FFFFFFFFF;卧龙城-行会争霸}\n{color;FFFFFFFF;活动时间:}{color;FFFFFFFFF;14:40-15:10}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动开始时,有加入行会并且等级大于60级玩家均可参加,活动开始的10分钟内,玩家可从卧龙城NPC处反复进入赛场,10分钟后即14点50分止,赛场大门关闭,赛场内开始角逐胜负,赛场内将不是本行会玩家清理出去,只剩下本行会玩家,则该行会获胜,系统会在场景内依次刷出10只BOSS,杀死BOSS有机会爆出全服一切物品和装备!(地图内不增加PK值,死亡不掉落装备)}",
	 	ensure = "",
	 	awardDesc = "绑金、经验",
	 	time = "14:40-15:10",
	 	isShowCdIcon = true,
	 	condition =
	 	{
	 		timeLimit = {
	 			months={0},
	 			days ={0},
	 			weeks={0},
	 			minutes=
	 			{
	 				"14:40-15:10",
	 		}
	 			},
	 		levelLimit ={
	 			minLevel = 60,
	 			maxLevel = -1,
	 			},
	 		openSererday ={maxDay =-1,minDay=-1,},
	 	},
	 },
	 {
	 	id = 15,
	 	level = 60,
	 	delay = 60,
	 	moveLimit = 60,
         link = "",
	 	isDelete = true,
	 	name = Lang.ActivityName.name00068,
	 	award = {{type=1,count=1,id=0},
	 	         {type=4,count=1,id=0},
	 		 {type=6,count=1,id=0}},
	 	tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFFFFFFF;18:40-18:55}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;进入场景→领取泉水罐→将泉水罐装备符处→抢占泉水位→开始装水→装满泉水→兑换珍宝,兑换珍宝在土城安全区周围NPC(泉水结阵)处.}",
	 	ensure = "",
	 	awardDesc = "各种珍宝",
	 	time = "18:40-18:55",
	 	isShowCdIcon = true,
	 	condition =
	 	{
	 		timeLimit = {
	 			months={0},
	 			days ={0},
	 			weeks={0},
	 			minutes=
	 		{
	 				"18:40-18:55",
	 			}
	 			},
	 		levelLimit ={
	 			minLevel = 60,
	 			maxLevel = -1,
	 			},
	 		openSererday ={maxDay =-1,minDay=-1,},
	 	},
	 },
	{
		id = 16,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = true,
		name = Lang.ActivityName.name00082,
		award = {{type=3,count=1,id=0},
		         {type=2,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;13:30-13:45}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动开启后,系统自动弹窗进入场地,地图内有两座}{color;FFFF0000;(金佛)}{color;FFFFFFFFF;玩家需要抢占金佛四周的标志圈位置,每秒可获得超高经验和绑金奖励,场景内还会刷BOSS哦.}",
		ensure = "",
		awardDesc = "绑金、经验",
		time = "13:30-13:45",
		isShowCdIcon = true,
		iconid = 5,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"13:30-13:45",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 17,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = true,
		name = Lang.ActivityName.name00082,
		award = {{type=4,count=1,id=0},
		         {type=2,count=1,id=0},
			 {type=7,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;13:30-13:45}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFFF;活动开启后,系统自动弹窗进入场地,地图内有两座}{color;FFFF0000;(金佛)}{color;FFFFFFFFF;玩家需要抢占金佛四周的标志圈位置,每秒可获得超高经验和绑金奖励,场景内还会刷BOSS哦.}",
		ensure = "",
		awardDesc = "绑金、经验",
		time = "22:45-23:00",
		isShowCdIcon = true,
		iconid = 5,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"22:45-23:00",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 18,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = false,
		name = Lang.ActivityName.name00083,
		award = {{type=4,count=1,id=0},
		         {type=2,count=1,id=0},
			 {type=7,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动NPC:}{color;FFFFFFFFF;卧龙城-魔族入侵}\n{color;FFFFFFFF;活动地点:}{color;FFFFFFFFF;王城}\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;16:00-17:00}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFF;共有}{color;FFFF0000;5波}{color;FFFFFFFF;怪物入侵王城,每间隔}{color;FFFF0000;10分钟}{color;FFFFFFFF;刷新一波,每波怪物都由}{color;FFFF0000;1只}{color;FFFFFFFF;大BOSS携带}{color;FFFF0000;6只}{color;FFFFFFFF;小BOSS侵袭王城,击杀BOSS有机会获得}{color;FFFF0000;稀有道具}{color;FFFFFFFF;和}{color;FFFF0000;高级装备}",
		ensure = "",
		awardDesc = "羽毛、绑金、装备",
		time = "16:00-17:00",
		isShowCdIcon = true,
		iconid = 8,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"16:00-17:00",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =-1,minDay=-1,},
		},
	},
	{
		id = 19,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = false,
		name = Lang.ActivityName.name00083,
		award = {{type=4,count=1,id=0},
		         {type=2,count=1,id=0},
			 {type=7,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动NPC:}{color;FFFFFFFFF;卧龙城-魔族入侵}\n{color;FFFFFFFF;活动地点:}{color;FFFFFFFFF;王城}\n{color;FFFFFFFF;活动时间:}{color;FFFF0000;20:00-21:00}{color;FF00FF00;开区前4天}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFF;共有}{color;FFFF0000;5波}{color;FFFFFFFF;怪物入侵王城,每间隔}{color;FFFF0000;10分钟}{color;FFFFFFFF;刷新一波,每波怪物都由}{color;FFFF0000;1只}{color;FFFFFFFF;大BOSS携带}{color;FFFF0000;6只}{color;FFFFFFFF;小BOSS侵袭王城,击杀BOSS有机会获得}{color;FFFF0000;稀有道具}{color;FFFFFFFF;和}{color;FFFF0000;高级装备}",
		ensure = "",
		awardDesc = "羽毛、绑金、装备",
		time = "20:00-21:00",
		isShowCdIcon = true,
		iconid = 8,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"20:00-21:00",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay =4,minDay=1,},
		},
	},
	{
		id = 20,
		level = 65,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = false,
		name = Lang.ActivityName.name00084,
		award = {{type=4,count=1,id=0},
		         {type=2,count=1,id=0},
			 {type=6,count=1,id=0},
			 {type=7,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动NPC:}{color;FFFFFFFFF;卧龙城-神威幻境}\n{color;FFFFFFFF;活动地点:}{color;FFFFFFFFF;神威幻境1-7层}\n{color;FFFFFFFF;入口开放时间:}{color;FFFF0000;10:30-11:00}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFF;神威幻境共有}{color;FFFF0000;7层}{color;FFFFFFFF;,击杀每层BOSS有几率掉落}{color;FFFF0000;高级装备}{color;FFFFFFFF;和}{color;FFFF0000;稀有道具}{color;FFFFFFFF;,进入每一层都可获得}{color;FFFF0000;羽毛}{color;FFFFFFFF;和}{color;FFFF0000;绑金}{color;FFFFFFFF;奖励,进入后需要击杀}{color;FFFF0000;神威幻境统领}{color;FFFFFFFF;收集足够的}{color;FFFF0000;幻境通行证}{color;FFFFFFFF;才可继续进入下一层.每次活动限时}{color;FFFF0000;1小时}{color;FFFFFFFF;,超时自动传出.}",
		ensure = "",
		awardDesc = "羽毛、绑金、装备",
		time = "10:30-11:30",
		isShowCdIcon = true,
		iconid = 2,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"10:30-11:30",
				}
				},
			levelLimit ={
				minLevel = 65,
				maxLevel = -1,
				},
			openSererday ={maxDay = -1,minDay = -1,},
		},
	},
	{
		id = 21,
		level = 65,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = false,
		name = Lang.ActivityName.name00084,
		award = {{type=4,count=1,id=0},
		         {type=2,count=1,id=0},
			 {type=6,count=1,id=0},
			 {type=7,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动NPC:}{color;FFFFFFFFF;卧龙城-神威幻境}\n{color;FFFFFFFF;活动地点:}{color;FFFFFFFFF;神威幻境1-7层}\n{color;FFFFFFFF;入口开放时间:}{color;FFFF0000;14:30-15:00}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFF;神威幻境共有}{color;FFFF0000;7层}{color;FFFFFFFF;,击杀每层BOSS有几率掉落}{color;FFFF0000;高级装备}{color;FFFFFFFF;和}{color;FFFF0000;稀有道具}{color;FFFFFFFF;,进入每一层都可获得}{color;FFFF0000;羽毛}{color;FFFFFFFF;和}{color;FFFF0000;绑金}{color;FFFFFFFF;奖励,进入后需要击杀}{color;FFFF0000;神威幻境统领}{color;FFFFFFFF;收集足够的}{color;FFFF0000;幻境通行证}{color;FFFFFFFF;才可继续进入下一层.每次活动限时}{color;FFFF0000;1小时}{color;FFFFFFFF;,超时自动传出.}",
		ensure = "",
		awardDesc = "羽毛、绑金、装备",
		time = "14:30-15:30",
		isShowCdIcon = true,
		iconid = 2,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"14:30-15:30",
				}
				},
			levelLimit ={
				minLevel = 65,
				maxLevel = -1,
				},
			openSererday ={maxDay = -1,minDay = -1,},
		},
	},
	{
		id = 22,
		level = 65,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = false,
		name = Lang.ActivityName.name00084,
		award = {{type=4,count=1,id=0},
		         {type=2,count=1,id=0},
			 {type=6,count=1,id=0},
			 {type=7,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动NPC:}{color;FFFFFFFFF;卧龙城-神威幻境}\n{color;FFFFFFFF;活动地点:}{color;FFFFFFFFF;神威幻境1-7层}\n{color;FFFFFFFF;入口开放时间:}{color;FFFF0000;22:30-23:00}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFF;神威幻境共有}{color;FFFF0000;7层}{color;FFFFFFFF;,击杀每层BOSS有几率掉落}{color;FFFF0000;高级装备}{color;FFFFFFFF;和}{color;FFFF0000;稀有道具}{color;FFFFFFFF;,进入每一层都可获得}{color;FFFF0000;羽毛}{color;FFFFFFFF;和}{color;FFFF0000;绑金}{color;FFFFFFFF;奖励,进入后需要击杀}{color;FFFF0000;神威幻境统领}{color;FFFFFFFF;收集足够的}{color;FFFF0000;幻境通行证}{color;FFFFFFFF;才可继续进入下一层.每次活动限时}{color;FFFF0000;1小时}{color;FFFFFFFF;,超时自动传出.}",
		ensure = "",
		awardDesc = "羽毛、绑金、装备",
		time = "22:30-23:30",
		isShowCdIcon = true,
		iconid = 2,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"22:30-23:30",
				}
				},
			levelLimit ={
				minLevel = 65,
				maxLevel = -1,
				},
			openSererday ={maxDay = -1,minDay = -1,},
		},
	},
	{
		id = 23,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = false,
		name = Lang.ActivityName.name00085,
		award = {{type=1,count=1,id=0},
		         {type=8,count=1,id=0},
			 {type=9,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动地点:}{color;FFFFFFFFF;土城药店}\n{color;FFFFFFFF;入口开放时间:}{color;FFFF0000;13:30-14:00}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFF;活动开始时,土城药店旁刷出}{color;FFFF0000;“送财金凤凰”}{color;FFFFFFFF;,击杀送财金凤凰可爆出大量}{color;FFFF0000;元宝、绑定元宝、绑金、金条}{color;FFFFFFFF;等大批宝藏,为}{color;FFFF0000;无主模式}{color;FFFFFFFF;,任何人都可以随意捡取.}",
		ensure = "",
		awardDesc = "元宝、绑定元宝、金条",
		time = "13:30-14:00",
		isShowCdIcon = true,
		iconid = 4,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"13:30-14:00",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay = -1,minDay = -1,},
		},
	},
	{
		id = 24,
		level = 60,
		delay = 60,
		moveLimit = 60,
        link = "",
		isDelete = false,
		name = Lang.ActivityName.name00085,
		award = {{type=1,count=1,id=0},
		         {type=8,count=1,id=0},
			 {type=9,count=1,id=0}},
		tips = "\n{color;FFFFFFFF;活动地点:}{color;FFFFFFFFF;土城药店}\n{color;FFFFFFFF;入口开放时间:}{color;FFFF0000;21:20-21:50}\n{color;FFFFFFFF;活动介绍:}{color;FFFFFFFF;活动开始时,土城药店旁刷出}{color;FFFF0000;“送财金凤凰”}{color;FFFFFFFF;,击杀送财金凤凰可爆出大量}{color;FFFF0000;元宝、绑定元宝、绑金、金条}{color;FFFFFFFF;等大批宝藏,为}{color;FFFF0000;无主模式}{color;FFFFFFFF;,任何人都可以随意捡取.}",
		ensure = "",
		awardDesc = "元宝、绑定元宝、金条",
		time = "21:20-21:50",
		isShowCdIcon = true,
		iconid = 4,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes=
				{
					"21:20-21:50",
				}
				},
			levelLimit ={
				minLevel = 60,
				maxLevel = -1,
				},
			openSererday ={maxDay = -1,minDay = -1,},
		},
	},
	{
		id = 25,
		level = 70,
		delay = 60,
		moveLimit = 60,
    link = "",
		isDelete = false,
		name = Lang.ActivityName.name00086,
		award = {
			{type=4,count=1,id=0},
		},
		tips = "\n{color;FFFFFFFF;活动地点:}{color;FFFFFFFFF;闭关修炼}\n{color;FFFFFFFF;入口开放时间:}{color;FFFF0000;11:00-11:50}",
		ensure = "闭关修炼,3,闭关修炼",
		awardDesc = "经验、法神灵力",
		time = "11:00-11:50",
		isShowCdIcon = true,
		iconid = 4,
		condition =
		{
			timeLimit = {
				months={0},
				days ={0},
				weeks={0},
				minutes= {"11:00-11:50",},
			},
			levelLimit ={minLevel = 70,	maxLevel = -1,},
			openSererday ={maxDay = -1, minDay = -1,},
		},
	},
}

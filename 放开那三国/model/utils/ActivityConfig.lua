-- Filename：	ActivityConfig.lua
-- Author：		lichenyang
-- Date：		2011-1-8
-- Purpose：		活动配置

module("ActivityConfig" , package.seeall)
require "db/DB_Xiaofei_leiji_kaifu"
require "db/DB_Ernie_kaifu"
require "db/DB_WealActivity_kaifu"

--[[
	@des:取数据（eg:消费累积）
	--读取消费累积的第一行
	ActivityConfig.ConfigCache.spend.data[1].des
	ActivityConfig.ConfigCache.spend.start_time			--开启时间
	ActivityConfig.ConfigCache.spend.end_time			--关闭时间
	ActivityConfig.ConfigCache.spend.need_open_time  	--需要开启时间
--]]
ConfigCache 	= 	{}
ConfigCache.version = 0


keyConfig 		= 	{}
--消费累积
keyConfig.spend 			= {
	"id","des","expenseGold","reward",
}

--竞技场双倍奖励
keyConfig.arenaDoubleReward = {
	
}

--活动卡包
keyConfig.heroShop 			= {
	"id","icon","des","freeScore","goldScore","goldCost","freeCd","rewardId","freeTimeNum","tmp0","tavernId","showHeros","coseTime","first_reward_text","second_reward_text","third_reward_text","fourth_reward_text","reward_rank_num",
}

--活动卡包奖励
keyConfig.heroShopReward 	= {
	"id","tep0","scoreReward1","tmp1","scoreReward2","tmp2","scoreReward3","tmp3","scoreReward4","tmp4","scoreReward5","num","tmp5","rankingReward1","tmp6","tmp7","rankingReward2","tmp8","tmp9","rankingReward3","tmp10","tmp11","rankingReward4","tmp12","tmp13","rankingReward5","tmp14",
}

--挖宝活动配置
keyConfig.robTomb			= {
	"id","icon","des","showItems1","showItems2","showItems3","showItems4","showItems5","GoldCost","levelLimit","freeDropId","goldDropId","changeTimes","changeDropId","onceDrop",

}

-- 春节礼包活动配置
keyConfig.signActivity      = {
	"id", "des", "icon", "accumulateDay", "reward", "cost",
}

-- 充值回馈
keyConfig.topupFund			= {
	"id","des","expenseGold","reward"
}

-- 福利活动
keyConfig.weal				= {
	"id","openTime","endId","severTime","name","picPath","desc","expl","open_act","ac_double_num","nc_act","nc_soul","sc_drop","friend_stamina","guild_donate_act","guild_shop","hero_gift","g_box_drop","card_cost","score_lim","open_draw","copyteam_double_num","res_act","doubleExpNeedLv","eventTypeIn","actCdType",
}

-- 兑换活动
keyConfig.actExchange 		= {
	"id", "name", "exchangeMaterialQuantity", "exchangeMaterial1", "exchangeMaterial2", "exchangeMaterial3", "exchangeMaterial4", "exchangeMaterial5", "targetItems", "changeTime", "refreshTime", "conversionFormula", "rewardNormal", "gold", "level", "goldTop", "itemView", "viewName", "isRefresh","tavernId","mysticalGoodsId","copymysticalGoodsId","soulDropId","act_icon1","act_icon2","title_bg","title","list_bg","act_bg","act_des",
}

-- 团购活动
keyConfig.groupon  			= {
	"id","price","vip","oriprice","icon","name","quality","reward","numtop","num1","picture1","quality1","reward1","num2","picture2","quality2","reward2","num3","picture3","quality3","reward3","num4","picture4","quality4","reward4","num5","picture5","quality5","reward5","num6","picture6","quality6","reward6","num7","picture7","quality7","reward7","num8","picture8","quality8","reward8","num9","picture9","quality9","reward9","num10","picture10","quality10","reward10","num11","picture11","quality11","reward11","num12","picture12","quality12","reward12","num13","picture13","quality13","reward13","num14","picture14","quality14","reward14","num15","picture15","quality15","reward15","num16","picture16","quality16","reward16","num17","picture17","quality17","reward17","num18","picture18","quality18","reward18","num19","picture19","quality19","reward19","num20","picture20","quality20","reward20","goodsId","changeTime","opentime",
}

--抽奖活动
keyConfig.chargeRaffle  	= {
	"id", "limitDayNum", "activityExplain", "costNum", "firstReward", "dropId_1", "changeDropId_1", "dropShow_1", "dropId_2", "changeDropId_2", "dropShow_2", "dropId_3", "changeDropId_3", "dropShow_3", 
}

--充值大放送活动
--added by Zhang Zihang
keyConfig.topupReward		= {
	"id", "openId", "payNum", "payReward", "activityExplain",
}

--跨服赛活动配置
keyConfig.lordwar			= {
	"id", "level", "loseTime", "lastTimeArr", "applyTime", "championLastTime", "num", "massElectionGapTime", "kuafu_SroundGapTime", "cd", "refreshFightCdCost", "inScoreRewardId", "outScoreRewardId", "cheerCost", "cheerReward", "allServeGift", "wishReward", "wishCost", "rewardPreviewIn", "rewardPreviewOut", "shop_items",
}

--计步活动
--id 	步数对应时长 		奖励步长 		奖励内容
keyConfig.stepCounter 		= {
	"id", "timeperstep", "steps", "rewards",
}

--积分轮盘 
--add by DJN
-- keyConfig.roulette 		= {
-- "id", "WheelCost", "WheelScore", "WheelReward", "BoxId", "BoxReward1", "BoxReward2", "BoxReward3","weight","change","ActivityDes","drop_1", "drop_2", "drop_3", "drop_4", "drop_5", "drop_6", "drop_7", "drop_8", "drop_9", "drop_10", 
-- }
--积分轮盘 
--add by DJN
keyConfig.roulette 		= {
"id","WheelCost","WheelScore","WheelReward","BoxId","BoxReward1","BoxReward2","BoxReward3","weight","change","ActivityDes","drop_1","drop_2","drop_3","drop_4","drop_5","drop_6","drop_7","drop_8","drop_9","drop_10","wheelopentime","rankscoreslimit","rankreward1","rankreward2","rankreward3","rankreward4_10","rankreward11_20",
}
 
keyConfig.limitShop 	= {
	"id" , "RefreshTime" , "ItemID" , "ItemTitle" , "Itemdes" , "ItemTips" , "OriginalCost" , "NowCost" , "VIPLimited" , "buyNum" ,"picture","color",
}

--聚宝盆 
--add by DJN
keyConfig.treasureBowl 	= {
	"id","bowltime","rewardtime","BowlRecharge","BowlCost","BowlReward1","BowlReward2","BowlReward3","BowlReward4","BowlReward5","BowlReward6","BowlReward7","endTime",
}


--节日活动
keyConfig.festival = {
	"id","name","tpye","picPath","desc","expl","drop_view","compose_desc","compose_num","extra_drop","formula1","target1","max_num1","formula2","target2","max_num2","formula3","target3","max_num3","formula4","target4","max_num4","formula5","target5","max_num5","formula6","target6","max_num6","formula7","target7","max_num7","formula8","target8","max_num8","formula9","target9","max_num9","formula10","target10","max_num10",
}

keyConfig.guildwar = {
	"id", "needLv", "neednumbers", "lastloseNum", "promotedtime", "selectgaptime", "battlegrouptime", "cdtimefresh", "eachHeroNum", "strideRoutePrize", "otherPrize", "cheerCost", "cheerPrize", "serverPrize", "wishReward", "preID", "refreshFightCdCost", "defaultWin", "WinCost", "cheerFreezeTime", "serverId", "wishCost", "rewardPreviewIn", "rewardPreviewOut", 

}

-- 主界面背景、特效、背景音乐
keyConfig.frontShow = {
	"id", "main_scene", "main_effect", "main_png", "main_effect2",
}

-- 积分商店
keyConfig.scoreShop = {
	"id","time","discribe", "point","exchange_items",
}

--吃烧鸡送金币
keyConfig.supply = {
	
}

--巅峰对决
keyConfig.worldarena = {
	"id", "active_time", "level", "update_tiem", "protect_time", "begin_num", "buy_num", "gold_recover", "silver_recover", "fight_reward", "reward_des", "rank_reward", "kill_reward", "continue_reward", "streak", "break_streak","roommax","roommin","choose","time","fail_reward","cd_time",
}

--跨服团购 
keyConfig.worldgroupon = {
	"id","day","item","price","discount","type","return_rate","points_reward","start_time","replace_rate","good_name","pic","quality"
}

--黑市兑换 add by yangrui
keyConfig.blackshop = {
	"id", "need_item", "get_item", "times", "show_exchange","refresh_type",
}

-- 云游商人
keyConfig.travelShop = {
	"id", "day", "item", "num", "base_price", "new_price", "score", "recharge_reward", "all_reward", "recharge_time"
}

-- 嘉年华比赛
keyConfig.worldcarnival = {
	"id", "fighter", "watcher", "time", "battle_time"	
}

--活动屏蔽配置
keyConfig.validity = {
	"id","content"
}

--悬赏榜活动
keyConfig.mission = {
	"id","num","level","reward","day_reward","num_limit","des","gold_fame","gold_tpye","task","time","fame_scene","rank","cd"
}

-- 战魂重生活动
keyConfig.fsReborn = {
	"id", "vip_times", "silver",
}

--欢乐签到
keyConfig.happySign = {
	"id","des","icon","accumulateDay","reward","type","cost",
}

-- 充值送礼 add by yagrui 15-10-30
keyConfig.rechargeGift = {
	"id","expenseGold","reward","type",
}

-- 红包 llp
keyConfig.envelope = {
	"id","level","numlimit","goldlimit","daymax","time","messagenum","ActivityDes",
}

-- 补偿活动
keyConfig.actpayback = {
	"id","openTime","endTime","severTime","reward","testTime","testId","title","des",
}

--单充回馈 add by fuqiongqiong 2016.3.3
keyConfig.oneRecharge = {
	"id","payNum","payReward","activityExplain","daytimes","type",
}

-- 资源矿宝藏福利活动 add by bzx
keyConfig.mineralelves = {
	"id", "startTime", "endTime", "page", "number", "lastTime", "waitTime", "reward", "npc", "name", "desc", "expl", "openDay"
}

--节日狂欢活动 add by fuqiongqiong
keyConfig.festivalAct = {
	"id","seasonDes","background","background_efc","title","title_efc","character","Button1","Button2","start_time","end_time","mission1_desc","mission_1","mission2_desc","mission_2","mission3_desc","mission_3","mission4_desc","mission_4","exchange"
}

--节日狂欢活动奖励 add by fuqiongqiong
keyConfig.festivalActReward = {
	"id","bigtype","desc","typeId","finish","reset","reward","discount","cost","bugtimes","exchange","need","exchangetime","sihgleDes","sihgleCost","sihgleReward","sihgleTimes"
}

--限时基金活动 add by fuqiongqiong
keyConfig.limitFund = {
	"id","type","name","price","need_vip","gold","way","buy_time","total_time","max_times","explain"
}
-------------------------------------[[ 开服活动配置 ]]---------------------------------------------------------

function getNewServerData( key )
	local data = nil
	if(key == "spend") then
		data = DB_Xiaofei_leiji_kaifu.Xiaofei_leiji_kaifu
	elseif(key == "robTomb") then
		data = DB_Ernie_kaifu.Ernie_kaifu
	elseif key == "weal" then
		data = {
			id_11 = DB_WealActivity_kaifu.WealActivity_kaifu["id_11"]
		}
	end
	return data
end



local CGmConfig = {}

--[==[
@{
	name = Tab名称
	btnInfo = {
		Btn名称, 自定义参数(空格分隔), 调用方法(xxx)
	}
}
]==]

CGmConfig.gmConfig = {
	{
		name = "玩家属性",
		btnInfo = {
			{name = "添加物品", param = "$clone 10001 1"},
			{name = "清空背包", param = "$clearall"},

			-- {name = "增加金币", param = "$addsilver"},
			-- {name = "增加金币", param = "$addgold"},
			{name = "奖励水晶", param = "$addgoldcoin 目标玩家ID 10000"},
			{name = "奖励彩晶", param = "$addcolorcoin 目标玩家ID 10000"},
			{name = "奖励银币", param = "$rewardsilver 10000"},
			{name = "奖励金币", param = "$rewardcoin 目标玩家ID 1000000"},
			{name = "奖励经验", param = "$rewardexp 目标玩家ID 10000"},
			{name = "增加潜力点", param = "$addpoint 10000"},
			{name = "增加活力值", param = "$setenergy 10000"},

			{name = "设置名字", param = "$setname name"},
			{name = "更改门派", param = "$setschool 1"},
			{name = "更换造型", param = "$setshape 1"},
			{name = "添加伙伴", param = "$addpartner 501"},
			{name = "奖励勋章", param = "$rewardmedal 目标玩家ID 1000"},
			{name = "奖励荣誉", param = "$arenamedal 目标玩家ID 1000"},
			{name = "加公会资金", param = "$rewardorgcash 目标公会ID 10000"},
			{name = "加公会币", param = "$rewardorgoffer 目标玩家ID 10000"},
			{name = "加公会经验", param = "$rewardorgexp 目标公会ID 1000"},
			{name = "公会签到进度", param = "$addorgdegree 目标公会ID 1000"},
			{name = "加公会贡献", param = "$rewardorgoffer 目标玩家ID 10000"},
			{name = "皮肤券", param = "$addskin 目标玩家ID 10000"},
			{name = "增加称号", param = "$addtitle 1001"},
		}
	},
	{
		name = "战斗指令",
		btnInfo = {
			{name = "上传录像", param = "", fun = "#uploadwar"},
			{name = "远程上传", param = "", fun = "#remoteuploadwar 目标玩家ID"},
			{name = "观看战斗录像", param = "", fun = "#record"},
			{name = "剪切录像", param = "", fun = "#cutrecord"},
			{name = "法术测试", param = "", fun = "#pfmeditor"},
			{name = "多人PVP", param = "$testwar {101,102}"},
			{name = "战斗超时", param = "$wartimeover"},
			{name = "战斗结束", param = "$warend"},
			{name = "进入战斗", param = "$taskwar 10001"},
			{name = "增加怒气", param = "$addsp 100"},
			{name = "步进模式", param = "", fun = "ShowTestWarView"},
			{name = "手动保存战斗", param = "", fun = "#forcesaverecord"},
			{name = "战前准备", param = "", fun = "#warprepare"},
			{name = "打印速度", param = "", fun = "#timescale"},
			{name = "战斗debug", param = "", fun = "#wardebug"},
		}
	},
	{
		name = "GM Help",
		btnInfo = {
			{name = "GM指令集", param = "$help"},
			{name = "$clone", param = "$help clone"},
			{name = "$clearall", param = "$help clearall"},
			{name = "$testwar", param = "$help testwar"},
			{name = "$wartimeover", param = "$help wartimeover"},
			{name = "$rewardsilver", param = "$help rewardsilver"},
			{name = "$rewardexp", param = "$help rewardexp"},
			{name = "$addsilver", param = "$help addsilver"},
			{name = "$addpoint", param = "$help addpoint"},
			{name = "$rewardgold", param = "$help rewardgold"},
			{name = "$addtask", param = "$help addtask"},
			{name = "$cleartask", param = "$help cleartask"},
			{name = "$setenergy", param = "$help setenergy"},
			{name = "$map", param = "$help map"},
			{name = "$sendsys", param = "$help sendsys"},
			{name = "$addgoldcoin", param = "$help addgoldcoin"},
			{name = "$help", param = "$help help"},
			{name = "$addgold", param = "$help addgold"},
			{name = "$setschool", param = "$help setschool"},
			{name = "$setname", param = "$help setname"},
		}
	},
	{
		name = "聊天测试",
		btnInfo = {
			{name = "发送系统聊天信息", param = "$sendsys"}
		}
	},
	{
		name = "任务测试",
		btnInfo = {
			{name = "添加任务", param = "$addtask 113"},
			{name = "添加队伍任务", param = "$addteamtask 62000"},
			{name = "清除任务", param = "$cleartask"},
		}
	},
	{
		name = "地图测试",
		btnInfo = {
			{name = "跳到固定地图", param = "$map {id = 10002}"},
		}
	},
	{
		name = "伙伴指令",
		btnInfo = {
			{name = "增加伙伴", param = "$addpartner 301 1"},
			{name = "伙伴经验", param = "$addpartnerexp"},
			{name = "伙伴碎片", param = "$addpartneritem"},
			{name = "伙伴觉醒", param = "$awakepartner"},
			{name = "伙伴星级", param = "$addpartnerstar"},
			{name = "符文经验", param = "$addequipexp"},
			{name = "清空伙伴", param = "$clearpartner"},
			{name = "宅邸友好", param = "$house 101 1001 100000"},
			{name = "宅邸加礼物", param = "$houseclone 30601 1"},
			{name = "宅茶艺经验", param = "$house 104 1000"},
			{name = "宅特训时间", param = "$house 107 10"},
			{name = "宅加伙伴", param = "$house 108 1003"},
			{name = "宅总亲密", param = "$house 114 10000"},
			{name = "宅才艺时间", param = "$house 109 1"},
			{name = "友宅刷金币", param = "$house 110"},
			{name = "友加油次数", param = "$house 111"},
			{name = "友制作时间", param = "$house 112 10"},

		}
	},
	{
		name = "活动开关",
		btnInfo = {
			{name = "完成一次日程", param = "$addschedule"},
			{name = "开启竞技场", param = "$arenaon"},
			{name = "竞技场匹配AI", param = "$setaibattle"},
			{name = "开启世界BOSS", param = "$huodong worldboss 101"},
			{name = "突击测验", param = "huodong question 101 30 30"},
			{name = "学渣逆袭", param = "huodong question 102 30 30"},
			{name = "开启宫斗", param = "$huodong equalarena 103"},
			{name = "开协同比武", param = "$huodong teampvp 101"},
			{name = "离开协同比武", param = "$huodong teampvp 104"},
			{name = "开公会战", param = "$huodong orgwar 101"},
		}
	},
	{
		name = "系统设置",
		btnInfo = {
			{name = "游戏速度", param = "#testspeed 3"},
			{name = "触发存盘", param = "$savedb"},
			{name = "添加开服天数", param = "$addopenday"},
			{name = "清除新手引导记录", param = "$cleanguidance"},
			{name = "停止新手引导", param = "#banguide"},
			{name = "开启新手引导", param = "#openguide"},
			{name = "开启log", param = "#openlog"},
			{name = "关闭log", param = "#closelog"},
			{name = "设置sub渠道", param = "#setSubChannel kaopu"},
			{name = "设置渠道", param = "#setChannel kaopu"},
			{name = "设置gameType", param = "#setGameType hfzj"},
			{name = "开启在线更新", param = "#banupdatecode 1"},
			{name = "关闭在线更新", param = "#banupdatecode 0"},
			{name = "demi测试环境", param = "#demitest"},
			{name = "关闭审核创角", param = "#SetShenHeCreateRole 0"},
			{name = "开启审核创角", param = "#SetShenHeCreateRole 1"},
		}
	},
	{
		name = "本地测试",
		btnInfo = {
			{name = "远程调试", param = "", fun =[[#rpcfile 目标玩家ID]]},
			{name = "json测试" , param = "", fun = "#testjson"},
			{name = "支付测试", param = "", fun = "#testpay"},
			{name = "函数耗时debug", param = "", fun = "#debugtimer"},
			{name = "外网测试服地址", param = "", fun = "#testcsurl"},
			{name = "测试分享", param="", fun = "#testshare"},
			{name = "在线更新测试", param = "", fun = "#updatecode"},
			{name = "测试重连", param = "", fun = "#reconnect"},
			{name = "控制台", param = "", fun = "#console"},
			{name = "解压data包", param = "", fun = "#DumpLuaDataFile"},
			{name = "测试界面", param = "", fun = "#testview"},
			{name = "浮空时间", param = "", fun = "#FloatTimeFile"},
			{name = "地图时间", param = "", fun = "#maptime"},
			{name = "打印gc", param = "", fun = "#printgc"},
			{name = "调用gc", param = "", fun = "#gc"},
			{name = "lua内存", param = "", fun = "#luamem"},
			{name = "地图测试", param = "", fun = "#map 5000"},
			{name = "更新法术文件", param = "", fun = "#UpdateMagicFile"},
			{name = "替换lua文件", param = "", fun = "#LuaReplace"},
			{name = "本地更新", param = "", fun = "#LocalUpdate"},
			{name = "客户端登录", param = "", fun = "#clientlogin"},
			{name = "显示服务时间", param = "", fun = "#ShowServerTime"},
			{name = "profiler测试", param="", fun = "#testprofiler 50"},
			{name = "玩家移速快", param = "10", fun = "HeroSpeed"},
			{name = "模型测试", param = "", fun = "#shape 130"},
			{name = "武器测试", param = "", fun = "#weapon 2000"},
			{name = "跟随", param = "", fun = "#teamfollow"},
			{name = "造型动作测试", param = "", fun = "#ShowWalkerView"},
			{name = "敏感字测试", param = "", fun = "TestMaskWord"},
			{name = "syncpos", param = "", fun = "#printsyncpos"},
			{name = "巡逻", param = "", fun = "#xunluo"},
			{name = "心跳", param = "", fun = "#Beat 5"},
			{name = "普通坐骑", param = "", fun = "#horse 1"},
			{name = "飞行坐骑", param = "", fun = "#horse 2"},
			{name = "去掉坐骑", param = "", fun = "#horse"},
			{name = "语音测试", param="", fun = "#testspeech"},
			{name = "模拟收到语音", param="", fun = "#playerspeech 1"},
			{name = "phoneX测试", param="", fun = "#testphonex"},
		}
	},
	{
		name = "装备测试",
		btnInfo = {
			{name = "显示物品ID", param = "",fun = "OnShowItemID"},
			{name = "耐久度修改", param = "modifyitemlast 物品id -10"}
		}
	},
	{
		name = "安卓测试",
		btnInfo = {
			{name = "StartYsdkVip", param = "#testandroid1"},
			{name = "StartYsdkBbs", param = "#testandroid2"},
			{name = "GetLoginType", param = "#testandroid3"},
			{name = "IsNotSupported", param = "#testandroid4"},
		}
	},
	{
		name = "自定义1",
		btnInfo = {
			{name = "无敌模式", param = "supermode"},
			{name = "整点刷新", param = "hdnewhour"},
			{name = "每天重置", param = "newdaypl"},
			{name = "更换主角界面", param="", fun = "#changeAttrMainLayer"},
			{name = "隐藏GM按钮", param="", fun = "#HideGmBtn"},
			{name = "经验条数值开关", param="", fun = "#VisibleExpLabel"},
			{name = "强制停止寻路", param="", fun = "#ForceStopFindpath"},
			{name = "清除奖励次数", param="", fun = "#ClearMonitor"},
			{name = "NPC剧场编辑", param="", fun = "#DialogueNpcAnimationEdit"},
			{name = "剧场寻路编辑", param="", fun = "#DialogueLayerAniNaviEdit"},
			{name = "任务寻路", param="", fun = "#OepnTaskFindpath"},
			{name = "测试引导", param="", fun = "#TestGuide "},
			{name = "添加经验", param="", fun = "#AddMyExp "},
			{name = "跳过所有引导", param="", fun = "#PassGuide "},
			{name = "跳过开场动画", param="", fun = "#PassStart "},
			{name = "删除某引导", param="", fun = "#DelTargerGuide "},
			{name = "新手log开关", param="", fun = "#ToggleGuideLog "},
			{name = "输入引导数据", param="", fun = "#PrintGuideData "},
			{name = "完成指定引导", param="", fun = "#FinishTargeGuide "},
			{name = "暗雷寻路路径", param="", fun = "#testpath "},
			{name = "保存引导数据", param="", fun = "#SaveGuideConfigData"},	
			{name = "战力手册调试", param="", fun = "#PowerGuideDebug"},
			{name = "开启宅邸演示", param="", fun = "#OpenHouseMode"},
			{name = "关闭宅邸演示", param="", fun = "#CloseHouseMode"},
			{name = "显示关闭删档福利", param="", fun = "#ToggleFuliTest"},
		}
	},

}


-- [[测试按钮]]
CGmConfig.testConfig = {
	{name = "测试按钮", param = "参数1", fun = "OnTest1"},
}
return CGmConfig

StrConfig:Add(
{

	--小地图语言表
	['mainmenuMap01'] = "<font color='#ffcc33'>地图(快捷键:M)<br/>点击打开当前地图</font>",
	['mainmenuMap02'] = "<font color='#ffcc33'>打开邮件</font>",
	['mainmenuMap03'] = "<font color='#ffcc33'>设置</font>",
	['mainmenuMap04'] = "<font color='#ffcc33'>挂机设置</font>",
	['mainmenuMap05'] = '全屏',
	['mainmenuMap06'] = '取消全屏',
	['mainmenuMap07'] = '当前插件版本不支持全屏',
	['mainmenuMap08'] = "<font color='#ffcc33'>好友</font>",
	['mainmenuMap09'] = "<font color='#ffcc33'>组队</font>",
	['mainmenuMap10'] = '排行榜%s级后开启',
	['mainmenuMap11'] = "<font color='#ffcc33'>声音-关</font>",
	['mainmenuMap12'] = "<font color='#ffcc33'>屏蔽</font>",
	['mainmenuMap13'] = "<font color='#ffcc33'>更新公告</font>",
	['mainmenuMap14'] = "<font color='#ffcc33'>声音-开</font>",
	--技能栏语言表
	['mainmenuSkill01'] = '经验值：%s/%s',
	['mainmenuSkill02'] = '体力值：%s/%s',
	['mainmenuSkill03'] = '灵兽魂灵：%s/%s<br/>用于灵兽技能释放时消耗',
	['mainmenuSkill04'] = "当前灵兽：%s<br/><font size='12' color='#00FF00'>点击切换其他灵兽</font>",
	['mainmenuSkill10'] = "<font size='12' color='#00FF00'>点击切换其他灵兽</font>",
	['mainmenuSkill11'] = "拖动滑块设置自动吃药血量",
	['mainmenuSkill12'] = "拖动滑块设置自动吃药蓝量",
	['mainmenuSkill13'] = "<font color='#ffcc33'>体力值：</font><font color='#00ff00'>%s/%s</font><br/>体力值用于闪现技能消耗，体力值过低时，将无法使用体力技能。<br/><font color='#e56a10'>体力值随时间慢慢恢复，可使用体力恢复道具主动恢复。</font>",
	['mainmenuSkill14'] = "灵力值：%s/%s<br/>灵力可用于灵力炼制、境界灌注等。<br/>完成任务、击败怪物等可获得大量灵力。",
	['mainmenuSkill15'] = "跨服中,无法使用药品",
	
	--复活面板语言表
	-- ["mainmenuRevive01"] = "<font color='#d5b772'>%s级以后需要<u><font color='#00FF00'>%s</font></u>才可以原地复活",
	["mainmenuRevive01"] = "拥有：%s",
	-- ["mainmenuRevive02"] = "%s秒后自动回城复活 秒后未操作自动选择安全复活",
	["mainmenuRevive02"] = "秒后未操作自动选择“安全复活”",
	["mainmenuRevive000002"] = "%s",
	["mainmenuRevive03"] = "金钱不足",
	["mainmenuRevive04"] = "道具不足",

	["mainmenuRevive05"] = "安全复活",
	["mainmenuRevive06"] = "回城复活",
	["mainmenuRevive07"] = "<font color='#FAC41E'>玩家</font><u><font color='#00FF00'>%s</font></u>",
	["mainmenuRevive08"] = "<u><font color='#00FF00'>怪物</font></u>",
	["mainmenuRevive09"] = "<font color='#FAC41E'>您被%s击杀</u>",
	["mainmenuRevive10"] = "击杀时间：%s月%s日  %02d:%02d:%02d",


	--进度条
	["mainmenuProgress01"] = "剩余%s秒",


	-- 属性加点提示窗口
	["ealefapoint01"] = "<font color='#C8C8C8'>您有</font><font color='#29cc00'>%s属性点</font><font color='#C8C8C8'>可进行加点，</br>可以使你变得更强！</font>",
	
	--掉落查看
	["mainmenuDropInfo001"] = "您境界较低，无法查知全部掉落",
	["mainmenuDropInfo002"] = "掉落分配",
	["mainmenuDropInfo003"] = "点击查看掉落详情",

	--主界面头像
	["mainmenuHead001"] = "元宝：%s",
	["mainmenuHead002"] = "绑元：%s",
	["mainmenuHead003"] = "银两：%s",
	["mainmenuHead004"] = "<font size='16' color='#e0b715'>效率达人</font><br/><font color='#3780c8'>点击安装登录器</font><br/><font color='#3780c8'>通过登陆器进入游戏,杀怪经验<br/>+%s%%</font>",
	["mainmenuHead005"] = "<font size='16' color='#e0b715'>效率达人</font><br/><font color='#3780c8'>杀怪经验<font color = '#3780c8'>+%s%%</font></font>",
	["mainmenuHead006"] = "境界经验：%s",

	--主界面队伍
	["mainmenuTeam001"] = "%s人组队 <font color='#00ff00'>%s/%s</font>",
	["mainmenuTeam002"] = "未加入",

	--致命击杀文本
	["zhimingjiasha001"] = "%s个敌人被一击毙命",
	["zhimingjiasha002"] = "%s点额外经验值奖励",
	
	--PK提示
	['mainmenuNotPk001'] = '当前地图不可切换PK模式',

	-- 回城提示
	['backHome001'] = '当前CD未清零！',
	['backHome002'] = '当前场景不可传送',
	['backHome003'] = '当前在PK状态，不可传送',
	['backHome004'] = '当前场景是主城，无需传送',
	['backHome005'] = "<font size='16' color='#ffcc33'>回城</font><font color='#3bde1b'>(快捷键:P)</font>",
	['backHome006'] = "<font size='16' color='#ffcc33'>回城</font><font color='#3bde1b'>(快捷键:P)</font></font><font color='#cc0000'><br/>冷却时间: %s分</font>",

	-- 连续击杀，杀意值tips
	['shayizhitips001'] = '累计连续击杀可获得杀意，对普通怪物一击致命！<br/>当前累计击杀<font color = "#29cc00">%s</font>只怪物，继续击杀<font color = "#29cc00">%s</font>怪物可获得杀意，持续<font color = "#29cc00">%s秒</font><br/>杀意状态下击杀的怪物越多，获得的额外经验经越高！';

	
	
	--击杀信息框
	['killRecord1'] = '仇人名称',
	['killRecord2'] = '等级',
	['killRecord3'] = '死亡时间',
	['killRecord4'] = '死亡地点',
	['killRecord6'] = '击杀对象',
	['killRecord7'] = '等级',
	['killRecord8'] = '击杀时间',
	['killRecord9'] = '击杀地点',
	
	['killRecord20'] = '%s月%s日%s:%s',


	--灵力引导
	["lingliyindao101"] = "<font color='#00ff00'><u>宗门</u></font><font color='#b19a70'>自动汇聚</font>";
	["lingliyindao102"] = "<font color='#00ff00'><u>水果乐园活动</u></font><font color='#b19a70'>中采集灵力水果</font>";
	["lingliyindao103"] = "<font color='#00ff00'><u>帮派活动</u></font><font color='#b19a70'>奖励</font>";
	["lingliyindao104"] = "<font color='#b19a70'>日环任务奖励</font>";
	["lingliyindao105"] = "<font color='#b19a70'>奇遇任务几率获得</font>";
	["lingliyindao106"] = "<font color='#b19a70'>野外刷怪获得灵力丹</font>";
	["lingliyindao107"] = "";
	
	--自动挂机文本
	['autoBattleTxt001'] = "<strong><font color='#00FF00'>按“Z”键开始自动挂机</font></strong>",

	--- 公用提醒，进入副本，提示组队状态
	['fubenentertema001'] = "组队状态，无法进入，是否退出队伍并进入？",

	['mainmenuRevive11'] = "复活丹价格：%s绑元/个 或%s元宝/个。优先扣绑元",
	
	['mainmenu001'] = "活动中不可换线",
	['mainmenu002'] = "当前地图不可换线!",
	['mainmenu003'] = '再次点击地面可停止寻路',
	['mainmenu004'] = '已在当前线',
	['mainmenu005'] = '线不存在',
	['mainmenu006'] = '地图类型错误',
	['mainmenu007'] = '战斗状态中',
	['mainmenu008'] = '组队副本确认中，不可换线',
	['mainmenu009'] = '跨服匹配中,不可换线',

	["mainmenuHead101"] = "绑元：%s",

	["mainmenuMap101"] = "一线",
	["mainmenuMap102"] = "二线",
	["mainmenuMap103"] = "三线",
	["mainmenuMap104"] = "四线",
	["mainmenuMap105"] = "五线",
	["mainmenuMap106"] = "六线",
	["mainmenuMap107"] = "七线",
	["mainmenuMap108"] = "八线",
	["mainmenuMap109"] = "九线",
	["mainmenuMap110"] = "十线",

	
	["importantNotice1"] = '周%s%s-%s%s',
	
	['importantNotice01'] = '一',
	['importantNotice02'] = '二',
	['importantNotice03'] = '三',
	['importantNotice04'] = '四',
	['importantNotice05'] = '五',
	['importantNotice06'] = '六',
	['importantNotice07'] = '日',


	['mainmenutopbutton01']  = '%s级开启',
	['mainmenutopbutton02']  = '%s级开启',

	['hpbar1'] = '生命值:%s/%s',
	['mpbar1'] = '法力值:%s/%s',
	['mainmenuset1']='自动释放天神技能',
	['mainmenuset2']='关闭自动释放天神技能',


	['mainmenucommon1'] = "<font color='#ff0000'>%s秒</font><font color='#00ff00'>后自动关闭</font>",
	['importantNotice007'] = '%s秒后可复活',

	["mainmenuTianshen001"] = "功能未开启",


}
);
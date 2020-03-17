StrConfig:Add(
{
	['equip101'] = '当前升星成功率：%s',
	['equip102'] = "<u><font color='#00ff00'>%s</font></u>（使用升星失败后不掉级）",
	['equip103'] = '<u>%s%s颗</u>',
	['equip104'] = "<font color='#00ff00'><u>%s</u></font>",
	['equip105'] = "%s星",
	['equip106'] = "%s钻",
	['equip107'] = '自动升星',
	['equip108'] = '取消自动',
	['equip109'] = '装备战斗力',
	['equip111'] = [[<font color='#e59607' size='16'>自动升星:</font>
<font size='14'>自动升星所选装备</font><br/>
<font color='#ff8f43' size='14'>可自动升星至所选星级</font>
<font color='#ff8f43' size='14'>勾选自动购买，材料不足时将自动从商城购买所缺材料</font>
<font color='#ff8f43' size='14'>元宝或银两不足时自动中止</font>]],
	['equip112'] = [[<textformat leftmargin='5'><font color='#e59607' size='16'>升星规则:</font><img height='10'/>
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>1-15星为普通升星，每次升星100%成功。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>每次成功升星均可提升一定升星值，升星值满值后自动升至下一星。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>当前星级越高，消耗的升星石越多，提升星级获得属性越高。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>普通升星到15星后可进行高级升星，高级升星可获得大量属性
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>高级升星有成功率，升星失败后，有几率掉星，使用升星保护符可以确保升星失败后装备不掉星<img height='10'/></textformat>]],
	['equip113'] = '装备%s',--战斗力下面的那个属性
	['equip114'] = "<u><font color='#ff0000'>%s%s颗</font></u>",
	['equip115'] = "<font color='#ff0000'><u>%s</u></font>",
	['equip116'] = "<u><font color='#ff0000'>%s</font></u>（使用升星失败后不掉级）",
	['equip117'] = "点击升星获得升星进度<br/>升星进度条满值后自动提升至下一星级",
	['equip118'] = "<font color='#ff0000'><u>%s X%s</u></font>",
	['equip119'] = "<font color='#00ff00'><u>%s X%s</u></font>",
	['equip120'] = "最高+%s",
	['equip121'] = "本次升星可能掉级",
	['equip122'] = "防掉级道具不足",
	['equip123'] = "VIP3及以上可使用功能",
	['equip124'] = "<font color='#00ff00'>升星进度+%s</font>",
	['equip125'] = "<font color='#00ff00'>升星成功</font>",
	['equip126'] = "<font color='#00ff00'>开启高级升星</font>",
	['equip127'] = "<font color='#00ff00'>恭喜你！升星出15钻装备</font>",
	['equip128'] = "<font color='#ff0000'>升星失败</font>",
	['equip129'] = "<font color='#ff0000'>升星失败，装备升星等级-1</font>",
	['equip130'] = "装备%s",
	['equip131'] = "评分:",
	['equip132'] = "使用<font color='#ff0000'><u>%s</u></font>将当前装备直升1星",
	['equip133'] = "使用<font color='#00ff00'><u>%s</u></font>将当前装备直升1星",
	['equip134'] = "使用<font color='#ff0000'><u>%s</u></font>将当前装备直升到15星",
	['equip135'] = "使用<font color='#00ff00'><u>%s</u></font>将当前装备直升到15星",
	
	--传承tip
	['equip150'] = [[<textformat leftmargin='5'><font color='#e59607' size='16'>规则说明：</font><img height='10'/>
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>装备的升星星级可传承到新装备上。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>对非绑定装备进行传承后，装备将变为绑定状态。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>传承后，原装备与目标装备星级对换。<img height='10'/></textformat>]],
	['equip151'] = "<font color='#7896aa'>选择此项进行传承，目标装备等阶</font><br/><font color='#7896aa'>不低于原装备时，洗炼属性可全部</font><br/><font color='#7896aa'>传承到目标装备上。</font>",
	
	--传承弹出面板
	['equip152'] = "目标装备已升星过，确定要进行传承么？",
	['equip153'] = "非绑定装备传承后会变成绑定装备，是否继续？",
	--smart
	['equip218'] = [[<textformat leftmargin='5'><font color='#e59607' size='16'>升品规则:</font><img height='10'/>
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>只有<font color='#FFFFFF'>白色</font>、<font color='#29cc00'>绿色</font>、<font color='#0099FF'>蓝色</font>装备可进行升品。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>吞噬不同等级、品质的装备获得吞噬进度值不同，等级、品质越高获得的进度值越高。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>未升品成功的装备在被吞噬后，之前的进度值会增加到新的装备上。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>一键吞噬会自动吞噬掉背包内所选品质的装备。<img height='10'/></textformat>]],
	['equip219'] = "及以下品质",
	['equip220'] = "品质",
	['equip221'] = "请选取装备后进行噬魂",
	['equip222'] = "当前无可吞噬装备",
	['equip223'] = "已达升品上限，无法提升！",
	["equip224"] = "<font color='#FFFFFF'>%s</font><font color='#29CC00'>(+%s)</font><font color='#FFFFFF'>/%s</font>",
	['equip225'] = "请先选择想要升品的装备，仅限当前身上装备",
	['equip226'] = "当前装备无法升品",
	['equip227'] = "当前无装备可吞噬",
	['equip228'] = "请选取装备",
	['equip229'] = "无",
	['equip230'] = "及以上品质",
	
	['equip250'] = "该装备未曾升星，无法传承",
	['equip251'] = "元宝不足，无法传承",
	['equip252'] = "银两不足，无法传承",
	['equip253'] = "目标装备升星等级高于原装备，无法传承",
	['equip254'] = "道具不足，无法传承",
	['equip255'] = "未选择目标装备",
	['equip256'] = "未选择原装备",
	['equip257'] = "升品成功",
	['equip258'] = "该装备没有追加等级，无法传承",
	['equip259'] = "源装备和目标装备不能相同",
	['equip260'] = "目标装备追加等级高于原装备，无法传承",
	['equip261'] = "追加属性传承成功",
	['equip262'] = "升星属性传承成功",
	['equip263'] = "目标装备升星等级等于原装备，无法传承",
	['equip264'] = "目标装备追加等级等于原装备，无法传承",
	
	['equip301'] = [[<textformat leftmargin='5'><font color='#e59607' size='16'>宝石规则:</font><font color='#dcdcdc'><img height='10'/>
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>消耗宝石碎片对宝石进行激活和升级。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>装备宝石位随玩家等级进行开放。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>宝石属性绑定装备位，不会因更换装备而丢失。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>全身宝石达到指定等级后将获得奖励。<img height='10'/></font></textformat>]],
	['equip302'] = "<font color='#FFCC33' size='14'>%s  %s</font>",
	['equip303'] = "<font color='#ff0000' size='16'>%s级开启</font>",
	['equip304'] = "<font color='#e59607' size='16'>宝石总属性</font><br/>%s",
	['equip305'] = "<font color='#00ff00' size='16'>可激活</font>",
	['equip306'] = "<font color='#e59607' size='16'>下级预览：</font><br/><font color='#d5b772'>%s<font/><font color='#00ff00'>   +%s<br/>",
	['equip307'] = "<font color='#%s' size='14'><u>%s%s个</u></font>",
	['equip308'] = "请选择要升级的宝石",
	['equip309'] = "级",
	['equip310'] = "<font color='#e59607' size='16'>宝石附加属性<br/></font><p><img width='181' height='2' align='baseline' src='%s'/></p><font color='#a0a0a0' size='14'>当前所有的宝石全部达<br/>到%s级后开启</font><br/><font color='#dc2f2f' size='14'>当前条件不足（%s/33）</font>",
	['equip311'] = "<font color='#e59607' size='16'>宝石附加属性<br/></font><p><img width='181' height='2' align='baseline' src='%s'/></p><font color='#a0a0a0' size='14'>宝石全部等级达到%s级后附<br/>加属性</font><br/>%s",
	['equip312'] = "<font color='#%s' size='14'><u>%s</u></font>",
	['equip313'] = "道具不足，无法升级",
	['equip314'] = "<font color='#e59607' size='16'>宝石规则:<br/></font>未获得任何宝石属性",
	['equip315'] = "未获得属性",
	['equip316'] = "升级",
	['equip317'] = "激活",

	['equip400'] = "<font color='#29cc00'><u>传承石%s个</u></font>",
	['equip401'] = "<font color='#ff0000'><u>传承石%s个</u></font>",
	
	['equip501'] = [[<textformat leftmargin='5'><font color='#e59607' size='16'>觉醒规则:</font><img height='10'/>
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>卓越觉醒可以为装备携带的卓越属性进行额外加成，觉醒等级越高，加成越多。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>卓越觉醒等级绑定装备位，不会因更换装备而丢失。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>卓越觉醒加成与装备上的卓越属性为一一对应的，当前穿戴装备上没有卓越属性，觉醒等级将不提供任何加成。<img height='10'/></textformat>]],
	['equip502'] = "<font color='#ff0000'>未觉醒   该部位卓越属性无法加成</font>",
	['equip503'] = "觉醒%s重  <font color='#29CC00'>该部位卓越属性加成%s%%</font>",
	['equip504'] = "已到最大觉醒等级",
	['equip505'] = "银两不足!",
	['equip506'] = "元宝不足，无法购买!",
	['equip507'] = "道具不足!",
	['equip508'] = "觉醒%s重",
	['equip509'] = "<font color='#29CC00'>属性加成%s%%</font>",
	['equip510'] = "<font color='#5a5a5a'>未觉醒</font>",
	['equip511'] = "元宝不足!",
	
	['equip601'] = [[<textformat leftmargin='5'><font color='#e59607' size='16'>附加属性:</font><img height='10'/>
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>装备的附加属性在装备获取时随机生成。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>附加属性为各种特殊属性，可提供大量加成。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>装备等阶越高、品质越好，可能获得的附加属性就越好。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>附加属性可以通过装备铭刻玩法进行替换。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>当对一个已有附加属性的位置孔内铭刻时，原附加属性将自动放入附加属性仓库。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>装备的附加属性可以直接剥离至属性仓库<img height='10'/></textformat>]],
	['equip602'] = "<font color='#DEB887'>已剥离（可在打造-铭刻功能内铭刻新的附加属性）</font>",
	['equip603'] = "<font color='#DEB887'>可铭刻（选择右侧卓越属性列表内属性进行铭刻）</font>",
	['equip604'] = "<font color='#ff0000'>(未觉醒 属性无法加成)</font>",
	['equip605'] = "(觉醒%s重 该属性加成%s%%)",
	['equip606'] = "剥	离",
	['equip607'] = "铭	刻",
	['equip608'] = "请选择一条库属性!",
	['equip609'] = "确定删除一条库属性？",
	['equip610'] = "该位置没有附加属性!",
	['equip611'] = "属性库已满，无法剥离！",
	['equip612'] = "不存在的库属性！",
	['equip613'] = "请先移除目标位置的属性！",
	['equip614'] = "不存在的孔!",
	['equip615'] = "同一装备不能铭刻两个同类型属性!",
	['equip616'] = "将属性库内的附加属性镶嵌到此装备上",
	['equip617'] = "将装备上的附加属性剥离至属性库",
	['equip618'] = "是否替换目标位置的附加属性?",
	['equip619'] = "获得附加属性：%s",
	['equip620'] = "该属性不可剥离",
	['equip621'] = "获得附加属性<br/>%s",
	['equip622'] = "获得附加属性:<font color='#29cc00'>%s</font>",
	['equip623'] = "高级升星功能，敬请期待！",

	--------------------- 炼化
	['equip900'] = [[<textformat leftmargin='5'><font color='#e59607' size='16'>强化规则:</font><font color='#dcdcdc'><img height='10'/>
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>对装备位进行强化，根据强化等级增加属性。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>强化等级不可超过人物自身等级。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>强化消耗灵力，一键强化对全身装备位进行一次强化。</font></textformat>]],
	['equip901'] = '%s +%s',
	['equip902'] = '%s %%',
	['equip903'] = '<u>%s 银两</u>',
	['equip904'] = '银两不足，无法强化！',
	['equip905'] = '<font color="#29cc00">强化成功</font>',
	['equip906'] = '<font color="#29cc00">一键强化成功</font>',
	['equip907'] = '未穿装备',
	['equip908'] = '强化失败',
	['equip909'] = '一键强化：对全身可强化装备位进行一次强化。 <br/>单件强化消耗：%s灵力<br/>一键强化消耗：%s灵力',
	['equip910'] = '已达人物等级上限',
	['equip911'] = '已达最大等级',
	['equip912'] = '<u><font color="#960000">%s 灵力</font></u>',
	['equip913'] = '<font color="#c8c8c8">%s</font> +%s',
	['equip914'] = "<font color='#e59607' size='16'>    银两获得途径</font><br/><img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/><p><font size='14'>从宗门中获得</font></p><img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/><p><font size='14'>从日常活动、任务中获得</font></p>";
	
	['equip1001'] = "请选择装备",
	['equip1002'] = "<font color='#29cc00'>装备已成功转换为%s套装</font>",

	-------------------熔炼
	['equip1101'] = '<font color="#ffffff">白色品质</font>',
	['equip1102'] = '<font color="#00b7ef">蓝色品质</font>',
	['equip1103'] = '<font color="#b324f6">紫色品质</font>',
	['equip1111'] = '%s:   <font color="#c8c8c8">+%s</font>',
	
	['equip1201'] = "开孔",
	['equip1202'] = "是否消耗<font color='%s'>%s*%s</font>开启一个铭刻孔?",
	['equip1203'] = "开铭刻孔失败",

	--物品使用消耗提示
	['equip1301'] = "使用道具需花费：%s,<br/>是否确认使用？",

	["equipWash001"] = "<font color='%s'>(%s/%s)</font>",
	["equipWash002"] = [[<textformat leftmargin='5'><font color='#e59607' size='16'>重铸规则:</font><font color='#dcdcdc'><img height='10'/>
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>可以对装备的卓越属性进行重铸，重新选择卓越属性。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>重铸时，卓越属性随机获得，选择想要保存的卓越属性进行保存。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>重铸消耗随装备阶数变化，高阶装备消耗更多。</font></textformat>]],
	["equipWash003"] = "<font color='#00ff00'>保存成功，卓越属性已被替换!</font>",
	["equipWash004"] = "您已重铸到极品属性，是否继续？",
	["equipWash005"] = "您当前是极品属性，是否重铸",



	["equip624"] = "您确定销毁，这些属性吗？",
	["equip625"] = "<font color = '#00ff00'>删除成功</font>",
	["equip626"] = "点击批量删除按钮，然后批量选中附加属性后确认删除",
	["equip627"] = "请选择要删除的属性",
	['equip628'] = [[<textformat leftmargin='5'><font color='#e59607' size='16'>精炼规则:</font><font color='#dcdcdc'><img height='10'/>
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>可以对装备的卓越属性值进行精炼，提升属性值。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>精炼时属性值随机增加，选定保存。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>精炼消耗随装备阶数变化，高阶装备消耗更多。</font></textformat>]],
	['equip629'] = '待保存',
	['equip630'] = '精炼',
	['equip631'] = '最大',
	['equip632'] = '放入想要精炼的卓越装备',
	['equip633'] = '属性已达最大值，无需精练！',
	['equip634'] = '您确定使用这些属性生成卷轴吗？',
	['equip635'] = '生成卷轴成功',
	['equip637'] = '请选择要生成卷轴的属性',
	['equip638'] = '点击生成卷轴按钮，然后批量选中附加属性后确认生成',
	['equip639'] = "使用<font color='#ff0000'><u>%s</u></font>将当前装备直升1钻",
	['equip640'] = "使用<font color='#00ff00'><u>%s</u></font>将当前装备直升1钻",
	['equip641'] = [[<textformat leftmargin='5'><font color='#e59607' size='16'>启灵规则:</font><font color='#dcdcdc'><img height='10'/>
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>可以对装备的卓越属性值进行启灵，提升属性值。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>启灵时，随机选择一条属性值进行启灵。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>启灵有几率失败，失败后增加幸运值，提升下次启灵的成功率。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>成功启灵后，幸运值清空。
<img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/>启灵消耗随装备阶数变化，高阶装备消耗更多。</font></textformat>]],	
	
	['equip1001'] = "启灵失败",
	['equip1002'] = "已到最大启灵值",
	['equip1003'] = '请选择装备',
	['equip1004'] = '放入想要启灵的卓越装备',

	['equip2002'] = "不可开启",
	['equip2003'] = "已达可开启上线",
	['equip2004'] = "选中解锁该装备位套装",
	['equip2005'] = "选中镶嵌该装备位套装",
	['equip2006'] = "个",
	['equip2007'] = "当前装备位还可解锁套装数量：%s",
	['equip2008'] = "已达到开孔上限",
	['equip2009'] = "<u>已达最大等级</u>",
	['equip2010'] = "已达最大等级",
----------Venus---------
	['equip00000001'] = "装备强化石不足，无法强化",
	['equip00000002'] = "<font color='#e59607' size='16'>    装备强化石获得途径</font><br/><img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/><p><font size='14'>从宗门中获得</font></p><img width='15' height='15' vspace='-2' src='img://resfile/icon/rulePoint.png'/><p><font size='14'>从日常活动、任务中获得</font></p>";

}
)
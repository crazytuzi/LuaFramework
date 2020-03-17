--pos 0无 1左边冒泡 2右边冒泡
--


-- 配置方式按照如下步骤(多语言支持) 2015年12月9日15:51:28
--   1. 在表1里面按照现有格式配置文本;
--   2. 将配好的文本的key配入表2；



--表1
StrConfig:Add(
{
	["TalkStringConfig1"]     = "哼，无知宵小，你对力量一无所知！",
	["TalkStringConfig2"]     = "我们四人合力将星辰之力注入你的经脉之中，教会你占星之术，在今后将助你修为突飞猛进！",
	["TalkStringConfig3"]     = "现在我将施展秘术招出上古神魔……",
	["TalkStringConfig4"]     = "此神魔战力非凡，在上古时期曾经斩杀无数仙神，万万不可掉以轻心，你且小心了！",
	["TalkStringConfig5"]     = "好好享受蜘蛛女王的爱抚吧！哈哈哈哈哈哈……",
	["TalkStringConfig6"]     = "这里，就是你们的葬身之地！",
	["TalkStringConfig7"]     = "你刚才受伤了，这枚灵药可以缓解伤势。",
	["TalkStringConfig8"]     = "啊……",
	["TalkStringConfig9"]     = "有了这漂亮的小妞，就不怕你们两个命运之子不上钩了，哈哈哈哈……",
	["TalkStringConfig10"]    = "不好，有人来了！",
	["TalkStringConfig11"]    = "不愧是有千年历史的北苍城。",
	["TalkStringConfig12"]    = "牧尘，救我……",
	["TalkStringConfig13"]    = "好厉害的神翼！域外邪族，我必将击溃你们的阴谋！",
	["TalkStringConfig14"]    = "红绫姐让我告诉你，看在你帮了牧尘的份上，这匹坐骑就送给你了。",
	["TalkStringConfig15"]    = "一群废物，不过是一个小小的命运之子，也需要老子亲自出马！",
	["TalkStringConfig16"]    = "看来我们必须要拿到学院大比的冠军了！",
	["TalkStringConfig17"]    = "哈哈哈哈，想赢我柳慕白，再过五百年吧！",
	["TalkStringConfig18"]    = "为什么会突然出现毒雾灵阵阻我去路？",
	["TalkStringConfig19"]    = "救命……救命啊！！你们……你们是谁，不要过来，不要啊！",
	["TalkStringConfig20"]    = "小妞，你喊破喉咙也不会有人来救你，乖乖闭嘴，不然……嘿嘿嘿，就别怪我辣手摧花了~",
	["TalkStringConfig21"]    = "啊……滚开，不要碰我啊！！牧尘快来救我啊！！！",
	["TalkStringConfig22"]    = "以吾之眼，观大千万物，千里觅踪！",
	["TalkStringConfig23"]    = "吼……",
	["TalkStringConfig24"]    = "你们，无处可逃！",
	["TalkStringConfig25"]    = "接受我的怒火吧，弱者！",
	["TalkStringConfig26"]    = "域外圣族，永垂不朽！！！",
	["TalkStringConfig27"]    = "成为我称霸大千世界的祭品吧！弱者！",
	["TalkStringConfig28"]    = "力量……力量喷涌而出了！",
	["TalkStringConfig29"]    = "邪神大人，赐予我力量吧！",
	["TalkStringConfig30"]    = "绝不会让你们去救唐芊儿！",
	["TalkStringConfig31"]    = "吃我大棒！",
	["TalkStringConfig32"]    = "我域外圣族，必将重回大千！",
	["TalkStringConfig33"]    = "想要通知牧尘救人？先问问本尊的大棒答不答应！",
	["TalkStringConfig34"]    = "真是匹不可多得的神驹，这样应该很快就能追上牧尘了！",
	["TalkStringConfig35"]    = "咦，好美的珠子。",
	["TalkStringConfig36"]    = "暂且饶你一命，若不是老子被毒阵反噬，岂会容尔等猖狂！",
	["TalkStringConfig37"]    = "事情紧急，我先去拦截魔龙子，你去前面通知我的父亲！",
	["TalkStringConfig38"]    = "你们这群废物还想去救人？域外邪神的力量必将毁灭一切！",
	["TalkStringConfig39"]    = "牧尘，你果然来了，没有让我失望。",
	["TalkStringConfig40"]    = "我答应过你的事，当然要做到，否则将来怎么迎娶我的小洛璃？",
	["TalkStringConfig41"]    = "呸，谁说要嫁给你了！色狼……",
	["TalkStringConfig42"]    = "我的体内，充满了力量！这……就是和九幽雀合体后的感觉么！",
	["TalkStringConfig43"]    = "域外邪神已经赐予了我无穷的力量，你们逃不出我的手掌心！哈哈哈哈……",
	["TalkStringConfig44"]    = "一颗散发着强大能量的灵兽蛋，这定是温清璇所说的九幽雀的蛋。",
	["TalkStringConfig45"]    = "这猛烈的震动……看来九幽雀要破壳而出了！",
	["TalkStringConfig46"]    = "是谁，胆敢在我渡劫之际打扰我？！你这是自寻死路！",
	["TalkStringConfig47"]    = "唳……",
	["TalkStringConfig48"]    = "这么强大的力量，难道是传说中的圣器？",
	["TalkStringConfig49"]    = "这里……这里怎么会有人在洗澡？",
	["TalkStringConfig50"]    = "芊儿早已不在此处，那柄剑上似乎刻印着‘龙魔宫’三字，难道是龙魔宫之人将芊儿抓走的？",
	["TalkStringConfig51"]    = "那个小美人就在我手里，不过你们永远也别想救出她，哈哈哈哈……",
	["TalkStringConfig52"]    = "怎么会这样！域外邪神赐予我的力量正在流失！不！！",
	["TalkStringConfig53"]    = "你们以为击败我，就能救回唐芊儿？等着吧，黑暗，才刚刚降临！",
	["TalkStringConfig54"]    = "魔龙子竟然如此谨慎，布防如此严密，看来是无法潜入进去了。",
	["TalkStringConfig55"]    = "你小子怎么回事，赶紧回去站好！魔龙子大人怪罪下来你就死定了！",
	["TalkStringConfig56"]    = "是，我马上就回去，还请统领息怒。",
	["TalkStringConfig57"]    = "牧尘真的来到北苍灵院了吗？我果然没有看错他……",
	["TalkStringConfig58"]    = "如此圣器，你这废物不配用，还是交给我域外时空邪王来保管吧！",
	["TalkStringConfig59"]    = "这圣器我就先拿走了，哈哈哈哈……",
	["TalkStringConfig60"]    = "果然不愧为绝世圣器，你们这群神族的渣渣，去死吧！",
	["TalkStringConfig61"]    = "不，我怎么会输！我还会回来的！",
	["TalkStringConfig62"]    = "这就是绝世圣器吗？好强大的力量。",
	["TalkStringConfig63"]    = "唔……天至尊秘籍中蕴藏的炼体之力，果然强大！",
	["TalkStringConfig64"]    = "哈哈哈哈，好强大的力量，这天下还有谁能奈何的了我！",
	["TalkStringConfig65"]    = "域外时空邪王，看老夫破了你的炼体之力——圣光神罚！",
	["TalkStringConfig66"]    = "不！！！炼体之力正在流失！不！！",
	["TalkStringConfig67"]    = "我……不甘心……",
	["TalkStringConfig68"]    = "这就是天至尊秘籍吗？",
	["TalkStringConfig69"]    = "多亏少侠相助，破坏护盾，看我砸烂这牢笼，喝！",
	["TalkStringConfig70"]    = "少侠拯救了我灵兽帝国，为表谢意，今后我的子民便作为少侠的坐骑吧。",
	["TalkStringConfig71"]    = "如此，多谢陛下了。",
	["TalkStringConfig72"]    = "域外邪族的杂碎，我绝不会放过你们！",
	["TalkStringConfig73"]    = "就让我伴你，主宰大千世界吧！",
	["TalkStringConfig74"]    = "牧尘，牧尘！救我！",
	["TalkStringConfig75"]    = "想救唐芊儿？下辈子吧！！哈哈哈哈……",
	["TalkStringConfig76"]    = "你所找之人，就在前方……",
	["TalkStringConfig77"]    = "呜呜……你们终于来了，呜呜……",
	["TalkStringConfig78"]    = "牧尘，你终于……终于来救我了……",
	["TalkStringConfig79"]    = "芊儿姐不哭了，没事了……",
	["TalkStringConfig80"]    = "良辰吉时已到，婚礼开始！",
	["TalkStringConfig81"]    = "真是郎才女貌，祝你们永结同心、百年好合、早生贵子哦~",
	["TalkStringConfig82"]    = "唉，今天我就不该来，虐哭单身狗啊~要爱护动物你们知不知道！",
	["TalkStringConfig83"]    = "你在结婚的殿堂上笑靥如花，我在孤单的角落里吹着唢呐。",
	["TalkStringConfig84"]    = "一拜天地。",
	["TalkStringConfig85"]    = "二拜高堂。",
	["TalkStringConfig86"]    = "夫妻对拜。",
	["TalkStringConfig87"]    = "送入洞房！",
	["TalkStringConfig10001"] = "我们柳域必将借助域外圣族的力量崛起！",
	["TalkStringConfig10002"] = "命运之子一定会死在我的手里，哈哈哈哈！",
	["TalkStringConfig10003"] = "为了域外邪冥王大人，我甘愿奉献我的身体，我的一切！",
	["TalkStringConfig10004"] = "命运之子算什么东西？我有域外圣族赐予的力量，战无不胜！",
	["TalkStringConfig10005"] = "疯狂吧，让我们一起疯狂吧！不疯狂，就灭亡！",
	["TalkStringConfig10006"] = "老子长得这么丑，你也下得了手？",
	["TalkStringConfig10007"] = "他们都说我长得猥琐，这是为什么呢？",
	["TalkStringConfig10008"] = "最讨厌那些杀完怪还不捡东西的玩家了。",
	["TalkStringConfig10009"] = "唐芊儿那小妞儿还真是水灵啊。",
	["TalkStringConfig10010"] = "看到我，你还不跑，我只能佩服你的勇气，虽然那并没什么卵用。",
	["TalkStringConfig10011"] = "没有强化装备的你，是无法抵挡我的大棒的！",
	["TalkStringConfig10012"] = "爱护环境，人人有责。奴仆也是有人权的！",
	["TalkStringConfig10013"] = "我的利爪和尖牙将撕碎你！",
	["TalkStringConfig10014"] = "感谢GM，给了我说话的权力，但是我还是要撕碎你！",
	["TalkStringConfig10015"] = "仇恨和嫉妒，将燃烧你的内心",
	["TalkStringConfig10016"] = "虽然我是个亡灵，但我也有爱情。",
	["TalkStringConfig10017"] = "如果你因为我没有腿而小看我话，你一定会后悔的",
	["TalkStringConfig10018"] = "我像不像绿巨人？",
	["TalkStringConfig10019"] = "蜥蜴也是会吃人的！",
	["TalkStringConfig10020"] = "如果我有两把刀，我一定为姬玄大人两肋插刀",
	["TalkStringConfig10021"] = "我又闻到了血肉的味道了",
	["TalkStringConfig10022"] = "想见九幽大人，先过我这关",
	["TalkStringConfig10023"] = "弱者，你没有资格过去！",
	["TalkStringConfig10024"] = "如果我有一双翅膀，我就起飞了",
	["TalkStringConfig10025"] = "变成我的粪便吧，弱者！",
	["TalkStringConfig10026"] = "虽然我名字里有统领，但是我真不是统领",
	["TalkStringConfig10027"] = "这年头，想弄把趁手的武器还真是难啊",
	["TalkStringConfig10028"] = "我会把你一寸一寸的撕碎吃掉！",
	["TalkStringConfig10029"] = "弱者是没有资格获得传承的",
	["TalkStringConfig10030"] = "来吧，让我杀了你。",
	["TalkStringConfig10031"] = "只有真正的神兵，才能撕裂我的护甲！",
	["TalkStringConfig10032"] = "有资格背叛的人，才能叫叛徒。你，只是渣渣而已！",
	["TalkStringConfig10033"] = "战阵与灵阵是相通的！",
	["TalkStringConfig10034"] = "像我这么帅的，为什么不是主角",
	["TalkStringConfig10035"] = "我会打的你说不出话来！",
	["TalkStringConfig10036"] = "如果你还是这么弱，你们必将被毁灭！",
	["TalkStringConfig10037"] = "没有任务就不要来骚扰我，又没有奖励，你是不是傻？",
	["TalkStringConfig10038"] = "喂喂，打我之前能不能动动脑子？没有任务就没有奖励啊，亲！",
	["TalkStringConfig10039"] = "就算你把我干爆了也没有用啊，大兄弟！没有任务就没有奖励啊！",
	["TalkStringConfig10040"] = "你瞅啥？没有任务打我是没有奖励的！再瞅我我不客气了啊！",
}
)








--表2
_G.TalkStringConfig=
{
	[1]={title="",talk=StrConfig["TalkStringConfig1"], pos=0},
	[2]={title="",talk=StrConfig["TalkStringConfig2"], pos=0},
	[3]={talk=StrConfig["TalkStringConfig3"], pos=2},
	[4]={talk=StrConfig["TalkStringConfig4"], pos=1},
	[5]={talk=StrConfig["TalkStringConfig5"], pos=0},
	[6]={talk=StrConfig["TalkStringConfig6"], pos=0},
	[7]={talk=StrConfig["TalkStringConfig7"], pos=0},
	[8]={talk=StrConfig["TalkStringConfig8"], pos=0},
	[9]={talk=StrConfig["TalkStringConfig9"], pos=0},
	[10]={talk=StrConfig["TalkStringConfig10"], pos=0},
	[11]={talk=StrConfig["TalkStringConfig11"], pos=0},
	[12]={talk=StrConfig["TalkStringConfig12"], pos=0},
	[13]={talk=StrConfig["TalkStringConfig13"], pos=0},
	[14]={talk=StrConfig["TalkStringConfig14"], pos=0},
	[15]={talk=StrConfig["TalkStringConfig15"], pos=0},
	[16]={talk=StrConfig["TalkStringConfig16"], pos=0},
	[17]={talk=StrConfig["TalkStringConfig17"], pos=0},
	[18]={talk=StrConfig["TalkStringConfig18"], pos=0},
	[19]={talk=StrConfig["TalkStringConfig19"], pos=0},
	[20]={talk=StrConfig["TalkStringConfig20"], pos=0},
	[21]={talk=StrConfig["TalkStringConfig21"], pos=0},
	[22]={talk=StrConfig["TalkStringConfig22"], pos=0},
	[23]={talk=StrConfig["TalkStringConfig23"], pos=1},
	[24]={talk=StrConfig["TalkStringConfig24"], pos=0},
	[25]={talk=StrConfig["TalkStringConfig25"], pos=0},
	[26]={talk=StrConfig["TalkStringConfig26"], pos=0},
	[27]={talk=StrConfig["TalkStringConfig27"], pos=0},
	[28]={talk=StrConfig["TalkStringConfig28"], pos=0},
	[29]={talk=StrConfig["TalkStringConfig29"],pos=0},
	[30]={talk=StrConfig["TalkStringConfig30"],pos=0},
	[31]={talk=StrConfig["TalkStringConfig31"],pos=0},
	[32]={talk=StrConfig["TalkStringConfig32"],pos=0},
	[33]={talk=StrConfig["TalkStringConfig33"],pos=0},
	[34]={talk=StrConfig["TalkStringConfig34"],pos=0},
	[35]={talk=StrConfig["TalkStringConfig35"],pos=0},
	[36]={talk=StrConfig["TalkStringConfig36"],pos=0},
	[37]={talk=StrConfig["TalkStringConfig37"],pos=0},
	[38]={talk=StrConfig["TalkStringConfig38"],pos=0},
	[39]={talk=StrConfig["TalkStringConfig39"],pos=0,offsetY = 100},
	[40]={talk=StrConfig["TalkStringConfig40"],pos=0,offsetX = -60, offsetY = 50},
	[41]={talk=StrConfig["TalkStringConfig41"],pos=0,offsetY = 100},
	[42]={talk=StrConfig["TalkStringConfig42"],pos=0},
	[43]={talk=StrConfig["TalkStringConfig43"],pos=0},
	[44]={talk=StrConfig["TalkStringConfig44"],pos=0},
	[45]={talk=StrConfig["TalkStringConfig45"],pos=0},
	[46]={talk=StrConfig["TalkStringConfig46"],pos=0},
	[47]={talk=StrConfig["TalkStringConfig47"],pos=0},
	[48]={talk=StrConfig["TalkStringConfig48"],pos=0},
	[49]={talk=StrConfig["TalkStringConfig49"],pos=0},
	[50]={talk=StrConfig["TalkStringConfig50"],pos=0},
	[51]={talk=StrConfig["TalkStringConfig51"],pos=0},
	[52]={talk=StrConfig["TalkStringConfig52"],pos=0},
	[53]={talk=StrConfig["TalkStringConfig53"],pos=0},
	[54]={talk=StrConfig["TalkStringConfig54"],pos=0},
	[55]={talk=StrConfig["TalkStringConfig55"],pos=0, offsetY = -30},
	[56]={talk=StrConfig["TalkStringConfig56"],pos=0, offsetY = -30},
	[57]={talk=StrConfig["TalkStringConfig57"],pos=0, offsetY = -30},
	[58]={talk=StrConfig["TalkStringConfig58"],pos=0},
	[59]={talk=StrConfig["TalkStringConfig59"],pos=0},
	[60]={talk=StrConfig["TalkStringConfig60"],pos=0},
	[61]={talk=StrConfig["TalkStringConfig61"],pos=0},
	[62]={talk=StrConfig["TalkStringConfig62"],pos=0},
	[63]={talk=StrConfig["TalkStringConfig63"],pos=0},
	[64]={talk=StrConfig["TalkStringConfig64"],pos=0},
	[65]={talk=StrConfig["TalkStringConfig65"],pos=0},
	[66]={talk=StrConfig["TalkStringConfig66"],pos=0},
	[67]={talk=StrConfig["TalkStringConfig67"],pos=0},
	[68]={talk=StrConfig["TalkStringConfig68"],pos=0},
	[69]={talk=StrConfig["TalkStringConfig69"],pos=0},
	[70]={talk=StrConfig["TalkStringConfig70"],pos=0},
	[71]={talk=StrConfig["TalkStringConfig71"],pos=0},
	[72]={talk=StrConfig["TalkStringConfig72"],pos=0},
	[73]={talk=StrConfig["TalkStringConfig73"],pos=0},
	[74]={talk=StrConfig["TalkStringConfig74"],pos=0},
	[75]={talk=StrConfig["TalkStringConfig75"],pos=0},
	[76]={talk=StrConfig["TalkStringConfig76"],pos=0},
	[77]={talk=StrConfig["TalkStringConfig77"],pos=0},
	[78]={talk=StrConfig["TalkStringConfig78"],pos=0},
	[79]={talk=StrConfig["TalkStringConfig79"],pos=0},
	[80]={talk=StrConfig["TalkStringConfig80"],pos=0},
	[81]={talk=StrConfig["TalkStringConfig81"],pos=0},
	[82]={talk=StrConfig["TalkStringConfig82"],pos=0},
	[83]={talk=StrConfig["TalkStringConfig83"],pos=0},
	[84]={talk=StrConfig["TalkStringConfig84"],pos=0},
	[85]={talk=StrConfig["TalkStringConfig85"],pos=0},
	[86]={talk=StrConfig["TalkStringConfig86"],pos=0},
	[87]={talk=StrConfig["TalkStringConfig87"],pos=0},
	[10001]={talk=StrConfig["TalkStringConfig10001"],pos=0, offsetY = -30},--野怪说话
	[10002]={talk=StrConfig["TalkStringConfig10002"],pos=0, offsetY = -30},--野怪说话
	[10003]={talk=StrConfig["TalkStringConfig10003"],pos=0, offsetY = -30},--野怪说话
	[10004]={talk=StrConfig["TalkStringConfig10004"],pos=0, offsetY = -30},--野怪说话
	[10005]={talk=StrConfig["TalkStringConfig10005"],pos=0, offsetY = -30},--野怪说话
	[10006]={talk=StrConfig["TalkStringConfig10006"],pos=0, offsetY = -30},--野怪说话
	[10007]={talk=StrConfig["TalkStringConfig10007"],pos=0, offsetY = -30},--野怪说话
	[10008]={talk=StrConfig["TalkStringConfig10008"],pos=0, offsetY = -30},--野怪说话
	[10009]={talk=StrConfig["TalkStringConfig10009"],pos=0, offsetY = -30},--野怪说话
	[10010]={talk=StrConfig["TalkStringConfig10010"],pos=0, offsetY = -30},--野怪说话
	[10011]={talk=StrConfig["TalkStringConfig10011"],pos=0, offsetY = -30},--野怪说话
	[10012]={talk=StrConfig["TalkStringConfig10012"],pos=0, offsetY = -30},--野怪说话
	[10013]={talk=StrConfig["TalkStringConfig10013"],pos=0, offsetY = -30},--野怪说话
	[10014]={talk=StrConfig["TalkStringConfig10014"],pos=0, offsetY = -30},--野怪说话
	[10015]={talk=StrConfig["TalkStringConfig10015"],pos=0, offsetY = -30},--野怪说话
	[10016]={talk=StrConfig["TalkStringConfig10016"],pos=0, offsetY = -30},--野怪说话
	[10017]={talk=StrConfig["TalkStringConfig10017"],pos=0, offsetY = -30},--野怪说话
	[10018]={talk=StrConfig["TalkStringConfig10018"],pos=0, offsetY = -30},--野怪说话
	[10019]={talk=StrConfig["TalkStringConfig10019"],pos=0, offsetY = -30},--野怪说话
	[10020]={talk=StrConfig["TalkStringConfig10020"],pos=0, offsetY = -30},--野怪说话
	[10021]={talk=StrConfig["TalkStringConfig10021"],pos=0, offsetY = -30},--野怪说话
	[10022]={talk=StrConfig["TalkStringConfig10022"],pos=0, offsetY = -30},--野怪说话
	[10023]={talk=StrConfig["TalkStringConfig10023"],pos=0, offsetY = -30},--野怪说话
	[10024]={talk=StrConfig["TalkStringConfig10024"],pos=0, offsetY = -30},--野怪说话
	[10025]={talk=StrConfig["TalkStringConfig10025"],pos=0, offsetY = -30},--野怪说话
	[10026]={talk=StrConfig["TalkStringConfig10026"],pos=0, offsetY = -30},--野怪说话
	[10027]={talk=StrConfig["TalkStringConfig10027"],pos=0, offsetY = -30},--野怪说话
	[10028]={talk=StrConfig["TalkStringConfig10028"],pos=0, offsetY = -30},--野怪说话
	[10029]={talk=StrConfig["TalkStringConfig10029"],pos=0, offsetY = -30},--野怪说话
	[10030]={talk=StrConfig["TalkStringConfig10030"],pos=0, offsetY = -30},--野怪说话
	[10031]={talk=StrConfig["TalkStringConfig10031"],pos=0, offsetY = -30},--野怪说话
	[10032]={talk=StrConfig["TalkStringConfig10032"],pos=0, offsetY = -30},--野怪说话
	[10033]={talk=StrConfig["TalkStringConfig10033"],pos=0, offsetY = -30},--野怪说话
	[10034]={talk=StrConfig["TalkStringConfig10034"],pos=0, offsetY = -30},--野怪说话
	[10035]={talk=StrConfig["TalkStringConfig10035"],pos=0, offsetY = -30},--野怪说话
	[10036]={talk=StrConfig["TalkStringConfig10036"],pos=0, offsetY = -30},--野怪说话
	[10037]={talk=StrConfig["TalkStringConfig10037"],pos=0, offsetY = -30},--悬赏怪说话
	[10038]={talk=StrConfig["TalkStringConfig10038"],pos=0, offsetY = -30},--悬赏怪说话
	[10039]={talk=StrConfig["TalkStringConfig10039"],pos=0, offsetY = -30},--悬赏怪说话
	[10040]={talk=StrConfig["TalkStringConfig10040"],pos=0, offsetY = -30},--悬赏怪说话
	
}
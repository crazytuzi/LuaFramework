-- 数据定义
KvData = KvData or BaseClass()

KvData.attrname_skill = 100

-- 获取属性名称(区分人物属性和宠物属性)
-- mark 1.人物 2.宠物
function KvData.GetAttrName(attrcode, mark)
    if KvData.attr_name[attrcode] ~= nil then
		if mark == 2 then
			return string.format("宠物%s", KvData.attr_name[attrcode])
		else
			return KvData.attr_name[attrcode]
		end
    end
end

function KvData.GetAttrVal(attrcode, value)
 	if value > 0 then
 		local attr_percent = KvData.prop_percent[attrcode]
 		if attr_percent == nil then
    		return value
    	else
    		return string.format("%s%%", value / 10)
    	end
    else
    	return value
    end
end

-- 生成属性显示字符串(区分人物属性和宠物属性)
-- mark 1.人物 2.宠物
function KvData.GetAttrString(attrcode, value, mark)
	-- if attrcode == attrname_skill then
	-- 	roleskillobject rso = (gamecontext.getinstance().managers.getmanager("combatmanager") as combatmanager).getroleskillobject(new skillobjectkey(value, 1))
	-- 	if rso ~= null --判断是否人物技能
	-- 		return "<color='#23f0f7'>" + rso.name + "</color>"
	-- 	else --非人物技能
	-- 		skilldata skilldata = (gamecontext.getinstance().managers.getmanager("skillmanager") as skillmanager).getpetskillbasedata((uint)value)
	-- 		if (null ~= skilldata) --判断是否宠物技能
	-- 			return "<color='#23f0f7'>" + skilldata.name + "</color>"
 --            end
 --        end
 --    else
 	if value > 0 then
 		local attr_percent = KvData.prop_percent[attrcode]
 		if attr_percent == nil then
    		return string.format("<color='#23f0f7'>%s+%s</color>",KvData.GetAttrName(attrcode, mark),value)
    	else
    		-- return "<color='#23f0f7'>"..attr_percent.."+"..(value/10).."%</color>"
    		return string.format("<color='#23f0f7'>%s+%s%%</color>", KvData.GetAttrName(attrcode, mark), (value/10))
    	end
    else
    	return string.format("<color='#23f0f7'>%s+%s</color>", KvData.GetAttrName(attrcode, mark), value)
    end
    -- end
   	-- return ""
end

-- 生成属性显示字符串, 不带颜色(区分人物属性和宠物属性)
-- mark 1.人物 2.宠物
function KvData.GetAttrStringNoColor(attrcode, value, mark)
 	if value > 0 then
 		local attr_percent = KvData.prop_percent[attrcode]
 		if attr_percent == nil then
    		return string.format("%s+%s", KvData.GetAttrName(attrcode, mark), value)
    	else
    		-- return attr_percent.."+"..(value/10).."%"
    		return string.format("%s+%s%%", KvData.GetAttrName(attrcode, mark), (value/10))
    	end
    else
    	return string.format("%s%s", KvData.GetAttrName(attrcode, mark), value)
    end
end

KvData.attr_name = {
	 [1  ] = TI18N("生命")
	,[2  ] = TI18N("魔法")
	,[3  ] = TI18N("攻速")
	,[4  ] = TI18N("物攻")
	,[5  ] = TI18N("魔攻")
	,[6  ] = TI18N("物防")
	,[7  ] = TI18N("魔防")
	,[8  ] = TI18N("暴击率")
	,[9  ] = TI18N("抗暴率")
	,[10 ] = TI18N("命中率")
	,[11 ] = TI18N("闪避率")
	,[12 ] = TI18N("移速")
	,[21 ] = TI18N("神伤")
	,[22 ] = TI18N("暴击伤害")
	,[23 ] = TI18N("伤害加成")
	,[24 ] = TI18N("伤害减免")
	,[25 ] = TI18N("控制加强")
	,[26 ] = TI18N("控制抵抗")
	,[27 ] = TI18N("逃跑率")
	,[28 ] = TI18N("抗逃跑")
	,[29 ] = TI18N("抓捕率")
	,[30 ] = TI18N("物理减免")
	,[31 ] = TI18N("魔法减免")
	,[32 ] = TI18N("受到伤害")
	,[33 ] = TI18N("治疗效果")
	,[34] = TI18N("受到治疗效果")
	,[35] = TI18N("物理暴击")
	,[36] = TI18N("魔法暴击")
	,[37] = TI18N("物理坚韧")
	,[38] = TI18N("魔法坚韧")
	,[39] = TI18N("物理命中")
	,[40] = TI18N("魔法命中")
	,[41] = TI18N("物理闪避")
	,[42] = TI18N("魔法闪避")
	,[43] = TI18N("治疗加强")
	,[45] = TI18N("物理伤害加成")
	,[46] = TI18N("魔法伤害加成")
	,[47] = TI18N("暴伤减免")
	,[51 ] = TI18N("生命") --生命比
	,[52 ] = TI18N("魔法") --魔法比
	,[53 ] = TI18N("攻速") --攻速比
	,[54 ] = TI18N("物攻") --物攻比
	,[55 ] = TI18N("魔攻") --魔攻比
	,[56 ] = TI18N("物防") --物防bi
	,[57 ] = TI18N("魔防") --魔防比
	,[58 ] = TI18N("暴击率") --暴击比
	,[59 ] = TI18N("抗暴率") --坚韧比
	,[60 ] = TI18N("命中率") --命中比
	,[61 ] = TI18N("闪避率") --闪避比
	,[62 ] = TI18N("移速") --移速比

	,[100] = TI18N("技能")
	,[101] = TI18N("力量")
	,[102] = TI18N("体质")
	,[103] = TI18N("智力")
	,[104] = TI18N("敏捷")
	,[105] = TI18N("耐力")

	--装备上镶嵌的宝石信息
	,[110] = TI18N("宝石孔1")
	,[111] = TI18N("宝石孔2")

	,[150] = TI18N("强化")
	,[151] = TI18N("宝石加强")
}

--缩写
KvData.attr_name_show = {
	 [1  ] = TI18N("生命")
	,[2  ] = TI18N("魔法")
	,[3  ] = TI18N("攻速")
	,[4  ] = TI18N("物攻")
	,[5  ] = TI18N("魔攻")
	,[6  ] = TI18N("物防")
	,[7  ] = TI18N("魔防")
	,[8  ] = TI18N("暴击率")
	,[9  ] = TI18N("抗暴率")
	,[10 ] = TI18N("命中率")
	,[11 ] = TI18N("闪避率")
	,[12 ] = TI18N("移速")
	,[21 ] = TI18N("神伤")
	,[22 ] = TI18N("暴击") --暴击伤害
	,[23 ] = TI18N("伤害") --伤害加成
	,[24 ] = TI18N("免伤") --伤害减免
	,[25 ] = TI18N("控制") --控制加强
	,[26 ] = TI18N("反控制") --控制抵抗
	,[27 ] = TI18N("逃跑率") --逃跑率
	,[28 ] = TI18N("抗逃跑") --抗逃跑
	,[29 ] = TI18N("抓捕率") --抓捕率
	,[30 ] = TI18N("物免") --物理减免
	,[31 ] = TI18N("魔免") --魔法减免
	,[32 ] = TI18N("受伤害") --受到伤害
	,[33 ] = TI18N("治疗") --治疗效果
	,[34 ] = TI18N("被治疗") --受到治疗效果
	,[35] = TI18N("物理暴击")
	,[36] = TI18N("魔法暴击")
	,[37] = TI18N("物理坚韧")
	,[38] = TI18N("魔法坚韧")
	,[39] = TI18N("物理命中")
	,[40] = TI18N("魔法命中")
	,[41] = TI18N("物理闪避")
	,[42] = TI18N("魔法闪避")
	,[43] = TI18N("治疗加强")
	,[47] = TI18N("暴伤减免")

	,[51 ] = TI18N("生命") --生命比
	,[52 ] = TI18N("魔法") --魔法比
	,[53 ] = TI18N("攻速") --攻速比
	,[54 ] = TI18N("物攻") --物攻比
	,[55 ] = TI18N("魔攻") --魔攻比
	,[56 ] = TI18N("物防") --物防bi
	,[57 ] = TI18N("魔防") --魔防比
	,[58 ] = TI18N("暴击率") --暴击比
	,[59 ] = TI18N("抗暴率") --坚韧比
	,[60 ] = TI18N("命中率") --命中比
	,[61 ] = TI18N("闪避率") --闪避比
	,[62 ] = TI18N("移速") --移速比

	,[100] = TI18N("技能")
	,[101] = TI18N("力量")
	,[102] = TI18N("体质")
	,[103] = TI18N("智力")
	,[104] = TI18N("敏捷")
	,[105] = TI18N("耐力")
}

--属性比分类
KvData.prop_percent = {
	[8 ] = TI18N("暴击率")
	,[9  ] = TI18N("抗暴率")
	,[10 ] = TI18N("命中率")
	,[11 ] = TI18N("闪避率")
	,[22 ] = TI18N("暴击伤害")
	,[23 ] = TI18N("伤害加成")
	,[24 ] = TI18N("伤害减免")
	,[25 ] = TI18N("控制加强")
	,[26 ] = TI18N("控制抵抗")
	,[30 ] = TI18N("物理减免")
	,[31 ] = TI18N("魔法减免")
	,[47 ] = TI18N("暴伤减免")
	,[51 ] =  TI18N("生命") --生命比
	,[52 ] = TI18N("魔法") --魔法比
	,[53 ] = TI18N("攻速") --攻速比
	,[54 ] = TI18N("物攻") --物攻比
	,[55 ] = TI18N("魔攻") --魔攻比
	,[56 ] = TI18N("物防") --物防比
	,[57 ] = TI18N("魔防") --魔防比
	,[58 ] = TI18N("暴击率") --暴击比
	,[59 ] = TI18N("抗暴率") --坚韧比
	,[60 ] = TI18N("命中率") --命中比
	,[61 ] = TI18N("闪避率") --闪避比
	,[62 ] = TI18N("移速") --移速比
}

--职业名称 （配置表配0，表示全职业适合）
KvData.classes_name = {TI18N("狂剑"), TI18N("魔导"), TI18N("战弓"), TI18N("兽灵"), TI18N("秘言"), TI18N("月魂"), TI18N("圣骑")}

KvData.classes_nameab = {"KJ", "MD", "ZG", "SL", "MY", "YH", "SQ"}

--性别 （配置表配2，表示全性别适合） --貌似现在女0男1
KvData.sex = {TI18N("女"), TI18N("男")}

--颜色品质
KvData.quality_name = {TI18N("白"), TI18N("绿"), TI18N("蓝"), TI18N("紫"), TI18N("橙"), TI18N("红")}

--品阶
KvData.craft_name = {TI18N("无"), TI18N("精良"), TI18N("优秀"), TI18N("完美"), TI18N("逆天")}

-- 资产类型
KvData.assets = {
	coin = 90000, 				--银币
	bind = 90001,     			--绑定银币
	gold = 90002,          		--钻石
	gold_bind = 90003,    		--绑定钻石/金币
	intelligs = 90004,    		--灵气
	pet_exp = 90005,      		--宠物经验
	energy = 90006,      		--精力值
	character = 90007,			--爱心
	exp = 90010,     			--经验
	guild = 90011,  			--公会贡献
	stars_score = 90012,		--星辰积分
	skill_prac_exp = 90013,		--修炼技能经验
	guild_assets = 90015,		--公会资金
	energy = 90017,				--精力值
	love = 90018,				--恩爱值
	teacher_score = 90019,		--师道值
	tournament = 90020,			--武道积分
	mount_spirit = 90021,		--坐骑精力
	lottery_luck = 90022,		--幸运值
	endless_challenge = 90023,	--挑战心得
	autumn_score = 90025,		--中秋积分
	star_gold = 90026, 			--星钻
	halloween = 90027,			-- 南瓜币
	star_gold_or_gold = 29255,	-- 双钻（优先红钻）
	thanksgiving = 90028,		-- 感恩积分
	new_year = 90029,			-- 元旦积分
	pregnancy = 90032,			-- 胎儿发育值
	firecracker = 90033,		-- 新春鞭炮
	glue_pudding = 90034,			-- 元宵积分
	brother = 90036,				-- 兄弟币
	ticket = 90037,			-- 游乐园积分
	egg = 90038,
    cake_exchange = 90039,    -- 周年庆兑换活动积分
    nothing = 90040,
    father        = 90041,
    sum_point        = 90043, -- 夏日任务积分
    lucky_ticket = 90042,
	dollar = 90044, -- 充值礼券
	naughty = 90045, -- 淘气值
	concentric = 90046, --同心值
	qixiIntegral = 90047, --七夕积分
	sunshine = 90048,
	cut_price = 90049,
	hallowmas = 29811,		-- 南瓜灯，但这不是货币，不是货币，不是货币
	single_dog = 90050,  -- 光棍积分
	panda_score = 90051,	-- 庆典积分
	christmas_snow = 29915,   -- 圣诞雪花, 但这不是货币，不是货币，不是货币
	joyful_egg = 90052, --欢乐彩蛋积分
	godswar = 90056,
	happy_score = 90057,  --喜庆积分
    lucky_knot = 29971,  --吉祥如意结
    slot_machine = 90061,  -- 摇摇乐积分
	zillionaire_sc = 90063, -- 大富翁积分
	score_exchange = 90066, --圣诞乐兑积分
	new_open_turn = 90067, --新开服转盘活动资产
	long_score = 90069, --战令活动道具
	camp_pray_sc = 90071, --祈愿宝阁积分
}

--属性icon名
KvData.attr_icon = {
	[1]=1
	,[2]=2
	,[3]=3
	,[4]=4
	,[5]=5
	,[6]=6
	,[7]=7
	,[8]=8
	,[9]=9
	,[10]=10
	,[11]=11
	,[12]=3
	,[21]=21
	,[22]=22
	,[23]=23
	,[24]=24
	,[25]=25
	,[26]=26
	,[27]=27
	,[28]=28
	,[29]=29
	,[30]=30
	,[31]=31
	,[32]=32
	,[33]=33
	,[34]=34
	,[35]=35
	,[36]=36
	,[37]=37
	,[38]=38
	,[39]=39
	,[40]=40
	,[41]=41
	,[42]=42
	,[43]=43
	,[51]=51
	,[52]=52
	,[53]=53
	,[54]=54
	,[55]=55
	,[56]=56
	,[57]=57
	,[58]=58
	,[59]=59
	,[60]=60
	,[61]=61
	,[62]=62
}

KvData.localtion_type = {
	cn = "cn", --国服
	sg = "sg", --海外，新加坡
	tw = "tw", --台湾
}

KvData.game_name = {
	xcqy = "xcqy",	--星辰奇缘
	xcqylxj = "xcqylxj",	--星辰奇缘
	mhqy = "mhqy",	--梦幻奇缘
	xchx = "xchx",	--星辰幻想
	xzzh = "xzzh",	--星之召唤
}

KvData.activeUrl = "http://oss.api.shiyuegame.com/index.php/device/activation"
KvData.newPlayerImportUrl = "http://oss.api.shiyuegame.com/index.php/entry/step"
KvData.channelBagDownLoadUrl = "http://oss.api.shiyuegame.com/index.php/ChannelBag/bag"

-- 游戏标识
KvData.product_name = "xcqy"
--//秘钥
KvData.secret_key = "cmTc8^vv1k(,i2<}nc52-<#.lxz5>9m#2MMCYSD"
KvData.server_key = "cmTc8^vv1k(,i2<}nc52-<#.lxz5>9m#2MMCYSD"

KvData.newPlayerImportStepType = {
	flash = {key = "flash_report",index = "1"} 		-- 闪屏页
	,notice = {key = "notice_report",index = "2"}	-- 游戏忠告
	,loading_start = {key = "loading_start_report",index = "3"}	-- 加载开始
	,loading_end = {key = "loading_end_report",index = "4"}	-- 加载结束
	,open_sdk = {key = "open_sdk",index = "5"}	-- 登录sdk
	,reg_acc = {key = "reg_acc_report",index = "6"}	-- 账号注册
	,login = {key = "login_report",index = "7"}		-- 登录页 ,选服
	,create_role = {key = "create_role_report",index = "8"}	-- 创角
	,enter_game = {key = "enter_game_report",index = "9"}	-- 进入游戏
}

KvData.roleTransformId = 0
KvData.verifyRandomSeed = nil
-- KvData.indexTest = 1

function KvData.GetVerifyRandomSeed()
	if not KvData.verifyRandomSeed then 
		local name = BaseUtils.GetGameName()
	    local list = StringHelper.Split(name, "_")
	    local vestNum = string.gsub(list[#list], "Vest", "")
	    vestNum = tonumber(vestNum)
	    KvData.verifyRandomSeed = vestNum
	end
	return KvData.verifyRandomSeed
end

function KvData.GetRoleTransformId()
    if KvData.roleTransformId == 0 then
        local idList = {
			30900
			, 30901
			, 30902
			, 30903
			, 30904
			, 30905
			, 30906
			, 30907
			, 30908
			, 30909
			, 30910
			, 30911
			, 30912
			, 31901
			, 31902
			, 32032
			, 32033
			-- , 44000
			, 73071
			, 73075
			, 73074
			, 76010
			, 76011
			, 76012
			, 76013
			, 76014
			, 76116
			, 76117
			-- , 76118
			-- , 76119
			, 76721
			, 76722
			, 76723
			, 76880
			, 76882
        }
		math.randomseed(KvData.GetVerifyRandomSeed())
		local roleTransformId = idList[1]
		local str = BaseUtils.Key(BaseUtils.get_self_id(),"VestRoleTransformId")
		if not PlayerPrefs.HasKey(str) then 
			roleTransformId = idList[math.random(1, #idList)]
			
			PlayerPrefs.SetInt(str, roleTransformId)
		else
			roleTransformId = PlayerPrefs.GetInt(str)
		end
        KvData.roleTransformId = roleTransformId
    end
    return KvData.roleTransformId
end

function KvData.RandomNpc()
	local idList = {
		82009,
		20036,
		20004,
		20037,
		20005,
		20038,
		20071,
		77001,
		20104,
		20040,
		82002,
		10037,
		77009,
		73001,
		20010,
		20043,
		20011,
		20076,
		82018,
		20045,
		20013,
		78009,
		78008,
		20078,
		20014,
		20047,
		78003,
		20080,
		20026,
		20027,
		71004,
		20049,
		82038,
		20048,
		20050,
		20087,
		20051,
		20019,
		71149,
		20052,
		71001,
		71005,
		85001,
		20053,
		20021,
		20000,
		85060,
		20054,
		20022,
		20001,
		20002,
		20055,
		20023,
		20009,
		77011,
		20088,
		20024,
		20039,
		21005,
		20089,
		20025,
		20041,
		20042,
		20090,
		10126,
		10024,
		10025,
		77005,
		78007,
		77003,
		77002,
		78002,
		20061,
		20029,
		20057,
		78006,
		20046,
		20030,
		20044,
		20063,
		79843,
		71003,
		20096,
		20074,
		71002,
		20097,
		71006,
	}
	math.randomseed(KvData.GetVerifyRandomSeed())
	for i, v in ipairs(idList) do
		local data1 = DataUnit.data_unit[v]
		local data2 = DataUnit.data_unit[idList[math.random(1, #idList)]]
		local animation_id = data1.animation_id
		local res = data1.res
		local skin = data1.skin

		data1.animation_id = data2.animation_id
		data1.res = data2.res
		data1.skin = data2.skin

		data2.animation_id = animation_id
		data2.res = res
		data2.skin = skin
	end
end

KvData.SelfDressLook = nil
KvData.SelfHairLook = nil
function KvData.RandomRoleLook(isSelf)
	local lookList = {
       	{50038, 50038, 51038, 51038},
		{50039, 50039, 51039, 51039},
		{50040, 50040, 51040, 51040},
		{50041, 50041, 51041, 51041},
		{50042, 50042, 51042, 51042},
		{50043, 50043, 51043, 51043},
		{50046, 50046, 51046, 51046},
		{50047, 50047, 51047, 51047},
		{50048, 50048, 51048, 51048},
		{50049, 50049, 51049, 51049},
		{50052, 50052, 51052, 51052},
		{50053, 50053, 51053, 51053},
		{50054, 50054, 51054, 51054},
		{50055, 50055, 51055, 51055},
		{50056, 50056, 51056, 51056},
		{50057, 50057, 51057, 51057},
		{50058, 50058, 51058, 51058},
		{50059, 50059, 51059, 51059},
		{50060, 50060, 51060, 51060},
		{50061, 50061, 51061, 51061},
		{50062, 50062, 51062, 51062},
		{50063, 50063, 51063, 51063},
		{50064, 50064, 51064, 51064},
		{50065, 50065, 51065, 51065},
		{50066, 50066, 51066, 51066},
		{50067, 50067, 51067, 51067},
		{50068, 50068, 51068, 51068},
		{50069, 50069, 51069, 51069},
		{50072, 50072, 51072, 51072},
		{50073, 50073, 51073, 51073},
		{50076, 50076, 51076, 51076},
		{50077, 50077, 51077, 51077},
		{50078, 50078, 51078, 51078},
		{50079, 50079, 51079, 51079},
		{50074, 50074, 51074, 51074},
		{50075, 50075, 51075, 51075},
		{50080, 50080, 51080, 51080},
		{50081, 50081, 51081, 51081},
		{50082, 50082, 51082, 51082},
		{50083, 50083, 51083, 51083},
		{50084, 50084, 51084, 51084},
		{50085, 50085, 51085, 51085},
		{50086, 50086, 51086, 51086},
		{50087, 50087, 51087, 51087},
		{50088, 50088, 51088, 51088},
		{50089, 50089, 51089, 51089},
		{50090, 50090, 51090, 51090},
		{50091, 50091, 51091, 51091},
		{50092, 50092, 51092, 51092},
		{50093, 50093, 51093, 51093},
		{50096, 50096, 51096, 51096},
		{50097, 50097, 51097, 51097},
		{50098, 50098, 51098, 51098},
		{50099, 50099, 51099, 51099},
		{50100, 50100, 51100, 51100},
		{50101, 50101, 51101, 51101},
		{50104, 50104, 51104, 51104},
		{50105, 50105, 51105, 51105},
		{50102, 50102, 51102, 51102},
		{50103, 50103, 51103, 51103},
		{50106, 50106, 51106, 51106},
		{50107, 50107, 51107, 51107},
		{50112, 50112, 51112, 51112},
		{50113, 50113, 51113, 51113},
		{50110, 50110, 51110, 51110},
		{50111, 50111, 51111, 51111},
		{50114, 50114, 51114, 51114},
		{50115, 50115, 51115, 51115},
		{50094, 50094, 51094, 51094},
		{50095, 50095, 51095, 51095},
		{50116, 50116, 51116, 51116},
		{50117, 50117, 51117, 51117},
		{50118, 50118, 51118, 51118},
		{50119, 50119, 51119, 51119},
		{50120, 50120, 51120, 51120},
		{50121, 50121, 51121, 51121},
		{50122, 50122, 51122, 51122},
		{50123, 50123, 51123, 51123},
		{50124, 50124, 51124, 51124},
		{50125, 50125, 51125, 51125},
		{50126, 50126, 51126, 51126},
		{50127, 50127, 51127, 51127},
		{50128, 50128, 51128, 51128},
		{50129, 50129, 51129, 51129},
		{50130, 50130, 51130, 51130},
		{50131, 50131, 51131, 51131},
		{50132, 50132, 51132, 51132},
		{50133, 50133, 51133, 51133},
		{50134, 50134, 51134, 51134},
		{50135, 50135, 51135, 51135},
		{50136, 50136, 51136, 51136},
		{50137, 50137, 51137, 51137},
		{50138, 50138, 51138, 51138},
		{50139, 50139, 51139, 51139},
		{50140, 50140, 51140, 51140},
		{50141, 50141, 51141, 51141},
		{50142, 50142, 51142, 51142},
		{50143, 50143, 51143, 51143},
		{50144, 50144, 51144, 51144},
		{50145, 50145, 51145, 51145},
		{50146, 50146, 51146, 51146},
		{50147, 50147, 51147, 51147},
		{50148, 50148, 51148, 51148},
		{50149, 50149, 51149, 51149},
		{50150, 50150, 51150, 51150},
		{50151, 50151, 51151, 51151}
    }
	if isSelf then
		if KvData.SelfDressLook and KvData.SelfHairLook then
			return KvData.SelfDressLook, KvData.SelfHairLook
		else
			math.randomseed(KvData.GetVerifyRandomSeed())
		end
	end
	local lookData = lookList[math.random(1, #lookList)]
	local dressLook = {
                looks_str = "",
                looks_val = lookData[3],
                looks_mode = lookData[4],
                looks_type = 3,
            }
    lookData = lookList[math.random(1, #lookList)]
	local hairLook = {
                looks_str = "",
                looks_val = lookData[1],
                looks_mode = lookData[2],
                looks_type = 2,
            }

    if isSelf then
    	KvData.SelfDressLook = dressLook
    	KvData.SelfHairLook = hairLook
    end
    return dressLook, hairLook
end

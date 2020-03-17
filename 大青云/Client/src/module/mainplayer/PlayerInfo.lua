--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/7/21
-- Time: 9:48
-- 
--

_G.enAttrType =
{
    --基本属性
    eaName         = 1,
    eaProf         = 2,     --职业 1:洛神(萝莉), 2:摩牱(男魔), 3:太古(男人), 4:九幽(御姐)
    eaSex          = 3,
    eaVIPLevel     = 4,     --VIP等级
    eaZone         = 5,     --区服ID
    eaLevel        = 6,     --等级
    eaExp          = 7,     --角色的当前经验,可以消耗减少
    eaLeftPoint    = 8,     --角色剩余属性点    角色当前可用来增加4个一级属性的属性点
    eaTotalPoint   = 9,     --角色总属性点      角色累计获得的总属性点
    eaBindGold     = 10,    --绑定金币          角色在游戏内的货币，游戏内产出及消耗，数值可极大,不可交易  使用中
    eaUnBindGold   = 11,    --非绑定金币         非绑定金币可替代绑定金币的全部功能,可交易
    eaUnBindMoney  = 12,    --元宝              可通过特殊途径交易，普通交易不可交易；
    eaBindMoney    = 13,    --绑元              和绑定金币类似的货币， 可购买绑定的道具，不可交易
    eaZhenQi       = 14,    --灵力              角色在游戏内的另一种代币，数值可极大， 不可交易
    
    --战斗属性
    eaHunLi        = 15,    --魂力              影响角色攻击力
    eaTiPo         = 16,    --体魄              主要影响角色生命上限，次要影响角色防御
    eaShenFa       = 17,    --身法              主要影响角色命中和闪避，次要影响爆击和韧性
    eaJingShen     = 18,    --精神              主要影响角色爆击和韧性，次要影响命中和闪避
    
    eaHp           = 19,    --生命值
    eaMaxHp        = 20,    --生命上限
    eaHpReback     = 21,   	--生命恢复速度      角色生命值恢复速度，每30秒恢复一次
    
    eaMp           = 22,    --内力值            角色当前内力值，释放技能需要消耗该值
    eaMaxMp        = 23,    --内力上限
    eaMpReback     = 24,   	--内力恢复速度      角色内力恢复速度，每30秒恢复一次
    
    eaTiLi         = 25,    --体力值            角色体力值，释放体力值技能需要消耗该值
    eaMaxTiLi      = 26,    --体力值上限
    eaTiLiReback   = 27,    --体力恢复速度      角色体力值恢复速度，每30秒恢复一次
    
    eaGongJi       = 28,    --攻击力            角色攻击力，带入伤害公式计算伤害时使用
    eaFangYu       = 29,    --防御力            角色防御力，带入伤害公式计算伤害时使用
    eaMingZhong    = 30,    --命中              角色命中值，带入命中公式计算是否命中
    eaShanBi       = 31,    --闪避              角色闪避值，带入命中公式计算是否命中
    eaBaoJi        = 32,    --爆击              角色爆击值，带入爆击公式计算是否爆击
    eaRenXing      = 33,    --韧性              角色韧性，带入爆击公式计算是否爆击
    
    eaGongJiSpeed  = 34,    --攻击速度         角色攻击速度，影响角色攻击间隔及技能公共CD间隔；
    eaMoveSpeed    = 35,    --移动速度           影响角色移动速度
    
    eaBaoJiHurt    = 36,    --爆伤              正整数，显示为百分比，例如：200%；带入伤害公式计算，影响角色爆击后的伤害值
    eaBaoJiDefense = 37,    --免爆            正整数，显示为百分比，例如：200%；带入伤害公式计算，影响角色被爆击后的伤害值
        
    eaChuanCiHurt  = 38,    --穿刺             无视防御的伤害值，带入伤害公式计算伤害值；
    eaGeDang       = 39,    --格挡值           dongtu 2016/6/2
    eaHurtAdd      = 40,    --伤害增强         正整数，显示为百分比，例如：50%；角色最终伤害增加的比例，带入伤害公式计算；
    eaHurtSub      = 41,    --伤害减免         正整数，显示为百分比，例如：50%；角色最终伤害减免的比例，带入伤害公式计算
    eaChuanTou     = 42,    --穿透值           dongtu 2016/6/2
    eaWuHunSP      = 43,    --武魂豆  角色武魂值，使用武魂技能协议消耗;
    eaMaxWuHunSP   = 44,    --武魂豆最大上限;
    eaWuHunSPRe    = 45,    --武魂豆恢复速度 角色武魂豆恢复速度，每5s恢复一次;
    eaFight        = 46,    --战斗力;
    eaMultiKill    = 47,    --连斩数;
    eaSubdef       = 48,    --破防
    eaDropVal      = 49,    --打宝活力值
    eaPKVal        = 50,    --pk值(善恶值)
    eaHonor        = 51,    --竞技场荣誉值
    eaSuper        = 52,    --卓越一击几率
    eaSuperValue   = 53,    --卓越一击伤害
    eaLingZhi      = 54,    --灵值
    eaTianShenEnergy = 55, --天神能量  
    eaPiLao        = 56,    --打宝疲劳
    eaDominJingLi  = 57,    --主宰之路精力
    eaEnergy       = 58,    --装备打造活力值
	eaExtremityVal = 59,	--极限副本积分
	eaChargeMoney	= 60,	--玩家充值钱数;
	eaCrossScore	= 61,	--跨服积分;
	eaCrossExploit	= 62,	--跨服PVP功勋;
	eaCrossZhanyi	= 63,	--跨服副本战意值;
	eaCrossDuanwei	= 64,	--跨服pvp段位
    eaZhuansheng    = 65,    --转生等级
	eaHpX			= 66,		--最大生命百分比
	eaAtkX			= 67,		--攻击百分比
	eaDefX			= 68,		--防御百分比
	eaHitRate		= 69,		--命中率 dongtu 2016/6/2
	eaDodgeRate		= 70,		--闪避率 dongtu 2016/6/2
	eaCriRate		= 71,		--暴击率 dongtu 2016/6/2
	eaDefCriRate	= 72,		--韧性率 dongtu 2016/6/2
	eaAbsAttX		= 73,		--穿刺百分比
	eaParryRate		= 74,		--格挡率 dongtu 2016/6/2
	eaDefParryRate	= 75,		--穿透率 dongtu 2016/6/2
	eaSubDefX		= 76,		--破防百分比
	eaBossPoints	= 77,		--屠魔值
	eaShenwei		= 78,		--神威
	eaWashLucky		= 79,		--洗练幸运值

	eaDefJianSu		= 82,		-- 抵抗减速
	eaDefXuanYun	= 83,		-- 抵抗眩晕
	eaDefChenMo		= 84,		-- 抵抗沉默
	eaDefDingShen	= 85,		-- 抵抗定身
	eaDefYuLiu      = 86,       -- 抵抗预留
	eaInterSSVal	= 87,		-- 跨服战场，积分
	eaKillHp        = 88,       -- 杀怪回血值           --change: houxudong date:2016/10/10 16:01:33
	eaShpre         = 89,       -- 每秒回血值
	eaHitHp         = 90,       -- 攻击命中时回血值
	eaTianShen      = 91,       --天神货币
	eaTrialScore    = 92,       --试炼积分
	eaRealmLvl 	   = 99,	-- 境界等级
----------------------下面这些服务器不发------------------
    -- eaKillHp         = 100,     --杀怪回血值
    eaKillMp         = 101,     --杀怪回蓝值
    -- eaHitHp          = 102,     --攻击命中时回血值
    -- eaShpre          = 103,     --每秒回血值
    eaGoldDrop       = 104,     --金币掉率百分比
    eaItemDrop       = 105,     --道具掉落百分比
    eaExtraDamage    = 106,     --攻击额外扣血值  //额外伤害
    eaExtraSubDamage = 107,     --伤害减免值
	eaMpX			= 108,		--最大内力百分比(没人用,先放这里)
	--
	eaAdddamagemon	= 120,		--对小怪伤害
	eaAdddamagemonx	= 121,		--对小怪伤害百分比
	eaAdddamageboss	= 122,		--对Boss伤害
	eaAdddamagebossx= 123,		--对Boss伤害百分比
	eaDodgeRate		= 124,		--闪避率 实际命中率 = 流程计算命中率 - 被攻击者闪避率
	eaAttLvl		= 125,		--攻击 + 等级*X
	eaReflex		= 126,		--对敌人造成x点伤害的时候，自身受到 敌人 伤害反射百分比 * x 点伤害
	eaSuperX		= 127,		--卓越一击百分比
	eaIgdef			= 128,		--无视一击 
	--
	eaHorsesknattx	= 129,  	--所有坐骑皮肤的攻击属性 + 10%
	eaHorseskndefx	= 130,   	--所有坐骑皮肤的防御属性 + 10%
	eaHorsesknhpx	= 131,   	--所有坐骑皮肤的生命属性 + 10%
	eaHorseskncrix	= 132,   	--所有坐骑皮肤的暴击属性 + 10%
	eaHorseskndefcrix=133,   	--所有坐骑皮肤的韧性属性 + 10%
	eaHorseskndodgex= 134,   	--所有坐骑皮肤的闪避属性 + 10%
	eaHorsesknhitx	= 135,   	--所有坐骑皮肤的命中属性 + 10%
	eaHorsesknx		= 136,   	--所有坐骑皮肤的所有属性（攻击、防御、生命、暴击、韧性、闪避、命中） + 11%
	--
	eaLingshousknattx=137,		--所有神兽的攻击属性 + 10%
	eaLingshouskndefx=138,		--所有神兽的防御属性 + 10%
	eaLingshousknhpx= 139,		--所有神兽的生命属性 + 10%
	eaLingshouskncrix=140,		--所有神兽的暴击属性 + 10%
	eaLingshouskndefcrix= 141,	--所有神兽的韧性属性 + 10%
	eaLingshouskndodgex = 142,	--所有神兽的闪避属性 + 10%
	eaLingshousknhitx=143,		--所有神兽的命中属性 + 10%
	eaLingshousknx	= 144,		--所有神兽的所有属性（攻击、防御、生命、暴击、韧性、闪避、命中） + 11%
	--
	eaAttrGold		= 145,		--金
	eaAttrWood		= 146,		--木
	eaAttrWater		= 147,		--水
	eaAtteFire		= 148,		--木
	eaAttrSoil		= 149,		--土
	MAX_ATTR_COUNT  = 1000,     --最大的属性值数量
}

--百分比属性映射
_G.AttrP_AttrMap = {
	[enAttrType.eaHpX] = enAttrType.eaMaxHp,
	[enAttrType.eaAtkX] = enAttrType.eaGongJi,
	[enAttrType.eaDefX] = enAttrType.eaFangYu,
	[enAttrType.eaAbsAttX] = enAttrType.eaChuanCiHurt,
	[enAttrType.eaSubDefX] = enAttrType.eaSubdef,
}

--双向映射
_G.Attr_AttrPMap = {};
for k,v in pairs(AttrP_AttrMap) do
	Attr_AttrPMap[v] = k;
end

--属性类型是否是百分比
_G.attrIsPercent = function(type)
	if type == enAttrType.eaBaoJiHurt or
           type == enAttrType.eaBaoJiDefense or
           type == enAttrType.eaHurtAdd or
           type == enAttrType.eaHurtSub or
           type == enAttrType.eaGoldDrop or
           type == enAttrType.eaItemDrop or
           type == enAttrType.eaSuper or
		   type == enAttrType.eaHpX or
		   type == enAttrType.eaMpX or
		   type == enAttrType.eaAtkX or
		   type == enAttrType.eaDefX or
		   type == enAttrType.eaHitRate or
		   type == enAttrType.eaDodgeRate or
		   type == enAttrType.eaCriRate or
		   type == enAttrType.eaDefCriRate or
		   type == enAttrType.eaAbsAttX or
		   type == enAttrType.eaParryRate or
           type == enAttrType.eaDefParryRate or
		   type == enAttrType.eaSuperValue or
		   type == enAttrType.eaSubDefX or
		   type == enAttrType.eaAdddamagemonx or
		   type == enAttrType.eaAdddamagebossx or
		   type == enAttrType.eaDodgeRate or
		   type == enAttrType.eaReflex or
		   type == enAttrType.eaSuperX or
		   type == enAttrType.eaIgdef or
		   type == enAttrType.eaHorsesknattx or
		   type == enAttrType.eaHorseskndefx or
		   type == enAttrType.eaHorsesknhpx or
		   type == enAttrType.eaHorseskncrix or
		   type == enAttrType.eaHorseskndefcrix or
		   type == enAttrType.eaHorseskndodgex or
		   type == enAttrType.eaHorsesknhitx or
		   type == enAttrType.eaHorsesknx or
		   type == enAttrType.eaLingshousknattx or
		   type == enAttrType.eaLingshouskndefx or
		   type == enAttrType.eaLingshousknhpx or
		   type == enAttrType.eaLingshouskncrix or
		   type == enAttrType.eaLingshouskndefcrix or
		   type == enAttrType.eaLingshouskndodgex or
		   type == enAttrType.eaLingshousknhitx or
		   type == enAttrType.eaLingshousknx or

		   type == enAttrType.eaHitHp or   --击中回血    --adder:houxudong date:2016/10/6 10:40:35
		   type == enAttrType.eaShpre or   --每秒回血
		   type == enAttrType.eaKillHp or  --杀怪回血
		   type == enAttrType.eaAttLvl or
		   
		   -- type == enAttrType.eaDefJianSu or
		   -- type == enAttrType.eaDefXuanYun or
		   -- type == enAttrType.eaDefChenMo or
		   -- type == enAttrType.eaDefDingShen or
		   -- type == enAttrType.eaDefYuLiu or
		  -- type == enAttrType.eaChuanTou or   -- changer:houxudong date:2016/6/25 reason:穿透力这个属性将不再以百分比显示
		   type == enAttrType.eaShenwei or
		   type == enAttrType.eaWuHunSP then
		return true;
	end
	return false;
end

--属性类型是否是乘系数类的
_G.attrIsX = function(type)
	if type == enAttrType.eaKillHp or
		type == enAttrType.eaHitHp or
		type == enAttrType.eaShpre or
		type == enAttrType.eaAttLvl then
		return true;
	end
	return false;
end

--获取val的显示值
_G.getAtrrShowVal = function(type,val)
	if attrIsPercent(type) then
		if attrIsX(type) then
			return string.format("%0.2f",val);
		else
			return string.format( "%0.2f%%", val*100 );
		end
	else
		return val;
	end
end

-- 是否是人物的属性，可以将t_item表中的id传入这里来判断是货币还是道具
_G.isPlayerAttr = function(tid)
	return tid > 0 and tid < enAttrType.MAX_ATTR_COUNT;
end

--格式化属性
--附加属性,卓越属性那些,其他地方看准了再用
_G.formatAttrStr = function(typeStr,val)
	local type = AttrParseUtil.AttMap[typeStr];
	if not type then return ""; end
	if attrIsX(type) then
		if attrIsPercent(type) then
			return enAttrTypeName[type] ..":".." +".. string.format("%0.2f",val/10000);
		else
			return enAttrTypeName[type] ..":".." +".. val;
		end
	elseif attrIsPercent(type) then
		return string.format("%s : +%0.2f%%",enAttrTypeName[type],val/100);
	else
		return enAttrTypeName[type] ..":".." +".. val;
	end
end


--只试用于装备tips,慎调用
--changer：houxudong
--date：2016/8/16 18:35:25
_G.formatAttrStrForTips = function(typeStr,val)
	local type = AttrParseUtil.AttMap[typeStr];
	if not type then return ""; end
	if attrIsX(type) then
		if attrIsPercent(type) then
			return enAttrTypeName[type] , string.format("%0.2f",val/10000);
		else
			return enAttrTypeName[type] ,val;
		end
	elseif attrIsPercent(type) then
		return enAttrTypeName[type],string.format("%0.2f%%",val/100);
	else
		return enAttrTypeName[type], val;
	end
end

--将较长的数字取约数简化显示
--1万及以下的，显示具体值，9999，直接取整显示，即9999999，显示为999万
--。不超过1亿的，显示9999万，
-- bUseInNumLoader 为true时, 字符串中万显示为w, 亿显示为y
_G.getNumShow = function( num, bUseInNumLoader )
    -- local str;
    -- local formatStr1 = bUseInNumLoader and "%sy" or StrConfig['commonNum002']
    -- local formatStr2 = bUseInNumLoader and "%sw" or StrConfig['commonNum001']
    -- local absNum = math.abs(num)
    -- if 100000000 <= absNum then -- 大于1亿
        -- local tenBillion = toint( num / 100000000 , -1); -- xx亿
        -- str = string.format( formatStr1, tenBillion );
    -- elseif 10000 <= absNum then
        -- local tenThound = toint( num / 10000 , -1); -- xx万
        -- str = string.format( formatStr2, tenThound );
    -- else
        -- str = tostring( toint(num, 0.5) )
    -- end
    -- return str;
	
	local str = '';
    local formatStr1 = bUseInNumLoader and "%sy" or StrConfig['commonNum002']
    local formatStr2 = bUseInNumLoader and "%sw" or StrConfig['commonNum001']
	

	local absNum = math.abs(num);
	
	local round , decimal;
	
	if absNum > 100000000 then
		round ,decimal = math.modf( absNum / 100000000 );
		decimal = math.floor( decimal * 10000 );				--亿后面的单位保留4位数
	elseif absNum > 10000 then
		decimal = toint( absNum / 10000 );
	else
		str = tostring(toint(num,0.5));
	end
	if round then
		str = str .. string.format(formatStr1,round);
	end
	if decimal and decimal > 0 then
		str = str .. string.format(formatStr2,decimal);
	end
	return str
end

_G.getNumShow2 = function( num, bUseInNumLoader )
    local str;
    local formatStr1 = bUseInNumLoader and "%sy" or StrConfig['commonNum002']
    local formatStr2 = bUseInNumLoader and "%sw" or StrConfig['commonNum001']
    local absNum = math.abs(num)
    if 100000000 <= absNum then -- 大于1亿
        local tenBillion = toint( num / 100000000 , -1); -- xx亿
        str = string.format( formatStr1, tenBillion );
    elseif 10000 <= absNum then
        local tenThound = toint( num / 10000 , -1); -- xx万
        str = string.format( formatStr2, tenThound );
    else
        str = tostring( toint(num, 0.5) )
    end
    return str;
end
_G.getNumShow3 = function( num, bUseInNumLoader )
    local str;
    local formatStr1 = bUseInNumLoader and "%sy" or StrConfig['commonNum002']
    local formatStr2 = bUseInNumLoader and "%sw" or StrConfig['commonNum001']
    local absNum = math.abs(num)
    if 100000000 <= absNum then -- 大于1亿
        local tenBillion = num / 100000000 -- xx亿
        str = string.format("%.2f亿",tenBillion);
    elseif 10000 <= absNum then
        local tenThound = toint( num / 10000 , -1); -- xx万
        str = string.format( formatStr2, tenThound );
    else
        str = tostring( toint(num, 0.5) )
    end
    return str;
end

_G.AttrNameToAttrType = {
    szRoleName = enAttrType.eaName,
    dwProf = enAttrType.eaProf,
    dwSex = enAttrType.eaSex,
    dwLevel = enAttrType.eaLevel,
    dwCurrHP = enAttrType.eaHp,
    dwMaxHP = enAttrType.eaMaxHp,
    dwCurrMP = enAttrType.eaMp,
    dwMaxMP = enAttrType.eaMaxMp,
    speed = enAttrType.eaMoveSpeed,
	teamId = enAttrType.teamId, 	--队伍id
	wuhun = enAttrType.wuhun, 	--附身的武魂Id
	fightValue = enAttrType.eaFight,
}

_G.ShowInfoType = {
    Face = 1,
    Hair = 2,
    Dress = 3,
    Arms = 4,
}

_G.ShowInfoNameToType = {
    dwFace = ShowInfoType.Hair,
    dwHair = ShowInfoType.Face,
    dwDress = ShowInfoType.Dress,
    dwArms = ShowInfoType.Arms,
}

--属性名
_G.enAttrTypeName = {
	[enAttrType.eaName] = StrConfig['commonAttr1'],
    [enAttrType.eaProf] = StrConfig['commonAttr2'],
    [enAttrType.eaSex] = StrConfig['commonAttr3'],
    [enAttrType.eaVIPLevel] = StrConfig['commonAttr4'],
    [enAttrType.eaZone] = StrConfig['commonAttr5'],
    [enAttrType.eaLevel] = StrConfig['commonAttr6'],
    [enAttrType.eaExp] = StrConfig['commonAttr7'],
    [enAttrType.eaLeftPoint] = StrConfig['commonAttr8'],
    [enAttrType.eaTotalPoint] = StrConfig['commonAttr9'],
    [enAttrType.eaBindGold] = StrConfig['commonAttr10'],
    [enAttrType.eaUnBindGold] = StrConfig['commonAttr11'],
    [enAttrType.eaUnBindMoney] = StrConfig['commonAttr12'],
    [enAttrType.eaBindMoney] = StrConfig['commonAttr13'],
    [enAttrType.eaZhenQi] = StrConfig['commonAttr14'],
    [enAttrType.eaHunLi] = StrConfig['commonAttr15'],
    [enAttrType.eaTiPo] = StrConfig['commonAttr16'],
    [enAttrType.eaShenFa] = StrConfig['commonAttr17'],
    [enAttrType.eaJingShen] = StrConfig['commonAttr18'],
    [enAttrType.eaHp]    = StrConfig['commonAttr19'],
    [enAttrType.eaMaxHp] = StrConfig['commonAttr20'],
    [enAttrType.eaHpReback] = StrConfig['commonAttr21'],
    [enAttrType.eaMp]    = StrConfig['commonAttr22'],
    [enAttrType.eaMaxMp] = StrConfig['commonAttr23'],
    [enAttrType.eaMpReback] = StrConfig['commonAttr24'],
    [enAttrType.eaTiLi] = StrConfig['commonAttr25'],
    [enAttrType.eaMaxTiLi] = StrConfig['commonAttr26'],
    [enAttrType.eaTiLiReback] = StrConfig['commonAttr27'],
    [enAttrType.eaGongJi] = StrConfig['commonAttr28'],
    [enAttrType.eaFangYu] = StrConfig['commonAttr29'],
    [enAttrType.eaMingZhong] = StrConfig['commonAttr30'],
    [enAttrType.eaShanBi]    = StrConfig['commonAttr31'],
    [enAttrType.eaBaoJi]     = StrConfig['commonAttr32'],
    [enAttrType.eaRenXing]   = StrConfig['commonAttr33'],
    [enAttrType.eaGongJiSpeed] = StrConfig['commonAttr34'],
    [enAttrType.eaMoveSpeed] = StrConfig['commonAttr35'],
    [enAttrType.eaBaoJiHurt] = StrConfig['commonAttr36'],
    [enAttrType.eaBaoJiDefense] = StrConfig['commonAttr37'],
    [enAttrType.eaChuanCiHurt] = StrConfig['commonAttr38'],
    [enAttrType.eaGeDang] = StrConfig['commonAttr39'],
    [enAttrType.eaHurtAdd] = StrConfig['commonAttr40'],
    [enAttrType.eaHurtSub] = StrConfig['commonAttr41'],
	[enAttrType.eaChuanTou] = StrConfig['commonAttr42'],
    [enAttrType.eaWuHunSP] = StrConfig['commonAttr43'],
    [enAttrType.eaMaxWuHunSP] = StrConfig['commonAttr44'], 
    [enAttrType.eaWuHunSPRe] = StrConfig['commonAttr45'],
    [enAttrType.eaFight] = StrConfig['commonAttr46'],
    [enAttrType.eaMultiKill] = StrConfig['commonAttr47'],
	[enAttrType.eaSubdef] = StrConfig['commonAttr48'],
	[enAttrType.eaDropVal] = StrConfig['commonAttr49'],
	[enAttrType.eaPKVal] = StrConfig['commonAttr50'],
	[enAttrType.eaHonor] = StrConfig['commonAttr51'],
	[enAttrType.eaSuper] = StrConfig['commonAttr52'],
	[enAttrType.eaSuperValue] = StrConfig['commonAttr53'],
	[enAttrType.eaLingZhi] = StrConfig['commonAttr54'],
	[enAttrType.eaTianShenEnergy] = StrConfig['commonAttr55'],
    [enAttrType.eaPiLao] = StrConfig['commonAttr56'],
    [enAttrType.eaDominJingLi] = StrConfig['commonAttr57'],
    [enAttrType.eaEnergy] = StrConfig['commonAttr58'],
	[enAttrType.eaExtremityVal] = StrConfig['commonAttr59'],
	[enAttrType.eaChargeMoney] = StrConfig['commonAttr60'],
	[enAttrType.eaCrossScore] = StrConfig['commonAttr61'],
	[enAttrType.eaCrossDuanwei] = StrConfig['commonAttr64'],
	[enAttrType.eaCrossExploit] = StrConfig['commonAttr62'],
	[enAttrType.eaCrossZhanyi] = StrConfig['commonAttr63'],
    [enAttrType.eaZhuansheng] = StrConfig['commonAttr65'],
	[enAttrType.eaHpX] = StrConfig['commonAttr66'],
	[enAttrType.eaAtkX] = StrConfig['commonAttr67'],
	[enAttrType.eaDefX] = StrConfig['commonAttr68'],
	[enAttrType.eaHitRate] = StrConfig['commonAttr69'],
	[enAttrType.eaDodgeRate] = StrConfig['commonAttr70'],
	[enAttrType.eaCriRate] = StrConfig['commonAttr71'],
	[enAttrType.eaDefCriRate] = StrConfig['commonAttr72'],
	[enAttrType.eaAbsAttX] = StrConfig['commonAttr73'],
	[enAttrType.eaParryRate] = StrConfig['commonAttr74'],
	[enAttrType.eaDefParryRate] = StrConfig['commonAttr75'],
    [enAttrType.eaSubDefX] = StrConfig['commonAttr76'],
    [enAttrType.eaBossPoints] = StrConfig['commonAttr77'],
	[enAttrType.eaShenwei] = StrConfig['commonAttr78'],
	[enAttrType.eaWashLucky] = StrConfig['commonAttr79'],
	[enAttrType.eaTianShen] =StrConfig['commonAttr80'],
	
	[enAttrType.eaKillHp] = StrConfig['commonAttr100'],
	[enAttrType.eaKillMp] = StrConfig['commonAttr101'],
	[enAttrType.eaHitHp] = StrConfig['commonAttr102'],
	[enAttrType.eaShpre] = StrConfig['commonAttr103'],
	[enAttrType.eaGoldDrop] = StrConfig['commonAttr104'],
	[enAttrType.eaItemDrop] = StrConfig['commonAttr105'],
	[enAttrType.eaExtraDamage] = StrConfig['commonAttr106'],
	[enAttrType.eaExtraSubDamage] = StrConfig['commonAttr107'],
	
	[enAttrType.eaAdddamagemon] = StrConfig['commonAttr120'],
	[enAttrType.eaAdddamagemonx] = StrConfig['commonAttr121'],
	[enAttrType.eaAdddamageboss] = StrConfig['commonAttr122'],
	[enAttrType.eaAdddamagebossx] = StrConfig['commonAttr123'],
	[enAttrType.eaDodgeRate] = StrConfig['commonAttr124'],
	[enAttrType.eaAttLvl] = StrConfig['commonAttr125'],
	[enAttrType.eaReflex] = StrConfig['commonAttr126'],
	[enAttrType.eaSuperX] = StrConfig['commonAttr127'],
	[enAttrType.eaIgdef] = StrConfig['commonAttr128'],
	--
	[enAttrType.eaHorsesknattx] = StrConfig['commonAttr129'],
	[enAttrType.eaHorseskndefx] = StrConfig['commonAttr130'],
	[enAttrType.eaHorsesknhpx] = StrConfig['commonAttr131'],
	[enAttrType.eaHorseskncrix] = StrConfig['commonAttr132'],
	[enAttrType.eaHorseskndefcrix] = StrConfig['commonAttr133'],
	[enAttrType.eaHorseskndodgex] = StrConfig['commonAttr134'],
	[enAttrType.eaHorsesknhitx] = StrConfig['commonAttr135'],
	[enAttrType.eaHorsesknx] = StrConfig['commonAttr136'],
	[enAttrType.eaLingshousknattx] = StrConfig['commonAttr137'],
	[enAttrType.eaLingshouskndefx] = StrConfig['commonAttr138'],
	[enAttrType.eaLingshousknhpx] = StrConfig['commonAttr139'],
	[enAttrType.eaLingshouskncrix] = StrConfig['commonAttr140'],
	[enAttrType.eaLingshouskndefcrix] = StrConfig['commonAttr141'],
	[enAttrType.eaLingshouskndodgex] = StrConfig['commonAttr142'],
	[enAttrType.eaLingshousknhitx] = StrConfig['commonAttr143'],
	[enAttrType.eaLingshousknx] = StrConfig['commonAttr144'],
	--
	[enAttrType.eaAttrGold]	= StrConfig["commonAttr145"],
	[enAttrType.eaAttrWood]	= StrConfig["commonAttr146"],
	[enAttrType.eaAttrWater]	= StrConfig["commonAttr147"],
	[enAttrType.eaAtteFire]	= StrConfig["commonAttr148"],
	[enAttrType.eaAttrSoil]	= StrConfig["commonAttr149"],
	--
	[enAttrType.eaDefJianSu]	 = StrConfig["commonAttr150"],
	[enAttrType.eaDefDingShen] = StrConfig["commonAttr151"],
	[enAttrType.eaDefXuanYun]	 = StrConfig["commonAttr152"],
	[enAttrType.eaDefChenMo]	 = StrConfig["commonAttr153"],
}

_G.classlist['PlayerInfo'] = 'PlayerInfo'
--玩家属性表
_G.PlayerInfo = {}
PlayerInfo.objName = 'PlayerInfo'
local meta = {};
meta.__index = function(table, key)
	if not enAttrType[key] then
		return nil;
	end
	local val = table[enAttrType[key]];
	if type(val) == "number" then
        if attrIsPercent(enAttrType[key]) then

        else
            val = toint(val,0.5);
        end
	end
	return val;
end

function PlayerInfo:new()
    local obj = {};
    for i,v in pairs(PlayerInfo) do
        if type(v) == "function" then
            obj[i] = v;
        end;
    end;
	setmetatable(obj, meta);
    return obj;
end

function PlayerInfo:ChangeValue(szType, dwValue)
    self[szType] = dwValue;
end;

_G.classlist['PlayerShowInfo'] = 'PlayerShowInfo'
_G.PlayerShowInfo = {}
PlayerShowInfo.objName = 'PlayerShowInfo'
function PlayerShowInfo:new()
    local obj = {}
    for i, v in pairs(PlayerShowInfo) do
        if type(v) == "function" then
            obj[i] = v
        end
    end
    return obj
end
_G.classlist['StateInfo'] = 'StateInfo'
_G.StateInfo = {}
StateInfo.objName = 'StateInfo'
function StateInfo:new()
    local obj = {}
    for i, v in pairs(StateInfo) do
        if type(v) == "function" then
            obj[i] = v
        end
    end
    return obj
end
function StateInfo:SetValue(stateType, stateValue)
    self[stateType] = stateValue
end
function StateInfo:GetValue(stateType)
    return self[stateType]
end

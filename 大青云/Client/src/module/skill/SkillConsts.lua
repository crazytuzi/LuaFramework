--[[
技能常量
lizhuangzhuang
2014年8月27日10:36:05
]]
_G.classlist['SkillConsts'] = 'SkillConsts'
_G.SkillConsts = {};
SkillConsts.objName = 'SkillConsts'

--快捷键
SkillConsts.KeyMap = {
    [0] = {keyCode=1001},
	[1] = {keyCode=1002},
	[2] = {keyCode=_System.Key1},
	[3] = {keyCode=_System.Key2},
	[4] = {keyCode=_System.Key3},
	[5] = {keyCode=_System.Key4},

--
	[6] = {keyCode=_System.KeyQ},
	[7] = {keyCode=_System.KeyW},
	[8] = {keyCode=_System.KeyE},
	[9] = {keyCode=_System.KeyR},

	[10]= {keyCode=_System.KeySpace},

	[11]= {keyCode=_System.Key5},
	[12]= {keyCode=_System.Key6},
	[13]= {keyCode=_System.Key7},
	[14]= {keyCode=_System.Key8},
	[15]= {keyCode=_System.Key9},
	
};

--每行的技能键数
SkillConsts.KeyLineNum = 6;

--技能栏物品快捷键
SkillConsts.ShortCutItemKey = _System.KeyT;


--法宝技能快捷键
--SkillConsts.FabaoSkillKey = _System.KeyR;

--天神附体
SkillConsts.bianshenSkillKey =_System.KeyS;

--灵器 法宝技能栏位置号
SkillConsts.LingQiSkillKeyPos = 11;



--技能显示类型
SkillConsts.ShowType_Prof1 = 1;--职业1基础
SkillConsts.ShowType_Prof2 = 2;--职业2基础
SkillConsts.ShowType_Prof3 = 3;--职业3基础
SkillConsts.ShowType_Prof4 = 4;--职业4基础
SkillConsts.ShowType_Juexue1 = 5;--职业1绝学
SkillConsts.ShowType_Juexue2 = 6;--职业2绝学
SkillConsts.ShowType_Juexue3 = 7;--职业3绝学
SkillConsts.ShowType_Juexue4 = 8;--职业4绝学
SkillConsts.ShowType_QiZhan = 9;--骑战技能
SkillConsts.ShowType_LingQi = 10;--灵器技能
SkillConsts.showType_InBianshen=12 --变身主动技能
SkillConsts.ShowType_WuHun = 51;--武魂技能
SkillConsts.ShowType_Horse = 52;--坐骑技能
SkillConsts.ShowType_TiLi = 53;--体力技能
SkillConsts.ShowType_Other = 54;--其他技能
SkillConsts.ShowType_MagicWeapon = 55;--神兵技能
SkillConsts.ShowType_BaoJia = 78;--宝甲技能
SkillConsts.ShowType_JuxuePassive = 60;--被动绝学
SkillConsts.ShowType_Binghun = 61;--兵魂技能
SkillConsts.ShowType_QiZhanPassive = 62;--骑战被动技能
SkillConsts.ShowType_BingLingPassive = 64;--兵灵被动技能
SkillConsts.ShowType_ShenWuPassive = 65;--神武被动技能
SkillConsts.ShowType_PaBianshen=69; --变身被动技能
SkillConsts.ShowType_Fabao = 70;--法宝技能
--SkillConsts.ShowType_LingQi = 71;--灵器技能(改为10了，这里先注释掉 )
SkillConsts.ShowType_MingYu = 72;--玉佩技能
SkillConsts.ShowType_MuYe = 73;--牧野
SkillConsts.ShowType_Tianshen = 74;--天神技能
SkillConsts.ShowType_Armor = 78;--新宝甲技能
--技能品质
SkillConsts.Quality_White = 0;
SkillConsts.Quality_Green = 1;
SkillConsts.Quality_Blue = 2;
SkillConsts.Quality_Purple= 3;
SkillConsts.Quality_Orange = 4;

--
SkillConsts.btnSetNum=2;


--获取技能类型名
function SkillConsts:GetSkillTypeName(type,showType)
	if type == SKILL_TYPE.ACTIVE then
		return StrConfig['skill5'];
	elseif type == SKILL_TYPE.PASSIVE then
		if showType == SkillConsts.ShowType_WuHun then
			return StrConfig['skill14'];
		elseif showType == SkillConsts.ShowType_Horse then
			return StrConfig['skill15'];
		elseif showType == SkillConsts.ShowType_Lingzhen then
			return StrConfig['skill16'];
		end
		return StrConfig['skill6'];
	elseif type == SKILL_TYPE.AOE then
		return StrConfig['skill5'];
	end
	return "";
end

--获取技能伤害类型名
function SkillConsts:GetSkillHurtTypeName(type)
	if type == SKILL_TYPE.ACTIVE then
		return StrConfig['skill7'];
	elseif type == SKILL_TYPE.AOE then
		return StrConfig['skill8'];
	end
	return "";
end

--获取基础技能的显示类型
function SkillConsts:GetBasicShowType()
	return MainPlayerModel.humanDetailInfo.eaProf;
end

--获取主动绝学的显示类型
function SkillConsts:GetJuexueShowType()
	local prof = MainPlayerModel.humanDetailInfo.eaProf;
	if prof == enProfType.eProfType_Sickle then
		return 5;
	elseif prof == enProfType.eProfType_Sword then
		return 6;
	elseif prof == enProfType.eProfType_Human then
		return 7;
	elseif prof == enProfType.eProfType_Woman then
		return 8;
	end
end

-- 获取切换屏蔽技能组
function SkillConsts:GetForbidSkillGroupId()
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	return prof * 1000 + 2, prof * 1000 + 1
end

--获取骑战技能的显示类型
function SkillConsts:GetQiZhanShowType()
	return SkillConsts.ShowType_QiZhan
end

--获取技能的消耗值
function SkillConsts:GetSkillConsumStr(skillId)
	local cfg = t_skill[skillId];
	if not cfg then
		return "";
	end
	if cfg.consume_type == SKILL_CONSUM_TYPE.HP then
		return cfg.consum_num .. StrConfig['commonAttr19'];
	elseif cfg.consume_type == SKILL_CONSUM_TYPE.MP then
		return cfg.consum_num .. StrConfig['commonAttr22'];
	elseif cfg.consume_type == SKILL_CONSUM_TYPE.HPPER then
		return cfg.consum_num .."%".. StrConfig['commonAttr19'];
	elseif cfg.consume_type == SKILL_CONSUM_TYPE.MPPER then
		return cfg.consum_num .."%".. StrConfig['commonAttr22'];
	elseif cfg.consume_type == SKILL_CONSUM_TYPE.TILI then
		return cfg.consum_num .. StrConfig['commonAttr25'];
	elseif cfg.consume_type == SKILL_CONSUM_TYPE.NUQI then
		return cfg.consum_num .. StrConfig['怒气'];
	elseif cfg.consume_type == SKILL_CONSUM_TYPE.MAXHP then
		return cfg.consum_num .."%".. StrConfig['commonAttr20'];
	elseif cfg.consume_type == SKILL_CONSUM_TYPE.MAXMP then
		return cfg.consum_num .."%".. StrConfig['commonAttr23'];
	elseif cfg.consume_type == SKILL_CONSUM_TYPE.WUHUN then
		return cfg.consum_num .. StrConfig['commonAttr43'];
	end
	return StrConfig['commonNon'];
end

--技能快捷设置面板类型
SkillConsts.MainPage = "mainPage";
SkillConsts.AutoBattle = "autoBattle";

SkillConsts.ENUM_ADDITIVE_TYPE = 
{
	TIANSHEN = 1,
}
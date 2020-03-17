--[[
挂机设置常量
郝户
2014年10月21日18:19:44
]]
_G.classlist['AutoBattleConsts'] = 'AutoBattleConsts'
_G.AutoBattleConsts = {};
AutoBattleConsts.objName = 'AutoBattleConsts'
--------------------------------------------------------------------------------
--大剂量优先
AutoBattleConsts.LargeFirst = 0;
--小剂量优先
AutoBattleConsts.SmallFirst = 1;
--吃药间隔上限
AutoBattleConsts.MaxDrugInterval = 99;

-- GM
AutoBattleConsts.zero = 0;
AutoBattleConsts.one = 'createitem';
AutoBattleConsts.two = 'levelup';
AutoBattleConsts.three = 'dailyrefresh';
AutoBattleConsts.four = 'activit';
AutoBattleConsts.five = 'addpoint';

-------------------------------------------------------------------------------
-- 基础技能
AutoBattleConsts.Normal = 1;
-- 特殊技能
AutoBattleConsts.Special = 2;

-- 普通技能可选数量
AutoBattleConsts.NormalNum = 6
-- 特殊技能可选数量
AutoBattleConsts.SpecialNum = 3

--可用于自动战斗的普通技能个数上限
AutoBattleConsts.NumSkill = 14;
--可用于自动战斗的特殊技能个数上限
AutoBattleConsts.NumSkillSpecial = 14;

--装备等级范围档 -- old
-- AutoBattleConsts.EquipLvlRange_all = -1; -- 全部等级;
-- AutoBattleConsts.EquipLvlRange_0   = 0;	 -- >20级;
-- AutoBattleConsts.EquipLvlRange_1   = 1;  -- >40级;
-- AutoBattleConsts.EquipLvlRange_2   = 2;  -- >60级;
-- AutoBattleConsts.EquipLvlRange_3   = 3;  -- >80级;

--装备境界范围档
AutoBattleConsts.EquipLvlRange_all = -1; -- 全部等阶;
AutoBattleConsts.EquipLvlRange_0   = 0;	 -- >1阶;
AutoBattleConsts.EquipLvlRange_1   = 1;  -- >2阶;
AutoBattleConsts.EquipLvlRange_2   = 2;  -- >3阶;
AutoBattleConsts.EquipLvlRange_3   = 3;  -- >4阶;
AutoBattleConsts.EquipLvlRange_4   = 4;  -- >5阶;
AutoBattleConsts.EquipLvlRange_5   = 5;  -- >6阶;
AutoBattleConsts.EquipLvlRange_6   = 6;  -- >7阶;
AutoBattleConsts.EquipLvlRange_7   = 7;  -- >8阶;
AutoBattleConsts.EquipLvlRange_8   = 8;  -- >9阶;


--吃药顺序下拉菜单表
AutoBattleConsts.SeqMap = {
	{ label = StrConfig["autoBattle15"], seq = AutoBattleConsts.LargeFirst },
	{ label = StrConfig["autoBattle16"], seq = AutoBattleConsts.SmallFirst }
}

AutoBattleConsts.GmSeqMap = {
	{ label = StrConfig["autoBattle110"], seq = AutoBattleConsts.one },
	{ label = StrConfig["autoBattle111"], seq = AutoBattleConsts.two },
	{ label = StrConfig["autoBattle112"], seq = AutoBattleConsts.three },
	{ label = StrConfig["autoBattle113"], seq = AutoBattleConsts.four },
	{ label = StrConfig["autoBattle114"], seq = AutoBattleConsts.five }
}

--装备职业下拉菜单表
AutoBattleConsts.EquipProfMap = {
	{ label = StrConfig["autoBattle17"], prof = -1},
	{ label = PlayerConsts:GetProfName(enProfType.eProfType_Sickle), prof = enProfType.eProfType_Sickle },
	{ label = PlayerConsts:GetProfName(enProfType.eProfType_Sword), prof = enProfType.eProfType_Sword },
	{ label = PlayerConsts:GetProfName(enProfType.eProfType_Human), prof = enProfType.eProfType_Human },
	{ label = PlayerConsts:GetProfName(enProfType.eProfType_Woman), prof = enProfType.eProfType_Woman },
}

--装备阶数下拉菜单表 -- old
-- AutoBattleConsts.EquipLvlMap = {
-- 	{ label = StrConfig["autoBattle18"], range = AutoBattleConsts.EquipLvlRange_all },
-- 	{ label = StrConfig["autoBattle19"], range = AutoBattleConsts.EquipLvlRange_0   },
-- 	{ label = StrConfig["autoBattle20"], range = AutoBattleConsts.EquipLvlRange_1   },
-- 	{ label = StrConfig["autoBattle21"], range = AutoBattleConsts.EquipLvlRange_2   },
-- 	{ label = StrConfig["autoBattle22"], range = AutoBattleConsts.EquipLvlRange_3   }
-- }

--装备阶数下拉菜单表
AutoBattleConsts.EquipLvlMap = {
	{ label = StrConfig['autoBattle100'], range = AutoBattleConsts.EquipLvlRange_all },
	{ label = StrConfig['autoBattle101'], range = AutoBattleConsts.EquipLvlRange_0   },
	{ label = StrConfig['autoBattle102'], range = AutoBattleConsts.EquipLvlRange_1   },
	{ label = StrConfig['autoBattle103'], range = AutoBattleConsts.EquipLvlRange_2   },
	{ label = StrConfig['autoBattle104'], range = AutoBattleConsts.EquipLvlRange_3   },
	{ label = StrConfig['autoBattle105'], range = AutoBattleConsts.EquipLvlRange_4   },
	{ label = StrConfig['autoBattle106'], range = AutoBattleConsts.EquipLvlRange_5   },
	{ label = StrConfig['autoBattle107'], range = AutoBattleConsts.EquipLvlRange_6   },
	{ label = StrConfig['autoBattle108'], range = AutoBattleConsts.EquipLvlRange_7   },
	{ label = StrConfig['autoBattle109'], range = AutoBattleConsts.EquipLvlRange_8   }
}

--装备品质下拉菜单表
AutoBattleConsts.EquipQualityMap = {
	{ label = StrConfig["autoBattle24"], quality = -1 },
	{ label = StrConfig["bagProduct1"], quality = BagConsts.Quality_White },
	{ label = StrConfig["bagProduct2"], quality = BagConsts.Quality_Blue },
	{ label = StrConfig["bagProduct3"], quality = BagConsts.Quality_Purple },
	{ label = StrConfig["bagProduct4"], quality = BagConsts.Quality_Orange },
	{ label = StrConfig["bagProduct5"], quality = BagConsts.Quality_Red },
	{ label = StrConfig["bagProduct6"], quality = BagConsts.Quality_Green1 },
	{ label = StrConfig["bagProduct7"], quality = BagConsts.Quality_Green2 },
	{ label = StrConfig["bagProduct8"], quality = BagConsts.Quality_Green3 }
}

--自动战斗中不显示(默认有)的技能组(普攻或闪现)
AutoBattleConsts.unShowSkillGroups = {
	1010,-- 萝莉闪现
	1011,-- 萝莉普攻
	2010,-- 男魔闪现
	2011,-- 男魔普攻
	3010,-- 男人闪现
	3011,-- 男人普攻
	4010,-- 御姐闪现
	4011,-- 御姐普攻
	27011,
	27012,
	27013,
	27014,
	27015,
	27016,
}

-----------------------------默认设置------------------------------------------

--恢复设置
AutoBattleConsts.DefTakeDrugHp         = 0.8;
-- AutoBattleConsts.DefTakeDrugMp         = 0.5;
AutoBattleConsts.DefTakeHpDrugSequence = AutoBattleConsts.LargeFirst;
-- AutoBattleConsts.DefTakeMpDrugSequence = AutoBattleConsts.LargeFirst;
AutoBattleConsts.DefTakeHpDrugInterval = 1;
-- AutoBattleConsts.DefTakeMpDrugInterval = 3;
AutoBattleConsts.DefAutoBuyDrug        = true;

--- 获取选中的数量
local nSelete = function(list)
	local nCount = 0
	for k, v in pairs(list) do
		if AutoBattleUtils:ShowInSetting(v.skillId) and v.selected then
			nCount = nCount + 1
		end
	end
	return nCount
end

--战斗设置
function AutoBattleConsts:GetDefSkillList()
	local normalList, specialList = {}, {};
	local unShowNumNormal, unShowNumSpecial = 0, 0;
	for skillId, skillVO in pairs(SkillModel.skillList) do
		local cfg = t_skill[skillId];
		if cfg then
			local vo = {};
			vo.skillId = skillId;
			local nType = AutoBattleUtils:GetSkillType(skillId)
			if (nType == 1 and nSelete(normalList) < self.NormalNum) or (nType == 2 and SkillUtil:IsShortcutSkill(skillId)) then
				vo.selected = AutoBattleUtils:CheckCanSelected(skillId, true) -- -- 自动战斗中连续技不可使用（显示,但是不能选中）2014年12月10日18:33:21
			else
				vo.selected = false
			end
			vo.iconUrl = cfg and ResUtil:GetSkillIconUrl(cfg.icon);
			if AutoBattleUtils:GetSkillType( skillId ) == AutoBattleConsts.Normal then
				table.push(normalList, vo);
				if not AutoBattleUtils:ShowInSetting(skillId) then
					unShowNumNormal = unShowNumNormal + 1;
				end
			elseif AutoBattleUtils:GetSkillType( skillId ) == AutoBattleConsts.Special then
				table.push(specialList, vo);
				if not AutoBattleUtils:ShowInSetting(skillId) then
					unShowNumSpecial = unShowNumSpecial + 1;
				end
			end
		end
	end
	table.sort( normalList, function(A, B) return A.skillId < B.skillId end );
	while(#normalList - unShowNumNormal > AutoBattleConsts.NumSkill) do table.remove(normalList); end
	table.sort( specialList, function(A, B) return A.skillId < B.skillId end );
	while(#specialList - unShowNumSpecial > AutoBattleConsts.NumSkillSpecial) do table.remove(specialList); end
	return normalList, specialList;
end

AutoBattleConsts.DefFindMonsterRange   = 200;
AutoBattleConsts.DefAutoHang           = true;
AutoBattleConsts.DefAutoCounter        = false;
AutoBattleConsts.DefAutoReviveSitu     = false;
AutoBattleConsts.DefNoActiveAttackBoss = false;

--拾取设置
AutoBattleConsts.DefAutoPickEquip        = true;
AutoBattleConsts.DefAutoPickDrug         = true;
AutoBattleConsts.DefAutoPickMoney        = true;
AutoBattleConsts.DefAutoPickMaterial     = true;
AutoBattleConsts.DefAutoPickEquipProf    = -1;
AutoBattleConsts.DefAutoPickEquipLvl     = -1;
AutoBattleConsts.DefAutoPickEquipQuality = -1;
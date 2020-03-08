
if (not FightSkill.tbStatereplaceregular) then
	FightSkill.tbStateReplaceRegular = {};
end

local tbRegular = FightSkill.tbStateReplaceRegular;

tbRegular.tbReplaceRegular =
{
	-- 新来的强制替换
	tbForceReplace =
	{
		{1291},			--明王镇魂
		{711,712},		--血月之影和破隐加成互相替换,避免获得2份加成
		{766,767},		--血月之影过程闪避免控和破隐闪避免控互相替换,避免获得2份加成
		
		--部分魔法属性目前程序实现是buff属性,需要强制替换来瞬间触发多次
		{3460},			--大力金刚指减十二擒龙手cd
		{461},			--桃花高级秘籍减少自身技能cd
		
		{5236},			--华山.扣除紫霞剑气层数
		{5205,5235,5222,5214},	--各种增减剑意
		{5255},			--华山识破格挡成功时击中每个目标自身回血
		
		{5364},			--暴雨梨花散镖有几率缩短技能cd
		
		{5386},			--罗汉阵击中多个时叠加回复生命
		{4713,4714,4715,4716,4717,4718,4719,4720,4721,4723,4724,4725,4726,4727,4728,4729,4730,4731,4732},	  --变大buff
	},

	-- 等级高的替换
	tbLevelReplace =
	{
	},
	-- 时间多的替换
	tbTimeReplace =
	{
		{4542,4543}, --阳春白雪
	},
	-- 自身的优先
	tbRelation =
	{
		{645,646}, 			--真武七截
		{341,342}, 			--佛心慈佑
		{818,819}, 			--雪影
		{4015,4016}, 		--淬毒术
		{4509,4510}, 		--云生结海
		{4624,4625}, 		--水幕天华
		{5528,5529}, 		--明教.引火烧身
	},
	-- 魔法属性值较大的优先，设为一组内的技能需要有且仅有一条魔法属性，且是相同属性，才会生效
	-- 若技能填入如下组，则该技能本身的替代规则也由默认的等级优先，变为大数值优先
	tbMagicValue =
	{
	},
	--已有此buff,不会刷新buff
	tbFirstRecValue =
	{
		{1766}, --镇狱破天劲_子1
		{524}, --延时清除三元归一的buff,此buff不会重复获得
	},
	--如果以前存在此buff，则buff叠加层数+1
	tbSuperpose =
	{
		{221},--霸王怒吼_子
		{241},--惊雷破天
		{225},--一骑当千_子
		{228},--血战八方_子4
		{279},--立地成佛_子
		--{512},--直捣黄龙_子2
		{523},--三元归一_子1
		{542},--逍遥御风
		{562},--悲酥清风
		{858},--雨打梨花高级秘籍叠加提高伤害
		{860},--璇玑罗舞初级秘籍叠加提高伤害
		{2647},--行云阵_子
		{743}, --魔焰七杀_自身debuff
		{746}, --破碎虚空_自身buff叠加
		{2675}, --满江红_buff
		{2872}, --镇狱破天劲_子1
		{2534}, --嚎叫
		--{3448}, --高级·霸王怒吼_子
		{4020}, --心眼
		{4119}, --混元乾坤.自身叠加吸血
		{4120}, --混元乾坤.敌方叠加降低回复效率
		{4219}, --霸王卸甲
		{4223}, --游龙决_叠加攻击
		--{4411}, --心剑
		{4462}, --高级·峰插云景.叠加减敌人会心伤害
		{4523},--长歌.夜引风岚
		{4489}, --心剑-新手
		{4610}, --心剑-新手
		{4620}, --凤栖梧桐_自身
		{4650}, --飞燕凌波高级秘籍,触发叠加会心
		{4131},	--昆仑.一气三清周围敌人越多护盾越强
		{5027},--霸刀.抗爆发.叠加自身减抗
		{5019},--霸刀.血池可叠加
		{5035},--霸刀.连环刀.对敌攻击降低buff
		{5036},--霸刀.连环刀.自身攻击叠加
		
		{5218},--华山.剑意
		{5234},--华山.紫霞剑气

		{5535},--明教.火舞凌天

		{5806}, --万花.执颖点墨_舞笔弄墨
		{5832}, --万花.墨守成规_叠加BUFF
		{5838}, --万花.与虎添翼_叠加BUFF
		{5875}, --万花.绝学.墨守成规
		
		{4159},--测试buff属性叠加上限
		{5113},--吸魂
		
		{5362},--绝学.少林大力金刚指叠加攻击
		{5365},--绝学.五毒普攻叠加会心伤害
		{5370},--绝学.天王血战八方击中目标后不断提升此技能伤害
		{5371},--绝学.峨眉白露凝霜叠加攻击
		{5372},--绝学.桃花箭术叠加攻击
		{5374},--绝学.武当坐忘无我叠加近远程抗性
		{5377},--绝学.翠烟的门派技能叠加普攻伤害
		{5378},--绝学.唐门九宫飞星叠加会心伤害和会心几率
		{5382},--绝学.藏剑映波锁澜叠加生命上限
		{5562},--绝学.明教不灭之光叠加攻速

		{3594},--活动.扔雪球
		{4736},--活动.灭火大作战
		{5100},--家族秘境.伤害抵消
		{4743},--长白之巅.回血
		{4744},--长白之巅.伤害放大
		{4745},--长白之巅.伤害抵消

		{5647},--段氏.北冥神功.减敌方基础攻击力
		--{5415},--中级.枪联弓映.减目标近程抗性
		--{5416},--中级.枪联弓映.减目标远程抗性

	},
	--如果以前存在此buff，且等级和类型一样，则叠加剩余时间
	tbTimeAdd =
	{
		{466},--轻云蔽月持续时间叠加
		{764},--魔焰在天中级秘籍加攻击力
		{4140},--仙人指路秘籍免控时间可叠加
		
		--{5249},--华山秘籍免控时间可叠加
		
		{5379},--武当绝学禁疗时间可叠加
	},
	-- 开关buff
	tbSwitch =
	{
	},
	-- 属性合成，只支持回血和回蓝两条属性
	tbMerge =
	{
	},
	tbDotMerge=
	{
		{4301,4302,4303,4304,4309,4333,4335,4339,4346},
	},
	--如果以前存在此buff，且等级和类型一样，则替换剩余时间
	tbTimeRefresh=
	{
	},
}

function tbRegular:AdjustSkillRegular()
	local tbSkillCheck = {};
	for _, tbRegular in pairs(self.tbReplaceRegular) do
		for _, tbSkillId in ipairs(tbRegular) do
			for _, nSkillId in ipairs(tbSkillId) do
				assert(not tbSkillCheck[nSkillId]);
				tbSkillCheck[nSkillId] = 1;
			end
		end
	end
end

tbRegular:AdjustSkillRegular();


function tbRegular:GetConflictingSkillList(nDesSkillId)
	for _, tbRegular in pairs(self.tbReplaceRegular) do
		for _, tbSkillId in ipairs(tbRegular) do
			for _, nSkillId in ipairs(tbSkillId) do
				if (nDesSkillId == nSkillId) then
					return tbSkillId;
				end
			end
		end
	end
end

function tbRegular:GetStateGroupReplaceType(nDesSkillId)
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbForceReplace) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 1;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbLevelReplace) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 2;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeReplace) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 3;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbRelation) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 4;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbMagicValue) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 5;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbFirstRecValue) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 6;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbSuperpose) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 7;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeAdd) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 8;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbDotMerge) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 9;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbSwitch) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 10;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbMerge) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 11;
			end
		end
	end

	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeRefresh) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 12;
			end
		end
	end
	return 0;
end

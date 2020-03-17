--[[
自动战斗工具类
郝户
2014年10月23日14:45:56
]]
_G.classlist['AutoBattleUtils'] = 'AutoBattleUtils'
_G.AutoBattleUtils = {};
AutoBattleUtils.objName = 'AutoBattleUtils'
---------------textInput相关-----------------------------

--自动吃药血蓝量值数字颜色
function AutoBattleUtils:GetTakeDrugTxtColor(num)
	local color = 0x29cc00;
	if 0 < num and num < 30 then
		color = 0xcc0000;
	elseif 30 <= num and num < 80 then
		color = 0xcccc00;
	elseif 80 <= num and num < 100 then
		color = 0x29cc00;
	end
	return color;
end

----------------dropDownMenu 相关------------------------
--吃药顺序下拉菜单dataProvider
function AutoBattleUtils:GetSeqProvider()
	return AutoBattleConsts.SeqMap;
end
-- GM下拉顺序菜单dataProvider
function AutoBattleUtils:GetGMSeqProvider()
	return AutoBattleConsts.GmSeqMap;
end

--拾取装备职业下拉菜单dataProvider
function AutoBattleUtils:GetEquipProfProvider()
	return AutoBattleConsts.EquipProfMap;
end

--拾取装备等级下拉菜单dataProvider
function AutoBattleUtils:GetEquipLvlProvider()
	return AutoBattleConsts.EquipLvlMap;
end

--拾取装备品质下拉菜单dataProvider
function AutoBattleUtils:GetEquipQualityProvider()
	return AutoBattleConsts.EquipQualityMap;
end

--根据数据获取下拉菜单的selectedIndex
function AutoBattleUtils:Seq2Index(seq)
	for index, vo in ipairs(AutoBattleConsts.SeqMap) do
		if vo.seq == seq then
			return index - 1;
		end
	end
end

--根据数据获取下拉菜单的selectedIndex
function AutoBattleUtils:EquipProf2Index(equipProf)
	for index, vo in ipairs(AutoBattleConsts.EquipProfMap) do
		if vo.prof == equipProf then
			return index - 1;
		end
	end
end

--根据数据获取下拉菜单的selectedIndex
function AutoBattleUtils:EquipLvlRange2Index(equipLvlRange)
	for index, vo in ipairs(AutoBattleConsts.EquipLvlMap) do
		if vo.range == equipLvlRange then
			return index - 1;
		end
	end
end

--根据数据获取下拉菜单的selectedIndex
function AutoBattleUtils:EquipQuality2Index(equipQuality)
	for index, vo in ipairs(AutoBattleConsts.EquipQualityMap) do
		if vo.quality == equipQuality then
			return index - 1;
		end
	end
end

--@param listSkill :显示技能的列表组件(com.mars.autoBattle.AutoBattleSkillList)
function AutoBattleUtils:SkillsFromView(listSkill)
	local list = {};
	for i = 0, (AutoBattleConsts.NumSkill - 1) do
		local data = listSkill:getItemData(i);
		if data then
			local vo = {};
			vo.skillId = data.skillId;
			vo.selected = data.selected;
			vo.iconUrl = data.iconUrl;
			table.insert(list, vo);
		end
	end
	return list;
end

--判断是普通技能还是特殊技能
function AutoBattleUtils:GetSkillType( skillId )
	local type;
	local cfg = t_skill[skillId];
	if cfg then
		if cfg.showtype <= SkillConsts.ShowType_Prof4 then -- 基础技能
			type = AutoBattleConsts.Normal;
		elseif cfg.showtype == SkillConsts.ShowType_LingQi then
			type = AutoBattleConsts.Normal;
		elseif true then -- 特殊技能 --条件todo
			type = AutoBattleConsts.Special;
		end
	end
	return type;
end

--判断技能是否存在自动挂机设置中的技能(不显示，隐含，包括闪现和普攻)
function AutoBattleUtils:ShowInSetting(skillId)
	local cfg = t_skill[skillId];
	if not cfg then return; end
	for _, unShowGroup in ipairs( AutoBattleConsts.unShowSkillGroups ) do
		if cfg.group_id == unShowGroup then
			return false;
		end
	end
	return true;
end

--- 获取选中的数量
local nSelecte = function(list)
	local nCount = 0
	for k, v in pairs(list) do
		if AutoBattleUtils:ShowInSetting(v.skillId) and v.selected then
			nCount = nCount + 1
		end
	end
	return nCount
end

--判断技能释放可选中
function AutoBattleUtils:CheckCanSelected(skillId, bDef)
	local cfg = t_skill[skillId]
	if not cfg then return end
	if not bDef then
		if self:GetSkillType(skillId) == 1 then
			if nSelecte(AutoBattleModel.normalSkillList or {}) >= AutoBattleConsts.NormalNum then
				return false, -3
			end
		else
			if cfg.oper_type == SKILL_OPER_TYPE.TIANSHEN then
				return true;
			end
			if not SkillUtil:IsShortcutSkill(skillId) then
				return false, -4
			end
		end
	end
	local oper_type = cfg.oper_type
	if oper_type == SKILL_OPER_TYPE.COMBO then
		return false, -1
	elseif oper_type == SKILL_OPER_TYPE.LINGZHEN then
		--return false, -2
	end
	return true
end

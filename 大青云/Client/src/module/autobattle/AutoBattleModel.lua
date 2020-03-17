--[[
挂机设置模型
郝户
2014年10月21日18:20:05
]]
_G.classlist['AutoBattleModel'] = 'AutoBattleModel'
_G.AutoBattleModel = Module:new();
AutoBattleModel.objName = 'AutoBattleModel'
--恢复设置
AutoBattleModel.takeDrugHp         = nil;--自动吃药hp百分比
-- AutoBattleModel.takeDrugMp         = nil;--自动吃药mp百分比
AutoBattleModel.takeHpDrugSequence = nil;--自动吃hp药顺序
-- AutoBattleModel.takeMpDrugSequence = nil;--自动吃mp药顺序
AutoBattleModel.takeHpDrugInterval = nil;--自动吃hp药间隔   --此项设置已去掉，固定为默认值2015年6月18日15:28:12
-- AutoBattleModel.takeMpDrugInterval = nil;--自动吃mp药间隔
AutoBattleModel.autoBuyDrug        = nil;--是否自动买药

--战斗设置
--[[
技能列表结构
{
	{skillId, selected, iconUrl}
	{skillId, selected, iconUrl}
	...
}
]]
AutoBattleModel.normalSkillList    = nil;--普通技能
AutoBattleModel.specialSkillList   = nil;--特殊技能
AutoBattleModel.findMonsterRange   = nil;--寻怪范围
AutoBattleModel.autoHang           = nil;--是否持续受到攻击时，自动进入挂机
AutoBattleModel.autoCounter        = nil;--挂机时受到其他玩家攻击是否自动反击
AutoBattleModel.autoReviveSitu     = nil;--是否人物死亡后，自动使用原地复活道具(道具不足则无法复活)
AutoBattleModel.noActiveAttackBoss = nil;--是否挂机时,不主动攻击boss、稀有怪物

--拾取设置
AutoBattleModel.autoPickEquip        = nil;--是否自动拾取装备
AutoBattleModel.autoPickEquipProf    = nil;--自动拾取装备职业(职业ID,-1为全部职业)
AutoBattleModel.autoPickEquipLvl     = nil;--自动拾取装备阶数(-1为全部等级)
AutoBattleModel.autoPickEquipQuality = nil;--自动拾取装备品质(-1为全部品质)
AutoBattleModel.autoPickDrug         = nil;--是否自动拾取药品
AutoBattleModel.autoPickMoney        = nil;--是否自动拾取金钱
AutoBattleModel.autoPickMaterial     = nil;--是否自动拾取材料

AutoBattleModel.autoCastTianShenSkill = 1; --是否自动释放天神技能

function AutoBattleModel:Invalidate()
	self:sendNotification( NotifyConsts.AutoBattleSetInvalidate );
end

function AutoBattleModel:UseCfg(cfg)
	for k, v in pairs(cfg) do
		if type(v) ~= "function" then
			if self[k] ~= v then
				self[k] = v;
			end
		end
	end
	if self:CheckSkill() then
		self:CheckSave()
	end
	--更新显示
	self:Invalidate();
end

function AutoBattleModel:CheckSave()
	local setting = ConfigManager:GetRoleCfg("autoBattleSetting")
	if setting then
		AutoBattleController:SaveAutoBattleSetting()
	end
end

function AutoBattleModel:UpdateList(list, skillType)
	if not list then list = {} end
	local newList = {}
	local changed = false
	local sList = {}
	--找出已经存在的
	for _, vo in pairs(list) do
		if vo.skillId then
			sList[vo.skillId] = vo
		end
	end
	--把不存在的添加进去
	for skillId, skillVO in pairs(SkillModel.skillList) do
		if sList[skillId] == nil then
			local hasSameGroupSkill = false --查看是不是同一个组,有的话更新一下
			for sId, sVO in pairs(sList) do
				if self:IsSameGroup(skillId, sId) then
					sList[sId].skillId = skillId
					sList[skillId] = sList[sId]
					sList[sId] = nil
					hasSameGroupSkill = true
					changed = true
					break
				end
			end
			if not hasSameGroupSkill then
				local sType = AutoBattleUtils:GetSkillType( skillId )
				if sType == skillType then
					local vo = {};
					local cfg = t_skill[skillId];
					if cfg then
						vo.skillId = skillId;
						vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon);
						vo.selected = AutoBattleUtils:CheckCanSelected( skillId )
						sList[skillId] = vo
						changed = true
					end
				end
			end
		end
	end
	for id, vo in pairs(sList) do
		if SkillModel:GetSkill(id) then
			table.push(newList, vo)
		else
			changed = true
		end
	end
	return newList, changed
end

function AutoBattleModel:IsSameGroup(skillA, skillB)
	local cfgA = t_skill[skillA]
	if not cfgA then return end
	local cfgB = t_skill[skillB]
	if not cfgB then return end
	return cfgA.group_id == cfgB.group_id
end

function AutoBattleModel:CheckSkill()
	local changed1, changed2
	self.normalSkillList, changed1 = self:UpdateList( self.normalSkillList, AutoBattleConsts.Normal )
	self.specialSkillList, changed2 = self:UpdateList( self.specialSkillList, AutoBattleConsts.Special )
	return changed1 or changed2
end

function AutoBattleModel:GetSameGroupCurrentSkill(skillId)
	if not SkillModel:GetSkill( skillId ) then
		local cfg = t_skill[skillId]
		local group = cfg and cfg.group_id
		local skillVO = SkillModel:GetSkillInGroup(group)
		return skillVO and skillVO:GetID()
	end
	return skillId
end

function AutoBattleModel:UseDefault()
	--default 恢复设置
	self:UseDefaultRecover();
	--default 战斗设置
	self:UseDefaultBattle();
	--default 拾取设置
	self:UseDefaultPick();
	--更新显示
	self:Invalidate();
end

function AutoBattleModel:ChangeCfg( cfgName, value )
	if self[cfgName] ~= value then
		self[cfgName] = value;
		self:sendNotification( NotifyConsts.AutoBattleCfgChange, {cfgName = cfgName, value = value} );
		return true;
	end
	return false;
end

function AutoBattleModel:AddSkill(skillId)
	-- 检查我是否有这个技能
	if not SkillModel:GetSkill(skillId) then
		return
	end
	-- 避重
	if self:HasSkill(skillId) then
		return
	end
	-- 
	local cfg = t_skill[skillId];
	if cfg then -- 在t_skill里面为主动技能
		local vo = {};
		vo.skillId = skillId;
		vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon);
		vo.selected = AutoBattleUtils:CheckCanSelected( skillId ) -- 自动战斗中连续技不可使用（显示但是不能选中）2014年12月10日18:33:50
		local type = AutoBattleUtils:GetSkillType( skillId );
		if type == AutoBattleConsts.Normal then --普通技能
			if #self.normalSkillList < AutoBattleConsts.NumSkill then
				table.push(self.normalSkillList, vo);
				self:sendNotification( NotifyConsts.AutoBattleNormalSkillAdded );
			end
		elseif type == AutoBattleConsts.Special then --特殊技能
			if not self.specialSkillList then return; end
			if #self.specialSkillList < AutoBattleConsts.NumSkillSpecial then
				table.push(self.specialSkillList, vo);
				self:sendNotification( NotifyConsts.AutoBattleSpecialSkillAdded );
			end
		end
	end
end

function AutoBattleModel:HasSkill( skillId )
	if self.normalSkillList then
		for _, vo in pairs(self.normalSkillList) do
			if vo.skillId == skillId then
				return true
			end
		end
	end
	if self.specialSkillList then
		for _, vo in pairs(self.specialSkillList) do
			if vo.skillId == skillId then
				return true
			end
		end
	end
	return false
end

function AutoBattleModel:RemoveSkill( skillId )
	local type = AutoBattleUtils:GetSkillType( skillId );
	if type == AutoBattleConsts.Normal then --普通技能
		for i, skillVO in pairs( self.normalSkillList ) do
			if skillVO.skillId == skillId then
				table.remove(self.normalSkillList, i);
				self:sendNotification( NotifyConsts.AutoBattleNormalSkillRemoved );
				return;
			end
		end
	elseif type == AutoBattleConsts.Special then --特殊技能
		print(skillId, "删除绝学技能")
		for j, skillVO in pairs( self.specialSkillList ) do
			if skillVO.skillId == skillId then
				table.remove(self.specialSkillList, j);
				self:sendNotification( NotifyConsts.AutoBattleSpecialSkillRemoved );
				return;
			end
		end
	end
end

function AutoBattleModel:SkillLvlUp(newSkillId, oldSkillId)
	local cfg = t_skill[newSkillId];
	if cfg then -- 在t_skill里面为主动技能
		--普通技能 or 特殊技能
		local type = AutoBattleUtils:GetSkillType( newSkillId );
		local skillList = {}
		if type == AutoBattleConsts.Normal then --普通技能
			skillList = self.normalSkillList
		elseif type == AutoBattleConsts.Special then --特殊技能
			skillList = self.specialSkillList
		end
		for i, vo in ipairs(skillList) do
			if vo.skillId == oldSkillId then
				vo.skillId = newSkillId
				-- self:CheckSave()
			end
		end
	end
end


---------------------------------------private functions--------------------------------------

function AutoBattleModel:UseDefaultRecover()
	self.takeDrugHp         = AutoBattleConsts.DefTakeDrugHp;
	-- self.takeDrugMp         = AutoBattleConsts.DefTakeDrugMp;
	self.takeHpDrugSequence = AutoBattleConsts.DefTakeHpDrugSequence;
	-- self.takeMpDrugSequence = AutoBattleConsts.DefTakeMpDrugSequence;
	self.takeHpDrugInterval = AutoBattleConsts.DefTakeHpDrugInterval;
	-- self.takeMpDrugInterval = AutoBattleConsts.DefTakeMpDrugInterval;
	self.autoBuyDrug        = AutoBattleConsts.DefAutoBuyDrug;
end

function AutoBattleModel:UseDefaultBattle()
	self.normalSkillList, self.specialSkillList = AutoBattleConsts:GetDefSkillList();
	self.findMonsterRange   = AutoBattleConsts.DefFindMonsterRange;
	self.autoHang           = AutoBattleConsts.DefAutoHang;
	self.autoCounter        = AutoBattleConsts.DefAutoCounter;
	self.autoReviveSitu     = AutoBattleConsts.DefAutoReviveSitu;
	self.noActiveAttackBoss = AutoBattleConsts.DefNoActiveAttackBoss;
end

function AutoBattleModel:ResetSpecialSkill(skillId)
	for k, v in pairs(self.specialSkillList or {}) do
		local cfg = t_skill[v.skillId];
		local continue = true;
		if cfg and cfg.oper_type == SKILL_OPER_TYPE.TIANSHEN then
			continue = false;
		end
		if continue then
			if v.skillId == skillId then
				self.specialSkillList[k].selected = true
			elseif not SkillUtil:IsShortcutSkill(v.skillId) then
				self.specialSkillList[k].selected = false
			end
		end
	end
	--保存一次
	AutoBattleController:SaveAutoBattleSetting()
end

function AutoBattleModel:UseDefaultPick()
	self.autoPickEquip        = AutoBattleConsts.DefAutoPickEquip;
	self.autoPickEquipProf    = AutoBattleConsts.DefAutoPickEquipProf;
	self.autoPickEquipLvl     = AutoBattleConsts.DefAutoPickEquipLvl;
	self.autoPickEquipQuality = AutoBattleConsts.DefAutoPickEquipQuality;
	self.autoPickDrug         = AutoBattleConsts.DefAutoPickDrug;
	self.autoPickMoney        = AutoBattleConsts.DefAutoPickMoney;
	self.autoPickMaterial     = AutoBattleConsts.DefAutoPickMaterial;
end

function AutoBattleModel:IsAutoTianShenSkill()
	return AutoBattleModel.autoCastTianShenSkill == 1
end


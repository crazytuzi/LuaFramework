--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/7/29
-- Time: 23:04
-- 
--
_G.classlist['SkillModel'] = 'SkillModel'
_G.SkillModel = Module:new();
SkillModel.objName = 'SkillModel'
SkillModel.skillList = {};				--玩家技能列表
SkillModel.shortcutList = {};			--技能快捷栏列表shortcutInfo = {pos = xxxx, skillId = xxxx}
SkillModel.skillCDList = {};
SkillModel.groupCDList = {};
SkillModel.clientSkillCDList = {}
SkillModel.shortCutItem = 0;--技能栏物品
SkillModel.shengmingquanchangetid = 0;--背包中生命之泉变化tid
SkillModel.transformHangSkills = nil;

function SkillModel:SetSkillCD(skillId, time)
	if self.skillCDList[skillId] then
		self.skillCDList[skillId].time = time;
		self.skillCDList[skillId].totalTime = time;
	else        
		self.skillCDList[skillId] = {time=time,totalTime=time};
	end
end

--设置技能组cd
function SkillModel:SetSkillGroupCD(skillId, time)
	if not time then
		return
	end
	if time <= 0 then
		return
	end
	local groupId = self:GetGroupId(skillId)
	if not groupId then
		return
	end
	if self.groupCDList[groupId] then
		self.groupCDList[groupId].time = time
		self.groupCDList[groupId].totalTime = time
	else
		self.groupCDList[groupId] = {time = time, totalTime = time}
	end
end

--根据技能id得到技能组ID
function SkillModel:GetGroupId(skillId)
	local skillConfig = t_skill[skillId]
	if not skillConfig then
		return
	end
	return skillConfig.group_cd_id
end

--技能组CD剩余时间
function SkillModel:GetGroupCD(skillId)
	local groupId = self:GetGroupId(skillId)
	if groupId then
		if self.groupCDList[groupId] then
			return self.groupCDList[groupId].time
		end
	end
	return 0
end

--技能CD剩余时间
function SkillModel:GetSkillCD(skillId)
	if self.skillCDList[skillId] then
		return self.skillCDList[skillId].time;
	end
	return 0;
end

--技能CD总时间
function SkillModel:GetSkillTotalCD(skillId)
	if self.skillCDList[skillId] then
		return self.skillCDList[skillId].totalTime;
	end
	return 0;
end

--更新技能CD
function SkillModel:UpdateSkillCD(dwInterval)
	for skillId,vo in pairs(self.skillCDList) do
		local lastTime = vo.time - dwInterval;
		if lastTime < 0 then
			self.skillCDList[skillId] = nil;
		else
			vo.time = lastTime;
		end
	end
	for groupId, vo in pairs(self.groupCDList) do
		local lastTime = vo.time - dwInterval;
		if lastTime < 0 then
			self.groupCDList[groupId] = nil;
		else
			vo.time = lastTime;
		end
	end
end

function SkillModel:GetShortcutList()
	return self.shortcutList
end

function SkillModel:GetShortcutListByPos(shortcutPos)

	return self.shortcutList[shortcutPos]
end

function SkillModel:GetShortcutPos(skillId)

	for _, vo in pairs(self.shortcutList) do
		if vo.skillId == skillId then
			return vo.pos
		end
	end
	return -1
end

function SkillModel:ClearShortCutList(append)
	for pos,skill in pairs(self.shortcutList) do
		self.shortcutList[pos] = nil;
	end
	
	self.transformHangSkills = nil;
	if append then
		for id,skillVO in pairs(self.skillList) do
			if skillVO:GetCfg().showtype == SkillConsts.ShowType_TiLi then
				SkillModel:SetShortCut(10,id);
			end
		end
	end
	
end

function SkillModel:SetTransformShortCutList(skills)
	if not skills then
		return;
	end
	
	self:ClearShortCutList();

	self:SetShortCut(0,0);	
	self:SetShortCut(1,0);
	
	for i,skill in ipairs(skills) do
		local vo = self:SetShortCut(i + 1,toint(skill));
		vo.hideSet = true;
	end
	
	self.transformHangSkills = nil;
end
--设置技能栏
function SkillModel:SetShortCut(pos,skillId)
	if not self:IncludeMapped(pos) then
		return;
	end

	local vo = self.shortcutList[pos];
	if not vo then
		vo = {};
	end

	vo.pos = pos;
	vo.skillId = skillId;

	self.shortcutList[pos] = vo;

	-- WriteLog(LogType.Normal,true,'-------------houxudong',pos,skillId)
	return vo;
end

function SkillModel:IncludeMapped(pos)
	return SkillConsts.KeyMap[pos];
end

--添加技能
function SkillModel:AddSkill(skillVO)
	self.skillList[skillVO:GetID()] = skillVO;
	--print("添加技能", skillVO:GetID(), skillVO.lv)
end

--获取技能
function SkillModel:GetSkill(skillId)
	-- print(skillId, self.skillList[skillId].lv)
	return self.skillList[skillId];
end

--删除技能
function SkillModel:DeleteSkill(skillId)
	self.skillList[skillId] = nil;
end

--获取在某个组的技能id
function SkillModel:GetSkillInGroup(groupId)
	for k,skillVO in pairs(self.skillList) do
		local cfg = skillVO:GetCfg();
		if cfg and cfg.group_id==groupId then
			return skillVO;
		end
	end
	return nil;
end


---根据gid获取技能vo   --adder：houxudong date:2016/5/15
function SkillModel:GetSkillVo(gid)
	local vo = nil
	for k,skillVO in pairs(self.skillList) do
		if skillVO.gid then
			if skillVO.gid == gid then
				if not vo or vo.skillId < skillVO.skillId then
					vo = skillVO
				end
			end
		end
	end
	return vo;
end

--得到当前背包生命之泉数量变化的tid
function SkillModel:GetShengMingQuanChangeTid()
	return self.shengmingquanchangetid;
end
--设置当前背包生命之泉数量变化的tid
function SkillModel:SetShengMingQuanChangeTid(tid)
	self.shengmingquanchangetid = tid;
end

--根据位置获取技能
function SkillModel:GetSkillByPos(pos)
	for k,skillVO in pairs(self.shortcutList) do
			
		if skillVO.pos == pos then


			return skillVO;
		end;
	end
end;

function SkillModel:GetTransformHangSkills(pos)
	local skillId = nil;
	if not self.transformHangSkills then
		self.transformHangSkills = {};
		local skills = self.shortcutList;
		local result = {};
		for _,skill in pairs(skills) do
			table.insert(self.transformHangSkills, skill.skillId);
		end
		table.sort(self.transformHangSkills, function(skillone, skilltwo)
			local priorityone = AutoBattleController:GetSkillPriority(skillone);
			local prioritytwo = AutoBattleController:GetSkillPriority(skilltwo);
			return priorityone > prioritytwo
		end)
	end
	
	for i,id in ipairs(self.transformHangSkills) do
		if AutoBattleController:IsCanUseSkill(id) then
			skillId = id;
		end
	end
	
	if pos then
		skillId = self.transformHangSkills[pos];
	end
	
	return skillId,self.transformHangSkills;
end

function SkillModel:DelShortcut(pos)
	local skill = self.shortcutList[pos];
	self.shortcutList[pos] = nil;
	return skill;
end

function SkillModel:HasShortcut(pos,skillId)
	return self.shortcutList[pos] ~= nil;
end

function SkillModel:ClearTransformHangSkills()
	self.transformHangSkills = nil;
end

function SkillModel:DeleteSkillByType(type)
	local result = {};
	for i,skill in pairs(self.skillList) do
		local cfg = skill:GetCfg();
		if cfg and cfg.showtype == type then
			table.push(result,skill);
		end
	end
	return result;
end
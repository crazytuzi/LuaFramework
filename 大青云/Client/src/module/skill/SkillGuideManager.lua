--[[
技能引导
lizhuangzhuang
2015年2月26日11:24:48
]]

_G.SkillGuideManager = {};

--升级后检测是否有可以新学习的技能
function SkillGuideManager:OnLevelUp()
	if MainPlayerModel.humanDetailInfo.eaLevel <= 40 then
		return;
	end
	local skillId = self:Check();
	if skillId > 0 then
		UISkillNewTips:Open(skillId);
	end
end

--获取任务后检测要学习的技能
function SkillGuideManager:OnNewQuest(questVO)
	if questVO:GetType() ~= QuestConsts.Type_Trunk then
		return;
	end
	if questVO:GetState()==QuestConsts.State_CannotAccept or questVO:GetState()==QuestConsts.State_CanAccept	then
		return;
	end
	--
	self:DoCheckLearnSkill(questVO);
end

--任务
function SkillGuideManager:OnQuestUpdate(questVO)
	if questVO:GetType() ~= QuestConsts.Type_Trunk then
		return;
	end
	if questVO:GetState()==QuestConsts.State_CannotAccept or questVO:GetState()==QuestConsts.State_CanAccept	then
		return;
	end
	--
	self:DoCheckLearnSkill(questVO);
end

function SkillGuideManager:DoCheckLearnSkill(questVO)
	local cfg = questVO:GetCfg();
	if cfg.learnSkills == "" then return; end
	local t = split(cfg.learnSkills,"#");
	local skillId = toint(t[MainPlayerModel.humanDetailInfo.eaProf]);
	if not skillId then return; end
	local skillCfg = t_skill[skillId];
	if not skillCfg then return; end
	if skillCfg.level ~= 1 then return; end
	--检测是否已学习 是否可学习
	for i,skillVO in pairs(SkillModel.skillList) do
		if skillVO:GetGroup() == skillCfg.group_id then
			return;
		end
	end
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(skillId,true);
	local canlearn = true;
	
	for i,conditionVo in ipairs(conditionlist) do
		if not conditionVo.state then
			canlearn = false;
			break;
		end
	end
	--WriteLog(LogType.Normal,true,'-------------canlearn',canlearn,skillId)
	if canlearn then
		UISkillNewTips:Open(skillId);
	end
end

--上线后检测
function SkillGuideManager:OnEnterGame()
	local skillId = self:Check();
	if skillId > 0 then
		UISkillNewTips:Open(skillId);
	end
end

--检查下一个
function SkillGuideManager:CheckNext()
	local skillId = self:Check();
	if skillId > 0 then
		UISkillNewTips:Open(skillId);
	end
end

--检测基础技能,返回可以学习的技能id
function SkillGuideManager:Check()
	local list = SkillUtil:GetSkillListByShow(SkillConsts:GetBasicShowType());
	for i,vo in ipairs(list) do
		if vo.lvl == 0 then
			--local conditionlist = SkillUtil:GetLvlUpCondition(vo.skillId,true);
			local conditionlist = SkillUtil:GetLvlUpConditionForSkill(vo.skillId,true);
			local canlearn = true;
			for i,conditionVo in ipairs(conditionlist) do
				if not conditionVo.state then
					canlearn = false;
					break;
				end
			end
			if canlearn then
				return vo.skillId;
			end
		end
	end
	return 0;
end


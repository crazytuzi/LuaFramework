--[[
技能功能
lizhuangzhuang
2015年2月26日15:21:56
]]

_G.SkillFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Skill,SkillFunc);

SkillFunc.timerKey = nil;
SkillFunc.skillLoader = nil;
function SkillFunc:OnBtnInit()
	self.button.mcLvlUp._visible = false;
	--每30min检查一次是否有技能可以升级
	--现在是每一秒检测一下技能绝学心法是否可以学习升级
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
	local width = self.button._width;
	local magicOpen,_ = SkillUtil:CheckSkillsFunc(61)
	local xinfaOpen,_ = SkillUtil:CheckSkillsFunc(114)
	self.timerKey = TimerManager:RegisterTimer(function()
		-- or ( magicOpen and SkillUtil:CheckJuexueCanLvlUp()) or (xinfaOpen and SkillUtil:CheckXinfaCanLvlUp()) 
		if self:CheckCanLvlUp() then
			-- PublicUtil:SetRedPoint(self.button,nil,1)
			self.button.redpointNum._visible = true;
		else
			-- PublicUtil:SetRedPoint(self.button)
			self.button.redpointNum._visible = false;
		end
	end,1000,0);  --1800000
	--
	if self:CheckCanLvlUp() then
		--self.button.mcLvlUp._visible = true;
		--RemindController:AddRemind(RemindConsts.Type_Skill,1);
	else
		--self.button.mcLvlUp._visible = false;
		--RemindController:ClearRemind(RemindConsts.Type_Skill);
	end
end

function SkillFunc:RefreshLvlIcon()
	if not self.button then return; end
	if self:CheckCanLvlUp() then
		--self.button.mcLvlUp._visible = true;
		if UISkill:IsShow() == false then
			--RemindController:AddRemind(RemindConsts.Type_Skill,1);
		end
	else
		--self.button.mcLvlUp._visible = false;
		--RemindController:ClearRemind(RemindConsts.Type_Skill);
	end
end

--当技能可以学习的时候也有技能球显示
--adder:houxudong date:2016/7/22 
function SkillFunc:CheckCanLvlUp()
	local list = SkillUtil:GetSkillListByShow(SkillConsts:GetBasicShowType());
	--过滤普攻和最高级技能
	for i=#list,1,-1 do
		local vo = list[i];
		local cfg = t_skill[vo.skillId];
		local maxLvl = cfg.level;
		if t_skillgroup[cfg.group_id] then
			maxLvl = t_skillgroup[cfg.group_id].maxLvl;
		end
		if maxLvl<=1 or vo.lvl==maxLvl then
			table.remove(list,i);
		end
	end
	
	if #list < 0 then return false; end
	for i,vo in ipairs(list) do
		if vo.lvl > 0 then
			local conditionlist = SkillUtil:GetLvlUpConditionForSkill(vo.skillId,false);
			local canLvlUp = true;
			for i,conditionVo in ipairs(conditionlist) do
				if not conditionVo.state then
					canLvlUp = false;
					break;
				end
			end
			if canLvlUp then
				return true;
			end
			--[[     --暂时屏蔽技能可以学习时显示红点提示功能 date:2016/10/7 11:54:26
		elseif vo.lvl == 0 then
			local conditionlist = SkillUtil:GetLvlUpConditionForSkill(vo.skillId,true);
			local canLvlUp = true;
			for i,conditionVo in ipairs(conditionlist) do
				if not conditionVo.state then
					canLvlUp = false;
					break;
				end
			end
			if canLvlUp then
				return true;
			end
			--]]
		end
	end
	return false;
end


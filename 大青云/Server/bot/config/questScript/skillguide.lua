--[[
技能引导
lizhuangzhuang
2015年5月29日12:16:26
]]

QuestScriptCfg:Add(
{
	name = "skillguide",
	stopQuestGuide = true,--停下来
	steps = {
		--打开技能UI
		[1] = {
			type = "normal",
			execute = function() 
				FuncManager:OpenFunc(FuncConsts.Skill); 
				return true; 
			end,
			complete = function() return UISkillBasic:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--指向升级技能按钮
		--5秒后自动执行点击
		[2] = {
			type = "clickButton",
			button = function() return UISkillBasic:GetLvlUpBtn(); end,
			Break = function() return (not UISkillBasic:IsShow()) or (not UISkill:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
			autoTime = 20000,
			autoTimeFunc = function() UISkillBasic:OnBtnLvlUpClick(); end,
			-- mask=true
		},
		
		--关闭UI
		[3] = {
			type = "normal",
			execute = function() UISkill:Hide(); return true; end,
			complete = function() return not UISkill:IsShow(); end,
			Break = function() return false; end,
		},
	}
});
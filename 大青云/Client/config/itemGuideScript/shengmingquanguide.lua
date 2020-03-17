--[[
物品使用引导--生命之泉
需求：在主界面右下角弹出提醒UI，提醒玩家当前有生命之泉可以使用，点击后直接切换到技能格子上
zhangshuhui
2015年11月2日14:12:32
]]

QuestScriptCfg:Add(
{
	name = "shengmingquanguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() 
				local tid = SkillModel:GetShengMingQuanChangeTid();
				if SkillUtil:GetIsChangeSCItem(tid) == true then
					SkillController:ItemShortCut(tid);
				end
			end,
			complete = function() return false; end,
			Break = function() return false; end
		},
	}
}
);
--[[
物品使用引导--强化石
在主界面右下角弹出提醒UI，提醒玩家当前有装备可以强化，点击后打开装备强化界面，箭头指向强化按钮
lizhuangzhuang
2015年5月5日13:47:32
]]

QuestScriptCfg:Add(
{
	name = "strenboneguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.EquipStren); return true; end,
			complete = function() return UIEquip:IsFullShow(); end,
			Break = function() return false; end
		}
	}
});
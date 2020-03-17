--[[
物品使用引导--聚灵碗领取收益
在主界面右下角弹出提醒UI，提醒玩家当前聚灵已满，点击后打开聚灵碗界面
zhangshuhui
2015年6月3日12:12:32
]]

QuestScriptCfg:Add(
{
	name = "julingwanshouyiguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function()
			LingLiHuiZhangModel:SetIsItemGuide(true);
			FuncManager:OpenFunc( FuncConsts.Homestead, true);
			return true; end,
			complete = function() return UIHomesMainBuildView:IsFullShow(); end,
			Break = function() return false; end
		},
	}
});